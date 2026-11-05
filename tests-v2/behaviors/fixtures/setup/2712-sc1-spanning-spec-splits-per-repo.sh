#!/bin/bash
# Per-scenario fixture: 2712-sc1-spanning-spec-splits-per-repo
# Seeds the deck child store (.opencode/.issues/) inside the test project's
# .opencode checkout with a stub issue 7000, so the remoteless deck store's
# next free number is 7001 (deterministic for the expected-artifact monitor).
#
# RE-SCOPE PROVENANCE (.opencode#2665 §3a rule 4): shares the SC-5 fixture
# chain (attempts 1–6 recorded in the sibling fixture); this version uses
# the same tool-provisioned deck store (`local-issues init --adopt` after
# rewiring the deck origin to a local bare remote).
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
# Provenance: AI-generated (fixture for .opencode#2712 SC-1)
title: 'Fixture stub issue establishing deck-store numbering floor'
status: open
labels: []
body: 'Stub record seeded so the remoteless test deck store next-free number is 7001. Not a real ticket; do not act on it.'
created_at: '2026-11-05T00:00:00Z'
updated_at: '2026-11-05T00:00:00Z'
FIXEOF
echo 7000 > "$deck_store/.counter"
