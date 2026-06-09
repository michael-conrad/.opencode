#!/bin/bash
# Behavioral test: local-issues-list-spec-path
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: list outputs spec_path column relative to project root.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

# --- Main repo setup ---
mkdir -p "$TEST_DIR/.issues/100"
cat > "$TEST_DIR/.issues/100/issue.yaml" << 'YAML'
title: Main issue
status: open
labels: []
body: ""
created_at: "2026-06-09T12:00:00Z"
updated_at: "2026-06-09T12:00:00Z"
YAML
echo "comments: []" > "$TEST_DIR/.issues/100/comments.yaml"
echo "links: []" > "$TEST_DIR/.issues/100/links.yaml"

# --- Child repo setup ---
mkdir -p "$TEST_DIR/childrepo/.git"
pushd "$TEST_DIR/childrepo" >/dev/null
git init --quiet
git config user.email "test@test.com"
git config user.name "Test"
git commit --allow-empty --quiet -m "init"
popd >/dev/null

mkdir -p "$TEST_DIR/childrepo/.issues/42"
cat > "$TEST_DIR/childrepo/.issues/42/issue.yaml" << 'YAML'
title: Child issue
status: open
labels: []
body: ""
created_at: "2026-06-09T12:00:00Z"
updated_at: "2026-06-09T12:00:00Z"
YAML
echo "comments: []" > "$TEST_DIR/childrepo/.issues/42/comments.yaml"
echo "links: []" > "$TEST_DIR/childrepo/.issues/42/links.yaml"

cd "$TEST_DIR" && git init --quiet
git config user.email "test@test.com"
git config user.name "Test"
git add .
git commit --allow-empty --quiet -m "initial"

# --- Run tool ---
TOOL_REAL="$(cd "$SCRIPT_DIR/../.." && pwd)/tools/local-issues"
cd "$TEST_DIR"
output=$(uv run --python 3.12 --script "$TOOL_REAL" list 2>&1 || true)
echo "$output"

# Verify spec_path column header or values
if echo "$output" | grep -q 'spec_path'; then
  echo "PASS: spec_path column found in output"
else
  echo "FAIL: spec_path column not found"
  exit 1
fi

# Verify spec_path values are relative paths
if echo "$output" | grep -qE 'spec_path=\.issues'; then
  echo "PASS: spec_path contains relative paths"
else
  echo "FAIL: spec_path values missing or not relative"
  exit 1
fi

echo "PASS: SC-2 verified"
exit 0