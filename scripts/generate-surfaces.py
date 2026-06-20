#!/usr/bin/env python3
"""Generate Claude and Codex runtime surfaces from canonical role sources."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
ROLES_DIR = ROOT / "roles"
CLAUDE_AGENTS_DIR = ROOT / "agents"
CODEX_SKILLS_DIR = ROOT / ".agents" / "skills"
GENERATED_ROOTS = (CLAUDE_AGENTS_DIR, CODEX_SKILLS_DIR)
GENERATED_NAME_RE = re.compile(r"^[a-z][a-z0-9-]*$")

COMMON_SUPPORTING_FILES = [
    "contracts/finding.md",
    "contracts/scope-block.md",
    "policies/synthesis.md",
    "policies/scope-discipline.md",
    "policies/contract-enforcement.md",
    "vocabulary.md",
]

PLAN_SUPPORTING_FILES = [
    "contracts/plan.md",
]

CODE_SUPPORTING_FILES = [
    "contracts/code-change.md",
]

CONVERGENCE_SUPPORTING_FILES = [
    "contracts/code-change.md",
    "contracts/review-ledger.md",
]

PROMPT_SKILLS = [
    {
        "name": "gating-review",
        "source": "sidekick-prompts/gating-review.md",
        "description": (
            "Strict dirty-tree gating review. Use when Codex needs to review only "
            "the uncommitted changes in the current repository, investigate the "
            "surrounding code, and emit tightly qualified findings in the "
            "repository's gating-review JSON style."
        ),
        "display_name": "Gating Review",
        "short_description": "Strict dirty-tree review prompt",
        "default_prompt": "Use $gating-review to review the uncommitted changes.",
    }
]


class GenerateError(Exception):
    pass


def parse_frontmatter(path: Path) -> tuple[dict[str, str], str]:
    text = path.read_text()
    lines = text.splitlines()
    if not lines or lines[0] != "---":
        raise GenerateError(f"{path} is missing opening frontmatter delimiter")

    end = None
    for index, line in enumerate(lines[1:], start=1):
        if line == "---":
            end = index
            break
    if end is None:
        raise GenerateError(f"{path} is missing closing frontmatter delimiter")

    meta = parse_simple_yaml(lines[1:end], path)
    body = "\n".join(lines[end + 1 :]).strip() + "\n"
    return meta, body


def parse_simple_yaml(lines: list[str], path: Path) -> dict[str, str]:
    meta: dict[str, str] = {}
    index = 0
    while index < len(lines):
        line = lines[index]
        index += 1
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            raise GenerateError(f"{path}: invalid frontmatter line: {line!r}")
        key, raw_value = line.split(":", 1)
        key = key.strip()
        raw_value = raw_value.strip()
        if not key:
            raise GenerateError(f"{path}: empty frontmatter key")
        if raw_value in {"|", ">"}:
            block_lines: list[str] = []
            while index < len(lines):
                candidate = lines[index]
                if candidate.startswith("  "):
                    block_lines.append(candidate[2:])
                    index += 1
                    continue
                if candidate == "":
                    block_lines.append("")
                    index += 1
                    continue
                break
            meta[key] = "\n".join(block_lines).strip()
        else:
            meta[key] = strip_quotes(raw_value)
    return meta


def strip_quotes(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {'"', "'"}:
        return value[1:-1]
    return value


def yaml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def required(meta: dict[str, str], key: str, path: Path) -> str:
    value = meta.get(key, "").strip()
    if not value:
        raise GenerateError(f"{path}: missing required frontmatter key {key!r}")
    return value


def validate_generated_name(value: str, context: str) -> str:
    if not GENERATED_NAME_RE.fullmatch(value):
        raise GenerateError(
            f"{context}: invalid generated name {value!r}; use lowercase "
            "letters, numbers, and hyphens, starting with a letter"
        )
    return value


def role_name(meta: dict[str, str], path: Path) -> str:
    name = validate_generated_name(required(meta, "name", path), f"{path}: name")
    if path.stem != name:
        raise GenerateError(f"{path}: role name must match file stem {path.stem!r}")
    return name


def display_path(path: Path) -> str:
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def ensure_generated_path(path: Path) -> None:
    resolved_path = path.resolve(strict=False)
    for root in GENERATED_ROOTS:
        try:
            resolved_path.relative_to(root.resolve(strict=False))
            return
        except ValueError:
            continue
    raise GenerateError(
        "refusing generated path outside agents/ or .agents/skills/: "
        f"{display_path(path)}"
    )


def role_sources() -> list[tuple[Path, dict[str, str], str]]:
    if not ROLES_DIR.is_dir():
        raise GenerateError(f"missing roles directory: {ROLES_DIR}")

    roles = []
    for path in sorted(ROLES_DIR.glob("*.md")):
        meta, body = parse_frontmatter(path)
        role_name(meta, path)
        roles.append((path, meta, body))
    if not roles:
        raise GenerateError("no roles found")
    return roles


def render_claude_agent(meta: dict[str, str], body: str, path: Path) -> str:
    name = role_name(meta, path)
    description = required(meta, "claude_description", path)
    tools = required(meta, "claude_tools", path)
    model = required(meta, "claude_model", path)
    color = required(meta, "claude_color", path)

    return (
        "---\n"
        f"name: {name}\n"
        f"description: {yaml_string(description)}\n"
        f"tools: {tools}\n"
        f"model: {model}\n"
        f"color: {color}\n"
        "---\n\n"
        f"<!-- Generated from roles/{name}.md by scripts/generate-surfaces.py. Do not edit directly. -->\n\n"
        f"{body}"
    )


def supporting_files_for(meta: dict[str, str]) -> list[str]:
    support = []
    support.extend(COMMON_SUPPORTING_FILES)
    kind = meta.get("review_kind", "")
    if kind in {"plan", "minimality", "red-team"}:
        support.extend(PLAN_SUPPORTING_FILES)
    if kind == "code":
        support.extend(CODE_SUPPORTING_FILES)
    if kind == "convergence":
        support.extend(CONVERGENCE_SUPPORTING_FILES)

    seen = set()
    out = []
    for item in support:
        if item not in seen:
            seen.add(item)
            out.append(item)
    return out


def render_codex_role_skill(meta: dict[str, str], source_name: str, path: Path) -> str:
    name = role_name(meta, path)
    description = required(meta, "codex_description", path)
    title = required(meta, "codex_display_name", path)
    procedure = required(meta, "codex_procedure", path)
    supporting = supporting_files_for(meta)

    support_lines = "\n".join(f"- `../../../{item}`" for item in supporting)
    return (
        "---\n"
        f"name: {name}\n"
        f"description: {yaml_string(description)}\n"
        "---\n\n"
        f"<!-- Generated from roles/{source_name} by scripts/generate-surfaces.py. Do not edit directly. -->\n\n"
        f"# {title}\n\n"
        "## Source\n\n"
        f"Read `../../../roles/{source_name}` before acting. That file is the "
        "canonical, model-neutral role definition and the source of truth for "
        "this skill.\n\n"
        "Also read only the needed supporting files:\n\n"
        f"{support_lines}\n\n"
        "If the relative paths are unavailable, try the same files under the "
        "configured Codex home (`$CODEX_HOME` when set, otherwise `~/.codex`).\n\n"
        "## Procedure\n\n"
        f"{procedure.strip()}\n"
    )


def render_openai_yaml(meta: dict[str, str], path: Path) -> str:
    display_name = required(meta, "codex_display_name", path)
    short_description = required(meta, "codex_short_description", path)
    default_prompt = required(meta, "codex_default_prompt", path)
    return (
        "# Generated by scripts/generate-surfaces.py. Do not edit directly.\n"
        "interface:\n"
        f"  display_name: {yaml_string(display_name)}\n"
        f"  short_description: {yaml_string(short_description)}\n"
        f"  default_prompt: {yaml_string(default_prompt)}\n"
    )


def render_prompt_skill(entry: dict[str, str]) -> str:
    source = entry["source"]
    name = validate_generated_name(entry["name"], f"{source}: prompt skill name")
    description = entry["description"]
    title = entry["display_name"]
    return (
        "---\n"
        f"name: {name}\n"
        f"description: {yaml_string(description)}\n"
        "---\n\n"
        f"<!-- Generated from {source} by scripts/generate-surfaces.py. Do not edit directly. -->\n\n"
        f"# {title}\n\n"
        "## Source\n\n"
        f"Read `../../../{source}` and follow it as the source of truth. It defines "
        "the required investigation method, bug qualification criteria, priority "
        "mapping, and JSON output shape.\n\n"
        f"If the relative path is unavailable, try "
        f"`${{CODEX_HOME:-~/.codex}}/{source}`.\n\n"
        "## Procedure\n\n"
        "1. Review only tracked diffs plus new untracked files requested by the source prompt.\n"
        "2. Investigate call sites and data flow before reporting.\n"
        "3. Flag only introduced, discrete, actionable, non-speculative bugs.\n"
        "4. Use the JSON shape from the source prompt when the user asks for gating output; otherwise summarize findings in normal Codex review style.\n"
    )


def render_prompt_openai_yaml(entry: dict[str, str]) -> str:
    return (
        "# Generated by scripts/generate-surfaces.py. Do not edit directly.\n"
        "interface:\n"
        f"  display_name: {yaml_string(entry['display_name'])}\n"
        f"  short_description: {yaml_string(entry['short_description'])}\n"
        f"  default_prompt: {yaml_string(entry['default_prompt'])}\n"
    )


def write_or_check(path: Path, contents: str, check: bool, changed: list[Path]) -> None:
    ensure_generated_path(path)
    current = path.read_text() if path.exists() else None
    if current == contents:
        return
    changed.append(path)
    if check:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(contents)


def generated_paths(roles: list[tuple[Path, dict[str, str], str]]) -> set[Path]:
    paths: set[Path] = set()
    for source_path, meta, _body in roles:
        name = role_name(meta, source_path)
        paths.add(CLAUDE_AGENTS_DIR / f"{name}.md")
        paths.add(CODEX_SKILLS_DIR / name / "SKILL.md")
        paths.add(CODEX_SKILLS_DIR / name / "agents" / "openai.yaml")
    for entry in PROMPT_SKILLS:
        name = validate_generated_name(entry["name"], f"{entry['source']}: prompt skill name")
        paths.add(CODEX_SKILLS_DIR / name / "SKILL.md")
        paths.add(CODEX_SKILLS_DIR / name / "agents" / "openai.yaml")
    return paths


def generate(check: bool) -> int:
    changed: list[Path] = []
    roles = role_sources()
    expected = generated_paths(roles)

    for source_path, meta, body in roles:
        name = role_name(meta, source_path)
        write_or_check(
            CLAUDE_AGENTS_DIR / f"{name}.md",
            render_claude_agent(meta, body, source_path),
            check,
            changed,
        )
        write_or_check(
            CODEX_SKILLS_DIR / name / "SKILL.md",
            render_codex_role_skill(meta, source_path.name, source_path),
            check,
            changed,
        )
        write_or_check(
            CODEX_SKILLS_DIR / name / "agents" / "openai.yaml",
            render_openai_yaml(meta, source_path),
            check,
            changed,
        )

    for entry in PROMPT_SKILLS:
        name = entry["name"]
        write_or_check(
            CODEX_SKILLS_DIR / name / "SKILL.md",
            render_prompt_skill(entry),
            check,
            changed,
        )
        write_or_check(
            CODEX_SKILLS_DIR / name / "agents" / "openai.yaml",
            render_prompt_openai_yaml(entry),
            check,
            changed,
        )

    extra = [path for path in list_generated_files() if path not in expected]
    for path in extra:
        ensure_generated_path(path)
        changed.append(path)
        if not check:
            path.unlink()

    if changed:
        if check:
            print("generated surfaces are stale:")
        else:
            print("updated generated surfaces:")
        for path in sorted(changed):
            print(f"  {path.relative_to(ROOT)}")
        return 1 if check else 0

    print("generated surfaces are up to date")
    return 0


def list_generated_files() -> list[Path]:
    files: list[Path] = []
    if CLAUDE_AGENTS_DIR.is_dir():
        files.extend(CLAUDE_AGENTS_DIR.glob("*.md"))
    if CODEX_SKILLS_DIR.is_dir():
        files.extend(CODEX_SKILLS_DIR.glob("*/SKILL.md"))
        files.extend(CODEX_SKILLS_DIR.glob("*/agents/openai.yaml"))
    return files


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="fail if generated files are stale")
    args = parser.parse_args()

    try:
        return generate(check=args.check)
    except GenerateError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
