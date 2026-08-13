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
- Fix applied: presentation admission now reserves one generation under the
  existing lock, transfers ownership only after acknowledgement write/flush
  and non-blocking queue handoff, and generation-safely clears the reservation
  on every expected pre-handoff JSON, I/O, value, or full-queue failure. The
  acceptor contains that connection failure and remains available for a later
  authenticated session; unrelated programming exceptions are not swallowed.
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

## Epoch 5 amendment implementation

- User authorization: the user approved implementation of the reviewed Epoch 5
  amendment after the plan and ledger checkpoint was preserved separately on
  repository `main`.
- E5-CR-001 lifecycle: actioned; pending fresh Code Review. Ordinary and native
  code-review results now register candidate-bound first-class finding rows from
  the exact structured result artifact before primary disposition. Primary
  actions reference stable finding identities. A disposition-complete native
  result with only compatible non-actionable findings now records its receipt
  and exits the repair loop without relabelling or erasing those findings.
- E5-CR-002 lifecycle: actioned; pending fresh Code Review. Creating a restart
  proposal now atomically moves the work item to `waiting`; accepted intent
  revision and restart authorization preserve that pause. Only verified
  successor-attempt creation returns work to `active`.
- E5-CR-003 lifecycle: actioned; pending fresh Code Review. Root-assessment
  acceptance now requires a non-empty exact assessment artifact and the exact
  ordered evidence identities for the accepted plan, implementation artifact,
  observed worktree state, proposed constraint, and objective restart predicate.
- Plan-review follow-through: the separate gate-manifest/snapshot tables and
  lifecycle were removed. The existing immutable proposal-presentation artifact
  is now the approval packet. It contains the exact candidate and inventory,
  controller-derived receipt/evidence identities, candidate diff and validation,
  limitations, and primary-visible summary. Integration authorization binds that
  packet hash and revalidates its full subject against current durable state
  before Git mutation. Compound restart dispositions now support the accepted
  terminal intent-approve/restart-reject result without applying restart or
  resuming work.
- Focused coverage now proves first-class ordinary and native finding ingestion,
  compatible non-actionable receipt eligibility, malformed native-source
  rejection without finding rows, restart waiting-state continuity, evidence-
  bearing root assessment, mixed restart effects, approval-packet immutability,
  and absence of the removed gate-manifest projection.
- Validation before fresh review: 111 Python tests pass; Go transport tests pass;
  Python compilation, shell syntax, and `git diff --check` pass.
- Checkpoint state: actioned. A fresh history-blind Code Review discovery pass
  must independently verify the complete amendment before these findings close.

## Epoch 5 amendment Code Review — holistic discovery pass 2

- Reviewer independence: fresh physical reviewer with no session-memory or
  review-ledger input; scope was the accepted Epoch 5 amendment and its direct
  call paths/tests.
- Verdict: RED. Three blocking in-scope findings are open. Fixes must preserve
  the accepted plan rather than add generic recovery or hardening machinery.

### E5-CR-004 — Memory discriminator omits its unlimited positive control

- Review epoch: 5.
- Iteration: holistic discovery pass 2.
- Source: `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/fixture/memory_gate.py:82`.
- Statement: the naïve reference is run only under `RLIMIT_AS`; any reference
  failure is treated as negative-control evidence even though the accepted plan
  requires the same reference to first produce the exact corpus output without
  the limit.
- Scenario: a broken or incorrect reference fails for a non-memory reason, the
  candidate succeeds, and the gate reports PASS without proving that the corpus
  distinguishes the rejected in-memory design.
- Suggested resolution: require status-zero exact output from an unlimited
  reference run before the limited negative control; otherwise report
  inconclusive. Persist both results and test a broken reference.
- Lifecycle: open; no fix applied yet.

### E5-CR-005 — Replacement cannot validate the exact transferred handoff state

- Review epoch: 5.
- Iteration: holistic discovery pass 2.
- Source: `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:2626`.
- Statement: the replacement receives only the checkpoint summary and an opaque
  artifact hash, not the controller-observed expected HEAD/status/diff, state
  digest, or exact diff artifact identity required by the accepted handoff
  contract.
- Scenario: the worktree changes between checkpoint capture and replacement;
  the replacement validates only the already-changed current tree and the
  prototype falsely claims exact handoff continuity.
- Suggested resolution: construct an immutable handoff packet with exact
  expected state, digest, and diff artifact/hash; reject a controller-observed
  entry mismatch before the replacement edits, require the replacement to
  return the bound validation evidence, and test intervening mutation.
- Lifecycle: open; no fix applied yet.

### E5-CR-006 — Mixed restart rejection has no supported later direction

- Review epoch: 5.
- Iteration: holistic discovery pass 2.
- Source: `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:1189`.
- Statement: after intent-revision approval plus restart rejection, the paused
  handler recognizes only `/abandon work`; it cannot construct the fresh restart
  proposal or process the later direction promised by the amended plan.
- Scenario: the revised constraint becomes durable and restart remains rejected;
  a later user authorization cannot produce any transition, so the active work
  item can never resume or complete.
- Suggested resolution: preserve the rejected proposal, accept a later
  non-authorizing direction, construct and present a fresh proposal bound to the
  active attempt/current intent, and require a new exact user decision before
  restart. Cover mixed rejection followed by fresh authorization.
- Lifecycle: open; no fix applied yet.

## Epoch 5 amendment Code Review — pass 2 fixes

- E5-CR-004 lifecycle: actioned; pending holistic re-review. The same generated
  corpus now first runs the naïve reference without an address-space limit and
  requires status-zero exact output. Only that successful positive control can
  precede the limited negative control; a broken reference returns
  `inconclusive`. Both outcomes are explicit in the JSON evidence. New tests
  cover a broken reference and a positive-control-pass/limited-control-fail run.
- E5-CR-005 lifecycle: actioned; pending holistic re-review. The accepted
  checkpoint now produces one immutable handoff packet containing expected HEAD,
  porcelain status, complete tracked-plus-untracked diff, canonical state digest,
  and persisted diff artifact hash. The controller compares the replacement's
  observed entry state before starting its thread, and the replacement must
  return the exact state/diff evidence identities before acceptance. A mutation-
  between-checkpoint-and-entry test proves the mismatch fence.
- E5-CR-006 lifecycle: actioned; pending holistic re-review. A later non-abandon
  direction after restart rejection is recorded without authority, preserves the
  rejected proposal, and causes a fresh restart proposal to be constructed and
  presented. The workflow resumes only after a separate exact approval of that
  fresh packet. Kernel coverage now proves mixed intent-approve/restart-reject,
  fresh proposal approval, intent binding, and later restart authorization.
- Focused validation: 114 Python tests pass; Go transport tests, Python
  compilation, shell syntax, and `git diff --check` pass.
- Review continuation: rerun one fresh holistic Code Review pass over the
  complete amended implementation. The three findings remain open until that
  pass independently verifies their obligations and finds no new material issue.

## Epoch 5 amendment Code Review — holistic re-review convergence

- Independent verdict: GREEN; no blocking, significant, or adjacent finding.
- E5-CR-001 through E5-CR-006 lifecycle: resolved. The fresh reviewer verified
  the disposition-complete native gate, restart pause continuity, assessment
  evidence, unlimited memory positive control, exact pre-edit handoff fence, and
  post-rejection fresh-proposal flow in their complete current call paths.
- The same pass also verified candidate/result/source-bound ordinary and native
  finding ingestion plus controller-derived, immediately revalidated integration
  approval packets.
- Independent validation: 43 focused Python tests, `go test ./transport`, and
  staged/unstaged `git diff --check` passed.
- Phase 1 Code Review exit: clean. Continue to simplification and conditional
  specialist review before the independent native Codex gate.

## Epoch 5 amendment Code Review — simplification pass

- Verdict: clean; no semantic-preserving subtraction or consolidation would
  materially reduce the accepted behavior's surface.
- The fixes add no table, generic recovery lifecycle, or hidden authority. The
  fresh restart presentation state is load-bearing because a later direction
  must not double as approval. The explicit handoff packet and entry-state
  comparison are load-bearing because opaque hashes caused E5-CR-005.
- The unlimited and limited reference runners intentionally keep their process
  limits explicit; consolidating them would save little while obscuring the
  discriminator. Restart and integration presentation branches remain separate
  because their authority subjects and post-rejection continuations differ.
- Removed-subsystem check: no gate-manifest/snapshot implementation reference
  remains outside the negative projection assertion and historical documents.

## Epoch 5 amendment Code Review — conditional UX specialist

### E5-UX-001 — Voice-context approvals fail the lexical authority guard

- Review epoch: 5.
- Iteration: specialist discovery.
- Source: `ux-reviewer`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:560` and `poc/prototype.py:772`.
- Statement: after an exact proposal presentation, contextually unambiguous voice
  responses such as “yes, do both” or “looks good, go ahead” become
  clarification under the lexical guard; if the primary understands them as
  approval, the guard hard-fails the prototype.
- Scenario: exact proposal shown, user gives a natural adjacency-based approval,
  primary returns the matching typed approval, lexical guard disagrees, and the
  requested action is withheld or the session terminates.
- Suggested resolution: support a bounded set of contextual confirmations and
  turn guard/model disagreement into visible clarification with concrete accepted
  wording rather than a hard failure.
- Lifecycle: open; no fix applied yet.
- Resolution trigger: required. Contextual confirmation changes the boundary
  between voice-first usability and explicit user authority, so the user-owned
  product premise must be selected before implementation.

## Epoch 5 amendment Code Review — conditional security specialist

### E5-SEC-001 — Validation receipt can attest a dirty tree instead of its candidate

- Review epoch: 5.
- Iteration: specialist discovery.
- Source: `security-researcher`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:3022` and `poc/kernel.py:4334`.
- Statement: final validation executes from a mutable worktree without proving
  immediately before/after that its HEAD, parent, tree, diff, inventory, and
  clean status equal the candidate named by the receipt.
- Scenario: an uncommitted correction appears after candidate construction;
  tests pass against it, the receipt names the older commit, and integration
  fast-forwards to code that did not produce the passing result.
- Suggested resolution: validate from a fresh exact detached candidate checkout
  and persist/revalidate candidate identity in the typed validation artifact.
- Lifecycle: open; no fix applied yet.
- Resolution decision: `local-fix-appropriate` at implementation altitude. The
  accepted candidate/validation invariant already requires this identity; no new
  authority or lifecycle is needed.

### E5-SEC-002 — Handoff digest omits staged file contents

- Review epoch: 5.
- Iteration: specialist discovery.
- Source: `security-researcher`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:1820`, `poc/prototype.py:1855`, and
  `poc/prototype.py:2761`.
- Statement: worktree state includes porcelain status and only the unstaged Git
  diff; porcelain binds staged path/status but not the staged bytes.
- Scenario: staged version A is replaced and staged as version B while HEAD and
  porcelain remain identical; the handoff entry check accepts the different
  content as the checkpointed state.
- Suggested resolution: bind cached binary diff content in addition to unstaged
  and untracked content, and test restaging different bytes under identical
  porcelain status.
- Lifecycle: open; no fix applied yet.
- Resolution decision: `local-fix-appropriate` at implementation altitude. This
  completes the existing exact-state digest without adding an entity or policy.

## Epoch 5 amendment Code Review — security fixes

- E5-SEC-001 lifecycle: actioned; pending specialist re-review. Final validation
  now creates a fresh no-hardlinks detached checkout of the registered candidate,
  proves SHA, direct parent, tree, complete diff hash, changed-path inventory, and
  porcelain-clean state before validation, then proves the same identity after
  validation. Both observations are persisted in the validation artifact, and
  the kernel re-derives their exact expected values from the current candidate
  before issuing a receipt. A dirty/mismatched identity is rejected.
- E5-SEC-002 lifecycle: actioned; pending specialist re-review. Canonical
  worktree state now includes cached binary diff bytes before unstaged and
  untracked content. The handoff prompt names all three surfaces. Regression
  coverage restages different bytes while preserving identical porcelain status
  and proves the entry fence rejects the mismatch.
- Focused validation: 114 Python tests pass.

## Epoch 5 amendment Code Review — security re-review convergence

- Specialist verdict: GREEN. E5-SEC-001 and E5-SEC-002 are resolved; no new
  material security finding within the bounded normal-path scope.
- Exact detached validation identity is independently verified before/after and
  re-derived by the kernel before receipt creation. Cached staged bytes are now
  part of the canonical handoff state and the identical-porcelain restaging
  regression fails closed.
- Security specialist exit: clean. E5-UX-001 remains the sole blocking specialist
  finding and awaits its user-owned product-requirement decision.

## E5-UX-001 resolution decision and plan amendment

- Resolution challenge diagnosis: `requirement-ambiguity` at
  `product-requirement` altitude. “Explicit” approval after an exact adjacent
  presentation was not defined tightly enough to choose between ritual wording,
  bounded contextual confirmation, and model-owned interpretation.
- User decision: Option 2, bounded contextual confirmation tied to the exact
  current proposal and successful presentation.
- Accepted rule: compound restart requires bounded affirmative action language
  plus `both`/`dono`; integration accepts bounded contextual approval/action
  language. Bare assent, questions, uncertainty qualifiers, negation, and
  conflicting language clarify. Arbitrary text or isolated keywords never grant
  authority. Primary interpretation remains required underneath this
  deterministic ceiling.
- Disagreement behavior: if the primary exceeds the ceiling, apply no effect and
  obtain a primary-rendered visible clarification with concrete accepted wording;
  never hard-fail or silently narrow into authority.
- Plan state: amended; focused soundness, adversarial, and minimization review
  must converge before implementation.

## E5-UX-001 focused Plan Review — discovery

- Soundness verdict: RED; two blocking in-scope findings.
- Adversarial verdict: YELLOW CAUTION; three significant in-scope composition
  findings that overlap the soundness obligations.
- E5-UX-RFC-001: open. The contextual ceiling is example-based rather than a
  closed deterministic rule, and the allowed mixed restart disposition has no
  finite classification. Add bounded normalization, a finite v1 table for full
  restart approval, mixed intent-approve/restart-reject, total rejection,
  integration approval/rejection, and default clarification. Same-disposition
  contradictions and every non-match must clarify.
- E5-UX-RFC-002: open. Primary/guard disagreement is specified only for primary
  over-authority. Define total disposition-by-disposition reconciliation: only
  exact match can be terminal/effectful; every mismatch applies nothing, keeps
  the proposal pending, and produces a visible primary clarification. Persist
  rule version, guard result, and both interpretation/clarification output
  identities without adding a new lifecycle entity.
- E5-UX-RFC-003: open. “Current presentation” lacks a lifecycle after
  clarification, unrelated turns, detach/reattach, or rejection. Define which
  artifact remains current and when exact re-presentation is required before a
  later contextual reply can authorize anything.

## E5-UX-001 focused Plan Review — fixes

- E5-UX-RFC-001: actioned pending holistic re-review. The plan now defines
  `voice-approval-v1` with bounded normalization and a finite exact-form table
  for full restart approval, the one allowed mixed restart decision, total
  restart rejection, integration approval/rejection, and all-other clarification.
  Same-disposition contradictions and every non-match clarify.
- E5-UX-RFC-002: actioned pending holistic re-review. Only exact per-disposition
  guard/primary equality may be terminal or effectful. Every mismatch in either
  direction applies nothing, leaves the proposal pending, and records a second
  primary all-clarify output. The existing decision event binds the v1 rule,
  guard dispositions, initial interpretation hash, and clarification hash.
- E5-UX-RFC-003: actioned pending holistic re-review. One ordinary clarification
  and its required primary clarification turn retain the exact presentation;
  unrelated turns and detach invalidate contextual freshness, reattach requires
  exact re-presentation, new presentation supersedes old, and terminal decision
  closes it. Status synchronization is never an approval presentation.
- Review continuation: fresh focused soundness and adversarial re-review must
  find no material gap before minimization and implementation.

## E5-UX-001 focused Plan Review — re-review findings

- Soundness re-review: RED with one blocking and two significant in-scope gaps.
- Adversarial re-review: YELLOW CAUTION with one additional significant in-scope
  composition gap and no blocking scenario.
- E5-UX-RFC-004: open. Define freshness structurally: only the decision attempt
  and its controller-required clarification turn preserve the bound
  presentation; every other intervening user/primary turn invalidates it. Name
  durable evidence and focused tests.
- E5-UX-RFC-005: open. Complete the deterministic top-level aggregate mapping;
  the intent-approve/restart-reject vector aggregates to terminal `reject` while
  applying only its approved intent effect.
- E5-UX-RFC-006: open. Replace generic “punctuation” normalization with one exact
  Unicode character class and order.
- E5-UX-RFC-007: open. A fresh proposal after an intent-only mixed decision must
  not reapply or duplicate the already accepted revision. Define a restart-only
  proposal bound to the current accepted intent version/hash, with only restart
  disposition and no `revise_intent` effect; another intent change instead uses
  a new compound proposal.

## E5-UX-001 focused Plan Review — re-review fixes

- E5-UX-RFC-004: actioned pending final verification. Only a structurally linked
  decision attempt, matching all-clarify result, or single required mismatch-
  clarification turn preserves freshness. Every other turn invalidates by event;
  proposal presentations bind their attached generation, detach invalidates,
  and reattach requires exact re-presentation. Focused transition tests are named.
- E5-UX-RFC-005: actioned pending final verification. Aggregate precedence is
  complete: any clarify yields `clarify`, otherwise any reject yields `reject`,
  else all approve yields `approve`. The mixed vector therefore closes as
  terminal `reject` while applying only its approved intent disposition.
- E5-UX-RFC-006: actioned pending final verification. Normalization order is
  Unicode case-fold, replace Unicode general-category `P*` code points with
  ASCII spaces, collapse whitespace, trim, using the pinned Python Unicode data.
- E5-UX-RFC-007: actioned pending final verification. A post-mixed fresh proposal
  is restart-only and binds exact current accepted-intent version/hash plus the
  snapshot. It carries only restart disposition and cannot call `revise_intent`;
  stale intent blocks it, while another revision uses a new compound proposal.
- Review continuation: one final focused soundness and adversarial verification
  pass, then minimization if clean.

## E5-UX-001 focused Plan Review — final verification correction

- Soundness final verification: GREEN; E5-UX-RFC-004 through E5-UX-RFC-007
  closed with no qualified in-scope finding.
- Adversarial final verification: YELLOW CAUTION with E5-UX-RFC-008, one
  significant in-scope wording conflict. The freshness exception named the user
  attempt and reconciliation turn but omitted the initial mismatching primary
  interpretation required to trigger reconciliation.
- E5-UX-RFC-008: actioned pending narrow adversarial recheck. Freshness now uses
  one structurally related decision episode containing exactly the user attempt,
  its single initial primary interpretation regardless of disposition, and its
  optional single reconciliation turn. Exact terminal match closes; clarify or
  reconciled mismatch retains; only turns outside the episode invalidate.

## E5-UX-001 focused Plan Review — convergence and minimization

- Narrow adversarial recheck: E5-UX-RFC-008 resolved; no contradiction remains.
  Phase 1 soundness/adversarial review is GREEN.
- Minimization verdict: EXCESS with three significant in-scope subtraction
  opportunities, one significant adjacent site-list cleanup, and one
  acknowledged compression opportunity. The restart-only proposal, exact
  normalization/aggregate, freshness outcomes, and mismatch fail-closed behavior
  were confirmed load-bearing.
- Phrase-table action: trimmed near-synonyms to the smallest exercised forms
  while preserving every classification row, the contextual `yes do both` and
  `looks good go ahead` cases, the session's explicit approval forms, and
  default clarification.
- Evidence action: assigned one owner per datum. Proposal presentation owns the
  subject/presentation identity, primary outputs own interpretation and
  clarification payloads, the user decision owns verbatim/final output, and its
  event adds only guard version/dispositions plus output references.
- Freshness action: removed dedicated decision-episode and invalidation-event
  machinery as required implementation surface. Eligibility is derived from the
  pending proposal, latest exact presentation, active generation, and permitted
  intervening turn records; all named freshness outcomes/tests remain.
- Site-list action: removed unchanged `FULL_HARDENING_PLAN.md`, historical
  `run.sh`, and `REVIEW_LEDGER.md` from the active implementation site list.
- Acknowledged repetition: partially compressed at owning sections; no semantic
  obligation was removed.
- Review continuation: one post-minimization soundness and adversarial
  verification pass is required before implementation.

## E5-UX-001 focused Plan Review — post-minimization verification

- Soundness: RED on one blocking narrative/table inconsistency; adversarial:
  YELLOW CAUTION on the same significant scenario. No other protected obligation
  was reopened by minimization.
- Mechanical correction: restored normalized `haan dono approve` to the finite
  compound-restart approval row because the acceptance narrative intentionally
  advertises that Hindi voice example. All other phrase-table trimming remains.
- Final verification scope is only narrative/table identity; the one-owner
  evidence, derived freshness, mixed/restart-only, mismatch clarification,
  presentation lifecycle, and integration paths were independently confirmed.

## E5-UX-001 focused Plan Review — final closure

- Narrow soundness and adversarial checks confirmed the restored Hindi example
  exactly matches the finite normalized table. The sole post-minimization
  inconsistency is resolved.
- Final Plan Review status: GREEN. No blocking/significant in-scope finding,
  user decision, or minimization conflict remains.
- Reviewed plan hash:
  `c9e5376e671caaeb16f96651be8aa5c83327c1c45ec247fb3b8577efa4b5da6b`.
- Implementation authorization: the user selected Option 2 before this focused
  review. Implementation may now proceed only against this reviewed contract.

## E5-UX-001 implementation

- Status: actioned pending fresh Code Review convergence.
- `prototype.py` now owns the exact `voice-approval-v1` Unicode normalization,
  finite form table, deterministic aggregate, and two-turn all-clarify
  reconciliation when the primary interpretation differs from the guard.
- `kernel.py` now validates and records the guard version/dispositions and both
  primary-output references without duplicating the presentation subject. Only
  an exact guard/primary match can be terminal or effectful; a mismatch records
  clarification and leaves the proposal pending.
- Proposal presentations bind the current attached CLI generation. A repeated
  presentation carries that generation in its typed output, the latest one
  supersedes earlier packets, detach invalidates the old packet, and unrelated
  recorded primary output invalidates contextual freshness. The normal
  one-shot-CLI pilot re-presents the exact packet on the decision attachment
  before interpretation.
- A terminal intent-approve/restart-reject decision appends the accepted intent
  exactly once. Its fresh follow-up proposal binds the current accepted-intent
  version/hash and exposes only the restart disposition; approval authorizes
  restart without another `revise_intent` action. A stale identity is rejected.
- Focused coverage now includes punctuation/case normalization, Hindi and
  contextual exact forms, non-match clarification, restart-only decisions,
  primary/guard mismatch then retry, unrelated-turn invalidation,
  detach/reattach re-presentation, stale intent rejection, and preservation of
  intent version 2 across restart-only approval.
- Offline validation: 118 Python unit tests pass; Python compileall, shell
  syntax, `git diff --check`, and Go transport tests pass.
- Next gate: fresh correctness/cohesion, security, and UX Code Review passes;
  simplification; the independent native Codex gate; convergence diagnosis; and
  final RFC-to-code closure.

## Epoch 6 Option 2 Code Review — Phase 1 discovery

### E6-CR-001 — Human response precedes its claimed current presentation

- Review epoch: 6.
- Iteration: phase-1.1 discovery.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:1050`, `poc/prototype.py:1349`, and
  `poc/pty_tui.py:133`.
- Statement: the one-shot PTY detaches after rendering the proposal. On the
  next attachment the controller first receives the user's approval phrase,
  then creates a fresh presentation, then interprets the already-received
  phrase against it. Durable ordering therefore contradicts human chronology.
- Suspected surface: proposal-presentation occurrence ownership and the native
  CLI interaction lifecycle.
- Fix applied: none.
- Lifecycle: open.
- Relationship: spawned-sibling of E6-CR-002 on occurrence identity.

### E6-CR-002 — Content hashes cannot identify repeated output occurrences

- Review epoch: 6.
- Iteration: phase-1.1 discovery.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/kernel.py:1560` and `poc/kernel.py:1722`.
- Statement: primary outputs and proposal presentations use the content hash as
  their row identity while also binding it to one producing turn. A later valid
  turn that emits byte-identical typed JSON conflicts with the earlier turn,
  hard-failing repeated clarification or exact re-presentation.
- Suspected surface: conflation of immutable artifact identity with an
  attributable presentation or primary-output occurrence.
- Fix applied: none.
- Lifecycle: open.
- Relationship: spawned-sibling of E6-CR-001 on occurrence identity.

### Epoch 6 discovery synthesis

- Verdict: RED; both findings are valid blocking in-scope obligations.
- Active-epoch convergence trigger: not fired. Both findings arrived in the
  first discovery pass before any Epoch 6 fix; there is no repeated claimed
  fix, three-iteration threshold, or unresolved requirement ambiguity yet.
- Pre-fix repair candidate: introduce explicit per-turn output/presentation
  occurrences that reference reusable content artifacts, and keep the proposal
  presentation attachment alive long enough for a subsequent human response.
- Material semantic-surface delta: changes durable occurrence identity plus the
  PTY/controller interaction lifecycle and IPC. This triggers a resolution
  challenge before implementation; ordinary symptom fixes are paused.

### Epoch 6 resolution challenge and plan correction

- Diagnosis: local design flaw, high confidence. Both blocking findings expose
  one missing concept: an approval belongs to a unique human-interaction
  occurrence, while immutable typed content may be reused across occurrences.
- Repair altitude: architecture. Relaxing freshness or fabricating a later
  presentation would contradict the accepted informed-approval behavior, so no
  new product choice is required.
- Selected repair: separate content-addressed typed artifacts from attributable
  primary-output and proposal-presentation occurrences, and keep the bounded
  proposal-presenting CLI attached from visible readiness through the subsequent
  response and visible decision acknowledgement.
- Semantic delta: adds narrow occurrence relations/references and a bounded PTY
  readiness/follow-up relay; it does not add a generic session, messaging,
  recovery, or authorization framework.
- E6-CR-001 and E6-CR-002 remain open until reviewed-plan implementation and
  fresh code re-review prove both obligations resolved.
- Review continuation: the corrected plan requires a fresh Plan Review before
  implementation. After implementation, Code Review restarts from Phase 1 in a
  new epoch rather than treating the original RED pass as converged.

## Epoch 6 architecture-correction Plan Review — Phase 1 discovery

- E6-PLAN-RT-01: blocking / in-scope / open. A matching decision can become
  durable before its visible acknowledgement, while the detach rule says a
  pre-acknowledgement detach applies no effect. The authority commit point must
  be explicit and tested.
- E6-PLAN-RT-02: blocking / in-scope / open. A reusable terminal marker is not
  proof of the current presentation occurrence; historical redraw can satisfy
  it. Readiness and acknowledgement evidence must carry a controller-issued
  occurrence-specific token bound to the active generation and turn.
- E6-PLAN-RFC-01: significant / in-scope / open. The plan must join durable
  content/turn evidence with occurrence-bound PTY readiness before opening one
  response, and name the failure direction through acknowledgement.
- E6-PLAN-RFC-02: significant / in-scope / open. The shared PTY driver has a
  legacy one-shot caller and focused prototype tests; compatibility and those
  touched sites cannot remain implicit.
- E6-PLAN-UX-01: significant / in-scope / open. Every initial proposal needs a
  visually distinct input-ready prompt with the exact accepted phrases and the
  no-effect behavior for questions or other wording.
- E6-PLAN-UX-02: significant / in-scope / open. A proposal-bound user question
  must receive an answer from the existing packet when possible before a fresh
  exact presentation; syntax-only clarification is insufficient.
- E6-PLAN-UX-03: significant / in-scope / open. The visible acknowledgement must
  say disposition by disposition what is and is not authorized, current state,
  pause/proceed state, and the smallest next directions.
- Discovery synthesis: RED because of E6-PLAN-RT-01 and E6-PLAN-RT-02. The
  selected occurrence architecture remains root-level and appropriately bounded;
  the findings require completing its commit/observation contract rather than a
  new generic lifecycle framework.

### Epoch 6 architecture-correction Plan Review — fixes

- E6-PLAN-RT-01: actioned pending verification. The plan chooses acknowledgement-
  gated authority: response and interpretation remain non-authorizing; only the
  exact same-generation acknowledgement receipt permits a terminal decision or
  effect. Pre-acknowledgement detach applies nothing and requires fresh
  presentation plus fresh response.
- E6-PLAN-RT-02: actioned pending verification. Readiness and acknowledgement use
  different controller-issued occurrence-specific tokens joined to active
  generation and exact producing-turn evidence. Reusable semantic content and
  historical/redrawn markers cannot satisfy a current observation.
- E6-PLAN-RFC-01: actioned pending verification. The bounded handshake now orders
  durable semantic content and turn, PTY readiness receipt, ready occurrence,
  one subsequent response, non-authorizing interpretation, acknowledgement
  receipt, then terminal decision/effect, with fail-closed detach/token behavior.
- E6-PLAN-RFC-02: actioned pending verification. `pty_tui.py` gains an explicit
  gate-interaction mode while the existing one-shot default and `poc/run.sh`
  caller remain unchanged; focused compatibility coverage and
  `poc/test_prototype.py` are named.
- E6-PLAN-UX-01: actioned pending verification. Every initial gate ends with a
  distinct input-ready prompt listing exact effects, accepted phrases, and the
  no-effect behavior for questions/other wording; integration explains its
  isolated candidate and fast-forward effect.
- E6-PLAN-UX-02: actioned pending verification. Proposal-bound questions remain
  all-clarify but receive an evidence-grounded primary answer before a fresh
  exact presentation; unavailable information is named rather than guessed.
- E6-PLAN-UX-03: actioned pending verification. Acknowledgements explicitly name
  each authorized/non-authorized disposition, preserved state, pause/proceed
  state, and next directions, including mixed restart and integration rejection.
- Review continuation: rerun soundness, adversarial, and UX verification on the
  full corrected plan. No implementation is authorized yet.

### Epoch 6 architecture-correction Plan Review — verification iteration 1

- Soundness: GREEN. E6-PLAN-RFC-01 and E6-PLAN-RFC-02 resolved with no new
  soundness, decision-surface, or temporal contradiction.
- UX: GREEN. E6-PLAN-UX-01 through E6-PLAN-UX-03 resolved with no restart or
  integration flow regression.
- Adversarial: E6-PLAN-RT-01 and E6-PLAN-RT-02 resolved. One new significant
  in-scope finding remains.
- E6-PLAN-RT-03: significant / in-scope / actioned pending verification. The
  proposal prompt and later controller cue could both appear to open input, so a
  fast response invited by the first cue could be discarded at the second.
- E6-PLAN-RT-03 fix: proposal content and transport token now tell the user to
  wait and never claim eligibility. After readiness validation and one-response
  relay arming, the controller renders the sole occurrence-specific input-ready
  cue on the same attachment. Only input arriving after that cue is eligible.
- Review continuation: focused full-plan soundness, adversarial, and UX
  verification of the single-boundary correction; implementation remains paused.

### Epoch 6 architecture-correction Plan Review — Phase 1 convergence

- Soundness verification iteration 2: GREEN; the single authoritative cue is
  ordered after occurrence validation and relay arming and does not compete with
  primary semantic ownership.
- Adversarial verification iteration 2: GREEN CLEAR; E6-PLAN-RT-03 resolved,
  while E6-PLAN-RT-01 and E6-PLAN-RT-02 remain resolved with no regression.
- UX verification iteration 2: GREEN; exact effects/phrases, wait instruction,
  one eligible-now cue, questions, and branch acknowledgements remain coherent
  for restart and integration.
- E6-PLAN-RT-01, E6-PLAN-RT-02, E6-PLAN-RT-03, E6-PLAN-RFC-01,
  E6-PLAN-RFC-02, and E6-PLAN-UX-01 through E6-PLAN-UX-03: closed.
- Phase 1 final status: GREEN with no unresolved blocking or significant
  in-scope finding. Proceed to the required subtractive minimization pass; no
  implementation is authorized yet.

## Epoch 6 architecture-correction Plan Review — Phase 2 minimization

- Minimizer verdict: BLOATED as a plan artifact, while explicitly confirming the
  occurrence/acknowledgement/PTY architecture and all seven Phase 1 obligations
  are load-bearing.
- E6-PLAN-MIN-01: blocking / in-scope / actioned with governing-user-constraint
  qualification. The two derived correction choices were compressed into direct
  consequences. The user-selected occurrence Option 2 remains a full
  Problem/Options/Pros-Cons/Decision ITD because the governing operating model
  explicitly requires accepted ITDs to retain rejected alternatives; deleting
  that structure would violate the user's durable-decision rule.
- E6-PLAN-MIN-02: significant / in-scope / actioned. The repeated gate prose is
  replaced by one canonical ordered chain, the finite phrase table, one branch-
  acknowledgement matrix, and a compact evidence-ownership paragraph.
- E6-PLAN-MIN-03: significant / in-scope / actioned. Acceptance narrative remains
  user-observable, site entries remain ownership/compatibility oriented, focused
  tests remain scenario-only, and temporal sections retain only the transition
  and ordering coverage required by the plan contract.
- Phase 3 continuation: because minimization changed substantive plan text, run
  one full soundness and adversarial verification pass before issuing a fresh
  plan receipt. Implementation remains paused.

### Epoch 6 architecture-correction Plan Review — post-minimization verification

- UX: GREEN; compression retained the exact proposal/effects/phrases, wait
  instruction, sole cue, question behavior, branch state, and next directions.
- Soundness and adversarial reviewers independently found one shared significant
  in-scope acceptance-coverage gap; all protected behavior otherwise survived.
- E6-PLAN-POSTMIN-01: significant / in-scope / actioned pending verification.
  The plan named pre-readiness rejection but not the transport-ready/pre-cue
  window, so an early response could accidentally relay before user eligibility.
  It now requires no relay, interpretation, acknowledgement, terminal decision,
  or effect for any pre-cue input and a fresh exact presentation afterward.
- E6-PLAN-POSTMIN-02: significant / in-scope / actioned pending verification.
  The plan did not explicitly prove that an immediate response after the sole cue
  reaches an already-armed relay. It now requires zero-artificial-delay relay and
  proves that no earlier proposal/token output claims eligibility.
- Review continuation: narrow full-plan soundness and adversarial verification of
  both cue boundaries; implementation remains paused.

### Epoch 6 architecture-correction Plan Review — final closure

- Soundness: GREEN; both sides of the sole cue boundary are explicit and no
  conflicting authority path remains.
- Adversarial: GREEN CLEAR; E6-PLAN-RT-01 through E6-PLAN-RT-03 and
  E6-PLAN-POSTMIN-01/02 are closed with no new scenario.
- Final Plan Review status: GREEN with no unresolved blocking/significant
  in-scope finding or minimization conflict. The full user-selected ITD remains
  intentionally preserved under the governing durable-decision rule.
- Reviewed plan hash:
  `367b7d0cf08ea094342bfb1a4046441bd103ef081593653d2d161db6c4b0c3f9`.
- Implementation authorization: the user selected Option 2; implementation may
  proceed only against this exact reviewed plan.

## Epoch 7 Option 2 implementation Code Review — Phase 1 discovery

### E7-CR-001 — Proposal and acknowledgement bytes are not human-visible

- Review epoch: 7.
- Iteration: phase-1.1 discovery.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/pty_tui.py` PTY capture and `poc/prototype.py` gate-status reader.
- Statement: the PTY stores Codex terminal bytes only as evidence while the outer
  process consumes machine events and prints only the input-ready JSON. The human
  therefore cannot see the proposal or acknowledgement that supposedly grounds
  authority.
- Fix applied: the PTY bridge emits exact base64-framed human-output chunks on
  its machine stream; the controller decodes and flushes them to the outer human
  terminal in stream order while excluding raw frames from driver-log evidence.
- Lifecycle: actioned pending verification.

### E7-CR-002 — Pre-cue outer-terminal input can be relabelled as post-cue

- Review epoch: 7.
- Iteration: phase-1.1 discovery.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py` gate input collection.
- Statement: starting `input()` after the cue does not establish arrival time;
  an approval typed earlier can remain buffered in outer stdin and be accepted
  immediately after the cue.
- Fix applied: an outer-stdin reader starts before proposal rendering and records
  line arrival with a monotonic timestamp. Any completed line at or before the
  flushed cue is rejected, the ready gate is aborted with no decision/effect,
  and the loop requires a fresh presentation.
- Lifecycle: actioned pending verification.

### E7-CR-003 — Initial proposal omits the closed approval vocabulary

- Review epoch: 7.
- Iteration: phase-1.1 discovery.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py` proposal schema and `present_proposal`.
- Statement: the proposal neither receives nor validates the exact applicable
  `voice-approval-v1` phrases, although later hidden classification is closed
  over those phrases.
- Fix applied: the exact applicable phrase-to-disposition map and
  `voice-approval-v1` identity are constant fields in the typed presentation,
  semantic artifact, and kernel validation; the visible proposal must render
  them before readiness.
- Lifecycle: actioned pending verification.

### E7-CR-004 — Acknowledgement token does not prove required branch state

- Review epoch: 7.
- Iteration: phase-1.1 discovery.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py` acknowledgement prompt, schema, and validator.
- Statement: any non-empty summary plus the right token passes. Required
  authorized/unauthorized dispositions, preserved state, pause/proceed status,
  and next direction remain prompt-only, so effects can commit after an
  incomplete acknowledgement.
- Fix applied: each decision derives an exact branch-state object and one exact
  acknowledgement string naming authorized/unauthorized dispositions,
  preserved state, status, next direction, and the primary explanation or
  question answer. The output schema accepts only that string, whose final line
  is the occurrence token; turn completion and exact output validation still
  precede the authority commit.
- Lifecycle: actioned pending verification.

### Epoch 7 discovery synthesis

- Verdict: RED; all four findings are valid blocking in-scope obligations.
- Pattern assessment: one underlying boundary defect, high confidence. The
  controller has machine-observed readiness and acknowledgement events but does
  not yet make the complete human-visible proposal/cue/response/acknowledgement
  contract mechanically authoritative.
- Repair altitude: implementation of the already-reviewed architecture. The
  accepted plan explicitly requires human-visible bytes, exact phrase lists,
  pre-cue rejection, and branch-specific acknowledgements; no new product or
  architecture decision is needed.
- Selected repair direction: separate machine status framing from mirrored human
  PTY bytes; timestamp human input from before presentation; bind the finite
  vocabulary into semantic presentation content; and bind exact branch state
  into the acknowledgement schema before its trailing token.

### Epoch 7 fix validation before re-review

- Focused and full offline validation: 131 Python tests GREEN, including mirrored
  human bytes, outer-stdin pre-cue/post-cue classification, PTY abort, exact
  accepted forms, acknowledgement ordering, immediate post-cue relay, stale
  token rejection, pre-acknowledgement detach, repeated identical content, and
  legacy one-shot compatibility.
- Go transport tests: GREEN.
- Python compilation, shell syntax, diff whitespace: GREEN.
- `poc/run.sh`: unchanged.
- Review continuation: rerun the independent `code-review-analyst` on the full
  corrected diff; Phase 1 remains RED until all four findings close.

### Epoch 7 verification iteration 2

- E7-CR-001: closed. Exact PTY chunks are mirrored before their corresponding
  readiness/acknowledgement event, and raw human frames are excluded from the
  controller driver log.
- E7-CR-002: closed. Outer input is captured before presentation and classified
  against the flushed cue; early input aborts without authority while immediate
  post-cue input remains delay-free.
- E7-CR-003: behaviorally closed. Exact applicable phrases and dispositions are
  visible typed presentation fields and are kernel-validated.
- E7-CR-004: closed. Exact complete branch state precedes the final unique token
  in one schema-constant acknowledgement; exact turn completion and validation
  precede authority commit.
- No regression was found in abort/reader lifecycle, stale-token handling,
  question clarification, or legacy one-shot behavior.

### E7-CR-005 — Approval rule has two independent sources of truth

- Review epoch: 7.
- Iteration: phase-1.2 verification.
- Source: independent `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py` and `poc/kernel.py` approval-rule constants.
- Statement: the currently equal `voice-approval-v1` maps are defined twice; a
  one-sided future edit makes presentation/classification disagree with durable
  kernel validation and breaks affected gates at runtime.
- Repair altitude: implementation; no product or architecture decision needed.
- Fix applied: `poc/kernel.py` is the one versioned rule definition and
  `poc/prototype.py` imports the same version/map object. A focused test asserts
  shared identity and version equality in addition to exact behavioral forms.
- Lifecycle: actioned pending verification.
- Review continuation: rerun focused full-diff verification; Phase 1 is not yet
  GREEN.

### Epoch 7 Code Review — Phase 1 convergence

- Verification iteration 3: GREEN.
- E7-CR-005: closed. `poc/kernel.py` is the sole canonical rule definition;
  `poc/prototype.py` imports the exact same map/version objects and focused tests
  seal identity and behavior.
- E7-CR-001 through E7-CR-004 remain closed on the current full diff.
- Phase 1 final status: GREEN with no unresolved blocking or significant
  in-scope finding. Continue to applicable security, UX, and simplification
  review before the independent native Codex gate.

## Epoch 7 Option 2 implementation Code Review — specialist discovery

### E7-UX-001 — Integration rejection has no recovery path

- Source: independent `ux-reviewer`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py` integration-rejection loop.
- Statement: a non-abandon direction after integration rejection is recorded,
  but the workflow returns instead of constructing a fresh pending integration
  proposal and presentation for the retained candidate. The user therefore
  cannot reconsider or complete the still-live work.
- Lifecycle: accepted; action pending.

### E7-UX-002 — The authoritative cue and recovery feedback are machine JSON

- Source: independent `ux-reviewer`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py` gate cue, early-input rejection, clarification,
  and paused-rejection output.
- Statement: the exact moment at which a voice response becomes eligible, and
  the messages explaining ignored or paused input, are rendered as controller
  event objects rather than direct human instructions.
- Lifecycle: accepted; action pending.

### E7-UX-003 — Acknowledgements lead with internal disposition vocabulary

- Source: independent `ux-reviewer`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py` exact branch acknowledgement.
- Statement: the last pre-effect confirmation leads with internal disposition
  keys instead of a plain statement of the actual accepted/rejected decisions,
  making mixed decisions unnecessarily hard to verify.
- Lifecycle: accepted; action pending.

### E7-SIMP-001 — Proposal gates add a redundant channel-ready primary turn

- Source: independent subtractive `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py` restart/integration report branches and proposal
  presentation helper.
- Statement: the incoming stock-CLI turn first renders a channel-ready marker,
  then a second App Server turn renders the proposal. The incoming turn can
  itself be schema-bound into the exact proposal presentation, just as the
  acknowledgement turn already is. The extra turn adds latency and duplicated
  restart/integration lifecycle fields without discharging another obligation.
- Lifecycle: accepted; action pending.

### Epoch 7 specialist synthesis

- Security: GREEN for the bounded low-stakes scope. Raw terminal mirroring
  intentionally inherits the stock Codex renderer's terminal-control trust
  boundary; hostile output and publish-safe corpus redaction remain deferred.
- UX presentation-envelope density: acknowledged PoC roughness, not blocking.
- Pattern assessment: E7-UX-001 through E7-UX-003 are one human-control-boundary
  gap: the machine retains safe state, but the user cannot always understand or
  resume it. E7-SIMP-001 is a separate avoidable lifecycle duplication.
- Selected repair altitude: local implementation. No accepted product decision,
  reviewed plan obligation, or deferred production-hardening boundary changes.

### Epoch 7 specialist fixes before re-review

- E7-UX-001 actioned: a rejected integration proposal remains terminal, the
  candidate remains isolated and pending, and any later non-abandon direction
  returns to the integration loop by creating a new proposal identity over the
  same exact reviewed subject. Creating that fresh proposal restores the work
  item to `integration_pending`; only its own fresh presentation and response
  can authorize integration.
- E7-UX-002 actioned: the sole cue, pre-cue rejection, paused-direction request,
  fresh-presentation notice, and clarification retry now use direct human
  language. Machine status framing remains internal to the PTY/controller
  channel.
- E7-UX-003 actioned: every exact acknowledgement begins with a deterministic
  plain-language decision sentence, including compound mixed decisions, before
  the detailed disposition/evidence lines and final occurrence token.
- E7-SIMP-001 actioned: the incoming attached stock-CLI turn is rewritten and
  schema-bound directly into the exact proposal-presentation turn. Redundant
  channel-ready turns, markers, `last_*_decision` fields, and parallel active
  presentation fields were removed. The active occurrence lives in
  `pending_gate`; only the successfully acknowledged integration packet hash is
  retained after the gate.
- Validation: 132 Python tests GREEN; Go transport tests GREEN; Python compile,
  shell syntax, and diff whitespace GREEN. Coverage now includes rejected
  integration -> fresh proposal -> approval at the durable kernel boundary.
- Review continuation: independent UX, simplification, and security verification
  remain required before specialist convergence.

### Epoch 7 specialist re-review convergence

- UX: GREEN. E7-UX-001, E7-UX-002, and E7-UX-003 are resolved; no new blocking
  or significant in-scope UX finding.
- Simplification: GREEN. E7-SIMP-001 is resolved; the incoming stock-CLI turn is
  the proposal turn, redundant fields/markers are absent, and the remaining
  per-kind events are only coordination details.
- Security: GREEN. Fresh integration proposals bind the same exact pending
  candidate and immutable subject; active identity comes only from
  `pending_gate`; the acknowledged packet is re-resolved through SQLite before
  integration. No new blocking or significant in-scope security finding.
- All specialist findings are resolved. The trusted stock CLI renderer's raw
  terminal-control boundary remains the already-declared deferred qualification.

### Epoch 7 convergence diagnosis

- Mode: convergence diagnosis.
- Diagnosis: `local-design-flaw` (high confidence).
- Evidence cluster: E7-CR-001 through E7-CR-004 and E7-UX-001 through E7-UX-003
  all occurred where machine-observed gate state was mistaken for a complete
  human control boundary. E7-SIMP-001 was a sibling symptom: splitting one
  human proposal interaction across two primary turns created another mutable
  representation without another obligation.
- Repair altitude: implementation. The reviewed plan already specified the
  end-to-end human-visible proposal -> sole cue -> subsequent response -> exact
  acknowledgement -> effect invariant, plus paused rejection recovery. No
  product choice, scope change, or architecture amendment was missing.
- Rationale: one occurrence-owned `pending_gate`, direct forwarding of the
  attached proposal turn, exact human-byte mirroring, finite visible phrases,
  pre-cue timestamping, branch-specific acknowledgement, and fresh proposal
  identities close the whole boundary without new general lifecycle machinery.
- Next action: resume the recorded Code Review continuation at the independent
  native Codex gate. No new blocking or significant finding was revealed by
  the diagnosis.

## Epoch 7 native Codex hard gate — discovery

### E7-NATIVE-001 — Gate detach while awaiting human input hangs the workflow

- Source: `codex review --uncommitted`, Codex session
  `019fc7a8-fa71-7bd1-93fa-7e1da6e6d589`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:_await_gate_human_input`.
- Statement: after the cue, the controller blocks only on outer stdin. If the
  proposal-presenting CLI detaches first, `driver_eof` is never observed and the
  paused proposal cannot be freshly presented.
- Lifecycle: accepted; action pending.

### E7-NATIVE-002 — Pre-acknowledgement detach terminal-fails paused work

- Source: `codex review --uncommitted`, Codex session
  `019fc7a8-fa71-7bd1-93fa-7e1da6e6d589`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:_read_gate_event` and `run_gate_interaction`.
- Statement: detach after response relay or interpretation but before the exact
  acknowledgement becomes a hard failure. The reviewed contract instead keeps
  the proposal paused and requires a fresh occurrence and response.
- Lifecycle: accepted; action pending.

### E7-NATIVE-003 — Concurrent exact-turn waiters can exchange and hide events

- Source: `codex review --uncommitted`, Codex session
  `019fc7a8-fa71-7bd1-93fa-7e1da6e6d589`.
- Severity / scope: blocking / in-scope.
- Location: `poc/controller.py:_wait_for_exact_turn`.
- Statement: two waiters destructively consume one shared queue and privately
  defer nonmatching completions. Each can therefore hold the other's event and
  both can time out despite both turns having completed.
- Lifecycle: accepted; action pending.

### E7-NATIVE-004 — SIGTERM bypasses durable terminalization and cleanup

- Source: `codex review --uncommitted`, Codex session
  `019fc7a8-fa71-7bd1-93fa-7e1da6e6d589`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:main`.
- Statement: the prototype installs no SIGTERM handler, so ordinary service or
  launcher termination skips the exception/finally path that records terminal
  state, revokes capabilities, cleans children, and copies final evidence.
- Lifecycle: accepted; action pending.

### E7-NATIVE-005 — Cue rendering precedes its eligibility cutoff

- Source: `codex review --uncommitted`, Codex session
  `019fc7a8-fa71-7bd1-93fa-7e1da6e6d589`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py:run_gate_interaction`.
- Statement: the visible cue is flushed before its timestamp is captured, so a
  response entered immediately after seeing the cue can still be rejected as
  pre-cue input.
- Lifecycle: accepted; action pending.

### Epoch 7 native-gate pattern assessment

- E7-NATIVE-001, E7-NATIVE-002, and E7-NATIVE-005 are one remaining lifecycle
  boundary gap: the proposal occurrence coordinates independent terminal,
  driver-status, and outer-input streams without one explicit detach outcome or
  one synchronized cue/input eligibility boundary.
- E7-NATIVE-003 is a separate shared-consumer ownership flaw: an observation
  cache already exists, but exact waiters still destructively compete on the
  legacy notification queue.
- E7-NATIVE-004 is a separate terminal-entry omission; the cleanup path itself
  already exists and only SIGTERM bypasses it.
- Selected repair altitude: local implementation. All five obligations are
  already explicit in the reviewed plan; no product decision, architecture
  amendment, or full-hardening expansion is required.

### Epoch 7 native-gate fixes before re-review

- E7-NATIVE-001 actioned: the human-input wait now multiplexes the driver-status
  queue, so detach interrupts the wait and returns the unchanged proposal to the
  existing retry loop. A blocked outer-input reader is carried into the fresh
  occurrence instead of being orphaned; any input captured across detach is
  explicitly ineligible for the new occurrence.
- E7-NATIVE-002 actioned: driver EOF before acknowledgement has its own
  nonterminal `GateDetached` outcome. The driver is reaped, occurrence-local
  staged state is discarded, and the proposal is freshly presented. Each gate
  now owns its decision event, so a late completion from the detached occurrence
  cannot wake or stage a successor occurrence.
- E7-NATIVE-003 actioned: exact-turn waiters now observe the existing
  `(thread_id, turn_id)` completion cache under one condition variable. They no
  longer destructively consume or privately defer another waiter's queue item.
- E7-NATIVE-004 actioned: SIGTERM and SIGINT are converted into the prototype's
  existing in-process operator-interruption path, which records abandonment and
  executes the common finalization and cleanup block.
- E7-NATIVE-005 actioned: cue rendering and the input-eligibility transition now
  occur under the same boundary lock. The cue is flushed before eligibility is
  opened, while the input reader classifies its line under that same lock.
- Focused validation: 69 controller/prototype/phase-4 tests GREEN. New coverage
  exercises independent concurrent exact-turn waiters, detach during the human
  wait, pre-ack driver EOF, input-reader carry with stale-input invalidation,
  synchronized post-cue input, and the SIGTERM interruption handler.
- Full validation: 137 Python tests GREEN; Go transport tests GREEN; Python
  compilation, shell syntax, and `git diff --check` GREEN.
- Lifecycle: E7-NATIVE-001 through E7-NATIVE-005 actioned; all remain open
  pending a fresh native Codex holistic re-review.

## Epoch 7 native Codex hard gate — holistic re-review discovery

### E7-NATIVE-006 — Stock validation rejects controller-owned gate schemas

- Source: `codex review --uncommitted`, Codex session
  `019fc7bb-cfc6-7a71-986a-cf5f365680af`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:present_proposal` and
  `_forward_acknowledgement_turn`; `poc/controller.py:canonicalize_primary_mutation`.
- Statement: proposal and acknowledgement helpers place their controller-owned
  schema into the stock TUI request and then send it through stock authority
  validation, which correctly rejects every stock-supplied non-null schema. The
  first approval gate therefore creates no primary turn.
- Lifecycle: accepted; action pending.

### E7-NATIVE-007 — Consumed detached input state reuses a dead reader

- Source: `codex review --uncommitted`, Codex session
  `019fc7bb-cfc6-7a71-986a-cf5f365680af`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:_start_gate_input_reader`.
- Statement: detach after the one-shot reader's response was consumed carries an
  empty queue and dead reader into the successor occurrence, which can never
  receive another response.
- Lifecycle: accepted; action pending.

### E7-NATIVE-008 — Post-commit driver close enters the no-effect retry path

- Source: `codex review --uncommitted`, Codex session
  `019fc7bb-cfc6-7a71-986a-cf5f365680af`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:run_gate_interaction`.
- Statement: a broken command pipe during CLI completion is caught by the same
  handler as a pre-acknowledgement detach even after the exact decision and its
  effects were durably committed. The user is falsely told nothing changed and
  a terminal proposal may be retried.
- Lifecycle: accepted; action pending.

### E7-NATIVE-009 — Artifact identity hashes bytes that are not persisted

- Source: `codex review --uncommitted`, Codex session
  `019fc7bb-cfc6-7a71-986a-cf5f365680af`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:_store_artifact`.
- Statement: the artifact name and SQLite identity hash raw content, while the
  evidence writer redacts the file bytes. Content matching a redaction pattern
  therefore has an identity that cannot verify against its persisted file.
- Lifecycle: accepted; action pending.

### E7-NATIVE-010 — Launcher SIGTERM does not reach the prototype process

- Source: `codex review --uncommitted`, Codex session
  `019fc7bb-cfc6-7a71-986a-cf5f365680af`.
- Severity / scope: blocking / in-scope.
- Location: `poc/run-prototype.sh`.
- Statement: a supervisor signal to the launcher shell runs its EXIT cleanup
  without forwarding SIGTERM to foreground Python. The prototype can remain
  alive against a removed runtime and never execute its new durable interruption
  path.
- Lifecycle: accepted; action pending.

### Epoch 7 holistic re-review pattern assessment

- E7-NATIVE-006 is an authority-path composition defect: trusted controller
  additions and untrusted stock fields were collapsed into one validation
  channel. Stock schema injection must remain rejected while a separate internal
  argument carries the controller-owned schema after canonicalization.
- E7-NATIVE-007 and E7-NATIVE-008 refine the prior gate lifecycle cluster at two
  precise cut points: consumed input state versus blocked input state, and
  pre-commit detach versus post-commit transport cleanup.
- E7-NATIVE-010 is the launcher half of E7-NATIVE-004; in-process signal handling
  cannot help until the owning shell forwards the signal and waits for cleanup.
- E7-NATIVE-009 is a separate artifact-boundary identity flaw. The persisted,
  already-redacted bytes—not their pre-redaction source—must define the artifact
  hash and any exact typed record that recomputes it.
- Selected repair altitude: local implementation. These are contradictions
  between existing components and already-reviewed invariants, not missing
  product decisions or reasons to expand into the deferred hardening track.

### Epoch 7 holistic re-review fixes before next native pass

- E7-NATIVE-006 actioned: stock requests still reject any non-null
  `outputSchema`. Proposal and acknowledgement schemas now travel in a separate
  trusted internal argument and are added only after the stock request has been
  canonicalized. A focused test proves both halves of this boundary.
- E7-NATIVE-007 actioned: carried input state is reused only when it contains a
  stale queued line that must be rejected or its one reader remains blocked and
  live. An empty queue with a consumed/dead reader creates a fresh reader.
- E7-NATIVE-008 actioned: the pre-commit try/retry region now ends before
  `_commit_staged_gate_decision`. A broken completion pipe after commit is
  recorded as post-commit transport cleanup and returns the already-committed
  route; it never emits the no-effect message or re-presents the proposal.
- E7-NATIVE-009 actioned: `_store_artifact` redacts exactly once before deriving
  bytes, hash, filename, SQLite artifact registration, and file content.
  Typed primary, proposal, role-review, native-review, and validation records
  use the same redacted persisted representation wherever the kernel recomputes
  the artifact hash. A focused test hashes the actual file and matches its
  registered bytes.
- E7-NATIVE-010 actioned: the launcher now owns the Python PID, forwards TERM/INT,
  explicitly preserves stdin, and continues waiting after a trapped signal until
  Python completes its in-process finalization. Only then may the EXIT trap remove
  runtime state. An isolated signal test observed the child handler's status `2`
  through the same forward-and-wait loop.
- Focused validation: 73 controller/prototype/phase-4 tests GREEN.
- Full validation: 141 Python tests GREEN; Go transport tests GREEN; Python
  compilation, all shell syntax, and `git diff --check` GREEN.
- Lifecycle: E7-NATIVE-006 through E7-NATIVE-010 actioned; all remain open
  pending another fresh native Codex holistic re-review.

## Epoch 7 native Codex hard gate — second holistic re-review discovery

### E7-NATIVE-011 — Presentation-host failures are not propagated

- Review epoch / iteration: 7 / Phase 3 discovery after E7-NATIVE-006 through
  E7-NATIVE-010.
- Source: `codex review --uncommitted`, Codex session
  `019fc7d0-5ff3-79b2-910d-acd00bbe367c`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:start_presentation_host` host loop.
- Statement: an exception from the downstream-session handler terminates only
  the daemon presentation thread. The gate sees ordinary detach and can retry
  forever against a dead host instead of surfacing the hard failure.
- Suspected surface: presentation-host error ownership and gate lifecycle.
- Relationship: spawned-sibling of E7-NATIVE-001 and E7-NATIVE-002.
- Fix applied: the presentation host records its exact background failure and
  wakes every host-aware event, gate-status, gate-input, and CLI waiter. A dead
  host now becomes one visible hard failure instead of an ordinary detach retry.
- Lifecycle: actioned; pending fresh holistic review.

### E7-NATIVE-012 — Shutdown joins before disconnecting the active presentation

- Review epoch / iteration: 7 / Phase 3 discovery after E7-NATIVE-006 through
  E7-NATIVE-010.
- Source: `codex review --uncommitted`, Codex session
  `019fc7d0-5ff3-79b2-910d-acd00bbe367c`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:stop_presentation_host`.
- Statement: interruption or failure can leave the host blocked in the active
  downstream read while shutdown closes only the listener and immediately
  joins. Cleanup then times out, overwrites the intended interruption status,
  and races final evidence/database closure.
- Suspected surface: presentation ownership and terminal cleanup ordering.
- Relationship: spawned-sibling of E7-NATIVE-004 and E7-NATIVE-010.
- Fix applied: shutdown closes admission, closes the listener, shuts down the
  active downstream socket, drains queued sessions, and only then joins the
  presentation host. The host rejects a dequeued session after stop begins.
- Lifecycle: actioned; pending fresh holistic review.

### E7-NATIVE-013 — Asynchronous CLIs are outside final child ownership

- Review epoch / iteration: 7 / Phase 3 discovery after E7-NATIVE-006 through
  E7-NATIVE-010.
- Source: `codex review --uncommitted`, Codex session
  `019fc7d0-5ff3-79b2-910d-acd00bbe367c`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py:run_cli` and final cleanup.
- Statement: an asynchronous intake, reattach, or gate CLI that has not reached
  its normal waiter/reaper when another stage fails is not registered with the
  controller cleanup path. It can survive runtime removal and continue writing
  evidence after the controller exits.
- Suspected surface: subprocess lifecycle ownership.
- Relationship: spawned-sibling of E7-NATIVE-004, E7-NATIVE-008, and
  E7-NATIVE-010.
- Fix applied: every asynchronous CLI is registered at creation and removed
  only after its normal waiter or gate reaper completes. Final child cleanup
  terminates and waits for all remaining registered CLIs before the transport
  and App Server are reaped.
- Lifecycle: actioned; pending fresh holistic review.

### E7-NATIVE-014 — EOF and blank gate input terminalize live work

- Review epoch / iteration: 7 / Phase 3 discovery after E7-NATIVE-006 through
  E7-NATIVE-010.
- Source: `codex review --uncommitted`, Codex session
  `019fc7d0-5ff3-79b2-910d-acd00bbe367c`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py:_await_gate_human_input`.
- Statement: both stdin EOF and a blank line become the same hard failure. EOF
  should enter the existing operator-interruption path; blank input is
  non-authorizing and should leave the proposal unchanged for fresh
  presentation.
- Suspected surface: human-input lifecycle classification.
- Relationship: spawned-sibling of E7-NATIVE-001, E7-NATIVE-005, and
  E7-NATIVE-007.
- Fix applied: raw EOF raises the existing operator-interruption outcome; a
  blank line raises a bounded non-authorizing outcome that aborts the current
  gate, records no decision/effect, and returns to fresh presentation.
- Lifecycle: actioned; pending fresh holistic review.

### Epoch 7 convergence checkpoint — CP-E7-NATIVE-003

- Review epoch: 7.
- Triggered at: Phase 3 discovery, pre-fix.
- Continuation:
  - phase: `phase-3`
  - boundary: `pre-fix`
  - lane: `gating`
  - required next action: disposition and repair of E7-NATIVE-011 through
    E7-NATIVE-014, followed by the review action selected by convergence
    diagnosis.
- Trigger: new blocking sibling findings continue to appear at presentation,
  interruption, and subprocess lifecycle cut points after two native-gate fix
  batches; the active epoch also exceeds three substantive iterations.
- Evidence clusters:
  - E7-NATIVE-001, E7-NATIVE-002, E7-NATIVE-007, E7-NATIVE-008,
    E7-NATIVE-011, and E7-NATIVE-014 share incomplete ownership of proposal
    interaction outcomes across the host, PTY driver, and stdin.
  - E7-NATIVE-004, E7-NATIVE-010, E7-NATIVE-012, and E7-NATIVE-013 share
    incomplete terminal cleanup ownership across the launcher, presentation
    host, and asynchronous CLI processes.
- Diagnosis: `local-design-flaw` (high confidence). Asynchronous resources and
  outcomes are locally awaited but not supervised by the existing top-level
  `LowStakesPrototype` owner across failure and cleanup paths. E7-NATIVE-011
  and E7-NATIVE-014 continue the proposal-interaction cluster;
  E7-NATIVE-012 and E7-NATIVE-013 continue the terminal-cleanup cluster.
  E7-NATIVE-006 and E7-NATIVE-009 remain separate resolved defects.
- Repair altitude: implementation.
- Resolution decision: make the existing prototype owner expose one
  presentation-host failure signal, disconnect the active presentation before
  joining its host, register every asynchronous CLI until its normal
  waiter/reaper completes, and classify EOF as operator interruption while a
  blank line triggers a no-effect fresh presentation. This adds only bounded
  in-process ownership fields/helpers and focused tests; it adds no SQLite
  state, external interface, durable protocol, authority, automatic recovery,
  or production-hardening claim.
- Action: implement that bounded owner-level repair, validate it, then begin a
  new review epoch at counter zero and restart independent review rather than
  resuming ordinary review inside Epoch 7.
- Status: actioned.
- Status evidence: independent `review-convergence-analyst` diagnosis accepted
  the four findings, selected implementation altitude, and revealed no new
  blocking or significant finding.

### Epoch 7 owner-level lifecycle repair and validation

- E7-NATIVE-011 actioned: one presentation-host failure signal and retained
  exception are owned by `LowStakesPrototype`. Intake, reattach, proposal
  durability, gate status/input, acknowledgement evidence, and asynchronous CLI
  waiters check that signal and surface the exact background failure.
- E7-NATIVE-012 actioned: finalization disconnects the active presentation and
  closes queued sessions before joining the host. Admission closes before any
  of those operations, and a session dequeued after stop is rejected.
- E7-NATIVE-013 actioned: asynchronous intake, reattach, and gate CLIs enter one
  in-process registry on launch. Normal waiters/reapers unregister only after
  process completion; common final cleanup reaps every outstanding entry before
  controller children.
- E7-NATIVE-014 actioned: EOF enters the existing operator-interruption path;
  blank input aborts the occurrence, applies nothing, and returns `retry` for a
  fresh presentation.
- Focused coverage proves host-failure propagation, disconnect-before-join,
  cleanup of every registered CLI, EOF/blank classification, blank no-effect
  gate retry, and the pre-existing detach path.
- Full validation: 146 Python tests GREEN; Go transport tests GREEN; Python
  compilation, all shell syntax, and `git diff --check` GREEN.
- Checkpoint continuation: begin review epoch 8 at counter zero and restart
  independent Code Review. CP-E7-NATIVE-003 remains actioned until a clean
  restarted Phase 3 discovery pass proves the ownership cluster closed.

## Epoch 8 restarted Code Review — Phase 1 discovery

- Reviewer independence: fresh `code-review-analyst` received the current scope,
  plan, full diff, new files, and surrounding code without this ledger, prior
  findings, claimed fixes, or root-cause history.
- Validation observed before dispatch: 146 Python tests GREEN; Go transport
  tests, Python compilation, shell syntax, and `git diff --check` GREEN.
- Verdict: RED. One blocking and one significant in-scope finding are open.

### E8-CR-001 — Receipt-producing review roles may omit their result artifact

- Review epoch / iteration: 8 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py` role-output schema/validation and gate-receipt
  derivation.
- Statement: a clean plan or code reviewer may validly return
  `artifact_content: null`, but gate-receipt derivation unconditionally requires
  its artifact hash and hard-fails the otherwise valid happy path.
- Suspected surface: role-output contract and receipt eligibility.
- Fix applied: receipt-producing role schemas, runtime validation, and the five
  review/closure role contracts now require a non-empty review artifact. A
  focused contract test covers null, blank, and valid artifact content.
- Lifecycle: resolved.
- Verification: fresh independent holistic Phase 1 discovery did not reproduce
  the producer/consumer contradiction after the contract repair; 148 Python
  tests and Go transport tests remained GREEN.
- Resolution decision: local implementation. Require a non-empty exact artifact
  from every receipt-producing review/closure role in the schema, validator,
  and role contract. This aligns an existing producer contract with its existing
  consumer and adds no state, authority, lifecycle, or external interface.

### E8-CR-002 — The large memory corpus does not test global deduplication

- Review epoch / iteration: 8 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/fixture/memory_gate.py` corpus generation and expected-output
  validation.
- Statement: the two-million-record corpus contains only unique values. An
  implementation that deduplicates within each spill chunk but not across
  merged chunks can pass the small fixture and the memory gate.
- Suspected surface: final acceptance discriminator.
- Fix applied: the existing two-million-record corpus now includes a bounded
  deterministic duplicate suffix whose matching originals occur in the
  earlier input region. Exact output is still the complete ascending unique
  range. A negative control that deduplicates two regions independently and
  merges them without global suppression now fails the gate.
- Lifecycle: resolved.
- Verification: fresh independent holistic Phase 1 discovery did not reproduce
  the acceptance-corpus gap after the discriminator repair; its focused
  negative control and the full 148-test Python suite remained GREEN.
- Resolution decision: local implementation. Generate deterministic duplicates
  separated across spill-chunk boundaries while retaining two million input
  records, validate the exact unique range, and add a focused test. This changes
  only the existing test corpus, not product behavior or the accepted plan.

### Epoch 8 discovery synthesis

- The findings have no common root: E8-CR-001 is a producer/consumer contract
  contradiction; E8-CR-002 is an incomplete acceptance corpus.
- No active-epoch convergence trigger fires before this first Epoch 8 fix
  iteration. The recorded continuation is Phase 1 post-fix holistic discovery.

### Epoch 8 Phase 1 fix iteration 1 validation

- Focused receipt-artifact and memory-discriminator tests: GREEN.
- Full offline validation: 148 Python tests GREEN; Go transport tests GREEN;
  Python compilation, all shell syntax, and `git diff --check` GREEN.
- E8-CR-001 and E8-CR-002 remain `actioned` until a fresh independent holistic
  Phase 1 discovery pass verifies the current implementation.
- Convergence assessment: no trigger. This is the first substantive fix
  iteration in Epoch 8, the findings have different roots, and neither fix
  expands state, authority, lifecycle, protocol, or external surface.

## Epoch 8 restarted Code Review — Phase 1 discovery 2

- Reviewer independence: a fresh `code-review-analyst` received the accepted
  scope, plan, full base-to-working-tree diff, untracked files, and surrounding
  code without this ledger, prior findings, claimed fixes, or root-cause
  history.
- Validation observed independently: 148 Python tests GREEN; Go transport tests
  and `git diff --check` GREEN.
- Verdict: RED. Two blocking and one significant in-scope finding are open.
- Prior-finding verification: E8-CR-001 and E8-CR-002 did not reproduce and are
  resolved above.

### E8-CR-003 — Pilot launch does not bind the proven Phase 4 qualification packet

- Review epoch / iteration: 8 / Phase 1 discovery 2.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/run-prototype.sh` launch contract and prototype preflight.
- Statement: the ordinary pilot runner accepts only a run ID and never consumes
  or validates the required passing Phase 4 qualification packet. Runtime
  initialization checks only expected profile names and therefore does not
  bind exact database denial, configuration equivalence, Codex version, or
  executable provenance to this run.
- Demonstrated scenario: the previously qualified configuration or Codex
  executable drifts; the name-only preflight still passes; workers execute and
  the prototype can report PASS without current evidence for the worker
  isolation boundary.
- Suspected surface: pre-execution evidence binding at the ordinary pilot
  runner boundary.
- Fix applied: `run-prototype.sh` now accepts the exact qualification packet,
  captures the current runtime permission config, executable/source manifest,
  and Codex version, then invokes the existing Phase 4 qualification verifier
  before `prototype.py` starts. The owner-only binding persists the packet
  digest and exact runtime-input hashes; `prototype.py` refuses a non-passing
  binding before creating the workflow.
- Lifecycle: resolved.
- Verification: fresh Epoch 9 review accepted the pre-run qualification packet,
  config/version/provenance binding itself; its separate provenance finding is
  about the ordinary prototype source inventory, not the Phase 4 boundary.
- Resolution decision: bounded runner-owned implementation under
  CP-E8-CR-001.

### E8-CR-004 — Pilot success has no independent acceptance-narrative verifier

- Review epoch / iteration: 8 / Phase 1 discovery 2.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/run-prototype.sh` post-execution success boundary.
- Statement: the runner returns `prototype.py`'s exit status directly. No
  bounded `poc/assert.py` mode or smaller independent verifier checks saved
  evidence against the accepted narrative before PASS.
- Demonstrated scenario: an orchestration defect skips or misrecords a required
  transition but reaches the implementation's internal success path; the runner
  exits zero and publishes an unverified happy-path success.
- Suspected surface: post-execution independent evidence verification and final
  runner exit semantics.
- Fix applied: new bounded `poc/prototype_assert.py` independently revalidates
  the qualification packet, checks SQLite integrity/foreign keys and projection
  identities, proves the required attempt/restart/ask/handoff/review/closure/
  validation/integration narrative, and cross-checks the exact report and
  candidate. The producer emits only `completed` with verification pending;
  only this verifier can emit final `PASS` and allow runner status zero.
- Lifecycle: actioned.
- Verification status: Epoch 9 confirmed the verifier exists and owns final
  PASS, but found its SQLite value binding and approval-occurrence proof
  incomplete. The original obligation therefore remains actioned, not resolved.
- Resolution decision: bounded runner-owned implementation under
  CP-E8-CR-001.

### E8-CR-005 — Prototype report is transient on rejection and incomplete on success

- Review epoch / iteration: 8 / Phase 1 discovery 2.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py` rejection, abandonment, and final-report paths.
- Statement: rejection writes a non-terminal snapshot and later abandonment
  leaves that report unchanged. The success report records identifiers but omits
  the required user-visible interaction timeline, lineage narrative, exact
  diff/tests/reviews/closure account, and manual-intervention summary.
- Demonstrated scenario: the user rejects then explicitly abandons, but the
  retained report still says the controller is live; alternatively a successful
  run cannot be judged from the required ordinary plain-language report.
- Suspected surface: terminal report projection from durable workflow evidence.
- Fix applied: in-flight rejection report writes were removed. Common final
  cleanup now writes one report from the terminal durable projection for
  completion, abandonment, interruption, or failure. It includes the
  interaction timeline, intent/attempt/run/event/artifact lineage, exact diff
  and validation, review findings/receipts, closure and integration trace,
  interventions, unsupported behavior, and deferred claims. Focused tests prove
  reject-then-abandon cannot retain `controller_live: true`.
- Lifecycle: resolved.
- Verification: fresh Epoch 9 review did not reproduce transient rejection
  reporting or missing terminal report contents.
- Resolution decision: bounded terminal projection under CP-E8-CR-001.

### CP-E8-CR-001 — Acceptance proof and report ownership

- Trigger: after the first Epoch 8 substantive fix iteration, a fresh holistic
  pass found multiple new acceptance-completion sites. E8-CR-003 and E8-CR-004
  are opposite sides of the same runner boundary; E8-CR-005 may be another
  symptom of final evidence/report ownership rather than an independent local
  omission.
- Diagnosis: `local-design-flaw` (high confidence). The producer currently
  self-declares success, while the runner owns neither the Phase 4 precondition
  nor an independent postcondition, so the report is also left as an in-flight
  snapshot instead of a terminal durable projection. These are sibling symptoms
  of one incomplete acceptance boundary.
- Repair altitude: implementation. The accepted plan already assigns bounded
  launch, exit, evidence, independent-verifier, and final-report ownership; no
  product or architecture decision is missing.
- Resolution decision: make the ordinary runner bind the exact qualification
  packet before launch, produce one terminal report after final projection, and
  run one bounded independent verifier before emitting PASS. Reuse only the
  existing qualification-binding logic; add no SQLite tables, report lifecycle,
  approval packet, generic event/recovery machinery, retries, or deferred
  race/security/crash-hardening checks.
- Continuation: Epoch 8 / Phase 1 / pre-fix / discovery. After the bounded fix
  and full validation, restart Code Review in Epoch 9 rather than resuming
  ordinary discovery inside Epoch 8.
- Status: actioned.
- Required action: independently diagnose the shared root, preserve all three
  obligations, and choose implementation, architecture, or product/requirement
  repair altitude before any remedy is implemented.
- Status evidence: independent `review-convergence-analyst` accepted all three
  findings, selected implementation altitude, and revealed no new blocking or
  significant finding.

### Epoch 8 acceptance-boundary repair and validation

- Preflight integration check: the reused qualification logic bound the current
  manifest and existing sealed Phase 4 packet with PASS, Codex CLI `0.146.0`,
  packet digest `05126be67766cad2b89a6167fed88cdfe724907bfe0ebe1947063bdcf6383717`,
  and no violations. No model or external-agent run was launched.
- Focused verification proves qualification binding persistence, independent
  rejection of a missing durable transition and report drift, exact SQLite-to-
  projection identity binding, successful complete-narrative assessment, and
  terminal rejection-to-abandonment reporting.
- Full offline validation: 153 Python tests GREEN; Go transport tests GREEN;
  Python compilation, all shell syntax, and `git diff --check` GREEN.
- At this checkpoint E8-CR-003, E8-CR-004, and E8-CR-005 remained `actioned`
  pending fresh review. Epoch 9 later resolved E8-CR-003 and E8-CR-005 while
  keeping E8-CR-004 actioned because its independent proof remained incomplete.

## Epoch 9 restarted Code Review — Phase 1 discovery 1

- Reviewer independence: fresh `code-review-analyst` received accepted scope,
  plan, full base-to-working-tree diff, untracked files, and surrounding code
  without this ledger or any prior finding/fix/root-cause history.
- Validation observed independently: 153 Python tests GREEN; Go transport tests
  and `git diff --check` GREEN.
- Verdict: RED. Two blocking and one significant in-scope finding are open.

### E9-CR-001 — SQLite binding compares identities but not row values

- Review epoch / iteration: 9 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype_assert.py` database-to-projection binding.
- Statement: the verifier compares only row identity sets for every table except
  `work_items`. Attempt states, candidate tree/diff, receipt contents,
  validation, proposal subjects, and event payloads may differ between SQLite
  and the asserted saved projection while the binding still passes.
- Demonstrated scenario: a healthy SQLite event and saved projection share the
  same sequence ID but name different integration candidates; all current
  database facts remain true.
- Suspected surface: independent canonical projection reconstruction.
- Fix applied: none.
- Lifecycle: open.
- Resolution decision: pending convergence diagnosis.

### E9-CR-002 — Final verifier does not prove the occurrence-bound approval chain

- Review epoch / iteration: 9 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype_assert.py` authority checks and persisted gate
  observation evidence.
- Statement: restart/integration proof is reduced to one approve decision for
  each proposal kind. It does not independently establish the latest exact
  presentation, active generation, readiness/cue, subsequent response,
  interpretation occurrence, matching acknowledgement observation, and
  ordering before authority effects.
- Demonstrated scenario: decision rows containing uncorrelated acknowledgement
  strings satisfy the verifier because it does not join them to persisted gate
  observations or exact primary/action ordering.
- Suspected surface: bounded gate-observation persistence plus independent
  occurrence-chain reconstruction.
- Fix applied: none.
- Lifecycle: open.
- Resolution decision: pending convergence diagnosis.

### E9-CR-003 — Ordinary pilot provenance captures the archived harness

- Review epoch / iteration: 9 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/provenance.py` source inventory selected by
  `poc/run-prototype.sh`.
- Statement: the pilot captures `run.sh`, legacy assertion/native CLI/roles, and
  legacy fixtures while omitting the executed prototype runner, orchestrator,
  verifier, native CLI, workflow roles, and revised fixture helpers.
- Demonstrated scenario: the manifest and bound manifest hash remain unchanged
  when an ordinary-prototype source affecting the result changes.
- Suspected surface: explicit legacy versus ordinary-prototype provenance sets.
- Fix applied: none.
- Lifecycle: open.
- Resolution decision: pending convergence diagnosis.

### CP-E9-CR-001 — Repeated acceptance-boundary proof gaps

- Trigger: the convergence-driven Epoch 9 restart found two further blocking
  verifier/evidence sites and one sibling provenance site before the earlier
  acceptance-boundary checkpoint reached clean verification. E9-CR-002 in
  particular may require new persisted observations, so local patching could
  expand semantic surface.
- Diagnosis: `local-design-flaw` (high confidence). The accepted runner/verifier
  architecture remains sound; all three findings are bounded omissions in
  canonical SQLite reconstruction, existing-event occurrence proof, and source
  inventory selection. No product or requirement ambiguity exists.
- Repair altitude: implementation.
- Bounded resolution: compare the complete independently reconstructed SQLite
  projection; persist the normal gate chain in existing append-only workflow
  events and verify presentation/readiness/cue/subsequent response/relay/
  interpretation/acknowledgement/decision/effect ordering; and select an exact
  ordinary-prototype provenance set while preserving the legacy set.
- Excluded surface: no new table, gate snapshot entity, approval protocol,
  event bus, retry/recovery/idempotency machinery, competing-client/race or
  security hardening, or stable-host claim.
- Cap disposition: the prior acceptance-boundary checkpoint already consumed
  the single convergence-driven restart into Epoch 9. Recurrence of the same
  cluster must be escalated to the user. A bounded repair and fresh Epoch 10 may
  proceed only with explicit user authorization and must stop unconditionally
  if this cluster recurs again.
- Status: actioned.
- Required action: preserve all three obligations, diagnose whether this is an
  incomplete bounded implementation or evidence that the accepted independent
  acceptance gate needs architectural revision, and choose the smallest repair
  altitude before implementation.
- Status evidence: independent `review-convergence-analyst` accepted all three
  findings, selected implementation altitude, found no new finding, and applied
  the mandatory iteration-cap escalation. The subsequent top-down assessment
  identified the missing plan-to-verifier proof contract; the user then approved
  replacing end-only semantic verification with runtime enforcement plus a thin
  independent terminal consistency/result audit. The accepted plan amendment and
  its mandatory Plan Review are now the only allowed checkpoint action.

### CP-E9-CR-001 top-down root assessment — acceptance proof contract

- Mode: convergence diagnosis plus repair-altitude reassessment after the user
  paused the proposed bounded implementation repair.
- Scope: assessment only. No plan, production code, test, live-run, commit, or
  integration change is authorized by this note.
- Diagnosis: `local-design-flaw` (high confidence).
- Governing root: the accepted narrative is comprehensive prose, but there is no
  normative intermediate contract that maps every final PASS claim to its
  authoritative durable source, exact independent check, and falsifying negative
  case. The final verifier was consequently implemented bottom-up from the
  conveniently available projection fields instead of top-down from the complete
  narrative.
- Evidence:
  - `prototype_assert.py` compresses the narrative into a few existence, set, and
    count checks. Its SQLite binding compares row identity sets instead of the
    complete ordered projection values.
  - the verifier's success fixture is shaped around those aggregate checks. It
    omits primary actions/outputs and the persisted gate chronology, so its green
    result cannot reveal those missing proof obligations;
  - qualification binding, final report content, and provenance were repaired as
    separate runner sites in Epoch 8, after which Epoch 9 exposed the same
    claim-to-evidence omission in database binding, approval chronology, and
    ordinary-run source selection; and
  - the plan says that an independent verifier checks the acceptance narrative,
    but does not give the implementer or closure reviewer an enumerable proof
    surface on which completeness can be decided mechanically.
- Repair altitude: `architecture`, narrowly at the plan/verifier contract
  boundary. The runner, controller, SQLite single-writer model, and independent
  final-verifier ownership remain unchanged. No product or requirement decision
  is missing.

#### Draft proof-obligation matrix

Each row is mandatory for final PASS. `Source` names the authoritative evidence,
not a report copy. `Independent check` is the required final-verifier obligation.
`Falsifier` is the minimum negative case that must make that row fail.

| ID | PASS claim | Source | Independent check | Falsifier | Current coverage |
|---|---|---|---|---|---|
| P01 | The exact ordinary-run substrate was qualified before work started. | Sealed Phase 4 packet plus current config, Codex version, executable manifest, and selected ordinary-run source manifest. | Re-run the existing qualification comparison and bind all current input hashes before `prototype.py` starts. | Drift one config, executable, version, or executed ordinary-run source. | Partial: qualification binding works; the manifest selects legacy sources. |
| P02 | Verbatim intake preceded grounding, accepted intent, active work, and attempt start. | Work item, intent versions, primary output/action rows, and ordered workflow events. | Join the exact grounding occurrence to `accept_intent`; prove event order and accepted outcome/constraints/project identity. | Delete/reorder intake or substitute a different grounding/output payload. | Incomplete: final verifier checks final work-item state and intent version numbers only. |
| P03 | Each attempt used a durable plan with two independent reviews through convergence and exact plan lineage/diffs. | Plan artifacts, role runs/outcomes, primary decisions, gate receipts, and artifact hashes. | Prove reviewer independence, accepted dispositions, receipt eligibility, exact plan hash, adjacent diffs, and version-zero-to-current diff for each accepted plan. | Reuse a reviewer context, bind a receipt to another plan, or retain an unresolved actionable finding. | Incomplete: role/receipt sets are checked without the lineage or decision joins. |
| P04 | Attempt-one implementation preflight, checkpoint, and physical-agent handoff preserved exact execution state without ownership overlap. | Implementer runs/outcomes, checkpoint and Git-diff artifacts, primary handoff decision, physical-agent IDs, and ordered role events. | Prove old-run retirement precedes transfer, digest/diff equality at replacement entry, distinct physical identity, and one attributable post-handoff result. | Reuse the same physical agent, overlap ownership, or change the worktree after checkpoint. | Incomplete: only two distinct attempt-one physical IDs are required. |
| P05 | Normal detach/reattach returned to the same logical primary and rendered the durable status contract while work continued. | Presentation generations, logical-primary thread, status payloads, role/event progress across detach, and the status-sync primary occurrence. | Prove detach while work remained non-blocked, continuing progress, new attached generation, same logical primary, and exact status fields sourced from durable state. | Change logical primary, omit status fields, or show no progress across detach. | Incomplete: the verifier only requires two presentation rows. |
| P06 | The late constraint and independent root assessment objectively invalidated attempt one and preserved named carry-forward evidence. | Revised-constraint artifact, assessor assignment/outcome/artifact, attempt-one plan/implementation/checkpoint, and restart proposal subject. | Reconstruct the criterion, verify the assessor recommendation and evidence references, and match discarded/carry-forward material to the proposal. | Recommend restart without the criterion/evidence, or name unrelated carry-forward artifacts. | Incomplete: role presence is checked, not its evidence-bearing conclusion. |
| P07 | Restart approval was an informed, occurrence-bound human event. | Proposal/content artifact, proposal-presentation occurrence, generation, persisted readiness/cue/response/relay/interpretation/acknowledgement events, user decision, and primary outputs. | Join one latest exact presentation through same-generation cue, subsequent response, guard/primary interpretation, matching visible acknowledgement, and terminal decision in strict order. | Pre-cue response, stale generation/token, unrelated acknowledgement, intervening turn, or detach before acknowledgement. | Absent as an independent proof: the middle gate observations are not durable. |
| P08 | Restart effects followed separate accepted intent revision and exact restart authority, then restored the attempt-start snapshot before fresh work. | User decision, `revise_intent` and `authorize_restart` actions/events, attempt rows, abandonment/restore events, snapshot artifact, and attempt-two start. | Prove disposition order, exact intent/snapshot identities, abandonment after authority, verified filesystem restore, and successor start after restore. | Authorize against another snapshot, abandon before acknowledgement, or start attempt two before verified restore. | Partial: states and event names are checked without full identities/order. |
| P09 | Attempt two began from carried intent/evidence, paused on one genuine ITD ask, received an attributable within-authority answer, and produced a fresh reviewed plan. | Attempt-two context, ask/outcome row, primary answer action/output, planner continuation run, plan artifacts, and receipts. | Prove ask-before-pause, two options with pros/cons/recommendation, answer-before-resume, fresh planner turn, and no abandoned-plan acceptance. | Resume before answer, answer another ask, or accept the attempt-one plan as attempt two. | Incomplete: only two intent versions and any answered ask are required. |
| P10 | The final candidate is one immutable complete attempt-base-to-candidate Git object. | Git repository/ref plus candidate row, base/tree/diff/inventory artifacts, and registration event. | Recompute SHA, direct parent, tree, complete inventory, binary diff hash, clean checkout, and range `diff --check` from Git. | Layer on a prior candidate, omit an untracked file, or alter tree/diff/inventory while retaining IDs. | Partial: subject/result identities are checked, but SQLite row values are not fully bound. |
| P11 | Ordinary code reviews converged on the exact candidate and every finding was first-class and dispositioned before a receipt. | Review runs/results, code-finding rows, primary decision/actions, receipts, candidate history, and Git. | For both lenses, prove exact candidate/result occurrence, one normalized row per finding, compatible dispositions, no unresolved actionable finding, and supersession/rerun after accepted code fixes. | Omit a finding row, reuse a stale receipt, accept an unresolved finding, or change code after receipt. | Incomplete: final verifier checks only required receipt kinds. |
| P12 | Closure, native hard review, and final validation all cover the same final plan/candidate. | Closure run/result/receipt, native typed result/findings/receipt, validation receipt/artifacts, candidate Git object, and plan artifact. | Prove exact plan/candidate joins, typed native result, disposition completeness, exact commands/output, and discriminating memory-gate controls. | Wrong plan/candidate, malformed native prose-only result, broken positive control, unexpectedly passing limited naive reference, or final CLI output mismatch. | Partial: receipt kinds and summarized validation values are checked, not the complete provenance and decision chain. |
| P13 | The integration presentation is one immutable packet for the exact eligible candidate and evidence set. | Integration proposal subject/presentation artifact, candidate, receipts, validation, exact diff, limitations, and primary turn. | Reconstruct the packet from authoritative rows/Git and compare the complete canonical subject and packet hash. | Swap a receipt, candidate field, diff, validation result, or limitation while retaining proposal identity. | Partial: strong candidate/diff/validation checks exist, but full DB/projection and all packet inputs are not independently reconstructed. |
| P14 | Integration approval was a distinct informed, occurrence-bound human event. | Same gate-chain sources as P07 for the integration proposal. | Prove latest exact packet presentation through cue, subsequent response, interpretation, branch acknowledgement, and terminal decision before authorization. | Reuse restart acknowledgement, accept pre-cue input, use stale packet/generation, or detach before acknowledgement. | Absent as an independent proof for the same reason as P07. |
| P15 | Integration revalidated and fast-forwarded only disposable `main` to the approved candidate. | Authorization action/event, approval packet, immediate revalidation evidence, Git refs/tree, and integration-completed event. | Prove authorization precedes revalidation/effect, `main` was still at exact base, fast-forward result equals approved SHA/tree/diff, and completion follows Git verification. | Move `main`, supersede candidate/receipt, or record completion for another tree. | Partial: exact completion identity is checked, but complete authority/revalidation ordering is not. |
| P16 | Final projection is an exact canonical read of SQLite and the report is an exact human-readable view of it. | Read-only SQLite, declared projection queries/order, saved projection, report, evidence files, and Git. | Independently reconstruct every projected joined row with complete values, compare canonical projection bytes/hash, then verify every report section against that projection and Git. | Change a non-key payload/state/hash with the same row ID, omit a projected table, or drift report content. | Blocking gap: only work-item equality and other table ID sets are compared. |
| P17 | Only the independent verifier can emit PASS, and it emits PASS iff every matrix row passes. | Producer exit/result, final-verifier result, runner exit, and verifier proof-row set. | Require the exact P01-P18 result set, all true, producer status zero, and no producer-authored PASS marker before runner success. | Skip one proof row, let producer claim PASS, or return zero after any failed row. | Partial: PASS ownership is correct, but the proof set is not complete or matrix-bound. |
| P18 | The retained evidence identifies every source and executable that materially produced or verified this ordinary run. | Explicit ordinary-prototype source-role set, runtime manifest, binaries, role prompts, fixtures, and repository blobs. | Require exact profile-specific role set and hashes; verify each path/blob before execution and before cleanup. | Modify or omit `run-prototype.sh`, `prototype.py`, `prototype_assert.py`, native prototype CLI, workflow role, or revised fixture helper without manifest drift. | Significant gap: current manifest is the archived legacy-harness set. |

#### Root conclusion and bounded next action

- The recurrence is not evidence that SQLite, the controller-primary topology,
  or the independent runner-owned final gate should be replaced. It is evidence
  that their proof boundary was underspecified.
- Fixing only E9-CR-001 through E9-CR-003 would remain symptom-level because
  P02-P06 and P08-P15 still contain unenumerated joins and ordering obligations
  that a later review could rediscover one by one.
- The smallest root-level correction is to make this matrix a normative section
  of the accepted plan, trim or merge rows only through Plan Review, then perform
  one coherent implementation that:
  1. independently reconstructs and compares the complete canonical projection;
  2. persists only the missing normal gate observations in existing
     `workflow_events` and verifies their exact chain;
  3. uses explicit legacy and ordinary-prototype provenance profiles; and
  4. makes the verifier emit an exact result for every accepted matrix row, with
     at least one focused falsifier per row.
- Semantic-surface boundary: no new SQLite table, gate snapshot, approval
  protocol, event bus, retry/recovery/idempotency mechanism, competing-client
  claim, or production-hardening claim.
- User decision: approved Option 2, runtime enforcer plus thin independent
  terminal audit. The P01-P18 matrix moves into the accepted plan as the runtime
  proof contract; implementation remains paused until that amended plan completes
  mandatory Plan Review.

## Runtime-enforcement plan amendment — Plan Review Phase 1 discovery 1

- Reviewed artifact SHA-256:
  `bf1716b403eeeff794c3993880942d67b86ffbc070fb9956dce87eb00ea84b50`.
- Structured `rfc-reviewer`: GREEN; no blocking, significant, acknowledged,
  adjacent, or out-of-scope concern. Strengths were the explicit runtime/thin-
  audit ownership split, proof/evidence/invalidation matrix, and temporal/site
  coverage.
- Adversarial `rfc-red-team`: RED FLAG; one blocking in-scope finding. The red-
  team ran in a reused idle agent slot because the runtime thread limit prevented
  a fresh thread; it did not receive the structured review output or read this
  ledger, but history independence was degraded and is recorded here.

### E9-PLAN-RT-001 — Terminal PASS boundary is circular

- Severity / scope: blocking / in-scope.
- Location: P16-P17, terminal-audit ordering, and
  `NEW_CODEX_OPERATING_MODEL.md` Section 47A.
- Statement: the audit both consumes and determines the runner's final status,
  while report publication, evidence copying, runtime cleanup, trap handling, or
  exit propagation may still fail after PASS. It cannot verify a future status or
  permit later fallible finalization without risking a false authoritative PASS.
- Scenario: producer evidence and staged report pass audit -> audit emits PASS ->
  later cleanup/publication/exit work fails -> externally authoritative PASS
  remains despite incomplete terminal finalization.
- Suggested resolution: finish every fallible producer/runner cleanup and freeze
  the complete audit inputs first; then make the terminal auditor the final
  executable whose direct exit is the runner status. Audit staged report bytes;
  no mutation or cleanup follows its verdict.
- Lifecycle: actioned pending holistic Plan Review.
- Repair decision: local plan correction within accepted Option 2. It changes no
  product behavior, durable state, authority, or proof-obligation scope.
- Fix applied: the plan now requires all producer and runner child shutdown,
  evidence/report staging, provenance confirmation, temporary-runtime cleanup,
  and immutable input freeze before audit. The runner then replaces itself with
  the auditor as the final executable; the auditor does not consume a future
  runner status, its direct exit is that status, and no mutation/cleanup follows
  PASS or failure. P16 audits frozen staged report bytes rather than gating a
  later publication copy.

### Runtime-enforcement plan amendment — Phase 1 discovery 2

- Reviewed artifact SHA-256:
  `89a0f9ffc212afbf944208e8e626bac75924c891f24ec5aa8b42f4e7bede5817`.
- Structured `rfc-reviewer`: GREEN. E9-PLAN-RT-001 resolved; no new blocking or
  significant finding in the complete current plan.
- Adversarial `rfc-red-team`: GREEN CLEAR. The non-circular final-executable
  sequence closed the scenario; no new blocking or significant composition
  scenario survived holistic review.
- E9-PLAN-RT-001 lifecycle: resolved for Plan Review Phase 1.
- Resolution evidence: every fallible producer/runner finalization operation and
  immutable evidence freeze precedes audit; the auditor is the final executable,
  solely emits PASS, directly determines runner status, and has no post-verdict
  mutation, publication copy, cleanup, or trap work.
- Aggregate Phase 1 blocking/significant obligations passed to minimization:
  preserve the non-circular single-owner terminal PASS sequence established by
  E9-PLAN-RT-001. Reviewer strengths do not create additional protected content.

### Runtime-enforcement plan amendment — Phase 2 minimization

- Minimizer verdict: EXCESS; no blocking finding. It found no removable P01-P18
  row, state, authority, table, or lifecycle.
- MIN-001 (`significant / in-scope`): retain the complete ITD option catalogues.
  The user explicitly requires important technical decisions to preserve the
  problem, valid options, pros/cons, and decision as durable history; deleting
  that structure would violate an accepted operating-model requirement even
  though it is not executable guidance.
- MIN-002 (`significant / in-scope`): partially applied. The work-breakdown copy
  of the P16-P18 terminal sequence was compressed to references to the canonical
  ITD, runtime matrix, and temporal contract. Repetition required by the plan
  contract remains in the site list, transition surface, effect ordering,
  execution ownership, concurrency constraints, adversarial cases, and
  completion gate.
- MIN-003 (`significant / in-scope`): applied. The plain-language report now
  references the frozen terminal-audit result and stage-level evidence instead
  of repeating a machine-style P01-P18 evidence inventory.
- Phase 3: skipped per Plan Review Flow because minimization produced no
  `blocking × in-scope` finding and no recommendation conflicts with a Phase 1
  obligation.

### Runtime-enforcement plan amendment — Plan Review closure

- Final plan SHA-256:
  `05e8e6dfb5b5484ab1a001a1256508bdfdf2dec05d62544579a720ba94c95610`.
- Phase 1: GREEN / GREEN CLEAR after one blocking terminal-ordering correction.
- Phase 2: no blocking minimality finding. P01-P18 and all accepted state,
  authority, and lifecycle boundaries remained load-bearing; safe prose
  compression was applied without dropping an obligation.
- Phase 3: not triggered.
- UX review: not triggered because the amendment changes proof enforcement and
  terminal ownership, not the accepted user-facing gate phrases or flow.
- Verdict: GREEN and ready for the user's mandatory final plan review.
- Closure receipt: `.review-receipts/poc/PLAN.md.json`, ignored and untracked,
  bound to the final plan hash and repository HEAD
  `e045cf1e14277c2befc78a450201a6b19b33ba40`.
- CP-E9-CR-001 remains `actioned`: implementation, full validation, fresh Code
  Review Epoch 10, and clean discovery evidence are still required before the
  checkpoint can resolve.

## Runtime-enforcement implementation checkpoint — before Code Review Epoch 10

- Outcome: implement the accepted P01-P18 runtime-enforcement amendment in the
  disposable authoritative-host PoC without running the live model, committing,
  or integrating the PoC branch.
- In scope: runtime rejection before P01-P15 dependent effects; P18 ordinary-run
  preflight; exact restart/integration occurrence observations; immutable
  candidate and immediate integration revalidation; full-row SQLite projection
  reconstruction; qualification versus ordinary-prototype provenance profiles;
  and the P16-P18 terminal auditor as the runner's final executable.
- Out of scope: generic proof/state tables, recovery/retry machinery,
  competing-client correctness, production hardening, changes to the accepted
  user-facing phrases, a live Codex run, commit, or integration.
- Required invariants: the controller remains the sole SQLite writer and
  authority owner; the primary remains the semantic/user-facing owner; agents
  cannot authorize effects; rejection pauses rather than abandons; every rewind
  remains user-authorized; only the terminal auditor can emit PASS; and no
  fallible work follows its verdict.
- Implementation sites: `poc/kernel.py`, `poc/prototype.py`,
  `poc/prototype_assert.py`, `poc/provenance.py`, `poc/run-prototype.sh`, and
  focused offline tests.
- Runtime proof shape: successful boundaries append `runtime_proof_enforced`;
  failures append `runtime_proof_failed` with the exact P-ID, boundary, reason,
  and available evidence before the dependent effect. The final runtime
  eligibility record requires P01-P15 plus the P18 preflight. P16-P18 remain a
  thin read-only terminal consistency/result audit rather than a second semantic
  verifier.
- Normal-path timing correction during implementation: status synchronization
  is now awaited before the status-dependent restart assessment/proposal path;
  semantic interpretation is durably staged before the visible acknowledgement,
  and acknowledgement observation remains the authority commit prerequisite.
- Offline evidence before review: `git diff --check`, Bash syntax validation,
  Python byte-compilation, 160 Python unit tests, the Go transport test suite,
  and an actual ordinary-prototype provenance capture/verify all pass. The Go
  suite required an unrestricted local test sandbox solely to open its loopback
  listener.
- Review state: implementation complete enough to enter fresh holistic Code
  Review Epoch 10; no review-clean or RFC-closure claim is made by this entry.

## Code Review Epoch 10 — Phase 1 discovery 1

- Lane: fresh holistic discovery. The reviewer received the accepted scope
  block, complete dirty tree, surrounding code/tests, and the plan only as
  behavior context. It did not receive this ledger, prior findings, a proposed
  root cause, or a claimed fix.
- Validation observed by both implementer and reviewer: 160 Python tests and the
  Go transport suite pass. Those green suites do not close the findings below.

### E10-CR-001 — Pre-cue input can be classified after the cue

- Review epoch / iteration: 10 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py:_start_gate_input_reader` and
  `_publish_gate_input_cue`.
- Statement: `readline()` returns before the reader acquires the boundary lock
  and samples `eligible`. A line physically entered before the visible cue can
  therefore be classified as post-cue if the reader is descheduled and the cue
  path acquires the lock first.
- Demonstrated scenario: user enters a line after transport readiness but before
  the cue -> `readline()` returns -> reader pauses -> cue prints and sets
  eligibility -> reader resumes and queues the old line as eligible -> the line
  can reach restart or integration interpretation and authority.
- Obligation: pre-cue input must never enter the occurrence-bound P07/P14
  authority chain, regardless of scheduling between byte arrival and later
  classification.
- Suggested resolution: use one serialized I/O owner for arrival classification
  and cue publication, or otherwise capture arrival independently of a later
  eligibility sample; add a deterministic read-return/classification barrier
  falsifier.
- Relationship: repeated acceptance-boundary finding in the P07/P14 cluster
  established by E9-CR-002 and the runtime-enforcement plan amendment.
- Lifecycle: open; no fix may begin while CP-E10-CR-001 is open.

### E10-CR-002 — P16 omits receipt-only authoritative artifacts

- Review epoch / iteration: 10 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype_assert.py:database_projection` and the matching
  `DurableKernel.workflow_projection` query.
- Statement: the `artifacts` projection includes only artifacts referenced by
  role outcomes or code findings. It omits artifacts referenced only by gate
  receipts and other projected relations, including validation/native-review
  receipt artifacts, so the claimed complete full-row P16 comparison is not
  complete.
- Demonstrated scenario: mutate a non-key field of a receipt-only authoritative
  artifact before freeze -> neither producer nor auditor projection includes the
  row -> projection equality stays green -> terminal PASS remains reachable.
- Obligation: the canonical P16 projection must include complete values for
  every in-scope authoritative relation and every artifact row reachable from
  those relations.
- Suggested resolution: define and share or exactly duplicate the complete
  canonical relation closure; add a receipt-only-artifact mutation falsifier.
- Relationship: direct recurrence of E9-CR-001 at another omitted projection
  relation after the accepted full-row reconstruction repair.
- Lifecycle: open; no fix may begin while CP-E10-CR-001 is open.

### E10-CR-003 — P18 executable-role closure is optional

- Review epoch / iteration: 10 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/provenance.py:capture` and `verify_manifest`.
- Statement: exact role-set comparison covers only repository-backed source
  rows. Executable entries can be missing, duplicated, or unknown while the
  manifest still passes; Git, which materially produces and audits the ordinary
  result, is not captured at all.
- Demonstrated scenario: remove every executable entry, or replace uncaptured
  Git -> source-role equality and all remaining hashes still pass -> P18 claims
  exact ordinary-run provenance without the material executables.
- Obligation: qualification and ordinary profiles must each name an exact,
  non-optional set of material source and executable roles and reject missing,
  duplicate, unknown, or drifted entries.
- Suggested resolution: define exact source-plus-executable role sets, include
  Git and every material process in the bounded claim, and add omission/drift
  falsifiers for each required executable role.
- Relationship: direct recurrence of E9-CR-003 after the accepted split-profile
  provenance repair.
- Lifecycle: open; no fix may begin while CP-E10-CR-001 is open.

### E10-CR-004 — Proof tests bypass dependent transition boundaries

- Review epoch / iteration: 10 / Phase 1 discovery 1.
- Source: fresh independent `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/test_kernel.py:test_runtime_proof_falsifiers_p01_through_p15_and_p18_stop_before_effect`.
- Statement: P03/P04/P05/P06/P09/P10/P11 falsifiers call the enforcer directly
  instead of their actual public dependent transitions. P12/P15 accept generic
  failures without proving the external effect remained absent. The suite does
  not establish the required rejection-before-effect property.
- Demonstrated scenario: enforcement moves below reviewer dispatch or proposal
  creation -> direct enforcer calls still reject and tests stay green -> the
  forbidden runtime effect occurs before the proof failure.
- Obligation: every matrix falsifier must enter through the actual transition,
  assert the exact P-ID, and prove absence of the named role/proposal/authority/
  Git/integration/PASS effect.
- Suggested resolution: replace direct-enforcer coverage with public-boundary
  falsifiers and explicit no-effect assertions for every P01-P15/P18 boundary.
- Relationship: sibling recurrence of the accepted proof-contract cluster; the
  tests mirrored proof function existence rather than boundary enforcement.
- Lifecycle: open; no fix may begin while CP-E10-CR-001 is open.

### CP-E10-CR-001 — Acceptance-proof cluster recurred at the mandatory cap

- Trigger: the first fresh holistic discovery pass after the CP-E9-CR-001
  convergence-directed architecture amendment found blocking recurrence in the
  same P07/P14 chronology, P16 complete-projection, P18 provenance-closure, and
  boundary-falsifier surfaces.
- Status: open; escalated to the user by the accepted iteration-cap rule.
- Active epoch substantive-iteration count: zero. The checkpoint fired before
  any Epoch 10 fix.
- Pre-fix verification: the orchestrator independently inspected each cited
  path and accepted all four scenarios as valid. No finding was filtered as a
  false positive.
- Prior cap: CP-E9-CR-001 explicitly allowed one coherent repair and fresh Epoch
  10 only on the condition that recurrence of this cluster stop unconditionally
  and escalate rather than enter another ordinary fix loop.
- Continuation token:
  - phase: `phase-1`;
  - boundary: `pre-fix`;
  - lane: `discovery`;
  - pending obligation: user decision on whether to reopen the accepted
    architecture/proof contract or stop the PoC direction;
  - prohibited continuation: no local finding fix, re-review, Phase 2,
    Phase 3, RFC closure, live run, commit, or integration while open;
  - if the user authorizes an architectural correction: update the plan, run
    mandatory Plan Review, implement the reviewed design, start a new code-review
    epoch at zero, and restart Phase 1 with this ledger carried forward.
- Lifecycle effect: CP-E9-CR-001 cannot resolve; its required clean Epoch 10
  evidence did not materialize. This checkpoint supersedes ordinary review
  continuation and requires the user's explicit direction.
- Convergence diagnosis: `local-design-flaw` (high confidence). The four defects
  are concrete, but their recurrence shows that proof ownership, the closed
  authoritative universe, and the actual dependent-transition boundary remain
  separately hand-assembled and can still omit a member while staying green.
  This does not invalidate SQLite, the accountable-primary topology, or the
  P01-P18 product obligations.
- Selected repair altitude: `architecture`, narrowly at proof ownership,
  closed-world completeness, and transition enforcement. No product or
  requirement ambiguity and no stable-host/production-hardening expansion is
  justified.
- Action while status remains open: ask the user to choose whether to reopen the
  accepted proof architecture and return through mandatory Plan Review before
  any implementation, or stop the PoC direction at this checkpoint. No local
  Epoch 10 repair is an allowed continuation under the accepted cap.
- Diagnosis source: independent `review-convergence-analyst`; no new finding.

## Architecture reset after Code Review Epoch 10

- Trigger: the user challenged whether the runtime validator was grounded in
  concrete product requirements, whether the controller was incorrectly doing
  natural-language interpretation, and whether the process had displaced the
  accountable primary's technical judgment with an item-by-item user interview.
- Context recovery: a fresh independent re-prime of the complete available
  session lineage confirmed that the accepted north star is one voice-facing
  accountable primary, bounded internal agents, durable context, and a
  programmatic layer that enforces settled mechanical workflow policy. The
  P01-P18 proof matrix, finite approval grammar, cue/occurrence protocol,
  complete projection/provenance closure, and special terminal PASS had become
  prototype proof machinery rather than accepted product requirements.
- Revised convergence diagnosis: `product-assumption-mismatch` (high
  confidence). E10-CR-001 through E10-CR-004 remain valid defects in the current
  implementation and remain preserved as findings. Their local proof
  mechanisms are not promoted into obligations for the replacement
  architecture.
- Accepted semantic boundary: models interpret natural language. Python and
  other deterministic controller code may transport and validate typed model
  output, identities, and state, but may not infer meaning through phrase lists,
  normalization, keywords, regular expressions, substrings, or prose markers.
- Accepted high-stakes boundary: restart and authoritative integration require
  the primary's positive typed interpretation plus an independent one-shot
  model's matching positive interpretation of the same proposal and verbatim
  user response. Primary rejection or clarification is a no-effect path and
  needs no second model call.
- Accepted validation boundary: governed transitions are enforced mechanically
  at their actual controller boundaries, with checks placed at the earliest
  responsible build, initialization, runtime, review, or closure phase. There
  is no generic P-ID runtime validator or terminal proof authority.
- Accepted primary-authority boundary: after product intent, scope, authority,
  and genuine ITDs are settled, the primary owns derived architecture and
  implementation decisions. The user reviews genuine product/scope decisions,
  rewind and integration authority, and the consolidated architecture rather
  than answering a process questionnaire.
- Selected repair altitude: `product-requirement / architecture`. Rebase the
  prototype around the behaviorally complete low-stakes vertical slice and
  subtract machinery not required by that experience.
- Replacement plan: `poc/PLAN.md` SHA-256
  `e1c3d7b8b916d55a3f2ba31a390caa0f4efe4c2f7778671f23ec694a8bb15a82`.
- CP-E10-CR-001 status: `actioned`, not resolved. Its required architecture
  reset has begun. No local E10 finding fix, live model run, implementation,
  commit, or integration is permitted until the replacement plan completes
  mandatory Plan Review and receives the user's consolidated architecture
  approval.
- Continuation token:
  - phase: `plan-review`;
  - boundary: replacement architecture plan ready for independent review;
  - pending obligation: soundness review, adversarial review, subtractive
    minimality review, affected verification re-review, then the user's final
    consolidated architecture review;
  - prohibited continuation: implementation, live run, Code Review Epoch 11,
    commit, or integration before those obligations complete.

## Replacement architecture Plan Review — Phase 1 iteration 1

- Artifact reviewed: `poc/PLAN.md` SHA-256
  `e1c3d7b8b916d55a3f2ba31a390caa0f4efe4c2f7778671f23ec694a8bb15a82`.
- Discovery lanes: independent `rfc-reviewer`, `rfc-red-team`, and `ux-reviewer`.
  None received the prior finding ledger, a proposed repair, or the architecture-
  reset diagnosis.
- Reviewer execution note: the red-team pass was bounded after it continued
  broad investigation beyond the other completed reviews; it then returned a
  complete contract-shaped final assessment from the work already performed.

### APR-001 — Accepted-intent revision and clean restart authority were conflated

- Sources: convergent soundness and adversarial reviewers.
- Severity / scope: blocking / in-scope.
- Obligation: accepting the proposed product constraint and authorizing discard
  of attempt-one execution state must be separate, unambiguous user authorities.
- Scenario: the user accepts the new constraint but declines restart; an
  unspecified combined disposition can either rewind without authority or lose
  the accepted intent revision.
- Resolution: actioned in the replacement plan. The implementer first reports
  the proposed constraint and pauses. A distinct user decision may create
  accepted-intent version two without touching the worktree. Only a later root
  assessment and separately presented, independently co-signed restart proposal
  can authorize restore. Restart rejection preserves both the accepted intent
  and the incompatible paused attempt.
- Lifecycle: `actioned`; holistic Phase 1 iteration 2 must verify closure.

### APR-002 — A high-stakes response could bind before its proposal was shown

- Source: adversarial reviewer.
- Severity / scope: blocking / in-scope.
- Obligation: restart/integration authority may derive only from a response made
  after the exact proposal is completely visible in the current presentation.
- Scenario: buffered input arrives while the proposal is rendering or after a
  detach; both models later see complete durable context and agree positively
  even though the user did not see that occurrence.
- Resolution: actioned in the replacement plan. Proposal eligibility now starts
  only at completed-turn/full-render state for the current presentation;
  pre-render input cannot bind, and detach invalidates eligibility until complete
  re-presentation. This is structured presentation state, not text semantics or
  a phrase grammar.
- Lifecycle: `actioned`; holistic Phase 1 iteration 2 must verify closure.

### APR-003 — Native hard review had no distinct stated obligation

- Source: soundness reviewer.
- Severity / scope: blocking / in-scope.
- Obligation: retained runtime review stages must be load-bearing rather than
  inherited proof machinery.
- Resolution: actioned without deleting the user's explicit evergreen hard-
  review requirement. The scope and narrative now distinguish iterative
  correctness/cohesion review from one fresh, unanchored native Codex discovery
  pass over the complete final diff. It is not a terminal proof auditor and does
  not replace the two targeted lenses; a finding supersedes the candidate and
  returns through candidate-bound review.
- Lifecycle: `actioned`; holistic Phase 1 iteration 2 must decide whether this
  stated responsibility resolves the duplication concern.

### APR-004 — Reattachment and stopped-state summary was underspecified

- Source: UX reviewer.
- Severity / scope: significant / in-scope.
- Resolution: actioned. The plan now requires a compact conversational attention
  summary with accepted intent, material progress, current phase, preserved
  state, blocker/pending decision, effect status, and one next action.
- Lifecycle: `actioned`; UX re-review required.

### APR-005 — Confirmation latency and no-effect feedback was underspecified

- Source: UX reviewer.
- Severity / scope: significant / in-scope.
- Resolution: actioned. Both high-stakes gates now present the exact consequence,
  visibly state that independent confirmation is pending and no effect has
  occurred, then acknowledge either the applied result or a preserved-state
  no-effect clarification with one concrete question.
- Lifecycle: `actioned`; UX re-review required.

### Planner corrections from the accepted north star

- The initial replacement plan mentioned monitoring but did not exercise the
  accepted bidirectional checkpoint contract. Iteration 2 now includes one
  primary-initiated alignment check, one proactive agent inflection report, the
  compact checkpoint shape, and `continue/correct/pause/escalate` disposition.
- The plan now restates the accepted uncertainty rule: zero or multiple valid
  paths create uncertainty; exactly one valid path does not.
- The minimum ledger now retains the full ITD data structure: problem, options,
  per-option pros/cons, decision, and its work/intent relationships.
- Updated artifact for holistic Phase 1 iteration 2: `poc/PLAN.md` SHA-256
  `c85bfdad80aab58e1777254d58161d3102beedce24ce807c725bb74b63ead975`.

## Replacement architecture Plan Review — Phase 1 iteration 2

- Holistic verification results:
  - adversarial reviewer: GREEN CLEAR; APR-001 and APR-002 closed with no new
    blocking or significant scenario;
  - UX reviewer: APR-004 and APR-005 closed; one new significant attached-
    failure presentation gap surfaced;
  - soundness reviewer: APR-001 and APR-003 closed; two new blocking consistency
    gaps surfaced.

### APR-006 — Ask pause scope was internally inconsistent

- Source: soundness reviewer.
- Severity / scope: blocking / in-scope.
- Obligation: unresolved asks must stop every consumer of the missing answer
  without unnecessarily stopping truly independent work.
- Resolution: actioned using the user's earlier accepted dependency-scoped
  rule. An ask now fences its physical run and every assignment, phase advance,
  candidate, validation, or effect with a data, authority, phase, or outcome
  dependency on the answer. A provably independent run may continue. This
  replaces the contradictory whole-work-item wording without allowing work to
  advance through the unresolved decision.
- Lifecycle: `actioned`; holistic Phase 1 iteration 3 must verify closure.

### APR-007 — Declared ITD persistence had no genuine exercised occurrence

- Source: soundness reviewer.
- Severity / scope: blocking / in-scope.
- Obligation: if complete ITD persistence is a visible MVP behavior, a typed
  transition and genuine decision occurrence must own it; an ordinary local
  implementation choice cannot be relabeled as an ITD.
- Resolution: actioned. The fixture's spill-backend ask remains an ordinary
  primary-owned technical decision. The successful PoC instead unlocks the
  already pending, difficult-to-reverse authoritative-host ITD in
  `NEW_CODEX_OPERATING_MODEL.md`. The primary presents its complete problem,
  options, per-option pros/cons, recommendation, and PoC evidence; accept,
  reject, or defer is persisted with evidence links and gates dependent post-PoC
  architecture work.
- Lifecycle: `actioned`; holistic Phase 1 iteration 3 must verify closure.

### APR-008 — Attached failures lacked the recovery-oriented attention summary

- Source: UX reviewer.
- Severity / scope: significant / in-scope.
- Obligation: the accountable primary must explain a failure, blocker, or
  incomplete effect without forcing the user to decode raw controller state.
- Resolution: actioned by reusing the already accepted compact attention-summary
  shape for the first transition to waiting, blocked, failed, or incomplete,
  whether the user is attached or reattaching. The summary states what changed,
  exact effect status, preserved work, and one safe next action.
- Lifecycle: `actioned`; UX re-review required.

- Updated artifact for holistic Phase 1 iteration 3: `poc/PLAN.md` SHA-256
  `9134746b9197e73916e13e6adef304602f14edb95c54d58bad09d4935850396d`.

## Replacement architecture Plan Review — Phase 1 closure

- Final iteration-3 verdicts:
  - `rfc-reviewer`: GREEN; APR-006 and APR-007 resolved, no blocking or
    significant in-scope finding;
  - `rfc-red-team`: GREEN CLEAR; all prior authority/render scenarios remain
    closed and no new plausible in-scope blocker or regression surfaced;
  - `ux-reviewer`: UX GREEN; APR-008 resolved and no blocking or significant
    in-scope UX finding remains.
- Phase 1 aggregate obligations carried into minimization: APR-001 through
  APR-008. These protect the accepted behavior and invariants, not necessarily
  the exact mechanisms used by the current plan.
- Phase 1 result: clean convergence within the three-iteration cap.
- Current artifact entering Phase 2: `poc/PLAN.md` SHA-256
  `9134746b9197e73916e13e6adef304602f14edb95c54d58bad09d4935850396d`.

## Replacement architecture Plan Review — Phase 2 minimization

- Minimizer verdict: BLOATED with three blocking subtractive findings.
- MIN-001, remove the root-assessor role: not applied because it conflicts with
  an already accepted user ITD rather than an accidental review addition.
  `NEW_CODEX_OPERATING_MODEL.md` Section 71 assigns restart eligibility to an
  assessor using explicit evolving evidence predicates; Section 70 separates
  recommendation from user authorization. The plan now states that the assessor
  only evaluates predicate evidence independently while the primary owns the
  recommendation and orchestration. This prior accepted decision resolves the
  minimization tie; it is not reopened silently.
- MIN-002, remove generalized content-addressed artifact abstraction: applied.
  Durable content and identities remain owned directly by the specific intent,
  plan, checkpoint, outcome, review, finding, validation, ITD, and Git records
  that require them. General artifact hashing and its standalone tests are no
  longer plan obligations.
- MIN-003, delete the optional standalone assertion surface: applied.
  `poc/prototype_assert.py` and its dedicated test are planned for deletion;
  final validation, closure, and ledger/Git reporting retain their existing
  owners and no process owns terminal PASS.
- Phase 3 trigger: yes. Blocking minimization findings changed the plan and the
  retained root-assessor boundary requires one verification re-review.
- Minimized artifact SHA-256:
  `b816fceab07320a206774748aa379ceb4f29c3b3426ba1df71d02a68716eb0eb`.

## Replacement architecture Plan Review — Phase 3 verification

- UX verifier: GREEN; the two applied subtractions and retained internal root
  assessor introduced no user-facing regression.
- Soundness verifier: the artifact/evidence subtraction and standalone-assertion
  deletion preserve their obligations, but one blocking ownership contradiction
  remained between the acceptance narrative and minimized root-assessor rule.
- Adversarial verifier: the same ownership contradiction was significant. A
  non-positive or incomplete assessment could otherwise be treated as a
  recommendation and reach a user-approved but policy-ineligible rewind.
- Post-verification case-(c) correction: the assessor now records only the
  versioned predicate results and evidence. A complete positive current
  assessment precedes a separately recorded primary-owned recommendation; both
  bind the same intent, attempt, and start snapshot before a restart proposal or
  authority is eligible. Missing, negative, stale, or identity-mismatched
  assessment causes no effect.
- Verification-loop rule: Phase 3 permits only one independent verification
  pass. This exact post-pass ownership alignment therefore did not receive a
  second independent review dispatch; the orchestrator checked the complete
  plan contract and will surface this explicitly in the final architecture
  handoff so the user may request a manual re-check.
- Final reviewed-plan candidate SHA-256:
  `629924d630de160fc59703e76933f98aa220e3db2997afbad0bbcc4e78997def`.
- Phase status: ready for consolidated user review. Implementation remains
  prohibited until the user accepts the architecture.

## Consolidated replacement architecture approval

- The user reviewed the synthesized architecture, reviewer verdicts,
  minimization results, and the disclosed post-verification assessor/primary
  ownership correction, then explicitly responded `approved`.
- Approved plan SHA-256:
  `629924d630de160fc59703e76933f98aa220e3db2997afbad0bbcc4e78997def`.
- CP-E10-CR-001 remains `actioned`: implementation may now proceed, followed by
  proportional offline validation and a fresh Code Review epoch. The checkpoint
  cannot resolve until that restarted review flow converges cleanly.
- Still prohibited without later explicit authority: the live Codex model run,
  any commit, and any integration action.

## Replacement implementation checkpoint — offline candidate

- Implementation followed approved plan SHA-256
  `629924d630de160fc59703e76933f98aa220e3db2997afbad0bbcc4e78997def`
  in the disposable `poc/authoritative-host` worktree only.
- The ordinary workflow kernel was cleanly rebased around typed SQLite
  transitions. It now owns accepted intent versions, attempts, bounded role
  runs, bidirectional checkpoints, exact handoffs, dependency-scoped asks,
  model-call evidence, root predicate assessments, primary restart
  recommendations, fully-rendered proposal windows, asymmetric semantic
  confirmation, effects, plans, immutable Git candidates, candidate-bound
  reviews/findings, validation, closure, ITDs, and proportional reporting.
- Python natural-language authority was removed from the ordinary workflow.
  Verbatim user text is opaque to the controller and kernel; schema-constrained
  primary and independent model turns own semantic interpretation. The focused
  source test rejects reintroduction of the old phrase/normalization/cue
  surfaces.
- The prior `P01`-`P18` runtime proof API, proof-specific PTY cue/ack grammar,
  ordinary-run provenance closure, standalone `prototype_assert.py`, dedicated
  assertion test, and terminal-PASS owner were removed from the ordinary MVP
  path. Archived Phase 1-4 capability code and evidence remain separate.
- The executable workflow now includes one accepted-intent revision distinct
  from restart authority, one independent predicate assessment distinct from
  the primary recommendation, one planned detach/reattach, one exact worktree
  handoff, one dependency-scoped technical ask, iterative correctness/cohesion
  review, one fresh native hard-review role, first-class finding disposition and
  replacement candidate construction, isolated validation, plan-to-code
  closure, explicit integration authority, exact Git read-back, and final
  authoritative-host ITD review.
- The fixture test was renamed from `contract_test.py` to `test_contract.py` so
  the accepted `python3 -m unittest discover -v` command actually discovers the
  two contract tests. This was an implementation-time fixture correction, not a
  product-scope change.
- Current ordinary implementation identities before Code Review:
  - `poc/kernel.py` SHA-256
    `e0688a7c68544dba4dd0223368fa309c608fa9925f7bc46669f6504599c0be33`;
  - `poc/prototype.py` SHA-256
    `434bc5132c394581ddfb32bfc3cfa164817c85070825fef7220242f3c184230a`;
  - `poc/pty_tui.py` SHA-256
    `fa506d0b34086915ed6137101896bc890cf072d459b617c798cce5a99006858e`.
- Offline validation before fresh Code Review:
  - Python compilation: clean;
  - Bash syntax: clean;
  - Go transport tests: clean;
  - `python3 -m unittest discover -v`: 87 tests, all clean;
  - `git diff --check`: clean;
  - scripted full narrative: clean, including one accepted code finding and a
    direct-child replacement candidate;
  - high-stakes rejection, verifier disagreement, verifier failure,
    presentation invalidation, dependency fencing, sanitized SQLite export, and
    PTY render-boundary branches: clean.
- CP-E10-CR-001 remains `actioned`. A fresh implementation Code Review epoch is
  the next gate; these local results do not authorize the live Codex run,
  commit, or integration.

## Replacement implementation Code Review — Epoch 11 discovery

- Two delegated `code-review-analyst` discovery runs did not return a bounded
  verdict in time. The orchestrator therefore executed the same role contract
  locally, as permitted by the fallback rule. Reviewer independence was
  degraded; finding qualification and the approved happy-path scope were not.
- Scope remained the approved one-work-item, low-stakes MVP. Production
  hardening, hostile input, crash recovery, race tolerance, broad provenance,
  backtesting, and optimization were excluded.

### E11-CR-001 — Review, validation, and closure admit wrong-role evidence

- Source: local fallback `code-review-analyst` discovery.
- Severity / scope: significant / in-scope.
- Location: `poc/kernel.py` `record_review`, `record_validation`, and
  `record_closure`.
- Trigger: a completed current-attempt run with a role other than the role that
  owns the requested gate is supplied to one of these transitions.
- Propagation: the kernel checks run state and artifact identity but not the
  run's role against the review kind or validation/closure transition. The
  wrong actor can therefore create clean gate records that later satisfy plan
  acceptance or integration eligibility.
- Impact: SQLite no longer mechanically proves that the distinct reviewer,
  validator, and closure-verifier roles actually supplied their required
  evidence; a controller call-site bug can silently substitute authority.
- Likelihood: medium. The current happy path passes the intended runs, but the
  kernel is explicitly the authority boundary against orchestration mistakes.
- Obligation: bind each admitted gate to its exact allowed role without adding
  new state or lifecycle.
- Lifecycle: open before repair.

## Replacement implementation Code Review — Epoch 11 convergence repair

### E11-CR-009 actioned

- The EXIT trap now distinguishes terminal success from preserved paused/failed
  outcomes. Status 2 and failure retain the exact owner-only runtime and write
  its path to `preserved-runtime.txt`; no automatic resume or retry is implied.
- On successful completion, the launcher creates a bundle of the disposable
  repository's integrated `main`, verifies it against that repository, records
  the exact commit/tree identity, and only then allows transient runtime
  cleanup. Bundle export/verification failure changes the launcher result to
  failure and preserves the runtime for inspection.
- Lifecycle: `actioned`; fresh holistic discovery must resolve it.

### Convergence-repair validation and continuation

- Full Python discovery: 93 tests clean.
- Bash syntax, Go transport tests, and `git diff --check`: clean.
- No live launcher/model execution was used; runtime retention and successful
  bundle export still require the separately authorized live PoC run for direct
  end-to-end evidence.
- Current source identities:
  - `poc/kernel.py`: `b79471e1ea337a62c4576b051b85d4bd70ab0b6010183d7d9c8716429d9f212c`;
  - `poc/prototype.py`: `e7acd895c0c5e10d90f781691c2c88bfb81780c9d2ef171bc56b721a7023350a`;
  - `poc/pty_tui.py`: `dc31ade6206e3681ff4970f2fbf75f30425b074eff83e8890eb7e4f696b469b8`;
  - `poc/controller.py`: `3fd28eeb03e46bdb0f4d37f99dab53769add7535c66ba6d184a9d1a022b8800b`;
  - `poc/run-prototype.sh`: `1e86caa80d71546dd667c50522b86db5bf725255c3e01cb513ec89c2316769e9`.
- Continuation token: same approved scope and plan; all accepted Epoch 11
  findings are actioned, with E11-CR-003 rejected as reviewer error. A fresh
  no-history holistic discovery pass is required to resolve Phase 1.
- No live Codex PoC run, commit, or integration was performed.

### E14-CR-001 — Restart proposal subject is not bound to its recommendation

- Review epoch / iteration: 14 / fresh Phase 1 discovery.
- Source: delegated `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `DurableKernel.create_proposal` restart branch.
- Statement: the restart proposal checked only recommendation attempt/intent
  identity, while user-approved snapshot, discarded, and retained content could
  disagree with the durable recommendation and be detected only after an
  external rewind had already run.
- Suspected surface: exact durable prerequisite binding.
- Relationship: same missing-invariant cluster as CP-E13-CR-002; this is a
  missed repair site discovered before that checkpoint was resolved, not a new
  product or architecture decision.
- Fix applied: restart subject must now exactly equal the durable
  recommendation's ID, attempt, intent version, snapshot, discarded list, and
  retained list. Missing, mismatched, cross-work-item, or extra content is
  rejected before presentation or effect authority.
- Regression: wrong snapshot, discarded list, retained list, intent version,
  and extra-field subjects all fail proposal creation; existing high-stakes and
  complete narrative flows remain clean.
- Lifecycle: actioned; fresh holistic Phase 1 discovery is required.

### CP-E13-CR-002 diagnosis and repair decision

- Diagnosis: `local-design-flaw` (high confidence).
- Common root: SQLite was treated partly as an audit log while dispatch and
  continuation still consumed opaque IDs and ad-hoc control-flow shortcuts.
  The missing invariant is that every dependent role or transition consumes
  the exact durable prerequisite content, and execution remains fenced until
  the specific semantic continuation permits it.
- Repair altitude: implementation for E13-CR-011 through E13-CR-013. The
  accepted plan already settles durable re-priming, reconsider-versus-continue
  semantics, finding disposition, and candidate supersession; no user,
  product, scope, or architecture decision is required.
- Selected bounded repair:
  - compose purpose-specific read-only role-prime packets from existing rows;
    do not add a generic context service or agent database access;
  - keep intent-revision `reconsider` fully waiting across repeated
    conversation, and reactivate only `continue_preserved_attempt`;
  - preserve the same candidate for all-rejected findings, provide the exact
    rejected findings and rationales only to re-review, and construct a
    replacement only after an accepted finding produces a changed tree.
- Status: actioned while implementation and restarted holistic discovery are
  pending. Epoch 14 begins at substantive counter zero after the repair.
- Continuation: implement the three bounded corrections and invariant-focused
  regressions, then restart Code Review Phase 1 as fresh discovery. Native gate
  and RFC closure remain blocked until CP-E13-CR-002 is resolved by that
  evidence.

## Epoch 13 native-gate harness repair continuation

### E13-NATIVE-009 — Candidate contract tests fail in the source harness

- Review epoch / iteration: 13 / second native discovery attempt.
- Source: native `codex review --uncommitted` execution evidence.
- Severity / scope: significant / in-scope.
- Location: fixture contract collection outside a disposable
  candidate.
- Statement: general source-tree test discovery collected the fixture contract
  tests before `normalize_values.py` existed, so two tests failed for a missing
  file even though that program is intentionally produced only inside the
  candidate checkout.
- Suspected surface: test lifecycle and fixture/candidate boundary.
- Repair altitude: implementation; no lifecycle, authority, protocol, or
  product behavior changes.
- Initial fix: the contract class skipped while its target program was absent.
  Delegated discovery then proved this also allowed a candidate that omitted
  the required program to pass with zero executed contract tests; that approach
  was removed rather than patched.
- Final fix: the suite is now named `candidate_contract.py`, which general
  source-tree test discovery does not collect, while candidate validation
  explicitly discovers that exact file. It therefore executes both tests for a
  complete candidate and fails both tests when the candidate program is absent.
- Lifecycle: resolved by local positive and negative regression evidence;
  fresh native discovery remains pending.

### E13-CR-010 — Missing candidate program can be hidden by a suite skip

- Review epoch / iteration: 13 / post-native repair discovery.
- Source: delegated `code-review-analyst` holistic discovery.
- Severity / scope: significant / in-scope.
- Location: the initial E13-NATIVE-009 repair in the fixture contract suite.
- Statement: skipping the entire suite whenever `normalize_values.py` was
  missing made source discovery clean, but also let an invalid disposable
  candidate execute zero contract tests and return success.
- Suspected surface: test lifecycle and fixture/candidate boundary.
- Relationship: repair-induced sibling of E13-NATIVE-009.
- Repair altitude: implementation; the accepted candidate-validation contract
  and product behavior are unchanged.
- Fix applied: remove the conditional skip, separate the suite from general
  collection by filename, and explicitly discover it during candidate
  validation. A negative regression proves a missing program runs two failing
  tests; the happy-path narrative proves the complete candidate runs the same
  two tests with no skips.
- Lifecycle: actioned; targeted local verification is clean and a fresh
  holistic delegated discovery pass is required.

### Second native-discovery execution note

- The review was manually interrupted after it read the repository's
  orchestration playbook and recursively invoked another `codex review` from
  inside the active native gate. That recursive invocation is not an
  independent review phase and produced no authoritative final verdict.
- The completed evidence before interruption is retained, including
  E13-NATIVE-009. A replacement native gate must be explicitly constrained to
  inspect and report findings without launching another review workflow.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 13 native Codex gate findings and repair continuation

- Gate command: `codex -c model_reasoning_effort="xhigh" review --uncommitted`.
  The playbook's `danger-full-access` variant was rejected by managed policy, so
  the gate ran in the safer default workspace-write sandbox. It reviewed the
  combined staged, unstaged, and untracked surface and exited successfully with
  seven findings.

### E13-NATIVE-001 — One-sided Git effects remain merely requested

- Review epoch / iteration: 13 / phase-3 native discovery.
- Source: native `codex review --uncommitted`.
- Severity / scope: blocking / in-scope (mapped from P1).
- Location: `poc/prototype.py` integration and restart effect sites.
- Statement: if Git mutates the disposable repository and its subsequent
  read-back raises, the durable effect remains `requested` even though external
  state may already have changed.
- Suspected surface: split external-effect and durable-result lifecycle.
- Relationship: sibling of E13-NATIVE-002 and E13-NATIVE-004 at exception-to-
  durable-state ownership.
- Fix applied: both authorized Git effects now use one narrow helper that records
  every returned or raised result as `completed` or `incomplete`; incomplete
  results visibly pause and never acknowledge success or retry automatically.
- Lifecycle: actioned; native re-review pending.

### E13-NATIVE-002 — Failed workflow can retain an active run

- Review epoch / iteration: 13 / phase-3 native discovery.
- Source: native `codex review --uncommitted`.
- Severity / scope: blocking / in-scope (mapped from P1).
- Location: `poc/kernel.py:record_stop` and `poc/prototype.py` run ownership.
- Statement: a failure after run start stopped only the work item, leaving its
  exact role run active after process cleanup.
- Suspected surface: run/work terminal-state composition.
- Relationship: sibling of E13-NATIVE-001 and E13-NATIVE-004.
- Fix applied: the engine tracks the currently affected run and the kernel now
  atomically moves that exact run plus its work item to waiting or failed,
  including an append-only `run_stopped` event.
- Lifecycle: actioned; native re-review pending.

### E13-NATIVE-003 — Offline transport build depends on a warm module cache

- Review epoch / iteration: 13 / phase-3 native discovery.
- Source: native `codex review --uncommitted`.
- Severity / scope: blocking / in-scope (mapped from P1).
- Location: `poc/run-prototype.sh` transport build.
- Statement: `GOPROXY=off` made a fresh-host build fail because Gorilla
  WebSocket was not available without the user's Go module cache.
- Suspected surface: reproducible launcher bootstrap.
- Fix applied: the pinned Go dependency is vendored and both launchers build
  explicitly with `-mod=vendor`; an empty module-cache build is a regression
  gate.
- Lifecycle: actioned; native re-review pending.

### E13-NATIVE-004 — Some model failures bypass the no-effect path

- Review epoch / iteration: 13 / phase-3 native discovery.
- Source: native `codex review --uncommitted`.
- Severity / scope: significant / in-scope (mapped from P2).
- Location: `poc/prototype.py` typed-model and high-stakes boundaries.
- Statement: timeout, malformed-output, and decode failures not represented as
  `RuntimeError` could fail the workflow instead of preserving a no-effect
  proposal and asking for fresh direction.
- Suspected surface: model-boundary exception normalization.
- Relationship: sibling of E13-NATIVE-001 and E13-NATIVE-002.
- Fix applied: all ordinary exceptions at the model boundary become one typed
  `ModelCallError`; only that boundary error activates the existing high-stakes
  no-effect reconsideration path.
- Lifecycle: actioned; native re-review pending.

### E13-NATIVE-005 — Launcher cleanup can leave prototype descendants alive

- Review epoch / iteration: 13 / phase-3 native discovery.
- Source: native `codex review --uncommitted`.
- Severity / scope: significant / in-scope (mapped from P2).
- Location: `poc/run-prototype.sh` cleanup trap.
- Statement: terminating only the Python leader could leave transport or App
  Server descendants alive while their runtime directory was removed.
- Suspected surface: launcher process ownership.
- Fix applied: the prototype starts in a dedicated process group; cleanup sends
  TERM, waits briefly, escalates to KILL if necessary, and reaps the leader while
  retaining the group identity even if the leader exited first.
- Lifecycle: actioned; native re-review pending.

### E13-NATIVE-006 — Default Codex home is account-specific

- Review epoch / iteration: 13 / phase-3 native discovery.
- Source: native `codex review --uncommitted`.
- Severity / scope: significant / in-scope (mapped from P2).
- Location: `poc/run-prototype.sh` and preserved `poc/run.sh`.
- Statement: an absolute developer home path prevented another local account
  from using its normal Codex authentication directory.
- Suspected surface: launcher portability.
- Fix applied: both launchers prefer explicit `CODEX_HOME` and otherwise derive
  `.codex` from the invoking account's existing `HOME`.
- Lifecycle: actioned; native re-review pending.

### E13-NATIVE-007 — PTY relay leaks nonblocking stdin state

- Review epoch / iteration: 13 / phase-3 native discovery.
- Source: native `codex review --uncommitted`.
- Severity / scope: significant / in-scope (mapped from P2).
- Location: `poc/pty_tui.py` relay finalization.
- Statement: the relay enabled `O_NONBLOCK` on the inherited terminal file
  description but did not restore the original flags before returning control.
- Suspected surface: presentation-process resource ownership.
- Fix applied: relay finalization restores the exact saved stdin flags before
  closing its PTY and exporting the transcript.
- Lifecycle: actioned; native re-review pending.

### E13-CR-008 — PTY child session escapes launcher cleanup

- Review epoch / iteration: 13 / post-native repair verification.
- Source: fresh delegated `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/pty_tui.py` child-session lifecycle composed with
  `poc/run-prototype.sh` cleanup.
- Statement: the relay placed stock Codex and its descendants in a new session,
  outside the launcher's prototype group, but default relay termination did not
  terminate or reap that separately owned session.
- Suspected surface: nested process ownership and all-exit cleanup.
- Relationship: spawned sibling of E13-NATIVE-005; its first repair covered the
  outer group but did not compose through the PTY-owned session boundary.
- Fix applied: the relay now converts TERM and INT into controlled finalization,
  owns the child session on every exit path, sends bounded TERM then KILL, reaps
  the session leader, restores stdin state, and only then exports its transcript.
  A process-level regression uses a SIGHUP/TERM-resistant fake CLI plus a child
  and proves neither remains live after relay termination.
- Lifecycle: actioned; fresh delegated and native re-review pending.

### Epoch 13 convergence diagnosis and resolution decision

- Mode: convergence diagnosis plus pre-fix resolution challenge.
- Diagnosis: `local-design-flaw` with high confidence for E13-NATIVE-001,
  E13-NATIVE-002, and E13-NATIVE-004. Three sibling sites lacked one explicit
  rule: an exception crossing an owned runtime boundary must first produce the
  corresponding durable no-success state. E13-NATIVE-003 and E13-NATIVE-005
  through E13-NATIVE-007 are independent launcher or resource-local defects;
  they are not forced into that cluster.
- Candidate repair and semantic-surface delta: reuse the existing `incomplete`,
  `failed`, and `waiting` states; add exact affected-run tracking, one local
  external-effect wrapper, and one model-boundary exception type. No new user
  authority, recovery protocol, lifecycle state, or general orchestration
  abstraction is introduced.
- Selected repair altitude: implementation.
- Rationale: the accepted plan already names the required terminal states and
  no-automatic-recovery behavior. The architecture is sufficient; its failure
  transitions were incompletely materialized at local call sites.
- Next action: run focused and full regressions, then resume Phase 3 with a fresh
  native discovery pass. No product or scope question is required.
- E13-CR-008 is a composition-blind sibling of E13-NATIVE-005 at the same
  implementation repair altitude. Completing nested process ownership adds no
  new lifecycle state, recovery protocol, or product choice.
- No live Codex PoC run, commit, or integration was performed.

## Preserved post-Epoch 11 convergence detail

This detailed E12 evidence physically landed before the canonical Epoch 11 tail
because an append patch matched a repeated continuation sentence. Its content is
preserved here; the authoritative chronological E12 status is at true EOF.

### Security findings and resolution

- `E12-SEC-001` (significant, in-scope): model-facing child processes inherited
  ambient credentials. Resolved by one minimal child-environment constructor
  used by App Server, transport, PTY, native CLI, Git validation, and prototype
  children. Cloud, Git, SSH, and proxy credential variables are excluded; only
  bounded TLS certificate-path variables cross the model-network boundary.
- `E12-SEC-002` (significant, in-scope): authenticated proxy URLs could remain
  after the initial environment repair. Resolved by excluding proxy variables
  entirely; an authenticated `HTTPS_PROXY` canary proves absence.
- `E12-SEC-003` (blocking, in-scope): candidate-controlled validation executed
  as the controller UID without an OS filesystem/network boundary. Resolved by
  mandatory `BubblewrapValidationRuntime`: fresh namespaces, no parent network,
  no capabilities, cleared environment, read-only candidate and system mounts,
  dedicated writable scratch, `/dev/null` stdin, and a timeout.
- Candidate auth, controller state, and evidence remain outside sandbox mounts.
  Integration remains gated on isolated validation, closure, exact candidate
  identity, and explicit authorization.
- Final delegated `security-researcher` verdict: CLEAN, qualified to the
  declared low-stakes disposable PoC rather than hostile multi-user, kernel-
  sandbox, broad DoS, or production-hardening claims.

### UX findings and resolution

- Ambiguous intake now produces a primary clarification loop; accepted intent
  and attempt start occur only after the request is concrete.
- Restart and integration rejection, clarification, verifier disagreement, and
  transient primary/verifier model failures are durable no-effect pauses. Fresh
  typed direction may reconsider the exact proposal or remain paused; rejection
  never silently abandons work.
- Intent revision clarification re-presents the unchanged proposal. Rejection
  preserves intent v1 and the current attempt, restoring only the recorded
  paused runs on reconsideration.
- `continue_preserved_attempt` now lets the user reject intent v2 and complete
  intent v1 without creating a new intent or entering restart assessment. Its
  validation explicitly excludes the memory gate owned by rejected intent v2.
- Controller-owned primary JSON and history are suppressed from the native UI;
  only curated terminal-safe presentation is shown. Closed PTY input is visibly
  discarded, an acknowledged physical gate opens only after rendering, and
  accepted input alone can create authority.
- Integration presentation distinguishes requested outcome, user-level material
  changes, validation, unresolved risks, exact Git effect, and drill-down file
  inventory. The host ITD supports clarification and renders the complete
  problem/options/pros-cons/recommendation/evidence/limitations structure.
- Final delegated `ux-reviewer` verdict: CLEAN; 36 focused tests passed.

### Correctness findings and resolution

- `E12-CR-001` (significant, in-scope): launcher checked only that `bwrap`
  existed, so namespace denial could be discovered after model work. Resolved
  by `preflight_validation_sandbox.py`, which uses the production validation
  runtime before `prototype.py`, proves hidden host state is unreadable and the
  dedicated scratch is writable, and preserves failure diagnostics.
- `E12-CR-002` (significant, in-scope): the v1 continuation branch inherited the
  launcher-wide v2 memory gate. Resolved by binding that branch to preserved
  intent v1 and leaving the full memory gate only on the accepted-v2 path.
- `E12-CR-003` (significant, in-scope): the real kernel marked successful App
  Server mutations complete before method-specific effect evidence, while the
  controller expected `effect_pending`; fake-kernel tests hid the mismatch.
  Resolved by aligning dispatch shape and the durable state contract. A response
  now enters `effect_pending`; exact `thread/read` or `turn/completed` evidence
  alone records the effect, terminal disposition, outbox confirmation, and final
  `succeeded` state. Early turn completion and late response reconciliation are
  covered with the real kernel.
- `E12-CR-004` (significant, in-scope): `thread/resume` could confirm a mutually
  matching response/read-back for a thread other than the requested one.
  Resolved by requiring response ID, read-back ID, and requested `threadId` all
  to match; the wrong-thread negative test remains effect-pending.

The convergence diagnosis for E12-CR-003/004 is a local state-contract drift,
not a missing generic recovery architecture. The repair aligns the existing
kernel/controller/verifier contract and adds real-boundary tests; it introduces
no new product behavior or lifecycle.

### Final delegated status and validation

- Fresh delegated `code-review-analyst` verdict after all repairs: CLEAN.
- Python discovery: 105 tests clean; one nested Bubblewrap canary skips only in
  the ordinary outer sandbox. The same canary passed 2/2 with local host
  isolation, and the exact startup preflight returned
  `outside_readable=false, scratch_writable=true`.
- Go transport tests, Python compilation, Bash syntax, and `git diff --check`:
  clean.
- Reviewed source identities:
  - `poc/kernel.py`: `a13d4a4d5fc9e35ed8c735d349bbe7f34682416c09d889122f62ffaf8a82001e`;
  - `poc/controller.py`: `47d0626de0693050d640582ebd01767f0d0fe7adac11af0a08e47b39fe322c75`;
  - `poc/prototype.py`: `f55b20158cb4e6914af14648928eeee4084e4d9519090f5fd0a6163c83d818b5`;
  - `poc/pty_tui.py`: `0d428fb4d2520c6a8a8029de2eed87d1ee806e2464a93f13a9a4fb77d71e63b0`;
  - `poc/run-prototype.sh`: `bac7086669b06824132449a7db210fc3eab0865b4dfad957e210970984b44d29`;
  - `poc/preflight_validation_sandbox.py`:
    `a0992cba74228be5b58fbd28c593dedd147d3975933512efc0e35f926ca8791d`.
- Delegated implementation review phases are resolved. Native Codex review and
  final RFC-to-code closure remain pending.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 11 canonical chronology and closure continuation

The Epoch 11 entries above were appended through repeated review/fix turns, and
several repair sections landed before their discovery headings because the
append patch matched a repeated continuation sentence. No finding content was
lost. This index is the authoritative chronological reading order and status:

1. E11-CR-001 and E11-CR-002 discovered; both actioned.
2. E11-CR-003 recorded from truncated overlapping output, then rejected after a
   direct source re-read proved it was reviewer error.
3. E11-CR-004 and E11-CR-005 discovered; both actioned.
4. E11-CR-006, E11-CR-007, and E11-CR-008 discovered; all actioned.
5. E11-CR-009 discovered; actioned in the launcher.
6. E11-CR-010 discovered; actioned at the restart transaction boundary.

### E11-CR-010 actioned

- Successful restart now retires every `assigned`, `active`, or `waiting` run
  belonging to the abandoned attempt and records `ended_ns` in the same SQLite
  transaction that abandons the attempt and verifies the restored snapshot.
- The transition appends `attempt_runs_retired` with the exact affected count.
  The full narrative now asserts that attempt one has no nonterminal runs after
  restart.
- Lifecycle: `actioned`; one fresh no-history holistic pass is required before
  resolution.

### Current Epoch 11 continuation token

- Approved scope and plan SHA-256 remain
  `629924d630de160fc59703e76933f98aa220e3db2997afbad0bbcc4e78997def`.
- Full Python discovery: 93 tests clean.
- Python compilation, Bash syntax, Go transport tests, and `git diff --check`:
  clean.
- Current source identities:
  - `poc/kernel.py`: `beac8b878c1c69a0d9918b4c57bc04a69a05141112323bf4d56fc6a543018e74`;
  - `poc/prototype.py`: `e7acd895c0c5e10d90f781691c2c88bfb81780c9d2ef171bc56b721a7023350a`;
  - `poc/pty_tui.py`: `dc31ade6206e3681ff4970f2fbf75f30425b074eff83e8890eb7e4f696b469b8`;
  - `poc/controller.py`: `3fd28eeb03e46bdb0f4d37f99dab53769add7535c66ba6d184a9d1a022b8800b`;
  - `poc/run-prototype.sh`: `1e86caa80d71546dd667c50522b86db5bf725255c3e01cb513ec89c2316769e9`.
- No live Codex PoC run, commit, or integration was performed.

## Replacement implementation Code Review — Epoch 11 closure discovery

### E11-CR-010 — Restart abandons an attempt but leaves its run waiting

- Source: fresh delegated `code-review-analyst` closure pass.
- Severity / scope: significant / in-scope.
- Location: `poc/kernel.py` restart branch in `complete_effect`.
- Trigger: the approved restart effect restores the attempt-one snapshot.
- Propagation: intent revision previously moved the replacement implementer run
  to `waiting`; restart marks its attempt `abandoned` but never terminalizes
  that run.
- Impact: the final ledger contains a completed work item with apparently
  resumable waiting work owned by an abandoned attempt, contradicting exact
  lifecycle authority and later status/context queries.
- Likelihood: certain in the exercised happy path.
- Obligation: in the same restart-completion transaction, retire every
  nonterminal run of the abandoned attempt and record its end time.
- Root assessment: local missing lifecycle transition at the existing restart
  boundary; no new state, recovery flow, or product decision is required.
- Lifecycle: open before repair.

### E11-CR-002 — Attached pause and failure paths expose only generic errors

- Source: local fallback `code-review-analyst` discovery.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py` `main` exception handling and
  `WorkflowEngine` stop paths.
- Trigger: any exercised rejection, clarification, blocked review, failed
  validation, incomplete effect, or other `WorkflowStopped` branch occurs while
  the user is attached.
- Propagation: the workflow writes `workflow-stopped.txt` and prints the raw
  exception, but does not ask the accountable primary to present the approved
  compact attention-summary shape or durably record the stop before presenting
  it.
- Impact: the user must decode an implementation error instead of receiving
  what changed, current phase, effect status, preserved work, blocker/decision,
  and one safe next action. APR-008 is implemented for detach only, not for the
  attached stop path it explicitly protects.
- Likelihood: high. Rejection and clarification are normal supported branches,
  not production-hardening edge cases.
- Obligation: record the stop and have the primary present the same structured
  recovery summary on attached waiting/failed paths, without Python semantic
  text inference.
- Lifecycle: open before repair.

### E11-CR-003 — One effect request is logged twice

- Source: local fallback `code-review-analyst` discovery.
- Severity / scope: significant / in-scope.
- Location: `poc/kernel.py` `request_effect`.
- Trigger: either authorized restart or integration requests its exact external
  effect.
- Propagation: the transition inserts one effect row but appends two identical
  `effect_requested` workflow events.
- Impact: the append-only authoritative history falsely reports two requests
  for one physical effect, weakening the ledger/Git reconciliation that the PoC
  is intended to demonstrate.
- Likelihood: certain on both exercised high-stakes effects.
- Obligation: append exactly one request event per effect row.
- Lifecycle: open before repair.

### E11 resolution challenge — role-policy cluster

- Mode: resolution challenge.
- Diagnosis: `local-design-flaw` with high confidence.
- Evidence: all three role-sensitive gate methods validate phase and artifact
  identity but omit the same actor-to-transition invariant.
- Repair altitude: implementation. Add one explicit review-kind-to-role policy
  plus direct validator and closure role checks at the existing kernel
  boundaries. This completes the accepted architecture; it does not justify a
  new authorization framework, role registry, state machine, or product choice.
- E11-CR-002 is a direct missing accepted behavior, and E11-CR-003 is a local
  duplicate write. Neither shares the role-policy root cause.

### Epoch 11 synthesis correction — E11-CR-003 rejected

- A direct source re-read showed that `request_effect` appends exactly one
  `effect_requested` event. The apparent second line came from overlapping
  ranges in truncated terminal output, not from `poc/kernel.py`.
- E11-CR-003 is rejected as reviewer error. No code change is warranted, and it
  is excluded from convergence and closure counts.
- This correction also narrows the resolution-challenge result: E11-CR-001 is
  the role-policy cluster; E11-CR-002 is a separate missing accepted behavior.

## Replacement implementation Code Review — Epoch 11 repair checkpoint

### E11-CR-001 actioned

- `DurableKernel.REVIEW_ROLES` now defines the only admitted owner for each
  plan/candidate review kind. `record_review` rejects unknown kinds and
  completed runs whose recorded role is not that owner.
- `record_validation` now requires the completed `validator` run, and
  `record_closure` requires the completed `workflow-closure-verifier` run, in
  addition to their existing current-candidate, review, validation, and plan
  identity checks.
- Semantic-surface delta: one static policy map and checks at existing
  transition boundaries; no new state, lifecycle, protocol, or user choice.
- Lifecycle: `actioned`; fresh holistic discovery must resolve it.

### E11-CR-002 actioned

- The workflow now tracks its explicit mechanical phase. On an attached pause
  or failure, `record_stop` persists the state and reason before a typed primary
  `attention_summary` turn receives exact durable facts.
- The primary output schema requires what changed, current phase, effect status,
  preserved work, blocker/decision, one next action, and the conversational
  presentation. `record_attention_summary` admits only that primary call while
  the work item is stopped. Python does no phrase matching, classification, or
  other semantic interpretation.
- Raw failure detail remains in owner-only evidence; the attached terminal gets
  only a concise preservation/status notice after the primary recovery turn.
- Lifecycle: `actioned`; fresh holistic discovery must resolve it.

### Repair validation and continuation

- Focused `test_kernel` and `test_prototype`: 13 tests clean, including
  wrong-role rejection and stop-before-primary-summary ordering.
- Full Python discovery: 90 tests clean.
- Python compilation, Bash syntax, Go transport tests, and `git diff --check`:
  clean.
- Current reviewed source identities:
  - `poc/kernel.py`: `077f630df96e2b1d0a34b95a7495d44daea032f5863f032f251a2dff95f9fe30`;
  - `poc/prototype.py`: `b08a22178657b85acb4e3aedf9c154149928a831b45ef58aa5499564a7ca4282`;
  - `poc/pty_tui.py`: `fa506d0b34086915ed6137101896bc890cf072d459b617c798cce5a99006858e`;
  - `poc/controller.py`: `3fd28eeb03e46bdb0f4d37f99dab53769add7535c66ba6d184a9d1a022b8800b`.
- Continuation token: same approved scope and plan SHA-256
  `629924d630de160fc59703e76933f98aa220e3db2997afbad0bbcc4e78997def`;
  E11-CR-001 and E11-CR-002 are actioned, E11-CR-003 is rejected reviewer
  error, and the next step is a fresh no-history holistic discovery pass.
- No live Codex PoC run, commit, or integration was performed.

## Replacement implementation Code Review — Epoch 11 convergence discovery

### E11-CR-009 — Launcher cleanup destroys preserved paused work

- Source: fresh delegated `code-review-analyst` convergence pass.
- Severity / scope: blocking / in-scope.
- Location: `poc/run-prototype.sh` unconditional EXIT cleanup.
- Trigger: the user rejects or clarifies restart/integration, or another branch
  exits the workflow paused with status 2.
- Propagation: Python records the no-effect state and exits, then the launcher
  recursively deletes the runtime containing the attempt worktree, candidate
  repository, snapshot bundle, and controller database.
- Impact: the launcher reports “preserved” while destroying the execution state
  needed for inspection or a later directed resume. Successful runs also retain
  hashes but not the plan-required disposable Git bundle.
- Likelihood: certain on every paused exit and successful cleanup.
- Obligation: retain and report the exact runtime on paused/failed outcomes;
  after success, export and verify the disposable integrated-main Git bundle
  before deleting only transient runtime state.
- Root assessment: local lifecycle-policy leak from the archived proof harness,
  not a new architecture or product decision. The proportional fix belongs in
  the launcher; no recovery protocol or automatic resume is added.
- Lifecycle: open before repair.

## Replacement implementation Code Review — Epoch 11 final discovery

- A third fresh delegated `code-review-analyst` pass reviewed the current code
  without the ledger or prior findings.

### E11-CR-006 — Independent interpretation is not bound to its model call

- Source: fresh delegated `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/kernel.py` `record_interpretation` and
  `poc/prototype.py` `present_high_stakes`.
- Trigger: an orchestration wiring error submits caller-provided
  `source=independent`, disposition, response, or model result that did not come
  from the exact persisted semantic-verifier call for this proposal.
- Propagation: the kernel trusts those duplicated caller fields and does not
  verify the model-call role, purpose, exact proposal/response input, or stored
  typed output. `authorize_positive_effect` then counts the row as the required
  independent co-sign.
- Impact: restart or integration can execute without genuine independent
  semantic confirmation.
- Likelihood: medium. The current call site is intended correctly, but the
  kernel exists specifically to contain ordinary orchestration mistakes.
- Obligation: derive and admit interpretation evidence only from the exact
  persisted model call bound to this proposal and response.
- Lifecycle: open before repair.

### E11-CR-007 — Pre-render terminal bytes can become post-render authority

- Source: fresh delegated `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/pty_tui.py` stdin relay and `NativeCliPrimaryInterface`
  response-window opening.
- Trigger: the user enters a response while a high-stakes proposal is still
  rendering.
- Propagation: the PTY forwards stdin continuously. Even though controller
  capture opens only after render, already forwarded/buffered CLI input can be
  submitted after capture opens and appear eligible.
- Impact: a restart or integration response submitted before the completed-
  render boundary can authorize the effect.
- Likelihood: realistic for a voice/terminal user responding quickly.
- Obligation: physically drain and discard closed-window input, then explicitly
  open an acknowledged PTY gate only after render and controller admission.
- Lifecycle: open before repair.

### E11-CR-008 — Internally inconsistent review results can silently pass

- Source: fresh delegated `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/kernel.py` `record_review` and `poc/prototype.py`
  `review_candidate`.
- Trigger: a schema-valid reviewer result says `verdict=clean` while returning
  non-empty findings, or says `verdict=findings` with no findings.
- Propagation: the kernel records the caller's clean verdict without enforcing
  result consistency; the engine ignores findings on the clean branch.
- Impact: candidate findings can bypass first-class persistence/disposition and
  the candidate remains eligible for validation and integration.
- Likelihood: medium; structured model outputs can still be internally
  inconsistent under the current schema.
- Obligation: reject inconsistent verdict/finding combinations before recording
  any review gate.
- Lifecycle: open before repair.

### Epoch 11 second convergence diagnosis — duplicated semantic evidence

- Problem: repeated review iterations found that controller call sites pass
  semantic claims separately from the persisted evidence that is supposed to
  own them.
- Options considered:
  - add one caller-side comparison at each current site: smallest immediate
    diff, but future call paths can repeat the same authority-substitution bug;
  - make existing kernel transitions derive/check claims from their persisted
    owning records: modest local changes, one source of truth, no new lifecycle;
  - build a generic schema/policy execution framework: broader reuse, but large
    unproven semantic surface for this bounded MVP.
- Diagnosis: `local-design-flaw` with high confidence.
- Repair altitude and recommendation: implementation. Make the interpretation
  transition project role, purpose, exact proposal/response, and disposition
  from `model_calls`; make review admission enforce its own verdict/finding
  invariant. Separately add a PTY-owned input gate because E11-CR-007 is a
  physical presentation-boundary issue, not part of the semantic-record cluster.
- No product assumption or approved architecture needs to change.

## Replacement implementation Code Review — Epoch 11 final repair

### E11-CR-006 actioned

- `interpretations.interpretation_id` now references its owning persisted
  `model_calls` row. `record_interpretation` accepts only that model-call ID and
  the proposal ID; it derives source, disposition, exact response, and stored
  result rather than trusting caller duplicates.
- Admission verifies the exact work item, required primary or
  `semantic-verifier` role, restart/integration-specific purpose, exact proposal
  subject, verbatim response input, and allowed typed decision. Independent
  admission still additionally requires the exact current positive primary
  interpretation over the same response.
- The engine advances from the kernel-projected decision, not its local copy of
  model output.
- Lifecycle: `actioned`; fresh holistic discovery must resolve it.

### E11-CR-007 actioned

- Each native CLI attachment now has an explicit controller-to-PTY input control
  and acknowledged input-state file. The PTY starts closed, continuously drains
  closed-window stdin, performs a final non-blocking drain when opening, then
  acknowledges the exact generation/nonce before forwarding input.
- The native interface arms controller capture before requesting the physical
  open, waits for the open acknowledgement, captures one response, then closes
  and waits for the close acknowledgement.
- The PTY test submits bytes before the render/open boundary, proves they were
  counted and discarded, then proves only the post-open response reached the
  CLI. No terminal text is classified.
- Lifecycle: `actioned`; fresh holistic discovery must resolve it.

### E11-CR-008 actioned

- `record_review` now requires the result's verdict to equal the recorded
  verdict, rejects `clean` with any findings, rejects `findings` without at
  least one finding, and rejects unknown verdicts before any gate record is
  inserted.
- Lifecycle: `actioned`; fresh holistic discovery must resolve it.

### Final-repair validation and continuation

- Focused kernel/prototype/PTY suite: 17 tests clean, including wrong-role
  independent-call rejection, inconsistent review rejection, and physical
  pre-boundary input discard.
- Full Python discovery: 93 tests clean.
- Python compilation, Bash syntax, Go transport tests, and `git diff --check`:
  clean.
- Current source identities:
  - `poc/kernel.py`: `b79471e1ea337a62c4576b051b85d4bd70ab0b6010183d7d9c8716429d9f212c`;
  - `poc/prototype.py`: `e7acd895c0c5e10d90f781691c2c88bfb81780c9d2ef171bc56b721a7023350a`;
  - `poc/pty_tui.py`: `dc31ade6206e3681ff4970f2fbf75f30425b074eff83e8890eb7e4f696b469b8`;
  - `poc/controller.py`: `3fd28eeb03e46bdb0f4d37f99dab53769add7535c66ba6d184a9d1a022b8800b`.
- Continuation token: same approved scope and plan; E11-CR-001, E11-CR-002,
  E11-CR-004, E11-CR-005, E11-CR-006, E11-CR-007, and E11-CR-008 are
  actioned; E11-CR-003 is rejected reviewer error. A fresh no-history holistic
  discovery pass is required before Phase 1 can resolve.
- No live Codex PoC run, commit, or integration was performed.

## Replacement implementation Code Review — Epoch 11 verification discovery

- Fresh delegated `code-review-analyst` discovery inspected the current code
  without the ledger or prior finding history.

### E11-CR-004 — Restart policy version does not define the required predicates

- Source: fresh delegated `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `poc/prototype.py` root-assessment call and `poc/kernel.py`
  `record_assessment`.
- Trigger: the root assessor evaluates attempt one under
  `restart-predicates-v1`.
- Propagation: the prompt supplies only the version string; the output schema
  accepts any array; the kernel marks any non-empty collection of true-looking
  objects positive. The assessor can therefore omit, duplicate, or invent
  predicates and still unlock the primary recommendation and restart proposal.
- Impact: an explicitly authorized rewind can occur without evaluating every
  predicate in the accepted versioned policy, invalidating the core restart
  eligibility gate.
- Likelihood: high. This is the current call shape; the scripted test succeeds
  because its model double invents the intended-looking predicates.
- Obligation: define the bounded v1 predicate set, supply it exactly to the
  assessor, and reject missing, duplicate, extra, or structurally incomplete
  results before computing positivity.
- Lifecycle: open before repair.

### E11-CR-005 — Successful effects have no primary applied-result acknowledgement

- Source: fresh delegated `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `poc/prototype.py` successful restart and integration paths.
- Trigger: either high-stakes effect completes with exact read-back.
- Propagation: after `complete_effect`, orchestration immediately advances to
  the next phase without a primary turn presenting the applied status and exact
  result.
- Impact: the user sees confirmation-pending/no-effect feedback but not the
  required matching applied/result acknowledgement for either certain happy-
  path effect.
- Likelihood: certain on both successful effects.
- Obligation: after durable completion, have the primary acknowledge the exact
  effect result through the attached primary interface before advancing.
- Lifecycle: open before repair.

### Epoch 11 convergence diagnosis — incomplete policy materialization

- Problem: two consecutive discovery iterations found controller transitions
  whose intended policy existed in prose/call-site structure but was not fully
  represented at the mechanical boundary.
- Options considered:
  - patch only the currently observed values: smallest diff, but leaves the
    policy-version label detached from its required predicate identities;
  - complete the existing kernel boundary with one bounded v1 policy definition
    and one post-effect acknowledgement binding: slightly more code, but no new
    lifecycle and it removes both demonstrated omissions;
  - redesign the orchestration architecture: could generalize future policy
    enforcement, but is disproportionate to this one-work-item MVP and adds
    unrequired semantic surface.
- Diagnosis: `local-design-flaw` with high confidence.
- Repair altitude and recommendation: implementation. Materialize the already
  accepted v1 predicates in the kernel and add a primary-call-to-completed-effect
  acknowledgement transition. Do not add a generic policy engine, recovery
  protocol, or product decision.
- E11-CR-005 is a separate missing presentation step, not evidence that the
  restart predicate policy itself needs redesign.

## Replacement implementation Code Review — Epoch 11 verification repair

### E11-CR-004 actioned

- `DurableKernel.RESTART_POLICIES` now owns the exact three predicate IDs and
  statements for `restart-predicates-v1`, matching the accepted ITD.
- The exact definitions are supplied to the assessor. Its output schema
  requires one structured ID, boolean result, and non-empty evidence list per
  item. The kernel independently rejects unknown policy versions, wrong-shaped
  results, missing/duplicate/extra IDs, and predicates without specific
  evidence before computing positivity.
- The assessor role contract now explicitly forbids omitted, repeated, or
  invented predicate IDs.
- Lifecycle: `actioned`; fresh holistic discovery must resolve it.

### E11-CR-005 actioned

- Both completed restart and integration effects now trigger a typed primary
  `effect_acknowledgement` before orchestration advances.
- The kernel admits the acknowledgement only for an exactly completed effect,
  from the primary's owning model call, with `effect_status=applied` and an
  `exact_identity` structurally equal to the durable effect result. It then
  records the presentation link in the append-only workflow history.
- Lifecycle: `actioned`; fresh holistic discovery must resolve it.

### Verification-repair validation and continuation

- Focused kernel/prototype suite: 14 tests clean, including rejection of an
  incomplete v1 assessment and two exact effect acknowledgements in the full
  narrative.
- Full Python discovery: 91 tests clean.
- Python compilation, Bash syntax, Go transport tests, and `git diff --check`:
  clean.
- Current source identities:
  - `poc/kernel.py`: `75cd36c7fcfabdc5bbf9400bf2f4497fe0dad73a94d35c096fc34447f4c13c8a`;
  - `poc/prototype.py`: `e7ba96d3c2bf062497e5cd67c7deec8b51fa0053d08ce6af1f48b8b0bcf681b5`;
  - `poc/pty_tui.py`: `fa506d0b34086915ed6137101896bc890cf072d459b617c798cce5a99006858e`;
  - `poc/controller.py`: `3fd28eeb03e46bdb0f4d37f99dab53769add7535c66ba6d184a9d1a022b8800b`.
- Continuation token: same approved scope and plan; E11-CR-001, E11-CR-002,
  E11-CR-004, and E11-CR-005 are actioned, E11-CR-003 is rejected reviewer
  error. A fresh no-history holistic discovery pass is required.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 11 authoritative final status

- The authoritative chronological finding/status index is the “Epoch 11
  canonical chronology and closure continuation” section above. Later headings
  preserve detailed discovery and repair evidence even where physical append
  order is non-chronological.
- A fresh no-history `code-review-analyst` pass reviewed source identities:
  - `poc/kernel.py`: `beac8b878c1c69a0d9918b4c57bc04a69a05141112323bf4d56fc6a543018e74`;
  - `poc/prototype.py`: `e7acd895c0c5e10d90f781691c2c88bfb81780c9d2ef171bc56b721a7023350a`;
  - `poc/pty_tui.py`: `dc31ade6206e3681ff4970f2fbf75f30425b074eff83e8890eb7e4f696b469b8`;
  - `poc/controller.py`: `3fd28eeb03e46bdb0f4d37f99dab53769add7535c66ba6d184a9d1a022b8800b`;
  - `poc/run-prototype.sh`: `1e86caa80d71546dd667c50522b86db5bf725255c3e01cb513ec89c2316769e9`.
- Verdict: CLEAN; no blocking or significant in-scope happy-path defect.
- E11-CR-001, E11-CR-002, and E11-CR-004 through E11-CR-010 are resolved.
  E11-CR-003 remains rejected reviewer error.
- Phase 1 Code Review discovery is resolved. CP-E10-CR-001 may proceed to the
  remaining fresh review phases; it is not yet globally resolved.
- Validation baseline: 93 Python tests, Go transport tests, Python compilation,
  Bash syntax, and `git diff --check` clean.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 12 authoritative final status

- The detailed security, UX, and correctness findings and repairs are preserved
  in “Preserved post-Epoch 11 convergence detail” above. Chronologically, Epoch
  12 follows the complete Epoch 11 record and this section is authoritative.
- Resolved security findings: ambient child credentials, residual proxy
  credentials, and unsandboxed candidate validation.
- Resolved UX findings include ambiguous intake, recoverable no-effect pauses,
  hidden controller-owned primary turns, physical PTY input admission,
  intent-revision rejection, `continue_preserved_attempt`, integration summary,
  and host-ITD clarification.
- Resolved correctness findings: functional Bubblewrap startup preflight,
  rejected-v2 validation leakage into v1, real kernel/controller mutation-state
  drift, early-completion correlation, late-response effect ordering, and exact
  requested-thread identity for `thread/resume`.
- Final delegated verdicts: `security-researcher` CLEAN (bounded low-stakes PoC
  qualification), `ux-reviewer` CLEAN, and `code-review-analyst` CLEAN.
- Python discovery: 105 tests clean with one outer-sandbox-only Bubblewrap skip;
  the real host canary passed 2/2 and the exact startup preflight passed.
- Go transport tests, Python compilation, Bash syntax, and `git diff --check`:
  clean.
- Reviewed source identities:
  - `poc/kernel.py`: `a13d4a4d5fc9e35ed8c735d349bbe7f34682416c09d889122f62ffaf8a82001e`;
  - `poc/controller.py`: `47d0626de0693050d640582ebd01767f0d0fe7adac11af0a08e47b39fe322c75`;
  - `poc/prototype.py`: `f55b20158cb4e6914af14648928eeee4084e4d9519090f5fd0a6163c83d818b5`;
  - `poc/pty_tui.py`: `0d428fb4d2520c6a8a8029de2eed87d1ee806e2464a93f13a9a4fb77d71e63b0`;
  - `poc/run-prototype.sh`: `bac7086669b06824132449a7db210fc3eab0865b4dfad957e210970984b44d29`;
  - `poc/preflight_validation_sandbox.py`:
    `a0992cba74228be5b58fbd28c593dedd147d3975933512efc0e35f926ca8791d`.
- Delegated review is resolved. Native Codex review and final RFC-to-code
  closure remain pending.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 13 post-harness holistic discovery checkpoint

### E13-CR-011 — Fresh role threads lack load-bearing durable context

- Review epoch / iteration: 13 / holistic post-fix discovery.
- Source: delegated `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: role contexts in `poc/prototype.py` and fresh role-thread creation in
  `ControllerModelRuntime.call`.
- Statement: implementers and reviewers receive opaque plan or finding IDs but
  not the corresponding accepted content; the replacement implementer also
  omits the persisted checkpoint/conversation. Fresh role threads cannot query
  the controller-owned SQLite database, so the scripted model hides a real
  context-priming failure.
- Suspected surface: durable context ownership and bounded role-prime packets.
- Lifecycle: actioned; purpose-specific role primes now contain the exact
  accepted intent/plan, handoff checkpoint/conversation, and accepted finding
  content required by each fresh role. Context-sensitive narrative assertions
  reject missing content; fresh Epoch 14 discovery is pending.

### E13-CR-012 — Reconsidering an intent revision resumes paused execution

- Review epoch / iteration: 13 / holistic post-fix discovery.
- Source: delegated `code-review-analyst`.
- Severity / scope: blocking / in-scope.
- Location: `DurableKernel.record_resume_direction`.
- Statement: both `reconsider` and `continue_preserved_attempt` reactivate the
  work item and paused implementer run. Reconsider should only reopen the
  revision conversation; dependent execution must remain fenced until the
  revision is accepted or the user explicitly continues the preserved attempt.
- Suspected surface: semantic-conversation state versus execution authority.
- Lifecycle: actioned; intent-revision `reconsider` records the conversation
  direction while work and runs remain waiting. The same regression then proves
  a later explicit `continue_preserved_attempt` reactivates the exact run;
  fresh Epoch 14 discovery is pending.

### E13-CR-013 — Rejected findings create an unanchored identical candidate loop

- Review epoch / iteration: 13 / holistic post-fix discovery.
- Source: delegated `code-review-analyst`.
- Severity / scope: significant / in-scope.
- Location: `WorkflowEngine.review_candidate` and
  `accept_and_fix_findings`.
- Statement: every findings verdict registers a replacement candidate even
  when every finding is rejected and no code changes. The next reviewer gets
  neither the rejected finding nor its rationale, so the same finding can recur
  until the bounded loop stops.
- Suspected surface: finding disposition, candidate supersession, and re-review
  priming.
- Lifecycle: actioned; all-rejected findings preserve the exact candidate and
  prime its re-review with complete rejected findings and rationales. Accepted
  fixes alone construct a replacement, and an unchanged replacement tree stops
  visibly; fresh Epoch 14 discovery is pending.

### CP-E13-CR-002 — Cross-surface context and authority convergence checkpoint

- Status: actioned.
- Trigger: new blocking sibling findings appeared after multiple substantive
  Epoch 13 repair/discovery iterations, spanning role priming, paused execution
  authority, and finding re-review continuity.
- Pending obligation: determine whether these are independent implementation
  defects or symptoms of one unresolved boundary between durable controller
  state and fresh model-role execution.
- Continuation token:
  - phase: `phase-1`;
  - boundary: `pre-fix`;
  - lane: `discovery`;
  - next action: diagnose the cluster and select the least-surface repair
    altitude before changing implementation.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 14 context-boundary repair continuation

- CP-E13-CR-002 diagnosis selected an in-scope implementation repair with no new
  durable state, authority, lifecycle, protocol, or user-visible behavior.
- Existing SQLite rows now feed closed purpose-specific prime packets; agents
  still have no database access and program code still performs no natural-text
  classification.
- Invariant-focused evidence:
  - handoff prime returns the exact persisted checkpoint and conversation;
  - intent-revision reconsider remains waiting and a later explicit continue
    reactivates the exact paused run;
  - a context-sensitive model double refuses missing plan, intent, handoff, or
    finding content;
  - all-rejected findings re-review the same candidate with rationale, while an
    accepted finding produces the only replacement candidate;
  - missing candidate program runs two failing contract tests, while the valid
    candidate runs the same two tests cleanly without skips.
- Validation: 113 Python unittest tests clean with one outer-sandbox-only skip;
  112 pytest tests clean with the same skip; Python compilation, Bash syntax,
  shellcheck at warning severity, and `git diff --check` clean.
- Continuation token: start fresh Code Review Phase 1 discovery in Epoch 14.
  CP-E13-CR-002 remains actioned until that discovery and downstream native gate
  resolve the checkpoint.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 14 second holistic discovery findings

#### E14-CR-002 — Restart assessment omits untracked attempt content

- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst`.
- Location: root-assessor context construction.
- Statement: tracked Git diff omitted the attempt's untracked central program,
  so assessment could reason from incomplete implementation state.
- Relationship: same exact-prerequisite cluster as CP-E13-CR-002.
- Fix applied: a read-only attempt-state packet now includes the tracked binary
  diff plus every regular untracked file's path, size, SHA-256, and base64
  content. The context-sensitive narrative refuses to assess unless the actual
  untracked `normalize_values.py` content is present.
- Lifecycle: actioned; fresh holistic discovery pending.

#### E14-CR-003 — Integration proposal is not bound to candidate identity

- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst`.
- Location: `DurableKernel.create_proposal` integration branch.
- Statement: user-approved candidate/base/tree/diff/inventory/effect fields
  could disagree with the durable candidate that integration later used.
- Relationship: sibling of E14-CR-001 under CP-E13-CR-002.
- Fix applied: attempt, plan, intent version/outcome, candidate commit, base,
  tree, diff, inventory, and exact fast-forward effect must match the current
  durable candidate and intent before proposal persistence. Negative regressions
  reject mismatches and the valid narrative remains clean.
- Lifecycle: actioned; fresh holistic discovery pending.

#### E14-CR-004 — Malformed reviewer findings cross the model boundary

- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst`.
- Location: review output schema, `record_review`, and `record_finding`.
- Statement: findings array items were unconstrained and missing content could
  crash or be replaced by fabricated generic values.
- Relationship: same exact typed-prerequisite cluster as CP-E13-CR-002.
- Fix applied: output schema and kernel both require exact severity, scope,
  location, statement, scenario, and suggested-resolution fields with allowed
  enums and non-empty evidence. Fallback fabrication was removed, the complete
  finding is persisted, and malformed model results fail before review/finding
  state changes.
- Lifecycle: actioned; fresh holistic discovery pending.

- Updated focused evidence: integration identity mismatches, malformed finding
  payloads, complete attempt-state priming, and the complete narrative are
  clean. A new fresh holistic discovery pass is required before Phase 1 exit.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 14 Phase 3 native-gate findings and repair continuation

### E14-NATIVE-001 — Canonical terminal buffering crosses the response window

- Priority / scope: P1 / in-scope.
- Source: native `codex review --uncommitted` gate.
- Location: interactive stdin admission in `poc/pty_tui.py`.
- Statement: text typed while the response window was closed could remain
  unreadable in the outer terminal's canonical buffer; pressing Enter after the
  window opened would then deliver the pre-window line as current authority.
- Fix applied: the relay temporarily disables only outer-terminal canonical
  buffering, drains or discards every byte observed while closed, and restores
  the exact inherited termios and file-status flags on exit. A real-PTY
  regression proves a partial pre-window line is discarded before a fresh line
  is forwarded.
- Lifecycle: actioned; fresh native re-review pending.

### E14-NATIVE-002 — Restart approval can cover consequences not rendered

- Priority / scope: P1 / in-scope.
- Source: native `codex review --uncommitted` gate.
- Location: restart presentation in `WorkflowEngine.present_high_stakes`.
- Statement: a terse but schema-valid primary summary could be marked as the
  complete presentation even though the durable recommendation, attempt,
  intent version, restore snapshot, discarded state, and retained state were
  hidden from the user.
- Fix applied: restart decisions now mechanically render every exact
  subject-bound consequence before the proposal becomes response-eligible. A
  regression asserts every field is visible even when primary prose is terse.
- Lifecycle: actioned; fresh native re-review pending.

### E14-NATIVE-003 — Attach render can precede attach-turn completion

- Priority / scope: P1 / in-scope.
- Source: native `codex review --uncommitted` gate.
- Location: `NativeCliPrimaryInterface.attach`.
- Statement: startup output could satisfy quiet-render readiness while the
  attach prompt's App Server turn was still running, allowing input admission
  against an incomplete or wrong turn.
- Fix applied: attach captures the prior primary completion epoch, waits for a
  strictly newer `turn/completed`, then requires a render observation at or
  after that completion before the closed input gate is acknowledged.
- Lifecycle: actioned; fresh native re-review pending.

### E14-NATIVE-004 — Interactive PTY refactor breaks the retained qualification runner

- Priority / scope: P2 / in-scope touched invariant.
- Source: native `codex review --uncommitted` gate.
- Location: `poc/run.sh` and the PTY driver contract.
- Statement: the retained Phase-4 runner invoked the new interactive driver
  without its required gate arguments and still expected legacy marker/status
  artifacts that the interactive driver no longer emits.
- Fix applied: the one-shot qualification behavior now has a separate
  `poc/qualification_pty_tui.py`; `run.sh` and its provenance manifest use that
  driver, while the ordinary PoC keeps the smaller interactive gate. A focused
  subprocess test proves the legacy marker, status, raw, text, JSONL, and command
  artifacts are produced.
- Lifecycle: actioned; fresh native re-review pending.

- Repair-altitude assessment: all four findings are implementation defects.
  The first three share an incomplete response-eligibility boundary; the fourth
  is a compatibility regression at a retained touched surface. No product,
  requirement, architecture, authority, lifecycle, or scope change is needed.
- Post-repair validation: 120 unittest tests clean and 119 pytest tests clean,
  each with one expected outer-sandbox-only skip; Python compilation, Bash
  syntax, and `git diff --check` are clean.
- No live Codex PoC run, commit, or integration was performed.

### E14-CR-005 — Qualification status invents a marker-triggered termination

- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst` repair review.
- Location: `poc/qualification_pty_tui.py` status construction.
- Statement: a CLI that printed the marker and exited naturally before the
  delayed termination path would still be reported as having received
  `SIGTERM_after_marker`.
- Fix applied: marker observation, actual termination-path execution, and the
  termination reason are separate variables. A fast-exit regression proves
  marker success does not fabricate a signal, while the long-running marker
  path still records its actual termination.
- Lifecycle: actioned; delegated repair re-review pending.

### E14-CR-006 — Qualification provenance omits its imported cleanup source

- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst` repair review.
- Location: qualification driver import and qualification provenance profile.
- Statement: the driver executed `terminate_child_session` from
  `poc/pty_tui.py`, but only the caller was bound into the qualification source
  manifest, so cleanup logic could drift without invalidating evidence.
- Fix applied: the imported PTY session-cleanup source is now a distinct exact
  qualification provenance role. A regression binds the declared role to the
  actual import; the existing exact-tree provenance test covers source drift.
- Lifecycle: actioned; delegated repair re-review pending.

- Updated post-repair validation: 122 unittest tests clean and 121 pytest tests
  clean, each with one expected outer-sandbox-only skip; Python compilation,
  Bash syntax, shellcheck warning gate, and `git diff --check` are clean.
- No live Codex PoC run, commit, or integration was performed.

### E14-CR-007 — Final qualification assertion retains the old manifest role set

- Severity / scope: blocking / in-scope.
- Source: delegated repair re-review.
- Location: final executed-artifact manifest check in `poc/assert.py`.
- Statement: the capture and repository verifier included the newly bound PTY
  cleanup source, but the terminal assertion still demanded the prior exact role
  set, making every retained qualification run fail at final verdict.
- Fix applied: the final assertion's explicit role contract includes
  `pty_session_cleanup_source`. A focused test now requires the assertion role
  set to equal the qualification source profile plus the exact runtime-binary
  roles, preventing future capture/assertion drift.
- Lifecycle: actioned; delegated repair re-review pending.

- Updated validation: 123 unittest tests clean and 122 pytest tests clean, each
  with one expected outer-sandbox-only skip; Python compilation, Bash syntax,
  shellcheck warning gate, Go transport tests, and `git diff --check` are clean.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 14 delegated native-repair re-review closure

- Fresh delegated verdict: CLEAN.
- E14-NATIVE-001 through E14-NATIVE-004 and E14-CR-005 through E14-CR-007
  are resolved by review and focused evidence.
- Re-review additionally repeated the fast-marker exit path 25 times, confirmed
  the imported cleanup source is manifest-bound, and confirmed the final
  assertion role set exactly composes source and runtime roles.
- Continuation token: rerun the independent Phase 3 native Codex gate over the
  complete current uncommitted tree.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 14 second Phase 3 native-gate findings

### E14-NATIVE-008 — Restart consequences may be empty

- Priority / scope: P1 / in-scope.
- Source: native `codex review --uncommitted` gate.
- Location: restart recommendation schema and durable kernel transition.
- Statement: empty discarded/retained lists can reach a response-eligible
  restart proposal, so user authority may cover unnamed consequences.
- Resolution challenge: local implementation fix. Require non-empty, non-blank
  consequence lists at both the model schema and kernel boundary.
- Lifecycle: accepted; repair pending.

### E14-NATIVE-009 — Durable role owner is not its physical App Server thread

- Priority / scope: P1 / in-scope.
- Source: native `codex review --uncommitted` gate.
- Location: workflow run creation and `ControllerModelRuntime` thread lifecycle.
- Statement: a planner run can span two fresh App Server threads while its
  durable `owner_id` is an unrelated generated value, making pause/resume and
  ownership evidence false.
- Resolution challenge: local architecture defect. The amended plan requires
  one actual App Server thread per agent run, thread reuse for continuation, and
  an explicit new run/handoff for physical replacement.
- Lifecycle: accepted; narrow plan amendment and Plan Review pending.

### E14-NATIVE-010 — Qualification interruption can leak its PTY child session

- Priority / scope: P2 / in-scope touched invariant.
- Source: native `codex review --uncommitted` gate.
- Location: `poc/qualification_pty_tui.py` interruption path.
- Statement: external SIGINT/SIGTERM can exit the driver without terminating
  and reaping a signal-resistant child in its separate session.
- Resolution challenge: local implementation fix. Install parent signal
  handlers, reset them in the child, and guarantee session cleanup in `finally`
  while preserving a signal-derived exit status.
- Lifecycle: accepted; repair pending.

- Native gate verdict: findings; not yet converged.
- No live Codex PoC run, commit, or integration was performed.

### E14-PLAN-011 — Ownership domain and non-agent run representation are ambiguous

- Severity / scope: blocking / in-scope.
- Source: delegated `rfc-reviewer` verification.
- Location: amended execution-ownership contract.
- Statement: the plan did not distinguish App-Server-agent-owned runs from the
  controller-executed validator, and it left the semantic verifier's durable-run
  status unclear.
- Fix applied: existing roles now classify ownership without a new subsystem.
  Agent roles, including the one-shot semantic verifier, use their exact App
  Server thread ID; controller validation uses a stable validation-runtime
  identity and no agent thread; primary semantic turns remain on the identified
  logical-primary thread outside delegated role runs.
- Lifecycle: actioned; Phase 1 verification re-review pending.

### E14-PLAN-012 — Ownership correction lacks exact acceptance evidence

- Severity / scope: significant / in-scope.
- Source: delegated `rfc-reviewer` verification.
- Location: acceptance evidence and deliberate composition cases.
- Statement: generic role/handoff tests did not prove the three exact identity
  relationships whose omission caused E14-NATIVE-009.
- Fix applied: the plan now requires durable ordering evidence for actual thread
  binding before first work, identical thread/run reuse after the planner ask,
  and a different exact thread on the distinct replacement implementer run with
  no placeholder or overlap.
- Lifecycle: actioned; Phase 1 verification re-review pending.

- Adversarial reviewer: GREEN CLEAR; its only plausible scenario converged with
  E14-PLAN-011 and was not duplicated.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 14 ownership-amendment Plan Review closure

- Structured review after amendment: GREEN; E14-PLAN-011 and E14-PLAN-012
  resolved.
- Adversarial review after amendment: GREEN CLEAR.
- Subtractive minimality review: MINIMAL; no finding and no plan edit.
- Post-minimization verification: GREEN / GREEN CLEAR.
- Final reviewed plan SHA-256:
  `f880b235d24b3275e4d86bbaf3ca5d8c5c60e09e75ac5e92f83e2921e6e235d7`.
- A local ignored Plan Review receipt binds that artifact to repository HEAD
  `e045cf1e14277c2befc78a450201a6b19b33ba40`.
- Continuation token: implement E14-NATIVE-008 through E14-NATIVE-010 against
  the amended plan, then restart Code Review and the independent native gate.
- No live Codex PoC run, commit, or integration was performed.

## Epoch 15 fresh Phase 1 code-review findings

### E15-CR-001 — Planner run and turns bind different workspaces

- Severity / scope: blocking / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: planner run creation and `ControllerModelRuntime` exact-owner check.
- Statement: the planner thread is opened against the repository workspace, but
  its turns use the attempt worktree, so the live runtime rejects the defining
  planning path before a plan exists.
- Resolution challenge: implementation repair. Bind planner provisioning and
  every planner turn to the same current attempt worktree and exercise the
  exact role/workspace invariant in the workflow test double.
- Lifecycle: accepted; repair pending.

### E15-CR-002 — Semantic verifier can inspect primary evidence or use tools

- Severity / scope: blocking / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: semantic-verifier run creation and exact-turn acceptance.
- Statement: the independent prompt-only verifier currently receives read
  access to the main workspace, where the primary interpretation evidence is
  already stored, and its completed turn is accepted without rejecting tool
  activity.
- Resolution challenge: implementation repair of the already reviewed
  isolation contract. Give every verifier run a fresh empty directory under the
  disposable runtime, outside repository/evidence, bind its exact thread and
  turn there, and reject any exact-turn item other than model reasoning/plan and
  the final agent message. Existing runtime cleanup owns the directory.
- Lifecycle: accepted; repair pending.

### E15-CR-003 — Blocked code-review findings are not first-class

- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: iterative/native candidate-review verdict branching and
  `DurableKernel.record_finding`.
- Statement: a `blocked` review may contain findings, but the current flow
  pauses before promoting them to candidate-bound finding rows or obtaining
  primary dispositions.
- Resolution challenge: implementation repair. Persist and disposition every
  non-empty candidate finding list before verdict branching; permit findings
  from exact `findings` or `blocked` review rows; fix accepted findings into a
  replacement candidate and otherwise preserve/pause the candidate.
- Lifecycle: accepted; repair pending.

- Cluster diagnosis: E15-CR-001 and E15-CR-002 are role-specific workspace
  selection omissions, not evidence for a new generic workspace-policy
  framework. E15-CR-003 is an independent review-result composition defect.
  All three obligations already exist in the reviewed plan, so no plan change,
  Plan Review restart, or user product decision is required.
- Continuation token: apply the three bounded repairs, run targeted and full
  validation, then perform targeted verification followed by fresh holistic
  Phase 1 discovery.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 15 Phase 1 repair status

- E15-CR-001 fix applied: planner provisioning now uses the exact attempt
  worktree supplied to both planner turns. The scripted runtime enforces the
  same run/role/workspace binding as the live runtime, and the direct App Server
  runtime regression proves one thread is reused for both turns.
- E15-CR-002 fix applied: every verifier run receives a new empty directory
  under the disposable runtime's worktree root, outside repository/evidence;
  its exact thread and turn bind that directory. Exact-turn read-back rejects
  command, file, MCP, dynamic, collaboration, web, image, sleep, malformed, or
  any other non-prompt-only item before the typed output can become a co-sign.
- E15-CR-003 fix applied: iterative and native candidate review paths promote
  every non-empty finding list before verdict branching. Exact `findings` and
  `blocked` candidate reviews may own first-class finding rows; accepted blocked
  findings create a replacement candidate and re-review, while an unfixable or
  empty blocked result preserves the candidate and pauses.
- Lifecycle: E15-CR-001 through E15-CR-003 actioned; targeted verification
  pending. Continuation token remains a fresh holistic Phase 1 discovery pass
  after targeted closure.
- Post-fix validation: 128 unittest tests pass with one expected
  outer-sandbox-only skip; 127 pytest tests pass with the same skip. Python
  compilation, Go transport tests, Bash syntax, shellcheck warning gate, and
  staged/unstaged `git diff --check` are clean.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 15 targeted verification closure

- Delegated verification: E15-CR-001 CLOSED; planner provisioning and both
  turns share the exact attempt worktree and durable run owner.
- Delegated verification: E15-CR-002 CLOSED; verifier directories are fresh and
  isolated, exact turn items are prompt-only, and a violation enters the
  existing no-effect failure path.
- Delegated verification: E15-CR-003 CLOSED; both review loops promote blocked
  findings and the kernel binds them to the exact candidate review before
  disposition, fix, re-review, or visible pause.
- Lifecycle: E15-CR-001 through E15-CR-003 resolved by targeted verification.
  This does not establish Phase 1 convergence.
- Continuation token: fresh history-blind holistic Phase 1 discovery over the
  complete current tree.
- No live Codex PoC run, commit, or integration was performed.

### E15-CR-004 — Paused previous-intent attempt can advance artifacts

- Review epoch / iteration: 15 / Phase 1.2 holistic discovery.
- Severity / scope: blocking / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: current-lineage guards in `poc/kernel.py` plan, candidate, and
  dependent artifact transitions.
- Statement: accepting a new intent pauses the current attempt but intentionally
  leaves its ID current; downstream guards that compare only this ID allow the
  paused previous-intent attempt's accepted plan to remain readable and create
  a new current candidate.
- Suspected surface: current active attempt and intent-lineage invariant.
- Fix applied: none.
- Lifecycle: open.
- Relationship: spawned-sibling of other exact-identity enforcement findings;
  clustered with E15-CR-005.

### E15-CR-005 — Stale presented proposal can still authorize an effect

- Review epoch / iteration: 15 / Phase 1.2 holistic discovery.
- Severity / scope: blocking / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: proposal interpretation, positive authorization, and effect-request
  transitions in `poc/kernel.py`.
- Statement: a proposal presented under an older accepted intent can still
  receive primary and independent approvals and authorize a restart because
  positive authority/effect transitions do not revalidate the exact proposal
  subject against current lineage.
- Suspected surface: current proposal subject and effect-lineage invariant.
- Fix applied: none.
- Lifecycle: open.
- Relationship: spawned-sibling of E15-CR-004; both allow retained historical
  identities to masquerade as current authority.

### Epoch 15 convergence checkpoint — current-lineage enforcement

- Review epoch: 15.
- Triggered at: Phase 1.2 holistic discovery, before fixing E15-CR-004/005.
- Continuation:
  - Phase: Phase 1.
  - Boundary: pre-fix.
  - Lane: discovery.
  - Required next action: disposition and repair E15-CR-004/005, then targeted
    verification and a fresh holistic Phase 1 discovery pass.
- Trigger: new P1 sibling failures surfaced after a substantive fix/re-review
  iteration and repeatedly implicate missing exact-current-lineage enforcement.
- Evidence clusters:
  - retained `current_attempt_id` is treated as active/current-intent lineage by
    plan, candidate, and dependent artifact transitions;
  - a once-current proposal identity is treated as current effect authority
    after accepted intent supersession;
  - both findings were reproduced directly against temporary SQLite state.
- Diagnosis: pending.
- Action: pending convergence diagnosis and repair-altitude selection.
- Status: open.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 15 convergence diagnosis and action

- Diagnosis: `local-design-flaw` (high confidence). Retained durable identity is
  being mistaken for current authority across both artifact progression and
  high-stakes proposals.
- Repair altitude: implementation. The reviewed plan already requires active
  current-intent lineage and stale-reference rejection; no product assumption,
  user-visible choice, scope change, or plan amendment is missing.
- Action: add one private current-execution-lineage predicate to the exact
  plan/candidate/review/validation/closure authority barriers, plus one
  kind-specific proposal-currentness predicate at creation, interpretation,
  positive authorization, and effect request. Preserve historical findings,
  reviews, assessments, and recommendations; keep stale proposals closable as
  no-effect; do not add proposal states, recovery, or generic authorization.
- Test obligation: table-driven accepted-intent barriers for every named
  artifact transition and supersession-after-presentation checks at
  interpretation, authorization, and request-effect boundaries.
- Status: actioned.
- Status evidence: convergence diagnosis selected the bounded invariant repair;
  only that repair and its validation/review restart may proceed.
- After implementation, start review epoch 16 at counter zero and restart Code
  Review Phase 1. This checkpoint resolves only after the restarted flow
  converges through the required final gate.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 15 current-lineage repair status

- E15-CR-004 fix applied: one private current-execution-lineage predicate now
  requires the exact current attempt to be active and to carry the work item's
  current intent version. Plan recording/acceptance/priming, candidate
  registration and candidate review, validation, closure, and integration
  authority retain their artifact-specific checks and also pass this barrier.
- E15-CR-005 fix applied: one kind-specific proposal predicate now rechecks the
  exact current recommendation/paused restart target or active integration
  candidate/plan lineage at proposal creation, interpretation, positive
  authorization, and effect request. Stale presented proposals remain closable
  as no-effect; already-requested external results remain recordable.
- The repair adds no durable state, proposal lifecycle, generic authorization,
  recovery, or historical-record rejection.
- Lifecycle: E15-CR-004 and E15-CR-005 actioned; targeted verification pending.
- Validation: 130 unittest tests pass with one expected outer-sandbox-only skip;
  129 pytest tests pass with the same skip. Python compilation, Go transport
  tests, Bash syntax, shellcheck warning gate, and staged/unstaged
  `git diff --check` are clean.
- Continuation token: targeted verification of E15-CR-004/005, then start review
  epoch 16 at counter zero with a fresh holistic Phase 1 discovery pass.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 15 targeted current-lineage verification

- E15-CR-004 CLOSED: the exact active/current-intent predicate covers every
  accepted artifact authority barrier; no missing sibling was found in that
  transition set.
- E15-CR-005 CLOSED: exact subject currentness is rechecked at creation,
  interpretation, positive authorization, and effect request; stale presented
  proposals remain no-effect closable.
- Lifecycle: E15-CR-004 and E15-CR-005 resolved by targeted verification.
- Epoch transition: review epoch 16 starts at counter zero and restarts Code
  Review Phase 1 from a fresh discovery lane. The convergence checkpoint remains
  actioned until that restarted flow and its required final gate converge.
- No live Codex PoC run, commit, or integration was performed.

### E16-CR-001 — Detached high-stakes capture cannot re-present the proposal

- Review epoch / iteration: 16 / Phase 1.1 holistic discovery.
- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: `NativeCliPrimaryInterface._capture_user_input` and
  `WorkflowEngine.present_high_stakes` in `poc/prototype.py`.
- Statement: if the stock CLI presentation detaches while a high-stakes
  response is being captured, the controller invalidates the presentation but
  the interface continues waiting on the old generation's input queue/state.
  It eventually times out or fails instead of reattaching and presenting the
  exact pending proposal in a new generation.
- Suspected surface: presentation lifecycle and generation fencing.
- Fix applied: none.
- Lifecycle: open.

### E16-CR-002 — Preserved runtime retains copied Codex credentials

- Review epoch / iteration: 16 / Phase 1.1 holistic discovery.
- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: cleanup preservation branch in `poc/run-prototype.sh`.
- Statement: paused and failed runs intentionally preserve the runtime for
  diagnosis, but cleanup returns before deleting the copied
  `server-home/auth.json` and `tui-home/auth.json` credentials. Diagnostic
  preservation therefore retains secrets that are not part of the evidence
  contract.
- Suspected surface: launcher cleanup ordering.
- Fix applied: none.
- Lifecycle: open.

### Epoch 16 Phase 1 discovery status

- Fresh holistic discovery found no new P1 finding.
- E16-CR-001 and E16-CR-002 are accepted as significant, in-scope findings.
- Continuation token: run a pre-fix resolution challenge, apply only the
  selected bounded repairs, validate, and obtain targeted verification before
  another fresh holistic Phase 1 discovery pass.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 16 resolution challenge and repair status

- E16-CR-001 diagnosis: `local-design-flaw`; implementation altitude. Input
  capture assumed an attachment survived the response window even though
  detach is a first-class generation invalidation. No plan or product decision
  was missing.
- E16-CR-001 fix applied: opaque input is bound to its presentation generation;
  capture observes detach as a typed outcome and cancels old admission. The
  high-stakes loop preserves the exact proposal ID, subject, and rendered
  decision, attaches a fresh stock CLI, and presents it under the new
  generation. Detach discovered after capture but before interpretation,
  verification, or authorization enters the same re-presentation path. No new
  proposal, reconsideration, or recovery state was added.
- E16-CR-002 diagnosis: `local-fix-appropriate`; implementation altitude. The
  preserved-runtime branch preceded credential scrubbing.
- E16-CR-002 fix applied: after child termination/reap and before any preserve
  branch, the launcher deletes and verifies absence of only the two runtime
  auth copies. A scrub failure disables preservation, surfaces failure, and
  falls through to safe runtime deletion; source auth and evidence are not
  targeted.
- Lifecycle: E16-CR-001 and E16-CR-002 actioned; targeted verification pending.
- Validation: 136 unittest tests pass with one expected outer-sandbox-only
  skip; 135 pytest tests pass with the same skip. Python compilation, Go
  transport tests, Bash syntax, shellcheck warning gate, and staged/unstaged
  `git diff --check` are clean.
- Continuation token: targeted verification of E16-CR-001/002, then a fresh
  holistic Phase 1 discovery pass.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 16 targeted verification closure

- E16-CR-001 CLOSED: queued input is generation-bound; detach wakes capture,
  fences stale input, and re-presents the identical pending proposal and cached
  rendered decision under a higher generation. Invalidation before primary
  interpretation, verifier interpretation, or final authorization follows the
  same path. Reattach failure leaves the proposal pending with no effect.
- E16-CR-002 CLOSED: child processes are reaped before exact runtime auth-copy
  removal; residual credentials or scrub failure disable preservation and fall
  through to safe runtime deletion. The source credential is never targeted.
- No directly spawned sibling defect was found.
- Lifecycle: E16-CR-001 and E16-CR-002 resolved by targeted verification. This
  does not establish Phase 1 convergence.
- Post-verification validation: 138 unittest tests pass with one expected
  outer-sandbox-only skip. Python compilation, Go transport tests, Bash syntax,
  shellcheck warning gate, and staged/unstaged `git diff --check` remain clean.
- Continuation token: fresh history-blind holistic Phase 1 discovery over the
  complete current tree.
- No live Codex PoC run, commit, or integration was performed.

### E16-CR-003 — Native hard-review gate uses a custom reviewer turn

- Review epoch / iteration: 16 / Phase 1.2 holistic discovery.
- Severity / scope: blocking / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: native candidate review in `poc/prototype.py`.
- Statement: the gate named `native-hard-review` starts an ordinary custom
  `native-reviewer` App Server thread and turn. It does not invoke a native
  Codex review surface, so a custom role's clean output can satisfy the kernel
  while the plan-required native review never ran.
- Suspected surface: native review provenance and candidate-bound result.
- Fix applied: none.
- Lifecycle: open.
- Relationship: clustered with E16-CR-004 through E16-CR-006 as an
  evidence-to-claim binding defect.

### E16-CR-004 — Gate results are not bound to their run's consumed artifact

- Review epoch / iteration: 16 / Phase 1.2 holistic discovery.
- Severity / scope: blocking / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: `DurableKernel.record_review`, `record_validation`, and
  `record_closure` in `poc/kernel.py`.
- Statement: result recording checks the run role/state/attempt but does not
  mechanically compare the recorded artifact with the candidate or plan
  identity that the run consumed. A completed run over candidate A can
  therefore be recorded as the clean gate for candidate B.
- Suspected surface: immutable consumed-artifact provenance.
- Fix applied: none.
- Lifecycle: open.
- Relationship: exact-identity sibling of earlier authority findings and part
  of the current evidence-to-claim cluster.

### E16-CR-005 — Integration material-change summary is not final-candidate bound

- Review epoch / iteration: 16 / Phase 1.2 holistic discovery.
- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: `WorkflowEngine.integrate_candidate_and_record_itd` in
  `poc/prototype.py`.
- Statement: user-visible `material_changes` comes from the implementer's
  pre-review typed outcome rather than a synthesis over the exact final
  candidate, accepted plan, review fixes, validation, and closure. The user can
  therefore authorize the exact commit from an inaccurate or stale summary.
- Suspected surface: candidate-bound integration presentation evidence.
- Fix applied: none.
- Lifecycle: open.
- Relationship: evidence-to-claim sibling of E16-CR-003/004/006.

### E16-CR-006 — Detach exercise proves replacement, not detached execution

- Review epoch / iteration: 16 / Phase 1.2 holistic discovery.
- Severity / scope: significant / in-scope.
- Source: fresh delegated `code-review-analyst` discovery pass.
- Location: planned presentation replacement in `poc/prototype.py`.
- Statement: `detach_and_reattach` synchronously stops the old CLI and waits for
  the replacement before any accepted role operation proceeds. It proves
  presentation replacement and generation fencing, but not the plan's claim
  that work continues while no user presentation is attached.
- Suspected surface: detached-execution acceptance evidence.
- Fix applied: none.
- Lifecycle: open.
- Relationship: evidence-to-claim sibling of E16-CR-003 through E16-CR-005.

### Epoch 16 convergence checkpoint — evidence-to-claim binding

- Review epoch: 16.
- Triggered at: Phase 1.2 holistic discovery, before fixing E16-CR-003 through
  E16-CR-006.
- Continuation:
  - Phase: Phase 1.
  - Boundary: pre-fix.
  - Lane: discovery.
  - Required next action: diagnose the finding cluster and select repair
    altitude before any fix.
- Trigger: after multiple substantive review/fix iterations, a fresh discovery
  pass found two new P1s and two sibling P2s whose labels or attestations are
  not mechanically bound to the exact operation/artifact they claim to prove.
- Evidence clusters:
  - custom reviewer output is labeled as native review evidence;
  - completed gate runs can be attached to a different candidate/plan;
  - pre-review implementer prose is presented as the final candidate summary;
  - synchronous process replacement is presented as detached execution.
- Diagnosis: pending.
- Action: pending combined convergence diagnosis and repair-altitude selection.
- Status: open.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 16 convergence diagnosis and action

- Diagnosis: `local-design-flaw` — evidence-to-claim binding (high
  confidence). Each current flow can assert a stronger claim than its producing
  operation proves: custom turn as native review, current run as exact consumed
  artifact, pre-review prose as final-candidate summary, and presentation
  replacement as detached execution.
- Relationship to the prior checkpoint: distinct from Epoch 15
  current-lineage enforcement. Epoch 15 rejected historical-but-related state
  as current authority; this cluster fails to bind a current claim to its exact
  producer, immutable input, or time window. It is not a repeated occurrence
  of the same root and does not require user escalation.
- Independent corroboration: a second history-blind discovery pass confirmed
  E16-CR-005 and classified the stale final-candidate summary as blocking. It
  found buffered old-generation input correctly fenced and reported no other
  distinct issue. E16-CR-005 severity is therefore upgraded to blocking.
- Repair altitude and action:
  - E16-CR-003: narrow architecture-boundary repair using the installed App
    Server's actual `review/start` with the exact commit target on a pre-bound
    fresh read-only thread; preserve raw native output, then use a candidate-
    bound typed primary projection only if ledger-schema conversion is needed.
  - E16-CR-004: one shared consumed-artifact context-envelope invariant for
    plan/candidate gate runs, checked by review, validation, and closure result
    recording.
  - E16-CR-005: one persisted primary integration synthesis after final review,
    validation, and closure over the exact intent, plan, final candidate diff,
    findings, and gate evidence; the proposal must bind the exact model call and
    output fields it renders.
  - E16-CR-006: split detach and reattach; execute the already-planned
    replacement implementer inflection/checkpoint while no presentation is
    attached, then reattach from that durable progress.
- No generic proof system, Python semantic parser, replacement proposal,
  recovery framework, dummy work, new role, product decision, or semantic plan
  amendment is permitted by this action.
- Status: actioned. The four bounded repairs and tests may proceed; afterwards
  start a new review epoch at counter zero and restart Code Review Phase 1.
  The checkpoint resolves only after the restarted Phase 3 discovery gate is
  clean.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 16 evidence-to-claim repair status

- E16-CR-003 fix applied: the candidate hard-review path now invokes App
  Server `review/start` against the exact candidate commit on the run-owned
  read-only thread. The raw completed inline turn is persisted, and the
  primary's typed projection is mechanically bound to that raw result, its
  native request identity, physical owner, and candidate identity.
- E16-CR-004 fix applied: plan and candidate gate runs carry one exact
  `consumed_artifact` envelope. Review, validation, and closure recording reject
  a completed run whose envelope does not equal the durable artifact being
  credited.
- E16-CR-005 fix applied: the primary creates the integration summary only
  after final review, validation, and closure from the exact final candidate
  diff and durable gate evidence. The proposal binds that model call, its exact
  candidate context, and every rendered semantic field.
- E16-CR-006 fix applied: presentation detach and reattach are separate. The
  replacement implementer's constraint-inflection turn and durable checkpoint
  execute while presentation is detached, before a fresh stock CLI attaches.
- Negative coverage rejects a wrong native review commit, a wrong consumed
  plan/candidate, stale integration-summary fields, and the wrong completion
  thread for `review/start`. Narrative tracing proves detached work precedes
  reattachment and final synthesis consumes the replacement candidate.
- Lifecycle: E16-CR-003 through E16-CR-006 actioned; targeted verification
  pending.
- Validation: 141 unittest tests pass with one expected outer-sandbox-only
  skip; 140 pytest tests pass with the same skip. Python compilation, Go
  transport tests, Bash syntax for all four launch scripts, shellcheck warning
  gate, and staged/unstaged `git diff --check` are clean.
- Continuation token: targeted verification of E16-CR-003 through E16-CR-006,
  then start review epoch 17 at counter zero with a fresh holistic Phase 1
  discovery pass.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 16 targeted evidence-binding verification

- E16-CR-003 CLOSED: the actual App Server `review/start` request, completed
  inline turn, run-owned physical thread, exact candidate target, raw hash, and
  primary typed projection form one mechanically checked provenance chain.
- E16-CR-004 CLOSED: the shared consumed-artifact predicate derives the exact
  durable plan or candidate envelope and is applied by review, validation, and
  closure recording; mismatched envelopes are rejected.
- E16-CR-005 CLOSED: integration synthesis occurs after final candidate gates
  over the exact candidate diff and candidate-filtered durable evidence, and
  proposal currentness binds its model call and all rendered fields.
- E16-CR-006 CLOSED: the replacement implementer performs its accepted
  constraint-inflection turn and persists a checkpoint after detach completes
  and before reattachment begins.
- Six focused tests passed for exact native completion/request shape, artifact
  misbinding, final-candidate summary binding, and detached-work ordering.
- No directly spawned P1, P2, or P3 finding was found.
- Lifecycle: E16-CR-003 through E16-CR-006 resolved by targeted verification.
- Epoch transition: review epoch 17 starts at counter zero with a fresh
  history-blind holistic Phase 1 discovery pass. The Epoch 16 convergence
  checkpoint remains actioned until the restarted Phase 3 gate is clean.
- No live Codex PoC run, commit, or integration was performed.

### E17-CR-001 — Typed model output ignores terminal turn status

- Review epoch / iteration: 17 / Phase 1.1 holistic discovery.
- Severity / scope: blocking / in-scope.
- Source: fresh history-blind delegated `code-review-analyst` discovery pass.
- Location: `ControllerModelRuntime.call` in `poc/prototype.py`.
- Statement: after exact turn completion and `thread/read`, the runtime extracts
  parseable output without requiring either terminal representation to report
  `status=completed`. A failed or cancelled turn with schema-valid output can be
  persisted as a successful primary, reviewer, or semantic-verifier result.
- Suspected surface: terminal model-result admission.
- Fix applied: none.
- Lifecycle: open.

### E17-CR-002 — Primary projection owns the native-review verdict

- Review epoch / iteration: 17 / Phase 1.1 holistic discovery.
- Severity / scope: significant / in-scope.
- Source: fresh history-blind delegated `code-review-analyst` discovery pass.
- Location: native candidate review in `poc/prototype.py` and its provenance
  checks in `poc/kernel.py`.
- Statement: the raw native review is exact, but a later primary projection
  supplies the authoritative structured verdict. The primary can omit or
  contradict a native finding while still satisfying the raw-consumption
  provenance checks.
- Suspected surface: semantic ownership of native-review findings.
- Fix applied: none.
- Lifecycle: open.

### E17-CR-003 — Candidate controls its final validation oracles

- Review epoch / iteration: 17 / Phase 1.1 holistic discovery.
- Severity / scope: significant / in-scope.
- Source: fresh history-blind delegated `code-review-analyst` discovery pass.
- Location: `WorkflowEngine.validate_and_close` in `poc/prototype.py`.
- Statement: final validation executes `candidate_contract.py`,
  `memory_gate.py`, and `naive_in_memory.py` from the candidate checkout without
  proving their baseline identities. A candidate can weaken an oracle and make
  an incorrect program appear clean.
- Suspected surface: trusted validation-input boundary.
- Fix applied: none.
- Lifecycle: open.

### Epoch 17 convergence checkpoint — trusted producer boundaries

- Review epoch: 17.
- Triggered at: Phase 1.1 fresh holistic discovery, before fixing E17-CR-001
  through E17-CR-003.
- Continuation:
  - Phase: Phase 1.
  - Boundary: pre-fix.
  - Lane: discovery.
  - Required next action: run a combined resolution challenge and determine
    whether this repeats the prior evidence-to-claim root before any patch.
- Trigger: a restarted fresh pass found three substantive sites where an
  authoritative claim may be admitted from a failed, semantically wrong, or
  candidate-controlled producer.
- Evidence clusters:
  - parseable model output can outrank failed/cancelled terminal status;
  - primary semantic projection can replace the native reviewer's verdict; and
  - mutable candidate files can define the validation oracle that judges them.
- Diagnosis: pending.
- Action: pending combined convergence diagnosis and repair-altitude selection.
- Status: open.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 17 convergence diagnosis and action

- Diagnosis: `local-design-flaw` — authoritative-evidence admissibility /
  trusted-producer boundary (high confidence).
- Relationship to Epoch 16: deeper sibling invariant, not a repeated
  evidence-to-claim binding failure. Epoch 16 proves exact provenance; Epoch 17
  requires the exactly identified producer and result also to be eligible
  authority. The prior bindings remain valid.
- Selected repair altitude:
  - E17-CR-001: implementation-level fail-closed admission requiring both the
    exact terminal notification and exact `thread/read` turn to be completed
    before typed output is parsed or persisted;
  - E17-CR-002: narrow existing-ownership correction moving the typed native
    projection from the primary to the exact run-owned native-review thread,
    while preserving the raw native output; and
  - E17-CR-003: implementation-level attempt-base blob equality for exactly the
    three exercised validation oracles before validation starts.
- No generic evidence or oracle framework, external validation harness,
  independent native co-signer, new role/state/lifecycle, product decision,
  scope change, or semantic plan amendment is permitted by this action.
- Required negative tests: failed/cancelled typed turns; wrong-owner native
  projection; and changed/deleted validation oracles blocking before command
  execution or clean validation credit.
- Status: actioned. Only these three bounded repairs and their validation,
  targeted verification, and Epoch 18 review restart may proceed.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 17 trusted-producer repair status

- E17-CR-001 fix applied: controller-backed model calls now admit output only
  after the exact `turn/completed` notification and the exact `thread/read`
  turn both identify the requested thread/turn and report `status=completed`.
  Failed or cancelled turns stop before typed-output persistence. Native review
  capture uses the same predicate.
- E17-CR-002 fix applied: the schema-constrained native-review projection now
  runs on the same pre-bound native-review App Server thread and durable run as
  `review/start`. The primary no longer authors that verdict. Kernel admission
  binds the call's native role/run, raw input, candidate, output, and completed
  run outcome; primary ownership is rejected.
- E17-CR-003 fix applied: before creating a validation checkout or run, the
  candidate blobs for `candidate_contract.py`, `memory_gate.py`, and
  `naive_in_memory.py` must equal their attempt-base blobs. Change or deletion
  pauses before any validation command or clean result can be credited.
- Negative coverage exercises parseable failed/cancelled model turns,
  primary-owned native projection, changed/deleted oracle files, and the
  no-checkout/no-command oracle-rejection boundary. A candidate changing only
  `normalize_values.py` remains eligible for validation.
- Lifecycle: E17-CR-001 through E17-CR-003 actioned; targeted verification
  pending.
- Validation: 143 unittest tests pass with one expected outer-sandbox-only
  skip; 142 pytest tests pass with the same skip. Python compilation, Go
  transport tests, Bash syntax for all four launch scripts, shellcheck warning
  gate, and staged/unstaged `git diff --check` are clean.
- Continuation token: targeted verification of E17-CR-001 through E17-CR-003,
  then start review epoch 18 at counter zero with a fresh holistic Phase 1
  discovery pass.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 17 targeted trusted-producer verification

- E17-CR-001 CLOSED: ordinary, semantic-verifier, native-review, and native
  projection outputs require completed status in both exact terminal
  representations; parseable failed/cancelled output is rejected.
- E17-CR-002 CLOSED: the same durable native run/thread owns the structured
  projection, and the kernel rejects a primary-owned forged projection.
- E17-CR-003 CLOSED: all three bounded oracle blobs are compared with the exact
  attempt base before checkout, validator-run registration, or command
  execution; change/deletion blocks and a program-only candidate remains
  eligible.
- Four focused verification tests passed. No directly spawned P1, P2, or P3
  finding was found.
- Lifecycle: E17-CR-001 through E17-CR-003 resolved by targeted verification.
- Epoch transition: review epoch 18 starts at counter zero with a fresh
  history-blind holistic Phase 1 discovery pass. The Epoch 17 convergence
  checkpoint remains actioned until the restarted Phase 3 gate is clean.
- No live Codex PoC run, commit, or integration was performed.

### E18-CR-001 — Agent outputs advance without accountable primary acceptance

- Review epoch / iteration: 18 / Phase 1.1 holistic discovery.
- Severity / scope: blocking / in-scope.
- Source: fresh history-blind delegated `code-review-analyst` discovery pass.
- Location: `WorkflowEngine.run_role`, plan advancement, and
  `DurableKernel.complete_run`.
- Statement: agent results are completed with caller-default
  `accepted_by=primary`, and clean plan/review outputs advance mechanically,
  without any exact primary model turn accepting the agent output.
- Suspected surface: accountable semantic acceptance of delegated output.
- Fix applied: none.
- Lifecycle: open.

### E18-CR-002 — Plan review has no findings convergence path

- Review epoch / iteration: 18 / Phase 1.1 holistic discovery.
- Severity / scope: significant / in-scope.
- Source: fresh history-blind delegated `code-review-analyst` discovery pass.
- Location: `WorkflowEngine.plan_and_review` in `poc/prototype.py`.
- Statement: any soundness or red-team finding stops the workflow. There is no
  primary disposition, planner revision, immutable replacement plan version,
  or affected re-review, despite plan convergence being an accepted behavior.
- Suspected surface: bounded plan-review convergence.
- Fix applied: none.
- Lifecycle: open.

### E18-CR-003 — Final ITD disposition lacks exact authority binding

- Review epoch / iteration: 18 / Phase 1.1 holistic discovery.
- Severity / scope: significant / in-scope.
- Source: fresh history-blind delegated `code-review-analyst` discovery pass.
- Location: `WorkflowEngine.integrate_candidate_and_record_itd` and
  `DurableKernel.record_itd`.
- Statement: the ITD row accepts caller-supplied decision/disposition/evidence
  without binding the exact primary interpretation call, verbatim response,
  integrated candidate/effect, or evidence identity.
- Suspected surface: durable architecture-decision authority.
- Fix applied: none.
- Lifecycle: open.

### Epoch 18 convergence checkpoint — semantic authority closure

- Review epoch: 18.
- Triggered at: Phase 1.1 fresh holistic discovery, before fixing E18-CR-001
  through E18-CR-003.
- Continuation:
  - Phase: Phase 1.
  - Boundary: pre-fix.
  - Lane: discovery.
  - Required next action: combined resolution challenge before any patch.
- Trigger: a second restarted pass found delegated-output and user-decision
  transitions whose durable labels or advancement do not carry the exact
  accountable semantic authority, plus a missing required plan convergence
  branch.
- Evidence clusters:
  - caller code labels delegated run results as primary-accepted;
  - clean-first-pass plan outputs advance and findings have no revision path;
  - caller fields become a final ITD without exact interpretation/effect
    verification.
- Diagnosis: pending.
- Action: pending combined convergence diagnosis, relationship to Epoch 17,
  and repair-altitude selection.
- Status: open.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 18 convergence diagnosis — user authorization required

- Diagnosis: `local-design-flaw` — end-to-end semantic-authority closure (high
  confidence).
- Relationship to prior checkpoints: Epoch 16 exact provenance and Epoch 17
  trusted-producer admissibility are valid partial layers. Epoch 18 exposes the
  missing accountable adoption/disposition link in the same overarching chain:
  exact producer -> eligible result -> accountable primary adoption -> permitted
  transition -> exact durable user decision.
- This sibling P1 appeared after another convergence-directed restart. The
  review-loop cap therefore requires user-facing escalation before another fix;
  it is not permission to continue patching silently.
- Recommended bounded architecture clarification:
  - ordinary agent-owned outcomes require a primary typed acceptance call bound
    to the exact producer call/run/output; controller validation and independent
    semantic co-sign remain explicit exceptions;
  - plan findings remain in review JSON and receive one bound primary synthesis,
    then a fresh planner creates immutable version N+1 and both lenses re-review;
    no first-class plan-finding table; and
  - final ITD fields/evidence are derived from the exact primary interpretation
    call and exact completed integration effect/candidate/tree, not caller fields
    or the later presentation report.
- Required product semantics do not change, but the cross-boundary authority
  chain must be made explicit in `poc/PLAN.md`, re-reviewed with mandatory user
  review, then implemented and restarted at Code Review epoch 19.
- User authorization: on 2026-08-06 the user chose Option 1: freeze local
  patching, create one bounded end-to-end authority-transition inventory,
  clarify `poc/PLAN.md`, and run the mandatory Plan Review before considering
  implementation.
- Authorized scope: planning artifacts and Plan Review only. Implementation of
  the clarification remains blocked until the reviewed plan returns for the
  user's mandatory review and approval.
- Status: actioned. No implementation repair has been applied.
- No live Codex PoC run, commit, or integration was performed.

### Epoch 18 architecture Plan Review — Phase 1 iteration 1

- Artifact: revised `poc/PLAN.md` with one closed authority-transition
  inventory; implementation remained untouched.
- Independent soundness findings:
  - blocking: in-run checkpoints/asks/inflection reports were incorrectly
    covered by terminal role-result eligibility;
  - blocking: plan synthesis did not exhaustively disposition embedded findings
    and the revision bound was unspecified;
  - significant: maximum-work-budget cadence was unspecified; and
  - significant: the site list retained two absent assertion files and omitted
    the actual validation-sandbox helper/test.
- Independent adversarial findings:
  - blocking: a newer user correction while positive interpretation was pending
    did not revoke the earlier response before a restart/integration effect; and
  - significant: planned owner replacement lacked a distinct exact primary
    handoff decision.
- Synthesis and applied plan-only corrections:
  - separate exact active-run reports from terminal role outcomes;
  - require primary synthesis to disposition every embedded finding and review
    version zero plus at most two immutable replacements;
  - use a one-agent-turn maximum work budget between assignment/direction and a
    terminal outcome or durable report;
  - serialize a response approval epoch with user input through effect start so
    newer input invalidates pending positive authority;
  - require exact typed primary `handoff` authority; and
  - correct the validation sandbox site list.
- Continuation: fresh holistic soundness and adversarial review of the entire
  corrected plan, followed by minimization only after clean Phase 1 convergence.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 architecture Plan Review — Phase 1 iteration 2

- Fresh holistic soundness review remained RED on two blocking boundaries:
  assignment/start lacked exact delegation authority before the first agent
  turn, and raw native `review/start` output versus its structured projection
  had no chosen authoritative finding representation/completeness rule.
- Fresh adversarial review found no blocking scenario and four significant
  in-scope gaps: non-actionable plan findings could exhaust the revision loop;
  the same native projection ambiguity; post-terminal same-run revision was
  contradictory; and a closure-driven plan change did not invalidate/rebuild
  plan-bound candidate gates.
- Synthesis and applied plan-only corrections:
  - every agent assignment binds exact typed primary delegation or an exact
    accepted transition that mandates the fixed reviewer/verifier role before
    its first turn;
  - one native run owns raw stock discovery and a same-thread structured terminal
    finding set with exact raw anchors; primary adoption consumes both and must
    affirm no material raw finding is unmapped;
  - only unresolved actionable in-scope findings or accepted scope change force
    plan N+1; all embedded findings still receive durable routed disposition;
  - post-terminal revision always uses a distinct linked run; and
  - accepted closure-driven plan change invalidates the prior plan/candidate
    lineage, binds a fresh candidate instance, and reruns all candidate gates.
- Continuation: third and final allowed Phase 1 holistic review pass on the
  complete plan. Any remaining blocking in-scope finding returns to the user
  rather than another automatic review/fix loop.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 architecture Plan Review — Phase 1 iteration 3 cap

- Both fresh reviewers independently found the same two remaining blocking
  in-scope contradictions:
  - the universal one-turn agent work budget blocks the mandatory second native
    projection turn because raw `review/start` is not currently an eligible
    in-run report; and
  - the global version-zero-plus-two-replacements limit does not define what
    happens when implementation closure accepts a plan correction after plan
    version two.
- Adversarial severity for the second item was significant, while the structured
  reviewer marked it blocking; synthesis retains blocking because the current
  text has no valid closed transition at that boundary.
- Phase 1 reached its maximum three passes with blocking findings. No further
  automatic plan edit is permitted; the findings return to the user one
  decision at a time.
- Phase 2 minimization and the green closure receipt were not run/issued.
- Current status: Plan Review unresolved; implementation remains blocked.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 Plan Review cap — user disposition 1

- Decision: the user approved Option 2 for native finding structuring.
- Accepted shape:
  - run one direct `codex review --commit` discovery against the exact candidate
    and preserve its exact process target/status/stdout/stderr;
  - invoke the shared tool-less subagent/model runner as a distinct one-turn
    stateless NLP adapter, using a configurable faster/lower-effort model, to
    convert the complete raw review into the common finding schema;
  - require exact raw anchors, mechanical schema/anchor/identity checks, and
    primary completeness/adoption over both artifacts; and
  - keep the adapter non-authoritative and fail closed on command, model,
    schema, anchor, mapping, or adoption failure.
- Effect on the first capped finding: actioned in the plan. The native review
  process and structuring subagent are separate terminal invocations, so neither
  requires an unmediated second turn and both comply with the one-turn budget.
- Remaining user decision: behavior when closure accepts a plan correction after
  the global version-zero-plus-two-replacements limit has already been consumed.
- Plan Review remains unresolved; verification/minimization have not resumed.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 Plan Review cap — user correction 2

- Correction: `plan-review-limit` was the wrong concept and name. The intended
  state is `plan-review-auto-iteration-limit`.
- Accepted semantics:
  - plan versions are monotonic and may continue for as many revisions as the
    work requires;
  - after every three consecutive automatically generated/reviewed versions,
    the system preserves the open lineage and pulls in the user before another
    version or implementation;
  - exact user direction resets only the automatic-iteration counter, not plan
    numbering or history; and
  - implementation starts or resumes only from the exact final plan version
    closed by both reviews, exhaustive primary synthesis, and acceptance.
- Closure consequence: if closure accepts a correction after v2, the system
  pulls in the user, then creates and reviews v3. The prior v2 candidate/gates
  remain invalid, and implementation starts/resumes only from closed v3 before
  all candidate-bound gates rerun.
- Effect on the second capped finding: actioned in the plan. There is no global
  maximum plan version and therefore no closure-at-v2 dead end.
- Both iteration-3 blocking findings now have user-settled plan corrections;
  fresh verification is required before Phase 1 can converge or minimization can
  run.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 corrected-cap verification

- Fresh soundness verification found one blocking in-scope authority gap: the
  auto-iteration checkpoint required user direction but did not define how the
  verbatim response becomes an exact current typed transition. A qualified
  response such as “go ahead, but preserve X” could therefore be mistaken for
  permission to implement the prior closed plan.
- Fresh adversarial verification found two significant in-scope gaps:
  - a reviewer-proposed material scope change could reach N+1 without exact user
    authority and a durable revised intent/scope; and
  - physical-primary replacement has no closed rebind transition even though
    broader continuity language may imply one.
- The first soundness finding and scope-change finding share the same missing
  checkpoint authority boundary. Physical-primary continuity remains a separate
  plan-review finding to disposition after this correction.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 plan auto-iteration checkpoint — user disposition 3

- Decision: the user approved Option 3, primary interpretation plus independent
  verification only for the positive implementation-start outcome.
- Accepted contract:
  - present one exact checkpoint bound to current intent/scope, complete plan
    lineage, review synthesis, automatic count, exact closed plan when present,
    and proposed next action;
  - have the accountable primary interpret the verbatim response as only
    `proceed_closed_plan`, `revise_next_version`, `pause_or_clarify`, or explicit
    `abandon`;
  - independently verify only `proceed_closed_plan` with the shared tool-less
    lightweight semantic runner;
  - keep all natural-language interpretation out of Python/controller code;
    mechanically validate schema, exact identities, currentness, and required
    primary/verifier agreement; and
  - treat qualified approval as revision, persist any user-authorized revised
    intent/scope before N+1, and reset the auto counter only for an actionable
    current proceed/revise outcome.
- Effect: the soundness checkpoint gap and the adversarial scope-change gap are
  actioned in the plan. Physical-primary continuity remains unresolved.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 physical-primary continuity — user disposition 4

- Clarification: a physical-primary session loss must not leave the work stopped
  or require the user to operate recovery. “Authority transfer” was rejected as
  misleading because the accountable logical primary does not change.
- Decision: the user approved Option 3, stable logical primary plus automatic
  physical-session rebind.
- Accepted contract:
  - controller records one current physical-thread binding epoch for the stable
    logical primary;
  - on proven unavailability or deliberate replacement, fence the old thread,
    create one fresh candidate thread, and send an exact ledger-derived re-prime
    packet;
  - require `primary_reprime_ack` bound to the logical primary, old/new threads,
    packet, current work, and dependency identities before installing the new
    binding epoch;
  - persist user input during the transition, allow genuinely independent agent
    work to continue, and temporarily hold only transitions needing a primary
    decision; and
  - after binding, automatically deliver queued input and resume dependent work.
- Scope boundary: this proves one bounded planned physical-primary replacement,
  not controller/database crash recovery, hostile-client fencing, or general
  automatic reconciliation.
- Effect: the remaining fresh adversarial continuity finding is actioned in the
  plan. Fresh holistic verification is still required before Plan Review can
  converge.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 fresh holistic verification after user dispositions 3–4

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete current `poc/PLAN.md`. Neither reviewer received or read this ledger,
  prior findings, diagnoses, or claimed fixes.
- Structured reviewer verdict: RED.
  - `blocking × in-scope`: the plan requires a fresh candidate instance when a
    new closed plan reuses the same Git commit/tree, but does not define an
    instance identity separate from `candidate_sha` or bind all downstream
    gates/effects to it.
  - `blocking × in-scope`: invalid re-prime acknowledgement or replacement
    provisioning failure enters an unbounded fresh-candidate retry lifecycle,
    contradicting the bounded rebind and generic no-automatic-retry scope.
  - `significant × in-scope`: independent confirmation for
    `proceed_closed_plan` is accepted by the user but not yet propagated through
    the verifier decision, proposal kinds, assignment/storage, and tests.
  - `significant × in-scope`: the plan checkpoint does not yet reuse an exact
    completed-render/input boundary across detach and primary rebind.
- Adversarial reviewer verdict: RED FLAG.
  - `blocking × in-scope`, convergent with the structured reviewer: repeated
    provisioning/acknowledgement failure can churn candidate threads forever,
    accumulate queued input, and never reach a visible terminal waiting state.
  - `significant × in-scope`: after the third unclosed version, ordinary user
    direction to continue resolving already-durable findings is not an explicit
    legal `revise_next_version` case unless a new constraint is invented.
  - `significant × in-scope`: a newer durable user turn during rebind does not
    explicitly revoke an earlier plan-checkpoint response before its transition.
  - `significant × in-scope`: involuntary loss during an admitted but incomplete
    primary turn has no transition-specific reissue rule.
  - `significant × in-scope`: a proportional live review may close before three
    versions, so the checkpoint cannot be guaranteed in the live narrative
    without manufacturing findings; deterministic composition evidence should
    carry that conditional branch instead.
- Synthesis:
  - the unbounded rebind-failure lifecycle is one convergent blocking finding;
  - candidate-instance versus Git-artifact identity is a separate blocking
    finding that predates the rebind correction but was exposed by this fresh
    holistic pass;
  - all significant findings remain open and durable; several are direct
    contract-propagation corrections once their parent blocking behavior is
    selected; and
  - Plan Review remains unresolved. No closure receipt may be issued and
    implementation remains blocked.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 bounded rebind failure — user disposition 5

- Decision: the user approved Option 2, initial replacement candidate plus one
  automatic retry, followed by visible `rebind_failed` rather than an unbounded
  retry loop.
- Accepted contract:
  - each candidate attempt has a finite prototype App Server operation deadline;
  - a failed, timed-out, or invalid candidate is durably retired and fenced
    before the sole retry is provisioned, and every late output is rejected;
  - ordered queued input, durable work, and agent evidence remain preserved;
  - genuinely independent agents may continue while primary-dependent work
    waits; and
  - failure of candidate two records `rebind_failed`, emits the compact recovery
    summary, and performs no third automatic attempt.
- Effect: the convergent blocking rebind-lifecycle finding is actioned in the
  plan. Candidate-instance versus Git-artifact identity remains the next
  separate blocking finding.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 closure plan-change candidate identity — user correction 6

- Correction: the same Git commit should never need a special fresh-candidate
  identity merely because the accepted implementation plan changed.
- Accepted invariant:
  - an implementation-affecting plan change necessarily carries a concrete code
    delta;
  - after the replacement plan closes, the implementer applies that delta and
    the ordinary complete candidate-construction process creates a new commit;
  - standard candidate reviews, validation, and closure then run on that new
    commit; and
  - if no implementation delta is warranted, the finding is a non-superseding
    clarification rather than an implementation plan change. It cannot create a
    same-commit candidate exception.
- Resolution: reject the reviewer's proposed separate candidate-instance
  identity because it solves a plan-invented special case. Git commit identity
  remains the candidate identity, and the existing candidate lifecycle remains
  sufficient.
- Effect: the blocking candidate-instance-versus-Git-artifact finding is
  actioned by removing its false premise rather than expanding durable schema.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 in-flight primary input continuity — user disposition 7

- Decision: the user approved Option 2, automatic single reissue of an admitted
  user input when the old primary is lost before producing a durable typed
  result.
- Accepted contract:
  - persist the exact user-input and incomplete old-call identities as
    `pending_reissue`;
  - after successful physical-primary rebind, submit that same input identity
    exactly once under a distinct linked call before later queued inputs;
  - keep every fenced old-thread late result ineligible and prevent old/new
    results from both advancing state;
  - preserve input order across rebind; and
  - require any older consequential interpretation to remain the newest admitted
    user turn at its serialized transition boundary, so a durable later
    correction or wait instruction wins.
- Effect: the adversarial in-flight-turn-cut finding and its newer-input rebind
  composition are actioned in the plan without adding general replay behavior.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 conditional checkpoint evidence — primary disposition 8

- Correction to orchestration: whether to manufacture three plan versions in
  the live run was a technical evidence-placement choice, not a user product or
  architecture decision. Escalating it as another interview question was
  unnecessary and caused conversational drift.
- Primary disposition:
  - keep the live coding/review run honest and proportional; never manufacture
    findings or prevent legitimate early plan closure;
  - prove the three-version checkpoint and all negative/composed branches with
    deterministic transition tests;
  - exercise the checkpoint live only if three versions are naturally reached;
  - propagate the already user-approved `proceed_closed_plan` independent check
    through Decision 1, verifier proposal kinds/schema/assignment/storage/tests;
    and
  - reuse the completed-render/presentation boundary for checkpoint input,
    including detach, unchanged-presentation rebind, and newer-turn revocation.
- Effect: all remaining significant findings from the fresh holistic review are
  actioned at plan altitude without a new user decision. A fresh holistic review
  is required before convergence.
- Process learning: derived test placement, schema propagation, and reuse of an
  already accepted authority primitive remain primary-owned technical choices;
  only a genuine product, requirement, scope, or material architecture choice is
  returned to the user.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 Plan Review convergence checkpoint 2

- Status: `actioned`.
- Trigger: after another holistic review, four structured blocking findings and
  one adversarial blocking scenario appeared in sibling authority/lifecycle
  surfaces despite prior local corrections.
- Continuation: fresh holistic Plan Review after the architectural correction.
- Evidence cluster:
  - closed-plan implementation start exists only inside the three-version pacing
    checkpoint, leaving early plan closure without the promised user authority;
  - replacement-primary binding is specified but initial-primary binding is not;
  - `rebind_failed` requires a primary-authored attention summary when no primary
    is eligible;
  - response eligibility is repeated inconsistently across intent, plan,
    restart, integration, and final-ITD decisions;
  - a re-prime packet has no stable ledger frontier/catch-up rule while
    independent agents continue; and
  - wildcard sites obscure the exact owners of these sibling behaviors.
- Diagnosis: `local-design-flaw` with high confidence.
- Root: the plan models primary continuity and user-decision eligibility as
  transition-local special cases. Every local correction therefore creates or
  exposes another sibling default. The issue is not missing user product
  intent; accepted behavior is already clear.
- Repair altitude: architecture.
- Selected action: replace the repeated local machinery with exactly two bounded
  shared protocols:
  - primary binding/continuity, covering initial activation, physical rebind,
    ledger frontier and ordered catch-up, in-flight input, bounded failure, and
    mechanical no-primary fallback; and
  - user decision envelope, covering completed render, exact response/input
    sequence, detach/rebind, newest-turn invalidation, typed primary
    interpretation, optional positive verifier, and permitted transition.
- Semantic-surface disposition: this consolidates existing accepted state and
  invariants; it does not introduce a generic authorization/recovery framework
  or new user-visible behavior. Transition rows supply only their kind-specific
  payload and effect.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 shared-protocol architecture correction — primary disposition 9

- Status: `actioned`; fresh holistic verification pending.
- Applied the selected architecture repair as two bounded shared contracts rather
  than another set of transition-local patches.
- Primary binding/continuity now covers:
  - initial physical-primary activation as well as replacement;
  - packet frontier `F`, ordered catch-up through captured frontier `G`, and
    decision eligibility only after both re-prime and catch-up acknowledgements;
  - independent durable agent/reviewer results appended between `F` and `G`;
  - admitted in-flight input, exactly-once linked reissue, queue order, and
    newer-turn invalidation;
  - initial candidate plus one automatic retry for each activation/rebind episode;
    and
  - `primary_start_failed`/`rebind_failed` with a fixed, explicitly non-semantic
    controller status when no primary can author the ordinary attention summary.
- User decision envelopes now cover direct initial intake and every presented
  response kind: revised intent, plan pacing checkpoint, mandatory final closed-
  plan authorization, restart, integration, explicit abandonment, and final ITD.
  The common rule owns completed render, response admission, detach/presentation
  replacement, rebind before versus after admission, pending reissue, newest-turn
  invalidation, typed primary interpretation, and optional positive verifier.
- Closed-plan authority is no longer conditional on reaching three versions:
  every closed plan requires mandatory user review and independently affirmed
  `proceed_closed_plan` before implementation. When closure and the pacing
  checkpoint coincide, one exact envelope may serve both.
- Replaced wildcard plan sites with exact kernel/controller/prototype functions,
  role files, and test files that own these behaviors.
- Updated grounded requirements, transition inventory, acceptance narrative,
  work plan, site list, temporal ordering, ownership, and deliberate composition
  cases consistently.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 fresh holistic verification after shared-protocol correction

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete current `poc/PLAN.md`; neither received or read this ledger or prior
  findings.
- Structured reviewer verdict: RED.
  - `blocking × in-scope`: a response with a durable typed primary interpretation
    can become stranded if physical rebind occurs before verifier/effect
    completion because only the no-result case has a pending-reissue rule.
  - `blocking × in-scope`: closure-driven plan N+1 is described as resuming
    implementation after closure, bypassing the new mandatory final closed-plan
    user authorization.
  - `significant × in-scope`: role and fixture sites remain partly categorical or
    wildcarded instead of exact files.
- Adversarial reviewer verdict: RED FLAG.
  - `blocking × in-scope`: `primary_start_failed` / `rebind_failed` have a fixed
    status but no mechanically reachable fresh activation episode.
  - `blocking × in-scope`: failure of the single automatic pending-input reissue
    has no durable resolution and can block later queued turns permanently.
  - `significant × in-scope`: a one-model-turn budget does not bound work inside
    an agentic turn and therefore does not fulfill the PM-style maximum-work
    checkpoint requirement.
- Convergence assessment: the two shared protocols remain the correct repair
  altitude. The fresh findings expose missing lifetime/failure transitions inside
  those protocols plus two local propagation/site corrections; they do not point
  to another product decision or generic recovery framework.
- Selected primary-owned correction:
  - make an eligible durable primary interpretation survive physical rebind based
    on logical-primary and subject/input currentness, while verifier/effect waits
    for catch-up and newest-input checks;
  - route every replacement closed plan through ordinary final user authorization;
  - add one explicit non-semantic manual `activate_primary` action that opens a
    fresh bounded episode from either no-primary failure state;
  - terminalize a failed automatic input reissue as `reissue_failed`, unblock
    later turns, and allow only a distinct user/primary-directed retry or explicit
    supersession;
  - add a fixed controller-observable in-turn work quantum alongside the existing
    one-turn bound; and
  - enumerate exact role and fixture files.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 shared-protocol negative-path closure — primary disposition 10

- Status: `actioned`; fresh holistic verification pending.
- Durable typed primary interpretations now belong to the stable logical primary
  after eligibility is recorded. Physical rebind remains provenance and does not
  alone expire them; pending verifier/effect work waits for catch-up, ordered
  input admission, and exact subject/state/newest-turn revalidation. The existing
  pending-reissue path remains exclusive to the no-durable-result case.
- Every closure-driven replacement plan N+1 now passes through the same mandatory
  final closed-plan user envelope and independently affirmed
  `proceed_closed_plan` before any implementation resumes.
- No-primary failure states now expose one separately encoded, non-text
  `activate_primary` control. Its deliberate invocation opens a distinct bounded
  activation episode without interpreting/consuming queued prose or erasing the
  failed episode; natural-text-only input cannot trigger it.
- The sole automatic pending-input reissue now terminalizes failure as
  `reissue_failed`, preserves the original input/call provenance, closes automatic
  eligibility, and admits later queued input. Any retry/supersession is a distinct
  fresh typed user/primary direction.
- The PM-style budget now has a real in-turn bound in addition to one-turn
  continuation: six completed action items or five active minutes. At the first
  frontier, the controller records exact identities, requests `turn/interrupt`,
  rejects terminal adoption from that turn, obtains one tool-less schema
  checkpoint on the same run/thread, and waits for primary direction.
- Current installed Codex App Server capability was checked read-only by
  generating its experimental JSON schema under `/tmp`; the schema includes
  `item/completed` notifications and the `turn/interrupt` client request used by
  this bounded design.
- Site lists now enumerate every affected workflow role and fixture file rather
  than leaving implementation-time wildcards.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 second fresh holistic verification

- Dispatch: second fresh independent `rfc-reviewer` and `rfc-red-team` passes over
  the complete revised `poc/PLAN.md`, again without this ledger, prior findings,
  or implementation diff.
- Structured reviewer verdict: RED.
  - `blocking × in-scope`, convergent with the adversarial pass: durably admitted
    but not yet outbound-dispatch-journaled input has neither ordinary queued
    delivery nor `pending_reissue` ownership at physical-primary loss.
  - `blocking × in-scope`: packet frontiers are not yet founded on one global
    transactional sequence covering every packet-relevant durable mutation.
- Adversarial reviewer verdict: RED FLAG.
  - `blocking × in-scope`, same admitted-input cut point as above.
  - `significant × in-scope`: work-budget `turn/interrupt` does not yet prove the
    interrupted turn and every active action are terminal before checkpointing,
    handoff, or worktree reuse.
- Convergence assessment: the admitted-input finding is one convergent boundary
  bug; the ledger-sequence and quiescence findings are supporting mechanical
  invariants. The two shared protocol shapes remain sound and no product,
  requirement, scope, or material architecture decision is missing.
- Selected primary-owned correction:
  - assign every durable controller mutation one monotonic `ledger_seq` in the
    same SQLite transaction and derive packet/delta frontiers exclusively from it;
  - distinguish admitted/queued input with no outbound dispatch record from an
    outbound-journaled call lacking a result; ordinary delivery owns the former
    and `pending_reissue` only the latter; and
  - require exact terminal `interrupted` turn acknowledgement plus terminal
    status for every started action before the schema checkpoint or any worktree
    reuse; otherwise fence/pause the run as `budget_interrupt_failed`.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 serialization and quiescence closure — primary disposition 11

- Status: `actioned`; fresh holistic verification pending.
- Added one global monotonic `ledger_seq` owned by the controller's single SQLite
  writer for every mutation that changes primary semantic context or transition
  eligibility. Such transactions append canonical change records with exact
  identities/payload references; transport packet/delta/ack bookkeeping remains
  audit-only so the catch-up protocol cannot self-advance its own frontier. Every
  mutating operation must be structurally classified at initialization, and tests
  enumerate the full mutating surface. Packets/deltas project only `ledger_seq`.
- Catch-up can advance through multiple frontiers under the same candidate
  deadline. The binding-install transaction first compares the candidate's
  acknowledged frontier with the pre-transaction current maximum sequence; on
  equality it atomically records acknowledgement/installation and returns the
  resulting frontier `I`. The candidate remains decision-ineligible until the
  binding confirmation is successfully written; failure retires/fences it under
  the same episode. Records after `I` drain before the next primary turn.
- Split admitted input ownership:
  - `queued_not_dispatched` is durable admission without an outbound-call journal
    and receives one ordinary ordered delivery after rebind; and
  - `dispatched_pending` is atomically journaled before upstream send; only this
    no-result state may become the one linked `pending_reissue`.
- Updated decision envelopes so pre-admission rebind requires re-presentation,
  admitted/queued input receives ordinary delivery, outbound-journaled/no-result
  input receives one reissue, and an already durable interpretation survives
  rebind subject to catch-up/currentness.
- Work-budget interruption now requires exact `turn/completed` status
  `interrupted` and terminal status for every observed started action before the
  schema checkpoint, handoff, or worktree reuse. Missing quiescence by the finite
  deadline records `budget_interrupt_failed` and fences the run/worktree.
- Updated requirements, common contract, transition map, work plan, exact sites,
  temporal ordering, ownership/concurrency, and composition tests consistently.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 third fresh holistic verification

- Dispatch: third fresh independent `rfc-reviewer` and `rfc-red-team` passes over
  the complete revised `poc/PLAN.md`, without this ledger, earlier findings, or
  implementation diff.
- Structured reviewer verdict: RED.
  - `blocking × in-scope`: the authoritative rebind contract gives eligible
    reissues priority over later queued input, while the acceptance narrative
    orders queued-not-dispatched input before reissues; the protocol needs one
    global input order with delivery mode selected per item.
  - `blocking × in-scope`: the automatic-plan-version counter reset rule differs
    between the checkpoint and standalone final-plan paths.
  - `blocking × in-scope`: the initial restart predicate policy, its exact
    membership, and its accepted source are not materialized before root-assessor
    assignment.
- Adversarial reviewer verdict: RED FLAG.
  - `blocking × in-scope`: one decision-envelope binding epoch cannot faithfully
    represent a response presented under one physical primary and interpreted
    under its replacement after durable response admission.
  - `blocking × in-scope`: natural turn completion can win the work-budget
    interrupt race, so requiring only terminal `interrupted` status can reject a
    safe completed role result or misclassify it as interruption failure.
  - `significant × in-scope`: the same automatic-plan-version counter reset
    inconsistency appears across the duplicated surfaces.
- Convergence assessment: these are serialization, provenance, race, and policy-
  materialization omissions inside already accepted protocols. They require no
  new product, scope, or material architecture decision.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 serialization/provenance closure — primary disposition 12

- Status: `actioned`; fresh holistic verification pending.
- Every admitted input now has one global monotonic `input_seq`; rebind processes
  items strictly by that sequence and chooses ordinary delivery versus the sole
  eligible reissue from each item's durable dispatch state. Delivery mode cannot
  reorder input.
- The shared decision envelope now records immutable
  `presentation_binding_epoch` and `interpretation_binding_epoch` separately.
  They may differ only when the response was admitted before physical rebind;
  the controller validates each epoch at its own lifecycle boundary, the stable
  logical-primary identity, and current subject/input rather than requiring the
  epochs to match.
- The work-budget interrupt race now has three explicit safe terminal branches:
  `interrupted` permits the schema checkpoint after action quiescence; natural
  `completed` is an ordinary role outcome only when no post-frontier action began
  and its terminal schema is valid; `failed` uses ordinary failure handling.
  Post-frontier work or missing quiescence still fences the run/worktree.
- Every current actionable plan-envelope direction—`revise_next_version` or
  independently affirmed `proceed_closed_plan`—resets the automatic-version
  counter whether it comes from the pacing checkpoint, final closed-plan review,
  or a combined envelope. Pause, ambiguity, invalidity, and abandonment do not.
- The initial restart policy is now the immutable `restart-predicates-v1`
  materialization of accepted ITD 71 in `NEW_CODEX_OPERATING_MODEL.md`. It binds
  the accepted source/content identity and the existing exact predicate IDs
  `foundational-premise-invalidated`,
  `incremental-repair-preserves-invalid-structure`, and
  `clean-restart-has-better-path` before root-assessor assignment. A positive
  assessment requires all three exactly once, true, and backed by specific
  evidence; missing, duplicate, extra, evidence-free, source-mismatched, or stale
  policy results cannot create a restart proposal. Policy evolution remains an
  evidence-backed ITD with mandatory user review and immutable history.
- Updated the common contracts, transition map, acceptance narrative, work plan,
  exact sites, temporal composition, effect ordering, and deterministic
  composition cases consistently.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 fourth fresh holistic verification

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete frozen `poc/PLAN.md`, without this ledger, earlier findings, or the
  implementation diff.
- Structured reviewer verdict: RED.
  - `blocking × in-scope`: restart policy propagation binds the three IDs and a
    source identity but not the full accepted criterion statements. The IDs omit
    the accepted-plan-decision and disproportionate-complexity alternatives and
    cannot prove what semantics the assessor actually evaluated.
  - `blocking × in-scope`: explicit abandonment is declared preservation-only in
    the accepted decision but the temporal table says terminal state precedes
    cleanup, allowing a material effect on an independently unverified branch.
- Adversarial reviewer verdict: RED FLAG.
  - `blocking × in-scope`: primary continuity covers admitted user input and
    durable interpretations but not a controller-initiated non-user primary turn
    lost after dispatch and before typed-result persistence.
  - `significant × in-scope`: concurrent actions already started when the sixth
    completion is observed can exceed the six-item budget yet still satisfy the
    old safe-completion predicate.
  - `significant × in-scope`, convergent: restart policy identity does not prove
    that the assessor received the full accepted predicate semantics.
- Convergence assessment: restart semantics and abandonment are local contract
  propagation defects. The internal-primary-call finding requires a bounded
  continuity primitive, but a generic retry/recovery framework would add
  disproportionate semantic surface. The budget finding requires moving the
  eligibility frontier to action starts, not a scheduler redesign.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 continuity/policy closure — primary disposition 13

- Status: `actioned`; fresh holistic verification pending.
- `restart-predicates-v1` is now one immutable canonical ordered object containing
  its policy ID, accepted-ITD-71 source/content identity, object digest, and all
  three exact criterion statements. The complete object enters the root-assessor
  input and its digest returns with the result. Tests cover both alternatives in
  the first two criteria and reject narrowed, missing, duplicate, extra,
  evidence-free, digest/source-mismatched, or stale policy output.
- Explicit abandonment now terminalizes only workflow state while preserving the
  worktree, artifacts, findings, conversations, and every other evidence record.
  It performs no cleanup, deletion, reset, integration, or external effect; any
  future cleanup is a distinct high-stakes proposal.
- Every controller-initiated non-user primary semantic turn now has one stable
  durable operation identity before send, including exhaustive kind, authority,
  consumed frontier/artifacts, schema, currentness, and newest-input boundary.
  The physical attempt is separately journaled. After rebind, a still-current
  queued operation receives its ordinary first attempt and a still-current
  dispatched/no-result operation receives one new-epoch replacement attempt.
  Newer input or state supersession closes it without replay; live-binding
  replacement failure records `primary_operation_failed`, renders fixed facts,
  and pauses. This is physical continuity for one logical operation, not a
  general model/transport-error retry framework.
- The work quantum now counts action starts. The sixth start or five-minute
  frontier requests interruption; any seventh start or completion—including
  concurrent work before interrupt acceptance—is `budget_overrun` and cannot
  produce an eligible terminal outcome. Safe natural completion requires no
  seventh start/completion plus schema-valid output and full action quiescence.
- Corrected the remaining effect-ordering sentence: only current actionable
  `revise_next_version` or independently affirmed `proceed_closed_plan` resets
  the plan auto-iteration counter; pause, abandon, ambiguity, and invalidity do
  not.
- Updated requirements, common contracts, transition map, acceptance narrative,
  work plan, exact sites, temporal composition, effect ordering, execution
  ownership, and deterministic composition cases consistently.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 fifth fresh holistic verification

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete frozen `poc/PLAN.md`, without this ledger, earlier findings, or the
  implementation diff.
- Structured reviewer verdict: RED with two `blocking × in-scope` findings.
  - A live replacement-primary operation failure is required by the general
    attention rule to receive a primary-authored summary, while the continuity
    contract instead permits fixed controller facts. The failure-summary path and
    its own failure bound are contradictory/undefined.
  - The five-minute frontier can occur below six starts. An action starting after
    that time frontier but before interrupt acceptance is ineligible under one
    requirement yet not an overrun under the seventh-action-only rule elsewhere.
- Adversarial reviewer verdict: GREEN CLEAR. It found no blocking/significant
  in-scope failure and confirmed the bounded primary-operation lifecycle, action-
  count handling, full restart-policy semantics, abandonment preservation,
  continuity/decision authority, and plan authorization.
- Convergence assessment: the two remaining findings are lifecycle closure and
  duplicated-frontier propagation defects. Neither changes product behavior,
  scope, or the chosen architecture.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 failure-summary/time-frontier closure — primary disposition 14

- Status: `actioned`; fresh holistic verification pending.
- A terminal non-summary `primary_operation_failed` now closes the failed logical
  operation without retry, then opens one distinct current `attention_summary`
  operation under the still-live primary binding. If that summary operation
  itself terminally fails, the controller renders one explicitly labelled fixed
  durable-facts status, creates no recursive summary, preserves work, and waits
  for fresh user input. Fixed controller presentation is otherwise limited to
  no-primary activation/rebind exhaustion. This retains accountable primary
  communication while bounding the failure path.
- The first work-quantum limit—sixth action start or five-minute timer—is now a
  serialized controller frontier that atomically closes action-start eligibility.
  Any action start observed after that frontier is `budget_overrun` regardless of
  ordinal or interrupt race; any total above six is also overrun. Both
  `interrupted` checkpoint and racing natural `completed` require no post-frontier
  start, total at most six, terminal action quiescence, and their normal schema.
  Deterministic tests include a low-ordinal start racing after the time frontier.
- Updated requirements, common contracts, transition map, work plan, exact sites,
  temporal composition, effect ordering, execution ownership, and deliberate
  composition cases consistently.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 sixth fresh holistic verification

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete frozen `poc/PLAN.md` at SHA-256
  `1bd1677dbfb2acfa42773314541e72eed578fb4dc5aeb87612f6fcaeb56726ae`,
  without this ledger, implementation diff, or other agents' outputs.
- Adversarial reviewer verdict: GREEN CLEAR. It found no blocking/significant
  in-scope failure and affirmed non-recursive operation-failure containment,
  serialized count/time frontier, input/operation rebind, decision epochs, plan
  authorization, full restart semantics, abandonment, and retry bounds.
- Structured reviewer verdict: RED with one `blocking × in-scope` finding.
  - Post-binding primary semantic calls have explicit failure and physical-loss
    handling but no finite terminal deadline when the thread remains nominally
    live and returns nothing. Ordinary input delivery, non-user operation, or
    `attention_summary` can therefore remain `dispatched_pending` forever and
    prevent the existing failure/fallback states from becoming reachable.
- Independence caveat: the structured reviewer disclosed that a preliminary
  memory lookup exposed a high-level earlier-PoC recap. It did not inspect this
  ledger, diff, or other reviewer output, but its result is not treated as the
  sole independent gate; another fresh post-fix pair remains required.
- Convergence assessment: this is a missing finite terminal condition in the
  existing physical-call lifecycle, not a new retry/recovery architecture or
  product decision.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 primary-call deadline closure — primary disposition 15

- Status: `actioned`; fresh holistic verification pending.
- Every post-binding ordinary or replacement primary semantic-call attempt now
  has a controller-owned five-minute deadline starting from its durable pre-send
  journal. This covers user input delivery, controller-initiated non-user
  operations, and `attention_summary`; activation/rebind control calls keep their
  separate finite candidate-operation deadline.
- Expiry atomically terminalizes the attempt before requesting `turn/interrupt`,
  rejects all late results, and requires terminal turn quiescence within 30
  seconds. A quiescent live thread may continue only through the kind-specific
  failure path. Missing quiescence fences the thread and enters the existing
  bounded rebind, but timed-out semantic work stays terminal and cannot be
  retried by replacement.
- Non-user timeout records `primary_operation_failed` and enters the one-summary
  path; summary timeout uses the fixed non-primary no-recursion fallback;
  ordinary input timeout records `input_delivery_failed`; linked-reissue timeout
  records `reissue_failed`. Input outcomes preserve the verbatim input, apply no
  semantic effect, close automatic eligibility, and admit later input. Only
  physical loss before deadline with no other terminal outcome can make
  dispatched work eligible for the one existing replacement attempt.
- Updated requirements, common contracts, transition map, work plan, exact sites,
  temporal composition, effect ordering, execution ownership, and deliberate
  timeout/cancellation/late-result composition tests consistently.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 seventh fresh holistic verification

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete frozen `poc/PLAN.md` at SHA-256
  `35fcded77db855d3b6e11133a58f4bed603d9efa3a91a35dfde08ac5a2651e99`,
  without this ledger, implementation diff, or other agents' outputs.
- Structured reviewer verdict: RED.
  - `blocking × in-scope`: primary-call timeout treats terminal turn status as
    quiescence but does not require terminal outcomes for every action started by
    that turn; a live old action can overlap thread reuse/replacement.
  - `significant × in-scope`: the direct native `codex review --commit` subprocess
    has no deadline, termination/quiescence rule, or terminal timeout evidence, so
    the hard gate can hang indefinitely.
- Adversarial reviewer verdict: RED FLAG.
  - `blocking × in-scope`: explicit error or live supersession can logically close
    a possibly dispatched primary operation/input while its physical turn remains
    live; only timeout currently settles/fences the turn.
  - `significant × in-scope`, convergent: primary-call quiescence omits terminal
    status for started actions.
- Convergence assessment: all findings share one root: logical outcome and
  physical execution settlement are conflated outside the agent-work budget.
  The bounded repair applies one settlement invariant to the exact two exercised
  controller-launched surfaces, not a generic recovery framework.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 external-invocation settlement closure — primary disposition 16

- Status: `actioned`; fresh holistic verification pending.
- Every post-binding primary semantic-call attempt now records a durable
  `send_started` marker and separate logical-outcome versus physical-settlement
  state. Only mechanically proven failure before that marker needs no settlement;
  failure afterward is possibly dispatched.
- Success becomes eligible only when the exact turn is terminal and every action
  started for that turn has a terminal item outcome. Error, invalid output,
  supersession, or timeout closes semantic work first, rejects late results, and
  interrupts a known turn. Unknown-turn ambiguous send or failure to fully settle
  within 30 seconds fences the thread and enters bounded rebind. No successor
  primary call uses the thread before settlement, and rebind cannot retry terminal
  semantic work.
- Primary semantic calls expose only read-only context actions. Delegation,
  messages, writes, subprocesses, and effects occur through controller-owned
  transitions after settled eligible typed output; unexpected effect-capable
  action is a protocol failure with the same settlement/fence path.
- The direct native-review subprocess now has a 10-minute deadline. Timeout
  durably records command/candidate and partial stdout/stderr, requests
  termination of its isolated process group, waits 30 seconds, force-terminates
  the group if needed, and proves group quiescence before checkout reuse.
  Partial/timeout output cannot enter structuring or
  adoption, the gate fails visibly, and no automatic retry occurs.
- Updated requirements, common contracts, transition map, work plan, exact sites,
  temporal composition, effect ordering, execution ownership, and deterministic
  cases for explicit error, live supersession, ambiguous send, delayed action,
  native timeout, partial output, and process settlement.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 eighth fresh holistic verification

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete frozen `poc/PLAN.md` at SHA-256
  `365863b981c682ab12d075c839e04cc4249806e9554c90538cfee14987c1c38b`,
  without this ledger, implementation diff, or other agents' outputs.
- Structured reviewer verdict: GREEN. It found no blocking/significant in-scope
  findings and judged the plan prototype-ready under the declared PoC boundary.
- Adversarial reviewer verdict: RED FLAG.
  - `blocking × in-scope`: normal agent checkpoints, terminal role outcomes, and
    handoff could become eligible after turn output while an already-started
    write action remained live. The existing settlement invariant covered
    primary calls and budget interruption, not every role turn.
  - `significant × in-scope`: a native-review child could escape the original
    process group or retain stdout/stderr, so process-group quiescence did not
    prove descendant/output-producer termination before checkout reuse.
  - `significant × in-scope`: an `attention_summary` superseded by newer input
    had contradictory next states: process the queued input versus render the
    old summary's fixed failure fallback and wait for another input.
- Convergence assessment: the first finding reveals the same root invariant as
  the prior primary-call findings: logical model output never proves physical
  turn/action settlement. Apply it once to every agent-role App Server turn,
  with work-budget handling as an additional pacing rule. The native-review
  repair should not become a generic descendant-containment framework: the
  exact command is read-only, and a timeout can permanently retire its isolated
  checkout and close controller pipes. Summary supersession is distinct from
  summary failure and should yield to the already-admitted newer input.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 universal turn-settlement closure — primary disposition 17

- Status: `actioned`; fresh holistic verification pending.
- Every agent-role App Server turn now has one common settlement invariant. A
  checkpoint, ask, inflection report, terminal role outcome, or fixed-role
  one-shot result remains provisional until the exact turn and every started
  action are terminal. Logical completion, failure, invalidity, or supersession
  opens a 30-second settlement window. Failed settlement fences the run and its
  assigned worktree/checkout and forbids primary response, successor turn,
  checkpoint adoption, handoff, owner release/reuse, terminal-run adoption,
  candidate construction, and dependent progress. Work-quantum interruption
  reuses this invariant and adds its action/time frontier.
- Native-review timeout now freezes only bytes already received through
  controller-owned pipes, attempts bounded process-group termination, closes
  the controller pipe endpoints, and permanently retires the isolated checkout.
  The subprocess/descendants have read-only filesystem/tool authority; the plan
  makes no escaped-descendant quiescence claim. Partial output and cleanup status
  cannot enter structuring/adoption, and no automatic retry occurs.
- `attention_summary` supersession is no longer failure. After settlement or
  thread fencing, newer admitted input suppresses stale summary output and fixed
  fallback and proceeds in `input_seq` order. The fixed no-recursion fallback is
  limited to actual terminal failure of a still-current summary when no newer
  input determines the next operation.
- Updated requirements, common contracts, transition map, acceptance narrative,
  work plan, exact sites, temporal composition, effect ordering, execution
  ownership, concurrency constraints, and deterministic composition cases.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 Phase 1 convergence — ninth fresh holistic verification

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete frozen `poc/PLAN.md` at SHA-256
  `a410dfc7e6de1bf5e39050eb733bf0131c4c6579abb9cbd28535c5e9ebe854f6`,
  without this ledger, implementation files/diffs, memory, prior reviewer
  outputs, or other agents' work.
- Structured reviewer verdict: GREEN. No blocking or significant in-scope
  finding; the plan was judged root-level, coherent, temporally explicit,
  authority-closed, and operationally sufficient for its bounded PoC scope.
  Its stated limitation was that codebase reuse/site completeness was assessed
  from the plan declarations rather than implementation inspection.
- Adversarial reviewer verdict: GREEN CLEAR. It explicitly re-tested ordinary
  agent-turn settlement before checkpoint/handoff/candidate use,
  `attention_summary` supersession ordering, read-only native-review timeout with
  escaped descendant/pipe holder and permanent checkout retirement, plus rebind,
  decision currentness, supersession, and effect ordering. No blocking or
  significant in-scope failure remained.
- Phase 1 is converged. Per the Plan Review flow, the plan now enters the one-time
  subtractive minimality pass before final verification and the mandatory user
  review. No implementation, live Codex PoC run, commit, or integration was
  performed.

### Epoch 18 Phase 2 subtractive minimality review

- Artifact: frozen `poc/PLAN.md` at SHA-256
  `a410dfc7e6de1bf5e39050eb733bf0131c4c6579abb9cbd28535c5e9ebe854f6`.
- Independent `rfc-minimizer` verdict: BLOATED.
- `blocking × adjacent`: repeatable manual primary recovery after activation/
  rebind exhaustion. The structured `activate_primary` control, fresh manual
  episodes, kernel/controller/TUI sites, and dedicated tests add an operator-
  facing recovery lifecycle beyond the accepted single bounded automatic rebind
  and beyond its protected preserved-state/fixed-failure obligations. Per the
  scope routing policy this is a user scope-change decision, not an automatic
  plan edit.
- `significant × adjacent`: the separate normal presentation detach/reattach
  live-run exercise is a second successful continuity demonstration beyond the
  explicitly scoped physical-primary rebind. Its underlying envelope invalidation,
  re-presentation, and cross-rebind binding semantics remain protected; the
  minimizer recommends removing only the distinct live success claim/exercise
  while retaining deterministic coverage.
- Strength: the closed transition inventory and temporal-composition section are
  extensive but load-bearing for the supplied authority, settlement, ownership,
  currentness, candidate, review, and restart obligations; they do not become a
  generic authorization framework.
- No plan edit was applied. Mandatory user scope resolution precedes Phase 3
  verification. No implementation, live Codex PoC run, commit, or integration
  was performed.

### Epoch 18 manual-primary-recovery subtraction — user decision and disposition 18

- User decision: choose minimizer Option 1; remove repeatable manual primary
  recovery from the PoC rather than expand scope.
- Removed the structured `activate_primary` control, its manual activation
  transition/episode, kernel/controller/TUI/test obligations, and the composition
  case that reopened activation after bounded exhaustion.
- Retained the load-bearing behavior: initial activation and the one planned
  automatic rebind each have their bounded candidate attempts; exhaustion records
  `primary_start_failed` or `rebind_failed`, fences failed threads, preserves
  queued input/work/evidence, renders fixed non-semantic status, and performs no
  third attempt. The status now states that the bounded PoC stopped and provides
  no in-PoC recovery action.
- The second minimizer finding—whether the separate successful presentation
  detach/reattach live exercise is required—remains pending user disposition.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 live-detach-exercise subtraction — user decision and disposition 19

- User decision: retain UI detach/reattach behavior in implementation and
  deterministic tests, but remove it as a compulsory step of the live PoC
  acceptance run.
- Removed the separate successful presentation detach/reattach claim, its live
  acceptance-narrative episode, and the site-list obligation to exercise it in
  the live TUI run.
- Retained the load-bearing envelope behavior and deterministic coverage:
  detach/presentation replacement before response admission invalidates the
  presentation and requires complete re-presentation; reattachment itself grants
  no authority; attention-summary behavior remains testable. The distinct live
  physical-primary replacement still exercises successful continuity.
- Both Phase 2 minimizer findings are now dispositioned. The amended plan enters
  fresh Phase 3 soundness and adversarial verification; the minimizer is not
  rerun.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 Phase 3 post-minimization verification

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete frozen `poc/PLAN.md` at SHA-256
  `0adbd511df005f56f556dca782a9e573b22c7f09585ba3081e5af69d4be7b717`,
  without this ledger, implementation files/diffs, memory, prior review/minimizer
  outputs, or other agents' work.
- Structured reviewer verdict: GREEN. It verified terminal bounded activation/
  rebind exhaustion without manual recovery, retained deterministic detach/
  re-presentation semantics without a compulsory live exercise, and found the
  full plan internally sound and prototype-ready.
- Adversarial reviewer verdict: YELLOW CAUTION with one
  `significant × in-scope` finding. An independent write-capable agent turn may
  correctly continue during rebind, but candidate-two exhaustion did not stop or
  settle that turn before rendering terminal `rebind_failed`; the worktree could
  continue mutating after the claimed preserved terminal state.
- Convergence assessment: this is a missing composition of the existing
  agent-role settlement/fencing invariant with bounded no-primary exhaustion,
  not a new recovery system or user-visible product choice.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 no-primary agent-settlement closure — primary disposition 20

- Status: `actioned`; fresh Phase 3 verification pending.
- On activation/rebind candidate-two failure, the controller now records
  exhaustion, atomically closes new agent turn/action admission, interrupts every
  active agent-role turn, and applies the existing 30-second exact turn/action
  settlement contract before rendering fixed no-primary status.
- Settled agent outcomes remain durable unadopted evidence because no primary is
  available. Failed settlement records `role_turn_settlement_failed`, permanently
  fences the run and assigned worktree/checkout, and is named in the final status;
  the status does not claim that an unsettled fenced worktree has static contents.
- Added the ordering, execution-ownership, concurrency, controller/site, and
  deterministic composition obligations for candidate-two exhaustion racing an
  active write-capable agent action. No manual recovery path was reintroduced.
- No implementation, live Codex PoC run, commit, or integration was performed.

### Epoch 18 final Phase 3 convergence and Plan Review closure

- Dispatch: fresh independent `rfc-reviewer` and `rfc-red-team` passes over the
  complete frozen `poc/PLAN.md` at SHA-256
  `7d59bf8b8b582bbad4d90d5d308f8d01fddf15e49578d5867ac1f94225423523`,
  without this ledger, implementation files/diffs, memory, prior review/minimizer
  outputs, or other agents' work.
- Structured reviewer verdict: GREEN. It verified admission closure, exact
  settle-or-fence-before-render ordering, unadopted-result handling, non-reusable
  unsettled worktrees, no static-content claim, no third candidate/manual
  recovery, explicit sites/tests, and full prototype readiness.
- Adversarial reviewer verdict: GREEN CLEAR. The active independent write-action
  race now closes through durable exhaustion, admission closure, interruption,
  exact settlement or `role_turn_settlement_failed` fencing, accurate terminal
  status, and no recovery path. No blocking or significant in-scope regression
  remained across the complete plan.
- Final Plan Review state: GREEN. Phase 1 soundness/adversarial convergence,
  Phase 2 minimization with both user-dispositioned subtractions, and final
  Phase 3 verification are complete. No minimization conflict or user scope
  decision remains pending.
- The plan is eligible for its ignored closure receipt and mandatory user review.
  Implementation remains blocked until the user explicitly approves this exact
  final plan.
- No implementation, live Codex PoC run, commit, or integration was performed.

## Implementation Code Review — Epoch 1

Scope block: the accepted scope block at the start of `poc/PLAN.md`.

### CR-E1-01 — role-turn authority follows dispatch

- Review epoch: 1
- Iteration: phase-1.1
- Source: independent `code-review-analyst` discovery pass
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:4584`
- Statement: a writable agent `turn/start` is dispatched before the kernel
  reserves and validates the exact one-use run direction; a stale or unrelated
  direction can therefore fail after unmonitored work has already started.
- Suspected surface: agent-turn admission and direction authority
- Fix applied: the kernel now atomically reserves one exact run-targeted
  direction before App Server dispatch, binds the returned turn ID afterward,
  and fences the reservation/run/worktree if dispatch or collection fails. The
  deterministic offline runtime uses the same reserve-before-model-call order;
  only runtimes that attest their own equivalent enforcement bypass that wrapper.
- Lifecycle: `actioned; pending epoch-2 re-review`
- Notes: cleanup only disarms an unregistered monitor; direction selection uses
  the latest unrelated primary model call instead of a run-targeted direction.

### CR-E1-02 — two decisions bypass the shared envelope

- Review epoch: 1
- Iteration: phase-1.1
- Source: independent `code-review-analyst` discovery pass
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:3158`, `poc/prototype.py:3465`,
  `poc/kernel.py:3449`
- Statement: intent revision and final ITD capture/interpret user text without
  using the proposal presentation/currentness protocol, while `accept_intent`
  trusts caller fields instead of deriving an accepted revision from the exact
  typed result.
- Suspected surface: user-decision authority and semantic persistence
- Fix applied: intent revisions and final ITDs now use the same durable
  proposal/presentation/interpretation protocol as other user decisions.
  Accepted intent fields are derived from the exact authorized interpretation;
  final ITD fields are derived from its exact primary interpretation and retain
  the accepted plan's explicit no-independent-verifier, no-host-effect rule.
- Lifecycle: `actioned; pending epoch-2 re-review`
- Relationship: `spawned-sibling` of CR-E1-01

### CR-E1-03 — plan non-proceed outcomes have no valid transition

- Review epoch: 1
- Iteration: phase-1.1
- Source: independent `code-review-analyst` discovery pass
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:2264`, `poc/prototype.py:2539`,
  `poc/kernel.py:3816`
- Statement: plan clarification/rejection is routed to a resume API that rejects
  plan kinds, while pause, abandon, and revise do not durably close or
  terminalize the presented proposal as required.
- Suspected surface: plan-envelope state transitions
- Fix applied: typed plan dispositions now have explicit durable transitions:
  revise authorizes the next version and resets the auto-iteration window,
  pause/clarify rejects the envelope and waits without abandoning, and abandon
  retires the active attempt lineage and clears the work item's current attempt.
  A failed plan or final-ITD interpretation can be reconsidered through the same
  explicit paused-direction protocol instead of an unsupported-kind exception.
- Lifecycle: `actioned; pending epoch-2 re-review`
- Relationship: `spawned-sibling` of CR-E1-02
- Notes: the reviewer reproduced `ValueError: unsupported proposal kind` on the
  plan-checkpoint path.

### CR-E1-04 — ordinary workflow stops cannot be summarized

- Review epoch: 1
- Iteration: phase-1.1
- Source: independent `code-review-analyst` discovery pass
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:1708`, `poc/kernel.py:1592`
- Statement: attention summaries require a failed non-summary primary semantic
  operation, but expected workflow stops such as validation/review/closure or a
  primary pause have no such operation and therefore degrade to generic stderr.
- Suspected surface: durable stop presentation
- Fix applied: `workflow_stopped` now returns its exact ledger sequence and an
  attention-summary operation can target either one failed semantic operation
  or one exact ordinary workflow stop, with uniqueness enforced for both.
- Lifecycle: `actioned; pending epoch-2 re-review`
- Relationship: `spawned-sibling` of CR-E1-03

### CR-E1-05 — implementation closure cannot drive correction

- Review epoch: 1
- Iteration: phase-1.1
- Source: independent `code-review-analyst` discovery pass
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:2971`
- Statement: closure cannot emit or persist structured findings and has no
  code-correction versus plan-correction route, so a missing accepted-plan
  obligation cannot produce a corrected candidate through the defined workflow.
- Suspected surface: closure finding and correction lifecycle
- Fix applied: closure results now persist typed candidate/plan-bound findings.
  Exact primary dispositions route accepted findings through code correction or
  a fully reviewed and user-authorized next plan, then create a replacement
  candidate and repeat complete review, validation, and closure before the
  findings can resolve.
- Lifecycle: `actioned; pending epoch-2 re-review`
- Relationship: `spawned-sibling` of CR-E1-03

### CR-E1-06 — catch-up callback failure strands the candidate

- Review epoch: 1
- Iteration: phase-1.1
- Source: independent `code-review-analyst` discovery pass
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:1636`
- Statement: a failing independent-work callback is re-raised before the current
  replacement candidate is failed and its physical thread fenced, leaving the
  logical primary permanently `rebinding` with a `catching_up` candidate.
- Suspected surface: physical-primary candidate failure cleanup
- Fix applied: callback failure is re-raised only after the current binding
  candidate is failed and its physical thread is fenced; no retry masks or
  bypasses the original callback failure.
- Lifecycle: `actioned; pending epoch-2 re-review`
- Relationship: `spawned-sibling` of CR-E1-01

### Convergence checkpoint CR-CP-E1-01

- Review epoch: 1
- Triggered at: phase-1.1, pre-fix
- Continuation:
  - Phase: `phase-1`
  - Boundary: `pre-fix`
  - Lane: `discovery`
  - Required next action: diagnose the shared authority/transition cluster and
    select repair altitude before applying any finding fix
- Trigger: the first discovery pass produced sibling blocking findings across
  admission authority, user-decision envelopes, plan/closure transitions, and
  stop presentation; fixing them independently risks another symptom loop.
- Evidence clusters: CR-E1-01 through CR-E1-06; shared surface is missing
  pre-effect authority reservation and incomplete durable transition closure.
- Diagnosis: `local-design-flaw` (high confidence). The implementation encoded
  accepted producer-before-effect and terminal/no-effect contracts as post-hoc
  checks and partial happy-path procedures. CR-E1-06 is the same lifecycle-
  closure weakness at the binding-candidate boundary.
- Action: apply one bounded implementation-altitude transition-closure
  correction set for CR-E1-01 through CR-E1-06; no plan change or renewed Plan
  Review. After the fixes, start review epoch 2 and restart Phase 1 discovery.
- Status: `actioned`
- Status evidence: independent `review-convergence-analyst` diagnosis accepted
  every finding, found no missing product/scope decision, and selected the
  already-reviewed architecture as sufficient.

### Epoch 1 repair checkpoint

- CR-E1-01 through CR-E1-06 were repaired as the accepted single
  transition-closure set; no plan or scope change was introduced.
- Exact negative/transition coverage now proves pre-dispatch denial, fresh
  run-targeted continuation authority, intent-envelope non-bypass, plan
  revise/pause/abandon terminal states, ordinary-stop summary binding, and
  candidate/thread cleanup on a catch-up callback failure.
- The complete disposable narrative now persists a material plan-level closure
  finding, immediately invalidates the old plan/candidate gates, reviews and
  user-authorizes N+1, implements its named delta, creates a replacement commit
  candidate, repeats correctness/cohesion/native review plus validation and
  closure, and resolves the finding only against that replacement. Its final accepted ITD is
  derived from the exact primary interpretation without inventing a host effect
  or an independent co-sign that the accepted plan excludes.
- Offline validation: `python3 -m unittest discover -v` passes 168 tests with
  one outer-sandbox-dependent test skipped; `go test ./...`, Python bytecode
  compilation, shell syntax checks, `git diff --check`, and ShellCheck with the
  pre-existing indirect-trap `SC2317` diagnostic excluded all pass.
- Continuation token: start fresh Code Review Epoch 2 Phase 1 discovery over the
  complete current implementation. No live Codex PoC run, commit, integration,
  or push is authorized by this checkpoint.

## Implementation Code Review — Epoch 2

Scope block: the accepted scope block at the start of `poc/PLAN.md`.

### CR-E2-01 — binding becomes authoritative before installation confirmation

- Review epoch / iteration: 2 / phase-1.1
- Source: fresh independent `code-review-analyst`
- Severity / scope: `blocking × in-scope`
- Location: `poc/kernel.py:install_primary_binding`,
  `poc/prototype.py:establish_primary_binding`
- Statement: the candidate becomes active and agent admission opens before the
  required binding-installed confirmation is written to its exact physical
  thread. A routing-switch failure then leaves durable state active but the new
  thread fenced, with no valid candidate-failure or bounded-retry transition.
- Suspected surface: physical-primary installation/confirmation ordering
- Fix applied: install now enters a durable `confirming` state with assignment
  admission closed. Routing switches provisionally, an exact typed confirmation
  is delivered to that candidate thread, and only its matching durable receipt
  activates the logical primary. Confirmation failure retires/fences the
  candidate and uses the existing bounded retry.
- Lifecycle: `closed; verified clean in epoch 3`

### CR-E2-02 — intent revision incorrectly requires an independent co-sign

- Review epoch / iteration: 2 / phase-1.1
- Source: fresh independent `code-review-analyst`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:present_high_stakes`
- Statement: a positive intent revision enters the generic semantic-verifier
  path even though the accepted boundary makes revised product constraints a
  primary-owned user decision and limits co-signing to restart, integration,
  and `proceed_closed_plan`.
- Suspected surface: decision-envelope authority classification
- Fix applied: positive intent revision now uses the exact primary-only decision
  transition. Independent interpretation and effect authorization are explicitly
  allowlisted to restart, integration, and closed-plan proceed decisions; the
  verifier role contract names that same boundary.
- Lifecycle: `closed; verified clean in epoch 3`

### CR-E2-03 — restart policy is label-bound rather than artifact-bound

- Review epoch / iteration: 2 / phase-1.1
- Source: fresh independent `code-review-analyst`
- Severity / scope: `blocking × in-scope`
- Location: `poc/kernel.py:restart policy and assessment/recommendation gates`
- Statement: assignment and assessment validate the literal policy label and
  predicate IDs but not the immutable ordered policy object, accepted-ITD
  source/content identity, full statements, digest, or attempt-start snapshot;
  recommendation input/output is not bound to that exact assessment lineage.
- Suspected surface: restart-policy provenance and recommendation authority
- Fix applied: the controller now materializes one immutable ordered policy object
  with accepted ITD-71 source/content identity, all complete statements, and a
  digest. Root assignment, result, intent, attempt, and start snapshot bind that
  object exactly; the primary recommendation must consume that exact assessment
  lineage and return the exact persisted discarded/retained state and summary.
- Lifecycle: `closed; verified clean in epoch 3`

### CR-E2-04 — physically ineligible primary output can authorize a role turn

- Review epoch / iteration: 2 / phase-1.1
- Source: fresh independent `code-review-analyst`
- Severity / scope: `blocking × in-scope`
- Location: `poc/kernel.py:_exact_role_direction`,
  `poc/prototype.py:typed_call`
- Statement: later role-turn direction is selected from a typed primary
  `model_calls` row without proving that the owning physical primary call
  settled successfully. A failed/interrupted alignment result therefore remains
  discoverable as fresh continuation authority.
- Suspected surface: provisional primary result eligibility
- Fix applied: primary model-call rows now name their physical call attempt.
  Later role-turn direction authority joins that exact semantic operation and
  requires settled, physically successful, eligible completion.
- Lifecycle: `closed; verified clean in epoch 3`

### CR-E2-05 — primary-operation artifact currentness is persisted but ignored

- Review epoch / iteration: 2 / phase-1.1
- Source: fresh independent `code-review-analyst`
- Severity / scope: `significant × in-scope`
- Location: `poc/kernel.py:prepare_primary_operation_attempt`
- Statement: initial and replacement dispatch check newer user input but do not
  mechanically compare the operation's stored attempt, plan, and candidate
  identities with current durable lineage, allowing stale work to dispatch and
  complete without a newer input.
- Suspected surface: semantic-operation currentness enforcement
- Fix applied: registration accepts only typed attempt/plan/candidate identities;
  every initial or replacement prepare compares each declared identity with the
  current durable lineage in the same transaction. Any mismatch supersedes the
  operation and creates no physical call attempt.
- Lifecycle: `closed; verified clean in epoch 3`

### CR-E2-06 — non-controller post-dispatch failures strand reservations

- Review epoch / iteration: 2 / phase-1.1
- Source: fresh independent `code-review-analyst`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:typed_call role evidence/settlement pipeline`
- Statement: pre-reserved role turns are aborted only when `model.call` raises
  or returns a non-object. Later evidence, identity, binding, action, output, or
  settlement exceptions leave the turn active and permanently block the run.
- Suspected surface: role-turn post-dispatch settlement cleanup
- Fix applied: returned role evidence and the complete settlement/adoption
  pipeline now share one exception boundary. Any pre-reserved turn that has not
  settled is fenced with its run, assignment, output, and worktree before the
  error propagates; already settled turns remain terminal.
- Lifecycle: `closed; verified clean in epoch 3`

### Convergence checkpoint CR-CP-E2-01

- Review epoch: 2
- Triggered at: phase-1.1, pre-fix
- Continuation: diagnose relationship/root cause and select repair altitude for
  CR-E2-01 through CR-E2-06 before applying fixes; then resume Epoch 2 Phase 1
  on the resulting current implementation.
- Trigger: four blocking and two significant findings again cluster around when
  provisional identities become authoritative and how failed transitions close.
- Diagnosis: `local-design-flaw` (high confidence). The implementation treated
  durable existence as authority at three boundaries: promotion/currentness
  (binding, primary output, semantic operation), exact authority provenance
  (decision kind and restart policy), and failure closure (binding confirmation
  and role-turn settlement).
- Action: repair those existing plan-defined boundaries as one implementation-
  altitude set: provisional-until-confirmed binding, settled primary-result
  eligibility, dispatch-time artifact currentness, kind-specific verifier
  allowlisting, immutable restart-policy lineage, and settle-or-fence role-turn
  cleanup. Add negative tests at every cut point.
- Status: `actioned`
- Status evidence: independent `review-convergence-analyst` assessment found no
  missing product, scope, or plan decision and selected the accepted architecture
  as sufficient; after repair, restart fresh Phase 1 discovery over the complete
  current implementation.

### Epoch 2 repair checkpoint

- CR-E2-01 through CR-E2-06 were repaired as one eligibility/provenance/failure-
  closure set without changing accepted product behavior or plan scope.
- New deterministic coverage proves provisional binding remains decision-
  ineligible until exact-thread confirmation, confirmation failure consumes the
  bounded retry, intent revision has no independent co-sign, altered restart
  statements/digest/source are rejected, misbound recommendation calls are
  rejected, failed physical primary results cannot direct a successor, stale
  attempt/plan/candidate operations create no call attempt, and wrong-thread or
  malformed role evidence fences its reservation and run.
- The complete two-attempt narrative remains green with five semantic-verifier
  runs; the removed sixth run was the now-forbidden intent-revision co-sign.
- Offline validation: all 175 Python tests pass with one outer-sandbox-dependent
  skip; Go transport tests, Python bytecode compilation, shell syntax,
  `git diff --check`, and ShellCheck with the pre-existing indirect-trap `SC2317`
  diagnostic excluded all pass.
- Continuation token: start fresh Code Review Epoch 3 Phase 1 discovery over the
  complete current implementation. No live Codex PoC run, commit, integration,
  or push is authorized by this checkpoint.

## Implementation Code Review — Epoch 3

- Lane: fresh holistic discovery. The independent reviewer received the current
  scope, implementation, and codebase context without the earlier findings,
  convergence diagnosis, or claimed fixes.
- Verdict: clean. No blocking or significant in-scope findings were reported.
- Finding closure: CR-E2-01 through CR-E2-06 are closed by fresh discovery over
  the complete repaired implementation, not by targeted verification alone.
- Independent validation: all 175 Python tests passed with one
  outer-sandbox-dependent skip; Go transport tests and `go vet`, Python
  bytecode compilation, shell syntax, and `git diff --check` passed.
- Phase 1 exit: marginal utility reached with no new substantive finding and no
  open or actioned convergence checkpoint. Proceed to the post-convergence
  Code Review Flow gates; live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 2 Simplification

- Fresh simplification pass found two dead production helpers with no repository
  callers: `FixtureGit.verify_base()` and `scan_exact_values()`.
- Both helpers were removed. Existing candidate identity enforcement and
  capability-digest evidence scanning remain unchanged; no authority, state,
  data, or user-visible contract changed.
- Apparent duplication in primary/role settlement, controller notification IDs,
  and success/failure call closure was retained because the paths have distinct
  authority domains, malformed-input behavior, or evidence-sensitive ordering.
- Focused validation: all 42 evidence/prototype tests passed; Python bytecode
  compilation and `git diff --check` passed.
- Verdict: simplification complete with no remaining substantive reduction that
  is safe within the accepted behavior.

## Phase 2.5 Security Review

- Lane: fresh specialist discovery over the accepted scope and current changed
  production surfaces; prior findings and diagnoses were not supplied.
- Attack surfaces: loopback WebSocket/capability handshakes, primary and agent
  authority, SQLite transitions, candidate lifecycle, filesystem/process
  boundaries, validation sandbox, and the vendored Go dependency.
- Verdict: clean. No blocking or significant in-scope security finding.
- Strengths: exact capability and identity binding, transactional authority
  transitions, fixed subprocess argv/minimal environments, isolated candidate
  checkouts, process-group retirement, and bubblewrap validation are fail-closed
  for the accepted disposable PoC boundary.
- Deferred for later (`acknowledged × adjacent`): the owner-only sanitized
  SQLite evidence snapshot is not a general arbitrary-secret scrubber because
  native-review bytes also appear in base64 fields. The fixed disposable fixture
  and current non-production export boundary do not make this an in-scope
  disclosure, but a production/general evidence-export design must address it.
- Supply chain: `github.com/gorilla/websocket v1.5.3` is checksum-pinned and
  vendored; no applicable known issue was identified in the bounded review.
- Phase 2.7 exit: specialist findings are marginal, no fix or re-review is due,
  and no convergence trigger or checkpoint is open. Proceed to Phase 3.

## Phase 3 Native Codex Gate — Epoch 3

### CR-E3-01 — first accepted finding invalidates remaining dispositions

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:accept_and_fix_findings`
- Statement: accepting the first of multiple review findings immediately
  supersedes the current candidate, so every later disposition bound to that
  candidate fails currentness validation.
- Suspected surface: candidate review/disposition lifecycle
- Fix applied: every disposition turn now completes against the unchanged exact
  candidate, then one transaction proves the batch covers every finding in that
  review, persists all dispositions, and supersedes the candidate once when any
  finding was accepted.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-02 — rejected native findings retry a one-shot gate

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:review_candidate`
- Statement: rejecting every structured native finding loops back to native
  review on the unchanged candidate, but the kernel forbids a second native
  execution for that candidate.
- Suspected surface: native-review disposition and retry lifecycle
- Fix applied: an all-rejected native finding batch now closes the one-shot gate
  without another native execution; validation and integration gates recognize
  that exact fully disposed native review as satisfied.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-03 — candidate code can influence the validation oracle

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:validate_candidate`
- Statement: validation starts Python from the candidate checkout without
  isolated startup/import control or fresh trusted scratch state, so candidate
  modules such as `sitecustomize.py` or `unittest.py` can alter controller-owned
  validation and create a false pass.
- Suspected surface: candidate/trusted-validation authority boundary
- Fix applied: trusted baseline validation scripts run under Python `-I -S`, and
  each command receives a fresh controller-created private scratch directory.
  Candidate `sitecustomize.py` and `unittest.py` cannot replace the oracle.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-04 — primary-call durable deadline is not enforced

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:typed_call`
- Statement: a bound primary call persists a five-minute deadline but waits on
  the unrelated 900-second worker timeout, bypassing the specified timeout and
  settlement transition.
- Suspected surface: primary semantic-call temporal enforcement
- Fix applied: the exact persisted five-minute deadline bounds the App Server
  wait. Timeout records one ineligible logical outcome, requests exact-turn
  interrupt, and permits only its truthful persisted 30-second settlement
  window before settlement failure and rebind.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-05 — interrupted role turn ignores its settlement deadline

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:execute_role_quantum`
- Statement: after the role budget closes and interrupt is requested, the
  runtime can wait on the original 900-second worker timeout instead of fencing
  the turn at its required 30-second settlement deadline.
- Suspected surface: role-turn temporal enforcement and failure closure
- Fix applied: count/time frontier closure now persists its 30-second settlement
  deadline, and the collection wait consults that durable deadline. Expiry
  fences as `budget_interrupt_failed`; a pre-frontier global worker timeout
  remains ordinary dispatch/collection failure.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` from CR-E2-06 at a sibling settlement boundary

### CR-E3-06 — revise disposition has no replacement-run transition

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:adopt_run_output`
- Statement: a schema-valid primary `revise` disposition is persisted and then
  treated as a terminal non-adoption; its declared next state is ignored and no
  distinct linked authorized replacement run is created.
- Suspected surface: role-output adoption/revision lifecycle
- Fix applied: `revise` retires the exact settled source run and assignment,
  primes a distinct replacement with source run/output/adoption and typed
  `next_state`, obtains a fresh primary delegation, and continues only in that
  replacement. The source is never reopened.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-07 — effect-capable primary actions can settle successfully

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:typed_call`
- Statement: primary semantic turns record App Server actions but do not reject
  effect-capable item types, allowing valid typed output to become semantic
  authority after a forbidden action attempt.
- Suspected surface: physical-primary action authority boundary
- Fix applied: observed primary actions remain terminal evidence, but only the
  existing read-only `commandExecution` surface is eligible under `phase4-read`.
  Any other item type closes the call as `invalid_output` and cannot authorize
  a semantic transition.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-08 — fenced role failures suppress their attention summary

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:present_attention_summary`,
  `poc/kernel.py:record_stop`
- Statement: role-evidence failure fences the current run as failed, then the
  outer stop path attempts to transition that terminal run again; `record_stop`
  rejects it and replaces the useful recovery summary with a secondary failure.
- Suspected surface: terminal failure closure and presentation
- Fix applied: `record_stop` recognizes the exact already-failed run as the
  terminal state being presented, preserves its original end identity, and
  still records the workflow stop for the attention-summary operation.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` from CR-E1-05 and CR-E2-06 at their composed boundary

### CR-E3-09 — reviewer prompt contradicts its enforced schema

- Review epoch / iteration: 3 / phase-3.1
- Source: `codex review --uncommitted`
- Severity / scope: `significant × in-scope`
- Location: `poc/roles/workflow-correctness-reviewer.md`
- Statement: the role tells the model to return `completed`, while the runtime
  schema requires `verdict` to be `clean`, `findings`, or `blocked` and rejects
  additional fields.
- Suspected surface: reviewer role contract/schema alignment
- Fix applied: plan soundness, plan red-team, correctness, cohesion, and native
  structurer role prompts now name the exact `verdict`, `findings`,
  `artifact_content`, and `summary` contract and its verdict/finding relation.
- Lifecycle: `actioned; pending phase-3 re-review`

### Convergence checkpoint CR-CP-E3-01

- Review epoch: 3
- Triggered at: phase-3.1, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: diagnose the review-lifecycle, temporal-enforcement,
    and trusted-authority clusters and select repair altitude before any fix;
    then run the recorded repair/review continuation
- Trigger: one fresh gate produced eight sibling blocking findings, including
  repeated settlement/failure-closure symptoms from earlier epochs. Applying
  isolated patches risks preserving the same missing transition model.
- Evidence clusters:
  - CR-E3-01, CR-E3-02, and CR-E3-06: valid dispositions lack complete next-state
    transitions across candidate and run lifecycles.
  - CR-E3-04, CR-E3-05, and CR-E3-08: durable deadlines or terminal states exist
    but their runtime composition does not enforce the specified closure path.
  - CR-E3-03 and CR-E3-07: untrusted candidate/physical-primary behavior can
    enter trusted evidence without enforcing the accepted authority boundary.
  - CR-E3-09: the producer contract and deterministic consumer schema disagree.
- Diagnosis: `pending`
- Diagnosis: `local-design-flaw` (high confidence). Across all three clusters,
  the implementation durably records the accepted contract but its consuming
  orchestration path does not fully enforce the corresponding sequence,
  deadline, terminal-state, or trust-boundary transition. This is the same
  deeper pattern as earlier epochs: durable existence is being mistaken for
  authority, eligibility, or completed transition closure.
- Action: apply one implementation-altitude repair set: complete candidate/run
  disposition transitions, make runtime waits consume durable deadlines, make
  stop presentation compose with already-terminal runs, enforce existing
  validation/primary-action trust boundaries, and align producer prompts with
  deterministic schemas. Add focused negative tests, then resume the Phase 3
  gating continuation on the complete diff.
- Status: `actioned`
- Status evidence: independent `review-convergence-analyst` diagnosis confirmed
  that `poc/PLAN.md` already explicitly specifies every required behavior. No
  product decision, requirement clarification, scope expansion, architecture
  change, renewed Plan Review, or new generic lifecycle/protocol is required.

### Phase 3 resolution decision note

- Triggering cluster: CR-E3-01 through CR-E3-09.
- Candidate repair: one bounded implementation correction across existing
  review disposition, role revision, primary/role deadline settlement,
  terminal-stop presentation, validation isolation, primary action eligibility,
  and reviewer prompt/schema sites.
- Material semantic-surface delta: no new product behavior or authority model;
  only missing plan-defined transitions/checks plus focused proof. A generic
  transition framework is explicitly excluded as unnecessary new surface.
- Selected repair altitude: `implementation`.
- Next action: apply the clustered fix, mark entries `actioned`, run focused and
  full offline validation, then rerun Phase 3 discovery on the complete diff.

### Phase 3 repair checkpoint

- CR-E3-01 through CR-E3-09 were repaired as one implementation-altitude
  transition-enforcement set without changing the accepted product, scope, or
  architecture and without adding a generic lifecycle framework.
- Focused proof covers complete-set finding disposition, rejected-native
  one-shot eligibility, isolated validation startup and fresh scratch, primary
  persisted-deadline waiting and timeout settlement including interrupt-send
  failure, role frontier settlement deadline, effect-capable primary action
  rejection, already-failed stop presentation, exact reviewer schema prompts,
  and linked run revision.
- Offline validation: all 185 Python tests pass with one
  outer-sandbox-dependent skip; Go transport tests, Python bytecode compilation,
  and `git diff --check` pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — second discovery pass

### CR-E3-10 — presentation-host failures collapse into ordinary detach

- Review epoch / iteration: 3 / phase-3.2
- Source: `codex review --uncommitted`, Codex session
  `019fdca5-a78b-71f1-8400-08e63b0c105f`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:start_presentation_host`
- Statement: an exception from the downstream-session handler terminates the
  daemon host and signals only ordinary detach. Attach, input, and render
  waiters can then retry or time out against a host that no longer exists
  instead of surfacing the original hard failure.
- Suspected surface: presentation-host failure ownership and waiter wake-up
- Fix applied: the host stores the first exact exception, records it once, and
  wakes attachment/detachment waiters. Attach, primary-completion, input-gate,
  input-capture, render, detach, and reattach paths check that state before
  interpreting an event as ordinary presentation lifecycle.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` from E7-NATIVE-011 after the workflow rewrite

### CR-E3-11 — finalization can race a live presentation host

- Review epoch / iteration: 3 / phase-3.2
- Source: `codex review --uncommitted`, Codex session
  `019fdca5-a78b-71f1-8400-08e63b0c105f`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:stop_presentation_host`
- Statement: shutdown performs bounded joins but does not prove the acceptor
  and host stopped. A host blocked on an upstream acknowledgement can therefore
  remain an ordinary evidence/database writer while finalization exports and
  closes those resources.
- Suspected surface: presentation-owner quiescence before final evidence
- Fix applied: acknowledgement-turn waiting polls the stop frontier; shutdown
  closes admission, the active socket, listener, and queued sessions before
  joining, then requires both acceptor and host threads to be dead. Final
  evidence export and database closure are skipped if any presentation owner
  remains live.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` from E7-NATIVE-012 at the rewritten owner boundary

### CR-E3-12 — PTY hard-kill fallback can orphan the Codex child session

- Review epoch / iteration: 3 / phase-3.2
- Source: `codex review --uncommitted`, Codex session
  `019fdca5-a78b-71f1-8400-08e63b0c105f`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:NativeCliPrimaryInterface.stop_process`
- Statement: when the PTY driver ignores the graceful timeout, the controller
  kills only that driver. Its `setsid()` Codex child can survive, retain the
  sole presentation connection, and make the replacement attach fail as a
  simultaneous client.
- Suspected surface: replaceable CLI process-tree ownership
- Fix applied: every PTY driver publishes a generation-bound driver PID and
  inner Codex session PGID, then records `reaped` only after its direct child is
  reaped. The hard fallback kills that exact inner group and still requires the
  driver's reaping proof plus no live group member before replacement.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: sibling of CR-E3-10/CR-E3-11 at presentation retirement

### Convergence checkpoint CR-CP-E3-02

- Review epoch: 3
- Triggered at: phase-3.2, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: diagnose the repeated presentation ownership and
    quiescence cluster, select repair altitude, then resume the hard gate
- Trigger: the fresh holistic gate found two blocking and one significant
  lifecycle findings, including regressions of earlier presentation-owner
  findings after the workflow rewrite.
- Evidence cluster: CR-E3-10 through CR-E3-12 all concern a physical
  presentation generation being treated as retired before its host and full
  process tree have either terminated or exposed a terminal failure.
- Diagnosis: `local-design-flaw` (high confidence). All three paths treat a
  proxy as proof that the physical presentation retired: detach stands in for
  host health, a timed join stands in for thread termination, and PTY-driver
  exit stands in for termination of its separately owned Codex session.
- Repair altitude: `implementation`. The accepted architecture already requires
  visible failure, replaceable presentation, and one current physical
  presentation. No product decision, plan change, generic lifecycle framework,
  or renewed Plan Review is required.
- Action: store and propagate one exact host failure to every presentation
  waiter; make acknowledgement waiting stop-aware and prove host/acceptor
  quiescence before finalization; bind every PTY generation to its inner session
  identity and require verified termination/reaping before reattach.
- Status: `actioned; implementation in progress`
- Status evidence: independent `review-convergence-analyst` confirmed the
  shared ownership/quiescence flaw and found no additional finding or scope
  expansion.

### Phase 3 presentation-owner repair checkpoint

- CR-E3-10 through CR-E3-12 were repaired as one implementation-altitude
  ownership/quiescence correction. No new durable protocol, authority, product
  behavior, or generic supervisor was added.
- Focused proof covers exact host-failure propagation to completion/render/input
  waiters, prompt acknowledgement cancellation at shutdown, PTY hard fallback
  ordering, and driver-owned child-session termination/reaping.
- Offline validation: the complete 188-test Python suite succeeds (including
  the pre-existing outer-sandbox-dependent skip); Go transport tests and
  `go vet`, Python compilation, shell syntax/ShellCheck, and `git diff --check`
  pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — third discovery pass

### CR-E3-13 — semantic primary dispatch can use a fenced binding during rebind

- Review epoch / iteration: 3 / phase-3.3
- Source: `codex review --uncommitted`, Codex session
  `019fdcbf-c2b8-71b1-9a19-45fd7967ae2b`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:typed_call`
- Statement: while the durable primary state is `rebinding`, an ordinary
  semantic primary call is dispatched without a physical-attempt journal. In
  the planned-rebind path, independent role progress reaches
  `role_output_adoption` before the replacement binding is installed, so the
  already-fenced old primary can still make a decision that advances work.
- Suspected surface: semantic primary admission across physical rebind
- Required outcome: independent role work may settle while rebinding, but its
  semantic adoption must wait for an active installed binding; every ordinary
  semantic primary dispatch must bind a durable physical attempt, and terminal
  no-primary states must reject dispatch.
- Fix applied: role-turn settlement can now persist an exact deferred adoption;
  the planned-rebind inflection uses it, catches the replacement up, installs
  the new binding, then performs the normal adoption and only afterward writes
  its dependent checkpoint. Every non-binding-control primary call now rejects
  unless primary state is `active`, and therefore cannot reach `model.call`
  without a durable physical attempt.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` trust/authority-boundary symptom from CR-E3-07

### CR-E3-14 — native raw anchors can be synthesized across output streams

- Review epoch / iteration: 3 / phase-3.3
- Source: `codex review --uncommitted`, Codex session
  `019fdcbf-c2b8-71f1-8400-08e63b0c105f`
- Severity / scope: `significant × in-scope`
- Location: `poc/kernel.py:record_review`
- Statement: native provenance joins stdout and stderr with a newline before
  checking each anchor. An anchor made from the end of stdout plus the start of
  stderr can therefore pass even though it occurs in neither original stream.
- Suspected surface: exact native-review source provenance
- Required outcome: each raw anchor must occur wholly in decoded stdout or
  wholly in decoded stderr from the exact native execution.
- Fix applied: decoded stdout and stderr remain separate authoritative byte
  streams; every anchor must occur wholly in at least one of them.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `new`, local exact-membership defect

### Convergence checkpoint CR-CP-E3-03

- Review epoch: 3
- Triggered at: phase-3.3, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: diagnose whether CR-E3-13 and CR-E3-14 share or
    repeat an underlying flaw, select repair altitude, then apply the bounded
    repair and resume the hard gate
- Trigger: the fresh holistic gate found one blocking authority failure and one
  significant provenance-membership failure after the prior repair pass.
- Diagnosis: `no-common-root-cause` (high confidence). CR-E3-13 repeats the
  earlier transition-enforcement flaw: durable state says `rebinding`, but the
  semantic-call consumer does not enforce that state before dispatch. CR-E3-14
  is an independent local membership defect caused by composing two
  authoritative byte streams into a synthetic third stream.
- Repair altitude: `implementation` for both. The accepted plan already permits
  independent work to settle while primary-dependent adoption waits, requires
  every ordinary semantic primary call to use an active journaled binding, and
  requires exact raw-source anchors. No product decision, architecture change,
  new schema field, or renewed Plan Review is required.
- Action: separate role-output settlement from adoption only at the rebind
  inflection, resume that exact adoption after replacement install, reject all
  ordinary semantic primary dispatch without an active binding, and check raw
  anchors independently against stdout and stderr. Add focused negative and
  ordering proofs, then resume the Phase 3 gate.
- Status: `actioned; implementation in progress`
- Status evidence: independent `review-convergence-analyst` found no shared root
  and no additional finding or scope expansion.

### Phase 3 binding-admission and native-anchor repair checkpoint

- CR-E3-13 and CR-E3-14 were repaired at implementation altitude without a
  product, plan, schema, or architecture change.
- Focused proof shows semantic dispatch is rejected in `rebinding` and terminal
  `rebind_failed` states before any model call, the independent role output is
  adopted only after replacement-install confirmation, every ordinary primary
  call in the complete narrative has a physical-attempt identity, and a
  cross-stream synthetic anchor fails while same-stream anchors pass.
- Offline validation: all 190 Python tests pass with one expected
  outer-sandbox-dependent skip; Go transport tests and `go vet`, Python
  compilation, shell syntax, and `git diff --check` pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — fourth discovery pass

### CR-E3-15 — prompt-only roles reject their own input items

- Review epoch / iteration: 3 / phase-3.4
- Source: `codex review --uncommitted`, Codex session
  `019fdcd3-fdf5-7a10-88d3-01aca2d30a5c`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:ControllerModelRuntime.call`
- Statement: the prompt-only verifier/structurer check accepts reasoning, plan,
  and agent output but rejects ordinary `userMessage` and `hookPrompt` items.
  Mandatory semantic confirmation or native structuring can therefore fail on
  its own input rather than persist an outcome.
- Required outcome: prompt-only turns accept their ordinary non-action input and
  output item types while continuing to reject every tool/effect surface.
- Fix applied: verifier, native-review projection, and budget-checkpoint paths
  now share one exact non-prompt-item classifier. Ordinary `userMessage`,
  `hookPrompt`, reasoning, plan, and agent-output items are accepted; unknown or
  executable item types remain forbidden.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-16 — high-stakes proposal presentation lacks render-completion proof

- Review epoch / iteration: 3 / phase-3.4
- Source: `codex review --uncommitted`, Codex session
  `019fdcd3-fdf5-7a10-88d3-01aca2d30a5c`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:NativeCliPrimaryInterface.present_decision`
- Statement: a hidden primary turn's proposal is written directly to parent
  stdout, `proposal_id` is ignored, and the method returns without waiting for a
  proposal-bound render sequence. The proposal can be marked presented and
  input opened before verified complete rendering.
- Required outcome: proposal presentation binds its exact proposal identity to
  completed rendering in the current presentation before input admission.
- Fix applied: the interface writes a generation-bound proposal control record
  containing the terminal-safe content and its digest. The PTY owner writes the
  exact bytes, waits its render-settle interval, and publishes a receipt bound to
  proposal ID, content digest, generation, and monotonically newer render
  sequence. The interface waits for that exact receipt before returning.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-17 — launcher termination bypasses in-process finalization

- Review epoch / iteration: 3 / phase-3.4
- Source: `codex review --uncommitted`, Codex session
  `019fdcd3-fdf5-7a10-88d3-01aca2d30a5c`
- Severity / scope: `blocking × in-scope`
- Location: `poc/run-prototype.sh:cleanup`
- Statement: on SIGTERM/SIGINT, the EXIT trap sends SIGTERM directly to the
  prototype process group. Python has no handled interruption path, so it can
  terminate without unwinding durable finalization, capability revocation,
  database export, or ordinary child cleanup.
- Required outcome: ordinary termination first reaches a handled in-process
  interruption and is allowed to unwind; a hard group kill remains only the
  bounded fallback.
- Fix applied: TERM/INT now enter a handled Python interruption path that runs
  the normal `finally` finalizer. The launcher signals the prototype PID first,
  waits boundedly for that unwind, and uses process-group TERM/KILL only as the
  fallback.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-18 — follow-up reads can fence a completed mutation identity

- Review epoch / iteration: 3 / phase-3.4
- Source: `codex review --uncommitted`, Codex session
  `019fdcd3-fdf5-7a10-88d3-01aca2d30a5c`
- Severity / scope: `significant × in-scope`
- Location: `poc/controller.py:request timeout bookkeeping`
- Statement: a follow-up `thread/read` may reuse the completed mutation's
  operation ID. If the read times out, timeout and late-response reconciliation
  can rewrite/fence that already-succeeded mutation and its outbox or replace
  its original response.
- Required outcome: observation/read requests have their own request identity
  and cannot mutate the terminal state or evidence of the operation they inspect.
- Fix applied: thread confirmation reads no longer reuse the inspected
  mutation's operation ID. Kernel timeout fencing is additionally limited to a
  mutation still in `dispatching`, so a terminal or effect-confirmed mutation
  cannot be downgraded by a mislabeled later request.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-19 — failed child cleanup does not block database finalization

- Review epoch / iteration: 3 / phase-3.4
- Source: `codex review --uncommitted`, Codex session
  `019fdcd3-fdf5-7a10-88d3-01aca2d30a5c`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:main finalization`
- Statement: `cleanup_children()` returning false changes only the exit code;
  finalization still records `ordinary_writers_stopped`, exports the database,
  and closes the kernel while an App Server reader or child may remain live.
- Required outcome: final snapshot/export/close occurs only after all ordinary
  child/reader writers are proven quiescent.
- Fix applied: finalization aggregates presentation-owner and ordinary-child
  quiescence. A false or exceptional child cleanup result suppresses the
  `ordinary_writers_stopped` boundary, stderr snapshot, database export, and
  explicit kernel close rather than publishing a false final snapshot.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` owner-quiescence symptom from CR-E3-11/CR-E3-12

### CR-E3-20 — partial native-CLI construction can lose process ownership

- Review epoch / iteration: 3 / phase-3.4
- Source: `codex review --uncommitted`, Codex session
  `019fdcd3-fdf5-7a10-88d3-01aca2d30a5c`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:main / NativeCliPrimaryInterface.__init__`
- Statement: construction spawns and attaches the PTY before the caller assigns
  `native_interface`. A fallible attach/completion/render step can leave the
  driver and separately sessioned Codex child alive while finalization assumes
  no interface owner exists.
- Required outcome: ownership is established before fallible startup, and any
  partial construction is explicitly stopped before finalization.
- Fix applied: native-interface construction is now side-effect-free; the
  caller assigns the owner before invoking fallible `attach()`, so the normal
  finalizer can stop a partially attached PTY and its separately sessioned Codex
  child.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` owner-retirement symptom from CR-E3-12

### Convergence checkpoint CR-CP-E3-04

- Review epoch: 3
- Triggered at: phase-3.4, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: cluster the six findings, identify repeated roots,
    select repair altitude, then apply the bounded repair and resume the gate
- Trigger: the fresh holistic pass found three blocking happy-path/finalization
  defects and three significant lifecycle/journaling defects.
- Diagnosis: `no-common-root-cause` (high confidence). CR-E3-15 is local
  prompt-item classification drift. CR-E3-16 repeats the weaker-proxy-for-proof
  flaw at the presentation boundary. CR-E3-17, CR-E3-19, and CR-E3-20 share the
  repeated owner/quiescence flaw from CR-E3-10 through CR-E3-12. CR-E3-18 is an
  independent mutation-versus-observation identity conflation.
- Repair altitude: `implementation` for all four clusters. The accepted
  architecture already requires prompt-only roles, proposal-bound presentation,
  orderly shutdown, proven writer quiescence, and durable mutation identity. No
  product decision, plan change, schema expansion, or renewed Plan Review is
  required.
- Action: share the non-action classifier; add exact proposal render control and
  receipt; make interface ownership two-phase and shutdown signal-aware; gate
  final export on aggregate quiescence; detach confirmation reads from mutation
  timeout identity and guard terminal mutations from timeout downgrade.
- Status: `actioned; implementation complete, pending hard-gate re-review`
- Status evidence: independent `review-convergence-analyst` found four bounded
  implementation clusters and no architecture or product decision to reopen.

### Phase 3 prompt, presentation, shutdown, and request-identity repair checkpoint

- CR-E3-15 through CR-E3-20 were repaired at implementation altitude without a
  product, plan, or durable-schema change.
- Focused proof covers ordinary prompt items versus executable items, exact
  proposal-bound render receipts, side-effect-free interface construction,
  handled TERM finalization, cleanup-refusal suppression of false final
  snapshots, distinct confirmation-read identity, and terminal mutation state
  preservation.
- Offline validation: all 196 Python tests pass with one expected
  outer-sandbox-dependent skip; Go transport tests and `go vet`, Python
  compilation, shell syntax/ShellCheck, and `git diff --check` pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — fifth discovery pass

### CR-E3-21 — reconsideration presentations omit their proposal identity

- Review epoch / iteration: 3 / phase-3.5
- Source: `codex review --uncommitted`, Codex session
  `019fdcf9-f3d2-7a21-ba64-5a8af990d189`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:wait_for_reconsideration` and
  `wait_for_intent_revision_reconsideration`
- Statement: both no-effect pause paths call `present_decision` without a
  proposal ID even though the live native interface rejects any decision
  presentation without that identity. Rejection, clarification, or verifier
  failure therefore raises before the user can receive the pause or provide
  fresh direction.
- Required outcome: every reconsideration presentation carries the exact
  durable paused proposal identity.
- Fix applied: both reconsideration pause presentations now pass the exact
  durable paused `proposal_id`; strict native-semantics regressions cover the
  ordinary high-stakes and intent-revision pause paths.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: incomplete propagation of the CR-E3-16 proposal-identity
  repair to its reconsideration call sites

### CR-E3-22 — evidence redaction changes operational proposal bytes

- Review epoch / iteration: 3 / phase-3.5
- Source: `codex review --uncommitted`, Codex session
  `019fdcf9-f3d2-7a21-ba64-5a8af990d189`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:NativeCliPrimaryInterface.present_decision`
- Statement: proposal control uses the evidence-redacting JSON writer. A valid
  presentation containing an email or credential-like text is changed after
  its digest is computed, so the PTY rejects the control object and cannot
  publish the required render receipt.
- Required outcome: owner-only operational control preserves the exact
  terminal-safe presentation bytes; any redacted evidence copy is separate.
- Fix applied: proposal control now uses a distinct owner-only operational JSON
  writer with no evidence transform, preserving terminal-safe presentation
  bytes and their SHA-256 exactly even for email/password-like text.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: repeated exact-operational-representation versus redacted-
  evidence boundary from E7-NATIVE-009

### CR-E3-23 — JSON evidence is redacted twice and can become invalid

- Review epoch / iteration: 3 / phase-3.5
- Source: `codex review --uncommitted`, Codex session
  `019fdcf9-f3d2-7a21-ba64-5a8af990d189`
- Severity / scope: `blocking × in-scope`
- Location: `poc/evidence.py:secure_write_json`
- Statement: the helper deep-redacts the value, serializes it, then sends that
  serialization through text redaction again. Text such as `password=abc`
  can make the second pass consume JSON syntax and leave an unreadable file.
- Required outcome: deep-redact once and write the resulting JSON serialization
  directly through the owner-only file primitive.
- Fix applied: JSON evidence is deep-redacted exactly once, serialized once,
  and written directly through the owner-only file primitive; a regression
  parses email/password-like evidence back as valid redacted JSON.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: same representation-boundary cluster as CR-E3-22

### CR-E3-24 — review artifacts may be empty despite the role contract

- Review epoch / iteration: 3 / phase-3.5
- Source: `codex review --uncommitted`, Codex session
  `019fdcf9-f3d2-7a21-ba64-5a8af990d189`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:review_schema`
- Statement: `artifact_content` accepts an empty string and the kernel has no
  second non-empty check, while every reviewer role requires a non-empty review
  artifact. An empty artifact can therefore satisfy a review gate.
- Required outcome: the structured review contract rejects empty artifact
  content before it can be persisted or satisfy a gate.
- Fix applied: review and closure schemas require `artifact_content` with
  `minLength: 1`, and both durable recording boundaries independently reject a
  missing or empty artifact before persistence.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: repeated producer/consumer contract drift from CR-E3-09

### CR-E3-25 — recorded native commands disagree with executed commands

- Review epoch / iteration: 3 / phase-3.5
- Source: `codex review --uncommitted`, Codex session
  `019fdcf9-f3d2-7a21-ba64-5a8af990d189`
- Severity / scope: `significant × in-scope`
- Location: `poc/qualification_pty_tui.py`, `poc/pty_tui.py`, and the two native
  CLI launchers
- Statement: retained qualification evidence records `xhigh` while its launcher
  executes `low`; ordinary PTY evidence omits the permission profile and
  `xhigh` flags its launcher executes. The persisted expanded commands are not
  exact provenance for the child processes.
- Required outcome: each driver records the exact stock argv that its launcher
  executes from one synchronized definition.
- Fix applied: `poc/native_command.py` is the single argv builder and execution
  source consumed by both launchers and both PTY evidence renderers. The
  qualification path remains `low` with the `codex-cli 0.146.0` pin; the
  ordinary prototype path remains `xhigh`. Qualification provenance and final
  assertion roles now bind the shared source.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: direct recurrence of E3-CR-006

### Convergence checkpoint CR-CP-E3-05

- Review epoch: 3
- Triggered at: phase-3.5, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: diagnose the five findings across prior review
    history, select repair altitude, then apply the bounded repair and resume
    the hard gate
- Trigger: the fifth holistic pass found three blocking live-path/data-format
  failures and two significant contract/provenance mismatches.
- Source-integrity check: the review process left the workspace unchanged. The
  pre/post unstaged tracked-diff SHA-256 remained
  `11b4037624cc10b3bbbdb2a18539e914fd33ef0632e789982d137148ed4b4129`,
  and the untracked aggregate remained
  `3eca0346157a41a0884edfca08617882b0fc0b94520e008f5e6de630f11d46e3`.
- Diagnosis: `no-common-root-cause` (high confidence). CR-E3-21 and CR-E3-24
  share contract-propagation drift: a strengthened consumer invariant did not
  reach every call site or deterministic schema/recording boundary. CR-E3-22
  and CR-E3-23 share an exact-representation boundary error: runtime control
  bytes and publishable redacted evidence use the same transform. CR-E3-25 is
  the repeated command-provenance drift caused by reconstructing evidence next
  to, rather than from, the executed argv.
- Repair altitude: `implementation` for all three clusters. Pass existing
  proposal identity through both pause paths; enforce non-empty review artifacts
  in schemas and the persistence boundary; split exact owner-only control JSON
  from once-redacted evidence JSON; and give executed and recorded Codex argv
  one source of truth. No product, plan, architecture, durable-schema, or user-
  visible behavior decision needs reopening.
- Status: `diagnosed; bounded implementation repair authorized by the active
  code-review flow`.
- Status evidence: independent `review-convergence-analyst` found no additional
  finding and no scope expansion.

### Phase 3 fifth-gate repair checkpoint

- CR-E3-21 through CR-E3-25 were repaired at implementation altitude without a
  product, plan, architecture, or durable-schema change.
- Focused proof covers strict proposal identity at both reconsideration paths,
  exact operational proposal bytes and digest for email/password-like text,
  once-redacted valid JSON evidence, non-empty review/closure artifacts at both
  schema and persistence boundaries, shared exact native argv, mode-specific
  reasoning effort, qualification version pinning, and provenance binding.
- Offline validation: all 202 Python tests pass with one expected
  outer-sandbox-dependent skip; Go transport tests and `go vet`, Python
  compilation, Bash syntax, ShellCheck with the pre-existing indirect-trap
  `SC2317` diagnostic excluded, and `git diff --check` pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — sixth discovery pass

### CR-E3-26 — the normal launcher and Python entry point both create the evidence directory

- Review epoch / iteration: 3 / phase-3.6
- Source: `codex review --uncommitted`, Codex session
  `019fdd19-ff3a-7012-b6f4-885def30cb1e`
- Severity / scope: `blocking × in-scope`
- Location: `poc/run-prototype.sh:24` and `poc/prototype.py:main`
- Statement: the launcher creates the run-specific evidence directory before
  starting Python, but `main()` then calls `mkdir()` for the same path without
  `exist_ok=True`. Every normal launcher invocation therefore raises
  `FileExistsError` before controller initialization.
- Required outcome: the launcher-owned evidence directory is accepted by the
  Python entry point without weakening the unique run-path or owner-only
  permissions boundary.
- Fix applied: the launcher remains the sole creator and pre-existing-run
  rejector. The Python entry point now requires that exact path to already be a
  direct directory owned by the current user with mode `0700`, then proceeds to
  initialization without a second exclusive create.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: new local initialization-ownership mismatch; not a recurrence
  of the shutdown/quiescence cluster

### CR-E3-27 — the documented candidate validation command discovers no contract tests

- Review epoch / iteration: 3 / phase-3.6
- Source: `codex review --uncommitted`, Codex session
  `019fdd19-ff3a-7012-b6f4-885def30cb1e`
- Severity / scope: `significant × in-scope`
- Location: `poc/fixture/PROTOTYPE_WORK_ITEM.md:18`
- Statement: the work item still directs the implementer to run
  `python3 -m unittest discover -v`, but default discovery ignores the renamed
  `candidate_contract.py`; in the fixture this runs zero tests and exits 5.
- Required outcome: the documented attempt-one validation command executes the
  exact retained contract suite that the authoritative validation path uses.
- Fix applied: the work item now names
  `python3 -I -S candidate_contract.py`, matching the authoritative isolated
  validation entry point while retaining exclusion from general source-tree
  discovery.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: direct propagation sibling of E13-NATIVE-009 and E13-CR-010;
  the candidate-only suite was renamed correctly, but its user-facing command
  remained stale

### Convergence checkpoint CR-CP-E3-06

- Review epoch: 3
- Triggered at: phase-3.6, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: assess both findings against prior review history,
    select repair altitude, apply only the bounded correction, and rerun the
    hard gate
- Trigger: the sixth holistic pass found one blocking happy-path startup defect
  and one significant executable-documentation mismatch.
- Source-integrity check: the review process left the workspace unchanged. The
  pre/post complete HEAD diff SHA-256 remained
  `7010da95c158b4188a555a096ea770c9674196847165a9c9b93f9ecc4ae861bf`,
  the unstaged tracked-diff SHA-256 remained
  `4dc56ef36a214ee57349a25a651056d18bf3a5428c342eea9c2d4cc9ac37d1c3`,
  the staged diff SHA-256 remained
  `6d54b02817d3d076bf1b8ba555e1b42a5068ed7f1471e9ac86bac31ca99ff0cf`,
  the untracked aggregate remained
  `f24734d156a6f215a21b243f0b83f18bc76e6c942839051cc8d2e8f6a6eb4c17`,
  and the status SHA-256 remained
  `2f9039be0d58be3e8de86c2f9c1dfdfffe09327c7e8525344a9a3727c3061371`.
- Diagnosis: `no-common-root-cause` (high confidence). CR-E3-26 is a new local
  initialization-order/ownership mismatch: the launcher must create the unique
  owner-only evidence path for pre-Python evidence, while Python must validate
  and use it rather than create it exclusively again. CR-E3-27 is a direct
  propagation sibling of E13-NATIVE-009/E13-CR-010: the suite was deliberately
  renamed so source-wide discovery excludes candidate-only tests, but the
  work-item command did not change to the explicit candidate validation entry
  point.
- Repair altitude: `implementation` for both findings. Preserve launcher
  ownership and pre-existing-run rejection; make Python accept only the
  launcher-created owner-only directory. Document the exact isolated contract
  command already used by authoritative candidate validation; do not rename the
  suite back or restore generic discovery. No product, plan, architecture, or
  durable-schema decision needs reopening.
- Status: `diagnosed; bounded implementation repair authorized by the active
  code-review flow`.
- Status evidence: independent `review-convergence-analyst` found two separate
  local contract mismatches and no scope expansion.

### Phase 3 sixth-gate repair checkpoint

- CR-E3-26 and CR-E3-27 were repaired at implementation altitude without a
  product, plan, architecture, or durable-schema change.
- Focused proof covers launcher-created `0700` evidence reaching mocked
  controller initialization, missing/wrong-mode/symlink evidence rejection,
  the existing orderly-signal path, exact execution of both candidate contract
  tests from the documented command, and continued rejection of a missing
  candidate program.
- Offline validation: all 205 Python tests pass with one expected
  outer-sandbox-dependent skip; Python compilation, Bash syntax, ShellCheck
  with the established indirect-trap `SC2317` diagnostic excluded, and
  `git diff --check` pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — seventh discovery pass

### CR-E3-28 — PTY relay can truncate authoritative user input

- Review epoch / iteration: 3 / phase-3.7
- Source: `codex review --uncommitted`, Codex session
  `019fdd29-eb51-7691-bb1b-c2e908140882`
- Severity / scope: `blocking × in-scope`
- Location: `poc/pty_tui.py:350`
- Statement: the input-open relay writes captured user bytes to the stock CLI
  with one unchecked `os.write()`. A partial PTY write silently drops the
  suffix even though the resulting turn is treated as authoritative opaque
  user input.
- Required outcome: relay every captured byte or fail; never publish a
  silently truncated user message as authoritative input.
- Fix applied: the relay's single exact-write primitive now owns every terminal
  and input write, retrying short writes and failing on zero progress. A forced-
  short-write regression proves the complete authoritative byte string is
  forwarded, and a zero-progress regression proves explicit failure.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: pending assessment against prior exact-byte and authoritative-
  input findings

### CR-E3-29 — timeout-race fallback returns an upstream failure as data

- Review epoch / iteration: 3 / phase-3.7
- Source: `codex review --uncommitted`, Codex session
  `019fdd29-eb51-7691-bb1b-c2e908140882`
- Severity / scope: `significant × in-scope`
- Location: `poc/controller.py:785`
- Statement: if the upstream reader clears a pending request and enqueues its
  failure exactly as the request wait times out, the race fallback returns the
  exception object instead of raising it as the ordinary delivery path does.
  Dict-oriented callers then fail with unrelated secondary errors.
- Required outcome: the timeout-race fallback must preserve the same exception
  semantics as ordinary waiter delivery.
- Fix applied: one `unwrap_request_result()` primitive now interprets results
  from both the blocking dequeue and timeout-race fallback. A deterministic
  race test proves identical queued-success return and queued-failure raise
  behavior.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: pending assessment against prior timeout, late-response, and
  transport-settlement findings

### CR-E3-30 — qualification run IDs can escape the evidence root

- Review epoch / iteration: 3 / phase-3.7
- Source: `codex review --uncommitted`, Codex session
  `019fdd29-eb51-7691-bb1b-c2e908140882`
- Severity / scope: `significant × in-scope`
- Location: `poc/run.sh:11`
- Statement: unlike the ordinary launcher, the qualification launcher accepts
  path components in `RUN_ID`. A value such as `../outside` makes `install -d`
  create and chmod a directory outside `poc/evidence` before a later command
  rejects the run.
- Required outcome: reject every run ID that is not one safe filename
  component before constructing or creating an evidence path.
- Fix applied: both launchers now enforce the same safe-component grammar,
  including explicit `.` and `..` rejection, before any run-derived path or
  filesystem effect. One negative matrix runs both launchers against empty,
  traversal, slash, whitespace, and punctuation cases and proves the filesystem
  remains unchanged.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: pending assessment against prior launcher and filesystem-
  boundary findings

### Convergence checkpoint CR-CP-E3-07

- Review epoch: 3
- Triggered at: phase-3.7, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: diagnose the three findings across the accumulated
    review history, select repair altitude, apply only the bounded correction,
    and rerun the hard gate
- Trigger: the seventh holistic pass found one blocking exact-input defect and
  two significant error/path-boundary defects despite the offline suite
  passing.
- Source-integrity check: the review process left the workspace unchanged. The
  pre/post complete HEAD diff SHA-256 remained
  `ec00c2e9290cf03f4ec393953629838b7b458ac826661f3607eb26c30d466009`,
  the unstaged tracked-diff SHA-256 remained
  `6e23111b64b3acb36a1e05c167b1864c40637fdc3efad6d202dc6297432e1682`,
  the staged diff SHA-256 remained
  `6d54b02817d3d076bf1b8ba555e1b42a5068ed7f1471e9ac86bac31ca99ff0cf`,
  the untracked aggregate remained
  `f24734d156a6f215a21b243f0b83f18bc76e6c942839051cc8d2e8f6a6eb4c17`,
  and the status SHA-256 remained
  `040b461ac57bbc008a10d15b65b1445a7114ce55440c0ca43cc9330c6279a2d4`.
- Diagnosis: `local-design-flaw` (high confidence). All three findings are
  parity failures where an accepted invariant exists on one path but sibling
  paths bypass it because enforcement remains call-site-local. CR-E3-28 is a
  direct sibling of the exact-human-byte family (CR-E3-16/22): proposal output
  uses the exact-write primitive while authoritative input does not. CR-E3-29
  repeats the CR-007/010/013 and CR-E3-18 settlement family: one request
  boundary interprets the same queued result differently on its blocking and
  timeout-race exits. CR-E3-30 is launcher-boundary validation drift: the
  ordinary launcher validates its run ID before path construction while the
  qualification launcher does not.
- Repair altitude: `implementation`, with a boundary-level correction rather
  than three isolated line edits. Make exact writes compulsory across PTY relay
  byte paths; unwrap request results through one primitive on both dequeue
  exits; and enforce one safe single-component run-ID admission invariant
  before either launcher constructs or mutates a path. Audit sibling call sites
  and add forced-short-write, timeout-race success/failure, and both-launcher
  rejection/no-effect regressions. No new protocol, durable state, product
  decision, plan revision, or generic boundary framework is justified.
- Status: `diagnosed; bounded implementation repair authorized by the active
  code-review flow`.
- Status evidence: independent `review-convergence-analyst` found one local
  parity-design class across three separate owning boundaries and no scope
  expansion.

### Phase 3 seventh-gate repair checkpoint

- CR-E3-28 through CR-E3-30 were repaired at implementation altitude without a
  product, plan, architecture, protocol, or durable-schema change.
- Focused proof covers complete retry of forced short terminal/input writes,
  explicit zero-progress failure, timeout-race success and exception parity,
  and both launchers rejecting unsafe run IDs before any filesystem effect.
- Offline validation: all 208 Python tests pass with one expected
  outer-sandbox-dependent skip; Python compilation, Bash syntax, ShellCheck
  with the established indirect-trap `SC2317` diagnostic excluded, Go tests,
  `go vet`, and `git diff --check` pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — eighth discovery pass

### CR-E3-31 — rejected checkpoint dispatch can leave a live unowned turn

- Review epoch / iteration: 3 / phase-3.8
- Source: `codex review --uncommitted`, Codex session
  `019fdd3e-396c-7751-85ea-cef6f82182f1`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:5724-5728`
- Statement: the budget-checkpoint `turn/start` is dispatched before
  `start_budget_checkpoint_turn()` verifies and records the exact interrupted
  frontier. If the durable admission rejects, the physical turn remains live
  without a `role_turns` authority record, and the existing cleanup path cannot
  interrupt it because it only aborts an existing row.
- Required outcome: reserve exact checkpoint authority before dispatch and bind
  the returned turn, or explicitly terminate every turn whose post-dispatch
  durable admission fails.
- Fix applied: budget checkpoints now reserve the exact settled interrupted
  frontier before any physical dispatch and bind only the exact returned turn.
  A stale-frontier regression proves that only the original interrupted turn
  was dispatched and no checkpoint `turn/start` occurred.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: pending assessment against prior role-turn authority,
  interruption, settlement, and fencing findings

### CR-E3-32 — post-dispatch setup failure fences state but not the physical turn

- Review epoch / iteration: 3 / phase-3.8
- Source: `codex review --uncommitted`, Codex session
  `019fdd3e-396c-7751-85ea-cef6f82182f1`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:5564-5569`
- Statement: after `turn/start` succeeds, a failure in
  `bind_role_turn_dispatch()` or `register_role_turn_monitor()` leaves an exact
  physical App Server turn running. The `finally` path aborts the durable row
  and fences the run/worktree but never interrupts and settles that physical
  turn; a `phase4-write` implementer can therefore keep mutating after its
  authority was rejected.
- Required outcome: interrupt the exact started turn and await terminal
  settlement before fencing or returning from every post-dispatch setup
  failure.
- Fix applied: one physical closure path now permanently rejects output/action
  eligibility, binds the returned turn for failure settlement, requests the
  exact interrupt, waits and reads exact terminal turn/action evidence, and
  settles it ineligible; an unprovable settlement invokes the existing durable
  run/worktree fence. Bind and monitor-registration failures are covered with
  write-capable action evidence and settlement-timeout regressions.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: pending assessment against CR-E3-31 and prior role-turn
  lifecycle findings

### CR-E3-33 — validation may dispatch an interpreter absent from its sandbox

- Review epoch / iteration: 3 / phase-3.8
- Source: `codex review --uncommitted`, Codex session
  `019fdd3e-396c-7751-85ea-cef6f82182f1`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:3340`
- Statement: candidate validation passes `sys.executable` into Bubblewrap, but
  the sandbox mounts only system runtime prefixes. When the launcher resolves
  Python from a virtualenv, pyenv, or another unmounted prefix, validation fails
  with executable-not-found on an otherwise supported host.
- Required outcome: dispatch an interpreter guaranteed to exist inside the
  validation sandbox, or bind the selected interpreter and its required runtime
  read-only.
- Fix applied: `BubblewrapValidationRuntime` now selects and verifies an
  executable interpreter under its mounted system roots and owns the Python
  command used by both startup preflight and candidate validation. Absent,
  non-executable, and out-of-mount interpreters fail before validation; a
  simulated host virtualenv does not affect the selected sandbox command.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: pending assessment against prior validation-sandbox and
  launcher portability findings

### Convergence checkpoint CR-CP-E3-08

- Review epoch: 3
- Triggered at: phase-3.8, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: assess the three findings across accumulated review
    history, select repair altitude, apply only bounded corrections, and rerun
    the complete native hard gate
- Trigger: the eighth holistic pass found two blocking physical-turn lifecycle
  escapes and one significant sandbox/interpreter portability defect despite
  the offline suite passing.
- Source-integrity check: the review process left the workspace unchanged. The
  pre/post complete HEAD diff SHA-256 remained
  `3cf82df0180c4813cc8a3c6af29c5872d0b6472557b8ba6c3a6023a73a5c466f`,
  the unstaged tracked-diff SHA-256 remained
  `973799e9ed4c233a8af440fcfa58edd5159ab56d566bee17660bb643df46f18a`,
  the staged diff SHA-256 remained
  `6d54b02817d3d076bf1b8ba555e1b42a5068ed7f1471e9ac86bac31ca99ff0cf`,
  the untracked aggregate remained
  `11d508b210f7a6ded0fc53bd2d1d34a08fb46a2acc46206ab76004c2d17dbff6`,
  and the status SHA-256 remained
  `040b461ac57bbc008a10d15b65b1445a7114ce55440c0ca43cc9330c6279a2d4`.
- Diagnosis: `no-common-root-cause` (high confidence). CR-E3-31 and CR-E3-32
  form one repeated post-dispatch ownership/settlement flaw: a physical App
  Server turn can start before its durable identity and monitor are fully
  installed, while failure cleanup treats a database abort/fence as though it
  also stopped that physical turn. This directly repeats the existing
  reserve-before-dispatch and settle-or-fence invariant. CR-E3-33 is independent:
  host-process interpreter identity is being reused inside a deliberately
  narrower mount namespace where that path may not exist.
- Repair altitude: `implementation`. Split checkpoint creation into durable
  reserve-before-dispatch and exact returned-turn binding. Once any role turn
  may have started, retain physical ownership through one common closure path:
  close further eligibility, interrupt the exact turn, await bounded terminal
  evidence, and settle it; if settlement cannot be proven, durably fail
  settlement and retain the run/worktree fence. Separately, let the validation
  runtime own one verified interpreter under its mounted system roots and use
  that same path for preflight and candidate validation; do not mount an
  arbitrary host virtualenv.
- Required regression proof: a stale/invalid checkpoint frontier sends no
  `turn/start`; bind and monitor-registration failures after dispatch interrupt
  and await the exact turn, including a write-capable role; failed settlement
  leaves the existing permanent fence. A simulated host virtualenv must still
  select the same mounted system interpreter for preflight and real validation,
  and an absent, non-executable, or out-of-mount candidate must fail before
  candidate validation.
- Status: `diagnosed; bounded implementation repair authorized by the active
  code-review flow`.
- Status evidence: independent `review-convergence-analyst` found one systemic
  role-dispatch closure correction for CR-E3-31/32 and one bounded validation-
  runtime correction for CR-E3-33, with no product, plan, architecture, or
  durable-schema reopening.

### Phase 3 eighth-gate repair checkpoint

- CR-E3-31 through CR-E3-33 were repaired at implementation altitude without a
  product, plan, architecture, protocol, or durable-schema change.
- Focused proof covers pre-dispatch checkpoint-frontier rejection, exact
  physical interrupt and terminal/action settlement after normal bind and
  monitor-registration failures, permanent fencing when settlement cannot be
  proven, and one mounted-system Python selection shared by preflight and real
  candidate validation independently of the host interpreter.
- Independent offline validation: all 214 Python tests pass with one expected
  outer-sandbox-dependent skip; Python compilation, Bash syntax, ShellCheck
  with only the established indirect-trap `SC2317` diagnostic excluded, Go
  tests, `go vet`, and `git diff --check` pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — ninth discovery pass

### CR-E3-34 — primary interpretations are not bound to admitted, settled input

- Review epoch / iteration: 3 / phase-3.9
- Source: `codex review --uncommitted`, Codex session
  `019fdd63-6008-7901-af11-6623e7b38378`
- Severity / scope: `blocking × in-scope`
- Location: `poc/kernel.py:5366-5368`
- Statement: a primary `interpret_*_response` model call can be accepted without
  an exact `primary_call_attempt_id`, with an attempt belonging to another
  subject, or before its physical delivery has settled. Role, purpose, and
  repeated context text alone can therefore become restart or integration
  authority without the durable response-admission and delivery path.
- Required outcome: bind every primary proposal interpretation to the exact
  eligible, physically settled `primary_call_attempts` and `user_inputs` records
  before it can be admitted or counted as authority.
- Fix applied: one narrow durable `proposal_responses` relation binds the exact
  proposal and presentation generation to its admitted input. Primary
  interpretation now joins that input to the exact non-null physical attempt
  and rejects wrong subject/input/work item/response/result/binding, unsettled
  or failed attempts, and newer-input supersession before recording authority.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` incomplete materialization of the accepted shared
  decision envelope and exact primary-settlement invariant

### CR-E3-35 — detach invalidates responses already durably admitted

- Review epoch / iteration: 3 / phase-3.9
- Source: `codex review --uncommitted`, Codex session
  `019fdd63-6008-7901-af11-6623e7b38378`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:4685-4687`
- Statement: presentation detach unconditionally resets a presented proposal to
  `pending`, including after `admit_opaque_user_text()` has persisted its
  response or after the primary interpretation is durable. The high-stakes loop
  then rejects that in-flight interpretation and asks the user to repeat an
  already admitted decision instead of preserving its ordinary-delivery or
  linked-reissue path.
- Required outcome: serialize detach with response admission and invalidate
  only envelopes that do not yet own a durably admitted response.
- Fix applied: proposal response admission and presentation invalidation now
  serialize in kernel transactions. Detach invalidates only a presentation with
  no admitted response; an admitted input survives through its existing
  ordinary-delivery or sole linked-reissue path without re-presentation.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` from the shared presentation-envelope and E16
  detach/rebind corrections at the post-admission ownership boundary

### CR-E3-36 — PTY cleanup scope begins after the child is forked

- Review epoch / iteration: 3 / phase-3.9
- Source: `codex review --uncommitted`, Codex session
  `019fdd63-6008-7901-af11-6623e7b38378`
- Severity / scope: `significant × in-scope`
- Location: `poc/pty_tui.py:178`
- Statement: a signal or parent-side setup exception after `fork()` but before
  the cleanup `try` begins can leave the already separately sessioned Codex
  child alive outside the prototype launcher's process group while it retains
  the presentation connection.
- Required outcome: put every parent-side post-fork initialization step under
  the child-session cleanup scope.
- Fix applied: both PTY drivers initialize one all-exit cleanup scope before
  fallible setup, block termination signals across handler installation and
  `fork()`, reset/unblock safely in the child, and unblock in the parent only
  after positive child ownership. Every acquired descriptor, signal state, and
  child/group is conditionally retired; PID/PGID zero is rejected.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` all-exit process ownership gap from prior PTY child-
  session and partial-construction findings

### CR-E3-37 — qualification skips descendant cleanup after normal leader exit

- Review epoch / iteration: 3 / phase-3.9
- Source: `codex review --uncommitted`, Codex session
  `019fdd63-6008-7901-af11-6623e7b38378`
- Severity / scope: `significant × in-scope`
- Location: `poc/qualification_pty_tui.py:145`
- Statement: when the qualification CLI exits normally, the driver skips the
  session-group cleanup helper. A background descendant that survives terminal
  hangup can therefore remain alive after the qualification run finishes.
- Required outcome: run bounded group cleanup on every exit, including after
  the session leader has already been reaped.
- Fix applied: qualification now invokes the shared bounded group cleanup on
  every exit, including natural leader exit, and publishes session absence only
  after the exact group is gone. Its full post-fork parent path uses the same
  conditional cleanup ownership and signal-mask handoff as the ordinary PTY.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` from prior qualification interruption and ordinary
  PTY child-session ownership findings

### Convergence checkpoint CR-CP-E3-09

- Review epoch: 3
- Triggered at: phase-3.9, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: assess the four findings across accumulated review
    history, select repair altitude, apply only bounded corrections, and rerun
    the complete native hard gate
- Trigger: the ninth holistic pass found two blocking gaps in the durable
  decision-envelope/input binding and two significant all-exit PTY cleanup gaps
  despite the complete offline suite passing.
- Source-integrity check: the review process left the workspace unchanged. The
  pre/post complete HEAD diff SHA-256 remained
  `9f40017df278b665ea6e3f95cf96b58d27e0f0e4e18c8acfd0dc786e1a2aae3f`,
  the unstaged tracked-diff SHA-256 remained
  `9ee9e3d5406151ec0c1d9d4d27f6fa1051d75417668658a9a52401cac023c77d`,
  the staged diff SHA-256 remained
  `6d54b02817d3d076bf1b8ba555e1b42a5068ed7f1471e9ac86bac31ca99ff0cf`,
  the untracked aggregate remained
  `13b2af60c77dc75973b6db3420dae07d2e2d3527d0f58d3399d18cc402791920`,
  and the status SHA-256 remained
  `040b461ac57bbc008a10d15b65b1445a7114ce55440c0ca43cc9330c6279a2d4`.
- Diagnosis: `local-design-flaw` (high confidence). All four findings repeat one
  ownership-handoff mistake in two local lifecycle clusters: CR-E3-34/35 infer
  decision-envelope ownership from presentation or model-call proxies instead
  of transferring it monotonically from exact presented proposal to durably
  admitted input to physically settled interpretation; CR-E3-36/37 begin PTY
  child-session ownership after the fork or treat leader exit as proof that the
  owned process group is gone.
- Repair altitude: `implementation`. The accepted plan already specifies that a
  response admitted before detach/rebind survives through ordinary delivery or
  one linked reissue, that interpretation authority requires exact physical
  settlement, and that separately sessioned children are retired on every exit.
  No product behavior, authority policy, plan shape, or generic lifecycle
  framework needs reopening.
- Action: add one exact durable proposal-to-input relationship and a kernel-owned
  response-admission transition; invalidate only presentations without an
  admitted response; require the exact eligible settled input attempt before a
  primary interpretation is recorded. Separately, establish PTY cleanup
  ownership around the fork and invoke bounded process-group cleanup on every
  exit, including after natural leader reap. Prove both monotonic handoffs with
  targeted regressions, run the complete suite, then resume the native hard
  gate.
- Status: `actioned; bounded implementation complete, pending native hard-gate
  re-review`. No live PoC run, commit, integration, or push was performed.
- Status evidence: independent `review-convergence-analyst` found no new
  finding and classified the accepted user-decision-envelope architecture as
  correct but incompletely materialized; Plan Review does not reopen. Primary
  verification passed 43 focused envelope tests, 17 focused PTY/qualification
  tests, and all 232 Python tests with one expected outer-sandbox skip. Python
  compilation, Bash syntax, ShellCheck excluding only established `SC2317`, Go
  tests, `go vet`, and scoped repaired-file diff checks are clean.

### Phase 3 ninth-gate repair checkpoint

- CR-E3-34 through CR-E3-37 were repaired at implementation altitude without a
  product, plan, authority-policy, generic lifecycle, or user-visible behavior
  change.
- Focused proof covers the monotonic proposal-to-input-to-settled-interpretation
  handoff, pre- versus post-admission detach behavior, ordinary delivery versus
  the sole linked reissue, all invalid physical-attempt variants, inherited
  signal safety across `fork()`, immediate post-fork parent failure, natural
  leader exit with a resistant descendant, and exact group absence before
  `reaped` evidence.
- Independent offline validation: all 232 Python tests pass with one expected
  outer-sandbox-dependent skip; cache-isolated Python compilation, Bash syntax,
  ShellCheck with only the established indirect-trap `SC2317` diagnostic
  excluded, Go tests, `go vet`, and scoped repaired-file `git diff --check`
  pass.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — tenth discovery pass

### CR-E3-38 — the normal launcher disconnects interactive stdin

- Review epoch / iteration: 3 / phase-3.10
- Source: `codex review --uncommitted`, Codex session
  `019fddaa-db77-7e93-8249-345c11ddf8ed`
- Severity / scope: `blocking × in-scope`
- Location: `poc/run-prototype.sh:210`
- Statement: the normal launcher starts the interactive prototype as a Bash
  background job while job control is disabled. Bash therefore connects the
  job's stdin to `/dev/null`; `NativeCliPrimaryInterface` passes that inherited
  descriptor to `pty_tui.py`, so user input cannot reach initial intake and the
  normal PoC times out.
- Required outcome: the normal interactive prototype process retains its exact
  inherited input stream while preserving the launcher's process-group and
  signal ownership.
- Fix applied: the existing background `setsid` invocation now explicitly
  duplicates the launcher's stdin with `<&0`; PID/PGID ownership, signal
  forwarding, bounded group cleanup, status capture, and completion behavior
  remain unchanged. A real non-job-control Bash/`setsid` regression passes a
  unique input line and proves the child receives it rather than EOF.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `regression` of E7-NATIVE-010 through the later
  E13-NATIVE-005 process-group ownership repair. One accepted launcher change
  preserved interactive stdin; the later background `setsid` composition
  preserved isolated group ownership but dropped that stdin obligation.

### CR-E3-39 — post-return primary settlement failures leave the thread reusable

- Review epoch / iteration: 3 / phase-3.10
- Source: `codex review --uncommitted`, Codex session
  `019fddaa-db77-7e93-8249-345c11ddf8ed`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:1552`
- Statement: after a primary turn returns, malformed physical-call evidence or
  an exception while recording settlement bypasses
  `_terminalize_failed_primary_call()`. The durable attempt can remain
  `send_started` or `logical_terminal` while its primary binding remains active,
  allowing a successor `typed_call()` on the same physical thread even though
  the prior call is unresolved.
- Required outcome: every failure after a primary turn may have returned must
  terminalize the exact attempt or fence and rebind the physical thread before
  any successor primary call becomes eligible.
- Fix applied: one partial-state-aware post-return closure boundary now covers
  model-call persistence through exact physical evidence, binding, action,
  logical-outcome, terminal-turn, and final-settlement recording. It preserves
  an already settled/fenced attempt, terminalizes `send_started` where possible,
  and otherwise fences/rebinds the old thread; `logical_terminal` is never given
  a duplicate outcome. A 17-case fault matrix proves every cut point is settled
  or fenced before a successor dispatch and does not semantically replay the
  terminal operation.
- Lifecycle: `actioned; pending phase-3 re-review`
- Relationship: `repeated` primary settle-or-fence ownership defect and a
  post-return sibling of CR-E3-32, continuing the invariant established by
  CR-E3-04, CR-E3-13, CR-E3-31/32, and CR-E3-34

### Convergence checkpoint CR-CP-E3-10

- Review epoch: 3
- Triggered at: phase-3.10, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: assess both findings across accumulated review
    history, select repair altitude, apply only bounded corrections, and rerun
    the complete native hard gate
- Trigger: the tenth holistic pass found one blocking normal-launcher intake
  failure and one blocking post-return primary-settlement escape despite the
  complete offline suite passing.
- Source-integrity check: the review process left the source and index
  unchanged. The pre/post HEAD remained
  `e045cf1e14277c2befc78a450201a6b19b33ba40`, the complete HEAD diff SHA-256
  remained `302e45a05b8ed229b12831a7a826bec1630aff41a42193d50111e097d545c6d4`,
  the unstaged tracked-diff SHA-256 remained
  `0996a0cd293f0a45c44332ef2a58d776868f7388a002d2e54c82258786083a70`,
  the staged diff SHA-256 remained
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`,
  the status SHA-256 remained
  `86d6890675d9140c192318f4a3ba4dd7e5931a269528a26a4a30acd1ecd3df52`,
  and there were no untracked files (the pre-review aggregate was
  `abcfa6a9d4df344d1781bc2560b5e4cdcae08b39ed303063535e7e1e926a304a`).
- Diagnosis: `no-common-root-cause` (high confidence). CR-E3-38 is a launcher
  composition regression: the E7 stdin-preservation obligation was lost when
  the E13 background `setsid` process-group ownership shape was introduced.
  CR-E3-39 is the repeated primary settlement-ownership flaw: the post-return
  persistence/evidence/binding/action/outcome/turn/settlement sequence is not
  inside one partial-state-aware failure-closure boundary. Their abstract
  similarity is too broad to justify shared machinery.
- Repair altitude: `implementation`. Preserve stdin explicitly on the existing
  background launch without weakening PID/PGID ownership. Separately, add one
  bounded post-return primary closure path that handles `send_started`,
  `logical_terminal`, `settled`, and `fenced` states and never propagates while
  an unresolved attempt leaves the old physical binding reusable. No product,
  plan, authority, durable-schema, retry, or generic lifecycle change is
  required; Plan Review remains closed.
- Required regression proof: the actual job-control-disabled background
  `setsid` shell shape receives a unique line from inherited stdin while all
  existing signal/group/status behavior remains intact. Fault injection at
  model-call persistence, physical evidence parsing and identity, turn/action
  recording, logical outcome, terminal turn, and final settlement must leave
  every attempt exactly settled or the old thread fenced/rebound before another
  primary dispatch, without semantic replay of terminal work.
- Status: `diagnosed; bounded implementation repair authorized by the active
  code-review flow`.
- Status evidence: independent `review-convergence-analyst` found no additional
  finding and no reason to reopen product decisions, architecture, or Plan
  Review.
- No live PoC run, commit, integration, or push was performed.

### Phase 3 tenth-gate repair checkpoint

- CR-E3-38 and CR-E3-39 were repaired independently at implementation altitude
  without a product, plan, architecture, durable-schema, retry-policy, or user-
  visible behavior change.
- Focused proof covers the actual job-control-disabled background `setsid`
  launch shape and 17 post-return primary failure cut points from model-call
  persistence through settlement, including failures immediately before and
  after durable outcome/settlement commits.
- Independent offline validation: all 234 unittest tests pass with one expected
  outer-sandbox-dependent skip; all 233 pytest tests pass with the same expected
  skip; cache-isolated Python compilation, Bash syntax, ShellCheck excluding
  only the established indirect-trap `SC2317` diagnostic, Go tests, `go vet`,
  and scoped repaired-file `git diff --check` pass. The complete diff has only
  the two established vendored Gorilla WebSocket EOF warnings.
- Continuation token: rerun the Phase 3 native Codex gating review over the
  complete current diff. Live PoC execution, commit, integration, and push
  remain separately gated.

## Phase 3 native Codex hard gate — eleventh discovery pass

### CR-E3-40 — replacement primary is installed without complete semantic state

- Review epoch / iteration: 3 / phase-3.11
- Source: `codex review --uncommitted`, Codex session
  `019fddd1-62e3-7a93-aa61-af84e7f5e5ac`
- Severity / scope: `blocking × in-scope`
- Location: `poc/kernel.py:895-900`
- Statement: the physical-primary re-prime packet contains only ledger event
  records. Those events name identities but do not carry the accepted outcome
  and constraints, plan text, review findings, conversation, or next permitted
  transition. A replacement can therefore become decision-eligible without the
  complete durable semantic state required to continue the logical primary.
- Required outcome: materialize the complete durable semantic projection
  required by `poc/PLAN.md:869-874` and bind it to the candidate's
  acknowledgement before installing a replacement primary.
- Fix applied: candidate creation now materializes one canonical, bounded
  SQLite semantic projection at the exact re-prime frontier, stores and digests
  that complete packet in the candidate row, requires the replacement primary
  to acknowledge the exact stored packet, and keeps later catch-up as ordered
  ledger deltas. Tamper, omission, post-frontier mutation, and catch-up tests
  prove that installation cannot occur from an incomplete or recomputed
  re-prime packet.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-41 — primary adoption omits the producer's actual output

- Review epoch / iteration: 3 / phase-3.11
- Source: `codex review --uncommitted`, Codex session
  `019fddd1-62e3-7a93-aa61-af84e7f5e5ac`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:1221-1227`
- Statement: the separate primary adoption turn receives producer identities,
  kind, and payload hash, but not the producer payload. Because the role ran on
  another App Server thread and ordinary role payloads are not otherwise
  visible to the primary, it cannot meaningfully choose adopt, revise, reject,
  or escalate before dependent work advances.
- Required outcome: include the exact producer payload in the adoption context
  and durably verify that the primary consumed that exact payload, as required
  by `poc/PLAN.md:145-153`.
- Fix applied: every ordinary and native-review adoption context now carries
  the exact producer payload in addition to its identity and digest, and the
  kernel canonical-compares that payload to the eligible durable role-output
  row before accepting the primary disposition. A mismatched-payload
  regression proves that a matching identity and hash field alone cannot
  authorize adoption.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-42 — a blocked plan review can still close the plan

- Review epoch / iteration: 3 / phase-3.11
- Source: `codex review --uncommitted`, Codex session
  `019fddd1-62e3-7a93-aa61-af84e7f5e5ac`
- Severity / scope: `blocking × in-scope`
- Location: `poc/kernel.py:6036-6039`
- Statement: `record_plan_synthesis()` loads review identities, kinds, and
  result payloads but drops their verdicts. A valid `blocked` review with no
  findings therefore contributes no required disposition, allowing a primary
  `close` decision to accept the plan and reach final authorization.
- Required outcome: synthesis must inspect both exact review verdicts and
  refuse closure while either independent review is blocked.
- Fix applied: plan synthesis now loads each exact review verdict with its
  result and rejects `close` whenever either required independent review is
  blocked. Regressions cover a blocked verdict in either lens, clean closure,
  and finding-driven revision.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-43 — known-returned primary work can become replayable after persistence failure

- Review epoch / iteration: 3 / phase-3.11
- Source: `codex review --uncommitted`, Codex session
  `019fddd1-62e3-7a93-aa61-af84e7f5e5ac`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:1735-1739`
- Statement: when the fallback outcome write for a known-returned primary call
  fails before committing, the error is swallowed and generic rebind handling
  classifies the still-`send_started` attempt as an ambiguous send. It fences
  the physical attempt but resets the semantic operation to `queued` with one
  replacement, making already-returned semantic work replayable.
- Required outcome: terminalize or permanently fail the exact known-returned
  semantic operation before rebinding; it must never enter ambiguous-send
  replacement eligibility.
- Fix applied: a dedicated transactional kernel transition now fences the
  still-`send_started` physical attempt and terminally fails its exact input or
  semantic operation before any rebind. The engine stops rather than rebinds if
  that terminal write cannot be established. The post-return fault matrix
  proves no replacement is created for the returned semantic subject and a
  successor primary turn can proceed only after the prior subject is terminal.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-44 — workflow report omits the durable proposal-response binding

- Review epoch / iteration: 3 / phase-3.11
- Source: `codex review --uncommitted`, Codex session
  `019fddd1-62e3-7a93-aa61-af84e7f5e5ac`
- Severity / scope: `non-blocking × in-scope`
- Location: `poc/kernel.py:7446`
- Statement: `proposal_responses` is the durable relation tying a high-stakes
  proposal and presentation generation to its admitted user input, but
  `workflow_report()` omits it. The final `prototype-report.json` therefore
  cannot independently demonstrate the response-to-interpretation authority
  chain even though the separate SQLite evidence snapshot retains the row.
- Required outcome: include work-item-scoped proposal-response rows in the
  workflow report.
- Fix applied: `workflow_report()` now includes `proposal_responses`, scoped by
  joining each response through its proposal to the requested work item. A
  two-work-item regression proves that the report includes the local binding
  and excludes the unrelated response while the ledger retains both.
- Lifecycle: `actioned; pending phase-3 re-review`

### Convergence checkpoint CR-CP-E3-11

- Review epoch: 3
- Triggered at: phase-3.11, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: assess CR-E3-40 through CR-E3-44 across the complete
    finding history, identify any shared governing defect, select repair
    altitude, apply only the accepted bounded corrections, and rerun the
    complete native hard gate
- Trigger: the eleventh holistic pass found four blocking semantic authority or
  continuity escapes and one in-scope evidence omission despite the complete
  offline suite passing.
- Source-integrity check: the review process left source and index unchanged.
  The pre/post HEAD remained
  `e045cf1e14277c2befc78a450201a6b19b33ba40`, the complete HEAD diff SHA-256
  remained `d76904fbd53f9cf470fc4cbcb90d7fc96ae9db919d0a059469cd988d6ccd5e42`,
  the unstaged tracked-diff SHA-256 remained
  `3b94c5fb16e77b7243a9728615756071bd764f704cacdb33eb3cdb075bd788c0`,
  the staged diff SHA-256 remained
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`,
  the status SHA-256 remained
  `3827fea0fdb4f4cb1003974fe5e4c4df5408b3a98bc40cb9a5416506957415e2`,
  and there were no untracked files.
- Evidence clusters:
  - CR-E3-40/41/42/44 are one projection-completeness cluster. Manually
    assembled authority/evidence boundaries retain identities, hashes, or
    selected rows while omitting semantic content or decisive state that the
    consumer needs; the consumer then treats the partial projection as
    complete.
  - CR-E3-43 is a distinct known-returned settlement/no-replay defect spawned
    by the CR-E3-39 repair. It loses return certainty when the terminal outcome
    write fails and incorrectly hands the attempt to ambiguous-send recovery.
- Diagnosis: `no-common-root-cause` (high confidence). The projection cluster
  is a `local-design-flaw`, while CR-E3-43 is a separate lifecycle defect.
  CR-E3-40 extends the continuity family behind CR-E3-13 and CR-E3-34/35;
  CR-E3-41 continues the exact-output/adoption family of CR-E3-06/13/31/32;
  CR-E3-42 repeats decisive verdict/consumer-shape loss related to CR-E3-09;
  CR-E3-44 is composition blindness after `proposal_responses` became
  authoritative in CR-E3-34/35; and CR-E3-43 directly repeats the
  CR-E3-04/13/31/32/34/39 settle-before-rebind invariant.
- Repair altitude: `implementation` for all five. The accepted plan already
  requires complete continuity state, exact producer output for accountable
  adoption, both independent review outcomes before plan closure, terminal
  semantic work never revived by rebind, and reconstructable durable evidence.
  Realizing those existing contracts does not change product behavior,
  architecture, authority, scope, or the plan, so Plan Review remains closed.
- Resolution decision:
  - Problem: five accepted findings expose incomplete boundary consumption,
    including one separate no-replay lifecycle escape.
  - Option 1: patch each visible symptom independently. Pros: smallest local
    edits. Cons: does not audit sibling consumers and is likely to repeat the
    partial-projection failure pattern.
  - Option 2: apply one bounded implementation repair set across the four exact
    projection boundaries plus one narrow known-returned terminal transition.
    Pros: realizes the accepted plan consistently without adding a generic
    framework. Cons: touches several existing boundary tests and packet/report
    shapes.
  - Option 3: reopen architecture and introduce a generic projection or recovery
    subsystem. Pros: could centralize future boundaries. Cons: adds unjustified
    semantic surface and solves no missing plan or product decision.
  - Recommendation: Option 2.
- Action: materialize and digest a complete canonical SQLite semantic
  projection in each re-prime packet; include and durably compare the exact
  producer payload at adoption; require both exact plan-review verdicts to be
  clean before closure; include work-item-scoped `proposal_responses` in the
  report; and add one kernel-owned known-returned failure transition that makes
  the subject terminal before rebind, visibly stopping if that durable write
  cannot be established. Audit the immediate sibling consumers, add the named
  tamper/omission/no-replay regressions, run the complete offline suite, then
  rerun the full native hard gate.
- Status: `actioned`.
- Status evidence: independent `review-convergence-analyst` found no new
  finding, classified the four projection omissions as one local design cluster
  and CR-E3-43 as distinct, and found no basis to reopen product requirements,
  architecture, scope, or Plan Review. The user's active approval authorizes
  the bounded Code Review Flow repair and continuation.
- No live PoC run, commit, integration, or push was performed.

### Phase 3 eleventh-gate repair checkpoint

- CR-E3-40 through CR-E3-44 were repaired at implementation altitude using the
  bounded Option 2 resolution. No product, plan, architecture, authority,
  retry-policy, or user-visible workflow decision was changed.
- Independent regression proof covers exact semantic re-prime projection and
  acknowledgement, exact producer-payload adoption, blocked plan-review
  closure refusal, known-returned no-replay settlement including failure of the
  terminal write itself, and work-item-scoped proposal-response reporting.
- Independent offline validation: all 239 unittest tests pass with one expected
  outer-sandbox-dependent skip; all 238 pytest tests pass with the same expected
  skip; cache-isolated Python compilation, Bash syntax, ShellCheck excluding
  only the established indirect-trap `SC2317` diagnostic, Go tests, `go vet`,
  and complete `git diff --check` pass.
- Continuation token: freeze the complete current source/index state and rerun
  the Phase 3 native Codex gating review over that exact diff. Live PoC
  execution, commit, integration, and push remain separately gated.


## Phase 3 native Codex hard gate — twelfth discovery pass

### CR-E3-45 — failed presentation admission can permanently wedge reattachment

- Review epoch / iteration: 3 / phase-3.12
- Source: `codex review --uncommitted`, Codex session
  `019fde06-563b-7dd3-88a2-8e18ed106aff`
- Severity / scope: `blocking × in-scope`
- Location: `poc/controller.py:2430`
- Suspected surface: presentation transport admission ownership and rollback.
- Statement: an authenticated presentation connection sets
  `presentation_active` before its handshake acknowledgement is successfully
  written, flushed, and handed to the session queue. If the connection drops in
  that interval, the exception path closes the socket but leaves the active
  flag set, so every later legitimate reattachment is rejected.
- Required outcome: publish the active-session admission state only after a
  successful handoff, or roll it back on every failure before the queue owns the
  session.
- Fix applied: none.
- Relationship: `spawned-sibling` of PRT-001/CR-014 and the later
  presentation-owner lifecycle cluster; admission reservation was treated as
  completed ownership.
- Resolution decision: CR-CP-E3-12 selected implementation altitude. Repair the
  existing admission boundary across acknowledgement and queue handoff without
  adding durable presentation state or a generic state machine.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-46 — the replacement-primary re-prime packet is not bounded

- Review epoch / iteration: 3 / phase-3.12
- Source: `codex review --uncommitted`, Codex session
  `019fde06-563b-7dd3-88a2-8e18ed106aff`
- Severity / scope: `blocking × in-scope`
- Location: `poc/kernel.py:1250-1252`
- Suspected surface: bounded primary continuity projection and re-prime
  protocol.
- Statement: every replacement candidate receives all ledger entries from
  sequence zero plus a semantic projection containing complete prompts,
  outputs, and artifacts. A sufficiently late rebind can therefore exceed the
  model context, and both allowed replacement attempts repeat the same
  oversized packet before ending in `rebind_failed`.
- Required outcome: make the exact re-prime packet explicitly bounded while
  retaining the current semantic state and the ordered frontier/catch-up
  protocol required by the accepted plan.
- Fix applied: re-prime packet version 2 now carries an exact SQLite-derived
  current-state projection rather than sequence-zero events and complete
  historical table dumps. Full history remains durable in SQLite. The exact
  prompt plus output-schema serialization is capped at 256 KiB before model
  dispatch with no truncation or Python semantic summarization; an oversized
  required current state stops visibly. Both candidate and active-primary
  catch-up now emit and acknowledge contiguous size-bounded `ledger_seq`
  chunks, while one individually oversized required entry fails visibly.
- Relationship: direct `spawned-sibling` of CR-E3-40. That repair implemented
  complete semantic state as complete history, despite the accepted plan's
  bounded current-state projection. The unbounded catch-up delta is an
  immediate sibling consumer of the same packet contract, not a separate
  finding.
- Resolution decision: CR-CP-E3-12 selected implementation altitude. Retain
  complete history in SQLite; send the exact structurally selected current
  state, enforce an explicit pre-dispatch bound without silent truncation or
  Python semantic summarization, and deliver catch-up as bounded contiguous
  sequence chunks.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-47 — a second termination signal can interrupt orderly cleanup

- Review epoch / iteration: 3 / phase-3.12
- Source: `codex review --uncommitted`, Codex session
  `019fde06-563b-7dd3-88a2-8e18ed106aff`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:6356-6357`
- Suspected surface: process-level signal ownership during orderly cleanup.
- Statement: when execution reaches `finally` through normal completion,
  `WorkflowStopped`, or another exception, the interrupt-raising SIGTERM and
  SIGINT handlers remain installed. A signal during that cleanup can raise an
  unhandled `PrototypeInterrupted` and skip remaining presentation teardown,
  child cleanup, evidence export, database close, and handler restoration.
- Required outcome: prevent termination signals from interrupting every
  orderly-cleanup path, not only cleanup entered because the first signal was
  caught.
- Fix applied: the common `finally` atomically blocks TERM/INT before changing
  their dispositions, keeps both ignored throughout every cleanup path, then
  discards cleanup-time pending signals while ignored and restores the caller's
  exact signal mask and handlers only after cleanup. Normal completion,
  `WorkflowStopped`, other failures, and an initially handled signal now share
  the same protected boundary.
- Relationship: `repeated` from E7-NATIVE-004/10/12/13 and the later all-exit
  process-ownership findings; signal protection begins on one exit path instead
  of the common cleanup boundary.
- Resolution decision: CR-CP-E3-12 selected implementation altitude. Make the
  existing common cleanup non-interruptible on every entry path, without adding
  a lifecycle supervisor or changing the launcher's bounded hard-kill fallback.
- Lifecycle: `actioned; pending phase-3 re-review`

### Twelfth-gate source-integrity checkpoint

- The review process left the frozen source and index unchanged. The pre/post
  HEAD remained `e045cf1e14277c2befc78a450201a6b19b33ba40`, the complete HEAD
  diff SHA-256 remained
  `9dc1302309f724b3f4fd4cb0e8c358b78fe7c241536da6299c0d6cf4a904af63`,
  the unstaged tracked-diff SHA-256 remained
  `ae5d92887df4af3d71bc5d6d0f0be1399561a3ed1f86321aebb9e4cffb437d3e`,
  the staged diff SHA-256 remained
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`,
  the status SHA-256 remained
  `5559b48c273c1228bc7175754aca445999b788a8c6a1df1e36fd0d53f4a05724`,
  and there were no untracked files.
- Offline reviewer validation independently passed `git diff --check`, the
  complete Python test suite (238 passed, one expected skip), Go tests and
  `go vet`, Bash syntax, and ShellCheck excluding only the established
  indirect-trap `SC2317` diagnostic.
- Continuation token: assess CR-E3-45 through CR-E3-47 against the complete
  finding history before selecting repair altitude. Live PoC execution,
  commit, integration, and push remain separately gated.

### Convergence checkpoint CR-CP-E3-12

- Review epoch: 3
- Triggered at: phase-3.12, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: diagnose CR-E3-45 through CR-E3-47 against the
    complete ledger, select the least-surface repair altitude for every valid
    obligation, apply only the accepted resolution, and rerun the complete
    Phase 3 discovery gate
- Trigger: the twelfth holistic gate exposed three new substantive sibling
  failure paths after the prior projection/no-replay repair, including one
  continuity-packet finding whose boundedness obligation may affect the packet
  shape.
- Evidence clusters:
  - CR-E3-45 concerns publication and rollback of presentation admission
    ownership before queue handoff.
  - CR-E3-46 concerns the difference between the accepted bounded current-state
    re-prime contract and the implementation's complete-history projection.
  - CR-E3-47 concerns process-level signal ownership throughout orderly
    cleanup, including cleanup entered without a preceding signal.
  - The complete earlier ledger must determine whether these are independent,
    repeat an earlier temporal-composition or projection cluster, or expose an
    accepted-plan gap.
- Diagnosis: `no-common-root-cause` (high confidence). CR-E3-45 and CR-E3-47
  share a broad lifecycle-ownership theme but affect distinct admission and
  shutdown boundaries. CR-E3-46 is a separate continuity-context defect and a
  direct regression from CR-E3-40's projection repair. Each repeats an earlier
  local cluster; none reveals a missing product decision or accepted-plan gap.
- Repair altitude: `implementation` for all three. The plan already requires
  one-session admission ownership, a bounded exact current-state re-prime
  source with ordered deltas, and orderly all-exit cleanup.
- Resolution decision:
  - Problem: close the three accepted obligations without turning local PoC
    lifecycle/context defects into a generic supervisor or compaction service.
  - Option 1: patch only the three reported lines. Pros: smallest diff. Cons:
    leaves immediate sibling failure paths at queue handoff, catch-up packet
    sizing, and alternate cleanup entry paths.
  - Option 2: apply three boundary-aligned implementation repairs and audit
    their immediate consumers. Pros: realizes the accepted plan with no new
    authority, product behavior, or generic framework. Cons: needs broader
    focused tests and precise current-state projection queries.
  - Option 3: reopen the plan for generic presentation, lifecycle-supervision,
    or semantic-compaction architecture. Pros: possible future production
    generality. Cons: exceeds this one-work-item PoC and addresses no missing
    accepted decision.
  - Recommendation: Option 2.
- Action: generation-safely roll back every failed pre-handoff presentation
  admission; replace complete-history re-prime content with the plan's exact
  bounded current-state categories, preflight its serialized size without
  truncation, and chunk catch-up into contiguous bounded deltas; shield every
  common-cleanup entry from TERM/INT until cleanup completes. Add focused fault,
  size, ordering, and cleanup-entry tests, run the complete offline suite, then
  resume the Phase 3 discovery gate.
- Status: `resolved`.
- Status evidence: independent `review-convergence-analyst` accepted all three
  obligations, found no separate catch-up finding and no reason to reopen
  product requirements, architecture, scope, or Plan Review. Review epoch 4
  begins at counter zero and resumes the recorded pre-fix continuation.

### Phase 3 twelfth-gate repair checkpoint

- CR-E3-45 through CR-E3-47 were repaired at implementation altitude using the
  bounded Option 2 resolution. No product, plan, architecture, durable
  authority, retry policy, or user-visible workflow decision changed.
- Focused proof covers acknowledgement-write, flush, and queue-handoff failure
  followed by successful reattachment; concurrent session rejection; current
  semantic projection with large superseded historical state omitted; exact
  packet tamper/omission rejection; oversized required state rejected before a
  model call; contiguous bounded catch-up through installation; individually
  oversized delta rejection; and TERM/INT across early, middle, and late
  cleanup after every exit class with exact signal-state restoration.
- Independent post-fix audit additionally narrowed transport failure handling
  to expected connection/queue exceptions and made cleanup entry atomically
  signal-masked before handler replacement.
- Independent offline validation: all 244 unittest tests pass with one expected
  outer-sandbox-dependent skip; all 243 pytest tests pass with the same expected
  skip; cache-isolated Python compilation, Bash syntax, ShellCheck excluding
  only the established indirect-trap `SC2317` diagnostic, uncached Go tests,
  `go vet`, and complete `git diff --check` pass.
- Continuation token: freeze the complete current source/index state and rerun
  the Phase 3 native Codex gating review over that exact diff. Live PoC
  execution, commit, integration, and push remain separately gated.

### CR-E3-48 — process interruption is misclassified as a model-call failure

- Review epoch / iteration: 4 / phase-3.13
- Source: `codex review --uncommitted`, Codex session
  `019fde41-dba4-7b20-b706-e6bc3481238b`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:1467`
- Suspected surface: process-interrupt propagation across the model-call
  wrapper.
- Statement: SIGTERM or SIGINT during `self.model.call(...)` raises
  `PrototypeInterrupted`, but the generic `Exception` handler can translate it
  into model failure or run model-failure recovery first. This bypasses the
  outer process-interrupt path and can persist the wrong durable outcome and
  return the wrong exit status.
- Required outcome: preserve `PrototypeInterrupted` as process control and
  re-raise it before ordinary model-call failure handling.
- Fix applied: process interruption now propagates unchanged through typed
  model calls, physical run-owner provisioning, external effects, direct native
  review, replacement-owner provisioning, binding recovery, and outer failure
  reporting. Required physical settlement, fencing, monitor release, child
  reaping, and checkout retirement retain the first interruption and re-raise
  that exact object afterward; they do not translate it into a semantic model,
  timeout, role, or effect failure.
- Relationship: `repeated` from the earlier control-versus-domain
  misclassification and process-ownership cluster. Independent post-fix audit
  found and closed immediate sibling catches in primary-timeout and rejected
  role-turn settlement.
- Resolution decision: CR-CP-E3-13 selected Option 2 at implementation
  altitude: explicit process-control precedence within existing owners, with no
  new recovery authority or lifecycle supervisor.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-49 — stream-close failure can terminate presentation admission

- Review epoch / iteration: 4 / phase-3.13
- Source: `codex review --uncommitted`, Codex session
  `019fde41-dba4-7b20-b706-e6bc3481238b`
- Severity / scope: `blocking × in-scope`
- Location: `poc/controller.py:2489`
- Suspected surface: authenticated presentation connection teardown.
- Statement: after an acknowledgement write or flush fails, closing its
  `TextIOWrapper` can retry the buffered flush and raise another `OSError` from
  the outer `finally`. That exception terminates the acceptor thread and can
  skip socket close, so a later valid session cannot attach even though the
  presentation reservation was rolled back.
- Required outcome: make stream and socket teardown independent and
  non-throwing so one broken peer cannot terminate the accept loop.
- Fix applied: candidate timeout/makefile/read/acknowledgement/handoff and both
  independent close attempts are contained by a typed expected-peer boundary;
  a failed reservation rolls back before teardown and later candidates remain
  admissible. The ordinary interactive host applies the same narrow boundary
  to active-peer read/write/flush/close operations, invalidates and detaches the
  failed presentation, then accepts a later session. Evidence, kernel, parsing,
  and invariant failures remain host-visible rather than being hidden as peer
  failures.
- Relationship: direct `spawned-sibling` of CR-E3-45. Independent post-fix
  audit extended the same accepted detach/re-presentation contract from
  handshake teardown to the already-admitted peer's exact stream operations.
- Resolution decision: CR-CP-E3-13 selected Option 2 at implementation
  altitude: keep expected peer failure local to its connection while preserving
  authoritative host failures.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-50 — PTY cleanup begins with an interruptible signal-state window

- Review epoch / iteration: 4 / phase-3.13
- Source: `codex review --uncommitted`, Codex session
  `019fde41-dba4-7b20-b706-e6bc3481238b`
- Severity / scope: `blocking × in-scope`
- Locations: `poc/pty_tui.py:455-459` and the corresponding sequence in
  `poc/qualification_pty_tui.py`.
- Suspected surface: PTY relay signal ownership at cleanup entry.
- Statement: the parent restores its signal mask before replacing the
  interrupt-raising TERM/INT handlers. A signal in that sequential window can
  raise inside `finally`, skip child-session termination and lifecycle
  publication, and leave the `setsid()` Codex child outside the launcher's
  process group.
- Required outcome: atomically block TERM and INT before changing their
  dispositions, keep cleanup non-interruptible, then restore the caller's exact
  signal state only after cleanup finishes.
- Fix applied: both PTY owners now block TERM/INT at common cleanup entry,
  install non-raising dispositions, terminate and reap the exact child process
  group, restore terminal/descriptors and publish lifecycle evidence, discard
  cleanup-time pending signals while still blocked, restore prior handlers, and
  restore the caller's exact mask last. The top-level prototype uses the same
  handlers-before-mask restoration order.
- Relationship: `repeated` from the all-path signal/process-ownership cluster;
  CR-E3-47 fixed the top-level owner but had not propagated the invariant to
  both PTY child owners.
- Resolution decision: CR-CP-E3-13 selected Option 2 at implementation
  altitude, reusing one small local signal-state guard rather than adding a
  supervisor.
- Lifecycle: `actioned; pending phase-3 re-review`

### Thirteenth-gate source-integrity checkpoint

- The review process left the frozen source and index unchanged. The pre/post
  HEAD remained `e045cf1e14277c2befc78a450201a6b19b33ba40`, the complete HEAD
  diff SHA-256 remained
  `d66b55c76a8c9d0a8625b870745b8bcb408df864bf9cae8164d0bf4f2dd21d9f`,
  the unstaged tracked-diff SHA-256 remained
  `07b4502b1394f82951261de690051474cedcdaa9dfbc95e8cefc9dcda60ea2ca`,
  the staged diff SHA-256 remained
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`,
  the status SHA-256 remained
  `6b4846a1952a8e8218212aef0f94db9462ec23ffc2983e51db5893a23f9ffba4`,
  and there were no untracked files.
- Reviewer verdict: three blocking in-scope findings, CR-E3-48 through
  CR-E3-50. The gate did not mutate source or index.
- Continuation token: assess the three findings against the complete finding
  history before selecting repair altitude. Live PoC execution, commit,
  integration, and push remain separately gated.

### Convergence checkpoint CR-CP-E3-13

- Review epoch: 4
- Triggered at: phase-3.13, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: apply the bounded exception-ownership repair for
    CR-E3-48 through CR-E3-50, validate immediate sibling sites, and rerun the
    complete Phase 3 discovery gate
- Trigger: the thirteenth holistic gate found three blocking control-flow and
  cleanup failures after the preceding admission and top-level signal repair.
- Diagnosis: `local-design-flaw` (high confidence). All three findings expose
  the same implementation-level exception-ownership defect: asynchronous
  process control crosses a semantic model-failure boundary, per-peer teardown
  crosses into the long-lived acceptor owner, or cleanup remains interruptible
  after its owner has begun releasing resources.
- Prior relationships:
  - CR-E3-48 repeats the control-versus-domain misclassification cluster around
    CR-E3-17, CR-E3-29, CR-E3-39/43, and CR-E3-47.
  - CR-E3-49 is a direct spawned sibling of CR-E3-45 and repeats the earlier
    one-presentation-failure-kills-a-broader-owner pattern.
  - CR-E3-50 directly repeats the all-path process and signal ownership cluster
    from E7-NATIVE-004/10/12/13 and CR-E3-17/20/36/37/47.
- Accepted-plan challenge: no plan, product, authority, retry, or user-visible
  decision is missing. Existing accepted behavior leaves one valid outcome at
  each boundary: process interruption reaches process finalization unchanged;
  one failed peer remains local; and an owned PTY child is reaped before
  lifecycle publication and return.
- Resolution decision:
  - Problem: close the shared exception-ownership defect without adding a
    generic supervisor or recovery framework.
  - Option 1: patch only the three reported lines. Pros: smallest immediate
    diff. Cons: leaves sibling generic catches, pre-`try` presentation setup,
    independent close operations, and signal-restoration windows available for
    recurrence.
  - Option 2: apply one narrow exception-ownership contract at the exact
    participating sites. Pros: fixes the root while keeping process
    interruption, peer failure, and cleanup interruption mechanically distinct
    within existing owners. Cons: requires a bounded audit of nearby catches
    and both PTY implementations.
  - Option 3: introduce a generic lifecycle/exception supervisor and reopen
    architecture. Pros: possible future generality. Cons: adds authority and
    lifecycle surface not required by this PoC.
  - Recommendation: Option 2.
- Repair altitude: `implementation`; at most small local helpers for peer
  teardown and signal guarding. PLAN Review remains closed.
- Action: re-raise `PrototypeInterrupted` before semantic failure handling and
  audit immediate model/run/effect owners; contain all expected candidate
  setup/teardown failures within the accept loop while preserving invariant and
  evidence failures; and make both PTY cleanup sequences plus top-level
  restoration block signals until prior handlers are restored and the caller's
  original mask is restored last.
- Status: `resolved`.
- Status evidence: independent `review-convergence-analyst` selected Option 2,
  identified no separate new finding, and found no reason to reopen product
  requirements, architecture, scope, or Plan Review. Review epoch 5 begins at
  counter zero after the bounded repairs and complete offline validation.

### Phase 3 thirteenth-gate repair checkpoint

- CR-E3-48 through CR-E3-50 were repaired at implementation altitude using the
  bounded Option 2 exception-ownership rule. No product, plan, architecture,
  semantic authority, retry policy, or user-visible workflow decision changed.
- Focused proof covers TERM and INT during primary and role model calls, run
  provisioning, external effect execution, direct native review, primary
  timeout settlement, rejected-role settlement, nested failure reporting, and
  every top-level cleanup entry; the first process interruption remains exact,
  required physical cleanup completes, and exit status remains 143 or 130.
- Presentation proof faults candidate setup, acknowledgement write/flush,
  queue handoff, stream/socket close, and admitted-peer read/write/flush. Each
  expected peer failure releases its reservation or active presentation,
  records bounded diagnostics, and permits a later authenticated session;
  evidence and invariant failures remain fatal to the host.
- PTY proof covers common cleanup ordering, pending cleanup signals, partial
  parent setup, natural leader exit, handled interruption, resistant descendants,
  exact child-group absence, lifecycle publication, and exact handler/mask
  restoration in both ordinary and retained qualification drivers.
- Independent unsharded validation: all 257 unittest tests pass with one
  expected outer-sandbox-dependent skip; all 256 pytest tests pass with the
  same expected skip. Cache-isolated Python compilation, Bash syntax,
  ShellCheck excluding only the established indirect-trap `SC2317` diagnostic,
  uncached Go tests, `go vet`, and complete `git diff --check` pass.
- Continuation token: freeze the complete current source/index state and rerun
  the Phase 3 native Codex gating review over that exact diff. Live PoC
  execution, commit, integration, and push remain separately gated.

### CR-E3-51 — a crashed PTY driver can leave its detached Codex group alive

- Review epoch / iteration: 5 / phase-3.14
- Source: `codex review --uncommitted`, Codex session
  `019fde8a-ec09-7473-8ae9-ef4121f4ebcf`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:5453-5454`
- Suspected surface: replacement-time ownership of the stock-CLI PTY child.
- Statement: when the PTY driver has already exited while its lifecycle receipt
  still says `running`, `stop_process()` skips its only process-group kill path
  and merely rejects replacement. The inner Codex process has called `setsid()`,
  so the launcher cannot reach that surviving group.
- Required outcome: inspect and terminate the exact recorded PTY child group
  even when the driver process has already exited, and permit replacement only
  after proving that group absent.
- Fix applied: replacement now reads the generation-bound lifecycle receipt
  before deciding that the PTY owner is closed, treats the recorded child
  process group independently of driver liveness, terminates any still-live
  group, and permits replacement only after the driver is terminal and that
  exact group is proven absent. An invalid receipt fails closed.
- Relationship: `repeated` from CR-E3-12/36/37 and the broader detached-child
  ownership cluster: a terminal proxy process was again mistaken for complete
  retirement of the resource it owned.
- Resolution decision: CR-CP-E3-14 selected Option 2 at implementation
  altitude: enforce complete closure inside the existing PTY owner without a
  new supervisor or lifecycle authority.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-52 — interrupted native-review teardown can remain physically and durably open

- Review epoch / iteration: 5 / phase-3.14
- Source: `codex review --uncommitted`, Codex session
  `019fde8a-ec09-7473-8ae9-ef4121f4ebcf`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:5671-5673`
- Suspected surface: direct native-review process ownership under process
  interruption.
- Statement: after SIGKILL, a wait timeout or another interruption is swallowed;
  `poll()` may therefore remain `None`, the durable execution may stay
  `running`, and a `start_new_session` process group may remain outside
  controller cleanup before the original interruption is re-raised.
- Required outcome: retain the first process interruption while completing
  bounded kill/reap verification, terminalizing the native-review execution,
  and retiring its checkout before re-raising that exact interruption.
- Fix applied: interrupted native review now retains the first interruption,
  kills and repeatedly waits for its exact process group under a bounded
  deadline, closes both pipes independently, proves physical group absence,
  terminalizes any possibly committed durable execution, verifies that it is
  no longer `running`, retires the checkout, and only then re-raises the exact
  original interruption. Kernel-start failure follows the same owner cleanup.
- Relationship: `repeated` incomplete sibling of CR-E3-48 and the
  CR-E3-17/19 native-process cluster: control-flow preservation previously
  stopped short of proving physical and durable owner closure.
- Resolution decision: CR-CP-E3-14 selected Option 2 at implementation
  altitude: complete the existing native-review owner's bounded closure while
  preserving the first process-control event.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-53 — an acceptor-owner failure is invisible to presentation waiters

- Review epoch / iteration: 5 / phase-3.14
- Source: `codex review --uncommitted`, Codex session
  `019fde8a-ec09-7473-8ae9-ef4121f4ebcf`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:5050-5052`
- Suspected surface: presentation acceptor thread ownership.
- Statement: a non-peer failure from the acceptor, such as an evidence writer or
  kernel invariant failure, exits the raw thread target without recording a
  presentation-host failure or waking attachment/response waiters. Callers see
  timeouts and shutdown treats the already-dead thread as quiescent success.
- Required outcome: make unexpected acceptor termination visible through the
  existing presentation-host failure channel and wake every waiter class.
- Fix applied: a supervised acceptor wrapper now reports any unexpected error,
  or an ordinary early return while shutdown is not requested, through the
  existing presentation-host failure channel. That channel records the
  original failure and wakes attachment and response waiters; a normal return
  after the stop flag is set remains ordinary shutdown.
- Relationship: `repeated` from E7-NATIVE-011/CR-E3-10 and a sibling of
  CR-E3-49: the raw thread's disappearance was again treated as owner success
  without parent-visible terminal evidence.
- Resolution decision: CR-CP-E3-14 selected Option 2 at implementation
  altitude: supervise this existing owner through the already-defined host
  failure channel rather than introducing a generic thread supervisor.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-54 — qualification signal restoration precedes evidence publication

- Review epoch / iteration: 5 / phase-3.14
- Source: `codex review --uncommitted`, Codex session
  `019fde8a-ec09-7473-8ae9-ef4121f4ebcf`
- Severity / scope: `blocking × in-scope`
- Location: `poc/qualification_pty_tui.py:255-256`
- Suspected surface: qualification-driver finalization.
- Statement: TERM/INT state is restored immediately after child cleanup but
  before raw, JSONL, text, and status evidence is published. A signal in that
  window can terminate the driver after it reaps the child while leaving the
  required qualification packet incomplete.
- Required outcome: keep cleanup signal protection through all required
  evidence publication and restore the caller's exact signal state only as the
  final action.
- Fix applied: child cleanup and raw, JSONL, text, and status evidence
  publication now run within one non-interruptible finalization scope. The
  caller's exact handlers and signal mask are restored in `finally` only after
  publication has completed or failed, and publication failure still
  propagates after restoration.
- Relationship: `repeated` from CR-E3-47/50: signal-safe child cleanup had not
  yet included the evidence tail required to complete the same owner.
- Resolution decision: CR-CP-E3-14 selected Option 2 at implementation
  altitude: extend the existing signal guard through the complete required
  evidence boundary.
- Lifecycle: `actioned; pending phase-3 re-review`

### CR-E3-55 — queued-session close failure can abort presentation shutdown

- Review epoch / iteration: 5 / phase-3.14
- Source: `codex review --uncommitted`, Codex session
  `019fde8a-ec09-7473-8ae9-ef4121f4ebcf`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:5096-5097`
- Suspected surface: queued presentation teardown during host shutdown.
- Statement: an `OSError` or `ValueError` from either queued stream/socket close
  escapes before the acceptor and host threads are joined. Top-level
  finalization can then report unresolved presentation ownership and omit the
  final database export.
- Required outcome: contain expected queued-peer close failures using the
  established non-throwing peer teardown boundary and continue joining both
  owners.
- Fix applied: presentation shutdown now drains every queued session, attempts
  stream and socket teardown independently, records unexpected cleanup
  failures, and still joins both presentation owners and performs final
  quiescence checks. Expected peer-close `OSError` and `ValueError` stay local;
  live-owner nonquiescence retains precedence over a stored cleanup failure.
- Relationship: `repeated` from E7-NATIVE-012/CR-E3-11 and a sibling of
  CR-E3-49: one local close failure could still bypass the aggregate owner's
  mandatory sibling joins.
- Resolution decision: CR-CP-E3-14 selected Option 2 at implementation
  altitude: make existing peer teardown exhaustive while preserving host-level
  failures and mandatory owner joins.
- Lifecycle: `actioned; pending phase-3 re-review`

### Fourteenth-gate source-integrity checkpoint

- Frozen pre/post HEAD: `e045cf1e14277c2befc78a450201a6b19b33ba40`.
- Frozen pre/post complete HEAD diff SHA-256:
  `877587413941af171d63ff852057dcd51ff9dfb5f0bf720e7f4cbdb7e0a8e5cd`.
- Frozen pre/post unstaged tracked-diff SHA-256:
  `4728a927aff5202666ceef32865f0462f359cc87e05790fc9d845f9a5a69db14`.
- Frozen pre/post staged diff SHA-256:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Frozen pre/post status SHA-256:
  `6b4846a1952a8e8218212aef0f94db9462ec23ffc2983e51db5893a23f9ffba4`.
- No untracked files existed before or after the gate. The reviewer did not
  mutate source or index.
- Reviewer verdict: four P1 and one P2 in-scope findings, CR-E3-51 through
  CR-E3-55. Complete Python and Go tests plus compilation, shell, vet, and diff
  checks were green, but the reproduced lifecycle failures keep Phase 3 open.
- Continuation token: assess the complete five-finding set against prior
  lifecycle/ownership clusters before selecting repair altitude. Live PoC,
  commit, integration, and push remain separately gated.

### Convergence checkpoint CR-CP-E3-14

- Review epoch: 5
- Triggered at: phase-3.14, pre-fix
- Diagnosis: `local-design-flaw` (high confidence). CR-E3-51 through CR-E3-55
  repeat one owner-closure defect: a driver exit, one wait, raw thread return,
  child cleanup, or one close attempt is treated as owner completion before the
  complete owned set is closed. Complete closure requires the physical resource
  terminal or absent, durable lifecycle terminal where applicable, required
  evidence published, unexpected failure reported to the parent, and sibling
  owners joined.
- Prior relationships: CR-E3-51 repeats CR-E3-12/36/37; CR-E3-52 is an
  incomplete sibling of CR-E3-48 and the CR-E3-17/19 native-process cluster;
  CR-E3-53 repeats E7-NATIVE-011/CR-E3-10 and is a sibling of CR-E3-49;
  CR-E3-54 repeats CR-E3-47/50; CR-E3-55 repeats
  E7-NATIVE-012/CR-E3-11 and is another sibling of CR-E3-49. The closest prior
  root is CR-CP-E3-02: a local proxy's termination did not prove its complete
  physical owner retired.
- Accepted-plan challenge: no product, requirement, authority, retry, or
  user-visible choice is missing. The accepted PoC already requires child-group
  retirement, complete qualification evidence, visible owner failure, and
  proven shutdown quiescence. PLAN Review remains closed.
- Resolution decision:
  - Problem: close the five ownership obligations without continuing
    line-by-line patchwork or introducing a generic lifecycle framework.
  - Option 1: patch only the five reported lines. Pros: smallest immediate
    diff. Cons: prior gates show that site-local repair misses startup failure,
    alternate exits, evidence tails, and aggregate shutdown paths.
  - Option 2: apply one bounded owner-closure contract within the existing
    owners. Pros: fixes the root while reusing current lifecycle identity,
    host-failure channel, peer-close helper, signal guard, and native execution
    states. Cons: requires a deliberate sibling audit and fault tests across
    the four participating modules.
  - Option 3: add a generic process/thread/resource supervisor and reopen
    architecture. Pros: possible future reuse. Cons: expands lifecycle and
    orchestration surface beyond this bounded PoC and its accepted plan.
  - Recommendation: Option 2.
- Repair altitude: `implementation`; no new authority or generic supervisor.
- Action: make PTY child-group ownership independent of driver liveness;
  terminalize interrupted native review after bounded physical cleanup while
  rethrowing the first interruption; supervise the acceptor through the
  existing host-failure channel; retain qualification signal protection
  through evidence publication; and make queued-peer shutdown teardown
  non-throwing while preserving mandatory joins. Audit only the exact startup,
  alternate-exit, evidence-tail, and join siblings named by the independent
  assessment.
- Status: `actioned`.
- Continuation token: apply this bounded implementation repair, run focused
  fault injection and the complete offline suite, then rerun a fresh holistic
  Phase 3 gate. Live PoC, commit, integration, and push remain separately
  gated.

### Phase 3 fourteenth-gate repair checkpoint

- CR-E3-51 through CR-E3-55 were repaired as one bounded owner-closure change
  inside the existing PTY, native-review, presentation, and qualification
  owners. No product behavior, authority boundary, accepted-plan obligation,
  generic supervisor, or architecture surface changed.
- The repair added twelve focused regressions; the complete focused selection
  passes 15/15, including the previously established neighboring cases.
- Independent unsharded validation: all 269 `unittest` tests pass with one
  expected outer-sandbox-dependent skip; all 268 `pytest` tests pass with the
  same expected skip. Cache-isolated Python compilation, Bash syntax,
  ShellCheck excluding only the established indirect-trap `SC2317` diagnostic,
  uncached Go tests, `go vet`, and complete `git diff --check` pass.
- Continuation token: freeze the complete current source/index state and rerun
  a fresh Phase 3 native Codex gating review over that exact diff. Live PoC
  execution, commit, integration, push, Codex-pin changes, and index changes
  remain separately gated.

### CR-E3-56 — timeout pipe-close failure can leave native review durably running

- Review epoch / iteration: 5 / phase-3.15
- Source: `codex review --uncommitted`, Codex session
  `019fdeb4-972d-72f1-a5ce-fa6cdb8717f4`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:5812-5815`
- Suspected surface: direct native-review timeout owner closure.
- Statement: if closing stdout raises during native-review timeout cleanup,
  stderr close and every following action are skipped. The checkout is not
  retired and the durable native-review execution can remain `running` after
  the process was terminated.
- Required outcome: close both descriptors independently and make checkout
  retirement plus durable terminalization failure-safe before propagating any
  cleanup error.
- Fix applied: timeout and interruption now enter one failure-aggregating native
  owner closure tail. It attempts stdout and stderr closure independently,
  retires the checkout, durably terminalizes any started execution, and records
  `controller_pipes_closed` only when both descriptors actually closed. A
  stdout-close-failure regression proves stderr closure, retirement, and
  terminalization still occur without a false pipe-closure claim.
- Relationship: direct `spawned-sibling` of CR-E3-52 and a repeated instance of
  CR-E3-55's one-local-close-aborts-aggregate-closure shape.
- Resolution decision: CR-CP-E3-15 selected Option 2 at implementation
  altitude: both timeout and interruption paths must enter one bounded,
  failure-aggregating native-owner closure tail.
- Lifecycle: `actioned`; pending fresh Code Review epoch 6.

### CR-E3-57 — native-review teardown remains interruptible outside `wait()`

- Review epoch / iteration: 5 / phase-3.15
- Source: `codex review --uncommitted`, Codex session
  `019fdeb4-972d-72f1-a5ce-fa6cdb8717f4`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:5800-5803` and the complete native-review teardown
  helper.
- Suspected surface: signal ownership across direct native-review teardown.
- Statement: a termination signal during the timeout grace loop, group
  liveness checks, pipe closure, retirement, or durable terminalization can
  escape outside the helper's protected `wait()` call. Cleanup can therefore
  stop before force-kill, evidence closure, checkout retirement, and durable
  terminalization.
- Required outcome: retain or block later TERM/INT events across the complete
  teardown, finish bounded owner closure, then re-raise only the first process
  interruption.
- Fix applied: the complete native-review closure tail now blocks TERM/INT,
  retains the first exact `PrototypeInterrupted`, aggregates later cleanup
  failures, completes process, pipe, checkout, and durable-state closure, then
  restores the prior signal state before propagation. Cut-point tests cover
  later interruptions without leaving a durable execution `running`.
- Relationship: incomplete propagation of CR-E3-48/52 and the
  CR-E3-47/50/54 signal-safe finalization cluster.
- Resolution decision: CR-CP-E3-15 selected Option 2 at implementation
  altitude: signal ownership covers the complete native teardown, not only its
  `wait()` call.
- Lifecycle: `actioned`; pending fresh Code Review epoch 6.

### CR-E3-58 — budget-interrupt workers can write after final evidence export

- Review epoch / iteration: 5 / phase-3.15
- Source: `codex review --uncommitted`, Codex session
  `019fdeb4-972d-72f1-a5ce-fa6cdb8717f4`
- Severity / scope: `blocking × in-scope`
- Location: `poc/controller.py:1415-1419`
- Suspected surface: asynchronous role-budget interrupt ownership.
- Statement: the daemon that sends `turn/interrupt` is neither retained nor
  joined. Shutdown can export and close the kernel after ordinary child cleanup
  while this worker is still inside the journaled request or failure evidence
  append, producing a stale snapshot or a closed-database write.
- Required outcome: retain and quiesce every budget-interrupt worker before the
  `ordinary_writers_stopped` boundary and final evidence export.
- Fix applied: role-budget timers and interrupt workers are retained before
  start, their admission closes at finalization, and `cleanup_children()` now
  cancels and joins them as ordinary evidence writers. A non-quiescent owner
  makes cleanup false, thereby suppressing the final writer-stopped boundary
  and evidence export. Focused tests cover retained-owner cleanup and the
  finalization/admission race.
- Relationship: `repeated` from E7-NATIVE-013, CR-015, CR-E3-11/19, and the
  retained-writer rule diagnosed at Gate 14; this daemon is another omitted
  ordinary writer.
- Resolution decision: CR-CP-E3-15 selected Option 2 at implementation
  altitude: retain, close admission to, and join the existing interrupt workers
  as part of ordinary-writer quiescence.
- Lifecycle: `actioned`; pending fresh Code Review epoch 6.

### CR-E3-59 — settlement deadline race can skip durable fencing

- Review epoch / iteration: 5 / phase-3.15
- Source: `codex review --uncommitted`, Codex session
  `019fdeb4-972d-72f1-a5ce-fa6cdb8717f4`
- Severity / scope: `blocking × in-scope`
- Location: `poc/prototype.py:6304-6308` and the analogous primary-call wait.
- Suspected surface: bounded primary and role-turn settlement.
- Statement: the deadline can expire between the loop condition and the second
  wall-clock read, producing a negative `time.sleep()` duration. Its
  `ValueError` exits closure before `fail_role_turn_settlement`, leaving the run
  and worktree unfenced; the primary-call sibling has the same race.
- Required outcome: compute remaining time once per iteration and break or
  clamp at zero so deadline expiry always reaches durable settlement failure.
- Fix applied: both primary-call and role-turn settlement use one shared wait
  helper that reads `time.time_ns()` once per iteration, exits at non-positive
  remaining time, and never passes a negative duration to `sleep()`. Deadline
  expiry therefore reaches the existing durable settlement-failure fence.
- Relationship: `repeated` settle-or-fence obligation from CR-E3-04/05,
  CR-E3-31/32, and CR-E3-39; deadline arithmetic can still bypass its mandatory
  durable tail.
- Resolution decision: CR-CP-E3-15 selected Option 2 at implementation
  altitude: use one non-negative remaining-time calculation in both existing
  settlement owners.
- Lifecycle: `actioned`; pending fresh Code Review epoch 6.

### CR-E3-60 — pre-join queue drain can miss a late presentation session

- Review epoch / iteration: 5 / phase-3.15
- Source: `codex review --uncommitted`, Codex session
  `019fdeb4-972d-72f1-a5ce-fa6cdb8717f4`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:5123-5130`
- Suspected surface: presentation acceptor-to-host handoff during shutdown.
- Statement: shutdown can drain an empty queue while an authenticated acceptor
  has reserved presentation ownership but has not yet enqueued the session.
  The acceptor may enqueue afterward, both threads may exit, and the socket plus
  `presentation_active` state remain owned by nobody.
- Required outcome: prevent handoff after shutdown or drain and retire queued
  sessions only after the acceptor can no longer enqueue.
- Fix applied: presentation shutdown closes admission and the listener, joins
  the acceptor before its final queue drain, then joins the host. The handoff
  path rechecks stop/admission under the presentation lock, rolls back a
  reserved generation, and closes the peer rather than enqueueing after stop.
  Race tests cover stop during the reservation-to-handoff cut point.
- Relationship: direct `spawned-sibling` of CR-E3-55/45 and a recurrence of
  CR-014, E7-NATIVE-012, and CR-E3-11: consumer drain preceded producer
  quiescence.
- Resolution decision: CR-CP-E3-15 selected Option 2 at implementation
  altitude: close handoff admission, quiesce the queue producer, then perform
  the final exhaustive drain and host join.
- Lifecycle: `actioned`; pending fresh Code Review epoch 6.

### CR-E3-61 — first-interrupt handling has a second-signal window

- Review epoch / iteration: 5 / phase-3.15
- Source: `codex review --uncommitted`, Codex session
  `019fdeb4-972d-72f1-a5ce-fa6cdb8717f4`
- Severity / scope: `significant × in-scope`
- Location: `poc/prototype.py:6894-6895`
- Suspected surface: top-level process-interruption entry.
- Statement: after the first signal raises `PrototypeInterrupted`, SIGTERM and
  SIGINT handlers are changed sequentially without first blocking both. The
  other signal can raise in that window, skip interruption evidence, and alter
  the intended signal exit behavior.
- Required outcome: atomically block TERM and INT before installing non-raising
  dispositions, then enter the established protected finalization path.
- Fix applied: one idempotent signal-state transition blocks SIGTERM and SIGINT
  before changing either handler. The first-interrupt evidence and common
  finalizer run inside that protected interval; handlers are restored while
  blocked and the exact prior mask is restored last. Ordering tests cover the
  former second-signal window.
- Relationship: direct `repeated` instance of CR-E3-47/50/54 at the
  first-interrupt entry immediately before the already-protected common
  finalizer.
- Resolution decision: CR-CP-E3-15 selected Option 2 at implementation
  altitude: reuse one idempotent block-before-handler-change transition.
- Lifecycle: `actioned`; pending fresh Code Review epoch 6.

### CR-E3-62 — diagnostic evidence can be scanned before its writers finish

- Review epoch / iteration: 5 / phase-3.15
- Source: `codex review --uncommitted`, Codex session
  `019fdeb4-972d-72f1-a5ce-fa6cdb8717f4`
- Severity / scope: `significant × in-scope`
- Location: `poc/diagnose_phase4_tool_surface.py:185-186`
- Suspected surface: retained Phase 4 diagnostic producer closure.
- Statement: App Server process exit can precede completion of its stdout reader
  and request-handler workers. `close()` returns and the evidence safety scan
  can pass while those workers are still appending the raw log.
- Required outcome: retain and join the reader and every spawned request worker
  before `close()` returns and evidence is scanned or sealed.
- Fix applied: the diagnostic client retains its stdout reader and every
  server-request handler, closes handler admission before process shutdown,
  and joins all retained producers before returning from `close()`. Reader or
  handler non-quiescence is returned as an explicit qualification failure, so
  the evidence scan cannot establish success while a writer remains live.
- Relationship: `repeated` from CR-015 and SR-002 at the retained diagnostic
  boundary: evidence consumption again starts before all producers are joined.
- Resolution decision: CR-CP-E3-15 selected Option 2 at implementation
  altitude: retain and quiesce the diagnostic's existing producer threads
  before evidence consumption.
- Lifecycle: `actioned`; pending fresh Code Review epoch 6.

### Fifteenth-gate source-integrity checkpoint

- Frozen pre/post HEAD: `e045cf1e14277c2befc78a450201a6b19b33ba40`.
- Frozen pre/post complete HEAD diff SHA-256:
  `21498c2d76d9e888746594fa99e664cd86f1dfc8a83a8ab362bee2178ac4e702`.
- Frozen pre/post unstaged tracked-diff SHA-256:
  `dc643df35ad96bf3f2c1a700133b8021761f35d4db862301a9e26b214d19e98f`.
- Frozen pre/post staged diff SHA-256:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Frozen pre/post status SHA-256:
  `3979042543b33d203bfb7e9c4d143439f113e17b745a11516263a235dd26ccd2`.
- No untracked files existed before or after the gate. The reviewer did not
  mutate source or index.
- Reviewer verdict: four P1 and three P2 in-scope findings, CR-E3-56 through
  CR-E3-62. The complete Python and Go tests plus compilation, shell, vet, and
  diff checks were green, but the reproduced lifecycle races keep Phase 3 open.
- Continuation token: diagnose this seven-finding set against the cumulative
  owner-closure history before another fix iteration. Live PoC, commit,
  integration, push, Codex-pin changes, and index changes remain separately
  gated.

### Convergence checkpoint CR-CP-E3-15

- Review epoch: 5
- Triggered at: phase-3.15, pre-fix
- Continuation:
  - Phase: `phase-3`
  - Boundary: `pre-fix`
  - Lane: `gating`
  - Required next action: disposition and repair CR-E3-56 through CR-E3-62,
    then restart Code Review from Phase 1 in a new epoch as required by the
    active review-control contract.
- Trigger: fresh P1 findings again appeared in sibling owner-closure surfaces
  after Gate 14's claimed bounded owner-closure repair.
- Evidence clusters: CR-E3-56/57 are unclosed native-review teardown tails;
  CR-E3-58/60/62 are producer quiescence omissions before final consumption;
  CR-E3-59 lets intermediate deadline arithmetic bypass mandatory fencing; and
  CR-E3-61 leaves one signal window before the common protected finalizer.
- Diagnosis: `local-design-flaw` (high confidence). Teardown remains linear and
  path-specific rather than following one bounded closure order: stop new
  owner creation or handoff, retain every existing producer, complete
  independent physical and durable closure despite local failures or later
  signals, prove terminality, then publish or consume final evidence.
- Resolution decision:
  - Problem: close the recurring owner-closure class without seven isolated
    patches or a production-grade lifecycle framework.
  - Option 1: patch the seven reported statements. Pros: smallest immediate
    diff. Cons: repeats the repair method that missed timeout alternatives,
    producer races, signal tails, and retained diagnostic workers.
  - Option 2: apply a bounded closure inventory and small shared local
    primitives inside the existing owners. Pros: fixes the governing defect,
    preserves existing ownership and durable schema, and adds no user-visible
    behavior, authority, or retry policy. Cons: requires explicit cut-point
    tests across the existing native-review, controller, presentation,
    settlement, signal, and diagnostic owners.
  - Option 3: introduce a generic resource/thread supervisor and reopen
    architecture. Pros: possible future reuse. Cons: expands lifecycle and
    orchestration surface beyond the MVP and its explicit exclusions.
  - Recommendation: Option 2.
- Repair altitude: `implementation`. The accepted PLAN already requires these
  exact owner, settlement, signal, presentation, and evidence boundaries; no
  product requirement, accepted architecture, scope block, or Plan Review is
  reopened.
- Action: implement only Option 2, add the bounded failure/race tests named by
  the independent analyst, run focused and complete offline validation, then
  begin review epoch 6 at Phase 1 with the cumulative ledger retained.
- Status: `actioned`.
- Status evidence: independent `review-convergence-analyst` accepted all seven
  obligations, found one repeated local owner-closure defect, selected the
  bounded implementation repair, and reported no additional blocking or
  significant finding.

### Epoch 6 restart checkpoint

- Prior checkpoint: CR-CP-E3-15 is actioned by the bounded Option 2 repair;
  closure remains pending a clean restarted hard gate.
- Review continuation:
  - Review epoch: 6
  - Phase: `phase-1`
  - Boundary: `discovery`
  - Lane: `gating`
  - Required next action: dispatch a fresh history-blind
    `code-review-analyst` over the complete current code-change artifact.
- Implemented owner-closure inventory:
  - native review uses one signal-shielded, failure-aggregating physical and
    durable closure tail for startup failure, interruption, and timeout;
  - controller role-budget timers/workers are retained, admission-closed, and
    joined before the ordinary-writer boundary;
  - role and primary settlement share one single-clock-read deadline wait;
  - presentation handoff rechecks stop/admission and shutdown joins its
    producer before the final queue drain;
  - first-interrupt handling blocks both termination signals before changing
    either disposition; and
  - the diagnostic client joins every raw-evidence producer and fails
    qualification on non-quiescence.
- Changed implementation/test files for this repair:
  `poc/prototype.py`, `poc/controller.py`,
  `poc/diagnose_phase4_tool_surface.py`, `poc/test_prototype.py`,
  `poc/test_controller.py`, and `poc/test_phase4.py`.
- Validation: focused affected suites passed 18 + 10 + 35 + 37 + 22 tests;
  complete unittest passed 279 tests with one skip; complete pytest passed 278
  tests with one skip; Python compilation, shell syntax, shellcheck, uncached
  Go tests, `go vet`, and `git diff --check` are green.
- Frozen dispatch state:
  - HEAD: `e045cf1e14277c2befc78a450201a6b19b33ba40`
  - staged diff SHA-256:
    `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`
  - complete unstaged diff SHA-256 before this checkpoint:
    `ff6b2c13869f57f94113d137dcf30207b819324248548382234ddc726d81c059`
  - status SHA-256 before this checkpoint:
    `0c12757510713afca71a543ac251b784b94701bd771d5e9446185f80d33ccbe6`
  - untracked files: none.
- Authority remains unchanged: no live PoC, staging/index mutation, commit,
  integration, push, or Codex qualification-pin update is authorized by this
  checkpoint.

### Epoch 6 Phase 1 holistic discovery

- Reviewer: fresh delegated `code-review-analyst` in discovery lane, with the
  accepted scope block and complete code-change artifact but without this
  ledger, prior findings, root-cause claims, or claimed fixes.
- Verdict: `CLEAN`; no actionable `blocking × in-scope` or
  `significant × in-scope` finding.
- Coverage: complete change inventory other than this intentionally withheld
  ledger, including plan/context, kernel/controller/prototype, PTY,
  evidence/provenance, validation sandbox, launchers, role prompts, fixtures,
  tests, Go transport, and vendored dependency context.
- Independent validation: pytest passed 278 tests with one skip; Go tests and
  vet, Python compilation, and shell syntax passed. The complete HEAD diff's
  only whitespace diagnostics are blank-line-at-EOF warnings in two unchanged
  vendored Gorilla documentation files; they are not an actionable correctness
  finding and the vendor content remains unmodified.
- Phase 1 exit reason: holistic history-blind discovery produced only marginal
  vendor-format noise and no substantive issue; no active checkpoint blocks
  progression.
- Continuation token: proceed to Code Review Phase 2 simplification over the
  current changed implementation. No live PoC, staging/index mutation, commit,
  integration, push, or Codex qualification-pin update is authorized.

### Epoch 6 Phase 2 simplification

- Independent read-only simplification audit inspected every changed
  non-vendored source, test, and script and identified three
  behavior-preserving reductions.
- Applied reductions:
  - removed the uncalled weaker `DurableKernel.handoff_run` transition and its
    sole isolated test; the workflow uses only the stricter
    `handoff_assigned_run` contract and its end-to-end coverage;
  - replaced three identical primary-action start/terminal persistence loops
    with one module-private helper without moving caller validation, binding,
    outcome, terminal-turn, or settlement ordering; and
  - replaced two identical terminal attention-summary attempts with one nested
    helper while preserving branch artifacts, messages, interruption behavior,
    and exit codes.
- Semantic-surface assessment: subtractive only. No product behavior,
  authority, durable schema, lifecycle, retry rule, or interface changed.
- Validation: focused kernel passed 32 tests; focused prototype/workflow passed
  63 tests; complete unittest passed 278 tests with one skip; complete pytest
  passed 277 tests with one skip; Python compilation and `git diff --check`
  passed; the deleted API has no remaining caller. The staged diff SHA-256
  remains `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Continuation token: run the applicable security and user-facing-flow
  specialist reviews over the simplified current implementation. No live PoC,
  staging/index mutation, commit, integration, push, or Codex qualification-pin
  update is authorized.

### Epoch 6 Phase 2.5 security review

- Reviewer: delegated `security-researcher`, scoped to the current local PoC's
  network, capability, parsing, subprocess, filesystem, SQLite authority,
  approval/candidate, validation-sandbox, and vendored-dependency boundaries.
- Verdict: `CLEAN`; no verified `blocking × in-scope` or
  `significant × in-scope` security finding.
- Positive evidence: loopback-only listeners; separate random audience-bound
  public/internal capabilities; fixed message bounds/deadlines; reconstructed
  allowlisted App Server requests; minimal model/tool environments; sandboxed
  candidate validation; controller-only owner-mode SQLite; exact persisted
  approval/verifier/candidate binding; fast-forward-only integration; isolated
  read-only native review; credential scrubbing; and vendored Gorilla source
  matching the pinned local module-cache copy.
- Validation limits: focused offline Go transport tests passed. The specialist
  sandbox could not open a socket for one Go test, so that environmental
  failure was not treated as product evidence. No live PoC was run.
- Continuation: await and synthesize the parallel user-facing-flow specialist
  result before Phase 3.

### UX-E6-01 — paused fresh-direction input does not recover from presentation detach

- Review epoch / iteration: 6 / specialist pass 1.
- Source: delegated `ux-reviewer`, targeted verification after synthesis
  challenged the original over-broad controller-restart scenario.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:3069-3072`, `poc/prototype.py:3139-3142`,
  and the `PresentationDetached` boundary in `NativeCliPrimaryInterface`.
- Statement: after a high-stakes no-effect result enters
  `wait_for_reconsideration()` or the intent-revision equivalent, detaching only
  the inner stock CLI while the controller remains alive lets `response()`
  raise through the top-level failure path. The same outcome cannot continue
  through the accepted bounded reattachment behavior.
- Scenario: reject or clarify a proposal -> enter its fresh-direction prompt ->
  inner presentation detaches before direction admission -> controller and
  durable work remain alive -> uncaught `PresentationDetached` fails the PoC
  instead of reattaching and re-rendering the same no-effect pause.
- Required outcome: catch detach around each paired pause-presentation/response,
  reattach with a compact no-effect summary, and re-render the unchanged fresh-
  direction prompt. Whole-controller restart remains out of scope.
- Suggested resolution: reuse the existing `reattach()` primitive in both
  paused-direction loops; add a focused regression test.
- Fix applied: both paused-direction loops now catch `PresentationDetached`
  across the paired presentation/response boundary, use the existing bounded
  reattach primitive with an unchanged/no-effect summary, and regenerate the
  same fresh-direction prompt. Focused tests cover both the ordinary proposal
  pause and intent-revision pause while the controller remains alive.
- Lifecycle: `resolved`; verified by UX specialist pass 2.

### UX-E6-02 — first launch visibly requests input while input is closed

- Review epoch / iteration: 6 / specialist pass 1.
- Source: delegated `ux-reviewer`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/prototype.py:7058-7060`, the initial attach/input sequence in
  `poc/prototype.py:5267-5331`, and `poc/pty_tui.py:380-398,489-497`.
- Statement: the initial attach turn asks the user for the coding outcome while
  the PTY input gate is closed. Speech responding to that visible request is
  discarded, then the controller asks the same intake question after opening
  the real response window.
- Required outcome: only the response-eligible turn asks for user input.
- Suggested resolution: make the attach turn a brief non-interactive readiness
  message and retain the existing controller intake question as the sole ask.
- Fix applied: the initial native attach now requests only a brief readiness
  acknowledgement and explicitly forbids asking for input. The later
  response-eligible controller request remains the sole outcome-intake ask;
  exact prompt coverage protects that sequence.
- Lifecycle: `resolved`; verified by UX specialist pass 2.

### UX-E6-03 — long successful-path phases expose no useful milestone status

- Review epoch / iteration: 6 / specialist pass 1.
- Source: delegated `ux-reviewer`.
- Severity / scope: `significant × in-scope`.
- Location: milestone obligation at `poc/PLAN.md:157-161`; execution boundaries
  around `poc/prototype.py:4254-4290`; generic closed-input status at
  `poc/pty_tui.py:403-405`.
- Statement: after accepted intent, planning, implementation, review, and
  validation can run for long periods while the user sees only generic
  `Working` feedback and cannot distinguish progress from a stalled process.
- Required outcome: expose compact truthful progress at existing phase
  boundaries without opening a concurrent semantic-input protocol.
- Suggested resolution: present fixed or already-available primary-owned
  milestone outputs for planning, implementation, review, and validation; keep
  the input gate closed until a defined response window.
- Fix applied: fixed user-language milestones now mark entry to plan/review,
  implementation, complete-candidate review, and validation/plan-closure at
  their existing phase boundaries. They neither open the input gate nor add a
  model call, state transition, or concurrent-input protocol. The complete
  narrative test verifies their order.
- Lifecycle: `resolved`; verified by UX specialist pass 2.

### UX-E6-04 — rebind acknowledgement exposes internal orchestration machinery

- Review epoch / iteration: 6 / specialist pass 1.
- Source: delegated `ux-reviewer`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/prototype.py:4429-4431` and user-facing rule at
  `poc/roles/prototype-primary.md:34-36`.
- Statement: the continuity message requires the user to parse `logical
  primary`, `replacement physical session`, `exact ledger catch-up`, and
  `independent implementer`, contradicting the one-accountable-primary user
  boundary.
- Required outcome: retain the request/progress continuity and no-effect facts
  in ordinary user language.
- Suggested resolution: say the request and current progress are intact, no
  change was approved or integrated during reconnection, and work continues
  from the latest checkpoint.
- Fix applied: the rebind acknowledgement now says in ordinary user language
  that the request and current work are intact, progress made while
  reconnecting is preserved, no change was approved or integrated during
  reconnection, and work continues from the latest checkpoint.
- Lifecycle: `resolved`; verified by UX specialist pass 2.

### Epoch 6 specialist synthesis — UX pass 1

- Security result: clean.
- UX synthesis correction: the initial claim that a terminated controller must
  resume from the same run ID was rejected as out-of-scope crash recovery.
  Detach during an ordinary pending-proposal response is already correct. The
  retained blocker is only the controller-alive paused-direction sibling path.
  The request to accept arbitrary input while `Working` was also rejected; the
  retained obligation is passive milestone visibility.
- Convergence trigger: not fired. This is the first substantive review/fix
  iteration in epoch 6; no active-epoch claimed fix has repeated or spawned a
  new P1.
- Resolution decision:
  - Problem: close the four user-flow gaps without introducing a generic resume
    service, concurrent semantic input, or new authority lifecycle.
  - Option 1: reuse current presentation primitives for paused reattachment,
    make initial attach non-interactive, show fixed truthful phase milestones,
    and simplify reconnect wording. Pros: satisfies the exact UX obligations
    with no state/schema/authority change. Cons: progress remains compact and
    predetermined.
  - Option 2: add a generic resume command, concurrent user questions, and
    model-generated live status. Pros: richer interaction. Cons: adds lifecycle,
    semantic-input, and recovery surface beyond this MVP.
  - Option 3: accept the gaps. Pros: no code. Cons: fails the accepted bounded
    detach and voice-first experience.
  - Recommendation: Option 1.
- Repair altitude: `implementation`; no accepted product decision, architecture,
  scope block, or plan changes.
- Continuation token: phase `phase-2-review`, boundary `pre-fix`, lane
  `specialist`; implement Option 1, record fixes, then rerun the applicable UX
  specialist over the complete changed flow. Phase 3 remains blocked until that
  re-review is marginal or clean.

### Epoch 6 UX Option 1 repair checkpoint

- Scope: implementation-altitude UX repair only. Source behavior changed only
  in `poc/prototype.py`; directly relevant coverage changed in
  `poc/test_prototype.py` and `poc/test_validation_sandbox.py`. No schema,
  authority, lifecycle, role prompt, controller, kernel, diagnostic, PLAN, pin,
  main-repository, staging, commit, live-run, integration, or push change.
- UX-E6-01 through UX-E6-04 are actioned pending specialist re-review. This is
  epoch 6 substantive review/fix iteration 1; no repeated claimed fix or new P1
  has yet triggered a convergence checkpoint.
- Independent validation: the four focused regressions passed; `py_compile`
  passed; full `unittest` passed 279 tests with one skip; full `pytest` passed
  278 tests with one skip; `git diff --check` passed.
- Staged binary diff SHA-256 remains
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Continuation token: phase `phase-2-review`, boundary `post-fix`, lane
  `specialist`; rerun the UX specialist over the complete current user flow.
  Phase 3 remains blocked until that re-review is marginal or clean.

### UX-E6-05 — high-stakes render detach escapes bounded reattachment

- Review epoch / iteration: 6 / specialist pass 2.
- Source: delegated `ux-reviewer` post-fix holistic re-review.
- Severity / scope: `blocking × in-scope`.
- Location: the high-stakes presentation/response window at
  `poc/prototype.py:3229-3236` and the native render-receipt boundary around
  `poc/prototype.py:5480-5534`.
- Statement: the main high-stakes path presents the proposal before entering
  the detach-recovery `try`. If the inner stock CLI detaches while rendering or
  before the exact render receipt returns, `present_decision()` raises through
  the top-level failure path instead of reattaching and presenting the same
  still-pending proposal again.
- Scenario: controller remains alive -> high-stakes proposal is current ->
  inner presentation detaches during render -> no authority or effect exists ->
  workflow fails rather than continuing the bounded pending-proposal journey.
- Required outcome: bounded recovery must encompass the complete high-stakes
  presentation-and-response window and re-render the same pending proposal
  after reattach, without carrying authority/effect across the detach.
- Verification gap: response-time detach and both paused-direction windows are
  covered; no regression injects detach from `present_decision()` itself.
- Fix applied: `present_high_stakes()` now catches `PresentationDetached`
  across the complete caller-owned presentation, durable render marking,
  response, and response-admission window. Its existing `ValueError` recovery
  remains nested only around response/admission. Cached content, proposal
  identity, pending checks, and later interpretation/authority order are
  unchanged. Focused tests cover successful render-detach replay and
  render-detach reattach failure.
- Relationship: `spawned-sibling` of UX-E6-01. The claimed paused-window fix
  exposed that detach recovery ownership is still distributed across decision
  call sites and the main high-stakes path protects only response capture.
- Lifecycle: `resolved`; verified by UX specialist pass 3.

### Epoch 6 UX specialist pass 2 and convergence trigger

- UX-E6-01 through UX-E6-04 are resolved by full-flow specialist verification.
- New UX-E6-05 is a P1 sibling after the UX-E6-01 fix, so the convergence
  checkpoint triggers immediately rather than waiting for three substantive
  iterations.
- Specialist's provisional diagnosis: `local-design-flaw`, high confidence.
  The candidate governing issue is fragmented ownership of a decision's
  presentation-and-response recovery window; product and scope requirements
  remain unchanged.
- Specialist validation: 16 focused UX/workflow tests and all 88
  `test_prototype.py` tests passed; holistic inspection covered PLAN, primary
  prompt, `PrimaryInterface` call sites, native CLI/PTY behavior, launch flow,
  and relevant tests. No live PoC was run.
- Continuation token: phase `phase-2-review`, boundary `pre-fix`, lane
  `convergence`; independently diagnose UX-E6-05 against all current decision
  windows and choose repair altitude before any implementation.

### CR-CP-E6-01 — UX-E6-05 decision-window convergence checkpoint

- Trigger: UX specialist pass 2 found a new P1 sibling immediately after the
  UX-E6-01 repair.
- Independent verdict: UX-E6-05 is valid, `spawned-sibling`, high confidence.
  Final diagnosis is `local-fix-appropriate`, high confidence; this corrects
  the specialist's broader provisional `local-design-flaw` classification.
- Governing invariant, narrowed by CR-CP-E6-02: a high-stakes
  `presented_response` window begins at `present_decision()` and remains
  generation-current through atomic proposal-response admission. An ordinary
  opaque input instead remains physically generation-current through successful
  capture return; a later detach does not invalidate that completed capture.
- Site audit: both paused-direction windows already satisfy the invariant. Only
  `present_high_stakes()` begins recovery after presentation and durable render
  marking, so only that site is incorrect.
- Resolution decision:
  - Problem: close the proven render-time detach gap without changing transport
    ownership, proposal semantics, or generic lifecycle.
  - Option 1: extend the existing high-stakes recovery boundary across
    presentation, durable render marking, response, and response admission.
    Pros: smallest direct repair; preserves current owner, cached rendering,
    pending-proposal check, and replay semantics. Cons: semantically different
    decision sites retain their own explicit recovery blocks.
  - Option 2: add a shared decision-window helper. Pros: superficially
    centralizes pairing. Cons: high-stakes has an intervening durable transition
    and cached presentation, while pause paths regenerate and have no such
    transition; a helper needs callbacks/policy and adds non-load-bearing
    abstraction.
  - Option 3: move recovery into `PrimaryInterface`. Pros: central transport
    surface. Cons: wrong owner; the interface cannot know durable pending state,
    cached-vs-regenerated content, or the truthful no-effect summary without
    coupling transport to kernel/workflow semantics.
  - Recommendation: Option 1.
- Repair altitude: `implementation`. No product, requirement, scope, schema,
  authority, or architecture decision is missing.
- Bounded implementation: change only `WorkflowEngine.present_high_stakes()`
  and focused tests. Preserve paused-direction loops, all interfaces,
  controller, kernel, proposal schema, cached presentation behavior, and
  response-admission `ValueError` semantics.
- Required regression: first `present_decision()` detaches; reattach once;
  re-render the same proposal ID and byte-identical cached content under a new
  generation; presentation model called once; detached generation creates no
  interpretation, authority, or effect; successful response binds only to the
  replacement generation; reattach failure remains pending and effect-free.
- Continuation token: phase `phase-2-review`, boundary `pre-fix`, lane
  `implementation`; apply Option 1, validate, then rerun UX specialist pass 3.

### Epoch 6 UX-E6-05 repair checkpoint

- Scope: only `poc/prototype.py` and directly relevant
  `poc/test_prototype.py` coverage changed. No paused-direction loop,
  interface, controller, kernel, schema, authority, lifecycle, role, PLAN, pin,
  main-repository, staging, commit, live-run, integration, or push change.
- Independent validation: three focused decision-window tests passed;
  `py_compile` passed; full `unittest` passed 280 tests with one skip; full
  `pytest` passed 279 tests with one skip.
- The successful replay regression proves same proposal ID, byte-identical
  cached presentation, generations 1 then 2, one presentation model call, one
  reattach, response/interpretations bound only to generation 2, and no effect.
  The failure regression proves a render-time reattach failure leaves the
  proposal pending, without a presentation generation, interpretation, or
  effect.
- This is epoch 6 substantive review/fix iteration 2. The immediate sibling P1
  already triggered and completed CR-CP-E6-01; no further convergence trigger
  is pending before specialist re-review.
- Staged binary diff SHA-256 must remain
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Continuation token: phase `phase-2-review`, boundary `post-fix`, lane
  `specialist`; run UX specialist pass 3 over every decision window and the
  complete user flow. Phase 3 remains blocked until marginal or clean.

### UX-E6-06 — pause direction detach race after capture and before durable admission

- Review epoch / iteration: 6 / specialist pass 3.
- Source: delegated `ux-reviewer` post-fix holistic re-review.
- Severity / scope: reported `blocking × in-scope`; independently rejected as
  an invalid product-assumption mismatch.
- Location: pause presentation/capture/admission windows at
  `poc/prototype.py:3072-3083` and `poc/prototype.py:3149-3160`; generic input
  admission at `poc/prototype.py:2050-2065`.
- Statement: each pause loop catches detach through `response()` but then
  persists the captured direction with `admit_opaque_user_text()` outside the
  recovery block. If the presentation detaches after capture returns and before
  persistence, the generic admission checks primary epoch but not presentation
  generation; the direction may therefore drive reconsideration or continuation
  after the UI has detached.
- Scenario: no-effect pause is rendered -> user direction is captured while the
  controller is alive -> inner presentation detaches before durable input
  persistence -> captured direction is interpreted and can resume a branch
  without reattachment.
- Reported required outcome: keep the pause window open through a
  generation-current admission/check; if detach wins, discard the capture,
  reattach, and re-render the same semantic direction prompt.
- Verification gap: existing pause tests inject detach from presentation or
  response, not between response return and generic persistence.
- Relationship: reported `repeated` instance of the CR-CP-E6-01 complete-window
  invariant at both pause admission edges. The original UX-E6-01 render/response
  scenarios remain fixed; whether its obligation should be reopened or this is
  a distinct sibling depends on the convergence diagnosis.
- Fix applied: none; no source defect exists under the accepted input-envelope
  semantics.
- Resolution decision: CR-CP-E6-02 selected Option 3. Successful ordinary
  capture return is its presentation-current cut point; later detach does not
  retroactively erase that captured direction.
- Lifecycle: `retracted`; no code action.

### Epoch 6 UX specialist pass 3 and repeated-P1 trigger

- UX-E6-02 through UX-E6-05 are verified resolved. UX-E6-01's original
  render/response scenarios remain correct, but the specialist classifies
  UX-E6-06 as an incomplete edge of the broader CR-CP-E6-01 invariant.
- Specialist found no other blocking/significant issue across startup,
  long-voice intake, passive milestones, primary rebind wording, pause/failure,
  candidate review, validation, closure, and integration.
- Specialist validation: 109 prototype/PTY tests passed. No live PoC was run.
- Convergence triggers immediately because the same P1 invariant recurred after
  a claimed fix, now at two admission edges; this is epoch 6 substantive
  review/fix iteration 3.
- Continuation token: phase `phase-2-review`, boundary `pre-fix`, lane
  `convergence`; independently establish whether post-capture detach invalidates
  a direction already captured under a current generation, audit all analogous
  capture/admission sites, and challenge the proposed shared primitive before
  implementation.

### CR-CP-E6-02 — ordinary-capture versus presented-response boundary

- Trigger: UX-E6-06 claimed the CR-CP-E6-01 high-stakes admission boundary
  recurred at both ordinary pause-direction inputs.
- Independent verdict: UX-E6-06 is invalid as reported; classification
  `product-assumption-mismatch`, high confidence. It is neither `repeated` nor
  `spawned-sibling`; it overextended high-stakes `presented_response` semantics
  to ordinary opaque input.
- Accepted product boundary:
  - Ordinary opaque input is captured under presentation generation G;
    `NativeCliPrimaryInterface` performs a final G-current check before
    `response()` returns. At that return the user-input occurrence is complete.
    Later SQLite ordering and typed primary interpretation create durable and
    semantic identity, but later presentation detach does not erase the captured
    words.
  - A high-stakes proposal response is deliberately stricter: generation G must
    remain current through atomic durable `proposal_responses` admission. Detach
    before that point invalidates the envelope and requires re-presentation;
    detach afterward preserves the exact admitted response.
- Plan/code evidence: PLAN gives `direct_intake` no presentation epoch and gives
  only `presented_response` exact completed-render/generation validity through
  response admission. Initial intake, intake clarification, and both no-effect
  fresh-direction paths use `admit_opaque_user_text()`; only
  `present_high_stakes()` uses `admit_proposal_response()`. A rejected/no-effect
  proposal ID in a pause prompt is rendering identity, not a reopened proposal
  authority envelope.
- Call-site audit: initial outcome, intake clarification, ordinary pause
  direction, and intent-revision pause direction are generic opaque input;
  high-stakes plan/restart/integration/ITD decisions are generation-bound
  proposal responses. No analogous user-input site is missed.
- Resolution decision:
  - Problem: decide whether disconnect after successful ordinary capture but
    before SQLite persistence invalidates the captured direction.
  - Option 1: add a local post-response generation check. Pros: small apparent
    diff. Cons: semantically wrong and still racy; detach can occur after the
    check, and post-insertion invalidation conflicts with append-only ordering.
  - Option 2: return a generation-bound token and atomically validate it at
    admission. Pros: can implement the reviewer's stricter semantics only if
    detach and SQLite share one serialization boundary. Cons: creates a new
    presented-direction envelope and changes interface/kernel/schema ownership,
    direct intake, clarification, and voice behavior without an accepted
    product requirement.
  - Option 3: preserve the existing ordinary-capture boundary and narrow the
    review invariant. Pros: matches PLAN, keeps captured voice input once
    acknowledged, and adds no state/authority/protocol. Cons: the distinction
    must remain explicit to prevent future false recurrence.
  - Recommendation: Option 3.
- Repair altitude: no code repair. CR-CP-E6-01 wording is narrowed above. A new
  product decision would be required only if ordinary fresh directions are to
  become exact presentation-bound envelopes.
- UX-E6-01 and UX-E6-05 remain resolved. No shared decision-window primitive,
  generation token, pause-loop change, interface/kernel/schema change, or new
  test obligation follows from UX-E6-06.
- Continuation token: phase `phase-2-review`, boundary `post-convergence`, lane
  `specialist`; ask the UX specialist to re-evaluate UX-E6-06 against the
  accepted direct-input versus presented-response distinction. Phase 3 remains
  blocked until that verdict is corrected and the holistic UX pass is clean or
  marginal.

### Epoch 6 UX specialist pass 4 — corrected clean verdict

- Verdict: `CLEAN`; no blocking or significant current-scope UX finding.
- UX-E6-01 through UX-E6-05 are verified resolved. UX-E6-06 is dismissed as a
  false positive caused by applying `presented_response` semantics to ordinary
  fresh-direction input.
- Accepted distinction verified in PLAN and code: ordinary opaque capture is
  generation-current through successful `response()` return and remains valid
  if the inner presentation later detaches; an active high-stakes proposal
  remains generation-current through atomic `proposal_responses` admission.
- Holistic coverage included first-time long-voice intake, pause/reconsideration,
  controller-alive detach, physical-primary rebind, passive milestones,
  candidate review, validation, closure, and integration. Seven focused
  regressions passed; no live PoC was run.
- Convergence: no UX trigger remains. The apparent repeated P1 was a product-
  assumption mismatch, not another implementation failure.
- Epoch 6 Phase 2 exit: security clean, UX clean, all actionable specialist
  findings resolved, invalid finding retracted, CR-CP-E6-01 and CR-CP-E6-02
  complete. Proceed to the independent native Phase 3 gate over the exact
  current uncommitted target.

## Phase 3 native Codex hard gate — epoch 6 discovery pass

### CR-E6-01 — detach can race durable presentation marking

- Review epoch / iteration: 6 / phase-3.1.
- Source: `codex review --uncommitted`, Codex session
  `019fdf31-30e2-7640-92b3-cf8ad99b4506`.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:3233-3235` in
  `WorkflowEngine.present_high_stakes()`.
- Statement: presentation generation G can detach after
  `present_decision()` returns but before `mark_proposal_presented()` commits.
  The detach invalidation then observes a still-pending proposal and changes
  nothing; the subsequent mark records stale G as presented. When response
  capture reports the detach, pending-only reattachment refuses to replay the
  proposal and pauses the workflow.
- Reproduction: the native reviewer injected invalidation between completed
  rendering and the durable mark and observed `WorkflowStopped` with the
  proposal left `presented` at generation 1.
- Required outcome: detach invalidation and durable presentation marking must
  have one serialized/currentness boundary so a detached generation cannot be
  committed as current; the same still-pending proposal must be re-presentable.
- Relationship: possible `repeated` instance of UX-E6-05 and
  CR-CP-E6-01's high-stakes presentation-window obligation. Exact root pattern
  and repair altitude require convergence assessment before a fix.
- Fix applied: none.
- Lifecycle: `open`; blocks Phase 3 exit.

### CR-E6-02 — invalid mixed input consumes the open response window

- Review epoch / iteration: 6 / phase-3.1.
- Source: `codex review --uncommitted`, Codex session
  `019fdf31-30e2-7640-92b3-cf8ad99b4506`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/prototype.py:4946-4952` in
  `InteractiveController._handle_downstream_message()`.
- Statement: a `turn/start` carrying one text item plus an attachment or other
  invalid shape can be read as opaque text and clear `capture_next_input`
  before the base controller validates and dispatches the turn. Base rejection
  then creates no acknowledgement turn, so the exact-one-created-turn check
  raises and terminates the presentation host.
- Required outcome: an open response window is consumed only by a canonical,
  successfully admitted and dispatched user turn; malformed or rejected input
  must remain a no-authority rejection without terminating presentation.
- Relationship: first observed instance in epoch 6; assess alongside the other
  presentation-boundary findings before repair.
- Fix applied: none.
- Lifecycle: `open`; Phase 3 remains open.

### CR-E6-03 — Unicode bidi controls survive terminal-safe presentation

- Review epoch / iteration: 6 / phase-3.1.
- Source: `codex review --uncommitted`, Codex session
  `019fdf31-30e2-7640-92b3-cf8ad99b4506`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/prototype.py:534-537` in
  `terminal_safe_presentation()`.
- Statement: Unicode bidirectional override and isolate controls such as
  U+202E and U+2066 survive the terminal filter. A terminal may visually
  reorder or conceal approval-envelope text even though the digest correctly
  binds the underlying bytes.
- Required outcome: terminal approval text and the bytes hashed for its render
  receipt must exclude bidi formatting controls that can change the visible
  order or containment of decision text.
- Relationship: first observed instance in epoch 6; assess whether this is a
  local sanitization omission or evidence of a broader presentation-trust
  boundary gap.
- Fix applied: none.
- Lifecycle: `open`; Phase 3 remains open.

### Epoch 6 Phase 3.1 gate and source-integrity checkpoint

- Native gate verdict: three actionable findings, CR-E6-01 through CR-E6-03;
  Phase 3 does not exit.
- Gate validation: full Python `pytest` passed 279 tests with one skip; full Go
  tests passed; Python compilation checks passed. These passing suites did not
  cover the three reproduced/inspected boundary failures above.
- Source integrity after the external review matches the frozen pre-gate
  target exactly: HEAD
  `e045cf1e14277c2befc78a450201a6b19b33ba40`; complete HEAD binary diff
  SHA-256 `113eb7b1ce8e9c5878ab3616a9b541ccb336264037b93e79cc403d8c16469b47`;
  unstaged binary diff SHA-256
  `49ba2b0ba8bdea5ff548cde623c6603e435498a9a6e2f219ce03a542666c6fbb`;
  staged binary diff SHA-256
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`;
  status SHA-256
  `0c12757510713afca71a543ac251b784b94701bd771d5e9446185f80d33ccbe6`;
  no untracked files.
- Continuation token: phase `phase-3`, boundary `pre-fix`, lane
  `convergence`; independently classify the cross-finding pattern and select
  repair altitude before changing source.

### CR-CP-E6-03 — Phase 3.1 presentation-boundary convergence checkpoint

- Trigger: CR-E6-01 reproduced a blocking failure at the same high-stakes
  presentation site after UX-E6-05 was claimed resolved; CR-E6-02 and
  CR-E6-03 were discovered in the same native gate.
- Independent validity: all three findings are valid at their reported
  severities.
- Pattern classification:
  - CR-E6-01 is `repeated` from UX-E6-05/CR-CP-E6-01. The previous repair
    widened exception coverage but did not restore the durable pending
    invariant when detach invalidation ran before presentation marking.
    Root classification: `local-design-flaw`, high confidence.
  - CR-E6-02 is a separate `local-design-flaw`, high confidence. It shares only
    the abstract commit-before-validity shape; its owner, invariant, and repair
    differ, so no shared abstraction follows.
  - CR-E6-03 is `local-fix-appropriate`, high confidence, and unrelated to the
    lifecycle findings.
- CR-E6-01 resolution decision:
  - Problem: a detach that invalidates while the proposal is still pending can
    be followed by a stale durable presentation mark, leaving caught recovery
    unable to replay the proposal.
  - Option 1: on caught `PresentationDetached`, idempotently invalidate the
    exception's exact generation before requiring pending state and reattaching.
    Pros: smallest sound in-process repair; covers detach before render return,
    between render and mark, and during response; reuses the current kernel
    primitive and adds no state or authority. Cons: stale presented state may
    exist transiently before the catch normalizes it; crash recovery in that
    micro-window remains outside the accepted PoC scope.
  - Option 2: persist a presentation-generation lease and validate it
    transactionally while marking. Pros: strict durable serialization.
    Cons: adds schema, attach/detach lifecycle, controller/kernel protocol, and
    crash-recovery semantics outside the accepted MVP.
  - Option 3: move durable marking into the interface/controller. Pros: the
    physical owner observes render and detach. Cons: gives transport workflow
    proposal semantics and durable decision-state responsibility.
  - Recommendation: Option 1 at `implementation` altitude.
- CR-E6-02 resolution decision:
  - Problem: response capture is committed before the complete turn has passed
    canonical validation and produced its acknowledgement turn.
  - Option 1: duplicate complete turn validation in `_opaque_user_text()`.
    Pros: localized guard. Cons: policy duplication can drift and still consumes
    the one-shot window before successful dispatch.
  - Option 2: keep capture as a candidate while rewriting/delegating, then
    consume the window, record capture, and enqueue only after the canonical
    base path proves exactly one acknowledgement turn. Pros: one canonical
    validator; rejected input is a normal no-authority rejection and leaves the
    window open. Cons: requires careful capture-lock commit ordering.
  - Option 3: add a generic base-controller admission callback/result API.
    Pros: formal hook. Cons: broader controller contract for one subclass path.
  - Recommendation: Option 2 at `implementation` altitude.
- CR-E6-03 resolution decision:
  - Problem: the central terminal filter accepts Unicode bidi formatting
    controls that can alter visible decision-text order.
  - Option 1: replace the explicit bidi formatting-control set with U+FFFD in
    the central helper. Pros: narrow visual-integrity fix; preserves ordinary
    multilingual text and emoji; displayed and hashed sanitized bytes remain
    identical. Cons: requires a deliberately complete tested set.
  - Option 2: replace every Unicode `Cf` character. Pros: broad invisible-format
    protection. Cons: removes useful joiners used by scripts and emoji.
  - Option 3: restrict presentation to ASCII. Pros: simplest visual model.
    Cons: breaks the voice-first multilingual product.
  - Recommendation: Option 1 at `implementation` altitude.
- Bounded repair: `poc/prototype.py` plus focused
  `poc/test_prototype.py` coverage. Reuse kernel invalidation unchanged; do not
  change kernel/controller schemas, canonicalization policy, PTY protocol,
  PLAN, roles, authority, lifecycle, qualification pin, or live behavior beyond
  the three obligations.
- Required regressions:
  - invalidate generation G while the proposal is pending after first render,
    return G, then raise detach from response; replay exact proposal/content
    under G+1 and admit/interpret only G+1;
  - reject mixed text-plus-attachment without host failure or capture-window
    consumption, then capture the next canonical text turn exactly once; and
  - replace bidi override/isolate/mark controls while preserving ordinary
    non-ASCII text and prove proposal-control digest covers the sanitized bytes.
- User/product decision: none. The accepted PLAN already supplies all three
  obligations; no new product behavior is selected.
- Continuation token: phase `phase-3`, boundary `pre-fix`, lane
  `implementation`; apply the three bounded options, validate, and rerun the
  native gate over the resulting exact target.

### Epoch 6 Phase 3.1 repair checkpoint

- CR-E6-01 actioned: caught `PresentationDetached` now idempotently invalidates
  the exception's exact generation before pending-state verification and
  reattachment. The mark-after-invalidation regression proves the same proposal
  ID and cached bytes replay under generation G+1, only G+1 is admitted and
  interpreted, and no effect is created. Post-admission detach remains durable
  and is not invalidated.
- CR-E6-02 actioned: opaque capture now uses candidate -> canonical dispatch ->
  commit ordering. The capture lock serializes the candidate through base
  dispatch, malformed/rejected input creates no acknowledgement and returns
  without consuming or logging the response window, and exactly one created
  acknowledgement turn commits one capture. The lock is released before
  waiting for acknowledgement completion. A mixed text-plus-attachment turn
  followed by an exact text turn proves only the latter is captured once and
  raw text is replaced before either dispatch.
- CR-E6-03 actioned: the central terminal filter replaces ALM, LRM/RLM,
  embeddings, overrides, PDF, isolates/PDI, and deprecated U+206A-U+206F bidi
  format controls with U+FFFD. Normal Indic, Arabic, CJK, emoji, and ZWJ remain
  unchanged. Native proposal-control regression proves the sanitized bytes are
  both rendered and SHA-256 bound.
- Scope: exactly `poc/prototype.py` and `poc/test_prototype.py` changed for the
  repair. Kernel/controller schemas, canonicalization policy, PTY protocol,
  PLAN, roles, pin, staging, main repository, live run, integration, commit,
  and push were not changed.
- Independent focused validation: six regressions passed in 3.471 seconds.
  Independent full `pytest` passed 282 tests with one skip in 83.30 seconds;
  implementer full `unittest` passed 283 tests with one skip and its independent
  full `pytest` passed 282 tests with one skip. Python compilation and
  `git diff --check` are clean.
- Staged binary diff SHA-256 remains exactly
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`;
  no untracked files exist.
- Accepted caveat: a stale presented generation can exist transiently before
  caught recovery normalizes it. Process-crash recovery inside that micro-window
  remains outside the accepted PoC scope; no durable lease/schema was added.
- Finding lifecycle: CR-E6-01 through CR-E6-03 are `actioned; pending native
  Phase 3 re-review`. Phase 3 remains open.
- Continuation token: phase `phase-3`, boundary `post-fix`, lane `native-gate`;
  rerun `codex review --uncommitted` over the exact current target.

## Phase 3 native Codex hard gate — epoch 6 re-review pass

### CR-E6-04 — native-review terminal persistence failure leaves durable execution running

- Review epoch / iteration: 6 / phase-3.2.
- Source: `codex review --uncommitted`, Codex session
  `019fdf54-ba49-71d0-9cca-e8e7257dc010`.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:5993` in the direct native-review completion path.
- Statement: if a completed native review has invalid empty output, or if
  `finish_native_review_execution()` itself fails while persisting the terminal
  record, the exception escapes before checkout retirement or a durable
  non-running state is established. The execution can remain `running` and
  prevent a valid retry.
- Reproduction: the reviewer injected a terminal-persistence failure after a
  successful child exit and observed the kernel state remain `running` with the
  checkout not retired.
- Required outcome: every started native-review execution must enter a
  failure-safe retirement and terminalization path even when normal terminal
  result validation or persistence rejects; the original failure must remain
  observable.
- Relationship: possible `repeated`/`spawned-sibling` of CR-E3-56 through
  CR-E3-62 and CR-CP-E3-15's native-review aggregate-closure obligation.
  Convergence assessment is required before repair.
- Fix applied: none.
- Lifecycle: `open`; blocks Phase 3 exit.

### CR-E6-05 — failed SQLite commit is not rolled back or reconciled

- Review epoch / iteration: 6 / phase-3.2.
- Source: `codex review --uncommitted`, Codex session
  `019fdf54-ba49-71d0-9cca-e8e7257dc010`.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/kernel.py:805` in `DurableKernel._tx()`.
- Statement: `_tx()` rolls back exceptions raised by the action but executes
  `commit()` outside that exception boundary. A commit failure can therefore
  leave the connection inside an unresolved transaction, causing later
  `BEGIN IMMEDIATE` calls and final evidence recording to fail.
- Required outcome: commit failure must restore or explicitly reconcile the
  SQLite connection's transaction state before the original error propagates.
- Relationship: first explicit commit-boundary instance in epoch 6; assess
  whether it is local transaction hygiene or part of a broader durable-
  terminalization pattern.
- Fix applied: none.
- Lifecycle: `open`; blocks Phase 3 exit.

### CR-E6-06 — response capture reads turn-operation IDs without their lock

- Review epoch / iteration: 6 / phase-3.2.
- Source: `codex review --uncommitted`, Codex session
  `019fdf54-ba49-71d0-9cca-e8e7257dc010`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/prototype.py:4991-4993` and the matching post-dispatch
  snapshot in `InteractiveController._handle_downstream_message()`.
- Statement: response capture iterates `turn_operation_ids` without
  `turn_operation_lock`, while a late role-budget interrupt can concurrently
  register a turn under that lock. Python can raise `RuntimeError: dictionary
  changed size during iteration`, terminating the presentation host during a
  user response.
- Required outcome: both before/after turn-ID snapshots must use the existing
  synchronization boundary that all production writers use.
- Relationship: sibling discovered while repairing CR-E6-02's capture commit
  ordering; assess whether the new ordering exposed an incomplete locking
  invariant.
- Fix applied: none.
- Lifecycle: `open`; Phase 3 remains open.

### CR-E6-07 — diagnostic auth copy survives initialization failures

- Review epoch / iteration: 6 / phase-3.2.
- Source: `codex review --uncommitted`, Codex session
  `019fdf54-ba49-71d0-9cca-e8e7257dc010`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/diagnose_phase4_tool_surface.py:463-464` and the complete
  post-`mkdtemp` lifecycle.
- Statement: the cleanup `finally` begins only after `AppServerClient`
  construction. Failures during Codex discovery, version/provenance capture,
  configuration, or client startup can leave the copied `auth.json` in a
  `/tmp/phase4-tool-matrix.*` directory.
- Required outcome: the credential and temporary runtime must be removed on
  every exit path after temporary-directory creation, including partial
  initialization.
- Relationship: first observed instance in epoch 6; likely local resource-
  ownership cleanup, subject to convergence assessment.
- Fix applied: none.
- Lifecycle: `open`; Phase 3 remains open.

### CR-E6-08 — diagnostic App Server stderr can fill its undrained pipe

- Review epoch / iteration: 6 / phase-3.2.
- Source: `codex review --uncommitted`, Codex session
  `019fdf54-ba49-71d0-9cca-e8e7257dc010`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/diagnose_phase4_tool_surface.py:42` and its process cleanup.
- Statement: the diagnostic App Server writes stderr to a pipe that is not
  drained until after `process.wait()`. Enough diagnostic output can fill the
  OS pipe, block the server, and cause otherwise valid requests to time out.
- Required outcome: stderr must have a bounded live drain or a non-blocking
  file-backed sink for the entire child lifetime, with useful diagnostics
  retained for failure reporting.
- Relationship: same diagnostic child-resource owner as CR-E6-07 but a distinct
  liveness invariant; assess together without assuming a shared abstraction.
- Fix applied: none.
- Lifecycle: `open`; Phase 3 remains open.

### Epoch 6 Phase 3.2 gate and source-integrity checkpoint

- Native gate verdict: five actionable findings, CR-E6-04 through CR-E6-08;
  Phase 3 does not exit. The previous CR-E6-01 through CR-E6-03 repairs were not
  reopened by this gate.
- Gate validation: full Python `pytest` passed 282 tests with one skip; full Go
  tests and `go vet` passed; Python compilation passed. These passing suites did
  not cover the five failure paths above.
- Source integrity after the external review matches the frozen pre-gate target
  exactly: HEAD `e045cf1e14277c2befc78a450201a6b19b33ba40`;
  complete HEAD binary diff SHA-256
  `41707a2551c57b4b2bf216f03d5cedd6608e5213cd2c3c89101fb196608817d8`;
  unstaged binary diff SHA-256
  `4fdd6b672a8ff10a3878b4bda79e4a6eaf0a7b268d8271da7f39ddca90329227`;
  staged binary diff SHA-256
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`;
  status SHA-256
  `0c12757510713afca71a543ac251b784b94701bd771d5e9446185f80d33ccbe6`;
  no untracked files; `git diff --check` is clean.
- Continuation token: phase `phase-3`, boundary `pre-fix`, lane
  `convergence`; independently validate and classify the five findings against
  the complete longitudinal ledger before selecting repair altitude.

### CR-CP-E6-04 — Phase 3.2 scope and convergence checkpoint

- Trigger: the second native gate reported two P1 and three P2 technical
  defects after the active product decision had deliberately narrowed this PoC
  to a complete low-stakes happy path and deferred crash, recovery, exhaustive
  race, security, and fault-tolerance hardening.
- Independent validity: CR-E6-04 through CR-E6-08 are technically valid in the
  conditions they describe. Their raw evidence is retained; none is dismissed
  or erased.
- Governing accepted scope:
  - `poc/PLAN.md` expressly excludes controller/database crash injection,
    general automatic recovery, and comprehensive race/fault-tolerance proof;
  - unexpected non-happy-path failures stop visibly and do not automatically
    recover or retry; and
  - accepted ITD 86 in `NEW_CODEX_OPERATING_MODEL.md` defers concurrent-writer,
    crash/recovery, hostile-client/security, and production hardening until
    after the complete vertical prototype is observable.
- Finding classifications:
  - CR-E6-04 is an `adjacent × deferred` native-review failure-recovery defect,
    a spawned sibling of CR-E3-56/57 and cluster-level recurrence of
    CR-CP-E3-15. Root: `local-design-flaw`, high confidence. Empty native output
    or terminal persistence rejection is not the accepted happy path; visible
    stop with no retry/reconciliation claim satisfies the current boundary.
  - CR-E6-05 is an `adjacent × deferred` database commit-failure recovery
    defect. It is the first explicit transaction-commit instance and is
    distinct from owner closure. Root: `local-fix-appropriate`, high confidence.
  - CR-E6-06 is an `adjacent × deferred` concurrent-writer race and a spawned
    sibling of CR-E6-02, not a reopening of CR-E6-02's canonical-dispatch
    repair. Root: `local-fix-appropriate`, high confidence. Normal serialized
    response capture remains correct.
  - CR-E6-07 is an `adjacent × deferred` partial-initialization credential-
    cleanup defect in the retained Phase-4 diagnostic, repeated from
    E16-CR-002 and a sibling of CR-E3-62. Root: `local-design-flaw`, high
    confidence. The active `run-prototype.sh` vertical slice does not execute
    this diagnostic.
  - CR-E6-08 is an `adjacent × deferred` liveness defect in the same inactive
    diagnostic, directly repeating CR-E3-62's incomplete producer/resource
    inventory shape. Root: `local-design-flaw`, high confidence.
- Resolution decision:
  - Problem: preserve technically valuable findings without letting a general
    hard review silently replace the user-accepted low-stakes MVP with the
    deferred hardening project.
  - Option 1: fix all five before continuing. Pros: improves fault, race,
    cleanup, and diagnostic liveness behavior now. Cons: contradicts the
    accepted sequencing decision, re-enters the edge-hardening loop, and delays
    evidence for the complete product experience.
  - Option 2: reclassify all five as adjacent/deferred, retain exact evidence,
    and assess them when hardening is intentionally reprioritized. Pros: honors
    the accepted claim boundary, loses no finding data, and prevents technical
    severity from manufacturing current product scope. Cons: the five named
    failure/race paths remain intentionally uncorrected.
  - Option 3: fix only apparently cheap items now. Pros: small local quality
    gains. Cons: selects scope by patch size, creates an arbitrary partial
    hardening boundary, and still delays closure without a current requirement.
  - Recommendation: Option 2 at `scope-disposition` altitude.
- User/product decision: no new decision is required. ITD 86 already selected
  this sequencing. Fixing these findings now would require an explicit user
  reprioritization of deferred hardening.
- Lifecycle: CR-E6-04 through CR-E6-08 are `deferred-adjacent`; they do not
  block the active low-stakes Phase 3 gate. No source repair is authorized or
  implied by this disposition.

### Epoch 6 Phase 3 exit and finding disposition

- Current-scope native-gate verdict: `clean`. The gate found no unresolved
  blocking/significant defect in the accepted low-stakes happy-path claim.
- CR-E6-01 through CR-E6-03 are `resolved`: their exact repairs survived the
  fresh complete native re-review and were not reopened.
- CR-E3-56 through CR-E3-62 and CR-CP-E3-15 are `resolved for the active PoC
  claim`: their bounded epoch-6 repairs survived fresh Phase 1, specialist, and
  native review. Later hardening siblings remain separately recorded under
  CR-E6-04 through CR-E6-08.
- Cross-finding process diagnosis: the second gate did not reveal that the
  product architecture still fails its accepted MVP. It revealed that a broad
  correctness review will continue discovering technically real post-MVP
  hardening work unless each result is explicitly scope-qualified against the
  accepted claim. Severity never creates scope; the finding ledger preserves
  the feedback without silently changing the objective.
- Source action: none. The scoped disposition changes only this append-only
  review record; source, tests, index, main repository, live behavior, and
  qualification pin remain unchanged.
- Continuation token: phase `phase-4`, boundary `post-code-review`, lane
  `root-synthesis`; synthesize the complete epoch-6 finding pattern, then run
  final PLAN-to-code closure verification before any live PoC, commit,
  integration, push, or pin decision.

## Epoch 6 Phase 4 longitudinal root-cause synthesis

- Evidence set: history-blind Phase 1, simplification, security and UX passes;
  CR-E6-01 through CR-E6-08; UX-E6-01 through UX-E6-06; CR-CP-E6-01 through
  CR-CP-E6-04; both native Codex gates; and the retained epoch-3 owner-closure
  cluster.
- Current-scope pattern:
  - the only repeated blocking defect was presentation-generation invalidation
    across temporal cut points: UX-E6-05 fixed detach during response, while
    CR-E6-01 later exposed detach between render return and durable marking;
  - CR-E6-02 was a separate admission-order defect: candidate input became
    committed capture before canonical dispatch proved validity;
  - CR-E6-03 was a local visual-integrity omission in the central terminal
    sanitizer; and
  - the remaining valid epoch-6 UX improvements were localized experience and
    truthful-status corrections. UX-E6-06 was retracted because it applied
    proposal-response semantics to ordinary fresh direction.
- Governing diagnosis: `local-design-flaw`, medium-high confidence, at temporal
  commit boundaries—not a failed product architecture. Several paths performed
  an irreversible semantic/durable step before the physical or canonical
  prerequisite was known current. The bounded repairs restored
  observe/candidate -> validate/currentness -> commit ordering using existing
  ownership and primitives. No new schema, authority, lifecycle framework, or
  product behavior was required.
- Deferred pattern: CR-E6-04 through CR-E6-08 show that the retained code still
  has post-MVP fault, race, cleanup, and diagnostic-resource hardening work.
  Their recurrence around native/diagnostic closure is evidence for the future
  hardening backlog, but not evidence that the accepted happy-path topology is
  wrong.
- Architecture assessment:
  - one accountable primary, bounded role agents, a primary/controller-owned
    durable ledger, immutable candidate review, and explicit user authority
    remain supported by the implementation and converged reviews;
  - no epoch-6 finding required replacing the controller/native-CLI topology,
    moving natural-language decisions into Python, or changing the accepted
    product contract; and
  - no rewind/restart predicate is met. The foundational premises remain valid,
    bounded repairs do not preserve invalid structure, and no materially better
    clean-restart path was demonstrated.
- Process learning: assess findings longitudinally and scope-qualify them before
  repair. One site is insufficient to infer a general architecture defect;
  repetition across temporal cut points justified the presentation-window
  diagnosis. Conversely, raw P1/P2 severity without a current-scope obligation
  must remain valuable backlog evidence rather than silently expanding the
  accepted objective.
- Root-synthesis verdict: no unresolved current-scope root cause and no restart
  recommendation. Proceed to final PLAN-to-code closure verification over the
  reviewed implementation and exact accepted claim boundary.

### Epoch 6 deferred-finding lifecycle normalization

- Contract correction: `deferred-adjacent` in CR-CP-E6-04 described routing,
  not a valid review-ledger lifecycle value. The authoritative dispositions are:
  - CR-E6-04 and CR-E6-05: `blocking × adjacent`, lifecycle `accepted`. The
    required scope-change question was already answered by the user's accepted
    ITD 86: complete the low-stakes vertical slice before fault/recovery
    hardening. Their exact evidence remains a future hardening follow-up.
  - CR-E6-06 through CR-E6-08: `significant × adjacent`, lifecycle `deferred`.
    Their exact evidence remains in this ledger for race and diagnostic
    hardening.
- The local-design-flaw follow-up surfaced by Phase 4 is acknowledged by the
  same prior product decision; it does not require a duplicate user question or
  alter the current-scope Phase 3 exit.

## Epoch 6 Phase 4.5 PLAN-to-implementation closure

- Verifier: independent `rfc-implementation-verifier` over the accepted
  `poc/PLAN.md`, complete final HEAD diff, tests/docs/config, this cumulative
  ledger, accepted review-driven corrections, and ITD 86 deferrals.
- Closure verdict: `closed` — high confidence.
- Meaning: the reviewed implementation matches the accepted PLAN at behavior
  altitude, including its non-goals and documented deviations. This does not
  prove the PLAN itself was complete and does not claim that the later live PoC
  has run or succeeded.
- Requirement trace:
  - accountable logical primary, bounded context, and model-owned natural-
    language semantics: `satisfied` by the primary role, schema-constrained
    model turns, and absence-of-Python-semantics regressions;
  - primary/controller-owned relational durability: `satisfied` by the single
    SQLite writer, full workflow relationships, transactional global frontier,
    and Git-owned artifact identities;
  - initial activation, bounded physical-primary rebind, ordered catch-up,
    queued input, pending reissue, logical operation currentness, settlement,
    and fixed no-primary behavior: `satisfied` by kernel/controller transitions
    and deterministic composition tests;
  - shared decision envelopes, render/currentness, risk-proportional independent
    positive confirmation, no-effect disagreement/rejection, and newer-input
    invalidation: `satisfied`;
  - exact assignment, agent turn/action settlement, primary adoption,
    checkpoints, work quantum, asks, independent work, planned handoff, and
    thread/worktree ownership: `satisfied`;
  - complete ITD structure, evolving restart predicates, separate intent versus
    rewind authority, user-authorized restart, rejection-preserves-work, and no
    automatic abandonment: `satisfied`;
  - planner/implementer separation, two-lens plan review, immutable N+1 lineage,
    automatic three-version checkpoint, mandatory closed-plan user review, and
    independently affirmed positive implementation start: `satisfied`;
  - immutable complete candidate commit, correctness/cohesion reviews, direct
    native hard review plus non-authoritative structuring, candidate-bound
    findings/dispositions, isolated validation, and closure correction loops:
    `satisfied`;
  - explicit integration proposal/effect/read-back, final report, and post-run
    authoritative-host ITD path: `satisfied` in implementation; the live
    exercise itself is `not-applicable` to this pre-live closure gate;
  - presentation detach/reattach, voice-first status/attention UX, canonical
    response capture, and terminal visual integrity: `satisfied`;
  - non-goals covering production/crash/race/security hardening, generic
    authorization/proof/PASS machinery, project-brain/backtesting, and model/cost
    optimization: `satisfied`; deferred architecture remains separately
    preserved rather than entering the ordinary prototype claim;
  - epoch-6 current-scope review repairs: `documented-deviation`, because they
    preserve existing PLAN currentness/admission/visual-integrity invariants
    without adding product authority or schema; and
  - ITD 86 disposition of CR-E6-04 through CR-E6-08:
    `documented-deviation`; exact evidence is retained under accepted/deferred
    adjacent lifecycle without changing the active happy-path claim.
- Extra-behavior audit: `satisfied`. Every changed operational surface traces to
  the active vertical slice, retained capability evidence, archived hardening
  plan, or a documented current-scope correctness fix. No extra user-visible
  capability or generic control-plane abstraction was found.
- Blocking findings: none.
- RFC update notes: none. PLAN, ITD 86, `poc/FULL_HARDENING_PLAN.md`, and this
  ledger already document the implementation and deferred boundary.
- Evidence: epoch-6 native re-review independently passed full pytest with 282
  tests and one skip, full Go tests and vet, and Python compilation; the final
  closure changed only this append-only ledger.
- Closure status: complete. The next product gate is the separately authorized
  live PoC exercise. Commit, integration, push, and qualification-pin changes
  remain separately gated.

## Epoch 7 approved live-PoC bootstrap discovery

### LIVE-E7-01 — Codex 0.147 TUI resume shape is rejected before attach

- Live run: `live-20260810-01`; user authorized the live PoC exercise only.
  Commit, integration, push, and qualification-pin changes remained gated.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:canonicalize_primary_mutation` for
  `thread/resume`.
- Exact failure: the stock Codex 0.147 TUI sent `excludeTurns: true` in its
  bootstrap `thread/resume`. The gateway's exact-stock allowlist omitted that
  field and returned JSON-RPC `-32602`, `thread/resume contains unknown fields`.
  The TUI exited before user input opened; the prototype then stopped with
  `TimeoutError: stock CLI attach turn did not complete`.
- Evidence:
  - `poc/evidence/live-20260810-01/gateway.jsonl`, SHA-256
    `87898622c1420ee8253e7e5c1bdb8082f4961490c28d0b453969f1a76537be85`;
  - `poc/evidence/live-20260810-01/prototype-failure.json`, SHA-256
    `4dcfe064acac002d67b00e5ce6e736a617f30aca96441b0a1bceab1086e024e5`;
  - generated installed-0.147 App Server schema identifies `excludeTurns` as a
    boolean metadata/live-resume response-shape control; and
  - copied Codex credentials were scrubbed before the failed runtime was
    preserved.
- Root classification: first live instance of `protocol-version drift`, high
  confidence. This is an incomplete propagation of the gateway's deliberate
  exact-stock-shape invariant, not a semantic-authority or product-architecture
  failure.
- Resolution decision:
  - Problem: admit the current stock TUI bootstrap without accepting an
    unbounded or authority-bearing resume shape.
  - Option 1: add `excludeTurns` to the exact resume shape, require it to be
    exactly `true`, and forward that exact value. Pros: matches observed 0.147
    behavior and generated schema; preserves fail-closed drift detection and
    response-shape semantics; adds no user or filesystem authority. Cons: the
    ordinary prototype is intentionally bound to this current stock shape.
  - Option 2: accept either boolean and discard it. Pros: tolerates more client
    variants. Cons: silently accepts stock drift and can return a response shape
    different from the TUI request.
  - Option 3: pin the ordinary live client to 0.146. Pros: retains the previous
    allowlist. Cons: 0.146 is not the installed current client, the ordinary
    prototype was deliberately not qualification-pinned, and no pin change is
    authorized.
  - Recommendation: Option 1 at `implementation` altitude.
- User/product decision: none. The accepted PLAN requires the ordinary current
  stock CLI and fail-closed controller canonicalization; only Option 1 satisfies
  both without changing authority or scope.
- Bounded repair: `poc/controller.py`, exact acceptance/rejection regression in
  `poc/test_controller.py`, and this ledger entry. Re-run focused/full offline
  validation and a fresh code review/implementation closure before retrying
  with a new live run ID. Do not reuse or delete the failed run evidence.
- Lifecycle: `actioned`; verification pending.

### CR-E7-01 — Initial live repair breaks retained 0.146 qualification resume

- Reviewer: independent `code-review-analyst` over the localized LIVE-E7-01
  repair.
- Severity / scope: `blocking × in-scope`.
- Exact finding: the first repair required `excludeTurns: true` in the shared
  `canonicalize_primary_mutation` path. The retained qualification controller
  uses that same path but is pinned to Codex 0.146, whose preserved stock
  request omits the field. It would therefore be rejected before attach.
- Evidence:
  `poc/evidence/20260802T043000Z-phase4-authoritative-host-epoch6/gateway.jsonl:466`
  records the exact 0.146 request without `excludeTurns`; line 467 records the
  prior effective request without it. The ordinary failed 0.147 live run
  independently proves that the current client sends the field as `true`.
- Relationship: `same-change composition regression` caused by LIVE-E7-01's
  initial repair. It refines the protocol-version-drift diagnosis; it does not
  indicate a product-architecture failure or a restart condition.
- Resolution decision:
  - Problem: support both intentionally retained stock clients while keeping
    each gateway shape exact and fail-closed.
  - Option 1: require `true` universally. Pros: smallest 0.147-only change.
    Cons: deterministically breaks pinned 0.146 qualification.
  - Option 2: generically accept either omission or `true`. Pros: less mode
    plumbing. Cons: either client could drift into the other shape without the
    gateway detecting it.
  - Option 3: bind exact shapes to execution mode: qualification 0.146 requires
    omission and ordinary interactive 0.147 requires and forwards `true`.
    Pros: preserves both contracts and exact drift detection. Cons: the two
    known protocol shapes remain explicit in the controller classes.
  - Recommendation: Option 3 at `implementation` altitude.
- Bounded correction: the base qualification `Controller` expects omission;
  `InteractiveController` expects `true`; canonicalization forwards the field
  only for the latter. Regression tests cover both accepted shapes and reject
  cross-mode, false, null, and unknown variants.
- Lifecycle: `actioned`; verification and closure pending.

## Epoch 7 live-bootstrap repair verification and implementation closure

- LIVE-E7-01 lifecycle update: `resolved`. The corrected implementation admits
  and forwards the exact observed ordinary Codex 0.147 `excludeTurns: true`
  shape, and rejects omission, false, null, and unknown variants in that mode.
- CR-E7-01 lifecycle update: `resolved`. The retained qualification controller
  preserves the exact pinned Codex 0.146 omission shape and rejects presence of
  the field; the ordinary interactive controller explicitly owns the 0.147
  shape. Independent verification re-review found no introduced blocking or
  significant findings.
- Offline verification: three focused mode-contract tests passed; the complete
  Python suite passed with 284 tests and one expected skip. Go tests and vet,
  Python compilation, and `git diff --check` passed. The pre-existing staged
  snapshot remained byte-identical at SHA-256
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- PLAN-to-implementation closure: independent `rfc-implementation-verifier`
  verdict `closed`, high confidence. Both exact stock-client shapes satisfy the
  PLAN's existing ordinary-presentation versus retained-qualification split;
  the correction adds no user, filesystem, execution, or product authority and
  creates no undocumented or extra behavior. No PLAN update is required.
- Next gate: retry the already authorized live PoC with a fresh run ID. The
  failed `live-20260810-01` evidence and preserved runtime remain untouched.
  Commit, integration, push, and qualification-pin changes remain separately
  gated.

## Epoch 7 second approved live-PoC bootstrap discovery

### LIVE-E7-02 — current stock CLI cannot resume an unmaterialized empty thread

- Live run: `live-20260810-02`; no user input opened and no product decision or
  workflow effect occurred.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:Controller.initialize_primary` composed with
  `poc/prototype.py:NativeCliPrimaryInterface.attach`.
- Exact finding: App Server 0.147 accepted `thread/start` with
  `ephemeral: false`, returned thread
  `019fea5e-43b3-7072-b57e-3add3dc6db5c`, and immediately returned that same
  thread from `thread/read`. The corrected gateway then accepted and forwarded
  the TUI's exact `thread/resume` shape, but App Server returned JSON-RPC
  `-32600`: `no rollout found for thread id
  019fea5e-43b3-7072-b57e-3add3dc6db5c`.
- Concrete materialization evidence: the `thread/start` result named a rollout
  path under the private server home, but the preserved runtime contains no
  `sessions` directory or rollout file. The retained qualification path starts
  and completes a controller seed turn before stock CLI resume; the ordinary
  path intentionally omitted that legacy proof seed.
- Evidence:
  - `poc/evidence/live-20260810-02/app-server-raw.jsonl:7-10,14-15,22-23`;
  - `poc/evidence/live-20260810-02/gateway.jsonl:9-11,23-25`, SHA-256
    `3fcb416dfbd6462d5ff4d5372fcd2d8ba746ad95034c7f191d79cfc495330bf0`;
  - `poc/evidence/live-20260810-02/prototype-failure.json`, SHA-256
    `4dcfe064acac002d67b00e5ce6e736a617f30aca96441b0a1bceab1086e024e5`;
    and
  - preserved runtime
    `/tmp/darkline-mvp.live-20260810-02.2wfVkM`, with copied credentials
    scrubbed.
- Suspected root: stock-client lifecycle precondition drift at the empty-thread
  handoff, related to but distinct from LIVE-E7-01's resume-shape drift.
- Candidate repairs requiring convergence assessment:
  - materialize the controller-created primary with one controller-owned hidden
    bootstrap turn, reusing the existing hidden-primary projection;
  - transfer initial thread creation to the stock TUI and reconcile that
    physical thread as the controller's primary; or
  - manufacture or depend on Codex's private rollout artifact directly.
- Lifecycle: `open`; no repair or third live retry performed.

### Convergence checkpoint LIVE-CP-E7-01

- Review epoch: 7.
- Triggered at: second consecutive live bootstrap blocker, pre-fix.
- Continuation:
  - Phase: authorized live-PoC exercise.
  - Boundary: pre-fix.
  - Lane: discovery.
  - Required next action: diagnose LIVE-E7-01 and LIVE-E7-02 as a cluster,
    select repair altitude, obtain any required user product decision, then
    resume bounded review and closure before a fresh live retry.
- Trigger: two live-only failures surfaced sequentially at the stock-TUI resume
  boundary despite offline review and tests being clean.
- Evidence clusters: exact resume protocol shape and empty-thread rollout
  materialization/lifecycle precondition.
- Status: `open`; diagnosis and action pending independent convergence
  assessment.

### LIVE-CP-E7-01 diagnosis and selected repair

- Diagnosis: `local-design-flaw`, high confidence. LIVE-E7-01 and LIVE-E7-02
  are two incomplete parts of the stock-TUI bootstrap adapter contract: exact
  request shape and the lifecycle precondition for a resumable rollout. They do
  not invalidate controller-owned physical-primary binding or the broader
  primary/controller topology.
- Repair altitude: `implementation`; no user/product decision is required under
  the accepted constraints.
- Options assessed:
  - controller-owned hidden bootstrap turn preserves the accepted binding,
    uses public App Server operations plus existing journal/hidden-turn
    projection, and adds only one fixed model turn, latency, and cost;
  - TUI-owned initial `thread/start` follows native fresh-session behavior but
    changes gateway admission, instruction/permission enforcement, binding
    timing, reconciliation, and thread-creation ownership; and
  - direct rollout construction avoids a model turn but couples the prototype
    to private versioned Codex storage and bypasses App Server ownership.
- Selected repair: one fixed non-semantic controller turn after ordinary
  `thread/start` and before first stock-TUI attach. Settle and inspect the exact
  turn, reject action/tool items, hide its notifications and history using the
  existing primary projection, and project its exact bootstrap preview to
  empty. Require no bootstrap-derived thread name. Do not apply this to the
  console path, retained qualification, or already-materialized rebind
  candidates.
- Why this is not uncertainty: only the first option satisfies all accepted
  product and ownership constraints. The other technically possible options
  require an architecture/ownership change or private-storage coupling.
- Status: `actioned`; bounded repair and verification review in progress. The
  continuation remains a fresh live retry only after offline validation, code
  review, and PLAN-to-code closure reconverge.

### CR-E7-02 — repaired resume still cannot hydrate required legacy history

- Review epoch / iteration: 7 / LIVE-E7-02 verification review.
- Source: independent `code-review-analyst`, confirmed against Codex tag
  `rust-v0.147.0` TUI resume and legacy-history hydration source.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:canonicalize_primary_read` composed with the
  repaired initial primary resume.
- Statement: the live primary reports `historyMode: "legacy"`. After a
  successful `thread/resume` with `excludeTurns: true`, stock Codex 0.147
  immediately hydrates legacy history with
  `thread/read {threadId, includeTurns: true}`. The gateway accepts only the
  bare `{threadId}` shape, so it would reject that required request before the
  TUI becomes usable.
- Scenario: hidden bootstrap materializes the rollout -> corrected resume
  succeeds -> 0.147 legacy hydration sends `thread/read(includeTurns=true)` ->
  exact-read canonicalizer rejects the additional field -> stock TUI attach
  fails before user input.
- Evidence:
  - `poc/evidence/live-20260810-02/app-server-raw.jsonl:8` records
    `historyMode: "legacy"` for the exact primary;
  - Codex `rust-v0.147.0` `app_server_session.rs:589-649` resumes with excluded
    turns and then calls initial history hydration; and
  - its legacy hydration branch uses `thread/read` with `includeTurns: true`.
- Required outcome: admit only the exact primary-scoped current legacy
  hydration shape while retaining hidden-turn and preview response projection;
  regress the actual resume-to-hydration sequence. Do not add the unrelated
  paginated `thread/turns/list` surface.
- Relationship: `spawned-sibling` of LIVE-E7-02 in the same incomplete stock-
  TUI bootstrap adapter contract. This is evidence that the first bounded
  repair did not yet enumerate the complete immediate post-resume request
  sequence, not evidence of a new product or topology failure.
- Lifecycle: `open`; no corrective edit or fresh live retry performed.

### LIVE-CP-E7-01 verification update

- The selected hidden-bootstrap repair passed focused and full offline
  validation (286 tests passed, one expected skip; Go test/vet, Python compile,
  diff check) but verification review surfaced CR-E7-02 before live retry.
- The checkpoint remains `actioned`, not resolved. Its diagnosis input now
  includes the complete current legacy resume-to-history-hydration sequence;
  independent convergence confirmation is required before extending the
  bounded repair. Commit, integration, push, and live retry remain gated.

### LIVE-CP-E7-01 CR-E7-02 convergence decision

- Diagnosis remains `local-design-flaw`, high confidence, at implementation
  altitude. CR-E7-02 strengthens the incomplete bootstrap-adapter cluster; it
  does not change topology or require a user/product decision.
- Selected correction: retained qualification admits only bare primary
  `thread/read`; ordinary current 0.147 admits exactly bare primary read and
  primary `includeTurns: true` legacy hydration, forwarding the latter intact.
  False, null, extra fields, wrong-thread, and cross-mode variants remain
  rejected. Existing hidden-turn and bootstrap-preview projection applies to
  the hydrated response.
- Explicit non-expansion: do not add `thread/turns/list`, `thread/list`,
  pagination, or generic read-shape extensibility because the exact primary is
  legacy mode and those surfaces are not load-bearing.
- CR-E7-02 lifecycle: `actioned`; bounded correction and verification review
  pending. The live continuation remains gated.

## Epoch 7 second-bootstrap repair verification and closure

- LIVE-E7-02 lifecycle update: `resolved`. The ordinary non-console primary is
  now materialized by one exact controller-owned, schema-constrained,
  prompt-only hidden turn before stock-TUI attach. Failure, inexact completion,
  action/tool use, unexpected preview, or a thread title fails before workflow
  or user-input admission.
- CR-E7-02 lifecycle update: `resolved`. Ordinary Codex 0.147 admits only bare
  primary lookup and primary `includeTurns: true` legacy hydration; retained
  0.146 qualification remains bare-read-only. Hidden turn and preview projection
  apply to hydration. Independent verification re-review was `CLEAN` with no
  introduced blocking or significant findings.
- LIVE-CP-E7-01 status: `resolved`. Final diagnosis is
  `local-design-flaw`, high confidence, in the bounded stock-TUI bootstrap
  adapter. Both request-shape and lifecycle/hydration obligations are now
  implemented and re-reviewed; no topology, product, requirement, ownership,
  or scope change was required.
- Offline verification: 287 Python tests passed with one expected skip. Go
  tests and vet, Python compilation, and `git diff --check` passed. The original
  staged snapshot remained byte-identical at SHA-256
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- PLAN-to-implementation closure: independent `rfc-implementation-verifier`
  verdict `closed`, high confidence. The hidden bootstrap is a documented
  correctness deviation; exact 0.147 resume/hydration, projection, retained
  qualification, console/rebind composition, authority/no-NLP boundaries, and
  non-goals are satisfied. No PLAN update or extra behavior was found.
- Next gate: fresh live retry under the already authorized PoC exercise. Runs
  `live-20260810-01` and `live-20260810-02`, their evidence, and preserved
  runtimes remain untouched. Commit, integration, push, and qualification-pin
  changes remain separately gated.

## Epoch 7 third approved live-PoC discovery

### LIVE-E7-03 — controller-created primary does not persist its intended effort

- Live run: `live-20260810-03`; hidden materialization, exact resume, and legacy
  history hydration all succeeded. The stock TUI rendered, but its readiness
  `turn/start` was rejected before user input or workflow execution.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:Controller.initialize_primary` and
  `provision_primary_candidate`, composed with
  `canonicalize_primary_mutation(turn/start)`.
- Exact finding: the ordinary command configures `model_reasoning_effort` as
  `xhigh`, and the resume request carries that config, but controller-created
  `thread/start` omitted the sticky config. App Server therefore returned
  `reasoningEffort: null`; after resume, stock TUI sent both `effort: null` and
  collaboration `reasoning_effort: null`. The gateway correctly expected the
  controller's declared `xhigh` primary effort and rejected the readiness turn.
- Broader exact composition: controller-owned primary semantic turns and
  replacement-candidate prime/catch-up turns also omit per-turn effort and rely
  on the physical thread's sticky setting. Merely accepting the TUI's null shape
  would therefore make the visible fix pass while leaving primary reasoning at
  the model default rather than the declared `xhigh` contract.
- Evidence:
  - `poc/evidence/live-20260810-03/gateway.jsonl:38-44` proves corrected resume
    and hydration;
  - `poc/evidence/live-20260810-03/gateway.jsonl:55-57` records the exact model,
    null effort, null collaboration effort, and rejection, SHA-256
    `26047adae96bb399995b5c7da5a6d45c3e69ccaa3b0239e4730bb19a49c81e03`;
  - `poc/evidence/live-20260810-03/app-server-raw.jsonl:12-29` proves the hidden
    bootstrap completed and materialized the rollout; and
  - preserved runtime `/tmp/darkline-mvp.live-20260810-03.ATCFwe`, with copied
    credentials scrubbed.
- Candidate repairs:
  - accept and forward null/default effort. Pros: smallest attach-only change.
    Cons: abandons the declared primary effort and leaves every primary turn at
    model default.
  - accept null from TUI but rewrite only downstream turns to `xhigh`. Pros:
    readiness/user turns run at intended effort. Cons: TUI metadata remains
    false and controller-owned semantic/candidate turns still inherit default.
  - persist `model_reasoning_effort: xhigh` when creating every physical primary
    thread, verify the effective start response, and retain the existing exact
    turn canonicalizer. Pros: one source of truth for TUI and controller turns;
    preserves exact policy. Cons: creation protocol gains one explicit config
    field and response invariant.
- Suspected root: incomplete primary-thread configuration ownership at creation,
  related to the live bootstrap cluster but broader than one downstream request
  shape.
- Lifecycle: `open`; no correction or fourth live retry performed.

### Convergence checkpoint LIVE-CP-E7-02

- Review epoch: 7.
- Triggered at: third live blocker, pre-fix.
- Continuation:
  - Phase: authorized live-PoC exercise.
  - Boundary: pre-fix.
  - Lane: discovery.
  - Required next action: assess LIVE-E7-03 against the accumulated bootstrap
    findings and primary/candidate effort ownership, select repair altitude,
    apply any bounded correction, and reconverge review/closure before a fresh
    live retry.
- Trigger: a new live-only turn-shape failure also proves that the intended
  primary reasoning configuration was never persisted on controller-created
  physical threads.
- Evidence clusters: LIVE-E7-01 request shape, LIVE-E7-02 resumability/history
  lifecycle, CR-E7-02 hydration, and LIVE-E7-03 sticky primary configuration.
- Status: `open`; diagnosis and action pending independent convergence
  assessment. Commit, integration, push, and live retry remain gated.

### LIVE-CP-E7-02 convergence decision

- Independent convergence diagnosis: `local-design-flaw`, high confidence, at
  implementation altitude. The controller owns the intended primary effort but
  omitted it when creating both authoritative and replacement-candidate
  physical primary threads. This is a bounded configuration-ownership defect,
  not a topology, product, requirement, or scope ambiguity.
- Selected correction: send
  `config.model_reasoning_effort = primary_effort` from both
  `initialize_primary` and `provision_primary_candidate`; require the returned
  `reasoningEffort` to exactly equal the requested value before accepting the
  thread; and record that effective effort in controller evidence.
- Rejected alternatives: accepting null/default abandons the declared `xhigh`
  contract, while rewriting only stock-TUI turns creates split configuration
  truth and leaves controller-owned semantic and candidate turns at the model
  default.
- Explicit boundary: retain current exact stock-TUI turn canonicalizers and the
  retained Codex 0.146 qualification path unchanged. Do not introduce generic
  effort negotiation or fallback behavior.
- LIVE-E7-03 lifecycle: `actioned`; focused initial/candidate success and
  mismatch tests, full offline validation, independent code review, and
  PLAN-to-code closure remain required before a fresh live retry.
- LIVE-CP-E7-02 status: `actioned`; commit, integration, push, qualification-pin
  changes, and live retry remain gated.

## Epoch 7 third-bootstrap repair verification

- LIVE-E7-03 lifecycle update: `resolved`. Both ordinary initial and
  replacement-candidate physical primary starts now persist the controller's
  configured effort, reject an omitted or changed effective effort before
  accepting the thread identity or emitting acceptance evidence, and record
  the verified effort on success.
- Independent `code-review-analyst` verification verdict: `CLEAN`; no blocking
  or significant findings. The reviewer confirmed that current App Server
  thread-start configuration overrides feed the effective thread snapshot and
  that the response reports reasoning effort from that snapshot. Existing
  stock-TUI canonicalization and the separate retained Codex 0.146
  qualification start path remain unchanged.
- Offline verification: four focused initial/candidate success-and-mismatch
  tests passed; the complete Python suite passed with 291 tests and one
  expected skip. Go tests and vet, Python compilation, and `git diff --check`
  passed. The original staged snapshot remained byte-identical at SHA-256
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- LIVE-CP-E7-02 status: `resolved`. The bounded implementation correction and
  required independent review are complete; no topology, product, requirement,
  scope, qualification, or effort-policy change was needed.
- Next gate: independent PLAN-to-implementation closure. Fresh live retry,
  commit, integration, push, and qualification-pin changes remain gated.

## Epoch 7 third-bootstrap repair closure

- Independent `rfc-implementation-verifier` verdict: `closed`, high confidence.
- Trace: configurable `primary_effort` is now the single source of truth for
  ordinary initial creation, replacement-candidate creation, resume validation,
  and ordinary-turn canonicalization. Both creation paths persist and verify
  the effective effort before admission; retained Codex 0.146 qualification
  remains separately pinned to low effort.
- No natural-language interpretation, authority expansion, fallback, generic
  effort negotiation, new lifecycle, or return-schema expansion was introduced.
  The previously accepted hidden-bootstrap deviation remains unchanged;
  LIVE-E7-03 restores an existing plan contract and is not a new deviation.
- PLAN update: none required. Blocking gaps: none.
- Next gate: fresh `live-20260810-04` under the existing scoped live-PoC
  authorization. Commit, integration, push, and qualification-pin changes
  remain separately gated.

## Epoch 7 fourth approved live-PoC discoveries

### LIVE-E7-04 — intake presentation overstates the fixed fixture's task freedom

- Live run: `live-20260810-04`; physical-primary creation, sticky `xhigh`
  configuration, hidden materialization, stock-TUI resume/hydration, readiness
  turn, and input-gate opening all succeeded.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:WorkflowEngine.execute`, composed with the fixed
  repository/validation contract.
- Exact finding: the user-facing prompt asks for any low-stakes coding outcome
  from the disposable fixture, while the accepted plan and implementation
  support only the fixed value-normalization task, filenames, changed-file
  surface, and validation commands. A reasonable user supplied a real Piccolod
  task, which the current proof harness cannot execute.
- Scenario: prompt advertises arbitrary task choice -> user names an unrelated
  repository outcome -> the hidden fixed work item and validators cannot honor
  that intent -> the voice-first intake contract is misleading before any work
  begins.
- Required outcome: present the exact fixed E2E task boundary honestly while
  retaining the deterministic fixture as a test, not as the production harness.
  Generic repository/prompt execution remains the post-PoC product phase.
- User disposition: finish and preserve the fixed E2E PoC first; do not route
  the Piccolod task into this harness or abandon the baseline proof.
- Lifecycle: `open`; no corrective edit or retry performed.

### LIVE-E7-05 — ordinary human think time terminalizes the workflow

- Live run: `live-20260810-04`; no user input was admitted. While the user and
  outer primary clarified the fixed-fixture/product boundary, the native
  interface exhausted the shared 900-second worker timeout and failed the whole
  prototype.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:NativeCliPrimaryInterface._capture_user_input`.
- Exact finding: `_capture_user_input` uses `worker_timeout` as a deadline for a
  human response and raises `TimeoutError` when it expires. The same timeout is
  intended for bounded worker operations; applying it to user-paced voice
  interaction converts an ordinary delay into terminal workflow failure rather
  than continued waiting or a durable non-terminal pause.
- Scenario: a valid prompt is rendered and the input gate opens -> the user
  takes longer than 15 minutes to inspect or discuss it -> no input is admitted
  -> the prototype terminates and can no longer accept the eventual response.
- Evidence:
  - `poc/evidence/live-20260810-04/prototype-failure.json` records exact
    `TimeoutError: timed out waiting for primary user input`, SHA-256
    `2ed70c984cd1d276785483289b470ab6330fab9fcbd4f2601b3669346b77c3aa`;
  - `poc/evidence/live-20260810-04/gateway.jsonl` proves successful `xhigh`
    readiness and input presentation before the timeout, SHA-256
    `51c255e6e0a3506cc9737c3171c11ff0b778ecbc6e59a7c831cc1c63939bbda5`;
    and
  - preserved runtime `/tmp/darkline-mvp.live-20260810-04.omBgDZ`, with copied
    credentials scrubbed.
- Required outcome: separate human-response waiting from worker/model operation
  deadlines so ordinary user think time cannot terminalize accepted work. Do
  not introduce general crash recovery or automatic retry.
- Lifecycle: `open`; no corrective edit or retry performed.

### Convergence checkpoint LIVE-CP-E7-03

- Review epoch: 7.
- Triggered at: fourth live run, pre-fix.
- Continuation:
  - Phase: authorized live-PoC exercise.
  - Boundary: pre-fix.
  - Lane: discovery.
  - Required next action: assess LIVE-E7-04 and LIVE-E7-05 against the accepted
    fixed-fixture proof boundary and user-paced primary interaction, select the
    least-surface repair, reconverge review/closure, and only then start a fresh
    fixed E2E run.
- Trigger: two sibling user-interface contract failures surfaced after the
  underlying stock-TUI attach path became operational; one hides the proof's
  fixed task boundary and one applies an agent-operation deadline to a human.
- Evidence clusters: accepted deterministic E2E fixture versus future generic
  product harness; primary presentation/input ownership; prior live bootstrap
  findings LIVE-E7-01 through LIVE-E7-03.
- Status: `open`; diagnosis and action pending independent convergence
  assessment. Commit, integration, push, production-harness work, Piccolod
  execution, and live retry remain gated.

### LIVE-CP-E7-03 convergence decision

- Independent diagnosis: `no-common-root-cause`, high confidence. LIVE-E7-04 is
  a presentation-contract mismatch; LIVE-E7-05 is an independent lifecycle/
  deadline mismatch. They share the human-interface boundary but neither causes
  the other, so no new common abstraction is justified.
- Repair altitude: `implementation`; `local-fix-appropriate`, high confidence.
  The accepted fixed-fixture/product boundary and the user's decision to finish
  the deterministic E2E remove product and requirement ambiguity.
- LIVE-E7-04 selected correction: state the exact fixed
  `PROTOTYPE_WORK_ITEM.md` value-normalization task and explicit no-other-task/
  repository boundary while still requiring genuine user voice intake. Do not
  autosupply the request or change fixture semantics/validators.
- LIVE-E7-05 selected correction: wait indefinitely only while the current
  presentation remains attached. Retain short queue polling, generation checks,
  host-failure/detach detection, admission cancellation, and bounded PTY gate
  acknowledgements. Keep worker/model/post-admission deadlines unchanged.
- Rejected wait alternatives: another finite human deadline only moves the
  arbitrary terminalization point; durable idle pause/resume adds recovery state
  outside this happy-path PoC; blocking `queue.get()` would hide detach and host
  failure.
- Explicit non-expansion: no qualification, console, rebind, crash-recovery,
  retry, generic prompt/repository, production-harness, or Piccolod change.
- LIVE-E7-04 and LIVE-E7-05 lifecycle: `actioned`; focused regression tests,
  full offline validation, independent code review, and PLAN-to-code closure
  remain required.
- LIVE-CP-E7-03 status: `actioned`; its recorded continuation remains a fresh
  fixed-fixture E2E run only after those gates close.

## Epoch 7 fourth-live repair verification

- LIVE-E7-04 lifecycle update: `resolved`. The initial presentation now names
  the exact fixed `PROTOTYPE_WORK_ITEM.md` value-normalization task, explicitly
  rejects another repository/task, and still requires the user to provide the
  genuine verbatim request in their own words.
- LIVE-E7-05 lifecycle update: `resolved`. Human response capture no longer
  consumes `worker_timeout`; it waits while the exact presentation remains
  attached using bounded 50-millisecond queue polls. Current-generation
  filtering, detach/host-failure wake-up, admission cancellation, and bounded
  PTY gate acknowledgements remain intact. Worker, model, post-admission, and
  settlement deadlines remain unchanged.
- Independent `code-review-analyst` verdict: `CLEAN`; no blocking or significant
  findings and no extra behavior. The reviewer independently reran all five
  focused prompt/wait/detach/stale-generation/host-failure tests successfully.
- Offline verification: five focused tests passed; the complete Python suite
  passed with 292 tests and one expected skip. Go tests and vet, Python
  compilation, and `git diff --check` passed. The original staged snapshot
  remained byte-identical at SHA-256
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- LIVE-CP-E7-03 status: `resolved`. Both independent local corrections and their
  required holistic verification are complete; no shared architecture,
  product, generic-harness, recovery, or scope change was required.
- Next gate: independent PLAN-to-implementation closure. Fresh live retry,
  production-harness work, Piccolod execution, commit, integration, push, and
  qualification-pin changes remain gated.

## Epoch 7 fourth-live repair closure

- Independent `rfc-implementation-verifier` verdict: `closed`, high confidence.
- Fixed-fixture intake now matches the accepted PLAN and still preserves the
  user's genuine verbatim voice request. Human think time is independent of
  `worker_timeout` while the exact presentation remains attached; existing
  host-failure, detach, generation, admission, and bounded PTY-gate behavior is
  preserved.
- Worker/model/post-admission/settlement deadlines, qualification, console,
  rebind, authority, retry, and recovery contracts remain unchanged. No generic
  repository/product harness or Piccolod behavior was added.
- The prior hidden-bootstrap deviation remains documented and unchanged.
  LIVE-E7-04 and LIVE-E7-05 restore accepted contracts and are not deviations.
- PLAN update: none required. Blocking findings: none.
- Next gate: fresh `live-20260810-05` fixed-fixture E2E run under the existing
  scoped authorization. Production-harness work, Piccolod execution, commit,
  integration, push, and qualification-pin changes remain separately gated.

## Epoch 7 fifth approved live-PoC discoveries

### LIVE-E7-06 — controller emits invalid strict output schemas

- Live run: `live-20260810-05`; primary activation, verbatim intake, intent
  acceptance, attempt creation, planner assignment, and planner-thread start all
  succeeded. No implementation, candidate, validation, or Git effect occurred.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:WorkflowEngine.plan_schema`, composed with the
  remaining bare nested-object schemas in role adoption and effect
  acknowledgement.
- Exact finding: the planner request's nullable `ask` object declares an object
  branch without `additionalProperties: false`. The OpenAI structured-output
  boundary rejects the request before model execution with HTTP 400
  `invalid_json_schema`. Read-only inspection found the same invalid bare-object
  construction pattern at the role-adoption `next_state` and effect-
  acknowledgement `exact_identity` sites, which the successful E2E path would
  reach later.
- Scenario: a valid fixed task is accepted -> the controller starts the planner
  with its declared output schema -> the provider rejects the controller-owned
  schema before planning -> the workflow truthfully stops and preserves the
  accepted intent and attempt, but cannot reach implementation.
- Evidence:
  - `poc/evidence/live-20260810-05/prototype-failure.json` records
    `ModelCallError: attempt_1_planner model call failed`, SHA-256
    `f8dac0c4857e4c46856a220ad561edc872080b8dfd237daee96c51f2304b1c4f`;
  - `poc/evidence/live-20260810-05/app-server-raw.jsonl` records the exact
    provider error at turn `019fec41-1068-7ac0-9e1d-0dddbcfa56eb`:
    `additionalProperties` is required and must be false at
    `properties.ask.type.0`, SHA-256
    `93e3aa53afcf4dc4d0e6ee18e367154c32e3269c02444ffe58777c5cc6742f41`;
    and
  - preserved runtime `/tmp/darkline-mvp.live-20260810-05.eViLST`, with copied
    credentials scrubbed.
- Required outcome: every controller-owned structured-output object branch used
  by the fixed narrative must be closed and explicit before another live run;
  offline regression coverage must mechanically inspect the complete narrative's
  emitted schemas so this static contract error is caught before runtime.
- Lifecycle: `open`; no corrective edit or live retry performed.

### Convergence checkpoint LIVE-CP-E7-04

- Review epoch: 7.
- Triggered at: fifth live run, pre-fix.
- Continuation:
  - Phase: authorized fixed-fixture live-PoC exercise.
  - Boundary: pre-fix.
  - Lane: diagnosis.
  - Required next action: assess the three sibling invalid nested-object schema
    sites and relevant historical schema findings, select the smallest repair
    that closes the demonstrated E2E failure class, then complete offline
    validation, holistic code review, and PLAN-to-code closure before proposing
    a fresh live run.
- Trigger: one runtime failure exposed the same invalid controller-owned schema
  construction at three sequential E2E sites. Fixing only the first rejection
  would predictably move the next live failure to role adoption or effect
  acknowledgement.
- Status: `open`; ordinary fix, review dispatch, live retry, commit, integration,
  push, and qualification-pin changes remain gated pending diagnosis.

### LIVE-CP-E7-04 convergence decision

- Independent diagnosis: `local-design-flaw`, high confidence, at
  implementation altitude. LIVE-E7-06 is one shared construction defect across
  three sequential sites: top-level schemas use `object_schema`, while planner
  `ask`, role-adoption `next_state`, and effect-acknowledgement `exact_identity`
  bypass it with bare nested object branches.
- Relationship: related to historical producer/schema propagation misses
  CR-E3-09 and CR-E3-24, but not the same root as E7-NATIVE-006. That finding
  concerned the authority/transport channel for controller-owned schemas;
  LIVE-E7-06 concerns whether the schema bytes reaching the provider satisfy its
  demonstrated strict-object contract.
- Selected correction: make planner ask/options explicit closed objects;
  replace arbitrary role-adoption next-state keys with one closed required
  instruction field matching the only consumer; and make restart/integration
  effect identities explicit closed schemas bound to their exact result values.
- Offline prevention: recursively inspect every schema captured by the existing
  complete two-attempt narrative and require every object-bearing branch,
  including nullable and array-item branches, to declare `properties`,
  `additionalProperties: false`, and a complete matching `required` set. Add
  focused shape assertions for planner ask, role revision, and both effect kinds.
- Rejected alternatives: patching only the first `ask` would leave predictable
  later failures; removing structured output violates the accepted typed
  boundary; a runtime recursive schema rewriter would hide under-specification
  and catch a static controller defect too late; no product, PLAN, provider, or
  version workaround is required.
- LIVE-E7-06 lifecycle: `actioned`; the three corrections and offline
  regressions are one repair set. Full validation, holistic code review, and
  PLAN-to-code closure remain required.
- LIVE-CP-E7-04 status: `actioned`; live retry, commit, integration, push, and
  qualification-pin changes remain gated until its recorded continuation
  completes.

### E7-SCHEMA-CR-001 — revision test emits an impossible adoption shape

- Review epoch / iteration: 8 / phase-1.1 discovery.
- Source: independent `code-review-analyst`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/test_prototype.py`, revision-run adoption double.
- Statement: the second adoption in the revision-flow test still returns
  `next_state={"accepted_kind":"terminal"}` after the controller schema was
  narrowed to one required `instruction` field. The test passes only because
  this custom scripted output is not provider-validated, so its fixture cannot
  represent a possible live structured-output response.
- Relationship: same LIVE-E7-06 schema-propagation repair cluster, at the
  offline producer-fixture boundary. It is not a new live or product failure.
- Required outcome: emit the exact new `instruction` shape and bind the custom
  mock's keys/non-empty value to the supplied adoption schema so this regression
  cannot silently drift again.
- Lifecycle: `open`; no fix applied yet. No new convergence checkpoint fires:
  this is the first substantive finding in the restarted review epoch, is not a
  repeated P1, and changes neither architecture nor scope.

### E7-SCHEMA-CR-001 correction and continuation

- Fix applied: both revision-test adoption responses now emit the one required
  non-empty `instruction` field. The custom model asserts its response keys
  equal the exact supplied `next_state.required` set before returning.
- Focused verification: revision replacement/adoption, explicit closed-schema,
  and complete two-attempt narrative tests all pass (3/3).
- Lifecycle: `actioned`.
- Continuation token:
  - Phase: phase-1.
  - Boundary: post-fix.
  - Lane: discovery.
  - Required next action: rerun the fresh holistic `code-review-analyst` over
    the complete current schema repair, without prior finding or fix context.
- Post-fix trigger evaluation: one substantive iteration in review epoch 8; no
  P1 repetition, sibling-P1 sequence, ownership ambiguity, scope expansion, or
  three-iteration threshold. No new convergence checkpoint opens.

### Epoch 8 Phase 1 convergence and simplification

- Fresh holistic `code-review-analyst` discovery verdict: `CLEAN`; no
  actionable in-scope findings. The reviewer received the scope block and
  current code/test artifact without the ledger, prior finding, diagnosis, or
  claimed fix.
- Independent checks: focused closed-schema and complete-narrative tests passed;
  the complete `test_prototype` module passed with 97 tests; scoped
  `git diff --check` passed.
- E7-SCHEMA-CR-001 lifecycle: `resolved`. The clean discovery pass inspected
  every related scripted fixture in addition to the production schema and
  consumer sites.
- Phase 1 exit: findings are marginal/none and no new checkpoint blocks the
  phase. LIVE-CP-E7-04 remains `actioned` pending its downstream Phase 3 and
  PLAN-closure continuation.
- Phase 2 simplification: the three explicit schema constructors and recursive
  offline assertion are each load-bearing for one demonstrated provider or
  regression boundary. No safe simplification or removal was identified; no
  code change was made.
- Next gate: scoped security specialist review because the change tightens the
  model-output validation/trust boundary, then Phase 3 discovery gating.

### Epoch 8 security specialist review

- Independent `security-researcher` verdict: `CLEAN`; no actionable in-scope
  security finding.
- Planner asks are recursively closed. Role adoption remains bound to the exact
  producer output identity, and restart/integration acknowledgements are bound
  to the controller's exact persisted effect result.
- No dependency, credential, network-authority, filesystem-authority, or
  supply-chain surface changed. The focused schema, revision, and complete-
  narrative tests passed.
- Next gate: Phase 3 independent dirty-tree review.

### Epoch 8 Phase 3 independent gate

- The playbook's requested `danger-full-access` sandbox was rejected by the
  managed execution policy, so the same `codex review --uncommitted` target ran
  with the materially safer `read-only` sandbox, Codex 0.147.0, GPT-5.6 Codex,
  and `xhigh` reasoning effort.
- Verdict: `CLEAN`; no actionable in-scope defects were found. The gate ran all
  294 Python tests plus static validations successfully. Its Go network tests
  could not open loopback listeners inside the read-only sandbox; the ordinary
  local Go test and vet gates remain authoritative for that environment-only
  limitation.
- LIVE-CP-E7-04 status: `resolved`. Its required restarted discovery gate is
  clean after the complete repair and security review.
- LIVE-E7-06 status: `actioned`, pending final local validation and independent
  PLAN-to-implementation closure. Fresh live retry, commit, integration, push,
  and qualification-pin changes remain gated.

### Epoch 8 final local validation

- Python: 294 tests passed, with the one existing outer-sandbox network-canary
  test skipped.
- Go: `go test ./...` and `go vet ./...` passed.
- Static checks: Python compilation and `git diff --check` passed.
- The original staged snapshot remained byte-identical at SHA-256
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- LIVE-E7-06 remains `actioned` only until the independent PLAN-to-
  implementation closure records whether the final repair is closed.

### Epoch 8 strict-schema repair closure

- Independent `rfc-implementation-verifier` verdict: `closed`, high confidence.
- Planner asks/options, role-adoption next state, and restart/integration exact
  effect identities satisfy the accepted typed-boundary contracts. The complete
  two-attempt narrative recursively checks every emitted schema, and focused
  coverage exercises planner, revision/adoption, restart, and integration paths.
- Missing required behavior: none. Extra behavior: none attributable to this
  repair. Undocumented deviation: none. PLAN update: none required.
- Primary accountability and kernel producer/effect identity checks remain
  intact. No runtime schema rewriter, generic harness, retry/recovery change,
  provider/version workaround, Piccolod behavior, or publication effect was
  introduced.
- LIVE-E7-06 lifecycle: `resolved`.
- Next gate: explicit user approval for a fresh fixed-fixture live E2E run. No
  live retry, commit, integration, push, or qualification-pin change has been
  performed by this repair cycle.

## Epoch 7 sixth approved live-PoC discovery

### LIVE-E7-07 — terminal role actions disappear from `thread/read`

- Live run: `live-20260811-01`. Intake and intent acceptance succeeded. The
  attempt-one planner read the fixture with one successful `commandExecution`
  action and returned a valid schema-constrained plan. No implementation,
  candidate, validation, or Git effect occurred.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:ControllerModelRuntime.call`, composed with
  `poc/controller.py` role-turn action monitoring.
- Exact finding: the runtime requires the action IDs observed in live
  `item/started` / `item/completed` notifications to equal actions returned by
  the later exact `thread/read`. Codex 0.147 emitted and the controller durably
  recorded the planner's completed command action, but `thread/read` returned
  only the user and final agent-message items even with `itemsView=full`. The
  equality check therefore rejected a successfully completed planner turn and
  its valid plan.
- Scenario: planner performs one allowed read-only command -> the sole App
  Server stream emits exact start and completed notifications -> the planner
  emits valid plan JSON and the turn completes -> `thread/read` omits the
  already-observed command item -> the controller treats the two different API
  projections as if they must contain the same item universe -> planning fails.
- Evidence:
  - planner turn `019fee35-f7a9-7742-88ff-a8803bb444ea` and action
    `exec-d0e951e8-08d4-4c6f-a731-711773cbc95e`;
  - `poc/evidence/live-20260811-01/app-server-raw.jsonl`, SHA-256
    `ad08a0aa1bb71c9f1290c54e73349f12a132d259a4cd55bb44d948bb3b090c41`,
    records terminal action notifications, valid plan output, terminal turn,
    and the action-omitting exact `thread/read` result;
  - `poc/evidence/live-20260811-01/journal.sqlite`, SHA-256
    `a512a58190700340d39f4fbe446cc24d44fcf351c1ed7e3f4c95e6f0122e2212`,
    preserves the completed durable action and fenced run; and
  - preserved runtime `/tmp/darkline-mvp.live-20260811-01.X1JcyS`, with copied
    credentials scrubbed.
- Lifecycle: `open`; no corrective edit or live retry performed.

### LIVE-E7-07 resolution challenge

- Diagnosis: `local-design-flaw`, high confidence. Repair altitude:
  `implementation`.
- Governing mistake: the controller conflates two authoritative but different
  App Server projections. Ordered item notifications are the action lifecycle
  source; exact `turn/completed` plus `thread/read` remain the terminal-turn and
  final-output source. The accepted PLAN already requires notification-based
  action tracking and does not require `thread/read` to replay action items.
- Selected correction: retain each monitored action's exact ID, item type, and
  terminal state from the sole ordered notification stream; use that complete
  terminal set as call evidence. Continue requiring exact completed turn and
  final typed output from `turn/completed` plus `thread/read`. Fail closed on a
  missing start, missing terminal state, or inconsistent action identity.
- Rejected alternatives: removing action enforcement would lose the PM-style
  work frontier; treating `thread/read` omission as no action would corrupt the
  corpus; adding recovery/retry or a second evidence store would not correct the
  source-boundary mistake.
- Semantic-surface delta: no new state, authority, lifecycle, protocol, product
  behavior, or PLAN change. This is a bounded source-selection correction plus
  regression coverage.
- LIVE-E7-07 lifecycle: `actioned`; focused validation and the normal holistic
  review/closure continuation are required before another live retry.

### E7-ACTION-CR-001 — notification terminal state is not exact

- Review epoch / iteration: 9 / phase-1.1 discovery and security specialist.
- Sources: independent `code-review-analyst` and `security-researcher`.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:_observe_role_budget_notification`.
- Statement: the notification observer silently ignores malformed or duplicate
  lifecycle events and maps every completion status outside a small failure set
  to `completed`. A missing, nonterminal, unknown, or `declined` status can
  therefore become successful terminal evidence when `thread/read` omits the
  action.
- Required outcome: validate the ordered action lifecycle exactly, reject
  malformed or duplicate events, accept only protocol-defined terminal action
  statuses, and preserve one consistent canonical terminal state for both the
  notification authority and the optional `thread/read` contradiction check.
- Relationship: sibling propagation miss within LIVE-E7-07's accepted
  notification-authority correction; not a new product or PLAN requirement.
- Lifecycle: `open`; no fix applied.

### E7-ACTION-CR-002 — failure settlement still reconstructs actions from thread read

- Review epoch / iteration: 9 / security specialist.
- Source: independent `security-researcher`.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:_close_dispatched_role_turn`.
- Statement: the rejected-turn settlement path discards the monitor summary and
  uses `thread/read` plus `reconcile_rejected_role_action` to create or
  terminalize durable action evidence. The secondary projection can therefore
  become the lifecycle source after the ordinary path rejects it.
- Required outcome: retain and validate notification-derived action evidence in
  failure settlement; use `thread/read` only to detect contradictions; fence
  rather than repair missing or nonterminal notification evidence.
- Relationship: second sibling propagation miss within LIVE-E7-07's accepted
  source-ownership correction.
- Lifecycle: `open`; no fix applied.

### E7-ACTION-CR-003 — prompt-only roles inspect the secondary projection

- Review epoch / iteration: 9 / phase-1.1 discovery.
- Source: independent `code-review-analyst`.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:ControllerModelRuntime.call` prompt-only role gate.
- Statement: `semantic-verifier` and native hard-review prompt-only enforcement
  still inspects only `thread/read` actions. An action omitted there but retained
  by authoritative notifications can therefore evade the no-tools rule.
- Required outcome: enforce prompt-only roles against the notification-derived
  action set and retain `thread/read` solely for contradiction checking.
- Relationship: third sibling propagation miss within LIVE-E7-07's accepted
  source-ownership correction.
- Lifecycle: `open`; no fix applied.

### LIVE-CP-E7-05 — action-authority propagation checkpoint

- Trigger: the first LIVE-E7-07 repair corrected the ordinary successful-turn
  projection, after which fresh discovery found three blocking sibling sites at
  lifecycle validation, failure settlement, and prompt-only enforcement. This
  is pattern evidence that the source-ownership invariant was not propagated to
  every consumer.
- Status: `open`; no ordinary fix or downstream gate may proceed before the
  convergence diagnosis records the governing boundary and least-surface
  continuation.
- Continuation token:
  - Phase: phase-1.
  - Boundary: pre-fix.
  - Lane: discovery plus security specialist.
  - Required next action: diagnose the sibling cluster, select repair altitude,
    then either apply the bounded source-ownership correction and rerun fresh
    holistic reviews or escalate the smallest product/scope decision.

### LIVE-CP-E7-05 convergence decision

- Independent diagnosis: `local-design-flaw`, high confidence, at
  implementation altitude. The accepted notification-authority invariant was
  propagated only through the ordinary success path; lifecycle parsing,
  rejected-turn settlement, and prompt-only enforcement remained sibling
  bypasses.
- Exact invariant: one valid start followed by one matching terminal completion
  on the ordered notification stream is the only source allowed to create,
  type, order, or terminalize a role action. Missing identity, duplicate or
  out-of-order events, type mismatch, and missing, unknown, or nonterminal
  completion status make the turn ineligible. `turn/completed` plus
  `thread/read` continue to own terminal turn and final output, while any action
  that `thread/read` does return must be a matching subset of notification
  evidence and can never repair it.
- Selected correction: define one explicit pinned action-status mapping; retain
  exact monitor violations; make ordinary completion, rejected-turn settlement,
  prompt-only roles, and budget checkpoints consume the same notification
  snapshot; remove rejected-action reconstruction from `thread/read`; and share
  the one-way contradiction check.
- Rejected alternatives: no second action store, notification/read union,
  equality requirement, replay/retry/recovery machinery, generic event-sourcing
  framework, provider reconstruction, product decision, or PLAN revision.
- Required verification: exact valid lifecycle with omitted read action;
  supported terminal mappings; malformed, duplicate, out-of-order, mismatched,
  missing, unknown, and nonterminal notification rejection; read omission versus
  extra/contradictory action behavior; no failure-settlement reconstruction;
  fencing of incomplete notification state; and prompt-only rejection from
  notification evidence.
- LIVE-CP-E7-05 status: `actioned`; apply this bounded repair, then restart a
  fresh review epoch and resolve the checkpoint only after holistic code,
  security, Phase 3, and PLAN-closure evidence are clean.

### Epoch 10 action-authority repair and continuation

- E7-ACTION-CR-001 fix: one explicit Codex-0.147 action lifecycle mapping now
  validates exact item identity, start status, terminal status, duplicate and
  out-of-order events. `completed` remains completed; `failed` and `declined`
  canonicalize to the kernel's failed terminal state. Missing, unknown, and
  nonterminal statuses become a retained monitor violation and request the
  existing exact-turn interrupt; no fallback maps an unknown status to success.
- E7-ACTION-CR-002 fix: rejected-turn settlement retains the exact monitor
  snapshot, requires its actions to equal the durable kernel action frontier,
  and permits `thread/read` only as a matching subset. The production
  `reconcile_rejected_role_action` mutation was removed; missing, invalid, or
  incomplete notification evidence fences rather than reconstructs a turn.
- E7-ACTION-CR-003 fix: semantic-verifier, native hard-review structuring, and
  budget-checkpoint prompt-only enforcement now consume the same notification-
  derived action snapshot used by ordinary role success. Omitted read actions
  can no longer bypass the tool-less rule.
- Shared boundary: one helper validates the optional `thread/read` action subset
  against notification evidence, and one pinned status validator is used by
  both the live observer and read-side contradiction parser. No new state,
  protocol, authority, retry, recovery, product behavior, or PLAN decision was
  added.
- Focused verification: nine action-authority, notification lifecycle,
  settlement, prompt-only, and kernel regressions passed. Broader controller,
  prototype, authoritative-kernel, and kernel validation passed 211 tests.
- Lifecycles: E7-ACTION-CR-001, E7-ACTION-CR-002, and E7-ACTION-CR-003 are
  `actioned`; LIVE-CP-E7-05 remains `actioned`.
- Continuation token:
  - Phase: phase-1 restart, review epoch 10.
  - Boundary: post-fix.
  - Lane: fresh holistic discovery plus security specialist.
  - Required next action: review the complete current action-authority repair
    without prior findings or claimed-fix context, then run simplification,
    Phase 3, full local validation, and independent PLAN closure.

### E7-ACTION-CR-004 — pre-binding notification integrity can fail open

- Review epoch / iteration: 10 / security discovery after convergence restart.
- Source: fresh independent `security-researcher`.
- Severity / scope: provisionally `blocking × in-scope`, pending exact trust-
  boundary disposition.
- Location: `poc/controller.py:_read_upstream`,
  `register_role_turn_monitor`, and `_observe_role_budget_notification`.
- Statement: invalid JSON is logged and skipped, while action notifications on
  an armed role thread are buffered by their reported turn identity and only the
  returned turn's bucket is consumed. A same-thread wrong-turn bucket can be
  abandoned; after binding, a same-thread wrong-turn event is ignored. Because
  read-side omission is allowed, the exact monitor could appear action-free.
- Required outcome under the accepted trust model: an integrity-invalid
  notification window must not make role output eligible. Distinguish failures
  the controller can prove (invalid protocol frame; wrong turn on the exact
  armed/monitored role thread) from a Byzantine App Server falsely attributing
  an action to an unrelated valid thread, for which the notification source
  itself supplies no independent identity evidence.
- Relationship: same LIVE-E7-07 action-authority cluster, discovered after the
  first convergence-driven restart.
- Fix applied / lifecycle: `actioned` in the approved bounded second repair.
  Invalid JSON/non-object provider frames now fail the protocol reader and
  invalidate every active monitored role window. Potential action events for a
  different turn on the exact armed or active role thread invalidate the exact
  monitor, while known non-action items remain outside action authority.

### LIVE-CP-E7-06 — repeated action-authority boundary checkpoint

- Trigger: the restarted epoch found another blocking candidate in the same
  notification-authority cluster. Per the one-restart convergence cap, no
  further ordinary fix loop is permitted before user-visible disposition.
- Status: `actioned` by the user's explicit 2026-08-11 selection of the bounded
  second repair. Only that repair and its convergence-directed review restart
  are permitted while this checkpoint remains actioned.
- Continuation token:
  - Phase: phase-1 convergence-directed restart, review epoch 11.
  - Boundary: pre-fix.
  - Lane: bounded implementation repair followed by fresh holistic and security
    discovery.
  - Required next action: apply only the approved E7-ACTION-CR-004/005 repair,
    then dispatch fresh review without prior-finding or claimed-fix priming.

### E7-ACTION-CR-005 — a retained violation disables its own enforcement clock

- Review epoch / iteration: 10 / fresh holistic code discovery after
  convergence restart.
- Source: independent `code-review-analyst`.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:_observe_role_budget_notification` and
  `_request_role_budget_interrupt`.
- Statement: recording a lifecycle violation cancels the only budget timer and
  ignores subsequent item events without first durably closing action admission
  or establishing a settlement deadline. The asynchronous interrupt worker also
  treats a returned JSON-RPC `error` object as success because it checks only
  raised exceptions.
- Scenario: invalid action event -> monitor records violation and cancels timer
  -> `turn/interrupt` returns an error without raising -> the worker continues,
  later actions become invisible, and exact-turn waiting can remain governed by
  the original five-minute frontier rather than a bounded rejected-turn
  settlement.
- Required outcome: a proven lifecycle violation must first close durable action
  admission and establish bounded failure settlement or fence the exact role
  turn; an interrupt error response is failure; later action events must not
  become silently invisible before terminal/fenced state.
- Relationship: same LIVE-E7-07 cluster and partly introduced/exposed by the
  first repair's retained-violation path.
- Fix applied / lifecycle: `actioned` in the approved bounded second repair.
  The controller now starts the existing durable failure-settlement transition
  before recording the violation and cancelling its timer, treats a returned
  interrupt `error` as failure evidence, and continues observing exact-turn
  action lifecycle events after the first violation until terminal or fence.

### LIVE-CP-E7-06 synthesized escalation

- Fresh code discovery and security discovery each found a concrete blocking
  gap after the convergence-directed restart. E7-ACTION-CR-004 concerns the
  pre-binding integrity window; E7-ACTION-CR-005 concerns durable enforcement
  after a detected violation.
- Local validation remains clean (300 tests, one existing sandbox skip; Go
  test/vet, Python compilation, and diff check pass), proving the current tests
  are internally consistent but not discharging either newly demonstrated
  scenario.
- The staged baseline remains byte-identical at
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
  Main repository `main` remains clean at
  `97210764c21504f88874bdcb350b64cf4ac18b37`.
- At escalation time the one-restart convergence cap left LIVE-CP-E7-06 `open`;
  no second same-cluster fix or later gate was then authorized without the
  user's explicit disposition. The following entry records that disposition.

### LIVE-CP-E7-06 user disposition and resolution decision

- User decision: on 2026-08-11 the user selected Option 1, the bounded second
  repair, after the two concrete gaps and the rewind/accept alternatives were
  presented.
- Diagnosis: `local-design-flaw` with high confidence.
- Repair altitude: `implementation`.
- Triggering cluster: E7-ACTION-CR-004 and E7-ACTION-CR-005.
- Candidate repair and semantic-surface delta: make invalid provider frames and
  controller-detectable same-thread/wrong-turn action evidence invalidate the
  monitored window; reuse the existing durable role-turn failure-settlement
  path before cancelling its enforcement timer; treat an interrupt JSON-RPC
  error response as failure; retain observation of later exact-turn action
  lifecycle events until terminal or durable fence. This adds no product
  behavior, database lifecycle, generic recovery protocol, or PLAN decision.
- Trust boundary: a Byzantine provider falsely labeling an action as belonging
  to an unrelated valid thread remains outside the controller's provable
  identity surface and outside this repair.
- Action: apply only the bounded repair, mark E7-ACTION-CR-004 and
  E7-ACTION-CR-005 actioned, then restart holistic discovery in review epoch 11.
  LIVE-CP-E7-06 remains actioned until that restarted flow closes cleanly.
- Still unauthorized: any live retry, commit, integration, push, or
  qualification-pin change.

### Review epoch 11 bounded repair checkpoint

- Scope: only E7-ACTION-CR-004 and E7-ACTION-CR-005 under the recorded user
  disposition.
- Focused evidence: all 47 controller tests pass, including new invalid-frame,
  pre-/post-binding wrong-turn, interrupt-error, durable-settlement, and
  post-violation observation regressions. The broader controller, kernel,
  prototype, and authoritative-kernel suite also exits cleanly.
- Repository invariants: `git diff --check` is clean; the staged baseline is
  unchanged at `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`;
  the main repository remains clean.
- Continuation: fresh review epoch 11 holistic code discovery and security
  discovery, without prior-finding or claimed-fix priming.

### E7-ACTION-CR-006 — role terminal does not seal the notification window

- Review epoch / iteration: 11 / fresh holistic and security discovery.
- Source: independent `code-review-analyst` and `security-researcher`
  convergence.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:1720` and monitor removal at
  `poc/controller.py:1509`.
- Statement: exact `turn/completed` only cancels the timer. Exact-turn actions
  arriving afterward are accepted before monitor removal and silently ignored
  after removal, so the terminal event is not an enforced action-authority
  boundary.
- Scenario: exact turn completion -> late action start/terminal -> action is
  either accepted into an otherwise clean summary or disappears after
  unregister -> writable effect exists outside the integrity-valid window.
- Suggested resolution: represent and enforce the terminal boundary. Reject new
  action starts after exact `turn/completed`, but continue accepting matching
  terminal notifications for actions whose starts were observed earlier, as
  required by the accepted turn/action settlement race. Retain only the minimum
  binding needed to prevent invalid post-unregister events from disappearing
  before the role is settled or fenced.
- Lifecycle / relationship: `open`; `repeated` in the LIVE-E7-07 action-
  authority cluster after the user-authorized bounded repair.

### E7-ACTION-CR-007 — clean upstream EOF bypasses active-window containment

- Review epoch / iteration: 11 / fresh holistic discovery.
- Source: independent `code-review-analyst`.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:743`.
- Statement: the exception path invalidates active monitors, but premature
  clean App Server EOF synthesizes its `ConnectionError` only in `finally` and
  never invokes the same durable failure settlement.
- Scenario: active monitored role -> sole notification stream ends cleanly ->
  reader failure is logged without closing action admission or adding a
  settlement deadline -> a crash can preserve an active unfenced role turn.
- Suggested resolution: route premature EOF through the same active-monitor
  containment path and test it with an active monitor.
- Lifecycle / relationship: `open`; `spawned-sibling` of the notification-
  integrity failure path.

### E7-ACTION-CR-008 — arm-to-bind replay can reorder valid notifications

- Review epoch / iteration: 11 / fresh holistic discovery.
- Source: independent `code-review-analyst`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/controller.py:1494`.
- Statement: registration exposes the live monitor before buffered events are
  replayed outside the lock, so the reader can deliver a later live completion
  before its buffered start. Buffered starts are also timestamped at replay
  rather than receipt.
- Scenario: start buffered before `turn/start` response -> monitor exposed ->
  live completion processed first -> valid stream is rejected as completion-
  without-start.
- Suggested resolution: drain one ordered, receipt-timestamped per-thread queue
  across the arm-to-bind transition before switching atomically to live
  processing.
- Lifecycle / relationship: `open`; same pre-binding surface, availability
  rather than fail-open authority.

### E7-ACTION-CR-009 — upstream App Server envelopes are unbounded

- Review epoch / iteration: 11 / fresh security discovery.
- Source: independent `security-researcher`.
- Severity / scope: `significant × in-scope`.
- Location: `poc/controller.py:705`.
- Statement: the sole App Server stream uses an unbounded line iterator, then
  parses, copies, and persists the complete line before any size check.
- Scenario: oversized provider envelope -> repeated memory/evidence allocation
  -> controller exhaustion before active role containment completes.
- Suggested resolution: use a bounded upstream read, reject overflow without
  persisting its raw body, and invalidate active notification windows.
- Lifecycle / relationship: `open`; sibling of malformed provider-frame
  handling.

### E7-ACTION-CR-010 — global protocol failure can fall between response and binding

- Review epoch / iteration: 11 / orchestrator synthesis of the reviewed pre-
  binding invariant.
- Source: primary orchestrator exact interleaving trace.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:_read_upstream`,
  `_invalidate_active_role_monitors`, and `register_role_turn_monitor`.
- Statement: global protocol failure invalidates registered monitors only; it
  leaves an armed thread unmarked. A turn response can already be delivered to
  its waiter while the main caller has not yet registered the returned turn.
- Scenario: arm thread -> reader delivers `turn/start` response -> malformed
  next frame fails the reader while no monitor is registered -> caller binds
  and registers afterward -> the new monitor has no violation and can wait on
  the original work frontier despite the corrupt notification window.
- Suggested resolution: carry a pre-binding integrity failure on the armed
  thread into exact monitor registration, and make exact-turn waiting observe
  terminal reader failure.
- Lifecycle / relationship: `open`; `repeated` incomplete propagation of
  E7-ACTION-CR-004.

### LIVE-CP-E7-07 — second restarted action-authority convergence checkpoint

- Review epoch / triggered at: 11 / fresh Phase 1 and security discovery.
- Continuation:
  - Phase: phase-1.
  - Boundary: pre-fix.
  - Lane: discovery plus specialist.
  - Required next action: diagnose the repeated action-authority cluster and
    obtain the user's disposition before any further fix or review restart.
- Trigger: the same notification-authority cluster produced new blocking
  findings after the one user-authorized bounded repair/restart; the recorded
  convergence cap prohibits another automatic loop.
- Evidence clusters: unsealed terminal boundary; exception/EOF/pre-binding
  integrity failures not propagated across every monitor state; arm-to-bind
  ordering; provider-envelope bounds.
- Diagnosis: `local-design-flaw`, high confidence, at architecture altitude.
- Action: ask the user whether to amend and re-review the PLAN for one bounded
  controller-owned notification-window lifecycle, change the provider-trust
  requirement, or rewind/defer the action-authority proof.
- Status: `open`.
- Gate: no further implementation fix, Phase 2/3, PLAN closure, live retry,
  commit, integration, push, or qualification-pin change is permitted while
  this checkpoint is open.

### LIVE-CP-E7-07 convergence decision

- Independent diagnosis: `local-design-flaw`, high confidence, at architecture
  altitude. Notification-window ownership is fragmented across armed threads,
  per-turn buffers, active monitors, reader state, caller waits, monitor removal,
  and later kernel settlement. CR006-CR010 are adjacent transitions of that one
  missing lifecycle rather than independent local mistakes.
- Required invariant: one controller-owned lifecycle spans `armed -> binding/
  replay -> active -> turn-terminal/settling -> settled/fenced`; receipt order
  and time survive binding; every integrity-loss path enters the same durable
  failure transition; terminal reader failure wakes exact-turn waiters; exact
  turn completion closes new action-start admission while allowing already-
  started actions to terminalize; and the exact binding survives until kernel
  settlement or fence.
- Candidate architecture correction: reuse the existing kernel action and
  settlement records, add only the private controller lifecycle/ordered bounded
  queue and minimum finalization seam, and cover the named interleavings. No
  second durable store or generic event/recovery framework is justified.
- Genuine alternative: explicitly trust a narrower App Server provider
  contract and abandon complete host-derived action authority. That is a
  product/requirement change because notification-only action evidence is
  currently required when `thread/read` omits actions.
- Next action: obtain the user's choice. If the architecture correction is
  selected, update `poc/PLAN.md`, run full Plan Review, then implement and
  restart Code Review from Phase 1. No further local patch is permitted first.

### LIVE-CP-E7-07 user disposition

- Date: 2026-08-11.
- User choice: Option 1, the bounded controller-owned notification-window
  lifecycle.
- Decision effect: amend `poc/PLAN.md` with the exact lifecycle, authority,
  ordering, failure, framing, finalization, site-list, and deterministic-test
  obligations; run the complete independent Plan Review flow; then return the
  reviewed plan for mandatory user authorization before any code implementation.
- Finding relationship: E7-ACTION-CR-006 through E7-ACTION-CR-010 remain open
  implementation obligations. The architecture decision addresses their shared
  cause but does not resolve or action them by itself.
- Status: `actioned` at the architecture-decision boundary; implementation and
  review closure remain pending.
- Still unauthorized: any code edit for this architecture correction, live
  retry, commit, integration, push, or qualification-pin change.

### Plan Review epoch 12 / iteration 1

- Artifact: revised `poc/PLAN.md` under the LIVE-CP-E7-07 Option 1 decision.
- Lenses: fresh independent `rfc-reviewer` and `rfc-red-team`; neither consumed
  this ledger or prior review outputs.
- Verdict: RED. The two lenses converged on two missing lifecycle boundaries;
  the soundness lens also found one framing-site omission.

#### E12-PLAN-001 — pre-binding turn terminal is outside receipt order

- Severity / scope: `blocking × in-scope`.
- Statement: the armed/binding queue included action notifications but not the
  exact turn-terminal notification, allowing a later buffered action start to
  replay without the earlier terminal admission boundary.
- Disposition: accepted. Revise the shared lifecycle stream to receipt-sequence
  action starts, action terminals, and turn terminals together, and add the
  exact terminal-before-response interleaving test.
- Lifecycle: `actioned` in plan iteration 2; verification re-review pending.

#### E12-PLAN-002 — primary semantic calls lack the same action authority

- Severity / scope: `blocking × in-scope`.
- Statement: post-binding primary semantic calls already require every started
  action to terminalize, but the draft gave notification-derived authority only
  to role turns even though `thread/read` may omit actions.
- Disposition: accepted. Reuse the same private notification lifecycle for both
  governed turn kinds, with their existing separate durable role-turn and
  primary-attempt settlement/fence records and primary-specific action policy.
- Lifecycle: `actioned` in plan iteration 2; verification re-review pending.

#### E12-PLAN-003 — framing boundary site is incomplete

- Severity / scope: `significant × in-scope`.
- Statement: the one-MiB requirement cannot be guaranteed after text-mode line
  iteration has already allocated/decoded the complete envelope; the plan did
  not name `_start_app_server` as part of the framing boundary.
- Disposition: accepted. Require bounded byte acquisition before decode, parse,
  copy, or evidence append; name `_start_app_server` and `_read_upstream`; test
  exact/over boundary and partial-envelope EOF.
- Lifecycle: `actioned` in plan iteration 2; verification re-review pending.

### Plan Review epoch 12 / iteration 2 continuation

- Revision: generalized only the private notification lifecycle from role turns
  to the two already-governed App Server turn kinds; added complete pre-binding
  lifecycle receipt ordering and the actual byte-framing sites/tests. No generic
  event framework, new durable store, product behavior, or code edit was added.
- Next action: fresh holistic soundness and adversarial re-review of the complete
  revised plan.
- Gate remains: no implementation, live retry, commit, integration, push, or
  qualification-pin change before green Plan Review and mandatory user approval.

### Plan Review epoch 12 / iteration 2 result

- Prior-finding verification: E12-PLAN-001 through E12-PLAN-003 were discharged
  by both lenses.
- Verdict: RED. Both lenses converged on the missing binding-candidate subject;
  adversarial review additionally found an eligibility-before-retirement seam.
  The soundness pass's accidental isolated ledger-line exposure was not used for
  either finding, and the independent red-team convergence supplies the required
  clean evidence for the shared blocker.

#### E12-PLAN-004 — binding continuity calls lack a durable lifecycle subject

- Severity / scope: `blocking × in-scope`.
- Statement: re-prime, catch-up, and installed-confirmation turns can advance
  binding state but were outside the role/post-binding-primary subject adapters,
  so snapshot-omitted actions could remain unsettled while an acknowledgement
  advanced.
- Disposition: accepted. Scope the private lifecycle by consequence and add a
  third closed adapter backed by the existing candidate/episode plus linked
  primary-call attempt; reserve before every candidate or active-binding
  continuity send; require a prompt-only clean terminal window in the same
  transaction that advances acknowledgement/frontier/install/confirmation.
- Lifecycle: `actioned` in plan iteration 3; verification re-review pending.

#### E12-PLAN-005 — eligibility can precede fallible window retirement

- Severity / scope: `blocking × in-scope`.
- Statement: durable role/primary settlement could become eligible before the
  runtime retired the exact notification binding, leaving no monotonic outcome
  if a concurrent integrity event or retirement failure followed.
- Disposition: accepted. Replace settlement-then-unregister with one controller-
  serialized clean-finalization boundary: validate the final receipt frontier,
  record clean closure together with the subject's existing durable advancing
  transition, retire in memory, then expose success. No fallible post-eligibility
  retirement remains.
- Lifecycle: `actioned` in plan iteration 3; verification re-review pending.

#### E12-PLAN-006 — affected test consumers omitted

- Severity / scope: `significant × in-scope`.
- Statement: `poc/test_authoritative_kernel.py` directly consumes the tightened
  settlement APIs and `poc/test_phase4.py` constructs the controller monitor
  state being replaced, but neither was named in the site list.
- Disposition: accepted. Add both to the site/test list and require their direct
  callers/fixtures to adapt while retaining unrelated capability cases.
- Lifecycle: `actioned` in plan iteration 3; verification re-review pending.

### Plan Review epoch 12 / iteration 3 convergence decision

- Independent resolution challenge: `local-design-flaw`, high confidence, at
  architecture altitude.
- Root correction: lifecycle membership is consequence-based, not caller-
  category based. The closed adapters are role turn, post-binding primary
  attempt, and primary-binding continuity attempt; no generic model-call registry
  or second durable notification store is introduced.
- Monotonic rule: no consequential model result advances its existing durable
  subject until the controller cleanly finalizes the notification window in the
  same serialized operation as that advancing kernel transition.
- User input: not required before revision; this completes propagation of the
  user-selected Option 1 and adds no product behavior. Mandatory user review
  remains required after green Plan Review and before implementation.
- Next action: fresh holistic soundness and adversarial verification re-review.
- Gate remains: no code implementation, live retry, commit, integration, push,
  or qualification-pin change.

### Plan Review epoch 12 / iteration 3 result

- Adversarial lens: GREEN; it verified the continuity subject and monotonic
  clean-finalization boundary.
- Fresh soundness lens: RED with one `blocking × in-scope` finding.

#### E12-PLAN-007 — direct primary-thread turns bypass the closed subject set

- Severity / scope: `blocking × in-scope`.
- Grounding: `InteractiveController.materialize_primary_for_resume` starts a
  bootstrap turn directly; `NativeCliPrimaryInterface.attach` causes the stock
  CLI to start a prompt turn; and captured response acknowledgement flows through
  `InteractiveController._handle_downstream_message`. These authority-bearing
  primary-thread turns do not use `ControllerModelRuntime.call` or any declared
  notification-window subject.
- Scenario: a bootstrap/attach/acknowledgement turn starts an action omitted by
  `thread/read`; its visible turn completes; binding, user-input release, or the
  next semantic attempt reuses the thread before the action terminalizes.
- Lifecycle: `open`; exact propagation sibling of E12-PLAN-004 rather than a new
  product requirement.
- Candidate resolution: keep the three-adapter architecture but rename/broaden
  the third adapter to a closed `primary-control-plane attempt` covering exactly
  binding re-prime/catch-up/confirmation, bootstrap materialization, attach/
  reattach prompt, and captured-response acknowledgement. Every retained call is
  prompt-only and cleanly finalizes before thread reuse or input/binding advance.
  Enumerate every authority-bearing primary `turn/start` site and remove or route
  any redundant model call instead of adding a fourth adapter.

### Plan auto-iteration checkpoint after version 3

- Trigger: the third automatically generated/reviewed plan version remains open
  because of E12-PLAN-007.
- Recommendation: `revise_next_version` using the bounded primary-control-plane
  adapter above, then run both independent lenses again.
- Alternatives: pause for clarification; or abandon/defer this PoC while
  preserving all work and evidence. No automatic version 4 may be created.
- Status: waiting for the user's exact direction.
- Gate remains: no plan v4 edit, implementation, live retry, commit, integration,
  push, or qualification-pin change.

### Plan auto-iteration checkpoint user disposition

- User direction: Option 1 / `revise_next_version`.
- Effect: authorize Plan v4 only, using the bounded primary-control-plane adapter
  and fresh both-lens review. This does not authorize implementation or any live,
  Git, integration, push, or qualification-pin action.
- E12-PLAN-007 disposition: `actioned` in Plan v4 by exhaustively classifying
  every authority-bearing primary-thread `turn/start` as a semantic-primary or
  one exact prompt-only control-plane purpose, and rejecting all others.
- Grounded data-shape decision: bootstrap/initial attach precede any work item,
  so Plan v4 uses one bounded `primary_control_plane_attempts` table keyed to the
  existing controller operation rather than weakening work-item-bound semantic
  attempt records or fabricating a work item. The same table supports the closed
  binding and presentation purposes; it is not a second store or generic model-
  call framework.
- Required verification: direct bootstrap, attach/reattach, captured-response
  acknowledgement, outside-window notice, binding continuity, semantic primary,
  and role paths; bare completion, omitted/delayed actions, unknown purpose,
  detach/supersession, clean-finalization ordering, and captured-input retention.
- Next action: fresh holistic soundness and adversarial Plan Review of v4.

### Plan Review epoch 12 / iteration 4 result

- Artifact: Plan v4 with the closed primary-control-plane adapter authorized at
  the three-version checkpoint.
- Lenses: fresh independent `rfc-reviewer` and `rfc-red-team`; neither consumed
  this ledger, prior reviewer outputs, memory, or review receipts.
- Verdict: RED. Both lenses independently found that the attempt record did not
  truthfully own pre-work failure or the semantic/presentation endpoint across
  rebind. The adversarial lens additionally exposed the capture-versus-detach
  admission race.

#### E12-PLAN-008 — pre-work control-plane failure has no owner

- Severity / scope: `blocking × in-scope`.
- Grounding: bootstrap, initial attach, and the first captured-response
  acknowledgement execute before `WorkflowEngine.execute()` creates the work
  item and before activation opens a candidate episode. The draft incorrectly
  routed their failure to a candidate or active-binding rebind path.
- Disposition: accepted. Bind those purposes to `pre_work_startup`; failure
  terminalizes the attempt, fences the provisional thread, preserves captured
  text/evidence, emits fixed startup-failure facts, and stops without automatic
  activation/rebind or retry.
- Lifecycle: `actioned` in the amended Plan v4; verification re-review pending.

#### E12-PLAN-009 — semantic rebind can retain the fenced presentation thread

- Severity / scope: `blocking × in-scope`.
- Grounding: current `install_primary_candidate` changes `primary_thread_id`,
  while `_downstream_primary_thread_id` and stock-CLI attach continue to prefer
  the independently cached `presentation_thread_id`. Later presentation turns
  can therefore target the fenced old primary.
- Disposition: accepted. Keep the candidate pending through direct-addressed
  confirmation and explicit candidate-thread attach, then change semantic
  routing, presentation routing/generation, and endpoint readiness through one
  handoff. Old/fenced presentation turns are rejected.
- Lifecycle: `actioned` in the amended Plan v4; verification re-review pending.

#### E12-PLAN-010 — capture release races detach/rebind invalidation

- Severity / scope: `blocking × in-scope` (adversarial lens; the soundness lens's
  endpoint finding shares the same owner seam).
- Grounding: opaque text storage, acknowledgement completion, presentation-host
  disconnect observation, and input release were not one ordered boundary. A
  response could be released from a generation whose detach was observed only
  after the blocking acknowledgement handler returned.
- Disposition: accepted. Storage alone is not admission. For one presentation
  generation, acknowledgement clean-finalization and detach/rebind invalidation
  serialize through one kernel winner: clean finalization creates exactly one
  pre-work intake token or post-intake `input_seq`; invalidation permanently
  blocks release while preserving text and requires re-presentation after
  intake. A pre-work loss stops startup.
- Lifecycle: `actioned` in the amended Plan v4; verification re-review pending.

### Plan v4 endpoint-ownership resolution challenge and user disposition

- Diagnosis: `local-design-flaw`, high confidence, at architecture altitude.
  Notification attempt, semantic owner, and presentation owner were conflated.
- Options considered: site-local patches; one bounded primary-endpoint contract;
  reorder intake/activation before bootstrap; or remove transparent rebind/pre-
  intake presentation.
- Recommendation: the bounded endpoint contract, reusing
  `primary_control_plane_attempts` with no second table or generic framework.
- User direction: Option 2 approved on 2026-08-12.
- Effect: amend Plan v4 only with exact owner/failure disposition, terminal
  pre-work startup failure, direct candidate confirmation, atomic semantic+
  presentation endpoint handoff, and capture/invalidation winner semantics.
  This does not authorize implementation, live retry, commit, integration,
  push, or qualification-pin change.
- Next action: fresh holistic soundness and adversarial verification review of
  the complete amended Plan v4.

### Plan Review epoch 12 / amended iteration 4 result

- Artifact: amended Plan v4 after the user-selected bounded primary-endpoint
  contract.
- Lenses: fresh independent soundness and adversarial verification, both bound
  to Plan SHA-256
  `17e1f3c95a90a1e8b6051c68f811166052e1966f6d1027f7538c9814e63df331`;
  neither consumed this ledger, prior outputs, memory, or review receipts.
- Verdict: RED/YELLOW. The soundness lens found one blocking candidate-resource
  lifecycle gap; the adversarial lens found one significant canonical-intake
  bypass.

#### E12-PLAN-011 — failed candidate attach can retain a live presentation

- Severity / scope: `blocking × in-scope`.
- Grounding: a candidate stock CLI/process/session can physically attach before
  its attach attempt cleanly finalizes or endpoint handoff commits. Failure then
  fenced the candidate but did not own/detach that non-current presentation, so
  stale traffic or the one-session host could block candidate two. The same gap
  applies when the already-attached startup presentation transfers to activation
  candidate one and that candidate later fails.
- Disposition: accepted. Reserve an exact candidate-owned presentation lease
  containing thread, generation, process/PTY, and transport-session identity.
  Any pre-handoff failure invalidates/fences and proves bounded teardown before
  retry. Unproven cleanup terminalizes `primary_start_failed` or `rebind_failed`
  immediately with actual attempt count and blocks retry/readiness.
- Lifecycle: `actioned` in Plan v4; verification re-review pending.

#### E12-PLAN-012 — startup token does not own one canonical initial input

- Severity / scope: `significant × in-scope`.
- Grounding: the draft allowed token consumption to create intake and later
  `admit_opaque_user_text(original)` to create the `direct_intake` input, leaving
  duplicate/mismatched authority. The explicit `--console-ui` launcher branch
  bypassed the token entirely.
- Disposition: accepted. One specialized transaction validates and consumes the
  clean token, atomically creates work item, unbound primary state, and exactly
  one canonical `user_inputs` row from its capture identity/verbatim payload at
  `input_seq = 1`, then returns that identity. No second admission is allowed.
  The governed launcher rejects/removes `--console-ui`; the console interface may
  remain only as a test double.
- Lifecycle: `actioned` in Plan v4; verification re-review pending.

### Amended Plan v4 propagation challenge

- Diagnosis: `local-design-flaw`, high confidence. E12-PLAN-011 and
  E12-PLAN-012 are required propagations of the already approved endpoint
  contract, not new product decisions.
- Candidate-resource options: attach-exception patch; bounded candidate
  presentation lease; or stop after every attach failure. Selected the bounded
  lease because it preserves the accepted sole retry only after proven cleanup
  and adds no table/generic cleanup framework.
- Initial-input options: keep intake and admission separate; atomic token consume
  into canonical input; or generalize every UI as a token producer. Selected
  atomic token consumption and exclusion of the console launcher because the
  governed MVP is explicitly stock-CLI; supporting another governed interface
  would be a separate scope decision.
- No new user disposition is required before this propagation. Mandatory user
  review remains after green Plan Review and before implementation.
- Next action: fresh holistic soundness and adversarial re-review of the complete
  Plan v4. No code, live retry, Git, integration, push, or qualification-pin
  action is authorized.

### Plan Review epoch 12 / amended iteration 4 second result

- Artifact: Plan v4 after candidate-presentation lease and canonical initial-
  input propagation, SHA-256
  `3602f11ea6b02ae2ef9006633eee3ce7c4c7414df3117a55c738a8df54c610f0`.
- Verdict: RED/YELLOW. Soundness found one blocking typed-handoff omission;
  adversarial review found one significant old-endpoint cleanup omission.

#### E12-PLAN-013 — initial request returns text without token identity

- Severity / scope: `blocking × in-scope`.
- Grounding: `PrimaryInterface.request` and native/scripted implementations
  return only raw text, so `WorkflowEngine.execute` had no exact handle for the
  startup token it must consume. Latest-token lookup, caller-text matching, or
  hidden controller state would be unplanned authority, and scripted tests would
  otherwise bypass the canonical input transition.
- Disposition: accepted. The initial request contract returns a typed capture
  handle containing exact token/capture identity plus bound verbatim text. Native
  returns the controller-created handle; scripted tests pre-create a valid test
  token through the same contract. Execute consumes only that handle. Raw-text-
  only, stale/wrong handle, mismatch, and alternate raw intake are rejected.
- Lifecycle: `actioned` in Plan v4; verification re-review pending.

#### E12-PLAN-014 — old current presentation teardown is outside rebind ownership

- Severity / scope: `significant × in-scope`.
- Grounding: candidate-owned cleanup did not own the pre-existing current stock-
  CLI/process/session. If old detach failed, candidate attach/retry could still
  start against the one-session host or race a live old endpoint.
- Disposition: accepted. Rebind first transfers the old current endpoint lease to
  episode cleanup, invalidates its generation, and proves exact process/PTY/
  transport absence before provisioning/attaching any candidate presentation.
  Failed proof terminalizes `rebind_failed` at candidate count zero with cleanup
  reason and spends no retry.
- Lifecycle: `actioned` in Plan v4; verification re-review pending.

### Second amended Plan v4 propagation decision

- E12-PLAN-013 and E12-PLAN-014 are exact interface/resource propagation of the
  user-approved endpoint contract. They add no user-visible recovery behavior,
  second table, or alternate UI.
- Next action: fresh complete soundness and adversarial verification re-review.
  Implementation and all live/Git/integration actions remain unauthorized.

### Plan Review epoch 12 / amended iteration 4 third result

- Artifact: Plan v4 after canonical startup-token consumption and candidate lease
  cleanup, SHA-256
  `3602f11ea6b02ae2ef9006633eee3ce7c4c7414df3117a55c738a8df54c610f0`.
- Verdict: RED/YELLOW. Soundness found one blocking missing token-handle handoff;
  adversarial review found one significant old-current-endpoint cleanup gap.

#### E12-PLAN-015 — startup token identity is not returned by the UI contract

- Severity / scope: `blocking × in-scope`.
- Grounding: `PrimaryInterface.request` and native/scripted implementations
  returned raw text, leaving `WorkflowEngine.execute` to invent latest-token,
  text-matching, or hidden-state selection. The relevant interface sites were not
  enumerated and scripted execution could not prove the same canonical intake.
- Disposition: accepted. The initial request returns a typed capture/token handle
  plus bound verbatim text. Native receives it from controller clean-finalization;
  scripted tests pre-create a production-contract test token. Execute consumes
  only that handle. Raw-text-only, stale/wrong handle, mismatch, and alternate
  intake fail.
- Lifecycle: `actioned` in Plan v4; verification re-review pending.

#### E12-PLAN-016 — old current endpoint can outlive rebind invalidation

- Severity / scope: `significant × in-scope`.
- Grounding: failed-candidate cleanup did not prove teardown of the old current
  stock-CLI/process/PTY/transport session before replacement attach. A lingering
  old session could block or race an otherwise healthy candidate.
- Disposition: accepted. Rebind first transfers the old endpoint lease to episode
  cleanup, invalidates/fences it, and proves exact process/session absence before
  candidate provisioning or attach. Failed proof terminalizes `rebind_failed` at
  candidate count zero with cleanup reason; candidate cleanup cannot compensate.
- Lifecycle: `actioned` in Plan v4; verification re-review pending.

### Third amended Plan v4 propagation decision

- Both findings are required typed-interface/resource ownership propagation of
  the approved endpoint contract and add no new user-visible behavior or retry.
- Next action: fresh complete two-lens Plan Review. Code/live/Git/integration
  authority remains closed.

### Plan Review epoch 12 / amended iteration 4 fourth result

- Artifact: typed startup-handle and old-endpoint-cleanup Plan v4, SHA-256
  `df9592d69c3432ea897a4c332e97ce2ed66724c90e22cd2c0864213767b88c71`.
- Verdict: RED/YELLOW. Soundness found one blocking orchestration-site omission;
  adversarial review found one significant post-intake typed-handoff omission.

#### E12-PLAN-017 — central binding orchestrator omitted from the site list

- Severity / scope: `blocking × in-scope`.
- Grounding: `WorkflowEngine.establish_primary_binding` currently registers/
  provisions candidates, confirms, and installs routing. Lower-level endpoint
  changes could leave that sequence installing before confirmation/handoff or
  provisioning before old-endpoint cleanup if this central caller stayed
  unchanged.
- Disposition: accepted. Make `establish_primary_binding` own old-lease cleanup
  before rebind provisioning, exact startup-lease transfer for activation,
  continuity/direct confirmation/attach with routing unchanged, completed
  handoff submission, and only then install-result consumption. Name its direct
  activation/rebind tests.
- Lifecycle: `actioned` in Plan v4; verification re-review pending.

#### E12-PLAN-018 — post-intake capture still hands consumers raw text

- Severity / scope: `significant × in-scope`.
- Grounding: clean-finalization created an admitted `input_seq`, but clarification
  and proposal-response paths could still receive raw text, throw detach after
  admission, re-present, or re-admit a duplicate input without linking the winner.
- Disposition: accepted. Every governed capture returns a typed result. Pre-work
  returns the token handle; post-intake returns exact admitted
  `input_id`/`input_seq`, generation, and bound text. Clean admission remains the
  winner across later detach; invalidation-first returns no handle. All consumers
  link the exact identity without another admission, including scripted tests.
- Lifecycle: `actioned` in Plan v4; verification re-review pending.

### Fourth amended Plan v4 propagation decision

- Both findings complete caller/interface propagation of already accepted
  endpoint and capture-winner obligations; no product/scope decision was added.
- Next action: fresh complete two-lens Plan Review. Implementation and all live/
  Git/integration authority remain closed.

### Plan Review epoch 12 / amended iteration 4 convergence

- Artifact: complete Plan v4 SHA-256
  `a0105dc680d5dd58b81b9f9d45e4cd250a1f73ccc9ff68c85dc32f58f61e379a`.
- Fresh holistic soundness verification: GREEN CLEAR.
- Fresh holistic adversarial verification: GREEN CLEAR.
- E12-PLAN-001 through E12-PLAN-018 are discharged by the complete current
  architecture and exact site/test propagation; none remains open.
- Plan Review is green before minimization. Implementation, live retry, Git,
  integration, push, and qualification-pin authority remain closed.
- Next action: subtractive `rfc-minimizer` pass over the green plan and aggregate
  finding history, followed by verification re-review if minimization changes a
  reviewed obligation or affected surface.

### Plan Review epoch 12 / minimization and closure

- `rfc-minimizer`: GREEN / MINIMAL on exact Plan SHA-256
  `a0105dc680d5dd58b81b9f9d45e4cd250a1f73ccc9ff68c85dc32f58f61e379a`.
- No blocking, significant, or acknowledged subtractive finding; no plan edit
  followed minimization, so no affected-surface verification re-review was
  required.
- GREEN review receipt issued at
  `.review-receipts/poc/PLAN.md.json`, binding the exact Plan hash to current HEAD
  `e045cf1e14277c2befc78a450201a6b19b33ba40`.
- Plan v4 is closed for mandatory user review. Closure does not authorize
  implementation, live retry, staging/commit, integration, push, or
  qualification-pin change.

### Closed Plan v4 user authorization

- User direction: `proceed` on 2026-08-12 after receiving the consolidated
  closed-plan summary.
- Authorized artifact: `poc/PLAN.md` SHA-256
  `a0105dc680d5dd58b81b9f9d45e4cd250a1f73ccc9ff68c85dc32f58f61e379a`,
  GREEN receipt bound to HEAD `e045cf1e14277c2befc78a450201a6b19b33ba40`.
- Effect: implementation against that exact plan may begin in the disposable
  worktree. Relevant non-destructive tests and the full Code Review Flow are
  authorized as ordinary implementation steps.
- Still unauthorized: live OpenAI/Codex qualification retry, staging/unstaging,
  commit, integration, push, main-repo change, or qualification-pin change.

## Code Review epoch 13

**Problem:** Demonstrate one real low-stakes coding outcome through the defining
voice-first operating model without turning the prototype's proof harness into
the product.
**In scope:** One project context, one active user-level work item, one
accountable logical primary, bounded role agents, a primary-owned SQLite work
ledger, bidirectional execution checkpoints and asks, PM-style agent monitoring,
planned worker context handoff, one automatic physical-primary session rebind,
one separately accepted intent revision and independently assessed,
user-authorized clean attempt restart, proportional plan review with a three-
version automatic-iteration checkpoint, correctness and cohesion code review,
one fresh native Codex hard-review gate, one immutable candidate commit, first-
class candidate-bound code findings, final validation and closure, risk-
proportional independent semantic confirmation for positive restart/integration
authority and plan implementation start, one controller-owned bounded
notification-window lifecycle for exact App Server model-turn action authority,
and explicit user approval before the disposable repository is integrated,
followed by user review of the genuine pending authoritative-host ITD against
the completed PoC evidence. Every governed semantic transition is covered by
one closed producer-to-effect authority inventory, including explicit
accountable-primary adoption of delegated results and checkpointed plan-review
convergence.
**Out of scope:** Concurrent unrelated user workstreams, production deployment,
hostile or simultaneous clients, controller/database crash injection and
general automatic recovery beyond the bounded physical-primary rebind,
exactly-once external effects, comprehensive race or fault-tolerance proof,
natural-language classification in Python, a closed approval phrase grammar,
an exhaustive P01-P18 runtime proof matrix, complete source/executable
provenance, canonical full-database projection proof, a special terminal PASS
process, the full project-brain/inbox roadmap, automated finding-pattern
assessment, backtesting evaluation, and model/cost optimization. Also out of
scope is a generic authorization framework or a new first-class plan-finding
subsystem; the prototype uses exact transition-specific contracts and keeps
plan findings in immutable review results. The governed executable supports the
ordinary stock-CLI primary only; `ConsolePrimaryInterface` remains a test
double, and `--console-ui` is rejected/removed rather than becoming a second
governed intake protocol. A Byzantine App Server that deliberately relabels an
action as belonging to an unrelated valid thread is also outside the
controller's provable identity boundary.

### Review start

- Review epoch: 13; substantive-iteration counter: 0.
- Artifact: current complete dirty-tree implementation against accepted Plan v4
  SHA-256 `a0105dc680d5dd58b81b9f9d45e4cd250a1f73ccc9ff68c85dc32f58f61e379a`
  at HEAD `e045cf1e14277c2befc78a450201a6b19b33ba40`.
- Preserved staged baseline diff SHA-256:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Initial independent evidence: 307 Python tests passed with one documented
  environment-dependent skip; Go transport tests passed; changed Python files
  compile; `git diff --check` is clean; main repository remains clean.
- Current lane: Phase 1 implementation-quality discovery. The discovery
  reviewer receives the scope block, current code/diff, Plan v4, and test
  evidence, but not this ledger, prior findings, claimed fixes, or root-cause
  history.
- No Code Review findings or convergence checkpoint recorded yet.
- Authority remains closed for live qualification, staging/unstaging, commit,
  integration, push, main-repo changes, and qualification-pin changes.

### Phase 1 discovery result / iteration 1

- Source: independent `code-review-analyst` discovery over the complete current
  dirty tree, without review-ledger or prior-finding context.
- Verdict: blocked by two `blocking × in-scope` findings.
- Active-epoch pattern evaluation before fixes: no convergence trigger fires.
  The findings touch different already-specified authority transitions, neither
  repeats a claimed epoch-13 fix, and no requirement, ownership, or scope
  ambiguity was reported.

#### E13-CR-001 — generic completion invents primary acceptance

- Review epoch / iteration: `13 / phase-1.1`.
- Source: `code-review-analyst` discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/kernel.py:5904`; consumer at `poc/prototype.py:2928`.
- Statement: `complete_run()` accepts any active run and defaults
  `accepted_by` to `primary` without validating role, owner, or a mechanical
  exception. `WorkflowEngine.finish_run()` uses that fallback for controller-
  owned validation/native-review runs, inventing primary attribution while
  retaining a generic delegated-run bypass.
- Scenario: a controller-owned validation completes without agent adoption;
  the fallback writes `accepted_by='primary'`, completes the run, and lets
  validation/closure consume a false authority record. The same path can
  complete an ordinary delegated run without exact primary adoption.
- Suspected surface: terminal role-outcome authority and the explicit
  controller-owned mechanical exceptions.
- Suggested resolution: delegated roles complete only through exact adoption;
  add one narrow role/owner-validated mechanical completion transition for
  validator and native-review execution with truthful controller identity.
- Fix applied: replaced the caller-visible snapshot / later settlement / later
  retirement sequence with one controller-owned `finalize_model_turn_window`
  operation for role, semantic-primary, and prompt-only control subjects. Under
  notification serialization it validates the exact final snapshot and receipt
  frontier, invokes the subject-specific durable transaction, persists
  `clean_receipt_frontier` on role/primary/control settlement, retires the
  in-memory window, and only then returns the result. Runtime evidence reads are
  private and provisional; governed eligibility cannot use them. Timeout,
  rejected-turn, interrupted-turn, and happy-path callers use the same boundary.
  The old snapshot/retire/complete APIs and production choreography were
  removed; scripted fixture settlement is isolated in test-only support.
- Lifecycle: `actioned`, pending the user-directed fresh holistic Code Review
  restart and final Phase 3 discovery evidence.

#### E13-CR-002 — failed turn creation registers a fictitious `None` turn

- Review epoch / iteration: `13 / phase-1.1`.
- Source: `code-review-analyst` discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:2812`; consumer at `poc/prototype.py:5605`.
- Statement: `_journaled_request()` registers a mapping after classified turn
  mutations even when the App Server returned an error or omitted the exact
  turn identity, stringifying the missing value to `None`. The stock-CLI
  handler treats it as a created turn, binds the prepared control-plane attempt
  to that fictitious identity, and waits for an impossible completion.
- Scenario: App Server rejects a presentation/capture `turn/start`; the failed
  operation still inserts a `None` turn mapping, the handler binds and waits up
  to the 900-second worker timeout, and the owner-specific immediate failure
  disposition is delayed behind an impossible identity.
- Suspected surface: journaled mutation result validation and control-plane
  presentation/capture turn ownership.
- Suggested resolution: publish a turn mapping only after a successful response
  with validated non-empty thread/turn strings; immediately abort/fence the
  prepared control-plane attempt/window on error or missing identity, and pass
  the validated created-turn result explicitly rather than discovering it by a
  global-map diff.
- Fix applied: none.
- Lifecycle: `open`.

### Phase 1 pre-fix resolution decisions

- E13-CR-001 problem: preserve accountable adoption while retaining the two
  accepted mechanical exceptions. Options considered: require a caller label
  (small but still forgeable); send mechanical facts through model adoption
  (truthful but contradicts Plan v4); or use a closed role/owner-validated
  mechanical transition and require adoption everywhere else. Selected the
  third option because it directly implements the accepted authority inventory
  without new state or behavior. Repair altitude: `implementation`.
- E13-CR-002 problem: prevent failed/malformed turn creation from becoming
  durable turn identity. Options considered: filter `None` in the consumer
  (leaves global inference and split ownership); rely on timeout (violates the
  existing immediate failure disposition); or validate at the journal boundary,
  abort the prepared owner there, and hand the exact result directly to the
  consumer. Selected the third option. Repair altitude: `implementation`.
- Neither fix adds or expands durable state, authority, lifecycle, protocol,
  operator surface, or product behavior; no resolution challenge or Plan
  amendment is required.

### Phase 1 iteration 1 fixes applied

- E13-CR-001 lifecycle: `actioned`. Removed the generic/default completion
  transition. Ordinary delegated runs now require exact adopted terminal output.
  The only non-adoption completion is a closed controller-owned transition for
  `validator` and `native-review-surface`, gated by exact role, controller owner,
  fixed-transition authority, non-empty/current authority identity, run-context
  hash, assignment, and absence of an unsettled role turn; it records the stable
  controller owner rather than fabricated primary attribution.
- E13-CR-002 lifecycle: `actioned`. Journaled turn mutations publish an exact
  mapping only after a successful response with validated non-empty identities.
  Error or missing/malformed identity immediately fences the prepared control-
  plane attempt/window, creates no mapping, and returns no created-turn result.
  The presentation/capture handler consumes the explicit validated result and
  never binds or waits when it is absent.
- Changed by the repair batch: `poc/kernel.py`, `poc/controller.py`,
  `poc/prototype.py`, `poc/test_kernel.py`,
  `poc/test_authoritative_kernel.py`, `poc/test_controller.py`, and
  `poc/test_prototype.py`.
- Evidence: five focused regressions passed; 223 relevant module tests passed;
  full discovery passed 312 tests with one environment-dependent skip; Go tests
  passed; `git diff --check` is clean. Plan and staged-baseline hashes remain
  exact.
- Active-epoch substantive-iteration counter: 1.
- Post-fix convergence evaluation: no threshold or pattern trigger fires. The
  repairs implement two accepted local obligations without sibling-surface
  expansion, repeat, new P1, or requirement/ownership ambiguity.
- Continuation token: phase `phase-1`; boundary `post-fix`; lane
  `verification`; required next action `targeted verification of E13-CR-001 and
  E13-CR-002, followed by a fresh holistic Phase 1 discovery pass regardless of
  targeted result`.

### Phase 1 targeted verification result

- Source: original `code-review-analyst`, verification lane.
- Result: E13-CR-001 and E13-CR-002 remain `open`; both are marked
  `repeated` after an incomplete claimed fix.
- E13-CR-001 verified the governed adoption and mechanical completion gates but
  found `DurableKernel.seed_test_completed_run` still exposes unrestricted
  completion on the production kernel class. An ordinary active planner can be
  completed through it and then consumed by `record_plan` without adoption.
- E13-CR-002 verified mapping validation, immediate durable fencing, and direct
  created-turn handoff but found the owning capture/attach waiter is not released.
  The handler clears `capture_subject`, receives no created turn, returns without
  queue output, and `_capture_user_input` waits until an unrelated detach.
- All five focused tests pass, but the second finding's test proves only no
  bind/wait inside the handler, not termination of the actual capture waiter.

### Open convergence checkpoint E13-CC-001

- Review epoch: 13.
- Triggered at: `phase-1.1 targeted verification`.
- Continuation:
  - phase: `phase-1`
  - boundary: `pre-fix`
  - lane: `verification`
  - required next action: `disposition and correct the incomplete propagation
    of E13-CR-001 and E13-CR-002, then targeted verification and fresh holistic
    discovery`
- Trigger: both P1s repeated after their claimed fix.
- Evidence clusters:
  - Completion authority is closed in intended callers but remains bypassable
    through a test-named method on the production authority class.
  - Control-plane failure is durably closed at the controller/kernel owner but
    does not settle the presentation/capture consumer that is blocked on its
    result.
  - Both repairs validated the immediate transition while leaving another
    public/consumer boundary able to contradict the claimed end-to-end
    invariant.
- Requirement/invariant ambiguity: none reported; Plan v4 already requires
  ordinary adoption, explicit mechanical exceptions, owner-specific failure,
  and no blocked successor/capture path.
- Ownership/boundary changes implicated: production kernel versus test fixture
  construction; durable control-plane owner versus native-interface waiter.
- Reviewer disagreements: none.
- Diagnosis: `local-design-flaw`. Independent follow-up diagnosis found that
  Plan v4 states the desired clean-finalization invariant but leaves two
  load-bearing architecture seams ambiguous: whether `receipt frontier` means
  largest assigned receipt or largest contiguous fully routed/applied receipt,
  and which identity-bound owner must choose exactly one terminal `finalize` or
  `abort/fence` disposition after a runtime returns provisional evidence but
  before engine persistence/finalization completes. The exceptional repair
  implemented against those incomplete contracts therefore began after the true
  receipt boundary and ended before the true failure-ownership boundary.
- Action: ask the user to choose between (a) a narrow Plan amendment for those
  two seams, full Plan Review and fresh authorization, followed by a targeted
  notification/finalization subsystem rewind and Code Review restart; or (b)
  stop/defer the PoC. Do not fix, rewind, or dispatch another review before the
  decision. Preserve the implementation-start snapshot, Plan/ledger history,
  and all regression scenarios. If the targeted rebuild later produces another
  blocking finding in this same receipt/finalization/ownership cluster, stop the
  PoC rather than authorize another repair loop.
- Status: `actioned`.
- Status evidence: the user selected the narrow Plan amendment plus targeted
  subsystem rewind. This authorizes Plan construction and Plan Review only at
  the current boundary. Targeted implementation rewind/reimplementation remains
  blocked until the amended Plan reaches GREEN and the user reviews its summary
  and gives fresh implementation approval.

The open checkpoint blocks another ordinary fix/review iteration, phase exit,
RFC implementation closure, and all Git/integration actions until diagnosis and
the recorded action are complete.

### E13-CC-001 convergence diagnosis and action

- Diagnosis: `local-design-flaw`, high confidence; one root cluster with two
  sibling boundary violations.
- Root invariant: an authority-bearing transition is closed only when every way
  to publish its state proves required provenance, and every exact consumer
  receives one identity-bound terminal success or failure before ownership is
  cleared.
- Evidence: `seed_test_completed_run` still publishes trusted completion without
  adoption provenance; failed capture clears its owner but publishes no terminal
  result to the already-selected capture/attach waiter.
- Repair altitude: `implementation`. Plan v4 already requires the end-to-end
  producer/effect closure, test/production separation, typed capture settlement,
  and owner-specific control-plane failure behavior.
- Completion options: preserve a guarded kernel seeder (rejected: production
  bypass remains); construct every fixture through full adoption (valid but
  disproportionate); or remove the method from `DurableKernel` and centralize
  schema-level setup in test-only support. Selected the test-only helper.
- Waiter options: use generation detach as the only signal (valid but broad and
  conflates owner dispositions); or publish one private identity-bound terminal
  failure to the exact selected queue, exhaustively reject it at attach/capture
  consumers, and then execute the existing owner-specific disposition. Selected
  typed exact-waiter failure, with any required invalidation/teardown remaining
  owned by `startup_stop`, `candidate_failure`, or `active_binding_fence` rather
  than by the queue protocol itself.
- Semantic-surface delta: remove one production method; add one test-only helper;
  add one private terminal failure variant at the two existing queues. No new
  SQLite state, authority class, generic lifecycle, public PrimaryInterface
  result, or user-visible choice.
- Plan amendment / user decision: none required while the implementation stays
  within this bounded shape.
- Action: apply both boundary corrections as one cluster; then start review
  epoch 14 at counter zero and restart Code Review Flow from Phase 1 with the
  cumulative ledger. A clean restarted Phase 3 discovery result is required to
  resolve this checkpoint. A second convergence trigger for this same cluster
  must escalate under the one-restart cap.
- Checkpoint status: `actioned`.

### E13-CC-001 action completed / review epoch 14 start

- Removed the production `DurableKernel` fixture-completion method and migrated
  all 42 fixture callers to `poc/test_support.py`, a test-only schema constructor.
- Added a private identity-bound success/failure terminal union at the existing
  attach/capture queues. Failure may publish only after durable fencing and
  before selected subject ownership clears. Exact consumers validate attempt,
  generation, thread, owner, and disposition; stale terminals are ignored, and
  current startup/candidate/active failures route through their existing stop,
  cleanup/retry, or detach/fence/rebind behavior.
- No durable schema, authority class, generic lifecycle, public PrimaryInterface
  result, or user-visible behavior was added.
- Repair evidence: focused cluster `6/6`; relevant modules `226/226`; full
  Python discovery `315 passed, 1 environment-dependent skip`; Go and py_compile
  passed; diff-check clean; exact Plan and staged-baseline hashes preserved.
- E13-CR-001 and E13-CR-002 lifecycle: `actioned`, pending independent restarted
  review evidence.
- Review epoch: 14; substantive-iteration counter: 0.
- Restart boundary: Code Review Flow Phase 1 holistic `discovery`, with this
  cumulative ledger retained by the orchestrator but not passed to the discovery
  reviewer.
- E13-CC-001 remains `actioned`. Only a clean restarted Phase 3 discovery gate
  may mark it `resolved`.

### Review epoch 14 / Phase 1 discovery result

- Source: fresh independent `code-review-analyst` discovery over the complete
  dirty tree without ledger, prior findings, claimed fixes, or convergence
  diagnosis.
- Evidence: 315 Python tests passed with one environment-dependent skip; Go and
  py_compile passed. No additional blocking or significant finding was found.
- E13-CR-001 and E13-CR-002 lifecycle: `resolved` by fresh holistic discovery;
  their exact production/test and waiter boundaries were audited without the
  prior claims being supplied.

#### E14-CR-001 — snapshot-clean windows stop observation before settlement

- Review epoch / iteration: `14 / phase-1.1`.
- Source: fresh `code-review-analyst` discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:1797`, `poc/controller.py:1850`,
  `poc/prototype.py:1597`, `poc/prototype.py:2025`, and
  `poc/prototype.py:7942`.
- Statement: role and semantic-primary notification windows become
  `snapshot_clean`, but receipt observation accepts only `binding`, `active`,
  and `turn_terminal`. Their durable kernel settlement and retirement occur in
  later separate calls, so an exact lifecycle receipt in that interval is
  silently ignored.
- Scenario: App Server returns a terminal snapshot; the controller marks the
  window `snapshot_clean`; an exact `item/started` arrives before durable
  settlement; the observer ignores it; the role output may become eligible/
  adopted or the primary result may authorize downstream state without that
  action being recorded or settled.
- Suspected surface: final notification frontier to durable subject settlement
  and window retirement.
- Suggested resolution: one controller-owned role/primary finalization barrier
  that holds the notification lock continuously from final snapshot validation
  through matching durable settlement and retirement, with interleaving tests
  for both subject kinds. Prompt-only control finalization already has this
  atomic shape and is unaffected.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `spawned-sibling` of the E13-CC-001 root invariant. It is a
  third surface where the immediate owner is clean but the next consumer/
  publication boundary remains open.

### Second convergence stop E14-CC-001

- Review epoch: 14.
- Triggered at: `phase-1.1 discovery` after the convergence-directed restart.
- Continuation:
  - phase: `phase-1`
  - boundary: `pre-fix`
  - lane: `discovery`
  - required next action: `obtain explicit user disposition for the same-cluster
    finding after the one-restart cap; if authorized, apply only the selected
    action and restart review as directed`
- Trigger: a new P1 appeared in a sibling boundary of the same producer-to-
  consumer closure cluster after the one permitted convergence-driven restart.
- Evidence cluster: completion provenance, control-plane waiter settlement, and
  now notification-snapshot settlement each made the immediate transition clean
  while leaving the next authority consumer/publication boundary able to
  contradict the end-to-end invariant.
- Diagnosis: `local-design-flaw`, inherited and newly evidenced; Plan v4 already
  specifies the required closure, while implementation remains incomplete at a
  further site.
- Action: implement the user-selected bounded structural correction: one closed
  controller-owned clean-finalization primitive for role, semantic-primary, and
  primary-control-plane subjects. The operation must keep final receipt
  validation, the subject-specific durable transition, in-memory retirement,
  and consumer visibility inside one serialized boundary; it must not add a
  durable notification-recovery protocol or preserve caller-local snapshot /
  settle / retire choreography. Then begin a new review epoch and restart Code
  Review at Phase 1.
- Status: `actioned`.
- Status evidence: the user selected Option 2 after an independent chronological
  convergence assessment distinguished the notification transaction cluster
  from the E13 provenance and waiter-propagation findings. The selected repair
  altitude is `implementation`: Plan v4 already requires this exact common
  clean-finalization boundary, and the existing control-plane path demonstrates
  it without a Plan amendment. No rewind, live run, Git mutation, integration,
  or broader recovery design was authorized.

The one-restart cap forbids another automatic same-cluster repair. E13-CC-001
remains `actioned`; E14-CC-001 is `actioned`; Phase 2, Phase 3, RFC closure, Git,
integration, push, and live qualification remain blocked.

### User-directed E14 repair completion / review epoch 15 restart

- Repair evidence: focused controller/kernel/prototype coverage `230/230`;
  complete offline Python discovery `319 passed, 1 environment-dependent skip`;
  Go, py_compile, and diff-check passed.
- Structural evidence: all three subject kinds share one controller-owned
  finalizer; role and primary settlement require and atomically persist a clean
  receipt frontier; production has no snapshot-clean state or separate
  retirement/complete call. Barrier tests cover receipt-before-transaction,
  transaction failure, retirement-before-success, and the exact concurrent
  role/primary transaction-to-retirement interval.
- Integrity evidence: accepted Plan hash remains
  `a0105dc680d5dd58b81b9f9d45e4cd250a1f73ccc9ff68c85dc32f58f61e379a`;
  preserved staged binary diff hash remains
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Plan deviation: none.
- Review epoch: 15; substantive-iteration counter: 0.
- Restart boundary: Code Review Flow Phase 1 holistic discovery. The cumulative
  ledger remains with the orchestrator and is excluded from discovery input.
- E14-CR-001, E14-CC-001, and the earlier E13-CC-001 remain `actioned`; only a
  clean restarted Phase 3 discovery result may resolve the checkpoints.

### Review epoch 15 / Phase 1 discovery result

- Source: fresh independent `code-review-analyst` discovery over the complete
  code-change artifact and Plan context. It did not receive the ledger, prior
  findings, claimed repair, or convergence diagnosis.
- Validation evidence: `319 passed, 1 environment-dependent skip`; Go and
  py_compile passed. The only checkout-wide diff-check warnings were the known
  vendored Gorilla documentation trailing blanks.

#### E15-CR-001 — receipt numbering can precede lifecycle routing and finalization

- Review epoch / iteration: `15 / phase-1.1`.
- Source: fresh `code-review-analyst` discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:756` and masked test shape at
  `poc/test_controller.py:2117`.
- Statement: `_read_upstream` increments `upstream_receipt_sequence` under
  `notification_lock`, releases the lock, and only then routes/applies the
  lifecycle envelope. Clean finalization can therefore settle at a frontier
  that already includes an unrouted owned receipt, retire the window, and let
  later routing silently ignore that receipt. The new barrier helper masks this
  exact production gap by holding the lock across both numbering and routing.
- Scenario: a late exact action start receives sequence N and pauses before
  routing; finalization settles at frontier N and exposes eligibility; routing
  resumes after retirement and drops the disqualifying action.
- Suspected surface: definition and serialization of the authoritative routed
  receipt frontier.
- Suggested resolution: serialize accepted-receipt routing with the frontier,
  or introduce a distinct contiguous routed watermark used by finalization;
  carry the final `thread/read` response frontier through that boundary and add
  a production-reader barrier test.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `repeated` same notification-finalization cluster after the
  user-authorized structural repair; it demonstrates that the repaired window /
  SQLite boundary began one step after the true receipt authority boundary.

#### E15-CR-002 — control-plane deadlines do not gate authority release

- Review epoch / iteration: `15 / phase-1.1`.
- Source: fresh `code-review-analyst` discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/kernel.py:5043`, `poc/prototype.py:5800`, and
  `poc/prototype.py:7914`.
- Statement: `primary_control_plane_attempts.deadline_ns` is persisted but not
  enforced by finalization, while presentation and binding callers may wait on
  the longer generic worker timeout. An expired prompt-only control attempt can
  still settle and release startup, capture, binding, or endpoint authority.
- Scenario: a capture acknowledgement completes after its five-minute durable
  deadline but within the fifteen-minute worker wait; finalization accepts it
  and releases an input/token. The reviewer reproduced post-deadline acceptance
  directly against the durable kernel.
- Suspected surface: control-plane temporal authority and owner-specific failure
  disposition.
- Suggested resolution: enforce the deadline in caller waits and the serialized
  kernel authority boundary; expiration fences through the existing owner
  disposition before release. Cover every owner class at the boundary.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: independent temporal-authority sibling, not evidence that the
  notification transaction itself is wrong.

#### E15-CR-003 — detach can override an already released capture handle

- Review epoch / iteration: `15 / phase-1.1`.
- Source: fresh `code-review-analyst` discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:6476`.
- Statement: native capture checks `presentation_detached` before consuming an
  already clean-finalized exact terminal. Detach can therefore override the
  durable capture winner between queue publication and consumer wake-up.
- Scenario: finalization queues `released_input`; teardown sets detached; the
  consumer raises before dequeuing. Re-presentation can admit a second input
  while the first winning handle remains stranded and blocks ordered delivery.
- Suspected surface: capture-finalization winner to exact consumer handoff.
- Suggested resolution: resolve the exact attempt/generation terminal or
  durable attempt state before treating detach as failure; add the finalization
  to queue to detach to consumer interleaving.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: independent endpoint/waiter publication sibling of the earlier
  capture-versus-detach ownership work.

#### E15-CR-004 — post-return role failures do not fence the runtime-owned subject

- Review epoch / iteration: `15 / phase-1.1`.
- Source: fresh `code-review-analyst` discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:1990` and `poc/prototype.py:8223`.
- Statement: a runtime-enforced role result returns while its shared window
  remains open for engine settlement. If later model-call persistence or role
  consumption fails, `typed_call` fences only `pre_reserved_role_turn_id`, which
  is `None` under runtime enforcement; the actual role turn/window remains open.
- Scenario: `record_model_call` fails after a valid runtime result; propagation
  performs no exact runtime-subject abort, leaving the run/worktree blocked
  without the required durable fence and retirement.
- Suspected surface: provisional result owner to engine finalization/failure
  settlement.
- Suggested resolution: one runtime-owned post-return abort keyed by call ID
  must fence and retire the exact subject on every post-return failure or
  interruption, with fault injection across persistence and finalization sites.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `spawned-sibling` in the same end-to-end notification owner /
  finalization cluster; the success boundary was closed but its pre-finalization
  failure boundary remained caller-local.

#### E15-CR-005 — final snapshot action state is not cross-checked

- Review epoch / iteration: `15 / phase-1.1`.
- Source: fresh `code-review-analyst` discovery.
- Severity / scope: `significant × in-scope`.
- Location: `poc/controller.py:1842`.
- Statement: final snapshot validation compares action identity and type but not
  the canonical terminal state, so contradictory notification and `thread/read`
  outcomes can settle.
- Scenario: notifications say a command completed while the final snapshot says
  failed; validation retains the notification action as clean and permits
  settlement.
- Suspected surface: final snapshot contradiction check.
- Suggested resolution: canonicalize each snapshot action, reject duplicates,
  and require its terminal state to equal notification-derived state for role
  and primary subjects.
- Fix applied: none.
- Lifecycle: `open`.

### Third convergence stop E15-CC-001

- Review epoch: 15.
- Triggered at: `phase-1.1 discovery` before any new fix.
- Continuation:
  - phase: `phase-1`
  - boundary: `pre-fix`
  - lane: `discovery`
  - required next action: `obtain a new convergence diagnosis and explicit user
    disposition; do not apply another same-cluster repair automatically`
- Trigger: after the user-authorized exceptional structural repair and fresh
  restart, E15-CR-001 repeats the notification-finalization P1 at the upstream
  receipt-routing boundary and E15-CR-004 exposes a sibling failure-finalization
  gap. This satisfies the previously recorded rewind stop condition.
- Evidence clusters:
  - receipt read / numbering / routing / final snapshot / durable settlement /
    retirement / result visibility still do not form one closed authority
    transaction;
  - runtime role result ownership remains split between the model runtime and
    engine when post-return persistence fails;
  - control deadline and capture-detach findings are blocking but independently
    clustered and must not be overfit into the notification diagnosis.
- Diagnosis: `pending`.
- Action: `pending`.
- Status: `open`.

E15-CC-001 permits only the selected Plan amendment and its Plan Review. It
continues to block code fixes/rewind, Code Review, RFC closure, Git, integration,
push, and live qualification until reviewed-Plan authorization and the recorded
restart evidence complete.

### User-selected E15 Plan amendment / Plan Review iteration 1

- User disposition: Option 1 — amend and independently review the Plan, then
  rewind/reimplement only the receipt-through-finalization subsystem after a
  fresh implementation approval. No code rewind or implementation is authorized
  by this disposition.
- Initial amended-Plan hash supplied to reviewers:
  `17b78f4f3bf7fb71d3861d90ccebe9f721bd88e44205953d58f3dbc5a3c8e22a`.
- Reviewers: independent `rfc-reviewer`, independent `rfc-red-team`, and
  conditional `ux-reviewer`; each received the complete immutable Plan and scope
  without this ledger.
- Iteration-1 verdict: `RED`.

#### E15-RFC-001 — Plan review closure was not mechanically severity/scope-safe

- Severity / scope: `blocking × in-scope`.
- Statement: a primary synthesis could acknowledge or reject a blocking or
  significant in-scope finding and still close the plan; closure was not derived
  from the current review batch and typed severity/scope dispositions.
- Resolution: the Plan now defines a closed compatibility matrix, forbids a
  dirty batch from closing, and requires a fresh independent same-version batch
  after a grounded invalidity rejection. Controller code validates typed
  combinations/completeness only; no NLP or new plan-finding table is added.
- Lifecycle: `actioned`, pending fresh full-Plan verification.

#### E15-RFC-002 / E15-RT-003 — rebind budget was bounded only per episode

- Severity / scope: `blocking × in-scope` (`rfc-reviewer`) and `significant ×
  in-scope` (`rfc-red-team`).
- Statement: the candidate retry count was bounded inside an episode, but
  repeated physical losses could create multiple successful replacement episodes
  for one work item despite the stated one-rebind proof.
- Resolution: one work-item-level automatic-rebind allowance is derived from
  durable history and consumed before the first replacement cleanup. Initial
  activation does not consume it. A later trigger fences and enters terminal
  no-primary settlement without another episode, candidate, lease, or retry.
- Lifecycle: `actioned`, pending fresh full-Plan verification.

#### E15-RT-001 — `thread/read` did not provide a causal notification close

- Severity / scope: `blocking × in-scope`.
- Statement: a contiguous routed frontier proves processing only through a
  sampled point; without a provider ordering contract, a same-turn lifecycle
  notification could still arrive after `thread/read` and after eligibility.
- Resolution: ordinary execution is pinned to `codex-cli 0.147.0` and its exact
  official tagged App Server v2 lifecycle contract. Exact `turn/completed`, not
  `thread/read`, is the causal close after every item lifecycle; `thread/read` is
  only output/snapshot contradiction validation. Startup records the exact
  version, tagged source/content identity, and bounded qualification. Drift,
  missing evidence, missing close, or same-turn lifecycle after close blocks.
- Lifecycle: `actioned`, pending fresh full-Plan verification.

#### E15-RT-002 — confirmation pending lacked a governed correction producer

- Severity / scope: `blocking × in-scope`.
- Statement: the Plan promised that a newer user correction could invalidate
  positive authority, while the physical one-response gate could already be
  closed and unable to durably admit that correction before effect start.
- Resolution: the governed stock-CLI presentation remains listening during
  positive confirmation. The first opaque capture reserves an exact correction
  attempt against the approval epoch through the same writer as effect start;
  reservation blocks the effect, clean admission invalidates it, and capture
  failure remains no-effect with explicit re-presentation. If effect start wins
  first, later input is ordinary next direction. Program code never interprets
  the text.
- Lifecycle: `actioned`, pending fresh full-Plan verification.

#### E15-UX-001 — recovery/capture truth was not presented as ordered user state

- Severity / scope: `significant × in-scope`.
- Statement: durable capture/rebind mechanics did not specify how the user sees
  listening pause, stored-but-not-accepted text, no effect, re-presentation,
  reopening, and exactly-once admission.
- Resolution: the Plan now fixes those presentation states and their order for
  native PTY/TUI behavior and deterministic tests, including distinct pre-work
  stored-versus-accepted status.
- Lifecycle: `actioned`, pending fresh full-Plan verification.

Iteration-1 corrections also close the reviewer-noted reader-failure sibling:
one notification-serialized operation enumerates every non-retired subject and
one kernel transaction durably fails/fences that set before waking waiters; a
transaction failure is fatal no-progress, never partial eligibility.

Corrected Plan hash for iteration-2 full verification:
`0456e555b2d326e7083d4a1c63deea2d054649e13cd9efd1ba0c037fb7087694`.
The preserved staged binary diff hash remains
`0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 Plan Review iteration 2 correction

- Reviewed Plan hash:
  `0456e555b2d326e7083d4a1c63deea2d054649e13cd9efd1ba0c037fb7087694`.
- `rfc-reviewer`: `RED`; prior E15-RFC-001 and E15-RFC-002 resolved.
- `ux-reviewer`: `GREEN`; E15-UX-001 resolved with no regression after the
  durable closed-turn lookup addition.

#### E15-RFC-003 — two stale sites permitted action terminality after causal close

- Severity / scope: `blocking × in-scope`.
- Statement: the common contract correctly requires every complete item
  lifecycle before exact `turn/completed`, but one work-plan bullet and one test
  inventory bullet still retained the superseded design in which a previously
  started action could terminalize after turn terminal.
- Resolution: both sites now require terminal notification before causal close;
  any later start or terminal receipt follows the provider-contract fail-closed
  path. The durable closed thread/turn lookup remains after live-window
  retirement.
- Lifecycle: `actioned`, pending fresh complete-Plan verification.

Corrected Plan hash for the next verification:
`262d3d5c62e6e9df5453ca0660cfdb321e767461abe76d6664d65fe542dbbe76`.

### E15 Plan Review iteration 3 / Phase 1 convergence

- Frozen Plan hash:
  `262d3d5c62e6e9df5453ca0660cfdb321e767461abe76d6664d65fe542dbbe76`.
- `rfc-reviewer`: `GREEN`; E15-RFC-001, E15-RFC-002, and E15-RFC-003
  independently verified resolved; no new findings.
- `rfc-red-team`: `GREEN CLEAR`; E15-RT-001, E15-RT-002, and E15-RT-003
  independently verified resolved; reader-wide failure, finalization ordering,
  post-retirement late-lifecycle recognition, and correction/effect races passed
  adversarial assessment; no new findings.
- `ux-reviewer`: `GREEN CLEAR`; E15-UX-001 remains resolved and the final
  causal-close wording introduces no UX regression; no new findings.
- Phase 1: converged within the three-iteration cap.
- Code rewind/implementation remains unauthorized and blocked pending Phase 2
  minimization, terminal Plan Review closure, and fresh user approval.

### E15 Plan Review Phase 2 / subtractive minimization

- Reviewed frozen Plan hash:
  `262d3d5c62e6e9df5453ca0660cfdb321e767461abe76d6664d65fe542dbbe76`.
- `rfc-minimizer` verdict: `EXCESS`; no `blocking` findings, four
  `significant × in-scope` subtraction candidates, and one `significant ×
  adjacent` subtraction candidate.
- Per the Plan Review Flow, no automatic Phase 3 is triggered without a
  blocking minimization finding. The user authorized the accountable primary to
  decide purely technical/internal simplifications while reserving material
  accepted-behavior changes for user disposition.

#### E15-MIN-001 — separate six-action/five-minute work-quantum subsystem

- Severity / scope: `significant × in-scope`.
- Suggested subtraction: remove action/time frontiers, budget-specific failure
  states, interrupt-race recovery turn, and dedicated tests while retaining one
  work turn per primary direction, proactive checkpoints, common turn/action
  settlement, and primary adoption.
- User decision: replace the interrupting work quantum with non-blocking routine
  observation. The controller schedules a configurable low-cost, read-only
  observer on cadence or durable progress events over an immutable evidence
  frontier. The observer returns a typed evidence-backed assessment to the
  primary but cannot message, stop, pause, correct, adopt, mutate, or authorize
  the worker. Only a separate currentness-checked primary decision may intervene;
  observer failure never stops work and is surfaced when repeated.
- Resolution: remove action/time frontiers, budget-specific interrupt/failure
  states, recovery turns, and dedicated work-quantum tests. Retain proactive
  worker inflection reports, ordinary turn/action settlement, primary adoption,
  and the new Decision 9 observer contract.
- Lifecycle: `actioned`, pending holistic verification of the amended Plan.

#### E15-MIN-002 — versioned/digest-bound restart-predicate policy object

- Severity / scope: `significant × in-scope`.
- Suggested subtraction: retain the three exact accepted predicates, per-
  predicate assessor evidence, primary recommendation, user authority, and
  independent co-sign; remove policy version/source/content digest/stale-policy
  lifecycle and exhaustive malformed-object matrix.
- Resolution: subtraction accepted. The amended Plan retains the three exact
  predicates, one specific-evidence result for each, primary recommendation,
  user authority, and independent co-sign; it removes the version/source/digest
  and stale-policy lifecycle/matrix.
- Lifecycle: `actioned`, pending holistic verification after MIN-001 closes.

#### E15-MIN-003 — specialized native-review subprocess containment

- Severity / scope: `significant × in-scope`.
- Suggested subtraction: retain bounded deadline, ordinary process-group
  termination, failed gate/no partial result, disposable-checkout cleanup, and
  no retry; remove escaped-descendant, inherited-pipe-holder, pipe-cutoff, and
  permanent-retirement protocol branches/tests.
- Resolution: subtraction accepted. The amended Plan retains read-only isolated
  execution, a 10-minute deadline, process-group termination, disposable-
  checkout cleanup, complete-output-only gating, and no retry; it removes the
  descendant/pipe/permanent-retirement subsystem.
- Lifecycle: `actioned`, pending holistic verification after MIN-001 closes.

#### E15-MIN-004 — repeated normative contracts across Plan sections

- Severity / scope: `significant × in-scope`.
- Suggested subtraction: make each behavior canonical in one authority or
  temporal section and compress duplicate requirement/decision/work/site/test
  prose while preserving unique decisions, site coverage, ordering, and all
  Phase-1 obligations.
- Resolution: subtraction accepted. The authority inventory and temporal-
  composition sections are now the normative behavior sources; work plan and
  site list were compressed from duplicate specifications to implementation
  sequencing/mapping while retaining every Phase-1 obligation. Plan size fell
  from 3,172 to 2,636 lines before the remaining MIN-001 disposition.
- Lifecycle: `actioned`, pending holistic verification after MIN-001 closes.

#### E15-MIN-005 — architecture-history/review-ledger edits inside runtime work

- Severity / scope: `significant × adjacent`.
- Suggested subtraction: keep `NEW_CODEX_OPERATING_MODEL.md` and
  `poc/REVIEW_LEDGER.md` as read-only decision/process inputs rather than PoC
  runtime implementation sites. The review ledger continues to be maintained by
  this existing review process.
- Lifecycle: `deferred`; it does not block the current Plan and no separate
  memory write is authorized.

Plan hash after primary-owned MIN-002/003/004 simplification:
`4462ebac2935ed6663fae17c8a36e22a1abeba05750cdf60b6bb6926a7a12c08`.
The staged implementation-start diff remains unchanged at
`0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 Plan Review Phase 2 / MIN-001 disposition

- The user selected the controller-dispatched low-cost observer option.
- The amended Plan contains no hard six-action/five-minute work-quantum,
  action/time frontier, or budget-interrupt lifecycle. Routine observation is a
  separately assigned read-only role over an immutable frontier; the worker
  continues, and intervention remains a later primary-owned transition.
- Current amended Plan hash for holistic post-minimization verification:
  `7dbecd74110b19ab23ff9071727eeb3e996877f7eae4281eb69166f169825e34`.
- Preserved staged implementation-start diff hash:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

- Phase 2 remains open only for the required holistic verification; no
  implementation, rewind, Git mutation, or live run is authorized.

### E15 Plan Review Phase 2 / holistic post-minimization verification

- Reviewed Plan hash:
  `7dbecd74110b19ab23ff9071727eeb3e996877f7eae4281eb69166f169825e34`.
- `ux-reviewer`: `GREEN / CLEAR`; observer monitoring introduces no competing
  user-facing authority or interruption and the prior capture/rebind/correction/
  restart/approval flows remain coherent.
- `rfc-red-team`: `GREEN CLEAR`; observer overlap, stale evidence, uncertainty,
  failure, and false assessment remain bounded evidence-only behavior. It noted
  the accepted possibility that false `on_track` can delay drift detection but
  cannot authorize or mutate work.
- `rfc-reviewer`: `RED`; one blocking observer-intervention seam and one
  significant omitted test-support site follow.

#### OBS-001 — primary intervention after observation was not a closed transition

- Severity / scope: `blocking × in-scope`.
- Statement: the observer assessment was durably attributable and
  non-authoritative, but the later primary `continue`/`correct`/`pause`/
  `escalate` path did not bind the observed/current worker identities and
  frontiers or specify delivery, settlement, and stale no-effect behavior.
- Resolution challenge: `local-design-flaw`, high confidence; repair altitude
  `architecture`. The accepted behavior already requires uninterrupted routine
  observation and primary-owned intervention, so no product decision is
  missing. The minimal repair reuses the existing settled role boundary rather
  than adding an interrupt subsystem: the primary decision binds both the
  observer assessment/frontier and freshest worker run/owner/assignment/control
  frontier, reserves before successor admission/outcome adoption, lets the
  active turn settle normally, and then uses existing continuation,
  post-terminal revision, or pause semantics. Stale/superseded reservation is
  durable no-effect.
- Lifecycle: `actioned`, pending fresh holistic verification.

#### SITE-001 — fixture settlement support omitted from the site list

- Severity / scope: `significant × in-scope`.
- Statement: `poc/test_support.py` composes with role settlement through
  scripted/test-only completion helpers but was absent from the implementation
  site inventory.
- Resolution: add it as a fixture-only site, keep its shortcuts outside
  production and ineligible for notification/finalization composition tests,
  and require updates when the role settlement contract changes.
- Lifecycle: `actioned`, pending fresh holistic verification.

Corrected Plan hash for verification:
`dbd17d00020239509008c702b4ca736226c3225a2ca03acafd91a5a03c23a285`.
The staged implementation-start diff remains unchanged at
`0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 Plan Review Phase 2 / observer-intervention verification

- Reviewed Plan hash:
  `dbd17d00020239509008c702b4ca736226c3225a2ca03acafd91a5a03c23a285`.
- `rfc-reviewer`: `GREEN`; OBS-001 and SITE-001 verified closed, with no new
  findings.
- `ux-reviewer`: `GREEN / CLEAR`; next-boundary intervention timing introduced
  no worker interruption or user-visible authority regression.
- `rfc-red-team`: `RED FLAG`; all prior obligations remained closed, but one
  new multi-assessment composition finding follows.

#### E15-RT-004 — overlapping observer-triggered reservations competed for one boundary

- Severity / scope: `blocking × in-scope`.
- Statement: multiple overlapping observer assessments could each cause a
  primary intervention reservation for the same unsettled worker boundary. The
  Plan did not define exclusive arbitration between contradictory reservations
  or their complete ordering with handoff/retirement.
- Resolution challenge: `local-design-flaw`, high confidence; repair altitude
  `architecture`. Adding a reservation slot/version would create a new execution
  lifecycle solely for monitoring. The narrower repair removes standalone
  observer-triggered intervention entirely: assessments are non-authoritative
  evidence, and every settled relevant assessment through the ordinary primary
  context frontier is consumed only at the next already-required settled
  checkpoint-direction or terminal-outcome-adoption call. That boundary has one
  existing primary decision. Later assessments remain for a later eligible
  boundary; handed-off, retired, or superseded identity makes them historical.
  No observer-specific reservation, interrupt, competing consumer, or worker
  state exists.
- Lifecycle: `actioned`, pending fresh holistic verification.

Corrected Plan hash for the next verification:
`bed2c617c43ad8876059f44a095cb45f38d35575c94757b96be6383c655749aa`.
The staged implementation-start diff remains unchanged at
`0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 Plan Review terminal closure

- Final Plan hash:
  `bed2c617c43ad8876059f44a095cb45f38d35575c94757b96be6383c655749aa`.
- `rfc-reviewer`: `GREEN`; no findings. E15-RT-004 is eliminated by
  removing observer-specific intervention/reservation rather than adding an
  arbitration lifecycle. SITE-001 and all prior obligations remain closed.
- `rfc-red-team`: `GREEN CLEAR`; multiple/late/stale observations, long turns,
  checkpoint-versus-terminal boundaries, handoff/retirement/supersession, and
  failed settlement compose without a competing observer command or owner.
- `ux-reviewer`: `GREEN / CLEAR`; checkpoint-only observation preserves timely
  PM-style awareness, one accountable primary, uninterrupted worker execution,
  and all existing user-facing flows.
- E15-MIN-001 through E15-MIN-004: `resolved` by the final holistic
  verification. E15-MIN-005 remains `deferred` as adjacent process bookkeeping.
- OBS-001, SITE-001, and E15-RT-004: `resolved` by the final holistic
  verification.
- Terminal Plan Review verdict: `GREEN`; no blocking/significant in-scope
  finding, minimization conflict, or pending user design decision remains.
- Preserved staged implementation-start diff hash:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- No implementation, rewind, staging change, commit, live run, integration, or
  push occurred during Plan Review. Fresh explicit implementation authorization
  remains required.

## E15 Plan closure invalidation / immediate observer intervention

- The user rejected the checkpoint-only observer-intervention premise after the
  terminal closure above: detecting possible drift during a worker turn is useful
  only if the accountable primary can assess and intervene immediately, without
  waiting for an unrelated checkpoint. This is a product-assumption correction,
  not a local wording change.
- The prior terminal Plan closure and its receipt are invalid. The receipt was
  removed; the historical review records above remain append-only evidence and
  cannot authorize implementation of the amended Plan.
- Decision 10 now records the selected Option 3: an attention-bearing or
  uncertain observer result is persisted and routed immediately to one
  `observer_attention` primary operation. The worker continues while the primary
  assesses. Only the primary may choose `continue`, exact-turn `steer`, `pause`,
  or `escalate`; the observer has no steering, interruption, or state authority.
- The single logical-primary contract is preserved. An alert never waits for a
  worker checkpoint merely for pacing, but if another primary call is physically
  unresolved it remains durable and dispatches as the next eligible operation
  rather than opening a concurrent primary turn. Later assessments are
  coalesced behind one immutable frontier.
- Pinned local `codex-cli 0.147.0` generated App Server v2 schema evidence shows
  that `turn/steer` requires `threadId`, `expectedTurnId`, and input, returns a
  `turnId`, and exposes `activeTurnNotSteerable`. The Plan therefore requires
  startup qualification of accepted ordinary steering, stale-turn rejection,
  and non-steerable rejection; missing capability cannot silently degrade to
  interruption.
- Proven stale, pre-send, or provider-rejected steering is no-effect. A steering
  send/response that may have been admitted but cannot be proven is instead an
  incomplete-delivery fence with no retry or automatic interrupt. Accepted
  steering admits direction to the same turn but does not replace ordinary
  worker turn/action settlement.
- Current amended Plan hash before fresh independent review:
  `ca3c3b0c28d53d5084951d9c6900e7ab3a91c9d624e99e43e698b372c4419805`.
- Preserved staged implementation-start diff hash:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Lifecycle: `open`; a fresh holistic soundness, adversarial, and UX review of
  this exact amended Plan is required before any new closure or implementation
  authorization.

### E15 immediate-intervention Phase 1 discovery, pass 1

- Reviewed Plan hash:
  `ca3c3b0c28d53d5084951d9c6900e7ab3a91c9d624e99e43e698b372c4419805`.
- `rfc-reviewer`: `RED`, with three `blocking × in-scope` findings.
- `rfc-red-team`: `YELLOW CAUTION`, with two `significant × in-scope` and one
  `acknowledged × in-scope` finding; no adversarial blocker met its two-part
  threshold.
- `ux-reviewer`: not GREEN, with two `significant × in-scope` findings and no
  blocker.

#### E15-OBS-001 — old automatic worker-budget interruption competes with primary authority

- Severity / scope: `blocking × in-scope`.
- Obligation: continuing workers cannot remain subject to the existing five-
  minute/six-action automatic interrupt and synthetic budget checkpoint after
  the accepted design gives observer evidence no stop authority and makes the
  primary the sole routine intervention authority.
- Resolution: remove continuing-worker work deadlines, ordinal/time frontiers,
  budget overrun, controller budget timers/interrupts, and budget-checkpoint
  turns. Retain action inventory for notification integrity/settlement, real
  protocol/failure/shutdown interruption, and finite deadlines that fail only a
  one-shot evaluator.
- Lifecycle: `actioned`; pending holistic pass-2 verification.

#### E15-OBS-002 — observation dispatch is not bounded

- Severity / scope: `blocking × in-scope`.
- Obligation: cadence/progress triggers and slow observers must not create
  unbounded role runs or stale executable assessments.
- Resolution: reuse existing run/assignment/ledger state with one in-flight
  observer for the work item and one latest pending immutable frontier. Dispatch
  at most one catch-up after settlement; pause suppresses scheduling; handoff,
  retirement, supersession, or terminal state makes old results historical. No
  scheduler table or new execution authority is added.
- Lifecycle: `actioned`; pending holistic pass-2 verification.

#### E15-OBS-003 — live acceptance rebind contradiction

- Severity / scope: `blocking × in-scope`.
- Obligation: the PoC claim requires one planned physical-primary replacement,
  while the live-run work step had also forbidden manufactured rebinds.
- Resolution: the planned replacement is now an intentional happy-path step;
  only rebind failures/retries and unrelated conditional branches remain
  unmanufactured.
- Lifecycle: `actioned`; pending holistic pass-2 verification.

#### E15-OBS-004 — same-turn material progress can obsolete a primary steer

- Severity / scope: `significant × in-scope`.
- Obligation: structural identity equality alone cannot authorize a direction
  selected from materially older worker evidence.
- Resolution: derive a worker-progress frontier from exact worker-originated
  ledger events, run/assignment/turn state, routed action evidence, and artifact
  identities. Observer, primary decision, and effect bind it; effect start
  requires equality. Newer progress makes the old effect no-op, and a later
  inclusive frontier dominates older assessments.
- Lifecycle: `actioned`; pending holistic pass-2 verification.

#### E15-OBS-005 — repeated observer failure is permissive

- Severity / scope: `significant × in-scope`.
- Obligation: repeated loss of the PM-style monitoring lens cannot remain
  silently unconsumed while work appears normally monitored.
- Resolution: derive consecutive failures from durable observer runs; threshold
  two in PoC tests emits one `monitoring_degraded` fact per streak and
  mandatorily opens/joins `observer_attention`; success resets the streak. This
  does not stop the worker or grant observer authority.
- Lifecycle: `actioned`; pending holistic pass-2 verification.

#### E15-OBS-UX-001 — internal pause and user escalation are indistinguishable

- Severity / scope: `significant × in-scope`.
- Obligation: the one-primary UX must say whether the team is handling a hold or
  requires the user's response.
- Resolution: primary `pause` must name the next internal action and resume
  condition, then presents informational no-action-needed status after interrupt
  settlement. Only `escalate` or another accepted user-dependency boundary asks
  one concrete question and consequence.
- Lifecycle: `actioned`; pending holistic pass-2 verification.

#### E15-OBS-UX-002 — voice plan approval lacks progressive disclosure

- Severity / scope: `significant × in-scope`.
- Obligation: a voice-only user must not have to retain the full plan lineage or
  confuse another review iteration with implementation authority.
- Resolution: keep complete plan/lineage/findings/evidence bound in the envelope,
  lead with compact problem/outcome, material delta, review status/risk, and
  exact consequence, and keep full detail available for drill-down. Combined
  envelopes explicitly distinguish N+1 from starting coding from exact N.
- Lifecycle: `actioned`; pending holistic pass-2 verification.

#### E15-OBS-006 — next-available primary latency

- Severity / scope: `acknowledged × in-scope`.
- Disposition: documented accepted trade-off. Attention evidence is persisted
  immediately and never waits for a worker checkpoint merely for pacing, but an
  already-dispatched primary operation settles before the alert because the
  system preserves one logical-primary channel. This is not a bounded real-time
  guarantee.

### E15 immediate-intervention resolution challenge

- Diagnosis: `local-design-flaw`, high confidence.
- Repair altitude: `architecture`; no product/requirement ambiguity or scope
  collision remains.
- Root invariant: a continuing worker is never routinely stopped by time,
  action count, cadence, or observer output. Only eligible primary pause/
  escalation, explicit shutdown/no-primary drain, or real protocol/settlement
  failure may interrupt it.
- Minimum surface: reuse runs, assignments, role turns/outputs, global
  `ledger_seq`, routed action frontier, artifact identities, existing
  `primary_semantic_operations`, and existing steering/interrupt journals. Add
  typed snapshot/frontier, assessment/failure, intervention decision, internal-
  pause continuation, and presentation-mode data inside those records. Add no
  generic scheduler/health table, stop token, second primary channel, or new user
  decision framework.
- Corrected Plan hash for holistic pass 2:
  `38daf3d9efdf94b71f3a1f112acea2caf0a7f121be61ec88cd67d266578204c9`.
- Preserved staged implementation-start diff hash:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 immediate-intervention Phase 1 discovery, pass 2

- Reviewed Plan hash:
  `38daf3d9efdf94b71f3a1f112acea2caf0a7f121be61ec88cd67d266578204c9`.
- `rfc-reviewer`: `GREEN`; no blocking or significant finding. It acknowledged
  that exact progress-frontier equality could cause repeated no-effect cycles.
- `rfc-red-team`: `RED FLAG`; one `blocking × in-scope` continuity finding and
  one `significant × in-scope` intervention-liveness finding follow.
- `ux-reviewer`: `GREEN`; the internal pause/escalate distinction and compact
  voice-first plan authorization remained clear.

#### E15-RT-P2-001 — moving-frontier rebind can starve under healthy writes

- Severity / scope: `blocking × in-scope`.
- Obligation: physical-primary activation/rebind must converge while an
  independent worker continues recording durable progress; healthy ledger writes
  cannot consume the bounded candidate or sole rebind allowance.
- Resolution challenge: `local-design-flaw`, high confidence; repair altitude
  `architecture`. The moving-current-maximum equality gate was the enabling
  decision. Adding a write pause, retry budget, or another buffer would enlarge
  the protocol without restoring the missing finite cut. The Plan instead
  freezes one candidate cutover `F`, installs at `I = F` after exact packet
  acknowledgement, and treats later records as the existing ordered backlog.
  Before each semantic primary call it freezes and acknowledges one finite
  dispatch prefix through `D`; later writes wait for a later drain.
- Lifecycle: `actioned`; pending holistic pass-3 verification.

#### E15-RT-P2-002 — universal progress equality can starve intervention

- Severity / scope: `significant × in-scope`.
- Obligation: once the observer detects possible drift, ordinary progress by the
  same active worker must not indefinitely prevent the primary from continuing,
  steering, pausing, or escalating that turn.
- Resolution challenge: same `local-design-flaw`, high confidence; repair
  altitude `architecture`. A moving evidence frontier had incorrectly become a
  universal effect gate. The Plan now keeps it for provenance and assessment
  dominance while defining action-specific currentness: `continue` has no worker
  effect; `steer`, `pause`, and `escalate` require exact active-turn ownership but
  tolerate compatible progress. Steer sends the complete structured delta
  through a fixed send frontier for worker-side semantic reconciliation. Only a
  conflicting lifecycle/ownership winner, stale turn, or proven provider
  rejection makes the action no-effect.
- Lifecycle: `actioned`; pending holistic pass-3 verification.

Corrected Plan hash for holistic pass 3:
`5d2701de07036e33080b05ce0d603b4ee1bbe3b589c01270fd06e132ae39fec7`.
The staged implementation-start diff remains unchanged at
`0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 immediate-intervention Phase 1 discovery, pass 3

- Reviewed Plan hash:
  `5d2701de07036e33080b05ce0d603b4ee1bbe3b589c01270fd06e132ae39fec7`.
- `rfc-reviewer`: `GREEN`; no findings. It explicitly verified fixed-prefix
  activation/rebind, sustained producers, action-specific intervention
  currentness, bounded observer scheduling, pause/escalate authority, and
  voice-first plan authorization.
- `ux-reviewer`: `GREEN`; no blocking, significant, or acknowledged UX
  findings.
- `rfc-red-team`: `RED FLAG`; one `blocking × in-scope` capacity finding
  follows.

#### E15-RT-P3-001 — fixed frontiers remain unbounded model inputs

- Severity / scope: `blocking × in-scope`.
- Obligation: removing moving-frontier starvation must not require an unlimited
  number or size of ledger records to fit in one re-prime, pre-call drain, or
  steering input. Continuing workers intentionally have no work-time or action-
  count cap, while every model request has finite context capacity.
- Trigger and impact: a sufficiently large frozen `F`, `D`, or steering delta
  cannot fit in one request. Candidate retry sees the same oversized prefix and
  can exhaust primary activation/rebind; an active-binding drain can repeat that
  failure; an oversized steering delta can prevent live intervention.
- Detection gap: sustained-producer tests prove that the cut does not move, but
  do not exercise an already-frozen prefix larger than one request.
- Lifecycle: `open`; the third automatic review pass has reached the user
  checkpoint, so no further Plan version or review starts without current user
  direction.

### E15-RT-P3-001 resolution challenge

- Diagnosis: `local-design-flaw`, high confidence; repair altitude
  `architecture`.
- Smallest enabling decision: the Plan equated durable completeness with copying
  every durable record into model context. The actual obligation is that a
  replacement primary receive a complete bounded representation of all current
  authority, obligations, and dependencies as of an immutable frontier, with
  exact durable history remaining queryable by identity. The same active worker
  already owns its post-decision current state, so steering does not require the
  controller to replay every progress record back to it.
- Candidate resolution: use a closed, deterministic, size-bounded current-state
  projection at fixed `F` and each fixed `D`, including exact IDs, hashes,
  counts/digests, and query cursors for omitted historical detail. Essential
  unresolved/current facts remain explicit; history stays in SQLite/Git and is
  available through the existing read-only context-retrieval boundary. Steering
  carries the primary direction, evidence/frontier identities, and a conditional
  reconcile-with-current-state instruction rather than a complete raw delta.
  If the required current-state projection itself exceeds the declared context
  limit, fail explicitly as `context_capacity_exceeded`, preserve work, and do
  not misclassify it as a retryable primary transport/rebind failure.
- Rejected repair altitude: ordered chunks of every historical record add a new
  transport lifecycle yet still cannot guarantee that the accumulated model
  context fits. Raising or assuming a model limit is not deterministic across
  models and violates the measurement/portability intent.
- User decision required: the Plan's three-automatic-version checkpoint is due.
  No implementation, rewind, staging change, live run, integration, or push is
  authorized.

### E15 context-capacity checkpoint disposition

- The user selected Option 3 for the current PoC: rely on the pinned model's
  available context for the bounded fixture/live corpus and solve general
  long-history continuity later.
- This is an explicit MVP scope boundary, not a claim that fixed frontiers bound
  payload size. Arbitrarily large ledger prefixes, chunked continuity transport,
  bounded current-state projection, and smaller-context-model portability are
  deferred.
- The Plan keeps exact fixed-prefix `F`/`D` and exact steering-delta behavior for
  the supported corpus. A real provider capacity rejection follows the existing
  visible candidate or semantic-call failure path, preserves durable work, gains
  no special retry, and cannot be reported as successful continuity.
- The actionable user direction resets the three-version automatic-review
  counter and authorizes creation/review of this next Plan version only; it does
  not authorize implementation.
- Revised Plan hash for fresh holistic review:
  `57e9daa06eff39f868531047bf7b5cb0031e98cc090c0dc2478d6a1c30eff94a`.
- Preserved staged implementation-start diff hash:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 bounded-context Plan Review, pass 1

- Reviewed Plan hash:
  `57e9daa06eff39f868531047bf7b5cb0031e98cc090c0dc2478d6a1c30eff94a`.
- `rfc-red-team`: `GREEN CLEAR`; Decision 11 is a legitimate bounded-PoC
  boundary and no grounded adversarial finding remained.
- `ux-reviewer`: `GREEN`; the limitation is honest without burdening the normal
  voice path, and failure communication preserves the one-primary experience.
- `rfc-reviewer`: `YELLOW`; one `significant × in-scope` disposition mismatch
  follows.

#### E15-CAP-001 — capacity rejection used a generic wrong-owner failure label

- Severity / scope: `significant × in-scope`.
- Statement: Decision 11 described every capacity rejection as a candidate or
  semantic-call failure, but active-binding `D` is a control-plane attempt and
  `turn/steer` is an intervention effect with its own proven-rejection versus
  ambiguous-delivery distinction.
- Resolution: enumerate only the existing owner-specific paths. Candidate `F`
  uses `binding_candidate` failure; active-binding `D` uses the
  `active_binding` fence/rebind-or-no-primary lifecycle; proven steering
  rejection is no-effect with current-evidence reassessment/ordinary-boundary
  consumption, while only possibly admitted unprovable steering delivery uses
  the worker/run/worktree fence. None gains a capacity-specific retry.
- Lifecycle: `actioned`; pending fresh holistic pass-2 verification.

Corrected Plan hash for bounded-context pass 2:
`8511e2f8415caabc9fde89b200ed2816c959560e7b9d79311abee7950ec1e226`.
The staged implementation-start diff remains unchanged at
`0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 bounded-context Plan Review convergence

- Verified Plan hash:
  `8511e2f8415caabc9fde89b200ed2816c959560e7b9d79311abee7950ec1e226`.
- `rfc-reviewer`: `GREEN`; E15-CAP-001 is closed and no new findings arose.
- `rfc-red-team`: `GREEN CLEAR`; exact capacity-rejection ownership and the
  complete temporal surface produced no grounded adversarial finding.
- `ux-reviewer`: `GREEN`; no blocking, significant, or acknowledged UX finding.
- E15-RT-P3-001 is dispositioned by the user-selected bounded-PoC scope: the
  arbitrary-history obligation is deferred rather than claimed. E15-CAP-001 is
  `resolved` by explicit owner-specific existing failure paths.
- Phase 1 verdict: `GREEN`; no unresolved blocking/significant in-scope finding
  or pending user design decision remains. Phase 2 minimality review is next.
- Preserved staged implementation-start diff hash:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 final minimality review

- Reviewed Plan hash:
  `8511e2f8415caabc9fde89b200ed2816c959560e7b9d79311abee7950ec1e226`.
- `rfc-minimizer`: `BLOATED`; the core architecture is load-bearing, but two
  `blocking × in-scope` artifact-minimality findings follow.

#### E15-MIN-P2-001 — competing full contract restatements

- Severity / scope: `blocking × in-scope`.
- Statement: requirements, E15 correction, authority inventory, acceptance
  narrative, and temporal sections repeated nearly complete mechanical
  contracts, creating competing specifications without preserving additional
  behavior.
- Resolution: retain concise user-observable requirements, the explicit
  problem/options/decision records, one normative authority-transition
  inventory, temporal composition, site/work plan, and a milestone-only
  acceptance narrative. Replace the E15 restatement with only the interpretation
  and rewind boundary. All converged Phase-1 obligations remain in the normative
  map/temporal rules.
- Lifecycle: `actioned`; pending the single post-minimization holistic
  verification pass.

#### E15-MIN-P2-002 — exhaustive implementation-level test permutation matrix

- Severity / scope: `blocking × in-scope`.
- Statement: the deliberate-composition list repeatedly specified low-level
  permutations beyond the scope's explicit deferral of comprehensive race/fault
  tolerance and exhaustive proof matrices.
- Resolution: replace it with one bounded distinguishing obligation per contract
  cluster: notification/finalization; presentation/input; continuity; capacity;
  agent settlement/ownership; observation/intervention; plan/decision authority;
  restart; candidate/review; integration/closeout. Preserve the specific
  sustained-write F/I/D, repeated-progress intervention, no routine worker stop,
  observer bound/degradation, planned rebind, authority, and review closures.
- Lifecycle: `actioned`; pending the single post-minimization holistic
  verification pass.

Post-minimization Plan hash:
`71d72fd4c7a8e74a02d56b285f22c2e5fe1c363b471a26473474c684f14f198d`.
The Plan decreased from 3,059 to 2,471 lines without changing the accepted
behavior or implementation scope. The staged implementation-start diff remains
unchanged at
`0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 post-minimization holistic verification, pass 1

- Reviewed Plan hash:
  `71d72fd4c7a8e74a02d56b285f22c2e5fe1c363b471a26473474c684f14f198d`.
- `rfc-reviewer`: `GREEN`; E15-MIN-P2-001/002 closed and all prior obligations
  remained complete.
- `ux-reviewer`: `GREEN`; no findings and the concise one-primary journey
  remained complete.
- `rfc-red-team`: `YELLOW`; no blocker and one `significant × in-scope` wording
  contradiction follows.

#### E15-MIN-V-001 — ordinary ask used terminal fence vocabulary

- Severity / scope: `significant × in-scope`.
- Statement: the temporal `Pause` row said an ask fences its run, contradicting
  the normative transition map and `Resume` row where an ordinary settled ask
  preserves the same active run/thread and blocks only dependent progress.
- Resolution: replace the word `fence` with a dependency gate that explicitly
  preserves active run, physical thread, ownership, and independent progress;
  reserve `fence` for settlement/integrity failures.
- Lifecycle: `actioned`; pending exact-delta verification.

Corrected post-minimization Plan hash:
`e5b474fabcb8e618e103935b53ee0381a1843bb5ad5782db78e11ade7ddfef2a`.
The staged implementation-start diff remains unchanged at
`0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E15 terminal Plan Review closure

- Final Plan hash:
  `e5b474fabcb8e618e103935b53ee0381a1843bb5ad5782db78e11ade7ddfef2a`.
- Exact-delta `rfc-reviewer`: `GREEN`; E15-MIN-V-001 is closed with no
  unrelated behavioral change.
- Exact-delta `rfc-red-team`: `GREEN CLEAR`; dependency gating/resume and true
  settlement/integrity fencing are coherent.
- Phase 1 soundness/adversarial/UX review converged; the user-selected bounded-
  context decision and exact F/D/steer failure ownership are closed.
- Phase 2 minimization removed competing restatements and the exhaustive test
  matrix; post-minimization holistic and exact-delta verification are GREEN.
- E15-MIN-P2-001, E15-MIN-P2-002, and E15-MIN-V-001 are `resolved`.
- Terminal verdict: `GREEN`; no unresolved blocking/significant in-scope
  finding, minimization conflict, or pending user design decision remains.
- Preserved staged implementation-start diff hash:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- No implementation, rewind, staging change, commit, live run, integration, or
  push occurred during this Plan Review. Fresh explicit implementation
  authorization remains required for this exact Plan hash.

## E16 reviewed-Plan implementation / Code Review restart

- User authority: the user explicitly approved implementation of the exact
  closed Plan and then directed `proceed`.
- Implemented Plan hash:
  `e5b474fabcb8e618e103935b53ee0381a1843bb5ad5782db78e11ade7ddfef2a`.
- Preserved staged implementation-start binary diff hash:
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Implementation disposition: removed continuing-worker action/time budgets and
  synthetic checkpoints; added the reviewed non-blocking observer, primary-owned
  observer attention/intervention paths, fixed F/I/D continuity, bounded-context
  owner-specific failure handling, and the corresponding offline tests and role
  prompts. No live run, staging operation, commit, integration, push, or main-repo
  change occurred.
- Validation evidence: full Python discovery `337 passed, 1 environment-only
  skip`; focused kernel/controller `137/137`; focused prototype `111/111`; Go
  test/build, bash syntax, Python compileall, diff-check, and retained helper
  `--help` checks passed.
- Plan deviation: none reported by the implementer; final traceability remains
  reserved for RFC implementation closure after Code Review convergence.
- E15-CC-001 and the E15 implementation findings remain `actioned` pending the
  required restarted review evidence. Their status is not inferred from tests.
- Review epoch: 16; substantive-iteration counter: 0.
- Restart boundary: Code Review Flow Phase 1 holistic discovery. Discovery
  reviewers receive the exact scope, current artifact, codebase context, tests,
  and Plan only; they do not receive this ledger, prior findings, a claimed fix,
  or a proposed root cause.

### Review epoch 16 / Phase 1 discovery result

- Sources: two parallel `code-review-analyst` discovery passes over the complete
  code-change artifact and exact Plan context: one correctness/temporal lens and
  one cohesion/ownership lens. Neither received this ledger, the other current
  review, a claimed fix, or a proposed root cause.
- Review-integrity qualification: the correctness reviewer was required by its
  managed environment to run a memory lookup and saw one older high-level
  action-lifecycle note. It did not use that note as finding evidence. The
  notification finding below is independently corroborated by the unexposed
  cohesion reviewer and a deterministic current-code reproduction; the other
  correctness findings were derived from the current artifact.
- Validation evidence: full Python discovery `337 passed, 1 environment-only
  skip`; Go passed; `git diff --check` passed.

#### E16-CR-001 — receipt assignment can outrun routing and certify a false frontier

- Review epoch / iteration: `16 / phase-1.1`.
- Source: both discovery reviewers; convergent.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:845`, `poc/controller.py:1844`, and
  `poc/controller.py:1962`.
- Statement: the reader advances `upstream_receipt_sequence` under the
  notification lock, releases the lock, and only then routes the envelope.
  Finalization may persist that assigned counter as the clean routed frontier,
  retire the subject maps, and then silently ignore the late routed lifecycle
  receipt. The implementation also accepts an action terminal after exact
  `turn/completed` and loses exact ownership after retirement.
- Scenario: same-turn lifecycle envelope receives sequence N and pauses before
  routing; another thread finalizes at N and exposes eligibility; routing resumes
  after retirement and drops the disqualifying lifecycle event.
- Suspected surface: authoritative assigned-to-routed receipt frontier and
  post-causal-close subject ownership.
- Suggested resolution: one serialized receipt-assignment/routing/frontier
  boundary or a distinct contiguous routed watermark, plus bounded retired
  thread/turn recognition; deterministic all-subject interleaving tests.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `repeated` notification/finalization authority cluster after
  the E15 reviewed-Plan implementation.

#### E16-CR-002 — consequential approval loses its correction producer

- Review epoch / iteration: `16 / phase-1.1`.
- Source: correctness discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:3869`, `poc/prototype.py:4137`,
  `poc/prototype.py:6660`, `poc/pty_tui.py:483`, `poc/kernel.py:8076`, and
  `poc/kernel.py:8217`.
- Statement: high-stakes response admission closes capture while independent
  verification runs; later typed bytes are discarded, and effect authorization /
  request does not serialize against a correction reservation or newer-input
  boundary.
- Scenario: user approves restart/integration, then says `wait` before effect
  start; the correction creates no durable input and the older authority still
  requests the effect.
- Suspected surface: confirmation-pending capture versus effect-start winner.
- Suggested resolution: keep the governed correction capture alive and make
  reservation versus effect start one approval-epoch transaction for both
  restart and integration.
- Fix applied: none.
- Lifecycle: `open`.

#### E16-CR-003 — work-item one-rebind allowance is not durably enforced

- Review epoch / iteration: `16 / phase-1.1`.
- Source: correctness discovery; deterministic two-loss reproduction.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/kernel.py:2007`, `poc/kernel.py:2162`, and
  `poc/prototype.py:2748`.
- Statement: successful handoff resets episode fields, a later active binding
  can open another replacement episode, and presentation teardown happens before
  any durable global-allowance decision.
- Scenario: first endpoint loss installs replacement one; loss of that
  replacement opens and installs `rebind-2`, exceeding the one-rebind proof.
- Suspected surface: work-item physical-primary replacement authority.
- Suggested resolution: atomically check/consume the durable allowance before
  teardown; every later trigger follows the terminal no-primary path without a
  new episode/candidate.
- Fix applied: none.
- Lifecycle: `open`.

#### E16-CR-004 — failed shared window can strand the unbounded worker waiter

- Review epoch / iteration: `16 / phase-1.1`.
- Source: correctness discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:1530`, `poc/controller.py:1653`,
  `poc/prototype.py:8177`, and `poc/prototype.py:8356`.
- Statement: notification-window failure fences durable state and signals only
  the notification condition; `_wait_for_exact_turn` waits on a different
  condition, ignores its role-turn identity, and the continuing implementer has
  no timeout.
- Scenario: malformed lifecycle input fences the implementer and App Server
  emits no terminal turn; no wake/interrupt reaches the waiter, so settlement
  and cleanup never run without an external signal.
- Suspected surface: shared-window failure propagation to its exact consumer.
- Suggested resolution: make the exact waiter observe/wake on window failure,
  issue the bounded interrupt owned by that failure, and enter the existing
  settle-or-fence path.
- Fix applied: none.
- Lifecycle: `open`.

#### E16-CR-005 — attention-bearing observation can be overtaken or stranded

- Review epoch / iteration: `16 / phase-1.1`.
- Source: cohesion discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:1544`, `poc/prototype.py:1642`,
  `poc/kernel.py:4374`, and `poc/kernel.py:5572`.
- Statement: assessment settlement and attention-pending ownership are separate;
  ordinary terminal adoption has no predecessor gate, and failure after a
  settled assessment is swallowed by scheduler handling that only searches an
  unsettled snapshot.
- Scenario: `possible_drift` persists; terminal adoption completes the worker
  before attention obtains the primary channel, or the attention primary call
  fails; durable attention remains unconsumed with no guaranteed summary/path.
- Suspected surface: observer-assessment producer to primary-attention and
  ordinary-boundary consumer ordering.
- Suggested resolution: atomically mark attention pending with assessment
  settlement, make ordinary terminal boundaries wait for or consume it, and
  route post-assessment primary failure through the existing operation failure /
  attention-summary path.
- Fix applied: none.
- Lifecycle: `open`.

#### E16-CR-006 — semantic primary can use the prohibited command tool

- Review epoch / iteration: `16 / phase-1.1`.
- Source: cohesion discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:2296`, `poc/prototype.py:8115`, and
  `poc/roles/prototype-primary.md:7`.
- Statement: semantic-primary windows admit actions and explicitly exempt
  `commandExecution`, contradicting the role's no-tools contract; a schema-valid
  decision can therefore become eligible after a prohibited command.
- Scenario: primary executes a command, returns typed output, and the command is
  recorded as allowed action evidence before the semantic decision drives an
  effect.
- Suspected surface: primary role capability versus runtime window policy.
- Suggested resolution: make semantic-primary windows zero-action and remove the
  command exemption; test every action type as ineligible.
- Fix applied: none.
- Lifecycle: `open`.

#### E16-CR-007 — candidate-finding disposition lacks exact primary projection and compatibility

- Review epoch / iteration: `16 / phase-1.1`.
- Source: cohesion discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:4351`, `poc/prototype.py:4371`,
  `poc/kernel.py:9343`, and `poc/kernel.py:9572`.
- Statement: ordinary candidate-finding disposition discards the primary call
  identity, validates no exact primary input/output, accepts incompatible
  severity/scope actions, and reuses the native-review-adoption operation kind.
- Scenario: an adjacent or non-actionable finding receives free-form `accepted`,
  supersedes the candidate, and dispatches fixes without exact accountable-
  primary evidence or compatibility proof.
- Suspected surface: candidate review finding adoption authority.
- Suggested resolution: reuse the existing closure-finding projection pattern,
  enforce severity/scope compatibility transactionally, and use a dedicated
  candidate-finding operation kind.
- Fix applied: none.
- Lifecycle: `open`.

#### E16-CR-008 — rejected-turn closure reads a stale second action inventory

- Review epoch / iteration: `16 / phase-1.1`.
- Source: cohesion discovery.
- Severity / scope: `significant × in-scope`.
- Location: `poc/controller.py:2085`, `poc/prototype.py:7799`, and
  `poc/prototype.py:7879`.
- Statement: production action lifecycle updates the shared window, but one
  rejected-turn closure path compares an empty legacy monitor action map with
  thread/durable evidence and can manufacture a contradiction/fence.
- Scenario: permitted worker action completes, output collection later fails,
  and failure closure sees complete shared/durable evidence but an empty legacy
  summary, waits, then unnecessarily fences the run/worktree.
- Suspected surface: duplicate shared-window versus legacy-monitor ownership.
- Suggested resolution: use the shared window as the sole action-evidence source
  and reduce/remove the legacy monitor's action inventory.
- Fix applied: none.
- Lifecycle: `open`.

### E16-CC-001 convergence checkpoint

- Review epoch: 16.
- Triggered at: `phase-1.1 discovery`, before any finding fix.
- Continuation:
  - phase: `phase-1`
  - boundary: `pre-fix`
  - lane: `discovery`
  - required next action: `disposition the E16 Phase 1 finding cluster, then
    perform the selected repair path and a fresh holistic Phase 1 discovery`
- Trigger: active-epoch evidence independently re-establishes the same
  notification assigned/routed-frontier P1 after the E15 Plan amendment and
  implementation; sibling findings also expose producer-to-consumer ordering,
  ownership, and authority gaps across observer attention, waiter failure,
  correction capture, rebind, and finding adoption.
- Evidence clusters:
  - authoritative producer-to-consumer ordering: E16-CR-001, E16-CR-004, and
    E16-CR-005;
  - user/effect and lifecycle authority: E16-CR-002 and E16-CR-003;
  - primary/review authority policy: E16-CR-006 and E16-CR-007;
  - duplicate action-evidence ownership: E16-CR-008.
- Diagnosis: `pending`.
- Action: `pending`.
- Status: `open`.

While E16-CC-001 is open, no fix, review dispatch, simplification, security
review, native gate, RFC implementation closure, Git mutation, live run,
integration, push, or main-repo change is permitted.

### E16-CC-001 convergence diagnosis

- Analyst: independent `review-convergence-analyst` in
  `convergence-diagnosis` mode over the cumulative E13-E16 ledger, current
  artifact, and exact accepted Plan.
- Diagnosis: `local-design-flaw`, high confidence, specifically an
  implementation/data-flow flaw rather than a flaw or ambiguity in the accepted
  Plan.
- Evidence:
  - E16-CR-001/004/008 form the notification/finalization cluster: assigned
    receipt versus routed frontier, exact-consumer failure wake/settlement, and
    duplicate legacy action-evidence ownership. E16-CR-001 repeats the historical
    E14/E15 notification authority cluster.
  - E16-CR-005 is a separate incomplete implementation of the reviewed
    observer-assessment to pending-attention to ordinary-boundary ordering.
  - E16-CR-002/003/006/007 are independent omissions of explicit reviewed Plan
    gates: correction/effect winner, global one-rebind allowance, semantic-
    primary zero-tool policy, and exact candidate-finding primary projection /
    compatibility.
- Repair altitude: `implementation` for every cluster. No product, requirement,
  scope, or Plan decision is missing, and no Plan amendment/re-review is needed.
- Smallest repair shape:
  - close receipt assignment/routing/routed-frontier under the existing
    notification serialization, retain exact closed-turn recognition, wake the
    exact failed waiter into the existing interrupt/settle-or-fence path, and
    remove the duplicate legacy action inventory;
  - publish existing pending observer attention atomically with its assessment,
    gate/consume it at ordinary boundaries, and use the existing primary-
    operation failure/summary path;
  - reuse the existing capture/proposal/effect writer for the correction-versus-
    effect winner;
  - check/consume the one rebind allowance from existing durable history before
    teardown;
  - make semantic-primary windows zero-action; and
  - reuse closure-style exact primary projection and compatibility for candidate
    findings under a dedicated existing semantic-operation kind extension.
  No generalized protocol, scheduler, recovery state machine, generic
  authorization layer, or NLP is justified.
- Cap disposition: E16 is already the convergence-directed restarted flow and
  E16-CR-001 re-establishes the same notification cluster. The one-restart cap
  therefore requires explicit user disposition before another repair pass even
  though the accepted design remains sound.
- Action: ask whether to authorize one bounded implementation-completion pass
  for E16-CR-001..008 under the unchanged Plan, followed by a fresh complete Code
  Review restart, or stop/defer the PoC.
- Status: `open`; no fix or review dispatch is permitted until that decision.
- Integrity evidence: Plan hash remains
  `e5b474fabcb8e618e103935b53ee0381a1843bb5ad5782db78e11ade7ddfef2a`;
  staged binary diff hash remains
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.

### E16-CC-001 user disposition / bounded completion authorized

- User decision: Option 1 — authorize one bounded implementation-completion
  pass for E16-CR-001..008 under the unchanged accepted Plan, followed by a
  fresh complete Code Review restart.
- Authority boundary: implement only the diagnosed implementation-altitude
  shapes. No Plan/scope/product change, generalized protocol or state machine,
  live run, staging/unstaging, commit, integration, push, or main-repo change is
  authorized.
- Checkpoint status: `actioned`.
- Required continuation: complete and validate the bounded repair; mark the
  affected finding entries `actioned` with exact fix evidence; begin review
  epoch 17 at counter zero; restart Code Review Flow at Phase 1 holistic
  discovery with the cumulative ledger excluded from discovery input.
- Resolution condition: only the required fresh review evidence, ultimately a
  clean restarted Phase 3 discovery gate, may resolve E16-CC-001 and the earlier
  actioned convergence checkpoints.

### E16 bounded repair completion / review epoch 17 start

- Repair altitude: `implementation`, under the unchanged accepted Plan and the
  user-authorized bounded E16 completion pass.
- E16-CR-001/004/008 fix: notification receipt assignment, complete routing,
  and contiguous routed-frontier advancement now share the existing notification
  serialization boundary; finalization consumes that routed frontier; exact
  causal close rejects later same-turn lifecycle; durable retired-turn identity
  remains recognizable; exact failed waiters wake into the existing interrupt /
  settle-or-fence path; rejected closure uses shared-window action evidence only.
- E16-CR-005 fix: attention-bearing assessment publishes existing pending
  attention ownership atomically; ordinary checkpoint/adoption/handoff/successor
  boundaries require it clear; primary attention failure uses the existing
  semantic-operation failure and attention-summary path.
- E16-CR-002 fix: restart/integration positive verification keeps the governed
  correction producer available and serializes correction reservation versus
  effect start through the existing proposal/control/effect writer.
- E16-CR-003 fix: the work-item one-rebind allowance is durably decided before
  presentation teardown; a later trigger enters the existing terminal no-primary
  path without another candidate.
- E16-CR-006 fix: semantic-primary windows are zero-action for every action type;
  the command-execution exemption is removed.
- E16-CR-007 fix: candidate-finding disposition uses its own semantic-operation
  kind, exact persisted primary input/output projection, candidate/finding
  identity, and severity/scope-compatible transactional disposition.
- Semantic-surface delta: only the diagnosed Plan-defined seams; no generalized
  protocol/state machine, generic authorization layer, new scheduler, NLP, Plan,
  scope, or product change.
- Finding lifecycle: E16-CR-001 through E16-CR-008 are `actioned`, pending the
  required fresh holistic discovery and downstream gate evidence; none is yet
  `resolved`.
- Validation evidence: focused Python `255/255`; full Python `344 passed, 1
  environment-only skip`; fresh Go test, Go vet, explicit-output Go build,
  Python compileall, shell syntax, and unstaged diff-check passed.
- Validation caveats: bare `go build ./...` conflicts with the existing
  `transport/` output directory name; the explicit-output build passes. The
  complete staged/HEAD diff retains two pre-existing vendored EOF blank-line
  warnings; the E16 unstaged diff is clean. The skipped sandbox isolation test
  cannot create its parent listener under the outer sandbox.
- Integrity evidence: Plan hash remains
  `e5b474fabcb8e618e103935b53ee0381a1843bb5ad5782db78e11ade7ddfef2a`;
  staged binary diff hash remains
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
- Review epoch: 17; substantive-iteration counter: 0.
- Restart boundary: Code Review Flow Phase 1 holistic discovery. Reviewers do
  not receive this ledger, the E16 findings, claimed fixes, diagnosis, or user
  disposition. Only fresh evidence may close the findings/checkpoint.

### Review epoch 17 / Phase 1 discovery result

- Sources: two parallel fresh `code-review-analyst` discovery passes over the
  complete current artifact and exact Plan context: correctness/temporal and
  cohesion/ownership. Neither received this ledger, earlier findings, claimed
  fixes, or diagnoses. The correctness pass had no memory/history exposure. The
  cohesion pass disclosed a policy-required memory lookup but used no memory
  content as evidence.
- Validation evidence: full Python `344 passed, 1 environment-only skip`; Go
  test passed; shell syntax passed. Complete-diff warnings remain limited to the
  two preserved staged vendored EOF blanks.

#### E17-CR-001 — durable endpoint handoff precedes fallible local publication

- Review epoch / iteration: `17 / phase-1.1`.
- Source: cohesion discovery; fault probe reproduced the split state.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:2934`, `poc/kernel.py:2004`, and
  `poc/controller.py:1330`.
- Statement: SQLite commits the candidate installed/current primary before
  controller publication and evidence persistence, but the enclosing generic
  failure path still fences/detaches that now-installed endpoint and attempts a
  candidate retry that is no longer eligible.
- Scenario: handoff commits, local publication or evidence fsync fails, generic
  cleanup detaches the current endpoint, and retry fails while durable state
  still reports an active/admitting primary.
- Suspected surface: durable endpoint handoff versus fallible process-local
  publication and recovery owner.
- Suggested resolution: prepare fallible work before the handoff; make remaining
  selector publication idempotent/non-throwing; use an explicit installed-
  endpoint terminalization path for unavoidable post-commit failure rather than
  candidate retry.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `spawned-sibling` of the endpoint ownership/handoff cluster.

#### E17-CR-002 — observer trigger and shutdown lack exact lifecycle ownership

- Review epoch / iteration: `17 / phase-1.1`.
- Source: cohesion discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:237`, `poc/controller.py:268`,
  `poc/prototype.py:1607`, `poc/controller.py:4088`, and
  `poc/controller.py:4202`.
- Statement: a progress trigger queues only mutable `run_id`, snapshots later,
  and the scheduler has no closed-admission state; finalization may stop the App
  Server before active/pending observer work is terminalized.
- Scenario: trigger occurs, worker terminalizes or finalization begins before the
  callback snapshots; snapshot creation fails without a durable observer outcome,
  or pending observation begins after finalizing and loses App Server dependency.
- Suspected surface: observation trigger producer, immutable frontier ownership,
  and shutdown/quiescence ordering.
- Suggested resolution: freeze/persist exact snapshot identity at the producer;
  close scheduler admission and drain/terminalize pending/in-flight observation
  before stopping dependencies or exporting final state.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `spawned-sibling` of E16 observer producer/consumer ordering.

#### E17-CR-003 — process-local identity allocation is unsafe across concurrent producers

- Review epoch / iteration: `17 / phase-1.1`.
- Source: cohesion discovery.
- Severity / scope: `significant × in-scope`.
- Location: `poc/controller.py:1047`, `poc/controller.py:1059`, and
  `poc/prototype.py:1561`.
- Statement: background observer and main workflow share unlocked read/modify/
  write counters, while request publication can overwrite an existing pending
  waiter for a duplicate ID.
- Scenario: concurrent allocations reuse a model/run/role-turn or request ID;
  durable uniqueness fails or one pending waiter is overwritten and stranded.
- Suspected surface: concurrent process-local identity namespaces and pending
  request publication.
- Suggested resolution: lock each allocator and allocate/check/insert request IDs
  under one `pending_lock` boundary; reject duplicate explicit IDs; add barrier
  concurrency tests.
- Fix applied: none.
- Lifecycle: `open`.

#### E17-CR-004 — plan synthesis can close incompatible blocking findings

- Review epoch / iteration: `17 / phase-1.1`.
- Source: correctness discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/kernel.py:8833`.
- Statement: plan closure keys on `revise`/top-level verdict, not immutable
  finding severity/scope, compatible disposition, rationale, and required
  same-version invalidity verification.
- Scenario: a blocking in-scope finding receives primary `reject`; no revision
  flag is set and the dirty plan closes without N+1 or independent same-version
  verification.
- Suspected surface: plan-review finding adoption and closure authority.
- Suggested resolution: enforce the reviewed compatibility matrix and grounded
  same-version verification path transactionally; otherwise require N+1 and
  close only an exhaustively compatible clean current batch.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `spawned-sibling` of E16 candidate-finding disposition authority.

#### E17-CR-005 — ambiguous observer interrupt is recorded as proven no-effect

- Review epoch / iteration: `17 / phase-1.1`.
- Source: correctness discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/controller.py:2603`, `poc/kernel.py:5945`, and
  `poc/prototype.py:8474`.
- Statement: the broad interrupt-dispatch exception handler maps
  `AmbiguousDispatch` to `no_effect`, so a physically interrupted worker can
  remain durably active/unfenced and later bypass common closure.
- Scenario: interrupt reaches App Server, response times out, journal marks
  ambiguous, but observer effect records pre-send/no-effect; the interrupted
  completion sees that terminal and skips exact role-turn closure.
- Suspected surface: observer interrupt dispatch certainty and exact turn
  settlement owner.
- Suggested resolution: distinguish proven pre-send failure from ambiguous
  delivery; ambiguous becomes incomplete delivery and uses the existing common
  exact role-turn fence/settlement path.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `spawned-sibling` of E16 observer effect settlement.

#### E17-CR-006 — activation retry does not initially own inherited presentation cleanup

- Review epoch / iteration: `17 / phase-1.1`.
- Source: correctness discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/prototype.py:2832`, `poc/kernel.py:1618`, and
  `poc/prototype.py:6693`.
- Statement: activation candidate one acquires cleanup ownership of the inherited
  startup presentation only after fallible continuity-packet construction.
- Scenario: packet sizing fails before candidate insertion; cleanup skips detach;
  candidate two attaches and overwrites the process handle, leaking an old live
  presentation that can no longer be proven absent.
- Suspected surface: startup presentation lease transfer and candidate cleanup.
- Suggested resolution: transfer cleanup ownership before any fallible candidate-
  one work; require proven teardown before candidate two; reject attach while an
  existing process remains live.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `spawned-sibling` with E17-CR-001 in endpoint lifecycle.

#### E17-CR-007 — candidate commit lacks exact implementer/adoption/content binding

- Review epoch / iteration: `17 / phase-1.1`.
- Source: correctness discovery.
- Severity / scope: `blocking × in-scope`.
- Location: `poc/kernel.py:9081` and `poc/prototype.py:868`.
- Statement: candidate registration checks plan/attempt and Git identity but not
  an exact settled implementer outcome, its accountable-primary adoption, or the
  intended quiescent worktree tree/diff/inventory identity.
- Scenario: implementer creates intended code plus an unintended file omitted
  from its self-report; `git add -A` includes both and the kernel accepts the
  unbound tree as the immutable candidate.
- Suspected surface: implementer output/adoption to candidate content authority.
- Suggested resolution: capture exact quiescent Git identity after implementer
  settlement, bind it to exact primary adoption, and require candidate
  registration to validate the run/adoption/content identity.
- Fix applied: none.
- Lifecycle: `open`.
- Relationship: `spawned-sibling` in candidate/review authority closure.

### E17-CC-001 convergence checkpoint

- Review epoch: 17.
- Triggered at: `phase-1.1 discovery`, before any E17 fix.
- Continuation:
  - phase: `phase-1`
  - boundary: `pre-fix`
  - lane: `discovery`
  - required next action: `disposition the E17 Phase 1 finding clusters before
    any repair; if continuation is permitted, complete the selected artifact /
    implementation path and restart holistic Phase 1 discovery`
- Trigger: new P1s continue to appear in sibling lifecycle/ownership/authority
  surfaces immediately after the user-authorized E16 completion and epoch-17
  restart. Endpoint, observer, and review/candidate findings demonstrate the
  same producer-to-consumer closure problem at previously unaudited call sites.
- Evidence clusters:
  - endpoint lifecycle: E17-CR-001 and E17-CR-006;
  - observer trigger/effect lifecycle: E17-CR-002 and E17-CR-005;
  - review/candidate authority: E17-CR-004 and E17-CR-007;
  - concurrent identity allocation: E17-CR-003.
- Diagnosis: `pending`.
- Action: `pending`.
- Status: `open`.

E17-CC-001 is a hard gate. No ordinary fix/review iteration, simplification,
specialist or native gate, RFC closure, Git mutation, live run, integration,
push, or main-repo change is permitted while it remains open.

### E17-CC-001 convergence diagnosis

- Analyst: independent `review-convergence-analyst` in
  `convergence-diagnosis` mode over cumulative E13-E17 evidence, the exact Plan,
  and current implementation.
- Diagnosis: `local-design-flaw`, high confidence, at convergence-level
  architecture/traceability altitude. This is not reviewer noise, requirement
  ambiguity, or seven independent first-time omissions.
- Evidence clusters:
  - endpoint lifecycle E17-CR-001/006 repeats sibling durable/local publication,
    lease-transfer, rebind, and capture ownership surfaces;
  - observer lifecycle E17-CR-002/005 repeats sibling trigger/attention/effect /
    settlement ownership after E16 observer repair;
  - review/candidate authority E17-CR-004/007 repeats sibling finding/adoption /
    candidate producer-to-effect closure after E16 candidate-finding repair;
  - E17-CR-003 is an independent concurrency defect introduced by the overlapping
    observer/main producers and is not overfit into those authority clusters.
- Repair altitude:
  - each isolated E17 obligation is already explicit in the accepted Plan and
    would individually be `implementation` altitude;
  - the convergence-level response is `architecture`, because another site-by-
    site pass repeats the approach that has already failed after the final
    authorized bounded completion. Continued work should first simplify the
    ownership/data flow or narrow the PoC slice, amend/review the Plan, and start
    from a clean boundary.
- Process-level root: both architecture complexity and implementation
  traceability/verification failed, with complexity upstream. The 2,471-line
  Plan is behaviorally adequate but not an executable ownership map. One
  invariant remains distributed across SQLite transactions, controller memory,
  workflow orchestration, App Server effects, and evidence writes. The site list
  names files but does not mechanically enumerate every producer, consumer, and
  effect boundary, so tests/reviews repeatedly close the inspected site while a
  sibling remains.
- Action: keep the checkpoint open and stop ordinary fixes/reviews. Ask the user
  whether to stop/defer while preserving evidence, reopen architecture to design
  a smaller mechanically traceable PoC slice, or explicitly waive the cap and
  accept the demonstrated recurrence risk of patching E17 under the same Plan.
  Architecture reopening is recommended if the objective remains important.
- Status: `open`; no code rewind, Plan edit, implementation, review dispatch,
  live run, Git mutation, integration, push, or main-repo change is authorized
  by the diagnosis itself.
- Integrity evidence: Plan hash remains
  `e5b474fabcb8e618e103935b53ee0381a1843bb5ad5782db78e11ade7ddfef2a`;
  staged binary diff hash remains
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`.
