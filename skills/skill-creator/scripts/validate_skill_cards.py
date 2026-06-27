#!/usr/bin/env -S uv run --script
# fmt: off
"exec" "uv" "run" "--script" "$0" "$@" # MUST GO BEFORE PEP 723 HEADER

# PEP 723 HEADER MUST BE AFTER BASH GUARD
# /// script
# requires-python = "~=3.12"
# dependencies = []
# ///

# fmt: on
"""
Skill card validation only (sensor mode). Corrections are agent-driven.

Validates SKILL.md files per spec #1124:
  REQ-1: Frontmatter validation (name, description, type, license, compatibility)
  REQ-2: Placeholder enforcement (no hardcoded identity values)
  REQ-3: Worktree Mode section requirement for skills with bash/git/file ops
  REQ-4: Provenance field validation
  REQ-5: Mandatory Task Discipline admonishment presence (5-item checklist)

Usage:
    uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py           # validate
    uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py --json   # JSON output

Exit codes: 0 = all pass, 1 = any fail
"""

import json
import re
import sys
from pathlib import Path
from typing import NamedTuple

VALID_TYPES = {
    "discipline-enforcing",
    "technique",
    "pattern",
    "reference",
    "orchestrator",
}
VALID_PROVENANCE = {"AI-generated", "AI-assisted", "Human-written", "Derived"}
HARDCODED_AGENT_NAMES = re.compile(
    r"\bOpenCode\b|\bClaude\b|\bCopilot\b|\bGemini\b|\bGPT-4\b"
)
HARDCODED_MODEL_IDS = re.compile(
    r"\bollama-cloud/[a-z0-9._-]+\b"
    r"|claude-3[-_]5[-_]sonnet"
    r"|claude-3-opus"
    r"|claude-3-sonnet"
    r"|gpt-4[a-z0-9-]*"
    r"|glm-[0-9.]+"
)
HARDCODED_DEV_NAMES = re.compile(r"\bexample-developer\b|\bexample-dev-alias\b")
HARDCODED_ORG_REPO = re.compile(r"\bexample-org\b|\bexample-repo\b")
ATTRIBUTION_EXEMPT = re.compile(r"Co-authored with AI:.*<AgentName>.*<ModelId>")
CODE_BLOCK_RE = re.compile(r"```[\s\S]*?```", re.MULTILINE)
WORKTREE_MODE_HEADING_RE = re.compile(
    r"^##\s+Worktree\s+Mode", re.MULTILINE | re.IGNORECASE
)
FILE_OPS_PATTERN = re.compile(
    r"`?read`?|`?write`?|`?edit`?|`?glob`?|`?grep`?"
    r"|\bbash\b.*tool\b|\bgit\s+\w"
    r"|worktree\.path",
    re.IGNORECASE,
)

class Violation(NamedTuple):
    violation_type: str
    skill_name: str
    rule_id: str
    message: str
    detail: str = ""
    file_path: str = ""
    line_approx: int | None = None
    severity: str = "ERROR"
    pass_fail: str = "FAIL"

def discover_skill_cards(root: Path) -> list[Path]:
    cards = sorted(root.glob(".opencode/skills/*/SKILL.md"))
    cards.extend(sorted(root.glob(".opencode/skills/*/platforms/*/SKILL.md")))
    return cards

def parse_frontmatter(content: str) -> tuple[dict[str, str], str, str]:
    match = re.match(r"^---\n(.*?)\n---", content, re.DOTALL)
    if not match:
        return {}, "", content
    fm_text = match.group(1)
    body = content[match.end() :]
    fields: dict[str, str] = {}
    for line in fm_text.split("\n"):
        colon = line.find(":")
        if colon > 0:
            key = line[:colon].strip()
            val = line[colon + 1 :].strip()
            val = val.strip("\"'")
            fields[key] = val
    return fields, fm_text, body

def skill_name_from_path(p: Path) -> str:
    parts = p.parts
    idx = parts.index("skills")
    return "/".join(parts[idx + 1 : -1])

