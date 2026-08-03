# Low-Stakes End-to-End Operating-Model Prototype Plan

**Problem:** Demonstrate the complete defining behavior of the new voice-first Codex operating model on one low-stakes coding outcome before investing further in adversarial authority, race, recovery, and production-hardening proofs.
**In scope:** One project context, one active user-level work item, one accountable primary, durable SQLite-backed execution state, bounded role agents, proportional planning and independent review, first-class candidate-bound code-review findings, one agent ask, normal detach/reattach, planned context handoff or physical-agent replacement, one informed user-authorized clean attempt restart, implementation closure, final validation, and explicit user approval before Git integration.
**Out of scope:** Concurrent unrelated workstreams, hostile or simultaneous clients, exhaustive protocol-input matrices, malformed or non-canonical integer input, arbitrary-precision integers, crash injection, automatic crash recovery, exactly-once guarantees under ambiguous failure, duplicate review-result delivery or replay, approval races, security hardening beyond the already working local PoC boundary, production deployment, full project-brain features, first-class plan-review finding normalization, periodic finding-assessment automation, model/cost optimization, and a stable-host architecture claim.

## Decision and claim boundary

This plan optimizes for a complete usable experience, not a hardened host proof.
The existing Phase 1-4 PoC establishes that stock Codex CLI can operate through a
controller-owned gateway, that the controller can persist commands, and that it
can create isolated worker threads. That passing foundation is reused without
continuing its edge-case hardening unless the happy path itself is blocked.

A passing prototype establishes only:

- the programmatic-control-plane plus native-CLI topology is usable enough for
  the next MVP iteration;
- the intended primary/agent workflow can complete one real low-stakes coding
  outcome end to end; and
- durable artifacts can carry the exercised context and authority transitions.

It does not establish race safety, fault tolerance, hostile-local-client
security, automatic recovery, or production readiness. Those claims remain in
`poc/FULL_HARDENING_PLAN.md` and become measurement-driven later work.

Normal-path correctness is not deferred. Every exercised transition must either
complete with attributable evidence or stop visibly without claiming success.
Unexpected failures are recorded and surfaced; the prototype does not attempt
automatic recovery.

### Amendment decision: use one immutable candidate commit as integration identity

**Problem:** The reviewed worktree diff, user-approved diff, and integrated Git
result need one mechanically identical artifact identity; a mutable worktree can
change representation between those gates.

#### Option 1: Mutable worktree diff plus pre/post-commit hash checks

Pros:

- avoids creating a commit before the user authorizes integration; and
- keeps the current worktree-first sequence largely intact.

Cons:

- requires exact staging, patch canonicalization, and post-commit equivalence
  across multiple mutable representations; and
- leaves review and validation vulnerable to time-of-check/time-of-use drift.

#### Option 2: Immutable candidate commit before final gates

Pros:

- gives code review, closure, native hard review, validation, user approval,
  and integration one native Git identity;
- lets native Codex review the exact object with `review --commit`; and
- makes integration a fast-forward of the already approved commit rather than
  a new content-creating operation.

Cons:

- creates a non-main candidate commit before integration approval; and
- every accepted code fix must supersede it with a new candidate and invalidate
  downstream receipts.

#### Decision

Choose Option 2. A candidate commit is an immutable review artifact, not user-
visible integration. Only explicit approval may move the disposable repository's
`main` branch to that exact commit.

### Amendment decision: satisfy review gates with no unresolved actionable findings

**Problem:** A hard review may return valid strengths, acknowledged limitations,
or adjacent observations that require no code change. Requiring a literally empty
finding set would make those durable observations fatal or encourage their
suppression.

#### Option 1: Require a literal zero-finding result

Pros:

- gives `clean` one simple literal meaning.

Cons:

- harmless observations can block forever; and
- rerunning the same nondeterministic reviewer until it emits nothing is not a
  meaningful convergence rule.

#### Option 2: Require zero unresolved actionable findings

Pros:

- preserves every surfaced observation and its compatible primary disposition;
- keeps blocking and significant in-scope obligations mandatory; and
- gives the gate a deterministic semantic condition.

Cons:

- a satisfied gate may retain documented non-actionable findings.

#### Option 3: Split findings and observations into separate reviewer channels

Pros:

- preserves a literal zero-finding gate while retaining observations.

Cons:

- adds a second result protocol solely to rename compatible findings.

#### Decision

Choose Option 2. A review receipt means that the exact result was dispositioned
and no unresolved `revise` or `escalate` obligation remains. The raw result and
first-class findings preserve whether the reviewer emitted an empty set or
compatible non-actionable observations; the receipt must not rewrite one as the
other.

### Amendment decision: normalize code-review findings at the candidate boundary

**Problem:** Code-review findings embedded only inside result JSON are not
directly queryable as longitudinal project feedback, while duplicating Git's
snapshot model or building a future assessment ontology would expand the MVP.

#### Option 1: Retain only raw review-result JSON

Pros:

- adds no schema.

Cons:

- makes candidate-specific finding queries and later corpus analysis depend on
  repeated JSON extraction and source-specific formats.

