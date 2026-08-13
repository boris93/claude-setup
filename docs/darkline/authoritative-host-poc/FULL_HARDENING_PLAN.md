# Deferred Authoritative Host Full-Hardening Plan

**Status:** Preserved as the post-prototype race, recovery, and fault-tolerance
backlog. It is not the active happy-path implementation plan.

**Problem:** Prove or reject whether a small controller can be the authoritative, recoverable host for Codex App Server while stock Codex CLI 0.146.0 remains the only user-facing frontend.
**In scope:** One temporary Git project, one active work item, one logical primary, controller-created planner, implementer, and verifier worker threads, the controller-owned protocol gateway and durable command kernel, and adversarial proof of ordering, durability, approval, ask, isolation, lineage, replacement, compaction, detach/reattach, and crash-recovery behavior.
**Out of scope:** Production UI, a general-purpose schema, notifications, snapshots, scheduling, model tuning, multiple projects or workstreams, native model-spawned agents, and production hardening beyond what is needed to prove or reject this architecture.

## Objective and governing invariant

Build only a disposable proof-of-capability that can produce a decisive evidence
packet. The topology under test is:

`stock Codex CLI -> controller-owned protocol gateway -> Codex App Server`

The gateway is part of the controller's authority boundary. It is the sole
upstream App Server subscriber and the sole issuer of allowlisted mutating App
Server calls. The CLI sees only the gateway's primary-facing protocol projection;
it never receives the raw App Server stream or an App Server endpoint it can use
to bypass the controller. Workers are controller-created App Server threads in
isolated Git worktrees. They neither access the controller's SQLite database nor
create native model-spawned agents.

The controller's durable command kernel uses one append-only journal, a
transactional outbox, stable operation IDs, and reconciliation against App Server
state. No mutation may be sent upstream without a durable intent and operation
ID; no completion may be reported merely from an ambiguous transport result.
Every accepted mutation, rejection, dispatch attempt, observed upstream result,
reconciliation result, and user-visible projection is journaled. The single
shared invariant across the lifecycle and authority tests is:

> One journaled operation has at most one accepted semantic effect, every effect
> is attributable and recoverable, and no CLI, worker, replay, or raw-stream
> consumer can cross the controller's ordering and authority boundary.

## ITD: authenticate the presentation path and keep execution policy controller-owned

### Problem statement

Loopback binding alone does not prove that the stock CLI is the connected
presentation client, and forwarding its `thread/resume` or `turn/start` fields
unchanged lets that client select permission, workspace-root, approval, model,
or environment authority. That contradicts the controller-owned boundary this
PoC is meant to test.

### Option 1: Per-run capabilities plus canonical controller parameters

Give the transport and stock-CLI connection separate unguessable, run-scoped
capabilities. The transport authenticates both hops before forwarding JSON, and
the controller constructs the effective primary mutation from the accepted
thread ID, user input, and its pinned primary policy. Conflicting client
authority fields are rejected before journaling or dispatch.

Pros:

- closes both direct-control and WebSocket connection races;
- keeps permission, roots, approval, model, and environment ownership in the
  controller;
- needs no durable identity, refresh, or operator lifecycle; and
- remains compatible with the stock CLI's remote WebSocket surface.

Cons:

- adds an ephemeral connection capability and one transport handshake; and
- the capability must be kept out of committed evidence even though it expires
  with the run.

### Option 2: Owner-only Unix socket for the internal hop

Replace controller-to-transport TCP with an owner-only Unix socket, while adding
separate authentication for the stock CLI's required WebSocket hop.

Pros:

- uses an operating-system ownership boundary for the internal connection; and
- removes the controller port from the loopback TCP namespace.

Cons:

- still requires WebSocket authentication;
- introduces platform-specific socket-path and cleanup behavior; and
- adds more transport lifecycle surface than the bounded PoC requires.

### Option 3: Treat loopback as trusted

Retain the current connection behavior and rely on the isolated test host.

Pros:

- adds no code or protocol surface.

Cons:

- does not establish the claimed authority boundary; and
- allows another local client to race the stock CLI or submit broader execution
  parameters.

### Decision

Choose Option 1. Capabilities exist only for one live run, are never durable
control-plane state, and are redacted from evidence. Authentication only
identifies the intended transport/presentation path; authorization remains the
controller's exact method and parameter policy. Invalid authentication or
conflicting authority fields fail before a durable mutation intent or upstream
dispatch exists.

#### Capability and handshake contract

| Hop | Creator and carrier | Verifier and accepted wire shape | Lifetime and failure behavior |
| --- | --- | --- | --- |
| Stock CLI to WebSocket transport | The controller creates a public-hop capability for one controller activation; the runner carries it only in an owner-only environment variable to the exact stock CLI launch. | The pinned CLI uses `--remote-auth-token-env`; the transport validates that bearer, for this audience only, before WebSocket upgrade or JSON forwarding. | Valid across sequential detach/reattach while the same activation remains live. Missing, wrong, swapped, stale, or concurrent-owner use is rejected before forwarding. |
| Transport to controller | The controller creates a distinct internal-hop capability and passes it only to its transport child through the child environment. | The controller listener validates an audience-tagged first-message handshake containing a channel kind plus a unique session-connection or audit-attempt identity before treating any following bytes as protocol or audit data. | Valid only for that controller/transport activation. Reuse of the capability across distinct connections is expected; missing, wrong, swapped, stale, or replayed handshake identities close the connection before processing. |

