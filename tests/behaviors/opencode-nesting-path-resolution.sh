#!/bin/bash
# Behavioral test: opencode-nesting-path-resolution
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral enforcement test: .opencode/.opencode/ path nesting
# Verifies the agent composes paths correctly when workdir is inside .opencode/
# (e.g., submodule context) — must use "tmp" not ".opencode/tmp".
#
# Tags: opencode-nesting, workdir-aware, path-resolution, submodule
#
# Co-authored with AI: OpenCode (unknown (version detection failed))

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO="opencode-nesting-path-resolution"
MESSAGE="Create a temporary directory named .opencode/tmp/test-nesting for this session's output. Report the directory path you created."

echo ""
echo "========== Behavioral Test: opencode-nesting-path-resolution =========="
echo ""
echo "Prompt: $MESSAGE"
echo ""

behavior_run "$SCENARIO" "$MESSAGE"

echo ""
echo "--- Verdicts ---"
echo ""

PASSES=0
FAILS=0

# V1: Assert the agent did NOT issue tool calls that create .opencode/.opencode/ nesting
# (grep -qF catches guideline text in system prompt — tautological)
# Target only tool-call-command patterns that would produce nesting
OUTPUT=$(behavior_get_stdout)
if echo "$OUTPUT" | grep -qE '(mkdir|write|filePath|path.*=).*\.opencode[/]+\.opencode[/]'; then
    echo "FAIL: V1 — agent tool call creates .opencode/.opencode/ nested path"
    FAILS=$((FAILS + 1))
else
    echo "PASS: V1 — no agent tool call creates .opencode/.opencode/ nested path"
    PASSES=$((PASSES + 1))
fi

# V2: Assert the agent uses path relative to workdir when in submodule context
# When workdir is .opencode/, the correct path is tmp/ not .opencode/tmp/
if echo "$OUTPUT" | grep -qE '\b(tmp/test-nesting|tmp/)\b'; then
    echo "PASS: V2 — agent used workdir-relative path (tmp/...)"
    PASSES=$((PASSES + 1))
elif echo "$OUTPUT" | grep -q '.opencode/tmp/test-nesting'; then
    echo "FAIL: V2 — agent used .opencode/tmp/ when workdir is inside .opencode/"
    FAILS=$((FAILS + 1))
else
    echo "INCONCLUSIVE: V2 — could not determine path resolution in output"
fi

# V3: Assert no nested .opencode/.opencode/tmp directory was created on disk
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
if [ -d "$PROJECT_ROOT/.opencode/.opencode/tmp" ]; then
    echo "FAIL: V3 — .opencode/.opencode/tmp/ directory exists on disk"
    FAILS=$((FAILS + 1))
elif [ -d "$PROJECT_ROOT/.opencode/.opencode" ]; then
    echo "FAIL: V3 — .opencode/.opencode/ directory exists on disk"
    FAILS=$((FAILS + 1))
else
    echo "PASS: V3 — no .opencode/.opencode/ directory on disk"
    PASSES=$((PASSES + 1))
fi

echo ""
echo "--- Results ---"
echo "PASS: $PASSES | FAIL: $FAILS"
echo ""

if [ "$FAILS" -gt 0 ]; then
    echo "OVERALL: FAIL"
    exit 1
else
    echo "OVERALL: PASS"
    exit 0
fi
