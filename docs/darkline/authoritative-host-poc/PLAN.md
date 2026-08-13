# Voice-First Primary-and-Agents MVP Prototype Plan

**Problem:** Demonstrate one real low-stakes coding outcome through the defining
voice-first operating model without turning the prototype's proof harness into
the product.
**In scope:** One project context, one active user-level work item, one
accountable logical primary, bounded role agents, a primary-owned SQLite work
ledger, bidirectional execution checkpoints and asks, PM-style agent monitoring,
planned worker context handoff, one automatic physical-primary session rebind,
one separately accepted intent revision and
independently assessed, user-authorized clean attempt restart, proportional plan
review with a three-version automatic-iteration checkpoint, correctness and
cohesion code review, one fresh native Codex hard-review
gate, one immutable candidate commit, first-class candidate-bound code findings,
final validation and closure, risk-proportional independent semantic
confirmation for positive restart/integration authority and plan implementation
start, one controller-owned bounded notification-window lifecycle for exact
App Server model-turn action authority, and explicit user
approval before the disposable repository is integrated, followed by user
review of the genuine pending authoritative-host ITD against the completed PoC
evidence. Every governed semantic transition is covered by one closed
producer-to-effect authority inventory, including explicit accountable-primary
adoption of delegated results and checkpointed plan-review convergence.
**Out of scope:** Concurrent unrelated user workstreams, production deployment,
hostile or simultaneous clients, controller/database crash injection and
general automatic recovery beyond the bounded physical-primary rebind,
exactly-once external effects, comprehensive race or fault-tolerance proof,
natural-language classification in Python, a closed approval phrase grammar,
an exhaustive P01-P18 runtime proof matrix, complete source/executable
provenance, canonical full-database projection proof, a special terminal PASS
process, the full project-brain/inbox roadmap, automated finding-pattern
assessment, backtesting evaluation, and general model/cost optimization beyond
the one explicit configurable low-cost observer role. Also out of
scope is a generic authorization framework or a new first-class plan-finding
subsystem; the prototype uses exact transition-specific contracts and keeps
plan findings in immutable review results. The governed executable supports the
ordinary stock-CLI primary only; `ConsolePrimaryInterface` remains a test double,
and `--console-ui` is rejected/removed rather than becoming a second governed
intake protocol. Arbitrarily large ledger/history prefixes, context projection,
chunked continuity transport, and portability across smaller-context models are
also outside this PoC: its fixed re-prime/drain/steering payloads are exercised
only with the bounded fixture and live-run corpus that fits the pinned model's
available context. A Byzantine App Server that
deliberately relabels an action as belonging to an unrelated valid thread is
also outside the controller's provable identity boundary.

## Objective and claim boundary

The prototype answers one question: can a voice-first user work through one
accountable Codex primary that operates a small internal agent team while a
programmatic control plane preserves context and mechanically enforces the
settled workflow?

A successful run establishes only that:

- the native CLI, controller/gateway, App Server, SQLite ledger, and bounded
  agent topology can provide the intended happy-path experience;
- the primary can preserve intent and execution continuity across one planned
  worker handoff and one automatic physical-primary session rebind;
- the exercised planning, monitoring, ask, intent-revision, restart, candidate,
  review, validation, closure, approval, and integration transitions compose
  correctly; and
- the final disposable Git result is the exact candidate reviewed and approved.

It does not establish production-host suitability, hostile-client security,
controller/database crash recovery, arbitrary interleaving safety, or a general
proof framework. It also does not establish continuity for an arbitrarily large
ledger or a different model context limit. A physical-primary session loss uses
the one bounded rebind path below. Other unexpected failures—including a provider
context-capacity rejection—follow the exact existing owner-specific failure path
and preserve the available ledger state; this prototype does not add capacity-
aware recovery, projection, chunking, or retry.

The existing Phase 1-4 gateway work is capability evidence. The previous
approval grammar, occurrence/cue protocol, P01-P18 proof system, provenance
closure, and terminal auditor are exploration history, not inherited product
requirements.

## Grounded behavioral requirements

The prototype must visibly demonstrate these user-settled outcomes; the
authority-transition inventory and temporal-composition section below are the
normative mechanical contracts.

1. The user interacts with one accountable logical primary. Relevant context is
   gathered before interpretation; program code treats natural text as opaque,
   and the primary resolves semantics and uncertainty.
2. SQLite preserves product/workflow state and relationships while Git preserves
   implementation artifacts. One global ledger order supports physical-primary
   replacement without changing logical-primary identity.
3. Initial primary activation and the sole automatic rebind use fixed finite
   prefixes and bounded candidate attempts. Successful recovery requires no user
   operation; failure visibly preserves work and accepts no stale authority.
4. Delegated reports and outcomes are provisional evidence until exact turn and
   action settlement. The primary remains accountable for adoption, direction,
   handoff, and user communication.
5. A continuing worker is never routinely stopped by elapsed time, action count,
   cadence, or observer output. One read-only observer may run while it works;
   one pending observation coalesces, repeated observer failure reaches primary
   attention, and the observer has no messaging, stop, or decision authority.
6. Attention-bearing observation reaches the next available logical-primary
   operation without waiting for a worker checkpoint. The primary alone chooses
   `continue`, exact-turn `steer`, internal `pause`, or user `escalate`;
   ordinary compatible same-turn progress does not invalidate intervention.
7. Explicit agent asks block only dependent work. The primary answers ordinary
   technical questions and asks the user only for missing product knowledge,
   scope/authority, or a genuine Important Technical Decision.
8. Every genuine ITD persists its problem, valid options, option-specific pros
   and cons, and decision, linked to affected intent and work.
9. Planning and implementation are separate. Independent soundness and
   adversarial reviews must close the exact plan; after three automatic versions
   the user reviews progress. Every closed plan still requires compact,
   voice-first, exact-consequence user authorization before coding.
10. Code review covers correctness and architecture cohesion, followed by one
    fresh native hard-review gate. Findings remain tied to immutable candidate
    commits, and final closure checks the reviewed implementation against the
    accepted plan with neither omissions nor extras.
11. Intent revision, implementation rewind, candidate integration, and
    abandonment remain separate transitions. Rewind and integration require
    explicit current user authority; rejection or clarification preserves work.
12. Runtime enforcement covers runtime facts; build, initialization, tests, and
    reviews own code and structural correctness.
13. Waiting, blocked, failed, or incomplete states receive a compact primary
    summary. Internal pause says no user action is needed and names its next
    action/resume condition; escalation alone asks one concrete user question.
14. This PoC claims continuity only for its bounded fixture/live corpus within
    the pinned model context. Arbitrarily large history, projection, chunking,
    and smaller-context portability are explicitly deferred under Decision 11.

## Architecture decisions

### Decision 1: semantic authority and risk-proportional positive confirmation

**Problem:** The primary can misunderstand a voice response, but program code
must not become a competing natural-language authority.

#### Option 1: primary interpretation alone

Pros:

- preserves the simplest conversational path; and
- keeps semantic ownership entirely with the accountable primary.

Cons:

- one model interpretation can directly authorize a high-stakes effect.

#### Option 2: primary interpretation plus independent positive-effect confirmation

Pros:

- removes the primary as the sole semantic failure point for restart,
  integration, and closed-plan implementation-start approval;
- keeps natural-language understanding in models rather than Python; and
- incurs extra work only on the high-stakes branch.

Cons:

- adds one model call and possible latency for a positive effect; and
- correlated model errors remain possible, so this is risk reduction rather
  than formal semantic proof.

#### Option 3: deterministic Python approval grammar plus primary interpretation

Pros:

- produces a closed machine classification.

Cons:

- moves semantic authority into the wrong layer;
- makes voice interaction brittle; and
- creates phrase, normalization, timing, reconciliation, and presentation
  machinery unrelated to the core workflow.

#### Decision

Choose Option 2. The primary and an independent one-shot semantic verifier each
receive the exact pending proposal and verbatim user response without seeing
the other's output. Each returns a schema-constrained typed disposition. The
verifier accepts only proposal kinds `restart`, `integration`, and
`proceed_closed_plan`; its output binds the exact kind, proposal/checkpoint,
response, plan/candidate where applicable, and positive/no-match disposition.
A positive restart/integration effect or closed-plan implementation start
requires exact agreement. Any disagreement, invalid output, or verifier failure
applies no effect and returns to the primary for clarification.

The second model is not invoked for rejection, revision, clarification, defer,
or explicit abandonment. In this PoC abandonment only terminalizes the workflow
while preserving all evidence; it performs no cleanup or external effect. Stakes
belong to the resulting typed effect, not to a word:
if a future nominal rejection can delete, abandon, or otherwise cause a
material effect, that branch must be reclassified as high stakes before use.

The controller validates only structured fields, identities, current state, and
the presence of the required independent confirmation. It never interprets the
verbatim text. Model selection and effort remain configurable and are not
optimized in this prototype.

A presented user decision becomes response-eligible only after the exact proposal
is a completed primary turn and is fully rendered in the current presentation.
Input submitted before that boundary cannot attach to it. Detach, presentation
replacement, or physical-primary rebind before response admission closes that
window and requires complete re-presentation under the current binding. A
response durably admitted before rebind may instead use the bounded pending-input
reissue path. This one completed-turn/render rule applies to revised intent,
plan checkpoint/final authorization, restart, integration, abandonment, and ITD;
it is structured state, not phrase classification. Any newer admitted user turn
still invalidates an older consequential outcome before its serialized boundary.

The bound response also opens one approval epoch. User input is durably ordered
within the current presentation. Any newer user turn recorded before the
controller's serialized effect-start boundary invalidates the pending positive
interpretations and authority, applies no effect, and returns the newer turn to
the primary. The effect-start transition closes the epoch only after confirming
that the response is still the newest user input. A turn arriving after an
external effect has started cannot retroactively cancel that operation and is
handled as the next user direction.

The user-facing sequence is explicit consequence proposal, brief confirmation-
pending feedback that says no effect has occurred, then either an applied/result
acknowledgement or a no-effect clarification naming what remains preserved and
one concrete next question.

Confirmation-pending keeps the governed stock-CLI presentation open for a newer
correction. The initial response admission opens one exact correction-capture
window bound to that approval epoch. Receipt of opaque text first reserves its
existing captured-response control attempt and blocks effect start; clean
capture finalization admits the next ordinary `input_seq`, invalidates the older
positive authority, and returns that input to the primary. If detach or capture
failure wins, the older effect remains no-effect and the proposal must be
re-presented. Effect start and correction-attempt reservation serialize through
the same writer: if effect start wins first, a later input is ordinary next
direction and cannot retroactively cancel the started effect. Program code never
classifies the correction text.

The presentation exposes that boundary mechanically. Detach/rebind renders that
listening is paused and already admitted input/work is preserved. If a capture
loses admission, the fixed notice says that the last response was stored but not
accepted, caused no effect, and will require complete re-presentation. Listening
reopens only after the current presentation and exact proposal are fully rendered;
the next clean capture is then acknowledged once. Pre-work capture failure uses
the analogous stored-versus-accepted distinction and names only the mechanically
permitted next action. These fixed states add no primary interpretation or new
retry authority.

### Decision 2: policy enforcement and validation phase

**Problem:** The workflow must prevent mechanically invalid transitions without
using runtime validation as a substitute for correct code.

#### Option 1: independently re-prove the full workflow before every stage

Pros:

- provides an explicit proof result for every named stage.

Cons:

- duplicates transition logic;
- moves code completeness into runtime; and
- requires manually maintained evidence universes and proof call sites that can
  themselves omit members.

#### Option 2: enforce policy by construction at transition boundaries and validate at the earliest responsible phase

Pros:

- a transition cannot occur without its typed prerequisites;
- static defects are caught before a run; and
- runtime checks remain limited to current state, identity, availability, and
  actual external results.

Cons:

- controller transition contracts and their tests must be complete; and
- code review remains responsible for detecting missing call paths.

#### Option 3: trust agent behavior and verify only at the end

Pros:

- has the smallest controller surface.

Cons:

- dependent work or effects can occur before an invalid transition is noticed.

#### Decision

Choose Option 2. There is no generic runtime proof matrix and no separately
assembled P-ID validator. The controller exposes the only mutation/effect paths
for governed workflow state. Each path checks the actor, current state, exact
referenced identities, and required durable predecessors as part of that
transition.

Validation ownership is:

- **Build/test/review:** schemas, complete call-site coverage, role permissions,
  transition logic, candidate construction, and absence of Python semantic text
  processing.
- **Initialization:** SQLite schema/migrations, required App Server protocol
  capabilities, Git/worktree availability, configured model access, and writable
  project/runtime boundaries.
- **Runtime:** actual current state, actor and object identity, unresolved asks,
  model-call results, independent confirmation when required, worktree/candidate
  identity, external command results, and stale/superseded records.
- **Final validation/closure:** product output, accepted-plan coverage, exact
  reviewed candidate identity, unresolved findings, and final Git read-back.

The final report is a human-readable ledger/Git summary. It is not a second
semantic authority, a full database replica, or the owner of a special PASS
claim.

### Decision 3: authoritative durable state

**Problem:** Context and workflow state must survive model compaction and
physical-session or worker replacement without making agents concurrent writers
or duplicating Git.

#### Option 1: transcript and Git history only

Pros:

- introduces no project database.

Cons:

- does not provide queryable pre-work intent, asks, decisions, blockers, or
  agent continuity.

#### Option 2: one primary-owned relational SQLite ledger plus Git artifact identity

Pros:

- provides queryable semantic state and relationships;
- lets Git remain authoritative for source snapshots and candidate identity;
  and
- gives replacement contexts a bounded re-prime source.

Cons:

- requires a single-writer boundary and explicit transition ownership.

#### Option 3: every agent writes shared durable state directly

Pros:

- avoids routing agent reports through the primary/controller.

Cons:

- creates conflicting semantic writers and ordering ambiguity.

#### Decision

Choose Option 2. The logical primary is the semantic writer; the controller is
the sole physical SQLite writer and effect executor. Agents communicate through
typed reports and primary-agent conversation. Git owns implementation snapshots,
trees, diffs, and commits; SQLite stores their identities and product/workflow
relationships rather than duplicating their contents.

The minimum ledger relates:

- work items and versioned accepted intent;
- attempts and execution snapshots;
- primary decisions and genuine ITDs with their problem, options, per-option
  pros/cons, and decision;
- plans and immutable plan versions;
- agent assignments, runs, checkpoints, asks, ordered conversation messages,
  and outcomes;
- role outputs and evidence referenced directly by their owning records;
- immutable Git candidates and their base/tree/diff identities;
- review runs, first-class candidate-bound code findings, dispositions, and
  validation/closure results; and
- append-only workflow transition history.

Every controller-owned semantic transition records its durable state in the
same SQLite transaction. External effects use a durable requested/in-progress
record before execution and a result record after read-back. If the process
cannot complete both sides, it reports the incomplete state and stops; automatic
reconciliation is deferred.

### Decision 4: immutable candidate as review and integration identity

**Problem:** Code review, validation, user approval, and integration must refer
to one complete source state, including files that were previously untracked.

#### Option 1: mutable worktree diff through all gates

Pros:

- avoids creating a pre-integration commit.

Cons:

- leaves multiple mutable representations and can omit untracked content.

#### Option 2: one complete attempt-base-to-candidate commit

Pros:

- gives every gate one native Git identity; and
- lets integration fast-forward the exact object already reviewed and approved.

Cons:

- creates an isolated candidate commit before main-branch integration.

#### Decision

Choose Option 2. Candidate construction includes every intended tracked,
unstaged, and untracked file. Reviews and validation use an isolated checkout of
that commit and compare it to the attempt base. A code-changing fix supersedes
the entire candidate with another direct child of the same attempt base.
Integration may only fast-forward the disposable `main` to the exact currently
approved candidate after immediate Git read-back confirms that it remains
current.

### Decision 5: closed authority-transition composition

**Problem:** Successive review epochs found valid but different missing links
between an exact model/agent output and the durable state or effect attributed
to it. Fixing only the latest call site can leave the next consumer unexamined.

#### Option 1: one closed transition inventory plus transition-specific contracts

Pros:

- makes every producer, accountable adoption, current-state gate, user authority,
  and durable effect visible in one reviewable artifact;
- closes the repeated root rather than only its latest symptom; and
- preserves the existing small controller instead of creating a second policy
  system.

Cons:

- requires a top-down pass across existing role, plan, review, decision, and
  effect paths; and
- the inventory must remain synchronized when a governed transition changes.

#### Option 2: repair only E18-CR-001 through E18-CR-003

Pros:

- is the smallest immediate code patch.

Cons:

- repeats the local-fix pattern that exposed one further authority gap in each
  restarted review epoch; and
- provides no evidence that sibling transitions are closed.

#### Option 3: add a generic authorization and event framework

Pros:

- could represent many future workflow shapes.

Cons:

- adds new authority, lifecycle, and protocol surface beyond this MVP;
- duplicates the typed transition contracts already owned by the controller;
  and
- makes a bounded composition problem harder to review.

#### Decision

Choose Option 1. The following inventory is the architecture closure artifact
for this prototype. A governed semantic transition is closed only when its exact
producer is eligible, its required accountable adoption or explicit exception
is durable, every referenced artifact is still current, any required user
authority is exact, and the resulting state/effect is recorded. Omission of one
link blocks advancement; it is not repaired by a caller-supplied label such as
`accepted_by="primary"`.

### Decision 6: authoritative native hard-review findings

**Problem:** The fresh native Codex review should remain free to discover issues
in its normal unstructured form, while the ledger requires typed, candidate-
bound findings. Program code must not interpret the prose, and structuring must
not silently replace the source review.

#### Option 1: require the native CLI review itself to return structured JSON

Pros:

- uses one model invocation; and
- custom `codex review` instructions can request the required shape.

Cons:

- the CLI does not mechanically enforce an output schema; and
- formatting constraints can compete with unconstrained holistic discovery.

#### Option 2: preserve raw native review and use the shared model NLP runner

Pros:

- keeps the direct native CLI discovery output unchanged and authoritative as
  source evidence;
- reuses the same tool-less, schema-constrained runner primitive used for other
  low-effort language interpretation such as approval confirmation;
- allows a configurable faster/lower-effort model for this non-authoritative
  transformation; and
- each invocation remains a one-turn terminal operation under the normal work
  budget.

Cons:

- adds one inexpensive model invocation; and
- semantic mapping completeness still requires accountable primary judgment.

#### Option 3: parse native prose mechanically in Python

Pros:

- avoids the additional model invocation.

Cons:

- reintroduces prohibited natural-language interpretation in program code; and
- is brittle to wording and output-format changes.

#### Decision

Choose Option 2. The controller runs direct `codex review --commit <candidate>`
with the accepted custom review focus in an isolated checkout and preserves the
exact command target, exit status, stdout, and stderr. A distinct stateless
structuring subagent then consumes the complete raw review through the shared
tool-less model runner and returns the common finding schema in one terminal
turn. The raw CLI result remains immutable source evidence; the adopted
structured set is the ledger's operational finding representation.

