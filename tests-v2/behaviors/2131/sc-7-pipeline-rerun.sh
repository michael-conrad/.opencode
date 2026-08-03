#!/bin/bash
# Behavioral test: 2131-sc-7-pipeline-rerun
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Generalized Parsing Logic Changes preserve pipeline-rerun constraint
# RED phase: Assert the pipeline-rerun constraint text still exists in the
#   Parsing Logic Changes section — test FAILS now because the section
#   still has project-specific paths that will be removed in GREEN.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2131-sc-7-pipeline-rerun"
TARGET_FILE=".opencode/guidelines/080-code-standards.md"

# SC-7: Assert the pipeline-rerun constraint keyword is present
# This should PASS now (constraint exists) — it's a pre-condition check.
# After GREEN, the constraint must still be present in the generalized form.
if grep -q 'pipeline rerun' "$TARGET_FILE"; then
  echo "PASS: pipeline-rerun constraint present in $TARGET_FILE"
else
  echo "FAIL: pipeline-rerun constraint missing from $TARGET_FILE (expected present)"
  exit 1
fi
