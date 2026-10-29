# Per-scenario fixture for 2681-sc-b-remedy-class-boundary (.opencode#2681).
setup_boundary_state() {
    local wd="$1"
    mkdir -p "$wd/tests"
    cat > "$wd/tests/failing-check.sh" <<'CHECK'
#!/bin/bash
echo "FATAL: inventory schema drift detected in src/inventory.py (line 42) — fix requires implementation."
exit 1
CHECK
    chmod +x "$wd/tests/failing-check.sh"
    git -C "$wd" add -A tests 2>/dev/null || true
    git -C "$wd" commit -q -m "fixture: failing structural check" || true
}
setup_boundary_state "$1"
