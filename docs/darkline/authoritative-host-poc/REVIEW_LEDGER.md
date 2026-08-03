# PoC Review Ledger

Scope: chronological review evidence for the authoritative-host PoC. The first
section records the deferred full-hardening implementation track; the final
section records the active low-stakes vertical-plan review. Historical entries
remain unchanged even when a later ITD changes which track is active.

## CR-001 — Worker evidence violations did not universally fail the gate

- Discovery: code-review round 1
- Severity / scope: significant / in-scope
- Status: resolved
- Obligation: every recorded worker-evidence violation must make a Phase 4 PASS
  impossible.
- Resolution: `verify_phase4_worker_evidence()` now exposes an exhaustive
  `all_worker_evidence_invariants_hold` gate. `completion.json` is compared as an
  exact record, including worker identity, turn status, and outcome hash.
- Verification: negative tests cover every forbidden worker item type and each
  previously unchecked completion field. The final runtime packet passes the
  exhaustive gate with an empty violations list.

## CR-002 — Runtime PASS was not bound to its isolation qualification

- Discovery: code-review round 1
- Severity / scope: significant / in-scope
- Status: resolved
- Obligation: a runtime isolation claim must consume and independently validate
  one exact passing qualification packet.
- Resolution: `run.sh` now requires a qualification packet. `assert.py`
  independently recomputes its raw command/result assessments, compares the
  effective and runtime permission semantics, checks Codex version and
  provenance, and records a digest in `qualification-binding.json`.
- Verification: qualification packet
  `20260801T170000Z-phase4-read-write-qualification-review-fixed` passes; runtime
  packet `20260801T173000Z-phase4-authoritative-host-review-fixed` binds its
  SHA-256 `609b7c4d9b57cc491e0f8fca4c2d97aa7e25e6cb0b10aeca4479e99be9d87656`
  and passes all gates.

## CR-003 — Executed-artifact provenance omitted the native Codex binary

- Discovery: code-review round 1
- Severity / scope: significant / in-scope
- Status: resolved
- Obligation: provenance must identify the executable that implements Codex App
  Server and CLI behavior, not only its Node launcher.
- Resolution: provenance now resolves and separately hashes the Node launcher,
  Codex package metadata, and platform-native executable. The qualification
  harness records the same three artifacts plus its own source.
- Verification: the final runtime manifest verifies all artifacts before cleanup;
  the native executable is 311001136 bytes with SHA-256
  `2e863156ed35ecc5253b1e2f907a9143077b9f7cb51942070c61996471ff6e04`.

## Pattern assessment

All three findings were instances of one evidence-closure defect: the prose PASS
claim was stronger than the mechanically consumed evidence. The repair therefore
tightened existing gates and provenance rather than adding a new runtime
authority, protocol, or lifecycle.

## SR-001 — Downstream client could select execution authority

- Review epoch / iteration: 1 / security phase
- Source: security-researcher
- Severity / scope: blocking / in-scope
- Location: `poc/transport/main.go`, `poc/controller.py:downstream gateway`
- Suspected surface: presentation authentication and controller-owned mutation
  policy
- Lifecycle: resolved
- Statement: unauthenticated loopback clients could submit primary mutations
  with broader permissions, roots, approvals, model, or environment settings.
- Fix applied: the controller creates distinct activation-scoped public and
  internal capabilities, the transport authenticates both hops before protocol
  forwarding, and the controller rejects or reconstructs primary mutations
  before any journal intent or upstream dispatch. The private public-capability
  handoff is owner-only, single-use, and removed before the stock CLI starts;
  final evidence contains only capability digests.
- Resolution challenge: `local-design-flaw` at architecture altitude. Add two
  ephemeral per-run connection capabilities and controller-side canonical
  primary parameters; no durable identity or credential lifecycle. Update and
  review the plan, implement, then restart holistic code/security review.
- Verification: runtime packet
  `20260801T190000Z-phase4-authoritative-host-auth-fixed-r2` passes all 49
  gates. It records two pre-upgrade authentication denials, one authenticated
  stock-CLI admission, exact controller-built `thread/resume` and `turn/start`
  parameters, capability revocation before both child cleanups, a successful
  post-cleanup exact-canary scan, and no surviving `connection.json`.

## SR-002 — Qualification raw evidence was neither secure-opened nor leak-gated

- Review epoch / iteration: 1 / security phase
- Source: security-researcher
- Severity / scope: significant / in-scope
- Location: `poc/diagnose_phase4_tool_surface.py`, `poc/assert.py`
- Suspected surface: qualification evidence handling
- Lifecycle: resolved
- Statement: raw qualification messages were mode `0664`, unredacted, and not
  scanned before accepting the packet.
- Fix applied: qualification JSONL is deep-redacted before owner-only append;
  all qualification artifacts use secure owner-only writes. The producer and
  runtime consumer independently scan non-schema evidence and verify every
  packet path has no group/other permission bits before accepting the
  qualification.
- Verification: qualification packet
  `20260801T180000Z-phase4-read-write-qualification-auth-fixed` passes with an
  empty `evidence_leaks` list, an empty `insecure_evidence_paths` list, 34 files
  at mode `0600`, and directories at mode `0700`. Runtime packet
  `20260801T190000Z-phase4-authoritative-host-auth-fixed-r2` independently binds
  and verifies that exact packet.

## Security pattern assessment

Both security findings were boundary-ownership defects. The presentation path
had transport reachability without authenticated admission or canonical
authorization, while the qualification path persisted raw data without applying
the runtime evidence boundary. The repair makes both boundaries explicit and
fail-closed without introducing a durable identity system or a second policy
owner.

## CR-004 — Unsafe historical evidence is inside the broad source-add surface

- Review epoch / iteration: 2 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: blocking / in-scope
- Location: `poc/evidence/*`
- Suspected surface: source-artifact inclusion and evidence confidentiality
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: historical packets contain unredacted account email and private Git
  origin metadata; a broad `git add poc/` would publish them even though the
  accepted final packets are clean.
- Fix applied: `poc/.gitignore` excludes all local evidence packets, generated
  transport binaries, and Python bytecode while preserving the historical
  packets locally.
- Verification: `git status --short --ignored` classifies `poc/evidence/` as
  ignored and the fresh source manifest contains no evidence path.
- Relationship: spawned-sibling of SR-002 at the repository-inclusion boundary.
- Resolution decision: cluster CR-004 through CR-008 and SR-003/SR-004;
  candidate adds explicit activation-lifetime admission, late-response, bounded
  envelope, and final packet-seal transitions. Selected altitude:
  `architecture` (`local-design-flaw`, high confidence). Preserve historical
  packets locally but ignore `poc/evidence/` from Git; no pre-commit framework.

## CR-005 — Final exact-canary scan omits the internal capability

- Review epoch / iteration: 2 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: blocking / in-scope
- Location: `poc/run.sh:finalize_runtime`, `poc/assert.py:final capability scan`
- Suspected surface: capability finalization and evidence closure
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: the controller scans both canaries before runner-added artifacts,
  but the final assertion scans only the public canary. A late internal-canary
  leak can therefore survive into a PASS packet.
- Fix applied: after ordinary writers stop, the final assertion scans the exact
  overlapping candidate space against both public and internal capability
  digests, then atomically seals the exhaustive pre-seal inventory.
- Verification: the fresh packet scans 22,792 candidates with both digest names,
  zero matches, and 411 inventoried files; an assertion rerun refuses the seal
  before writing and the packet tree hash remains unchanged.
- Relationship: spawned-sibling of SR-002 at the post-controller finalization
  boundary.
- Resolution decision: same CP-002 architecture amendment. Preserve internal
  audience isolation by scanning overlapping 64-character URL-safe candidates
  against the persisted SHA-256 after all ordinary writes, then atomically add a
  schema-bounded no-more-writes seal.

## CR-006 — Simultaneous-client audit is unavailable during the active session

- Review epoch / iteration: 2 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: blocking / in-scope
- Location: `poc/controller.py:serve`, `poc/transport/main.go:reportAttempt`
- Suspected surface: activation admission and controller-listener ownership
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: after accepting the stock-CLI session the controller stops accepting
  internal connections, so the transport cannot deliver the required
  simultaneous-client audit record.
- Fix applied: a controller acceptor services authenticated session and audit
  handshakes throughout the activation while retaining exactly one presentation
  owner; simultaneous authenticated and rejected attempts are durably merged.
- Verification: the fresh sealed runtime gates
  `authenticated_capability_epoch_and_negative_admission` and
  `one_downstream_tui_connection` are true with `audit_drained` chronology.
- Relationship: repeated lifecycle gap in SR-001's accepted authentication
  architecture.
- Resolution decision: same CP-002 architecture amendment. Keep one session
  owner while servicing authenticated audit handshakes for the full activation.

## CR-007 — Timed-out upstream waiters silently consume late responses

- Review epoch / iteration: 2 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: blocking / in-scope
- Location: `poc/controller.py:request`, `poc/controller.py:_route_upstream_message`
- Suspected surface: durable request lifecycle and ambiguity reconciliation
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: a timed-out waiter remains registered; a later exact response is
  delivered to the abandoned queue rather than becoming durable late-response
  evidence available for reconciliation.
- Fix applied: timeout detaches the exact waiter, durably fences the operation,
  publishes a correlation route only after that commit, persists any exact late
  response, and reconciles it without recreating the waiter or replaying.
- Verification: kernel/controller timeout tests and the fresh runtime's exact
  late-response schedule PASS.
- Relationship: spawned-sibling of the durable evidence-closure findings.
- Resolution decision: same CP-002 architecture amendment. Add a bounded
  `pending -> timed_out -> late_response -> reconciled` route keyed by upstream
  request and operation identity.

## CR-008 — Canonicalization accepts and discards altered stock defaults

- Review epoch / iteration: 2 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: significant / in-scope
- Location: `poc/controller.py:canonicalize_primary_mutation`
- Suspected surface: presentation authorization algebra
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: altered `approvalsReviewer`, resume personality, or collaboration
  developer-instruction fields are accepted and discarded instead of rejected
  before durable intent.
- Fix applied: resume and turn canonicalization now validates every pinned stock
  default, including approval reviewer, collaboration instruction digest,
  nullable fields, model, effort, permissions, and workspace authority, before
  durable intent; altered values are rejected rather than discarded.
- Verification: canonicalization acceptance and conflict tests PASS; fresh
  sealed runtime gate `primary_mutations_controller_canonicalized` is true.
- Relationship: repeated sibling in SR-001's canonicalization boundary.
- Resolution decision: same CP-002 architecture amendment; exact pinned stock
  defaults reject before journaling rather than being silently discarded.

## SR-003 — Malformed authenticated JSON can terminate the controller

