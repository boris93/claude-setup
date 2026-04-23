#!/usr/bin/env bash
#
# Install (or refresh) claude-setup symlinks into ~/.claude.
# Idempotent — safe to re-run after pulls or structural changes.
#
# Links each expected item from this repo into ~/.claude. If the target
# already exists as a symlink (pointing anywhere), it is replaced. If the
# target exists as a real file or directory, the link is skipped with a
# warning so the user can resolve manually rather than losing local state.

set -euo pipefail

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

mkdir -p "$CLAUDE_DIR"

# Items to link from repo root into ~/.claude. Both files and directories
# use `ln -sfn` which handles either cleanly.
ITEMS=(
  "CLAUDE.md"
  "vocabulary.md"
  "agents"
  "contracts"
  "policies"
  "playbooks"
  "sidekick-prompts"
)

linked=0
relinked=0
skipped=0
missing=0

for item in "${ITEMS[@]}"; do
  src="${SETUP_ROOT}/${item}"
  dst="${CLAUDE_DIR}/${item}"

  if [[ ! -e "$src" ]]; then
    echo "skip  ${item} (not present in repo)"
    missing=$((missing + 1))
    continue
  fi

  if [[ -L "$dst" ]]; then
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      echo "ok    ${item}"
    else
      ln -sfn "$src" "$dst"
      echo "relink ${item} (was -> ${current})"
      relinked=$((relinked + 1))
    fi
  elif [[ -e "$dst" ]]; then
    echo "WARN  ${item} exists in ~/.claude as a real file/directory; not overwriting" >&2
    skipped=$((skipped + 1))
  else
    ln -sfn "$src" "$dst"
    echo "link  ${item}"
    linked=$((linked + 1))
  fi
done

echo
echo "linked: ${linked}  relinked: ${relinked}  skipped: ${skipped}  missing: ${missing}"

if (( skipped > 0 )); then
  echo
  echo "One or more targets in ~/.claude exist as real files/directories."
  echo "Remove them manually and re-run this script to complete the install."
  exit 1
fi
