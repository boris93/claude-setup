# New Codex Operating Model

**Status:** Working design record
**Started:** 2026-07-31
**Method:** Interview-driven; update this document after each settled answer.

## Purpose

The objective is to build a minimum viable version of a new Codex setup for the
current generation of models and native agents. This document is an
intermediate design record, not the product or objective itself. It exists so
that the intended behavior and settled decisions survive context compaction,
session changes, and future implementation work.

"Minimum viable" describes the smallest coherent delivery of the intended
end-state behavior; it does not make minimum code or maximum reliance on
currently available Codex features the goal. The MVP must visibly contain the
aspirational model's defining DNA:

- a voice-first user can give large, exploratory inputs without becoming the
  prompt or process engineer;
- one accountable primary Codex understands intent, leads the technical team,
  and remains the user's interface;
- subagents execute bounded responsibilities without transferring the
  primary's accountability to the user;
- durable project intent and execution context survive compaction, physical
  session replacement, and agent replacement;
- important product and technical decisions follow the correct authority and
  remain inspectable; and
- proportional planning, independent review, implementation closure, and final
  validation preserve the evergreen quality principles learned from the old
  setup.

Native Codex capabilities are the preferred substrate, not the boundary of the
requirements. If Codex lacks a capability necessary for this DNA, the MVP must
fill the gap through the smallest appropriate extension, adapter, service, or
focused upstream-compatible modification. Conversely, the project must not
rebuild Codex from the ground up merely to own machinery that Codex already
provides well. Reduced breadth, polish, or optimization is an acceptable MVP
cut; removing a defining behavioral invariant is not.

The existing setup in this repository is historical evidence only for this
design exercise. Its RFC flows, code-review flows, roles, contracts, ledgers,
receipts, and terminology are not inherited as requirements. An old idea may be
reused only when it independently earns a place in the new model.

The user is voice-typing. Raw speech may be exploratory, repetitive, unordered,
or partially formed. Converting that input into a coherent understanding is
Codex's responsibility, not the user's.

## Settled Decisions

### 1. One accountable user interface

The user ideally interacts only with the primary Codex.

Subagents are an internal team managed by the primary Codex. The user does not
need to dispatch, coordinate, reconcile, or monitor individual subagents.
Delegating work does not transfer the primary Codex's accountability for the
final outcome.

### 2. Ground understanding before acting

When relevant read-only context could materially improve understanding, the
primary Codex gathers it before interpreting the request or asking for
confirmation.

Already fresh and sufficient context is reused. Context is not gathered again
merely to repeat work.

### 3. User language defines discussion versus execution

The user's phrasing is the primary authority signal:

- Language such as "let us think about this", "I am considering", or "what do
  you think?" requests discussion, investigation, or refinement.
- Language such as "do this", "fix this", or "implement this" requests
  execution.

The primary Codex must not replace these signals with a universal task taxonomy.

### 4. Ambiguity determines whether an intent gate is required

An explicit action request that remains unambiguous after relevant context
gathering is itself authorization to proceed. It does not require a redundant
second approval.

If any meaningful ambiguity, clarification need, or refinement opportunity
remains, the primary Codex presents a brief intent gate containing:

1. its understood summary;
2. the proposed next action; and
3. a request for correction and approval to proceed.

The user's next response settles both whether the summary is correct and whether
Codex should proceed.

This refines the earlier preference for a confirmation on every non-trivial
request: an unambiguous explicit action request needs no second handshake, while
an ambiguous or refinable request does.

### 5. Canonical decision method

For a meaningful decision, Codex uses this structure internally and presents the
same structure when the decision is brought to the user:

1. **Problem Statement**
2. **Valid Options**
3. **Pros and Cons for Each Option**
4. **Recommendation or Decision**

A separate repetitive explanation of why the recommendation was selected is not
required when the pros and cons already make the selection basis clear.

### 6. Important Technical Decisions

The project maintains a durable log of Important Technical Decisions (ITDs).

An ITD is a technical decision that:

- is directly connected to the core problem the product solves or to what makes
  its output good;
- establishes a fundamental technical direction;
- would be difficult or expensive to change later;
- constrains many downstream implementation decisions; and
- has rationale that future maintainers will need when revisiting the choice.

Small implementation details are not ITDs.

Before interrupting the user with an ITD interview question, the primary must
apply an ITD qualification gate:

- at least two valid paths must remain after applying accepted constraints and
  ordinary engineering practice;
- choosing among them must materially affect product behavior, an architecture
  boundary, authority, durable state, systemic risk or cost, or a broad set of
  downstream decisions; and
- the choice must be required now to unblock or correctly shape meaningful
  downstream work.

A consequence that follows directly from an already accepted decision is not a
new ITD. Neither are routine Git mechanics, local implementation choices,
schema details that can safely remain inside an implementation plan, or
hypothetical edge cases without current decision pressure. The accountable
primary or execution role resolves those matters without turning them into a
user interview. Deferrable details remain explicitly deferred.

The primary does not keep the interview alive by manufacturing adjacent
questions. When no currently load-bearing ITD remains, it says so and moves to
the next substantive operating-model area or pauses the interview.

The primary Codex is responsible for recognizing and classifying ITD candidates.
Every ITD requires the user's review before it becomes accepted.

While an ITD is awaiting review, only work dependent on that decision pauses.
Independent work continues.

Each persisted ITD contains the complete decision structure:

1. **Problem Statement**
2. **Options**
3. **Pros and Cons for Each Option**
4. **Decision**

Rejected alternatives remain preserved as options within that structure.

ITDs are stored inside the project repository in version control. The project
uses one chronological, append-oriented ITD log file rather than one file per
decision. An accepted entry is never erased. If a later decision changes it, the
original remains and is marked as superseded by the newer ITD.

The transcript that informed this definition is currently:

`/home/abhishek-borar/Downloads/CTO Bootcamp - What is an ITD_.transcript.txt`

Whether and where to archive that transcript inside the project remains open.

### 7. One logical primary, not one immortal transcript

From the user's perspective, a project has one persistent primary Codex identity
similar to one accountable product or engineering lead.

That identity does not require one ever-growing physical chat transcript.
Distinct physical sessions, subagent threads, or other execution contexts may
be used underneath as an implementation detail. The user should not have to
manage those contexts to preserve continuity.

Project continuity must therefore live in durable project artifacts rather than
depending exclusively on one transcript or on compaction preserving every
detail.

### 8. Project-native project brain

**MVP classification:** Post-MVP product-management breadth. Sections 8-16
preserve the envisioned future idea and roadmap system, but they are not
requirements for the execution-focused MVP. The MVP's durable state remains
limited to the intent, decisions, work, context, evidence, and outcomes needed
to execute accepted work reliably.

The project needs a project-native project-management system, not merely a
living status note.

It should eventually hold and make queryable:

- raw ideas and curiosities;
- possible experiments;
- roadmap candidates;
- active work and priorities;
- pending decisions and blockers; and
- other project-management state still to be defined.

It must remain durably associated with the project. An earlier decision placed
and versioned it directly in the target source repository; the later
control-plane architecture discussion reopened that physical placement and
version-control boundary. Its storage and interaction interface remain separate
concerns.

The project brain should ideally replace the user's current Google Keep workflow
for project ideas.

### 9. Automatic idea capture

Future-looking ideas and curiosities expressed during conversation are captured
automatically. The user does not need to remember an explicit "save this"
command.

Capture means that a thought is safely in the inbox. It does not mean the idea
has been approved, prioritized, or committed to the roadmap.

Each captured idea stores:

- a short Codex-synthesized title or summary;
- the original voice excerpt so the user's exact intent remains available; and
- tags for retrieval.

### 10. Emergent canonical tags

Tags are generated at capture time.

The system reuses an existing relevant tag when one fits. It creates a new tag
only when no existing tag adequately represents the concept. The vocabulary is
therefore emergent rather than fully free-form or fixed in advance.

Alias, merge, and cleanup behavior remains to be designed.

### 11. Promotion remains user-led

Codex does not silently turn a curiosity into a commitment or choose its
priority. The user decides whether an inbox item should be promoted into a real
roadmap item, experiment, or work item.

An earlier preference for Codex to recommend promotions during inbox review was
refined later: the default inbox review is non-prescriptive and contains no
promotion recommendation. The user may explicitly ask for recommendations when
wanted.

### 12. Inbox review is organized and evidence-preserving

Inbox review happens only when the user explicitly requests it. The primary
Codex does not interrupt ordinary conversation with immediate or
checkpoint-based inbox reviews.