#### Option 2: Add one first-class candidate-bound code-finding relation

Pros:

- makes every code finding directly queryable with its exact immutable commit
  context and review provenance; and
- reuses Git for the complete tree and parent/base instead of duplicating a
  working-tree snapshot.

Cons:

- adds one normalized relation and ingestion path.

#### Option 3: Add assessment, relationship, and scheduling structures now

Pros:

- could support periodic architectural analysis immediately.

Cons:

- invents lifecycle and clustering requirements before that separate workflow
  is designed.

#### Decision

Choose Option 2. Persist code-review findings only. Each row binds one exact
candidate commit, exact structured review-result artifact and source occurrence,
and the fields from `contracts/finding.md`. Git remains the snapshot authority;
candidate refs remain reachable evidence. Primary dispositions continue through
the existing decision/action record and name these finding identities. Plan-
review finding normalization and any later assessment or relationship model are
deferred without blocking future extension.

## Acceptance narrative

The pilot is a run-created disposable Git repository seeded from `poc/fixture/`.
It does not modify an unrelated user repository. Its exact task is to implement
a standard-library Python CLI named `normalize_values.py` that reads
guaranteed-valid canonical ASCII signed 32-bit newline-delimited integers from
standard input and writes them in ascending numeric order with exactly one
trailing newline per emitted value. Malformed input, non-canonical encodings,
and arbitrary-precision integers are explicitly outside the fixture contract.

The initial voice request explicitly requires duplicate removal and limits input
to 1,000 total input records. Its accepted simplicity constraint requires the
first plan to use the direct in-memory `sorted(set(...))` shape; bounded-memory
behavior is explicitly not part of attempt one. After that implementation and
one observable post-handoff checkpoint, the harness reveals a pre-versioned
proposed constraint: the same CLI must handle at most 2,000,000 total records
within a 96 MiB address-space limit. This is a product-constraint amendment, not automatically accepted
learning. The primary must separately obtain the user's acceptance of the new
constraint and authorization to discard and restart the current attempt. One
user response may confirm both, but the controller records two ordered authority
transitions.

For this fixture, the accepted clean-restart criterion is objective: after
implementation has started, an accepted intent revision invalidates the current
plan's required core algorithm and requires a replacement plan rather than a
local extension. The direct in-memory attempt and the accepted bounded-memory
constraint satisfy that criterion. The independent assessor verifies the
criterion and the carry-forward evidence; it does not choose a competing
restart policy. If the evidence does not satisfy the rule, the prototype is
inconclusive and must not manufacture the required restart.

After the approved clean restart, the fresh planner encounters one genuine
architecture choice within the revised accepted intent: use bounded sorted chunk
files with `heapq.merge`, or use a temporary SQLite database with an ordered
query. Both are standard-library paths capable of satisfying the observable CLI
contract. The planner sends the primary an ITD-shaped ask and pauses. The primary
may resolve it within the already accepted product authority; the fixture's
expected decision is sorted chunk files because they preserve the CLI's
single-purpose, stream-oriented shape without introducing a database lifecycle.

The attempt-start snapshot covers the exact disposable repository filesystem,
including HEAD, index, tracked, and untracked execution files. The final
validation commands are `python3 -m unittest discover -v`, an exact fixture
stdin/stdout comparison, a Linux `resource.setrlimit(RLIMIT_AS)` acceptance run,
`git status --porcelain` for a clean candidate checkout, and
`git diff --check <attempt-base>..<candidate>` for the committed change. The
memory gate first proves the fixture is discriminating: the seeded direct
in-memory reference must first produce the exact expected result on the same
generated two-million-record corpus without the address-space limit, then fail
on that corpus under 96 MiB, while the final CLI must succeed under the same
limit and produce the exact output. A broken positive control or an unexpectedly
successful limited reference makes the run inconclusive rather than PASS. The
integration target is only the disposable repository's `main` branch.

The valid-input and signed-32-bit bounds are a runtime-derived fixture correction:
earlier live runs showed that leaving the input domain open caused reviewers to
design a production parser instead of testing the operating model. The narrowed
contract preserves the material memory/restart challenge while keeping this a
low-stakes proof.

The accepted run demonstrates this complete narrative:

1. The user supplies one voice-typed request to the stock Codex CLI. The primary
   preserves the source input, gathers relevant read-only project context, and
   always shows a concise non-blocking understanding recap containing outcome,
   constraints, and repository boundary. It presents an approval-bearing intent
   gate only if material ambiguity remains.
2. The controller records the source request as intake before grounding. After
   required clarification and approval, it records the accepted outcome,
   constraints, project identity, and active work item before execution starts.
3. A dedicated planner receives bounded project and intent context and produces
   a durable plan artifact. Fresh soundness/completeness and adversarial reviewer
   contexts independently review the plan through verified convergence; the
   primary integrates their findings and records each immutable version. The
   accepted chain preserves exact adjacent and version-zero-to-current diffs.
4. A fresh implementer performs an executability preflight and works in its own
   Git worktree from the accepted plan. The primary remains the user's interface
   and periodically records compact alignment checkpoints.
