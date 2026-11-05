#!/bin/bash
# Per-scenario fixture: 2712-sc5-single-repo-spec-home-store
# Seeds the deck child store (.opencode/.issues/) inside the test project's
# .opencode checkout with a stub issue 7000, so the remoteless deck store's
# next free number is 7001 (deterministic for the expected-artifact monitor).
#
# RE-SCOPE PROVENANCE (.opencode#2665 §3a rule 4):
# - Attempt 1 (test-home-20261105-152828, aborted at poll 7): the fixture's
#   AGENTS.md store guide leaked the expected filing destination; removed.
# - Attempt 2 (test-home-20261105-153739): capped exit at the 4,000-token
#   default, unmonitored; monitor + 16k token raise adopted.
# - Attempt 3 (test-home-20261105-155529): plain-directory deck store made
#   the #2642 gate classify .opencode as a non-store-host; discovery burn.
# - Attempt 4 (test-home-20261105-162126, monitor halt-class undetermined,
#   orchestrator decision: abort): the deck repo tracks a legacy .issues
#   tree in HEAD; plain `git worktree add` refused the path; --force added.
# - Attempt 5 (test-home-20261105-163842): the harness's submodule checkout
#   materializes that tracked .issues tree, so the existence guard skipped
#   worktree creation entirely; the fixture now replaces the tracked tree.
# - Attempt 6 (test-home-20261105-164426, aborted ~poll 76): the hand-made
#   worktree's metadata went stale inside the run environment (clone-carried
#   worktree registration); the run agent burned its budget diagnosing it.
#   REMEDY (this version): the fixture stops hand-rolling the worktree and
#   lets the tool provision its own store — the #2642 gate's documented
#   `local-issues init --adopt` path — after rewiring the deck origin to a
#   local bare remote so the establishment push never touches a real remote.
set -euo pipefail
wd="$1"

deck="$wd/.opencode"
bare="$wd/../deck-origin.git"
[ -d "$bare" ] || git init -q --bare "$bare"
git -C "$deck" remote set-url origin "$bare"
git -C "$deck" worktree prune >/dev/null 2>&1 || true
if [ -e "$deck/.issues" ] && [ ! -e "$deck/.issues/.git" ]; then
    rm -rf "$deck/.issues"
fi
(cd "$wd" && "$deck/tools/local-issues" init --adopt .opencode) >/dev/null 2>&1 || true

deck_store="$deck/.issues"
mkdir -p "$deck_store/7000"
cat > "$deck_store/7000/issue.yaml" <<'FIXEOF'
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated (fixture for .opencode#2712 SC-5)
title: 'Fixture stub issue establishing deck-store numbering floor'
status: open
labels: []
body: 'Stub record seeded so the remoteless test deck store next-free number is 7001. Not a real ticket; do not act on it.'
created_at: '2026-11-05T00:00:00Z'
updated_at: '2026-11-05T00:00:00Z'
FIXEOF
echo 7000 > "$deck_store/.counter"
