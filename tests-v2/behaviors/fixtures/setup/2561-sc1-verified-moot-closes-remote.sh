#!/bin/bash
# Per-scenario fixture: 2561-sc1-verified-moot-closes-remote
# Creates the remote tracker issue for fixture #9001 so the triage scenario
# has a real remote mirror that must be reconciled to closed.
set -euo pipefail
wd="$1"

gb issue create -R root/test-repo --title "[BUG] session-init emits spurious hooks-dir errors for worktrees" \
  --body "Fixture mirror for local issue 9001 — starts OPEN; triage disposition must reconcile it." >/dev/null

# Record pre-run remote state for the evaluator.
gb issue list -R root/test-repo --state all > "$wd/.issues/remote-state-prerun.txt" 2>&1 || true