During review, the primary Codex:

- groups related ideas;
- presents well-organized, compact summaries; and
- preserves an option to inspect the original verbatim voice excerpt and intent
  behind any summarized item.

The default review does not recommend promotion, merging, archiving, or
prioritization.

### 13. Lifecycle uses reserved system tags

An idea has exactly one current lifecycle tag from a controlled `status:*`
namespace:

- `status:inbox`
- `status:promoted`
- `status:archived`

These tags reuse the common tag mechanism, but unlike emergent topic tags they
are system-defined and mutually exclusive. A lifecycle transition replaces the
previous `status:*` tag; it cannot leave conflicting current states.

Topic tags remain emergent and reusable as defined above.

Reviewing or displaying an inbox item does not change its lifecycle state.

### 14. Voice capture preserves source and extracts linked ideas

A voice message is preserved as one source note containing the user's verbatim
input and its conversational context.

Codex may extract one or more atomic idea records from that source note. Each
idea record has its own synthesized summary, topic tags, and lifecycle tag, and
links back to the source note. Multiple ideas can therefore be queried and
promoted independently without duplicating or losing the original intent.

### 15. Automatic capture is deliberately liberal

Capture favors recall over inbox cleanliness. Codex captures any thought that
could plausibly have future relevance, including tentative possibilities,
examples, and rejected directions.

Capture is not endorsement. The linked verbatim source preserves whether the
user proposed, questioned, illustrated, or rejected the thought, so later
review does not silently convert exploration into intent.

### 16. Repeated ideas preserve occurrences

An idea record may be canonical across multiple conversations, while every
verbatim source occurrence remains preserved and linked to it.

When a new occurrence clearly expresses the same underlying intent, Codex links
it to the existing idea instead of creating a duplicate or overwriting earlier
material. When sameness is uncertain, Codex creates a separate idea; later
cleanup may merge or relate them without deleting their source notes.

### 17. The work ledger begins before the work

The project brain contains a product-perspective work ledger. Unlike Git
history, which records repository changes after they happen, a ledger entry is
created before the corresponding work begins.

The initial entry preserves the intended outcome and known context. Subsequent
events append the work's evolution, including decisions, blockers, abandonment,
completion, and supporting evidence. Git commits may be linked as implementation
evidence, but they neither create nor define the work item.

The logical model combines:

- an append-only work-event history; and
- a queryable current-state projection for each work item.

This makes intended or attempted work visible even when it produces no commit.

### 18. Work begins through intake and start events

Work enters the ledger in two stages:

1. Codex records an `intake` event as soon as a user request enters the work
   path, before read-only grounding or clarification.
2. Codex records a `started` event only after the request has been grounded,
   its intent is sufficiently clear, and any required user approval has been
   received.

The intake event preserves the original request without prematurely treating it
as active work. Discussion-only conversation remains governed by automatic idea
capture rather than being mislabeled as started work.

### 19. Work decomposition is dynamic

**MVP classification:** The MVP executes one accepted user-level outcome at a
time. That outcome may be decomposed into multiple internally tracked tasks and
handled by multiple role agents. Concurrent unrelated user workstreams are
post-MVP breadth; later references to independent work continuing describe the
end-state model rather than an MVP acceptance requirement.

A preserved intake may produce one or more independently tracked work items.
Those items link back to the intake so the user's original intent remains
available even when execution is decomposed.

The initial decomposition is not closed. During execution, an executing agent
may discover additional work. The primary Codex assesses the discovery and,
when it agrees that the work exists, records a separate work item linked to the
work that exposed it. This can happen without the user being actively present.

Runtime-generated work items preserve their discovery context, including who or
what discovered them, the supporting evidence, and their relationship to the
parent work.

### 20. Runtime work inherits authority only within the parent outcome

Recording a runtime-discovered work item does not by itself authorize its
execution.

The primary Codex may record and start the item without additional user
approval when it is necessary to complete the already approved parent outcome
and remains within that outcome's scope. If it is an optional improvement, a
material scope expansion, or requires a new product decision, the primary
records it as intake but does not start it without the user's approval.

### 21. Work items have a minimal derived lifecycle

The current-state projection derives exactly one lifecycle state for each work
item from its event history:

- `intake`
- `active`
- `blocked`
- `completed`
- `abandoned`

The lifecycle stays deliberately coarser than execution phases such as
planning, implementation, review, or validation. Blocked, completed, and
abandoned events preserve their reason or supporting evidence rather than
encoding that detail into additional states.

### 22. Every non-trivial work item is delegated

The primary Codex does not directly execute non-trivial work items. It delegates
each one to an execution agent.

The primary remains the user's sole interface and retains responsibility for:

- understanding and confirming intent;
- maintaining the work ledger and project-wide state;
- decomposing and routing work;
- resolving or escalating decisions;
- integrating execution results; and
- ensuring the requested outcome is actually complete.

Delegation transfers execution, not accountability.

### 23. One dedicated execution agent per work item

Each non-trivial work item is assigned to one dedicated execution agent by
default. The durable identity is the work item and its ledger state, not the
physical agent session.

The primary Codex owns execution continuity:

- it primes the assigned agent with the work item's relevant context;
- it ensures required context survives agent compaction;
- if the agent must be replaced, it primes a new agent from the same durable
  work state; and
- it preserves the previous agent's progress, discoveries, decisions, and
  evidence across that replacement.

This continuity must not depend solely on detecting compaction at the moment it
happens. The exact durable checkpoint mechanism remains to be designed.

### 24. The primary routinely checks execution alignment

The primary Codex does not wait for compaction, replacement, completion, or a
reported blocker before checking an execution agent. It performs routine
PM-style check-ins to detect derailment while correction is still cheap.

The exact checkpoint contents and work-budget selection remain to be designed.

### 25. Execution checkpoints are bidirectional

Checkpointing combines executor push reports with independent primary check-ins.

At delegation time, the primary gives the execution agent a proactive reporting
contract. The agent reports meaningful state changes and inflection points,
including blockers, failed assumptions, scope pressure, newly discovered work,
and material deviation from the current approach.

Independently, the primary checks alignment at meaningful milestones and when a
risk-adjusted maximum uninterrupted-work budget is reached. Agent reporting
does not replace primary oversight, and primary polling does not replace the
agent's duty to escalate material changes promptly.

### 26. Execution checkpoints use a compact fixed contract

Each execution checkpoint reports:

- the current objective;
- progress and evidence since the previous checkpoint;
- the current approach and state;
- deviations, discoveries, blockers, and unknowns; and
- the next intended action.

The primary reviews this against the work item's approved outcome and responds
with one of four directions: `continue`, `correct`, `pause`, or `escalate`.
Checkpoint reports are compact context and control artifacts, not full
transcript or artifact dumps.

### 27. Checkpoints and product events are linked layers

Every checkpoint is preserved in an append-only execution-checkpoint stream.
The latest checkpoint is also available through the work item's current-state
projection for fast recovery and priming.

The product-facing work ledger receives only material summarized events rather
than every routine executor update. The execution stream and product events
remain linked, providing complete recovery history without turning the product
view into operational chatter.

### 28. SQLite is the preferred storage candidate

The emerging project-brain model is relational: work items, events,
checkpoints, ideas, source occurrences, tags, ITDs, agents, Git evidence, and
their links must be independently queryable.

SQLite is therefore the preferred storage candidate, using multiple related
tables and views. The following decision selects its canonical role and writer
boundary.

### 29. SQLite is canonical and single-writer; placement is open

The project brain's SQLite database is its canonical source of truth and is
mutated only by the primary Codex.

Execution agents may work concurrently in separate Git worktrees, but they do
not modify the canonical database. They report checkpoints, discoveries, and
results to the primary, which serializes the corresponding ledger writes. This
keeps parallel code execution from creating SQLite writer or merge conflicts.

The writer boundary belongs to the logical primary role rather than one
immortal process. If the physical primary session is replaced, writer ownership
transfers; multiple primary writers must never be active concurrently.

An earlier decision placed and committed the database in the primary worktree.
That placement is now explicitly reopened. The database may ultimately live in
the target repository, in external per-project control-plane state, or behind a
hybrid versioning/export boundary.

### 30. Primary and execution agents maintain a general conversation

Execution agents do not receive only a static context packet or a narrow
database-query interface. They maintain a bidirectional conversation with the
primary throughout the work.

An agent may ask the primary any question needed for execution, including
questions about broader architecture, product intent, project vision, prior
decisions, or surrounding implementation context. The primary:

