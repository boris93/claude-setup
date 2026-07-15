# Scope Discipline Policy

**Status:** Shared policy. Governs how every role treats problem scope during plan construction, review, and synthesis.

The L1 directive ("comprehensiveness within declared scope, not license to expand") is in `CLAUDE.md`. This file is the operational detail.

## Scope-tagging obligation

Every reviewer MUST scope-tag every finding (`in-scope` / `adjacent` / `out-of-scope`) per `contracts/finding.md`. Findings without scope tags are unreliable — synthesis discards them.

Reviewers read the scope block (per `contracts/scope-block.md`) passed in as preamble; it is the anchor for tagging.

## Obligations and remedies

Architecture may discharge obligations; it does not create them. Scope binds
the required outcome or existing invariant exposed by a finding, not the
reviewer's suggested resolution or responsibilities conventionally associated
with an architectural label or familiar pattern.

A valid finding remains valid when its suggested mechanism is rejected. Before
adding or expanding durable state, authority, lifecycle, protocol, operator
surface, or general-purpose abstraction, identify the concrete omission
scenario that would violate the scoped outcome or a touched invariant. If that
trace is absent, narrow, reuse, inline, remove, or defer the mechanism instead.

When a finding exists only because the reviewed artifact introduced an optional
mechanism, challenge that mechanism before completing its implied
responsibilities.

Prefer the resolution with the least new semantic surface that preserves the
obligation. A larger site list, surface area, or work breakdown is not by itself
a scope change: if it remains inside the declared outcome, revise it and
re-review holistically. Use the scope-change or scope-architecture-collision
path below only when the load-bearing resolution crosses or alters declared
scope; do not absorb that boundary change as an implementation detail.

## Scope change requests

If a reviewer believes the scope itself is wrong — too narrow to address real risk, too broad to execute cleanly, or misaligned with the actual problem — it raises a **scope change request** as a single separate finding. This escalates to the user. The user decides whether to revise the scope block and re-review. Reviewers do not unilaterally expand scope; they request permission.

A `blocking × adjacent` finding automatically becomes a scope-change request per the routing matrix in `policies/synthesis.md`.

## Scope-architecture collisions

When the architecturally-correct fix to a stated request is larger than the request itself, the planner (or any role making the same call) faces a collision: shipping the smaller fix produces patchwork that violates design cohesion; absorbing the larger fix expands scope unilaterally. **Neither is the planner's call to make, regardless of framing (design cohesion, completeness, quality, or anything else).**

Resolution: surface the collision to the user explicitly, with:
- The minimal fix to the stated request (and the patchwork cost it incurs)
- The architecturally-correct alternative (and the size delta)
- The design-cohesion cost of accepting patchwork

The user chooses one of:
- Expand the request to the design-consistent fix
- Accept the patchwork with a tracked follow-up (captured durably as a memory entry; see `policies/synthesis.md` for capture conventions)
- Re-scope the request differently

**Trigger:** when the smallest fix to the stated request would itself be patchwork, *and* the architecturally-correct alternative materially changes the plan's site list, surface area, or work breakdown. Choices fully internal to a single plan item (naming, local structure, in-file organization) are below threshold.

**Distinction from scope-change requests:** a scope-change request says *"the declared scope is wrong"* (typically raised by a reviewer). A scope-architecture collision says *"the declared scope is right, but solving it cleanly requires going outside it"* (typically surfaced by the planner during construction).

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
