# Contract Enforcement Policy

**Status:** Shared policy. Specifies where artifact contracts are enforced and how each role relates to enforcement.

## Principle

Artifact contracts (defined in `contracts/*`) are enforced at **agent boundaries** — the dispatcher validates the artifact before it flows to the consumer. For the review pipelines, the orchestrator is the dispatcher and thus the gate.

Reviewers are content specialists. They focus on judgment ("is the idea sound?") and trust the gate for shape. This separation keeps reviewer responsibilities single-purpose and keeps shape-validation at one deterministic chokepoint instead of replicated as defensive Step 0 checks across every reviewer.

## Enforcement points

- **Plan Review Flow gate** — the orchestrator validates plan artifacts (per
  `contracts/plan.md`, which composes `contracts/scope-block.md`) before
  dispatching to RFC reviewers. When a temporal-composition trigger applies,
  the conditional section is part of the required artifact. See
  `playbooks/orchestrator.md`.
- **Plan Review closure marker** — for a repository-backed plan or RFC, the
  orchestrator issues the ignored sidecar defined by
  `contracts/plan-review-receipt.md` only after terminal GREEN closure. A
  current receipt suppresses duplicate Plan Review; it does not gate commits.
- **Code Review Flow gate** — the orchestrator validates code change artifacts (per `contracts/code-change.md`) before dispatching to code reviewers. Synthesizes the scope block from context if the change was a direct dirty-tree edit.
- **RFC implementation closure gate** — the orchestrator validates closure artifacts (per `contracts/rfc-implementation-closure.md`) before dispatching to the RFC implementation verifier.

If a contract fails at the gate, the orchestrator either:
- **Fixes the artifact** mechanically (e.g., synthesizes a missing scope block, compresses an implementation body to prose on behalf of the author when the violation is minor) — then proceeds.
- **Rejects it back to the author** (e.g., substantive altitude violation) — requests compliance, blocks review until the artifact conforms.

## Role responsibilities

- **Planner** self-checks against the plan contract before hand-off (author-side compliance). The planner is trusted but the orchestrator verifies. See `playbooks/planner.md`.
- **Implementer** classifies the proposed commit by artifact kind and requires
  either the RFC/plan-only route or the Code Review Flow. See
  `playbooks/implementer.md`.
- **Orchestrator** is the sole enforcement gate and the sole issuer of Plan
  Review closure receipts. See `playbooks/orchestrator.md`.
- **Reviewers** (rfc-reviewer, rfc-red-team, rfc-implementation-verifier, code-review-analyst, ux-reviewer, security-researcher) are content specialists. They consume artifacts, assume the gate has validated shape, and focus on content review. Their output complies with `contracts/finding.md`.

## Reviewer defensive behavior (defense in depth, not primary enforcement)

If a reviewer is invoked with an artifact that violates a contract (rare — indicates the orchestrator bypassed enforcement), the reviewer may flag the violation as a malformed-input complaint and decline to produce findings. This is defense-in-depth, not the primary enforcement mechanism. Reviewers should not build elaborate shape-validation into their flow; the orchestrator is the designated gate.

## Rationale

Shape-validation is deterministic: either the artifact has the required fields or it doesn't. This is best done at a single chokepoint (the orchestrator) where the check can be maintained once and applied consistently. Content review is judgment-heavy and parallelizable across multiple reviewer lenses; keeping reviewers focused on judgment (not shape) makes each lens more effective.
