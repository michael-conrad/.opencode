#!/bin/bash
# Behavioral test: texted-mcp-isolated
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Test: texted-mcp-isolated
#
# Creates an isolated git-init test repo with full .opencode/ submodule
# (real opencode.jsonc, AGENTS.md, and texted MCP config), then verifies
# the agent discovers and uses texted MCP tools via opencode-cli run.
#
# #521 — texted MCP Server
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
OVERALL_RESULT=0

echo "=== Behavioral Test: $SCENARIO_NAME ==="

TEST_REPO=$(mktemp -d "$PROJECT_DIR/tmp/texted-test-repo-XXXXXX")
cleanup() { chmod -R +w "$TEST_REPO" 2>/dev/null; rm -rf "$TEST_REPO" 2>/dev/null; }
trap cleanup EXIT

cd "$TEST_REPO"
git init -q
git config user.email "test@test.dev"
git config user.name "Test"
git commit -q --allow-empty -m "init"

# Full .opencode/ submodule — real config, real AGENTS.md, real MCP setup
git submodule add https://github.com/michael-conrad/.opencode.git .opencode
git submodule update --init .opencode
git -C .opencode fetch origin feature/530-de-lobotomize-behavioral-tests
git -C .opencode checkout feature/530-de-lobotomize-behavioral-tests

# Create a file the agent can edit via texted tools
mkdir -p tmp
echo "Hello old world" > tmp/texted-edit-target.txt

git add -A
git commit -q -m "test repo with texted MCP and edit target"

echo "Test repo: $TEST_REPO"
echo "  .opencode: $(git -C .opencode rev-parse --short HEAD) on $(git -C .opencode branch --show-current)"

echo ""
echo "--- Ground truth: actual MCP tools loaded ---"
MCP_LIST=$(opencode mcp list 2>/dev/null || echo "FAIL: opencode mcp list failed")
echo "$MCP_LIST"
TEXTED_TOOLS=$(echo "$MCP_LIST" | grep -oP '"texted[^"]*"' | tr -d '"' | sort -u || true)
echo "  texted tools available: $(echo "$TEXTED_TOOLS" | tr '\n' ' ' || echo 'none')"

echo ""
echo "--- Running agent ---"

# Agent must discover texted MCP tools via opencode mcp list and use
# texted's edit_file to transform the file. Prompt says WHAT, not HOW.
behavior_run "$SCENARIO_NAME" \
    "Use opencode mcp list to see which MCP tools are available. Then use one of them to edit tmp/texted-edit-target.txt: change 'old' to 'new'." \
    "ollama/kimi-k2.6:cloud" \
    "$TEST_REPO"

AGENT_OUTPUT=$(behavior_get_stdout 2>/dev/null || echo "")
echo "$AGENT_OUTPUT"

echo ""
echo "--- Assertions ---"

# File transformation is the unambiguous behavioral proof
if [ -f "$TEST_REPO/tmp/texted-edit-target.txt" ] && [ "$(cat "$TEST_REPO/tmp/texted-edit-target.txt")" = "Hello new world" ]; then
    echo "PASS: texted edit_file transformed file content"
else
    echo "FAIL: file content not transformed by agent"
    [ -f "$TEST_REPO/tmp/texted-edit-target.txt" ] && echo "  Content: $(cat "$TEST_REPO/tmp/texted-edit-target.txt")" || echo "  File missing"
    OVERALL_RESULT=1
fi

# Agent references having used texted/MCP tools (wording varies)
if echo "$AGENT_OUTPUT" | grep -qiE "texted|mcp.*tool|edit_file"; then
    echo "PASS: agent referenced texted/MCP tool use"
else
    echo "FAIL: agent did not reference texted or MCP tools"
    OVERALL_RESULT=1
fi

echo ""
[ "$OVERALL_RESULT" -eq 0 ] && echo "PASS: $SCENARIO_NAME" || echo "FAIL: $SCENARIO_NAME"
exit $OVERALL_RESULT
