#!/bin/bash
# Per-scenario fixture: 2450-sc4-analyze-contract — pre-seed the seven analytical
# artifacts the analyze task (Steps 1-5.2) would produce, so the run agent
# reaches the Step 5.3 R-13 gate without regenerating artifacts.
# Accepts $1 = attempt workdir.
set -euo pipefail
wd="$1"
art="$wd/tmp/4299/artifacts"
mkdir -p "$art"
for name in blast-radius concern-map code-path-inventory cross-cutting-matrix interface-compatibility state-analysis testability-assessment; do
  cat > "$art/$name.yaml" <<EOF
artifact: $name
issue: 4299
status: pre-seeded by fixture setup (2450-sc4-analyze-contract)
sections: {}
EOF
done
git -C "$wd" add tmp/ 2>/dev/null || true
