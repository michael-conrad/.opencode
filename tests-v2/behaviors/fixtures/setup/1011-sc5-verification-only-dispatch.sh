#!/bin/bash
# Per-scenario fixture for 1011-sc5-verification-only-dispatch (.opencode#1011):
# provision the merged-PR state via the shared common fixture.
source "$(dirname "${BASH_SOURCE[0]}")/1011-sc-common.sh"
setup_1011_merged_pr_state "$1"
