---
lifecycle_events:
  - event: plan_created
    timestamp: 2026-08-01T14:34:00Z
    issuer: OpenCode (deepseek-v4-flash)
    plan_path: .opencode/.issues/2214/plan.md
    phase_count: 2
    dispatch_modes: inline, sub-agent, clean-room
    status: DONE
issue: 2214
title: "Rewrite implementation-workflow reference card as data catalog"
spec_path: .opencode/.issues/2214/spec.md
dispatch:
  - phase: "Phase 1: Rewrite reference file as data catalog"
    skill: writing-plans
    task: create
  - phase: "Phase 2: Verify cross-reference integrity"
    skill: writing-plans
    task: create
---

# Plan: Rewrite implementation-workflow reference card as data catalog

## Pre-Implementation Steps

### Coherence Gate

- [ ] 1. Verify spec/plan coherence: confirm the spec at `.opencode/.issues/2214/spec.md` matches the plan structure. The spec defines 10 SCs across 2 phases — this plan covers all 10. (**inline**)

### Baseline Check

- [ ] 2. Verify the current file exists at `skills/writing-plans/reference/implementation-workflow.md` and is readable. (**inline**)
- [ ] 3. Verify all consuming task files exist: `skills/writing-plans/tasks/create.md`, `skills/writing-plans/tasks/research.md`, `skills/writing-plans/tasks/validate.md`. (**inline**)

---

## Phase 1: Rewrite reference file as data catalog

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

**Cost frame:** Single file rewrite (~494 lines → ~200 lines). All SCs verified by grep (string evidence). No behavioral tests needed. Low risk — no consumer-side changes.

### Item 1: Remove orchestrator sections (SC-1)

- [ ] 1. **RED** — Write a grep-based verification script that checks for absence of prohibited section headers. Save to `tmp/2214/verify-sc1.sh`. (**inline**)
  - Prohibited headers: `## Persona`, `## Worktree Mode`, `## Mandatory Task Discipline`, `### DISPATCH_GATE`, `## Sub-Agent Routing`, `## Invocation`, `## Orchestrator Entry Criteria`, `## State Management`, `## Remediation Routing`, `## Lifecycle Manifest`, `## Pipeline Enforcement Rules`, `## Sub-agent Context Shape`, `## Context Passing`, `## Dispatch Mode Verification Gate`, `## Overflow Signal`, `## Cross-References`
  - Script should `grep -c` for each header and exit 1 if any found.
- [ ] 2. **GREEN** — Edit `skills/writing-plans/reference/implementation-workflow.md` to remove all orchestrator-level routing sections listed above. (**sub-agent**)
  - Context: `{issue_number: 2214, file: skills/writing-plans/reference/implementation-workflow.md, sections_to_remove: [Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing, Invocation, Orchestrator Entry Criteria, State Management, Remediation Routing, Lifecycle Manifest, Pipeline Enforcement Rules, Sub-agent Context Shape, Context Passing, Dispatch Mode Verification Gate, Overflow Signal, Cross-References]}`
- [ ] 3. **Verify** — Run the RED script from step 1. Confirm all prohibited sections are absent. (**inline**)
- [ ] 4. **Commit** — `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Remove orchestrator routing sections from implementation-workflow reference card"` (**inline**)

### Item 2: Remove YAML frontmatter (SC-2)

- [ ] 1. **RED** — Write a grep-based verification script that checks for absence of YAML frontmatter delimiters (`---` at lines 1-6) and `name:`, `license:`, `provenance:` fields. Save to `tmp/2214/verify-sc2.sh`. (**inline**)
- [ ] 2. **GREEN** — Edit `skills/writing-plans/reference/implementation-workflow.md` to remove the YAML frontmatter block (lines 1-6). (**sub-agent**)
  - Context: `{issue_number: 2214, file: skills/writing-plans/reference/implementation-workflow.md, action: remove_yaml_frontmatter}`
- [ ] 3. **Verify** — Run the RED script from step 1. Confirm no frontmatter remains. (**inline**)
- [ ] 4. **Commit** — `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Remove YAML frontmatter from implementation-workflow reference card"` (**inline**)

### Item 3: Add Pipeline Step Catalog table (SC-3)