Authentication proves possession of the correct activation capability, not
binary identity. The executed-artifact manifest and PTY launch evidence
separately prove that the accepted happy-path client was stock Codex CLI 0.146.0.
Evidence records only an activation identifier and non-reversible capability
digests. It never records the bearer or internal capability.

The controller listener remains an activation-lifetime acceptor rather than a
one-shot session accept. It services authenticated audit handshakes concurrently
for the entire live epoch while granting at most one concurrent session owner.
Each admitted session receives a monotonically increasing presentation
generation. A new session is rejected while the current generation is active or
draining; takeover is never inferred from silence or a second connection. EOF or
an explicit runner-driven close first fences the old generation, removes all its
downstream waiter mappings, and durably records its closure before the next
generation can be admitted. This permits sequential same-epoch reattachment
without permitting two owners or leaving a half-open stream authoritative.

Client request IDs are qualified by presentation generation and exist only for
projection back to that generation. Controller-assigned upstream request IDs and
durable operation IDs remain generation-independent. A late upstream result is
therefore reconciled against its original operation and may update durable state,
but it can never resolve a waiter in a later presentation generation; the later
generation receives the resulting durable projection instead.

Admission also establishes a journaled projection cutover. Under the projection
lock, the controller selects the latest durable projection sequence `C`, installs
the new generation's buffered live subscription for sequences greater than `C`,
then releases the lock. It emits one replace-style snapshot of primary state
through `C`, drains the buffered events in sequence, and only then switches the
generation to live delivery. Snapshot members and incremental events carry stable
semantic projection IDs, so an interrupted attachment is fenced and a successor
can repeat the snapshot/cutover without append-style duplication. This prevents
a result committed during reattachment from falling between replay and live
delivery or appearing in both.

Audit connections cannot carry protocol JSON, and a session stream cannot carry
audit records. The transport child receives a controller-generated, non-secret
transport-instance identity and numbers audit attempts monotonically within it.
The controller accepts distinct `(transport_instance, audit_sequence)` records,
deduplicates exact re-delivery by that identity, and rejects identity reuse with
different content. Reuse of the internal capability is not itself a duplicate
handshake. This keeps repeated legitimate authentication failures countable
without admitting replayed audit evidence.

The controller hands the public capability to its parent runner through exactly
one run-owned `connection.json` beneath the mode-`0700` runtime directory. It is
created mode `0600`, is never copied or sanitized into evidence, and contains
only the live WebSocket endpoint, public capability, activation identifier, and
controller-selected primary thread ID. The runner verifies owner/mode, reads it
once, unlinks it before launching the CLI, and carries the capability from then
on only in the named owner-process environment variable. Controller failure
before consumption makes the activation unusable and the runner removes the
whole run-owned runtime directory; it never reuses the orphaned secret.

#### Canonical primary mutation contract

For this bounded proof, the presentation client owns only its request ID and one
text prompt. `turn/start` accepts exactly one text input item with no path, URL,
skill, mention, audio, image, or unknown nested variant. `thread/resume` accepts
only the selected primary thread identity. For both methods, the controller
constructs the effective cwd, exact workspace roots, `phase4-read` permission,
`never` approval policy, low reasoning effort, inherited primary model, no
environment override, no output schema, and no legacy sandbox override. A
conflicting or unknown authority-bearing field is rejected rather than ignored.
The pinned stock defaults that accompany those calls—including approval-reviewer,
resume personality, and collaboration developer-instruction identity—are
validated exactly before canonicalization; altered values receive a rejection
with no journal intent or upstream dispatch.

Every downstream frame must be an object-shaped JSON-RPC envelope with a string
method, a valid request identifier when present, and object parameters. Invalid
envelopes receive a bounded per-message protocol error without terminating the
active session. The transport and controller enforce the same fixed maximum
envelope size before forwarding, JSON parsing, or full-body evidence persistence;
oversized input is rejected with only its size/reason recorded.

#### Activation, recovery, and revocation

Capabilities belong to one controller activation epoch. The controller creates
them before either listener admits traffic and records only their digests. CLI
detach does not rotate them while that epoch remains live. Before recovery, the
runner fences and reaps the old transport/controller process group; the new
controller creates a new epoch and capabilities, and a reattached stock CLI
receives only the new public capability. Secrets do not survive controller
death.

Verdict finalization uses one explicit quiescence sequence. The runner asks the
controller to finalize; before signaling any child, the controller durably enters
`finalizing`, rejects new mutations/retries/worker starts, and settles every
operation, worker outcome, ask, and approval to a terminal disposition or an
explicit `unresolved_at_finalization` record. A bounded deadline converts any
remaining ambiguity to an INCONCLUSIVE run; it never authorizes replay. Once no
new upstream dispatch is possible, the controller sends its transport child a
graceful shutdown signal. The transport first closes the public listener and active
WebSocket, so the controller session handler observes EOF, removes that
generation's waiters, and durably records `presentation_retired`. The transport
then drains only the now-bounded set of already accepted audit handlers and sends
an authenticated terminal audit watermark containing its transport-instance
identity and highest issued audit sequence. The controller durably merges every
audit record through that watermark, records `audit_drained`, closes internal
admission, and joins the acceptor. Cleanup and packet staging cannot begin before
this terminal boundary.

