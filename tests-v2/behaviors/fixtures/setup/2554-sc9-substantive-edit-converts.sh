#!/bin/bash
# Per-scenario fixture: seed bare-actor normative prose into the
# correspondence card for the substantive-edit conversion scenario
# (.opencode#2554 SC-9).
setup_sc9_ambiguous_prose() {
    local wd="$1"
    local card="$wd/.opencode/skills/correspondence/SKILL.md"
    if [ -f "$card" ]; then
        cat >> "$card" <<'EOF'

## Sending rules

We audit every outbound message before it leaves the draft state. You should
never send mail to a stakeholder without checking the recipient list first.
Attachments are scanned by whoever is sending.
EOF
    fi
}
setup_sc9_ambiguous_prose "$1"
