# Agent Instructions

## Commit Messages
- Don't add authoring
- Should be succinct
- **Never commit without completing the full Code Review Flow first.** If the user asks to commit, run the review process before creating the commit.

## Plan Review Flow

When creating a plan in plan mode, before presenting it to the user for approval:

1. **Submit to both reviewers in parallel** — Use the Task tool to launch both `rfc-reviewer` and `rfc-red-team` simultaneously. Each reviewer operates independently (the red-team does NOT receive the rfc-reviewer's output — this prevents anchoring bias).
2. **Synthesize findings** — When both reviews complete, produce a unified synthesis:
   - *Convergent findings* (both reviewers flag the same concern): High confidence — keep as a single entry, note the convergence.
   - *Complementary findings* (different reviewers find different issues): Both valid, address both.
   - *Severity conflicts* (same concern, different severity): Present both assessments with reasoning to the user — do not unilaterally resolve.
   - *Malformed red-team findings* (lack a concrete scenario): Discard the finding. If all red-team findings are malformed, treat it as a reviewer failure and apply the single-reviewer fallback (step 6).
   - Present as a single unified synthesis grouped by: Blocking, Significant/Acknowledged (with source attribution), Strengths.
3. **Fix any issues** — Address all blocking issues and red flags from either reviewer.
4. **Re-review holistically** — After fixes, re-submit the *entire* plan (not just the fixes) to both reviewers in parallel.
5. **Iterate until clean** — Repeat steps 2–4 until no blocking issues or red flags remain from either reviewer. **Max 3 dual-reviewer iterations.** After 3 passes, present remaining findings to the user for judgment rather than continuing to loop.
6. **Single-reviewer fallback** — If one reviewer fails (timeout, error, empty output), proceed with the other's findings and note the failure. Do not block the entire flow on a single reviewer.
7. **Then present to user** — Use ExitPlanMode once the plan has passed both reviews (or the available reviewer, if one failed per step 6, or after the iteration cap per step 5). Include the unified synthesis showing: resolved issues, acknowledged risks, and final verdicts. When verdicts are clean, keep the presentation brief.

## Code Review Flow

After implementing changes, follow this multi-reviewer convergence process. Each phase loops until feedback reaches marginal utility.

**Timeout policy:** All review sub-tasks must run without timeouts. Bash-based reviewers (Codex, Claude CLI fallback) must use `run_in_background: true` so they are not subject to the Bash tool's default timeout. Task-based reviewers (`code-review-analyst`) must not set `max_turns`, allowing them to run to natural completion. **Wait for completion:** Always wait for background commands to fully terminate (via notification) before reading output with `TaskOutput`. Never assume a background task has failed while it is still running.

**Deferred findings policy:** Valid findings that fall outside the scope of the current change (pre-existing tech debt, broader architectural issues, etc.) must not be silently dropped. After Phase 3 converges, batch all such findings into a single `deferred_`-prefixed memory entry. Include the finding in the review synthesis under a "Deferred for later" heading so the user is aware. This policy does not override Phase 3b — P1/critical findings in the current diff must still be fixed before committing; only out-of-scope, non-blocking findings are deferred.

### Phase 1: Parallel Review Loop

**1a. Trigger reviewer:**

**code-review-analyst** (Task agent):
- Use the `code-review-analyst` subagent via the Task tool (no `max_turns` limit)

**1b. Synthesize and fix:**
- Evaluate validity of each finding
- Identify overlapping concerns (high confidence issues)
- Filter out false positives or stylistic noise
- Present a succinct summary to the user with actionable next steps
- Apply agreed-upon fixes

**1c. Re-run parallel reviews** on the updated code. Repeat from 1a.

**1d. Exit condition:** Stop looping when new findings are marginal — i.e., reviewers surface only minor stylistic nits, no new substantive issues, or repeat prior findings already addressed. Briefly state to the user why you're exiting the loop (e.g., "third pass surfaced only formatting nits — converged").

### Phase 2: Simplification

Run `/simplify` on the changed files.

### Phase 2.5: Security Review (conditional)

If changes touch security-sensitive areas (auth, crypto, input validation, permissions, secrets handling, network boundaries, etc.), run the `security-researcher` subagent via the Agent tool before proceeding to Phase 3. Scope the review to the current changes only (or as specifically directed) — not a generic full-codebase audit.

### Phase 2.6: UX Review (conditional)

If changes touch user-facing UI (components, layouts, flows, navigation, modals, forms, error states, onboarding, etc.), run the `ux-reviewer` subagent via the Agent tool before proceeding to Phase 3. Scope the review to the changed flows/screens only — not a full application UX audit. If both Phase 2.5 and 2.6 apply, run them in parallel.

### Phase 3: Final Gating Loop

Once prior phases have converged:

**3a. Run high-effort gating review** (run in background):
```bash
codex -s danger-full-access -c model_reasoning_effort="xhigh" -m "gpt-5.4" review --uncommitted
```
**Fallback:** Only trigger after Codex has fully terminated. If Codex fails (non-zero exit, rate limits, errors, etc.), run the fallback gating review via Claude CLI instead (run in background):
```bash
claude --dangerously-skip-permissions --effort max -p "$(cat <<'REVIEW_EOF'
Review the uncommitted changes in this repository. Begin by running `git diff HEAD` for all staged and unstaged changes to tracked files, and `git ls-files --others --exclude-standard` to list new untracked files. Read any new files in full. Review only these changes.

Classify every finding as P1 (must fix -- correctness bug, security flaw, data loss risk) or P2 (informational -- style, minor improvement). Be skeptical: if you are unsure whether something is a real bug, verify by reading the surrounding code before reporting it.

For each finding, state: file:line, severity, what is wrong, and a concrete fix.

Output nothing if the diff is clean. Do not comment on style, naming, or formatting unless it introduces a bug.
REVIEW_EOF
)"
```
Do not fall back while Codex is still running.

**3b. Address critical findings.** If any P1 (critical/high-severity) issues are found, fix them and re-run from 3a.

**3c. Exit condition:** Stop when the gating review surfaces no critical or high-severity findings. Minor/informational findings do not block. State to the user why you're exiting (e.g., "gating review clean — only informational notes remain").

Proceed to commit/PR only after Phase 3 converges.

## Feedback Processing — Double-Loop Learning

When receiving feedback on writing artifacts (RFCs, marketing copy, proposals, documentation, etc.), apply double-loop learning — don't just fix what was flagged, interrogate *why* it was flagged.

### Single-loop (necessary but insufficient)
- Apply the specific correction requested.

### Double-loop (required)
- **Surface the governing assumption** that led to the flawed output. Ask: "What belief or framing choice caused this mistake?"
- **Revise the mental model**, not just the text. If feedback says "this section is too technical for the audience," the fix isn't merely simplifying that section — it's recalibrating your audience model for the entire document.
- **Propagate the insight** across the artifact. A local fix that doesn't ripple through related sections is single-loop in disguise.
- **State the learning explicitly** to the user: briefly articulate what assumption shifted and how it changes the approach going forward.

### Practical triggers
- After receiving any substantive feedback on a writing artifact, pause before editing. Spend a reasoning step identifying the underlying model mismatch.
- When multiple rounds of feedback cluster around a theme (e.g., tone, depth, audience), treat it as a signal that a core framing assumption needs revisiting — not that individual sentences need tweaking.
- When the user rejects a direction rather than wordsmithing, that is always a double-loop signal.
