#!/usr/bin/env python3
"""TDD-1 RED phase: Verify userMessages.length === 1 still used for first-turn detection.

SC-1: injectedFirstTurnSessions Set replaces userMessages.length === 1 for first-turn detection
SC-2: injectedFirstTurnSessions persists across messages within same session (process-scoped)

These tests verify the BEFORE state. They PASS now (RED signal: heuristic still present).
After GREEN phase (Set replaces heuristic), these tests will FAIL — confirming the change.
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


def test_sc1_heuristic_still_present():
    """SC-1: Verify userMessages.length === 1 is STILL used (GREEN will remove it)."""
    src = SESSION_ENFORCEMENT.read_text()
    pattern = r"userMessages\.length\s*===\s*1"
    # Check in code lines only (not comments)
    code_lines = [
        line for line in src.split("\n")
        if not line.strip().startswith("*") and not line.strip().startswith("//")
    ]
    code_src = "\n".join(code_lines)
    match = re.search(pattern, code_src)
    check(
        match is not None,
        "userMessages.length === 1 heuristic present in code",
        "SC-1",
        f"Pattern '{pattern}' {'found' if match else 'NOT found'} in code (excluding comments)",
    )


def test_sc1_isFirstTurn_still_derived_from_length():
    """SC-1: Verify isFirstTurn is derived from userMessages.length === 1."""
    src = SESSION_ENFORCEMENT.read_text()
    # Look for: const isFirstTurn = userMessages.length === 1
    pattern = r"const\s+isFirstTurn\s*=\s*userMessages\.length\s*===\s*1"
    match = re.search(pattern, src)
    check(
        match is not None,
        "isFirstTurn derived from userMessages.length === 1",
        "SC-1",
        "After GREEN, isFirstTurn should be derived from injectedFirstTurnSessions Set",
    )


def test_sc2_set_not_yet_exists():
    """SC-2: Verify injectedFirstTurnSessions Set does NOT yet exist (GREEN will add it)."""
    src = SESSION_ENFORCEMENT.read_text()
    has_set = "injectedFirstTurnSessions" in src
    check(
        not has_set,
        "injectedFirstTurnSessions Set does not yet exist",
        "SC-2",
        "After GREEN, this Set should exist as a process-scoped declaration",
    )


def test_sc2_no_session_scoped_tracking():
    """SC-2: Verify no Set<sessionID> tracks which sessions got first-turn injection."""
    src = SESSION_ENFORCEMENT.read_text()
    # Look for any Set declaration tracking first-turn sessions
    pattern = r"(?:const|let|var)\s+\w*[Ff]irst[Tt]urn\w*\s*=\s*new\s+Set"
    match = re.search(pattern, src)
    check(
        match is None,
        "No Set-based first-turn session tracking exists",
        "SC-2",
        "After GREEN, a process-scoped Set<sessionID> should track injected sessions",
    )


if __name__ == "__main__":
    print("=== TDD-1 RED Phase ===")
    print(f"Target: {SESSION_ENFORCEMENT}")
    print()
    print("SC-1: userMessages.length === 1 still used for first-turn detection")
    test_sc1_heuristic_still_present()
    test_sc1_isFirstTurn_still_derived_from_length()
    print()
    print("SC-2: injectedFirstTurnSessions Set does NOT yet exist")
    test_sc2_set_not_yet_exists()
    test_sc2_no_session_scoped_tracking()
    print()
    print(f"Overall: {'PASS (tests pass = RED signal — heuristic still present)' if OVERALL_RESULT == 0 else 'FAIL'}")
    sys.exit(OVERALL_RESULT)
