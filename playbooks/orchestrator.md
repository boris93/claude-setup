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

For a repository-backed plan or RFC, first check the repo-local sidecar defined
by `contracts/plan-review-receipt.md`. If it is current for the artifact and
repository HEAD, Plan Review is already closed: do not dispatch reviewers again
unless the user explicitly requested a fresh review. Before dispatching that
fresh review, remove the existing receipt. A missing or stale receipt enters
Phase 1 normally.

### Phase 1: Parallel review loop

1. **Gate: enforce the plan contract** per `contracts/plan.md`. Fix the plan yourself rather than forwarding a non-conformant artifact to reviewers:
   - **Scope block present** per `contracts/scope-block.md` (Problem / In scope / Out of scope).
   - **Plan altitude clean** — scan for code-fenced blocks containing implementation bodies (function bodies, control-flow blocks, error-handling logic). If present, compress to prose/pseudocode/signatures before submitting. Signatures, schemas, and state transitions are permitted when the shape itself is the decision.
   - **Site list present** — Q1 of the plan completeness test must have been answered. If missing, return the plan to the author before dispatch.
   - **Temporal composition present when triggered** — apply the triggers in
     `contracts/plan.md`. If one applies, require the transition surface,
     effect ordering, execution ownership, concurrency constraints, and
     adversarial composition cases before dispatch.

