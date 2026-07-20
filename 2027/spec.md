---
title: "[SPEC-FIX] Missing task cards in spec-creation pipeline: research-card-consultation and interdependency-check"
status: draft
created: 2026-07-20
license: MIT
provenance: AI-generated
issue: 2027
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-20

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

# [SPEC-FIX] Missing task cards in spec-creation pipeline: research-card-consultation and interdependency-check

## Problem Statement

The `spec-creation` SKILL.md defines a 25-step pipeline for spec creation. Two pipeline steps — `research-card-consultation` (step 4) and `interdependency-check` (step 20) — reference task files that do not exist on disk. The contract table in `spec-creation/SKILL.md` defines reads/writes for both steps (lines 140, 153), but the corresponding task files at `spec-creation-validation/tasks/research-card-consultation.md` and `spec-creation-validation/tasks/interdependency-check.md` are absent.

Additionally, the sub-skills table in `spec-creation/SKILL.md` line 28 reports `spec-creation-validation` as having "6 task files" when the directory actually contains 9 files. The `spec-creation-validation/SKILL.md` tasks list at lines 16-21 lists only 6 of the 9 task files, missing `create-remote-stub.md`, `pre-spec-inspection.md`, and `revise-remote-body.md`.

## Root Cause Analysis

The root cause is a gap in the spec-creation pipeline's artifact lifecycle: when the pipeline was refactored (PR #1998, merged Jul 19 2026), the contract table and pipeline step references were added to `spec-creation/SKILL.md` for `research-card-consultation` and `interdependency-check`, but the corresponding task files were never created. The metadata counts and task lists in the SKILL.md files were not updated to reflect the actual directory state.

This is a documentation gap, not a code defect — the pipeline references exist but point to non-existent files. The pipeline will fail at runtime when it attempts to dispatch these steps.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](guidelines/080-code-standards.md).

## Scope Boundary

This SPEC-FIX is **documentation-only**. It documents the missing artifacts and metadata corrections and prescribes their creation. It does NOT implement the creation of the missing task files or apply the metadata corrections. Implementation is a separate phase.

**Non-requirements (explicitly out of scope):**
- Creating the actual task file content for `research-card-consultation.md` and `interdependency-check.md` — a separate implementation spec or plan is required
- Modifying any existing task file content in `spec-creation-validation/tasks/` — only the missing files and metadata counts are in scope
- Adding new pipeline steps to `spec-creation/SKILL.md` beyond the two missing task files — only the two referenced-but-missing steps are in scope

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Create task files inline in this SPEC-FIX | Violates SPEC-FIX scope boundary — SPEC-FIX documents and prescribes, it does not implement. Implementation requires a separate plan and authorization. |
| Merge the two missing task files into a single "pipeline-gap" task | Each task file has a distinct contract (different reads, writes, and purpose). Merging would violate the single-concern principle and make the contract table inconsistent. |
| Remove the pipeline step references and contract entries instead of creating task files | The steps are intentionally part of the pipeline design. Removing them would lose functionality. The correct fix is to create the missing files. |

## Objectives

- Document the two missing task files (`research-card-consultation.md`, `interdependency-check.md`) and prescribe their creation
- Document the metadata corrections needed in `spec-creation/SKILL.md` (count fix) and `spec-creation-validation/SKILL.md` (tasks list update)
- Establish the SPEC-FIX scope boundary — this spec is documentation-only, no implementation is authorized

## Goals

- SC-1: `research-card-consultation.md` task file exists at `spec-creation-validation/tasks/` with correct contract behavior
- SC-2: `interdependency-check.md` task file exists at `spec-creation-validation/tasks/` with correct contract behavior
- SC-3: `spec-creation/SKILL.md` sub-skills table count corrected from "6 task files" to "9 task files"
- SC-4: `spec-creation-validation/SKILL.md` tasks list includes all 9 task files from the directory
- SC-5: SPEC-FIX scope boundary is explicitly documented — no implementation steps appear in the spec body

## Non-Goals

- **Task file content creation** — The actual content of `research-card-consultation.md` and `interdependency-check.md` is not created by this spec. A separate implementation phase is required.
- **Existing task file modification** — No existing task files in `spec-creation-validation/tasks/` are modified by this spec.
- **Pipeline expansion** — No new pipeline steps are added to `spec-creation/SKILL.md` beyond the two already-referenced steps.

## Constraints and Scope

- This SPEC-FIX is documentation-only — no implementation work is authorized
- All units are independent — no unit depends on another's output
- The spec-creation pipeline (25 steps in `spec-creation/SKILL.md`) is the authoritative reference for task file contracts
- Task files MUST follow the existing YAML-frontmatter + section format used by all other task files in `spec-creation-validation/tasks/`

