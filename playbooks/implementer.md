# Implementer Playbook

**Load when:** You are implementing code changes or preparing to commit.

**Who this is for:** The main session acting as implementer (and, if Phase E is built, the `code-implementer` subagent). Not loaded by reviewer subagents.

**Prerequisites:** CLAUDE.md L1 + L2 (contracts, policies, vocabulary).

---

## Implementation discipline

The L1 Execution Mindset applies directly here: prefer architecturally correct approaches; don't throttle ambition to human effort estimates; raise the bar. But **within the declared scope** — the scope block from planning is your boundary, defined by `contracts/scope-block.md` and governed by `policies/scope-discipline.md`.

When implementation reveals something the plan didn't anticipate:

- **In-scope and affects the plan:** pause and re-discuss with the user (or return to planner if in a subagent).
- **Adjacent to scope:** defer per `policies/synthesis.md`. Do not absorb.
- **Pre-existing issue in the same area:** defer unless load-bearing for the current change.

Do not silently expand scope because implementation surfaced an opportunity. Scope expansion goes through the scope change request process in `policies/scope-discipline.md`.

Treat a review finding as an obligation to discharge, not as authority for its
suggested mechanism. If a substantive fix would materially expand semantic
surface or depends on an unresolved product or requirement assumption, pause
before the expanded work and return to the resolution challenge in
`playbooks/orchestrator.md`.

## Commit messages

- Don't add authoring lines (no Co-Authored-By, no "Generated with" trailers) unless the user has explicitly asked for them.
- Be succinct — one or two sentences.
- Convey the *why*, not just the *what* (the diff shows what).
- Use conventional prefixes when appropriate (add, update, fix, refactor, docs, test).

## Commit gating

Classify the complete proposed commit before choosing its gate:

1. **RFC/plan-only commit** — every changed path is a repository-backed plan or
   RFC artifact conforming to `contracts/plan.md`. There are no deletions and
   no code, configuration, generated surface, instruction, implementation
   documentation, or other artifact changes.
2. **Implementation or mixed commit** — every other diff, including a plan/RFC
   committed together with any non-plan artifact.

For an **RFC/plan-only commit**:

- Do not run any Code Review Flow phase: no `code-review-analyst`, simplification
  pass, specialist review, `codex review` gate, root-cause synthesis, or RFC
  implementation closure.
- Run ordinary non-review commit checks appropriate to the repository, such as
  inspecting the exact proposed diff and running `git diff --check`, then
  commit. A Plan Review receipt is not a commit gate.

For an **implementation or mixed commit**, complete the full Code Review Flow
defined in `~/.claude/playbooks/orchestrator.md`, then return here to create the
commit. The flow is incomplete while any convergence checkpoint in the review
ledger is `open` or `actioned`. A clean reviewer rerun does not implicitly close
the checkpoint; its diagnosis and status evidence must be recorded.

These routes are mandatory:

- If scope or time pressure tempts you to skip the applicable gate, that is a
  signal to **narrow the commit scope** (smaller diff, fewer concerns), not to
  bypass the gate.
- If a pre-commit hook fails, fix the underlying issue and create a **new** commit. Never `--amend` or `--no-verify` unless the user has explicitly requested it.
