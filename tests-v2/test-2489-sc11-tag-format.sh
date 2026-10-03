#!/usr/bin/env bash
# SC-11 enforcement test (.opencode#2489):
# All six Tag-Format Site Inventory sites carry the suffixed
# `<parent-repo>/<issue-number>-<submodule>` form; no unsuffixed
# `<parent-repo>/<issue-number>` variant remains at any site.
# Sites are located by PHRASE ANCHOR (never line numbers).
# Exit 0 = PASS (all sites suffixed). Non-zero = FAIL (unsuffixed pattern found).

set -u
TASKS="/home/muksihs/git/opencode-config/.opencode/skills/git-workflow-branch/tasks"
PRE="$TASKS/pre-work.md"
PROV="$TASKS/provenance.md"
OUT="/home/muksihs/git/opencode-config/tmp/issue-2489/artifacts/red-test-output.log"
mkdir -p "$(dirname "$OUT")"

fail=0
report() {
    echo "SITE $1 [$2]: $3" | tee -a "$OUT"
    [ "$3" = "UNSUFFIXED-MATCH" ] && fail=1
}

# Site 1: pre-work.md Step 3, item 5 (tag step) — anchor: "- [ ] 5. Tags each submodule"
site1=$(grep -n -- '- \[ \] 5\. Tags each submodule at remote' "$PRE" | grep '<parent-repo>/<issue-number>' | grep -v -- '-<submodule>')
[ -n "$site1" ] && report 1 "pre-work.md Step 3 item 5 tag line" "UNSUFFIXED-MATCH" || report 1 "pre-work.md Step 3 item 5 tag line" "CLEAN"

# Site 2: pre-work.md Step 4 commit-message template — anchor: 'update submodule pointer to'
site2=$(grep -n 'update submodule pointer to <parent-repo>/<issue-number>' "$PRE" | grep -v -- '-<submodule>')
[ -n "$site2" ] && report 2 "pre-work.md Step 4 commit-message template" "UNSUFFIXED-MATCH" || report 2 "pre-work.md Step 4 commit-message template" "CLEAN"

# Site 3: provenance.md "Tag-based provenance (Tier 3)" paragraph — anchor: '**Tag-based provenance (Tier 3):**'
site3=$(grep -n '\*\*Tag-based provenance (Tier 3):\*\*' "$PROV" | grep '<parent>/<issue-number>' | grep -v -- '-<submodule>')
[ -n "$site3" ] && report 3 "provenance.md Tag-based provenance (Tier 3)" "UNSUFFIXED-MATCH" || report 3 "provenance.md Tag-based provenance (Tier 3)" "CLEAN"

# Site 4: provenance.md tier-table Pre-work row — anchor: 'Pre-work (feature dev start)'
site4=$(grep -n 'Pre-work (feature dev start)' "$PROV" | grep '<parent>/<issue-number>' | grep -v -- '-<submodule>')
[ -n "$site4" ] && report 4 "provenance.md tier-table Pre-work row" "UNSUFFIXED-MATCH" || report 4 "provenance.md tier-table Pre-work row" "CLEAN"

# Site 5: pre-work.md Step 5 rebase command line — anchor: 'git rebase <parent-repo>/<issue-number>'
site5=$(grep -n 'git rebase <parent-repo>/<issue-number>' "$PRE" | grep -v -- '-<submodule>')
[ -n "$site5" ] && report 5 "pre-work.md Step 5 rebase command" "UNSUFFIXED-MATCH" || report 5 "pre-work.md Step 5 rebase command" "CLEAN"

# Site 6: pre-work.md Step 5 checkout command line — anchor: 'git checkout -b feature/<issue-number>-<slug> <parent-repo>/<issue-number>'
site6=$(grep -n 'git checkout -b feature/<issue-number>-<slug> <parent-repo>/<issue-number>' "$PRE" | grep -v -- '-<submodule>')
[ -n "$site6" ] && report 6 "pre-work.md Step 5 checkout command" "UNSUFFIXED-MATCH" || report 6 "pre-work.md Step 5 checkout command" "CLEAN"

if [ "$fail" -eq 1 ]; then
    echo "RED EXPECTED: unsuffixed tag format present (SC-11 not yet implemented)" | tee -a "$OUT"
    exit 1
fi
echo "PASS: all six Tag-Format Site Inventory sites use the suffixed form" | tee -a "$OUT"
exit 0
