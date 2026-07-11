# Blast Radius Analysis — Issue #1885

**Spec:** [SPEC-FIX] Close artifact gate bypass escape hatch in writing-plans skill
**Generated:** 2026-07-11
**Root symbols:** 5 directly changed files

---

## Root Symbols (Directly Changed)

| ID | File | Change |
|----|------|--------|
| R1 | `.opencode/skills/writing-plans/SKILL.md` | Trigger Dispatch Table: add artifact pre-check; Entry Criteria: add artifact requirement; Mandatory Task Discipline item 8: elevate to hard gate |
| R2 | `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md` | Add artifact check procedure step |
| R3 | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` | Add artifact validation check |
| R4 | `.opencode/guidelines/000-critical-rules.md` | Add critical-rules entry prohibiting artifact gate bypass |
| R5 | `.opencode/tests/behaviors/` | New behavioral enforcement test |

---

## Affected Symbols Table

### Direct Consumers (First Ring)

Symbols that directly call, import, reference, or dispatch to the changed symbols.

| ID | File | Impact Classification | Propagation Path | Impact Severity | Notes |
|----|------|----------------------|------------------|-----------------|-------|
| D1 | `.opencode/skills/writing-plans/tasks/create.md` | Direct consumer | R1 → D1 (reads Trigger Dispatch Table, Entry Criteria, Mandatory Task Discipline) | **HIGH** | Step 4a artifact validation already exists; entry-point check complements it. No structural change needed to create.md itself. |
| D2 | `.opencode/skills/writing-plans/tasks/retroactive.md` | Direct consumer | R1 → D2 (dispatches writing-plans sub-tasks) | **LOW** | Retroactive path also benefits from entry-point artifact gate. No change needed — gate fires before any task dispatch. |
| D3 | `.opencode/skills/writing-plans/tasks/completion.md` | Direct consumer | R1 → D3 (references writing-plans) | **LOW** | Completion task unaffected — gate fires at entry, not completion. |
| D4 | `.opencode/skills/writing-plans/tasks/clean-room.md` | Direct consumer | R1 → D4 (references writing-plans) | **LOW** | Clean-room task unaffected. |
| D5 | `.opencode/skills/writing-plans/tasks/operating-protocol.md` | Direct consumer | R1 → D5 (references writing-plans) | **LOW** | Operating protocol unaffected. |
| D6 | `.opencode/skills/writing-plans/tasks/readiness.md` | Direct consumer | R3 → D6 (references spec-to-plan handoff) | **LOW** | Readiness task already checks sc-pipeline-readiness.yaml; artifact check is complementary. |
| D7 | `.opencode/guidelines/INDEX.md` | Direct consumer | R4 → D7 (must be updated with new trigger pattern) | **HIGH** | INDEX.md must add the new critical-rules entry's trigger pattern. |
| D8 | `.opencode/skills/plan-creation-pipeline/SKILL.md` | Direct consumer | R1 → D8 (references writing-plans --task create) | **MEDIUM** | Plan-creation-pipeline dispatches to writing-plans; entry-point gate fires before pipeline entry. |
| D9 | `.opencode/skills/spec-creation/SKILL.md` | Direct consumer | R1 → D9 (pipeline: brainstorming → spec-creation → ... → writing-plans) | **MEDIUM** | Spec-creation pipeline references writing-plans as downstream step. |
| D10 | `.opencode/skills/spec-creation/tasks/create.md` | Direct consumer | R3 → D10 (generates spec-to-plan-handoff.yaml) | **MEDIUM** | Spec-creation generates the handoff manifest that spec-to-plan validates. |
| D11 | `.opencode/skills/approval-gate/SKILL.md` | Direct consumer | R3 → D11 (references spec-to-plan cascade) | **MEDIUM** | Approval-gate references spec-to-plan cascade. |
| D12 | `.opencode/skills/approval-gate/tasks/verify-authorization.md` | Direct consumer | R3 → D12 (references spec-to-plan-cascade) | **MEDIUM** | Verify-authorization references spec-to-plan-cascade. |
| D13 | `.opencode/skills/approval-gate/tasks/verify-authorization/spec-to-plan-cascade.md` | Direct consumer | R3 → D13 (spec-to-plan cascade logic) | **MEDIUM** | Spec-to-plan cascade task. |
| D14 | `.opencode/skills/approval-gate/enforcement/auto-dispatch-table.md` | Direct consumer | R3 → D14 (references spec-to-plan-cascade) | **LOW** | Auto-dispatch table references spec-to-plan-cascade. |
| D15 | `.opencode/skills/approval-gate/enforcement/work-state-schema.md` | Direct consumer | R3 → D15 (references spec-to-plan-cascade) | **LOW** | Work-state schema references spec-to-plan-cascade. |
| D16 | `.opencode/skills/implementation-pipeline/tasks/pre-flight.md` | Direct consumer | R3 → D16 (reads spec-to-plan-handoff-*.yaml) | **MEDIUM** | Pre-flight reads spec-to-plan handoff manifest for consistency checks. |
| D17 | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` | Direct consumer | R3 → D17 (reads spec-to-plan-handoff-*.yaml) | **MEDIUM** | Pre-flight-handoff reads spec-to-plan handoff manifest. |
| D18 | `.opencode/skills/brainstorming/SKILL.md` | Direct consumer | R1 → D18 (references writing-plans) | **LOW** | Brainstorming references writing-plans as downstream skill. |
| D19 | `.opencode/skills/brainstorming/tasks/completion.md` | Direct consumer | R1 → D19 (references writing-plans) | **LOW** | Brainstorming completion references writing-plans. |
| D20 | `.opencode/skills/brainstorming/tasks/explore/exploration-workflow.md` | Direct consumer | R1 → D20 (references writing-plans) | **LOW** | Exploration workflow references writing-plans. |
| D21 | `.opencode/skills/audit/tasks/plan-fidelity.md` | Direct consumer | R1 → D21 (references writing-plans for clean-room generation) | **LOW** | Plan-fidelity audit references writing-plans. |
| D22 | `.opencode/skills/completeness-gate/SKILL.md` | Direct consumer | R1 → D22 (routes to writing-plans on FAIL) | **LOW** | Completeness-gate routes to writing-plans. |
| D23 | `.opencode/skills/issue-operations/tasks/comment.md` | Direct consumer | R1 → D23 (references writing-plans --task update) | **LOW** | Comment task references writing-plans. |
| D24 | `.opencode/skills/issue-operations/tasks/single-task-check.md` | Direct consumer | R1 → D24 (references writing-plans) | **LOW** | Single-task-check references writing-plans. |
| D25 | `.opencode/skills/issue-operations/tasks/pre-creation.md` | Direct consumer | R1 → D25 (references writing-plans duplicate check) | **LOW** | Pre-creation references writing-plans. |
| D26 | `.opencode/skills/verification-before-completion/tasks/verify.md` | Direct consumer | R1 → D26 (references writing-plans) | **LOW** | VbC verify references writing-plans. |
| D27 | `.opencode/skills/verification-enforcement/SKILL.md` | Direct consumer | R1 → D27 (references writing-plans) | **LOW** | Verification-enforcement references writing-plans. |
| D28 | `.opencode/skills/solve/SKILL.md` | Direct consumer | R1 → D28 (references writing-plans) | **LOW** | Solve references writing-plans. |
| D29 | `.opencode/guidelines/010-approval-gate.md` | Direct consumer | R1 → D29 (references writing-plans) | **LOW** | Approval-gate guideline references writing-plans. |
| D30 | `.opencode/skills/executing-plans/tasks/start.md` | Direct consumer | R4 → D30 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change for existing consumers. |
| D31 | `.opencode/skills/executing-plans/tasks/step.md` | Direct consumer | R4 → D31 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D32 | `.opencode/skills/implementation-pipeline/SKILL.md` | Direct consumer | R4 → D32 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D33 | `.opencode/skills/implementation-pipeline/tasks/sc-count-gate.md` | Direct consumer | R4 → D33 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D34 | `.opencode/skills/implementation-pipeline/tasks/checkpoint-tag-create.md` | Direct consumer | R4 → D34 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D35 | `.opencode/skills/completeness-gate/tasks/check.md` | Direct consumer | R4 → D35 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D36 | `.opencode/skills/finishing-a-development-branch/SKILL.md` | Direct consumer | R4 → D36 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D37 | `.opencode/skills/finishing-a-development-branch/tasks/completion.md` | Direct consumer | R4 → D37 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D38 | `.opencode/skills/audit/tasks/spec-audit.md` | Direct consumer | R4 → D38 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D39 | `.opencode/skills/audit/tasks/guideline-audit.md` | Direct consumer | R4 → D39 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D40 | `.opencode/skills/audit/tasks/verification-audit.md` | Direct consumer | R4 → D40 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D41 | `.opencode/skills/audit/tasks/content-audit.md` | Direct consumer | R4 → D41 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D42 | `.opencode/skills/audit/tasks/cross-validate.md` | Direct consumer | R4 → D42 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D43 | `.opencode/skills/audit/tasks/coherence-extraction.md` | Direct consumer | R4 → D43 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D44 | `.opencode/skills/audit/tasks/coherence-maintenance.md` | Direct consumer | R4 → D44 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D45 | `.opencode/skills/audit/tasks/drift-detection.md` | Direct consumer | R4 → D45 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D46 | `.opencode/skills/audit/tasks/closure-verification.md` | Direct consumer | R4 → D46 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D47 | `.opencode/skills/audit/tasks/spec-summary.md` | Direct consumer | R4 → D47 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D48 | `.opencode/skills/audit/tasks/concern-separation.md` | Direct consumer | R4 → D48 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D49 | `.opencode/skills/issue-operations/SKILL.md` | Direct consumer | R4 → D49 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D50 | `.opencode/skills/issue-operations/tasks/creation.md` | Direct consumer | R4 → D50 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D51 | `.opencode/skills/issue-operations/tasks/completion.md` | Direct consumer | R4 → D51 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D52 | `.opencode/skills/issue-operations/tasks/update-issue.md` | Direct consumer | R4 → D52 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D53 | `.opencode/skills/issue-operations/platforms/local/SKILL.md` | Direct consumer | R4 → D53 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D54 | `.opencode/skills/issue-operations/platforms/local/tasks/push-body.md` | Direct consumer | R4 → D54 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D55 | `.opencode/skills/issue-review/SKILL.md` | Direct consumer | R4 → D55 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D56 | `.opencode/skills/issue-review/tasks/audit.md` | Direct consumer | R4 → D56 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D57 | `.opencode/skills/issue-review/tasks/analyze-and-spec.md` | Direct consumer | R4 → D57 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D58 | `.opencode/skills/issue-review/tasks/qa.md` | Direct consumer | R4 → D58 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D59 | `.opencode/skills/issue-review/tasks/operating-protocol.md` | Direct consumer | R4 → D59 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D60 | `.opencode/skills/systematic-debugging/SKILL.md` | Direct consumer | R4 → D60 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D61 | `.opencode/skills/git-workflow/tasks/cleanup/branch-cleanup.md` | Direct consumer | R4 → D61 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D62 | `.opencode/skills/conflict-resolution/tasks/classify-and-resolve.md` | Direct consumer | R4 → D62 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D63 | `.opencode/skills/correspondence/SKILL.md` | Direct consumer | R4 → D63 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D64 | `.opencode/guidelines/020-go-prohibitions.md` | Direct consumer | R4 → D64 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D65 | `.opencode/guidelines/060-tool-usage.md` | Direct consumer | R4 → D65 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D66 | `.opencode/guidelines/065-verification-honesty.md` | Direct consumer | R4 → D66 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D67 | `.opencode/guidelines/067-context-completeness.md` | Direct consumer | R4 → D67 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D68 | `.opencode/guidelines/075-docs-verification.md` | Direct consumer | R4 → D68 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D69 | `.opencode/guidelines/080-code-standards.md` | Direct consumer | R4 → D69 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D70 | `.opencode/guidelines/091-incremental-build.md` | Direct consumer | R4 → D70 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D71 | `.opencode/guidelines/116-pair-mode.md` | Direct consumer | R4 → D71 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D72 | `.opencode/guidelines/117-session-trigger-behavior.md` | Direct consumer | R4 → D72 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D73 | `.opencode/guidelines/141-planning-status-tracking.md` | Direct consumer | R4 → D73 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D74 | `.opencode/AGENTS.md` | Direct consumer | R4 → D74 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D75 | `.opencode/README.md` | Direct consumer | R4 → D75 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D76 | `.opencode/CHANGELOG.md` | Direct consumer | R4 → D76 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |
| D77 | `.opencode/tests/behaviors/fixtures/issues/100-stacked-branch-for-pr/spec.md` | Direct consumer | R4 → D77 (references 000-critical-rules.md) | **LOW** | Additive entry — no behavior change. |

