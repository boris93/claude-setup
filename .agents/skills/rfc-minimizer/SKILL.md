---
name: rfc-minimizer
description: "Subtractive plan minimality review. Use after RFC or plan review convergence to identify non-load-bearing content, inflated site lists, premature abstraction, or defensive structure not justified by the stated scope or prior blocking findings."
---

<!-- Generated from roles/rfc-minimizer.md by scripts/generate-surfaces.py. Do not edit directly. -->

# RFC Minimizer

## Source

Read `../../../roles/rfc-minimizer.md` before acting. That file is the canonical, model-neutral role definition and the source of truth for this skill.

Also read only the needed supporting files:

- `../../../contracts/finding.md`
- `../../../contracts/scope-block.md`
- `../../../policies/synthesis.md`
- `../../../policies/scope-discipline.md`
- `../../../policies/contract-enforcement.md`
- `../../../vocabulary.md`
- `../../../contracts/plan.md`

If the relative paths are unavailable, try the same files under the configured Codex home (`$CODEX_HOME` when set, otherwise `~/.codex`).

## Procedure

1. Re-read the original scope block and use its narrowest faithful meaning.
2. Treat all findings as subtractive: remove, compress, or reclassify content.
3. Protect content required by the plan contract and the behavioral obligations or invariants established by prior blocking or significant Phase 1 findings, not necessarily the exact remedies chosen for them.
4. Do not propose alternative architectures; that belongs to $rfc-reviewer.
5. Tag every finding by severity and scope.
