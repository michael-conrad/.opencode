#!/bin/bash
# Behavioral test: local-issues-list-qualified-format
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: list outputs qualified {repo}#{N} format excluding current repo prefix.
#
# Setup: creates a main git repo with a child sub-repo, both with .issues/ entries.

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

# --- Child repo (simulated sibling) setup ---
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

# Init the main repo tracking the child as sibling
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

# Verify: current repo issues are bare #N, child repo issues have childrepo#N
if echo "$output" | grep -qE '^#100 '; then
  echo "PASS: Bare #N for current repo found"
else
  echo "FAIL: Expected bare #100 for current repo"
  exit 1
fi

if echo "$output" | grep -qE '^childrepo#42 '; then
  echo "PASS: Qualified childrepo#42 found"
else
  echo "FAIL: Expected childrepo#42 for child repo"
  exit 1
fi

# Verify NO qualified prefix for current repo
if echo "$output" | grep -qE '^opencode-config#'; then
  echo "FAIL: Current repo should NOT have qualified prefix"
  exit 1
fi

echo "PASS: SC-1 verified"
exit 0