Each structured finding carries an exact raw text anchor that the controller
can verify by byte membership without interpreting meaning. Exact primary
adoption consumes the raw and structured artifacts and must affirm that no
material raw finding remains unmapped. Native command failure, structurer
failure, schema failure, missing or invented anchors, or primary inability to
affirm completeness blocks the native gate. The structurer alone never decides
cleanliness, disposes a finding, or authorizes progress. Broader model/cost
optimization remains out of scope; this bounded adapter's model and effort are
configurable and may use the faster/lower-effort setting selected for simple NLP.

### Decision 7: shared continuity and user-decision protocols

**Problem:** Repeating physical-primary ownership and user-response eligibility
inside every workflow transition creates sibling gaps and prevents plan-review
convergence.

#### Option 1: keep every transition fully bespoke

Pros:

- avoids naming shared control-plane primitives.

Cons:

- repeats the same binding, presentation, currentness, and failure rules;
- has already produced contradictory initial/rebind and decision surfaces; and
- makes each new decision kind another default-by-omission risk.

#### Option 2: two bounded shared protocols with kind-specific payloads

Pros:

- one primary binding/continuity protocol closes initial activation, rebind,
  frontier/catch-up, in-flight input, and no-primary failure behavior;
- one user decision envelope closes render, response, detach/rebind, newest-turn,
  interpretation, optional co-sign, and transition ordering; and
- workflow rows retain their exact kind-specific evidence and permitted effect.

Cons:

- adds two explicit shared contracts and requires every participating site to
  bind their identities.

#### Option 3: a generic authorization and recovery framework

Pros:

- could generalize to arbitrary workflows, clients, and recovery policies.

Cons:

- materially exceeds the one-work-item low-stakes MVP;
- recreates the proof harness as product architecture; and
- introduces extensibility and operator lifecycle not required by this run.

#### Decision

Choose Option 2. The two protocols consolidate already accepted behavior; they
do not add user-visible choices or generic extensibility. The primary
binding/continuity protocol owns who may act as the logical primary and how that
physical binding moves. The user decision envelope owns when a verbatim response
may authorize one named semantic transition. Individual workflow transitions
provide only their exact subject, allowed typed dispositions, verifier policy,
and resulting state/effect.

### Decision 8: App Server model-turn notification-window ownership

**Problem:** Consequential App Server action authority comes from live
notifications, because the later `thread/read` snapshot may omit action items.
Agent-role turns, post-binding primary semantic calls, and primary-binding
continuity acknowledgements can each unlock durable state. The current
controller instead spreads notification integrity across caller categories,
armed threads, pre-binding buffers, active monitors, reader status, caller
waits, monitor removal, and later kernel settlement. Repeated review findings
show that category-local patches leave gaps at the transitions between those
states.

#### Option 1: one bounded controller-owned notification lifecycle

Pros:

- gives receipt ordering, exact-turn binding, action admission, turn terminality,
  stream failure, and final settlement one owner and one fail-closed path;
- preserves complete host-derived action authority for every model result that
  can unlock durable state even when `thread/read` exposes only the final
  conversation snapshot; and
- reuses the kernel's existing durable role-turn, primary-attempt, and binding-
  candidate records rather than creating a second authority store.

Cons:

- adds a private finite lifecycle and bounded receipt queue to the controller;
- requires a small explicit finalization seam between controller, runtime, and
  kernel; and
- requires the architecture plan and code-review flow to restart before the
  PoC can continue.

#### Option 2: trust a narrower App Server provider contract

Pros:

- keeps the controller simpler; and
- avoids retaining notification identity after a governed turn appears complete.

Cons:

- weakens the accepted proof that every governed role or primary action is
  within its host settlement/capability boundary; and
- cannot reconstruct omitted actions from `thread/read` when notification
  evidence is incomplete.

#### Option 3: defer the action-authority proof

Pros:

- stops architecture growth in the current PoC; and
- preserves the existing evidence for a later attempt.

Cons:

- leaves the current MVP incomplete; and
- discards the already working primary/agent path instead of correcting its
  bounded lifecycle seam.

#### Decision

Choose Option 1, as selected by the user on 2026-08-11. The controller owns one
private lifecycle with exactly three subject adapters: assigned agent-role turn,
post-binding primary call attempt, and prompt-only primary-control-plane attempt. Every
consequential App Server model call uses one of them:
`armed -> binding/replay -> active -> turn-terminal/settling -> settled/fenced`.
The lifecycle preserves ordered receipt evidence from before exact turn binding
through durable kernel settlement or fence. It adds no generic event framework,
second database, automatic recovery policy, or new user-visible decision.

The primary-control-plane adapter has a closed purpose set: initial stock-resume
bootstrap materialization; binding candidate or active-binding re-prime and
catch-up; binding-installed confirmation; presentation attach or reattach;
captured-response acknowledgement; and outside-response-window notice. Every
authority-bearing primary-thread `turn/start` must be classified into either a
post-binding semantic attempt or one of these exact prompt-only purposes before
send; every other direct primary-thread turn is rejected. The legacy Phase-3
transport seed remains outside the ordinary MVP initialization path.

#### Control-plane durable subject choice

**Problem:** Bootstrap and initial attach occur before a user work item exists,
so the work-item-bound `primary_call_attempts` table cannot truthfully own every
primary-control-plane turn.

##### Option 1: one bounded control-plane-attempt table

Pros:

- keys every attempt to the existing pre-send controller operation while
  allowing an optional exact work item, binding epoch, or candidate identity;
- preserves the real pre-intake lifecycle without a fake work item or nullable
  semantic-primary record; and
- remains one small table in the existing SQLite control plane, not a second
  authority store or generic model-call registry.

Cons:

- adds one durable table and subject-specific kernel methods; and
- requires the presentation and binding paths to supply exact typed purpose and
  identity fields before forwarding a turn.

##### Option 2: make the semantic primary-attempt table pre-intake-capable

Pros:

- avoids a new table.

Cons:

- makes work-item and semantic-operation identities nullable or artificial;
- broadens established semantic-call invariants for presentation/bootstrap
  mechanics; and
- increases migration and caller risk across otherwise sound primary attempts.

##### Option 3: eliminate or reorder all pre-intake model turns

Pros:

- removes the need for a pre-work durable subject.

Cons:

- conflicts with the stock CLI's required rollout materialization and initial
  attach flow; and
- turns a bounded lifecycle correction into a larger UI/intake redesign.

##### Decision

Choose Option 1. `primary_control_plane_attempts` references the existing
pre-send `operations.op_id`, records one exact closed purpose, thread/turn,
one closed owner class and mechanically derived failure disposition, optional
candidate/binding/work/presentation identity, opaque captured-input payload when
applicable, deadline, routed receipt frontier, and terminal state. Because every
purpose is prompt-only, any action start is a violation recorded on the attempt;
no separate action-inventory table is needed.

#### Primary-endpoint ownership and handoff

**Problem:** A durable notification attempt identifies one model turn, but it
does not by itself identify who owns failure or which presentation may release
input. Before intake there is no work item, candidate episode, or active binding;
after rebind the semantic-primary and stock-CLI presentation thread can diverge;
and capture finalization can race presentation detach. Site-local failure routing
would therefore leave the same lifecycle gap under a different name.

##### Option 1: patch each bootstrap, attach, capture, and rebind site locally

Pros:

- has the smallest immediate code delta.

Cons:

- preserves independent notification, semantic-thread, and presentation owners;
  and
- is likely to leave another sibling gap across retry, detach, or reattach.

##### Option 2: one bounded primary-endpoint transition contract

Pros:

- gives every control-plane attempt one truthful owner/failure disposition;
- switches semantic and presentation routing through one controller-owned
  handoff and serializes capture release with presentation invalidation; and
- reuses `primary_control_plane_attempts` and existing binding/presentation
  state without a second table or generic lifecycle framework.

Cons:

- adds an explicit controller/kernel/native-interface transition seam; and
- requires stock-CLI attach to target an explicit candidate thread rather than
  an independently cached presentation thread.

##### Option 3: create intake and activation before bootstrap/presentation

Pros:

- lets all control-plane attempts reference an existing work-item binding.

Cons:

- is circular for the voice-first request that creates the work item; and
- requires a provisional/dummy work item or a larger intake/UI redesign.

##### Option 4: remove transparent rebind or pre-intake primary presentation

Pros:

- removes some endpoint-lifecycle obligations.

Cons:

- materially reduces already accepted primary-session behavior; and
- solves an implementation seam by changing product scope.

##### Decision

Choose Option 2, as selected by the user on 2026-08-11. The closed owner classes
are `pre_work_startup`, `binding_candidate`, and `active_binding`; purpose plus
current typed state mechanically selects one before send. A pre-work failure
terminalizes its attempt, fences the provisional thread, preserves any captured
text, emits fixed mechanical startup-failure facts, and stops with no automatic
candidate/rebind attempt. A binding-candidate failure consumes only the existing
two-candidate episode. An active-binding failure uses only the existing thread
fence/rebind path.

Candidate confirmation is addressed directly to the candidate thread without
changing global semantic or presentation routing. A clean confirmation permits
one endpoint handoff: invalidate/detach the old presentation, explicitly attach
the stock CLI to the candidate under its own clean control-plane attempt, and
only then make the new semantic thread, presentation thread/generation, and
endpoint readiness current together. The initial activation may promote the
already-clean pre-work presentation only when its exact thread/generation still
matches and no capture is unresolved. Until handoff completes, neither semantic
work nor presentation input may use the candidate; old/fenced thread turns are
rejected.

Physical candidate attach also reserves an exact non-current presentation lease
under that candidate/control-plane attempt: candidate thread, presentation
generation, stock-CLI process/PTY identity, and transport session. The lease is
candidate-owned from process launch until endpoint handoff or proven teardown.
Any attach, clean-finalization, candidate, or endpoint-handoff failure first
fences the candidate and invalidates the generation, then stops/detaches and
quiesces the exact process/session under the existing bounded cleanup. Candidate
two may start only after teardown proves the prior process/session absent. If
teardown cannot be proven, the episode terminalizes as `primary_start_failed` or
`rebind_failed` with the actual attempt count and cleanup reason; it cannot spend
another candidate, expose readiness, or claim quiescence. The already-attached
pre-work presentation transfers into candidate-one ownership when activation
registers that exact thread/generation and follows the same rule if candidate one
later fails.

The current endpoint also has an exact presentation lease. Beginning rebind
transfers that old lease to the episode's cleanup ownership, invalidates its
generation, and proves the stock-CLI/process/PTY/transport session absent before
provisioning or physically attaching any replacement presentation. If old-
endpoint teardown cannot be proven, `rebind_failed` terminalizes immediately
with candidate count zero and the cleanup reason; the episode cannot spend a
candidate or race a second physical presentation against the old session.

Opaque capture storage alone is not input admission. Capture clean-finalization
and detach/rebind invalidation for the same presentation generation compete in
one serialized kernel boundary. If clean finalization wins, it records one exact
release: a pre-work capture yields a one-use intake token, while a post-intake
capture receives its immutable `input_seq` in that transaction. One specialized
token-consumption transaction validates that token as clean/current/unused and
atomically creates the work item, unbound primary state, and the sole canonical
initial `user_inputs` row from the token's stored capture identity and verbatim
text with `input_seq = 1` and pre-binding epoch; it marks the token consumed,
links and returns that input identity, and forbids a later second admission.
`WorkflowEngine.execute` consumes that returned identity for activation and
initial-intent interpretation instead of calling raw `kernel.intake()` and later
`admit_opaque_user_text()` for the same request. If invalidation wins, the text remains durable but
unreleased, later release is impossible, and the presentation must be shown
again; a pre-work capture failure stops startup instead. The acknowledgement
turn never authorizes admission from bare `turn/completed` or an in-memory queue.

Every governed user capture returns one typed result, not raw text alone. Before
work exists it contains the exact startup token/capture identity, generation, and
bound verbatim text. After intake it contains the exact already-admitted
`input_id`, immutable `input_seq`, presentation generation, and bound verbatim
text. `PrimaryInterface.request` returns the applicable form; `response` always
returns the post-intake form. `WorkflowEngine` consumers use/link that identity
without another admission. If clean capture finalization wins and detach follows
before the method returns, the durable admitted handle still wins and is
returned; if invalidation wins, no handle can be returned and re-presentation is
required. The governed native interface obtains handles from controller
finalization. Scripted tests pre-create valid token/admitted-input handles through
the same kernel contracts. Stale/wrong/mismatched or raw-text-only results are
rejected. The console test double cannot enter the governed executable flow.

### Decision 9: non-blocking agent observation

**Problem:** Routine PM-style monitoring must detect drift or blockers without
interrupting productive agent work or continuously consuming the accountable
primary's context and model budget.

#### Option 1: the primary directly monitors every routine checkpoint

Pros:

- gives the accountable primary the richest context.

Cons:

- pollutes primary context with routine progress; and
- spends the most expensive decision-maker on non-authoritative observation.

#### Option 2: controller-dispatched low-cost observer agent

Pros:

- observes immutable durable evidence without stopping the worker;
- gives the primary a compact evidence-backed assessment; and
- permits model/cost optimization without transferring authority.

Cons:

- observer judgment may be imperfect; and
- requires explicit evidence, uncertainty, and no-authority boundaries.

#### Option 3: deterministic controller metrics only

Pros:

- is cheapest and mechanically predictable.

Cons:

- cannot detect semantic drift when activity remains mechanically valid.

#### Decision

Choose Option 2. The controller dispatches a read-only, configurable low-cost
observer on routine cadence or durable progress events. It receives only an
immutable ledger/artifact snapshot and returns a typed evidence-backed
assessment. It cannot message or stop the worker, mutate state, or authorize a
transition. The primary alone decides whether an assessment warrants
`continue`, same-turn `steer`, `pause`, or `escalate`; routine `on_track`
assessments may be batched, while uncertain or attention-bearing results trigger
the immediate primary path in Decision 10.
One observer run may be in flight for the work item. Later triggers coalesce to
one latest pending frontier; after settlement the controller starts at most that
one catch-up run. Waiting/primary pause suppresses scheduling until resume.
Handoff, retirement, supersession, or terminal state makes old-run results
historical; a successor schedules from its own fresh frontier. A finite timeout
for the one-shot observer fails only that observer, never the observed worker.
Two consecutive failures in this PoC emit one durable `monitoring_degraded` fact
per streak and mandatorily enter the same `observer_attention` path; a successful
observation resets the derived streak. No scheduler or monitoring-health table
is added: run/assignment outcomes, global `ledger_seq`, and the existing primary
semantic-operation records carry this lifecycle.
Mechanical safety and authority enforcement remain controller responsibilities,
not observer judgments.

### Decision 10: immediate primary assessment and tiered steering

**Problem:** Waiting for a worker checkpoint before the primary sees or acts on
detected drift defeats the purpose of observing work while it is in progress,
but automatically interrupting on every observer judgment makes a fallible
observer an execution authority.

#### Option 1: defer every assessment until the next worker checkpoint

Pros:

- introduces no mid-turn control path.

Cons:

- permits detected drift to compound until an unrelated natural boundary; and
- makes between-checkpoint observation largely retrospective.

#### Option 2: automatically interrupt on every attention-bearing assessment

Pros:

- stops possible drift immediately.

Cons:

- transfers practical stop authority to a fallible observer; and
- disrupts correct work on false or uncertain assessments.

#### Option 3: immediate primary assessment with tiered intervention

Pros:

- gives the accountable primary immediate evidence and current worker state;
- allows same-turn steering without stopping correct work; and
- reserves interruption for a primary decision that drift is material.

Cons:

- requires currentness and single-decision arbitration while worker state moves;
  and
- steering is provider-capability-dependent and may be rejected for a
  non-steerable active turn.

#### Decision

Choose Option 3. `on_track` may batch, but every other or uncertain observer
assessment is immediately persisted and routed to one logical primary attention
operation for the exact worker run. It dispatches immediately when the stable
logical-primary thread has no unresolved call; it never waits for a worker
checkpoint merely for pacing. If one attention operation is already active,
newly settled relevant assessments join the next frontier rather than opening a
competing call. The primary call receives the coalesced assessment set and a
fresh worker snapshot and returns exactly one of `continue`, `steer`, `pause`,
or `escalate`. This is next-available-primary immediacy, not bounded real-time
latency: an already-dispatched primary call settles first so the system never
creates a second logical-primary channel.

`steer` is an exact-turn effect using pinned App Server `turn/steer` with the
current worker `threadId` and required `expectedTurnId`; acceptance adds the
primary's direction to that same active turn without interrupting it. `pause`
or `escalate` uses exact `turn/interrupt`, then the common role-turn settlement
path, before dependent work becomes paused. `pause` must also name the internal
next action and resume condition; after settlement the same run waits while the
controller starts that existing internal path, and the user receives an
informational “no action needed” summary. `escalate` instead opens the ordinary
primary-authored user-attention path with one concrete question because user
knowledge or authority is required. The observer never invokes either method.
The primary result binds the fresh worker-progress frontier: the maximum global
`ledger_seq` among exact worker-originated action/status/report/outcome/artifact
records, run/assignment/turn state, routed receipt/action frontier, and relevant
artifact identities. This is the decision's evidence prefix, not a universal
effect-start equality requirement. `continue` acknowledges the coalesced
assessment frontier without changing the worker; compatible progress after the
snapshot remains available to a later assessment. `steer`, `pause`, and
`escalate` revalidate exact run, owner, assignment, thread, and active
`expectedTurnId`. Ordinary action, status, report, or artifact progress on that
same active turn does not invalidate them. Before a steer send, the controller
fixes the latest worker-progress frontier and attaches the complete structured
delta since the decision frontier—ledger records and artifact identities, not
controller-interpreted prose—together with the primary's direction. This exact
delta is supported only within Decision 11's bounded PoC corpus. The worker
is told to reconcile the direction against that current state and not undo work
that already satisfies it. A completed turn, checkpoint/terminal winner,
handoff, retirement, supersession, or owner/assignment change makes an
unstarted intervention no-effect and routes still-relevant evidence to the next
eligible primary assessment or already-produced ordinary boundary. An older
assessment dominated by an already-consumed same-run assessment frontier is
historical. A proven stale identity, stale `expectedTurnId`, pre-send
rejection, or `activeTurnNotSteerable` records no effect and never silently
changes action. If the worker is still active, that rejection fact and the
still-relevant observer evidence enter the next eligible primary assessment; if
a checkpoint or terminal outcome already won, its ordinary primary boundary
consumes that evidence instead. A send or reader failure after steering may have
been admitted, and a mismatched or unprovable response therefore cannot claim no
effect: it invokes the common reader/run/worktree fence, reports incomplete
steering delivery, and does not retry. A failed steer is never converted
automatically into an interrupt. Accepted steering records only same-turn
direction admission; the worker turn must still reach ordinary turn/action
settlement. Only one primary attention operation and one chosen effect may be
current for a worker run; its terminal result precedes the next attention
operation.

### Decision 11: context-capacity boundary for the PoC

