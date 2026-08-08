#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture for 2241-sc21-resolve-scope-chat-only.
# Seeds the local issue #2241 comments.yaml with an authorization comment whose
# scope CONFLICTS with the authorization phrase in the chat message. The fixture
# issue #2241 (spec.md + issue.yaml) is injected by setup-fixture-issues.sh into
# .issues/2241/ and .issues/open/2241/. This script guarantees the local record
# carries a comment that grants a DIFFERENT scope than the chat message, so that:
#   - GREEN path (resolve-scope parses auth from chat message only): the agent
#     parses `for_implementation` from the chat message and ignores the comment.
#   - RED path (resolve-scope parses auth from issue comments): the agent reads
#     the comment and resolves `for_plan` instead of `for_implementation`.
#
# SC-21: `approval-gate/tasks/resolve-scope.md` SHALL parse authorization from the
# chat message only (verb-prefix table), not from issue comments. Currently
# resolve-scope.md Purpose says "Parse authorization text (issue comments, user
# messages)" — it parses auth from issue comments as a source.
#
# Usage: sourced by helpers.sh with the workdir path as $1.

setup_sc21_conflicting_comment() {
    local wd="$1"
    local issue_dir="$wd/.issues/2241"
    mkdir -p "$issue_dir"

    # Seed a conflicting authorization comment. The chat message grants
    # `for_implementation`; this comment grants `for_plan`. If the agent parses
    # auth from comments (RED), it resolves for_plan. If it parses from the chat
    # message only (GREEN), it resolves for_implementation.
    cat > "$issue_dir/comments.yaml" <<'YAML'
comments:
- type: internal
  body: "approved #2241 for plan"
  timestamp: '2026-08-06T20:00:00+00:00'
YAML

    git -C "$wd" add .issues/ 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "seed sc21 conflicting authorization comment" 2>/dev/null || true
}

setup_sc21_conflicting_comment "$1"
