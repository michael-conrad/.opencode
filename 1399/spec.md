> **Full spec and plan artifacts:** https://github.com/michael-conrad/.opencode/tree/issues-data/1399/

## Problem

Multiple spec-creation task files contain language that lets agents skip mandatory steps, producing defective specs. The original design (commit 4ec894fc) intentionally had skip conditions in the Tasks table's "Skippable?" column, but this is structurally wrong — allowing agents to self-classify their work as "trivial" or "simple" means they skip rigor and produce incomplete specs.

## Scope

**In scope:**
- Remove skip/optional/opt-out language from Entry Criteria in 4 task files
- Verify SKILL.md Tasks table has no "Skippable?" column

**Out of scope:**
- No changes to task file content beyond Entry Criteria lines
- No changes to task file procedures, exit criteria, or other sections
- The `description` frontmatter fix is tracked in #1388

## Approach

For each defective file, remove the skip opt-out or weak qualifier from the Entry Criteria section. The fixes are:

1. **decompose.md** — Remove "or explicitly skipped for trivial specs" → "Requirements extraction completed"
2. **risk.md** — Remove "(Recommended)" qualifier → "Decomposition completed"
3. **traceability.md** — Remove "(Optional)" qualifier → "Decomposition completed"
4. **write.md** — Remove "or explicitly skipped via simplicity heuristic" → "Other prerequisite tasks completed"

Also verify the SKILL.md Tasks table has no "Skippable?" column (already confirmed clean).

## Impact

| Risk | Mitigation |
|------|------------|
| Overlooked skip patterns in other sections | SC-5 covers all Entry Criteria sections across all task files |
| SKILL.md Tasks table regression | SC-6 verifies no "Skippable?" column exists |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/1399/`.
After creation, `local-issues sync 1399` MUST be run and the result committed to create the local `.opencode/.issues/1399/` entry.
The implementation plan will be created in `.opencode/.issues/1399/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

| Constraint | Value |
|------------|-------|
| Length | 150-300 words, 1 page max |
| Structure | BLUF — conclusion/action first, context second, evidence third |
| Tone | Assertive, decision-oriented, jargon-free, third-person |
| Independence | Fully readable without clicking any link |
| Links | All links MUST be full resolved URLs from session-init — no platform-specific shortcuts |
| Exclusions | No implementation details, file paths, algorithms, methodology, unreferenced acronyms |
| Platform | Platform-agnostic — no hardcoded GitHub/GitBucket tool names |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `decompose.md` Entry Criteria no longer contains "or explicitly skipped" | `string` | grep for "explicitly skipped" in decompose.md — 0 matches |
| SC-2 | `risk.md` Entry Criteria no longer contains "(Recommended)" | `string` | grep for "(Recommended)" in risk.md — 0 matches |
| SC-3 | `traceability.md` Entry Criteria no longer contains "(Optional)" | `string` | grep for "(Optional)" in traceability.md — 0 matches |
| SC-4 | `write.md` Entry Criteria no longer contains "or explicitly skipped" | `string` | grep for "explicitly skipped" in write.md — 0 matches |
| SC-5 | No skip/optional language remains in any spec-creation task file Entry Criteria | `string` | grep for "skipped\|optional\|Optional\|Recommended\|simplicity heuristic" in tasks/*.md Entry Criteria sections — 0 matches |
| SC-6 | SKILL.md Tasks table has no "Skippable?" or skip column | `string` | grep for "Skippable" in SKILL.md — 0 matches |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)