**Problem:** Fixed frontiers prevent a continuously moving ledger target, but
they do not make an arbitrarily large historical prefix fit in one finite model
context. Solving general long-history continuity would require a separate
projection or transport design.

#### Option 1: send every record through ordered acknowledged chunks

Pros:

- preserves raw ordered history at the continuity boundary.

Cons:

- adds another transport and acknowledgement lifecycle; and
- still cannot guarantee that the accumulated conversation fits the model's
  usable context after all chunks are consumed.

#### Option 2: build a bounded current-state projection with query references

Pros:

- can separate current authority/obligations from historical detail; and
- is the plausible production direction for model-independent continuity.

Cons:

- requires a new projection schema, completeness contract, query policy, and
  capacity tests beyond the current happy-path proof.

#### Option 3: constrain the PoC corpus to the pinned model context

Pros:

- preserves the simple exact fixed-prefix protocol for this bounded experiment;
  and
- adds no speculative production abstraction before the PoC demonstrates its
  defining user experience.

Cons:

- does not support arbitrary history size or smaller-context models; and
- a real context-capacity rejection follows the ordinary visible failure path
  rather than being recovered automatically.

#### Decision

Choose Option 3, as selected by the user. The deterministic fixture and bounded
live run must keep the complete fixed `F`, `D`, and steering-delta payloads
within the pinned model's available context. The PoC neither claims nor tests
arbitrary-duration/context-scale continuity and adds no chunking, compaction,
projection, or proactive capacity controller. A provider context-capacity
rejection is not silently treated as successful continuity and does not gain a
capacity-specific retry. Rejection of candidate packet `F` uses the existing
`binding_candidate` failure and bounded candidate lifecycle. Rejection of an
active-binding drain through `D` uses the existing `active_binding` failure/
fence and bounded rebind-or-no-primary lifecycle. A proven provider rejection of
the steering delta is durable no-effect followed by current-evidence
reassessment or ordinary-boundary consumption; only a possibly admitted but
unprovable steering delivery uses the existing worker/run/worktree fence. Each
path visibly preserves its durable evidence/work and remains evidence for the
later production context-management design. The corpus and observed payload
size are recorded so later configurations can be compared, but that measurement
creates no runtime authority or gate in this PoC.

## Plan interpretation and rewind boundary

The fixed-prefix continuity, notification finalization, endpoint ownership, and
observer-intervention rules selected in Decisions 8–11 are implemented only
through the authoritative transition inventory and temporal rules below. Earlier
PoC proof machinery is not a competing contract.

The implementation rewind is targeted to the active implementation worktree and
its implementation-start Git snapshot. Durable control-plane history, accepted
intent, plans, decisions, findings, evidence, and user conversation never rewind.
Every rewind remains a separately presented, independently confirmed,
user-authorized effect.

## Authority-transition inventory

### Common contract

- A **model-turn notification window** starts when the controller reserves one
  of the three exact durable subjects and arms its assigned role, bound primary,
  binding-candidate, or active-binding thread before send and before the physical
  turn ID is known. The App Server reader gives every accepted upstream envelope
  a monotonic receipt sequence and time, completes its classification/routing
  under notification serialization, and only then advances the contiguous
  routed receipt frontier. In `armed`, potentially
  relevant action-start, action-terminal, and turn-terminal notifications enter
  one per-thread receipt-sequenced queue with their original receipt time; reader
  failure marks the window invalid. `binding/replay` binds the exact turn and drains that complete
  lifecycle stream in receipt order before newer live notifications can overtake
  it. A terminal-before-binding receipt therefore closes action admission before
  any later buffered start. `active` records exact action starts and matching
  terminal notifications. The first exact turn-terminal notification enters
  `turn-terminal/settling`, durably closes admission of new action starts, and
  is clean only when every earlier started action already has its routed terminal
  notification. Exact identity remains recognizable until the kernel
  has durably settled or fenced the corresponding role turn, primary attempt,
  or primary-control-plane attempt;
  only then does the window become `settled/fenced` and retire.
  For the pinned provider, exact `turn/completed` is also the causal close of
  that turn's item lifecycle: every same-turn item start and its terminal
  notification must already be routed before it. Any same-turn lifecycle receipt
  after that close is a provider-
  contract violation that fails qualification and blocks dependent work; it is
  never accepted as a new lifecycle phase. Retiring the in-memory window does
  not remove the exact durable thread/turn lookup used to recognize that late
  violation for the remainder of the governed connection/work item.
- **Primary-control-plane attempts** reserve the exact durable row before every
  retained direct primary-thread turn. Binding purposes also bind the existing
  candidate/episode or active binding epoch, packet/frontier or confirmation
  digest; presentation purposes bind the physical-primary thread, presentation
  generation, and captured-input identity when applicable; bootstrap binds the
  exact initial thread and materialization operation. The row also binds one
  closed owner class and its mechanically derived failure disposition. All are
  prompt-only: any action start is a window violation. A binding acknowledgement
  cannot advance candidate frontier, pending installation, confirmation, or
  decision eligibility until its exact turn and clean zero-action window settle.
  Candidate confirmation targets that candidate directly; it cannot mutate the
  controller's global primary/presentation selectors. Attach/reattach cannot
  become render-ready, and a captured response cannot be released for ordered
  processing, until the same clean finalization.
- **Primary-endpoint ownership** distinguishes notification attempt, semantic
  owner, and presentation generation. `pre_work_startup` failure terminalizes
  startup without an invented candidate/rebind; `binding_candidate` failure uses
  the existing episode budget; `active_binding` failure fences/rebinds the exact
  current thread only when the work item's sole rebind allowance is unused;
  otherwise it enters terminal no-primary failure. Candidate confirmation precedes a single endpoint handoff that
  cleanly attaches presentation to the candidate before semantic/presentation
  selectors and readiness become current together. Old/fenced presentation
  turns and direct turns during handoff are rejected.
- **A pending candidate owns its physical presentation lease.** Process launch
  records exact process/PTY, transport-session, thread, and generation identity
  before attach can become ready. Failure before endpoint handoff invalidates the
  generation, fences the candidate, and proves bounded process/session teardown
  before another candidate may start. Unproven cleanup terminalizes the episode
  immediately with the real attempt count; it cannot silently consume the retry
  or leave a stale presentation attached. Exact pre-work presentation ownership
  transfers to activation candidate one only for the same clean thread/generation.
- **A rebind episode owns the old current presentation lease before it owns a
  replacement.** It invalidates that generation and proves exact stock-CLI/
  process/PTY/transport teardown before replacement provisioning or presentation
  attach. Failed proof terminalizes `rebind_failed` with candidate count zero;
  candidate cleanup success cannot compensate for a still-live old endpoint.
- **Each work item permits one automatic rebind episode total.** The existing
  durable binding/episode history consumes that allowance when the first
  replacement episode begins, before old-endpoint cleanup or candidate
  provisioning; initial activation does not consume it. That episode retains its
  initial-candidate-plus-one-retry budget whether it succeeds or fails. After a
  successful replacement, any later loss, ambiguous send, settlement failure, or
  other rebind trigger fences the current thread, preserves work/input/evidence,
  drains or fences active runs under the existing no-primary contract, and
  terminalizes `rebind_failed` without opening another episode or candidate.
- **Capture release and presentation invalidation have one winner.** The
  controller persists opaque text first, but storage is not admission. Under the
  same presentation-generation serialization and kernel transaction, clean
  acknowledgement finalization either creates a one-use pre-work intake token or
  the post-intake `input_seq`; detach, replacement, or rebind instead marks the
  generation invalid and the capture permanently unreleased. Captured text
  remains durable in both cases. Pre-work invalidation/failure stops startup;
  post-intake invalidation requires re-presentation. No in-memory queue or bare
  completion can decide this race.
- **Confirmation-pending has a governed correction producer.** After a
  consequential response is admitted and before effect start, the current stock-
  CLI presentation remains listening. The first new opaque capture reserves its
  existing control-plane attempt against the approval epoch and blocks effect
  start before acknowledgement. Clean finalization admits it as the next ordinary
  input and invalidates the older positive authority; invalidation/failure leaves
  the effect no-op and requires proposal re-presentation. The serialized effect-
  start boundary may instead win before any correction attempt is reserved, in
  which case later input is next direction only. No Python text interpretation
  decides whether the capture is a correction.
- **The one-use startup token creates the canonical initial input.** Its consume
  transaction verifies the exact stored capture, creates the work item/unbound
  primary state and one `user_inputs` row with `input_seq = 1`, links and consumes
  the token, and returns that input ID. Raw caller text, a second intake/admission,
  and the tokenless `--console-ui` launcher path are ineligible.
- **Every governed capture handoff is typed.** Pre-work `request` returns the
  exact startup token/capture handle. Post-intake `request` and every `response`
  return the exact already-admitted input ID/sequence, presentation generation,
  and bound verbatim text. Native input obtains the winner handle from controller
  clean-finalization; scripted tests seed the same production-contract token or
  admitted-input handle. Once clean admission wins, later detach cannot replace
  it with an exception or a second input. A consumer resolves the exact
  attempt/generation terminal or durable released handle before treating a later
  detach as failure; if invalidation wins, no handle exists.
  Latest-token selection, caller-text matching, hidden mutable controller state,
  and raw-text-only results cannot select authority.
- Presentation mechanics expose the same capture truth: detach/rebind closes
  listening and renders preserved admitted state; an unreleased stored capture
  is explicitly reported as not accepted/no-effect before re-presentation; and
  listening reopens only after the current prompt/proposal is fully rendered.
  Exactly one admitted handle is acknowledged. Pre-work failure distinguishes
  durable stored text from an accepted request and names only the fixed next
  action.
- The App Server reader accepts at most one MiB per JSON-line envelope through
  bounded byte acquisition before text decoding, JSON parsing, copying, or
  evidence append. An armed or binding/replay thread buffers at most 128
  potentially relevant lifecycle notifications and one MiB of their accepted
  raw envelopes in total. Overflow, malformed JSON, a non-object envelope, or a
  potentially relevant owned-thread lifecycle envelope with missing or
  contradictory exact identity, invalid action lifecycle, premature clean EOF,
  or reader exception enters the same fail-closed transition. That
  transition marks an armed window invalid or durably begins the subject's
  existing role-turn, primary-attempt, pre-work-startup failure,
  candidate-failure, or active-binding fence path before cancelling an
  enforcement timer or requesting interrupt. A
  reader-wide failure enumerates every armed, binding/replay, active, or
  settling subject while holding notification serialization and uses one bounded
  kernel transaction to apply every enumerated subject's exact durable failure/
  fence disposition before waking its waiter. If that transaction itself fails,
  the controller enters fatal no-progress and exposes no subject success or
  future admission; it cannot merely set a global flag while an existing subject
  remains waitable or eligible. A returned JSON-RPC interrupt
  error is failure evidence, and the existing
  30-second settlement deadline remains authoritative. Terminal reader
  failure wakes exact-turn waiters; it can never fall between response delivery
  and later binding without invalidating the new window. Oversized raw bodies
  are never copied into evidence; only bounded size/reason metadata is retained.
- `thread/read(includeTurns=true)` is a final conversation/turn snapshot and may
  omit action items. It validates final output and rejects a contradictory exact
  action item if one is present. Every present snapshot action has one canonical
  terminal state; duplicate identities or identity, type, or terminal-state
  disagreement with notification evidence reject the subject. The snapshot
  cannot erase, recreate, or weaken the
  notification-derived role-turn or primary-attempt action inventory. This
  relies on the pinned App Server contract that each item lifecycle precedes its
  exact terminal `turn/completed`, the single stdout preserving that order, and
  truthful thread/turn identity. `thread/read` is not itself a lifecycle barrier;
  deliberate relabeling to an unrelated valid thread remains out of scope.
- **Clean finalization is the only eligibility boundary.** After exact turn and
  notification-derived action terminality, the runtime obtains and validates the
  final `thread/read` response plus its routed receipt frontier on the same
  receipt-ordered stdout. Eligibility requires the routed frontier to include the
  exact causal `turn/completed` and every prior lifecycle receipt; the response
  only validates snapshot/output contradiction. The runtime returns provisional
  evidence only together with its exact finalization lease. The controller then holds the short
  notification serialization lock, verifies that response's routed frontier and
  the complete clean window, and invokes one subject-
  specific kernel transaction that records the same routed receipt frontier
  together with role settlement, primary-attempt settlement, or continuity-
  acknowledgement/binding advancement. It retires the in-memory window before
  releasing the lock; no separate fallible unregister/retirement step remains.
  Any reader failure or provider-contract/lifecycle violation serialized before that transaction makes
  the subject ineligible and enters its existing failure/fence path. Consumers
  access eligibility only after this controller operation returns. Under the
  pinned single-stream provider contract, the earlier exact `turn/completed`
  closes that turn's item lifecycle. A later global reader failure does not
  retroactively invalidate a cleanly finalized subject, but the same serialized
  failure operation must durably fail/fence every other non-retired subject,
  wake its waiter, and block future work.
- A provisional result never creates an ownerless interval. Before the runtime
  returns it, runtime cleanup owns abort/fence. The returned typed finalization
  lease then makes the workflow consumer responsible for exactly one clean
  finalization or abort/fence, including failures while persisting model-call
  evidence, validating or recording provisional output, recording terminality,
  or invoking settlement. A terminal disposition retires the in-memory window;
  propagation, adoption, reuse, and dependent effects cannot precede it.

- A **settled agent-role turn** has a terminal exact App Server turn and a
  terminal item outcome for every action started by that turn. The controller
  records the turn/run/thread and started-action inventory. Any report or result
  received earlier is durable provisional evidence only. Logical completion,
  failure, invalid output, or supersession opens one 30-second settlement window;
  non-success rejects late output and requests `turn/interrupt` when needed.
  A continuing worker has no elapsed work deadline, action-count frontier,
  budget-overrun state, or automatic budget-checkpoint turn. One-shot evaluator
  roles may retain a finite operation deadline whose expiry fails only that run.
  Missing settlement fences the run and its assigned worktree/checkout. Before
  settlement, and permanently after failed settlement, the controller forbids
  report adoption or response, a successor turn, checkpoint adoption, handoff,
  owner/worktree release or reuse, terminal-run adoption, candidate construction,
  and every dependent transition. This is the common App Server execution
  invariant; observation never changes or replaces settlement.
- An **eligible role outcome** is the schema-valid terminal output of the exact
  settled run turn and App Server thread assigned to that role. Failed,
  cancelled, incomplete, wrong-thread, stale, superseded, or physically
  unsettled output is evidence but cannot advance dependent work.
- An **eligible in-run report** is a schema-valid checkpoint, inflection report,
  or ask from an exact settled model turn on the App Server thread of the
  still-active run. The report and raw turn become durable before the primary
  responds; the run itself remains active and cannot continue through dependent
  work until that exact report receives a typed primary direction or answer.
- A **routine observation** is a distinct read-only one-shot agent run over an
  immutable ledger/artifact frontier. Only one is in flight for the work item;
  triggers replace one latest pending snapshot until settlement permits one
  catch-up. Its assignment binds the observed worker, objective/plan, evidence
  frontier, checkpoints/reports, recent action/status events, artifact identities,
  elapsed progress, and known deviations. Its typed
  result is one of `on_track`, `possible_drift`, `blocked`, or
  `needs_primary_attention`, with evidence references and uncertainty. The
  controller persists the assessment and routes it according to Decision 9. A
  worker-progress frontier is the tuple of the maximum global `ledger_seq` among
  exact worker-originated action start/terminal, status/report/ask/outcome, and
  artifact-identity records; exact run/assignment/turn state; routed receipt/
  action frontier; and relevant artifact identity digest. Primary/observer
  bookkeeping does not advance that worker component. The observer snapshot,
  primary decision, and effect request each bind the applicable frontier for
  provenance and dominance. A same-run later snapshot with a higher worker
  `ledger_seq` includes the older worker-event frontier; once its assessment is
  consumed, it makes an included older assessment historical. Progress alone
  does not invalidate an intervention. Effect currentness is action-specific:
  `continue` has no worker effect; `steer`, `pause`, and `escalate` require the
  same exact active turn/owner/assignment, and only a conflicting lifecycle or
  ownership winner makes them no-effect. A steer carries the structured progress
  delta through a fixed effect-start frontier so semantic reconciliation remains
  with the worker rather than controller text processing.
  Observation creates no worker pause, direction, adoption, effect, or state
  authority; observer failure likewise does not change worker execution. Two
  consecutive durable failures produce one `monitoring_degraded` fact per
  streak; success resets the derived streak. An
  attention-bearing or uncertain result becomes input to the closed
  `observer_attention` primary semantic-operation kind from Decision 10. One
  such operation per worker run may be current; it binds the coalesced settled
  assessment frontier plus a fresh run/thread/turn/owner/assignment snapshot.
  Only its eligible primary result may request a controller steering or
  interruption effect.
- **Primary adoption** is a schema-constrained primary model call that names the
  exact producer run/model call/output and returns `adopt`, `revise`, `reject`,
  or `escalate`, plus the bounded next-state fields needed by that transition.
  A database default, controller inference, or orchestration caller cannot stand
  in for this turn.
- **Plan-review closure is mechanically derived from severity, scope, and the
  current review batch.** Every immutable reviewer finding receives one exact
  synthesis disposition and grounded rationale in the existing review-result /
  synthesis records. `blocking` or `significant` `in-scope` permits revision, or
  a recorded invalidity rejection followed by a fresh independent verification
  batch over the same immutable version; a version cannot close in a batch that
  contains either class. `blocking` `adjacent` becomes a scope-change request and
  pauses for the user. `significant` or `acknowledged` `adjacent` may be durably
  deferred. `acknowledged` `in-scope` may be documented, revised, or rejected
  with rationale; `out-of-scope` is recorded as dropped. Closure requires both
  current review verdicts to contain no `blocking` or `significant` `in-scope`
  finding and exhaustive compatible dispositions for every current finding.
  Controller code validates only these typed combinations and completeness; it
  never judges the rationale text. This adds no plan-finding table or generic
  finding workflow.
