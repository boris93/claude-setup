# Review Ledger Contract

**Status:** Shared contract. The shape of cumulative review history used by the
Code Review Flow convergence checkpoint.

This file specifies the *shape*. Behavioral rules for when to trigger
convergence diagnosis live in `playbooks/orchestrator.md`.

## Purpose

The review ledger prevents code review loops from treating repeated findings as
isolated comments. It records enough history to distinguish independent bugs
from symptoms of an unresolved architectural, requirement, ownership, or
invariant problem.

## Required Scope

Every ledger is anchored to the same scope block used for the code change under
review.

## Entry Shape

Each substantive review finding receives one entry:

- `iteration` — review loop number and phase, for example `phase-3.2`.
- `source` — reviewer or tool that produced the finding.
- `severity` and `scope` — copied from the finding contract or mapped from the
  reviewer priority scale.
- `location` — file and line, subsystem, or review-output reference.
- `statement` — concise finding statement.
- `suspected surface` — module, abstraction, invariant, requirement, or user
  flow the finding appears to involve.
- `fix applied` — what changed in response, or `none` if not fixed yet.
- `result` — one of:
  - `resolved`
  - `repeated`
  - `moved`
  - `spawned-sibling`
  - `deferred`
  - `false-positive`
- `notes` — optional context needed to understand the pattern.

## Substantive Findings

Record findings that could affect correctness, security, maintainability,
requirements, or user-facing behavior. Do not record pure style comments unless
they reveal a broader design or ownership issue.

## Pattern Summary Shape

When invoking convergence diagnosis, pass a compact summary derived from the
ledger:

- repeated findings
- sibling findings by surface
- fixes that spawned new findings
- requirement or invariant ambiguities
- modules whose ownership or boundary changed during fixes
- reviewer disagreements that affected fix direction

## Enforcement

The orchestrator maintains the ledger. Reviewers consume ledger summaries when
asked to diagnose convergence; they do not enforce ledger completeness.
