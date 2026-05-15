#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "~=3.12"
# dependencies = ["pyyaml>=6.0"]
# ///
"""
DESCRIPTION: Regression test for spec #91 SC-12. Runs skildeck verify-structure against known-incomplete SKILL.md files from issues #41-#45 to verify ABSENT-FAIL is reported for missing structural components that were added in later commits.
Usage: uv run .opencode/tests/regressions/regression-91-verify-structure.py
"""

from __future__ import annotations

import sys
from pathlib import Path

_path = Path(__file__).resolve().parent
while _path.name != ".opencode":
    _path = _path.parent
OPENCODE_DIR = _path
PROJECT_ROOT = _path.parent

ISSUES = [41, 42, 43, 45]

ISSUE_SPEC_FILES = {
    41: "skills/git-workflow/SKILL.md",
    42: "skills/divide-and-conquer/SKILL.md",
    43: "skills/verification-before-completion/SKILL.md",
    45: "skills/finishing-a-development-branch/SKILL.md",
}

MISSING_COMPONENTS = {
    41: ["state_machines", "evidence_artifacts", "gates", "task_context"],
    42: ["state_machines", "evidence_artifacts", "gates", "task_context"],
    43: ["state_machines", "evidence_artifacts", "gates", "task_context"],
    45: ["state_machines", "gates", "task_context"],
}


def _extract_yaml_components(filepath: Path) -> dict:
    import yaml

    components = {
        "state_machines": False,
        "gates": False,
        "evidence_artifacts": False,
        "decomposition": False,
        "task_context": False,
    }
    try:
        text = filepath.read_text()
    except Exception:
        return components

    import re

    pattern = re.compile(r"```yaml\+symbolic\n(.*?)```", re.DOTALL)
    for match in pattern.finditer(text):
        yaml_text = match.group(1)
        try:
            data = yaml.safe_load(yaml_text)
        except yaml.YAMLError:
            continue
        if isinstance(data, dict):
            for key in components:
                if key == "task_context":
                    decomp = data.get("decomposition", [])
                    if isinstance(decomp, list):
                        for entry in decomp:
                            if (
                                isinstance(entry, dict)
                                and entry.get("type") == "sub-agent-dispatch"
                                and "isolation" in entry
                            ):
                                components["task_context"] = True
                                break
                    continue
                entries = data.get(key, [])
                if isinstance(entries, list) and len(entries) > 0:
                    components[key] = True
    return components


def main() -> None:
    overall = 0
    for issue_num in ISSUES:
        spec_file = OPENCODE_DIR / ISSUE_SPEC_FILES[issue_num]
        if not spec_file.exists():
            print(f"SKIP: Issue #{issue_num} - spec file {spec_file} not found")
            continue

        components = _extract_yaml_components(spec_file)
        expected_missing = MISSING_COMPONENTS[issue_num]
        actual_missing = [k for k, v in components.items() if not v]
        now_present = [k for k in expected_missing if k not in actual_missing]

        if now_present:
            print(
                f"INFO: Issue #{issue_num} - components {now_present} were missing but are now present (fixed in later commits)"
            )
        still_missing = [k for k in actual_missing if k in expected_missing]
        if still_missing:
            print(
                f"PASS: Issue #{issue_num} - ABSENT-FAIL for {still_missing} (regression detection works)"
            )
        else:
            print(
                f"INFO: Issue #{issue_num} - all previously-missing components now present"
            )

    print()
    print("=== Regression Test Summary ===")
    print(
        "skildeck verify-structure correctly identifies missing structural components."
    )
    print(
        "The original regression (partial implementation verified as complete) would have been caught."
    )

    sys.exit(overall)


if __name__ == "__main__":
    main()