- Every controller-initiated, non-user **primary semantic operation** is durable
  before network send. Its stable operation ID binds the operation kind,
  authority source, consumed ledger frontier and artifact identities, exact
  output schema, and currentness predicate; its initial state is
  `queued_not_dispatched`. A physical call attempt is journaled with its binding
  epoch and the operation atomically becomes `dispatched_pending` before send;
  one eligible typed result closes it. The kernel exhaustively enumerates every
  controller-initiated primary call site/kind and initialization fails if any
  such send is unclassified. At most one non-user primary operation may be
  unresolved because the next semantic operation is derived only after its
  predecessor closes. `observer_attention` is one exhaustively enumerated kind,
  not a parallel primary channel. An attention-bearing assessment is persisted
  immediately; if another primary semantic operation is unresolved, its exact
  frontier waits as the next eligible operation after that predecessor settles.
  Further assessments may extend only a later immutable frontier and cannot
  mutate the input of an already-dispatched primary call. New user input or a
  superseding workflow transition uses this same operation-settlement rule,
  after which the controller rechecks whether the persisted observer evidence is
  still relevant rather than carrying stale direction authority forward.
  If that physical thread is lost before a typed result is durable, the attempt
  is fenced with the thread. After replacement catch-up, the controller may
  issue one replacement attempt for the same logical operation only when its
  authority, consumed identities, currentness predicate, and newest-user-input
  boundary still match. A queued operation receives its ordinary first attempt
  after replacement; an operation dispatched before physical loss with no
  terminal outcome receives the sole replacement attempt. A newer user input or superseding workflow state records
  the old operation as `superseded` and lets the current state produce its normal
  next operation only after the old physical attempt is settled or its thread is
  fenced and replacement binding installed. A replacement-attempt failure
  records `primary_operation_failed`, closes that operation, and opens one
  distinct current `attention_summary` operation only after the same settlement/
  eligible-binding boundary; it is
  not retried. If the failed operation was itself `attention_summary`, the
  controller renders the fixed, explicitly non-primary failure status only after
  physical settlement or thread fencing, only when no newer admitted input has
  superseded that summary, and waits for fresh user input. A summary superseded
  by newer input suppresses both its stale output and fallback after settlement/
  fencing, then processes that input by `input_seq`; it is not a summary
  failure. This prevents recursive summary calls. Thus physical
  primary continuity neither invents a new semantic decision nor creates a
  generic model-error retry loop. User-originated turns retain the separate
  ordered input delivery/reissue contract below.
- Every post-binding primary semantic-call attempt, whether ordinary or a bounded
  replacement, has distinct logical-outcome and physical-settlement states. Its
  durable pre-send record enters `send_started` before dispatch and starts one
  controller-owned five-minute deadline; a failure after that marker is possibly
  dispatched, while only a proven pre-marker failure needs no settlement. This
  covers user input delivery, non-user semantic operations, and
  `attention_summary`. A physical attempt is settled only when the exact App
  Server turn is terminal **and** every action started for that turn has a terminal
  item outcome. No successful result becomes eligible and no successor call may
  use that thread before settlement. Every logical outcome opens a 30-second
  settlement window. Error, invalid output, supersession, or
  timeout closes semantic eligibility first, makes every later result ineligible,
  and requests `turn/interrupt` when the exact turn is known. An ambiguous send
  without a turn identity fences the thread immediately. Settlement failure
  fences the thread and
  enters the existing bounded rebind protocol. Neither path restores retry
  eligibility to terminal semantic work; a provisional success becomes
  kind-specific `physical_settlement_failed` and its result is ineligible. That
  reason maps to the same terminal kind as timeout below. A timed-out non-summary operation becomes
  `primary_operation_failed` and follows the one-summary rule; a timed-out summary
  uses the fixed no-recursion fallback. Ordinary input timeout becomes
  `input_delivery_failed`; automatic reissue timeout becomes `reissue_failed`.
  Both preserve the input, apply no semantic effect, close automatic eligibility,
  and permit later queued input. A live primary may summarize the exact input
  failure through the same one-summary rule. Send error, invalid terminal output,
  and explicit call failure use these same kind-specific terminal outcomes
  without automatic semantic retry. Primary semantic calls expose only read-only
  context actions; delegation, messages, writes, subprocesses, and effects occur
  only through controller-owned transitions after an eligible typed result. An
  unexpected effect-capable action is protocol failure and follows the same
  settlement/fence path. Activation/rebind and active-binding packet/
  acknowledgement turns use the same notification lifecycle with a zero-action
  policy, their separate finite candidate-operation deadline, and their existing
  candidate or active-binding failure/fence path.
- A primary-owned semantic turn is already the accountable authority for its
  typed decision and therefore does not require the primary to adopt itself. It
  must still bind its exact inputs, current artifact identities, and structured
  output before the controller acts.
- Controller-executed validation is a mechanical fact-producing exception: its
  exact command/run/evidence may directly satisfy a validation gate because it
  makes no semantic choice. The independent semantic verifier is a different
  exception: its exact result is only a required co-sign on a configured
  positive primary interpretation (`restart`, `integration`, or
  `proceed_closed_plan`) and can never authorize a transition or effect alone.
- A purely mechanical controller transition needs no new model acceptance when
  it only enforces already-durable exact authority. It must reject stale
  identities and record the resulting transition or external-effect status.
- The controller's single SQLite writer assigns one strictly monotonic
  **`ledger_seq`** to every mutation that can change primary semantic context or
  transition eligibility, in the same transaction as that mutation. The
  exhaustive prototype classes are user/conversation intake, semantic model-call
  results, role reports/outcomes, asks, decisions, plans/reviews/findings,
  Git/artifact identities, workflow/effect state, and semantic binding/input
  state. Each such transaction appends a canonical change record naming all
  affected identities and exact payload/row references; multiple records receive
  contiguous values and become visible atomically. Re-prime packet/delta delivery,
  acknowledgement receipt, and other transport bookkeeping remain in the
  ordinary audit journal but do not advance `ledger_seq` because the candidate
  directly observes them and they change no semantic/transition state. Every
  mutating controller operation must declare one of these two structural classes;
  initialization fails for an unclassified operation, and tests enumerate the
  complete mutating surface. Nothing without a relevant change record is eligible
  packet context or transition authority.
  Re-prime packets and catch-up deltas are ordered projections over this one
  sequence, so frontier `F` means all records through `F`, never a collection of
  per-table watermarks.
- The **primary binding/continuity protocol** names one stable logical-primary
  identity and permits exactly one decision-eligible physical App Server thread.
  Initial activation and later replacement use the same bounded candidate
  protocol. At candidate start the controller freezes one durable finite cutover
  frontier `F`, creates an exact packet containing every record through `F`—
  current intent/scope, accepted decisions, plan/review state, active work/runs/
  checkpoints, pending asks, relevant Git and artifact identities, attributable
  conversation, and next permitted transition—and gives it to the candidate
  under a finite operation deadline. A schema-valid `primary_reprime_ack` binds
  the logical primary, candidate thread, episode, attempt, packet, and exact `F`,
  but advances nothing until its reserved prompt-only continuity attempt cleanly
  finalizes. That single-writer finalization records acknowledgement through `F`
  and pending install at cutover `I = F`; it never compares against or chases the
  moving current maximum. The
  candidate remains decision-ineligible until the controller cleanly finalizes
  that prompt-only confirmation addressed directly to its exact thread and
  completes the matching presentation attach/promotion and endpoint handoff.
  Confirmation delivery/finalization failure retires and
  fences the pending candidate, invalidates its presentation lease, and proves
  process/session teardown under the same episode before any retry. After
  successful endpoint handoff, records committed after `I` are already the normal
  ordered backlog. Before each primary semantic call, the controller freezes one
  finite dispatch frontier `D`, delivers every record after the binding's last
  acknowledged frontier through `D`, and requires a matching clean
  acknowledgement through `D`; records committed after `D` wait for a later
  ordered drain. A continuously writing worker therefore cannot prevent install
  or exhaust a candidate/rebind allowance. A candidate is never semantically
  decision-eligible while bootstrapping, and a bound primary cannot make a
  semantic call before its finite dispatch prefix is acknowledged. Under
  Decision 11 this exact-payload rule is claimed only for the bounded PoC corpus
  that the pinned model accepts; it is not arbitrary-history support.
  Replacement additionally transfers the old endpoint lease to episode cleanup,
  fences/invalidates it, and proves process/session absence before provisioning
  a candidate;
  physical replacement never transfers authority to another role. Independent
  agents may continue and append durable results during the episode, while every
  primary-dependent transition waits for installation and its own finite-prefix
  acknowledgement.
- Initial activation and the work item's sole rebind episode each permit the
  initial candidate plus exactly one automatic retry. The first rebind episode
  consumes the durable work-item allowance before old-endpoint cleanup; no later
  trigger may open another episode. Failure, timeout, or invalid/stale acknowledgement
  durably retires/fences the candidate, invalidates its generation, and proves
  any started presentation lease absent before retry. Unproven teardown
  terminalizes the episode immediately; otherwise exhaustion records
  `primary_start_failed` or `rebind_failed`, atomically closes new agent turn/
  action admission, interrupts every active agent-role turn, and applies the
  existing 30-second turn/action settlement rule before the terminal render.
  A settled result remains evidence because no primary can adopt it. Missing
  settlement records `role_turn_settlement_failed` and permanently fences the
  run and assigned worktree/checkout; the final status names that unresolved
  fence and does not claim its contents are static. Only after every active run
  is settled or fenced may the controller render the fixed status. Exhaustion
  preserves all work and ordered input and performs no third automatic attempt.
  With no eligible primary, the
  controller may render only a fixed non-semantic status from exact durable
  fields: failure kind, preserved work, queued-input count, current blocker, and
  the fixed fact that the bounded PoC has stopped and no further in-PoC activation
  is available.
  It may not generate or infer a recommendation. Every admission receives one
  strictly monotonic `input_seq`. Admission first records input as
  `queued_not_dispatched`. Immediately before any upstream send, the controller
  journals the exact outbound call and atomically moves it to
  `dispatched_pending`; this write precedes the send. Rebind delivers
  all admitted inputs strictly by `input_seq`: each `queued_not_dispatched` item
  receives one ordinary delivery, while only `dispatched_pending` after physical
  loss and without a terminal outcome becomes `pending_reissue` and receives one distinct linked
  reissue. Delivery mode never reorders inputs; the first eligible result closes
  that input state once. Every
  old/failed-thread late result is ineligible, and every consequential result
  must still use the newest admitted user turn at its serialized transition.
- The **user decision envelope protocol** owns semantic user decisions without
  giving the controller any prose authority. Each envelope binds a decision ID
  and kind, exact subject artifacts, admitted input identity/sequence,
  `presentation_binding_epoch`, `interpretation_binding_epoch`, typed primary
  interpretation, allowed dispositions, optional positive-verifier policy, and
  resulting transition.
  Initial unsolicited intent uses `direct_intake`; all responses to a proposal
  use `presented_response` and additionally require the exact completed primary
  turn, presentation generation, render-complete sequence, and verbatim response.
  For `presented_response`, the immutable presentation epoch must have been the
  active binding for completed turn/render and remain valid through response
  admission. The interpretation epoch must be the active caught-up binding for
  the exact primary call; they may differ only when response admission preceded
  physical rebind. `direct_intake` has no presentation epoch and binds only its
  admitted input plus interpretation epoch. Pre-render input is ineligible.
  Detach, presentation replacement, or physical
  rebind after render but before durable response admission invalidates the
  presentation and requires complete re-presentation under the current binding.
  A response admitted before rebind is not presented again: if still
  `queued_not_dispatched` it receives one ordinary ordered delivery, while only
  `dispatched_pending` after physical loss without a terminal outcome follows
  `pending_reissue`. Any newer
  admitted user turn before the serialized transition invalidates
  the older consequential interpretation. The controller checks only schema,
  each epoch's historical eligibility, stable logical-primary identity, subject/
  input currentness, kind-specific disposition, and required verifier agreement;
  it never requires the two epochs to be equal. Independent semantic verification is required only for positive
  `restart`, `integration`, and `proceed_closed_plan`; rejection, revision,
  clarification, defer, and explicit abandonment remain primary-owned outcomes.
  Only explicit abandonment terminalizes workflow state while preserving work,
  artifacts, and evidence; the others apply no effect.
- A primary interpretation that was schema-valid and durably eligible when its
  turn completed is owned by the stable logical primary; its physical thread and
  binding epoch remain provenance, not an expiry condition. Later physical
  rebind alone therefore does not invalidate it. Any required verifier or
  consequential transition waits until the replacement is fully caught up and
  ordered queued input is admitted, then rechecks the interpretation's exact
  subject, response, workflow state, and newest-input identity. Subject/state
  supersession or newer input invalidates it normally. If no typed interpretation
  became durable or another terminal outcome was recorded,
  `queued_not_dispatched` versus physically lost `dispatched_pending` selects
  ordinary delivery versus the one `pending_reissue` path.
- The one automatic `pending_reissue` call has a terminal failure path. Any
  model/transport failure, timeout, or physical loss after that automatic attempt
  starts records `reissue_failed`, preserves the original input and linked calls,
  closes automatic-reissue eligibility, and lets later queued input proceed in
  order. The eligible primary presents the unresolved input/failure and may make
  a distinct retry or supersession only after a fresh typed user/primary direction;
  that later call is not another automatic reissue.
- An ordinary queued-input delivery that reaches its physical-call deadline
  records `input_delivery_failed` rather than becoming `pending_reissue`, even if
  its non-quiescent thread must then be fenced/rebound. It preserves the verbatim
  input and attempt evidence, closes that delivery's automatic eligibility,
  admits later input, and enters the bounded failure-summary path. Only physical
  thread loss before the call deadline, without another terminal outcome, may use
  the existing one linked reissue after replacement.
- Any dispatched input call closed by send error, invalid output, newer-input
  supersession, or another no-effect outcome still follows the shared physical-
  settlement contract. A successor input/summary cannot use the thread until its
  exact turn and all started actions are terminal; ambiguous send without a known
  turn or failed 30-second settlement fences/rebinds the thread without reviving
  the closed input.
- Every agent-owned run has exact **assignment authority** before its first
  turn. A discretionary planner, implementer, root-assessor, or handoff run uses
  a typed primary delegation naming role, purpose, context artifacts, and
  worktree. A mandatory plan/code reviewer, native-review structurer, closure
  verifier, positive-effect semantic verifier, or routine observer may instead
  be assigned as the exact mechanical next step of the current accepted
  transition or configured observation trigger that requires that fixed role.
  An observer assignment additionally binds its immutable observed frontier and
  grants no authority over the observed worker. Every assignment records which
  authority path it used and the exact run/thread binding; orchestration caller
  intent is never authority.
- The direct native CLI review is a fixed read-only model operation, not an
  SQLite writer or a user-facing authority. The controller may launch it only as
  the exact next step after iterative candidate reviews converge, against the
  exact current commit in an isolated checkout. Its completed process record is
  the assignment authority for the separate one-shot structuring subagent. The
  subprocess runs read-only in an isolated process group with a 10-minute
  controller deadline. Expiry terminates the group and cleans the disposable
  checkout; timeout, nonzero exit, incomplete cleanup, or partial output fails
  the gate, never enters structuring or primary adoption, and is not retried.
- The root assessor receives these three exact restart predicates:
  - `foundational-premise-invalidated`: evidence invalidates a foundational
    premise or accepted plan decision of the current attempt;
  - `incremental-repair-preserves-invalid-structure`: incremental repair would
    preserve that invalid structure or introduce disproportionate complexity;
    and
  - `clean-restart-has-better-path`: a clean restart has a plausible path to
    satisfy the already accepted outcome better.
  Its output binds the current intent, attempt, and start snapshot and returns
  each predicate exactly once with a boolean result and specific evidence. A
  positive assessment requires all three results to be true. Missing, duplicate,
  unknown, narrowed, or evidence-free results are ineligible. The assessor
  cannot add, remove, narrow, or amend a predicate.

### Closed transition map

