#!/bin/bash
# Behavioral test: 492-stale-branch-auto-rebase
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase: staleness detection and auto-rebase behavior in git-workflow review-prep.
# Covers SC-2 (stale branch → auto-rebase), SC-4 (Tier 3 conflict → halt+escalate),
# SC-5 (clean branch → proceed normally).
# Expected to FAIL because git-workflow review-prep has no staleness check yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_PHASE="RED"
BEHAVIOR_FIXTURE_ISSUES=0
BEHAVIOR_STORY_FIXTURES=0
BEHAVIOR_SUBMODULE_COMMIT=""
BEHAVIOR_SET_BARE_REMOTE=1
: "${BEHAVIOR_TIMEOUT:=420}"
: "${BEHAVIOR_SEMANTIC_TIMEOUT:=120}"
: "${BEHAVIOR_MAX_RETRIES:=2}"

# Create test home once for reuse across all three scenarios
unset TEST_HOME
SETUP_OUTPUT=$(bash "$PARENT_REPO_DIR/$BEHAVIOR_TEST_HOME" --setup "$PARENT_REPO_DIR" 2>/dev/null)
SHARED_TEST_HOME=$(echo "$SETUP_OUTPUT" | grep '^TEST_HOME=' | cut -d= -f2-)
export TEST_HOME="$SHARED_TEST_HOME"

# === SCENARIO 1: Stale branch (SC-2) ===
# Feature branch is behind origin/main by 2 commits.
# Agent should detect staleness and auto-rebase before proceeding.
WD_STALE=$(mktemp -d "/tmp/opencode/behavior-isolated-XXXXXX")
git init -q "$WD_STALE"
git -C "$WD_STALE" config user.email "test@test.dev"
git -C "$WD_STALE" config user.name "Test"

# Create bare remote
BARE_REMOTE="$WD_STALE/../origin.git"
git init --bare "$BARE_REMOTE"
git -C "$WD_STALE" remote add origin "$BARE_REMOTE"

echo "initial" > "$WD_STALE/file.txt"
git -C "$WD_STALE" add file.txt
git -C "$WD_STALE" commit -q -m "initial"
git -C "$WD_STALE" branch -M main
git -C "$WD_STALE" push -q -f -u origin main

git -C "$WD_STALE" fetch -q origin main
git -C "$WD_STALE" checkout -q main
git -C "$WD_STALE" reset -q --hard origin/main
git -C "$WD_STALE" checkout -b feature/stale-test
echo "feature work" >> "$WD_STALE/file.txt"
git -C "$WD_STALE" add file.txt
git -C "$WD_STALE" commit -q -m "feature commit"
git -C "$WD_STALE" checkout main
echo "main ahead 1" >> "$WD_STALE/file.txt"
git -C "$WD_STALE" add file.txt
git -C "$WD_STALE" commit -q -m "main ahead 1"
echo "main ahead 2" >> "$WD_STALE/file.txt"
git -C "$WD_STALE" add file.txt
git -C "$WD_STALE" commit -q -m "main ahead 2"
git -C "$WD_STALE" push -q origin main
git -C "$WD_STALE" checkout feature/stale-test

mkdir -p "$WD_STALE/.issues"
printf ".opencode/\ntmp/\n.issues/\nfixtures/\n*.pyc\n__pycache__/\n" > "$WD_STALE/.gitignore"
git -C "$WD_STALE" add -A
git -C "$WD_STALE" add -f .gitignore
git -C "$WD_STALE" commit -q --allow-empty -m "setup complete"

behavior_run "492-stale-branch-auto-rebase-stale" \
    "Execute the push-and-cleanup task for the current feature branch. Run git fetch, check if the branch is behind origin/main, and if so rebase. Then push the branch." \
    "$DEFAULT_TEST_MODEL" "$WD_STALE"

# === SCENARIO 2: Clean branch (SC-5) ===
# Feature branch is up-to-date with origin/main (behind == 0).
# Agent should proceed normally without rebase.
WD_CLEAN=$(mktemp -d "/tmp/opencode/behavior-isolated-XXXXXX")
git init -q "$WD_CLEAN"
git -C "$WD_CLEAN" config user.email "test@test.dev"
git -C "$WD_CLEAN" config user.name "Test"

BARE_REMOTE_CLEAN="$WD_CLEAN/../origin.git"
git init --bare "$BARE_REMOTE_CLEAN"
git -C "$WD_CLEAN" remote add origin "$BARE_REMOTE_CLEAN"

