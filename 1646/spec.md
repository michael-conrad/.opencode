---
type: SPEC
status: DRAFT
version: 1.0
created: 2026-07-01
labels: [SPEC, adversarial-audit, pipeline, touchpoint]
priority: medium
---

# [SPEC] Pipeline touchpoint verification — auto-invocation of adversarial-audit

## Problem

The `adversarial-audit` skill defines 7+ pipeline touchpoints where audits should auto-invoke (spec-creation, writing-plans, issue-operations, implementation-pipeline, verification-before-completion, pr-creation-workflow, git-workflow). However, there is no verification that these touchpoints actually invoke the audit. The dispatch table exists in `adversarial-audit/SKILL.md` but the consuming skills may or may not call it.

This was originally proposed in `.opencode#483` (SC-5) but that spec was a consolidation mega-spec that is now partially superseded. This spec extracts pipeline touchpoint verification as a focused, standalone concern.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Each touchpoint skill's SKILL.md or task file contains adversarial-audit invocation | `string` | `grep -l "adversarial-audit" .opencode/skills/spec-creation/SKILL.md .opencode/skills/writing-plans/SKILL.md .opencode/skills/issue-operations/SKILL.md .opencode/skills/implementation-pipeline/SKILL.md .opencode/skills/verification-before-completion/SKILL.md .opencode/skills/pr-creation-workflow/SKILL.md .opencode/skills/git-workflow/SKILL.md` — all 7 return matches |
| SC-2 | Behavioral test confirms automatic invocation at spec-creation touchpoint | `behavioral` | Clean-room semantic inspector: spec-creation pipeline dispatches spec-audit |
| SC-3 | Behavioral test confirms automatic invocation at writing-plans touchpoint | `behavioral` | Clean-room semantic inspector: writing-plans dispatches plan-fidelity + concern-separation |
| SC-4 | Behavioral test confirms automatic invocation at implementation-pipeline touchpoint | `behavioral` | Clean-room semantic inspector: implementation-pipeline dispatches coherence-extraction + coherence-maintenance |
| SC-5 | Behavioral test confirms automatic invocation at verification-before-completion touchpoint | `behavioral` | Clean-room semantic inspector: verification-before-completion dispatches cross-validate |
| SC-6 | Behavioral test confirms automatic invocation at pr-creation-workflow touchpoint | `behavioral` | Clean-room semantic inspector: pr-creation-workflow dispatches spec-summary |
| SC-7 | Behavioral test confirms automatic invocation at git-workflow touchpoint | `behavioral` | Clean-room semantic inspector: git-workflow dispatches closure-verification |
| SC-8 | Each touchpoint passes correct `audit_phase` context | `behavioral` | Clean-room semantic inspector: each invocation includes correct `audit_phase` value |
| SC-9 | No manual audit invocation required at these touchpoints | `behavioral` | Clean-room semantic inspector: audit fires automatically without explicit user request |

## Touchpoint Table

| Touchpoint | Pipeline Skill | Audit Task | audit_phase |
|------------|---------------|------------|-------------|
| 1 | spec-creation | spec-audit | spec_creation |
| 2 | writing-plans | plan-fidelity + concern-separation | plan_creation |
| 3 | issue-operations | concern-separation | sub_issue_creation |
| 4 | implementation-pipeline | coherence-extraction + coherence-maintenance | coherence_gate |
| 5 | verification-before-completion | cross-validate | implementation_verification |
| 6 | pr-creation-workflow | spec-summary | pr_creation |
| 7 | git-workflow | closure-verification | post_merge |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/spec-creation/SKILL.md` | Verify/update adversarial-audit invocation |
| `.opencode/skills/writing-plans/SKILL.md` | Verify/update adversarial-audit invocation |
| `.opencode/skills/issue-operations/SKILL.md` | Verify/update adversarial-audit invocation |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Verify/update adversarial-audit invocation |
| `.opencode/skills/verification-before-completion/SKILL.md` | Verify/update adversarial-audit invocation |
| `.opencode/skills/pr-creation-workflow/SKILL.md` | Verify/update adversarial-audit invocation |
| `.opencode/skills/git-workflow/SKILL.md` | Verify/update adversarial-audit invocation |
| `.opencode/tests/behaviors/` | 7 new behavioral tests (one per touchpoint) |

## Constraints

- Each touchpoint must pass the correct `audit_phase` context
- Behavioral tests must use stderr-based assertions (tool dispatch strings), not prose-recall prompts
- Tests must be scoped to trigger only the relevant touchpoint (not full pipeline execution)

## Dependencies

- None — self-contained spec

## Origin

Extracted from `.opencode#483` (closed as partially superseded). The consolidation work from #483 is complete; this spec addresses the remaining pipeline touchpoint verification gap.

🤖 OpenCode (deepseek-v4-flash)
