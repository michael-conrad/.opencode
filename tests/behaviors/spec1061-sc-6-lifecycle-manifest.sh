#!/bin/bash
# Content-verification test (RED phase): spec1061 SC-6 - lifecycle manifest
# Checks that the lifecycle manifest does NOT exist yet and that the append-only
# spec_created event pattern is NOT present in files (RED = should fail because
# GREEN hasn't generated it)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../.."

OVERALL_RESULT=0
echo "SC-6: Lifecycle manifest created"

# SC-6 requires lifecycle.yaml at  with spec_created event
ARTIFACT=".opencode/.issues/1061/lifecycle.yaml"
if [ -f "$ARTIFACT" ]; then
    echo "  FAIL: $ARTIFACT already exists (GREEN would be no-op)" >&2
    OVERALL_RESULT=1
else
    echo "  PASS: $ARTIFACT does NOT exist (RED confirmed)"
fi

# Check lifecycle manifest generation pattern is not in write.md
WRITE_MD=".opencode/skills/spec-creation/tasks/write.md"
if grep -q "lifecycle\.yaml\|lifecycle_manifest\|lifecycle manifest" "$WRITE_MD" 2>/dev/null; then
    echo "  FAIL: lifecycle manifest pattern already in write.md" >&2
    OVERALL_RESULT=1
fi

# Check implementation-pipeline SKILL.md for lifecycle event emission points
PIPELINE_MD=".opencode/skills/implementation-pipeline/SKILL.md"
if grep -q "lifecycle.*event\|event: spec_created\|lifecycle_yaml\|lifecycle manifest" "$PIPELINE_MD" 2>/dev/null; then
    echo "  FAIL: lifecycle event emission pattern already in implementation-pipeline/SKILL.md" >&2
    OVERALL_RESULT=1
fi

exit $OVERALL_RESULT