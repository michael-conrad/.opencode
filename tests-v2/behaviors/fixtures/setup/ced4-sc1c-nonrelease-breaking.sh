#!/bin/bash
# Per-scenario fixture for ced4-sc1c-nonrelease-breaking (cedproject#4 scenario A): seeds the
# breaking-release product-repo state via the shared ced4 logic.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/ced4-pr-common.sh"
setup_ced4_case "$1" "breaking-release"