def validate_req1(
    name: str, fields: dict[str, str], fm_text: str, file_path: str
) -> list[Violation]:
    violations: list[Violation] = []
    if "name" not in fields:
        violations.append(
            Violation(
                "REQ-1", name, "name", "Missing 'name' field", file_path=file_path
            )
        )
    else:
        val = fields["name"]
        if not re.match(r"^[a-z0-9-]+$", val):
            violations.append(
                Violation(
                    "REQ-1",
                    name,
                    "name",
                    f"Name '{val}' not hyphen-case",
                    val,
                    file_path=file_path,
                )
            )
        elif val.startswith("-") or val.endswith("-") or "--" in val:
            violations.append(
                Violation(
                    "REQ-1",
                    name,
                    "name",
                    f"Name '{val}' has bad hyphens",
                    val,
                    file_path=file_path,
                )
            )
    if "description" not in fields:
        violations.append(
            Violation(
                "REQ-1",
                name,
                "description",
                "Missing 'description' field",
                file_path=file_path,
            )
        )
    else:
        desc = fields["description"]
        if not desc.startswith("Use when"):
            violations.append(
                Violation(
                    "REQ-1",
                    name,
                    "description",
                    "Description doesn't start with 'Use when'",
                    desc[:60],
                    file_path=file_path,
                )
            )
        if "<" in desc or ">" in desc:
            violations.append(
                Violation(
                    "REQ-1",
                    name,
                    "description",
                    "Description contains angle brackets",
                    desc[:60],
                    file_path=file_path,
                )
            )
    if "type" not in fields:
        violations.append(
            Violation(
                "REQ-1", name, "type", "Missing 'type' field", file_path=file_path
            )
        )
    elif fields["type"] not in VALID_TYPES:
        violations.append(
            Violation(
                "REQ-1",
                name,
                "type",
                f"Invalid type '{fields['type']}'",
                fields["type"],
                file_path=file_path,
            )
        )
    if "license" not in fields:
        violations.append(
            Violation(
                "REQ-1", name, "license", "Missing 'license' field", file_path=file_path
            )
        )
    if "compatibility" not in fields:
        violations.append(
            Violation(
                "REQ-1",
                name,
                "compatibility",
                "Missing 'compatibility' field",
                file_path=file_path,
            )
        )
    return violations

