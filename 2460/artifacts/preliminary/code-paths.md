# Preliminary Code Path Inventory — playwright-cli description fix

The changed artifact is agent-facing routing text, not executable code. Inventory of the paths that consume it:

## Path 1 — Skill indexing (startup)

opencode startup → skill indexer parses SKILL.md YAML frontmatter → `description` surfaced in `<available_skills>` (Level-1 metadata). Binary constraints: name regex, description 1-1024 chars. New text: 665 chars — verified within limit.

## Path 2 — Level-1 semantic routing (the defect site)

Orchestrator Pre-Response Gate evaluates its own intent against every `<available_skills>` description → `skill({name})` load decision. Current description offers only user-utterance phrases → missed activation for research/verification intents. New description adds the escalation capability class (sentence 2) → intended to flip the dispatch decision for browser-appropriate tasks. This path is what SC-8/SC-9 measure.

## Path 3 — Post-load dispatch (unchanged)

Orchestrator loads card → reads Workflows → `task()` dispatch → sub-agent reads `tasks/commands-reference.md` → executes `playwright-cli` commands. When-clause extension (line 55) changes only the workflow's entry description, not the dispatch contract. NOTE: execution binaries (`playwright-cli`, `npx`) are absent in this environment — behavioral SCs are scoped to the dispatch decision, not execution (non-goal).

## Path 4 — Static validation

`validate_skill_cards.py` (REQ-1 description checks, SC-LINT-001 deprecated patterns) → currently FAILs on playwright-cli → expected PASS after fix. `skildeck-lint` / `test-enforcement.sh` content tests read the same frontmatter.

## Path 5 — Behavioral harness

`tests-v2/behaviors/<scenario>.sh` → `behavior_run()` → pre-flight git-state gate (commit → push → fetch/verify cycle) → `with-test-home` clone+checkout → `opencode run` → session.yaml export → clean-room evaluation sub-agent. RED phase executes against pre-change remote state (current description already on remote main); GREEN phase requires the fix commit pushed to its remote branch.
