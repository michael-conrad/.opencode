#!/bin/bash
# Per-scenario fixture: 2707-sc1-triage-in-place-spec-conversion
# Seeds the test repo with a README whose architecture link is broken (the
# fixture bug report's verifiable claim) and creates the remote tracker issue
# mirroring fixture #9051 so the conversion scenario has a real remote surface
# to reconcile.
set -euo pipefail
wd="$1"

mkdir -p "$wd/docs"
cat > "$wd/README.md" <<'EOF'
# Test repo

Overview of the test repository. See [the architecture doc](docs/architecture.md) for design notes.
EOF

gb issue create -R root/test-repo --title "[BUG] README.md links to docs/architecture.md which does not exist" \
  --body "Fixture mirror for local issue 9051 — starts OPEN; triage disposition must reconcile both surfaces of the record." >/dev/null

gb issue list -R root/test-repo --state all > "$wd/.issues/remote-state-prerun.txt" 2>&1 || true
