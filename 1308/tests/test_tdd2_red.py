#!/usr/bin/env python3
"""TDD-2 RED phase: Verify inline work detector code still exists (GREEN will remove it).

SC-3: Inline work detector code is removed (no isInlineWork, no containsFileEditPattern, no associated regex)
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


def test_sc3_is_inline_work_absent():
    """SC-3: Verify isInlineWork function does NOT exist (already removed)."""
    src = SESSION_ENFORCEMENT.read_text()
    # Check for function definition or variable assignment
    has_func = re.search(r"(function\s+isInlineWork|const\s+isInlineWork\s*=|isInlineWork\s*\()", src) is not None
    check(
        not has_func,
        "isInlineWork function/variable absent",
        "SC-3",
        "Inline work detector function should be removed",
    )


def test_sc3_contains_file_edit_pattern_absent():
    """SC-3: Verify containsFileEditPattern function does NOT exist."""
    src = SESSION_ENFORCEMENT.read_text()
    has_func = re.search(r"(function\s+containsFileEditPattern|const\s+containsFileEditPattern\s*=|containsFileEditPattern\s*\()", src) is not None
    check(
        not has_func,
        "containsFileEditPattern function/variable absent",
        "SC-3",
        "File edit pattern matcher should be removed",
    )


def test_sc3_no_file_edit_regex():
    """SC-3: Verify no FILE_EDIT_PATTERN regex constant or similar patterns exist."""
    src = SESSION_ENFORCEMENT.read_text()
    # Check for regex constants and patterns used by inline work detection
    patterns = [
        r"FILE_EDIT_PATTERN",
        r"FILE_EDIT_REGEX",
        r"EDIT_PATTERN",
        r"isInlineWork",
        r"containsFileEditPattern",
    ]
    found = [p for p in patterns if re.search(p, src)]
    check(
        len(found) == 0,
        "No inline work detection regex/function patterns found",
        "SC-3",
        f"Found {len(found)} pattern(s): {found}" if found else "Clean — no inline work detection code",
    )


if __name__ == "__main__":
    print("=== TDD-2 RED Phase ===")
    print(f"Target: {SESSION_ENFORCEMENT}")
    print()
    print("SC-3: Inline work detector code removed")
    test_sc3_is_inline_work_absent()
    test_sc3_contains_file_edit_pattern_absent()
    test_sc3_no_file_edit_regex()
    print()
    print(f"Overall: {'PASS (all removed — GREEN signal)' if OVERALL_RESULT == 0 else 'FAIL (detector still present — RED signal)'}")
    sys.exit(OVERALL_RESULT)
