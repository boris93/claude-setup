# Orchestrator Playbook

**Load when:** You are running a Plan Review Flow or Code Review Flow.

**Who this is for:** The main session acting as orchestrator of multi-reviewer flows. Not loaded by leaf subagents.

**Prerequisites:** CLAUDE.md L1 + L2 (contracts, policies, vocabulary).

The orchestrator is the **sole enforcement gate** for artifact contracts entering either review flow (see `policies/contract-enforcement.md`). Reviewers are content specialists; they trust the gate and focus on judgment.

## Delegation Model

Review flows are designed around independent reviewer roles. The orchestrator
should launch those roles when the runtime exposes and permits a
subagent/delegation mechanism. If the mechanism is unavailable or not permitted,
run the same role contracts locally and state that independence or parallelism
was degraded.

---

## Plan Review Flow

When creating a plan in plan mode, before presenting it to the user for approval. Phased structure mirrors Code Review Flow.

### Phase 1: Parallel review loop

1. **Gate: enforce the plan contract** per `contracts/plan.md`. Fix the plan yourself rather than forwarding a non-conformant artifact to reviewers:
   - **Scope block present** per `contracts/scope-block.md` (Problem / In scope / Out of scope).
   - **Plan altitude clean** — scan for code-fenced blocks containing implementation bodies (function bodies, control-flow blocks, error-handling logic). If present, compress to prose/pseudocode/signatures before submitting. Signatures, schemas, and state transitions are permitted when the shape itself is the decision.
   - **Site list present** — Q1 of the plan completeness test must have been answered. If missing, return the plan to the author before dispatch.

