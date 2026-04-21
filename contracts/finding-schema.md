# Finding Schema

**Status:** Shared contract. Every reviewer (plan-stage and code-stage) emits findings using this schema. Every synthesis consumes this schema.

## Required tags on every finding

Each finding carries two orthogonal tags plus a fixed shape.

**Severity** — exactly one of:
- `blocking` — must resolve before proceeding. For plans: implementation cannot begin. For code: cannot ship.
- `significant` — should resolve; quality degrades if skipped
- `acknowledged` — noted observation, not blocking. Covers accepted risks (e.g., security caveats), low-priority concerns, and improvement opportunities (e.g., UX polish). Distinct from `significant` in that no action is expected.
- `strength` — done well, worth preserving

**Scope** — exactly one of (see `scope-protocol.md` for the definition of scope):
- `in-scope` — within the declared problem scope
- `adjacent` — valid concern, outside current PS; routes to deferred (see `deferred-policy.md`)
- `out-of-scope` — unrelated to PS; surfaced briefly only if valuable, otherwise discarded

## Required fields on every finding

- `severity` and `scope` tags (above)
- `location` — file:line for code; RFC section or plan step for plans
- `statement` — what is wrong / what is strong
- `scenario` — REQUIRED for `blocking` findings from adversarial lenses (rfc-red-team, etc.). Shape: trigger → propagation → impact. Without this, the finding is malformed and discarded.
- `suggested resolution` — REQUIRED for `blocking` and `significant`; optional elsewhere

## Routing matrix

Synthesis aggregates findings by (severity × scope), not as a flat list.

|              | in-scope                    | adjacent                                            | out-of-scope         |
|--------------|-----------------------------|-----------------------------------------------------|----------------------|
| blocking     | fix now                     | **escalate — scope-change request** (not deferred)  | discard with note    |
| significant  | fix unless user defers      | defer per policy                                    | discard              |
| acknowledged | document                    | defer per policy                                    | discard              |
| strength     | note                        | skip                                                | skip                 |

**Special case — `blocking × adjacent`:** A blocking-severity finding outside declared scope is a signal that scope is too narrow. It does NOT defer. Instead, raise a scope-change request per `scope-protocol.md` so the user can decide whether to revise scope (and re-review) or explicitly accept the risk. Deferring a real blocker is a process bug; the matrix must force escalation.

## Output precedence when presenting to the user

Lead with the findings that demand decisions; compress the rest. In order:

1. `blocking × in-scope` — full detail, demands user decision
2. `significant × in-scope` — summarized with resolution
3. `adjacent` findings — single "Deferred for later" section, compressed
4. `out-of-scope` — one-line summary ("N off-topic observations dropped") unless individually valuable
5. `strength × in-scope` — brief, at the end

This precedence exists to enforce altitude discipline on synthesis output: decisions first, noise last.