Drain has a bounded failure path rather than an infinite wait. If the transport
exits without a watermark, the deadline expires, or a sequence is missing,
conflicting, or post-watermark, the controller records `audit_drain_failed` with
the observed watermark/gaps/conflicts, fences the presentation generation, and
closes internal admission. Cleanup may then proceed, but the packet can seal only
an authoritative failing or inconclusive verdict; it cannot synthesize
`audit_drained` or PASS the affected admission schedules.

After either audit terminal state, the controller stops the App Server input and
subscription, joins every ordinary evidence writer, persists the final durable
snapshot, and records `ordinary_writers_stopped`. Only that record permits packet
staging, inventory, and sealing. Recovery that observes `finalizing` never opens
admission, starts workers, or replays outbox work: after fencing/reaping orphan
processes it resumes only reconciliation, cleanup, and final packet closure. A
crash at any finalization step may therefore yield INCONCLUSIVE, but cannot
return the work item to active execution.

A pre-controller authentication failure is not a mutation rejection. The
transport emits a credential-free attempt record that is causally merged into
the evidence timeline before verdict; authenticated protocol rejections remain
controller-journaled. If the transport cannot deliver or preserve that bounded
audit record, the corresponding competing-client schedule is inconclusive, not
a PASS.

#### Timed-out and late upstream responses

An upstream request registration durably retains its request and operation
identity through a bounded `pending -> timed_out -> late_response -> reconciled`
route. Timeout removes the live waiter with an identity-safe transition and
fences any mutation; a subsequent exact response cannot be delivered to an
abandoned queue or treated as ordinary success. Instead it is correlated to the
timed-out operation, appended as durable late-response evidence, and made
available to explicit reconciliation while the operation remains fenced. An
unknown or duplicate late response is recorded and rejected without changing
semantic state.

#### Final evidence closure and repository inclusion

Historical diagnostic packets remain immutable and locally available, but the
entire `poc/evidence/` runtime tree is excluded from broad Git adds because early
packets predate the final redaction contract. Accepted packet paths and digests
remain in the review ledger; any later publication is a separate sanitized
archive decision. Generated transport binaries and Python bytecode are likewise
excluded from the source change.

After every ordinary packet artifact—including assertion details, sanitized
process logs, source-manifest verification, status, candidate verdict, and the
fixed packet schema—is staged, the finalizer computes the exact sorted inventory
of every pre-seal regular file with its byte length and SHA-256 digest. Missing
required paths, extra paths outside the schema's declared variable subtrees, or a
manifest mismatch invalidates the packet. It then scans those same finalized
bytes for both capability digests. Since the 48-byte random capabilities have a
fixed 64-character URL-safe encoding, the scan hashes every overlapping
candidate of that exact shape and compares it to the persisted public and
internal SHA-256 values; the raw internal capability is never transferred to the
runner.

The only subsequent packet write is an atomic `packet-seal.json`, constructed
outside the packet and renamed into place. Its fixed schema contains the packet-
schema version, exact sorted pre-seal path/length/digest inventory, source-
manifest verification digest, gate booleans, both authoritative capability-scan
results, run status, and any architecture verdict. Any missing, extra, or changed
pre-seal file invalidates the seal, and no packet mutation is permitted afterward. If the
finalizer crashes after scanning but before publication, the absence of a seal
is non-terminal: after proving ordinary writers are stopped, recovery repeats
the read-only inventory and scan and attempts the atomic seal again. Temporary
seal files live outside the packet and are never evidence artifacts.

## Prototype fixtures and exact evidence artifacts

Source/helper ownership is defined once in the required site list below. The
prototype-specific fixtures and evidence artifacts are:

- `poc/fixture/input.txt`: `3`, `1`, `3`, `2`, one value per line.
- `poc/fixture/expected.txt`: `1`, `2`, `3`, one value per line.
- `poc/fixture/WORK_ITEM.md`: produce `output.txt`; checkpoints require
  deduplication and exactly one trailing newline.
- `poc/evidence/<run-id>/`: an immutable, schema-governed evidence packet. Its
  required pre-seal inventory is:
  - surface and provenance: `version.txt`, `help.txt`, `schemas/**`,
    `source-manifest.json`, `manifest-verification.json`, permission/config
    snapshots, and any qualification binding;
  - execution and protocol: `commands.log`, `timeline.jsonl`, sanitized process
    logs/status, `app-server-raw.jsonl`, `gateway.jsonl`, `controller.jsonl`, and
    `cli.jsonl` plus declared raw/TTY captures;
  - durable state: `journal.sqlite`, `journal.jsonl`, `outbox.jsonl`,
    `database-export.json`, and `reconciliation.jsonl`;
  - variable but schema-bounded subtrees: `workers/<worker-id>/**` for worker
    identity/outcomes and `plans/{objects/<sha256>,revisions.jsonl,diffs/**,
    hashes.txt}` for immutable plan lineage;
  - lifecycle and verdict inputs: readiness/preflight/summary documents,
    `crashes.jsonl`, `cleanup.log`, `assertions.json`, `gate-matrix.md`,
    `status.json`, `verdict.md` as the candidate verdict, and
    `packet-schema.json`.
  The sole seal artifact is `packet-seal.json`. It is excluded from its own
  inventory and is the authoritative verdict. `packet-schema.json` names every
  required path, optional schedule-specific path, and allowed variable subtree;
  a path outside that algebra is invalid rather than silently archived.

