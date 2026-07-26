#!/bin/bash
# Behavioral test: verify-recording-readback
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: The verify-recording task checks that spec.md frontmatter has
# status: approved, comments.yaml has the authorization record, and issue.yaml
# has the label — and returns BLOCKED if any are missing or corrupted.
#
# Four scenarios:
#   sc9-all-present:  All three files have correct state → verify-recording returns PASS
#   sc9-missing-spec: spec.md frontmatter missing status: approved → BLOCKED
#   sc9-missing-comments: comments.yaml missing authorization record → BLOCKED
#   sc9-missing-label: issue.yaml missing approved-for-* label → BLOCKED

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-9a: All three files have correct state → verify-recording returns PASS
SCENARIO_ALL_PRESENT="verify-recording-sc9-all-present"
PROMPT_ALL_PRESENT="Approved issue #42 for implementation. The authorization has been recorded: spec.md has status: approved, comments.yaml has the authorization record, and issue.yaml has the approved-for-implementation label. Run the verify-recording step to confirm all three files have the correct authorization state."

echo "=== SC-9a: All three files correct → verify-recording returns PASS ==="
behavior_run "$SCENARIO_ALL_PRESENT" "$PROMPT_ALL_PRESENT"

# SC-9b: spec.md frontmatter missing status: approved → BLOCKED
SCENARIO_MISSING_SPEC="verify-recording-sc9-missing-spec"
PROMPT_MISSING_SPEC="Approved issue #42 for implementation. The authorization was recorded but spec.md frontmatter is missing status: approved. Run the verify-recording step and report the specific reason it fails."

echo "=== SC-9b: spec.md missing status: approved → BLOCKED ==="
behavior_run "$SCENARIO_MISSING_SPEC" "$PROMPT_MISSING_SPEC"

# SC-9c: comments.yaml missing authorization record → BLOCKED
SCENARIO_MISSING_COMMENTS="verify-recording-sc9-missing-comments"
PROMPT_MISSING_COMMENTS="Approved issue #42 for implementation. The authorization was recorded but comments.yaml is missing the authorization record. Run the verify-recording step and report the specific reason it fails."

echo "=== SC-9c: comments.yaml missing authorization record → BLOCKED ==="
behavior_run "$SCENARIO_MISSING_COMMENTS" "$PROMPT_MISSING_COMMENTS"

# SC-9d: issue.yaml missing approved-for-* label → BLOCKED
SCENARIO_MISSING_LABEL="verify-recording-sc9-missing-label"
PROMPT_MISSING_LABEL="Approved issue #42 for implementation. The authorization was recorded but issue.yaml is missing the approved-for-implementation label. Run the verify-recording step and report the specific reason it fails."

echo "=== SC-9d: issue.yaml missing approved-for-* label → BLOCKED ==="
behavior_run "$SCENARIO_MISSING_LABEL" "$PROMPT_MISSING_LABEL"

exit 0
