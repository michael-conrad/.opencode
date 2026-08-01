#!/bin/bash
# Structural test: 2211-phase5-reference-paths
# SC-5: All reference doc Read [Text](path) references point to existing files
# (created by .opencode#2210).
#
# The test MUST fail (non-zero exit) if any path is missing.
# The test MUST pass (exit 0) if all paths exist.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
OVERALL_RESULT=0

echo "=== Phase 5 — Verify reference doc paths (SC-5) ==="
echo ""

check_path() {
    local path="$1"
    local label="$2"
    local full_path="$PROJECT_ROOT/.opencode/reference/$path"
    if [ -f "$full_path" ]; then
        echo "  ✅ $label — exists at .opencode/reference/$path"
    else
        echo "  ❌ $label — MISSING at .opencode/reference/$path"
        OVERALL_RESULT=1
    fi
}

check_path "spec-structure-standards.md" "spec-structure-standards.md"
check_path "plan-structure-standards.md" "plan-structure-standards.md"
check_path "cost-model-standards.md" "cost-model-standards.md"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "=== PASS: All reference doc paths exist ==="
else
    echo "=== FAIL: One or more reference doc paths are missing ==="
fi

exit "$OVERALL_RESULT"