- Review epoch / iteration: 2 / phase-2 security discovery
- Source: security-researcher
- Severity / scope: significant / in-scope
- Location: `poc/transport/main.go:WebSocket read`,
  `poc/controller.py:_handle_downstream_message`
- Suspected surface: downstream protocol-envelope boundary
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: syntactically valid scalar JSON or an unhashable/non-string method
  reaches object-only controller logic and can terminate the authoritative host.
- Fix applied: transport and controller both reject scalar, malformed, unknown,
  and invalid-ID envelopes with a bounded per-message JSON-RPC error while the
  authenticated session remains live.
- Verification: malformed-envelope unit tests PASS and the fresh stock-TUI
  runtime completes normally.
- Resolution decision: same CP-002 architecture amendment; invalid envelopes
  receive a bounded per-message rejection and do not terminate the session.

## SR-004 — Authenticated frames and evidence writes are unbounded

- Review epoch / iteration: 2 / phase-2 security discovery
- Source: security-researcher
- Severity / scope: significant / in-scope
- Location: `poc/transport/main.go:WebSocket read`, `poc/controller.py:Evidence.append`
- Suspected surface: authenticated transport and evidence resource boundary
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: one bearer-valid frame can force unbounded buffering, JSON parsing,
  and duplicate synchronous evidence persistence.
- Fix applied: the same fixed one-MiB limit is enforced before full WebSocket or
  controller JSONL buffering; oversize frames are drained/rejected and evidence
  redaction occurs at the single owner-only append boundary.
- Verification: envelope and evidence-safety tests PASS; fresh sealed runtime
  reports no non-schema leaks or insecure evidence paths.
- Resolution decision: same CP-002 architecture amendment; one fixed envelope
  limit is enforced before forwarding or full-body evidence persistence.

## SR-005 — Local Codex provenance has no external authenticity root

- Review epoch / iteration: 2 / phase-2 security discovery
- Source: security-researcher
- Severity / scope: acknowledged / adjacent
- Location: `poc/run.sh:Codex resolution`, `poc/provenance.py`
- Suspected surface: host supply-chain trust root
- Lifecycle: deferred
- Statement: cross-packet hashes prove binary identity and drift, not that a
  locally installed self-reporting Codex binary is an authentic OpenAI release.
- Fix applied: none; the bounded PoC treats the local installed Codex/toolchain as
  its environmental trust root. A signed or externally pinned distribution root
  belongs to production hardening.

## Checkpoint CP-002 — Authentication/evidence lifecycle boundary

- Review epoch: 2
- Triggered at: phase-2 security discovery, pre-fix
- Continuation:
  - phase: phase-2-review
  - boundary: pre-fix
  - lane: specialist
  - required next action: resolve CR-004 through CR-008 and SR-003/SR-004, then
    restart holistic Code Review Phase 1 after any required architecture update.
- Trigger: repeated and spawned-sibling findings across the authentication,
  late-response, and evidence-finalization boundaries after SR-001/SR-002 were
  claimed resolved.
- Evidence clusters: CR-005/CR-006/CR-008 repeat the activation authority and
  canonicalization boundary; CR-004/CR-005 repeat evidence closure at later
  lifecycle sites; CR-007/SR-003/SR-004 expose unnamed post-happy-path protocol
  states.
- Diagnosis: `local-design-flaw` (high confidence).
- Action: update and review `poc/PLAN.md`, implement the bounded lifecycle
  amendment, then restart holistic Code Review Phase 1 in epoch 3.
- Status: actioned
- Status evidence: resolution challenge selected architecture altitude; no user
  or scope decision is required. The actioned checkpoint remains blocking until
  plan review, implementation, fresh evidence, and restarted review converge.

## Plan Review Epoch 2 — Lifecycle amendment

### PR-001 — Final seal did not bind an exhaustive packet inventory

- Source: rfc-reviewer
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: the artifact list omitted load-bearing provenance and closure files,
  while the proposed seal did not explicitly bind every pre-seal path and digest.
- Plan correction: one packet schema now declares all required, optional, and
  variable paths. The atomic seal binds the exact sorted pre-seal inventory,
  sizes, digests, source-manifest verification, scans, gates, and authoritative
  verdict; missing, extra, or changed files invalidate it.

### PR-002 — Site list omitted helper ownership and tests

- Source: rfc-reviewer
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: the plan assigned behavior to broad controller/assertion labels but
  omitted the helper modules that actually own durability, evidence,
  provenance, authentication probes, and their tests.
- Plan correction: the artifact and site lists now name `kernel.py`,
  `evidence.py`, `provenance.py`, `probe_gateway_auth.py`, every applicable test
  module, transport tests, and the local-artifact ignore boundary.

### PRT-001 — Detach/reattach had no presentation-generation protocol

- Source: rfc-red-team
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: a half-open old stream and replacement connection could overlap or
  misattribute reused client request IDs and an exact late upstream response.
- Plan correction: at most one active/draining presentation generation; no
  silence-based takeover; durable old-generation closure precedes the next
  generation; waiter IDs are generation-scoped while upstream/operation IDs are
  not. A named half-open/retry/late-response schedule proves the boundary.

### PRT-002 — Legitimate repeated audits were indistinguishable from replay

- Source: rfc-red-team
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: reuse of the activation capability across audit connections
  conflicted with duplicate-handshake rejection.
- Plan correction: the controller-generated transport instance and monotonic
  audit sequence identify each delivery. Exact re-delivery is idempotent;
  identity/content conflict is rejected; capability reuse is not replay.

### PRT-003 — Audit drain and packet seal lacked a common closure boundary

- Source: rfc-red-team
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: an in-flight audit could be lost during revocation, and a crash
  between scan and seal had no deterministic recovery rule.
- Plan correction: transport shutdown emits a terminal audit watermark;
  controller durability through that watermark precedes internal admission
  closure and cleanup. An unsealed packet may repeat only the read-only
  inventory/scan and external-temp atomic seal publication.

### PR-003 — Quiescence order could deadlock the active session handler

- Source: rfc-reviewer re-review
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: waiting for every transport handler before retiring the current
  presentation meant the active session handler could prevent its own fence.
- Plan correction: controller-triggered graceful transport shutdown now closes
  public admission and the active WebSocket first; observed EOF durably retires
  the presentation, then only bounded audit handlers drain through the watermark
  before internal admission closes.

### PR-004 — Inconclusive evidence had no legal terminal result

- Source: rfc-reviewer re-review
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: the plan named inconclusive admission evidence but exposed only two
  PASS architecture verdicts and architecture rejection.
- Plan correction: every packet seals a run status; `INCONCLUSIVE` carries a
  null architecture verdict and bounded rerun reason. Only conclusive runs select
  one of the three architecture verdicts.

### PR-005 — Pre-seal capability-scan artifact created circular ownership

- Source: rfc-reviewer re-review
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: a required pre-seal scan result could not authoritatively cover its
  own finalized bytes without an unstated second pass.
- Plan correction: remove `capability-scan.json`; the seal alone stores the
  authoritative two-digest scan over the exact pre-seal inventory.

### PR-006 — Approval proof had no dedicated owner or policy exception

- Source: rfc-reviewer re-review
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: the primary is pinned to `never`, while the approval gate needs one
  controlled raw approval stimulus.
- Plan correction: a controller-created `phase8-approval-probe` thread uses the
  manifested no-network, sentinel-bounded `phase8-approval` profile and
  `on-request`; the primary and ordinary workers retain `never`.

### PRT-004 — Missing audit watermark had no bounded cleanup path

- Source: rfc-red-team re-review
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: transport failure before its watermark could block cleanup forever
  or force an invalid synthesized drain.
- Plan correction: bounded drain failure records gaps/conflicts as
  `audit_drain_failed`, retires presentation/internal admission, permits cleanup,
  and seals only FAIL or INCONCLUSIVE—not PASS.

### PRT-005 — Reattach replay and live delivery had a projection race

- Source: rfc-red-team re-review
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: a late durable result could land between replay and live
  subscription, causing a gap or duplicate.
- Plan correction: attachment atomically installs a buffered subscription above
  journal cutover `C`, emits a stable-ID replace snapshot through `C`, drains the
  buffer in order, then enters live mode.

### PRT-006 — Sealed historical source was not bound to reviewed source

- Source: rfc-red-team re-review
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: later source edits could be incorrectly justified by an internally
  valid older packet.
- Plan correction: before review receipt, commit, or evidence claim, a read-only
  inclusion check compares all eligible current paths/digests to the sealed
  source manifest; any drift requires fresh qualification/runtime evidence.

### PR-007 — Working-tree freshness did not bind the staged or commit tree

- Source: rfc-reviewer terminal verification
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: executed untracked source could be absent or differ in the staged
  index while a working-tree digest comparison still passed.
- Plan correction: the manifest fixes repo-relative eligible paths, regular-file
  type/mode, length, and digest. Pre-commit verification targets the exact staged
  tree OID; post-commit verification requires the same commit tree OID and
  entries. Working-tree comparison is freshness-only.

### PRT-007 — Transport quiescence did not quiesce durable semantic work

- Source: rfc-red-team terminal verification
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: outbox retries, worker completion, or upstream effects could remain
  active while admission closed and packet staging began.
- Plan correction: durable `finalizing` fences all new semantic work first;
  operations/workers/asks/approvals settle or become explicitly unresolved;
  App Server and ordinary writers stop before snapshot/staging. Recovery from
  `finalizing` never reopens admission or replays work.

### PRT-008 — Approval ownership was not tested across crash boundaries

- Source: rfc-red-team terminal verification
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: crashes around pending persistence, decision dispatch, and sentinel
  effect could lose or duplicate the approval without violating existing races.
- Plan correction: four named crash schedules reconcile stable approval identity,
  surviving thread/item state, decision response, and sentinel state; inability
  to classify no effect or one effect fails the architecture gate.

### PRT-009 — Audit failure contradicted the shutdown-complete invariant

- Source: rfc-red-team terminal verification
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending verification re-review
- Statement: one section allowed cleanup after `audit_drain_failed`, while the
  concurrency invariant required a drained watermark for all shutdown.
- Plan correction: both `audit_drained` and `audit_drain_failed` are terminal
  cleanup states, but only the durably drained state can support PASS.

## Plan Review Epoch 2 — Minimization

### MIN-001 — Compress the completed ITD alternatives

- Source: rfc-minimizer
- Severity / scope: significant / in-scope
- Lifecycle: not applied; governed by accepted user requirement
- Statement: the selected capability contract no longer needs the full rejected-
  option catalogue for implementation.