5. While non-blocked work is active, the CLI disconnects normally. The
   controller and agent continue. A fresh CLI attachment returns to the same
   logical primary. A controller-owned status-synchronization turn presents the
   accepted outcome, last completed milestone, current activity or blocker,
   changes since detach, pending ask/approval, and next expected action. Full
   lineage remains available as drill-down rather than default output.
6. One planned execution-agent handoff replaces the physical agent context. The
   old run is retired before the controller transfers exclusive ownership of the
   same exact implementation worktree to the replacement. The accepted checkpoint
   binds a controller-derived worktree-state digest and Git diff artifact in
   addition to the accepted intent, current plan, compact progress, relevant
   artifacts, and assignment. Hidden predecessor context is not required. The
   replacement validates that exact transferred state before editing and produces
   one attributable progress checkpoint or completed sub-outcome that proves
   continuity before restart is considered.
7. The proposed bounded-memory constraint triggers an independent
   root-architecture assessment against the accepted attempt-invalidating
   criterion. When the evidence satisfies that rule, the primary identifies
   the current attempt and exact base snapshot, explains the proposed intent
   revision, summarizes discarded execution changes, names evidence and learning
   that will carry forward, and states that control-plane history remains. The
   user's one unambiguous response may approve both decisions, but the controller
   first records acceptance of the revised constraint and then separately binds
   restart authorization to the attempt and snapshot. Only then may the old
   attempt become abandoned and the execution plane restore. The controller
   verifies restore completion before creating fresh roles for the new attempt.
8. The fresh planner's spill-backend uncertainty produces one real, bounded agent
   ask after the revised intent is active. The ask names the affected outcome,
   why planning is paused, the two valid paths with pros and cons, and the
   recommendation. It is persisted before projection, the planner pauses, and the
   primary records its within-authority answer before confirming what resumes in
   a new planner turn. The resulting fresh plan extends the immutable lineage
   without treating the abandoned plan as accepted structure.
9. The final implementation receives two independent code reviews through
   verified convergence: correctness/quality and codebase cohesion. Findings,
   fixes, and re-review outcomes remain linked to the work item, current attempt,
   and exact candidate commit. Every ordinary and native code-review finding is
   also persisted as a first-class candidate-bound row before disposition. A
   separate fresh verifier then closes plan adherence against reviewed code; the
   native Codex hard review examines the final diff last. Any accepted post-review
   code change invalidates and reruns every affected review, closure, hard-review,
   and validation gate. The native result is an exact typed verdict and finding
   set rather than an exit-code/prose proxy; compatible non-actionable findings
   remain visible without preventing gate satisfaction.
10. The primary presents the final outcome, validation evidence, known prototype
    limitations, and exact integration diff. Only explicit user approval permits
    integration into the pilot branch. The final Git commit is linked back to the
    durable work item and accepted plan.

## Work breakdown

### 1. Preserve and simplify the proven foundation

- Treat the fresh passing Phase 1-4 packet as evidence for the current pinned
  CLI/gateway/worker substrate, not as an architecture verdict.
- Keep the stock CLI, controller gateway, App Server, SQLite single-writer, and
  isolated worker worktrees.
- Separate the ordinary prototype runner and evidence summary from the archived
  forensic hardening harness. Do not delete the historical harness or packets.
- Add no new transport, authentication, or process-lifecycle mechanism unless a
  normal happy-path step cannot run without it.

### 2. Add minimal durable product state

Persist only the execution-focused state needed by the acceptance narrative:

- original source request and accepted intent;
- work item identity, current derived state, and append-only work events;
- decisions and user answers;
- agent assignments, physical runs, checkpoints, asks, and outcomes;
- content-addressed plan, handoff, implementation, review, and closure artifacts;
- first-class code-review findings bound to their exact candidate commits,
  structured result artifacts, and source occurrences;
- execution attempts, base snapshots, supersession/restart authorization; and
- an immutable approval packet containing the exact candidate commit, changed-
  path inventory, diff identity, applicable review/closure receipts, validation
  evidence, and primary-visible summary; separate append-only authorization and
  final Git result events reference that packet hash without mutating its approved
  subject. The packet is the existing persisted proposal-presentation artifact,
  not a separate gate-snapshot entity or lifecycle.

SQLite remains controller-owned and single-writer. Agents communicate outcomes
to the controller; they never write the database directly. The schema should be
the smallest relational representation of these accepted responsibilities, not
a generic project-management ontology.

### 3. Use one bounded controller protocol

Every primary command and role outcome is a structured envelope bound to the
current work item, attempt, physical run, role, and schema version. Every
primary-owned semantic action additionally names the logical-primary thread,
exact producing turn, typed output artifact, and output hash. The kernel accepts
the action only when that evidence contains the same action and semantic
payload. Artifact references are immutable hashes or controller-owned paths;
free-form prose may explain an outcome but cannot itself trigger a transition.