| Workflow transition | Eligible producer and evidence | Accountable adoption / user authority | Permitted durable transition or effect | No-effect / revision path |
|---|---|---|---|---|
| Pre-work primary startup | Exact `pre_work_startup` control-plane attempt for bootstrap, initial attach, or first-intake capture acknowledgement; provisional thread/generation and startup presentation lease; captured payload; routed receipt frontier; typed capture/token handle | Mechanical startup/presentation only; no work item, binding candidate, semantic decision, or retry authority exists | Clean bootstrap/attach may publish exact readiness. Clean capture finalization returns one typed handle. Consuming that exact handle creates work item, unbound primary state, and sole canonical initial input (`input_seq = 1`) from the stored payload | Raw-text-only, stale/wrong handle, action, lifecycle/stream failure, timeout, invalidation, or failed finalization stops. Fence thread, preserve text, prove startup lease teardown, emit fixed facts; no activation/rebind/retry |
| Initial physical-primary activation | Stable logical-primary identity, activation episode, candidate attempt/thread, one fixed global `ledger_seq` cutover `F`, exact packet through `F`, cleanly finalized acknowledgement, and exact candidate presentation lease or transferable clean startup lease | Mechanical continuity only: matching candidate re-prime acknowledgement and final binding-installed confirmation; none creates a product/workflow decision | Clean acknowledgement records pending install at `I = F` without comparing to the moving ledger maximum; clean direct-to-candidate confirmation then permits one endpoint handoff. The already-clean startup lease may transfer only on exact thread/generation match; otherwise clean explicit candidate attach must complete before routing/readiness become current together. Each later primary semantic call drains and acknowledges one newly fixed finite prefix | Any unsettled/invalid candidate or endpoint attempt fences the candidate, invalidates its generation, and must prove its process/session absent before the sole retry. Unproven teardown terminalizes `primary_start_failed` immediately with actual attempt count. Two cleanly retired candidate failures preserve work/input, show fixed status, and make no third attempt |
| Primary-control-plane model call | Exact control-plane-attempt/operation ID, closed purpose, owner class and failure disposition; thread/turn; optional candidate/episode, binding epoch, packet/frontier/confirmation digest, presentation generation/lease, or captured-input identity; terminal exact turn; zero notification-derived actions; final snapshot routed receipt frontier; and finite operation/settlement timers | Mechanical bootstrap, continuity acknowledgement, endpoint handoff/presentation, or input-capture acknowledgement only; no semantic, product, or new retry authority | One serialized clean-finalization operation rechecks the attempt deadline and records only its exact owner-compatible follow-on: candidate/active-binding acknowledgement, pre-work readiness/token release, endpoint attach/readiness, post-intake `input_seq` admission, or outside-window notice completion. Startup-token consume alone creates canonical initial input | Any action, unknown purpose/owner, stream/lifecycle violation, expired deadline, invalid output, stale/fenced endpoint, missing finalization, or failed handoff makes the result ineligible and durably applies the owner-specific disposition. `pre_work_startup` stops; `binding_candidate` may retry only after proven lease teardown; `active_binding` fences/rebinds. Presentation invalidation can permanently prevent capture release |
| Initial intent or revised intent | A current user decision envelope: `direct_intake` for unsolicited initial input; `presented_response` over the exact proposal for a revision; plus bounded context and exact typed primary interpretation | The primary interpretation is the semantic authority under the envelope's current binding/input/presentation identities | Record the versioned accepted intent; activate or pause only work whose exact intent dependency changed | Ambiguity, rejection, stale/invalid envelope, detach/rebind before response admission, or invalid interpretation preserves current intent and work; a presented response requires re-presentation when its window is invalidated |
| Agent assignment and first turn | Exact typed primary delegation for discretionary work, or the exact current accepted transition/configured observation trigger that mechanically requires one fixed reviewer/verifier/structurer/observer role; plus role, purpose, consumed artifacts, worktree permission, and provisioned thread identity | The assignment record binds its authority source and exact run/thread before work is delivered; an observer additionally binds its immutable observed frontier and receives no worker authority | Permit the first turn only for that role/purpose/context; routine observation may overlap but cannot direct or pause the observed worker | Missing/stale authority, failed provisioning, wrong role/context/worktree, or supersession gives the thread no work and advances no phase |
| Planner result becomes a review candidate | Eligible planner run/output bound to current intent, attempt, ask state, and parent plan version | Exact primary adoption of that planner output for review | Record immutable plan version N and launch both independent review lenses | Revise/reject/escalate creates no accepted plan and no implementation assignment |
| Plan reviews converge or request revision | Eligible soundness and adversarial outcomes, each bound to the same immutable plan ID/version/content, with every finding tagged by severity and scope | One exact primary synthesis binds both results, gives every finding one compatible typed disposition and rationale, and may request revision or invalidity verification. A material scope change remains only a proposal until a current user decision envelope accepts revised intent/scope | `blocking`/`significant` in-scope always prevents closure in its current batch and permits N+1, or a same-version fresh independent verification after grounded invalidity rejection. `blocking` adjacent pauses as a scope-change request; other adjacent findings may defer; acknowledged in-scope may document. Only a current batch with no blocking/significant in-scope finding plus exhaustive compatible dispositions mechanically closes the exact version for final user review | Versions remain monotonic and unlimited. Incompatible/missing disposition or dirty current batch cannot close. A proposed scope change pauses for the user. After three consecutive automatically generated/reviewed versions, record `plan-review-auto-iteration-limit` and enter the checkpoint before another version. No finding is silently ignored and no first-class plan-finding table is added |
| Plan auto-iteration user checkpoint | A current `presented_response` decision envelope over the exact checkpoint, intent/scope, immutable lineage, latest synthesis, automatic-version count, proposed next action, and closed-plan identity when one exists; its compact voice lead names problem/outcome, material delta, review status/risk, and exact consequence, with complete drill-down available | The primary returns `revise_next_version`, `pause_or_clarify`, `abandon`, or, only when the envelope also contains a closed plan, `proceed_closed_plan`; the positive proceed requires an independent matching semantic-verifier result | Current revise continues durable findings or first records a requested/user-authorized intent/scope revision, then permits N+1 and resets the automatic counter. A combined current `proceed_closed_plan` resets the counter and also satisfies final plan authorization. The presentation explicitly distinguishes N+1 review from starting implementation. Explicit abandon terminates without deleting evidence | Qualified approval is revision, not proceed. Invalid/stale envelope, newer input, ambiguity, verifier disagreement/failure, or pause leaves the lineage waiting and resets no counter. An open-plan checkpoint cannot emit or authorize `proceed_closed_plan` |
| Final closed-plan user authorization | A current `presented_response` decision envelope over the exact closed plan version/content, intent/scope, complete plan/review lineage and synthesis, whether the auto checkpoint is also due, and verbatim user response; compact voice lead says positive authority starts coding from exact N and full detail is available | The primary returns `proceed_closed_plan`, `revise_next_version`, `pause_or_clarify`, or `abandon`; positive proceed requires independent matching semantic verification | Any current revise or independently affirmed proceed resets the automatic counter. Proceed marks only that exact closed version implementation-authorized; revision returns through normal N+1 review. When the pacing checkpoint is also due, the same envelope satisfies it | Every closed plan requires this transition, including closure at v0/v1/v2. Closure alone, invalid/stale envelope, newer input, disagreement/failure, or pause resets no counter and cannot assign implementation. Qualified approval is revision; abandon preserves lineage |
| Agent-role App Server turn settlement | Exact run/thread/turn, controller-owned notification window and routed receipt order, logical outcome, every started/terminal action, stream integrity, finalization lease, and 30-second settlement timer | Mechanical execution classification only; no semantic adoption or retry authority | Exact `turn/completed` durably closes new action-start admission and is clean only when every previously started exact action already has its routed terminal notification. That causal close, state-consistent final snapshot, routed frontier validation, and durable kernel settlement may then consume the lease as finalized, retire the binding, and make a report/result eligible | Any lifecycle after the causal close, other notification-window integrity or post-return persistence/validation failure consumes the same lease through durable abort/fence before propagation. Missing terminal disposition fences run and assigned worktree/checkout; no successor turn, checkpoint adoption, handoff, owner release/reuse, terminal-run adoption, candidate construction, or dependent transition occurs |
| Routine worker observation | A cadence/progress trigger snapshots the exact active worker, assignment, plan, artifact identities, and worker-progress frontier; no other observer is in flight for the work item | Observer output is evidence for the primary, never adoption or direction authority | Assign one finite one-shot read-only observer. While it runs, coalesce triggers into one latest pending frontier; after settlement start at most one catch-up. Persist typed status/evidence/uncertainty/model/config/frontier. Batch `on_track`; attention/uncertainty immediately opens or joins next-available `observer_attention` while the worker continues. Two consecutive failures emit one `monitoring_degraded` fact per streak and mandatorily enter that same path; success resets the derived streak | Observer timeout/failure closes only the observer. Waiting/pause stops scheduling until fresh resume. Handoff, retirement, supersession, or terminal state disables the old run and makes its late result historical. No cadence, elapsed-time, action-count, observer output, or monitoring degradation can interrupt the worker |
| Immediate primary assessment of observer attention | Exact current worker run/thread/active-turn/owner/assignment and worker-progress evidence frontier plus all still-relevant settled attention assessments through frontier A; one closed `observer_attention` semantic operation and its cleanly settled eligible primary result | Primary alone selects exactly one of `continue`, `steer`, `pause`, or `escalate`; controller code does not reinterpret observer or primary prose | `continue` acknowledges through A with no worker effect. `steer` durably records its request/frontier, revalidates exact structural currentness, attaches the structured progress delta through a fixed send frontier, sends `turn/steer(threadId, expectedTurnId, direction + reconciliation context)`, and accepts only the same turn; direction admission does not settle the worker. `pause`/`escalate` revalidate the same active turn, interrupt, and require common settlement. `pause` then starts the named internal next action and presents informational no-action-needed status; `escalate` asks one concrete user question. Only after terminality may another attention operation start | Ordinary compatible same-turn progress does not invalidate the chosen action. A dominated already-consumed assessment, completed turn, checkpoint/terminal winner, handoff, retirement, supersession, owner/assignment change, proven stale/non-steerable turn, or pre-send failure is no-effect; current evidence is reassessed if the worker remains active or consumed by the winning ordinary boundary. Possibly admitted steering with send/reader failure or mismatched/unprovable response uses the common reader/run/worktree fence as incomplete delivery, never no-effect/retry/automatic interrupt. Interrupt/settlement failure uses its common fence. A checkpoint/terminal outcome waits provisional while this operation closes |
| In-run checkpoint, inflection report, or ask | Eligible settled voluntary report bound to the exact active run and evidence | Exact primary direction/answer is required only for work dependent on the report/ask | Primary may `continue`, `correct`, `pause`, or `escalate`; independent work may continue when it consumes none of the unresolved authority or answer | Missing settlement fences normally. An unresolved ask or direction-dependent report preserves the run and blocks only dependent progress. If `observer_attention` is current, the report remains provisional until that operation/effect terminalizes, then receives one ordinary direction against current state |
| Terminal role outcome | Eligible settled role outcome bound to its exact producer run/model call/output and consumed artifacts | Exact primary adoption/revision/rejection/escalation bound to that outcome | Accepted outcome permits only its named phase-compatible dependent transition | Unsettled, unadopted, rejected, stale, or superseded outcome cannot advance. If `observer_attention` is current, the outcome remains provisional until that operation/effect terminalizes; any post-terminal revision uses a distinct linked run, never reopens the completed run |
| Handoff / owner replacement | Exact active run, settled durable checkpoint, quiescent worktree/artifact identities, and intended replacement assignment | A separate typed primary `handoff` decision binds those identities; `continue` alone is not handoff authority | After source-turn settlement, retire the old run before assigning the checkpoint and exclusive worktree to a distinct exact replacement run/thread | Missing settlement, stale handoff authority, or retirement/binding mismatch fences or pauses with the old work preserved and gives the replacement no work |
| Automatic physical-primary rebind | Stable logical primary, exact old semantic thread and current endpoint lease, replacement cause, unused work-item rebind allowance derived from durable binding/episode history, episode/candidate and non-current candidate lease, clean continuity attempt, fixed global-sequence packet frontier `F`, input/operation/role state | Mechanical continuity only: beginning the first replacement episode consumes the sole work-item allowance; matching cleanly finalized re-prime/direct confirmation and endpoint-handoff attempts create no product/workflow decision | Transfer the old lease to episode cleanup, fence/invalidate it, and prove process/session absence before provisioning a replacement. Freeze `F`; clean packet acknowledgement records pending install at `I = F` without chasing later writes. Clean direct confirmation and candidate attach precede one handoff that transfers the candidate lease and makes semantic/presentation routing/readiness current together; later records drain in fixed finite prefixes before semantic calls | Old-endpoint cleanup failure terminalizes `rebind_failed` at candidate count zero. Later candidate/attach/handoff failure must prove candidate-lease teardown before the episode's sole candidate retry. After episode exhaustion—or any later rebind trigger once the global allowance was consumed—settle/fence active work, preserve state, render fixed status, and open no episode/candidate |
| Pending-input delivery/reissue outcome | Exact admitted input state, original input, outbound-call journal when present, replacement binding, linked call if reissue is eligible, and physical-attempt deadline/outcome | `queued_not_dispatched` uses one ordinary delivery; only outbound-journaled `dispatched_pending` without a terminal result may use mechanical exactly-once reissue after physical loss. Neither creates semantic authority | One eligible typed result closes the state and enters ordinary decision currentness. Ordinary deadline/failure records `input_delivery_failed`; reissue deadline/failure records `reissue_failed`. Both preserve input, close automatic eligibility, permit later input, and enter bounded failure summary | Only fresh typed direction may create a distinct retry/supersession; timed-out/failed/late calls, duplicate ordinary delivery, and any second automatic reissue are ineligible. Timeout-triggered rebind does not revive the input call |
| Unfinished non-user primary semantic operation after rebind | Stable logical operation ID in `queued_not_dispatched`, or in `dispatched_pending` with its physically lost old attempt and no terminal deadline/error outcome; exact operation kind/schema, authority source, consumed frontier/artifacts, currentness predicate, and newest-input boundary; replacement binding fully caught up | Mechanical continuity of computation only; any resulting typed interpretation remains the logical primary's semantic authority | If every bound input/authority remains current, a queued operation receives its ordinary first attempt and an operation dispatched before physical loss with no terminal outcome receives one replacement attempt under the new epoch. Its eligible typed result closes the same logical operation only after physical settlement | Newer input or superseding state records semantic `superseded` but waits for settlement/fence before successor dispatch. Timeout/error records `primary_operation_failed`; after settlement/eligible binding, non-summary failure opens one attention summary. Actual current-summary failure with no newer input renders fixed facts; superseded summary yields to that input. Rebind cannot revive terminal work |
| Post-binding primary semantic-call settlement | Exact call-attempt journal, `send_started` marker, binding/thread/turn when known, controller-owned routed-receipt notification window, five-minute deadline, operation/input kind and identity, every started/terminal action, finalization lease, and controller timer | Mechanical outcome/settlement classification only; no model interpretation or retry authority | Every logical outcome opens a 30-second settlement window. Exact `turn/completed` closes new action starts and is clean only after terminal outcome for every prior-started action; notification evidence remains authoritative when `thread/read` omits actions. Success is eligible only after that causal close, state-consistent final snapshot and routed frontier validation, and durable attempt settlement consume the lease as finalized | Proven pre-send failure needs no settlement. Notification-integrity, post-return persistence/validation failure, unexpected action type, unknown-turn ambiguous send, or missing settlement consumes the exact lease through abort/fence and fences/rebinds the thread. Provisional success becomes kind-specific `physical_settlement_failed`; other terminal semantic work remains failed/superseded and cannot retry |
| Root assessment becomes restart recommendation | Eligible root-assessor result bound to current intent, attempt, and start snapshot, with each of the three exact restart predicates present once, true, and supported by specific evidence | Exact primary interpretation/adoption produces its own restart recommendation over the same identities | Record recommendation and permit presentation of that exact proposal; the assessor never recommends or authorizes restart | Missing, duplicate, unknown, negative, narrowed, evidence-free, stale-identity, or rejected assessment produces no restart proposal/effect |
| Positive restart authority and rewind | Current `presented_response` decision envelope for the exact restart proposal, typed primary interpretation, and independent matching semantic-verifier result | User response plus the two exact agreeing interpretations, still current at the serialized effect-start boundary | Record authority, start the effect only if no newer user turn exists, restore and read back the implementation-start snapshot, then create a fresh attempt | Rejection, clarification, disagreement, verifier failure, invalidated presentation, newer user turn, or stale identity applies no effect and pauses; rewind never occurs without current user authority |
| Candidate construction | Accepted plan, current attempt base, settled implementer terminal turn, intended complete quiescent worktree contents, and exact Git commit/tree/diff read-back | Exact primary adoption of the settled implementer outcome and intended candidate contents | Record one immutable candidate and permit isolated candidate-bound reviews | Unsettled/fenced run, construction/read-back mismatch, or unadopted implementation output leaves no eligible candidate |
| Correctness/cohesion/native review and findings | Eligible iterative reviewer outcomes from the exact candidate, followed by a successful direct `codex review --commit` process bound to that candidate and one eligible one-turn structurer outcome over its complete raw output; every structured finding has a mechanically present raw anchor | Exact primary synthesis/adoption consumes raw plus structured native evidence, dispositions every actionable finding, and affirms no material raw finding is unmapped | Clean converged lenses permit the next gate. Accepted code change invalidates the candidate before constructing a replacement from the same attempt base | Native nonzero exit, 10-minute timeout, cleanup failure, structurer/schema/anchor/completeness failure blocks. Timeout terminates the isolated process group, cleans the disposable checkout, never structures partial output, and does not retry. Every replacement candidate re-enters affected reviews |
| Final validation | Exact controller-owned validation run, command results, candidate checkout, and Git identity | Explicit mechanical exception; no primary adoption is invented | Record validation only for the current candidate; a clean result permits closure | Failure, incomplete command, or stale candidate blocks closure and integration |
| Implementation closure | Eligible independent closure-verifier result bound to exact accepted plan and validated candidate | Exact primary adoption of the closure result | Record closed status and permit the integration proposal only when plan coverage has no missing/extra behavior | A code-only correction supersedes the candidate and re-enters candidate gates. A plan-level correction is eligible only when it names a material implementation delta. Its acceptance invalidates the old plan/candidate gate lineage and creates the next immutable N+1 after any due auto-iteration user checkpoint. After N+1 closes, it must receive the ordinary final closed-plan user authorization; only then may the implementer apply the code change and construct a fresh commit before all candidate reviews, validation, and closure run normally. A clarification with no implementation delta is not plan supersession and cannot create a same-commit candidate exception |
| Integration proposal and effect | Current `presented_response` decision envelope over the exact primary summary/proposal, accepted plan, final candidate, reviews, validation, closure, and base; plus matching independent semantic-verifier result | User response plus the two exact agreeing interpretations, still current at the serialized effect-start boundary | Record authority, start only if no newer user turn exists, fast-forward only the authorized candidate, then Git commit/tree read-back and completed effect | Rejection, clarification, disagreement, invalidated presentation, newer user turn, stale base/candidate, or failed read-back preserves the candidate and pauses; incomplete effects are reported, not retried automatically |
| Final authoritative-host ITD | Current `presented_response` decision envelope over the complete ITD and exact completed integration candidate/effect/tree/evidence identities | The exact primary interpretation is the accountable accept/reject/defer authority; no independent verifier is used because every disposition is durable and creates no host effect in this PoC | Derive and record the ITD decision/disposition/evidence from those bound records; later presentation only summarizes it | Reject/defer is a valid durable disposition and authorizes no dependent host architecture work; invalid/stale envelope or incomplete evidence blocks persistence |
| Effect acknowledgement / attention summary | Exact completed/incomplete effect or failed-operation state, current workflow/attachment state, and newest admitted input | When a primary exists, one distinct typed `attention_summary` operation consumes those records but creates no new authority. Fixed mechanical status is eligible only when no primary exists after activation/rebind exhaustion or when that attention-summary operation terminally fails without newer input superseding it | Record attributable primary presentation, or explicitly record the non-semantic fallback render; show only outcome/preserved state/blocker/next permitted action supported by the chosen path | Actual summary failure leaves authoritative state unchanged and does not recurse. Newer input marks the summary `superseded`; after settlement/fencing, suppress stale output/fallback and process that input by `input_seq`. The controller fallback cannot interpret, recommend, or claim primary authorship |

The inventory is intentionally transition-specific. New product behavior that
introduces another semantic state advance or external effect must add a row (or
show that an existing row fully covers it), its controller site, and its
negative path before implementation.

## Prototype acceptance narrative

The bounded live run creates a disposable repository from `poc/fixture/` and
executes this happy-path story; it never integrates an unrelated user repository.

1. Voice intake becomes durable accepted intent through the accountable primary.
2. A planner and both independent review lenses converge on an immutable plan;
   the user receives the compact consequence-led checkpoint when due and
   separately authorizes the exact closed plan before coding.
3. An implementer works in an isolated worktree while the controller runs the
   bounded observer. A drift assessment reaches the primary during the active
   turn; the primary successfully steers that same turn without interruption.
4. A settled checkpoint receives primary direction, then a distinct handoff
   retires the old worker before its replacement continues from durable context.
5. The replacement discovers the revised fixture constraint. The user accepts
   revised intent without changing implementation state.
6. The independent root assessor evaluates all three restart predicates. The
   primary recommends restart, the user separately authorizes it with independent
   semantic confirmation, and only then is the active implementation worktree
   restored to its verified start snapshot; durable control-plane history remains.
7. A fresh planner raises one technical ask, receives the primary's answer, and
   completes a newly reviewed and user-authorized plan. A separate implementer
   produces one immutable candidate.
8. Correctness and cohesion review/fix loops converge on complete replacement
   candidates. One fresh native Codex hard review then runs over the whole
   attempt-base-to-candidate commit, and its complete raw result is structured
   and dispositioned without becoming a second review.
9. Isolated validation and implementation-to-plan closure pass on the final
   candidate. Any code or material plan change returns through its ordinary
   upstream gates.
10. The user receives a compact integration proposal, independently confirmed
    positive authority permits only the exact fast-forward, and commit/tree
    read-back precedes completion.
11. The completed evidence grounds the final authoritative-host ITD; the primary
    records the user's accept, reject, or defer disposition without changing host
    architecture in this PoC.
12. During the run, one planned physical-primary replacement freezes packet
    frontier `F`, installs at `I = F`, and later drains one finite prefix
    through `D` while an independent worker continues writing. The same logical
    primary resumes without user-operated recovery. The fixture/live payloads
    remain within Decision 11's pinned-model context boundary.

Waiting, failure, and incomplete states use the transition map's primary summary
or explicitly non-primary no-binding fallback; neither invents authority.

## Work plan