- Disposition: preserve it. The user explicitly requires the complete ITD data
  structure—problem statement, valid options, each option's pros/cons, and
  decision—to remain as durable decision history. This direct requirement is
  load-bearing even though the alternatives are not implementation steps.

### MIN-002 — Source/helper ownership was duplicated

- Source: rfc-minimizer
- Severity / scope: significant / in-scope
- Lifecycle: resolved
- Statement: the prototype artifact section and required site list repeated the
  same per-file ownership descriptions.
- Fix applied: the prototype section now contains only fixture and packet
  artifacts; the site list is the single source/helper ownership inventory.

### MIN-003 — Compression dropped the qualification-harness site

- Source: rfc-reviewer and rfc-red-team post-minimization verification
- Severity / scope: blocking / in-scope
- Lifecycle: resolved
- Statement: after removing duplicated artifact bullets, the site list lacked
  `diagnose_phase4_tool_surface.py`, its only remaining ownership declaration.
- Fix applied: one bounded site entry now retains its exact SQLite denial probe,
  normal-worker separation, and launcher/native-executable provenance duties.
- Verification: terminal rfc-reviewer GREEN and rfc-red-team GREEN CLEAR on the
  complete minimized plan.

## Code Review Epoch 3 — Lifecycle amendment discovery

### CR-009 — Audit terminal state does not close the producer set

- Review epoch / iteration: 3 / phase-1 discovery
- Source: code-review-analyst plus transport-concurrency scan
- Severity / scope: blocking / in-scope
- Location: `poc/transport/main.go:audit handler and shutdown`,
  `poc/controller.py:_record_audit_handshake/_record_audit_drain`
- Suspected surface: audit producer quiescence and terminal watermark
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: an accepted HTTP handler can increment/report after shutdown has
  observed a zero wait group and published its watermark; independently, a
  conflicting sequence reuse or any post-watermark audit is logged but does not
  irreversibly invalidate `audit_drained`.
- Fix applied: the transport closes its admission gate before waiting for every
  previously registered handler, then emits the watermark only after that
  producer set joins. The controller treats sequence conflicts and every
  post-watermark record as an irreversible `audit_drain_failed` state.
- Verification: transport admission tests, controller conflict/post-watermark
  tests, Go race test, and fresh sealed runtime packet
  `20260802T013000Z-phase4-authoritative-host-epoch4` PASS.
- Relationship: repeated and spawned-sibling of CR-006/PRT-002/PRT-003.

### CR-010 — Timeout routing becomes visible before timeout durability

- Review epoch / iteration: 3 / phase-1 discovery
- Source: code-review-analyst and security-researcher
- Severity / scope: blocking / in-scope
- Location: `poc/controller.py:request/_route_upstream_message`
- Suspected surface: timed-out waiter and late-response ownership transition
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: `request()` publishes the in-memory late-response route and
  releases `pending_lock` before the SQLite timeout row commits, so the exact
  response can be classified `unknown` and permanently suppressed in that
  interval.
- Fix applied: under the single pending-route lock, `request()` commits the
  SQLite timeout row and fences the operation before removing the live waiter
  and publishing the late-response route.
- Verification: the timeout unit test observes the lock held and route still
  hidden during the durable transition; the fresh sealed runtime exercises the
  exact race schedule and PASSes.
- Relationship: repeated incomplete implementation of CR-007.

### CR-011 — Timeout evidence export and hard gate omit the exercised schedule

- Review epoch / iteration: 3 / phase-1 discovery
- Source: code-review-analyst and security-researcher
- Severity / scope: blocking / in-scope
- Location: `poc/kernel.py:write_sanitized_evidence_snapshot`,
  `poc/assert.py:verify_durable_kernel_evidence`
- Suspected surface: late-response evidence closure
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: `request_timeouts.late_response` has no snapshot JSON-field
  handling and the Phase 3 gate accepts an empty timeout table. A real timeout
  row therefore breaks export instead of proving the required
  `timed_out -> late_response`, still-fenced chain.
- Fix applied: sanitized export JSON-decodes and persists
  `request_timeouts.late_response`; the mandatory schedule times out a real
  `thread/resume`, persists its exact late response, reconciles without replay,
  confirms by `thread/read`, and gates both database chain and schedule artifact.
- Verification: durable fixtures and kernel timeout tests PASS; fresh sealed
  runtime gates `durable_late_response_reconciled_without_replay` and
  `durable_late_response_schedule_artifact` are true.
- Relationship: spawned-sibling of CR-007 and CR-010.

### CR-012 — WebSocket has multiple unsynchronized data writers

- Review epoch / iteration: 3 / phase-1 discovery and security phase
- Source: code-review-analyst, transport-concurrency scan, and
  security-researcher
- Severity / scope: blocking / in-scope
- Location: `poc/transport/main.go:controller forwarding and rejection writes`
- Suspected surface: presentation write ownership and bounded failure
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: controller projection and malformed/oversized-input rejection can
  write concurrently to one Gorilla WebSocket even though it permits only one
  data writer; write failure also lacks a deadline and does not cancel the
  peer direction.
- Fix applied: one bounded outbound queue feeds the sole WebSocket data writer;
  every data write has a deadline, oversize output is rejected before writing,
  and any directional failure closes both WebSocket and controller connection.
  Controller JSONL writes also carry a bounded write deadline.
- Verification: focused framing/deadline tests, Go unit tests, `go vet`, Go race
  tests, and fresh sealed runtime PASS.
- Relationship: spawned-sibling of SR-003/SR-004 at the concurrency boundary.

### CR-013 — App Server loss can be misclassified as a terminal response

- Review epoch / iteration: 3 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: blocking / in-scope
- Location: `poc/controller.py:_read_upstream`
- Suspected surface: upstream transport loss and durable mutation disposition
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: EOF clears pending mutation waiters with a fabricated JSON-RPC
  error, which the kernel can record as a correlated terminal failure even when
  the semantic effect may already have occurred.
- Fix applied: upstream EOF wakes pending mutations with `AmbiguousDispatch`,
  wakes reads with a transport error, never fabricates a terminal JSON-RPC
  response, and records unexpected EOF as a reader failure that closes the
  downstream session.
- Verification: explicit unexpected-EOF and waiter tests PASS; fresh sealed
  runtime PASS.
- Relationship: spawned-sibling of CR-007 at the ambiguous-response boundary.

### CR-014 — Presentation ownership reopens during final retirement

- Review epoch / iteration: 3 / phase-1 discovery
- Source: code-review-analyst plus transport-concurrency scan
- Severity / scope: blocking / in-scope
- Location: `poc/controller.py:serve`
- Suspected surface: final presentation admission and retirement ordering
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: `presentation_active` is cleared while the public transport and
  internal acceptor remain live. A second authenticated session can be queued
  after the only consumer has finished and never receive a retirement record.
- Fix applied: the controller durably enters `finalizing` and closes semantic
  admission before clearing presentation ownership; the acceptor cannot admit a
  new session after this boundary.
- Verification: fresh sealed runtime gate
  `finalizing_quiesces_all_ordinary_producers` is true with exact chronology.
- Relationship: repeated incomplete implementation of PRT-001/PRT-007.

### CR-015 — App Server reader is unsupervised across shutdown and snapshot

- Review epoch / iteration: 3 / phase-1 discovery
- Source: code-review-analyst plus transport-concurrency scan
- Severity / scope: significant / in-scope
- Location: `poc/controller.py:App Server reader lifecycle and finalization`
- Suspected surface: upstream reader failure propagation and writer quiescence
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: the anonymous daemon can die on a routing exception without
  failing the controller, and it is not joined before final database export and
  kernel close. Buffered notifications can therefore be omitted or race a
  closed database.
- Fix applied: the App Server reader is retained and supervised; routing or
  unexpected-EOF failures propagate to the presentation, cleanup joins it, and
  `ordinary_writers_stopped` plus database export require the join.
- Verification: reader failure unit test and fresh sealed runtime gates
  `controller_children_stopped_and_reaped`, `durable_finalization_boundaries`,
  and `finalizing_quiesces_all_ordinary_producers` are true.
- Relationship: spawned-sibling of CR-013 and PRT-007.

### SR-006 — Read-only App Server calls retain client-selected filesystem scope

- Review epoch / iteration: 3 / security phase
- Source: security-researcher
- Severity / scope: significant / in-scope
- Location: `poc/controller.py:READ_ONLY forwarding`
- Suspected surface: presentation authorization algebra
- Lifecycle: actioned; pending epoch-4 re-review
- Statement: forwarded methods such as `config/read` and `skills/list` accept
  client-controlled `cwd`/`cwds` without an exact per-method algebra, allowing
  the presentation client to select control-plane reads outside the
  controller-owned workspace.
- Fix applied: only six pinned stock read shapes are exposed. Account and config
  requirement reads accept no parameters, model listing is exact, skills listing
  is fixed to the controller workspace, and thread read is fixed to the logical
  primary; broader methods such as `config/read` are rejected.
- Verification: per-method canonicalization/rejection tests PASS and fresh
  sealed runtime gate `primary_reads_controller_canonicalized` is true.
- Relationship: spawned-sibling of CR-008 at the presentation authority
  boundary.

## Checkpoint CP-003 — Quiescence producer/consumer ownership

- Review epoch: 3
- Triggered at: phase-1 discovery, pre-fix
- Continuation:
  - phase: phase-1
  - boundary: pre-fix
  - lane: discovery
  - required next action: disposition CR-009 through CR-015 and SR-006, then
    restart holistic Code Review Phase 1 in a new epoch if architecture changes.
- Trigger: multiple new and repeated P1 sibling findings appeared in audit,
  presentation, upstream-response, and late-response lifecycle surfaces after
  the epoch-2 lifecycle amendment and fresh happy-path PASS.
- Evidence clusters: CR-009/CR-014/CR-015 share incomplete producer quiescence;
  CR-010/CR-011/CR-013 share non-atomic response ownership and disposition;
  CR-012 and SR-006 expose presentation paths without one serialized authority.
- Diagnosis: `local-design-flaw` (high confidence). The shared defect is an
  incompletely realized ownership/quiescence boundary: producers, writers, and
  response-route transitions remain independently live during shutdown or
  authority transfer.
- Action: realize the already-reviewed `finalizing`/no-admission boundary as one
  coherent correction; quiesce producers before terminal audit/snapshot, make
  response ownership transitions durable before visible, serialize
  presentation writes and read authorization, exercise/export/gate the late
  response schedule, then restart Code Review in epoch 4.
- Status: actioned
- Status evidence: convergence diagnosis selected architecture altitude within
  the existing accepted PLAN. No new product behavior, durable state, or plan
  amendment is required; CP-003 remains blocking until the epoch-4 Phase 3 gate
  is clean.

## Code Review Epoch 4 — Restarted discovery

