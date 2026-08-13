# Authoritative-Host PoC Legacy Learnings

**Status:** Distilled handoff from an abandoned experiment

This is not a specification for the next PoC. It separates the operating-model
DNA worth retaining from the implementation shape that failed to converge.
Everything here must be reconsidered at the altitude stated: user-settled
invariants are inputs; technical mechanisms are evidence; old architecture is
legacy.

The inheritance classification is:

- user-settled operating decisions remain current, including the relational
  SQLite project brain and logical-primary sole-writer boundary;
- bounded principles such as risk-proportional authority, earliest-responsible-
  phase checks, and durable evidence remain current without selecting their
  implementation;
- App Server hosting, controller/state-machine topology, notification windows,
  rebind protocols, runtime transaction ownership, and the 60-table kernel are
  reopened or superseded mechanisms; and
- the archived Plans and ledger are historical attempts, not specifications.

## 1. What we were trying to prove

The original Darkline vision described an autonomous software team managed by a
human through one accountable interface. The later operating-model interview
narrowed that into a voice-first experience in which:

- the user speaks freely to one accountable primary;
- the primary understands product intent, manages internal agents, and remains
  responsible for the result;
- agents can plan, implement, review, ask questions, and report inflection
  points without forcing the user to micromanage them;
- important intent, decisions, work, findings, and handoffs survive session
  compaction and agent replacement; and
- the system preserves the user's authority over consequential changes while
  continuing independent work when possible.

The authoritative-host PoC tried to demonstrate that experience through stock
Codex CLI/App Server plus a programmatic controller, SQLite ledger, role agents,
Git worktrees, review loops, and explicit authority transitions.

## 2. User-settled operating invariants worth preserving

The detailed decision record remains
[`NEW_CODEX_OPERATING_MODEL.md`](../../../NEW_CODEX_OPERATING_MODEL.md). The
following is a compact index, not a replacement for it.

### Interaction and accountability

- The user interacts primarily with one logical Codex primary, not directly
  with a swarm and not necessarily through one immortal transcript.
- Long voice input is a normal high-bandwidth brief. The primary should
  structure it into intent, context, constraints, success criteria, decisions,
  and work rather than requiring one small pointer at a time.
- Read-only context gathering comes before interpretation whenever available
  evidence can answer the question. Already-gathered current context is reused.
- The user's language normally distinguishes discussion from execution. A clear,
  unambiguous execution request may proceed; material ambiguity requires a
  concise understood-summary and approval to continue.
- The primary owns derived technical decisions within accepted intent. The user
  should not be interviewed about every implementation mechanism.

### Decision discipline

- A meaningful decision is recorded as: problem statement, valid options,
  option-specific pros and cons, and the decision.
- An ITD earns that weight only when it connects to what makes the product's
  output good, fixes a fundamental hard-to-change technical direction, and
  preserves the rationale that future change work must re-evaluate.
- Important Technical Decisions persist that complete structure, not only the
  selected option.
- The user's review of a user-owned ITD is mandatory. Independent work may
  continue if it does not depend on the unresolved decision.
- Uncertainty exists only when the current constraints admit zero valid paths or
  more than one valid path. One valid path is not an uncertainty merely because
  execution is difficult.

### Durable project memory

- Product intent, verbatim source, structured summaries, decisions, work,
  agent asks, answers, findings, and relationships belong in project-native,
  version-controlled durable storage rather than only a chat transcript.
- SQLite is the accepted relational project-brain store, with the logical
  primary as the sole writer and agents communicating through the primary. A
  fresh PoC may exercise only the smallest project-brain slice needed for its
  claim. This decision does not make SQLite the transaction engine for every
  runtime protocol and does not preserve the abandoned 60-table kernel.
- Git history records delivered implementation state. A work ledger begins
  before work starts and records intent, decomposition, blockers, abandonment,
  restarts, and product perspective.
- Verbatim voice intent and organized summaries should both remain available.
  Auto-generated/reused tags can provide flexible retrieval without forcing a
  rigid taxonomy at capture time.

### Delegation and context management

- Planning and implementation are separate responsibilities. A good plan should
  carry enough context that handoff loss is treated as a planning smell.
- Each non-trivial work item may have a dedicated execution agent. Runtime
  discoveries may create new linked work items within inherited authority.
- Primary-to-agent communication is bidirectional and general: architecture,
  product context, questions, checkpoints, steering, and inflection reports are
  all legitimate.
- An agent pauses only dependent work while an unresolved ask is answered.
- The primary owns agent context priming after spawn or compaction and checks
  alignment during long work. A low-cost observer may assist, but cannot become
  a second primary or stop work on its own.

### Quality and authority

- Every implementation has a proportional plan.
- Plans receive independent soundness and adversarial review before coding.
- Implementations receive independent correctness and codebase-cohesion review.
- A fresh closure pass verifies that the reviewed code implements the accepted
  plan completely, with neither omissions nor unapproved extras.
