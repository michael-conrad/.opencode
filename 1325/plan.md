# Plan: Adversarial Audit Pre-Flight Validation Gate

**Spec:** [michael-conrad/.opencode#1325](https://github.com/michael-conrad/.opencode/issues/1325)
**Goal:** Insert a Step 0 Pre-Flight Validation Gate at the top of every adversarial audit task file's Procedure section, before any existing step.
**Architecture:** Single-task — same mechanical pattern applied to 10 task files. No architectural changes.
**Tech Stack:** Markdown task files in `.opencode/skills/adversarial-audit/tasks/`

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Phase 1: Pre-Flight Validation Gate Implementation

**Concern:** Entering implementation — adding Step 0 to all 10 audit task files
**Files:** `.opencode/skills/adversarial-audit/tasks/*.md` (10 files)
**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6
**Cost-frame:** String-evidence SCs (SC-1, SC-3, SC-4, SC-5) verified at pre-commit gate via grep — structural check, 1s execution, 1000× DDL if missed. Semantic SCs (SC-2, SC-6) verified at pre-PR gate via sub-agent read — 10× DDL multiplier. All SCs must PASS for spec approval per SC Enforcement Gate.

### Pre-RED Common

- [ ] 1. **Read spec and verify approval** (**inline**). Confirm spec #1325 is approved (`approved-for-*` label present). Read spec body to extract per-task required inputs table, standardized BLOCKED format, and Step 0 template. → SC-1
- [ ] 2. **Read all 10 task files** (**inline**). Read each file in `.opencode/skills/adversarial-audit/tasks/` to understand current Procedure section structure, existing BLOCKED error codes, and Completion Dependency Chain section. → SC-6
- [ ] 3. **Map per-task required inputs** (**inline**). For each of the 10 files, determine which required inputs from the spec's per-task table apply. Create a mapping: task → {required_inputs, needs_vbc, needs_plan, existing_error_codes}. → SC-2

### Per-Item RED+green Chains

- [ ] **TDD-1: verification-audit.md** (SC-1, SC-2, SC-3, SC-4, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `verification-audit.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. If it does, flag as already-implemented. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Insert Step 0 Pre-Flight Validation Gate at top of Procedure section. Required inputs: `spec_local_dir`, `artifact_evidence_dir` (≥2 YAML files — use `INSUFFICIENT_ARTIFACTS`). Include context-specific remediation messages. Renumber existing steps (Step 1→2, etc.). Update Completion Dependency Chain to include Step 0. Preserve existing BLOCKED error codes. → SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

- [ ] **TDD-2: cross-validate.md** (SC-1, SC-2, SC-3, SC-4, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `cross-validate.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: `spec_local_dir`, `artifact_evidence_dir` (≥2 YAML files — `INSUFFICIENT_ARTIFACTS`). Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

- [ ] **TDD-3: spec-audit.md** (SC-1, SC-2, SC-3, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `spec-audit.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: `spec_local_dir` only. No VbC, no plan needed. Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-5, SC-6

- [ ] **TDD-4: plan-fidelity.md** (SC-1, SC-2, SC-3, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `plan-fidelity.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: `clean_room_plan`, `spec_local_dir`. No VbC. Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-5, SC-6

- [ ] **TDD-5: concern-separation.md** (SC-1, SC-2, SC-3, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `concern-separation.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: `spec_local_dir` only. Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-5, SC-6

- [ ] **TDD-6: drift-detection.md** (SC-1, SC-2, SC-3, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `drift-detection.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: `spec_local_dir` only. Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-5, SC-6

- [ ] **TDD-7: closure-verification.md** (SC-1, SC-2, SC-3, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `closure-verification.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: PR number, spec issue number. Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-5, SC-6

- [ ] **TDD-8: spec-summary.md** (SC-1, SC-2, SC-3, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `spec-summary.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: PR number, spec issue number. Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-5, SC-6

- [ ] **TDD-9: guideline-audit.md** (SC-1, SC-2, SC-3, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `guideline-audit.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: target file paths. Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-5, SC-6

- [ ] **TDD-10: test-quality-audit.md** (SC-1, SC-2, SC-3, SC-5, SC-6)
  - [ ] 1. **RED: Step 0 does not exist** (**clean-room**). Verify `test-quality-audit.md` does NOT contain `### Step 0: Pre-Flight Validation Gate`. → SC-1
  - [ ] 2. **GREEN: Insert Step 0** (**clean-room**). Required inputs: VbC artifact path, `file_paths_changed`, `spec_success_criteria`. Renumber steps. Update dependency chain. Preserve existing codes. → SC-1, SC-2, SC-3, SC-5, SC-6

### Post-RED/green

- [ ] 3. **SC-1 verification: grep for Step 0 in all 10 files** (**inline**). Run `grep -c "### Step 0: Pre-Flight Validation Gate"` on each of the 10 task files. All must return ≥1. → SC-1
- [ ] 4. **SC-2 verification: per-task input validation** (**clean-room**). Sub-agent reads each file's Step 0 section and confirms the checked inputs match only the task's own required inputs from the per-task table. → SC-2
- [ ] 5. **SC-3 verification: remediation messages present** (**inline**). Run `grep -c "remediation:"` on each of the 10 task files. All must return ≥1. → SC-3
- [ ] 6. **SC-4 verification: INSUFFICIENT_ARTIFACTS in cross-validate and verification-audit** (**inline**). Run `grep -c "INSUFFICIENT_ARTIFACTS"` on both files. Both must return ≥1. → SC-4
- [ ] 7. **SC-5 verification: Step 0 in dependency chains** (**inline**). Run `grep -c "Step 0"` on each of the 10 task files. All must return ≥1. → SC-5
- [ ] 8. **SC-6 verification: existing error codes preserved** (**clean-room**). Sub-agent reads each file and confirms existing BLOCKED error codes (MISSING_EVIDENCE_DIR, SPEC_NOT_FOUND, etc.) are still present alongside new Step 0 codes. → SC-6
- [ ] 9. **Completeness gate** (**clean-room**). Sub-agent verifies all 10 files modified, all SCs covered, no TBD/TODO placeholders. → SC-1, SC-2, SC-3, SC-4, SC-5, SC-6
- [ ] 10. **Adversarial audit** (**orchestrator multi-dispatch**). Run resolve-models → dispatch spec-audit with auditor_1 → remediate → dispatch spec-audit with auditor_2 → cross-validate. → SC-1, SC-2, SC-3, SC-4, SC-5, SC-6

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

- All 10 task files have Step 0 Pre-Flight Validation Gate
- All SCs (SC-1 through SC-6) verified PASS
- Plan auto-approved (authorization_scope: for_pr)