Gateway intake is the sole pre-primary semantic exception: it preserves the
verbatim source and creates an inactive item. The primary then receives that
original source plus bounded repository context and returns the structured
grounding that may accept intent. For later role outcomes, the controller
supplies the exact staged result and permitted decision vocabulary to the
primary; it may validate or narrow the returned decision but may not manufacture
one by assigning `actor=primary`. Related dispositions may share one primary
turn when they judge one artifact or proposal.

At a user decision gate, the primary receives the verbatim response and returns
one typed semantic decision bound to the exact pending proposal: `approve`,
`reject`, or `clarify`. A compound restart proposal carries separate dispositions
for intent revision and attempt restart even when one response decides both.
Those dispositions are the effect authorities; the top-level decision is their
deterministic aggregate. `approve` requires every disposition to approve;
`clarify` applies no partial effect and keeps the complete proposal pending; a
terminal mixed `intent_revision=approve, restart=reject` records the accepted
intent revision, leaves restart unauthorized, closes that proposal, and keeps
work paused for a fresh restart proposal, another intent revision, or explicit
abandonment. Restart cannot approve while its prerequisite intent revision is
rejected or unresolved; such a response remains clarification with no effect.
Before accepting that response, the controller requires one successful
user-visible primary presentation bound to the proposal ID, immutable subject
hash, exact restart-discard summary or candidate/diff identity, primary thread,
and presentation turn/output hash. The presentation output contains the exact
controller-supplied proposal subject in addition to its concise summary. The
typed decision names that immutable approval-presentation artifact (the approval
packet); a failed render, stale
presentation, or subject mismatch remains paused.
Only an approved disposition permits its named controller action. A complete
rejection and every clarification keep all proposal effects unapplied. A
terminal partial restart decision permits only the approved intent revision and
never restart. Every non-restarting result keeps the proposal history and
affected work paused and visible, preserves the current attempt and any
integration candidate, and keeps the controller live for the user's next
direction. It neither resumes nor abandons work. Only a separate explicit
abandonment or operator-termination direction ends it. The controller never
infers approval from non-empty text, keywords, or conversational markers.

The controller accepts only these workflow actions from their named authority:

| Action | Authority | Required controller effect |
|---|---|---|
| `intake` | Gateway ingress on the user's source message | Preserve the verbatim source and create an inactive work item before primary grounding. |
| `accept_intent` | Primary carrying the user's unambiguous request or approved intent gate | Persist accepted outcome and constraints, then activate the work item. |
| `revise_intent` | Primary carrying explicit user acceptance of a proposed outcome or constraint change | Append a new accepted intent version without changing execution state or implying restart authority. |
| `decide_result` | Primary acting within accepted intent | Bind an exact role outcome to an allowed phase decision: `accept`, `revise`, `continue`, `pause`, `escalate`, or `handoff`. Reviewer results also carry per-finding dispositions. Only this action accepts plans, checkpoints, handoffs, and role artifacts or directs their revision. |
| `decide_native_review` | Primary acting within accepted intent on the exact native result artifact | Bind the current candidate, native-result artifact, primary turn/output, decision, and every compatible first-class finding disposition. A revision or escalation leaves the candidate receipt-ineligible; a disposition-complete result with no unresolved actionable finding may produce a receipt. |
| `answer_ask` | Primary carrying the user's answer or its own decision within accepted authority | Bind one attributable answer to the currently open ask before a resume assignment exists. |
| `authorize_restart` | Primary carrying a typed informed user approval | Bind the approved proposal to the recommended attempt, accepted intent revision, and exact base snapshot. |
| `authorize_integration` | Primary carrying a typed explicit user approval | Bind the exact candidate commit to the user-approved immutable approval-packet hash; revalidate its candidate, receipt, validation, and diff contents before Git mutation; record authorization separately without changing the approved subject. |
| `abandon` | Primary carrying user direction | End the active work item or attempt without integration. |

Role agents return exactly one outcome per assigned turn. Controller validation
stages the outcome but never semantically advances the workflow; a compatible
`decide_result`, `answer_ask`, or stronger user-authority action is required:

| Outcome | Allowed producer and controller behavior |
|---|---|
| `ready` | Implementer preflight confirms one executable path; no project files changed yet. |
| `checkpoint` | Active role publishes compact progress plus artifact references; work remains paused at the turn boundary until the primary records `continue`, `revise`, `pause`, `escalate`, or `handoff` through `decide_result`. |
| `ask` | Active role supplies evidence and zero-or-multiple valid paths; controller persists the ask and pauses dependent work. |
| `completed` | Active role supplies its expected artifact or review result; controller validates role, phase, identity, and references, then waits for a compatible primary decision. |
| `failed` | Active role supplies the bounded failure; controller records blocked/failed state and advances nothing. |

Reviewer `completed` outcomes additionally carry contract-shaped findings or an
explicit clean verdict. The controller validates `decide_result` against a
phase table: plan acceptance requires converged plan-review receipts; handoff
requires an accepted checkpoint; review advancement requires dispositions for
every finding; closure requires clean code-review receipts. The controller
rejects stale attempt/run IDs, outcomes or decisions not allowed for the assigned
role or phase, missing referenced artifacts, and a second outcome from the same
turn. Rejection is visible and does not advance workflow. This action table is
exhaustive for primary-owned semantic transitions in the prototype.

