#!/bin/bash
# Per-scenario fixture: create dead and live branches for SC-9.
source "$(dirname "${BASH_SOURCE[0]}")/2219-dead-branches-common.sh"
setup_dead_branches "$1"
