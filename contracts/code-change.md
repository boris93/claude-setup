# Code Change Artifact Contract

**Status:** Shared contract. The shape of a code change entering the Code Review Flow.

## Required elements

1. **Scope block** per `contracts/scope-block.md` — provided from the prior plan, or synthesized by the orchestrator from the user's original request and the diff if the change was a direct dirty-tree edit without a prior plan. A synthesized scope block is a legitimate input; the contract requires *a* scope block, not specifically a plan-derived one.
2. **Diff** — the actual code change under review.
3. **Related context** — tests, config, or documentation changes accompanying the diff; also any pertinent files the diff touches that reviewers need for judgment.

## Enforcement

The orchestrator enforces this contract in Phase 1a of the Code Review Flow per `playbooks/orchestrator.md` and `policies/contract-enforcement.md`. Reviewers consume the artifact to produce findings; they do not re-validate the artifact's shape.