- Phase 1 independent discovery: GREEN for the implemented Phase 1–4 slice.
  The reviewer reconstructed the current behavior without receiving this ledger
  or prior claimed fixes and reported no well-qualified findings.
- Simplification: no safe subtractive change identified.

### CR-016 — Timed acceptor join can leave an ordinary writer live

- Review epoch / iteration: 4 / post-Phase-1 simplification
- Source: primary orchestration inspection
- Severity / scope: blocking / in-scope
- Location: `poc/controller.py:serve/_accept_transport_connections`,
  `poc/assert.py:finalization chronology`
- Suspected surface: transport-handshake producer quiescence
- Lifecycle: actioned; pending epoch-5 discovery and final gate
- Statement: `serve()` requests acceptor shutdown and performs a timed `join()`,
  but never checks whether the thread joined. An unauthenticated local peer can
  hold an already accepted handshake open with a slow line; socket inactivity
  timeouts are per read, so the acceptor can outlive the join deadline and later
  append evidence after `ordinary_writers_stopped` or race kernel closure.
- Fix applied: shutdown performs the existing bounded join, records its exact
  result, and fails the run if the acceptor remains live. The durable
  `ordinary_writers_stopped` boundary refuses a known-live acceptor, and the
  final assertion requires the successful join between audit termination and
  capability revocation.
- Verification: joined and still-live unit fixtures PASS within the 82-test
  Python suite. Fresh sealed runtime packet
  `20260802T040000Z-phase4-authoritative-host-acceptor-join-r2` PASSes all 53
  gates and proves `audit_drained < transport_acceptor_joined < capability
  revocation`; epoch-5 review remains pending. The earlier unsealed
  `20260802T033000Z-phase4-authoritative-host-acceptor-join` packet is preserved
  as an assertion-wiring failure.
- Resolution decision: the user rejected full slow-handshake/socket-registry
  hardening as disproportionate. Resolution challenge selected
  `implementation`: preserve the no-false-PASS obligation with one fail-closed
  join check/event/gate and no new protocol or connection lifecycle.
- Semantic-surface delta: one optional runtime boolean, one helper and lifecycle
  event, and one evidence-order check; no new product behavior, durable state,
  socket registry, or PLAN change.
- Relationship: repeated sibling of CR-009/CR-014/CR-015 and the CP-003
  producer-quiescence diagnosis.

## Checkpoint CP-004 — Producer quiescence restart cap

- Review epoch: 4
- Triggered at: post-Phase-1 simplification, pre-fix
- Continuation:
  - phase: phase-1
  - boundary: pre-fix
  - lane: discovery
  - required next action: apply CR-016's bounded producer-close/join correction,
    then restart holistic Code Review Phase 1 in epoch 5.
- Trigger: the convergence-driven epoch-4 restart found another blocking sibling
  in the same producer-quiescence cluster.
- Diagnosis: same `local-design-flaw` as CP-003; the implementation still lacks
  one complete registry and join proof for every ordinary producer.
- Action: apply the user-approved minimal fail-closed join proof and restart the
  required review flow without adding slow-handshake hardening.
- Status: actioned
- Status evidence: the user approved Option 2, which retains the existing
  bounded join and prevents a false PASS if it does not complete. Implementation,
  offline tests, and fresh sealed runtime evidence are complete; epoch-5 review
  remains pending.

## Code Review Epoch 5 — Independent discovery

Phase 1 independent discovery reconstructed the current implementation without
this ledger or prior fix history and reported three significant in-scope
findings. None requires a product, requirement, or architecture change; each is
being resolved at implementation altitude with the smallest local correction.

### CR-017 — Runner cleanup loses the process group when its leader exits first

- Review epoch / iteration: 5 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: significant / in-scope
- Location: `poc/run.sh:controller launch and stop_controller_group`
- Suspected surface: controller child-process quiescence
- Lifecycle: actioned; pending epoch-5 holistic discovery
- Statement: cleanup probes and signals the controller PID before signaling its
  process group. If the `setsid` leader exits while one of its children remains
  live, cleanup skips the group entirely and can proceed with an orphaned App
  Server or transport process.
- Selected resolution: `implementation`. Record and validate the dedicated PGID
  at launch, probe/signal that process group independently of leader liveness,
  and retain ordinary leader reaping/status capture. No process supervisor or
  generalized lifecycle abstraction is added.
- Fix applied: `run.sh` records the validated `setsid` process group separately
  from the leader PID and always probes/signals that group before reaping the
  leader, including when the leader has already exited.
- Verification: the exact cleanup function is exercised with a dead group
  leader and live child; the regression, shell syntax, and shellcheck PASS.
- Relationship: sibling of CR-012/CR-015/CR-016 at the process-quiescence
  boundary.

### CR-018 — Failed notification delivery can kill the App Server reader

- Review epoch / iteration: 5 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: significant / in-scope
- Location: `poc/controller.py:_project_notification/_send_downstream`
- Suspected surface: upstream-reader ownership versus presentation retirement
- Lifecycle: actioned; pending epoch-5 holistic discovery
- Statement: a downstream disconnect race can make a projected notification
  write fail; that presentation error propagates through `_read_upstream` and
  terminates the sole App Server reader, incorrectly turning loss of the TUI
  projection into loss of upstream ownership.
- Selected resolution: `implementation`. Catch only notification-delivery
  failures, retire/fence that exact downstream presentation, and let the App
  Server reader continue until normal finalization. No reconnect protocol or
  new presentation lifecycle is introduced.
- Fix applied: notification projection snapshots ownership without holding the
  lifecycle lock across I/O; an I/O failure clears and shuts down only the exact
  failed downstream. Successful delivery is recorded only after the write.
- Verification: the regression forces `BrokenPipeError`, proves exact socket
  retirement, no false `to_tui` record, and continued handling as
  `no_downstream`; the full Python suite PASSes.
- Relationship: sibling of CR-013/CR-015 at the upstream-reader boundary.

### CR-019 — Packet inventory follows allowed-prefix symlinks

- Review epoch / iteration: 5 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: significant / in-scope
- Location: `poc/evidence.py:packet_inventory`
- Suspected surface: sealed-packet self-containment
- Lifecycle: actioned; pending epoch-5 holistic discovery
- Statement: inventory discovery and hashing use symlink-following file checks,
  opens, and metadata. A symlink under an allowed variable-data prefix can make
  the seal inventory external file bytes as if they belonged to the packet.
- Selected resolution: `implementation`. Inventory entries must be direct
  regular files opened without symlink following and validated from the opened
  descriptor; symlinks and other non-regular entries are refused. No new packet
  format or trust policy is added.
- Fix applied: inventory walks every packet entry with `lstat`, refuses anything
  other than a directory or direct regular file, opens files with `O_NOFOLLOW`,
  and derives mode from the opened descriptor.
- Verification: an allowed-subtree symlink to an external owner-only file is
  rejected before hashing; the evidence suite and full Python suite PASS.
- Relationship: independent evidence-integrity finding.

## Checkpoint CP-005 — Epoch-5 three-fix convergence gate

- Review epoch: 5
- Triggered at: phase-1, post-fix
- Continuation:
  - phase: phase-1
  - boundary: post-fix
  - lane: discovery
  - required next action: run a fresh sealed runtime, then launch holistic
    epoch-5 Phase 1 discovery without prior findings or claimed fixes.
- Trigger: three substantive epoch-5 findings have been corrected, reaching the
  active-epoch review/fix threshold before another review dispatch.
- Evidence clusters: CR-017 is a producer-quiescence sibling of CP-003/CP-004;
  CR-018 concerns presentation failure isolation from upstream ownership;
  CR-019 concerns sealed-packet self-containment.
- Diagnosis: `local-design-flaw` (high confidence). CR-017 and CR-018 repeat
  CP-003/CP-004's ownership/quiescence flaw: one component's lifetime was used
  as a proxy for another owned producer or channel. CR-019 is independent.
- Repair altitude: `implementation`. The accepted plan already requires exact
  process-group reaping, presentation/upstream separation, and direct regular
  packet inventory; the applied fixes discharge those obligations without new
  protocol, durable state, product behavior, or architecture.
- Cap disposition: CP-004 already consumed the convergence-driven restart into
  epoch 5. Ordinary flow cannot restart automatically for the same cluster.
  Await explicit user authorization for one bounded exception: start a new
  epoch at counter zero, run the fresh sealed runtime, and resume the exact
  holistic Phase 1 discovery continuation with no architecture expansion. If
  the cluster recurs, stop rather than add another local patch.
- User decision: approved the recommended bounded exception.
- Action: start review epoch 6 at counter zero and resume the recorded
  post-fix continuation exactly: fresh sealed runtime followed by history-blind
  holistic Phase 1 discovery. Do not add another local patch if the same
  ownership/quiescence cluster recurs.
- Status: actioned

## Full-hardening track disposition

- A fresh epoch-6 runtime packet,
  `poc/evidence/20260802T043000Z-phase4-authoritative-host-epoch6`, passed all
  53 exercised gates with 411 inventoried files.
- The pending history-blind epoch-6 holistic code review was not run, and the
  packet intentionally records no architecture verdict. The full-hardening
  implementation therefore did not reach review closure.
- ITD 86 superseded this track as the active objective. Its plan is preserved at
  `poc/FULL_HARDENING_PLAN.md`; unresolved hardening work is deferred, not
  silently treated as passed or discarded.

## Low-stakes vertical-plan review

### Phase 1 discovery and convergence

- Initial soundness review found four blocking obligations: define an exact
  pilot; make primary/controller/agent semantic transitions explicit; separate
  ordinary detach from finalization and define reattach status; and distinguish
  clean full-attempt restart from phase rewind. It also required the complete
  independent quality-gate chain.
- Initial adversarial review found five significant false-success paths: restart
  retained old plan/agent state; reattach lacked a durable status projection;
  handoff did not require replacement progress; the proposed ask was
  manufactured from withheld intake ambiguity; and native hard review was
  missing.
- Initial UX review required an informed restart summary and tightened the
  always-present understanding recap, contextual ask/resume acknowledgment, and
  compact reattach status.
- Holistic re-review exposed four remaining obligations: move the agent ask to a
  valid post-intent decision point; cover every exercised primary-owned semantic
  transition with structured authority; make the restart fixture deterministic
  and measurably discriminating; and name independent correctness/quality and
  codebase-cohesion review lenses before separate closure.
- The final holistic soundness, adversarial, and UX verdicts were GREEN after
  these obligations were applied. No deferred race, crash-recovery, hostile-
  client, or production-hardening requirement was imported.

### Phase 2 minimality and closure