Evidence packets must redact credentials but preserve exact protocol messages,
operation IDs, sequence numbers, thread and turn IDs, process-exit status, hashes,
timestamps, and assertion inputs needed to reproduce the verdict.

A sealed packet is evidence only for its executed source manifest. That manifest
defines a fixed repository-eligibility algebra for every repo-owned execution
input: repository-relative path, regular-file type, executable bit/mode, byte
length, and SHA-256. It excludes external toolchain binaries and ignored runtime
outputs, which retain their separate manifest roles. A read-only working-tree
comparison is only a pre-review freshness check.

Before commit, the same checker compares every eligible entry against the exact
staged Git tree OID, not working-tree bytes; untracked executed source must be in
that tree, and missing, extra eligible, mode-changed, or content-changed entries
fail. After commit it verifies that the commit's tree OID is the staged tree and
reruns the entry comparison. The staged and commit tree OIDs plus check result
are recorded outside the immutable packet in the review ledger or receipt. Any
mismatch invalidates packet reuse and requires a fresh qualification/runtime run
and seal; historical packet integrity alone never proves a different tree.

## Ordered phases and hard gates

The phases are ordered. A hard-gate failure stops later architecture claims,
though the harness may continue solely to collect diagnostic evidence.

1. **Freeze the supported surface.** Capture the installed Codex CLI and App
   Server versions, relevant help, and generated protocol schemas. Determine the
   exact stock CLI transport the gateway must serve and the exact App Server
   transport the gateway must consume. Demonstrate that stock CLI can connect to
   the gateway and present a gateway-owned primary thread. Fail if this requires
   modifying the CLI, presenting the CLI with the raw App Server endpoint, or
   allowing another upstream subscriber.

2. **Establish the authoritative topology.** Start App Server behind the
   controller-owned gateway. Authenticate the transport and stock CLI with
   distinct per-run capabilities, then construct effective primary mutation
   parameters from controller policy rather than client authority fields. The
   controller creates the work item and primary thread, the CLI exchanges one
   prompt and reply through the gateway, and the evidence correlates CLI
   projection, gateway records, journal sequence, outbox operation, and App
   Server events. Require the gateway to be the sole upstream subscriber and
   require every mutating call to be authenticated, allowlisted, canonicalized,
   and journaled before dispatch. Keep the internal acceptor live for the epoch
   so credential-free audit records remain deliverable during the one admitted
   session.

3. **Prove durable command semantics.** For each allowlisted mutation, persist a
   stable operation ID and intent in the append-only journal with its outbox entry
   in one transaction, dispatch it, observe or reconcile its App Server effect,
   and persist the terminal disposition. Exercise retry and duplicate delivery
   with the same operation ID. Require a gap-free journal, no unjournaled
   mutation, no double semantic effect, and no terminal success inferred only
   from transport acknowledgement. Inject a response timeout followed by the
   exact late response and require durable correlation without abandoned-waiter
   delivery or automatic unfencing.

4. **Create isolated workers under controller ownership.** The controller creates
   planner, implementer, and verifier App Server threads, assigns a distinct Git
   worktree and nonce to each, and records their relationship to the logical
   primary. Qualify the pinned permission configuration separately by giving the
   diagnostic worker the exact `journal.sqlite` path and independently proving
   the read is denied. Normal planner, implementer, and verifier assignments do
   not repeat that adversarial probe or receive the database path. Prove that the
   controller applies the qualified profile and exact worktree environment to
   every worker, that workers cannot issue controller mutations, create native
   model-spawned agents, or publish directly to the CLI. Only controller-mediated
   structured outcomes may affect primary state; only the primary-facing
   projection may reach the CLI.

5. **Race writers and probe raw-stream isolation.** Race a CLI steer/new-turn
   attempt, a queued controller command, a replayed outbox command, a worker
   mutation attempt, and a second would-be App Server subscriber. Require the
   gateway to serialize an allowlisted controller operation or reject the attempt
   before upstream effect. Verify that the CLI and workers cannot observe raw
   worker, approval, token, or internal App Server events. Any invisible,
   bypassing, multiply-owned, or unattributable mutation or raw-stream leak is a
   hard failure.

   First run named negative admission cases: missing, wrong, swapped, stale,
   duplicate, and simultaneous capabilities on both hops. Then submit
   `turn/start` and `thread/resume` variants with conflicting permissions, roots,
   approval, model, environment, legacy sandbox, unknown authority fields, and
   every non-text or path/URL-bearing input variant in the pinned schema. Each
   case must correlate a rejection/audit event with zero durable mutation intent,
   zero outbox row, and zero upstream request. Include scalar/array envelopes,
   invalid method/ID/params types, and an oversized valid JSON frame; each must
   be rejected without terminating the admitted session or persisting the full
   rejected body. Issue multiple distinct audit attempts, replay one exact audit
   identity, and revoke admission while another audit delivery is in flight;
   require unique counting, idempotent re-delivery, a complete terminal
   watermark, and durable drain before cleanup. Digest-scan the finalized packet
   for both exact canary capabilities; any occurrence fails the gate.

