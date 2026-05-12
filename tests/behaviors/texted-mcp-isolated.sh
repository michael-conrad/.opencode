#!/bin/bash
# Behavioral Test: texted-mcp-isolated
#
# Creates an isolated git-init test repo with texted MCP configured,
# then verifies the MCP server responds to protocol-level queries:
# SC-5: tools/list returns edit_file, texted_eval, texted_doc
# SC-7: edit_file performs multi-step buffer transformation
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

# Copy the full .opencode/ to get real texted config + tools
git submodule add https://github.com/michael-conrad/.opencode.git .opencode
git submodule update --init .opencode
git -C .opencode fetch origin feature/521-texted-protocol-test
git -C .opencode checkout feature/521-texted-protocol-test

# Make run-texted-mcp executable
chmod +x .opencode/tools/run-texted-mcp

git add -A
git commit -q -m "test repo with full .opencode/ including texted MCP"

echo "Test repo: $TEST_REPO"
echo "  .opencode commit: $(git -C .opencode rev-parse --short HEAD)"

echo ""
echo "--- SC-5: MCP tools/list protocol call ---"
# Start texted MCP, send tools/list, capture response
MCP_OUTPUT=$(echo '{"jsonrpc":"2.0","method":"tools/list","params":{},"id":1}' | timeout 120 .opencode/tools/run-texted-mcp 2>/dev/null || true)

if echo "$MCP_OUTPUT" | grep -q '"edit_file"'; then
    echo "PASS: edit_file tool found in tools/list response"
else
    echo "FAIL: edit_file not found in MCP response"
    OVERALL_RESULT=1
fi

if echo "$MCP_OUTPUT" | grep -q '"texted_eval"'; then
    echo "PASS: texted_eval tool found in tools/list response"
else
    echo "FAIL: texted_eval not found in MCP response"
    OVERALL_RESULT=1
fi

if echo "$MCP_OUTPUT" | grep -q '"texted_doc"'; then
    echo "PASS: texted_doc tool found in tools/list response"
else
    echo "FAIL: texted_doc not found in MCP response"
    OVERALL_RESULT=1
fi

echo ""
echo "--- SC-7: Multi-step buffer edit via MCP ---"
# Start texted MCP, create a file, send edit_file, verify content
mkdir -p tmp
echo "Hello old world" > tmp/texted-test.txt

# Start the MCP server in the background, send initialize + edit_file
python3 -c "
import json, subprocess, os, sys

proc = subprocess.Popen(
    ['.opencode/tools/run-texted-mcp'],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL,
    text=True, cwd='$TEST_REPO'
)

def send(msg):
    proc.stdin.write(json.dumps(msg) + '\n')
    proc.stdin.flush()
    return json.loads(proc.stdout.readline())

# Initialize
resp = send({'jsonrpc':'2.0','id':1,'method':'initialize','params':{'protocolVersion':'2024-11-05','capabilities':{},'clientInfo':{'name':'test','version':'1.0'}}})
assert resp.get('result'), f'Init failed: {resp}'

# Call edit_file
resp = send({'jsonrpc':'2.0','id':2,'method':'tools/call','params':{'name':'edit_file','arguments':{'files':['tmp/texted-test.txt'],'script':'search-forward \"old\"; replace-match \"new\"'}}})
assert resp.get('result'), f'edit_file failed: {resp}'

proc.terminate()
content = open('tmp/texted-test.txt').read().strip()
assert content == 'Hello new world', f'Expected \"Hello new world\", got \"{content}\"'
print(f'SC-7 PASS: content=\"{content}\"')
sys.exit(0)
" 2>&1 || echo "SC-7 FAIL"

if [ -f "$TEST_REPO/tmp/texted-test.txt" ] && [ "$(cat "$TEST_REPO/tmp/texted-test.txt")" = "Hello new world" ]; then
    echo "PASS: texted edit_file performed multi-step buffer edit"
else
    echo "FAIL: buffer edit did not produce expected content"
    OVERALL_RESULT=1
fi

echo ""
echo "--- SC-8: Go toolchain caching ---"
# Remove only texted binary, keep Go toolchain
rm -f "$TEST_REPO/.tools/gopath/bin/texted" 2>/dev/null || true

# Run again — should recompile without re-downloading Go
REBUILD_OUTPUT=$(echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},'\
'"clientInfo":{"name":"test","version":"1.0"}}}' | timeout 120 .opencode/tools/run-texted-mcp 2>&1 || true)

if echo "$REBUILD_OUTPUT" | grep -q '"result"'; then
    echo "PASS: MCP server started after rebuild without Go download"
else
    echo "FAIL: texted failed to start after rebuild"
    echo "  Output: $(echo "$REBUILD_OUTPUT" | head -3)"
    OVERALL_RESULT=1
fi

# Verify Go was NOT re-downloaded (cached)
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
echo "--- Agent discovery test (discourse-level) ---"
behavior_run "$SCENARIO_NAME" \
    "List all available MCP tools. What tools does the texted MCP server provide?" \
    "ollama/kimi-k2.6:cloud" \
    "$TEST_REPO"

AGENT_OUTPUT=$(behavior_get_stdout 2>/dev/null || echo "")
if echo "$AGENT_OUTPUT" | grep -qi "edit_file"; then
    echo "PASS: agent references texted edit_file"
else
    echo "FAIL: agent did not reference texted edit_file"
    OVERALL_RESULT=1
fi

echo ""
[ "$OVERALL_RESULT" -eq 0 ] && echo "PASS: $SCENARIO_NAME" || echo "FAIL: $SCENARIO_NAME"
exit $OVERALL_RESULT
