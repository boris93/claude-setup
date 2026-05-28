---
name: gating-review
description: "Strict dirty-tree gating review. Use when Codex needs to review only the uncommitted changes in the current repository, investigate the surrounding code, and emit tightly qualified findings in the repository's gating-review JSON style."
---

<!-- Generated from sidekick-prompts/gating-review.md by scripts/generate-surfaces.py. Do not edit directly. -->

# Gating Review

## Source

Read `../../../sidekick-prompts/gating-review.md` and follow it as the source of truth. It defines the required investigation method, bug qualification criteria, priority mapping, and JSON output shape.

If the relative path is unavailable, try `${CODEX_HOME:-~/.codex}/sidekick-prompts/gating-review.md`.

## Procedure

1. Review only tracked diffs plus new untracked files requested by the source prompt.
2. Investigate call sites and data flow before reporting.
3. Flag only introduced, discrete, actionable, non-speculative bugs.
4. Use the JSON shape from the source prompt when the user asks for gating output; otherwise summarize findings in normal Codex review style.
