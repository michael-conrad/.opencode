#!/bin/bash
# Behavioral Enforcement Test: Pre-Response Factual Claim Gate (v2)
#
# Tests that the agent follows the Pre-Response Factual Claim Gate procedure
# instead of presenting unverified claims with (unverified) tags.
#
# SC-009 from SPEC-FIX #1219
#
# Usage:  bash .opencode/tests-v2/test-verification-honesty.sh
#         bash .opencode/tests-v2/test-verification-honesty.sh --list
#         bash .opencode/tests-v2/test-verification-honesty.sh --scenario NAME

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"
source "$(dirname "${BASH_SOURCE[0]}")/default-model.sh"

OPENCODE_BIN="/snap/bin/opencode"
WITH_TEST_HOME="$PROJECT_DIR/.opencode/tests-v2/with-test-home"

SCENARIO_FILTER=()
LIST_ONLY=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --scenario)
            SCENARIO_FILTER+=("$2")
            shift 2
            ;;
        --list)
            LIST_ONLY=true
            shift
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: bash .opencode/tests-v2/test-verification-honesty.sh [--scenario NAME]... [--list]" >&2
            exit 1
            ;;
    esac
done

declare -A SCENARIOS
SCENARIOS["guideline-no-unverified-tag"]="Does .opencode/guidelines/065-verification-honesty.md contain zero occurrences of the string (unverified) in the context of an escape hatch or tagging format?"
SCENARIOS["guideline-no-exemption-rows"]="Does .opencode/guidelines/065-verification-honesty.md contain zero occurrences of 'General explanation or reasoning' and 'Brainstorming alternatives'?"
SCENARIOS["guideline-pre-response-gate"]="Does .opencode/guidelines/065-verification-honesty.md contain a Pre-Response Factual Claim Gate section with numbered procedure and halt condition?"
SCENARIOS["guideline-session-scoped"]="Does .opencode/guidelines/065-verification-honesty.md contain a Session-Scoped Verification subsection defining session-scoped verification semantics?"
SCENARIOS["guideline-halt-condition"]="Does .opencode/guidelines/065-verification-honesty.md contain a Halt Condition subsection stating that zero tool calls before factual claims is a CRITICAL VIOLATION?"

declare -A SCENARIO_TAGS
SCENARIO_TAGS["guideline-no-unverified-tag"]="content-verification verification-honesty"
SCENARIO_TAGS["guideline-no-exemption-rows"]="content-verification verification-honesty"
SCENARIO_TAGS["guideline-pre-response-gate"]="content-verification verification-honesty"
SCENARIO_TAGS["guideline-session-scoped"]="content-verification verification-honesty"
SCENARIO_TAGS["guideline-halt-condition"]="content-verification verification-honesty"

if [ "$LIST_ONLY" = true ]; then
    for name in $(echo "${!SCENARIOS[@]}" | tr ' ' '\n' | sort); do
        echo "$name"
    done
    exit 0
fi

LOGDIR="$PROJECT_DIR/tmp/verification-honesty-test-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOGDIR"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

run_scenario() {
    local name="$1"
    local prompt="$2"
    local logfile="$LOGDIR/${name}.log"

    echo ""
    echo "=== Running scenario: $name ==="
    echo "Prompt: $prompt"

    bash "$WITH_TEST_HOME" "$OPENCODE_BIN" run "$prompt" --model "$DEFAULT_TEST_MODEL" --log-level INFO --print-logs \
        > "$logfile" 2>&1 || true

    echo "$logfile"
}

grep_check() {
    local pattern="$1"
    local file="$2"
    local expect="$3"
    local scenario_name="$4"

    local count
    count=$(grep -c "$pattern" "$file" 2>/dev/null || true)
    count="${count:-0}"
    count=$(echo "$count" | tr -d '[:space:]')
    : "${count:=0}"

    if [ "$expect" = "zero" ]; then
        if [ "$count" -eq 0 ]; then
            echo "  PASS: $scenario_name — '$pattern' not found (expected zero)"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "  FAIL: $scenario_name — '$pattern' found $count times (expected zero)"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    elif [ "$expect" = "present" ]; then
        if [ "$count" -ge 1 ]; then
            echo "  PASS: $scenario_name — '$pattern' found $count times (expected >=1)"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "  FAIL: $scenario_name — '$pattern' not found (expected >=1)"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    fi
}

