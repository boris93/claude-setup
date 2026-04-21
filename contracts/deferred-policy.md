# Deferred Findings Policy

**Status:** Shared contract. Applies to both plan-review and code-review flows. Generalizes what was previously only the Code Review Flow's deferred policy.

## Principle

Valid findings outside the declared problem scope are not dropped, not silently accepted, and not absorbed into the current change. They are **deferred** — captured durably and surfaced to the user at synthesis time.

## What gets deferred

- `adjacent` findings at `significant` or `acknowledged` severity
- `out-of-scope` findings only if the reviewer explicitly flags them as valuable for future work

## What does NOT get deferred

- `blocking × in-scope` — blocks by definition
- `blocking × adjacent` — **escalates as a scope-change request** per `scope-protocol.md`. A blocker outside scope is not a deferral candidate; it signals the scope itself may be wrong. The user decides whether to revise scope (and re-review) or explicitly accept the risk.

## Capture mechanism

Deferred findings are batched into `deferred_`-prefixed memory entries.

- One memory entry per related cluster, not per finding
- Include scenario, impact, and suggested resolution
- Link back to the originating change (commit SHA, PR link, or RFC path) for context
- Keep the entry concise — a hook for future work, not a full writeup

## Surfacing to user

Every synthesis that produced deferred findings MUST include a **"Deferred for later"** section:
- List concisely (one line per cluster with link to memory entry)
- Grouped by cluster when multiple findings share a root
- No severity classification within the deferred section — they are all "out of current scope"

The user sees the deferred list at synthesis time, not discovered later in memory.

## Distinction from follow-up tasks

Follow-up tasks (Code Review Flow Phase 4 root-cause synthesis) are **distinct from deferred findings**:

| Type | Blocks current change? | Requires user ack? | Captured where |
|------|------------------------|--------------------|----------------| 
| Deferred finding | No | No (just surfaced) | `deferred_` memory |
| Follow-up task | Until acknowledged | Yes | Presented inline, user decides |

Use the correct category. A latent design flaw surfaced during root-cause synthesis is a follow-up task, not a deferred finding — the distinction is that follow-ups require user acknowledgment before proceeding, deferred findings do not.

## What this policy does NOT do

- Does not permit deferring `in-scope blocking` findings (scope protocol prevents scope from shrinking to skip a blocker)
- Does not permit deferring P1/critical findings in the current diff (P1 in current change is always in-scope by severity rule)
- Does not eliminate the need for future work tracking — deferred entries should be surfaced periodically as backlog
