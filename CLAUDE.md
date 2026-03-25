# Agent Instructions

## Commit Messages
- Don't add authoring
- Should be succinct
- **Never commit without completing the full Code Review Flow first.** If the user asks to commit, run the review process before creating the commit.

## Plan Review Flow

When creating a plan in plan mode, before presenting it to the user for approval:

1. **Submit to `rfc-reviewer`** — Use the `rfc-reviewer` subagent via the Task tool to review the plan.
2. **Fix any issues** — If the reviewer surfaces blocking issues or concerns, address them in the plan.
3. **Re-review holistically** — After fixes, re-submit the *entire* plan (not just the fixes) to `rfc-reviewer` for a fresh holistic review.
4. **Iterate until clean** — Repeat steps 2–3 until no blocking issues remain.
5. **Then present to user** — Only use ExitPlanMode once the plan has passed rfc-reviewer review.

## Code Review Flow

After implementing changes, follow this multi-reviewer convergence process. Each phase loops until feedback reaches marginal utility.

**Timeout policy:** All review sub-tasks must run without timeouts. Bash-based reviewers (Gemini, Codex) must use `run_in_background: true` so they are not subject to the Bash tool's default timeout. Task-based reviewers (`code-review-analyst`) must not set `max_turns`, allowing them to run to natural completion. **Wait for completion:** Always wait for background commands to fully terminate (via notification) before reading output with `TaskOutput`. Never assume a background task has failed while it is still running.

### Phase 1: Parallel Review Loop

**1a. Trigger all reviewers simultaneously:**

**code-review-analyst** (Task agent):
- Use the `code-review-analyst` subagent via the Task tool (no `max_turns` limit)

**Gemini** (run in background):
```bash
gemini -y -p "/review uncommitted changes"
OR
gemini -y -p "/review <optional custom instruction>"
```

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

If changes touch security-sensitive areas (auth, crypto, input validation, permissions, secrets handling, network boundaries, etc.), run the `security-researcher` subagent via the Agent tool before proceeding to Phase 3.

### Phase 3: Final Gating Loop

Once prior phases have converged:

**3a. Run high-effort gating review** (run in background):
```bash
codex -s danger-full-access -c model_reasoning_effort="xhigh" -m "gpt-5.4" review --uncommitted
```
**Fallback:** Only trigger after Codex has fully terminated. If Codex fails (non-zero exit, rate limits, errors, etc.), run the gating review via the `code-review-analyst` subagent (Task tool, no `max_turns` limit) instead. Do not fall back while Codex is still running.

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