### Indirect Consumers (Second Ring)

Symbols that consume a direct consumer but not the changed symbol directly.

| ID | File | Impact Classification | Propagation Path | Impact Severity |
|----|------|----------------------|------------------|-----------------|
| I1 | `.opencode/skills/executing-plans/tasks/start.md` | Indirect consumer | R1 → D8 (plan-creation-pipeline) → I1 (executing-plans reads plan) | **LOW** |
| I2 | `.opencode/skills/verification-enforcement/SKILL.md` | Indirect consumer | R1 → D27 (verification-enforcement) → I2 (self-reference) | **LOW** |
| I3 | `.opencode/skills/issue-operations/tasks/post-creation.md` | Indirect consumer | R1 → D24 (single-task-check) → I3 (post-creation triggers writing-plans) | **LOW** |

### Data-Flow Dependents

Symbols that depend on data produced by the changed symbols through a chain of transformations.

| ID | File | Impact Classification | Propagation Path | Impact Severity |
|----|------|----------------------|------------------|-----------------|
| F1 | `.opencode/skills/implementation-pipeline/tasks/pre-flight-handoff.md` | Data-flow dependent | R3 (spec-to-plan handoff manifest) → D17 (pre-flight-handoff reads manifest) → F1 (plan-to-pipeline handoff consumes SC coverage data) | **MEDIUM** |
| F2 | `.opencode/skills/implementation-pipeline/tasks/pre-flight.md` | Data-flow dependent | R3 (spec-to-plan handoff manifest) → D16 (pre-flight reads manifest) → F2 (handoff-consistency check consumes SC coverage data) | **MEDIUM** |

