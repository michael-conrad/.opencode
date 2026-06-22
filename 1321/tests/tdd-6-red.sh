#!/usr/bin/env bash
# TDD-6: .issues/AGENTS.md references canonical layout (SC-4)
# RED: grep for canonical/see cross-reference — should FAIL (no cross-reference exists)
set -euo pipefail

ROOT_FILE=".issues/AGENTS.md"
if grep -qiE "canonical|see also|see:|cross-ref" "$ROOT_FILE"; then
    echo "PASS: cross-reference found in $ROOT_FILE"
    exit 0
else
    echo "FAIL: no cross-reference to canonical found in $ROOT_FILE"
    exit 1
fi
