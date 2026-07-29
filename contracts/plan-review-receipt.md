# Plan Review Closure Receipt Contract

**Status:** Shared contract. The repo-local sidecar that records terminal Plan
Review closure for a repository-backed plan or RFC.

## Purpose

A current `green` receipt records that the plan or RFC already completed the
Plan Review Flow at the current repository HEAD. It prevents a fresh session or
compaction from reopening the same unchanged artifact.

The receipt is only a local Plan Review optimization hint. It is not review
history, a tracked project artifact, commit authorization, or evidence that an
implementation satisfies the plan. Commit routing never depends on it.

## Location

For a plan or RFC at `<artifact-path>` relative to the repository root, write:

```text
.review-receipts/<artifact-path>.json
```

For example, `docs/rfcs/recovery.md` maps to
`.review-receipts/docs/rfcs/recovery.md.json`.

The `.review-receipts/` directory must be ignored by the repository and must
never enter the commit. If the repository does not already ignore it, add
`.review-receipts/` to the local exclude file resolved by
`git rev-parse --git-path info/exclude` before writing a receipt. Do not modify
a tracked ignore file solely to create a receipt; a project may adopt the
ignore rule separately.

## Shape

```json
{
  "schema_version": 1,
  "artifact_path": "docs/rfcs/recovery.md",
  "artifact_sha256": "<lowercase SHA-256 of the exact artifact bytes>",
  "reviewed_head": "<full Git commit ID at Plan Review closure>",
  "verdict": "green",
  "closed_at": "<RFC 3339 timestamp>"
}
```

All fields are required. `artifact_path` is repository-relative and must not
escape the repository. `verdict` has one valid value: `green`. Non-green review
states do not produce a receipt.

## Issuance

Only the Plan Review orchestrator writes or replaces a receipt, and only after
the applicable Plan Review phases complete with:

- no unresolved `blocking × in-scope` finding;
- no pending user decision or minimization conflict; and
- the final artifact saved at `artifact_path`.

The receipt records the Plan Review Flow's existing terminal verdict; it does
not redefine that verdict. Compute `artifact_sha256` after the final artifact
write and record the current `HEAD` as `reviewed_head`. Do not copy findings,
review iterations, reviewer transcripts, or convergence state into the receipt.

## Currentness and invalidation

A receipt is current for another Plan Review decision only when:

- its `artifact_path` identifies the artifact being considered;
- its `verdict` is `green`; and
- hashing the artifact's current exact bytes produces `artifact_sha256`; and
- the repository's current `HEAD` equals `reviewed_head`.

Any artifact edit or `HEAD` change makes the receipt stale automatically. A
missing, malformed, or stale receipt provides no Plan Review shortcut and must
not be repaired by changing its fields without completing Plan Review on the
current artifact and repository HEAD.

A current receipt has no time-based expiry. The artifact may be reviewed again
only when it changes or the user explicitly asks for a fresh review.

When an explicit fresh Plan Review begins, the orchestrator must remove the
existing receipt before dispatching reviewers, even if the artifact bytes have
not changed. The artifact remains without closure until that fresh flow reaches
GREEN and issues a new receipt.

## Consumption

- Before starting Plan Review on a repository-backed artifact, the orchestrator
  checks for a current receipt. If one exists, it treats Plan Review as already
  closed and does not dispatch reviewers unless the user explicitly requested a
  fresh review.
- The implementer does not read the receipt. RFC/plan-only commit routing is
  defined independently in `playbooks/implementer.md`.
