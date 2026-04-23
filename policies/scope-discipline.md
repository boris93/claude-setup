# Scope Discipline Policy

**Status:** Shared policy. Governs how every role treats problem scope during plan construction, review, and synthesis.

The L1 directive ("comprehensiveness within declared scope, not license to expand") is in `CLAUDE.md`. This file is the operational detail.

## Scope-tagging obligation

Every reviewer MUST scope-tag every finding (`in-scope` / `adjacent` / `out-of-scope`) per `contracts/finding.md`. Findings without scope tags are unreliable — synthesis discards them.

Reviewers read the scope block (per `contracts/scope-block.md`) passed in as preamble; it is the anchor for tagging.

## Scope change requests

If a reviewer believes the scope itself is wrong — too narrow to address real risk, too broad to execute cleanly, or misaligned with the actual problem — it raises a **scope change request** as a single separate finding. This escalates to the user. The user decides whether to revise the scope block and re-review. Reviewers do not unilaterally expand scope; they request permission.

A `blocking × adjacent` finding automatically becomes a scope-change request per the routing matrix in `policies/synthesis.md`.

## Prohibited reviewer behaviors

Reviewers MUST NOT:
- Reclassify an `adjacent` finding as `in-scope` because it is architecturally connected.
- Expand scope by labeling adjacent work as "prerequisite" or "required for correctness."
- Generate findings that don't reference the scope block.

## Severity is not downgraded by scope

Scope governs *routing*, not *severity*. An `in-scope blocking` finding stays blocking. Scope cannot be used to mute a legitimate blocker — only to defer findings that are genuinely adjacent.

## Anti-patterns

- Leaving scope implicit ("this is obvious, we all know what we're doing") — forbidden. Declare it via the scope block contract.
- Using scope to suppress legitimate blockers by retroactively shrinking "in-scope" around them.
- Expanding scope mid-review to absorb every adjacent finding — forbidden. Either defer, or raise a scope-change request.
- Omitting the "Out of scope" line from the scope block — that line is the YAGNI guardrail.