- Findings are first-class durable evidence tied to the exact reviewed Git
  artifact. Longitudinal pattern assessment is more reliable after repeated
  sites/iterations than after one isolated finding.
- Intent revision, implementation restart/rewind, abandonment, and Git
  integration are distinct transitions. Rewind and integration require explicit
  current user authority and must never happen silently.
- Runtime discoveries that change the accepted plan must update and re-close the
  plan before the dependent implementation continues.
- Measurement is cross-cutting. Runtime should preserve clean replay/evaluation
  corpus inputs so future models, prompts, and configurations can be compared
  rather than judged only by feel. Building the evaluation engine itself was
  not part of this PoC.

## 3. Research evidence worth retaining, but not inheriting blindly

These observations came from source inspection, offline prototypes, and some
approved live exercises. They are version-sensitive and were not closed as a
production proof.

- Stock Codex CLI and App Server expose enough thread, turn, notification,
  steering, interruption, and model-configuration surfaces to remain a plausible
  substrate for agent orchestration.
- A native-first architecture can route different roles to different models and
  reasoning effort. Initial quality-first defaults can later be optimized from
  measurements.
- Primary-to-agent and agent-to-primary conversation can be modeled without
  exposing agents directly to the user or the control database.
- Git commits/worktrees are good immutable implementation and review identities.
  After review fixes, the relevant review scope is the cumulative diff from the
  accepted base, while the new candidate commit captures all tracked and newly
  added files.
- SQLite is effective for an auditable work/decision/finding ledger and exact
  relational queries. It became problematic only when it was also made to
  coordinate a large distributed runtime protocol with process-local mirrors.
- App Server snapshots such as `thread/read` cannot safely be assumed to be a
  complete causal action ledger. Notification ordering, delivery certainty,
  finalization, detach, and physical-process ownership must be treated as
  explicit integration concerns if a future design depends on them.
- Passing a large offline test suite is useful implementation evidence but not
  proof that every cross-component ownership path has been enumerated.

## 4. What the implementation became

The intended low-stakes vertical slice grew into a high-assurance workflow
runtime:

- the final Plan was 2,471 lines;
- the three core Python modules were 23,891 lines;
- the four core test modules were 17,555 lines;
- the SQLite kernel contained 60 tables; and
- the chronological review ledger grew to 14,886 lines.

Authority was distributed across SQLite transactions, controller-local mutable
state, workflow orchestration, App Server notifications and effects, OS process
and PTY ownership, Git candidates, and evidence files. A prose plan described
many behaviors, but it was not a mechanically exhaustive producer-to-consumer-
to-effect ownership map.

This is the central failure: the project was no longer proving the desired user
experience. It was trying to make a custom distributed control plane correct
under many races before the product shape had earned that complexity.

## 5. Attempt and failure chronology

The full chronological history is preserved in
[`REVIEW_LEDGER.md`](REVIEW_LEDGER.md), with bounded live-run field projections
in [`LIVE_RESEARCH_EVIDENCE.md`](LIVE_RESEARCH_EVIDENCE.md). The main
arc was:

1. Early phases explored a controller gateway, durable command kernel, worker
   isolation, native CLI connection, exact evidence, and a large runtime proof
   matrix.
2. Review repeatedly found shutdown, PTY, process, presentation, notification,
   authority, and evidence-lifecycle edge cases. The proof harness started
   dominating the product objective.
3. The project explicitly reset toward a complete low-stakes happy path and
   rejected program-owned natural-language approval grammar and the generic
   runtime proof system.
4. Approved live attempts exposed real Codex/App Server integration behavior:
   resume/hydration constraints, model configuration, strict schema issues,
   human-wait behavior, and missing action information in snapshots.
5. Notification authority then expanded into receipt windows, causal close,
   finalization, failure propagation, bounding, and endpoint lifecycle. Local
   fixes repeatedly uncovered sibling sites in later review iterations.
6. The Plan was rewritten and repeatedly reviewed. Observation, immediate
   steering, bounded context, rebind, correction/effect races, and candidate
   authority added still more transition surfaces.
7. After a user-authorized bounded E16 completion pass, 344 offline tests passed.
   A fresh E17 review nevertheless found new blockers in endpoint publication,
   observer lifecycle, plan-finding closure, interrupt certainty, presentation
   ownership, candidate binding, and concurrent identity allocation.
8. The final convergence diagnosis concluded that each individual obligation
   was described, but the architecture and manual traceability method were not
   converging. Another site-by-site repair pass was stopped.

The repeated findings were not simply reviewers inflating insignificant issues:
most described real paths by which the system could claim authority, completion,
or ownership that its physical effects did not match. At the same time, many of
those paths existed only because the PoC had become far more ambitious than its
low-stakes proof claim required. Both facts are true.

## 6. Root failure patterns

### Scope inflation

