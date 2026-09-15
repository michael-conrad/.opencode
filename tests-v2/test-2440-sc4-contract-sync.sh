#!/bin/bash
# Structural content-verification test: 2440 SC-4 — contract sync
# Verifies trunk-tip-verification.md Exit Criteria + Result Contract and
# trunk-tip-enforcement.sh assertion sync for safe-state WARN classification.
# RED-phase test — test only, no edits.
set -uo pipefail

TASK_FILE=".opencode/skills/git-workflow-branch/tasks/trunk-tip-verification.md"
ENFORCE_FILE=".opencode/tests-v2/behaviors/trunk-tip-enforcement.sh"
FAILS=0

check() {
    local desc="$1"; shift
    if "$@"; then
        echo "PASS: $desc"
    else
        echo "FAIL: $desc"
        FAILS=$((FAILS + 1))
    fi
}

# Negated variant: assertion holds when the pattern is ABSENT
check_absent() {
    local desc="$1"; shift
    if "$@"; then
        echo "FAIL: $desc"
        FAILS=$((FAILS + 1))
    else
        echo "PASS: $desc"
    fi
}

# ---- (a) Exit Criteria + Result Contract document parent_clean and
# ---- submodule_pointer_match as PASS | WARN | FAIL enums with WARN =
# ---- release-capture-pending

# SC-4a1: Result Contract declares parent_clean as PASS | WARN | FAIL
check "Result Contract: parent_clean PASS | WARN | FAIL enum" \
    grep -qE 'parent_clean: PASS \| WARN \| FAIL' "$TASK_FILE"

# SC-4a2: Result Contract declares submodule_pointer_match as PASS | WARN | FAIL
check "Result Contract: submodule_pointer_match PASS | WARN | FAIL enum" \
    grep -qE 'submodule_pointer_match: PASS \| WARN \| FAIL' "$TASK_FILE"

# SC-4a3: WARN annotations carry release-capture-pending reason on parent_clean
check "Result Contract: parent_clean WARN = release-capture-pending" \
    grep -qE 'parent_clean: PASS \| WARN \| FAIL.*release-capture-pending' "$TASK_FILE"

# SC-4a4: WARN annotations carry release-capture-pending reason on submodule_pointer_match
check "Result Contract: submodule_pointer_match WARN = release-capture-pending" \
    grep -qE 'submodule_pointer_match: PASS \| WARN \| FAIL.*release-capture-pending' "$TASK_FILE"

# Extract Exit Criteria section (between '## Exit Criteria' and next '## ')
EXIT_CRITERIA=$(sed -n '/^## Exit Criteria/,/^## /p' "$TASK_FILE")

# SC-4a5: Exit Criteria documents parent_clean safe-state WARN classification
check "Exit Criteria: parent_clean WARN release-capture-pending documented" \
    grep -qE 'parent_clean.*WARN|WARN.*parent_clean' <<<"$EXIT_CRITERIA"

# SC-4a6: Exit Criteria documents submodule_pointer_match safe-state WARN classification
check "Exit Criteria: submodule_pointer_match WARN release-capture-pending documented" \
    grep -qE 'submodule_pointer_match.*WARN|WARN.*submodule_pointer_match' <<<"$EXIT_CRITERIA"

# ---- (b) They do NOT declare pointer staleness a failure/BLOCKED trigger

# SC-4b1: Exit Criteria does not declare pointer staleness (+ drift) a FAIL/BLOCKED trigger
check_absent "Exit Criteria: no pointer-staleness FAIL/BLOCKED trigger" \
    grep -qE '\+.*prefix.*(FAIL|BLOCKED)|pointer.*(must|MUST).*(match|empty).*(fail|block)' <<<"$EXIT_CRITERIA"

# SC-4b2: Result Contract does not make submodule_pointer_match FAIL-only
check_absent "Result Contract: submodule_pointer_match not FAIL-only" \
    grep -qE 'submodule_pointer_match: PASS \| FAIL$' "$TASK_FILE"

# ---- (c) SUBMODULE_UNMERGED_COMMIT is the only documented BLOCKED trigger

# SC-4c1: SUBMODULE_UNMERGED_COMMIT is documented in the task file
check "Task file: SUBMODULE_UNMERGED_COMMIT documented" \
    grep -q 'SUBMODULE_UNMERGED_COMMIT' "$TASK_FILE"

# SC-4c2: no other *_BLOCKED / BLOCKED_WITH codes besides SUBMODULE_UNMERGED_COMMIT
OTHER_CODES=$(grep -oE '\b[A-Z][A-Z_]{8,}\b' "$TASK_FILE" | grep -v -E '^(SUBMODULE_UNMERGED_COMMIT|DEFAULT_BRANCH|SC|FAIL|WARN|PASS|SKIP|BLOCKED|DONE|HEAD)$' | sort -u | grep -E 'BLOCKED|BLOCK' || true)
check "Task file: no BLOCKED trigger codes other than SUBMODULE_UNMERGED_COMMIT" \
    [ -z "$OTHER_CODES" ]

# SC-4c3: SUBMODULE_UNMERGED_COMMIT appears as the sole named BLOCKED reason
BLOCKED_LINES=$(grep -c 'BLOCKED' "$TASK_FILE")
UNMERGED_LINES=$(grep -c 'SUBMODULE_UNMERGED_COMMIT' "$TASK_FILE")
check "Task file: SUBMODULE_UNMERGED_COMMIT is the sole BLOCKED reason" \
    [ "$UNMERGED_LINES" -ge 1 ] && [ "$UNMERGED_LINES" -eq "$BLOCKED_LINES" ]

# ---- (d) trunk-tip-enforcement.sh assertion sync

# SC-4d1: no stale FAIL assertions on parent_clean safe-state cases
check_absent "Enforcement script: no stale FAIL assertions on parent_clean safe state" \
    grep -qE 'parent_clean.*(FAIL|fail)' "$ENFORCE_FILE"

# SC-4d2: no stale FAIL assertions on submodule_pointer_match safe-state cases
check_absent "Enforcement script: no stale FAIL assertions on submodule_pointer_match safe state" \
    grep -qE 'submodule_pointer_match.*(FAIL|fail)|\+.*prefix.*fail' "$ENFORCE_FILE"

# SC-4d3: SUBMODULE_UNMERGED_COMMIT blocking assertion retained intact
check "Enforcement script: SUBMODULE_UNMERGED_COMMIT blocking assertion present" \
    grep -q 'SUBMODULE_UNMERGED_COMMIT' "$ENFORCE_FILE"

echo ""
echo "Total failures: $FAILS"
[ "$FAILS" -eq 0 ] && exit 0 || exit 1
