#!/usr/bin/env python3
"""TDD-3 RED phase: Verify mode-switch handling code still exists (GREEN will remove it).

SC-4: Mode-switch handling code removed (isModeSwitchContent, handleModeSwitchParts, MODE_SWITCH_ANCHOR absent)
SC-5: Synthetic mode-switch messages are stripped unconditionally by text-content check (GREEN adds this)
"""
import re
import sys
from pathlib import Path

SESSION_ENFORCEMENT = Path(__file__).resolve().parents[3] / "plugins" / "session-enforcement.ts"

OVERALL_RESULT = 0


def check(condition: bool, label: str, sc: str, detail: str):
    global OVERALL_RESULT
    status = "PASS" if condition else "FAIL"
    if not condition:
        OVERALL_RESULT = 1
    print(f"  [{sc}] {label}: {status}")
    if detail:
        print(f"         {detail}")


def test_sc4_isModeSwitchContent_exists():
    """SC-4: isModeSwitchContent function should still exist (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+isModeSwitchContent\s*\(", src) is not None
    check(
        has,
        "isModeSwitchContent function exists",
        "SC-4",
        "RED: mode-switch detection still present; GREEN will remove it",
    )


def test_sc4_handleModeSwitchParts_exists():
    """SC-4: handleModeSwitchParts function should still exist (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+handleModeSwitchParts\s*\(", src) is not None
    check(
        has,
        "handleModeSwitchParts function exists",
        "SC-4",
        "RED: mode-switch handler still present; GREEN will remove it",
    )


def test_sc4_MODE_SWITCH_ANCHOR_exists():
    """SC-4: MODE_SWITCH_ANCHOR constant should still exist (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "MODE_SWITCH_ANCHOR" in src
    check(
        has,
        "MODE_SWITCH_ANCHOR constant exists",
        "SC-4",
        "RED: mode-switch anchor still present; GREEN will remove it",
    )


def test_sc4_handleModeSwitchParts_called():
    """SC-4: handleModeSwitchParts should be called in messages.transform (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "handleModeSwitchParts(" in src
    check(
        has,
        "handleModeSwitchParts() call exists",
        "SC-4",
        "RED: call site still present; GREEN will remove it",
    )


if __name__ == "__main__":
    print("=== TDD-3 RED Phase ===")
    print(f"Target: {SESSION_ENFORCEMENT}")
    print()
    print("SC-4: Mode-switch handling code present")
    test_sc4_isModeSwitchContent_exists()
    test_sc4_handleModeSwitchParts_exists()
    test_sc4_MODE_SWITCH_ANCHOR_exists()
    test_sc4_handleModeSwitchParts_called()
    print()
    print(f"Overall: {'RED signal (code still present — correct)' if OVERALL_RESULT == 0 else 'GREEN signal (code already removed — unexpected)'}")
    sys.exit(OVERALL_RESULT)
