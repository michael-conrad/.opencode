#!/bin/bash
# Per-scenario fixture: 2561-sc2-drift-reconciles-on-sync
# Creates remote tracker issue for fixture #9002 (OPEN remotely) while the
# local store record is already closed with a recorded verdict — the drift
# the reconciliation rule must repair without re-authorization.
set -euo pipefail
wd="$1"

gb issue create -R root/test-repo --title "[BUG] stale cache invalidation drops writes on early exit" \
  --body "Fixture mirror for local issue 9002 — local store is CLOSED with a recorded CLOSE-MOOT verdict; the remote mirror is left OPEN to create drift." >/dev/null

gb issue list -R root/test-repo --state all > "$wd/.issues/remote-state-prerun.txt" 2>&1 || true

# The injector places all fixture dirs under .issues/open/ — move the
# already-closed 9002 record to closed/ so the store is self-consistent.
if [ -d "$wd/.issues/open/9002-drift-moot" ]; then
    mkdir -p "$wd/.issues/closed"
    mv "$wd/.issues/open/9002-drift-moot" "$wd/.issues/closed/"
fi