- The independent minimizer verdict was MINIMAL with no blocking, significant,
  or acknowledged subtraction. It found the plan's density traceable to the
  scope, plan contract, or protected Phase 1 obligations.
- Final plan: `poc/PLAN.md` at SHA-256
  `50d0d65f63980b8c93cec266a34d24356fd2e1a3512b75ecb2f5b82a85051651`.
- Plan Review closed GREEN at repository HEAD
  `e045cf1e14277c2befc78a450201a6b19b33ba40`; the ignored local closure receipt
  is `.review-receipts/poc/PLAN.md.json`.

## Low-stakes Code Review Epoch 1 — Happy-path implementation discovery

### LS-CR-001 — Approved diff identity diverges from the integrated commit

- Review epoch / iteration: low-stakes 1 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: blocking / in-scope
- Location: `poc/prototype.py:1509`
- Suspected surface: reviewed artifact identity and integration authority
- Lifecycle: open
- Statement: `integrate()` stages only `normalize_values.py` after the user has
  approved a broader worktree diff. Live v9 approved diff `d7c0c791...`, but
  commit `50975fcd...` contains only `normalize_values.py`; contract and test
  changes were omitted while durable state still links the commit to the
  approved hash.
- Relationship: repeated evidence-binding defect from CR-001 through CR-003;
  spawned sibling of the final-gate findings below.
- Fix applied: none; convergence diagnosis is required before repair.

### LS-CR-002 — Any non-empty response authorizes restart or integration

- Review epoch / iteration: low-stakes 1 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: blocking / in-scope
- Location: `poc/prototype.py:411`, `poc/prototype.py:450`
- Suspected surface: user authority interpretation and proposal binding
- Lifecycle: open
- Statement: the controller records authority-changing actions for every
  non-empty response, including rejection, clarification, or a question.
- Relationship: sibling of SR-001/CR-008 at the controller-owned authorization
  boundary.
- Fix applied: none; convergence diagnosis is required before repair.

### LS-CR-003 — Native hard review passes without proving it saw the diff

- Review epoch / iteration: low-stakes 1 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: blocking / in-scope
- Location: `poc/prototype.py:1479`
- Suspected surface: final review evidence and reviewed-artifact identity
- Lifecycle: open
- Statement: v9's review could not access the linked worktree Git metadata, but
  exit zero plus absence of priority markers was accepted as a valid hard
  review. The gate therefore passed without a successful Git inventory.
- Relationship: repeated evidence-closure defect from CR-001 through CR-003;
  sibling of LS-CR-001.
- Fix applied: none; convergence diagnosis is required before repair.

### LS-CR-004 — Kernel does not enforce role, outcome, decision, or pending-hash bindings

- Review epoch / iteration: low-stakes 1 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: significant / in-scope
- Location: `poc/kernel.py:1393`
- Suspected surface: workflow transition authority and relational invariants
- Lifecycle: open
- Statement: the kernel accepts invalid role/outcome decisions, ignores finding
  dispositions, and accepts fabricated gate receipts or an integration hash
  different from the pending hash.
- Relationship: sibling of LS-CR-001/LS-CR-002 at the durable authorization
  boundary.
- Fix applied: none; convergence diagnosis is required before repair.

### LS-CR-005 — Reviewer findings cannot satisfy the shared finding contract

- Review epoch / iteration: low-stakes 1 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: significant / in-scope
- Location: `poc/prototype.py:118`
- Suspected surface: review artifact schema and synthesis gate
- Lifecycle: open
- Statement: the runtime schema omits scope, required resolutions, and
  adversarial blocking scenarios, while validation accepts any findings list.
- Relationship: sibling of LS-CR-004 at the gate-contract enforcement boundary.
- Fix applied: none; convergence diagnosis is required before repair.

### LS-CR-006 — Root assessment and closure use ambiguous prose substrings

- Review epoch / iteration: low-stakes 1 / phase-1 discovery
- Source: code-review-analyst
- Severity / scope: significant / in-scope
- Location: `poc/prototype.py:1272`, `poc/prototype.py:1400`
- Suspected surface: role-result interpretation and semantic gate status
- Lifecycle: open
- Statement: negative prose such as "restart is not recommended" or "not
  closed" can satisfy positive substring gates.
- Relationship: sibling of LS-CR-002/LS-CR-005 at the unstructured semantic
  interpretation boundary.
- Fix applied: none; convergence diagnosis is required before repair.

## Checkpoint LS-CP-001 — Semantic authority and exact-artifact binding

- Review epoch: low-stakes 1
- Triggered at: phase-1 discovery, pre-fix
- Continuation:
  - phase: phase-1
  - boundary: pre-fix
  - lane: discovery
  - required next action: diagnose LS-CR-001 through LS-CR-006 and select the
    repair altitude before any ordinary fix; if architecture changes, update
    and review the accepted low-stakes plan before implementation.
- Trigger: three blocking sibling findings plus three significant findings all
  point at missing semantic authority, gate-contract enforcement, and exact
  reviewed-artifact binding. The same prose-claim-versus-mechanical-evidence
  pattern already appeared in CR-001 through CR-003.
- Evidence clusters: LS-CR-001/LS-CR-003 bind approval and review to the wrong or
  unproven artifact; LS-CR-002/LS-CR-004 fail to bind authority transitions to
  an exact accepted proposal and valid phase; LS-CR-005/LS-CR-006 treat prose or
  under-specified schemas as authoritative semantic results.
- Diagnosis: `local-design-flaw` (high confidence). The prototype lacks one
  mechanically authoritative chain from semantic decision, through a permitted
  transition and reviewed artifact, to gate receipts, user approval, and the
  integrated Git tree.
- Repair altitude: `architecture`. The correction changes shared typed
  interfaces, durable invariants, and evidence flow across the primary, role
  schemas, kernel, review gates, and Git integration; it is not six independent
  condition fixes.
- Action: amend the accepted low-stakes plan with one typed semantic-decision
  contract and one controller-owned immutable candidate/gate manifest, complete
  fresh Plan Review, obtain the user's mandatory plan approval, implement, then
  restart Code Review Phase 1 in low-stakes epoch 2 with this ledger retained.
- Status: actioned
- Status evidence: independent convergence diagnosis found no product,
  requirement, or scope decision. The accepted scope already requires the
  missing authority and artifact bindings; implementation remains blocked until
  the architecture amendment is reviewed and user-approved.

## Low-stakes Architecture Amendment Plan Review — Phase 1

### LS-PR-001 — Candidate comparison base was implicit

- Source: rfc-reviewer discovery
- Severity / scope: blocking / in-scope
- Lifecycle: resolved
- Location: `poc/PLAN.md:Amendment decision`, `Complete review, closure, and integration`, `Effect ordering`
- Obligation: native review, changed-path inventory, presented diff, whitespace
  validation, approval, and integration must cover the same complete attempt
  implementation rather than only the delta from a prior candidate.
- Plan correction: every candidate and superseding candidate is one complete
  commit whose direct parent is the exact attempt-base commit. Candidate tree,
  path inventory, diff, and diff checks are all derived from that explicit
  base/candidate pair.

### LS-PR-002 — Finding dispositions and receipt eligibility were underspecified

- Source: rfc-reviewer discovery
- Severity / scope: blocking / in-scope
- Lifecycle: resolved
- Location: `poc/PLAN.md:Use one bounded controller protocol`, `Complete review, closure, and integration`
- Obligation: a gate receipt cannot be created while a substantive in-scope
  finding remains unresolved or by mixing outcomes from another plan,
  candidate, attempt, or superseded artifact.
- Plan correction: the bounded finding-disposition algebra and its allowed
  severity/scope mappings are explicit. Receipt eligibility is derived by the
  kernel and keyed to exact plan hash, candidate SHA, or both as applicable;
  superseded and prior-attempt receipts are ineligible.

### Phase 1 discovery synthesis

- `rfc-red-team`: GREEN CLEAR with strengths for compound restart separation,
  candidate supersession, standalone native-review identity, and exact final
  fast-forward.
- `rfc-reviewer`: RED only for LS-PR-001 and LS-PR-002; the immutable candidate
  approach itself was assessed as proportionate.
- No adjacent or out-of-scope findings were produced.

### LS-PR-003 — Candidate supersession ordering contradicted itself

- Source: rfc-reviewer holistic verification
- Severity / scope: blocking / in-scope
- Lifecycle: resolved
- Location: `poc/PLAN.md:Candidate supersession`, `Effect ordering`
- Obligation: after a code-changing fix is accepted, an old candidate must not
  remain integration-eligible while its replacement is being constructed or if
  replacement verification fails.
- Plan correction: acceptance of the fix first makes the prior candidate and
  manifest ineligible. The replacement is then reconstructed and verified from
  the attempt base; only verified success activates it and permits new receipts.
  Failure remains visibly blocked with no eligible candidate.

### LS-PR-004 — Native hard review had identity proof but no semantic verdict gate

- Source: rfc-red-team holistic verification
- Severity / scope: blocking / in-scope
- Lifecycle: resolved
- Location: `poc/PLAN.md:Complete review, closure, and integration`
- Obligation: a native review that reports an actionable defect cannot become a
  clean receipt merely because it examined the right commit and exited zero.
- Plan correction: native Codex must emit one exact candidate-bound typed clean
  verdict or contract-shaped finding set. Malformed/ambiguous output fails;
  actionable findings enter the same disposition/revision path and require a
  superseding candidate plus affected downstream reruns.

### Phase 1 terminal synthesis

- Final `rfc-reviewer` verdict: GREEN. LS-PR-001 through LS-PR-004 are resolved;
  no blocking or significant in-scope finding remains.
- Final `rfc-red-team` verdict: GREEN CLEAR. Failed replacement, stale receipt,
  exit-zero-with-defect, malformed/wrong-candidate native output, and final
  integration-identity scenarios all fail closed as intended.
- The reviewed amendment keeps one authoritative chain from typed semantic
  decision, through a permitted transition and immutable candidate-bound gate
  manifest, to exact user approval and verified fast-forward integration.
- Phase 1 status: converged after three automatic iterations.

## Low-stakes Architecture Amendment Plan Review — Phase 2

- `rfc-minimizer` verdict: MINIMAL / GREEN.
- Reviewed plan SHA-256:
  `67dd7f143d63728f527eea1bdc38dc4d3e9c009cd745b4793dd0676503c204fa`.
- No subtraction, merge, or deferral safely preserves the accepted prototype
  scope plus LS-PR-001 through LS-PR-004. Candidate identity, authority,
  receipt eligibility, supersession, and native semantic-result sections carry
  distinct obligations despite their related subject matter.
- Phase 2 status: closed with no changes; no Phase 3 verification rerun was
  required.
