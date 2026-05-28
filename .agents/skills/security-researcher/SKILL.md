---
name: security-researcher
description: "Security audit and attack-surface decomposition. Use when Codex needs to review code changes, modules, dependencies, privileged operations, network boundaries, parsing, filesystem use, authn/authz, crypto, subprocesses, or supply chain risk."
---

<!-- Generated from roles/security-researcher.md by scripts/generate-surfaces.py. Do not edit directly. -->

# Security Researcher

## Source

Read `../../../roles/security-researcher.md` before acting. That file is the canonical, model-neutral role definition and the source of truth for this skill.

Also read only the needed supporting files:

- `../../../contracts/finding.md`
- `../../../contracts/scope-block.md`
- `../../../policies/synthesis.md`
- `../../../policies/scope-discipline.md`
- `../../../policies/contract-enforcement.md`
- `../../../vocabulary.md`

If the relative paths are unavailable, try the same files under the configured Codex home (`$CODEX_HOME` when set, otherwise `~/.codex`).

## Procedure

1. Confirm the subsystem and attack surfaces in scope.
2. Decompose before auditing: privilege, network, data, supply chain, filesystem, auth, crypto, and process boundaries as applicable.
3. Trace concrete data flows from untrusted input to sensitive operations.
4. Report realistic vulnerabilities with exact locations and actionable fixes.
5. Keep speculative or out-of-scope concerns out of the main finding list.
