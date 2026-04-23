# Plan Artifact Contract

**Status:** Shared contract. The shape of a plan or RFC that enters the Plan Review Flow.

This file specifies the *shape*. Planner-side authoring guidance is in `playbooks/planner.md`. Orchestrator-side enforcement is in `playbooks/orchestrator.md` and `policies/contract-enforcement.md`.

## Required elements

A plan artifact has three required elements:

1. **Scope block** per `contracts/scope-block.md` — opens the plan.
2. **Plan altitude** — decisions and shapes, not implementation bodies (see below).
3. **Site list** — enumeration of every site that will read, write, or compose with the new behavior (Q1 of the plan completeness test in `playbooks/planner.md`).

## Plan altitude

Plans express **decisions and shapes**, not **implementation bodies**. A plan at plan altitude is reviewable at the decision level. A plan that drifts into implementation bodies becomes unreviewable — the user cannot see decisions for the code, and review cycles compound the bloat.

- **Banned in plans:** function bodies, control-flow blocks, error-handling logic, loops/conditionals with real logic — anything that would attract line-level code-review comments.
- **Allowed when the shape *is* the decision:** type signatures, function signatures (no body), schemas, state transitions, API/interface contracts.
- **Default expression:** prose for rationale, pseudocode for algorithmic shape (1–5 lines max, no real syntax), site lists (`file:function`) for decision-surface audits.

## Enforcement

A plan failing this contract is caught at the orchestrator gate before dispatch to reviewers (see `policies/contract-enforcement.md`). Reviewers trust the gate and focus on content review — they do not re-validate shape as their first step.
