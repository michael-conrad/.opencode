#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Standalone scenario wrapper for test-enforcement.sh __STANDALONE__ dispatch:
# bridges the registered scenario name -> behaviors/2456-sc24-early-
# termination-red.sh with BEHAVIOR_PHASE=RED, then reports PASSED/FAILED
# counts in the log contract test-enforcement.sh greps. Exit contract mirrors
# the behaviors RED script (0=GREEN, 1=RED/confirmed-failing, 2=
# precondition-fail, 3=ALREADY_GREEN-abort); the reported PASSED/FAILED
# counts reflect the predicate verdict — a RED outcome (exit 1) is the
# expected RED-phase result and is reported FAILED here only as the wrapper's
# pass/fail contract, never as a defect; an ALREADY_GREEN abort (exit 3) is
# reported PASSED with the abort cited as the item's genuine outcome record
# (test-driven-development red task).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BEHAVIOR_SCRIPT="$SCRIPT_DIR/behaviors/2456-sc24-early-termination-red.sh"

pass_count=0
fail_count=0
abort_kind=""

behavior_out="/home/muksihs/git/opencode-config/tmp/tmp-2456-sc24-behavior.err"
if BEHAVIOR_PHASE=RED bash "$BEHAVIOR_SCRIPT" > /dev/null 2> "$behavior_out"; then
    pass_count=1
    detail="$(tail -1 "$behavior_out" 2>/dev/null || true)"
else
    rc=$?
    detail="$(tail -3 "$behavior_out" 2>/dev/null | tr '\n' ' ' || true)"
    if [ "$rc" -eq 3 ]; then
        pass_count=1
        abort_kind="ALREADY_GREEN"
    else
        fail_count=1
    fi
fi

if [ "$pass_count" -ge 1 ]; then
    echo "PASSED: $pass_count -- sc24 early-termination predicate confirmed${abort_kind:+ ($abort_kind abort)}: $detail"
else
    echo "FAILED: $fail_count -- sc24 early-termination predicate not satisfied: $detail" >&2
fi
echo "PASSED: $pass_count"
echo "FAILED: $fail_count"

if [ "$fail_count" -gt 0 ]; then
    exit 1
fi
exit 0

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)