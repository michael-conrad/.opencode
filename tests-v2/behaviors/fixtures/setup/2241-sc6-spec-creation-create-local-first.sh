#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Per-scenario fixture for 2241-sc6-spec-creation-create-local-first.
# Seeds the analysis artifacts required by spec-creation create.md Entry Criteria
# into the test workdir at tmp/2241/artifacts/ so the agent reaches Step 3/Step 3.1
# (the remote-first label write) instead of stalling on missing dispatch context.
#
# Usage: sourced by helpers.sh with the workdir path as $1.

setup_sc6_analysis_artifacts() {
    local wd="$1"
    local fixture_base="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../spec-analysis-2241"
    mkdir -p "$wd/tmp/2241/artifacts"
    if [ -d "$fixture_base/artifacts" ]; then
        cp "$fixture_base/artifacts/"*.yaml "$wd/tmp/2241/artifacts/" 2>/dev/null || true
    fi
    mkdir -p "$wd/.issues/2241"
    # Create the local issue dir so the create step can write sc-summary.yaml / spec.md.
    touch "$wd/.issues/2241/issue.yaml" 2>/dev/null || true
    git -C "$wd" add tmp/ .issues/ 2>/dev/null || true
    git -C "$wd" commit -q --allow-empty -m "seed sc6 analysis artifacts" 2>/dev/null || true
}

setup_sc6_analysis_artifacts "$1"
