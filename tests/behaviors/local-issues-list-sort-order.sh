#!/bin/bash
# Behavioral test: local-issues-list-sort-order
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: list sorts: main repo first, submodules alpha, issue number descending.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# --- Main repo issues (various numbers) ---
for n in 7 100 42; do
  mkdir -p "$TEST_DIR/.issues/$n"
  cat > "$TEST_DIR/.issues/$n/issue.yaml" << YAML
title: Main issue $n
status: open
labels: []
body: ""
created_at: "2026-06-09T12:00:00Z"
updated_at: "2026-06-09T12:00:00Z"
YAML
  echo "comments: []" > "$TEST_DIR/.issues/$n/comments.yaml"
  echo "links: []" > "$TEST_DIR/.issues/$n/links.yaml"
done

# --- Child repo A (should sort before B) ---
mkdir -p "$TEST_DIR/achildrepo/.git"
pushd "$TEST_DIR/achildrepo" >/dev/null
git init --quiet
git config user.email "test@test.com"
git config user.name "Test"
git commit --allow-empty --quiet -m "init"
popd >/dev/null

for n in 3 99; do
  mkdir -p "$TEST_DIR/achildrepo/.issues/$n"
  cat > "$TEST_DIR/achildrepo/.issues/$n/issue.yaml" << YAML
title: A child issue $n
status: open
labels: []
body: ""
created_at: "2026-06-09T12:00:00Z"
updated_at: "2026-06-09T12:00:00Z"
YAML
  echo "comments: []" > "$TEST_DIR/achildrepo/.issues/$n/comments.yaml"
  echo "links: []" > "$TEST_DIR/achildrepo/.issues/$n/links.yaml"
done

# --- Child repo B (should sort after A) ---
mkdir -p "$TEST_DIR/bchildrepo/.git"
pushd "$TEST_DIR/bchildrepo" >/dev/null
git init --quiet
git config user.email "test@test.com"
git config user.name "Test"
git commit --allow-empty --quiet -m "init"
popd >/dev/null

for n in 5 1; do
  mkdir -p "$TEST_DIR/bchildrepo/.issues/$n"
  cat > "$TEST_DIR/bchildrepo/.issues/$n/issue.yaml" << YAML
title: B child issue $n
status: open
labels: []
body: ""
created_at: "2026-06-09T12:00:00Z"
updated_at: "2026-06-09T12:00:00Z"
YAML
  echo "comments: []" > "$TEST_DIR/bchildrepo/.issues/$n/comments.yaml"
  echo "links: []" > "$TEST_DIR/bchildrepo/.issues/$n/links.yaml"
done

cd "$TEST_DIR" && git init --quiet
git config user.email "test@test.com"
git config user.name "Test"
git add .
git commit --allow-empty --quiet -m "initial" 2>/dev/null || true

# --- Run tool ---
TOOL_REAL="$(cd "$SCRIPT_DIR/../.." && pwd)/tools/local-issues"
cd "$TEST_DIR"
output=$(uv run --python 3.12 --script "$TOOL_REAL" list 2>&1 || true)
echo "$output"

# Expected order:
# Main repo first: #100, #42, #7 (desc order)
# achildrepo: achildrepo#99, achildrepo#3
# bchildrepo: bchildrepo#5, bchildrepo#1

# Extract just the display_num (first token)
lines=$(echo "$output" | grep -oE '^[^ ]+')
expected=("#100" "#42" "#7" "achildrepo#99" "achildrepo#3" "bchildrepo#5" "bchildrepo#1")

idx=0
for expected_token in "${expected[@]}"; do
  actual=$(echo "$lines" | sed -n "$((idx+1))p")
  if [ "$actual" != "$expected_token" ]; then
    echo "FAIL: Line $((idx+1)) expected '$expected_token' but got '$actual'"
    exit 1
  fi
  idx=$((idx+1))
done

echo "PASS: Sort order verified (main repo first, child repos alpha, numbers desc)"
exit 0