echo "initial" > "$WD_CLEAN/file.txt"
git -C "$WD_CLEAN" add file.txt
git -C "$WD_CLEAN" commit -q -m "initial"
git -C "$WD_CLEAN" branch -M main
git -C "$WD_CLEAN" push -q -f -u origin main

git -C "$WD_CLEAN" fetch -q origin main
git -C "$WD_CLEAN" checkout -q main
git -C "$WD_CLEAN" reset -q --hard origin/main
git -C "$WD_CLEAN" checkout -b feature/clean-test
echo "feature work" >> "$WD_CLEAN/file.txt"
git -C "$WD_CLEAN" add file.txt
git -C "$WD_CLEAN" commit -q -m "feature commit"

mkdir -p "$WD_CLEAN/.issues"
printf ".opencode/\ntmp/\n.issues/\nfixtures/\n*.pyc\n__pycache__/\n" > "$WD_CLEAN/.gitignore"
git -C "$WD_CLEAN" add -A
git -C "$WD_CLEAN" add -f .gitignore
git -C "$WD_CLEAN" commit -q --allow-empty -m "setup complete"

behavior_run "492-stale-branch-auto-rebase-clean" \
    "Execute the push-and-cleanup task for the current feature branch. Run git fetch, check if the branch is behind origin/main, and if so rebase. Then push the branch." \
    "$DEFAULT_TEST_MODEL" "$WD_CLEAN"

# === SCENARIO 3: Tier 3 conflict (SC-4) ===
# Dev branch renamed process_data to transform_data. Feature branch still uses
# process_data. Rebase produces a structural conflict requiring developer intent.
# Agent should classify as Tier 3 (intent) and HALT with escalation.
WD_CONFLICT=$(mktemp -d "/tmp/opencode/behavior-isolated-XXXXXX")
git init -q "$WD_CONFLICT"
git -C "$WD_CONFLICT" config user.email "test@test.dev"
git -C "$WD_CONFLICT" config user.name "Test"

BARE_REMOTE_CONFLICT="$WD_CONFLICT/../origin.git"
git init --bare "$BARE_REMOTE_CONFLICT"
git -C "$WD_CONFLICT" remote add origin "$BARE_REMOTE_CONFLICT"

cat > "$WD_CONFLICT/lib.py" << 'PYEOF'
def process_data(input):
    return input.strip()
PYEOF
echo "config: default" > "$WD_CONFLICT/config.yaml"
git -C "$WD_CONFLICT" add lib.py config.yaml
git -C "$WD_CONFLICT" commit -q -m "initial"
git -C "$WD_CONFLICT" branch -M main
git -C "$WD_CONFLICT" push -q -f -u origin main

git -C "$WD_CONFLICT" fetch -q origin main
git -C "$WD_CONFLICT" checkout -q main
git -C "$WD_CONFLICT" reset -q --hard origin/main
git -C "$WD_CONFLICT" checkout -b feature/conflict-test
cat > "$WD_CONFLICT/app.py" << 'PYEOF'
from lib import process_data

def handle_request(data):
    return process_data(data)
PYEOF
git -C "$WD_CONFLICT" add app.py
git -C "$WD_CONFLICT" commit -q -m "add app.py using process_data"

git -C "$WD_CONFLICT" checkout main
cat > "$WD_CONFLICT/lib.py" << 'PYEOF'
def transform_data(input):
    """Transform input data (renamed from process_data for clarity)."""
    return input.strip()
PYEOF
git -C "$WD_CONFLICT" add lib.py
git -C "$WD_CONFLICT" commit -q -m "rename process_data to transform_data"
git -C "$WD_CONFLICT" push -q origin main
git -C "$WD_CONFLICT" checkout feature/conflict-test

mkdir -p "$WD_CONFLICT/.issues"
printf ".opencode/\ntmp/\n.issues/\nfixtures/\n*.pyc\n__pycache__/\n" > "$WD_CONFLICT/.gitignore"
git -C "$WD_CONFLICT" add -A
git -C "$WD_CONFLICT" add -f .gitignore
git -C "$WD_CONFLICT" commit -q --allow-empty -m "setup complete"

behavior_run "492-stale-branch-auto-rebase-conflict" \
    "Execute the push-and-cleanup task for the current feature branch. Run git fetch, check if the branch is behind origin/main, and if so rebase. Then push the branch." \
    "$DEFAULT_TEST_MODEL" "$WD_CONFLICT"

exit 0
