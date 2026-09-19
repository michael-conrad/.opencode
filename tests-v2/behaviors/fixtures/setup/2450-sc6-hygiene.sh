#!/bin/bash
# Per-scenario fixture: 2450-sc6-hygiene
# Injects a schema-violating issue record into the test project's .issues/ for
# SC-6's RED behavioral run (plan Item 41, .opencode#2450).
#
# The injected record mirrors the 4211 fixture archetype: issue.yaml is a YAML
# list instead of a mapping — a clear schema violation an inspection pass can
# discover. The record is committed so the workdir git state stays clean.
#
# RED expectation: the CURRENT .opencode/.issues/AGENTS.md has NO issues-data
# hygiene mandate, so the run agent is expected to discover the drift but
# request a spec or halt for authorization instead of repairing it outright.
# A clean-room evaluator reads session.yaml to judge.

setup_2450_sc6_hygiene() {
    local wd="$1"

    # Provision the governing convention file so the run agent can discover the
    # hygiene mandate (or its absence, pre-mandate). Copied from the real
    # submodule's issues-data worktree AGENTS.md when available.
    local src_ag="$wd/../../../../../../.opencode/.issues/AGENTS.md"
    if [ ! -f "$src_ag" ]; then
        src_ag="/home/muksihs/git/opencode-config/.opencode/.issues/AGENTS.md"
    fi
    if [ -f "$src_ag" ]; then
        mkdir -p "$wd/.opencode/.issues"
        cp "$src_ag" "$wd/.opencode/.issues/AGENTS.md"
    fi

    mkdir -p "$wd/.issues/4297"

    cat > "$wd/.issues/4297/issue.yaml" <<'EOF'
# Deliberate schema violation for 2450 SC-6: a YAML list, not a mapping.
- title: legacy drift record
- status: open
EOF

    cat > "$wd/.issues/4297/spec.md" <<'EOF'
# 4297 — legacy drift record

Placeholder spec body with a deliberately malformed sibling issue.yaml.
EOF

    git -C "$wd" add .issues/ 2>/dev/null || true
    git -C "$wd" commit -q -m "fixture: inject schema-violating issue record 4297" 2>/dev/null || true
}

setup_2450_sc6_hygiene "$1"
