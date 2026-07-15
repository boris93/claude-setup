# Synthesis Policy

**Status:** Shared policy. Governs how the orchestrator aggregates, routes, and presents findings from reviewers (plan-stage or code-stage).

Inputs: findings emitted per `contracts/finding.md`. Outputs: a unified synthesis for the user plus durable deferred capture.

## Routing matrix

Aggregate findings by (severity × scope), not as a flat list.

|              | in-scope                    | adjacent                                            | out-of-scope         |
|--------------|-----------------------------|-----------------------------------------------------|----------------------|
| blocking     | resolve obligation now      | **escalate — scope-change request** (not deferred)  | discard with note    |
| significant  | resolve unless user defers  | defer                                               | discard              |
| acknowledged | document                    | defer                                               | discard              |
| strength     | note                        | skip                                                | skip                 |

**Special case — `blocking × adjacent`:** A blocking-severity finding outside declared scope signals that scope itself may be too narrow. It does NOT defer. Instead, raise a scope-change request per `policies/scope-discipline.md`. Deferring a real blocker is a process bug; the matrix forces escalation.

"Resolve obligation" applies to the finding's missing behavior or invariant,
not automatically to its suggested mechanism. Synthesis preserves the
obligation while the orchestrator selects the remedy with the least new
semantic surface per `policies/scope-discipline.md`. A familiar architectural
name does not turn its conventional responsibilities into in-scope work.

## Output precedence when presenting to the user

Lead with findings that demand decisions; compress the rest. In order:

1. `blocking × in-scope` — full detail, demands user decision
2. `significant × in-scope` — summarized with resolution
3. `adjacent` findings — single "Deferred for later" section, compressed
4. `out-of-scope` — one-line summary ("N off-topic observations dropped") unless individually valuable
5. `strength × in-scope` — brief, at the end

This precedence enforces altitude discipline on synthesis output: decisions first, noise last.

## Deferred capture

Findings routed to deferred must be captured durably so they surface for future work.

**What gets deferred:**
- `adjacent × significant` and `adjacent × acknowledged`
- `out-of-scope` findings only if the reviewer explicitly flags them as valuable for future work

**What does NOT get deferred:**
- `blocking × in-scope` — blocks by definition
- `blocking × adjacent` — escalates as a scope-change request per `policies/scope-discipline.md`

**Capture mechanism (memory entry shape):**
- One memory entry per related cluster, not per finding
- Filename prefix: `deferred_`
- Include scenario, impact, and suggested resolution
- Link back to the originating change (commit SHA, PR link, or RFC path)
- Keep concise — a hook for future work, not a full writeup

**Surfacing to user:** every synthesis that produced deferred findings MUST include a **"Deferred for later"** section in the presented output:
- One line per cluster with a link to the memory entry
- Grouped by cluster when multiple findings share a root
- No severity classification within this section — they are all "out of current scope"

## Deferred findings vs follow-up tasks

Distinct artifacts with different user expectations:

| Type | Blocks current change? | Requires user ack? | Captured where |
|------|------------------------|--------------------|----------------|
| Deferred finding | No | No (just surfaced) | `deferred_` memory |
| Follow-up task | Until acknowledged | Yes | Presented inline, user decides |

A latent design flaw surfaced during the Code Review Flow convergence checkpoint or Phase 4 root-cause synthesis is a follow-up task, not a deferred finding — the distinction is that follow-ups require explicit user acknowledgment before proceeding.

## Malformed findings

Discard findings missing required fields (e.g., adversarial `blocking` without scenario per `contracts/finding.md`). If all findings from a reviewer are malformed, treat as reviewer failure per the orchestrator's fallback policy.

## Convergent / complementary / conflicting findings

- *Convergent* (multiple reviewers flag the same concern): high confidence, single entry, note convergence.
- *Complementary* (different reviewers find different issues): both valid, address both.
- *Conflicting severity* (same concern, different severity): present both assessments with reasoning — do not unilaterally resolve.
- *Conflicting recommendation* (different reviewers propose opposite actions on the same plan element — typically `rfc-minimizer` says remove, another reviewer's finding justifies keep): present both with reasoning, surface to the user. Do not auto-resolve; do not search for a compromise. The user breaks the tie. This conflict is structural for minimizer-vs-redteam by design — minimizer removes non-load-bearing structure, red-team justifies defensive structure via scenarios.