- Plan Review terminal status: GREEN at repository HEAD
  `e045cf1e14277c2befc78a450201a6b19b33ba40`. The local closure receipt is
  `.review-receipts/poc/PLAN.md.json`. Implementation remains blocked pending
  the user's mandatory review and explicit approval of the amended plan.

## Low-stakes Code Review Epoch 2 — Phase 1 discovery

### E2-CR-001 — One plan-review outcome can fabricate the entire gate manifest

- Source: independent `code-review-analyst`; dynamically reproduced.
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending fresh Epoch 3 verification
- Location: `poc/kernel.py:workflow_role_runs`, `record_workflow_gate_receipt`,
  `complete_workflow_gate_manifest`
- Obligation: each receipt must prove the assigned role reviewed the exact
  phase, plan, candidate, turn, and artifact required by that gate. One accepted
  outcome or arbitrary known artifact cannot be relabelled to satisfy another
  gate.
- Scenario: reuse one accepted plan-review outcome and artifact under all seven
  gate-kind labels; the current kernel completes the manifest.

### E2-CR-002 — Approval is proposal-ID-bound but not proposal-subject-bound

- Source: independent `code-review-analyst`; dynamically reproduced.
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending fresh Epoch 3 verification
- Location: `poc/kernel.py:_require_approved_disposition`, intent revision and
  integration authorization actions
- Obligation: approval must authorize the exact canonical proposed effect, not
  merely a reusable proposal ID and disposition name.
- Scenario: approve proposed constraints, then use the same decision IDs to
  persist different unproposed constraints; the current kernel accepts them.

### E2-CR-003 — Git main moves before candidate authorization is validated

- Source: independent `code-review-analyst`; dynamically reproduced.
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending fresh Epoch 3 verification
- Location: `poc/prototype.py:integrate`,
  `poc/kernel.py:complete_workflow_integration`
- Obligation: the controller must prove the exact candidate/base/tree is the
  currently authorized effect before changing disposable `main`; observed Git
  identity is recorded only after the effect.
- Scenario: pass a superseded direct-child candidate while another candidate is
  authorized; `main` advances to the stale SHA before kernel rejection.

### E2-CR-004 — Reject and clarify decisions fail instead of remaining paused

- Source: independent `code-review-analyst`.
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending fresh Epoch 3 verification
- Location: `poc/prototype.py` decision branches and run loop;
  `poc/pty_tui.py` marker wait
- Obligation: a typed non-approval must complete the user turn without applying
  the proposed effect. Clarification remains durably pending; rejection becomes
  a visible non-integrated/non-restarted outcome instead of a runner failure.
- Scenario: the controller emits a pending marker while the PTY waits only for
  the approved marker, so the correctly recorded non-approval still fails the
  PoC process.

### E2-CR-005 — Implementer role requests an unsupported ask outcome

- Source: independent `code-review-analyst`.
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending fresh Epoch 3 verification
- Location: `poc/roles/workflow-implementer.md`; implementer output schema and
  kernel ask ownership
- Obligation: the role contract and executable protocol must agree whether an
  implementer can pause on an ask.
- Scenario: an implementer follows its written ask instruction, but its output
  schema and kernel reject that outcome.

### Epoch 2 discovery synthesis and checkpoint E2-CP-001

- Verdict: RED — four blocking and one significant in-scope finding.
- Prior obligations fully resolved: LS-CR-003, LS-CR-005, LS-CR-006,
  LS-PR-001, and LS-PR-004.
- Prior obligations still partial/open: LS-CR-001, LS-CR-002, LS-CR-004,
  LS-PR-002, and LS-PR-003.
- Pattern candidate: stored identities exist, but the kernel still accepts a
  caller-selected interpretation at proposal→effect, outcome→receipt, and
  authorization→Git-effect boundaries. E2-CR-004 may be the user-facing state-
  machine manifestation of the same incomplete decision protocol; E2-CR-005 is
  a smaller role-contract mismatch.
- Checkpoint state: open for independent convergence diagnosis. No finding fix
  has been applied in Epoch 2.

### E2-CP-001 convergence diagnosis

- Classification / confidence: `local-design-flaw` / high.
- Repair altitude: implementation. The accepted plan already requires kernel-
  derived receipt eligibility, exact proposal-bound effects, typed non-approval,
  and authorization before Git mutation; no new architecture or product choice
  is required.
- E2-CR-001 through E2-CR-003 share one cause: identities are stored, but callers
  still select their meaning at outcome→receipt, proposal→effect, and
  authorization→Git-effect boundaries. E2-CR-004 is the presentation/run-loop
  manifestation of that incomplete decision protocol.
- E2-CR-005 is a separate role-contract mismatch. The narrow repair removes the
  unsupported implementer-ask instruction and uses its existing typed failed/
  blocked path; it does not generalize asks to every role.
- Selected correction: persist the exact review assignment subject and derive
  receipts from it; compare authority actions with canonical proposal effects;
  fetch the exact authorized candidate/base/tree from the kernel before Git
  fast-forward; synchronize on a neutral typed-decision marker and branch on
  durable approve/reject/clarify state.
- Explicit non-solutions: no generic authorization framework, Git/SQLite two-
  phase commit, lease/recovery state machine, rollback protocol, or generalized
  implementer ask subsystem.
- User decision: not required; no scope collision or disputed product behavior.
- Checkpoint state: actioned. Fixes must be verified by dynamic negative tests,
  then enter fresh history-blind Code Review Epoch 3 rather than resuming Epoch
  2 discovery.

### Epoch 2 repair receipt

- E2-CR-001: role runs now bind the exact gate kind, role, turn, plan,
  candidate, and reviewed artifact. Role receipts derive only from that accepted
  assignment/outcome; native-review and validation artifacts must hash their
  exact typed clean results.
- E2-CR-002: restart and integration proposals now use closed canonical subject
  shapes, and every authority action compares its exact effect with the approved
  subject before mutation.
- E2-CR-003: the kernel returns the sole currently authorized
  candidate/base/tree/diff/plan identity before Git mutation, and the controller
  rejects any supplied candidate mismatch before touching disposable `main`.
- E2-CR-004: approve, clarify, and reject all complete on a neutral
  decision-recorded marker. Clarification loops without effect; rejection emits
  a terminal visible declined result without restart or integration.
- E2-CR-005: the implementer contract now uses its existing typed `failed`
  outcome for an unexecutable plan and no longer advertises an unsupported ask.
- Dynamic negative coverage includes mismatched approved constraints, gate-role
  relabelling, mismatched native-review artifacts, stale integration candidates,
  all three decision routes, and implementer contract/schema agreement.
- Offline verification: 101 Python tests pass; Python compilation, Go tests,
  shell syntax, and `git diff --check` pass.
- Next gate: fresh history-blind Code Review Epoch 3.

## Low-stakes Code Review Epoch 3 — Phase 1 discovery

### E3-CR-001 — Typed role failure is rejected before durable staging

- Source: fresh history-blind `code-review-analyst`.
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending fresh Epoch 4 verification
- Location: `poc/prototype.py:run_role`
- Obligation: a valid typed `failed` outcome must become durable before the
  controller visibly stops or routes its supported pause/escalation decision.
- Scenario: a role returns `failed` while the call expects a success kind; the
  controller raises before `stage_workflow_outcome`, leaving no canonical
  failure record.

### E3-CR-002 — Restart successor lacks enforced revision and restore prerequisites

- Source: fresh history-blind `code-review-analyst`; dynamically reproduced.
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending fresh Epoch 4 verification
- Location: `poc/kernel.py` restart authorization, restore verification, and
  successor-attempt creation
- Obligation: restart authorization must name the applied revised intent, and a
  successor attempt must use the predecessor's verified exact base snapshot.
- Scenario: authorize restart without applying the intent revision, abandon the
  attempt, then create attempt two from a different base without a restore
  record; the kernel accepts it.

### E3-CR-003 — Phase results can be accepted before prerequisite review receipts

- Source: fresh history-blind `code-review-analyst`; dynamically reproduced.
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending fresh Epoch 4 verification
- Location: `poc/kernel.py:apply_workflow_action(decide_result)` and
  `poc/prototype.py:plan_attempt`, `close_plan`
- Obligation: accepting a plan or closure must truthfully mean its exact
  prerequisite review receipts already exist; later manifest protection cannot
  repair an earlier false semantic transition.
- Scenario: accept a completed planner result with zero plan-review receipts;
  the kernel records the plan as accepted.

### E3-CR-004 — Native-review findings bypass durable primary disposition

- Source: fresh history-blind `code-review-analyst`.
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending fresh Epoch 4 verification
- Location: `poc/prototype.py:run_native_hard_review` and native-fix loop
- Obligation: a non-clean native result and every selected finding disposition
  must be candidate-bound durable history before invalidation or repair starts.
- Scenario: an in-scope significant native finding directly invalidates the
  candidate and launches a fix without an intervening durable primary decision.

### E3-CR-005 — Write-role evidence can hide preflight or implementation changes

- Source: fresh history-blind `code-review-analyst`.
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending fresh Epoch 4 verification
- Location: `poc/prototype.py:run_role`, implementation preflight call sites
- Obligation: write-capable role evidence must always contain the
  controller-observed worktree state; a `ready` preflight must prove it made no
  changes.
- Scenario: an implementer edits during preflight and returns prose artifact
  content; the controller stores the prose, accepts `ready`, and continues from
  the changed worktree.

### E3-CR-006 — Recorded stock command disagrees with executed reasoning effort

- Source: fresh history-blind `code-review-analyst`.
- Severity / scope: acknowledged / in-scope
- Lifecycle: actioned; pending fresh Epoch 4 verification
- Location: `poc/pty_tui.py`, `poc/native-cli-prototype.sh`
- Obligation: recorded command evidence and the executed stock command must use
  one effective reasoning-effort value.
- Scenario: the evidence expansion records `low` while the wrapper executes
  `xhigh`.

### Epoch 3 discovery synthesis and checkpoint E3-CP-001

- Verdict: RED — two blocking, three significant, and one acknowledged
  in-scope finding.
- Dynamic validation remained green: 101 Python tests, Go tests, Python
  compilation, and `git diff --check`. The findings expose missing transition
  assertions rather than existing test failures.
- Pattern candidate: several semantic states are recorded before or after the
  evidence that makes them true, while failure and native findings bypass the
  same durable decision path. Write-role evidence is a related provenance gap.
- Checkpoint state: open for independent convergence diagnosis. No Epoch 3
  finding fix has been applied.

### E3-CP-001 convergence diagnosis

- Classification / confidence: `local-design-flaw` / high.
- Repair altitude: implementation. The accepted plan already requires all six
  obligations; no product, requirement, or user-visible behavior decision is
  reopened.
