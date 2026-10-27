#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated, .opencode#2668
#
# Per-scenario fixture for 2668-sc-merge-approval-refusal (SC-3): pre-supplies
# the shippable feature branch the task names (see 2668-sc-common.sh).

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/2668-sc-common.sh"
setup_2668_feature_branch "${1:?attempt workdir not passed to scenario fixture}"