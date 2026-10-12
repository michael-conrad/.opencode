#!/bin/bash
# Per-scenario fixture: seed a spelling mistake into the
# git-workflow-conflict card for the mechanical-fix scenario (.opencode#2554 SC-8).
setup_sc8_typo() {
    local wd="$1"
    local card="$wd/.opencode/skills/git-workflow-conflict/SKILL.md"
    if [ -f "$card" ]; then
        # Deterministic single-token typo: "Analyze" -> "Analayze".
        sed -i '0,/Analyze/s//Analayze/' "$card"
    fi
}
setup_sc8_typo "$1"