1. answers from knowledge and evidence it already has;
2. gathers or queries relevant read-only context, including the project brain,
   when needed; and
3. asks the user when the required knowledge or decision is not otherwise
   available.

The primary then relays the grounded answer to the agent. SQLite supports this
conversation but does not define or limit it. The user continues to interact
only with the primary.

### 31. An agent pauses while its ask is unresolved

When an execution agent raises an explicit ask to the primary, its entire
assigned work item pauses until the ask is resolved and the answer is returned.
The agent does not continue independent branches within that work item while
waiting.

This pause is local to that work item. Other independent work items and their
agents continue, preserving the earlier rule that unrelated work should not be
stalled by a pending decision.

### 32. Uncertainty is determined by valid-path count

An execution agent first gathers all safe, relevant, in-scope context and
applies the accepted outcome, constraints, product decisions, architecture, and
codebase patterns to the problem.

It then evaluates the remaining valid solution paths:

- exactly one valid path means there is no uncertainty, so the agent proceeds;
- zero valid paths means there is an uncertainty or blocker, so the agent asks
  the primary and pauses; and
- multiple valid paths mean there is an unresolved choice, so the agent asks
  the primary and pauses.

This rule applies to every residual actionable uncertainty; there is no
additional materiality threshold. A momentary lack of knowledge before
available context has been inspected is not yet an uncertainty.

### 33. Agent asks use the canonical decision structure

An execution agent sends the primary a structured ask containing:

- the problem statement;
- gathered evidence and applicable constraints;
- the number of remaining valid paths;
- for multiple paths, each option's pros and cons and the agent's
  recommendation;
- for zero paths, why the investigated candidates are invalid and what could
  unblock the work; and
- the exact answer or decision requested.

The ask contains sufficient evidence for review without dumping the agent's
full execution context.

### 34. The primary resolves asks within established authority

On receiving an ask, the primary first uses broader evidence and accepted
project decisions to determine whether they reduce the problem to one valid
path. The primary also decides routine non-ITD technical choices within the
approved outcome.

The primary escalates to the user when resolution requires:

- knowledge that only the user can provide;
- a new product or scope choice; or
- review of an Important Technical Decision.

The executing agent does not choose among unresolved alternatives after asking.
It resumes only after the primary returns a decision or grounded answer.

### 35. Every agent ask and answer is durably preserved

Every primary-agent ask and answer is stored in a dedicated execution-
conversation table or table group in the canonical SQLite project brain.
Records link to their work item, participating agent, and relevant checkpoint,
decision, or ITD.

These records are not mixed into the main `work_events` stream. Product-facing
ledger views can therefore remain concise while the complete execution
conversation stays directly queryable for recovery, audit, and future context.
No materiality classification is required to decide whether an ask or answer
is preserved.

### 36. Agent conversations are durable threads

Each structured agent ask opens a conversation thread. The thread preserves its
initial structured ask, has an `open` or `resolved` state, and contains
append-only ordered messages from the execution agent, primary, and any user
response relayed by the primary.

A thread may therefore support clarification and escalation across multiple
turns without overwriting earlier messages. The assigned execution agent
remains paused until the primary marks the thread resolved and returns the
grounded resolution.

### 37. User-required agent asks are surfaced immediately for now

When the primary determines that an agent ask requires user knowledge or a user
decision, it surfaces the ask immediately rather than waiting for a requested
review or a natural conversation boundary.

This is the initial operating policy and is explicitly revisitable after real
usage reveals its interruption cost. It is separate from the idea inbox, which
remains review-on-request.

### 38. Delegation follows responsibility rather than estimated size

The primary directly owns:

- user conversation and intent handling;
- work decomposition, routing, and coordination;
- canonical project-brain writes;
- bounded read-only grounding needed to understand or route a request; and
- integration and outcome accountability.

Substantive analysis, design, implementation, or validation that produces the
project outcome is assigned to a dedicated execution agent. Delegation is not
based on an estimated duration or number of tool calls.

### 39. Substantive work has an independent deliverable

Work is substantive when it produces its own independently verifiable
deliverable or conclusion. This includes diagnosis, research, planning or
design, implementation, review, and validation outcomes, even when no
repository mutation occurs.

Bounded context lookup used only to understand or route a request, primary
synthesis of agent results, user communication, coordination, and canonical
project-brain bookkeeping remain primary responsibilities.

### 40. Every implementation has a proportional plan

Before implementation starts, a dedicated planning agent produces an explicit
plan. Plan depth scales with the change:

- a small change may need only a compact statement of intent, affected sites,
  and validation; while
- a large or architectural change may require a full plan or RFC.

Implementation does not begin until the plan has passed the operating model's
acceptance process. Scaling the plan down does not remove the planning gate.

### 41. Every implementation plan receives two independent reviews

Before acceptance, each implementation plan is reviewed by:

- an independent soundness and completeness reviewer; and
- an independent adversarial reviewer that constructs concrete failure
  scenarios.

The reviewers do not share a reasoning path or substitute for each other. The
primary gives them the grounded plan context and synthesizes their outputs. The
depth of each review may scale with the plan, but both lenses remain present.

### 42. Plan review continues to verified convergence

The primary assesses the reviewers' findings and accepts the findings that are
valid. The planning agent revises the plan, and each affected reviewer verifies
the revision. This repeats until no unresolved blocking finding remains.

The loop is not allowed to churn indefinitely. If the same concern remains
unresolved across revisions, it becomes an explicit uncertainty or ITD
escalation rather than another local patch attempt.

### 43. Finding-pattern analysis is longitudinal

Reviewers should search broadly for sibling failure sites in each pass, but the
process must not assume that one pass will expose them all. A first finding may
need to be fixed before the next review iteration reveals another manifestation
of the same underlying problem.

Every finding is therefore preserved with its site, review iteration, accepted
remedy, and verification result. Each later finding is compared with the full
accumulated history rather than only the current review batch.

One finding can suggest several possible explanations and is not, by itself,
enough to declare a pattern. A second related occurrence, a finding that
migrates after a local fix, or multiple affected sites creates a pattern
candidate. Before another local symptom fix, the primary reassesses the
combined evidence for a shared upstream cause.

The shared cause may be a bad or unnecessary decision, an unsuitable or
unnecessary architecture, a misunderstood scope, or another faulty premise.
When supported by the accumulated evidence, that upstream choice is revisited,
narrowed, or removed before further local fixes.

### 44. A first finding is resolved without declaring a pattern

For a first occurrence, the primary accepts the demonstrated obligation
separately from the reviewer's suggested remedy. The planning agent applies a
locally correct resolution, the reviewer searches for sibling sites, and the
revision is independently verified.

The full evidence is retained. When a second related occurrence appears, the
pattern gate runs before another local fix, even if the first resolution was
valid in isolation.

### 45. RFC and plan revisions form an immutable lineage

The initial reviewable RFC or plan is preserved as version zero. Every
review-driven revision creates a new immutable version linked to its parent and
review iteration; prior versions are never overwritten.

The system can reconstruct:

- the exact diff between adjacent versions;
- the exact cumulative diff from version zero to any later version; and
- the findings, accepted remedies, and verification results that produced each
  transition.

This makes cumulative architectural drift inspectable rather than leaving only
the latest apparently converged document.

### 46. Cumulative diffs support independent root-architecture assessment

After review-driven revisions, an independent assessment can receive the
version-zero RFC, the current revision, their exact hard diff, and the
accumulated finding and remedy history.

Its job is to determine whether the sequence of individually reasonable fixes
reveals a shared bad or unnecessary decision, architecture, or premise. The
exact trigger cadence for this assessment remains to be selected.

### 47. The operating model is becoming a software-controlled workflow

The emerging model is not only a collection of natural-language instructions.
It is a deterministic orchestration process in which software can enforce
repeatable state transitions, persistence, version creation, diff generation,
review loops, and mandatory triggers.

Agents provide bounded semantic analysis and execution inside those controlled
steps. The primary remains the user-facing orchestrator. The exact boundary
between program-enforced behavior and agent judgment remains to be selected.

### 48. Pending ITD: authoritative orchestration host

**Status:** Pending mandatory user review after the proof-of-capability gate.
Option 3 is the preferred hypothesis, not an accepted decision.

#### Problem Statement

The system must decide where its authoritative loop lives:

- inside Codex CLI and its extension ecosystem; or
- inside an independent program that hosts Codex agents.

This boundary determines who owns truth, ordering, recovery, SQLite writes,
agent lifecycle, checkpoint timing, worktrees, approvals, and the user
interface. Reversing it after workflow logic spreads across the system would be
expensive.

#### Decision drivers

The selected host must preserve the already accepted invariants:

- primary Codex is the user's only interface and semantic team lead;
- a deterministic state machine owns mandatory transitions and gates;
- the canonical SQLite database has one primary-controlled writer;
- execution agents work concurrently in isolated worktrees;
- agent asks, pauses, checkpoints, replacement, and rehydration are reliable;
- RFC versions, findings, remedies, diffs, and review triggers are durable; and
- workflow correctness does not depend on a model remembering to invoke every
  required step.

#### Option 1: Codex CLI is both agent and authoritative container

Skills express the workflow, an MCP service exposes controlled SQLite
operations, hooks observe or guard lifecycle events, and native Codex subagents
execute work.

Pros:

- preserves the native Codex CLI experience, authentication, permissions,
  tools, plugins, skills, approvals, and subagent UI;
- lowest bootstrap cost; and
- uses current Codex multi-agent behavior directly.

Cons:

- orchestration remains driven by model-interpreted requests and tool choices,
  not an independently authoritative state machine;
- hooks are lifecycle-triggered rather than a complete timer and scheduler, and
  current command hooks are synchronous;
- reliable worker pausing, replacement, rehydration, and single-writer
  transition ordering are not established as hard guarantees; and
- worker approvals may surface directly to the user, weakening the
  primary-only interface.

Under the accepted hard-determinism constraint, this option is valid only if
that constraint is weakened to best-effort compliance plus guards.

#### Option 2: Independent program with its own UI hosts Codex

A custom service owns the state machine, SQLite, worktrees, primary and worker
threads, timers, routing, and a custom chat or project UI. It drives Codex
through App Server or an SDK.

Pros:

- gives software direct authority over ordering, idempotency, pausing,
  scheduling, recovery, and the single SQLite writer;
- can mediate every user turn, approval, checkpoint, and agent message; and
- can provide a purpose-built product-management interface.

Cons:

- requires rebuilding chat streaming, history, approvals, settings, and error
  recovery before the operating model can be used;
- native Codex UX and feature parity are not automatic; and
- a custom UI is premature relative to the user's preference for primary Codex
  CLI interaction.

This option satisfies the control requirements but adds avoidable MVP product
scope.

#### Option 3: Programmatic control plane with native Codex CLI frontend

A local program owns the canonical SQLite connection, workflow state machine,
timers, worktrees, thread mappings, asks, checkpoints, RFC lineage, and review
triggers. Codex App Server provides primary and worker threads. The user
initially interacts with the primary through native Codex CLI remote mode or a
thin protocol gateway; a custom frontend can be added later without changing
the workflow kernel.

Pros:

- keeps mechanical authority deterministic while primary Codex retains
  semantic leadership;
- preserves the familiar native CLI, existing Codex auth, permissions, tools,
  skills, and plugins;
- avoids building a custom chat UI before it is necessary;
- supports explicit timers, pauses, replacement, rehydration, worktree
  isolation, and one SQLite writer;
- can route each work type to an appropriate model and reasoning effort instead
  of paying primary-model cost for every agent; and
- keeps the frontend and Codex runtime replaceable around a stable domain state
  machine.

Cons:

- has more moving parts and requires a protocol adapter or gateway;
- App Server and remote-control commands are currently marked experimental in
  the installed Codex CLI;
- ingress ownership, approval routing, multi-client behavior, crash recovery,
  and exact native-CLI parity are not sufficiently documented to assume; and
- Codex protocol compatibility must be pinned and tested across upgrades.

#### Recommendation

Choose Option 3 only after a narrow proof-of-capability succeeds.

The durable architectural decision would be:

1. authoritative orchestration belongs to a programmatic control plane rather
   than prompts, skills, hooks, or model memory; and
2. native Codex CLI remains the initial replaceable frontend rather than
   becoming the authority boundary.

Skills remain role guidance, MCP remains a controlled agent-to-controller
interface, hooks remain lifecycle observation and fail-closed guards, and
plugins may package those surfaces. None owns the state machine.

#### Required proof-of-capability

Before accepting the ITD, one vertical slice must prove:

- a native Codex CLI primary can operate through the controlled App Server
  path;
- intake commits before a controller-created worker starts;
- two workers run in separate worktrees without SQLite write access;
- agent checkpoints and an ask are persisted and the ask stops further worker
  work;
- primary-mediated resolution resumes the worker;
- compaction and worker replacement rehydrate only from durable state;
- an RFC `v0 -> v1 -> v2` sequence produces exact adjacent and cumulative
  diffs; and
- approvals and user questions never bypass the primary interface.

If the remote CLI frontend fails but the control-plane guarantees succeed, the
control-plane decision remains viable and only the frontend option must be
reopened.

The current App Server direction is promising enough to test rather than
dismiss. Because Codex is open source, a focused fork is also a possible
worst-case escape hatch if a required invariant cannot be implemented through
the available supported or experimental surfaces. The operating model does not
assume that a fork is the default implementation substrate.

### 49. Codex is upstream-first and fork-last

The system uses Codex's supported upstream surfaces first, then a local adapter
or gateway, and then a bounded proof of any necessary experimental surface.

A Codex fork is allowed only when:

- the remaining gap blocks an already accepted mandatory invariant;
- the gap cannot be resolved through those preceding options; and
- the required patch is focused enough to carry responsibly.

An activated fork keeps its delta minimal, has compatibility tests, is
regularly rebased on upstream, and should be proposed upstream when practical.
Forking is an escape hatch, not the default implementation substrate.

### 50. Root-architecture assessment has deterministic triggers

The workflow program generates both the adjacent-version diff and the exact
version-zero-to-current diff after every RFC or plan revision.

It launches an independent root-architecture assessment:

- when a second related finding or affected site is recorded;
- when version two is created, even if no relationship has yet been
  established;
- after every later review-driven revision; and
- once more before final plan acceptance.

This operationalizes the principle that one point admits many explanations,
while a second point makes a shared line assessable. Triggering does not depend
on the primary remembering to notice a pattern.

### 51. Root-architecture assessment uses a fresh agent

The assessor has not participated in drafting the plan or in its soundness and
adversarial review loops.

Its evidence pack contains:

- version zero and the current version;
- adjacent and cumulative hard diffs;
- all findings, sites, review iterations, remedies, and verification results;
  and
- the accepted outcome, constraints, product decisions, and ITDs.

This spends an additional agent run to avoid anchoring the cumulative
architecture judgment to a reviewer's earlier reasoning.

### 52. Agent configuration can be routed by work type

A subagent-native architecture allows the control plane to select the model and
reasoning effort independently for each assigned work item or role.

Routine or well-bounded work can use a cheaper, faster configuration, while
high-stakes architecture, ITD, or root-cause analysis can receive a stronger
configuration. This makes cost and latency optimization an architectural
benefit rather than requiring every step to run at the primary's configuration.

### 53. Routing is policy-based and starts quality-first

The control plane selects model and reasoning effort through a recorded policy
based on work type, risk, and required judgment. The primary may override the
default with a recorded reason, and an execution agent may request stronger
configuration with evidence.

The initial policy assigns all agents the max/default configuration. Cheaper or
faster routes are introduced only later, using observed work outcomes rather
than speculative quality assumptions. The routing machinery therefore exists
from the start while optimization remains incremental and reversible.

### 54. Measurement and future backtesting are cross-cutting requirements

The operating model must make its real performance measurable rather than
judging changes by intuition. This applies to cost optimization and to the
quality of the complete Darkline-style system.

Historical project usage should be able to become a representative evaluation
corpus. When OpenAI releases a new Codex model, the user selects another model,
or the orchestration configuration changes, the system should eventually be
able to replay or otherwise evaluate the new configuration against material
past cases and compare outcomes.

The backtesting system does not need to be implemented in the initial version.
However, the blanket data design must preserve the evidence that future
backtesting will require; data that was never recorded cannot be reconstructed
months later.

### 55. Backtesting uses structured replay envelopes

A replayable historical case preserves:

- the original user intent and accepted outcome and constraints;
- the base repository commit and final diff or artifact references;
- the model, reasoning effort, prompts, instructions, skills, tools, and
  workflow versions;
- decisions, checkpoints, asks, review findings, remedies, validation results,
  and user corrections;
- token usage, cost, latency, and relevant execution timing; and
- provenance or stable fixtures for external inputs when possible.

