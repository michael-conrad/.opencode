#!/bin/bash
# Behavioral test: 2131-sc-1-parsing-paths
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Parsing Logic Changes section has no project-specific paths
#   (src/commons/parsing/, 0100_ingest_xml.ipynb)
# RED phase: Assert these paths are ABSENT — test FAILS now because they exist.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2131-sc-1-parsing-paths"
TARGET_FILE=".opencode/guidelines/080-code-standards.md"

# SC-1: Assert src/commons/parsing/ is NOT present in the Parsing Logic Changes section
# This will FAIL (exit non-zero) because the path currently exists — that's RED.
if grep -q 'src/commons/parsing/' "$TARGET_FILE"; then
  echo "FAIL: src/commons/parsing/ still present in $TARGET_FILE (expected absent for RED)"
  exit 1
else
  echo "PASS: src/commons/parsing/ absent from $TARGET_FILE"
fi
