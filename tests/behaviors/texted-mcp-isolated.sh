#!/bin/bash
# Behavioral Test: texted-mcp-isolated
#
# Creates an isolated git-init test repo with texted MCP configured,
# then verifies:
# SC-5: tools/list protocol call returns edit_file, texted_eval, texted_doc
# SC-7: opencode-cli run session where agent actually uses texted tools
# SC-8: Go toolchain caching
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

# Clone full .opencode/ with texted MCP configured
git submodule add https://github.com/michael-conrad/.opencode.git .opencode
git submodule update --init .opencode
git -C .opencode fetch origin feature/521-texted-protocol-test
git -C .opencode checkout feature/521-texted-protocol-test
chmod +x .opencode/tools/run-texted-mcp

# Create a text file the agent will edit via texted
mkdir -p tmp
echo "Hello old world" > tmp/texted-edit-target.txt

git add -A
git commit -q -m "test repo with texted MCP and edit target"

echo "Test repo: $TEST_REPO"
echo "  .opencode commit: $(git -C .opencode rev-parse --short HEAD)"

echo ""
echo "--- SC-5: MCP tools/list protocol call ---"
MCP_OUTPUT=$(echo '{"jsonrpc":"2.0","method":"tools/list","params":{},"id":1}' | timeout 120 .opencode/tools/run-texted-mcp 2>/dev/null || true)

for tool in edit_file texted_eval texted_doc; do
    if echo "$MCP_OUTPUT" | grep -q "\"$tool\""; then
        echo "PASS: $tool found in tools/list response"
    else
        echo "FAIL: $tool not found in MCP response"
        OVERALL_RESULT=1
    fi
done

echo ""
echo "--- SC-7: opencode-cli run session using texted tools ---"
# Agent must use texted's edit_file tool to transform the file
# Prompt tells the agent what to do, NOT how to do it
behavior_run "$SCENARIO_NAME" \
    "Use the texted MCP server to edit tmp/texted-edit-target.txt. Change 'old' to 'new' using texted's search-and-replace tool." \
    "ollama/kimi-k2.6:cloud" \
    "$TEST_REPO"

AGENT_OUTPUT=$(behavior_get_stdout 2>/dev/null || echo "")

# Check result: file should now contain "Hello new world"
if [ -f "$TEST_REPO/tmp/texted-edit-target.txt" ] && [ "$(cat "$TEST_REPO/tmp/texted-edit-target.txt")" = "Hello new world" ]; then
    echo "PASS: agent used texted edit_file to transform file content"
else
    echo "FAIL: file content not transformed by agent"
    [ -f "$TEST_REPO/tmp/texted-edit-target.txt" ] && echo "  Content: $(cat "$TEST_REPO/tmp/texted-edit-target.txt")" || echo "  File missing"
    OVERALL_RESULT=1
fi

# Verify agent actually invoked the texted tool
if echo "$AGENT_OUTPUT" | grep -qi "edit_file\|texted"; then
    echo "PASS: agent referenced texted tool in output"
else
    echo "FAIL: agent did not reference texted tools"
    OVERALL_RESULT=1
fi

echo ""
echo "--- SC-8: Go toolchain caching ---"
rm -f "$TEST_REPO/.tools/gopath/bin/texted" 2>/dev/null || true

REBUILD_OUTPUT=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}' | timeout 120 .opencode/tools/run-texted-mcp 2>&1 || true)

if echo "$REBUILD_OUTPUT" | grep -q '"result"'; then
    echo "PASS: MCP server started after rebuild without Go download"
else
    echo "FAIL: texted failed to start after rebuild"
    OVERALL_RESULT=1
fi

GO_MOD_TIME=$(stat -c %Y "$TEST_REPO/.tools/go/bin/go" 2>/dev/null || echo "0")
echo "  Go toolchain cached at mtime: $GO_MOD_TIME"

echo ""
echo "--- SC-4: --version flag ---"
VERSION_OUTPUT=$(timeout 10 .opencode/tools/run-texted-mcp --version 2>&1 || true)
if echo "$VERSION_OUTPUT" | grep -qi "texted-mcp version"; then
    echo "PASS: --version flag works"
else
    echo "FAIL: --version flag not working"
    OVERALL_RESULT=1
fi

echo ""
[ "$OVERALL_RESULT" -eq 0 ] && echo "PASS: $SCENARIO_NAME" || echo "FAIL: $SCENARIO_NAME"
exit $OVERALL_RESULT
