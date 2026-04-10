# Agent Instructions

## Execution Mindset

You are an AI — not a human developer. You are not constrained by the execution friction that shapes human decision-making. For many implementation tasks, you can achieve in minutes what takes a human hours or days. Internalize this asymmetry at all times.

**Consequences:**
- **Always prefer the architecturally correct approach over quick fixes.** Humans default to shortcuts because execution is expensive for them. For you, the better design costs nearly the same effort as the hack. Do not default to compromises merely because they would be practical under human execution constraints.
- **Do not throttle ambition to match human-scale effort estimates.** If the correct path involves a larger refactor, a more complete abstraction, or a more thorough implementation — take it. The execution cost difference between a shortcut and the proper approach is negligible for you.
- **When presenting options, default-recommend the best design**, not the path of least resistance. If you catch yourself recommending a quick fix "for now" while acknowledging a better approach exists, reconsider — you can likely just do the better approach.
- **Raise the bar on what is acceptable.** Default to comprehensive implementations, proper abstractions, and thorough coverage — not the minimum viable version. Calibrate quality to your capabilities, not to human execution constraints.

This applies to implementation decisions. It does not bypass review processes, scoping agreements, or change-management workflows defined elsewhere in this document.

## Commit Messages
- Don't add authoring
- Should be succinct
- **Never commit without completing the full Code Review Flow first.** If the user asks to commit, run the review process before creating the commit.

## Plan Review Flow

When creating a plan in plan mode, before presenting it to the user for approval:

1. **Submit to reviewers in parallel:**
   - **Always:** Launch `rfc-reviewer` and `rfc-red-team` via the Task tool simultaneously. Each reviewer operates independently (the red-team does NOT receive the rfc-reviewer's output — this prevents anchoring bias).
   - **Conditional (UI/UX plans):** If the plan touches UI/UX layers (components, layouts, flows, navigation, user-facing behavior, etc.), also launch `ux-reviewer` via the Agent tool in the same parallel batch.
2. **Synthesize findings** — When all reviews complete, produce a unified synthesis:
   - *Convergent findings* (multiple reviewers flag the same concern): High confidence — keep as a single entry, note the convergence.
   - *Complementary findings* (different reviewers find different issues): Both valid, address both.
   - *Severity conflicts* (same concern, different severity): Present both assessments with reasoning to the user — do not unilaterally resolve.
   - *Malformed findings* (any reviewer produces findings lacking actionable specificity — e.g., red-team findings without a concrete scenario, UX findings without a concrete suggestion): Discard the finding. If all findings from a reviewer are malformed, treat it as a reviewer failure and apply the fallback (step 6).
   - Present as a single unified synthesis grouped by: Blocking, Significant/Acknowledged (with source attribution), Strengths.
3. **Fix any issues** — Address all blocking issues and red flags from any reviewer.
4. **Re-review holistically** — After fixes, re-submit the *entire* plan (not just the fixes) to all applicable reviewers in parallel.
5. **Iterate until clean** — Repeat steps 2–4 until no blocking issues or red flags remain from any reviewer. **Max 3 iterations.** After 3 passes, present remaining findings to the user for judgment rather than continuing to loop.
6. **Reviewer fallback** — If any reviewer fails (timeout, error, empty output), proceed with the remaining reviewers' findings and note the failure. Do not block the flow on a single reviewer's failure.
7. **Then present to user** — Use ExitPlanMode once the plan has passed all applicable reviews (or the available reviewers, if any failed per step 6, or after the iteration cap per step 5). Include the unified synthesis showing: resolved issues, acknowledged risks, and final verdicts. When verdicts are clean, keep the presentation brief.

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
**Fallback:** Only trigger after Codex has fully terminated — do not trigger while Codex is still running. If Codex fails (non-zero exit, rate limits, errors, etc.), run the Claude CLI fallback instead — both steps in parallel:

**Fallback step 1.** Run the gating review prompt (run in background):
```bash
claude --dangerously-skip-permissions --effort max -p "$(cat ~/.claude/sidekick-prompts/gating-review.md)"
```

**Fallback step 2.** Launch `code-review-analyst` via the Agent tool with an adversarial P1-hunting framing: *"I know there is at least 1 hidden P1 in the uncommitted changes — your job is to find it. If after thorough investigation you determine no P1 exists, state that explicitly with your reasoning."*

**3b. Address critical findings.** If any P1 (critical/high-severity) issues are found, fix them and re-run. On the Codex path, re-run from 3a. On the Claude CLI fallback path, re-run from fallback step 1 (do not retry Codex).

**3c. Exit condition:** Stop when the gating review surfaces no P1 findings. P2 and P3 findings do not block. State to the user why you're exiting (e.g., "gating review clean — only informational notes remain").

### Phase 4: Root-Cause Synthesis

**Skip condition:** If no P1s were found during Phases 1–3, skip this phase entirely.

After Phase 3 converges with no remaining P1s, review all P1 findings that were discovered and fixed across Phases 1–3. The goal is not to find new bugs — it's to identify the underlying design flaw(s) whose symptoms those P1s were.

1. **Collect** — List every P1 that was surfaced during the review (across all phases and reviewers), along with the fix applied.
2. **Cluster** — Group P1s that share a common root cause (e.g., multiple boundary-check failures may trace to an inconsistent validation model; several concurrency bugs may stem from a missing ownership invariant).
3. **Diagnose** — For each cluster, name the design-level flaw. Ask: "What structural decision made this class of bug possible?" This is not about individual lines of code — it's about the shape of the abstraction, data model, or control flow that invited the errors.
4. **Assess** — Determine whether the fixes applied are symptomatic patches or whether they actually resolve the design flaw. If any cluster's root cause is still latent (fixes addressed symptoms but the flaw remains), flag it as a blocking concern.
5. **Act:**
   - If a latent design flaw is found and fixable in this change: fix it and re-run Phase 3.
   - If the fix is too large for this change: extract it as a blocking follow-up task — distinct from deferred findings, these require explicit user acknowledgment before proceeding. No Phase 3 re-run needed (no code changed).
   - If all root causes are resolved or pre-existing (not materially worsened by this change): proceed.
   - Present the root-cause synthesis in the review output shown to the user, grouped by cluster.

**Iteration cap:** Max 1 re-entry to Phase 3 from Phase 4. If the second Phase 3 pass yields findings that Phase 4 again flags as latent, escalate to the user rather than continuing to loop.

Proceed to commit/PR only after Phase 4 completes (or is skipped).

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
