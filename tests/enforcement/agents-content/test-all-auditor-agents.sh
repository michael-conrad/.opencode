#!/bin/bash
# Content-Verification Test: All 7 Auditor Agent Files — Canonical Schema Validation
#
# Validates that each of the 7 auditor agent files in .opencode/agents/
# has correct YAML frontmatter per spec #381 canonical schema:
#   - mode: subagent
#   - model: <expected model string>
#   - permission: block with 6 allow + 5 deny keys
#
# SC-7 from Spec #381: all 7 agent files have correct permission surface (6 allow, 5 deny)
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$SCRIPT_DIR")" != ".opencode" ]; do
    SCRIPT_DIR="$(dirname "$SCRIPT_DIR")"
done
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="$SCRIPT_DIR/agents"

declare -A MODELS
MODELS["auditor-deepseek-flash"]="ollama/deepseek-v4-flash:cloud"
MODELS["auditor-deepseek-v3"]="ollama/deepseek-v3.2:cloud"
MODELS["auditor-glm-5.1"]="ollama/glm-5.1:cloud"
MODELS["auditor-glm-5"]="ollama/glm-5:cloud"
MODELS["auditor-mistral-large"]="ollama/mistral-large-3:675b-cloud"
MODELS["auditor-kimi-k2"]="ollama/kimi-k2.6:cloud"
MODELS["auditor-qwen3.5"]="ollama/qwen3.5:397b-cloud"

ALLOW_KEYS=("read" "glob" "grep" "skill" "webfetch" "websearch")
DENY_KEYS=("edit" "bash" "task" "todowrite" "question")
EXPECTED_ALLOW=${#ALLOW_KEYS[@]}
EXPECTED_DENY=${#DENY_KEYS[@]}
EXPECTED_COUNT=${#MODELS[@]}
EXPECTED_PERM_TOTAL=$(( EXPECTED_ALLOW + EXPECTED_DENY ))

FAILURES=0

echo "=== Content-Verification: Auditor Agent Files Canonical Schema ==="
echo ""

if [ ! -d "$AGENTS_DIR" ]; then
    echo "FAIL: .opencode/agents/ directory does not exist"
    FAILURES=1
else
    echo "PASS: .opencode/agents/ directory exists"
fi
echo ""

echo "--- File Existence ($EXPECTED_COUNT expected) ---"
EXIST_COUNT=0
for agent in "${!MODELS[@]}"; do
    FILE="$AGENTS_DIR/${agent}.md"
    if [ -f "$FILE" ]; then
        echo "PASS: ${agent}.md exists"
        EXIST_COUNT=$((EXIST_COUNT + 1))
    else
        echo "FAIL: ${agent}.md does not exist"
        FAILURES=1
    fi
done

if [ "$EXIST_COUNT" -ne "$EXPECTED_COUNT" ]; then
    echo "FAIL: Expected $EXPECTED_COUNT agent files, found $EXIST_COUNT"
    FAILURES=1
else
    echo "PASS: All $EXPECTED_COUNT agent files exist"
fi
echo ""

echo "--- YAML Frontmatter Validation (6 allow + 5 deny) ---"
for agent in "${!MODELS[@]}"; do
    FILE="$AGENTS_DIR/${agent}.md"
    EXPECTED_MODEL="${MODELS[$agent]}"

    if [ ! -f "$FILE" ]; then
        echo "SKIP: ${agent}.md (file missing, cannot validate frontmatter)"
        continue
    fi

    FILE_FAILURES=0

    FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$FILE" | sed '1d' | sed '$d')

    if [ -z "$FRONTMATTER" ]; then
        echo "FAIL: ${agent}.md has no YAML frontmatter"
        FAILURES=1
        continue
    fi

    MODE=$(echo "$FRONTMATTER" | grep '^mode:' | sed 's/^mode:[[:space:]]*//' | tr -d '"' | tr -d "'")
    if [ "$MODE" != "subagent" ]; then
        echo "FAIL: ${agent}.md mode: expected 'subagent', got '$MODE'"
        FILE_FAILURES=1
    fi

    ACTUAL_MODEL=$(echo "$FRONTMATTER" | grep '^model:' | sed 's/^model:[[:space:]]*//' | tr -d '"' | tr -d "'")
    if [ "$ACTUAL_MODEL" != "$EXPECTED_MODEL" ]; then
        echo "FAIL: ${agent}.md model: expected '$EXPECTED_MODEL', got '$ACTUAL_MODEL'"
        FILE_FAILURES=1
    fi

    if echo "$FRONTMATTER" | grep -q '^permissions:'; then
        echo "FAIL: ${agent}.md uses 'permissions:' (plural) — must use 'permission:' (singular)"
        FILE_FAILURES=1
    fi

    PERM_BLOCK=$(echo "$FRONTMATTER" | sed -n '/^permission:/,$p')
    if [ -z "$PERM_BLOCK" ]; then
        echo "FAIL: ${agent}.md has no 'permission:' block"
        FILE_FAILURES=1
        if [ "$FILE_FAILURES" -gt 0 ]; then
            FAILURES=1
        fi
        continue
    fi

    for key in "${ALLOW_KEYS[@]}"; do
        VAL=$(echo "$PERM_BLOCK" | grep "^  ${key}:" | sed "s/^  ${key}:[[:space:]]*//" | tr -d '"' | tr -d "'")
        if [ "$VAL" != "allow" ]; then
            echo "FAIL: ${agent}.md permission.${key}: expected 'allow', got '$VAL'"
            FILE_FAILURES=1
        fi
    done

    for key in "${DENY_KEYS[@]}"; do
        VAL=$(echo "$PERM_BLOCK" | grep "^  ${key}:" | sed "s/^  ${key}:[[:space:]]*//" | tr -d '"' | tr -d "'")
        if [ "$VAL" != "deny" ]; then
            echo "FAIL: ${agent}.md permission.${key}: expected 'deny', got '$VAL'"
            FILE_FAILURES=1
        fi
    done

    PERM_LINE_COUNT=$(echo "$PERM_BLOCK" | grep -c "^  [a-z]" || true)
    if [ "$PERM_LINE_COUNT" -ne "$EXPECTED_PERM_TOTAL" ]; then
        echo "FAIL: ${agent}.md has $PERM_LINE_COUNT permission keys, expected $EXPECTED_PERM_TOTAL ($EXPECTED_ALLOW allow + $EXPECTED_DENY deny)"
        FILE_FAILURES=1
    fi

    if [ "$FILE_FAILURES" -eq 0 ]; then
        echo "PASS: ${agent}.md — mode=subagent, model='$EXPECTED_MODEL', permissions $EXPECTED_ALLOW allow + $EXPECTED_DENY deny"
    else
        FAILURES=1
    fi
done

echo ""
if [ "$FAILURES" -eq 0 ]; then
    echo "=== RESULT: PASS ==="
    exit 0
else
    echo "=== RESULT: FAIL ==="
    exit 1
fi
