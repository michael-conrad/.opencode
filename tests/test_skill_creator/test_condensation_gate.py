"""RED test for SC-5: condensation-format validation gate in skill-creator.

Asserts that validate_skill_cards.py carries a structural condensation-format
check that FAILs a path-restatement dispatch link `[text]` (dead-weight pattern)
on card create/edit. The gate does not exist yet, so this test FAILS in RED phase.
"""

import importlib.util
from pathlib import Path

import pytest

SCRIPT_PATH = Path(__file__).resolve().parents[2] / "skills" / "skill-creator" / "scripts" / "validate_skill_cards.py"


@pytest.fixture(scope="module")
def validator():
    spec = importlib.util.spec_from_file_location("validate_skill_cards", SCRIPT_PATH)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _write_card(tmp_path: Path, body: str) -> Path:
    card = tmp_path / "skills" / "sample-skill" / "SKILL.md"
    card.parent.mkdir(parents=True)
    card.write_text(
        "---\n"
        "name: sample-skill\n"
        "description: Dispatch when validating sample skill cards.\n"
        "license: MIT\n"
        "compatibility: opencode\n"
        "---\n"
        + body,
        encoding="utf-8",
    )
    return card


def test_condensation_gate_rejects_path_restatement(validator, tmp_path):
    """SC-5: a path-restatement dispatch link `[text]` MUST FAIL the gate.

    The dead-weight pattern restates the dispatch path as the link text
    (e.g., `[tasks/validate.md](.opencode/skills/skill-creator/tasks/validate.md)`).
    The condensation-format gate must flag it. The gate does not exist yet, so
    no condensation violation is produced and this assertion fails (RED).
    """
    body = (
        "## Workflows\n"
        "1. **Validate**\n"
        "   - **Prompt:** `task(subagent_type=\"general\", prompt: concat(\"You are a sub-agent. "
        "Follow the instructions in [tasks/validate.md](.opencode/skills/skill-creator/tasks/validate.md). \"))`\n"
    )
    card = _write_card(tmp_path, body)
    violations = validator.validate_card(card, tmp_path)
    condensation_violations = [
        v for v in violations if v.violation_type == "CONDENSATION"
    ]
    assert condensation_violations, (
        "SC-5 FAIL: path-restatement dispatch link `[tasks/validate.md]` PASSED "
        "validation — no condensation-format violation was produced. The "
        "condensation-format gate does not exist yet."
    )


def test_condensation_gate_accepts_condensation(validator, tmp_path):
    """SC-5: a purpose-condensation dispatch link `[text]` MUST PASS the gate.

    A compliant condensation (e.g., `[validate skill cards]`) must not be flagged.
    This is the positive case; it also fails in RED because the gate is absent.
    """
    body = (
        "## Workflows\n"
        "1. **Validate**\n"
        "   - **Prompt:** `task(subagent_type=\"general\", prompt: concat(\"You are a sub-agent. "
        "Follow the instructions in [validate skill cards](.opencode/skills/skill-creator/tasks/validate.md). \"))`\n"
    )
    card = _write_card(tmp_path, body)
    violations = validator.validate_card(card, tmp_path)
    condensation_violations = [
        v for v in violations if v.violation_type == "CONDENSATION"
    ]
    assert not condensation_violations, (
        "SC-5 FAIL: compliant condensation `[validate skill cards]` was flagged "
        "by the condensation-format gate."
    )
