#!/bin/bash
# RED phase: local-issues-list-sort-order
# This script is a direct verification test — it evaluates tool output behavior.
#
# SC-3: list sorts: main repo first, submodules alpha, issue number descending.
# MUST FAIL in RED phase — current cmd_list outputs flat unsorted #N [status] title.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_REAL="$(cd "$SCRIPT_DIR/../.." && pwd)/tools/local-issues"

TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

for n in 1 42 50; do
  mkdir -p "$TEST_DIR/.issues/$n"
  printf 'title: Test %d\nstatus: open\nlabels: []\nbody: ""\ncreated_at: "2026-06-09T12:00:00Z"\nupdated_at: "2026-06-09T12:00:00Z"\n' "$n" > "$TEST_DIR/.issues/$n/issue.yaml"
  echo "comments: []" > "$TEST_DIR/.issues/$n/comments.yaml"
  echo "links: []" > "$TEST_DIR/.issues/$n/links.yaml"
done

cd "$TEST_DIR"
output=$(uv run --python 3.12 --script "$TOOL_REAL" list 2>&1 || true)

# Current output is bare "#N [status] title" — no {repo}#{N} format.
# Expected (post-GREEN): repo-grouped, repo prefix, desc by issue number.
# RED phase MUST FAIL because format is wrong.
if ! echo "$output" | grep -qE '[a-zA-Z0-9_.-]+#[0-9]+'; then
  echo "FAIL (RED expected): No qualified {repo}#{N} format — sort order unverifiable"
  echo "$output"
  exit 1
fi

# Verify main repo group appears first
first_line=$(echo "$output" | head -1)
if ! echo "$first_line" | grep -qE '^opencode-config#'; then
  echo "FAIL (RED expected): Main repo not first in sort order"
  echo "First line: $first_line"
  echo "$output"
  exit 1
fi

# Within each repo group, verify descending issue number
last_num=999999
sort_errors=0
while IFS= read -r line; do
  if echo "$line" | grep -qE '^([a-zA-Z0-9_.-]+)#([0-9]+)'; then
    num=$(echo "$line" | sed -nE 's/^[a-zA-Z0-9_.-]+#([0-9]+).*/\1/p')
    if [ "$num" -gt "$last_num" ]; then
      sort_errors=$((sort_errors + 1))
    fi
    last_num=$num
  fi
done <<< "$output"

if [ "$sort_errors" -gt 0 ]; then
  echo "FAIL (RED expected): $sort_errors descending-order violations"
  echo "$output"
  exit 1
fi

echo "PASS: Sort order verified"
exit 0