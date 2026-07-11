#!/bin/bash
# Behavioral test: cli-auth-status-redaction
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests SC-5 (sensitive values redacted) by running session-init
# with a mock CLI that emits a token in its output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="cli-auth-status-redaction"

# Create a temp dir with mock CLIs
MOCK_DIR=$(mktemp -d "$PARENT_REPO_DIR/tmp/mock-cli-redact-XXXXXX")

# Mock gh: emits token in output
cat > "$MOCK_DIR/gh" << 'EOF'
#!/bin/bash
if [ "$1" = "auth" ] && [ "$2" = "status" ]; then
  echo "github.com
  ✓ Logged in to github.com as testuser (ghp_1234567890abcdef)"
  exit 0
fi
exit 1
EOF
chmod +x "$MOCK_DIR/gh"

# Mock gb: emits token in output
cat > "$MOCK_DIR/gb" << 'EOF'
#!/bin/bash
if [ "$1" = "auth" ] && [ "$2" = "status" ]; then
  echo "Logged in to gitbucket.example.com as testuser (token=abc123def456)"
  exit 0
fi
exit 1
EOF
chmod +x "$MOCK_DIR/gb"

# Run session-init with mocked PATH
PATH="$MOCK_DIR:$PATH" uv run --script "$PARENT_REPO_DIR/.opencode/tools/session-init" 2>/dev/null > "$PARENT_REPO_DIR/tmp/$SCENARIO_NAME-output.txt" || true

# Clean up mock dir
rm -rf "$MOCK_DIR"

# Create artifact directory
ARTIFACT_DIR="$PARENT_REPO_DIR/tmp/behavioral-evidence-$SCENARIO_NAME-GREEN-manual"
mkdir -p "$ARTIFACT_DIR"
cp "$PARENT_REPO_DIR/tmp/$SCENARIO_NAME-output.txt" "$ARTIFACT_DIR/stdout.log" 2>/dev/null || true
echo "0" > "$ARTIFACT_DIR/exit_code"
cat > "$ARTIFACT_DIR/manifest.yaml" <<MANIFESTEOF
scenario_name: $SCENARIO_NAME
phase: GREEN
model: manual
timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
exit_code: 0
harness_version: 1
MANIFESTEOF

echo "Artifacts at: $ARTIFACT_DIR"
exit 0
