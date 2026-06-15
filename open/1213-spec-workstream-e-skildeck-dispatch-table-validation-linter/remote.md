---
remote_issue: 1213
remote_url: "https://github.com/michael-conrad/.opencode/issues/1213"
last_sync: 2026-06-14T20:50:47Z
source: github.com
---

> **Scope revision: `.opencode#1222` Part 4 (Contract Schema Linter) defines a parallel linter function that validates contract YAML fields. This spec merges into the same `skildeck` tool — dispatch table validation and contract schema linting are subcommands of one tool, not two separate tools. Scope below updated to reflect the merged architecture.**

## Workstream E — skildeck Dispatch Table + Contract Schema Linter

**Parent:** #1208
**Depends on:** #1210 (Workstream B), `.opencode#1222` Part 4 (Contract Schema Linter)

### Scope

The skildeck CLI tool (`.opencode/tools/skildeck`). This spec covers dispatch table validation. Contract schema validation follows the spec in `#1222` Part 4 — both live under `skildeck` as subcommands: `skildeck validate` (dispatch tables) and `skildeck contract lint` (contract YAML fields).

### Changes

Add dispatch table validation to the skildeck `validate` command. The validation checks:

1. **Presence check:** Every SKILL.md MUST contain a `## Trigger Dispatch Table` section heading
2. **Column check:** The table must have at minimum columns: `User says / Context`, `Task`, `Dispatch`, `Context passed`
3. **Non-empty check:** The table must have at least one data row (excluding the header)

### Validation Results

| Condition | Result |
|-----------|--------|
| SKILL.md has ## Trigger Dispatch Table with correct columns and ≥1 row | PASS |
| SKILL.md missing ## Trigger Dispatch Table section | MISSING_DISPATCH_TABLE |
| SKILL.md has section but missing required column(s) | INVALID_DISPATCH_TABLE_COLUMNS |
| SKILL.md has section and columns but zero data rows | EMPTY_DISPATCH_TABLE |

### Invocation

The linter is invoked via the existing skildeck validate workflow. Contract linting (`#1222` Part 4) is invoked via `skildeck contract lint <path>`. If any check fails, the command exits non-zero with a report of all failures.

### SCs

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-E1 | skildeck validate checks dispatch table presence in SKILL.md | behavioral |
| SC-E2 | skildeck validate reports MISSING_DISPATCH_TABLE for SKILL.md without a dispatch table | behavioral |
| SC-E3 | skildeck validate checks column correctness in found dispatch tables | behavioral |
| SC-E4 | skildeck validate exits non-zero when at least one SKILL.md fails validation | behavioral |

🤖 OpenCode (deepseek-v4-flash)