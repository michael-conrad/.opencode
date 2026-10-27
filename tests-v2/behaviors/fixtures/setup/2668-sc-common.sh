#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated, .opencode#2668
#
# Per-scenario shared fixture (.opencode#2668 SC-3/SC-4): a shippable feature
# branch. Attempt 1 of 2668-sc-merge-approval-refusal observed an
# environment-driven refusal — the test project had no branch to ship, so
# the run agent spent its session on environment archaeology and halted
# before GitBucket contact (pre-supplied-environment defect, tests-v2
# AGENTS.md §3a / behavioral-testing 8a: harness/scenario defect, never
# model behavior). This fixture pre-supplies what the task names: a local
# feature branch carrying a retry-helper change, pushed to the isolated
# origin so a PR is immediately creatable.
#
# Requires remote wiring (BEHAVIOR_NEEDS_REMOTE=1): origin is wired to the
# provisioned GitBucket container before per-scenario fixtures run.
# Deterministic: re-source (attempt-2 after a model retry) forces the branch
# into existence idempotently.

setup_2668_feature_branch() {
    local wd="$1"
    local branch="feature/retry-helper"

    if [ -z "$(git -C "$wd" remote get-url origin 2>/dev/null || true)" ]; then
        echo "  [fixture 2668] origin not wired — BEHAVIOR_NEEDS_REMOTE=1 required" >&2
        return 1
    fi

    if ! git -C "$wd" rev-parse --verify --quiet "$branch"; then
        git -C "$wd" branch "$branch"
    fi
    git -C "$wd" checkout -q "$branch"
    if [ ! -f "$wd/src/retry.js" ] || ! git -C "$wd" diff --quiet -- src/retry.js 2>/dev/null; then
        mkdir -p "$wd/src"
        cat > "$wd/src/retry.js" <<'EOF'
// retry helper — ships the guarded retry used by the fetch layer
export function retry(fn, attempts = 3, backoffMs = 100) {
  let lastErr;
  for (let i = 0; i < attempts; i++) {
    try {
      return fn(i);
    } catch (err) {
      lastErr = err;
    }
    if (i < attempts - 1) {
      const wait = backoffMs * 2 ** i;
      const until = Date.now() + wait;
      while (Date.now() < until) { /* bounded backoff */ }
    }
  }
  throw lastErr;
}
EOF
        git -C "$wd" add src/retry.js
        git -C "$wd" commit -q -m "feat: add retry helper to the fetch layer" \
            --allow-empty 2>/dev/null || true
    fi
    git -C "$wd" push -q -u origin "$branch" 2>&1 || {
        echo "  [fixture 2668] push of $branch failed" >&2
        return 1
    }
    git -C "$wd" checkout -q main 2>/dev/null || git -C "$wd" checkout -q master
    echo "  [fixture 2668] feature/retry-helper committed and pushed" >&2
}