#!/bin/bash
# Per-scenario fixture for 2751-sc3-label-passthrough-attempt: seed the GitBucket
# test repo with two issues so the scenario's label task targets an existing
# issue #2. Runs inside behavior_run after remote wiring; GB_TOKEN/GITBUCKET_PORT
# are the harness-exported GitBasket container env (§12). $1 = attempt workdir.
setup_2751_seed_issues() {
    local wd="$1"
    [ -n "${GITBUCKET_PORT:-}" ] || { echo "  [2751 fixture] no GITBUCKET_PORT — skipping seed" >&2; return 0; }
    local base="http://localhost:${GITBUCKET_PORT}/api/v3/repos/root/test-repo/issues"
    curl -s -u root:root -X POST "$base" -H "Content-Type: application/json" \
        -d '{"title":"setup marker issue","body":"marker issue so #2 exists"}' >/dev/null 2>&1 || true
    curl -s -u root:root -X POST "$base" -H "Content-Type: application/json" \
        -d '{"title":"2751 label target","body":"Set labels on this issue."}' >/dev/null 2>&1 || true
    echo "  [2751 fixture] issues #1 and #2 seeded in root/test-repo" >&2
}
setup_2751_seed_issues "$1"
