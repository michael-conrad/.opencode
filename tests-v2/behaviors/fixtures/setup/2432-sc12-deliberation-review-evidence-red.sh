#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
# Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
#
# Per-scenario fixture for 2432-sc12-deliberation-review-evidence-red:
# copy the reused exported session evidence directory (SC12_REVIEW_INPUT_DIR,
# selected by the scenario script) into the test project at tmp/review-input/
# so the reviewing agent can read the prior run's session evidence from inside
# the isolated test home. Idempotent — behavior_run may retry the run.

sc12_fixture() {
    local wd="$1"
    local src="${SC12_REVIEW_INPUT_DIR:-}"
    [ -n "$src" ] && [ -f "$src/session.yaml" ] || return 0
    mkdir -p "$wd/tmp/review-input"
    cp -f "$src/session.yaml" "$wd/tmp/review-input/session.yaml"
    for f in manifest.yaml stdout.log stderr.log exit_code timeline.yaml; do
        [ -f "$src/$f" ] && cp -f "$src/$f" "$wd/tmp/review-input/$f" || true
    done
}
sc12_fixture "$1"