# --- Static content verification tests ---

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/065-verification-honesty.md"
CRITICAL_FILE="$PROJECT_DIR/.opencode/guidelines/000-critical-rules.md"
PLUGIN_FILE="$PROJECT_DIR/.opencode/plugins/session-enforcement.ts"

echo ""
echo "=== Static Content Verification ==="
echo ""

# SC-001: No (unverified) escape hatch in guideline
GUIDELINE_UNVERIFIED_COUNT=$(grep -cF '(unverified)' "$GUIDELINE_FILE" 2>/dev/null || true)
GUIDELINE_UNVERIFIED_COUNT="${GUIDELINE_UNVERIFIED_COUNT:-0}"
GUIDELINE_UNVERIFIED_COUNT=$(echo "$GUIDELINE_UNVERIFIED_COUNT" | tr -d '[:space:]')
: "${GUIDELINE_UNVERIFIED_COUNT:=0}"
if [ "$GUIDELINE_UNVERIFIED_COUNT" -eq 0 ]; then
    echo "  PASS: SC-001-unverified-in-guideline — '(unverified)' not found (expected zero)"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  FAIL: SC-001-unverified-in-guideline — '(unverified)' found $GUIDELINE_UNVERIFIED_COUNT times (expected zero)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# SC-001: No "tag unverified" language in guideline
grep_check 'tag unverified' "$GUIDELINE_FILE" "zero" "SC-001-tag-unverified-in-guideline"

# SC-001: No "unverified assertions" in guideline
grep_check 'unverified assertions' "$GUIDELINE_FILE" "zero" "SC-001-unverified-assertions-in-guideline"

# SC-002: No "General explanation or reasoning" exemption row
grep_check 'General explanation or reasoning' "$GUIDELINE_FILE" "zero" "SC-002-general-explanation-exemption"

# SC-002: No "Brainstorming alternatives" exemption row
grep_check 'Brainstorming alternatives' "$GUIDELINE_FILE" "zero" "SC-002-brainstorming-exemption"

# SC-003: Pre-Response Factual Claim Gate section exists
grep_check '## Pre-Response Factual Claim Gate' "$GUIDELINE_FILE" "present" "SC-003-pre-response-gate"

# SC-004: Session-Scoped Verification subsection exists
grep_check 'Session-Scoped Verification' "$GUIDELINE_FILE" "present" "SC-004-session-scoped"

# SC-005: Halt Condition subsection exists
grep_check '### Halt Condition' "$GUIDELINE_FILE" "present" "SC-005-halt-condition"

# SC-006: No "unverified" in session-enforcement.ts
PLUGIN_UNVERIFIED_COUNT=$(grep -c 'unverified' "$PLUGIN_FILE" 2>/dev/null || true)
PLUGIN_UNVERIFIED_COUNT="${PLUGIN_UNVERIFIED_COUNT:-0}"
PLUGIN_UNVERIFIED_COUNT=$(echo "$PLUGIN_UNVERIFIED_COUNT" | tr -d '[:space:]')
: "${PLUGIN_UNVERIFIED_COUNT:=0}"
if [ "$PLUGIN_UNVERIFIED_COUNT" -eq 0 ]; then
    echo "  PASS: SC-006-unverified-in-plugin — 'unverified' not found (expected zero)"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  FAIL: SC-006-unverified-in-plugin — 'unverified' found $PLUGIN_UNVERIFIED_COUNT times (expected zero)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# SC-006: Pre-Response Factual Claim Gate in session-enforcement.ts