6. **Detach and reattach through the gateway.** Start implementation, close the
   CLI while a worker is active, wait for a fixture checkpoint, and reconnect the
   stock CLI to the gateway. Require App Server work to continue without the CLI,
   gateway/controller history to persist, and reattachment to resume the same
   logical primary without replay gaps, duplicate user-visible output, or a new
   upstream subscription. Repeat detachment during active, waiting-for-user, and
   waiting-for-approval states. Add a half-open schedule in which the old
   presentation generation has a timed-out operation and an outbox retry while a
   replacement attach and the exact late upstream response arrive. The
   replacement must be rejected until old-generation closure is durable, then
   admitted with the next generation; the late response must reconcile only the
   original operation and must not resolve a reused client request ID in the new
   generation.

7. **Make business asks durable outcomes and enforce the ask barrier.** The
   planner completes its App Server turn with a structured outcome asking whether
   duplicate values should be retained; the durable ask is not represented as an
   open App Server request. The controller journals that completed outcome,
   transitions the work item to `waiting_for_user`, projects the ask through the
   primary to the CLI, journals one answer, and resumes with exactly one new
   operation. Construct the difficult boundary by arranging for an allowlisted
   mutation to have been dispatched but not resolved when the ask outcome arrives.
   The controller must reconcile and durably classify that in-flight mutation at
   the barrier, must not claim a clean waiting state while its effect is
   ambiguous, and must permit no dependent post-ask work before the answer.

8. **Prove exclusive approval ownership.** The controller creates a dedicated
   `phase8-approval-probe` thread and isolated worktree with the manifested
   `phase8-approval` permission profile: no network, read-only fixture access,
   write access only to one run-owned sentinel directory, and
   `approvalPolicy: on-request`. Its fixed role prompt requests one exact command
   that causes App Server to emit a raw approval before writing that sentinel.
   This is the sole approval-policy exception; the presentation primary and
   ordinary workers remain pinned to `never`. While approval is pending, attempt to
   answer through the attached CLI protocol, a second client, a worker, and a
   replayed/stale response. Require the controller's raw-stream subscriber to be
   the sole approval owner and only one controller-authorized primary decision to
   resolve it. Denial creates no sentinel; approval creates exactly one. Direct,
   stale, duplicated, or wrong-owner resolution is a hard failure.

   Run named crashes at four approval boundaries: after raw request observation
   but before pending-approval persistence; after persistence but before decision;
   after decision dispatch but before its response/effect record; and after the
   sentinel effect but before terminal disposition. The pending request has a
   stable operation/fingerprint identity. Recovery never blindly resends a
   decision: it correlates surviving App Server thread/item state, decision
   response, and exact sentinel state, then durably classifies no effect or one
   attributable effect. If the pinned surface cannot restore or conclusively
   classify a boundary, the exclusive-approval architecture gate fails.

9. **Persist immutable, content-addressed plan lineage.** Materialize v0 (sort
   values), v1 (deduplicate after the user answer), and v2 (preserve exactly one
   trailing newline after verifier feedback) as content-addressed objects.
   Journal each immutable revision's object hash, parent hash, trigger event,
   worker provenance, and unified diff. Inject crashes between object creation,
   durable revision-reference publication, and current-plan advancement. Require
   recovery to ignore unreferenced objects safely, reject missing or corrupt
   referenced objects, reconstruct the complete chain byte-for-byte, and detect
   or reject mutation against an old plan version.

10. **Replace physical workers and compact context.** Kill a worker after partial
    output and create a physically new App Server thread in a fresh isolated
    worktree. Supply only the durable primary summary, current plan object hash,
    bounded content-addressed artifact references, and the replacement assignment;
    do not reuse hidden context. Force context compaction on a surviving worker
    and prove it can continue from the same durable inputs and attribution.
    Physical thread replacement and forced compaction are both mandatory; a proof
    based only on resuming the same thread fails this gate.

11. **Crash controller and App Server at ambiguous boundaries.** Inject separate
    controller crashes after durable intent but before dispatch, after upstream
    dispatch but before acknowledgement, after observable App Server effect but
    before terminal journal state, after ask recording but before answer routing,
    and after answer recording but before resume dispatch. Also crash App Server
    before and after an effect whose controller result is ambiguous, both with the
    controller alive and during controller restart. Recover via the journal,
    outbox, stable operation IDs, App Server thread/list/read/resume state, and
    explicit reconciliation. Require no lost or duplicated semantic action, exact
    pending ask or approval restoration, the correct next sequence number, and no
    success classification where the surviving evidence is insufficient.

12. **Exercise adversarial compositions and decide.** Run distinct named
    schedules, not three repetitions of one happy path. At minimum cover:
    streaming reconnect plus outbox retry; two-client attach plus approval race;
    ask arrival plus an unresolved in-flight mutation; CLI detach plus App Server
    crash; controller crash plus worker completion; plan-object crash plus worker
    replacement; and compaction plus stale-plan submission. Record ownership,
    state transitions, replay boundaries, duplicates, rejected attempts, dropped
    events, and cleanup for every schedule. Every hard capability must pass under
    all schedules in which it is exercised.

## Site list and required behavior

