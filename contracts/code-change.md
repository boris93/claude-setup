# Code Change Artifact Contract

**Status:** Shared contract. The shape of a code change entering the Code Review Flow.

## Initial Required Elements

1. **Scope block** per `contracts/scope-block.md` — provided from the prior plan, or synthesized by the orchestrator from the user's original request and the diff if the change was a direct dirty-tree edit without a prior plan. A synthesized scope block is a legitimate input; the contract requires *a* scope block, not specifically a plan-derived one.
2. **Diff** — the actual code change under review.
3. **Related context** — tests, config, or documentation changes accompanying the diff; also any pertinent files the diff touches that reviewers need for judgment. If the implementation is based on an RFC or plan, include that artifact as related context.

## Accumulated Review State

4. **Review ledger** per `contracts/review-ledger.md` — maintained by the orchestrator after review begins. It is not required for initial dispatch, but becomes required input when the Code Review Flow triggers the cross-phase convergence checkpoint.

Any convergence checkpoint required by the ledger contract must be resolved or
escalated before the code-change artifact can leave review.

## Enforcement

The orchestrator enforces the initial artifact contract in Phase 1a of the Code Review Flow per `playbooks/orchestrator.md` and `policies/contract-enforcement.md`. It then maintains the review ledger as review output accumulates. Reviewers consume the artifact to produce findings; they do not re-validate the artifact's shape.
