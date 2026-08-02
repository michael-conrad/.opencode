---
plan_schema_version: "1.0"
issue: 2225
title: "Spec-creation pipeline: validate/create task defects and reference-document loading rules"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 5
---

# Implementation Plan — #2225 — Spec-Creation Pipeline Defects

**Goal:** Fix the spec-creation pipeline's validate and create tasks so they load criteria dynamically from reference documents, apply format-level rules during assembly, and catch structural defects before audit.

**Architecture:** Five phases executed in dependency order. Phase 1 adds a rule to `task-card-structure-standards.md` requiring dynamic loading. Phase 2 fixes `create.md` to load and apply format-level rules. Phase 3 adds structured checks to `validate.md`. Phase 4 documents tiered escalation in `spec-creation/SKILL.md`. Phase 5 adds an artifact pre-flight gate to `spec-audit-investigator.md`. Phases 2 and 3 are independent and may execute in parallel. Phases 4 and 5 are independent of each other.

**Files:**
- `.opencode/reference/task-card-structure-standards.md`
- `.opencode/skills/spec-creation/tasks/create.md`
- `.opencode/skills/spec-creation/tasks/validate.md`
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/audit/tasks/spec-audit-investigator.md`

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Dynamic-loading rule | `test-driven-development` | `red` | `task-card-structure-standards.md` | SC-1 | — |
| 2 — create.md update | `test-driven-development` | `red` | `create.md` | SC-2, SC-11 | 1 |
| 3 — validate.md update | `test-driven-development` | `red` | `validate.md` | SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9 | — |
| 4 — Tiered escalation | `test-driven-development` | `red` | `spec-creation/SKILL.md` | SC-10 | 3 |
| 5 — Artifact pre-flight | `test-driven-development` | `red` | `spec-audit-investigator.md` | SC-12 | — (orphan — intentional per spec) |

---

## Phase Details

### Phase 1 — Dynamic-Loading Rule

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/reference/task-card-structure-standards.md` |
| SCs | SC-1 |
| Depends On | — |

**Procedure:**
- [ ] 1. Open `.opencode/reference/task-card-structure-standards.md`
- [ ] 2. Add a new rule under a "Dynamic Loading" subsection: "Any task that validates against reference-dependent criteria MUST load those criteria dynamically via `Read [Text](path)` from the canonical reference document. Hardcoded inline lists that duplicate reference content are prohibited."
- [ ] 3. Verify the rule references SC-1 and is placed in the correct section
- [ ] 4. Commit with message `phase-1: add dynamic-loading rule to task-card-structure-standards.md`

**Context:**
```yaml
target_file: .opencode/reference/task-card-structure-standards.md
sc_ids: [SC-1]
rule_text: "Any task that validates against reference-dependent criteria MUST load those criteria dynamically via Read [Text](path) from the canonical reference document. Hardcoded inline lists that duplicate reference content are prohibited."
```

### Phase 2 — create.md Update

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/spec-creation/tasks/create.md` |
| SCs | SC-2, SC-11 |
| Depends On | 1 |

**Procedure:**
- [ ] 1. Open `.opencode/skills/spec-creation/tasks/create.md`
- [ ] 2. Add `Read [Text](path)` calls to load `spec-structure-standards.md` and `cost-model-standards.md` at the start of the assembly step
- [ ] 3. Apply format-level rules (SHALL language, dark-prose-007 pattern, SC determinism, Documentation Sources columns) during spec body assembly
- [ ] 4. Add exit criteria to copy analytical artifacts from `tmp/{issue_number}/artifacts/` to `.issues/{N}/artifacts/`
- [ ] 5. Commit with message `phase-2: update create.md with dynamic loading and format rules`

**Context:**
```yaml
target_file: .opencode/skills/spec-creation/tasks/create.md
sc_ids: [SC-2, SC-11]
references_to_load:
  - spec-structure-standards.md
  - cost-model-standards.md
format_rules: [SHALL language, dark-prose-007 pattern, SC determinism, Documentation Sources columns]
artifact_copy_source: "tmp/{issue_number}/artifacts/"
artifact_copy_dest: ".issues/{N}/artifacts/"
```

### Phase 3 — validate.md Update

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/spec-creation/tasks/validate.md` |
| SCs | SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9 |
| Depends On | — |

**Procedure:**
- [ ] 1. Open `.opencode/skills/spec-creation/tasks/validate.md`
- [ ] 2. Add dynamic section loading: load required section inventory from `spec-structure-standards.md` via `Read [Text](path)`
- [ ] 3. Add format conformance check: SHALL language, dark-prose-007 pattern, Documentation Sources columns
- [ ] 4. Add determinism check with prohibited pattern list from `spec-structure-standards.md`
- [ ] 5. Add compound-SC detection: conjunctions, multiple verification targets, cross-concern references
- [ ] 6. Add causal chain verification: root cause to SC mapping, orphan detection
- [ ] 7. Add evidence type cross-check lookup table: behavioral→test, semantic→sub-agent, string→grep, structural→file
- [ ] 8. Add artifact cross-reference check: blast-radius, concern-map, interface-compatibility, testability-assessment
- [ ] 9. Commit with message `phase-3: add structured checks to validate.md`

