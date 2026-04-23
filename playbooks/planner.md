# Planner Playbook

**Load when:** You are in plan mode, constructing a plan for review.

**Who this is for:** The main session acting as planner. Not loaded by leaf subagents.

**Prerequisites:** CLAUDE.md L1 + L2 (contracts, policies, vocabulary). Especially `contracts/plan.md` (the plan contract) and `vocabulary.md` (composition blindness, default-by-omission, sibling shapes).

---

## Plan mode protocol

A plan is an artifact with a contract: `contracts/plan.md`. The contract requires three elements — scope block, plan altitude, site list. Your job as planner is to produce a plan that conforms to the contract.

When constructing a plan, the output must include:

1. **Problem scope block** per `contracts/scope-block.md`:
   - **Problem:** one-sentence statement of the problem being solved
   - **In scope:** what this plan addresses
   - **Out of scope:** valid-but-adjacent concerns explicitly deferred
2. **The plan itself** — sequence, work breakdown, call-site decisions, dependencies — expressed at plan altitude (no implementation bodies).
3. **Site list** produced by Q1 of the plan completeness test below.
4. **Pass the plan completeness test** before presenting to the user or reviewers.

The orchestrator gate (see `playbooks/orchestrator.md` and `policies/contract-enforcement.md`) validates the plan contract before dispatch to reviewers. Your self-check is author-side compliance; the gate is the authoritative enforcement.

## Plan completeness test

A plan converts implicit decisions into explicit ones *before* code is written. Bugs cluster where a plan left a decision implicit and the implementer chose a "locally clean" default that composed into globally wrong behavior. The two failure modes — **composition blindness** and **default-by-omission** — are defined in `vocabulary.md`.

Before exiting plan mode, answer in order:

1. *What is the surface area of this change — every site that will read, write, or compose with the new behavior?*
2. *At each of those sites, have I named the required behavior?* (catches default-by-omission)
3. *At each of those sites, what existing invariants must the new behavior preserve, and have I verified each one holds?* (catches composition blindness)

Q1 produces the site list (required element of the plan contract). Q2 and Q3 audit each site against the two failure modes. If any answer is "I haven't checked," the plan is not done — regardless of how clean its top-level architecture looks.

**Size the plan to the surface area of change, not the volume of new code.** A 100-line addition that introduces state read in 12 places is a 12-decision plan, not a 100-line plan.

## Apply the completeness test on sibling shapes

Apply Q1–Q3 whenever the plan introduces any of the sibling shapes defined in `vocabulary.md` (new error types, permissions, lifecycle states, default changes, serialized fields, tightened invariants, shared-utility refactors, sync→async conversions).

## Plan altitude — authoring without code

The plan altitude shape rule is in `contracts/plan.md` (what's banned, what's allowed, default expression forms). This section is the planner-side authoring guidance.

**How to express behavior without writing code:**

- **Name the behavior in prose.** *"On startup, the service reads the checkpoint file; if absent or corrupt, it fails closed and emits a structured log at ERROR level."* The implementer picks the code shape.
- **Use pseudocode sparingly** — only when an algorithmic shape is itself the decision, and keep it to 1–5 lines with invented syntax so it reads as shape not implementation.
- **List sites, not code.** *"The checkpoint read happens at `server.go:startup`, `worker.go:resume`, `cli.go:status`. Behavior at each is: [X]."* Site lists make the decision-surface audit (Q1–Q3 above) concrete without inviting implementation.
- **Write signatures when the shape *is* the decision.** A new function signature, a schema, a state transition table — these specify what's being agreed on. Include them. Do not include the body.

**Self-check before hand-off:** scan the plan for anything that looks like a function body or multi-line logic block. If found, either (a) replace with prose describing the behavior, (b) compress to a signature if the shape itself is the decision, or (c) remove entirely and defer to code review.

When in doubt: *"would a code reviewer leave a line comment on this block?"* If yes, it's at the wrong altitude for a plan.

## Hand-off to review

Once the plan passes the completeness test, hand off to the Plan Review Flow (see `~/.claude/playbooks/orchestrator.md`). If in doubt about completeness, err toward submitting — the orchestrator gate catches shape violations and reviewers catch content gaps. But do not submit a plan that would fail Q1 (no site list). A plan without a site list violates `contracts/plan.md` and the gate will bounce it.
