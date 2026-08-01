# Spec Structure Standards

Canonical reference document defining the required structure for specification documents. Both producers (`spec-creation/tasks/create.md`) and auditors (`spec-audit` tasks) read this document via `Read [Text](path)`.

## Required Sections

Every spec MUST contain the following sections in order:

1. **Intent and Executive Summary** — Preamble with 6 fields: Problem Statement, Root Cause / Motivation, Approach Chosen, Alternatives Considered & Why Discarded, Key Design Decisions, User Intent / Original Prompt. This section subsumes Objective and Background.
2. **Not Included** — Explicitly excluded scope
3. **Success Criteria** — Table with ID, Criterion, Evidence Type, Verification Method columns
4. **Requirements** — Numbered requirements with SHALL language
5. **Items** — Per-SC item enumeration. Each SC maps to exactly one item. Items numbered sequentially from 1.
6. **Dependencies** — Prerequisite specs, skills, guidelines
7. **Traceability** — Table mapping Requirements → SCs → Phases
8. **Documentation Sources** — Table with Source, Type, Location, Verification columns
9. **Enforcement Gate** — All-or-nothing statement: all SCs must pass before completion
10. **Cost Frame** — Per-SC cost-frame language following the dark-prose-007 pattern (see `reference/cost-model-standards.md`)
11. **Edge Cases** — Boundary conditions, failure modes, and their resolutions

## SC Table Column Requirements

| Column | Required | Description |
|--------|----------|-------------|
| ID | Yes | Unique SC identifier (SC-1, SC-2, etc.) |
| Criterion | Yes | What must be true for this SC to pass |
| Evidence Type | Yes | One of: structural, string, semantic, behavioral |
| Verification Method | Yes | How the SC is verified |

## Evidence Type Taxonomy

| Type | Minimum Acceptable Evidence | Example |
|------|---------------------------|---------|
| `structural` | File existence | `ls path/to/file` |
| `string` | grep/pattern match | `grep for pattern` |
| `semantic` | Sub-agent read + judgment | Clean-room sub-agent reads and evaluates |
| `behavioral` | Test execution with output inspection | `opencode run` with assertion helpers |

**EVIDENCE_TYPE_MISMATCH rules:**
- Declared type `behavioral` with only structural evidence → FAIL
- Declared type `semantic` with only string evidence → FAIL
- Default to `string` if no evidence type declared

## Prohibited Content Patterns

- **Tracking/status language:** "implemented", "pending", "confirmed", "viable", "completed" used as status markers → FAIL
- Only forward-looking "MUST be" language is permitted
- **Prescriptive code:** exact file paths with line numbers, exact import strings, exact assertion code → FAIL
- Specs should use file area references only (e.g., "the producer template" not "line 42 of create.md")

## Format Requirements

- Pipeline gates use canonical checklist format: numbered `- [ ] N.` with dispatch mode indicators
- Gate tables (per-unit or shared cross-reference) → FAIL
- If spec defines plan output format requirements, they must use canonical checklist format
- Dispatch tables, shared cross-references → FAIL

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
