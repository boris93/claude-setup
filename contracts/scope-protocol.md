# Scope Protocol

**Status:** Shared contract. Every plan, every non-trivial code change, and every review is governed by an explicit problem scope declared up front. Reviewers tag findings against this scope.

## Scope declaration

Every plan and every non-trivial code change opens with a **problem scope block**:

```
**Problem:** One-sentence statement of the problem being solved.
**In scope:** What this change addresses.
**Out of scope:** Valid-but-adjacent concerns explicitly deferred.
```

This block is the contract. It is passed verbatim to every reviewer as preamble, before the artifact being reviewed.

## Reviewer obligations

Every reviewer MUST:
1. Read the scope block before producing findings.
2. Scope-tag every finding (`in-scope` / `adjacent` / `out-of-scope`) per `finding-schema.md`.
3. If the scope block is missing, the reviewer's first and only output is a **scope request** — not findings. Findings without a scope anchor are unreliable.

Reviewers MUST NOT:
- Reclassify an `adjacent` finding as `in-scope` because it is architecturally connected.
- Generate findings that don't reference the scope block.
- Expand scope by labeling adjacent work as "prerequisite" or "required for correctness."

## Synthesis routing

Synthesis applies the routing matrix from `finding-schema.md`:
- `in-scope blocking` → address in current change
- `in-scope significant` → address unless user defers
- `adjacent` (any severity) → route to deferred per `deferred-policy.md`
- `out-of-scope` → discard (with note if valuable)

## Scope change requests

If a reviewer believes the scope itself is wrong — too narrow to address real risk, too broad to execute cleanly, or misaligned with the actual problem — it raises a **scope change request** as a single separate finding. This escalates to the user. The user decides whether to revise the scope block and re-review. Reviewers do not unilaterally expand scope; they request permission.

## Severity is not downgraded by scope

Scope governs *routing*, not *severity*. An `in-scope blocking` finding stays blocking. Scope cannot be used to mute a legitimate blocker — only to defer findings that are genuinely adjacent.

## Anti-patterns

- Leaving scope implicit ("this is obvious, we all know what we're doing") — forbidden. Declare it.
- Using scope to suppress legitimate blockers by retroactively shrinking "in-scope" around them.
- Expanding scope mid-review to absorb every adjacent finding — forbidden. Either defer, or go through the scope change process.
- Omitting the "Out of scope" line — this line is the YAGNI guardrail. Without it, reviewers cannot distinguish deferred from adjacent.
