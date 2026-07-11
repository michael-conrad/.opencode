# Plan: Close Artifact Gate Bypass Escape Hatch

**Issue:** #1885
**Spec:** [SPEC-FIX] Close artifact gate bypass escape hatch in writing-plans skill
**Authorization Scope:** for_pr
**Strategy:** Combined (4 phases, one feature branch, one PR)

## Goal

Add entry-point artifact validation checks to the writing-plans skill's plan creation pipeline, closing the bypass escape hatch where agents can skip Step 4a artifact validation. The fix adds artifact pre-checks at 4 entry points: Trigger Dispatch Table, pre-plan-readiness task, Entry Criteria, spec-to-plan handoff, plus a critical-rules prohibition.

## Architecture

| Component | File | Role |
|-----------|------|------|
| Trigger Dispatch Table (TDT) | `.opencode/skills/writing-plans/SKILL.md:36-53` | Entry-point routing — add artifact pre-check before "create plan" dispatch |
| Entry Criteria | `.opencode/skills/writing-plans/SKILL.md:97-100` | Prerequisites — add analytical artifact presence |
| Item 8 (Mandatory Task Discipline) | `.opencode/skills/writing-plans/SKILL.md:34` | Hard gate declaration — already elevated per 850c2dd0a |
| pre-plan-readiness task | `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md` | Entry-point gate — add artifact check procedure step |
| spec-to-plan handoff | `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` | Pipeline-internal handoff — add artifact validation manifest check |
| 000-critical-rules.md | `.opencode/guidelines/000-critical-rules.md` | Enforcement — add Tier 2 entry |
| Behavioral test | `.opencode/tests/behaviors/` | Agent behavior verification — RED/GREEN test |

## Phase Table

| Phase | Type | SCs | Concern | Dependencies |
|-------|------|-----|---------|--------------|
| Phase 0 | Global pre-phase | SC-9, SC-10 | Pipeline-readiness | None |
| Phase 1 | Per-file | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | Artifact-gate implementation | Phase 0 |
| Phase 2 | Per-file | SC-7, SC-8 | Behavioral enforcement | Phase 1 |
| Phase 3 | Global post-phase | SC-11, SC-12, SC-13 | Verification | Phase 2 |

## File Scope

| File | Phase | Change |
|------|-------|--------|
| `.opencode/skills/writing-plans/SKILL.md` | 1 | TDT artifact pre-check, Entry Criteria, Item 8 hard-gate verification |
| `.opencode/skills/writing-plans/tasks/pre-plan-readiness.md` | 1 | Add artifact check step |
| `.opencode/skills/writing-plans/tasks/handoffs/spec-to-plan.md` | 1 | Add artifact validation manifest check |
| `.opencode/guidelines/000-critical-rules.md` | 1 | Add Tier 2 critical-rules entry |
| `.opencode/tests/behaviors/` | 2 | New behavioral enforcement test |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Steps |
|-------|-----------|-------|-------|
| SC-1 | TDT "create plan" includes artifact pre-check | 1 | 1.1 |
| SC-2 | pre-plan-readiness checks all 7 artifact names | 1 | 1.2 |
| SC-3 | Entry Criteria lists analytical artifact prerequisite | 1 | 1.3 |
| SC-4 | Item 8 hard-gate language with BLOCKED | 1 | 1.4 |
| SC-5 | spec-to-plan handoff validates artifact presence | 1 | 1.5 |
| SC-6 | Critical-rules entry prohibiting bypass | 1 | 1.6 |
| SC-7 | Behavioral test — agent does NOT bypass gate | 2 | 2.1 (RED), 2.2 (GREEN) |
| SC-8 | Behavioral test exists and was RED before change | 2 | 2.1 (RED) |
| SC-9 | Coherence gate — spec-to-codebase alignment | 0 | 0.1 |
| SC-10 | Pre-flight checks — branch, artifacts, auth | 0 | 0.2 |
| SC-11 | Spec audit PASS | 3 | 3.1 |
| SC-12 | Cross-validate — no EVIDENCE_TYPE_MISMATCH | 3 | 3.2 |
| SC-13 | Review — deliverable completeness | 3 | 3.3 |

## Cross-Cutting Concerns

| Concern | Phases Affected | Handling |
|---------|----------------|----------|
| CC-1: Artifact Name Consistency | 1 | All 5 Phase 1 changes must reference identical 7-artifact-name set |
| CC-2: Gate Placement Synchronization | 1, 2 | Entry-point checks (Phase 1) must align with behavioral test expectations (Phase 2) |
| CC-3: Behavioral Evidence Requirements | 2 | SC-7/SC-8 require behavioral (opencode-cli run), not structural evidence |

## Exit Criteria

- All 13 SCs verified PASS
- Plan files committed to `feature/1881-skill-split-plan`
- SC evidence type annotation present on each SC in phase files
- Behavioral SCs carry `evidence_type: behavioral` annotation
- VbC for behavioral SCs includes `behavior_run` + `behavioral-test-evaluation` dispatch

## Safety/Rollback

| Phase | Destructive Operations | Rollback Plan | Data Loss Risk |
|-------|----------------------|---------------|----------------|
| Phase 0 | None | N/A | None |
| Phase 1 | File modifications (4 files) | `git checkout -- <file>` for each modified file | Low — all changes are additive text additions |
| Phase 2 | New test file | `git rm` the new test file | None — new file only |
| Phase 3 | None | N/A | None |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| All 4 target files exist for Phase 1 modifications | `bash test -f` in spec-audit Step 3 | ✅ |
| Behavioral tests run via opencode-cli with with-test-home wrapper | Verified in testability-assessment | ✅ |
| Commit 850c2dd0a elevated Item 8 to hard gate | grep of SKILL.md spec content | ✅ |
| 7 analytical artifact names must be consistent | SC-2 lists all 7 names; cross-cutting-matrix confirms | ✅ |
