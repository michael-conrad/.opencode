#!/usr/bin/env bash
# RED test for SC-2 (issue 2469).
# GREEN condition: the repo-scope qualifier + Read-link exist in the
# cost-blind verification clause of .opencode/guidelines/020-go-prohibitions.md §1.
# RED: qualifier not yet present -> this test FAILS (exit 1).
set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FILE="$REPO_ROOT/guidelines/020-go-prohibitions.md"
LOG_DIR="$REPO_ROOT/../tmp/2469/artifacts"
mkdir -p "$LOG_DIR"

# Extract the cost-blind clause paragraph.
clause=$(grep -n "Resource cost is NEVER a factor in verification decisions" "$FILE" || true)
if [ -z "$clause" ]; then
    echo "FAIL: cost-blind clause not found at all" | tee "$LOG_DIR/pipeline-red-2469-sc2.log"
    exit 1
fi

# GREEN requires BOTH: the repo-scope qualifier AND a Read-link to the SC-1
# anchor ("## Scope Anchor" in .opencode/tests-v2/AGENTS.md) within the
# cost-blind clause block.
if ! grep -q "## Scope Anchor" "$REPO_ROOT/tests-v2/AGENTS.md"; then
    echo "FAIL: SC-1 '## Scope Anchor' missing from tests-v2/AGENTS.md" | tee "$LOG_DIR/pipeline-red-2469-sc2.log"
    exit 1
fi

# Check the clause block (from the resource-cost line through the FORBIDDEN
# bullets) for the scope qualifier + Read-link.
start=$(grep -n "Resource cost is NEVER a factor in verification decisions" "$FILE" | cut -d: -f1)
block=$(sed -n "${start},$((start+10))p" "$FILE")

if ! printf '%s\n' "$block" | grep -qi "scope qualifier\|repo-scope\|\.opencode-targeted work only"; then
    echo "FAIL RED: repo-scope qualifier absent from cost-blind clause (SC-2 not yet implemented)" | tee "$LOG_DIR/pipeline-red-2469-sc2.log"
    exit 1
fi

if ! printf '%s\n' "$block" | grep -q "Read \[.*\](.*tests-v2/AGENTS.md.*#.*scope-anchor\|Read \[.*\](.*## Scope Anchor"; then
    echo "FAIL RED: Read-link to SC-1 Scope Anchor absent from cost-blind clause (SC-2 not yet implemented)" | tee "$LOG_DIR/pipeline-red-2469-sc2.log"
    exit 1
fi

echo "PASS: SC-2 qualifier + Read-link present" | tee "$LOG_DIR/pipeline-red-2469-sc2.log"
exit 0