Large immutable material should be content-addressed or referenced rather than
blindly duplicated. Secrets are explicitly excluded, and transient raw noise is
not retained merely because it existed.

The policy for universal versus curated case capture, heavy-artifact retention,
and redaction remains to be selected.

### 56. Evaluation isolates the change under test

"Backtesting" does not mean replaying every historical project interaction
end-to-end. Each evaluation declares what changed and isolates the relevant
layer.

Agent-intelligence changes such as a model, reasoning effort, role prompt, or
skill are best evaluated with stateless, unit-test-like cases. A case can use an
immutable repository commit from Git history, the original task and accepted
constraints, preserved local artifacts, and controlled tool access. It should
not depend on mutable external services merely because the original execution
did.

The deterministic control-plane harness is evaluated separately through normal
software unit and integration tests, using fake or replayed agent responses
where appropriate.

Stateful and external-system behavior still requires testing, but it belongs in
a smaller, explicitly curated integration or end-to-end suite rather than the
default agent backtest corpus.

### 57. Evaluation has three distinct layers

1. **Control-plane tests** exercise the deterministic state machine, SQLite
   transitions, timers, routing, worktree operations, recovery, and protocol
   adapters with normal software unit and integration tests. Fake or recorded
   agent responses isolate harness behavior.
2. **Stateless agent backtests** compare model, reasoning, prompt, skill, or
   role changes against immutable repository and task fixtures.
3. **Curated stateful tests** cover selected cross-agent, desktop, network,
   external-service, and full-system behavior that cannot be reduced to a pure
   agent case.

Results remain attributed to their layer rather than being blended into one
score whose regression source cannot be identified.

### 58. Runtime creates a pure corpus; backtest runs curate it

Every stateless-eligible work item automatically receives a lightweight corpus
record. The record does not duplicate its replay envelope; it relationally
references the work item's existing intent, constraints, repository commits,
configuration, checkpoints, decisions, reviews, validations, and outcomes in
the canonical SQLite project brain.

Runtime does not nominate or promote selected cases into a permanent benchmark.
Its responsibility is to preserve the purest useful historical corpus without
discarding cases based on a speculative future evaluation.

When a backtest is actually run, that campaign selects and curates a
representative slice for its declared change under test. It can assess noise,
duplicates, statefulness, and relevance at that time. Raw facts remain
immutable; derived summaries, labels, comments, fixtures, and selection
decisions remain linked rather than replacing the original case.

### 59. Evaluation artifacts use relational and content-addressed storage

Small structured comments, labels, and fixtures live in related SQLite tables.
Existing project material is referenced through immutable Git commits or other
already-canonical identifiers rather than copied.

Large or binary special fixtures live in a content-addressed artifact store.
SQLite preserves their hash, metadata, provenance, and relationships to cases.
The control plane must enforce consistency between relational records and the
artifact store.

The physical and version-control placement of both stores remains part of the
broader open control-plane placement decision.

### 60. Every backtest preserves its test-run recipe

An actual backtest creates an immutable, versioned recipe containing:

- its declared change under test;
- selected corpus case identifiers;
- filters and excluded cases with reasons;
- prompts, model and reasoning configurations;
- fixture and tool-environment versions; and
- grader and metric versions.

The recipe makes the same comparison reproducible later without deleting or
rewriting the raw historical corpus.

The current design scope stops at preserving the corpus and enough provenance
for future use. Actual backtest execution, graders, metrics, comparison logic,
and better-or-worse judgments are deliberately deferred.

### 61. Implementation receives two independent code reviews

After implementation and its own validation, the change is independently
reviewed through:

- a correctness and quality lens covering behavior, edge cases,
  maintainability, and validation; and
- a codebase-cohesion lens covering reuse of existing primitives, conventions,
  architecture, and fit with surrounding code.

The two reviewers do not substitute for each other. The primary receives and
synthesizes both outputs before the implementation can proceed toward closure.

### 62. Code review uses the same longitudinal convergence protocol

The first reviewable implementation is preserved as code snapshot version zero.
Every accepted review-fix round creates a new immutable version linked to its
findings, affected sites, remedies, and verification results.

The workflow preserves exact adjacent and version-zero-to-current diffs. It
applies the same deterministic pattern triggers and uses a fresh independent
root-architecture assessor when they fire.

Code review therefore does not discard cross-iteration evidence merely because
individual findings were locally fixed.

### 63. A fresh verifier closes the plan-to-code contract

After code review convergence, a previously uninvolved implementation-closure
agent receives the final accepted plan or RFC and the final reviewed code
change.

It maps every required behavior to concrete implementation and test evidence
and checks for:

- missing planned behavior;
- extra unplanned behavior; and
- deviations that were not explicitly documented and accepted.

The work cannot close while any such mismatch remains.

### 64. Native Codex hard review is the final independent gate

After implementation-closure verification passes, the final diff receives a
fresh review through the runtime's native Codex hard-review surface. It receives
only the necessary outcome and scope context and is not primed with prior
finding and remedy history.

An accepted finding returns the change to implementation. Because the code has
changed, affected code reviews, implementation-closure verification, and the
native hard-review gate are invalidated and must pass again before closure.

### 65. Specialist review is routed by deterministic applicability

The workflow adds specialist reviewers when touched surfaces make their lens
applicable. For example:

- authentication, secrets, parsers, networks, filesystems, privileges, or
  dependencies trigger security review; and
- user-facing screens, interactions, onboarding, settings, and destructive
  actions trigger UX review.

The applicability rules are program-enforced and extensible. The primary may
add another specialist when evidence justifies it. Every applicable specialist
participates in the same convergence, version-history, and invalidation
protocol as the core reviewers.

### 66. Runtime discoveries cannot bypass the accepted plan

The accepted plan remains the authoritative implementation contract. An
execution agent may discover new facts, but it cannot silently improvise
behavior, scope, architecture, affected sites, or other required work that the
plan does not cover.

The agent reports the discovery and pauses. The primary determines whether it
changes any accepted plan claim, decision, or required work. If it does, the
workflow returns to planning, the planning agent creates a new immutable plan
version, and all affected plan reviews and gates run again before
implementation resumes. If the discovery is already covered, it is recorded as
evidence and execution may continue without changing the plan.

The primary is accountable for keeping plan and execution synchronized. That
responsibility is orchestration and enforcement; it does not authorize the
primary to perform an unreviewed substantive plan rewrite.

### 67. Planning and implementation use separate agents

The parent outcome decomposes into linked planning and implementation work
items, each with its own dedicated agent.

After plan-review convergence, a fresh implementer receives the accepted plan
and its explicit authoritative references. The implementer does not depend on
the planner's hidden conversational context or informal handoff.

If the implementer cannot derive one valid execution path from that package, it
raises a structured ask and pauses. Missing context is treated as a plan-quality
finding: the workflow returns to the planning agent, creates a new immutable
plan version, and reruns affected plan reviews before implementation resumes.

Handoff loss is therefore evidence of an insufficient planning artifact, not a
reason to collapse planner and implementer into one agent.

### 68. A fresh implementer performs an executability preflight

Before touching implementation files, the implementer inspects the accepted
plan and every authoritative reference it names.

The implementer returns either:

- a structured `ready` receipt confirming that exactly one valid
  implementation path can be derived; or
- a structured ask, after which the implementation work item pauses and the
  plan-quality loop resumes.

This makes handoff quality measurable before implementation cost accumulates.

### 69. ITD: execution uses immutable, restartable attempts

**Status:** Accepted by the user.

#### Problem Statement

Accumulated review evidence can invalidate an attempt's original plan or
premise and reveal a materially simpler, more robust, or more efficient
alternative. Continuing to patch that attempt preserves the wrong foundation.

#### Option 1: Repair the same attempt

Pros:

- reuses existing work.

Cons:

- preserves the invalid foundation and accumulates complexity.

#### Option 2: Rewind code but retain the plan and agents

Pros:

- removes some implementation damage.

Cons:

- retains the original plan's anchoring, hidden context, and reasoning path.

#### Option 3: Preserve the attempt and restart cleanly

Pros:

- creates a genuine fresh reasoning and implementation path;
- retains complete audit and learning evidence; and
- prevents sunk-cost patching from defining the architecture.

Cons:

- some previously correct implementation may intentionally be redone.

#### Decision

Choose Option 3.

The current attempt becomes `abandoned`; its active worktree and implementation
state are discarded, while its plans, findings, remedies, reviews, decisions,
and evidence remain immutable.

