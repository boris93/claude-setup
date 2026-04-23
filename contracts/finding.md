# Finding Contract

**Status:** Shared contract. The shape of every finding emitted by every reviewer (plan-stage or code-stage).

This file specifies the *shape*. Synthesis *behavior* — routing by severity × scope, output precedence, deferred capture — lives in `policies/synthesis.md`.

## Required tags

Each finding carries two orthogonal tags.

**Severity** — exactly one of:
- `blocking` — must resolve before proceeding. For plans: implementation cannot begin. For code: cannot ship.
- `significant` — should resolve; quality degrades if skipped.
- `acknowledged` — noted observation, not blocking. Covers accepted risks (e.g., security caveats), low-priority concerns, and improvement opportunities (e.g., UX polish). Distinct from `significant` in that no action is expected.
- `strength` — done well, worth preserving.

**Scope** — exactly one of (see `contracts/scope-block.md` for the scope block these tags reference):
- `in-scope` — within the declared problem scope
- `adjacent` — valid concern, outside current PS
- `out-of-scope` — unrelated to PS

## Required fields

- `severity` and `scope` tags (above)
- `location` — `file:line` for code; RFC section or plan step for plans
- `statement` — what is wrong / what is strong
- `scenario` — **REQUIRED** for `blocking` findings from adversarial lenses (e.g., `rfc-red-team`). Shape: trigger → propagation → impact. Without this, the finding is malformed.
- `suggested resolution` — **REQUIRED** for `blocking` and `significant`; optional elsewhere.

## Validity

A finding missing required fields is malformed. Synthesis discards malformed findings per `policies/synthesis.md`.