---

## Boundary Symbols

Symbols at the edge of the blast radius where impact stops.

| ID | File | Boundary Type | Rationale |
|----|------|---------------|-----------|
| B1 | External agents invoking `skill({name: "writing-plans"})` | API boundary | The skill interface (`skill({name: "writing-plans"})`) does not change. The internal behavior changes (entry-point gate fires earlier) but the external contract is unchanged. |
| B2 | `.opencode/skills/writing-plans/tasks/create.md` Step 4a | Internal gate boundary | The existing artifact validation at Step 4a remains in place as a secondary validation gate. The new entry-point check fires before Step 4a. |
| B3 | `.opencode/guidelines/000-critical-rules.md` existing entries | Content boundary | The new entry is additive — it does not modify or remove any existing critical rule. Existing consumers of 000-critical-rules.md are unaffected. |
| B4 | `.opencode/tests/test-enforcement.sh` | Test infrastructure boundary | The test runner discovers new behavioral tests automatically. No change needed to the runner. |

---

## Coverage Verification

### Verification Checklist

- [x] Every direct consumer of a changed symbol is listed — D1 through D77 cover all files that reference writing-plans, pre-plan-readiness, spec-to-plan, or 000-critical-rules.md
- [x] Every indirect consumer reachable through a direct consumer is listed — I1 through I3 cover the second ring
- [x] Every data-flow dependent reachable through a data chain is listed — F1 and F2 cover the handoff manifest data flow
- [x] No symbol within the natural boundary is omitted — boundary symbols B1-B4 document where impact stops

