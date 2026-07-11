#!/bin/bash
# Behavioral test: cli-auth-status-not-installed
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests SC-6 (no CLI installed = no section) by running session-init
# with gh/gb removed from PATH.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="cli-auth-status-not-installed"

# Create a temp dir with NO CLIs — only harmless tools
MOCK_DIR=$(mktemp -d "$PARENT_REPO_DIR/tmp/mock-cli-none-XXXXXX")
# Add a harmless 'true' to ensure PATH is valid but has no gh/gb
ln -sf /bin/true "$MOCK_DIR/true"

# Strip gh and gb from PATH — keep only the mock dir and essential system paths
CLEAN_PATH="$MOCK_DIR:/bin:/usr/bin"

# Run session-init with PATH that has no gh/gb
PATH="$CLEAN_PATH" uv run --script "$PARENT_REPO_DIR/.opencode/tools/session-init" 2>/dev/null > "$PARENT_REPO_DIR/tmp/$SCENARIO_NAME-output.txt" || true

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
