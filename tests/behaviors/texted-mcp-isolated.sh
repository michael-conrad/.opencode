#!/bin/bash
# Behavioral Test: texted-mcp-isolated
#
# Creates an isolated test repo with git init and minimal .opencode/ setup,
# includes the texted MCP configuration, and verifies the agent can
# discover texted tools when asked.
#
# This tests the opencode.jsonc MCP configuration for texted in an
# isolated environment — no main project files are used.
#
# SC-4 through SC-6 (reduced): texted MCP tools discoverable
# #521 — texted MCP Server
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="texted-mcp-isolated"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Create isolated test repo
TEST_REPO=$(mktemp -d "$PROJECT_DIR/tmp/texted-test-repo-XXXXXX")
trap "rm -rf '$TEST_REPO'" EXIT

cd "$TEST_REPO"
git init -q
git config user.email "test@test.dev"
git config user.name "Test"
git commit -q --allow-empty -m "init"

# Create .opencode/ structure
mkdir -p .opencode/tools .opencode/guidelines .opencode/skills .opencode/hooks .opencode/plugins .opencode/scripts

# Copy the run-texted-mcp wrapper into the test repo
cp "$PROJECT_DIR/.opencode/tools/run-texted-mcp" .opencode/tools/run-texted-mcp
chmod +x .opencode/tools/run-texted-mcp

# Create minimal AGENTS.md
cat > .opencode/AGENTS.md << 'AGENTS'
# AGENTS.md

github.owner: test
github.repo: test-repo
AGENTS

# Create opencode.jsonc with texted MCP server configured
cat > .opencode/opencode.jsonc << 'JSONC'
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "build": {
      "prompt": "You are an AI coding assistant. Answer questions concisely."
    },
    "plan": {
      "prompt": "You are an AI coding assistant. Answer questions concisely."
    }
  },
  "mcp": {
    "texted": {
      "type": "local",
      "command": [".opencode/tools/run-texted-mcp"],
      "enabled": true
    }
  },
  "instructions": [
    ".opencode/AGENTS.md"
  ]
}
JSONC

# Stage everything in git so .git is clean
git add -A
git commit -q -m "test repo with texted MCP"

echo "Test repo at $TEST_REPO"
echo "  .opencode/tools/run-texted-mcp: $(ls -la .opencode/tools/run-texted-mcp 2>&1)"
echo "  .opencode/opencode.jsonc: $(ls -la .opencode/opencode.jsonc 2>&1)"

# Run the test: ask agent to list MCP tools
echo "--- Running agent prompt ---"
behavior_run "$SCENARIO_NAME" \
    "List all available MCP tools. What tools does the texted MCP server provide? Be specific about each tool's purpose."

# Assertions
echo "--- Assertions ---"

# SC-4: edit_file tool should be mentioned
assert_required_pattern_present "edit_file" "texted edit_file tool" || OVERALL_RESULT=1

# SC-5: texted_eval tool should be mentioned
assert_required_pattern_present "texted_eval" "texted texted_eval tool" || OVERALL_RESULT=1

# SC-6: texted_doc tool should be mentioned
assert_required_pattern_present "texted_doc" "texted texted_doc tool" || OVERALL_RESULT=1

# The texted server name should be mentioned
assert_required_pattern_present "[Tt]exted" "texted MCP server name" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
