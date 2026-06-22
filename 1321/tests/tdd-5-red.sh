#!/usr/bin/env bash
# TDD-5: .opencode/.issues/AGENTS.md is canonical with flat layout (SC-4)
# RED: grep for spec-artifacts/ — should FAIL (flat layout is canonical, no spec-artifacts/)
set -euo pipefail

CANONICAL_FILE=".opencode/.issues/AGENTS.md"
if grep -q "spec-artifacts/" "$CANONICAL_FILE"; then
    echo "FAIL: spec-artifacts/ found in $CANONICAL_FILE — flat layout is NOT canonical"
    exit 1
else
    echo "PASS: spec-artifacts/ NOT found in $CANONICAL_FILE — flat layout is canonical"
    exit 0
fi