- `poc/native-cli.sh`: connects stock CLI only to the gateway and captures the
  exact supported authenticated invocation; it never exposes an App Server
  bypass or persists the bearer value.
- `poc/transport/main.go`: owns the public bearer check, internal-hop handshake,
  presentation/audit identity assignment, connection exclusivity, fixed frame
  limit, credential-free admission-attempt record, and terminal audit watermark;
  it does not authorize protocol methods or parameters.
- `poc/run.sh` and `poc/pty_tui.py`: carry the public capability only through
  owner-only runtime state/environment, launch the pinned stock CLI, and redact
  all persisted command/environment surfaces.
- `poc/controller.py:protocol gateway`: terminates the CLI-facing protocol,
  authenticates both transport hops through an activation-lifetime acceptor,
  owns presentation generations and audit deduplication/drain, maintains the sole
  App Server subscription, validates bounded JSON-RPC envelopes, canonicalizes
  primary mutations, filters the raw stream, and projects only primary-facing
  state. It has no production path that bypasses `DurableKernel`.
- `poc/kernel.py`: validates the mutation allowlist, assigns stable operation IDs
  and journal sequence, atomically records intent/outbox, dispatches, persists
  timeout and exact late-response correlation, reconciles ambiguity, and
  publishes terminal disposition without delivering an abandoned waiter.
- `poc/controller.py:state machine`: owns active, waiting-for-user,
  waiting-for-approval, recovering, compacting, replacing, completed, and failed
  transitions and their barriers.
- `poc/controller.py:worker lifecycle`: creates App Server worker threads and
  isolated worktrees, bounds their inputs, accepts structured outcomes, forces
  compaction, and performs physical replacement without hidden context.
- `poc/controller.py:approval mediation`: consumes raw approval requests,
  rejects non-owner responses, and forwards exactly one authorized decision.
- `poc/controller.py:ask mediation`: converts completed structured worker outcomes
  into durable business asks, projects/records answers, and resumes once.
- `poc/controller.py:plan lineage`: stores and verifies content-addressed objects,
  advances immutable revision references, and rejects stale plan submissions.
- `poc/journal.sqlite`: is writable only by the controller and composes the
  journal, outbox, projections, asks, approvals, operations, workers, and plan
  references without permitting mutable history.
- `poc/roles/{primary,planner,implementer,verifier,approval-probe}.md`: constrain authority,
  database access, output visibility, structured outcomes, plan-hash checks, and
  artifact provenance at each worker boundary.
- `poc/fixture/WORK_ITEM.md`: supplies the three observable plan revisions and
  deterministic correctness checkpoints without importing broader product scope.
- `poc/run.sh`: selects named adversarial schedules, creates isolated run state,
  pins versions, and drives only allowlisted public harness controls.
- `poc/crash-controller.sh`: targets named process/boundary points and records
  crash identity without deleting durable state.
- `poc/evidence.py`: enforces owner-only evidence permissions, packet-schema
  membership, the exhaustive pre-seal inventory, chunk-boundary-safe overlapping
  candidate scanning against both capability digests, and atomic seal publish or
  unsealed-packet retry.
- `poc/provenance.py`: creates and verifies the exact source, executable,
  configuration, permission-profile, role-prompt, and command-chain manifests
  used by qualification and runtime. Its read-only repository-inclusion mode
  checks working-tree freshness, exact staged-tree entries/modes/OID before
  commit, and the resulting commit tree/OID afterward.
- `poc/diagnose_phase4_tool_surface.py`: is the sole qualification harness that
  receives the exact controller SQLite path, binds the native Codex launcher and
  executable provenance, and proves the pinned permission profile denies that
  read; normal runtime workers never receive the path or run this probe.
- `poc/probe_gateway_auth.py`: owns only public/internal admission test traffic,
  unique audit identities, duplicate delivery, concurrent-owner, revoke-during-
  audit, and drain-watermark schedules.
- `poc/assert.py`: correlates raw stream, journal/outbox, CLI projection, worktree
  artifacts, hashes, process state, cleanup, and the supplied isolation-
  qualification packet into hard-gate assertions, run status, and any
  architecture verdict. It
  also proves every negative admission/canonicalization case has no mutation or
  dispatch, scans finalized bytes against both capability digests, and publishes
  the atomic no-more-writes packet seal.
- `poc/test_controller.py`, `poc/test_kernel.py`, `poc/test_evidence.py`,
  `poc/test_provenance.py`, `poc/test_assertions.py`, `poc/test_phase4.py`, and
  `poc/transport` tests: cover the accepted per-method input algebra, malformed
  and oversized envelopes, exact stock defaults, presentation-generation
  fencing and replay/live cutover, timed-out/late-response correlation, audit
  replay/drain/failure, approval-probe isolation, exhaustive sealing and
  recovery, repository-source binding, plus missing, wrong, swapped, stale,
  duplicated, and simultaneous hop capabilities.
- `poc/.gitignore`: excludes local evidence packets, generated transport
  binaries, Python bytecode, and cache directories without deleting historical
  packets.
- `poc/evidence/<run-id>/`: is the read-only audit surface for every supported,
  undocumented, experimental, accepted, rejected, and ambiguous behavior used in
  the decision.

