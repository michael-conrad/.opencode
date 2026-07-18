#!/bin/bash
# run-harness.sh — Run a single cross-reference form comparison test for issue #1988
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$PROJECT_DIR/tmp/1988/fixtures"
OUTPUT_DIR="$PROJECT_DIR/tmp/1988"
MEASUREMENTS_FILE="$OUTPUT_DIR/measurements.jsonl"
WITH_TEST_HOME="$PROJECT_DIR/.opencode/tests-v2/with-test-home"

FIXTURE="${1:-}"
FORM="${2:-}"
RUN_NUMBER="${3:-1}"

if [ -z "$FIXTURE" ] || [ -z "$FORM" ]; then
    echo "Usage: $0 <fixture> <form> [run_number]" >&2
    echo "  fixture: a|b|c|d" >&2
    echo "  form: a|b1|b2|b3|c" >&2
    exit 1
fi

case "$FIXTURE" in a|b|c|d) ;; *) echo "ERROR: Invalid fixture '$FIXTURE'. Must be a|b|c|d" >&2; exit 1 ;; esac
case "$FORM" in a|b1|b2|b3|c) ;; *) echo "ERROR: Invalid form '$FORM'. Must be a|b1|b2|b3|c" >&2; exit 1 ;; esac

SKILL_FILE="skill-${FORM}.md"
SKILL_SRC="$FIXTURES_DIR/fixture-${FIXTURE}/$SKILL_FILE"
REFS_SRC="$FIXTURES_DIR/fixture-${FIXTURE}/references"

if [ ! -f "$SKILL_SRC" ]; then
    echo "ERROR: SKILL.md not found at $SKILL_SRC" >&2
    exit 1
fi
if [ ! -d "$REFS_SRC" ]; then
    echo "ERROR: references directory not found at $REFS_SRC" >&2
    exit 1
fi

# Extract task prompt from SKILL.md body (after frontmatter, skip title line)
TASK_PROMPT=$(sed -n '/^---$/,/^---$/!p' "$SKILL_SRC" | sed '1,/^# /d' | sed '/^$/d' | head -1)

case "$FIXTURE" in
    a) RELEVANT_REF="TimeoutConfig.md"
       IRRELEVANT_REFS="LoggingConfig.md CacheConfig.md" ;;
    b) RELEVANT_REF="NamingPolicy.md"
       IRRELEVANT_REFS="RetryPolicy.md AuthPolicy.md" ;;
    c) RELEVANT_REF="ErrorHandling.md"
       IRRELEVANT_REFS="DeploymentSteps.md BackupSteps.md" ;;
    d) RELEVANT_REF="ValidationSpec.md"
       IRRELEVANT_REFS="FormatSpec.md SecuritySpec.md" ;;
esac

mkdir -p "$OUTPUT_DIR"

RUNNER_SCRIPT=$(mktemp "$OUTPUT_DIR/.runner-XXXXXX.sh")
cat > "$RUNNER_SCRIPT" << 'RUNNEREOF'
#!/bin/bash
set -euo pipefail
SKILL_SRC="$1"
REFS_SRC="$2"
TASK_PROMPT="$3"

mkdir -p .opencode/skills/fixture references
cp "$SKILL_SRC" .opencode/skills/fixture/skill.md
cp -r "$REFS_SRC"/. references/

opencode run "$TASK_PROMPT" --model ollama/qwen3.6:35b-256k
RUNNEREOF
chmod +x "$RUNNER_SCRIPT"

START_TIME=$(date +%s.%N)
set +e
STDERR_OUTPUT=$(bash "$WITH_TEST_HOME" "$RUNNER_SCRIPT" "$SKILL_SRC" "$REFS_SRC" "$TASK_PROMPT" 2>&1)
EXIT_CODE=$?
set -e
END_TIME=$(date +%s.%N)

rm -f "$RUNNER_SCRIPT"

TIME_SECONDS=0
if command -v bc &>/dev/null; then
    TIME_SECONDS=$(echo "$END_TIME - $START_TIME" | bc)
elif command -v awk &>/dev/null; then
    TIME_SECONDS=$(awk "BEGIN { print $END_TIME - $START_TIME }")
fi

STDERR_SNIPPET=$(echo "$STDERR_OUTPUT" | head -c 500 | tr -d '\n\r' | tr -c '[:print:]' ' ' | sed 's/"/\\"/g')

# Check for actual model unavailability (not agent behavior issues)
if echo "$STDERR_OUTPUT" | grep -qiE 'model.*unavailable|no.*model.*found|model.*not.*found'; then
    JSON_LINE=$(printf '{"fixture":"%s","form":"%s","run":%d,"status":"INFRASTRUCTURE_FAILURE","time_seconds":%s,"stderr_snippet":"%s"}' \
        "$FIXTURE" "$FORM" "$RUN_NUMBER" "$TIME_SECONDS" "$STDERR_SNIPPET")
    echo "$JSON_LINE" >> "$MEASUREMENTS_FILE"
    echo "INFRASTRUCTURE_FAILURE: fixture=$FIXTURE form=$FORM run=$RUN_NUMBER" >&2
    exit 1
fi

FILE_ACCESS=false
READ_SELECTION="none"
READ_DEPTH="none"

if echo "$STDERR_OUTPUT" | grep -qiE '(read|read_file|open_file).*\.md'; then
    FILE_ACCESS=true
fi

RELEVANT_READ=false
IRRELEVANT_READ=false

if echo "$STDERR_OUTPUT" | grep -qiE "(read|read_file|open_file).*$RELEVANT_REF"; then
    RELEVANT_READ=true
fi

for ref in $IRRELEVANT_REFS; do
    if echo "$STDERR_OUTPUT" | grep -qiE "(read|read_file|open_file).*$ref"; then
        IRRELEVANT_READ=true
        break
    fi
done

if [ "$RELEVANT_READ" = true ] && [ "$IRRELEVANT_READ" = true ]; then
    READ_SELECTION="both"
elif [ "$RELEVANT_READ" = true ]; then
    READ_SELECTION="relevant"
elif [ "$IRRELEVANT_READ" = true ]; then
    READ_SELECTION="irrelevant"
fi

if echo "$STDERR_OUTPUT" | grep -qiE "(read|read_file).*offset.*limit"; then
    READ_DEPTH="partial"
elif [ "$FILE_ACCESS" = true ]; then
    READ_DEPTH="full"
fi

JSON_LINE=$(printf '{"fixture":"%s","form":"%s","run":%d,"file_access":%s,"read_selection":"%s","read_depth":"%s","time_seconds":%s,"stderr_snippet":"%s"}' \
    "$FIXTURE" "$FORM" "$RUN_NUMBER" \
    "$FILE_ACCESS" "$READ_SELECTION" "$READ_DEPTH" \
    "$TIME_SECONDS" "$STDERR_SNIPPET")

echo "$JSON_LINE" >> "$MEASUREMENTS_FILE"
echo "OK: fixture=$FIXTURE form=$FORM run=$RUN_NUMBER file_access=$FILE_ACCESS read_selection=$READ_SELECTION read_depth=$READ_DEPTH time=${TIME_SECONDS}s"
exit 0
