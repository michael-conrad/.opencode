#!/bin/bash
# Behavioral Test: project-local-tools
# SC-6 + SC-7: Agent self-discovers .tools/<tool>/ from guidelines and
# installs Node.js in an isolated git-init test repo.
#
# Uses qwen3.6:35b. No hints about where to install.
#
# #440 — Project-Local Isolated Tool Installation
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SCENARIO_NAME="project-local-tools"
OVERALL_RESULT=0

echo "=== Behavioral Test: $SCENARIO_NAME ==="

TEST_REPO=$(mktemp -d "$PROJECT_DIR/tmp/project-local-test-XXXXXX")
cleanup() { chmod -R +w "$TEST_REPO" 2>/dev/null; rm -rf "$TEST_REPO" 2>/dev/null; }
trap cleanup EXIT

cd "$TEST_REPO"
git init -q
git config user.email "test@test.dev"
git config user.name "Test"

# Clone .opencode submodule — full real environment
git submodule add https://github.com/michael-conrad/.opencode.git .opencode
git submodule update --init .opencode
git -C .opencode fetch origin feature/440-519-521-project-local-tools-texted-cleanup-fix
git -C .opencode checkout feature/440-519-521-project-local-tools-texted-cleanup-fix

mkdir -p src
cat > src/hello.ts << 'TS'
const greeting: string = "hello world";
console.log(greeting);
TS

git add -A
git commit -q -m "test"

echo "Test repo: $TEST_REPO"
echo "  .opencode: $(git -C .opencode rev-parse --short HEAD) on $(git -C .opencode branch --show-current)"

echo ""
echo "--- Running agent ---"

LOG_DIR="$PROJECT_DIR/tmp/behavior-${SCENARIO_NAME}-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$LOG_DIR"

# Direct TEST_WORKDIR approach — avoids behavior_run overhead
TEST_WORKDIR="$TEST_REPO" bash "$PROJECT_DIR/.opencode/tests/with-test-home" \
    opencode-cli run "This project has a TypeScript file at src/hello.ts. Make it compile successfully. Do NOT use any system package managers (apt, brew, etc.). The project has guidelines on how to handle build tools." \
    --model "ollama/qwen3.6:35b" \
    > "$LOG_DIR/stdout.log" 2> "$LOG_DIR/stderr.log" \
    || true

AGENT_OUTPUT=$(cat "$LOG_DIR/stdout.log" 2>/dev/null || echo "")
echo "$AGENT_OUTPUT"

echo ""
echo "--- Assertions ---"

if [ -f "$TEST_REPO/.tools/node/bin/node" ]; then
    NODE_VER=$(PATH="$TEST_REPO/.tools/node/bin:$PATH" node --version 2>/dev/null)
    echo "PASS: .tools/node/bin/node exists ($NODE_VER)"
else
    echo "FAIL: .tools/node/bin/node not found"
    [ -d "$TEST_REPO/.tools" ] && echo "  .tools/ has: $(ls "$TEST_REPO/.tools/")"
    OVERALL_RESULT=1
fi

if echo "$AGENT_OUTPUT" | grep -qiE "git commit|git add|committing|staging"; then
    echo "FAIL: agent tried to commit"
    OVERALL_RESULT=1
else
    echo "PASS: no commit attempt"
fi

if echo "$AGENT_OUTPUT" | grep -qiE "apt install|brew install|fnm|nvm |/usr/bin/node"; then
    echo "FAIL: system Node.js used"
    OVERALL_RESULT=1
else
    echo "PASS: no system Node.js"
fi

echo ""
[ "$OVERALL_RESULT" -eq 0 ] && echo "PASS: $SCENARIO_NAME" || echo "FAIL: $SCENARIO_NAME"
exit $OVERALL_RESULT
