# Plan: Fix playwright-cli description format (D1)

## Phase 1 — Update description

### Concern
Rewrite the `playwright-cli` SKILL.md YAML frontmatter `description` field to comply with D1 (starts with "Use when"), D4 (mandatory language), D3 (covers all dispatch conditions), and D5 (no narrative-only sentences). Preserve all other frontmatter fields unchanged.

### Items

| # | Item | SCs | Evidence Type |
|---|------|-----|---------------|
| 1 | Update `description` field in `.opencode/skills/playwright-cli/SKILL.md` | SC-1, SC-2, SC-3, SC-4, SC-5 | `string` + `semantic` + `structural` |

### Dependencies
None — single file, single field change.

### Verification
- SC-1: grep for `description: "Use when` in SKILL.md
- SC-2: grep for mandatory keyword (MUST, REQUIRED, always, not optional, mandatory) in description
- SC-3: sub-agent reads description + dispatch table, verifies coverage
- SC-4: sub-agent reads description, verifies no narrative-only sentences
- SC-5: verify license, provenance, upstream, upstream_license fields unchanged