- Kernel boundary: enforce prerequisites only where SQLite state itself claims
  semantic truth. Restart authorization must find its exact applied revision;
  successor creation must find exact restore evidence and reuse the predecessor
  base; plan and closure acceptance must find their exact prerequisite receipts.
- Controller boundary: persist typed failures before stopping, always capture
  controller-observed entry/exit evidence for write roles, prove ready preflight
  made no change, and record native findings plus primary dispositions before
  invalidation or repair.
- Native-review correction remains outside ordinary role transport. Its narrow
  primary action binds candidate, exact result artifact, typed findings, and
  compatible dispositions; it does not create a synthetic run/thread or a new
  review lifecycle.
- Evidence drift is repaired by matching the recorded PTY command effort to the
  executed `xhigh` wrapper value.
- Explicit non-solutions: no generic prerequisite graph, phase engine,
  recovery lifecycle, automatic retry, Git/SQLite two-phase commit, lease,
  rollback protocol, synthetic native role, or trust in agent prose as write
  evidence.
- User decision: not required; no scope collision or new behavior choice.
- Checkpoint state: actioned. After fixes and targeted verification, review
  resumes with fresh history-blind Code Review Epoch 4.

### Epoch 3 repair receipt

- E3-CR-001: typed role failure is now staged with exact evidence and receives
  a durable primary `pause` disposition before the controller stops visibly.
- E3-CR-002: restart authorization queries the exact already-recorded
  proposal/decision-bound intent revision; successor creation requires the
  predecessor's verified restore event and exact base hash/path.
- E3-CR-003: plan acceptance transactionally requires both exact plan-review
  receipts, closure acceptance requires both exact candidate-bound code-review
  receipts, and the controller derives plan receipts before acceptance.
- E3-CR-004: every non-clean native result is persisted as an exact
  candidate/artifact/result/disposition action before invalidation or repair.
- E3-CR-005: every write-capable role now records controller-observed entry and
  exit HEAD/status/diff evidence regardless of agent prose; ready preflight
  changes become typed durable failures.
- E3-CR-006: recorded and executed stock CLI commands both name `xhigh`.
- Targeted negative coverage now includes failure-before-stop ordering,
  revision-before-restart, restore-before-successor with exact base identity,
  zero/one-receipt plan and closure rejection, native finding disposition before
  invalidation, hidden preflight edits, and CLI effort agreement.
- Next gate: full offline validation, then fresh history-blind Code Review Epoch
  4.

## Low-stakes Code Review Epoch 4 — Phase 1 discovery

### E4-CR-001 — Controller impersonates primary semantic authority

- Source: fresh history-blind `code-review-analyst`.
- Severity / scope: blocking / in-scope
- Lifecycle: open; pending convergence diagnosis
- Location: `poc/prototype.py:_handle_downstream_message`,
  `poc/prototype.py:decide_result`
- Obligation: intent acceptance and role-result dispositions must be attributable
  to an exact structured logical-primary turn that received the evidence it was
  asked to judge.
- Scenario: the controller hardcodes accepted intake, then mechanically converts
  an agent-authored finding tag into an action labelled `primary`; the workflow
  advances without the logical primary inspecting either source request or
  finding.

### E4-CR-002 — Host termination leaves false live workflow state

- Source: fresh history-blind `code-review-analyst`; dynamically reproduced.
- Severity / scope: blocking / in-scope
- Lifecycle: open; pending convergence diagnosis
- Location: `poc/prototype.py` rejection branches and terminal exception path
- Obligation: before controller teardown, durable work, attempt, candidate, and
  manifest state must record the actual terminal or deliberately paused result.
- Scenario: restart rejection stops the runner while SQLite still reports an
  active work item and attempt; integration rejection similarly leaves
  `integration_pending`, and an unrecoverable exception writes only an external
  report.

### E4-CR-003 — Accepted non-actionable findings cannot produce a receipt

- Source: fresh history-blind `code-review-analyst`; dynamically reproduced.
- Severity / scope: blocking / in-scope
- Lifecycle: open; pending convergence diagnosis
- Location: `poc/kernel.py:derive_workflow_role_gate_receipt`
- Obligation: receipt eligibility must match the accepted disposition algebra:
  compatible non-revision findings are eligible when no unresolved in-scope
  blocking or significant obligation remains.
- Scenario: a valid in-scope strength finding is acknowledged and the review is
  accepted, but receipt derivation rejects the non-empty finding set and breaks
  the ordinary gate path.

### E4-CR-004 — Reused thread changes physical-agent identity

- Source: fresh history-blind `code-review-analyst`.
- Severity / scope: significant / in-scope
- Lifecycle: open; pending convergence diagnosis
- Location: `poc/prototype.py:run_role` reuse call sites and
  `poc/kernel.py:start_workflow_role_run`
- Obligation: one retained App Server thread must keep one physical-agent
  identity; an actual replacement must use a fresh thread and identity.
- Scenario: a resumed planner or implementer turn reuses its predecessor thread
  but is recorded under a newly invented agent ID, making durable continuity and
  replacement evidence false.

### Epoch 4 discovery synthesis and checkpoint E4-CP-001

- Verdict: RED — three blocking and one significant in-scope finding.
- Offline validation remained green: 105 Python tests, Go tests, Python
  compilation, shell syntax, and `git diff --check`. Focused probes exposed the
  terminal-state, receipt-algebra, and identity-affinity failures.
- Pattern candidate: controller convenience is being recorded as semantic or
  lifecycle truth without exact producing evidence. Receipt eligibility and
  thread identity are two narrower consistency violations of the accepted
  protocol.
- Strengths to preserve: attempt-base candidate reconstruction, fail-closed
  supersession, strongly candidate-bound gates, and exact authorized
  fast-forward verification.
- Checkpoint state: open for independent convergence diagnosis. No Epoch 4
  finding fix has been applied.

### E4-CP-001 convergence diagnosis

- Classification / confidence: `requirement-ambiguity` / high.
- Shared invariant: every durable semantic transition must be attributable to
  the authority and evidence that owns its meaning, while canonical identity
  and lifecycle state remain coherent through receipt derivation, thread reuse,
  and host termination.
- E4-CR-001 repair altitude: bounded architecture. Preserve gateway intake, but
  require an exact structured logical-primary grounding or disposition output
  before each primary-owned semantic action and bind the action to its primary
  thread, turn, and output artifact.
- E4-CR-003 repair altitude: implementation. Derive gate eligibility from the
  accepted result decision and compatible finding dispositions; zero unresolved
  in-scope blocking/significant obligations, rather than zero total findings,
  is the cleanliness condition.
- E4-CR-004 repair altitude: implementation. Make retained thread-to-physical-
  agent identity immutable using existing durable run history; only a fresh
  thread receives a new identity.
- E4-CR-002 is split. Unexpected exceptions and explicit operator termination
  require a durable failure or abandonment transition before cleanup. Rejection
  semantics remain contradictory: the accepted plan says every rejection keeps
  affected work paused and visible, but separately says integration decline is
  terminal, and it does not say whether restart decline is terminal.
- Explicit non-solutions: no generic authorization framework, cryptographic
  attestation, event-sourced command bus, general recovery/reopen state machine,
  leases, crash reconciliation, synthetic primary run per controller effect,
  standalone physical-agent registry, or suppression of non-actionable review
  findings.
- User decision: required separately for restart rejection and integration
  rejection. Clarification remains paused; unexpected failure and explicit
  termination behavior are already settled.
- Checkpoint state: blocked on the first one-at-a-time rejection-semantics
  decision. The accepted plan must be corrected and re-reviewed before fixes.

### E4-D-001 — Restart rejection semantics

- Decision authority: user.
- Decision: rejecting a proposed clean attempt restart rejects only that
  proposal. The current attempt remains paused and visible, the controller stays
  live, and it waits for the user's next direction.
- Explicit non-effect: restart rejection does not abandon the attempt or work
  item and does not silently resume execution.
- Status: accepted.

### E4-D-002 — Integration rejection semantics

- Decision authority: user.
- Decision: rejecting final Git integration leaves `main` unchanged, preserves
  the reviewed candidate and evidence, keeps the work paused and visible, and
  keeps the controller live for the user's next direction.
- Explicit non-effect: integration rejection does not close or abandon the work
  item. Abandonment is a separate explicit user decision.
- Status: accepted. The requirement ambiguity is resolved; the plan correction
  and fresh Plan Review are now required before Epoch 4 code repair.

## Epoch 4 architecture-correction Plan Review — discovery pass 1

### E4-PR-001 — Native-review disposition missing from exhaustive action table

- Source: fresh independent `rfc-reviewer`.
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending holistic Plan Review pass 2
- Obligation: the mandatory native hard-review gate needs an explicit
  candidate/result-bound primary action before revision or receipt derivation.
- Repair: the exhaustive protocol now declares bounded
  `decide_native_review`, its authority/evidence, compatible dispositions,
  invalidation ordering, and clean-result receipt rule.

### E4-PR-002 — Approval is not bound to the exact rendered proposal

- Source: fresh independent `rfc-red-team`.
- Severity / scope: blocking / in-scope
- Lifecycle: actioned; pending holistic Plan Review pass 2
- Obligation: user approval must authorize the exact restart summary or
  candidate/diff that the user actually saw, not merely the active proposal in
  controller state.
- Repair: every decision gate now requires an immutable successful presentation
  artifact bound to proposal subject, primary thread/turn/output, and exact
  restart or candidate/diff identity; stale or failed rendering remains paused.

### E4-PR-003 — Required restart depends on an unconstrained assessor judgment

- Source: fresh independent `rfc-red-team`.
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending holistic Plan Review pass 2
- Obligation: a valid independent assessment must not make the required restart
  demonstration nondeterministic or be scripted toward a preferred answer.
- Repair: the fixture now names an objective attempt-invalidating criterion;
  the assessor verifies it and the carry-forward evidence, while a mismatch
  makes the prototype inconclusive rather than fabricating restart need.

### E4-PR-004 — Plain whitespace validation misses the committed candidate

- Source: fresh independent `rfc-red-team`.
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending holistic Plan Review pass 2
- Obligation: whitespace validation must inspect the exact committed
  attempt-base-to-candidate change.
- Repair: the plan now requires range-bearing `git diff --check` and treats
  clean checkout status as a separate proof.

## Epoch 4 architecture-correction Plan Review — holistic pass 2

- Soundness verdict: GREEN; E4-PR-001 resolved with no new material finding.
- Adversarial verdict: YELLOW; E4-PR-002 through E4-PR-004 resolved, with one
  new significant consistency finding.

### E4-PR-005 — Gate-manifest identity is temporally self-referential

