# Plan Artifact Contract

**Status:** Shared contract. The shape of a plan or RFC that enters the Plan Review Flow.

This file specifies the *shape*. Planner-side authoring guidance is in `playbooks/planner.md`. Orchestrator-side enforcement is in `playbooks/orchestrator.md` and `policies/contract-enforcement.md`.

## Required elements

A plan artifact has three universal required elements and one conditional
element:

1. **Scope block** per `contracts/scope-block.md` — opens the plan.
2. **Plan altitude** — decisions and shapes, not implementation bodies (see below).
3. **Site list** — enumeration of every site that will read, write, or compose with the new behavior (Q1 of the plan completeness test in `playbooks/planner.md`).
4. **Temporal composition section, when triggered** — required when the plan
   changes or introduces long-lived, pausable/resumable, supersedable,
   retryable, recoverable, or concurrent behavior; separates an observable
   effect from its durable record; or coordinates multiple independently
   cancellable execution owners or authority lifecycles.

## Temporal composition section

When any trigger above applies, the section names the protocol over time at
plan altitude. It contains:

- **Transition surface** — for every applicable event in the canonical set
  below: active/stable state plus event, authority responsible, next state,
  observable effects, durable record, retry eligibility, and cleanup or
  compensation. Mark an event not applicable only with a rationale.
- **Effect ordering** — ordering between externally visible effects and durable
  state, including the behavior when only one succeeds.
- **Execution ownership** — lifetime and cancellation or supersession behavior
  for tasks, contexts, goroutines, leases, streams, or equivalent execution
  units introduced or changed by the plan.
- **Concurrency constraints** — allowed overlap, serialization or lock-order
  invariants, and which authority boundaries must not be crossed while holding
  mutually blocking resources. Name the invariant, not implementation bodies.
- **Adversarial composition cases** — the event combinations that tests must
  deliberately exercise; a generic race test is not a substitute.

### Canonical temporal events

This is the single normative event set for temporal-composition coverage:

- start or activation
- normal completion or commit
- abnormal failure or fault before any externally visible effect or durable
  partial completion
- pause or suspension
- resume or reacquisition
- cancellation, interruption, or abort
- supersession, handoff, or lease/owner change
- retry or replay
- restart or recovery
- rollback or compensation
- partial completion or one-sided effect/persistence success
- concurrent overlap or reordering

Planner and reviewer checklists reference this set rather than maintaining
parallel exhaustive lists. Reviewer-local examples are non-normative scenario
prompts.

If the section spans multiple independently testable lifecycle or authority
clusters, the plan must either name the single shared protocol invariant that
justifies one plan or split the work into a parent protocol decision and bounded
child plans.

## Plan altitude

Plans express **decisions and shapes**, not **implementation bodies**. A plan at plan altitude is reviewable at the decision level. A plan that drifts into implementation bodies becomes unreviewable — the user cannot see decisions for the code, and review cycles compound the bloat.

- **Banned in plans:** function bodies, control-flow blocks, error-handling logic, loops/conditionals with real logic — anything that would attract line-level code-review comments.
- **Allowed when the shape *is* the decision:** type signatures, function signatures (no body), schemas, state transitions, API/interface contracts.
- **Default expression:** prose for rationale, pseudocode for algorithmic shape (1–5 lines max, no real syntax), site lists (`file:function`) for decision-surface audits.

## Enforcement

A plan failing this contract is caught at the orchestrator gate before dispatch to reviewers (see `policies/contract-enforcement.md`). Reviewers trust the gate and focus on content review — they do not re-validate shape as their first step.