At every site, preserve the governing invariant: controller-only authority,
durable-before-dispatch intent, attributable at-most-once semantic effect,
fail-closed ambiguity, worker and raw-stream isolation, and immutable lineage.

## Temporal composition

### Transition surface

| Canonical event | Authority and transition | Observable effect and durable record | Retry and cleanup |
| --- | --- | --- | --- |
| Start or activation | Controller creates a fresh capability epoch, authenticates its transport child, then creates or reacquires the logical primary and workers from journaled state; CLI attachment changes presentation ownership only. | Non-secret epoch/capability digests and thread/worktree identities precede listener admission and projected activity. | Retry uses the same operation ID inside the live epoch; orphan processes/listeners are fenced before a replacement epoch. |
| Normal completion or commit | Controller accepts a structured worker outcome, verifies its plan and artifact hashes, records terminal state, then projects completion. | Journal terminal event and any content-addressed artifact reference precede CLI completion. | Duplicate outcomes are idempotent; extra worktrees/processes are cleaned after evidence capture. |
| Abnormal failure before visible effect or durable partial completion | Current controller-owned operation becomes failed or retry-eligible according to durable evidence; workers cannot decide. | Failure and evidence basis are journaled before projection. | Safe retries retain the operation ID; otherwise replace the worker or fail closed. |
| Pause or suspension | A durable business ask, raw approval request, detach policy, or explicit barrier moves ownership to the controller's waiting state. Presentation detach fences that generation but does not cancel execution ownership. | Waiting reason, barrier sequence, owner, pending payload, still-live capability epoch, and presentation-generation closure are journaled without persisting secrets; CLI may display only the mediated form. | No dependent mutation is eligible; unresolved earlier operations are reconciled before the state is declared stable. A half-open generation cannot be silently replaced. |
| Resume or reacquisition | One journaled answer, approval decision, authenticated reconnect after durable old-generation closure, or recovered lease returns control to the kernel. | A single resume operation links to the pending state; a reconnect receives the next presentation generation and a durable-state projection. | Same-epoch reconnect may reuse the live public capability but not the old generation or waiter namespace; a recovered controller issues a new epoch/capability after fencing the old listeners. Duplicate/stale resumes are rejected. |
| Cancellation, interruption, or abort | Controller alone cancels an operation or worker thread and records whether upstream effect is still possible. | Cancellation intent and reconciled result are distinct journal events. | Ambiguous cancellation remains recovering; replacement starts only after ownership is settled or explicitly fenced. |
| Supersession, handoff, or owner change | Physical replacement creates a new thread/worktree and supersedes the old worker; CLI reconnect changes no upstream owner. | Old/new identities, durable input set, current plan hash, and supersession reason are linked in the journal. | Late old-worker output is rejected; old resources are retained until attribution assertions finish, then cleaned. |
| Retry or replay | Kernel re-dispatches a pending outbox record with its stable operation ID; it never synthesizes a new semantic command. | Dispatch attempts and reconciliation observations append to history without rewriting intent. | Terminal operations are not re-effected; non-idempotent ambiguity blocks until authoritative reconciliation or failure. |
| Restart or recovery | Runner first reaps the old controller/transport group; restarted controller reconstructs projections and pending outbox from SQLite, creates a new capability epoch, and correlates App Server state by durable identities. If durable state is `finalizing`, it instead resumes the no-admission finalization path and creates no new epoch. | Recovery epoch, non-secret capability digests, observed App Server state, and each reconciliation decision are journaled before new listener admission or work; finalization recovery records only reconciliation, cleanup, writer-stop, and closure events. | Old capabilities are invalid because their listeners are fenced; unresolved operations remain fenced, and orphaned workers are resumed only when identity and state are proven. Finalization recovery never resumes workers or replays outbox commands. |
| Finalization | Controller first journals `finalizing`, fences new commands/retries/worker starts, and durably settles or classifies all semantic work before transport quiescence and App Server shutdown. | Operation/worker/ask/approval dispositions, presentation retirement, audit terminal state, final durable snapshot, and `ordinary_writers_stopped` precede packet staging. | A crash resumes only finalization. Unresolved work or audit failure yields FAIL/INCONCLUSIVE; neither can reopen admission or support PASS. |
| Rollback or compensation | Controller applies compensation only where the test defines a reversible effect; history and plan objects remain immutable. | Compensation has its own operation ID and links to the affected operation. | Compensation is itself reconciled; lack of safe compensation causes a hard failure rather than history mutation. |
| Partial completion or one-sided effect/persistence success | Kernel enters recovering whenever object/effect, acknowledgement, journal state, projection, or request timeout/late response succeed separately. | The surviving side and uncertainty are appended; an exact late response is linked to its fenced operation and terminal success waits for reconciliation. | Safe orphan objects are ignored, missing referenced objects fail closed, and possible external effects are never blindly replayed. |
| Concurrent overlap or reordering | Gateway orders all accepted mutations by journal sequence and ask/approval/plan barriers; raw events are correlated rather than trusted by arrival order. | Accepted/rejected attempts and observed reordering are recorded in the merged timeline. | Only independent read/projection activity may overlap; dependent or cross-owner mutations are serialized or rejected. |

### Effect ordering

