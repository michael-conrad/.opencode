#!/usr/bin/env python3
"""TDD-4 RED phase: Verify gate blocks still exist (GREEN will remove them).

SC-6: Pre-Implementation Gate block removed
SC-7: Core Principles injection block removed
SC-8: Tier 1 Mandate Enforcement injection block removed
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


def test_sc6_buildPreImplementationGate_exists():
    """SC-6: buildPreImplementationGate function still exists (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+buildPreImplementationGate\s*\(", src) is not None
    check(has, "buildPreImplementationGate function exists", "SC-6",
          "RED: gate function still present; GREEN will remove it")


def test_sc6_gateBlock_called():
    """SC-6: buildPreImplementationGate is called (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "buildPreImplementationGate(" in src
    check(has, "buildPreImplementationGate() call exists", "SC-6",
          "RED: gate call still present; GREEN will remove it")


def test_sc7_buildCorePrinciplesBlock_exists():
    """SC-7: buildCorePrinciplesBlock function still exists (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+buildCorePrinciplesBlock\s*\(", src) is not None
    check(has, "buildCorePrinciplesBlock function exists", "SC-7",
          "RED: core principles function still present; GREEN will remove it")


def test_sc7_buildSubAgentPrinciplesBlock_exists():
    """SC-7: buildSubAgentPrinciplesBlock function still exists (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+buildSubAgentPrinciplesBlock\s*\(", src) is not None
    check(has, "buildSubAgentPrinciplesBlock function exists", "SC-7",
          "RED: sub-agent principles function still present; GREEN will remove it")


def test_sc7_corePrinciplesBlock_called():
    """SC-7: buildCorePrinciplesBlock is called (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "buildCorePrinciplesBlock(" in src
    check(has, "buildCorePrinciplesBlock() call exists", "SC-7",
          "RED: core principles call still present; GREEN will remove it")


def test_sc8_buildTier1EnforcementBlock_exists():
    """SC-8: buildTier1EnforcementBlock function still exists (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+buildTier1EnforcementBlock\s*\(", src) is not None
    check(has, "buildTier1EnforcementBlock function exists", "SC-8",
          "RED: tier 1 enforcement function still present; GREEN will remove it")


def test_sc8_tier1Block_called():
    """SC-8: buildTier1EnforcementBlock is called (RED signal)."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "buildTier1EnforcementBlock(" in src
    check(has, "buildTier1EnforcementBlock() call exists", "SC-8",
          "RED: tier 1 enforcement call still present; GREEN will remove it")


if __name__ == "__main__":
    print("=== TDD-4 RED Phase ===")
    print(f"Target: {SESSION_ENFORCEMENT}")
    print()
    print("SC-6: Pre-Implementation Gate present")
    test_sc6_buildPreImplementationGate_exists()
    test_sc6_gateBlock_called()
    print()
    print("SC-7: Core Principles present")
    test_sc7_buildCorePrinciplesBlock_exists()
    test_sc7_buildSubAgentPrinciplesBlock_exists()
    test_sc7_corePrinciplesBlock_called()
    print()
    print("SC-8: Tier 1 Mandate Enforcement present")
    test_sc8_buildTier1EnforcementBlock_exists()
    test_sc8_tier1Block_called()
    print()
    print(f"Overall: {'RED signal (code still present — correct)' if OVERALL_RESULT == 0 else 'GREEN signal (code already removed — unexpected)'}")
    sys.exit(OVERALL_RESULT)
