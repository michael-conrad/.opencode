#!/bin/bash
# Behavioral test: 2131-sc-2-library-names
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Libraries & Packages section has no project-specific names
#   (NLTK, ConfigurationManager, project-config.ini, 210-scripting.md)
# RED phase: Assert these names are ABSENT — test FAILS now because they exist.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2131-sc-2-library-names"
TARGET_FILE=".opencode/guidelines/080-code-standards.md"

# SC-2: Assert NLTK is NOT present in the Libraries & Packages section
if grep -q 'NLTK' "$TARGET_FILE"; then
  echo "FAIL: NLTK still present in $TARGET_FILE (expected absent for RED)"
  exit 1
else
  echo "PASS: NLTK absent from $TARGET_FILE"
fi
