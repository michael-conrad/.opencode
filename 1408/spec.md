## Summary

Per `.opencode#1407` (routing-only SKILL.md restructure), the skill-creator validation task and reference docs must be updated to enforce and document the new SKILL.md structure. The linter (Fix D, #1387) and semantic auditor (Fix E, #1385) handle detection; this spec covers the validator integration and documentation.

## Requirements

### 1. Skill-creator validate task — add routing-only checks

Update `skill-creator/tasks/validate.md` to include the following checks in the validation workflow:

- **REQ-4**: SKILL.md body contains no procedure sections (mirrors SC-LINT-005)
  - Prohibited: "Procedure:", "Operating Protocol:", "Entry Criteria:", "Exit Criteria:", numbered step lists, code blocks with bash/python/YAML
  - Severity: ERROR
- **REQ-5**: Dispatch table sub-items use correct semantic type (mirrors SC-LINT-006)
  - Sub-bullets for parameter metadata (context fields, task file paths, dispatch type)
  - Sub-checkboxes for actionable sub-steps
  - Severity: WARNING
- **REQ-6**: All sub-task dispatch entries in the Trigger Dispatch Table have a corresponding `tasks/<task-name>.md` file
  - Severity: ERROR

### 2. Reference doc — routing-only SKILL.md template

Update `skills/reference/skill-card-change-types.md` to add a new change type:

**Type 11: Routing-Only Restructure**

| Field | Value |
|-------|-------|
| **Name** | Routing-Only Restructure |
| **Description** | Moving procedure content (step definitions, entry/exit criteria, code snippets, Operating Protocol) from SKILL.md to `tasks/*.md` files. SKILL.md retains only routing metadata: Trigger Dispatch Table, canonical dispatch strings, cross-references. |
| **Trigger** | Orchestrator bypasses dispatch gate because SKILL.md contains procedure text that enables inline execution. |
| **Blast Radius** | **Cross-skill** — affects every skill that undergoes the restructure. Each skill's orchestrator context shrinks to routing-only. |
| **Remediation Guidance** | Move all procedure sections to `tasks/<task-name>.md`. SKILL.md retains: Overview (1-2 sentences), Trigger Dispatch Table (checkbox list), Invocation (canonical strings), Cross-References, Symbolic rules. Sub-item semantics: sub-bullets for parameter metadata, sub-checkboxes for actionable sub-steps. |
| **Validation** | `grep` for absence of prohibited patterns in SKILL.md ("Procedure:", "Operating Protocol:", "Entry Criteria:", "Exit Criteria:"). `grep` for presence of Trigger Dispatch Table. Verify `tasks/*.md` files exist for all sub-task dispatch entries. |
| **Workflow Validation** | Generate Z3 solve contract for the restructured dispatch chain. Run `solve check` — MUST return SAT. Run `plan plan` — MUST return SOLVED_SATISFICING or SOLVED_OPTIMALLY. |
| **Example Spec** | `.opencode#1407` |

### 3. Reference doc — sub-item semantics

Add a new reference document at `skills/reference/sub-item-semantics.md`:

```markdown
# Sub-Item Semantics for Trigger Dispatch Tables

## Overview

Trigger Dispatch Table entries use two types of sub-items, each with a distinct semantic meaning:

### Sub-bullets (`-`): Parameter Metadata

Used for informational fields that describe the dispatch parameters. Not actionable.

Examples:
- Context fields passed to the sub-agent
- Task file path for the discovery directive
- Dispatch type annotation

### Sub-checkboxes (`- [ ]`): Actionable Sub-Steps

Used for discrete actions that must be performed as part of the dispatch. Each sub-checkbox represents a unit of work.

Examples:
- Pre-dispatch setup steps
- Post-dispatch verification steps
- Conditional branching decisions

## Enforcement

- SC-LINT-006 (structural linter) detects type violations
- SC-SEM-006 (semantic auditor) verifies type correctness
- REQ-5 (skill-creator validate) enforces during validation
```

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | skill-creator validate task includes REQ-4 (no procedure sections) | `string` |
| SC-2 | skill-creator validate task includes REQ-5 (sub-item type correctness) | `string` |
| SC-3 | skill-creator validate task includes REQ-6 (task files exist for sub-task entries) | `string` |
| SC-4 | skill-card-change-types.md includes Type 11 (Routing-Only Restructure) | `structural` |
| SC-5 | skills/reference/sub-item-semantics.md created with sub-bullet/sub-checkbox definitions | `structural` |
| SC-6 | Behavioral test: skill-creator validate detects SKILL.md with procedure sections | `behavioral` |
| SC-7 | Behavioral test: skill-creator validate detects missing task file for sub-task entry | `behavioral` |

## References

- `.opencode#1407` — routing-only SKILL.md restructure (parent spec)
- `.opencode#1385` — Fix E: semantic auditor criteria (SC-SEM-006)
- `.opencode#1387` — Fix D: linting rules (SC-LINT-005, SC-LINT-006)
- `skill-creator/tasks/validate.md` — validation task file
- `skills/reference/skill-card-change-types.md` — change type taxonomy

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