Role-specific terminal meaning is typed rather than recovered from prose. Every
review finding satisfies `contracts/finding.md`, including scope and required
resolution/scenario fields. Root assessment returns an explicit restart
recommendation; closure returns an exact closure status; reviewers return an
exact verdict and finding set. The kernel derives the allowed decision from the
assignment's role, phase, outcome kind, and finding dispositions. A failed role
cannot be accepted as completed, and caller-supplied receipt lists cannot create
gate satisfaction.

Code-review findings are inserted into one first-class relation after the exact
candidate-bound structured result validates and before primary disposition. A
stable finding identity binds the candidate SHA, result-artifact hash, and source
ordinal; the row contains the finding-contract fields rather than a second copy
of the Git tree, base, diff, or inventory. Ordinary role-review and native-review
results use the same ingestion boundary. Primary decisions reference those
identities, while their exact action records remain the disposition authority.
Plan-review findings remain in their existing content-addressed outcomes and are
not normalized by this amendment.

Reviewer finding dispositions use one bounded algebra: `revise`, `dismiss`,
`defer`, `acknowledge`, or `escalate`. In-scope blocking/significant findings
require `revise` and make the current artifact receipt-ineligible; adjacent
blocking findings require `escalate`; adjacent significant/acknowledged findings
may `defer`; out-of-scope findings may `dismiss`; and in-scope acknowledged or
strength findings may be `acknowledge`d. Malformed findings invalidate the role
outcome before disposition. A reviewer result may be accepted as clean only
when every finding has a compatible disposition and the exact accepted primary
decision for that review leaves no unresolved in-scope blocking/significant
obligation and no escalation awaiting user scope judgment. Receipt derivation
reads that decision and its dispositions rather
than requiring an empty finding set; acknowledged, strength, dismissed, or
otherwise compatible non-revision, non-escalation findings remain durable and
receipt-eligible. An `escalate` disposition stops visibly for user scope judgment
and cannot contribute a receipt.
A substantive user deferral is not exercised by this prototype and cannot be
manufactured by the primary.

The native Codex hard review is outside the ordinary role-agent transport but
obeys the same semantic gate. Its final output names the exact candidate SHA and
contains either a typed clean verdict or contract-shaped findings; malformed,
ambiguous, or identity-mismatched output fails closed. Any actionable in-scope
finding makes the native receipt ineligible, enters the compatible
disposition/revision path, and after a fix requires a superseding candidate and
all affected downstream gates. A valid exact result whose first-class findings
all have compatible non-revision, non-escalation dispositions may contribute the
native receipt
for the current candidate without erasing or relabelling those findings.

### 4. Implement the primary-led happy-path workflow

- Route intake, grounding, intent gating, work start, role assignment, asks,
  checkpoints, handoff, review, closure, and integration through the logical
  primary.
- Attribute every primary-owned semantic transition to a validated structured
  primary turn; controller-selected labels or deterministic finding mappings are
  not primary decisions.
- Use separate physical agent contexts for planner, implementer, reviewers, and
  closure verifier. Independence is established by bounded context, not by
  concurrent execution.
- Allocate one physical-agent identity when a role thread is created. Every
  later turn reusing that thread retains the same identity; a planned handoff or
  replacement receives both a fresh thread and fresh physical identity.
- Present status and asks through the primary-facing CLI projection only.
- Keep an active work item's controller and App Server epoch alive across normal
  presentation detach. Reattachment resumes the same logical primary and starts
  a controller-owned status-synchronization turn from the durable projection.
- When any expected step fails, record the failed or blocked state and stop the
  affected workflow. Do not retry, restart, replace, or integrate automatically.

### 5. Exercise continuity without fault injection

- Perform one intentional CLI detach while authorized work is progressing and
  one later reattach to the same logical primary.
- Perform one planned agent handoff at a durable checkpoint. The old agent exits
  normally and is retired before the same exact worktree's exclusive ownership
  transfers. The checkpoint binds the controller-derived worktree digest and Git
  diff artifact; the replacement validates both and proves one bounded
  continuation before restart is proposed. This is not presented as crash
  recovery.
- Perform one informed, user-approved clean attempt restart to the exact runtime
  base snapshot. The old planner, implementer, and reviewers are retired; fresh
  role contexts begin from accepted intent, constraints, findings, and learning,
  not from the abandoned plan structure or hidden agent context.
- Record acceptance of the late product-constraint revision before the separate
  restart authorization. The two effects may derive from one informed user
  response but neither implies the other.
- Preserve every preceding event and artifact in the control plane so the final
  report can reconstruct the sequence.

### 6. Complete review, closure, and integration

- Run the ordered mandatory gates on real saved artifacts: proportional plan;
  fresh soundness/completeness and adversarial plan reviews through verified
  convergence; implementation; fresh correctness/quality and codebase-cohesion
  code reviews through convergence; fresh plan-to-code closure; native Codex
  hard review; and normal project validation.