**Context:**
```yaml
target_file: .opencode/skills/spec-creation/tasks/validate.md
sc_ids: [SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9]
checks_to_add:
  - dynamic_section_loading: "Load required section inventory from spec-structure-standards.md via Read [Text](path)"
  - format_conformance: "SHALL language, dark-prose-007 pattern, Documentation Sources columns"
  - determinism: "Prohibited pattern list from spec-structure-standards.md"
  - compound_sc_detection: "Conjunctions, multiple verification targets, cross-concern references"
  - causal_chain: "Root cause to SC mapping, orphan detection"
  - evidence_type_crosscheck: "Lookup table: behavioral→test, semantic→sub-agent, string→grep, structural→file"
  - artifact_cross_reference: "Blast-radius, concern-map, interface-compatibility, testability-assessment"
```

### Phase 4 — Tiered Escalation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/spec-creation/SKILL.md` |
| SCs | SC-10 |
| Depends On | 3 |

**Procedure:**
- [ ] 1. Open `.opencode/skills/spec-creation/SKILL.md`
- [ ] 2. Add a "Tiered Escalation" subsection in the validate→revise loop section
- [ ] 3. Document tier 1: 3 validate→revise iterations before escalation
- [ ] 4. Document tier 2: dispatch structural diagnostic
- [ ] 5. Document tier 3: escalate to user
- [ ] 6. Commit with message `phase-4: add tiered escalation to spec-creation/SKILL.md`

**Context:**
```yaml
target_file: .opencode/skills/spec-creation/SKILL.md
sc_ids: [SC-10]
escalation_tiers:
  - tier_1: "3 validate→revise iterations"
  - tier_2: "Dispatch structural diagnostic"
  - tier_3: "Escalate to user"
```

### Phase 5 — Artifact Pre-Flight Gate

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` |
| Task | `red` |
| Target | `.opencode/skills/audit/tasks/spec-audit-investigator.md` |
| SCs | SC-12 |
| Depends On | — |

**Procedure:**
- [ ] 1. Open `.opencode/skills/audit/tasks/spec-audit-investigator.md`
- [ ] 2. Add a "Pre-Flight Validation Gate" as Step 1
- [ ] 3. Check for analytical artifact presence at `{analytical_artifact_dir}`
- [ ] 4. If missing, return `REMEDIATION_REQUIRED` with backfill dispatch
- [ ] 5. Commit with message `phase-5: add artifact pre-flight gate to spec-audit-investigator.md`

**Orphan note:** Phase 5 has no dependencies (depends_on: []) and no other phase depends on it. This is intentional per spec — the artifact pre-flight gate is an independent safety net that can be added without blocking or being blocked by other phases.

**Context:**
```yaml
target_file: .opencode/skills/audit/tasks/spec-audit-investigator.md
sc_ids: [SC-12]
gate_location: "Step 1 — Pre-Flight Validation Gate"
check: "analytical artifact presence at {analytical_artifact_dir}"
failure_response: "REMEDIATION_REQUIRED with backfill dispatch"
```

---

## Exit Criteria

- [ ] C1. `task-card-structure-standards.md` contains a rule requiring dynamic loading of reference-dependent criteria via `Read [Text](path)`
- [ ] C2. `create.md` Step 2 loads `spec-structure-standards.md` and `cost-model-standards.md` and applies format-level rules
- [ ] C3. `create.md` copies analytical artifacts from `tmp/` to `.issues/{N}/artifacts/` in exit criteria
- [ ] C4. `validate.md` loads section inventory dynamically from `spec-structure-standards.md`
- [ ] C5. `validate.md` has structured format-level conformance checks (SHALL, dark-prose-007, Documentation Sources)
- [ ] C6. `validate.md` has structured determinism check with prohibited pattern list
- [ ] C7. `validate.md` has structured compound-SC detection procedure
- [ ] C8. `validate.md` verifies causal chain between root causes and SCs
- [ ] C9. `validate.md` has evidence-type-to-method cross-check lookup table
- [ ] C10. `validate.md` cross-references spec against analytical artifacts
- [ ] C11. `spec-creation/SKILL.md` documents tiered escalation in validate→revise loop
- [ ] C12. `spec-audit-investigator.md` Step 1 checks for analytical artifact presence, returns REMEDIATION_REQUIRED with backfill dispatch if missing

---

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-02T04:30:00Z | `plan_created` | Plan file at `.opencode/.issues/2225/plan.md`, 5 phases, dependency contract at `.opencode/.issues/2225/dependency-contract.yaml` |
