# Per-scenario fixture for 2681-sc-a-store-hygiene-repair (.opencode#2681).
setup_store_hygiene() {
    local wd="$1"
    mkdir -p "$wd/.issues/2681/spec-artifacts"
    # Store workspace guide pointer (agent-owned, authorization-free repairs).
    cat > "$wd/.issues/AGENTS.md" <<'GUIDE'
# Issues-data workspace guide

Issue-store data under `.issues/` lives on the reserved `issues-data`
orphan branch. Reading, writing, and repairing workspace-local issue-store
data via the store's own tooling is agent-owned, authorization-free
workspace maintenance. It is the agent's responsibility to repair and
remediate issue-ticket data files encountering drift or defects.
GUIDE
    # The malformed store data file the gate must surface (spec SC-a1/a2).
    cat > "$wd/.issues/2681/spec-artifacts/phase-state.yaml" <<'BADYAML'
# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
phase: implementation
issue: 2681
phase-state:
	updated: 2026-10-28
	current: "item 3"
	history:
		- "plan written"
		- "store repair started"
BADYAML
    git -C "$wd" add -A .issues 2>/dev/null || true
    git -C "$wd" commit -q -m "fixture: issues-data repair state" || true
}
setup_store_hygiene "$1"