- Keep findings and fixes longitudinally linked, but use only the iterations
  produced by the pilot; do not manufacture findings or adversarial schedules.
- Persist every validated ordinary or native code-review finding before asking
  the primary to disposition it. The exercised path inserts each validated
  source occurrence once; duplicate result delivery and replay are not claimed.
  A malformed result or source/candidate mismatch creates no finding rows and
  advances no gate.
- After any accepted code-changing finding, rerun every affected downstream gate
  before integration can be offered.
- After implementation or an accepted code-changing fix, the controller stages
  all Git-visible changes from the disposable repository, whose fixture ignores
  generated bytecode, and creates one immutable candidate commit whose direct
  parent is the exact attempt-base commit and whose tree is the complete current
  accepted implementation. Every superseding candidate is reconstructed with
  that same direct parent rather than being layered on an earlier candidate.
  Acceptance of a code-changing fix first makes the prior candidate and any
  approval packet integration-ineligible. The replacement is then reconstructed
  and
  verified; only verified success activates it and permits new receipts.
  Replacement failure leaves the workflow visibly blocked with no integration-
  eligible candidate.
- Derive the candidate tree identity, changed-path inventory, user-presented
  diff, and range-bearing `git diff --check <attempt-base>..<candidate>` result
  from the explicit `attempt-base -> candidate` pair; verify clean checkout
  status separately. Candidate-bound gates are ineligible until
  the controller verifies the direct parent, complete tree, and those derived
  artifacts before constructing the approval packet.
- Materialize a standalone checkout whose Git administration data is inside the
  review permission root. Independently prove its candidate SHA, parent, tree,
  changed-path inventory, and clean status before invoking native Codex with
  `review --commit <candidate-sha>`. Failure to inventory the commit or any Git
  fatal diagnostic makes the gate fail regardless of command exit status.
- Require the native command's final result to validate as one candidate-bound
  typed clean verdict or contract-shaped finding set. Command success without a
  valid result is not a receipt. Actionable findings follow the same
  disposition, fix, candidate-supersession, and affected-gate rerun rules as the
  independent code reviews. Compatible non-actionable findings remain persisted
  and may coexist with the candidate's satisfied native-review receipt.
- The controller constructs one immutable approval packet from the exact current
  candidate, plan, changed-path inventory, diff identity, applicable durable
  review/closure receipts, hard-review evidence, validation artifacts, and
  primary-visible summary. The user's typed decision binds that packet hash.
  Immediately before Git mutation, the controller revalidates the packet's
  candidate and exact receipt/evidence identities against current durable state;
  any supersession or mismatch blocks integration. Approval and final Git result
  remain separate append-only events that reference the packet and never alter it.
- Plan-review receipts are keyed to the exact accepted plan hash. Code-review,
  native-review, and validation receipts are keyed to the exact candidate SHA;
  closure is keyed to both plan hash and candidate SHA. No receipt from a prior
  attempt, another plan/candidate version, or a superseded candidate is eligible.
  Integration eligibility is derived only from compatible final outcomes and
  dispositions for the exact current candidate; callers cannot supply or
  assemble the receipt set placed in the approval packet.
- Validate the exact candidate checkout normally for its technology and show
  the candidate commit identity, changed-path inventory, and exact diff to the
  user through the immutable approval packet.
- Integrate only after typed explicit approval; otherwise leave the candidate on
  its isolated ref with a durable pending-approval state. Integration may only
  fast-forward the disposable `main` branch to the approved candidate, then
  verifies and records that exact resulting commit and tree.

### 7. Produce a plain-language prototype report

The final report contains:

- whether the complete narrative ran;
- the user-visible interaction timeline;
- the durable event and artifact lineage for every stage;
- the final code diff, tests, reviews, closure trace, and integration decision;
- every manual intervention or unsupported Codex behavior encountered; and
- an explicit list of deferred race, security, crash-recovery, and hardening
  claims.

The report is ordinary inspectable prototype evidence. It does not require the
exhaustive immutable packet and architecture verdict defined by the deferred
full-hardening plan.

## Site list and required behavior

- `NEW_CODEX_OPERATING_MODEL.md`: records the accepted validation-strategy ITD
  and keeps the authoritative-host ITD pending until this prototype is assessed.
- `poc/FULL_HARDENING_PLAN.md`: preserves the prior adversarial proof plan as a
  deferred hardening backlog rather than an active gate.
- `poc/controller.py`: owns the logical primary, role routing, asks, checkpoints,
  typed user-decision and role-outcome projection, detach/reattach presentation,
  handoff, restart/integration proposal handling, workflow state, and user-facing
  synthesis.
- `poc/kernel.py`: owns the minimal relational execution state, append-only event
  history, phase/decision algebra, first-class candidate-bound code findings,
  finding dispositions, approval-packet validation and separately linked
  authorization/integration events, candidate identity, current projections,
  artifact references, attempt lineage,
  primary-turn/action evidence binding, immutable thread-to-physical-agent
  affinity, paused rejection state, terminal failure/abandonment finalization,
  and the sole SQLite write path.