### Cross-Reference Verification

| Check | Method | Result |
|-------|--------|--------|
| All writing-plans references found | `grep "writing-plans" --include="*.md" .opencode/` | ✅ 100+ matches, all classified |
| All pre-plan-readiness references found | `grep "pre-plan-readiness" --include="*.md" .opencode/` | ✅ 3 matches, all classified |
| All spec-to-plan references found | `grep "spec-to-plan" --include="*.md" .opencode/` | ✅ 28 matches, all classified |
| All 000-critical-rules references found | `grep "000-critical-rules" --include="*.md" .opencode/` | ✅ 100+ matches, all classified |

### Impact Summary

| Severity | Count | Key Files |
|----------|-------|-----------|
| **HIGH** | 2 | `writing-plans/tasks/create.md`, `guidelines/INDEX.md` |
| **MEDIUM** | 8 | `plan-creation-pipeline/SKILL.md`, `spec-creation/SKILL.md`, `spec-creation/tasks/create.md`, `approval-gate/SKILL.md`, `approval-gate/tasks/verify-authorization.md`, `approval-gate/tasks/verify-authorization/spec-to-plan-cascade.md`, `implementation-pipeline/tasks/pre-flight.md`, `implementation-pipeline/tasks/pre-flight-handoff.md` |
| **LOW** | 70 | All other direct consumers, indirect consumers, and data-flow dependents |

### Key Finding

The blast radius is **contained and low-risk**. The changes are:

1. **Additive, not destructive** — No existing behavior is removed. The entry-point artifact gate is a new check that fires before existing gates.
2. **Gate placement, not pipeline restructuring** — The 22-step pipeline structure is unchanged. The fix adds a pre-entry check, not a pipeline modification.
3. **The 000-critical-rules.md change is purely additive** — A new Tier 2 entry that does not modify any existing rule. All 70+ existing consumers of 000-critical-rules.md are unaffected.
4. **The behavioral test is self-contained** — A new test file that the test runner discovers automatically.

**Only 2 files have HIGH impact:**
- `writing-plans/tasks/create.md` — already has Step 4a artifact validation; the entry-point check complements it without structural change
- `guidelines/INDEX.md` — must be updated with the new critical-rules entry's trigger pattern (routine maintenance)
