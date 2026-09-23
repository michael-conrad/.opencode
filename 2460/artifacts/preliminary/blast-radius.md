# Preliminary Blast Radius — playwright-cli description fix

## Files modified

| File | Change |
|------|--------|
| `.opencode/skills/playwright-cli/SKILL.md` | `description` frontmatter field (line 3) replaced with approved agent-intent draft; "Browse the web" workflow When clause (line 55) extended with escalation intent family |

## Files added

| File | Purpose |
|------|---------|
| `.opencode/tests-v2/test-playwright-description-agent-intent.sh` | Content-verification test for SC-1..7 (grep-based, no model) |
| `.opencode/tests-v2/behaviors/playwright-dispatch-escalation.sh` | Behavioral artifact-only generator for positive probe (SC-8) |
| `.opencode/tests-v2/behaviors/playwright-no-false-activation.sh` | Behavioral artifact-only generator for negative control (SC-10) |

## Files NOT modified (verified out of blast radius)

- All other 50 skill cards — descoped (deck-wide compliance belongs to umbrella #1384)
- `research/`, `verification/`, `audit/`, `mcp-tool-usage/` pipelines — escalation wiring descoped per developer scope ruling
- `validate_skill_cards.py` — no validator change needed; current checks (REQ-1, SC-LINT-001) already prohibit the patterns being removed
- Guidelines and reference docs — `skill-card-description-standards.md` and `skill-card-schema.md` already codify the target format; no doc drift introduced

## Downstream consumers of the changed description

| Consumer | Impact |
|----------|--------|
| opencode binary skill indexer → `<available_skills>` | Description re-parsed at startup; ≤1024-char limit respected (665 chars) |
| Orchestrator Pre-Response Gate (Level-1 classifier) | Intent-match surface changes — this is the intended behavioral effect (SC-5/6) |
| `validate_skill_cards.py` REQ-1/SC-LINT-001 | Violations clear (verified against draft text: zero prohibited patterns) |
| `test-2296-sc3-canonical-format.sh` | Unaffected — checks body dispatch format, not description |

## Repo routing

- All changed files live under `.opencode/` → issue and PR against **michael-conrad/.opencode**
- Parent repo (michael-conrad/opencode-config) affected only via submodule pointer, which rides alongside the next real parent-repo change (never standalone)