A new attempt starts from a clean project baseline with a fresh planner,
implementer, and reviewers. Only accepted findings, constraints, and learning
carry forward; the abandoned solution structure and hidden agent context do
not.

The workflow kernel must therefore support phase snapshots, forward-recorded
rewind/restart events, and idempotent transitions. The exact restart trigger,
baseline-selection rule, and idempotency mechanism remain to be selected.

### 70. ITD: every attempt restart requires explicit user approval

**Status:** Accepted by the user.

#### Problem Statement

Abandoning an active attempt and restarting from a clean baseline is a costly
and consequential action, even though the abandoned attempt's history remains
recoverable and auditable. The operating model must decide who has authority to
trigger that transition.

#### Option 1: The root-architecture assessor restarts automatically

Pros:

- makes the transition fast and deterministic.

Cons:

- combines diagnostic and execution authority in one role; and
- a false-positive assessment can discard useful active work without user
  review.

#### Option 2: The assessor recommends and the primary decides

Pros:

- permits autonomous restarts within an already approved outcome; and
- allows the primary to escalate only product, scope, ITD, or substantial-cost
  changes.

Cons:

- requires a potentially ambiguous cost and authority boundary; and
- still allows meaningful active work to be abandoned without direct user
  approval.

#### Option 3: Every restart requires explicit user approval

Pros:

- gives the user final authority over every consequential restart; and
- prevents useful active work from being silently abandoned.

Cons:

- pauses orchestration while approval is pending; and
- can make the user a workflow bottleneck.

#### Decision

Choose Option 3.

The root-architecture assessor may recommend a restart but cannot authorize or
perform it. The primary presents the recommendation, supporting evidence,
preserved learning, proposed clean baseline, and expected discarded work to the
user. The affected attempt remains paused until the user explicitly approves
or rejects the restart. Independent work items may continue.

### 71. ITD: restart recommendations use evolving evidence predicates

**Status:** Accepted by the user.

#### Problem Statement

The operating model needs a consistent boundary for when a root-architecture
assessor may recommend abandoning an attempt. A fixed finding count does not
prove architectural invalidity, while unconstrained assessor judgment is
difficult to audit or compare over time. At the same time, the initial
eligibility criteria cannot be assumed to be universally correct.

#### Option 1: Use a fixed finding count

Pros:

- is simple and mechanically deterministic.

Cons:

- finding quantity does not establish that an attempt's foundation is invalid.

#### Option 2: Allow unrestricted assessor judgment

Pros:

- adapts to the full context of each attempt.

Cons:

- allows each assessor to redefine what is restart-worthy; and
- makes decisions difficult to audit, compare, or backtest consistently.

#### Option 3: Use explicit, evolving evidence predicates

Pros:

- constrains recommendations with an auditable eligibility test;
- retains contextual agent judgment when assessing the evidence; and
- allows the policy to improve as real cases reveal false positives, false
  negatives, or missing conditions.

Cons:

- the initial predicates may be incomplete or incorrectly calibrated; and
- policy-version changes complicate comparisons across historical assessments.

#### Decision

Choose Option 3.

A restart recommendation is eligible only when the assessor demonstrates that:

- evidence invalidates a foundational premise or accepted plan decision of the
  current attempt;
- incremental repair would preserve that invalid structure or introduce
  disproportionate complexity; and
- a clean restart has a plausible path to satisfy the already accepted outcome
  better.

These are a versioned operating policy, not universal truths. They may evolve
through evidence-backed ITDs with mandatory user review. Each assessment records
the exact predicate-policy version it used, its evidence against every
predicate, and its conclusion. Historical assessments are never rewritten when
the policy evolves; future evaluation may compare them under a newer policy.

### 72. ITD: a restarted attempt returns to the original base snapshot

**Status:** Accepted by the user.

#### Problem Statement

Execution can accumulate meaningful runtime state before the project is ready
for a Git commit. A clean restart therefore needs an exact rewind point that is
not limited to committed Git history.

#### Option 1: Return to the original attempt's base snapshot

This option is explicitly defined as a runtime snapshot, not merely the Git
commit from which the attempt began.

Pros:

- gives the replacement attempt the same starting state as the abandoned
  attempt;
- enables direct comparison between attempts; and
- remains usable when the relevant runtime state was never committed.

Cons:

- accepted independent changes made after the snapshot are not automatically
  present.

#### Option 2: Start from the latest main-branch commit

Pros:

- includes the newest committed project state.

Cons:

- silently introduces changes that were not part of the original attempt; and
- weakens reproducibility and direct comparison.

#### Option 3: Compose a new baseline for each restart

Pros:

- can include selected dependencies and accepted intervening changes.

Cons:

- adds a baseline-composition decision to every restart; and
- makes it harder to distinguish a genuinely fresh attempt from a changed
  experiment.

#### Decision

Choose the refreshed Option 1: every attempt begins with an immutable base
snapshot, and an approved restart returns to that exact snapshot.

Git remains the durable project history after work is accepted, but it is not
the workflow's only snapshot mechanism. The control plane must provide
additional runtime snapshotting sufficient to enable rewind, restart, and
attempt comparison before a Git commit exists. The snapshot's exact contents,
storage mechanism, lifecycle, and treatment of accepted independent changes
remain to be designed.

### 73. ITD: snapshot at attempt start and durable phase boundaries

**Status:** Accepted by the user.

#### Problem Statement

An attempt-start snapshot enables a complete clean restart, but long workflows
also contain useful accepted phase results. The operating model must balance
replay precision against snapshot noise, storage, and lifecycle complexity.

#### Option 1: Snapshot only at attempt start

Pros:

- is the simplest lifecycle; and
- always permits a clean full-attempt restart.

Cons:

- forces completed phases to be repeated when only a later phase needs replay.

#### Option 2: Snapshot every state change

Pros:

- provides maximum rewind precision.

Cons:

- creates excessive storage, noise, and lifecycle complexity; and
- makes meaningful recovery points difficult to distinguish from incidental
  state mutations.

#### Option 3: Snapshot attempt start and durable phase boundaries

Pros:

- preserves useful replay points with bounded complexity;
- supports both full-attempt and phase-level replay; and
- aligns snapshots with accepted workflow transitions.

Cons:

- requires explicit phase-boundary and retention definitions.

#### Decision

Choose Option 3.

Every attempt has an immutable start snapshot. Additional immutable snapshots
are created at defined durable phase boundaries, including accepted planning,
implementation handoff, review convergence, and final closure boundaries as
applicable. Exceptional on-demand snapshots are permitted when their reason is
recorded. Incidental state mutations do not each create a snapshot.

These additional snapshots enable phase-level replay; they do not change the
previous decision that a full attempt restart returns to the original attempt
base snapshot.

### 74. ITD: rewind only the execution plane

**Status:** Accepted by the user.

#### Problem Statement

The project has two fundamentally different planes. The control plane is the
permanent chronological record of every project instant and orchestration
transition. The execution plane contains the implementation state being
changed. Treating both as restorable state would erase or rewrite the very
history the control plane exists to preserve.

#### Option 1: Rewind both control and execution planes

Pros:

- appears to restore the complete system to an earlier instant.

Cons:

- erases or rewrites project chronology;
- destroys evidence about the abandoned path; and
- contradicts the control plane's append-only purpose.

#### Option 2: Rewind execution and the complete development environment

Pros:

- attempts to restore a broader runtime state.

Cons:

- is environment-specific and fragile;
- can include state that the project does not own; and
- expands Darkline beyond orchestration into general environment
  virtualization.

#### Option 3: Rewind only the execution plane

Pros:

- preserves the complete project history;
- restores only the state the attempt is authorized to mutate; and
- keeps environment reproducibility within normal software-engineering
  practices.

Cons:

- requires implementation setup, tests, and development tooling to be
  independently idempotent or replayable; and
- cannot automatically undo arbitrary external side effects.

#### Decision

Choose Option 3.

The control plane never rolls back. Snapshot creation, phase transitions,
attempt abandonment, user restart approval, execution rewind, and replacement
attempt creation are all recorded as new forward, append-only events. Current
control-plane projections may advance in response to those events, but no
historical record is rewritten or removed.

Only execution-plane state is restorable. This primarily means the code
worktree and repository-local implementation artifacts owned by the attempt.
Snapshot manifests and execution-state references may be stored by the control
plane, but they are evidence and pointers, not control-plane state to restore.
Agent sessions are not rewound; replacement agents receive fresh context
derived from the preserved record.

