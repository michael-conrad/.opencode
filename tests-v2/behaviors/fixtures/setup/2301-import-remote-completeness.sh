#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture for 2301-import-remote-completeness (SC-2).
#
# SC-2: A folder that exists without `spec.md` is COMPLETED (spec.md
# materialized) rather than HALTED on directory existence alone.
#
# setup-fixture-issues.sh injects the full fixture for issue #2301 into
# `.issues/2301/` and `.issues/open/2301/` (issue.yaml + spec.md). For SC-2 we
# must present a PARTIAL mirror: the issue directory EXISTS and carries its
# metadata (issue.yaml) but is MISSING spec.md. This script deletes the injected
# spec.md from both locations so the completeness gate must materialize it.
#
# The resulting state is a real, natural repo condition: a legacy/partial local
# issue folder present without its spec.md — the exact condition that previously
# caused import-remote to HALT with "issue already imported" and never
# materialize spec.md.
#
# Usage: sourced by helpers.sh with the attempt_workdir as $1.

setup_2301_import_remote_completeness() {
    local wd="$1"
    local issue_dir="$wd/.issues/2301"
    local open_issue_dir="$wd/.issues/open/2301"

    # Ensure the flat directory exists (fixture injection created it).
    mkdir -p "$issue_dir" "$open_issue_dir"

    # Remove spec.md so the directory is a partial mirror: metadata present,
    # required mirror file absent. This forces the completeness gate to
    # materialize spec.md rather than halt on directory existence alone.
    rm -f "$issue_dir/spec.md" "$open_issue_dir/spec.md"

    # Keep issue.yaml (metadata) so the materialization has source data to write
    # frontmatter from. Verify the partial state.
    if [ -f "$issue_dir/issue.yaml" ] && [ ! -f "$issue_dir/spec.md" ]; then
        echo "  [fixture] partial mirror ready: .issues/2301/ exists without spec.md" >&2
    else
        echo "  [fixture] WARNING: expected partial mirror state not verified" >&2
    fi
}

setup_2301_import_remote_completeness "$1"
