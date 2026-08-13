# Final PoC Source-State Identity

**Status:** Non-recoverable cryptographic identity; no source payload retained
**Captured:** 2026-08-13

The late review ledger refers to a disposable working tree whose final files
were not identical to its Git index. The historical staged binary-diff hash in
the archive therefore identifies an earlier checkpoint, not the complete final
implementation.

This document records a deterministic root for the final Git-visible PoC source
state without retaining any code, test, prompt, fixture, dependency, or binary
bytes.

## Manifest root

- Entry count: `83`
- SHA-256:
  `1b88c37f4d78601bf42400874b68716d23f8a60f75af048817ba4b498242769e`

## Canonical construction

The root was computed in the source worktree at base commit
`e045cf1e14277c2befc78a450201a6b19b33ba40` as follows:

1. Enumerate `poc/` paths using Git's cached-plus-untracked, standard-exclusion
   view: `git ls-files --cached --others --exclude-standard -- poc`.
2. Sort paths bytewise with the C locale.
3. Require every selected path to be a regular file. The source selection had
   no symlinks.
4. Hash the current working-tree bytes of each selected path, not its index
   blob. Write one canonical line per path as lowercase SHA-256, two ASCII
   spaces, the repository-relative path, and LF.
5. SHA-256 the resulting 83-line manifest. The manifest itself was temporary
   and is not retained because its per-file hashes are not needed to recover
   learning and must not become an invitation to reconstruct the codebase.

This construction covers staged, unstaged, and untracked non-ignored source,
including the final versions of `poc/controller.py`, `poc/kernel.py`,
`poc/prototype.py`, `poc/roles/workflow-observer.md`, and
`poc/test_support.py`.

It deliberately excludes Git-ignored generated or runtime material:

- `poc/.pytest_cache/`;
- `poc/__pycache__/` and nested Python bytecode caches;
- `poc/bin/`, including the built transport binary; and
- `poc/evidence/` runtime outputs.

The ignored evidence tree was separately inspected before deletion. Selected
non-executable field projections for the live discoveries, together with the
complete original source-file hashes, are preserved in
[`LIVE_RESEARCH_EVIDENCE.md`](LIVE_RESEARCH_EVIDENCE.md). The raw JSONL,
SQLite, model-input, prompt, and runtime payloads are not retained because they
embedded portions of the abandoned implementation.

`NEW_CODEX_OPERATING_MODEL.md` lives outside `poc/` and has its own captured and
current hashes in [`README.md`](README.md). The exact Plan, hardening Plan, and
review ledger are separately retained and hashed as documentary evidence.

The root can authenticate a separately discovered candidate source tree, but it
cannot recover any deleted source bytes. That is intentional.
