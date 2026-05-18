#!/bin/bash
# Behavioral Enforcement Test: Platform Routing Enforcement
#
# Verifies that:
# (a) 000-critical-rules.md contains Platform Routing Bypass violation (Tier 1)
# (b) 000-critical-rules.md contains Platform API Deliberation Prohibited (Tier 2)
# (c) SKILL.md task table has 7 new read/query task entries
# (d) No direct github_* issue calls exist outside issue-operations/platforms/
#
# SC-4: Platform Routing Bypass violation exists (content verification)
# SC-5: Platform API Deliberation Prohibited violation exists (content verification)
# SC-6: SKILL.md has 7 new read/query task entries (content verification)
# SC-7: Zero direct github_* issue calls outside issue-operations/platforms/ (content verification)
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PROJECT_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
while [ "$(basename "$PROJECT_ROOT")" != ".opencode" ]; do
    PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"

SCENARIO_NAME="platform-routing-enforcement"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# SC-4: 000-critical-rules.md contains Platform Routing Bypass violation section (Tier 1)
echo "--- SC-4: Platform Routing Bypass violation in 000-critical-rules.md ---"
CRITICAL_RULES="$PROJECT_ROOT/.opencode/guidelines/000-critical-rules.md"
if [ -f "$CRITICAL_RULES" ]; then
    if grep -qi "Platform Routing Bypass\|platform-routing-bypass" "$CRITICAL_RULES"; then
        echo "PASS: SC-4 — Platform Routing Bypass section found in 000-critical-rules.md"
    else
        echo "FAIL: SC-4 — Platform Routing Bypass section NOT found in 000-critical-rules.md"
        OVERALL_RESULT=1
    fi
    if grep -q "critical-rules-platform-routing-bypass" "$CRITICAL_RULES"; then
        echo "PASS: SC-4 — yaml+symbolic rule critical-rules-platform-routing-bypass found"
    else
        echo "FAIL: SC-4 — yaml+symbolic rule critical-rules-platform-routing-bypass NOT found"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: 000-critical-rules.md not found"
    OVERALL_RESULT=1
fi

# SC-5: 000-critical-rules.md contains Platform API Deliberation Prohibited section (Tier 2)
echo "--- SC-5: Platform API Deliberation Prohibited in 000-critical-rules.md ---"
if [ -f "$CRITICAL_RULES" ]; then
    if grep -qi "Platform API Deliberation Prohibited\|platform-api-deliberation" "$CRITICAL_RULES"; then
        echo "PASS: SC-5 — Platform API Deliberation Prohibited section found in 000-critical-rules.md"
    else
        echo "FAIL: SC-5 — Platform API Deliberation Prohibited section NOT found in 000-critical-rules.md"
        OVERALL_RESULT=1
    fi
    if grep -q "critical-rules-platform-api-deliberation" "$CRITICAL_RULES"; then
        echo "PASS: SC-5 — yaml+symbolic rule critical-rules-platform-api-deliberation found"
    else
        echo "FAIL: SC-5 — yaml+symbolic rule critical-rules-platform-api-deliberation NOT found"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: 000-critical-rules.md not found"
    OVERALL_RESULT=1
fi

# SC-6: SKILL.md task table has 7 new read/query task entries
echo "--- SC-6: SKILL.md has 7 new read/query task entries ---"
SKILL_FILE="$PROJECT_ROOT/.opencode/skills/issue-operations/SKILL.md"
if [ -f "$SKILL_FILE" ]; then
    MISSING_TASKS=""
    FOUND_COUNT=0
    for task in read-issue read-comments read-labels read-sub-issues list-issues search-issues update-issue; do
        if grep -q "$task" "$SKILL_FILE"; then
            FOUND_COUNT=$((FOUND_COUNT + 1))
        else
            MISSING_TASKS="$MISSING_TASKS $task"
        fi
    done

    if [ "$FOUND_COUNT" -eq 7 ]; then
        echo "PASS: SC-6 — All 7 read/query task entries found in SKILL.md task table"
    else
        echo "FAIL: SC-6 — Only $FOUND_COUNT/7 task entries found. Missing:$MISSING_TASKS"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: SKILL.md not found"
    OVERALL_RESULT=1
fi

# SC-7: Content verification — new dispatcher tasks route through platforms/, not bypass dispatcher
echo "--- SC-7: New dispatcher tasks route through platforms/ ---"
ROUTING_MISSING_COUNT=0
TASKS_DIR="$PROJECT_ROOT/.opencode/skills/issue-operations/tasks"
if [ -d "$TASKS_DIR" ]; then
    for taskfile in "$TASKS_DIR"/read-issue.md "$TASKS_DIR"/read-comments.md "$TASKS_DIR"/read-labels.md "$TASKS_DIR"/read-sub-issues.md "$TASKS_DIR"/list-issues.md "$TASKS_DIR"/search-issues.md "$TASKS_DIR"/update-issue.md; do
        if [ -f "$taskfile" ]; then
            basename_file="$(basename "$taskfile")"
            # Verify the task file routes through platforms/ (has "Resolve Platform" step)
            if ! grep -qi "Resolve Platform\|Route based on\|platform sub-skill\|platforms/" "$taskfile"; then
                echo "FAIL: SC-7 — $basename_file does not route through platforms/ (no platform routing step)"
                ROUTING_MISSING_COUNT=$((ROUTING_MISSING_COUNT + 1))
            fi
            # Verify the task file mentions the dispatcher routing principle
            if ! grep -qi "dispatcher\|routes to\|route.*platform\|no direct" "$taskfile"; then
                echo "FAIL: SC-7 — $basename_file does not mention dispatcher routing (no routing principle)"
                ROUTING_MISSING_COUNT=$((ROUTING_MISSING_COUNT + 1))
            fi
        fi
    done
fi

if [ "$ROUTING_MISSING_COUNT" -eq 0 ]; then
    echo "PASS: SC-7 — All new dispatcher task files route through platforms/"
else
    echo "FAIL: SC-7 — $ROUTING_MISSING_COUNT routing verification(s) missing in dispatcher task files"
    OVERALL_RESULT=1
fi

# Additional: 060-tool-usage.md contains Platform Routing Mandate subsection
echo "--- Additional: Platform Routing Mandate in 060-tool-usage.md ---"
TOOL_USAGE="$PROJECT_ROOT/.opencode/guidelines/060-tool-usage.md"
if [ -f "$TOOL_USAGE" ]; then
    if grep -qi "Platform Routing Mandate\|issue-operations dispatcher\|routes through.*issue-operations" "$TOOL_USAGE"; then
        echo "PASS: Platform Routing Mandate found in 060-tool-usage.md"
    else
        echo "FAIL: Platform Routing Mandate NOT found in 060-tool-usage.md"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: 060-tool-usage.md not found"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT