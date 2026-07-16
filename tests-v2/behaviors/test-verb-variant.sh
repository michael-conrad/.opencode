#!/bin/bash
# Test a single verb/directive variant
# Usage: ./test-verb-variant.sh <verb> <directive_text> <model> <prompt_keyword> [context]
#
# Tests whether a sub-agent proactively reads linked files when a task file
# contains self-contained instructions PLUS Read [path] links to 3rd files.
#
# Output: tmp/verb-test-runs/{verb}-{model}-{timestamp}/
#   test-home/       - XDG home with opencode DB
#   stdout.log       - Captured output
#   stderr.log       - Captured stderr
#   manifest.yaml    - Metadata
#   session.yaml     - Exported opencode DB

set -euo pipefail
VERB="$1"
DIRECTIVE="$2"
MODEL="$3"
PROMPT_KEYWORD="$4"
CONTEXT="${5:-orchestrator}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
MODEL_SLUG="${MODEL//[:\/]/_}"
RUN_DIR="/home/muksihs/git/opencode-config/tmp/verb-test-runs/${VERB}-${MODEL_SLUG}-${TIMESTAMP}"
TEST_HOME="$RUN_DIR/test-home"
TEST_PROJECT="$TEST_HOME/project"
mkdir -p "$TEST_HOME" "$TEST_PROJECT"

git init -q "$TEST_PROJECT"
git -C "$TEST_PROJECT" config user.email "test@test.dev"
git -C "$TEST_PROJECT" config user.name "Test"

SUBMODULE_URL="https://github.com/michael-conrad/.opencode.git"
git clone -q "$SUBMODULE_URL" "$TEST_PROJECT/.opencode"
SUBMODULE_COMMIT=$(git -C "/home/muksihs/git/opencode-config/.opencode" rev-parse HEAD 2>/dev/null || true)
[ -n "$SUBMODULE_COMMIT" ] && git -C "$TEST_PROJECT/.opencode" checkout -q "$SUBMODULE_COMMIT" 2>/dev/null || true

git -C "$TEST_PROJECT" add -A 2>/dev/null || true
git -C "$TEST_PROJECT" commit -q --allow-empty -m "init" 2>/dev/null || true

mkdir -p "$TEST_HOME/.config/opencode"
MODEL_BARE="${MODEL#ollama/}"
cat > "$TEST_HOME/.config/opencode/opencode.jsonc" << JSONC
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "options": { "baseURL": "http://localhost:11434/v1" },
      "models": { "$MODEL_BARE": {} }
    }
  }
}
JSONC

# Create the task file with self-contained instructions + verb directive to 3rd files
mkdir -p "$TEST_PROJECT/tmp/verb-test"
cat > "$TEST_PROJECT/tmp/verb-test/task.md" << TASK
# Task Instructions

Complete the following steps:

1. List all files in the project root directory.
2. Report the current git branch name.
3. ${DIRECTIVE}
4. ${VERB} [the supplementary data](tmp/verb-test/supplement.md).
5. Print "DONE" when finished.

These steps are self-contained. Steps 3-4 reference additional files
but the task can be completed without reading them.
TASK

# Create the 3rd files (irrelevant to task completion)
cat > "$TEST_PROJECT/tmp/verb-test/target-a.md" << 'TARGET'
# Authorization Tokens
- `xenon-7`
- `falcon-alpha`
- `zephyr-42`
- `token-8a3f9c71-b2d4-4e1a-9c6f-3d8b2a1e5f7c`
Any other token is NOT valid.
TARGET

cat > "$TEST_PROJECT/tmp/verb-test/supplement.md" << 'SUPPLEMENT'
# Supplementary Data
This file contains additional context that is not required for the task.
The project was initialized on 2026-07-16.
The default branch is main.
SUPPLEMENT

# Use default.txt as-is (no verb directive in system prompt)
cp /home/muksihs/git/opencode-config/.opencode/prompts/default.txt "$TEST_PROJECT/.opencode/prompts/default.txt"

STDOUT_FILE="$RUN_DIR/stdout.log"
STDERR_FILE="$RUN_DIR/stderr.log"

cd "$TEST_PROJECT"
export XDG_CONFIG_HOME="$TEST_HOME/.config"
export XDG_CACHE_HOME="$TEST_HOME/.cache"
export XDG_RUNTIME_DIR="$TEST_HOME/.runtime"
export XDG_DATA_HOME="$TEST_HOME/.local/share"
export XDG_STATE_HOME="$TEST_HOME/.local/state"

PROMPT="Dispatch a sub-agent to read and follow instructions in tmp/verb-test/task.md"

script -q -c "snap run opencode run '$PROMPT' --model $MODEL --log-level INFO --print-logs" "$STDOUT_FILE" 2> "$STDERR_FILE" || true

# Quick diagnostics to stderr
echo "=== $VERB / $MODEL / $CONTEXT ===" >&2
echo "stdout: $(wc -l < "$STDOUT_FILE" 2>/dev/null || echo 0) lines" >&2
echo "stderr: $(wc -l < "$STDERR_FILE" 2>/dev/null || echo 0) lines" >&2
# Check session.yaml for actual tool calls (not prose)
python3 -c "
import json
with open('$RUN_DIR/session.yaml') as f:
    data = json.load(f)
parts = data.get('tables', {}).get('part', {}).get('rows', [])
reads = [p for p in parts if 'target-a' in json.loads(p['data']).get('state',{}).get('input',{}).get('filePath','') or 'supplement' in json.loads(p['data']).get('state',{}).get('input',{}).get('filePath','')]
if reads:
    print('  READ CALLS TO LINKED FILES:', len(reads))
    for r in reads:
        d = json.loads(r['data'])
        fp = d.get('state',{}).get('input',{}).get('filePath','')
        print(f'    {d[\"tool\"]} -> {os.path.basename(fp)} ({d[\"state\"][\"status\"]})')
else:
    print('  no read calls to linked files')
" 2>/dev/null || echo "  (session.yaml not available)"

# Write manifest
TIMESTAMP_UTC=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$RUN_DIR/manifest.yaml" << MANIFESTEOF
scenario_name: verb-test-${VERB}
verb: ${VERB}
model: ${MODEL}
context: ${CONTEXT}
prompt_keyword: ${PROMPT_KEYWORD}
timestamp: ${TIMESTAMP_UTC}
exit_code: 0
harness_version: ${BEHAVIOR_HARNESS_VERSION}
MANIFESTEOF

# Export opencode DB to session.yaml
DB_PATH="$TEST_HOME/.local/share/opencode/opencode.db"
if [ -f "$DB_PATH" ]; then
  python3 -c "
import json, sqlite3, sys
db_path = '$DB_PATH'
output_file = '$RUN_DIR/session.yaml'
try:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute(\"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name\")
    tables = [row['name'] for row in cursor.fetchall()]
    result = {'source_db': db_path, 'tables': {}}
    for table_name in tables:
        cursor.execute(f'PRAGMA table_info(\"{table_name}\")')
        columns = [row['name'] for row in cursor.fetchall()]
        cursor.execute(f'SELECT * FROM \"{table_name}\"')
        rows = [dict(row) for row in cursor.fetchall()]
        result['tables'][table_name] = {'columns': columns, 'rows': rows}
    with open(output_file, 'w') as f:
        json.dump(result, f, indent=2, default=str)
except Exception as e:
    with open(output_file, 'w') as f:
        json.dump({'source_db': db_path, 'error': str(e)}, f)
"
else
  echo "source_db: null" > "$RUN_DIR/session.yaml"
fi

echo "Run dir: $RUN_DIR" >&2
exit 0
