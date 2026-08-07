#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture for 2241-sc7-analyze-and-spec-local-first.
# Ensures the local bug-report issue #2249 record exists in the test workdir so
# the issue-review analyze-and-spec task has a local issue.yaml to write labels to.
#
# SC-7: `issue-review/tasks/analyze-and-spec.md` SHALL write labels to local
# `{issues_prefix}/{N}/issue.yaml` as primary canonical source; remote write SHALL
# be best-effort/secondary only. Currently analyze-and-spec.md Step 6.1 applies the
# `spec-draft` label via the platform label API (remote-first) as primary.
#
# The fixture issue #2249 (issue.yaml + spec.md) is injected by
# setup-fixture-issues.sh into .issues/open/2249/ and .issues/2249/. This script
# only guarantees the local record is committed so the analyze-and-spec task can
# write labels to it as the canonical target.
#
# Usage: sourced by helpers.sh with the workdir path as $1.

setup_sc7_local_issue() {
    local wd="$1"

    # Ensure a local issue dir exists so analyze-and-spec has a local record target.
    mkdir -p "$wd/.issues/open/2249"
    if [ ! -f "$wd/.issues/open/2249/issue.yaml" ]; then
        printf 'issue_number: 2249\ntitle: Bug: analyze-and-spec crashes\nstate: open\nlabels:\n- bug\nowner: michael-conrad\nrepo: .opencode\n' \
            > "$wd/.issues/open/2249/issue.yaml"
    fi
    git -C "$wd" add -A 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "seed sc7 local issue record" 2>/dev/null || true
}

setup_sc7_local_issue "$1"