2. **Submit to reviewers in parallel:**
   - **Always:** Launch `rfc-reviewer` and `rfc-red-team` via the Task tool simultaneously. Each reviewer operates independently (the red-team does NOT receive the rfc-reviewer's output — prevents anchoring bias).
   - **Conditional (UI/UX plans):** If the plan touches UI/UX layers (components, layouts, flows, navigation, user-facing behavior), also launch `ux-reviewer` in the same parallel batch.
   - Pass the scope block verbatim to each reviewer as preamble.
   - **Note:** `rfc-minimizer` is NOT part of this batch — it runs in Phase 2 after convergence to avoid oscillation with `rfc-red-team` (minimizer would remove what red-team adds, red-team would re-add it next iteration).

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

8. **Aggregate Phase 1 findings.** Maintain a cumulative findings list across iterations 1..N (not just the final iteration's findings). The union is Phase 2's input — a finding raised in iteration 1, addressed by added plan content, then absent in iteration 2 still justifies that content; the minimizer needs to see it.

   **Filter to `blocking` and `significant` only** when passing to the minimizer. `acknowledged` findings document but don't require addressing per `policies/synthesis.md`; plan content added in response to them is planner-side scope inflation the minimizer is designed to catch. `strength` findings protect nothing.

### Phase 2: Minimization pass

Triggered only after Phase 1 reaches **clean convergence** — no `blocking × in-scope` findings remaining. The minimization pass audits whether plan content accumulated across iterations is still load-bearing for the original scope block.

**Skip Phase 2 (and Phase 3) and proceed directly to Phase 4 if:**
- Phase 1 hit the iteration cap with unresolved `blocking × in-scope` findings — the plan needs user revision; minimizing a plan about to change is wasted effort and muddles synthesis.
- The plan is trivial (single decision, no compositional surface) — minimization yields no useful output. Use judgment.

Otherwise:

1. **Launch `rfc-minimizer`** via Task tool. Pass three inputs:
   - The current plan (post Phase 1 convergence)
   - The original scope block (verbatim as preamble) — the minimizer's anchor
   - The aggregate Phase 1 findings (from step 8 above, already filtered to `blocking` and `significant`) — the minimizer downgrades any blocking finding whose removal would reintroduce a gap flagged by one of these

2. **Synthesize minimization findings** per `policies/synthesis.md`. All findings are subtractive by construction. Conflicting-recommendation findings (minimizer says remove, a Phase 1 finding justifies keep) surface to the user — do not auto-resolve.

3. **Minimizer fallback.** If `rfc-minimizer` fails (timeout, error, empty output, all-malformed findings), skip to Phase 4 with a note that minimization was skipped. Do not block on minimizer failure — Phase 1 already produced a sound plan.

4. **If no `blocking × in-scope` minimization findings**, skip Phase 3 and proceed to Phase 4.

### Phase 3: Verification pass (conditional)

Triggered only if Phase 2 yielded `blocking × in-scope` minimization findings.

1. **Apply minimization removals** to the plan. Adjacent-scope minimization findings route to deferred per `policies/synthesis.md` — do not apply, but capture as deferred follow-ups.

2. **Single verification re-review.** Re-launch `rfc-reviewer` and `rfc-red-team` (and `ux-reviewer` if applicable) in parallel on the minimized plan. Re-run the Phase 1 gate (step 1) before dispatch. **Max 1 verification pass; do not loop.**

3. **Synthesize verification findings:**
   - Clean (no new `blocking × in-scope`) → proceed to Phase 4.
   - New `blocking × in-scope` findings that conflict with minimization removals → surface the conflict to the user via Phase 4. Do not auto-resolve; do not re-loop. The user breaks the tie.
   - New `blocking × in-scope` findings unrelated to the removals (rare) → fix and skip back to Phase 4 directly; do not re-trigger Phase 2.

### Phase 4: Present to user

Present via ExitPlanMode. Include:

- Unified synthesis per `policies/synthesis.md` output precedence
- Deferred findings (compressed) per the same policy — including any adjacent-scope minimization findings
- Minimization removals applied (Phase 2 → 3 path)
- Any unresolved conflicting-recommendation findings from minimization vs Phase 1 reviewers — user breaks the tie
- Verification pass result (if Phase 3 ran), including any Phase 3 case (c) fix applied without re-verification — surface explicitly so the user can request a manual re-check if the change is non-trivial
- Final verdicts (per-reviewer)

---

## Code Review Flow

After implementing changes, follow this multi-reviewer convergence process. Each phase loops until feedback reaches marginal utility.

**Timeout policy:** All review sub-tasks must run without timeouts. Bash-based reviewers (Codex, Claude CLI fallback) use `run_in_background: true`. Task-based reviewers (`code-review-analyst`) must not set `max_turns`. Always wait for completion notifications before reading output — never assume a background task has failed while still running.

**Review ledger:** Maintain a cumulative review ledger per `contracts/review-ledger.md` from Phase 1 through Phase 3. Record every substantive finding, the fix applied, and whether it resolved, repeated, moved, or spawned sibling findings. This ledger is the input to convergence diagnosis; without it, the orchestrator can only patch the latest symptom.

**Substantive iteration:** A review/fix iteration is substantive when it addresses a finding that could affect correctness, security, maintainability, requirements, architecture, or user-facing behavior. Pure style nits do not count unless they reveal a broader design or ownership issue.

### Phase 1: Parallel review loop

**1a. Gate: enforce the code-change contract** per `contracts/code-change.md`, then trigger reviewer. Use `code-review-analyst` via Task tool (no `max_turns` limit). The scope block is required input:
- If the change came from a plan, use that plan's scope block verbatim.
- If the change is a direct dirty-tree edit with no prior plan, **synthesize the scope block from context** — derive Problem / In scope / Out of scope from the user's original request and the diff. A synthesized scope block is legitimate input per `contracts/code-change.md`; the contract requires *a* scope block, not specifically a plan-derived one.

Without this synthesis step the orchestrator gate fails and the flow stalls.

**1b. Synthesize and fix:**
- Classify each finding per `contracts/finding.md` (severity × scope).
- Filter false positives; identify convergent concerns.
- Add substantive findings and fixes to the review ledger.
- Present succinct summary to the user per `policies/synthesis.md` output precedence.
- Apply agreed fixes.

**1c. Re-run reviews** on updated code. Repeat from 1a. If the same substantive issue repeats after a claimed fix, mark it as `repeated` in the review ledger rather than treating it as a fresh isolated comment.

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

**3b. Address critical findings.** If P1 issues are found, add them to the review ledger, fix, and re-run. Codex path: re-run 3a. Fallback path: re-run *both* fallback step 1 and step 2 on the fix (do not retry Codex). Re-running step 2 is required because if the adversarial reviewer caught the P1, only it can verify the fix is complete — trusting step 1 alone risks landing an incomplete fix that reintroduces the same P1 in a different surface.

Before re-running, check whether Phase 3.5 is triggered. Do not keep patching the latest P1 if the ledger shows non-convergence.

**3c. Exit condition:** Stop when gating review surfaces no P1 findings. P2/P3 don't block. State exit reason.

### Phase 3.5: Convergence diagnosis checkpoint

Triggered during Phase 3 before another gating re-run when any of these are true:

- Three substantive review/fix iterations have occurred across Phases 1-3.
- A P1 repeats after a claimed fix.
- New P1s keep appearing in sibling surfaces after each fix.
- Reviewers repeatedly point at unclear requirements, missing invariants, ownership confusion, or cross-cutting behavior.
- The fix path expands across modules without reducing review severity.

This is not a hard cutoff. It is a pattern-analysis interrupt: stop asking "how do I fix this comment?" and ask "what unresolved design or requirement decision keeps producing this class of comments?"

1. **Prepare ledger summary.** Summarize the review ledger into:
   - repeated findings
   - sibling findings by surface
   - fixes that spawned new findings
   - requirement or invariant ambiguities
   - modules whose ownership or boundary changed during fixes
   - reviewer disagreements that affected fix direction

2. **Launch convergence analyst.** Launch `review-convergence-analyst` via Task tool with the original scope block, current diff summary, review ledger summary, and latest review output. If delegation is unavailable or not permitted, the orchestrator performs the same diagnosis locally and states that independence is degraded.

3. **Classify diagnosis:**
   - `no-common-root-cause` — findings are independent; continue Phase 3 and reset the substantive-iteration counter for this cluster.
   - `local-design-flaw` — an in-scope abstraction, invariant, ownership boundary, or data flow is wrong or missing.
   - `requirement-ambiguity` — product or behavior is underspecified; ask the user before more coding.
   - `scope-collision` — the architectural fix is larger than the declared scope.
   - `reviewer-noise` — comments are marginal, repeated, or false-positive enough that continuing the loop is not productive.

4. **Act on diagnosis:**
   - `no-common-root-cause` → continue Phase 3.
   - `local-design-flaw` fixable in scope → implement the architectural fix, then restart Code Review Flow from Phase 1 with the ledger carried forward.
   - `requirement-ambiguity` → pause and ask the user the smallest concrete requirement question that unblocks convergence.
   - `scope-collision` → surface the collision and ask whether to expand scope or create a blocking follow-up task.
   - `reviewer-noise` → classify remaining findings as marginal/repeats and exit Phase 3 if no P1 remains.

5. **Iteration cap:** Max 1 convergence-driven restart to Phase 1. If the restarted flow triggers Phase 3.5 again for the same cluster, escalate to the user with the ledger summary rather than continuing to loop.

### Phase 4: Root-cause synthesis

**Skip condition:** If no P1s surfaced during Phases 1-3 and Phase 3.5 did not run, skip entirely.

Review all P1 findings surfaced and fixed across Phases 1-3 plus any Phase 3.5 diagnosis. Goal: identify underlying design flaw(s) whose symptoms the review findings were and confirm whether the convergence action resolved them.

1. **Collect** — list every P1 and the fix applied.
2. **Cluster** — group P1s and Phase 3.5 evidence clusters that share a common root cause.
3. **Diagnose** — for each cluster, name the design-level flaw. Ask: *"What structural decision made this class of bug possible?"*
4. **Assess** — are fixes symptomatic patches or do they resolve the design flaw? If latent, flag as blocking concern.
5. **Act:**
   - Latent flaw fixable in this change → fix it, re-run Phase 3.
   - Fix too large → extract as **blocking follow-up task** (distinct from deferred findings per `policies/synthesis.md` — follow-ups require explicit user acknowledgment). No Phase 3 re-run needed.
   - All root causes resolved or pre-existing → proceed.
   - Present root-cause synthesis grouped by cluster in review output.

**Iteration cap:** Max 1 re-entry to Phase 3 from Phase 4. If the second Phase 3 pass yields findings Phase 4 again flags as latent, escalate to the user.

### Phase 4.5: RFC implementation closure (conditional)

Run only when the change was implemented from an RFC or plan.

This phase verifies the final reviewed implementation against the accepted RFC
contract. It is not a second code-quality review; it asks whether the final code
does exactly what the RFC asked, not more and not less.

1. **Gate: prepare closure artifact** per
   `contracts/rfc-implementation-closure.md`:
   - original RFC or plan, including scope block, non-goals, acceptance
     criteria, API/data/behavior contracts, and explicit out-of-scope items
   - final diff after Code Review Flow fixes
   - related evidence: tests, docs, config, migrations, generated artifacts, and
     relevant review-ledger entries
   - accepted deviations or review-forced correctness fixes, or `none`

2. **Launch `rfc-implementation-verifier`.** Pass the closure artifact and ask
   for one closure verdict plus a requirement-to-evidence trace. If delegation is
   unavailable or not permitted, the orchestrator performs the same closure
   check locally and states that independence was degraded.

3. **Act on closure verdict:**
   - `closed` → proceed to commit/PR.
   - `blocked-missing-requirement` or `blocked-scope-drift` → fix in scope if
     possible, then restart Code Review Flow from Phase 1 because the final code
     changed after review convergence.
   - `blocked-undocumented-deviation` → ask the user whether to approve an
     RFC/deviation update or change code back to the RFC.
   - `needs-user-decision` → pause and ask the smallest concrete scope or
     product question that unblocks closure.

4. **Iteration cap:** Max 1 closure-driven restart to Phase 1. If closure blocks
   again after the restarted review flow, escalate to the user with the trace
   summary rather than continuing to loop.

Proceed to commit/PR only after Phase 4.5 completes (or is skipped).

---

## Deferred findings during orchestration

Any `adjacent` finding surfaced in any phase routes to deferred per `policies/synthesis.md`. Batch by cluster, write to `deferred_`-prefixed memory, and surface in the synthesis under "Deferred for later." Do not let adjacent findings block progress on the current change.