## Missing Artifacts

### research-card-consultation.md

**Pipeline reference:** `spec-creation/SKILL.md` line 58 — step 4: `[sub-task] research-card-consultation`

**Contract table entry:** `spec-creation/SKILL.md` line 140:
- Reads: `.opencode/.issues/research-cards/*.md`
- Writes: `.issues/{N}/artifacts/research-cards-consulted.yaml`
- Returns: Standard result contract (status, finding_summary, artifact_path, blocker_reason)

**Target path:** `spec-creation-validation/tasks/research-card-consultation.md`

**Edge case:** The `.opencode/.issues/research-cards/` directory may be empty or absent. The task file MUST handle this gracefully — report no cards found, return empty consultation.

### interdependency-check.md

**Pipeline reference:** `spec-creation/SKILL.md` line 74 — step 20: `[sub-task] interdependency-check`

**Contract table entry:** `spec-creation/SKILL.md` line 153:
- Reads: GitHub API for open specs
- Writes: `.issues/{N}/artifacts/interdependency-check.yaml`
- Returns: Standard result contract (status, finding_summary, artifact_path, blocker_reason)

**Target path:** `spec-creation-validation/tasks/interdependency-check.md`

**Constraint:** MUST use GitHub API (`github_issue_read` or equivalent) — no local-only fallback per contract table. On API failure, MUST return BLOCKED with API failure reason.

## Metadata Corrections

### spec-creation/SKILL.md sub-skills table count

**Location:** Line 28
**Current value:** "6 task files"
**Correct value:** "9 task files"
**Rationale:** `spec-creation-validation/tasks/` contains 9 files: `completion.md`, `create.md`, `create-remote-stub.md`, `holistic-self-check.md`, `pipeline-readiness-gate.md`, `pre-spec-inspection.md`, `revise-remote-body.md`, `risk.md`, `traceability.md`

### spec-creation-validation/SKILL.md tasks list

**Location:** Lines 16-21
**Current entries (6):** `completion.md`, `create.md`, `holistic-self-check.md`, `pipeline-readiness-gate.md`, `risk.md`, `traceability.md`
**Missing entries (3):** `create-remote-stub.md`, `pre-spec-inspection.md`, `revise-remote-body.md`
**Correct state:** All 9 task files listed

## Format Constraints

Both new task files MUST follow the existing task file format convention:
- YAML frontmatter (name, description, license, provenance)
- Purpose section
- Entry Criteria section
- Exit Criteria section
- Procedure section (numbered steps)

Reference format: `spec-creation-validation/tasks/create.md` or any existing task file in the same directory.

## Contract Behavior

### research-card-consultation contract

| Field | Value |
|-------|-------|
| Reads | `.opencode/.issues/research-cards/*.md` |
| Writes | `.issues/{N}/artifacts/research-cards-consulted.yaml` |
| Returns | `{status: DONE, finding_summary: "...", artifact_path: "...", blocker_reason: null}` |
| Edge case | Empty/missing research cards directory → report no cards found, return empty consultation |

### interdependency-check contract

| Field | Value |
|-------|-------|
| Reads | GitHub API for open specs |
| Writes | `.issues/{N}/artifacts/interdependency-check.yaml` |
| Returns | `{status: DONE \| BLOCKED, finding_summary: "...", artifact_path: "...", blocker_reason: "..."}` |
| Constraint | MUST use GitHub API — no local-only fallback |
| Error case | API unavailable → return BLOCKED with API failure reason |

## Edge Cases

- **Empty research cards directory:** `research-card-consultation` MUST handle the case where `.opencode/.issues/research-cards/` is empty or absent — report no cards found, return empty consultation artifact
- **GitHub API unavailable:** `interdependency-check` MUST handle API failure gracefully — return BLOCKED with actionable failure details
- **No open specs found:** `interdependency-check` MUST handle empty results — report no interdependencies found (valid empty state)

