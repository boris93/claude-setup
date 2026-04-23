# Scope Block Contract

**Status:** Shared contract. The shape of the problem scope block that precedes every plan and every non-trivial code change entering review.

This file specifies the *shape*. Behavioral rules — scope-tagging obligations, scope-change requests, anti-patterns — live in `policies/scope-discipline.md`.

## Shape

```
**Problem:** One-sentence statement of the problem being solved.
**In scope:** What this change addresses.
**Out of scope:** Valid-but-adjacent concerns explicitly deferred.
```

All three lines are required. Omitting the "Out of scope" line is an incomplete scope block — that line is the YAGNI guardrail that distinguishes deferred from adjacent findings.

## Where it appears

- Opens every plan or RFC (composed into `contracts/plan.md`).
- Precedes every code change entering review (composed into `contracts/code-change.md`; synthesized from context by the orchestrator if the change was a direct dirty-tree edit without a prior plan).
- Passed verbatim to reviewers as preamble before the artifact being reviewed.

## Enforcement

The orchestrator validates scope block presence at dispatch time per `policies/contract-enforcement.md`. Reviewers consume the block to tag findings; they do not act as the primary gate.