The broader development environment is outside Darkline's snapshot and rewind
boundary. Project setup, tests, migrations, and local tooling must use normal
engineering practices to be idempotent and replayable. Arbitrary external side
effects are not silently treated as reversible; their policy, when relevant,
must be handled separately.

### 75. ITD: every execution rewind requires explicit user authorization

**Status:** Accepted by the user.

#### Problem Statement

An execution rewind is evidence that accumulated implementation state has
become unsafe, untrustworthy, contaminated, or uneconomical to continue. The
cause may be an implementation failure, agent derailment, incorrect input,
worktree contamination, or a defect in Darkline itself. Silently hiding such an
event would prevent the user from seeing material failures in either the work
or the operating framework.

#### Option 1: Require user authorization for every rewind

Pros:

- makes every exceptional recovery event visible to the user;
- exposes possible Darkline, agent, planning, or environment failures; and
- prevents useful execution state from being silently discarded.

Cons:

- pauses the affected work item while authorization is pending; and
- makes the user a required participant in recovery.

#### Option 2: Require approval only when crossing an accepted phase boundary

Pros:

- allows routine recovery within the active phase.

Cons:

- can hide material failures merely because the affected output was not yet
  accepted.

#### Option 3: Let the primary authorize any in-scope rewind

Pros:

- minimizes orchestration delay.

Cons:

- permits silent loss of execution work; and
- withholds evidence that may reveal a systemic framework problem.

#### Decision

Choose Option 1.

No execution-plane snapshot is restored without explicit user authorization.
The primary first reports the triggering problem, evidence, suspected cause,
affected and preserved state, proposed target snapshot, expected discarded
work, and recommended next action. The affected work item remains paused while
independent work may continue.

Ordinary tests, review findings, and forward code corrections do not constitute
a rewind and may continue under their existing authority. If a forward
correction requires restoring any earlier execution snapshot, it crosses this
authorization gate.

### 76. ITD: execution snapshots use tiered retention

**Status:** Accepted by the user.

#### Problem Statement

Abandoned and superseded execution states can be valuable for audit, root-cause
analysis, corpus construction, and exact replay. Preserving every incidental
snapshot forever, however, creates unbounded storage growth, while deleting all
old content destroys the strongest evidence.

#### Option 1: Preserve every snapshot indefinitely

Pros:

- provides the most complete historical replay surface.

Cons:

- creates unbounded storage growth; and
- gives incidental snapshots the same lifecycle as load-bearing evidence.

#### Option 2: Preserve only metadata or diffs

Pros:

- minimizes storage consumption.

Cons:

- can make exact reconstruction impossible; and
- weakens inspection of the implementation state that produced a failure.

#### Option 3: Use tiered retention

Pros:

- durably preserves load-bearing replay and audit evidence;
- permits bounded cleanup of incidental recovery points; and
- can use content-addressed deduplication to reduce duplicate storage.

Cons:

- requires explicit retention categories, durations, and garbage-collection
  rules.

#### Decision

Choose Option 3.

Attempt-start, accepted-phase, failure-trigger, and final execution snapshots
are durable evidence by default. Incidental or exceptional intermediate
snapshots may have configurable retention and may be garbage-collected after
their retention requirements are satisfied. Content-addressed storage should
allow identical content to be shared rather than copied repeatedly.

Garbage collection affects only eligible execution-snapshot content. The
control plane never deletes or rewrites the historical snapshot manifest,
retention decision, or garbage-collection event. Consequently, the record may
show that a historical snapshot once existed even when its non-durable content
has expired.

### 77. ITD: Git owns ordinary parallel-work integration

**Status:** Accepted by the user.

#### Problem Statement

Multiple work items may execute concurrently in separate branches and
worktrees. The operating model must not turn ordinary source-control isolation
and later integration into a speculative orchestration problem.

#### Option 1: Assess every accepted merge against every active attempt

Pros:

- may detect some incompatibilities before integration.

Cons:

- creates a proactive dependency-analysis subsystem without demonstrated need;
  and
- interrupts isolated work even when ordinary Git integration would suffice.

#### Option 2: Automatically update every active worktree

Pros:

- keeps active worktrees close to the latest main branch.

Cons:

- silently mutates attempt baselines;
- weakens reproducibility; and
- creates unnecessary churn and integration risk.

#### Option 3: Use normal Git isolation and integrate completed work

Pros:

- uses established branch and worktree primitives;
- preserves each attempt's captured base snapshot; and
- introduces Darkline handling only when a real incompatibility appears.

Cons:

- some conflicts or incompatibilities are discovered only at integration time.

#### Decision

Choose Option 3.

Each parallel work item executes in its own branch or worktree from its captured
base snapshot. Completed work is integrated into the main branch through normal
Git practices. Other active worktrees are neither automatically updated nor
proactively rebaselined by Darkline.

Normal merge or rebase handling, conflict resolution, and post-integration
validation remain ordinary engineering work. If integration exposes a material
incompatibility or new uncertainty, the existing discovery and primary-agent
ask process applies. If resolution requires restoring an earlier execution
snapshot, the mandatory user rewind-authorization gate applies.

### 78. ITD: authoritative integration requires explicit user approval

**Status:** Accepted by the user.

#### Problem Statement

Passing implementation review, closure verification, validation, and the final
hard gate establishes technical readiness, but does not by itself establish
that the user accepts the result into the project's authoritative branch.

#### Option 1: Let the primary integrate automatically after all gates pass

Pros:

- enables autonomous end-to-end completion.

Cons:

- changes authoritative project state before the user sees the final result.

#### Option 2: Require explicit user approval after a completion summary

Pros:

- creates a clear technical-readiness versus user-acceptance boundary;
- preserves the user's final authority over authoritative code; and
- gives the user a consolidated basis for acceptance.

Cons:

- pauses every completed work item before integration.

#### Option 3: Use a risk-based integration policy

Pros:

- can reduce user involvement for low-risk changes.

Cons:

- requires a fallible risk-classification system; and
- can integrate changes the user expected to review personally.

#### Decision

Choose Option 2.

After every required technical gate has passed, the primary presents a final
completion summary containing the accepted outcome, material implementation
changes, validation evidence, plan or scope deviations, review and closure
status, and known remaining risks. The work item is technically ready but not
integrated until the user explicitly approves integration into the
authoritative branch.

If the user requests changes instead, the affected work item returns to the
appropriate forward workflow phase and all invalidated gates repeat. Other
independent work items may continue while integration approval is pending.

### 79. ITD: the MVP is execution-focused, not a project-management system

**Status:** Accepted by the user.

#### Problem Statement

The end-state aspiration includes a persistent project brain that could replace
external idea and roadmap tools. The MVP must decide whether that full product
memory is defining execution DNA or later product-management breadth.

#### Option 1: Build an execution-only MVP

Pros:

- keeps the initial product focused on reliably completing accepted coding
  work; and
- limits durable state to what execution continuity and accountability require.

Cons:

- ideas, experiments, curiosity, and roadmap management remain external for the
  MVP.

#### Option 2: Build the full project-management system in the MVP

Pros:

- delivers broad continuous product memory immediately.

Cons:

- substantially expands the initial product beyond the coding-execution
  objective.

#### Option 3: Include a basic general project brain in the MVP

Pros:

- provides some product-memory continuity without full dashboards and
  analytics.

Cons:

- still mixes two product scopes before the execution system is proven.

#### Decision

Choose Option 1.

The MVP durably preserves only information required to execute accepted
substantive software-engineering work:
the user's accepted intent and constraints, decisions, work items and their
state, agent asks and checkpoints, accepted plan and implementation artifacts,
review and validation evidence, approvals, and outcomes.

General idea capture, curiosity and experiment storage, roadmap management,
inbox review, idea promotion, and replacement of Google Keep are explicitly
post-MVP capabilities. Their previously discussed behavior remains preserved as
end-state inspiration but cannot expand the MVP.

### 80. ITD: MVP completion requires one end-to-end real coding slice

**Status:** Accepted by the user.

#### Problem Statement

An installed setup or individually working components do not prove that the new
operating model delivers its defining behavior. Conversely, requiring broad
production hardening across many projects would turn the MVP into a full
rollout. The project needs an objective completion bar that is narrow in breadth
but complete in behavioral DNA.

#### Option 1: Treat successful setup installation as MVP completion

Pros:

- provides the fastest tangible delivery.

Cons:

- proves configuration, not the intended end-to-end operating behavior.

