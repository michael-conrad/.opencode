#!/usr/bin/env bash
# RED test for SC-3 (#2243): The carveout for `.opencode/` infrastructure tools
# SHALL be documented within the DI section (contained within SC-1).
#
# The DI section is the `## Dependency Injection` section in
# `.opencode/guidelines/082-python-standards.md`. SC-3 requires this section to
# document all three carveout paths:
#   - `.opencode/tools/`
#   - `.opencode/scripts/`
#   - `.opencode/skills/*/scripts/`
#
# SC-3 is structural evidence — a content-verification (grep) check is the
# appropriate evidence type per the spec's declared type.
#
# NOTE: SC-3's carveout was co-delivered with SC-1's GREEN (the DI section in
# `082-python-standards.md` already documents the carveout). Consequently this RED
# test may already PASS. That is acceptable — report the actual state truthfully
# rather than forcing a false failure.
#
# Usage: bash .opencode/tests-v2/test-sc3-di-carveout-doc.sh
# Exit: 0 if the DI section documents all three carveout paths, 1 otherwise.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/082-python-standards.md"

# Extract the `## Dependency Injection` section from the guideline file.
# DI_SECTION spans from the `## Dependency Injection` heading to the next `## `
# heading (or end of file).
DI_SECTION=$(awk '/^## Dependency Injection$/{flag=1; next} /^## /{flag=0} flag' "$GUIDELINE_FILE")

PASS_COUNT=0
FAIL_COUNT=0

echo ""
echo "=== SC-3 (#2243): DI section documents all three carveout paths ==="
echo ""

if [ -z "$DI_SECTION" ]; then
    echo "  FAIL: no '## Dependency Injection' section found in 082-python-standards.md"
    FAIL_COUNT=$((FAIL_COUNT + 1))
else
    echo "  DI section extracted (${#DI_SECTION} chars)."
    for pattern in ".opencode/tools/" ".opencode/scripts/" ".opencode/skills/*/scripts/"; do
        # SC-3: carveout path present in the DI section.
        if echo "$DI_SECTION" | grep -Fq "$pattern"; then
            echo "  PASS: DI section documents carveout path \"$pattern\""
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "  FAIL: DI section does NOT document carveout path \"$pattern\""
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    done
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: DI carveout paths not yet present in the DI section."
    echo "Note: SC-3 was co-delivered with SC-1; if all three paths are already"
    echo "documented, this test legitimately PASSES at RED time."
    echo ""
    exit 1
fi
exit 0
