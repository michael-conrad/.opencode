#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture for 2241-sc1-handoff-local-read.
# Seeds the local issue.yaml record for issue #2241 with an `approved-for-plan`
# label so the writing-plans handoff task has a local canonical source to read
# authorization from. The fixture issue #2241 (spec.md + issue.yaml) is injected
# by setup-fixture-issues.sh into .issues/2241/ and .issues/open/2241/. This
# script guarantees the local record carries the `approved-for-*` label so that
# IF the agent reads authorization from local issue.yaml (the GREEN path) it
# succeeds; the RED path (approval-gate --task verify-authorization reading
# remote labels) reports SPEC_NOT_APPROVED because the remote GitBucket issue
# has no approved label.
#
# SC-1: `writing-plans/tasks/handoff.md` SHALL read authorization from local
# `{issues_prefix}/{N}/issue.yaml` instead of calling
# `approval-gate --task verify-authorization` (which reads remote labels).
# Currently handoff.md Step 2 delegates to approval-gate (remote-first) as primary.
#
# Usage: sourced by helpers.sh with the workdir path as $1.

setup_sc1_local_issue() {
    local wd="$1"
    local issue_dir="$wd/.issues/2241"
    mkdir -p "$issue_dir"

    # Ensure the local issue.yaml record exists with an approved-for-* label so
    # the local read (GREEN path) would succeed. The fixture-injected record only
    # carries `needs-approval`; add `approved-for-plan` to make the local canonical
    # source the successful path.
    if [ -f "$issue_dir/issue.yaml" ]; then
        cat > "$issue_dir/issue.yaml" <<'YAML'
issue_number: 2241
title: '[SPEC] Authorization tracking: local issue.yaml is canonical source, not remote API labels'
state: open
labels:
- needs-approval
- approved-for-plan
created_at: '2026-08-03T15:31:00Z'
updated_at: '2026-08-06T20:25:25+00:00'
owner: michael-conrad
repo: .opencode
YAML
    fi

    # Ensure the spec exists so handoff.md Entry Criteria passes.
    if [ ! -f "$issue_dir/spec.md" ]; then
        cat > "$issue_dir/spec.md" <<'YAML'
# [SPEC] Authorization tracking: local issue.yaml is canonical source, not remote API labels

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `writing-plans/tasks/handoff.md` SHALL read authorization from local `issue.yaml` instead of calling `approval-gate --task verify-authorization` | semantic |
YAML
    fi

    git -C "$wd" add .issues/ 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "seed sc1 local issue record" 2>/dev/null || true
}

setup_sc1_local_issue "$1"
