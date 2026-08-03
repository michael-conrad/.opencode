#!/bin/bash
# Per-scenario fixture: create a broken skill deck (missing SKILL.md)
# The foo-bar directory exists under skills/ but has no SKILL.md,
# simulating a skill directory with a missing card.
setup_broken_skill_deck() {
    local wd="$1"
    mkdir -p "$wd/.opencode/skills/foo-bar"
    # No SKILL.md created — this is the broken state
}
setup_broken_skill_deck "$1"