- `poc/transport/main.go`: retains the already proven stock-CLI gateway and needs
  changes only where normal detach/reattach requires them.
- `poc/roles/`: contains bounded primary, planner, implementer, review, and
  closure-verifier role contracts used by the prototype.
- `poc/run.sh`: retains the historical proof runner without becoming the pilot
  entry point.
- `poc/run-prototype.sh`: owns the ordinary pilot launch arguments, bounded
  environment, component readiness, exit propagation, and evidence location.
- `poc/native-cli-prototype.sh`: launches the stock Codex CLI through the
  controller gateway and preserves the intended normal detach/reattach boundary.
- `poc/pty_tui.py`: owns the native terminal presentation bridge, intentional
  detach behavior, later reattachment, and visible propagation of launch or
  presentation failure.
- `poc/fixture/`: seeds the exact disposable normalization-CLI task, explicit
  duplicate-removal and small-input contract, direct in-memory reference,
  versioned proposed bounded-memory constraint, two spill-backend options,
  expected output, tests, generated-artifact ignore rules, repository boundary,
  snapshot boundary, and validation commands.
- `poc/prototype.py`: realizes the bounded happy-path orchestration, creates and
  supersedes immutable candidate commits, materializes the standalone native-
  review checkout, obtains structured primary grounding and result decisions,
  registers validated ordinary and native code findings before disposition,
  constructs the exact approval packet from existing candidate/evidence records,
  preserves a rejected restart or integration proposal as paused work, finalizes
  failures before cleanup, retains physical identity across thread reuse, and
  refuses any semantic or artifact-identity mismatch.
- `poc/assert.py` or a smaller prototype verifier: checks only the acceptance
  narrative and prevents a false happy-path success claim.
- `poc/test_controller.py`, `poc/test_kernel.py`, `poc/test_phase4.py`, and focused
  new tests where required: cover primary action provenance, non-actionable
  receipt eligibility, exact normal-path candidate-bound finding ingestion,
  immutable thread identity, paused rejection, restart-proposal waiting state,
  evidence-bearing root assessment, terminal failure ordering, the added normal
  transitions, and existing invariants
  without constructing the deferred adversarial matrix.
- `poc/REVIEW_LEDGER.md`: preserves historical hardening reviews separately from
  the new prototype's bounded review evidence.

## Temporal composition

The prototype is long-lived and includes pauses, reattachment, handoff, and a
clean attempt restart, so its normal transition protocol is explicit even though fault-tolerant
recovery is deferred.

| Event | Authority and next state | Durable record and visible effect | Retry or cleanup |
|---|---|---|---|
| Start | User-approved intent lets the controller move intake to active before assigning an agent. | Work-start event precedes agent creation. | No automatic retry. |
| Normal completion | Current role returns a typed structured outcome; controller validates/stages it, and a phase-compatible primary `decide_result` accepts or redirects it before advancement. | For code review, the exact result artifact and candidate-bound finding rows precede the primary decision; every outcome and artifact reference precedes completed state or the next assignment. | Agent worktree remains until its artifact is accepted. |
| Abnormal failure | Controller atomically records the affected work and attempt as failed or blocked before stopping it. | User sees the durable terminal reason through the primary; no success is projected. | No automatic retry; cleanup starts only after the terminal transition. |
| Pause | A durable ask or approval need blocks the affected assignment. | Pause reason and contextual ask exist before user notification. | No dependent work resumes meanwhile. |
| Resume | Primary emits a proposal-bound typed decision from the user's verbatim response; only an approved disposition records its named authority and eligible next effect. | Decision precedes any effect. Clarification applies nothing; complete rejection applies nothing; terminal intent-approve/restart-reject records only the revision and leaves work paused for a fresh direction. | Duplicate or non-authorizing answers are not new authority; restart never occurs without its prerequisite accepted revision, and no rejection implies resume or abandonment. |
| Presentation detach | Transport loses the current CLI while accepted work remains active or waiting. | Presentation generation closes; work, App Server epoch, and detached-period outputs remain durable. | Detach does not cancel work or start finalization. |
| Presentation reattach | A fresh authenticated CLI resumes the logical primary. | New presentation generation binds, then a primary status-synchronization turn renders the durable status contract. | Failure to render current status leaves presentation blocked, not successfully reattached. |
| Cancellation | User abandons the active work item or attempt. | Abandonment reason is retained; no integration occurs. | Execution worktree may be cleaned after evidence capture. |
| Handoff | Primary records a `handoff` decision against a checkpoint bound to the controller-derived worktree digest and Git diff, then retires the old physical run before transferring exclusive ownership of that exact worktree. | Both runs link to one work item, accepted plan, checkpoint, and transferred execution state; replacement validates it before progress proves the handoff. | No ownership overlap is allowed. A mismatch or failed handoff stops visibly and never falls back to hidden context. |
| Retry or replay | Not automatic in this prototype. | A user-directed retry creates a distinct linked attempt. | Earlier attempt remains immutable. |
| Process restart or crash recovery | Not claimed. Startup may display incomplete durable state but may not silently continue it. | Incomplete work is surfaced for user direction. | Automated reconciliation is deferred. |
| Rollback or compensation via clean attempt restart | Informed user approval binds the recommended attempt and exact runtime base snapshot; phase-only rewind is not exercised. | Old attempt becomes abandoned; execution-plane restore is verified before fresh planner, implementer, and reviewers start. | Control-plane history never rewinds; old hidden context and plan structure do not carry. |
| Candidate supersession | Acceptance of a code-changing fix first makes the prior candidate and any approval packet integration-ineligible, then reconstructs one complete replacement whose direct parent remains the exact attempt base. | The replacement's base/candidate tree, inventory, and diff identity must verify before it becomes current or new gates begin; any later packet is rebuilt from the replacement's exact receipts and evidence. | Superseded refs and packets remain evidence but cannot be authorized or contribute receipts; replacement failure leaves no eligible candidate and blocks visibly. |
| Terminal finalization | Work is completed and the exact candidate is integrated, the user explicitly abandons it, an unrecoverable visible failure occurs, or the operator explicitly terminates the prototype. Rejecting restart or integration is not terminal. | Terminal reason, candidate/result identity, and final status precede presentation/child cleanup. | Ordinary detach and rejected proposals are never terminal; operator termination records abandonment/interruption before cleanup. |
| Partial completion | Any artifact/effect without its expected durable transition leaves the step blocked, not successful. | The inconsistency is reported in the prototype evidence. | Recovery automation is deferred. |
| Concurrent overlap | One user-level work item is active; role stages are serialized except independent read-only reviews when deliberately launched together. | The controller remains the sole state writer and integration authority. | Unplanned overlap is rejected or stopped visibly. |