#### Option 2: Complete one representative real coding outcome end to end

Pros:

- demonstrates the full behavioral chain on actual brownfield work;
- keeps the validation surface narrow enough for an MVP; and
- tests both ordinary execution and durable recovery.

Cons:

- one slice cannot prove every future project or task class.

#### Option 3: Require multi-project and multi-task production hardening

Pros:

- provides stronger evidence of generality and operational maturity.

Cons:

- expands the MVP completion bar into full product rollout.

#### Decision

Choose Option 2.

The MVP is complete only when one representative real brownfield coding outcome
runs from voice-first intake through accepted intent, durable work state,
planning, delegated implementation, required independent reviews, plan-to-code
closure, final validation, user integration approval, and authoritative
integration.

The same slice must also exercise a controlled failure or interruption path
that proves compaction or physical-agent replacement recovery and an authorized
execution rewind without losing control-plane history. Component tests and
installation checks remain necessary evidence, but they cannot substitute for
this vertical acceptance slice. Selecting the exact pilot repository and task
belongs to later implementation planning.

### 81. ITD: the MVP executes one user-level work item at a time

**Status:** Accepted by the user.

#### Problem Statement

The end-state team model can coordinate multiple independent project
workstreams, but proving that concurrency in the first vertical slice broadens
the scheduler, UI, recovery, and acceptance surface. The MVP must decide how
much concurrency is defining DNA versus later breadth.

#### Option 1: Allow one active user-level work item with multiple internal agents

Pros:

- proves delegation, role separation, review independence, and durable recovery
  within one coherent outcome; and
- keeps the initial orchestration and acceptance surface bounded.

Cons:

- does not prove concurrent unrelated workstreams or continuation of one while
  another is blocked.

#### Option 2: Allow parallel children only within one parent outcome

Pros:

- additionally proves parallel worktree execution.

Cons:

- adds concurrency machinery without proving general multi-workstream project
  management.

#### Option 3: Allow multiple independent active work items

Pros:

- demonstrates the broader persistent-primary and team-lead aspiration.

Cons:

- materially expands MVP scheduling, state, recovery, and acceptance testing.

#### Decision

Choose Option 1.

The MVP accepts and executes one user-level software-engineering work item at a
time. It may
use multiple internal agents for planning, implementation, review, validation,
and other bounded responsibilities, including independent reviewer contexts.
Internal decomposition does not turn those tasks into separately user-managed
workstreams.

Additional user requests may still be preserved as pending intake, but they do
not execute concurrently with the active work item. Multiple independent active
workstreams and their blocked-work continuation semantics remain part of the
end-state aspiration, not the MVP completion bar.

### 82. ITD: the MVP is reusable but single-project-at-a-time

**Status:** Accepted by the user.

#### Problem Statement

The MVP will be accepted through one real brownfield coding slice. That narrow
validation target must not accidentally turn the implementation into a
pilot-specific prototype, while supporting a simultaneously managed portfolio
of projects would add unrelated product breadth.

#### Option 1: Build a pilot-specific prototype

Pros:

- provides the shortest route to a demonstration.

Cons:

- does not deliver the reusable Codex setup that motivated the project; and
- requires a later productization rewrite.

#### Option 2: Build a reusable, single-project-at-a-time setup

Pros:

- produces the intended installable setup rather than a one-off demo;
- keeps every project's durable state isolated; and
- allows MVP validation to remain bounded to one representative project.

Cons:

- requires a real project initialization, discovery, and state-isolation
  boundary.

#### Option 3: Build a multi-project management platform

Pros:

- delivers broader portfolio-level operation immediately.

Cons:

- expands scheduling, UI, state, and recovery beyond the MVP objective.

#### Decision

Choose Option 2.

The setup is shared and installable rather than hard-coded to the acceptance
pilot. It can initialize or operate inside different software projects, and
each project's durable execution state is isolated from every other project.

The MVP needs to operate in only one selected project context at a time and is
accepted on one real brownfield project. Concurrent project management, a
cross-project primary, and portfolio dashboards remain post-MVP breadth.

### 83. ITD: all substantive software-engineering work uses the MVP lifecycle

**Status:** Accepted by the user.

#### Problem Statement

A coding outcome often depends on diagnosis, research, planning, review, and
validation, and each can also be requested as an independently verifiable
outcome. Restricting durable orchestration to file-changing requests would
create context and accountability gaps between these closely related forms of
engineering work. Expanding it to every conversation would recreate the
deferred project-management scope.

#### Option 1: Orchestrate only code-changing requests

Pros:

- creates the narrowest controlled execution surface.

Cons:

- leaves substantive diagnosis, research, planning, and review outside durable
  work continuity; and
- creates fragile handoffs when those outcomes later drive implementation.

#### Option 2: Orchestrate all substantive software-engineering work

Pros:

- gives every independently verifiable technical outcome durable intent,
  evidence, and accountability; and
- keeps technical handoffs within one coherent project history.

Cons:

- requires lifecycle and role routing beyond implementation-only tasks.

#### Option 3: Orchestrate every non-trivial conversation

Pros:

- maximizes continuity across technical and product thinking.

Cons:

- pulls general ideation and roadmap management back into the MVP; and
- conflicts with the accepted execution-focused boundary.

#### Decision

Choose Option 2.

The MVP treats diagnosis, technical research, planning, implementation, review,
and validation as substantive work whenever the requested result is an
independently verifiable deliverable or conclusion. Such work receives durable
intent, bounded delegation, evidence, and completion status proportional to its
type.

Casual discussion, trivial answers, and exploratory product or roadmap thinking
do not automatically enter the controlled work lifecycle. Product thinking that
produces an accepted software-engineering outcome may create an execution
intake, but general project-brain behavior remains post-MVP.

### 84. ITD: accepted MVP work continues without an attached user session

**Status:** Accepted by the user.

#### Problem Statement

The intended executive-to-team relationship requires deciding whether accepted
work depends on the user keeping one physical Codex CLI session attached. This
choice materially determines whether the MVP is an interactive prompt setup or
a persistent execution system.

#### Option 1: Run only while the user session remains attached

Pros:

- requires the simplest runtime lifecycle.

Cons:

- makes the user responsible for keeping execution alive; and
- weakens the delegated-team behavior.

#### Option 2: Suspend durably when the user disconnects

Pros:

- preserves safe session replacement and later resumption without background
  execution.

Cons:

- prevents the team from progressing while the user is absent.

#### Option 3: Continue accepted work in the background

Pros:

- delivers genuine delegated execution after the user approves an outcome;
- allows the user to disconnect and later reconnect to the same logical
  primary and durable state; and
- pauses only when a required ask, approval, failure, or other accepted gate
  blocks progress.

Cons:

- requires a persistent orchestration host, crash recovery, secure identity,
  and user-attention routing.

#### Decision

Choose Option 3.

Once a software-engineering work item is accepted and started, its authorized
execution may continue when the user's UI or original physical primary session
is disconnected. An unresolved user ask, mandatory approval, rewind request, or
failure gate pauses the affected work until the user returns.

This decision establishes a required behavior, not the controller
implementation. A persistent programmatic control plane is the current working
mechanism: it would own mechanical work state, agent-thread lifecycle,
checkpoint and ask routing, pause enforcement, and recovery, while the logical
primary Codex retains semantic leadership and remains the user's interface. The
authoritative host and native-CLI connection remain subject to the pending
proof-of-capability ITD in Section 48.

## Later Design Areas

These have not yet been decided:

- control-plane code distribution and placement;
- per-project SQLite and artifact-store placement, versioning, backup, and
  export;
- SQLite's schema, journaling and interaction interface;
- the representation of current operational state across physical sessions;
- tag aliasing, merging, and cleanup authority;
- how active workstreams and their dependencies are represented;
- execution-agent context checkpoints and handoff mechanics;
- checkpoint work-budget selection;
- model-routing optimization and downgrade criteria;
- backtest-time corpus selection and the stateful evaluation suite;
- evaluation metrics, retention, redaction, and privacy policy;
- planning, implementation, validation, review, and closure;
- execution-plane snapshot contents, storage, retention durations, rewind, and
  idempotency semantics;
- policy for unavoidable external execution side effects;
- initial restart-predicate calibration and its amendment process;
- deterministic workflow-engine boundaries and triggers;
- progress reporting and escalation behavior;
- the final file name and structure of the chronological ITD log;
- archival location for the ITD reference transcript; and
- how the new operating model maps to Codex instructions, agents, skills,
  configuration, hooks, or tools.
