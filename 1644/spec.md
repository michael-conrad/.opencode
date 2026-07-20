---
type: SPEC
status: DRAFT
version: 2.1
created: 2026-07-01
updated: 2026-07-09
labels: [SPEC, audit, branch-verification]
priority: high
---

# [SPEC] Branch-Verification Mandate for audit

## Problem

Auditors in `audit` can be dispatched against the wrong branch — multiple AI agents on conflicting branches, stale worktrees from previous sessions, or post-merge drift. No task file verifies that the checked-out branch matches the target branch for the spec/plan being audited. This produces undetected cross-ups: the auditor evaluates a spec against the wrong codebase state, consuming cycles on irrelevant findings or — worse — reporting false confirmations.

This was originally proposed in `.opencode#483` (SC-9 / CONS-8) but that spec was a consolidation mega-spec that is now partially superseded. This spec extracts the branch-verification mandate as a focused, standalone concern.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The Pre-Flight Validation Gate in every audit task file includes branch verification (checking current branch against target branch) | `string` | `grep -c "BRANCH_MISMATCH\|branch.*verification\|branch.*target" .opencode/skills/audit/tasks/*.md` returns ≥ 15 |
| SC-2 | Branch mismatch produces `BRANCH_MISMATCH` result with `expected`, `actual`, `escalation` fields | `string` | `grep "BRANCH_MISMATCH" .opencode/skills/audit/tasks/*.md` returns matches |
| SC-3 | Branch mismatch prevents any audit logic from executing | `behavioral` | Clean-room semantic inspector: agent HALTs on branch mismatch, does not proceed to audit |
| SC-4 | Matching branch proceeds to normal audit flow | `behavioral` | Clean-room semantic inspector: agent proceeds through audit on branch match |
| SC-5 | Target branch resolution documented in SKILL.md | `string` | `grep "target.*branch\|branch.*resolution" .opencode/skills/audit/SKILL.md` returns match |
| SC-6 | Behavioral enforcement test exists for branch mismatch → hard FAIL + escalation | `behavioral` | Test script exists at `tests/behaviors/` and passes |

## Files Affected

| File | Change |
|------|--------|
| `.opencode/skills/audit/tasks/spec-audit.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/verification-audit.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/plan-fidelity.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/concern-separation.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/coherence-extraction.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/coherence-maintenance.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/guideline-audit.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/drift-detection.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/spec-summary.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/closure-verification.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/cross-validate.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/test-quality-audit.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/content-audit.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/resolve-models.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/tasks/completion.md` | Add branch verification to Pre-Flight Validation Gate |
| `.opencode/skills/audit/SKILL.md` | Document target branch resolution |
| `.opencode/tests/behaviors/` | New behavioral test for branch mismatch |

## Implementation Approach

**Approach B (selected): Add branch verification to the common Pre-Flight Validation Gate pattern.**

Every audit task file already has a Pre-Flight Validation Gate (Step 0) that validates required inputs (`spec_local_dir`, etc.) with a consistent pattern. Adding branch verification to this shared gate is a single conceptual change that propagates to all 15 task files. The gate already returns BLOCKED with `MISSING_REQUIRED_INPUT` — branch mismatch would return BLOCKED with `BRANCH_MISMATCH`.

This is preferred over the original approach (adding a separate "step_0" to each task file) because:
- Lower touch: one gate pattern change instead of 15 individual step insertions
- Consistent with existing architecture: branch verification is a pre-flight concern, not a separate audit step
- Reuses the existing BLOCKED return pattern — no new control flow needed
- The gate sits before role-specific logic (Evaluator, Knowledge Supporter, etc.), so branch verification applies uniformly regardless of DiMo role

## Constraints

- Branch verification is added to the Pre-Flight Validation Gate in every task file — before any audit logic and before role-specific dispatch
- On mismatch: hard FAIL, emit `BRANCH_MISMATCH` with `{ expected, actual, escalation: "developer" }`
- On match: proceed to normal audit flow
- Target branch is `main` (trunk-based development per #1657 — the dev branch has been removed)
- Target branch determined from invocation context or explicit `--branch` parameter
- If no target determinable: log warning, proceed (best-effort)
- No exception to the branch verification requirement
- The Pre-Flight Validation Gate already returns BLOCKED with `MISSING_REQUIRED_INPUT` for missing inputs; branch mismatch adds a parallel `BRANCH_MISMATCH` return path in the same gate

## DiMo Architecture Context

Post-creation, issues #1772 and #1672 implemented a DiMo (Role-Differentiated) architecture for audit tasks. Task files now have role headers (Evaluator, Knowledge Supporter, etc.) that define role-specific behavior. The Pre-Flight Validation Gate sits before the role-specific logic in every task file — it is a shared gate that fires before any role-specific dispatch. Branch verification integrates naturally into this gate, applying uniformly to all roles.

## Trunk-Based Development Context

Issue #1657 removed the dev branch. The target branch for branch resolution is `main`, not `dev`. All branch comparison logic must reference `main` as the canonical target.

## Coordination with #1643

SC-6 (behavioral test for branch mismatch) overlaps with #1643's behavioral test SCs. The behavioral test for branch mismatch should be coordinated with #1643 to avoid duplicate test scripts. Specifically:
- The test script should be placed in a location agreed with #1643
- Test assertions should be complementary, not overlapping
- If #1643 already covers branch-mismatch behavioral testing, SC-6 may be satisfied by extending that test rather than creating a new one

## Dependencies

- #1657 — Trunk-based development (affects branch resolution: target is `main`, not `dev`)
- #1772/#1672 — DiMo architecture (affects task file structure: role headers, Pre-Flight Gate position)
- #1643 — Behavioral test coordination (SC-6 overlap: avoid duplicate test scripts)
- **`.opencode#1645` — Baseline generation for audit** — SC-5 `branch_checked` field in #1645's baseline schema overlaps with this spec's branch verification mechanism. The baseline schema's `branch_checked` field should consume this spec's branch check output, not define its own. Coordinate during implementation: #1644 produces branch-verification output, #1645 consumes it for baseline snapshots.

## Interdependencies

| Issue | Relationship | Action |
|-------|-------------|--------|
| **#580** (PR staleness verification) | LOW | #580 and this spec both use `git rev-list --count --left-right` for branch state verification — #580 for PR creation staleness, this spec for audit pre-flight branch verification. Could share utility code or a common helper if implemented in the same timeframe. No direct coupling — complementary mechanisms. |

## Origin

Extracted from `.opencode#483` (closed as partially superseded). The consolidation work from #483 is complete; this spec addresses the remaining branch-verification gap.

🤖 OpenCode (deepseek-v4-flash)