def validate_sc_lint_001(name: str, fields: dict[str, str], file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    desc = fields.get("description", "")
    if not desc.startswith("Use when"):
        violations.append(
            Violation(
                "SC-LINT", name, "SC-LINT-001",
                "Description doesn't start with 'Use when'",
                desc[:60], file_path=file_path,
                severity="ERROR", pass_fail="FAIL",
            )
        )
    return violations

MANDATORY_KEYWORDS = re.compile(
    r"\bMUST\b|\bREQUIRED\b|\balways\b|\bnot optional\b|\bmandatory\b",
    re.IGNORECASE,
)
NARRATIVE_PATTERNS = re.compile(
    r"^(Professional engineers|Amateurs|X is the Y|X produces Y|X turns Y into Z)",
    re.IGNORECASE,
)
PROCEDURE_SECTION_RE = re.compile(
    r"^(Procedure:|Operating Protocol:|Entry Criteria:|Exit Criteria:)"
    r"|^- \[ \] \d+\.\s+\*\*Step\b",
    re.MULTILINE,
)
PROCEDURE_CODE_BLOCK_RE = re.compile(
    r"```(bash|python|yaml)\s*\n",
    re.MULTILINE,
)
DISPATCH_SUB_BULLET_RE = re.compile(r"^\s+-\s+[^-[\s]")
DISPATCH_SUB_CHECKBOX_RE = re.compile(r"^\s+- \[ \] ")

def validate_sc_lint_002(name: str, fields: dict[str, str], file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    desc = fields.get("description", "")
    if not MANDATORY_KEYWORDS.search(desc):
        violations.append(
            Violation(
                "SC-LINT", name, "SC-LINT-002",
                "Description lacks mandatory keyword (MUST/REQUIRED/always/not optional/mandatory)",
                desc[:60], file_path=file_path,
                severity="WARNING", pass_fail="FAIL",
            )
        )
    return violations

def validate_sc_lint_003(name: str, fields: dict[str, str], file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    desc = fields.get("description", "")
    sentences = [s.strip() for s in desc.replace("—", ".").split(".") if s.strip()]
    for s in sentences:
        if NARRATIVE_PATTERNS.match(s):
            violations.append(
                Violation(
                    "SC-LINT", name, "SC-LINT-003",
                    "Description contains narrative-only sentence",
                    s[:60], file_path=file_path,
                    severity="WARNING", pass_fail="FAIL",
                )
            )
            break
    return violations

def validate_sc_lint_004(name: str, fields: dict[str, str], file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    desc = fields.get("description", "")
    if len(desc) > 300:
        violations.append(
            Violation(
                "SC-LINT", name, "SC-LINT-004",
                f"Description exceeds 300 characters ({len(desc)})",
                desc[:60], file_path=file_path,
                severity="WARNING", pass_fail="FAIL",
            )
        )
    return violations

def validate_sc_lint_005(name: str, body: str, file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    if PROCEDURE_SECTION_RE.search(body):
        violations.append(
            Violation(
                "SC-LINT", name, "SC-LINT-005",
                "SKILL.md body contains prohibited procedure section",
                file_path=file_path,
                severity="ERROR", pass_fail="FAIL",
            )
        )
        return violations
    # Check for code blocks that appear within procedure-like context
    # (code blocks preceded by a heading that suggests procedure content)
    lines = body.split("\n")
    for i, line in enumerate(lines):
        if line.startswith("## ") and any(kw in line.lower() for kw in ["procedure", "protocol", "operating"]):
            # Check if next non-empty lines contain a code block
            for j in range(i + 1, min(i + 10, len(lines))):
                if PROCEDURE_CODE_BLOCK_RE.match(lines[j]):
                    violations.append(
                        Violation(
                            "SC-LINT", name, "SC-LINT-005",
                            "SKILL.md body contains code block under procedure heading",
                            file_path=file_path,
                            severity="ERROR", pass_fail="FAIL",
                        )
                    )
                    return violations
    return violations

def validate_sc_lint_006(name: str, body: str, file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    in_dispatch_table = False
    for line in body.split("\n"):
        stripped = line.strip()
        if "|" in stripped and "User says" in stripped:
            in_dispatch_table = True
            continue
        if in_dispatch_table:
            if stripped.startswith("---"):
                continue
            if not stripped.startswith("|"):
                in_dispatch_table = False
                continue
            # Check for sub-items in the last column
            if "|" in stripped:
                cells = stripped.split("|")
                if len(cells) >= 4:
                    last_cell = cells[-2].strip() if len(cells) > 2 else ""
                    if "`" in last_cell and "- [ ]" in last_cell:
                        violations.append(
                            Violation(
                                "SC-LINT", name, "SC-LINT-006",
                                "Dispatch table sub-item type violation: actionable step uses sub-bullet",
                                file_path=file_path,
                                severity="WARNING", pass_fail="FAIL",
                            )
                        )
    return violations

def validate_req2(name: str, content: str, file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    content_no_code = CODE_BLOCK_RE.sub("", content)
    lines_no_code = content_no_code.split("\n")
    for i, line in enumerate(lines_no_code):
        if ATTRIBUTION_EXEMPT.search(line):
            continue
        for pattern, label, placeholder in [
            (HARDCODED_AGENT_NAMES, "agent name", "<AgentName>"),
            (HARDCODED_MODEL_IDS, "model ID", "<ModelId>"),
            (HARDCODED_DEV_NAMES, "developer name", "<dev.name>/<dev.email>"),
            (HARDCODED_ORG_REPO, "org/repo name", "<github.owner>/<github.repo>"),
        ]:
            for m in pattern.finditer(line):
                violations.append(
                    Violation(
                        "REQ-2",
                        name,
                        "placeholder",
                        f"Hardcoded {label}: '{m.group()}' — use {placeholder}",
                        f"line~{i + 1}",
                        file_path,
                        i + 1,
                    )
                )
    return violations

def validate_req3(name: str, body: str, file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    if WORKTREE_MODE_HEADING_RE.search(body):
        return violations
    if FILE_OPS_PATTERN.search(body):
        violations.append(
            Violation(
                "REQ-3",
                name,
                "worktree-mode",
                "Missing 'Worktree Mode' section (skill contains bash/git/file operations)",
                file_path=file_path,
            )
        )
    return violations

ADMONISHMENT_HEADING_RE = re.compile(r"^##\s+Mandatory\s+Task\s+Discipline", re.MULTILINE)

def validate_req5(name: str, body: str, file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    if not ADMONISHMENT_HEADING_RE.search(body):
        violations.append(
            Violation(
                "REQ-5",
                name,
                "admonishment",
                "Missing 'Mandatory Task Discipline' section",
                file_path=file_path,
            )
        )
    return violations

def validate_req4(name: str, fields: dict[str, str], file_path: str) -> list[Violation]:
    violations: list[Violation] = []
    if "provenance" not in fields:
        violations.append(
            Violation(
                "REQ-4",
                name,
                "provenance",
                "Missing 'provenance' field",
                file_path=file_path,
            )
        )
    elif fields["provenance"] not in VALID_PROVENANCE:
        violations.append(
            Violation(
                "REQ-4",
                name,
                "provenance",
                f"provenance must be one of: {', '.join(sorted(VALID_PROVENANCE))}",
                fields["provenance"],
                file_path=file_path,
            )
        )
    return violations

def validate_card(card_path: Path, root: Path) -> list[Violation]:
    name = skill_name_from_path(card_path.relative_to(root))
    rel_path = str(card_path.relative_to(root))
    content = card_path.read_text(encoding="utf-8")
    fields, fm_text, body = parse_frontmatter(content)
    violations: list[Violation] = []
    if not content.startswith("---"):
        violations.append(
            Violation(
                "REQ-1",
                name,
                "frontmatter",
                "No YAML frontmatter found",
                file_path=rel_path,
            )
        )
        return violations
    if not fields:
        violations.append(
            Violation(
                "REQ-1",
                name,
                "frontmatter",
                "Invalid frontmatter format",
                file_path=rel_path,
            )
        )
        return violations
    violations.extend(validate_req1(name, fields, fm_text, rel_path))
    violations.extend(validate_sc_lint_001(name, fields, rel_path))
    violations.extend(validate_sc_lint_002(name, fields, rel_path))
    violations.extend(validate_sc_lint_003(name, fields, rel_path))
    violations.extend(validate_sc_lint_004(name, fields, rel_path))
    violations.extend(validate_sc_lint_005(name, body, rel_path))
    violations.extend(validate_sc_lint_006(name, body, rel_path))
    violations.extend(validate_req2(name, content, rel_path))
    violations.extend(validate_req3(name, body, rel_path))
    violations.extend(validate_req4(name, fields, rel_path))
    violations.extend(validate_req5(name, body, rel_path))
    return violations

def violation_to_dict(v: Violation) -> dict:
    return {
        "skill_name": v.skill_name,
        "file_path": v.file_path,
        "violation_type": v.violation_type,
        "rule_id": v.rule_id,
        "message": v.message,
        "detail": v.detail,
        "line_approx": v.line_approx,
        "severity": v.severity,
        "pass_fail": v.pass_fail,
    }

def main() -> int:
    if "--fix" in sys.argv:
        print(
            "ERROR: --fix mode has been removed. Autocorrection is now agent-driven.\n"
            "Use the skill-creator validate task for semantic review and correction.\n"
            "Invoke: /skill skill-creator --task validate"
        )
        return 2
    json_mode = "--json" in sys.argv
    root = Path.cwd()
    cards = discover_skill_cards(root)
    if not cards:
        if json_mode:
            print(json.dumps([]))
        else:
            print("No SKILL.md files found.")
        return 1
    all_violations: list[Violation] = []
    for card_path in cards:
        all_violations.extend(validate_card(card_path, root))
    if json_mode:
        print(json.dumps([violation_to_dict(v) for v in all_violations], indent=2))
        return 0 if not all_violations else 1
    print("=== Skill Card Validation ===")
    print(f"Discovered {len(cards)} skill cards\n")
    by_skill: dict[str, list[Violation]] = {}
    for v in all_violations:
        by_skill.setdefault(v.skill_name, []).append(v)
    for card_path in cards:
        name = skill_name_from_path(card_path.relative_to(root))
        violations = by_skill.get(name, [])
        if violations:
            print(f"FAIL  {name}")
            for v in violations:
                print(f"  [{v.violation_type}] {v.rule_id}: {v.message}")
                if v.detail:
                    print(f"         detail: {v.detail}")
        else:
            print(f"PASS  {name}")
    print("\n--- Summary ---")
    print(f"Cards: {len(cards)}, Violations: {len(all_violations)}")
    if all_violations:
        violating_skills = sorted({v.skill_name for v in all_violations})
        print(f"Failing skills: {', '.join(violating_skills)}")
    return 0 if not all_violations else 1

if __name__ == "__main__":
    sys.exit(main())