The authority-transition inventory is the single normative source for eligible
producers, adoption, effects, and negative paths. The temporal-composition
section is the single normative source for ordering, ownership, concurrency, and
adversarial cases. The steps below name implementation sequence without
restating either contract.

### 1. Preserve the bounded product and rewind boundary

- Keep the existing disposable fixture, implementation-start Git snapshot,
  append-only control-plane evidence, and already accepted user-facing workflow.
- After fresh implementation approval, restore only the E15 receipt-through-
  finalization and worker-budget/observation subsystem named in the targeted
  rewind boundary; preserve unrelated primary/agent, Git, review, and
  presentation behavior.
- Keep historical architecture and review documents as process inputs; their
  maintenance is not runtime implementation work.

### 2. Remove superseded proof machinery

- Remove Python natural-language interpretation, the earlier cue/occurrence and
  P01-P18 proof APIs, projection-equality/final-PASS machinery, and ordinary-run
  executable provenance obligations.
- Keep only retained initialization/capability checks and the mechanical typed
  transition validation required by the closed inventory.

### 3. Rebuild the controller-owned authority boundary

- Implement the canonical notification-window, routed-frontier, provider causal
  close, durable closed-turn lookup, finalization lease, reader-wide failure,
  control-attempt deadline, and subject-specific settle/fence contracts across
  controller, kernel, and runtime.
- Implement the canonical startup/capture token, presentation-generation winner,
  endpoint handoff, single work-item rebind allowance, ordered input/reissue,
  non-user primary-operation, and correction-reservation-versus-effect contracts.
- Keep all program code semantic-free: models interpret opaque language; code
  validates only typed fields, identities, state, deadlines, and currentness.

### 4. Preserve the primary-led workflow

- Bind every role assignment, in-run report, terminal result, primary direction,
  handoff, and adoption to its exact run/thread/output and worktree authority.
- Exercise planner/implementer handoff, bidirectional ask, proactive and scheduled
  checkpoints, accepted-intent revision, the three exact restart predicates with
  per-predicate evidence, primary recommendation, user authorization, and
  independent positive co-sign.
- Implement plan-review closure from the canonical severity/scope matrix,
  three-version automatic checkpoint, mandatory final-plan review, and verified
  positive implementation authority.
- Implement Decision 9's controller-scheduled low-cost observer over immutable
  progress snapshots and Decision 10's immediate `observer_attention` primary
  assessment. Observation alone remains non-blocking; only an eligible primary
  decision may continue, exact-turn steer, interrupt/pause, or escalate.
- Remove the existing continuing-worker five-minute/six-action work frontier,
  its automatic interrupt, budget overrun, and synthetic budget-checkpoint turn.
  Preserve action inventory only for notification integrity and settlement;
  finite deadlines remain permitted for one-shot evaluator roles and do not
  interrupt the worker they observe or review.

### 5. Preserve candidate-bound delivery

- Construct one complete immutable commit per candidate; bind correctness,
  cohesion, native hard review, validation, closure, and findings to that exact
  identity and invalidate downstream gates after every code-changing fix.
- Run native hard review read-only with the canonical bounded deadline,
  process-group termination, disposable-checkout cleanup, partial-output
  exclusion, and no-retry behavior; structure only complete raw output through
  the non-authoritative tool-less adapter.
- Require current user authority plus independent positive agreement before
  disposable fast-forward, then read back commit/tree and present the genuine
  authoritative-host ITD against completed PoC evidence.

### 6. Validate proportionately

- Deterministic tests cover every canonical temporal composition case and every
  touched transition's success/failure boundary through the production reader
  path. Retained unrelated capability tests stay unchanged.
- The bounded live run exercises only the natural happy-path narrative,
  including the one deliberately planned physical-primary replacement at its
  named safe boundary. It does not manufacture review findings, delays, rebind
  failures/retries, or extra plan versions to force a conditional branch.
- Final reporting is derived from SQLite and Git identities and states the
  accepted intent, attempts, roles, decisions, findings, validation, closure,
  limitations, and exact disposable Git result.
## Site list and required behavior

The authority inventory and temporal-composition sections define behavior; this
list identifies every implementation surface that reads, writes, or composes
with it.

- `poc/kernel.py` — durable schemas and single-writer transitions for global
  ledger order, primary binding, control/semantic attempts, notification-linked
  settlement/fence, presentation/capture and endpoint ownership, input/reissue,
  role assignment/adoption, observer snapshots/assessments, exact-run
  `observer_attention` operations, progress-frontier provenance/dominance,
  action-specific intervention currentness, observer-run
  failure streak derivation, and steering/interrupt results; remove continuing-
  worker work-deadline/action-count/budget-checkpoint state and transitions;
  preserve plan/review closure, candidates,
  findings, effects, validation, and ITD state. Add no generic authority or
  second endpoint store; keep fixture seeding test-only.
  The removal surface includes continuing-worker `work_deadline_ns`,
  `record_role_action_started` ordinal/time-frontier behavior,
  `close_role_time_frontier`, and budget-checkpoint reserve/start transitions;
  retain the ordinary reserve/bind/settle/fence role-turn contract.
- `poc/controller.py` — App Server startup/version qualification, bounded
  framing, receipt routing/frontier, the three-subject notification lifecycle,
  causal-close recognition, finalization/abort leases, reader-wide failure,
  control/one-shot deadlines, exact-turn `turn/steer`, primary-selected
  interrupts, structured fixed-frontier steering deltas, bounded one-in-flight/
  one-pending observer dispatch, fixed-prefix candidate binding and per-call
  active-binding drains, endpoint handoff,
  presentation cleanup, and
  fixed no-primary status. The production reader path is authoritative.
  Remove `role_budget_*`, `_close_role_time_budget`,
  `_request_role_budget_interrupt`, and budget-only observation branches; retain
  role notification monitoring and primary-selected/protocol interrupts.
- `poc/prototype.py` — primary interface/runtime/workflow orchestration:
  typed intake and capture handles, ordered input, activation/rebind, model-call
  lease handoff, plan/review loop, immediate observer-attention assessment,
  action-specific steering/pause/escalation, internal-pause continuation, removal of the
  continuing-worker budget-checkpoint path, agent asks/handoff, restart,
  candidate/review/validation/closure, high-stakes confirmation/correction,
  integration, and final ITD. Reject unclassified primary turns and the governed
  `--console-ui` path; keep console/scripted interfaces as test doubles.
  Remove the `budget_checkpoint` role turn and its continuation path rather than
  translating it into an observer checkpoint.
- `poc/pty_tui.py` and `poc/native-cli-prototype.sh` — stock-CLI presentation
  readiness, capture/detach, correction listening, and the canonical fixed
  paused/stored-not-accepted/re-presented/reopened/exactly-once states.
- `poc/qualification_pty_tui.py` — retained Phase-4 capability qualification,
  separate from ordinary intake.
- `poc/run-prototype.sh` — initialization, governed run, proportional
  assertions/reporting, and cleanup; no alternate intake or terminal PASS
  auditor.
- `poc/preflight_validation_sandbox.py` and `poc/provenance.py` — retain only
  bounded initialization/capability uses; remove ordinary-run proof/provenance
  obligations.
- `poc/roles/prototype-primary.md` — typed primary continuity, delegation,
  adoption, plan synthesis/authorization, decision-envelope, review
  completeness, `observer_attention` progress-frontier decisions, internal-pause
  next action/resume condition, attention-summary presentation mode, and ITD outputs.
- `poc/roles/semantic-verifier.md` — isolated tool-less positive confirmation
  for restart, integration, and closed-plan implementation only.
- `poc/roles/native-reviewer.md` — tool-less structuring of complete raw native
  review into anchored findings, with no decision authority.
- `poc/roles/workflow-planner.md`, `workflow-implementer.md`,
  `workflow-observer.md`,
  `workflow-plan-reviewer.md`, `workflow-red-team.md`,
  `workflow-correctness-reviewer.md`, `workflow-cohesion-reviewer.md`,
  `workflow-root-assessor.md`, and `workflow-closure-verifier.md` — exact
  exercised-role schemas and authority boundaries. Create the observer role
  from this Plan; do not reuse a worker budget-checkpoint prompt. The root assessor receives
  the three exact predicates bound to current intent/attempt/start snapshot.
- `poc/fixture/PROTOTYPE_WORK_ITEM.md`, `REVISED_CONSTRAINT.md`,
  `candidate_contract.py`, `expected.txt`, `input.txt`, `memory_gate.py`,
  `naive_in_memory.py`, and `repository.gitignore` — disposable task,
  constraint, snapshot inputs, and validation fixtures. Legacy
  `WORK_ITEM.md`/`SPILL_OPTIONS.md` remain capability fixtures only.
- `poc/test_kernel.py`, `test_authoritative_kernel.py`,
  `test_controller.py`, `test_prototype.py`, `test_pty_tui.py`, and
  `test_phase4.py` — deterministic coverage of every touched transition and
  deliberate composition case through production-equivalent seams, including
  provider causal close, finalization/reader races, capture/correction/effect
  ordering, global rebind allowance, plan closure, agent settlement/handoff,
  restart predicates, non-blocking observation plus primary-authorized
  exact-turn steering/interruption, bounded scheduling, progress-frontier
  provenance and action-specific currentness, repeated-failure degradation,
  removal of continuing-worker
  budget interruption/checkpoints, voice-first pause/plan presentation, native-review
  failure, candidate, and narrative paths.
- `poc/test_support.py` — fixture-only durable run-completion helpers used by
  scripted tests. Keep every shortcut outside production and ineligible for
  notification/finalization composition tests; update it when the role-run
  settlement contract changes.
- `poc/test_provenance.py` and `poc/test_validation_sandbox.py` — narrowed
  retained capability/initialization coverage only.
## Temporal composition

The shared invariant is: **the controller records and validates one current
semantic workflow state, while only the primary interprets meaning and only
typed current-state transitions may create effects.**

| Event | Authority and next state | Observable effect and durable record | Retry / cleanup |
|---|---|---|---|
| Pre-work primary startup | Before a work item exists, bootstrap, initial attach, and first-intake acknowledgement reserve `pre_work_startup` attempts plus the exact startup presentation lease. | Clean capture finalization creates a one-use token. Its consume transaction alone creates the work item, unbound primary state, and canonical initial input at `input_seq = 1`, then returns that identity. | Any invalid/unsettled attempt fences the provisional thread, preserves capture/evidence, proves lease teardown, emits fixed startup-failure facts, and stops without activation/rebind or retry. |
| Initial physical-primary activation | Controller consumes the token-created input identity, opens an episode, freezes packet frontier `F`, and reserves candidate-owned attempts/lease before the packet, direct confirmation, and required candidate-thread attach. | Clean packet acknowledgement records pending install at `I = F` without chasing later writes. Clean confirmation plus exact startup-lease transfer or clean candidate attach permits one endpoint transition that makes semantic/presentation routing and readiness current together. Records after `I` remain ordered and drain through a newly fixed finite prefix before each semantic call. | Failure fences candidate/generation and must prove the presentation absent before retry. Unproven cleanup terminalizes immediately; otherwise candidate two is the sole retry. Two retired failures produce `primary_start_failed`, preserve input/work, and render fixed status. |
| Work activation | The bound primary accepts direct-intake intent; controller moves inactive work to planning only after verbatim intake and typed intent are durable. An agent thread cannot receive work before exact delegation or a transition that mandates its fixed role. | Assignments record authority source, role, purpose, context/artifacts, worktree permission, and actual App Server thread ID; controller validation uses its stable runtime identity. Routine observation may overlap after assignment but grants no authority. | Missing/stale authority, provisioning failure, or wrong role/context/worktree stops before agent work; a distinct authorized run may be started. |
| App Server model-turn notification window | Controller reserves a role-turn, post-binding primary-attempt, or closed-purpose primary-control-plane subject and arms its exact thread before send. The reader assigns and fully routes each accepted envelope before advancing the contiguous routed frontier; exact-turn binding replays the complete queue before live delivery. Under the pinned qualified provider contract, exact `turn/completed` causally closes that turn's item lifecycle after every started item has its terminal lifecycle notification; `thread/read` is only later snapshot/output validation. | The final `thread/read` response carries its routed frontier and provisional output with one exact finalization lease. One serialized operation requires that frontier to contain the causal close and every earlier lifecycle receipt, validates the snapshot and clean window, records closure together with the subject's existing settlement or permitted control-plane transition, retires the in-memory window, consumes the lease, and only then exposes eligibility. Notification evidence remains authoritative when absent from `thread/read`; every control-plane subject requires zero actions. | Version/qualification drift, a same-turn lifecycle receipt after causal close, malformed/oversized/overflowing or identity-contradictory input, invalid lifecycle/type, clean EOF, reader exception, interrupt error, any control-plane action, post-return persistence/validation failure, or unknown primary turn purpose consumes the lease through the subject-specific rejection/failure/fence path and wakes armed/active waiters. No assigned-to-routed, response-to-binding, provisional-return-to-abort, eligibility-to-retirement, or finalization-to-fence gap may admit dependent work. |
| Primary presentation control-plane turn | Typed controller state selects exact purpose, owner, thread, generation, and finite deadline before send/forwarding. Captured text is stored but not yet admitted. Candidate attach targets the candidate explicitly. Confirmation pending leaves a correction capture open; reservation of new opaque text blocks effect start. | One generation-serialized boundary rechecks the deadline and makes clean finalization create a one-use startup-token handle or post-intake admitted-input handle (`input_id`/`input_seq`/generation/text); detach/rebind instead permanently blocks release. A later detach cannot override a winning durable handle, and the consumer resolves the exact terminal before interpreting detach. A confirmation-pending admitted handle invalidates older authority. Clean candidate confirmation+attach precede endpoint handoff. Bare completion changes none of these states. | Unknown/stale owner/purpose/thread, action, invalid lifecycle, expired deadline, or failed finalization follows its owner disposition. Losing capture returns no handle, remains preserved/unreleased, keeps the effect no-op, and requires re-presentation after intake; no consumer may admit raw text again. Fixed presentation states distinguish listening paused, stored-not-accepted, re-presentation, listening reopened, and one accepted response. |
| Routine worker observation | A cadence/progress trigger snapshots the active worker and progress frontier only when no observer is in flight. During one in-flight observer, later triggers replace one latest-pending snapshot; settlement starts at most that one catch-up. | Persist typed assessment/failure and frontier. Batch `on_track`; attention/uncertainty opens or joins next-available `observer_attention`. Derive consecutive failure streak from run outcomes; threshold two emits one `monitoring_degraded` fact per streak and mandatorily enters that path. | Observer deadline/failure closes only it. Waiting/pause stops new dispatch; resume snapshots fresh state. Handoff, retirement, supersession, or terminal state disables old scheduling and makes a late result historical. No observer path interrupts the worker. |
| Immediate observer-attention assessment and steering | The controller persists one `observer_attention` operation with exact run/owner/assignment/thread/active-turn identities, coalesced assessment frontier A, and fresh worker-progress decision frontier before the primary call. If another primary operation is unresolved, the assessment remains durable and becomes the next eligible primary operation rather than opening a parallel call. | One eligible settled primary result chooses `continue`, `steer`, `pause`, or `escalate`. `continue` acknowledges A without worker effect. Current `steer` records request/frontier before send, uses exact `expectedTurnId`, attaches the structured delta through a fixed send frontier, accepts only a matching turn, and leaves ordinary worker settlement pending. Current `pause`/`escalate` interrupts and settles; pause schedules its named internal next action and informational status, while escalation opens the user question. | Only one operation/effect is current per run. Ordinary compatible same-turn progress is not a conflict. Dominated consumed assessment, completed turn, checkpoint/terminal winner, handoff, retirement, supersession, owner/assignment change, or proven stale/non-steerable/pre-send rejection is no-effect; reassess current evidence or let the winning ordinary boundary consume it. Possibly admitted steering with send/reader failure or mismatched/unprovable response fences as incomplete delivery and cannot retry or auto-interrupt. Interrupt/settlement failure uses the common fence. Supersession settles/fences the physical primary attempt before relevance is rechecked. |
| In-run report and continuation | Every voluntary checkpoint, inflection report, or ask remains provisional until its exact turn and all started actions are terminal. | A settled report reaches one ordinary primary direction/answer after any current observer-attention path terminalizes; exact direction gates only dependent work. | Missing settlement uses the common role fence. Unresolved asks and explicit pause-worthy reports preserve work and block dependent progress; stale directions are rejected. |
| Normal role completion | Agent returns a typed outcome from the exact App Server thread bound to its run; it remains provisional until that turn and every started action are terminal. After any current observer-attention path terminalizes, a separate primary call adopts/revises/rejects/escalates that exact producer/run/output. | Assignment precedes work; turn/action settlement and attention-path terminality precede eligible role outcome disposition, handoff/owner release, candidate construction, and next assignment. | Missing settlement fences the run and assigned worktree/checkout. Revision creates a distinct linked authorized run; completed runs never reopen, and absent or mismatched adoption blocks every dependent transition. |
| Direct native-review subprocess | Controller launches exact read-only `codex review --commit` in an isolated process group and disposable immutable candidate checkout with a 10-minute deadline. | Only normal process exit plus complete raw output may enter structuring. Timeout terminates the process group and cleans the checkout. | Timeout, nonzero exit, cleanup failure, or partial output blocks the gate; partial output is never structured/adopted and no automatic retry occurs. |
| Plan review convergence | The primary adopts planner output as immutable N. Both reviews bind to N; one synthesis records every finding's compatible severity/scope disposition and rationale. | A batch with blocking/significant in-scope findings cannot close; it produces N+1 or, after invalidity rejection, one fresh independent same-version verification. Blocking adjacent pauses for scope decision; permitted adjacent findings defer. Only a current clean batch plus exhaustive compatible dispositions closes N for final user authorization. | Missing/incompatible disposition or dirty verification remains open. After three consecutive automatic versions, `plan-review-auto-iteration-limit` pauses before the next version and enters the checkpoint; numbering/history remain. |
| Plan auto-iteration user checkpoint | A fully rendered current decision envelope binds checkpoint, lineage, synthesis, count, proposed next action, any closed plan, and response; its voice lead is the compact problem/outcome, material delta, review status/risk, and exact consequence, with full drill-down available. | Primary interpretation is schema-constrained; positive `proceed_closed_plan` is allowed only with a bound closed plan and requires matching semantic verification. | Current revise/proceed resets the auto counter. The presentation distinguishes creating/reviewing N+1 from authorizing coding from exact closed N. Qualified approval, newer input, invalid/stale envelope, disagreement/failure, or pause authorizes no transition. |
| Final closed-plan authorization | Every closed plan and complete lineage are bound in a current decision envelope, even before the auto checkpoint; the voice lead is the compact summary and explicitly says that positive authority starts coding from exact N. | Only current unqualified `proceed_closed_plan` plus matching verification authorizes that version; current qualified approval is `revise_next_version`. | Either actionable direction resets the auto counter. Implementation consumes only the authorized plan; revision returns through N+1. Invalid/stale/pause outcomes preserve lineage and reset nothing. |
| Automatic physical-primary rebind | Controller derives the unused global allowance from durable history, consumes it when the first replacement episode begins, then transfers the old endpoint lease to cleanup, fences/invalidates it, and proves exact process/session absence before candidate one. | Clean continuity advances only pending state. Clean direct confirmation plus clean attach permit one handoff that transfers the candidate lease and changes semantic/presentation routing/readiness together. Only then do input and exact eligible unfinished operations resume. | Old cleanup failure terminalizes `rebind_failed` at candidate count zero. Candidate failure may use only that episode's sole retry. Any later rebind trigger after the allowance is consumed opens no episode/candidate, drains/fences active work, preserves state, and renders fixed terminal status. |
| Primary semantic-operation terminal failure | Explicit error, invalid terminal output, send failure, supersession, or five-minute timeout closes the logical operation without retry, while any possibly dispatched physical attempt remains unsettled. | Only after full turn/action settlement, or thread fencing plus replacement binding, may the current state create its next operation. A non-summary `primary_operation_failed` then creates one attention summary; a successful current summary is attributable communication only. | Actual summary failure with no superseding input renders fixed labelled facts once after settlement/fencing, makes no recursive call, preserves work, and waits for fresh input. Superseded summary suppresses stale output/fallback and yields to the already-admitted newer input in sequence. |
| Pending-input delivery/reissue | Admitted/queued input without outbound journal receives one ordinary delivery. Outbound-journaled input without any terminal outcome may receive the sole linked reissue after physical loss; either has the shared attempt deadline. | Eligible result closes only after physical settlement. Ordinary logical timeout/failure becomes `input_delivery_failed`; reissue becomes `reissue_failed`; both preserve input. Later input/summary dispatch waits for settlement or fenced-thread replacement. | Timed-out/failed/superseded/late calls, duplicate ordinary delivery, timeout-triggered rebind, and second automatic reissue are rejected; a fresh directed call is distinct. |
| Post-binding primary semantic-call settlement | `send_started` separates proven pre-send failure from possibly dispatched work. Success or logical failure does not settle the attempt; five minutes closes unresolved semantic eligibility. Runtime return transfers the exact finalization lease to its workflow consumer. | Every logical outcome opens 30-second settlement. The clean-finalization operation requires terminal exact turn, terminal outcome for every notification-derived started action, state-consistent final snapshot, and its routed response frontier; only its transaction consumes the lease as finalized and makes success eligible. | Any pre-finalization integrity loss, post-return persistence/validation failure, unknown-turn ambiguous send, or missing settlement consumes the lease through abort/fence and fences/rebinds the thread. Provisional success becomes kind-specific `physical_settlement_failed`; terminal/superseded work cannot be retried. |
| Abnormal failure before effect | Controller records the affected run/work as failed or blocked and stops the dependent path. | No success, approval, or integration is reported. | No automatic retry; retained evidence supports a user/primary-directed fresh run. |
| Pause | An ask, clarification, rejection, required user decision, or eligible primary internal hold moves only dependent work to waiting. An ask gates its dependent consumers while preserving the active run, physical thread, ownership, and independent progress; `fence` remains reserved for settlement/integrity failure. An internal hold must name its next internal action and resume/steer/handoff/escalation condition; no user authority is inferred. | The reason exists before presentation. Internal hold is informational and says no action needed; only an actual user dependency is action-required and asks one concrete question. | Internal action may produce a fresh primary direction; user-dependent resume requires a typed answer. The controller rechecks all identities before admitting consumers. |
| Resume | Primary records the resolved ask or fresh direction; controller rechecks the same current work/attempt/run identity. | The same physical App Server thread receives the answer and a bounded re-prime packet while the run retains ownership. | Stale/superseded work cannot resume; a new physical thread requires a new run or handoff. |
| Cancellation or abandonment | Only an explicit typed user-authorized abandonment terminates the workflow state. | Record the reason and terminal state while preserving worktrees, artifacts, findings, conversations, and all other evidence. No cleanup, deletion, reset, integration, or external effect occurs. | Not automatically retried. Rejection alone is not cancellation. Any future cleanup is a distinct high-stakes proposal with its own authority policy. |
| Handoff / owner replacement | A typed primary `handoff` decision bound to a settled checkpoint, old run, quiescent worktree/artifact identities, and replacement follows source-turn settlement; controller retires the old run before assigning work to the replacement. `continue` alone cannot change owners. | Both runs and the primary handoff decision link to one work item, plan, checkpoint, and Git/worktree identity. | Missing settlement, stale authority, or identity mismatch fences/blocks; the replacement receives no work and the system never silently falls back to transcript memory. |
| Retry or replay | General model/transport-error retry is not part of this prototype. Bounded continuity exceptions are the single second activation/rebind candidate, one linked pending-input reissue, and one new-epoch physical attempt for a still-current unfinished non-user primary semantic operation after successful replacement. | Each exception has exact episode/attempt/thread and input-or-operation identity and starts only from its named durable predecessor. Post-failure directed semantic work is a distinct call, not continuation of automatic eligibility; activation/rebind exhaustion has no in-PoC recovery call. | Earlier records remain immutable. Episode exhaustion returns to its fixed terminal failure state; reissue/operation failure terminalizes once and pauses its dependent path; no path silently loops. |
| Controller/database process restart or crash recovery | Not claimed; the physical-primary rebind above does not cover control-plane failure. | Incomplete durable state may be displayed but not silently resumed. | User/primary chooses a fresh run; automated reconciliation is deferred. |
| Accepted-intent revision | A separately presented product-constraint proposal and explicit user decision create a new accepted-intent version. | The new intent and its authority are durable; an incompatible plan/attempt pauses, but its worktree is untouched. | Rejection changes neither intent nor execution. Accepted intent remains current while the user chooses restart or another direction. |
| User decision envelope | Direct intake binds input plus interpretation epoch. Proposal response separately binds presentation epoch (active through render/admission), subject/input sequence, and interpretation epoch (active for primary call). Positive confirmation pending also binds one correction-capture window to the approval epoch. | Epochs may differ only after admitted-input rebind. Durable interpretation survives later rebind; verifier/effect waits for catch-up/currentness. Reservation of newer opaque input blocks effect start; clean admission invalidates the old authority and follows ordinary ordered delivery. Input dispatched before physical loss with no terminal outcome gets one reissue; pre-admission rebind or failed correction capture keeps no effect and requires re-presentation. | Pre-render input, invalid historical epoch, unstable logical primary, detach/replacement/rebind before admission, newer input or pending correction capture, subject/state supersession, or verifier disagreement invalidates/blocks authority. If effect start serializes first, later input is next direction only. The controller never interprets correction text or requires valid cross-rebind epochs to equal. |
| Clean attempt restart | A positive current assessment supplies all three exact restart predicates once, true, and with specific evidence. That assessment plus a separate primary recommendation, both bound to the same intent/attempt/start snapshot, precede user-positive restart authority and independent co-sign. Only then may the controller abandon execution state, restore and verify the snapshot, and create a fresh attempt. | Per-predicate evidence, primary recommendation, intent, decisions, findings, and other control-plane history remain append-only. | Missing, duplicate, unknown, negative, narrowed, or evidence-free predicate results, rejection, or disagreement preserve the current attempt and pause; they do not undo accepted intent. |
| Candidate supersession | Primary accepts a code-changing finding; controller invalidates the current candidate before replacement construction. | Old review/validation results remain evidence but cannot authorize integration. | Replacement failure leaves no eligible candidate and stops visibly. |
| Plan supersession after closure | Primary accepts a plan-level closure finding that names a material implementation delta; the prior plan/candidate gate lineage becomes invalid. After any due three-version user checkpoint, the next immutable N+1 enters both-lens review and becomes current only when closed. | N+1 then enters the ordinary mandatory final closed-plan decision envelope. Only independently affirmed `proceed_closed_plan` lets implementation apply the named delta and construct a fresh commit before every standard candidate review, validation, and closure reruns. | The pacing checkpoint never terminates the lineage or replaces final authorization. Until user direction, plan closure, final authorization, code change, and fresh candidate commit, preserved work cannot advance and stale prior-plan gates cannot authorize integration. A no-delta clarification is not plan supersession. |
| Integration | User positive authority plus independent co-sign and immediate Git revalidation allow only fast-forward to the exact candidate. | Requested effect precedes Git command; verified commit/tree and completed result follow it. | A one-sided Git/result failure is surfaced as incomplete; automatic recovery is deferred. |
| Genuine ITD review | Successful PoC evidence makes the pending authoritative-host decision current; the primary presents its complete structure through the shared decision envelope, then interprets the response with exact integration candidate/effect/tree/evidence. | The kernel derives the ITD disposition/evidence from that call without changing disposable Git; no independent verifier is required because no host effect occurs. | Rejection/defer remains preserved; invalid/stale envelope or incomplete evidence blocks persistence and dependent host work cannot assume acceptance. |
| Partial effect/persistence success | Controller never claims completion without effect read-back and durable result. | Incomplete requested/in-progress record remains inspectable. | Stop and surface; no automatic compensation. |
| Concurrent overlap or reordering | One user-level work item and one SQLite writer are active; independent read-only plan reviews may overlap, write roles may not share a worktree. | Actor/current-state checks reject stale or phase-incompatible transitions. | Conflicting work stops; lock/race hardening beyond exercised normal overlap is deferred. |

