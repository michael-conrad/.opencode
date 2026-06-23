#!/usr/bin/env python3
"""TDD-4 GREEN phase: Verify gate blocks are removed.

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


def test_sc6_buildPreImplementationGate_absent():
    """SC-6: buildPreImplementationGate function removed."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+buildPreImplementationGate\s*\(", src) is not None
    check(not has, "buildPreImplementationGate function absent", "SC-6", "Gate function removed")


def test_sc6_gateBlock_not_called():
    """SC-6: buildPreImplementationGate is no longer called."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "buildPreImplementationGate(" in src
    check(not has, "buildPreImplementationGate() call absent", "SC-6", "Gate call removed")


def test_sc7_buildCorePrinciplesBlock_absent():
    """SC-7: buildCorePrinciplesBlock function removed."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+buildCorePrinciplesBlock\s*\(", src) is not None
    check(not has, "buildCorePrinciplesBlock function absent", "SC-7", "Core principles function removed")


def test_sc7_buildSubAgentPrinciplesBlock_absent():
    """SC-7: buildSubAgentPrinciplesBlock function removed."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+buildSubAgentPrinciplesBlock\s*\(", src) is not None
    check(not has, "buildSubAgentPrinciplesBlock function absent", "SC-7", "Sub-agent principles function removed")


def test_sc7_corePrinciplesBlock_not_called():
    """SC-7: buildCorePrinciplesBlock is no longer called."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "buildCorePrinciplesBlock(" in src
    check(not has, "buildCorePrinciplesBlock() call absent", "SC-7", "Core principles call removed")


def test_sc8_buildTier1EnforcementBlock_absent():
    """SC-8: buildTier1EnforcementBlock function removed."""
    src = SESSION_ENFORCEMENT.read_text()
    has = re.search(r"function\s+buildTier1EnforcementBlock\s*\(", src) is not None
    check(not has, "buildTier1EnforcementBlock function absent", "SC-8", "Tier 1 enforcement function removed")


def test_sc8_tier1Block_not_called():
    """SC-8: buildTier1EnforcementBlock is no longer called."""
    src = SESSION_ENFORCEMENT.read_text()
    has = "buildTier1EnforcementBlock(" in src
    check(not has, "buildTier1EnforcementBlock() call absent", "SC-8", "Tier 1 enforcement call removed")


def test_echoParts_only_triggers():
    """SC-6/7/8: echoParts only contains trigger block (no gate/principles/tier1)."""
    src = SESSION_ENFORCEMENT.read_text()
    has_gate = "gateBlock" in src
    has_principles = "corePrinciplesBlock" in src
    has_tier1 = "tier1Block" in src
    check(
        not has_gate and not has_principles and not has_tier1,
        "echoParts contains only trigger block",
        "SC-6/7/8",
        f"gateBlock: {'found' if has_gate else 'absent'}, corePrinciplesBlock: {'found' if has_principles else 'absent'}, tier1Block: {'found' if has_tier1 else 'absent'}",
    )


if __name__ == "__main__":
    print("=== TDD-4 GREEN Phase ===")
    print(f"Target: {SESSION_ENFORCEMENT}")
    print()
    print("SC-6: Pre-Implementation Gate removed")
    test_sc6_buildPreImplementationGate_absent()
    test_sc6_gateBlock_not_called()
    print()
    print("SC-7: Core Principles removed")
    test_sc7_buildCorePrinciplesBlock_absent()
    test_sc7_buildSubAgentPrinciplesBlock_absent()
    test_sc7_corePrinciplesBlock_not_called()
    print()
    print("SC-8: Tier 1 Mandate Enforcement removed")
    test_sc8_buildTier1EnforcementBlock_absent()
    test_sc8_tier1Block_not_called()
    print()
    print("Combined: echoParts cleanup")
    test_echoParts_only_triggers()
    print()
    print(f"Overall: {'PASS' if OVERALL_RESULT == 0 else 'FAIL'}")
    sys.exit(OVERALL_RESULT)
