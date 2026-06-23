#!/usr/bin/env python3
"""TDD-1 GREEN phase: Verify injectedFirstTurnSessions Set replaces heuristic.

SC-1: injectedFirstTurnSessions Set replaces userMessages.length === 1
SC-2: Set persists across messages within same session (process-scoped)
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


def test_sc1_set_declared():
    """SC-1: injectedFirstTurnSessions is declared as a process-scoped Set."""
    src = SESSION_ENFORCEMENT.read_text()
    pattern = r"const\s+injectedFirstTurnSessions\s*=\s*new\s+Set<string>\(\)"
    match = re.search(pattern, src)
    check(
        match is not None,
        "injectedFirstTurnSessions declared as process-scoped Set",
        "SC-1",
        f"Pattern found at position {match.start()}" if match else "NOT found",
    )


def test_sc1_isFirstTurn_uses_set():
    """SC-1: isFirstTurn uses injectedFirstTurnSessions.has() instead of length check."""
    src = SESSION_ENFORCEMENT.read_text()
    # Should find: firstUserSessionID ? !injectedFirstTurnSessions.has(firstUserSessionID)
    # or: sessionID ? !injectedFirstTurnSessions.has(sessionID)
    pattern = r"isFirstTurn\s*=\s*\w+\s*\?\s*!injectedFirstTurnSessions\.has\(\w+\)"
    match = re.search(pattern, src)
    check(
        match is not None,
        "isFirstTurn uses injectedFirstTurnSessions.has() for detection",
        "SC-1",
        "Length check is now fallback for missing session ID only",
    )


def test_sc1_length_check_only_in_fallback():
    """SC-1: userMessages.length === 1 only appears in fallback path (not in logic)."""
    src = SESSION_ENFORCEMENT.read_text()
    # Exclude comment lines (lines starting with * or //)
    code_lines = [
        line for line in src.split("\n")
        if not line.strip().startswith("*") and not line.strip().startswith("//")
    ]
    code_src = "\n".join(code_lines)
    matches = re.findall(r"userMessages\.length\s*===\s*1", code_src)
    check(
        len(matches) <= 1,
        "userMessages.length === 1 appears at most once in code (fallback only)",
        "SC-1",
        f"Found {len(matches)} occurrence(s) in code: should be 0 or 1 (fallback for missing sessionID)",
    )


def test_sc2_set_add_after_injection():
    """SC-2: Session is added to Set after first-turn injection."""
    src = SESSION_ENFORCEMENT.read_text()
    pattern = r"injectedFirstTurnSessions\.add\(\w+\)"
    match = re.search(pattern, src)
    check(
        match is not None,
        "injectedFirstTurnSessions.add() called after injection",
        "SC-2",
        f"Found at position {match.start()}" if match else "NOT found",
    )


def test_sc2_guarded_by_session_id():
    """SC-2: Set add is guarded by session ID check."""
    src = SESSION_ENFORCEMENT.read_text()
    # Look for: if (firstUserSessionID && isFirstTurn) or similar guard
    pattern = r"if\s*\(\w+\s*&&\s*\w+\)\s*\{[^}]*injectedFirstTurnSessions\.add\(\w+\)"
    match = re.search(pattern, src, re.DOTALL)
    check(
        match is not None,
        "Set add guarded by session ID and isFirstTurn check",
        "SC-2",
        "Prevents adding undefined to Set and redundant tracking",
    )


if __name__ == "__main__":
    print("=== TDD-1 GREEN Phase ===")
    print(f"Target: {SESSION_ENFORCEMENT}")
    print()
    print("SC-1: injectedFirstTurnSessions Set replaces length heuristic")
    test_sc1_set_declared()
    test_sc1_isFirstTurn_uses_set()
    test_sc1_length_check_only_in_fallback()
    print()
    print("SC-2: Set persists across messages within same session")
    test_sc2_set_add_after_injection()
    test_sc2_guarded_by_session_id()
    print()
    print(f"Overall: {'PASS' if OVERALL_RESULT == 0 else 'FAIL'}")
    sys.exit(OVERALL_RESULT)