- Source: holistic `rfc-red-team` pass 2.
- Severity / scope: significant / in-scope
- Lifecycle: actioned; pending holistic Plan Review pass 3
- Obligation: the exact pre-approval gate subject must remain immutable when
  later authorization and integration-result facts are recorded.
- Repair: the plan now separates an immutable candidate/plan/receipt gate
  snapshot from append-only approval and final Git-result events that reference
  it.

## Epoch 4 architecture-correction Plan Review — closure

- Holistic pass 3 soundness: GREEN; all prior obligations remain resolved and
  the gate identity chain is acyclic.
- Holistic pass 3 adversarial: GREEN CLEAR; E4-PR-005 is resolved and no new
  material finding emerged.
- Minimization: MINIMAL; no material subtractive finding. Repeated content is
  load-bearing across distinct authority, site, effect-ordering, and temporal
  surfaces.
- Accepted plan SHA-256:
  `f7f31631b33e73216ea4d7692dc55ede5fc40530a4ce0793184793d7841e167b`.
- Plan Review status: GREEN and closed. Epoch 4 code repair may begin, followed
  by a fresh history-blind Code Review epoch.

## Epoch 4 architecture-correction implementation

- E4-CR-001 lifecycle: actioned; pending fresh Code Review. The work item now
  binds one logical-primary thread before grounding. Every primary-owned action
  carries an exact content-addressed typed output from that thread, and the
  kernel rejects absent, mismatched, or wrong-thread evidence. Proposal
  decisions additionally bind the exact immutable primary presentation artifact
  and its complete restart-discard or candidate/diff subject.
- E4-CR-002 lifecycle: actioned; pending fresh Code Review. Restart and
  integration rejection both leave durable waiting work, the active attempt,
  and any candidate/evidence preserved while the controller stays live. Only
  the separate exact `/abandon work` command records abandonment. Unexpected
  failure or operator interruption records a terminal workflow transition
  before presentation and child cleanup.
- E4-CR-003 lifecycle: actioned; pending fresh Code Review. Role-gate receipt
  derivation now reads the one exact accepted `decide_result` action and permits
  a review verdict with compatible non-revision findings. The strength-finding
  path is covered directly.
- E4-CR-004 lifecycle: actioned; pending fresh Code Review. Reused role threads
  obtain their existing physical-agent identity from durable run history; the
  kernel rejects any role, attempt, worktree, or physical-identity change on a
  retained thread.
- Plan-review follow-through: native-review dispositions have an exact primary
  action; root assessment uses the objective attempt-invalidating criterion;
  final whitespace validation names the exact base-to-candidate range; and the
  pre-approval gate snapshot remains byte-for-byte immutable across separate
  authorization and integration-result events.
- Focused negative coverage now rejects fabricated or wrong-thread primary
  actions, stale/unpresented proposal decisions, physical identity changes, and
  mutable gate identity. It proves rejected proposals are non-terminal, explicit
  abandonment and abnormal failure are terminal, integration clarification can
  later approve the same presented proposal, and accepted strength findings are
  receipt-eligible.
- Validation: 109 Python tests pass; Go transport tests pass; Python compilation
  and shell syntax pass; source whitespace is clean; the accepted plan still
  matches its GREEN receipt at
  `f7f31631b33e73216ea4d7692dc55ede5fc40530a4ce0793184793d7841e167b`.
- Checkpoint state: actioned. A fresh history-blind Code Review must independently
  verify the complete repair before this checkpoint can close.

## Epoch 5 fresh Code Review discovery

The fresh `code-review-analyst` received the current scope, plan, staged change,
and repository context without this ledger, prior findings, proposed fixes, or
claimed root cause. It ran 109 Python tests, the Go transport tests, shell syntax,
and `git diff --cached --check`; all passed. It reported three significant
in-scope findings.

### E5-CR-001 — Non-actionable native findings are dispositioned and then fatalized

- Review epoch: 5.
- Iteration: phase-1 discovery.
- Source: `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py:3248`.
- Statement: every non-empty native result enters the repair branch, but a result
  containing only acknowledged, deferred, dismissed, or strength findings has no
  automatic repair and raises a hard failure after the primary validly accepts
  its compatible dispositions.
- Suspected surface: native-review gate semantics and receipt eligibility.
- Fix applied: none; the accepted plan is being amended before implementation.
- Lifecycle: open.
- Resolution decision: `requirement-ambiguity` at `product-requirement` altitude.
  The user selected zero unresolved actionable findings rather than a literal
  empty finding set. The plan now requires exact result and first-class finding
  preservation, compatible primary dispositions, and receipt eligibility only
  when no `revise` or `escalate` obligation remains. Plan Review must close before
  implementation.

### E5-CR-002 — Restart proposal and intent revision expose false active state

- Review epoch: 5.
- Iteration: phase-1 discovery.
- Source: `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/kernel.py:1803` and `poc/kernel.py:2425`.
- Statement: creating a restart proposal does not move the work item to
  `waiting`, and applying the approved intent revision sets it to `active` even
  though execution remains paused through restart authorization and restoration.
- Suspected surface: restart pause-state invariant.
- Fix applied: none.
- Lifecycle: open.
- Resolution decision: `local-fix-appropriate` at `implementation` altitude.
  Set waiting state atomically with restart-proposal creation, preserve it through
  intent revision and restart authorization, and let verified successor-attempt
  creation restore active state. This adds no lifecycle or authority surface.

### E5-CR-003 — A bare restart recommendation can drive informed restart

- Review epoch: 5.
- Iteration: phase-1 discovery.
- Source: `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py:2531`.
- Statement: root-assessment acceptance checks the recommendation enum while the
  shared result schema permits a null artifact and empty evidence, so an
  unsubstantiated restart recommendation can reach the user proposal and final
  PASS.
- Suspected surface: root-assessment evidence boundary.
- Fix applied: none.
- Lifecycle: open.
- Resolution decision: `local-fix-appropriate` at `implementation` altitude.
  Require a non-null exact assessment artifact and explicit evidence bound to the
  accepted plan, observed implementation checkpoint/diff, proposed constraint,
  and objective restart predicate before acceptance. No new table or lifecycle is
  justified.

## Epoch 5 user-directed plan amendment

- Native-gate decision: a review is satisfied by zero unresolved actionable
  findings, not only by an empty finding set. Non-actionable findings remain
  visible and durable.
- Finding-corpus decision: normalize code-review findings only. Each first-class
  row binds the exact candidate commit and structured source result; Git remains
  the complete snapshot authority and candidate refs remain reachable evidence.
  Do not duplicate base/tree/diff state in the finding relation.
- Explicit deferrals: plan-review finding normalization, periodic assessment,
  finding relationships, and assessment scheduling remain outside this MVP and
  may be designed later without migrating away from candidate-bound code finding
  rows.
- Plan state: amended and awaiting fresh soundness, adversarial, and minimization
  review before any Epoch 5 code fix.

## Epoch 5 amendment Plan Review — discovery pass 1

- Soundness verdict: RED — two blocking and one significant in-scope finding.
- Adversarial verdict: YELLOW CAUTION — two significant in-scope findings.
- E5-RFC-001: actioned pending holistic re-review. Receipt eligibility now uses
  one invariant across ordinary and native review: neither `revise` nor
  `escalate` may coexist with a receipt.
- E5-RFC-002: actioned pending holistic re-review. The memory discriminator now
  requires the naive reference to pass an unlimited positive control on the same
  generated corpus before its 96 MiB failure has evidentiary value.
- E5-RFC-003: actioned pending holistic re-review. The site list now names
  `run-prototype.sh`, `native-cli-prototype.sh`, and `pty_tui.py` with their launch,
  presentation, detach/reattach, and failure-propagation responsibilities.
- E5-RFC-004: actioned pending holistic re-review. The user chose independent
  compound-restart dispositions. A terminal intent-approve/restart-reject result
  applies only the intent revision and keeps work paused; clarification applies
  no partial effect, and restart cannot approve without its prerequisite revision.
- E5-RFC-005: actioned pending holistic re-review. Handoff now transfers exclusive
  ownership of the same exact worktree only after retiring the old run, with the
  checkpoint and replacement validation bound to a controller-derived worktree
  digest and Git diff artifact.
- Review continuation: rerun the complete current plan through fresh soundness
  and adversarial review. No implementation is permitted before convergence.

## Epoch 5 amendment Plan Review — convergence and minimization

- Holistic soundness re-review: GREEN; E5-RFC-001 through E5-RFC-003 resolved
  with no new blocking or significant in-scope finding.
- Holistic adversarial re-review: GREEN CLEAR; mixed restart authority and exact
  handoff ownership resolved with no new material scenario.
- Minimization verdict: BLOATED. One blocking subtractive conflict challenged the
  separate immutable gate-snapshot subsystem; one significant subtraction removed
  unexercised duplicate-result re-ingestion idempotency. The candidate-bound code-
  finding relation itself was identified as minimal and worth preserving.
- Conflicting-recommendation decision: the user selected the subtractive option.
  Reuse the existing immutable proposal-presentation artifact as the approval
  packet containing candidate, exact receipt/evidence set, diff identity, and
  summary. Approval binds that packet hash; the controller revalidates its
  contents before fast-forward. Remove the separate gate-snapshot entity, hash,
  inventory duplication, and lifecycle while preserving exact approval binding.
- Re-ingestion decision: duplicate review-result delivery/replay is explicitly
  out of scope. Persist each validated normal-path source occurrence once; do not
  add idempotency semantics or dedicated replay tests.
- Review continuation: the subtractive plan change requires the single Phase 3
  soundness and adversarial verification pass before GREEN closure.

## Epoch 5 amendment Plan Review — post-minimization verification and closure

- Soundness verification: YELLOW with one significant stale-reference finding;
  the approval packet otherwise preserved exact candidate/evidence binding,
  candidate-specific receipt eligibility, and pre-fast-forward revalidation.
- Adversarial verification: YELLOW CAUTION with the same significant stale-
  reference finding and no blocking scenario. Mixed restart and exact-worktree
  handoff obligations remained intact.
- Mechanical correction: one Work breakdown §6 instruction still named the
  removed gate snapshot. It now makes the prior candidate and any approval packet
  integration-ineligible. This wording-only correction was applied after the
  single allowed verification pass and was not sent through another review loop.
- Final Plan Review status: GREEN; no blocking in-scope finding, user decision,
  or minimization conflict remains. The reviewed plan hash is
  `fc4ffb2c095d8300a42513547b206c5ac4dfc9d88d57383c3b365c9058fc793f`
  at repository HEAD `e045cf1e14277c2befc78a450201a6b19b33ba40`.
- Implementation remains paused for the user's review and approval of the final
  combined amendment summary.