The project repeatedly treated robustness mechanisms as prerequisites for the
first vertical experience. Each mechanism introduced new states, transitions,
failure modes, and proof obligations, which triggered more mechanisms.

### More than one owner for the same truth

Durable rows, in-memory windows, scheduler state, physical process state, Git,
and evidence files often represented related lifecycle facts. Correctness then
depended on updating every representation in the right order under interruption.

### Split transaction boundaries

Several recurring findings had the same shape: prepare or publish authority in
one component, perform a fallible effect in another, and settle or expose the
result later. A lock or SQLite transaction could protect one local step but not
the complete real-world effect.

### Manual traceability did not scale

The Plan named many behaviors and sites but could not mechanically enumerate
every producer, consumer, waiter, cleanup owner, and externally visible effect.
Tests and reviews closed the known site while another sibling path remained.

### Review became a complexity ratchet

The reviews were valuable at finding real inconsistencies, but fixes were too
often implemented at the local symptom altitude. The artifact grew after every
pass, increasing the next review's search space and the probability of another
cross-component omission.

### Assurance level did not match the PoC claim

The stated scope excluded production fault tolerance, hostile clients, and
general race proof, yet the implementation increasingly pursued properties
close to an authoritative production workflow engine. The review gate then
correctly assessed the machinery that existed, not the simpler product we wished
we had built.

## 7. Was Python itself a mistake?

Not as the original choice. Python was effective for source probes, fast
experiments, SQLite exploration, fixtures, and early end-to-end learning.

It became a poor fit after the PoC turned into one large concurrent authority
host combining threads, shared mutable state, async external responses, SQLite,
PTY/process control, and many typed lifecycle variants. Python's dynamic types
and permissive object/state boundaries made ownership omissions easier to write
and harder to make structurally impossible.

That was an amplifier, not the root cause. Rewriting the same architecture in Go
or Rust would preserve its distributed transactions and excessive state surface.
A stronger type system, explicit message ownership, structured concurrency, and
smaller process boundaries could expose some errors earlier, but only after the
next design first removes unnecessary behavior.

For a fresh PoC:

- choose the proof claim and ownership graph before choosing the language;
- Python remains reasonable for disposable probes, corpus tooling, and fixtures;
- a genuinely concurrent authoritative controller should favor a language and
  design that encode closed state variants and ownership explicitly; and
- do not build a standalone replacement Codex, large service, or fork merely to
  justify a language change.

The language decision is open.

## 8. Guardrails for a fresh PoC

1. Write one sentence stating exactly what the PoC proves. Anything not needed
   for that sentence is deferred.
2. Fix a small finite acceptance narrative before code. Review against that
   claim, not against imagined production use.
3. Start with the intended user experience: user to primary, primary to a small
   number of agents, durable intent/work capture, and a visible result.
4. Mechanically enforce only the minimum consequential boundary. Do not build a
   generic authorization, notification, recovery, or proof framework.
5. Give each lifecycle fact one authoritative owner. Avoid durable state plus a
   second process-local mirror unless the mirror is disposable and derivable.
6. If a real-world effect cannot share a transaction with durable state, model
   the narrow uncertainty explicitly or reduce the claim; do not simulate a
   distributed transaction through many ad hoc states.
7. Use native Codex capabilities wherever they already provide the needed
   lifecycle. Add a controller layer only for behavior Codex cannot supply and
   the PoC must visibly demonstrate.
8. Explicitly defer auto-rebind, rewind machinery, concurrent observations,
   crash recovery, exactly-once effects, and adversarial race closure until
   product evidence makes one necessary.
9. Keep review findings tied to the accepted PoC claim. A blocker must show that
   the claim or a deliberately touched invariant is false, not merely that a
   stronger system could be designed.
10. After one repair iteration reveals a repeated cluster, stop and reassess
    ownership/scope before adding more states or protocols.
11. Keep the implementation disposable and small enough that restart is cheaper
    than architectural patchwork.
12. Preserve learnings and evaluation inputs independently of the implementation
    so deleting a failed PoC remains safe.

## 9. Questions deliberately reopened

The next session should decide these from first principles rather than inherit
answers from the abandoned Plan:

- What is the smallest end-to-end experience that proves the operating-model
  DNA?
- Which responsibilities belong to the primary model, stock Codex, a thin
  deterministic controller, and durable project storage?
- Does the first PoC need App Server, or can native Codex delegation plus a small
  project ledger prove the experience?
- What single transition, if any, must the program enforce mechanically in v0?
- What failure classes are explicitly visible-but-deferred?
- What is the minimum durable schema, and which state can be reconstructed from
  Git or Codex rather than duplicated?
- Which current Codex APIs and tool surfaces must be reverified against the
  installed version?
- Given that smaller architecture, which implementation language is the best
  fit?

The fresh PoC should begin by answering these questions, not by porting any
schema, class, transition, prompt, or test from the discarded codebase.
