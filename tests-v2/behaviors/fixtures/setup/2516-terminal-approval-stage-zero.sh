#!/bin/bash
# Per-scenario fixture setup: 2516-terminal-approval-stage-zero
# The fixture spec (#9001) describes fixing the alt text on an existing
# README image embed — so the test repo must contain that README and image,
# or the agent legitimately halts on a missing artifact instead of
# demonstrating the stage-0 authorization carry-through under test.
set -euo pipefail
workdir="${1:?usage: setup script <attempt_workdir>}"

mkdir -p "$workdir/docs"
# 1x1 transparent PNG placeholder (smallest valid PNG).
printf '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n-\xb4\x00\x00\x00\x00IEND\xaeB`\x82' > "$workdir/docs/screenshot.png"
cat > "$workdir/README.md" <<'EOF'
# Demo project

Screenshot of the main window:

![](docs/screenshot.png)
EOF
git -C "$workdir" add README.md docs/screenshot.png
git -C "$workdir" commit -q -m "add README with screenshot embed"
echo "  [setup] 2516: README + docs/screenshot.png committed (alt-text fix target exists)"

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)
