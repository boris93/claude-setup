# Planner Playbook

**Load when:** You are in plan mode, constructing a plan for review.

**Who this is for:** The main session acting as planner. Not loaded by leaf subagents.

**Prerequisites:** CLAUDE.md L1 + L2 contracts (especially `scope-protocol.md` and `vocabulary.md`).

---

## Plan mode protocol

When constructing a plan, the output must include:

1. **Problem scope block** (per `contracts/scope-protocol.md`):
   - **Problem:** one-sentence statement of the problem being solved
   - **In scope:** what this plan addresses
   - **Out of scope:** valid-but-adjacent concerns explicitly deferred
2. **The plan itself** — sequence, work breakdown, call-site decisions, dependencies
3. **Pass the plan completeness test** (below) before presenting to the user or reviewers

Without the scope block, reviewers will refuse to emit findings and demand one. Declare it up front.

## Plan completeness test

A plan converts implicit decisions into explicit ones *before* code is written. Bugs cluster where a plan left a decision implicit and the implementer chose a "locally clean" default that composed into globally wrong behavior. The two failure modes — **composition blindness** and **default-by-omission** — are defined in `contracts/vocabulary.md`.

Before exiting plan mode, answer in order:

1. *What is the surface area of this change — every site that will read, write, or compose with the new behavior?*
2. *At each of those sites, have I named the required behavior?* (catches default-by-omission)
3. *At each of those sites, what existing invariants must the new behavior preserve, and have I verified each one holds?* (catches composition blindness)

Q1 produces the site list. Q2 and Q3 audit each site against the two failure modes. If any answer is "I haven't checked," the plan is not done — regardless of how clean its top-level architecture looks.

**Size the plan to the surface area of change, not the volume of new code.** A 100-line addition that introduces state read in 12 places is a 12-decision plan, not a 100-line plan.

## Apply the completeness test on sibling shapes

Apply Q1–Q3 whenever the plan introduces any of the sibling shapes defined in `contracts/vocabulary.md` (new error types, permissions, lifecycle states, default changes, serialized fields, tightened invariants, shared-utility refactors, sync→async conversions).

## Hand-off to review

Once the plan passes the completeness test, hand off to the Plan Review Flow (see `~/.claude/playbooks/orchestrator.md`). If in doubt about completeness, err toward submitting — reviewers catch remaining gaps. But do not submit a plan that would fail Q1 (no site list). A plan without a site list is one the reviewers cannot meaningfully evaluate.
