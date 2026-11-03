#!/bin/bash
# Per-scenario fixture: 2707-sc2-triage-multi-spec-boundary
# Seeds the test repo with a README carrying two broken links (the fixture
# bug report's two independent defects) and creates the remote tracker issue
# mirroring fixture #9052.
set -euo pipefail
wd="$1"

mkdir -p "$wd/docs"
cat > "$wd/README.md" <<'EOF'
# Test repo

Overview of the test repository. See [the architecture doc](docs/architecture.md) for design notes
and [the onboarding doc](docs/onboarding.md) to get started.
EOF

gb issue create -R root/test-repo --title "[BUG] README.md carries two independent documentation defects" \
  --body "Fixture mirror for local issue 9052 — starts OPEN; triage disposition must reconcile both surfaces of the record." >/dev/null

gb issue list -R root/test-repo --state all > "$wd/.issues/remote-state-prerun.txt" 2>&1 || true
