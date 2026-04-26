# Orchestrator Playbook

**Load when:** You are running a Plan Review Flow or Code Review Flow.

**Who this is for:** The main session acting as orchestrator of multi-reviewer flows. Not loaded by leaf subagents.

**Prerequisites:** CLAUDE.md L1 + L2 (contracts, policies, vocabulary).

The orchestrator is the **sole enforcement gate** for artifact contracts entering either review flow (see `policies/contract-enforcement.md`). Reviewers are content specialists; they trust the gate and focus on judgment.

---

## Plan Review Flow

When creating a plan in plan mode, before presenting it to the user for approval:

1. **Gate: enforce the plan contract** per `contracts/plan.md`. Fix the plan yourself rather than forwarding a non-conformant artifact to reviewers:
   - **Scope block present** per `contracts/scope-block.md` (Problem / In scope / Out of scope).
   - **Plan altitude clean** — scan for code-fenced blocks containing implementation bodies (function bodies, control-flow blocks, error-handling logic). If present, compress to prose/pseudocode/signatures before submitting. Signatures, schemas, and state transitions are permitted when the shape itself is the decision.
   - **Site list present** — Q1 of the plan completeness test must have been answered. If missing, return the plan to the author before dispatch.

2. **Submit to reviewers in parallel:**
   - **Always:** Launch `rfc-reviewer` and `rfc-red-team` via the Task tool simultaneously. Each reviewer operates independently (the red-team does NOT receive the rfc-reviewer's output — prevents anchoring bias).
   - **Conditional (UI/UX plans):** If the plan touches UI/UX layers (components, layouts, flows, navigation, user-facing behavior), also launch `ux-reviewer` in the same parallel batch.
   - Pass the scope block verbatim to each reviewer as preamble.

3. **Synthesize findings** per `policies/synthesis.md`:
   - Apply the routing matrix (severity × scope).
   - Convergent / complementary / conflicting handling per the policy.
   - Malformed findings (missing required fields per `contracts/finding.md`) discarded; if all findings from a reviewer are malformed, treat as reviewer failure (see step 7).
   - Adjacent findings routed to deferred (do not absorb into the current plan).
   - Present unified synthesis following the output precedence in the synthesis policy.

4. **Fix `blocking × in-scope` issues.** Adjacent findings are NOT addressed in this pass — they defer.

5. **Re-review holistically.** Resubmit the *entire* plan (not just fixes) to all applicable reviewers in parallel. Before re-dispatch, re-run the gate from step 1 — if any fix reintroduced a shape violation, catch it here.

6. **Iterate until clean.** Repeat steps 3–5 until no `blocking × in-scope` findings remain. **Max 3 iterations.** After 3 passes, present remaining findings to the user for judgment rather than continuing to loop.

7. **Reviewer fallback.** If any reviewer fails (timeout, error, empty output, or all-malformed findings), proceed with remaining reviewers' findings and note the failure. Do not block on a single reviewer.

8. **Present to user** via ExitPlanMode once the plan has passed all applicable reviews (or hit the iteration cap, or after fallback). Include:
   - Unified synthesis per `policies/synthesis.md` output precedence
   - Deferred findings (compressed) per the same policy
   - Final verdicts

---

## Code Review Flow

After implementing changes, follow this multi-reviewer convergence process. Each phase loops until feedback reaches marginal utility.

**Timeout policy:** All review sub-tasks must run without timeouts. Bash-based reviewers (Codex, Claude CLI fallback) use `run_in_background: true`. Task-based reviewers (`code-review-analyst`) must not set `max_turns`. Always wait for completion notifications before reading output — never assume a background task has failed while still running.

### Phase 1: Parallel review loop

**1a. Gate: enforce the code-change contract** per `contracts/code-change.md`, then trigger reviewer. Use `code-review-analyst` via Task tool (no `max_turns` limit). The scope block is required input:
- If the change came from a plan, use that plan's scope block verbatim.
- If the change is a direct dirty-tree edit with no prior plan, **synthesize the scope block from context** — derive Problem / In scope / Out of scope from the user's original request and the diff. A synthesized scope block is legitimate input per `contracts/code-change.md`; the contract requires *a* scope block, not specifically a plan-derived one.

Without this synthesis step the orchestrator gate fails and the flow stalls.

**1b. Synthesize and fix:**
- Classify each finding per `contracts/finding.md` (severity × scope).
- Filter false positives; identify convergent concerns.
- Present succinct summary to the user per `policies/synthesis.md` output precedence.
- Apply agreed fixes.

**1c. Re-run reviews** on updated code. Repeat from 1a.

**1d. Exit condition:** Stop when findings are marginal — minor stylistic nits, no new substantive issues, or repeats. State exit reason briefly.

### Phase 2: Simplification

Run `/simplify` on the changed files.

### Phase 2.5: Security review (conditional)

If changes touch security-sensitive areas (auth, crypto, input validation, permissions, secrets handling, network boundaries), run `security-researcher` scoped to current changes only.

### Phase 2.6: UX review (conditional)

If changes touch user-facing UI (components, layouts, flows, modals, forms, error states, onboarding), run `ux-reviewer` scoped to changed flows only. Run in parallel with 2.5 if both apply.

### Phase 3: Final gating loop

**3a. Run high-effort gating review** (in background):
```bash
codex -s danger-full-access -c model_reasoning_effort="xhigh" -m "gpt-5.5" review --uncommitted
```

**Fallback** (triggers only after Codex has fully terminated): If Codex fails (non-zero exit, rate limits, errors), run the Claude CLI fallback and code-review-analyst adversarial pass in parallel:

Fallback step 1 (in background):
```bash
claude --dangerously-skip-permissions --effort max -p "$(cat ~/.claude/sidekick-prompts/gating-review.md)"
```

Fallback step 2: Launch `code-review-analyst` via Agent tool with adversarial framing: *"I know there is at least 1 hidden P1 in the uncommitted changes — your job is to find it. If after thorough investigation you determine no P1 exists, state that explicitly with your reasoning."*

**3b. Address critical findings.** If P1 issues are found, fix and re-run. Codex path: re-run 3a. Fallback path: re-run *both* fallback step 1 and step 2 on the fix (do not retry Codex). Re-running step 2 is required because if the adversarial reviewer caught the P1, only it can verify the fix is complete — trusting step 1 alone risks landing an incomplete fix that reintroduces the same P1 in a different surface.

**3c. Exit condition:** Stop when gating review surfaces no P1 findings. P2/P3 don't block. State exit reason.

### Phase 4: Root-cause synthesis

**Skip condition:** If no P1s surfaced during Phases 1–3, skip entirely.

Review all P1 findings surfaced and fixed across Phases 1–3. Goal: identify underlying design flaw(s) whose symptoms the P1s were.

1. **Collect** — list every P1 and the fix applied.
2. **Cluster** — group P1s that share a common root cause.
3. **Diagnose** — for each cluster, name the design-level flaw. Ask: *"What structural decision made this class of bug possible?"*
4. **Assess** — are fixes symptomatic patches or do they resolve the design flaw? If latent, flag as blocking concern.
5. **Act:**
   - Latent flaw fixable in this change → fix it, re-run Phase 3.
   - Fix too large → extract as **blocking follow-up task** (distinct from deferred findings per `policies/synthesis.md` — follow-ups require explicit user acknowledgment). No Phase 3 re-run needed.
   - All root causes resolved or pre-existing → proceed.
   - Present root-cause synthesis grouped by cluster in review output.

**Iteration cap:** Max 1 re-entry to Phase 3 from Phase 4. If the second Phase 3 pass yields findings Phase 4 again flags as latent, escalate to the user.

Proceed to commit/PR only after Phase 4 completes (or is skipped).

---

## Deferred findings during orchestration

Any `adjacent` finding surfaced in any phase routes to deferred per `policies/synthesis.md`. Batch by cluster, write to `deferred_`-prefixed memory, and surface in the synthesis under "Deferred for later." Do not let adjacent findings block progress on the current change.