### Effect ordering

- Accepted intent is durable before work starts.
- Verbatim intake is durable before grounding begins.
- The primary's exact typed grounding is durable and bound to its thread and
  turn before accepted intent activates work.
- An assignment and its context references are durable before an agent turn.
- A staged agent result is durable before the primary decision that accepts,
  redirects, or hands it off.
- The primary's typed result decision and its output artifact are bound before
  the corresponding action can change outcome or receipt eligibility.
- An ask or approval requirement is durable before execution pauses or the user
  is notified.
- An approval proposal's exact subject and successful immutable approval packet
  are durable before the user's response can authorize any effect; the response
  and primary decision bind that same presentation. For a terminal mixed restart
  decision, the approved intent revision is durable while restart remains
  unauthorized; clarification persists no partial effect.
- An agent outcome and referenced artifact are durable before the next stage or
  completion is visible.
- An accepted intent revision is durable before it can inform restart; separate
  restart authorization is durable before the execution plane changes. Verified
  restoration precedes every fresh role assignment.
- Candidate identity, exact applicable receipts/evidence, and the immutable
  approval packet are durable before the integration decision. The typed approval
  binds that packet before the pilot branch changes; immediate revalidation and a
  separate verified fast-forward result event precede completion.
- Every candidate-bound review and validation consumes the full
  `attempt-base -> candidate` change. Acceptance of a code-changing fix first
  makes the prior candidate and any approval packet ineligible. The replacement then
  proves the same direct-parent and complete-tree invariants; only successful
  verification makes it current and allows any new receipt. Failure remains
  blocked with no integration-eligible candidate.
- A native-review receipt is durable only after Git inventory proof, exact result
  persistence, first-class finding ingestion, and compatible primary dispositions
  bind the current candidate. A malformed result or unresolved actionable finding
  cannot coexist with an eligible receipt; compatible non-actionable findings can.

### Execution ownership

The controller owns workflow state, SQLite, agent lifecycle, presentation
mapping, and Git integration authorization. The logical primary owns semantic
understanding and user communication. Each role agent owns only its current
bounded assignment and worktree. A handoff accepts the checkpoint, retires the
old run, and only then transfers exclusive ownership of the checkpoint-bound
worktree state to the replacement. Retained thread context and physical-agent
identity have the same lifetime; replacements change both together. The user
remains the authority for unresolved product decisions, attempt restart, final
integration, and abandonment after a rejected proposal.

### Concurrency constraints

Only the controller writes canonical state. Agents never share a writable
worktree. One user-level work item is active. Independent reviewers may inspect
the same immutable artifact, but their outputs are integrated serially by the
primary. The prototype does not claim correctness for competing presentations,
simultaneous mutations, or crash-time overlap.

### Deliberate composition cases

The acceptance run constructs only three normal compositions:

- agent work continues across an intentional CLI detach and later reattach;
- a post-restart planner ask pauses planning and the recorded primary answer
  resumes it; and
- a planned handoff proves bounded continuation before a late constraint leads
  to an informed, user-authorized clean restart from the exact base snapshot.

Adversarial reorderings and injected failures remain in the deferred plan.

## Completion gate

The active plan is complete when the specified disposable coding outcome runs
through the entire acceptance narrative, the final report exposes all evidence
and limitations, and the user can judge the experience from the native primary
interface. A failure at any step is a useful prototype result and must be
reported honestly; it does not authorize infrastructure hardening beyond the
smallest change needed to determine whether the happy path itself is viable.
