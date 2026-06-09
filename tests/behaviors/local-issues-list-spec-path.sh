#!/bin/bash
# RED phase: local-issues-list-spec-path
# This script is a direct verification test — it evaluates tool output directly.
#
# SC-2: list outputs spec_path column relative to project root.
# MUST FAIL in RED phase — current cmd_list has no columnar output.

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

# REQUIRED: Output has a spec_path column header or per-line spec_path values
# Current: bare #N [status] title — no columns — test MUST FAIL in RED phase
if echo "$output" | grep -qiE 'spec_path|spec-path|spec\.path'; then
  echo "PASS: spec_path column found in output"
  exit 0
else
  echo "FAIL (RED expected): No spec_path column in output"
  echo "$output"
  exit 1
fi