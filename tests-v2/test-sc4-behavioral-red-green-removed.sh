#!/usr/bin/env bash
# RED test for SC-4: Behavioral RED/GREEN section removed from 080-code-standards.md
# This test asserts the section does NOT exist.
# Currently it DOES exist, so this test MUST FAIL (RED phase).

set -euo pipefail

TARGET_FILE=".opencode/guidelines/080-code-standards.md"
SECTION_HEADER="Behavioral RED/GREEN as Primary Enforcement Gate"

if grep -q "$SECTION_HEADER" "$TARGET_FILE"; then
  echo "FAIL: Section '$SECTION_HEADER' still exists in $TARGET_FILE"
  exit 1
else
  echo "PASS: Section '$SECTION_HEADER' has been removed from $TARGET_FILE"
  exit 0
fi
