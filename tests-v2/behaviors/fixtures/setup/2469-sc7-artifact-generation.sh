# Per-scenario fixture: 2469-sc7-artifact-generation
# Creates the buggy root-repo utility the scenario asks the agent to fix,
# so the run agent can go straight to RED/GREEN instead of searching for a
# nonexistent file (fixture-state defect found in first RED run, R-18).
setup_2469_sc7_fixture() {
    local wd="$1"
    mkdir -p "$wd/tools" "$wd/tests"
    cat > "$wd/tools/summary.py" <<'EOF'
"""Summarize counts for the inventory report."""


def summarize_counts(items):
    counts = {}
    for item in items:
        counts[item] = counts.get(item, 0) + 1
    return counts
EOF
    cat > "$wd/tests/test_summary.py" <<'EOF'
from tools.summary import summarize_counts
EOF
    if [ ! -f "$wd/pytest.ini" ] && [ ! -f "$wd/pyproject.toml" ]; then
        touch "$wd/pytest.ini"
    fi
    git -C "$wd" add tools tests 2>/dev/null || true
    git -C "$wd" commit -m "fixture: add buggy summarize_counts for 2469-sc7 scenario" 2>/dev/null || true
}
setup_2469_sc7_fixture "$1"