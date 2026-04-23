# Shared Vocabulary

**Status:** Shared glossary. Definitions of cross-cutting concepts used across CLAUDE.md, contracts, policies, playbooks, and agent files. Definitions live here; directives that invoke these concepts live in `CLAUDE.md` L1; artifact shapes live in `contracts/`; behavioral rules live in `policies/`.

If you find a concept redefined elsewhere, fix that location to reference this file. If you find a directive, contract, or policy masquerading as vocabulary here, move it to its proper layer.

## Composition blindness

Introducing new state, invariants, permissions, error types, or lifecycle phases without auditing every existing site that reads or composes with them. Each unaudited composition is a latent bug.

*Test:* for the new thing being introduced, enumerate every existing site that observes it. Every unaudited site is a latent bug.

## Default-by-omission

Describing new code without enumerating the call sites that read it. Each unsurfaced site forces the implementer to pick a default (fail-open vs fail-closed, retry vs abort, propagate vs swallow) in the moment, under a "locally clean" bias. "Operationally clean" is the wrong prior in fail-closed, recovery, or safety-critical contexts.

*Test:* for every new code path, enumerate the call sites. Every site where behavior is not named in the plan is a default-by-omission.

## Sibling shapes

Same failure mode, different surface. When any of these are introduced, apply both composition-blindness and default-by-omission checks:

- New error types → every catch site
- New permissions → every check site
- New lifecycle states → every transition
- Default value changes → every site that relied on the old default
- New fields in serialized types → every reader/writer
- Tightened invariants → every site that previously satisfied the loose version
- Shared-utility refactors → every caller
- Sync → async conversions → every caller's error/cancellation handling

## Altitude

The abstraction level at which a conversation, response, or artifact operates. Common altitudes, from highest to lowest:

- **Strategy / PS** — what problem, should we solve it, business trade-offs
- **Architecture** — shape of solution, major components, interfaces
- **Plan** — sequence, work breakdown, dependencies
- **Implementation** — specific files, functions, tests
- **Operational** — debugging, edge cases, runtime behavior

The directive for how altitude is applied in responses is in `CLAUDE.md` L1 under **Response altitude**. The *plan* altitude applied to plan artifacts is captured as a shape rule in `contracts/plan.md`.

## Double-loop learning

A framing for responding to feedback:

- **Single-loop** — apply the specific correction.
- **Double-loop** — identify the governing assumption that produced the flawed output; revise the mental model, not just the text; propagate the revised model across the whole artifact.

*Triggers that always demand double-loop:* feedback clustering around a theme (tone, depth, audience); user rejecting a direction rather than wordsmithing.

The directive for when double-loop is required is in `CLAUDE.md` L1 under **Double-loop feedback discipline**.

## Contract vs policy vs vocabulary

A frame for deciding where a new rule lives:

- **Contract** — the shape of an *artifact* that flows between agents. Lives in `contracts/*`. Enforced at agent boundaries (see `policies/contract-enforcement.md`).
- **Policy** — a *behavioral rule* within a role, or shared across roles. Lives in `policies/*` (shared) or `playbooks/*` (role-specific) or agent files (agent-specific). Self-policed within the role.
- **Vocabulary** — a shared *definition* that neither prescribes behavior nor specifies a shape. Lives in this file. Referenced by name from every layer.

One contract typically induces policies at each role that touches the artifact (producer, gate, consumer). Contracts describe *what*; policies describe *how each role behaves with respect to the what*.

## Other cross-cutting principles

Directives authoritatively stated in `CLAUDE.md` L1 — referenced by name throughout the system:

- **Scope discipline** — comprehensiveness within declared scope, not license to expand (operational detail in `policies/scope-discipline.md`)
- **Response altitude** — match the user's altitude; signal drill-downs; compress lower detail
- **Layered abstraction (meta-principle)** — four layers (problem scope, agent structure, instruction files, conversational response) each honoring boundaries and signaling drill-down paths
- **Execution mindset** — calibrate ambition to AI execution economics
- **Plan altitude** — plans express decisions and shapes, not implementation bodies (shape rule in `contracts/plan.md`)

See `CLAUDE.md` for the authoritative directive wording.
