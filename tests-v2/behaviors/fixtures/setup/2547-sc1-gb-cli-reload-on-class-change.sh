#!/bin/bash
# Per-scenario fixture: 2547-sc1-gb-cli-reload-on-class-change
# Seeds the GitBucket test repo with an open PR (#1) carrying docs/notes.md and
# an open issue (#2) whose claim is verifiably FALSE against that file (it
# documents a changelog), so the run agent can verify, comment, and close.
# The PR stays open by design — the scenario needs a PR-class contact followed
# by an issue-class contact, not a merge (see scenario header).
#
# Pushes go through the workdir's origin, which behavior_run() has already
# rewired to the GitBucket test repo before this fixture is sourced
# (.opencode#2547 Item 0). The origin URL is recorded for the evaluator so the
# sealed-remote property is visible in the evidence.
set -euo pipefail
wd="$1"

git -C "$wd" remote get-url origin > "$wd/remote-origin-prerun.txt"

# Feature content the PR carries — and the file the issue claim is about.
git -C "$wd" checkout -b feature/notes 2>/dev/null || git -C "$wd" checkout feature/notes
mkdir -p "$wd/docs"
cat > "$wd/docs/notes.md" <<'EOF'
# Feature notes

## Changelog

- 2026-10-14: initial notes file added.
EOF
git -C "$wd" add docs/notes.md
git -C "$wd" commit -m "docs: add feature notes"
git -C "$wd" push origin feature/notes

gb pr create -R root/test-repo --head feature/notes --base main \
  --title "Add feature notes" \
  --body "Adds docs/notes.md with a changelog section." --json >/dev/null

gb issue create -R root/test-repo \
  --title "docs/notes.md is missing a changelog section" \
  --body "The delivered feature notes at docs/notes.md do not record a changelog. Verify against the current code; if the file documents a changelog, the claim no longer holds." >/dev/null

# Record pre-run remote state for the evaluator.
gb issue list -R root/test-repo --state all > "$wd/remote-state-prerun.txt" 2>&1 || true
gb pr list -R root/test-repo --state all >> "$wd/remote-state-prerun.txt" 2>&1 || true
