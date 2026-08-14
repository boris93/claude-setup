#!/usr/bin/env bash

set -euo pipefail

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_DIR="${CODEX_HOME:-${HOME}/.codex}"
AGENT_SKILLS_DIR="${HOME}/.agents/skills"
DRY_RUN=0
CHECK_ONLY=0

usage() {
  cat <<'EOF'
Usage: install-codex.sh [--dry-run] [--check] [--help]

  --dry-run  Validate and show link changes without writing them.
  --check    Validate repository files only.
  --help     Show this help.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --check) CHECK_ONLY=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "ERROR unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

required=(
  "codex/AGENTS.md"
  "codex/agents/reviewer.toml"
  "codex/agents/verifier.toml"
)

failures=0
for item in "${required[@]}"; do
  if [[ -f "${SETUP_ROOT}/${item}" ]]; then
    echo "check ${item}"
  else
    echo "ERROR missing ${item}" >&2
    failures=$((failures + 1))
  fi
done

if (( failures > 0 )); then
  echo "validation failed: ${failures} issue(s)" >&2
  exit 1
fi

if (( CHECK_ONLY == 1 )); then
  echo "validation ok"
  exit 0
fi

changed=0
skipped=0

remove_legacy_link() {
  local target="$1"
  local old_source="$2"
  local label="$3"

  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$old_source" ]]; then
    if (( DRY_RUN == 1 )); then
      echo "would unlink legacy ${label}"
    else
      unlink "$target"
      echo "unlink legacy ${label}"
    fi
    changed=$((changed + 1))
  fi
}

for item in vocabulary.md roles agents contracts policies playbooks sidekick-prompts; do
  remove_legacy_link "${CODEX_DIR}/${item}" "${SETUP_ROOT}/${item}" "${CODEX_DIR}/${item}"
done

for skill in code-review-analyst gating-review review-convergence-analyst \
  rfc-implementation-verifier rfc-minimizer rfc-red-team rfc-reviewer \
  security-researcher ux-reviewer; do
  remove_legacy_link "${AGENT_SKILLS_DIR}/${skill}" \
    "${SETUP_ROOT}/.agents/skills/${skill}" "${AGENT_SKILLS_DIR}/${skill}"
done

if (( DRY_RUN == 0 )); then
  mkdir -p "${CODEX_DIR}/agents"
fi

link_item() {
  local source="$1"
  local target="$2"
  local label="$3"

  if [[ -L "$target" ]]; then
    if [[ "$(readlink "$target")" == "$source" ]]; then
      echo "ok    ${label}"
      return
    fi
    if (( DRY_RUN == 1 )); then
      echo "would relink ${label}"
    else
      ln -sfn "$source" "$target"
      echo "relink ${label}"
    fi
    changed=$((changed + 1))
  elif [[ -e "$target" ]]; then
    echo "WARN  ${label} is a real file; not overwriting" >&2
    skipped=$((skipped + 1))
  elif (( DRY_RUN == 1 )); then
    echo "would link ${label}"
    changed=$((changed + 1))
  else
    ln -s "$source" "$target"
    echo "link  ${label}"
    changed=$((changed + 1))
  fi
}

link_item "${SETUP_ROOT}/codex/AGENTS.md" "${CODEX_DIR}/AGENTS.md" "AGENTS.md"
link_item "${SETUP_ROOT}/codex/agents/reviewer.toml" "${CODEX_DIR}/agents/reviewer.toml" "agents/reviewer.toml"
link_item "${SETUP_ROOT}/codex/agents/verifier.toml" "${CODEX_DIR}/agents/verifier.toml" "agents/verifier.toml"

echo "changed: ${changed}  skipped: ${skipped}"
if (( skipped > 0 )); then
  exit 1
fi