- [ ] 1. **RED** — Write a grep-based verification script that checks for the Pipeline Step Catalog table with columns: `step name`, `description`, `what it produces`. Save to `tmp/2214/verify-sc3.sh`. (**inline**)
- [ ] 2. **GREEN** — Add the Pipeline Step Catalog table to `skills/writing-plans/reference/implementation-workflow.md`. Extract step names from the current file's Invocation section (pre-regression, red, green, verify, audit, etc.) and describe what each produces. (**sub-agent**)
  - Context: `{issue_number: 2214, file: skills/writing-plans/reference/implementation-workflow.md, table: pipeline-step-catalog, columns: [step name, description, what it produces], data_source: current Invocation section}`
- [ ] 3. **Verify** — Run the RED script from step 1. Confirm table exists with correct columns. (**inline**)
- [ ] 4. **Commit** — `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Add Pipeline Step Catalog table"` (**inline**)

### Item 4: Add Trigger Dispatch Table (SC-4)

- [ ] 1. **RED** — Write a grep-based verification script that checks for the Trigger Dispatch Table with columns: `step name`, `owning skill`, `canonical dispatch string`. Save to `tmp/2214/verify-sc4.sh`. (**inline**)
- [ ] 2. **GREEN** — Add the Trigger Dispatch Table to `skills/writing-plans/reference/implementation-workflow.md`. Extract all dispatch entries from the current file's Sub-Agent Tasks table (pre-regression, red, green, verify, audit, etc.) with their owning skill and canonical dispatch string. (**sub-agent**)
  - Context: `{issue_number: 2214, file: skills/writing-plans/reference/implementation-workflow.md, table: trigger-dispatch-table, columns: [step name, owning skill, canonical dispatch string], data_source: current Sub-Agent Tasks table}`
- [ ] 3. **Verify** — Run the RED script from step 1. Confirm table exists with correct columns and all current dispatch entries are preserved. (**inline**)
- [ ] 4. **Commit** — `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Add Trigger Dispatch Table"` (**inline**)

### Item 5: Add Per-Task Cycle section (SC-5)

- [ ] 1. **RED** — Write a grep-based verification script that checks for RED, GREEN, COMMIT step definitions. Save to `tmp/2214/verify-sc5.sh`. (**inline**)
- [ ] 2. **GREEN** — Add the Per-Task Cycle section to `skills/writing-plans/reference/implementation-workflow.md`. Define the RED→GREEN→COMMIT sequence: RED (write failing test), GREEN (make test pass), COMMIT (commit test + change together). (**sub-agent**)
  - Context: `{issue_number: 2214, file: skills/writing-plans/reference/implementation-workflow.md, section: per-task-cycle, content: RED→GREEN→COMMIT sequence}`
- [ ] 3. **Verify** — Run the RED script from step 1. Confirm RED, GREEN, COMMIT are defined. (**inline**)
- [ ] 4. **Commit** — `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Add Per-Task Cycle section"` (**inline**)

### Item 6: Add Gate Sequence section (SC-6)

- [ ] 1. **RED** — Write a grep-based verification script that checks for gate sequence definition. Save to `tmp/2214/verify-sc6.sh`. (**inline**)
- [ ] 2. **GREEN** — Add the Gate Sequence section to `skills/writing-plans/reference/implementation-workflow.md`. List the mandatory gate order for a phase: pre-regression → red → green → post-regression → verify → commit → audit → z3-check → structural-checks. (**sub-agent**)
  - Context: `{issue_number: 2214, file: skills/writing-plans/reference/implementation-workflow.md, section: gate-sequence, gates: [pre-regression, red, green, post-regression, verify, commit, audit, z3-check, structural-checks]}`
- [ ] 3. **Verify** — Run the RED script from step 1. Confirm gate sequence is defined. (**inline**)
- [ ] 4. **Commit** — `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Add Gate Sequence section"` (**inline**)

### Item 7: Add Coercion Rules section (SC-7)

- [ ] 1. **RED** — Write a grep-based verification script that checks for coercion rule definitions (DONE_WITH_CONCERNS → FAIL, evidence type mismatch). Save to `tmp/2214/verify-sc7.sh`. (**inline**)
- [ ] 2. **GREEN** — Add the Coercion Rules section to `skills/writing-plans/reference/implementation-workflow.md`. Document: DONE_WITH_CONCERNS is coerced to FAIL for pipeline gate purposes; evidence type mismatch (e.g., structural evidence for behavioral SC) is a hard FAIL. (**sub-agent**)
  - Context: `{issue_number: 2214, file: skills/writing-plans/reference/implementation-workflow.md, section: coercion-rules, rules: [DONE_WITH_CONCERNS→FAIL, EVIDENCE_TYPE_MISMATCH→FAIL]}`
