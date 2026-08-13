# Authoritative-Host PoC Legacy Archive

**Status:** Abandoned experiment; read-only evidence, not an active design or implementation
**Final capture:** 2026-08-13

This directory preserves the useful documentary output of the disposable
authoritative-host PoC. The implementation itself is deliberately not retained.
Future work must start from a fresh architecture and may use this archive only
to avoid rediscovering decisions, evidence, and failure patterns.

## Reading order

1. [`../../../NEW_CODEX_OPERATING_MODEL.md`](../../../NEW_CODEX_OPERATING_MODEL.md)
   is the interview-derived record of user-settled operating-model decisions.
2. [`LEGACY_LEARNINGS.md`](LEGACY_LEARNINGS.md) is the distilled handoff for a
   fresh PoC.
3. [`LIVE_RESEARCH_EVIDENCE.md`](LIVE_RESEARCH_EVIDENCE.md) preserves sanitized,
   field-level records behind the version-sensitive live discoveries without
   retaining their source payloads.
4. [`PLAN.md`](PLAN.md) is the final, unimplemented-to-closure PoC Plan. It is
   preserved as design evidence, not as the next implementation plan.
5. [`FULL_HARDENING_PLAN.md`](FULL_HARDENING_PLAN.md) preserves the earlier
   high-assurance proof direction that the project later rejected for the
   low-stakes vertical slice.
6. [`REVIEW_LEDGER.md`](REVIEW_LEDGER.md) is the complete chronological record
   of review attempts, findings, repairs, restarts, and the final open
   convergence diagnosis.
7. [`SOURCE_STATE_IDENTITY.md`](SOURCE_STATE_IDENTITY.md) records a
   non-recoverable cryptographic identity for the complete final Git-visible
   PoC source state, including unstaged and untracked files.

## Inheritance rule

- User-settled goals and invariants remain valuable inputs.
- Version-specific Codex/App Server observations are research evidence and must
  be reverified before reuse.
- The Plan's controller architecture, schemas, state machines, protocols, and
  implementation sites are not inherited.
- No Python, Go, shell, role-prompt, fixture, test, vendored dependency, binary,
  raw database, or other executable PoC artifact is retained here. The live
  evidence document contains only selected non-executable field projections.

The final implementation had passing offline tests but did not achieve review
convergence or the approved live end-to-end proof. Passing tests therefore must
not be read as validation of the architecture.

## Provenance

- Source branch: `poc/authoritative-host`
- Source base commit: `e045cf1e14277c2befc78a450201a6b19b33ba40`
- Source state: uncommitted disposable worktree; no unique implementation commit
- Historical staged binary-diff SHA-256 (identity only; this is not the final
  working-tree identity):
  `0f1249782c8ed7a24480b72c6029607c37f22ac69ed5980c5c8f99075cecbb43`
- Final Git-visible PoC source-state manifest-root SHA-256:
  `1b88c37f4d78601bf42400874b68716d23f8a60f75af048817ba4b498242769e`
- Captured pre-archive `NEW_CODEX_OPERATING_MODEL.md` SHA-256:
  `bac87a3579e47503b6de41ab1ab35d47688ebbbe2e044febd6f165141e768e89`
- Current `NEW_CODEX_OPERATING_MODEL.md` SHA-256 after recording the archival
  decision in Section 91:
  `c4dad0849070d10a6d436b41e243d9811a121a3429afc28eaab283135ead4c08`
- `PLAN.md` SHA-256:
  `e5b474fabcb8e618e103935b53ee0381a1843bb5ad5782db78e11ade7ddfef2a`
- `FULL_HARDENING_PLAN.md` SHA-256:
  `af1afe394270e43cf1bf7c69c788f9a20c1c379c3237f3e90912a2c14ff88791`
- `REVIEW_LEDGER.md` SHA-256:
  `c2d13cd274c17e7d8ca31d0f49f19fd5779080fb9e254d342fd80d17ead2681a`
- `LIVE_RESEARCH_EVIDENCE.md` SHA-256:
  `ed1a69e52077d843920114a47091e5fc52ab295178a1b37e380f9d70f71d40b9`

References to `poc/*` inside the preserved documents refer to the deleted
source worktree. They are historical anchors, not paths that should be
recreated. Historical ledger statements that raw evidence or preserved
runtimes remained available describe their then-current state; the final
archive retained only the sanitized projections in
[`LIVE_RESEARCH_EVIDENCE.md`](LIVE_RESEARCH_EVIDENCE.md).