2. **Submit to reviewers in parallel:**
   - **Always:** Launch `rfc-reviewer` and `rfc-red-team` via the Task tool simultaneously. Each reviewer operates independently (the red-team does NOT receive the rfc-reviewer's output — prevents anchoring bias). This initial batch is a discovery pass: do not pass prior findings, a proposed fix, or an author-supplied root-cause conclusion.
   - **Conditional (UI/UX plans):** If the plan touches UI/UX layers (components, layouts, flows, navigation, user-facing behavior), also launch `ux-reviewer` in the same parallel batch.
   - Pass the scope block verbatim to each reviewer as preamble.
   - **Note:** `rfc-minimizer` is NOT part of this batch — it runs in Phase 2 after convergence to avoid oscillation with `rfc-red-team` (minimizer would remove what red-team adds, red-team would re-add it next iteration).

3. **Synthesize findings** per `policies/synthesis.md`:
   - Apply the routing matrix (severity × scope).
   - Convergent / complementary / conflicting handling per the policy.
   - Malformed findings (missing required fields per `contracts/finding.md`) discarded; if all findings from a reviewer are malformed, treat as reviewer failure (see step 7).
   - Adjacent findings routed to deferred (do not absorb into the current plan).
   - Present unified synthesis following the output precedence in the synthesis policy.

4. **Resolve `blocking × in-scope` obligations.** Adjacent findings are NOT
   addressed in this pass — they defer. Before editing the plan:
   - Restate the scoped outcome or touched invariant that the finding proves is
     missing. Treat the suggested resolution as advisory, not as scope
     authority.
   - If the finding exists only because of a plan-introduced mechanism, first
     test whether narrowing, reusing, inlining, or removing that mechanism
     preserves the obligation.
   - Add or expand durable state, authority, lifecycle, protocol, operator
     surface, or general-purpose abstraction only when a concrete omission
     scenario proves it load-bearing. Prefer the resolution with the least new
     semantic surface.
   - If the load-bearing remedy crosses or alters declared scope, stop and raise
     the applicable scope-change or scope-architecture-collision decision to
     the user before editing. A larger in-scope site list, surface area, or work
     breakdown is revised and re-reviewed in step 5; size alone is not a scope
     change.

5. **Re-review holistically.** Resubmit the *entire* plan (not just fixes) to all applicable reviewers in parallel. Before re-dispatch, re-run the gate from step 1 — if any fix reintroduced a shape violation, catch it here.

6. **Iterate until clean.** Repeat steps 3–5 until no `blocking × in-scope` findings remain. **Max 3 iterations.** After 3 passes, present remaining findings to the user for judgment rather than continuing to loop.

7. **Reviewer fallback.** If any reviewer fails (timeout, error, empty output, or all-malformed findings), proceed with remaining reviewers' findings and note the failure. Do not block on a single reviewer.

8. **Aggregate Phase 1 findings.** Maintain a cumulative findings list across
   iterations 1..N (not just the final iteration's findings). The union is
   Phase 2's input. Earlier findings preserve the behavioral obligations and
   invariants they established, not necessarily the exact mechanisms added to
   resolve them; the minimizer needs both the history and this distinction.

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
   - The aggregate Phase 1 findings (from step 8 above, already filtered to
     `blocking` and `significant`) — these protect the behavioral obligation or
     invariant they established, not the exact mechanism chosen to resolve it

2. **Synthesize minimization findings** per `policies/synthesis.md`. All findings are subtractive by construction. Conflicting-recommendation findings (minimizer says remove, a Phase 1 finding justifies keep) surface to the user — do not auto-resolve.

3. **Minimizer fallback.** If `rfc-minimizer` fails (timeout, error, empty output, all-malformed findings), skip to Phase 4 with a note that minimization was skipped. Do not block on minimizer failure — Phase 1 already produced a sound plan.

4. **If no `blocking × in-scope` minimization findings**, skip Phase 3 and proceed to Phase 4.

### Phase 3: Verification pass (conditional)

Triggered only if Phase 2 yielded `blocking × in-scope` minimization findings.

1. **Apply minimization without dropping obligations.** For each removal or
   narrowing, restate any Phase 1 obligation or invariant currently carried by
   that content. Apply the subtraction only together with a plan-altitude
   disposition that preserves the obligation, using the root-cut in Phase 1
   step 4 (narrow, reuse, inline, or remove the mechanism). If no smaller
   disposition can be named without reopening the gap, do not apply the
   subtraction; surface it as a conflicting recommendation for the user. If the
   load-bearing disposition crosses or alters declared scope, use the applicable
   scope-decision path before editing. A changed but still in-scope plan shape
   proceeds to the verification review. Adjacent-scope minimization
   findings route to deferred per `policies/synthesis.md` — do not apply, but
   capture as deferred follow-ups.

2. **Single verification re-review.** Re-launch `rfc-reviewer` and `rfc-red-team` (and `ux-reviewer` if applicable) in parallel on the minimized plan. Re-run the Phase 1 gate (step 1) before dispatch. **Max 1 verification pass; do not loop.**

3. **Synthesize verification findings:**
   - Clean (no new `blocking × in-scope`) → proceed to Phase 4.
   - New `blocking × in-scope` findings that conflict with minimization removals → surface the conflict to the user via Phase 4. Do not auto-resolve; do not re-loop. The user breaks the tie.
   - New `blocking × in-scope` findings unrelated to the removals (rare) → fix and skip back to Phase 4 directly; do not re-trigger Phase 2.

### Phase 4: Present to user

For a repository-backed plan or RFC, write or replace its closure receipt per
`contracts/plan-review-receipt.md` only when the final state is GREEN: all
applicable phase exit conditions are satisfied, no `blocking × in-scope`
finding remains, and no user decision or minimization conflict is pending.
Compute the artifact hash from the saved final artifact and record the current
repository HEAD. Do not issue a receipt for an unresolved, iteration-capped, or
conversational-only plan.

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

This flow does not apply to a commit whose complete diff consists only of
repository-backed plan/RFC artifacts. That commit uses the RFC/plan-only route
in `playbooks/implementer.md`; do not launch any Code Review phase for it.
Mixed commits and all other artifact kinds enter this flow normally.

**Timeout policy:** All review sub-tasks must run without timeouts. Bash-based reviewers (Codex, Claude CLI fallback) use `run_in_background: true`. Task-based reviewers (`code-review-analyst`) must not set `max_turns`. Always wait for completion notifications before reading output — never assume a background task has failed while still running.

**Review ledger:** Maintain a cumulative review ledger per
`contracts/review-ledger.md` from Phase 1 through Phase 3. Record every
substantive finding's lifecycle, any relationship to earlier findings, and the
fix and review evidence. When a resolution challenge runs, add its compact
decision note to the affected entries. The ledger is cumulative across review
epochs; the substantive-iteration counter is not. This ledger is the input to
convergence diagnosis; without it, the orchestrator can only patch the latest
symptom.

**Review context lanes:** Keep discovery, verification, and diagnosis inputs
distinct.

- **Discovery** receives the current scope block, artifact, and codebase context
  needed to reconstruct behavior. It does not receive prior findings, the
  review ledger, a proposed root cause, or the claimed fix. Initial review and
  final gating are discovery passes.
- **Verification** may receive the exact finding and claimed fix it must check.
  A clean verification result proves closure of that finding, not independent
  discovery of other failures.
- **Diagnosis and RFC closure** receive the ledger and accepted history because
  their mandates require cumulative evidence.

Never present a verification result as independent discovery. A fresh reviewer
invocation is not independent if its prompt contains the prior diagnosis.

**Substantive iteration and review epoch:** A review/fix iteration is
substantive when it addresses a finding that could affect correctness,
security, maintainability, requirements, architecture, or user-facing behavior.
This includes fixes from the conditional security and UX reviews. Pure style
nits do not count unless they reveal a broader design or ownership issue. Count
substantive fixes only within the active review epoch; retain earlier epochs in
the ledger as history, not as counter or trigger evidence for the new epoch.

### Review control model

The flow is event-driven. Apply this table in every review phase and specialist
lens; phase-specific prose supplies the reviewer and the recorded continuation,
but does not override the ordering here.

Every code-review fix also follows the obligation/remedy boundary in
`policies/scope-discipline.md`: the finding establishes missing behavior or an
invariant, while its suggested mechanism remains advisory. Prefer the least new
semantic surface that closes the demonstrated gap, and raise material scope
expansion to the user instead of absorbing it into a review fix.

Before implementing a substantive finding or related cluster, state the
candidate repair at plan altitude and its material semantic-surface delta. If a
resolution-challenge trigger in `policies/scope-discipline.md` applies, launch
`review-convergence-analyst` in `resolution-challenge` mode with the scope
block, current diff or concise change summary, latest review output, accepted
finding obligations, candidate repair or cluster, delta, and any disputed
product or requirement assumption. The challenge accepts the finding as valid
and selects one repair altitude:

- `implementation` — apply the local fix and continue the normal review flow
- `architecture` — create or update the plan, complete Plan Review, implement
  the reviewed design, then restart Code Review from Phase 1
- `product-requirement` — ask the user the smallest concrete decision question;
  update scope or plan when required, then implement and restart Phase 1

`scope-collision` is not an altitude selection. Keep the finding open and use
the existing scope-architecture-collision user decision path before changing
the plan or implementation.

Record the result as the compact resolution decision note defined by the ledger
contract. If convergence and resolution-challenge conditions are both present,
use one analyst pass to diagnose the loop and select the remaining repair
altitude, passing both the convergence ledger summary and the candidate repair,
semantic-surface delta, and disputed assumption required by the resolution
challenge. If the same finding cluster needs a second architecture or
product/requirement redirect, stop and ask the user instead of adding another
review protocol layer.

| Current state | Event | Required action | Allowed next state |
|---|---|---|---|
| reviewing | substantive findings recorded | Add each finding with lifecycle `open`, record any relationship to earlier entries, and evaluate every pattern-based convergence trigger **before applying a fix**. If a trigger fires, open a checkpoint with the pending pre-fix obligation; otherwise run any required resolution challenge, then apply the agreed fix. | checkpoint-open or fixing |
| fixing | substantive fix completed | Change the finding lifecycle to `actioned`, record the fix and the exact post-fix review obligation as a continuation token, increment the active epoch's substantive-iteration counter, and evaluate every convergence trigger **before review dispatch or phase advance**. | checkpoint-open, verification-required, or discovery-required |
| verification-required | targeted verification completes | Record whether the supplied finding closed. A clean result closes only that finding and requires a holistic discovery pass. | discovery-required |
| discovery-required | holistic discovery completes | Record new substantive findings and return to the first row, or, when findings are marginal and no checkpoint blocks progress, take the phase's normal exit. | reviewing or phase-exit |
| checkpoint-open | diagnosis completes | Record `diagnosis` and `action`; change status to `actioned`, `resolved`, or `escalated` according to the checkpoint rules. No ordinary fix or review dispatch is allowed while status remains `open`. | checkpoint-action or recorded continuation |
| checkpoint-action | recorded convergence action completes | Restart or resume only as specified by the checkpoint. `actioned` continues to block ordinary phase exit and downstream gates until its required review evidence is recorded. | phase-1 restart, recorded continuation, or checkpoint-resolved |

These transitions establish six invariants:

- Trigger evaluation happens after recording a finding and again after applying
  a substantive fix. A newly repeated or sibling finding can therefore
  interrupt before another symptom fix begins, while the iteration counter can
  interrupt immediately after a completed fix.
- Verification never establishes phase convergence. Any targeted verification
  is followed by holistic discovery before Phase 1 may exit.
- No review dispatch, phase advance, RFC implementation closure, commit, or PR
  may bypass an `open` or `actioned` checkpoint.
- The ledger persists across epochs, but a convergence-directed restart starts
  a new epoch at counter zero. Old evidence cannot fire a new checkpoint until
  new evidence in the active epoch establishes the trigger.
- A checkpoint resumes its continuation token. Diagnosis labels never erase a
  pending post-fix review obligation.
- A resolved or escalated checkpoint starts a new epoch at counter zero before
  ordinary review resumes. No checkpoint resumes inside its triggering epoch.

### Phase 1: Parallel review loop

**1a. Gate: enforce the code-change contract** per `contracts/code-change.md`, then trigger reviewer. Use `code-review-analyst` via Task tool (no `max_turns` limit). The first pass uses the discovery context lane. The scope block is required input:
- If the change came from a plan, use that plan's scope block verbatim.
- If the change is a direct dirty-tree edit with no prior plan, **synthesize the scope block from context** — derive Problem / In scope / Out of scope from the user's original request and the diff. A synthesized scope block is legitimate input per `contracts/code-change.md`; the contract requires *a* scope block, not specifically a plan-derived one.

Without this synthesis step the orchestrator gate fails and the flow stalls.

**1b. Synthesize and fix:**
- Classify each finding per `contracts/finding.md` (severity × scope).
- Filter false positives; identify convergent concerns.
- Add substantive findings to the review ledger with lifecycle `open`.
- Present succinct summary to the user per `policies/synthesis.md` output precedence.
- Follow the review control table: evaluate pattern triggers and any required
  resolution challenge before applying an agreed fix, then record each
  completed fix and perform the post-fix trigger evaluation. Before that
  evaluation, record a continuation token with phase `phase-1`, boundary
  `post-fix`, the chosen `verification` or `discovery` lane, and the exact
  required review dispatch.

**1c. Re-run reviews** on updated code. A targeted re-review may use the
verification lane, but after it completes re-run the entire applicable Phase 1
review as a discovery pass before evaluating the Phase 1 exit condition. If a
review result exposes the same substantive issue after a claimed fix, mark it
as `repeated` in the ledger and evaluate the pattern triggers before applying
another fix. All dispatches follow the review control table.

**1d. Exit condition:** Stop only after a holistic discovery pass reports
marginal findings—minor stylistic nits or no new substantive issues—and no
checkpoint blocks progress. A targeted verification result cannot satisfy this
condition. State the exit reason briefly.

### Phase 2: Simplification

Run `/simplify` on the changed files.

### Phase 2.5: Security review (conditional)

If changes touch security-sensitive areas (auth, crypto, input validation, permissions, secrets handling, network boundaries), run `security-researcher` scoped to current changes only.

### Phase 2.6: UX review (conditional)

If changes touch user-facing UI (components, layouts, flows, modals, forms, error states, onboarding), run `ux-reviewer` scoped to changed flows only. Run in parallel with 2.5 if both apply.

### Phase 2.7: Specialist review synthesis and convergence gate

Treat the applicable Phase 2.5/2.6 reviewers as one specialist-review batch for
convergence control:

1. Synthesize their findings per `policies/synthesis.md` and add substantive
   findings to the review ledger. Evaluate pattern-based convergence triggers
   and any required resolution challenge before applying an agreed fix. If a
   convergence trigger fires, open the checkpoint with a continuation token
   whose phase is `phase-2-review`, boundary is `pre-fix`, lane is `specialist`,
   and next action is the pending finding disposition.
2. When no checkpoint fires, apply agreed fixes. Record each completed
   substantive fix, increment the active epoch's counter, and record a token
   with phase `phase-2-review`, boundary `post-fix`, lane `specialist`, and next
   action `re-run the applicable specialist-review batch`. Then perform the
   post-fix trigger evaluation from the review control table.
3. Before re-running an applicable specialist reviewer after a fix, honor any
   checkpoint opened by the preceding evaluations.
4. Re-run every applicable specialist reviewer whose surface changed until its
   findings are marginal or resolved. If a re-run produces another substantive
   finding and fix, repeat steps 1-4 before advancing.
5. Before proceeding to the initial Phase 3 dispatch, evaluate the convergence
   triggers again. Do not enter Phase 3 with a fired but unopened checkpoint.

### Phase 3: Final gating loop

**3a. Before the initial and every repeated gating dispatch, honor any pending
checkpoint and evaluate convergence triggers supported by the active epoch.**
After a Phase 3 fix, the continuation token uses phase `phase-3`, boundary
`post-fix`, lane `gating`, and required next action `run Phase 3 discovery
gate`. Once the gate is clear, run high-effort gating review as a discovery pass
(in background). Do not include the review ledger, prior findings, proposed
root cause, or claimed fix in its prompt:
```bash
codex -s danger-full-access -c model_reasoning_effort="xhigh" review --uncommitted
```

Use the configured Codex model for this gate. The playbook fixes the review
effort, not a model version, so the gate follows the operator's selected model
without accumulating a stale override.

**Fallback** (triggers only after Codex has fully terminated): If Codex fails (non-zero exit, rate limits, errors), run the Claude CLI fallback and code-review-analyst adversarial pass in parallel:

Fallback step 1 (in background):
```bash
claude --dangerously-skip-permissions --effort max -p "$(cat ~/.claude/sidekick-prompts/gating-review.md)"
```

Fallback step 2: Launch `code-review-analyst` via Agent tool with adversarial framing: *"I know there is at least 1 hidden P1 in the uncommitted changes — your job is to find it. If after thorough investigation you determine no P1 exists, state that explicitly with your reasoning."*

**3b. Address critical findings.** If P1 issues are found, add them to the
review ledger and follow the review control table: evaluate pattern triggers and
any required resolution challenge before fixing, then record and evaluate again
after each substantive fix. When the checkpoint gate remains clear, re-run 3a.
Codex path: re-run 3a. Fallback path: re-run *both* fallback step 1 and step 2 on
the fix (do not retry Codex).
Re-running step 2 is required because if the adversarial reviewer caught the
P1, only it can verify the fix is complete—trusting step 1 alone risks landing
an incomplete fix that reintroduces the same P1 in a different surface.

**3c. Exit condition:** Stop when gating review surfaces no P1 findings. P2/P3 don't block. State exit reason.

### Cross-phase convergence diagnosis checkpoint

Triggered from Phase 1, the conditional specialist-review batch, or Phase 3
before another substantive review/fix iteration when active-epoch evidence
shows any of these are true:

- Three substantive review/fix iterations have occurred in the active epoch
  across Phases 1-3,
  including the conditional specialist-review batch.
- A P1 repeats after a claimed fix.
- New P1s keep appearing in sibling surfaces after each fix.
- Reviewers repeatedly point at unclear requirements, missing invariants, ownership confusion, or cross-cutting behavior.
- The fix path expands across modules without reducing review severity.

Evaluate pattern-based triggers when substantive findings are recorded, before
another fix begins. Evaluate the counter threshold and all pattern triggers
again after every substantive fix, before dispatch or phase advance. Once any
trigger fires it is a hard gate: create an `open` convergence checkpoint in the
review ledger and stop asking "how do I fix this comment?" Ask "what unresolved
design or requirement decision keeps producing this class of comments?" No
ordinary review/fix iteration may continue until the checkpoint records a
diagnosis and action.

When opening the checkpoint, record the active review epoch and a complete
continuation token per `contracts/review-ledger.md`. Construct the token from
the actual interruption boundary:

- `pre-fix` resumes the pending finding disposition or agreed fix.
- `post-fix` resumes the required verification, holistic discovery, specialist
  re-review, or gating discovery; it never resumes a phase exit.
- `pre-dispatch` resumes the exact review dispatch that was about to run.
- `phase-exit` is valid only when no fix or review obligation remains.

The checkpoint is an interrupt, not a phase jump. Unless its diagnosis requires
a new-epoch restart or user decision, control returns to this token.

1. **Prepare ledger summary.** Summarize the review ledger into:
   - repeated findings
   - sibling findings by surface
   - fixes that spawned new findings
   - requirement or invariant ambiguities
   - modules whose ownership or boundary changed during fixes
   - reviewer disagreements that affected fix direction

2. **Launch convergence analyst.** Launch `review-convergence-analyst` in
   `convergence-diagnosis` mode via Task tool with the original scope block,
   current diff summary, review ledger summary, and latest review output. If
   a resolution challenge is also pending, include its candidate repair or
   cluster, material semantic-surface delta, and any disputed product or
   requirement assumption, and require the same response to select repair
   altitude. If delegation is unavailable or not permitted, the orchestrator
   performs the same diagnosis locally and states that independence is degraded.

3. **Classify diagnosis:**
   - `no-common-root-cause` — findings are independent; begin a new review epoch
     at counter zero and resume the recorded continuation token.
   - `local-design-flaw` — an in-scope abstraction, invariant, ownership boundary, or data flow is wrong or missing.
   - `product-assumption-mismatch` — an accepted or assumed product behavior is
     producing the engineering failure class; ask the user before more coding.
   - `requirement-ambiguity` — product or behavior is underspecified; ask the user before more coding.
   - `scope-collision` — the architectural fix is larger than the declared scope.
   - `reviewer-noise` — comments are marginal, repeated, or false-positive enough that continuing the loop is not productive.

4. **Act on diagnosis:**
   - Record the diagnosis and selected action in the checkpoint before acting.
   - Apply these status rules to every user decision:
     - If the decision confirms the existing requirement and requires no scope,
       plan/RFC, or implementation change, mark the checkpoint `resolved` with
       that evidence, start a new review epoch at counter zero, and resume its
       continuation token.
     - If the decision changes required behavior or scope, mark the checkpoint
       `actioned`. Update the scope block and accepted plan/RFC, rerun Plan
       Review Flow when the accepted plan contract changed, implement the
       decision, then start a new review epoch at counter zero and restart Code
       Review Flow from Phase 1 with the ledger carried forward. Only a clean
       restarted Phase 3 discovery result may mark it `resolved`.
     - Use `escalated` only when the user explicitly accepts proceeding with a
       durable blocking follow-up. Record both the follow-up and acknowledgment
       as status evidence, then start a new review epoch at counter zero before
       resuming the continuation token or downstream flow.
   - `no-common-root-cause` → mark the checkpoint `resolved` with the cluster
     analysis, increment the review epoch, reset its counter to zero, then
     resume the recorded continuation token.
   - `local-design-flaw` fixable in scope → mark the checkpoint `actioned`.
     If the correction materially changes accepted architecture, create or
     update the plan and complete Plan Review before implementation. Apply the
     correction, then increment the review epoch, reset its counter to zero, and
     restart Code Review Flow from Phase 1 with the ledger carried forward. The
     restarted Phase 3 discovery result becomes status evidence; only then mark
     it `resolved`.
   - `product-assumption-mismatch` or `requirement-ambiguity` → keep the
     checkpoint `open`, pause, and ask the user the smallest concrete product or
     requirement question that unblocks convergence. Apply the decision status
     rules above; do not resolve merely because the user answered.
   - `scope-collision` → keep the checkpoint `open`, surface the collision, and
     ask whether to expand scope or create a blocking follow-up task. Record
     the decision, then apply the status rules above.
   - `reviewer-noise` → if the trigger evidence is established as marginal or
     false-positive and no P1 remains `open` awaiting action, mark the checkpoint
     `resolved`, increment the review epoch, reset its counter to zero, then
     resume the continuation token. A P1 that is `actioned` and awaiting its
     recorded post-fix review does not block this resume. A phase exit occurs
     only when the token boundary is `phase-exit`; any pre-fix, post-fix, or
     pre-dispatch obligation still runs.

5. **Iteration cap:** Max 1 convergence-driven restart to Phase 1. If the restarted flow triggers the convergence checkpoint again for the same cluster, escalate to the user with the ledger summary rather than continuing to loop.

6. **Exit gate:** Phase 4, RFC implementation closure, commit, and PR are
blocked while any convergence checkpoint is `open` or `actioned`.

### Phase 4: Root-cause synthesis

**Skip condition:** If no P1s surfaced during Phases 1-3 and the convergence checkpoint did not run, skip entirely.

Review all P1 findings surfaced and fixed across Phases 1-3 plus any convergence-checkpoint diagnosis. Goal: identify underlying design flaw(s) whose symptoms the review findings were and confirm whether the convergence action resolved them.

1. **Collect** — list every P1 and the fix applied.
2. **Cluster** — group P1s and convergence-checkpoint evidence clusters that share a common root cause.
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