- [ ] 3. **Verify** — Run the RED script from step 1. Confirm coercion rules are defined. (**inline**)
- [ ] 4. **Commit** — `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Add Coercion Rules section"` (**inline**)

### Item 8: Add Artifact Retention section (SC-8)

- [ ] 1. **RED** — Write a grep-based verification script that checks for artifact retention rules. Save to `tmp/2214/verify-sc8.sh`. (**inline**)
- [ ] 2. **GREEN** — Add the Artifact Retention section to `skills/writing-plans/reference/implementation-workflow.md`. Document: permanent artifacts under `.issues/{N}/` are never cleaned; ephemeral artifacts under `tmp/{N}/` are cleaned at PR merge; step-specific pre-cleanup at each step start. (**sub-agent**)
  - Context: `{issue_number: 2214, file: skills/writing-plans/reference/implementation-workflow.md, section: artifact-retention, rules: [permanent_never_cleaned, ephemeral_cleaned_at_pr_merge, step_specific_pre_cleanup]}`
- [ ] 3. **Verify** — Run the RED script from step 1. Confirm artifact retention rules are defined. (**inline**)
- [ ] 4. **Commit** — `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Add Artifact Retention section"` (**inline**)

---

## Phase 2: Verify cross-reference integrity

**SCs:** SC-9, SC-10

**Cost frame:** Verification-only phase. All SCs verified by grep (string evidence). No file modifications.

### Item 9: Verify cross-references remain valid (SC-9)

- [ ] 1. **RED** — Write a grep-based verification script that checks all task files referencing `skills/writing-plans/reference/implementation-workflow.md` still resolve. Save to `tmp/2214/verify-sc9.sh`. (**inline**)
  - Search for the file path in: `skills/writing-plans/tasks/create.md`, `skills/writing-plans/tasks/research.md`, `skills/writing-plans/tasks/validate.md`, `skills/audit/tasks/`
  - Verify the file still exists at the same path.
- [ ] 2. **GREEN** — Run the verification script. If any reference is broken, fix the reference in the consuming task file. (**inline**)
- [ ] 3. **Verify** — Confirm all references resolve. Report results. (**inline**)
- [ ] 4. **Commit** — If any task files were modified, commit them. Otherwise, no commit needed. (**inline**)

### Item 10: Verify read paths unchanged (SC-10)

- [ ] 1. **RED** — Write a grep-based verification script that checks `create.md`, `research.md`, `validate.md` still reference the same read path (`skills/writing-plans/reference/implementation-workflow.md`). Save to `tmp/2214/verify-sc10.sh`. (**inline**)
- [ ] 2. **GREEN** — Run the verification script. Confirm all three task files reference the same path. (**inline**)
- [ ] 3. **Verify** — Report results. (**inline**)
- [ ] 4. **Commit** — No commit needed (verification only). (**inline**)

---

## Post-Implementation Steps

### Structural Checks

- [ ] 1. Run `grep` for any remaining prohibited section headers in the rewritten file. (**inline**)
- [ ] 2. Run `grep` for any remaining YAML frontmatter delimiters. (**inline**)
- [ ] 3. Verify all 6 data tables are present by running the RED scripts from Phase 1 items 3-8. (**inline**)

### Verification

- [ ] 4. Run all verification scripts from `tmp/2214/verify-sc*.sh` and confirm all 10 SCs pass. (**inline**)

### Audit

- [ ] 5. Dispatch audit sub-agent to verify the rewritten file against the spec's 10 SCs. (**clean-room**)
  - Context: `{issue_number: 2214, spec_path: .opencode/.issues/2214/spec.md, artifact_path: .opencode/skills/writing-plans/reference/implementation-workflow.md}`

### Cross-Validate

- [ ] 6. Cross-validate audit findings against verification results. Resolve any discrepancies. (**inline**)

### Review-Prep

- [ ] 7. Prepare review summary: list what was removed, what was added, and verification results. (**inline**)

### PR Creation

- [ ] 8. Create PR with the rewritten file and any verification scripts. (**sub-agent**)
  - Context: `{issue_number: 2214, branch: feature/2214-implementation-workflow-rewrite, files_changed: [.opencode/skills/writing-plans/reference/implementation-workflow.md]}`

### Completion

- [ ] 9. Append lifecycle event and report executive summary. (**inline**)
