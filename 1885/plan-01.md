# Phase 1: Per-File Changes — Artifact Gate Implementation

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6
**Concern:** Artifact-gate implementation
**Evidence types:** SC-1 through SC-6 = `string` (grep)

## Entry Criteria

- Phase 0 complete (coherence gate + pre-flight checks PASS)

## Steps

### Step 1.1: TDT "create plan" Artifact Pre-Check (SC-1)

**File:** `.opencode/skills/writing-plans/SKILL.md`
**Location:** Trigger Dispatch Table, "create plan" row
**Change:** Add artifact validation step before dispatch to `create` task. The "create plan" entry must first verify analytical artifacts exist before dispatching.
**Evidence type:** `string`
**RED:** Write grep test for artifact validation in TDT "create plan" row — test FAILS
**GREEN:** Edit TDT "create plan" row to include artifact pre-check
**Verification:** `grep` for artifact validation in TDT "create plan" row

**Specific edit:** In the "create plan" / "analytical artifacts ready for plan" TDT entries, the dispatch action must include artifact pre-check logic that returns BLOCKED with MISSING_SPEC_ARTIFACT before invoking the task.

### Step 1.2: pre-plan-readiness Artifact Check (SC-2)

**File:** `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md`
**Change:** Add a new check step that verifies all 7 analytical artifacts exist in `.issues/{N}/` before allowing plan creation. Missing artifacts produce `BLOCKED` with `MISSING_SPEC_ARTIFACT`.
**Evidence type:** `string`
**RED:** Write grep test for artifact names (blast-radius, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) in pre-plan-readiness.md — test FAILS (no artifact check exists)
**GREEN:** Edit pre-plan-readiness.md to add artifact check step
**Verification:** `grep` for each of the 7 artifact names in pre-plan-readiness.md

### Step 1.3: Entry Criteria Artifact Requirement (SC-3)

**File:** `.opencode/skills/writing-plans/SKILL.md`
**Location:** Entry Criteria section
**Change:** Add analytical artifact presence as a prerequisite alongside spec approval and authorization scope.
**Evidence type:** `string`
**RED:** Write grep test for "analytical artifact" in Entry Criteria — test FAILS
**GREEN:** Edit Entry Criteria section to add artifact prerequisite
**Verification:** `grep` for "analytical artifact" in Entry Criteria

### Step 1.4: Item 8 Hard-Gate Verification (SC-4)

**File:** `.opencode/skills/writing-plans/SKILL.md`
**Location:** Mandatory Task Discipline item 8
**Change:** Verify Item 8 already has hard-gate language ("BLOCKED with MISSING_SPEC_ARTIFACT") from commit 850c2dd0a. SC-4 verifies consistent enforcement across all entry points.
**Evidence type:** `string`
**GREEN only:** Verify Item 8 contains "BLOCKED" and "MISSING_SPEC_ARTIFACT"
**Verification:** `grep` for "BLOCKED" and "MISSING_SPEC_ARTIFACT" in Item 8

### Step 1.5: spec-to-plan Handoff Artifact Validation (SC-5)

**File:** `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md`
**Change:** Add artifact validation check to the handoff manifest procedure that validates all 7 analytical artifact names are present.
**Evidence type:** `string`
**RED:** Write grep test for artifact names in spec-to-plan.md — test FAILS
**GREEN:** Edit spec-to-plan.md to add artifact validation check
**Verification:** `grep` for artifact names in spec-to-plan.md handoff manifest

### Step 1.6: Critical-Rules Entry (SC-6)

**File:** `.opencode/guidelines/000-critical-rules.md`
**Change:** Add a critical-rules entry prohibiting bypassing the artifact gate. Classification: Tier 2 (Process-Integrity). Reference the behavioral enforcement test.
**Evidence type:** `string`
**RED:** Write grep test for "artifact gate" or "analytical artifact" in 000-critical-rules.md — test FAILS
**GREEN:** Edit 000-critical-rules.md to add entry
**Verification:** `grep` for "artifact gate" or "analytical artifact" in 000-critical-rules.md

## Cross-Cutting Concern: Artifact Name Consistency (CC-1)

All 5 Phase 1 changes (Steps 1.1-1.6) must reference the identical set of 7 analytical artifact names:
- blast-radius
- code-path-inventory
- cross-cutting-matrix
- interface-compatibility
- state-analysis
- testability-assessment

A typo or omission in any one entry point creates a bypass.

## Phase Completion Gate

All 6 SCs (SC-1 through SC-6) MUST be PASS before proceeding to Phase 2.
Each SC verified by grep on the modified file.
