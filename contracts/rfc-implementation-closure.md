# RFC Implementation Closure Contract

**Status:** Shared contract. The shape of the final RFC-to-code closure check
run after code review convergence.

This file specifies the *shape*. Behavioral rules for when to run closure live
in `playbooks/orchestrator.md`.

## Purpose

The closure artifact verifies that the final reviewed implementation satisfies
the RFC or plan contract exactly: all required behavior is present, extra
behavior is justified, and deviations are documented before commit or PR.

It is a traceability artifact, not a second code-quality review.

## Required Inputs

1. **RFC or plan** — the original accepted artifact, including scope block,
   non-goals, acceptance criteria, API contracts, data model decisions, and
   explicit out-of-scope items.
2. **Final diff** — the current implementation after Code Review Flow fixes.
3. **Related evidence** — tests, docs, config, migrations, generated artifacts,
   and review ledger entries relevant to requirement closure.
4. **Accepted deviations** — user-approved deviations from the RFC, plus any
   review-driven fixes the orchestrator accepted as necessary to preserve an
   in-scope requirement or touched invariant. Reviewer comments alone do not
   approve product or scope drift. If none exist, state `none`.

## Trace Entry Shape

Each distinct RFC requirement, non-goal, or accepted deviation gets one entry:

- `rfc reference` — section, bullet, acceptance criterion, non-goal, or plan
  step.
- `expected behavior` — concise restatement of what the RFC requires or forbids.
- `implementation evidence` — files, tests, docs, commands, or review-ledger
  entries proving the status.
- `status` — one of:
  - `satisfied`
  - `missing`
  - `partial`
  - `extra-behavior`
  - `documented-deviation`
  - `needs-rfc-update`
  - `not-applicable`
- `notes` — optional context needed to understand the decision.

## Closure Verdict

Emit exactly one verdict:

- `closed` — all RFC requirements are satisfied, no unjustified extra behavior
  exists, and deviations are documented.
- `blocked-missing-requirement` — required RFC behavior is absent or partial.
- `blocked-scope-drift` — implementation adds behavior not justified by the RFC,
  scope block, accepted deviation, or correctness prerequisite.
- `blocked-undocumented-deviation` — implementation intentionally differs from
  the RFC but the deviation is not approved or documented.
- `needs-user-decision` — closure depends on a product or scope decision.

## Enforcement

The orchestrator ensures the required inputs are available before dispatching a
closure reviewer. The closure reviewer consumes the artifact, builds the trace,
and emits findings per `contracts/finding.md` when closure is not `closed`.
