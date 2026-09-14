#!/usr/bin/env bash
# SC-4 RED test for issue 2442 — .opencode submodule, AGENTS.md .issues/ guidance.
#
# Scans the WHOLE AGENTS.md for residual contradicting file-access-prohibition
# phrases on .issues/ files ("NEVER read/write .issues/", "MUST NOT read/write
# .issues/ files", and similar blanket file-axis prohibitions) OUTSIDE the
# preserved git-op rule.
#
# Preserved rule (excluded from assertion, git-axis only):
#   "MUST NOT read/write `.issues/` files directly through git operations"
# The test targets FILE-AXIS prohibitions only.

set -u

TARGET="/home/muksihs/git/opencode-config/.opencode/AGENTS.md"
OUT_DIR="/home/muksihs/git/opencode-config/.opencode/tmp/2442/artifacts"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/sc4-red-$(date +%Y%m%d%H%M%S).log"

if [ ! -f "$TARGET" ]; then
  echo "FAIL: target file missing: $TARGET" | tee "$OUT"
  exit 1
fi

# Blanket file-access prohibition phrases on .issues/ files (file-axis).
PATTERNS=(
  'NEVER read/write `\.issues/`'
  'MUST NOT read/write `\.issues/` files'
  'NEVER read or write `\.issues/`'
  'MUST NOT (read|write|edit|access) any file(s?) (in|under|within) `\.issues/`'
  'Do NOT use (the )?(read|write|edit|glob|grep) tool(s)? (on|for|with) `\.issues/`'
  'FORBIDDEN[[:space:]]*\|[[:space:]]*`read\(filePath=`\.issues/'
)

violations=0
while IFS= read -r line; do
  lineno="${line%%:*}"
  content="${line#*:}"
  # Exclude the preserved git-axis rule: prohibition scoped to git operations.
  if grep -qE 'MUST NOT read/write `\.issues/` files directly through git operations' <<<"$content"; then
    continue
  fi
  echo "VIOLATION (line $lineno): $content" | tee -a "$OUT"
  violations=$((violations + 1))
done < <(grep -nE "$(IFS='|'; echo "${PATTERNS[*]}")" "$TARGET")

if [ "$violations" -gt 0 ]; then
  echo "FAIL: $violations residual file-axis prohibition(s) on .issues/ files found outside the preserved git-op rule." | tee -a "$OUT"
  exit 1
fi

echo "PASS: no residual contradicting file-access prohibitions on .issues/ files outside the preserved git-op rule (issue 2442 SC-4)." | tee "$OUT"
exit 0