### Effect ordering

- Verbatim intake precedes primary interpretation; typed accepted intent precedes
  work activation.
- For routine observation, the controller first fixes the immutable observed
  worker, assignment/objective, accepted plan, and worker-progress frontier,
  then starts the sole in-flight one-shot observer. Triggers during that run
  precede replacement of one latest-pending snapshot; observer settlement and a
  still-active-worker check precede at most one catch-up dispatch. The observer's
  settled typed result/failure precedes assessment persistence and routing while
  the worker continues. Two consecutive durable failures precede one
  `monitoring_degraded` fact for that streak; success precedes streak reset.
  Attention-bearing or
  uncertain persistence precedes creation/coalescing of one exact-run
  `observer_attention` operation; its assessment frontier and fresh worker-
  progress decision frontier precede primary dispatch. The eligible primary
  decision precedes action-specific currentness validation. `continue` consumes
  only assessment evidence. For `steer`, a fixed effect-start progress frontier
  and its complete structured delta precede the exact steering-effect request;
  ordinary same-turn progress does not defeat it. For `pause`/`escalate`, exact
  active-turn identity precedes interrupt. A conflicting lifecycle/ownership
  winner precedes no-effect and fresh assessment/ordinary-boundary consumption.
  The exact steering-effect request is
  durable before send; only an accepted `turn/steer` response naming the expected
  turn precedes acknowledgement of `steer`, which does not settle the continuing
  worker turn. Proven rejection precedes no-effect persistence; an ambiguous
  possibly admitted request precedes the common fence and incomplete-delivery
  report without retry or automatic interrupt. Exact `turn/interrupt` response
  plus common turn/action settlement precedes paused/escalated worker state. A
  valid internal pause's named next action and informational presentation
  precede internal follow-up; an escalation's concrete question precedes the
  user wait.
  No-effect or fence persistence precedes any fresh assessment. When checkpoint/
  terminal state already won, its ordinary primary boundary consumes still-
  relevant evidence instead of opening a redundant attention operation.
  Operation/effect terminality precedes another attention operation, checkpoint direction, terminal adoption,
  handoff, owner retirement, successor assignment, or candidate construction.
- Exact delegation or fixed-role transition authority and assignment/context
  references precede agent start. Every consequential model call first reserves
  its exact role, semantic-primary, or primary-control-plane subject. Controller arming
  precedes send; bounded receipt assignment and complete routing precede the
  contiguous routed-frontier advance; waiter-visible responses carry that
  frontier; routed sequencing precedes exact-turn binding; ordered pre-binding replay precedes
  live delivery. The pinned provider orders every complete item lifecycle before
  exact `turn/completed`, which causally closes that turn's item lifecycle and
  durably closes new action-start admission. Terminal outcomes for every action
  therefore precede that close; later snapshot/output validation and its routed frontier
  precede typed finalization-lease transfer and the serialized
  clean-window plus durable-subject transition; in-memory
  retirement precedes release to controller consumers. For every agent-role turn,
  terminal exact-turn status and terminal outcomes for all started actions
  precede report/outcome
  eligibility. An eligible in-run report then precedes its bound primary direction
  and another continuation turn; an eligible terminal role outcome/artifacts
  precede exact primary adoption/disposition, handoff or owner release, candidate
  construction, and dependent phase advancement.
- Any failure after provisional lease transfer and before clean settlement
  precedes exact abort/fence consumption of that lease; exception propagation,
  thread/worktree reuse, successor dispatch, or dependent effect follows only
  the durable terminal disposition.
- For direct primary presentation turns, typed bootstrap/attach/capture state and
  exact owner-classified control-plane-attempt persistence precede send. Opaque
  captured input is stored before its acknowledgement turn, but storage is not
  admission. For the exact presentation generation, detach/rebind invalidation
  and acknowledgement clean-finalization serialize through one kernel boundary:
  before authority release the attempt deadline is rechecked; the winner either
  permanently blocks release or creates exactly one pre-work
  intake token/post-intake `input_seq`. Exact turn/zero-action/final-snapshot
  clean finalization precedes bootstrap or attach readiness. A candidate's clean
  direct confirmation and explicit candidate-thread attach precede the endpoint
  handoff that changes semantic/presentation routing and readiness together.
  Bare terminal notification or `last_primary_completion_ns` authorizes none of
  those transitions.
- A clean pre-work capture token precedes its single consume transaction. That
  transaction creates the work item, unbound primary state, and canonical initial
  input with `input_seq = 1` from the token payload before activation; its
  typed capture/token handle is the only request result and its returned input
  identity is the only initial-intent source. A second raw intake,
  later admission of the same text, mismatched payload, duplicate token consume,
  or tokenless governed console entry is rejected.
- Post-intake capture clean-finalization atomically creates the canonical
  `input_id`/`input_seq` before returning its typed handle. Clarification,
  direction, and proposal-response consumers bind that exact identity and text;
  they never re-admit the text. The consumer resolves that exact durable terminal
  before a concurrently observed detach. Detach after committed admission queues/rebinds
  the same input, while detach that wins before admission returns no handle and
  requires re-presentation.
- A positive response first opens its approval epoch and correction-capture
  window. Reservation of any new opaque capture precedes and blocks effect start;
  its clean admission invalidates the older authority, while capture failure or
  detach keeps the effect no-op and precedes fixed notice/re-presentation. Effect
  start closes that correction window only if it serializes before a reservation;
  later input is ordinary next direction.
- An adopted planner output precedes immutable review-candidate creation; both
  exact plan reviews precede primary synthesis; exhaustive compatible finding
  dispositions precede planner N+1 or same-version invalidity verification; a
  current batch with no blocking/significant in-scope finding precedes exact plan
  closure; closure and complete final-plan presentation precede current user
  `proceed_closed_plan` plus independent agreement; only that authorization
  precedes implementation.
- After the third consecutive automatically reviewed version, the user summary
  and exact direction precede the next N+1. When an exact closed plan is also
  presented, the same envelope may additionally authorize implementation. The
  current actionable `revise_next_version` or independently affirmed
  `proceed_closed_plan` resets only the automatic counter, never plan numbering/
  history; pause, abandon, ambiguity, or invalidity does not reset it.
- An ask precedes pause notification; its answer precedes resume.
- No assignment, candidate, validation, or effect may consume an unresolved ask's
  output or authority. Proven independent work may overlap and remains
  attributable.
- A material proposed constraint and its agent inflection report precede the
  user's separate accepted-intent decision; that decision precedes root
  assessment and any restart proposal.
- All three exact restart predicates precede root-assessor assignment. A
  complete positive current assessment bound to current intent, attempt, start
  snapshot, and all three exact criteria
  precedes the primary's separately recorded restart
  recommendation; both bind the same intent, attempt, and start snapshot before
  a proposal may be presented.
- Full rendering of every presented-response envelope precedes response
  eligibility. Detach, presentation replacement, or physical rebind before
  admission invalidates that ordering and requires a fresh complete presentation;
  after admission, queued-not-dispatched response uses ordinary once delivery and
  only a response dispatched before physical loss with no terminal outcome uses
  one linked reissue. A bound
  response preserves its historically valid presentation epoch; a replacement
  primary interpretation binds its own active epoch. They need not match. The
  response must remain the newest user turn through its serialized transition.
- Once an eligible typed primary interpretation is durable, later physical
  rebind does not erase it. Replacement catch-up and admission of queued input
  precede any pending verifier/effect; exact subject/state and newest-input
  revalidation then precede that transition.
- Primary positive interpretation and independent matching co-sign are durable
  before restart or integration authority.
- Restart authority precedes worktree restore; verified restore precedes the
  fresh attempt.
- Candidate commit/read-back precedes every candidate-bound gate; every
  code-changing fix invalidates the previous candidate before a replacement is
  eligible.
- Correctness/cohesion convergence precedes fresh native hard-review discovery;
  the successful immutable direct-CLI raw result precedes a distinct one-turn
  structuring subagent, whose anchored output precedes primary completeness/
  adoption. A clean final candidate then precedes validation and implementation
  closure.
- An accepted implementation-affecting plan change from closure precedes fresh
  plan review and mandatory final user authorization, which precede its required
  code change and ordinary fresh candidate-commit construction; that invalidates
  all prior-plan candidate gates before any new integration proposal.
- Integration request and exact authorization precede fast-forward; commit/tree
  read-back precedes completed state and the final report.
- The complete authoritative-host ITD, verbatim response, and completed
  integration candidate/effect/tree identities precede its primary
  interpretation; that exact interpretation precedes durable ITD disposition.
- For initial activation or rebind, the global-sequence packet through `F`
  and an exact prompt-only control-plane-attempt reservation precede re-prime send;
  exact terminal zero-action notification closure precedes its typed
  acknowledgement becoming eligible. The transaction records clean closure,
  acknowledgement, and pending install at fixed cutover `I = F` without testing
  the moving maximum. A clean direct
  candidate confirmation plus exact presentation attach/promotion precedes the
  endpoint-handoff transaction; only it makes semantic/presentation routing and
  readiness current together. Before each semantic call, one newly fixed dispatch
  frontier `D`, every ordered record in the unacknowledged prefix through `D`, and
  its clean acknowledgement precede ordered input or primary-dependent work;
  later records remain queued for a later finite drain.
- Candidate presentation process/PTY/transport lease reservation precedes
  physical attach. Any pre-handoff candidate/attach/finalization/handoff failure
  precedes generation invalidation, process/session stop, and quiescence proof;
  only that proof permits candidate two. Missing proof terminalizes the episode
  with its actual attempt count and cleanup reason before any retry or readiness.
- The first rebind-trigger transition verifies and consumes the work item's sole
  allowance before transferring the old current endpoint lease to episode cleanup and
  invalidates its generation before replacement work. Proven old process/session
  absence precedes candidate provisioning or presentation attach. Failure of
  that proof records `rebind_failed` with candidate count zero and precedes any
  use of the candidate budget. Any later trigger after that allowance was
  consumed skips episode/candidate creation and enters agent drain/fence plus
  terminal no-primary rendering.
