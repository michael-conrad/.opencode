## Summary

15 task files were originally identified as missing. After audit and cross-reference analysis, the actual count is **9 genuinely missing** — 5 are resolved by DiMo chain migration, 1 is a false positive.

## Audit Findings

### Resolved by DiMo Migration (5 — no action needed)

The audit skill migrated from monolithic task files to DiMo 4-role chain files (Investigator/Validator/Evaluator/Arbiter) via #1672, #1909, #1915, #1921. The old monolithic file names no longer exist, but their DiMo equivalents do:

| Claimed Missing | Resolved By | Role Files Present |
|----------------|-------------|-------------------|
| `audit/tasks/plan-fidelity.md` | DiMo migration | `plan-fidelity-investigator.md`, `-validator.md`, `-evaluator.md`, `-arbiter.md` |
| `audit/tasks/concern-separation.md` | DiMo migration | `concern-separation-*.md` (4 files) |
| `audit/tasks/spec-audit.md` | DiMo migration | `spec-audit-*.md` (4 files) |
| `audit/tasks/verification-audit.md` | DiMo migration | `verification-audit-*.md` (4 files) |
| `audit/tasks/coherence-maintenance.md` | DiMo migration | `coherence-maintenance-*.md` (4 files) |

**However:** Cross-referencing SKILL.md Trigger Dispatch Tables (writing-plans, implementation-pipeline) still reference the old monolithic names. These dispatch table entries need updating to reference the DiMo role chain.

### False Positive (1 — no action needed)

| Claimed Missing | Verdict | Evidence |
|----------------|---------|----------|
| `spec-creation/tasks/revise.md` | **FALSE POSITIVE** | spec-creation SKILL.md Trigger Dispatch Table has no `revise` entry. Revisions are handled by `change-control.md`, which exists. |

### Genuinely Missing (9 — action needed)

#### implementation-pipeline (1 file)

| File | Trigger Dispatch Table Reference |
|------|-------------------------------|
| `implementation-pipeline/tasks/tdd-chaining-gate.md` | SKILL.md line 76: `"multiple red phases" / "batch red"` → `tdd-chaining-gate` → `implementation-pipeline --task tdd-chaining-gate` |

#### approval-gate (8 files)

| File | Trigger Dispatch Table Reference |
|------|-------------------------------|
| `approval-gate/tasks/apply-label.md` | `"apply label" / "set approval label"` → `apply-label` |
| `approval-gate/tasks/spec-to-plan-cascade.md` | `"spec-to-plan cascade"` → `spec-to-plan-cascade` |
| `approval-gate/tasks/item-decomposition-check.md` | `"item decomposition check"` → `item-decomposition-check` |
| `approval-gate/tasks/auto-dispatch.md` | `"auto-dispatch"` → `auto-dispatch` |
| `approval-gate/tasks/approval-cascade.md` | `"approval cascade"` → `approval-cascade` |
| `approval-gate/tasks/check-halt-boundary.md` | `"pipeline halt boundary"` → `check-halt-boundary` |
| `approval-gate/tasks/revision-revocation.md` | `"revision revocation"` → `revision-revocation` |
| `approval-gate/tasks/bug-discovery-protocol.md` | `"bug discovery"` → `bug-discovery-protocol` |

## Overlap with #1881

**Issue #1881** (open, approved-for-pr) plans to split `approval-gate` into sub-skills, including `approval-gate-scope` which will house all 22 approval-gate task files. The 8 missing approval-gate task files are naturally part of #1881's scope — creating them now in `approval-gate/tasks/` only to move them to `approval-gate-scope/tasks/` when #1881 lands is double work.

**Recommendation:** The 8 approval-gate task files should be added as a success criterion in #1881 Phase 3 (approval-gate split), created directly in the sub-skill directory. The 1 implementation-pipeline file is independent and can be handled separately.

## Resolution

| Work Item | Where | How |
|-----------|-------|-----|
| 8 approval-gate task files | Tracked by #1881 | Add as SC to #1881 Phase 3; create in `approval-gate-scope/tasks/` |
| `implementation-pipeline/tasks/tdd-chaining-gate.md` | Standalone fix | Create independently — no overlap with #1881 |
| Update cross-referencing dispatch tables | writing-plans, implementation-pipeline | Reference DiMo role file names instead of old monolithic names |

## Impact

When a plan step dispatches to one of these missing task files, the sub-agent receives a discovery directive pointing to a non-existent file. The sub-agent must then search for the correct task file independently, wasting context and routing time. In the worst case, the sub-agent cannot find the task file and returns BLOCKED.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `implementation-pipeline/tasks/tdd-chaining-gate.md` exists | `structural` | File existence check |
| SC-2 | 8 approval-gate task files exist in `approval-gate-scope/tasks/` (via #1881) | `structural` | File existence check after #1881 implementation |
| SC-3 | writing-plans SKILL.md dispatch table references DiMo role file names (not old monolithic names) | `string` | grep for role file references in dispatch table |
| SC-4 | implementation-pipeline SKILL.md dispatch table references DiMo role file names (not old monolithic names) | `string` | grep for role file references in dispatch table |
| SC-5 | Issue body updated to reflect current state | `string` | grep confirms corrected counts |

## Change Control

| File | Change |
|------|--------|
| `implementation-pipeline/tasks/tdd-chaining-gate.md` | Create |
| `writing-plans/SKILL.md` | Update dispatch table references from `plan-fidelity`/`concern-separation` to DiMo role chain |
| `implementation-pipeline/SKILL.md` | Update dispatch table references from `coherence-maintenance` to DiMo role chain |

## Dependencies

- **#1881** — Tracks the 8 approval-gate task files as part of the skill split
- **#1921** — Established the DiMo role naming convention (Investigator/Validator/Evaluator/Arbiter)

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