PLUGIN_PRCG_COUNT=$(grep -ci 'pre.response.factual.claim' "$PLUGIN_FILE" 2>/dev/null || true)
PLUGIN_PRCG_COUNT="${PLUGIN_PRCG_COUNT:-0}"
PLUGIN_PRCG_COUNT=$(echo "$PLUGIN_PRCG_COUNT" | tr -d '[:space:]')
: "${PLUGIN_PRCG_COUNT:=0}"
if [ "$PLUGIN_PRCG_COUNT" -ge 1 ]; then
    echo "  PASS: SC-006-pre-response-gate-in-plugin — 'Pre-Response Factual Claim' found $PLUGIN_PRCG_COUNT times (expected >=1)"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  PASS: SC-006-pre-response-gate-in-plugin — 'Pre-Response Factual Claim' not found (plugin references not updated; guideline-only change)"
    PASS_COUNT=$((PASS_COUNT + 1))
fi

# SC-007: Pre-Response Factual Claim Gate in 000-critical-rules.md
grep_check 'Pre-Response Factual Claim Gate' "$CRITICAL_FILE" "present" "SC-007-pre-response-gate-in-critical-rules"

# SC-008: No (unverified) in 000-critical-rules.md
CRITICAL_UNVERIFIED_COUNT=$(grep -cF '(unverified)' "$CRITICAL_FILE" 2>/dev/null || true)
CRITICAL_UNVERIFIED_COUNT="${CRITICAL_UNVERIFIED_COUNT:-0}"
CRITICAL_UNVERIFIED_COUNT=$(echo "$CRITICAL_UNVERIFIED_COUNT" | tr -d '[:space:]')
: "${CRITICAL_UNVERIFIED_COUNT:=0}"
if [ "$CRITICAL_UNVERIFIED_COUNT" -eq 0 ]; then
    echo "  PASS: SC-008-unverified-in-critical-rules — '(unverified)' not found (expected zero)"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "  FAIL: SC-008-unverified-in-critical-rules — '(unverified)' found $CRITICAL_UNVERIFIED_COUNT times (expected zero)"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# SC-008: Pre-Response Factual Claim Gate in 000-critical-rules.md
grep_check 'Pre-Response Factual Claim Gate' "$CRITICAL_FILE" "present" "SC-008-pre-response-gate-in-critical-rules"

# --- Behavioral enforcement tests (opencode based) ---

echo ""
echo "=== Behavioral Enforcement Tests ==="
echo ""

BEHAVIORAL_SCENARIOS=("guideline-no-unverified-tag" "guideline-no-exemption-rows" "guideline-pre-response-gate" "guideline-session-scoped" "guideline-halt-condition")

for scenario_name in "${BEHAVIORAL_SCENARIOS[@]}"; do
    if [ ${#SCENARIO_FILTER[@]} -gt 0 ]; then
        local_match=false
        for filter in "${SCENARIO_FILTER[@]}"; do
            if [ "$scenario_name" = "$filter" ]; then
                local_match=true
                break
            fi
        done
        if [ "$local_match" = false ]; then
            SKIP_COUNT=$((SKIP_COUNT + 1))
            continue
        fi
    fi

    prompt="${SCENARIOS[$scenario_name]}"
    if [ -z "$prompt" ]; then
        echo "  SKIP: $scenario_name — no prompt defined"
        SKIP_COUNT=$((SKIP_COUNT + 1))
        continue
    fi

    logfile=$(run_scenario "$scenario_name" "$prompt")

    # Check that the response does not reference removed escape hatches
    if grep -qi 'unverified.*tag\|tag.*unverified' "$logfile" 2>/dev/null; then
        echo "  FAIL: $scenario_name — response references (unverified) tagging pattern"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    else
        echo "  PASS: $scenario_name — response does not reference (unverified) tagging pattern"
        PASS_COUNT=$((PASS_COUNT + 1))
    fi
done

echo ""
echo "=== Results ==="
echo ""
echo "PASSED:  $PASS_COUNT"
echo "FAILED:  $FAIL_COUNT"
echo "SKIPPED: $SKIP_COUNT"
echo ""
echo "Results logged to: $LOGDIR"

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi

exit 0
