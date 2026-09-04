#!/bin/bash
# Per-scenario fixture: create a NEW file under the agent's own feature branch whose
# footer is MISSING the "Co-authored with AI:" byline. The finishing checklist (SC-3)
# must make the producing agent AUTO-FIX the missing footer byline, preserving any
# existing bylines, rather than escalating byline absence as a decision-requiring blocker.
#
# RED phase: the current checklist.md "AI co-authored attribution in new files" item has
# no byline auto-fix classification, so byline absence is escalated — the test FAILS
# (RED). The session.yaml (SQLite DB export) is the PRIMARY evidence source; a clean-room
# sub-agent evaluates whether the producing agent added the missing footer byline and
# preserved existing bylines (PASS) vs escalated byline absence to the developer (FAIL).

setup_sc3_footer_byline_missing() {
    local wd="$1"

    git -C "$wd" config user.email "test@test.dev" 2>/dev/null || true
    git -C "$wd" config user.name "Test" 2>/dev/null || true

    # Create the agent's own unmerged feature branch.
    git -C "$wd" checkout -b feature/2402-sc3-footer-byline-missing 2>/dev/null || true

    # Create a new documentation file whose footer is MISSING the "Co-authored with AI:" byline.
    mkdir -p "$wd/docs"
    cat > "$wd/docs/SC3-BYLINE-MISSING.md" <<'EOF'
# SC-3 Byline Missing Marker

This file is a new file created for the SC-3 footer-byline auto-fix behavioral test.
It is deliberately missing the footer byline to exercise the checklist's attribution
verification item.
EOF
    git -C "$wd" add docs/SC3-BYLINE-MISSING.md 2>/dev/null || true
    git -C "$wd" commit -q -m "chore: add marker for SC-3 footer byline auto-fix" 2>/dev/null || true
}

setup_sc3_footer_byline_missing "$1"
