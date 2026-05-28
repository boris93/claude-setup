#!/usr/bin/env bash
#
# Install (or refresh) claude-setup for Codex.
#
# This keeps the Claude install path separate from Codex. It validates the
# Codex-facing files, symlinks global instructions and reference material into
# ~/.codex, and symlinks skill adapters into ~/.agents/skills where current
# Codex scans for user-installed skills.

set -euo pipefail

SETUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_DIR="${CODEX_HOME:-${HOME}/.codex}"
AGENTS_SKILLS_DIR="${HOME}/.agents/skills"
DRY_RUN=0
CHECK_ONLY=0

usage() {
  cat <<'EOF'
Usage: install-codex.sh [--dry-run] [--check] [--help]

Install or refresh this setup for Codex.

  --dry-run   Validate and print the links that would be created or refreshed.
  --check     Validate the repo's Codex-facing files without changing targets.
  --help      Show this help.

Targets:
  ${CODEX_HOME:-$HOME/.codex}/AGENTS.md
  ${CODEX_HOME:-$HOME/.codex}/{roles,agents,contracts,policies,playbooks,...}
  $HOME/.agents/skills/*
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      ;;
    --check)
      CHECK_ONLY=1
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

failures=0

require_path() {
  local path="$1"
  local label="$2"

  if [[ -e "$path" ]]; then
    echo "check ${label}"
  else
    echo "ERROR missing ${label}: ${path}" >&2
    failures=$((failures + 1))
  fi
}

validate_skill() {
  local skill_dir="$1"
  local skill_name
  skill_name="$(basename "$skill_dir")"
  local skill_md="${skill_dir}/SKILL.md"
  local metadata="${skill_dir}/agents/openai.yaml"

  require_path "$skill_md" ".agents/skills/${skill_name}/SKILL.md"
  require_path "$metadata" ".agents/skills/${skill_name}/agents/openai.yaml"

  if [[ -f "$skill_md" ]]; then
    if ! grep -q '^---$' "$skill_md"; then
      echo "ERROR ${skill_md} is missing YAML frontmatter delimiters" >&2
      failures=$((failures + 1))
    fi
    if ! grep -q "^name: ${skill_name}$" "$skill_md"; then
      echo "ERROR ${skill_md} must declare name: ${skill_name}" >&2
      failures=$((failures + 1))
    fi
    if ! grep -q '^description: .' "$skill_md"; then
      echo "ERROR ${skill_md} must declare a non-empty description" >&2
      failures=$((failures + 1))
    fi
    if grep -q 'TODO' "$skill_md"; then
      echo "ERROR ${skill_md} still contains TODO text" >&2
      failures=$((failures + 1))
    fi
  fi

  if [[ -f "$metadata" ]] && ! grep -Fq "Use \$${skill_name}" "$metadata"; then
    echo "ERROR ${metadata} default_prompt should mention \\$${skill_name}" >&2
    failures=$((failures + 1))
  fi
}

validate_repo() {
  if [[ -f "${SETUP_ROOT}/scripts/generate-surfaces.py" ]]; then
    if ! command -v python3 >/dev/null 2>&1; then
      echo "ERROR python3 is required to validate generated Codex surfaces" >&2
      failures=$((failures + 1))
    elif ! python3 "${SETUP_ROOT}/scripts/generate-surfaces.py" --check; then
      failures=$((failures + 1))
    fi
  else
    echo "ERROR missing scripts/generate-surfaces.py" >&2
    failures=$((failures + 1))
  fi

  require_path "${SETUP_ROOT}/AGENTS.md" "AGENTS.md"
  require_path "${SETUP_ROOT}/codex/AGENTS.md" "codex/AGENTS.md"
  require_path "${SETUP_ROOT}/vocabulary.md" "vocabulary.md"
  require_path "${SETUP_ROOT}/roles" "roles/"
  require_path "${SETUP_ROOT}/agents" "agents/"
  require_path "${SETUP_ROOT}/contracts" "contracts/"
  require_path "${SETUP_ROOT}/policies" "policies/"
  require_path "${SETUP_ROOT}/playbooks" "playbooks/"
  require_path "${SETUP_ROOT}/sidekick-prompts" "sidekick-prompts/"
  require_path "${SETUP_ROOT}/.agents/skills" ".agents/skills/"

  local skill_count=0
  if [[ -d "${SETUP_ROOT}/.agents/skills" ]]; then
    for skill_dir in "${SETUP_ROOT}"/.agents/skills/*; do
      [[ -d "$skill_dir" ]] || continue
      skill_count=$((skill_count + 1))
      validate_skill "$skill_dir"
    done
  fi

  if (( skill_count == 0 )); then
    echo "ERROR no Codex skill adapters found under .agents/skills" >&2
    failures=$((failures + 1))
  fi
}

validate_repo

if (( failures > 0 )); then
  echo
  echo "validation failed: ${failures} issue(s)" >&2
  exit 1
fi

if (( CHECK_ONLY == 1 )); then
  echo
  echo "validation ok"
  exit 0
fi

if (( DRY_RUN == 0 )); then
  mkdir -p "$CODEX_DIR"
  mkdir -p "$AGENTS_SKILLS_DIR"
fi

linked=0
relinked=0
skipped=0
missing=0
would_link=0
would_relink=0

link_item() {
  local src="$1"
  local dst="$2"
  local label="$3"

  if [[ ! -e "$src" ]]; then
    echo "skip  ${label} (not present in repo)"
    missing=$((missing + 1))
    return
  fi

  if [[ -L "$dst" ]]; then
    local current
    current="$(readlink "$dst")"
    if [[ "$current" == "$src" ]]; then
      echo "ok    ${label}"
    else
      if (( DRY_RUN == 1 )); then
        echo "would relink ${label} (was -> ${current})"
        would_relink=$((would_relink + 1))
      else
        ln -sfn "$src" "$dst"
        echo "relink ${label} (was -> ${current})"
        relinked=$((relinked + 1))
      fi
    fi
  elif [[ -e "$dst" ]]; then
    echo "WARN  ${label} exists as a real file/directory; not overwriting" >&2
    skipped=$((skipped + 1))
  else
    if (( DRY_RUN == 1 )); then
      echo "would link ${label}"
      would_link=$((would_link + 1))
    else
      ln -sfn "$src" "$dst"
      echo "link  ${label}"
      linked=$((linked + 1))
    fi
  fi
}

CODEX_ITEMS=(
  "vocabulary.md"
  "roles"
  "agents"
  "contracts"
  "policies"
  "playbooks"
  "sidekick-prompts"
)

link_item "${SETUP_ROOT}/codex/AGENTS.md" "${CODEX_DIR}/AGENTS.md" "${CODEX_DIR}/AGENTS.md"

for item in "${CODEX_ITEMS[@]}"; do
  link_item "${SETUP_ROOT}/${item}" "${CODEX_DIR}/${item}" "${CODEX_DIR}/${item}"
done

if [[ -d "${SETUP_ROOT}/.agents/skills" ]]; then
  for skill_dir in "${SETUP_ROOT}"/.agents/skills/*; do
    [[ -d "$skill_dir" ]] || continue
    skill_name="$(basename "$skill_dir")"
    link_item "$skill_dir" "${AGENTS_SKILLS_DIR}/${skill_name}" "${AGENTS_SKILLS_DIR}/${skill_name}"
  done
else
  echo "skip  .agents/skills (not present in repo)"
  missing=$((missing + 1))
fi

echo
if (( DRY_RUN == 1 )); then
  echo "would link: ${would_link}  would relink: ${would_relink}  skipped: ${skipped}  missing: ${missing}"
else
  echo "linked: ${linked}  relinked: ${relinked}  skipped: ${skipped}  missing: ${missing}"
fi

if (( skipped > 0 )); then
  echo
  echo "One or more Codex targets exist as real files/directories."
  echo "Remove them manually and re-run this script to complete the install."
  exit 1
fi