- On activation/rebind candidate-two failure, durable exhaustion and closure of
  new agent turn/action admission precede interruption of every active role turn.
  Exact turn/action settlement or a durable `role_turn_settlement_failed` run/
  worktree fence precedes the fixed no-primary render. A fenced-unsettled
  worktree remains non-reusable and the status does not claim static contents.
- Every controller-initiated non-user primary semantic-operation record and
  physical-attempt journal precede send. On loss, old-thread fencing and complete
  replacement catch-up precede currentness/newest-input validation; that check
  precedes either one new-epoch attempt for the same operation or durable
  supersession. Only one eligible typed result may close the operation.
- Every post-binding primary semantic-attempt journal records `send_started` and
  starts its five-minute deadline and arms its notification window before
  dispatch. Receipt-ordered binding/replay precedes result eligibility. Logical
  success/failure/supersession precedes physical settlement but never substitutes
  for it. Exact turn terminality plus every notification-derived prior-started
  action's terminality and final snapshot validation precede the serialized
  clean-window/attempt-settlement transaction and consumer visibility. Otherwise,
  unknown-turn/
  30-second settlement failure followed by thread fencing and the sole eligible
  rebind—or terminal no-primary after its allowance—precedes thread
  reuse and successor dispatch. No late result or rebind may reopen terminal work.
- A terminal non-summary `primary_operation_failed` record precedes its distinct
  attention-summary operation. Terminal failure of a still-current summary with
  no superseding input precedes one fixed non-primary render and cannot create
  another summary operation. Newer admitted input instead supersedes the summary;
  settlement/fencing precedes suppression of stale output/fallback and ordered
  processing of that input.
- Direct native-review start precedes its 10-minute deadline. Timeout precedes
  process-group termination and disposable-checkout cleanup. Only successful
  complete raw output may precede structuring and primary adoption; partial
  output, cleanup failure, and timeout block without automatic retry.

### Execution ownership

- The logical primary owns semantic decisions, user communication, context
  selection, delegation, monitoring, and final synthesis across physical
  sessions.
- Its physical binding is controller-owned durable state. Exactly one current
  App Server thread may emit primary decisions in a binding epoch. A replacement
  candidate may only acknowledge its exact fixed-prefix packet, direct confirmation,
  and attach while pending; only endpoint handoff installs the new epoch and
  transfers its presentation lease. No user authority or product decision
  changes during this mechanical activation/rebind. Rebind candidates are
  sequential: a failed candidate is retired/fenced and its presentation lease is
  proven absent before the sole retry,
  and neither failed candidate can become an execution owner afterward.
  Independent agent turns may continue only while a rebind candidate remains
  available. Candidate-two exhaustion makes the controller the sole shutdown
  owner: it closes agent admission, interrupts active role turns, waits for the
  existing settlement window, durably fences any unsettled run/worktree, and
  only then renders terminal no-primary status. No resulting agent output is
  adopted without a primary.
- An admitted user input is owned by its durable input identity, not by the
  physical thread that first received it. All input is processed by immutable
  `input_seq`; mode cannot reorder it. `queued_not_dispatched` input receives one
  ordinary delivery after binding. Only an outbound-journaled
  `dispatched_pending` call without any terminal outcome after physical loss may
  receive one linked reissue; timed-out/failed input is terminal and cannot;
  old and replacement results cannot both become eligible.
- A controller-initiated non-user primary decision is owned by its stable logical
  semantic-operation identity, not by one physical call. The old physical attempt
  is fenced on primary loss; at most one current replacement attempt under the
  installed epoch may complete the same operation, and stale/superseded
  or timed-out/failed operations receive no replacement call. Logical closure
  never releases a possibly dispatched attempt: settlement or thread fencing/
  rebind precedes every successor call.
- The controller owns the one SQLite connection/writer boundary, permitted
  state transitions, effect execution, exact object identities, and globally
  monotonic transactional `ledger_seq`. It also owns every post-binding primary
  semantic-call `send_started` marker, logical outcome, started/terminal action
  inventory, five-minute timer, interrupt, 30-second full-settlement deadline,
  late-result rejection, and resulting thread fence/rebind. Primary direct
  actions are read-only context retrieval; all delegation/messages/effects remain
  controller transitions after settled eligible output.
- The controller also exclusively owns the in-memory notification-window
  lifecycle and bounded receipt queue for the closed subject set: agent-role
  turn, post-binding primary attempt, and prompt-only primary-control-plane attempt. The App Server
  reader assigns receipt order/time and routes every potential owned-thread
  action envelope through that lifecycle; runtime consumers receive snapshots
  but cannot unregister or retire exact identity. The kernel remains the durable
  authority for role-turn, primary-attempt, and closed control-plane advancement,
  action admission, turn terminality, failure settlement, and subject-specific
  run/worktree, candidate, or primary-thread fence. The controller's serialized
  finalization boundary combines the final snapshot/window frontier with that
  durable transition and retires the in-memory window before exposing success.
- The controller, not the stock CLI or prompt text, owns the closed primary-
  control-plane purpose classification. Bootstrap is controller-internal;
  binding purposes come from exact candidate/active-binding state; presentation
  attach/reattach and captured/outside-window acknowledgement come from typed
  presentation/capture state. It also derives the closed owner/failure
  disposition and owns the primary-endpoint handoff. The stock CLI may request a
  turn but cannot select its durable purpose/owner, target a cached or fenced
  thread, win capture admission, or advance endpoint readiness. An unclassified
  or stale direct primary-thread `turn/start` is rejected before App Server send.
- Before endpoint handoff, the binding candidate owns every presentation
  resource started for it. The controller records the exact process/PTY,
  transport session, thread, and generation lease, invalidates/fences on failure,
  and is the sole teardown/quiescence verifier. Candidate ownership transfers to
  the current endpoint only in the handoff transaction. An unproven teardown
  blocks retry and readiness rather than allowing two physical presentation
  owners. The console interface is a test double, never another governed owner.
- The current primary endpoint owns the active presentation lease. Rebind
  transfers it to the episode's cleanup owner before any replacement candidate
  is provisioned or attached. Only proven generation invalidation plus exact
  process/PTY/transport absence releases that owner; cleanup failure terminalizes
  the episode at candidate count zero.
- Every agent-owned role run has one physical owner and an isolated worktree
  when it can write code. Its durable `owner_id` is the exact App Server thread
  that receives its turns, not a generated placeholder. Its first turn also
  requires durable exact assignment authority. An exact primary `handoff`
  decision precedes retirement; the old run retires before its already-
  provisioned replacement thread receives work under the new run. Pause and
  resume of one active run reuse its already-bound thread; post-terminal
  revision uses a distinct linked run. The controller owns the turn status,
  started/terminal action inventory, 30-second settlement window, late-result
  rejection, and resulting run/worktree fence for every role turn. Every report
  and outcome stays provisional until exact turn/action settlement; failure
  forbids primary response, successor turn, checkpoint adoption, handoff, owner/
  worktree release or reuse, terminal-run adoption, candidate construction, and
  dependent progress. Routine observation neither changes this invariant nor
  becomes another execution owner. Failed settlement already forbids every
  operation named above. A continuing worker has no work-time/action-count
  frontier or automatic budget-checkpoint owner; its actions remain inventoried
  only for notification integrity and terminal settlement. Finite operation
  deadlines may apply to one-shot evaluator roles and fail only that evaluator.
- Each routine observer is a one-shot read-only agent run owned by its exact
  evidence snapshot/frontier. It has no worker worktree, messaging, interruption,
  direction, adoption, or effect authority. Completion persists assessment only;
  failure closes that observer run without changing the observed worker. At most
  one observer is in flight for the work item and one latest pending frontier is
  held in controller memory; durable run/frontier outcomes remain evidence, but
  cadence-timer crash recovery is outside scope. Waiting suppresses new dispatch;
  handoff, retirement, supersession, or terminal state makes old results
  historical. The
  logical primary owns every `observer_attention` interpretation. The controller
  owns coalescing/frontier selection, currentness, the single-operation/effect
  boundary, exact `turn/steer` or `turn/interrupt` execution, and durable result;
  neither observer nor primary directly writes worker state. A current interrupt
  transfers no run/worktree ownership: the same run becomes paused only after
  common turn/action settlement. Internal pause then executes its named primary-
  owned follow-up without user authority; later resume/handoff uses existing
  rules. Escalation alone enters the user-attention path when user knowledge or
  authority is required.
- Controller-executed validation is a durable run owned by the stable
  validation-runtime component identity and deliberately has no App Server
  thread. Its command evidence remains bound to that run.
- The independent semantic verifier is an agent-owned, one-shot read-only run
  with its exact App Server thread identity. It cannot write SQLite, communicate
  with the user, or authorize an effect alone.
- The native CLI reviewer is a controller-launched read-only subprocess bound to
  the exact candidate, not a SQLite writer. Its separate structuring subagent is
  one-shot, tool-less, and non-authoritative; it may only transform the complete
  raw result into the required schema for primary completeness/adoption. The
  controller owns its read-only process group, 10-minute deadline, termination,
  disposable-checkout cleanup, partial-output exclusion, and no-retry failure.

### Concurrency constraints

- No agent or native CLI client writes SQLite directly.
- The single App Server reader establishes receipt order. Receipt-sequence
  assignment, envelope classification, lifecycle/response routing, and routed-
  frontier advancement form one notification-serialized operation; clean
  finalization cannot observe an assigned-but-unrouted receipt. Registration of a role,
  semantic-primary, or primary-control-plane turn never exposes a live exact-turn monitor until all earlier
  buffered lifecycle notifications are
  replayed in order; arrivals during binding/replay queue behind that backlog.
  Reader termination is serialized with arming/registration and atomically
  enumerates every non-retired window; one kernel transaction settles/fences that
  complete set before every waiter is released fail-closed. Failure of that
  transaction is fatal no-progress, never partial subject eligibility. The controller's
  short notification lock is never held across a model, user, subprocess, Git,
  interrupt-response wait, or settlement wait. It may cover only the final clean-
  window check, one bounded kernel transaction, and infallible in-memory
  retirement; the kernel never calls back into the controller while holding its
  writer transaction. Thus no reader event or controller consumer interleaves
  between clean validation and durable eligibility/acknowledgement advancement.
- Every packet-relevant controller mutation receives global `ledger_seq` in its
  mutation transaction; typed transport bookkeeping is audit-only. Every
  mutating operation is initialization-classified and no per-table watermark may
  satisfy packet currentness. The candidate-start transaction freezes one finite
  packet frontier `F`; pending-install records acknowledgement and `I = F`
  without comparing to later writes. Candidate
  confirmation and presentation attach/promotion remain ineligible until the
  endpoint-handoff transaction. Records after `I` queue before the next primary
  turn, which fixes and acknowledges one finite dispatch prefix. Each later call
  repeats that finite-prefix rule, so continuous producers cannot starve install
  or dispatch.
- One physical primary presentation and one physical primary-thread binding are
  current at a time and share one endpoint readiness identity; replacement does
  not change the logical primary identity. Frontier equality and candidate
  confirmation leave the candidate pending. Old-presentation invalidation,
  explicit candidate-thread attach, and the final endpoint switch serialize so
  no mixed old-presentation/new-semantic pair is current. Input admitted before
  invalidation remains queued; a concurrent capture is admitted only if its
  generation transaction wins first, otherwise it stays preserved/unreleased
  and requires re-presentation. Independent agent turns may continue while a
  rebind candidate remains, but any new primary decision waits for endpoint
  readiness. Rebind exhaustion serializes closure of new agent admission before
  interrupt/settle-or-fence and terminal status.
- At most one primary-control-plane or semantic-primary turn is admitted on an
  authority-bearing or pending-candidate physical thread at a time. Bootstrap,
  attach/captured-input readiness, detach/reattach, candidate confirmation,
  endpoint handoff, semantic dispatch, and thread reuse serialize behind clean
  finalization, the presentation-generation winner, or durable thread fence. A
  downstream stock-CLI request cannot bypass that ownership boundary or select
  its target from an independently cached presentation ID.
- At most one candidate presentation lease may be physically live in an episode.
  No candidate lease may begin while the old current endpoint lease is live.
  Candidate-two provisioning/attach begins only after candidate-one generation
  invalidation and proven process/session absence. A handoff-transaction failure
  leaves the lease candidate-owned and follows the same teardown gate.
- Only the first replacement episode may cross from a current endpoint into
  rebind cleanup for a work item. Its durable start consumes the work-item-level
  allowance before any physical cleanup or provisioning. A later rebind trigger
  may fence the current endpoint and settle/fence active work, but it cannot
  create another episode, presentation lease, candidate, or retry.
- User-input admission and the high-stakes effect-start boundary are serialized
  by the controller's single writer; no model/user wait occurs inside that
  boundary. While positive confirmation is pending, correction-capture
  reservation uses that same writer and exact approval epoch: reservation wins
  before effect start and blocks it until admission or no-effect failure, or
  effect start wins and closes that capture window before later input can affect
  the completed transition. Outbound-call journaling and the input-state move to
  `dispatched_pending` occur atomically before network send.
- Plan reviewers may run concurrently because they are independent and
  read-only. Primary synthesis occurs after both results are durable.
- Write-capable role runs do not overlap on the same worktree. Review and
  validation use isolated checkouts of immutable candidates. Every agent-role
  turn keeps exclusive ownership until terminal turn/action settlement; missing
  settlement fences the worktree from primary response, checkpoint adoption,
  handoff, owner release/reuse, terminal-run adoption, candidate construction,
  or dependent progress. The one read-only observer may overlap its observed
  worker because it consumes an immutable frontier and cannot mutate or lock the
  worker; observer runs do not overlap each other for this one work item. Native-
  review timeout follows the disposable-checkout cleanup/no-retry rule.
- Observer-assessment persistence may overlap worker execution. The ordinary
  single-writer boundary permits at most one unresolved `observer_attention`
  operation and at most one chosen steering/interruption effect per worker run.
  Its assessment frontier is immutable; later assessments remain pending for a
  subsequent operation. If any other non-user primary semantic operation is
  unresolved, the assessment is persisted immediately but dispatch waits behind
  that predecessor; no second logical-primary turn is opened. The primary model
  wait holds no controller lock and does not stop the worker. At most one
  observer is in flight and one latest pending frontier exists; observer
  settlement or old-run invalidation precedes catch-up dispatch. The decision's
  worker-progress frontier remains provenance, while effect start applies
  action-specific currentness. `continue` has no worker effect. `steer`, `pause`,
  and `escalate` serialize exact run/thread/active-turn/owner/assignment against
  turn completion, checkpoint/terminal adoption, handoff, retirement, successor
  admission, and candidate construction; ordinary compatible progress is not a
  conflict. `steer` additionally fixes and attaches the complete structured
  progress delta through its send frontier. The
  winning effect terminalizes before any of those consumers; if another state
  transition wins, the attention effect is no-effect. A still-active worker may
  then receive a fresh assessment, while an already-produced checkpoint/terminal
  outcome carries the evidence into its ordinary primary boundary. A dominated
  older observer frontier is historical, not another actionable assessment.
- No controller lock or database transaction is held while waiting for a model,
  user, subprocess, or Git operation.

### Deliberate composition cases

Deterministic tests cover one bounded distinguishing scenario per contract
cluster; the live run covers only the natural happy path and never fabricates a
review finding:

- **Notification and finalization:** causal close and routed-frontier ordering,
  action evidence omitted from `thread/read`, reader/finalizer serialization,
  exact identity-bound finalize-or-fence lease consumption, owner-specific
  control deadline failure, and global reader failure across non-retired
  subjects.
- **Presentation and input:** startup token/canonical first input, typed
  post-intake admission, detach-versus-capture and correction-versus-effect
  winners, exact endpoint lease handoff, ordered input delivery, and the single
  eligible reissue after physical loss.
- **Primary continuity:** fixed `F` installation at `I = F` and a finite
  `D` drain converge while a worker continues writing; old/candidate endpoint
  teardown precedes reuse; one retry and one rebind allowance are enforced; a
  second loss or exhaustion reaches settled/fenced no-primary state without
  inventing recovery.
- **Capacity boundary:** the bounded fixture/live `F`, `D`, and steering
  payloads fit the pinned model. Injected explicit capacity rejection exercises
  the existing `binding_candidate`, `active_binding`, and proven-steer
  no-effect dispositions; ambiguous steering delivery alone fences, and no path
  gains a capacity-specific retry.
- **Agent settlement and ownership:** provisional reports/outcomes cannot be
  adopted, continued, handed off, released, or used for candidate construction
  before exact turn/action settlement; failed settlement fences the run/
  worktree; delegation, same-run resume, and distinct-run handoff preserve one
  physical owner.
- **Observation and intervention:** one observer in flight plus one coalesced
  pending frontier, late historical outcomes, two-failure attention and reset,
  and observer failure affecting only itself. A long worker exceeding the
  removed time/action frontier continues. Repeated compatible same-turn progress
  still permits one exact-turn steer; structural lifecycle/ownership conflicts
  produce no-effect, pause is internal, escalation is user-facing, and ambiguous
  steer delivery is never retried or converted into interrupt.
- **Plan and decision authority:** arbitrary voice wording has no Python semantic
  path; every finding receives a compatible disposition; both plan lenses,
  three-version checkpoint, compact exact-consequence presentation, independent
  positive confirmation, and exact closed-plan authorization gate coding.
  Revised intent, restart, integration, and abandonment remain distinct and
  reject stale/newer-input authority.
- **Restart:** the assessor returns each of the three exact predicates with
  evidence; only all-positive current evidence may support the primary proposal,
  and only separately confirmed current user authority restores and verifies the
  implementation-start snapshot while durable history remains.
- **Candidate and review:** intended untracked files enter the complete candidate
  commit; every code-changing fix creates a replacement candidate and
  invalidates downstream gates; correctness, cohesion, native hard review,
  validation, and plan-to-code closure bind the exact candidate. Native-review
  timeout/nonzero/partial/cleanup or structuring mismatch blocks without retry.
- **Integration and closeout:** only the currently authorized final candidate may
  fast-forward the disposable base; commit/tree read-back precedes completion;
  incomplete effects remain visible and preserved; the final ITD persists its
  full decision structure and grants no host effect.

Crash cut points, hostile clients, duplicate transport delivery, broad race
matrices, arbitrary-history context transport, and automatic recovery remain
explicitly deferred.

## Completion gate

The architecture phase is complete when this plan:

1. passes independent soundness and adversarial Plan Review;
2. passes subtractive minimality review and affected verification re-review;
3. contains no unresolved blocking or significant in-scope finding; and
4. is reviewed by the user as one consolidated architecture, with any genuinely
   unresolved ITD called out separately.

Implementation may then begin against this reviewed plan. Completion of the
prototype additionally requires proportional offline tests, a fresh Code Review
epoch carried forward from `CP-E10-CR-001`, implementation closure against this
plan, the user-approved live Codex run, and separate explicit approval before
any commit or integration action covered by the existing session authority
boundary.