## Risk and Edge Cases

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| Task file format deviates from existing convention | Low | Low | Reference `create.md` as format template; review confirms YAML frontmatter + section structure |
| Contract mismatch with `spec-creation/SKILL.md` | Medium | Low | Contract is explicitly defined in SKILL.md; pipeline coherence gate catches mismatch |
| Empty/missing research cards directory not handled | Medium | Low | REQ-8 explicitly requires empty-directory handling |
| Implementation steps leak into spec body | Critical | Low | Non-requirements section documents scope boundary; review catches violations |
| GitHub API unavailable during task execution | Medium | Low | Task file MUST report BLOCKED with API failure reason |

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1998](https://github.com/michael-conrad/.opencode/issues/1998) | RELATED | Refactored spec-creation skill, verified 26 SCs PASS including pre-spec-inspection.md existence, but did not address missing research-card-consultation.md or interdependency-check.md |
| [#954](https://github.com/michael-conrad/.opencode/issues/954) | RELATED | Skill Task File Inventory — partial overlap on contract patterns but different core concern (contract/inventory classification, not gap-filling) |

## SC-to-Root-Cause Traceability

| SC | Root Cause Element |
|----|-------------------|
| SC-1 | Pipeline step 4 references non-existent `research-card-consultation.md` — task file was never created during pipeline refactoring |
| SC-2 | Pipeline step 20 references non-existent `interdependency-check.md` — task file was never created during pipeline refactoring |
| SC-3 | Sub-skills table count was not updated after task files were added — metadata drift |
| SC-4 | SKILL.md tasks list was not updated after task files were added — metadata drift |
| SC-5 | SPEC-FIX scope boundary must be explicitly documented to prevent unauthorized implementation |

## Feasibility Assessment

All referenced files and paths have been verified to exist (or, in the case of the missing task files, verified to be absent as expected). The contract table entries in `spec-creation/SKILL.md` lines 140 and 153 exist and define the correct reads/writes. The directory `spec-creation-validation/tasks/` exists and contains 9 files. The format convention is established by existing task files.

## Implementation Approach

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/2027/plan.md` before implementation begins.

The implementation plan MUST use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form for every dispatch step. Plan steps MUST NOT contain inline procedure text — the plan is a routing document, not a re-implementation of skill task cards. The full implementation pipeline MUST be enumerated with no skipped or combined steps: coherence gate, pre-red-baseline, RED/GREEN per item, VbC, audit, cross-validate, regression check, finishing checklist, review-prep, cleanup.

## Plan Format Requirements

- Every dispatch step in the plan MUST use the canonical `skill({name: "..."})` → `task(..., prompt: "execute <task> task from <skill>")` form
- Plan steps MUST NOT contain inline procedure text — the plan is a routing document, not a re-implementation of skill task cards
- The full implementation pipeline MUST be enumerated with no skipped or combined steps, each referencing the correct skill/task combination
- The full pipeline enumeration includes: coherence gate, pre-red-baseline, RED/GREEN per item, VbC, audit, cross-validate, regression check, finishing checklist, review-prep, cleanup

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `research-card-consultation.md` task file exists at `spec-creation-validation/tasks/` with correct contract behavior (reads `.opencode/.issues/research-cards/*.md`, writes `.issues/{N}/artifacts/research-cards-consulted.yaml`, handles empty/missing cards directory) | `ls spec-creation-validation/tasks/research-card-consultation.md` confirms file exists; `grep` confirms contract matches `spec-creation/SKILL.md` line 140; `grep` confirms no-cards-found path | On FAIL: create or revise task file to match contract; re-verify with same commands | red-green | `.opencode/.issues/2027/artifacts/sc-1-evidence.log` | REQ-1, REQ-5, REQ-7, REQ-8 | Phase 1 | pre-commit | sequential | AFFINITY-A | null | `behaviors/sc-1.sh` | Phase 1 |
| SC-2 | `interdependency-check.md` task file exists at `spec-creation-validation/tasks/` with correct contract behavior (reads GitHub API for open specs, writes `.issues/{N}/artifacts/interdependency-check.yaml`, returns BLOCKED on API failure) | `ls spec-creation-validation/tasks/interdependency-check.md` confirms file exists; `grep` confirms contract matches `spec-creation/SKILL.md` line 153; `grep` confirms BLOCKED-on-failure path | On FAIL: create or revise task file to match contract; re-verify with same commands | red-green | `.opencode/.issues/2027/artifacts/sc-2-evidence.log` | REQ-2, REQ-6, REQ-7 | Phase 1 | pre-commit | sequential | AFFINITY-A | null | `behaviors/sc-2.sh` | Phase 1 |
| SC-3 | `spec-creation/SKILL.md` sub-skills table count corrected from "6 task files" to "9 task files" | `grep '9 task files' spec-creation/SKILL.md` returns match; `grep '6 task files' spec-creation/SKILL.md` returns no match | On FAIL: edit `spec-creation/SKILL.md` line 28 to replace "6" with "9"; re-verify with grep | red-green | `.opencode/.issues/2027/artifacts/sc-3-evidence.log` | REQ-3, REQ-10 | Phase 1 | pre-commit | sequential | AFFINITY-B | null | `behaviors/sc-3.sh` | Phase 1 |
| SC-4 | `spec-creation-validation/SKILL.md` tasks list includes all 9 task files from the directory | `grep` confirms all 9 filenames appear in `spec-creation-validation/SKILL.md` lines 16-21; count of listed entries equals 9 | On FAIL: add missing entries to tasks list; re-verify with grep | red-green | `.opencode/.issues/2027/artifacts/sc-4-evidence.log` | REQ-4, REQ-10 | Phase 1 | pre-commit | sequential | AFFINITY-B | null | `behaviors/sc-4.sh` | Phase 1 |
| SC-5 | SPEC-FIX scope boundary explicitly documented — no implementation steps appear in the spec body | `grep` confirms scope boundary section exists in spec body; `grep` confirms no implementation verbs (create, write, edit, modify) in spec body outside scope section | On FAIL: add scope boundary section or remove implementation steps; re-verify with grep | red-green | `.opencode/.issues/2027/artifacts/sc-5-evidence.log` | REQ-9 | Phase 1 | pre-commit | sequential | AFFINITY-C | null | `behaviors/sc-5.sh` | Phase 1 |
| SC-6 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | Behavioral test via `opencode run` with stderr-based assertion verifying agent does not weaken SCs | On FAIL: restore original SC evidence type; re-verify with behavioral test | red-green | `.opencode/.issues/2027/artifacts/sc-6-evidence.log` | Anti-lobotomization mandate | Phase 1 | pre-commit | sequential | AFFINITY-C | null | `behaviors/sc-6.sh` | Phase 1 |

**Cost-frame mandate:** Each SC's verification method requires a real test execution command — not a structural check (file exists, grep match). Structural verification is NEVER a valid substitute for behavioral execution: a skipped runtime equals a defect undiscovered. Behavioral PASS is a break (zero downstream cost); structural-only PASS is a death spiral (compounding exponential cost).

**SC-6 (Anti-Lobotomization):** Behavioral test assertion — RED state: agent attempts to weaken SC evidence type; GREEN state: agent refuses to weaken and reports BLOCKED. Stderr-based assertion: `assert_stderr_pattern_absent_all_models "weaken"` or equivalent.

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | SPEC-FIX is documentation-only — no implementation | Prevents scope creep; implementation requires separate plan and authorization | MUST | SC-5 |
| DEC-2 | Task files follow existing YAML-frontmatter + section format | Consistency with existing task files; no new format convention needed | MUST | SC-1, SC-2 |
| DEC-3 | Two separate task files (not merged) | Each has distinct contract (different reads/writes); single-concern principle | MUST | SC-1, SC-2 |
| DEC-4 | Metadata corrections are documentation fixes, not new artifacts | Count and list updates are single-line edits, not new file creation | MUST | SC-3, SC-4 |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Task file format deviates from existing convention | Low | Low | Reference `create.md` as format template | SC-1, SC-2 |
| RISK-2 | Contract mismatch with SKILL.md | Low | Medium | Contract explicitly defined; pipeline coherence gate catches mismatch | SC-1, SC-2 |
| RISK-3 | Empty/missing research cards directory not handled | Low | Medium | REQ-8 explicitly requires empty-directory handling | SC-1 |
| RISK-4 | Implementation steps leak into spec body | Low | Critical | Non-requirements section documents scope boundary | SC-5 |
| RISK-5 | GitHub API unavailable during task execution | Low | Medium | Task file MUST report BLOCKED with API failure reason | SC-2 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Phase Artifact Requirements | PR Strategy |
| -------------- | ---------------- | --------------------------- | ----------- |
| single-task | 1 | Single `plan.md` file | single PR |

## Regression Invariants

- Existing pipeline step references in `spec-creation/SKILL.md` MUST NOT be removed or modified — only the missing task files are created
- Existing task files in `spec-creation-validation/tasks/` MUST NOT be modified — only new files are added
- The contract table in `spec-creation/SKILL.md` MUST NOT be modified — it is the authoritative contract definition

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `spec-creation/SKILL.md` lines 28, 58, 74, 140, 153 | Verify pipeline step references and contract table entries |
| Direct source search | `spec-creation-validation/SKILL.md` lines 16-21 | Verify tasks list entries |
| Direct source search | `spec-creation-validation/tasks/` directory listing | Verify actual task file count (9 files) |
| Direct source search | `spec-creation-validation/tasks/create.md` | Verify task file format convention |
| MCP search | `glob('spec-creation-validation/tasks/research-card-consultation.md')` | Confirm file does not exist |
| MCP search | `glob('spec-creation-validation/tasks/interdependency-check.md')` | Confirm file does not exist |
| MCP search | `glob('.opencode/.issues/research-cards/*.md')` | Verify research cards directory state (empty/absent) |
| Live verification | `read('spec-creation/SKILL.md')` lines 28, 58, 74, 140, 153 | Verify exact content of pipeline references and contract entries |
| Live verification | `read('spec-creation-validation/SKILL.md')` lines 16-21 | Verify exact content of tasks list |
| Live verification | `read('spec-creation-validation/tasks/traceability.md')` | Verify task file format convention |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