Mutation intent and outbox publication are atomic and precede upstream dispatch.
Observed App Server effect precedes terminal success, while terminal journal state
precedes user-visible success. Content-addressed plan object creation precedes a
durable reference, and a valid durable reference precedes current-plan
advancement. A CLI projection may lag and replay durable state, but it may never
become the source of truth. When either side of an effect/record pair succeeds
alone, the operation remains explicitly ambiguous and fenced until reconciliation
proves a terminal result or the gate fails.

### Execution ownership

The controller owns the gateway subscription, command kernel, journal/outbox,
logical primary, pending asks and approvals, plan head, worker creation,
compaction, replacement, and recovery. App Server owns execution of controller-
issued thread/turn operations but has no business-level durability authority.
The CLI owns only its presentation connection. A worker owns execution within
its assigned thread and worktree until completion, cancellation, or supersession;
it never owns durable coordination state. Controller death leaves durable
ownership recorded but inactive until reacquisition. App Server death leaves
effects unresolved until reconciliation. CLI detachment never cancels work.

### Concurrency constraints

- Exactly one gateway subscription and one active controller recovery epoch may
  issue mutations for the proof run.
- At most one presentation generation may be active or draining. Sequential
  generations share the logical primary, but their client request-ID namespaces
  and waiter mappings never overlap.
- Each transport instance has one monotonic audit sequence. Shutdown reaches an
  audit terminal state through either a durably verified watermark
  (`audit_drained`) or bounded `audit_drain_failed`; protocol sessions and audit
  channels cannot substitute for one another, and only the drained state is
  eligible for PASS.
- Journal sequence orders accepted mutations; stable operation ID deduplicates
  dispatch/replay; App Server arrival order alone grants no authority.
- Ask, approval, recovery, replacement, and plan-head barriers reject dependent
  operations until their owner and preceding outcomes are durable and unambiguous.
- Worker read/compute activity may overlap, but artifact publication must include
  the assigned plan hash and controller-accepted provenance.
- The gateway must not wait on CLI or worker input while holding authority that
  prevents recording raw App Server progress; durable recording and projection
  remain separable.
- No normal runtime worker or CLI process receives SQLite access, the raw-stream
  subscription, or capability needed to mutate App Server outside the gateway.
  The dedicated Phase 4 qualification harness receives the exact SQLite path so
  that denial is proven directly; path secrecy is not an isolation mechanism.

### Adversarial composition cases

The named schedules in gates 5, 6, and 12 deliberately compose retry with
half-open detach, generation-fenced reconnect, and an exact late response;
distinct and replayed audit delivery with revoke and drain; retry with reconnect,
approval with competing clients, ask transition with an already in-flight
mutation, all four approval persistence/decision/effect crash boundaries, detach
with App Server death, controller death with worker completion,
lineage publication with crash, replacement with late old-worker output,
compaction with stale plan state, simultaneous controller/App Server recovery,
finalizing with an in-flight operation/worker outcome, and finalizer crashes
before child shutdown, after audit termination, and between inventory scan and
seal publication.
Each schedule varies event placement at the ambiguous boundary and asserts the
same invariant from journal, raw-stream, filesystem, process, and CLI evidence;
three identical clean executions are not accepted as recovery evidence.

## Verdict and cleanup

Every sealed run has one `run_status`: `PASS`, `FAIL`, or `INCONCLUSIVE`. A
conclusive run also produces exactly one of three architecture verdicts:

- **Pass — stable reusable host:** every hard gate passes under its adversarial
  schedules, every accepted effect is reconciled and attributable, and correctness
  uses only documented/supported behavior on the pinned surface.
- **Pass — version-pinned experimental MVP only:** every hard correctness gate
  passes, but at least one required transport, subscription, ownership, replay, or
  recovery behavior depends exclusively on experimental or undocumented behavior.
  Name every such dependency and pin the exact version/schema.
- **Fail — reject the architecture:** any hard capability fails, including stock
  CLI incompatibility with the gateway, raw-stream or mutation bypass, competing
  approval ownership, unresolved or duplicated effect, ask-barrier violation,
  mutable/broken lineage, inability to compact and physically replace a worker,
  detach cancellation, or unrecoverable controller/App Server crash boundary.

**Inconclusive — rerun required** is a run status, not a fourth architecture
verdict. Use it when required evidence is missing, internally conflicting, or
not durably drained and no architecture failure was demonstrated. Its seal has
`architecture_verdict: null`, names the invalid schedules and bounded failure
reason, permits cleanup, and cannot support an architecture claim. A subsequent
run starts a fresh capability epoch and packet; it never edits or upgrades the
inconclusive packet.

After the last schedule, execute the explicit public-close, presentation-retire,
audit-drain-or-drain-failed, and internal-close quiescence sequence; then stop and
reap remaining workers and App Server.
Remove only run-specific sentinels, sockets, temporary worktrees/repository,
databases, processes, and private capability handoff state. Record every stopped
process and removed path in `cleanup.log`. Only after those records are closed,
stage sanitized logs, source-manifest verification, assertions, status,
candidate verdict, and packet schema; validate the exhaustive pre-seal inventory
and scan those exact bytes against both capability digests; then atomically
publish the schema-bounded final packet seal and issue its authoritative verdict.
An unsealed packet may repeat only this read-only validation and atomic publish
after proving ordinary writers stopped. No artifact may mutate after a valid
seal; never remove shared Codex state or unrelated processes.
