#!/usr/bin/env python3
"""TDD-3 GREEN phase: Verify mode-switch handling replaced with unconditional stripping.

SC-4: Mode-switch handling code removed (isModeSwitchContent, handleModeSwitchParts, MODE_SWITCH_ANCHOR absent)
SC-5: Synthetic mode-switch messages are stripped unconditionally by text-content check
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


def test_sc4_isModeSwitchContent_absent():
    """SC-4: isModeSwitchContent function is removed."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+isModeSwitchContent\s*\(", src) is not None
    check(not has, "isModeSwitchContent function absent", "SC-4", "Old detection function removed")


def test_sc4_handleModeSwitchParts_absent():
    """SC-4: handleModeSwitchParts function is removed."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+handleModeSwitchParts\s*\(", src) is not None
    check(not has, "handleModeSwitchParts function absent", "SC-4", "Old handler function removed")


def test_sc4_MODE_SWITCH_ANCHOR_absent():
    """SC-4: MODE_SWITCH_ANCHOR constant is removed."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "MODE_SWITCH_ANCHOR" in src
    check(not has, "MODE_SWITCH_ANCHOR constant absent", "SC-4", "Old anchor constant removed")


def test_sc5_isModeSwitchSynthetic_exists():
    """SC-5: New isModeSwitchSynthetic detection function exists."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+isModeSwitchSynthetic\s*\(", src) is not None
    check(has, "isModeSwitchSynthetic function exists", "SC-5", "New unconditional detection function present")


def test_sc5_checks_both_patterns():
    """SC-5: isModeSwitchSynthetic checks both mode-switch text patterns."""
    src = SESSION_ENFORCEMENT.read_text()
    has_plan = "Your operational mode has changed from" in src
    has_system = "# Plan Mode - System Reminder" in src
    check(has_plan and has_system, "Both mode-switch patterns checked", "SC-5",
          f"Plan switch: {'found' if has_plan else 'MISSING'}, System reminder: {'found' if has_system else 'MISSING'}")


def test_sc5_unconditional_stripping():
    """SC-5: Unconditional stripping logic exists (text = '')."""
    src = SESSION_ENFORCEMENT.read_text()
    # Look for: part.text = ''; part.synthetic = false;
    has = re.search(r"part\.text\s*=\s*'';\s*\n\s*part\.synthetic\s*=\s*false;", src) is not None
    check(has, "Unconditional stripping logic present", "SC-5",
          "part.text = '' + part.synthetic = false strips mode-switch messages")


def test_sc5_no_transition_logic():
    """SC-5: No transition-detection logic remains (unconditional stripping)."""
    src = SESSION_ENFORCEMENT.read_text()
    has_transition = "isTransition" in src or "findLast(m => m.info?.role === 'assistant')" in src
    check(not has_transition, "No transition-detection logic", "SC-5",
          "Unconditional stripping replaces transition-conditional logic")


if __name__ == "__main__":
    print("=== TDD-3 GREEN Phase ===")
    print(f"Target: {SESSION_ENFORCEMENT}")
    print()
    print("SC-4: Mode-switch handling code removed")
    test_sc4_isModeSwitchContent_absent()
    test_sc4_handleModeSwitchParts_absent()
    test_sc4_MODE_SWITCH_ANCHOR_absent()
    print()
    print("SC-5: Unconditional mode-switch stripping")
    test_sc5_isModeSwitchSynthetic_exists()
    test_sc5_checks_both_patterns()
    test_sc5_unconditional_stripping()
    test_sc5_no_transition_logic()
    print()
    print(f"Overall: {'PASS' if OVERALL_RESULT == 0 else 'FAIL'}")
    sys.exit(OVERALL_RESULT)
