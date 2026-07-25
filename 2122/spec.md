---
remote_issue: 2122
remote_url: https://github.com/michael-conrad/.opencode/issues/2122
labels: [spec]
---

## Problem

`010-approval-gate.md` is ~250 lines / ~13.7KB. While better-structured than 000, it contains sections that are only relevant when specific skills are dispatched — not at session start. These sections consume preloaded context unnecessarily.

## Proposed Solution

Move 6 sections to their respective skill/task cards. Keep 13 sections that are universal or orchestrator-level.

### Move to skill/task cards:

| Section | Destination | Rationale |
|---|---|---|
| Spec-to-Plan Approval Cascade + Edge Cases | `approval-gate` skill card | Internal approval-gate logic — only relevant when that skill is dispatched |
| Re-implementation Workflow | `approval-gate` skill card | Procedure only followed when approval-gate-006 fires |
| Label Handling | `approval-gate` skill card | Label management is the approval-gate skill's job |
| Audit Auto-Fix Exemption | `audit` skill card | Only relevant when audit is dispatched |
| Bug Report Response | `issue-operations` skill card | Bug-to-spec workflow is an issue-operations concern |
| Bug Discovery Protocol | `approval-gate` skill card | Authorization boundary enforcement — approval-gate's domain |

### Keep (universal/orchestrator-level, must be in every agent's context):

- Tier 0 Zero Tolerance Rules table
- Mandatory Requirements
- Issue Creation Is Reporting
- Decision Table: Authorization + File Modifications
- Explicit Authorization Priority
- Authorization Scope + Scope Model
- Scope Is Permission, Not Shortcut
- Multi-Task Plan Authorization
- Authorization Carry-Forward
- Revision Revokes Approval
- Action Authorization Classification
- `for_analysis` Allowlist/Blocklist
- Key Edge Cases

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Spec-to-Plan Approval Cascade content exists in `approval-gate` skill card | string | grep for cascade rule in approval-gate/SKILL.md |
| SC-2 | Re-implementation Workflow content exists in `approval-gate` skill card | string | grep for re-implementation steps in approval-gate/SKILL.md |
| SC-3 | Label Handling content exists in `approval-gate` skill card | string | grep for label rules in approval-gate/SKILL.md |
| SC-4 | Audit Auto-Fix Exemption content exists in `audit` skill card | string | grep for auto-fix exemption in audit/SKILL.md |
| SC-5 | Bug Report Response content exists in `issue-operations` skill card | string | grep for bug-to-spec workflow in issue-operations/SKILL.md |
| SC-6 | Bug Discovery Protocol content exists in `approval-gate` skill card | string | grep for bug discovery protocol in approval-gate/SKILL.md |
| SC-7 | All 13 keep sections remain in 010-approval-gate.md | string | grep for each section header |
| SC-8 | No content loss — moved sections have equivalent content in target cards | behavioral | Compare moved section content against target card content; verify all rules preserved |
| SC-9 | No orphaned cross-references to moved sections in other files | string | grep for moved section names across .opencode/ — only target cards and 010 remain |
| SC-10 | No line-count or word-count metrics used as success measurement | string | grep for absence of 'wc -l', 'file size', 'Final file size' in spec |

## Implementation Plan

### Phase 1: Move Spec-to-Plan Cascade, Re-implementation, Label Handling to approval-gate skill
### Phase 2: Move Audit Auto-Fix Exemption to audit skill
### Phase 3: Move Bug Report Response to issue-operations skill
### Phase 4: Move Bug Discovery Protocol to approval-gate skill
### Phase 5: Verify all 13 keep sections remain and no content loss

## Files Affected

- `.opencode/guidelines/010-approval-gate.md` — compacted
- `.opencode/skills/approval-gate/SKILL.md` — receives 4 sections
- `.opencode/skills/audit/SKILL.md` — receives 1 section
- `.opencode/skills/issue-operations/SKILL.md` — receives 1 section

## Risks

- **Content loss**: Moved sections must have equivalent content in target cards. Mitigation: SC-8 requires behavioral comparison.
- **Orphaned cross-references**: If other files reference the moved sections by name, those references break. Mitigation: SC-9 verifies no orphaned refs.

## Dependencies

- None. Self-contained refactoring.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
