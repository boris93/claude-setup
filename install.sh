#!/usr/bin/env bash

set -euo pipefail

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
CHECK_ONLY=0

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=1
  shift
fi

if [[ $# -gt 0 ]]; then
  echo "Usage: install.sh [--check]" >&2
  exit 2
fi

required=("CLAUDE.md" "agents/reviewer.md" "agents/verifier.md")
for item in "${required[@]}"; do
  if [[ -f "${SETUP_ROOT}/${item}" ]]; then
    echo "check ${item}"
  else
    echo "ERROR missing ${item}" >&2
    exit 1
  fi
done

if (( CHECK_ONLY == 1 )); then
  echo "validation ok"
  exit 0
fi

remove_legacy_link() {
  local target="$1"
  local old_source="$2"
  local label="$3"

  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$old_source" ]]; then
    unlink "$target"
    echo "unlink legacy ${label}"
  fi
}

for item in vocabulary.md roles agents contracts policies playbooks sidekick-prompts; do
  remove_legacy_link "${CLAUDE_DIR}/${item}" "${SETUP_ROOT}/${item}" "${CLAUDE_DIR}/${item}"
done

mkdir -p "${CLAUDE_DIR}/agents"

skipped=0
link_item() {
  local source="$1"
  local target="$2"
  local label="$3"

  if [[ -L "$target" ]]; then
    if [[ "$(readlink "$target")" == "$source" ]]; then
      echo "ok    ${label}"
    else
      ln -sfn "$source" "$target"
      echo "relink ${label}"
    fi
  elif [[ -e "$target" ]]; then
    echo "WARN  ${label} is a real file; not overwriting" >&2
    skipped=$((skipped + 1))
  else
    ln -s "$source" "$target"
    echo "link  ${label}"
  fi
}

link_item "${SETUP_ROOT}/CLAUDE.md" "${CLAUDE_DIR}/CLAUDE.md" "CLAUDE.md"
link_item "${SETUP_ROOT}/agents/reviewer.md" "${CLAUDE_DIR}/agents/reviewer.md" "agents/reviewer.md"
link_item "${SETUP_ROOT}/agents/verifier.md" "${CLAUDE_DIR}/agents/verifier.md" "agents/verifier.md"

if (( skipped > 0 )); then
  exit 1
fi
