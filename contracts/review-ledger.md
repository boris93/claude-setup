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

- `review epoch` — the counter epoch in which the finding was recorded.
- `iteration` — review loop number and phase within that epoch, for example
  `phase-3.2`.
- `source` — reviewer or tool that produced the finding.
- `severity` and `scope` — copied from the finding contract or mapped from the
  reviewer priority scale.
- `location` — file and line, subsystem, or review-output reference.
- `statement` — concise finding statement.
- `suspected surface` — module, abstraction, invariant, requirement, or user
  flow the finding appears to involve.
- `fix applied` — what changed in response, or `none` if not fixed yet.
- `lifecycle` — one of:
  - `open` — newly recorded and not yet dispositioned
  - `actioned` — a fix or other resolution was applied and required review is
    still pending
  - `resolved` — required verification or discovery evidence closed it
  - `accepted` — intentionally left without a fix under the applicable severity
    rule or an explicit user decision
  - `deferred` — routed outside the current change per synthesis policy
  - `dismissed` — rejected as malformed, out of scope, or false-positive
- `relationship` — optional evidence about how this finding relates to earlier
  entries: `repeated`, `moved`, `spawned-sibling`, or `false-positive`.
- `notes` — optional context needed to understand the pattern.

New substantive findings are recorded with lifecycle `open` before convergence
triggers are evaluated. Applying a fix changes the lifecycle to `actioned`;
only the required review evidence changes it to `resolved`. An intentional
non-fix changes it to `accepted`; routing or rejection changes it to `deferred`
or `dismissed`. Relationship labels do not close a finding and may be added at
any lifecycle state.

## Review Epochs

The ledger is cumulative, but the substantive-iteration counter is scoped to a
review epoch. Epoch 1 starts with the initial Code Review Flow. A
checkpoint resolution or escalation that returns control to review, and every
convergence-directed restart, increments the epoch and resets its counter to
zero while retaining all earlier entries as diagnosis history. A checkpoint
never resumes ordinary flow inside the epoch that triggered it.
Threshold and pattern triggers require evidence recorded in the active epoch;
historical evidence may inform diagnosis but cannot by itself immediately fire
a checkpoint in a new epoch.

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

## Convergence Checkpoints

When a trigger in `playbooks/orchestrator.md` fires, the ledger receives a
checkpoint before another review/fix iteration may begin:

- `review epoch` — active epoch when the checkpoint opened.
- `triggered at` — iteration and phase.
- `continuation` — a token preserving the interrupted obligation:
  - `phase` — `phase-1`, `phase-2-review`, or `phase-3`
  - `boundary` — `pre-fix`, `post-fix`, `pre-dispatch`, or `phase-exit`
  - `lane` — `discovery`, `verification`, `specialist`, `gating`, or `none`
  - `required next action` — the concrete fix, review dispatch, or phase-exit
    step that was pending when the checkpoint interrupted
- `trigger` — the specific threshold or pattern that fired.
- `evidence clusters` — repeated or sibling findings and the shared surface,
  invariant, requirement, or ownership boundary they implicate.
- `diagnosis` — omitted or `pending` while status is `open`; after diagnosis,
  one convergence classification from the orchestrator playbook.
- `action` — omitted or `pending` while status is `open`; after diagnosis,
  resume the continuation token, restart from Phase 1 in a new epoch after an
  architectural fix, ask the user, or extract a blocking follow-up.
- `status` — `open`, `actioned`, `resolved`, or `escalated`.
- `status evidence` — required when status is not `open`:
  - `actioned` records the user decision or architectural fix being carried
    through the required artifact, implementation, and review updates.
  - `resolved` proves either that the diagnosis requires no change
    (`no-common-root-cause` or `reviewer-noise`), that a user decision confirmed
    existing requirements without artifact or code changes, or that all
    required changes completed a restarted review flow.
  - `escalated` records the durable blocking follow-up and the user's explicit
    acknowledgment that permits the current change to proceed without it.

An `open` checkpoint represents the pre-diagnosis interrupt. Its `review epoch`,
`triggered at`, complete `continuation` token, `trigger`, `evidence clusters`,
and `status` fields are required immediately; `diagnosis`, `action`, and
`status evidence` are not yet known and may be omitted or recorded as `pending`.
Before the status changes from `open`, `diagnosis` and `action` become required,
and the new status requires its corresponding evidence above.

An `open` checkpoint is a hard gate against another ordinary review/fix
iteration. `actioned` permits only the recorded architectural fix, question,
or convergence-driven restart. Both states survive restarts and prevent commit,
PR, or RFC implementation closure; only `resolved` or `escalated` may leave the
review flow.

A user decision is not resolution evidence by itself when it changes required
behavior or scope. Such a checkpoint remains `actioned` until the scope and
accepted plan or RFC are updated, any required Plan Review Flow completes, the
implementation changes, and Code Review Flow restarts from Phase 1 and reaches
a clean Phase 3 discovery result.

## Enforcement

The orchestrator maintains the ledger. Reviewers consume ledger summaries when
asked to diagnose convergence; they do not enforce ledger completeness.
