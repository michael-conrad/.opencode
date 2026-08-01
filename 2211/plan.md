---
issue: 2211
spec: .opencode/.issues/2211/spec.md
generated: 2026-07-31T23:05:00Z
author: OpenCode (deepseek-v4-flash)
approved: true
dispatch:
  - phase: 1
    skill: audit
    task: modify
    dispatch_string: "execute modify from audit"
  - phase: 2
    skill: audit
    task: modify
    dispatch_string: "execute modify from audit"
  - phase: 3
    skill: audit
    task: modify
    dispatch_string: "execute modify from audit"
  - phase: 4
    skill: audit
    task: modify
    dispatch_string: "execute modify from audit"
  - phase: 5
    skill: verification
    task: verify
    dispatch_string: "execute verify from verification"
  - phase: 6
    skill: audit
    task: modify
    dispatch_string: "execute modify from audit"
  - phase: 7
    skill: audit
    task: modify
    dispatch_string: "execute modify from audit"
---

# Plan: Update Auditor Task Files to Reference Canonical Reference Docs

**Issue:** `.opencode#2211`
**Spec:** `.opencode/.issues/2211/spec.md`
**Dependency:** `.opencode#2210` — must complete first (creates reference docs)

## Pre-Implementation Steps

- [ ] **Coherence gate.** Verify spec/plan coherence before RED routing. Read the spec at `.opencode/.issues/2211/spec.md` and confirm the plan matches the spec's phase structure, SC assignments, and dependency ordering. If any mismatch is found, return BLOCKED with `COHERENCE_FAIL`.
  - (**inline**)

- [ ] **Baseline check.** Verify the current state of all affected files before modification. Read each file listed in the blast radius and confirm the content matches the "before" state described in the spec. If any file has already been modified, return BLOCKED with `BASELINE_CHANGED`.
  - (**inline**)

## Phase 1: Update spec-audit-evaluator.md

**SC:** SC-1
**Concern:** spec-audit-evaluator-update
**Cost frame:** Grepping for the Read reference costs one search. Skipping means the evaluator still hard-codes its SC table and drifts from the reference doc.

### Item 1 — Update spec-audit-evaluator.md Step 5a and Steps 5b-5h

- [ ] **RED.** Write a behavioral enforcement test that sends a prompt to the agent and verifies the evaluator reads from `reference/spec-structure-standards.md` instead of hard-coding the SC table. The test MUST fail at this point because the change hasn't been made yet.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/spec-audit-evaluator.md`:
  - Step 5a: Remove the hard-coded SC-1 through SC-14 table. Replace with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, check that the spec has that section with the correct content. For each SC in the spec's SC table, verify it has a verification method, that dependencies are documented, and that SCs are deterministic.`
  - Removed SCs: SC-3 (phases), SC-4 (steps), SC-6 (concerns), SC-7 (fidelity), SC-8 (edge cases), SC-10 (prose structure), SC-13 (cost-frame)
  - Derived from reference doc: SC-1 (preamble), SC-2 (verification methods), SC-5 (dependencies), SC-9 (determinism), SC-11 (documentation sources), SC-12 (preamble fields), SC-14 (enforcement gate)
  - Step 5b (SC-DET): Remains as explicit instruction
  - Step 5c (SC-STRUCTURAL-FAIL): Remains as explicit instruction
  - Step 5d (SC-EVIDENCE-TYPE): Replace hard-coded taxonomy with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Evidence Type Taxonomy and verify each SC's evidence matches the minimum acceptable method.`
  - Step 5e (SC-TRACKING-LANG): Replace hard-coded list with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Prohibited Content Patterns and verify the spec contains no tracking/status language.`
  - Step 5f (SC-PRESCRIPTIVE-CODE): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Prohibited Content Patterns and verify the spec contains no prescriptive code.`
  - Step 5g (SC-PIPELINE-GATES): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Format Requirements and verify pipeline gates use the canonical checklist format.`
  - Step 5h (SC-CANONICAL-PLAN-FORM): Replace hard-coded rules with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md) §Format Requirements and verify any plan output format requirements use the canonical checklist format.`
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass now. Verify the changes match the spec's SC-1 requirements: grep for SC-1 through SC-14 table removed; grep for Read reference present; grep for removed SC IDs absent.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes to `spec-audit-evaluator.md` with a descriptive message.
  - (**inline**) `git add .opencode/skills/audit/tasks/spec-audit-evaluator.md && git commit -m "Phase 1: Update spec-audit-evaluator.md to reference spec-structure-standards"`

## Phase 2: Update spec-audit-investigator.md

**SC:** SC-2
**Concern:** spec-audit-investigator-update
**Cost frame:** Grepping for the Read reference costs one search. Skipping means the investigator still hard-codes section names that drift from the reference doc.

### Item 2 — Update spec-audit-investigator.md Step 3

- [ ] **RED.** Write a behavioral enforcement test that verifies the investigator reads from `reference/spec-structure-standards.md` instead of hard-coding section names. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/spec-audit-investigator.md`:
  - Remove Step 3.3 (Phase inventory) — phases are a plan concept
  - Remove Step 3.7 (STATUS marker) — prohibited pattern
  - Replace Step 3.5 (Preamble presence) with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, collect evidence about its presence, content, and structure. Record what is found — do not infer or assume.`
  - Remove Step 3.6 (Documentation Sources) as a hard-coded section name — now derived from reference doc
  - Update the `spec_structure` YAML evidence structure to remove `phases`, `preamble`, `documentation_sources`, and `status_marker` fields. Replace with a dynamic structure derived from the reference doc's required sections.
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for hard-coded section names removed; grep for Read reference present; grep for removed items absent.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/spec-audit-investigator.md && git commit -m "Phase 2: Update spec-audit-investigator.md to reference spec-structure-standards"`

## Phase 3: Update plan-fidelity-evaluator.md

**SC:** SC-3
**Concern:** plan-fidelity-evaluator-update
**Cost frame:** Grepping for the Read reference costs one search. Skipping means the plan-fidelity evaluator still hard-codes PF criteria that drift from the reference doc.

### Item 3 — Update plan-fidelity-evaluator.md Step 3

- [ ] **RED.** Write a behavioral enforcement test that verifies the evaluator reads from `reference/plan-structure-standards.md` instead of hard-coding PF criteria. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`:
  - Remove PF-4 (edge cases) — error recovery is a pipeline invariant
  - Remove PF-DELEGATION — too rare, false FAILs
  - Remove PF-GLOBAL-NUMBERING — no evidence of defect prevention
  - Replace PF-6, PF-7, PF-7a, PF-ADMONISHMENT, PF-ONE-STEP, PF-PRESCRIPTIVE-CODE with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, verify the plan has that element with the correct format.`
  - PF-CHECKLIST-FORMAT: Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Step Format and verify all steps use the canonical checklist format.`
  - PF-DISPATCH-MODE: Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Dispatch Indicators and verify every step has exactly one valid dispatch indicator.`
  - PF-DISPATCH-DEFECTS: Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Dispatch Indicators and verify dispatch declarations are consistent with step indicators.`
  - PF-SUBSTEP-EXPAND: Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md) §Step Format and verify no step describes more than one atomic action.`
  - PF-1, PF-2, PF-3, PF-5, PF-STRUCTURAL-FAIL, PF-Z3-CONTRACT, PF-SEQUENCE-MATCHES remain as explicit instructions.
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for removed PF criteria absent; grep for Read reference present.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/plan-fidelity-evaluator.md && git commit -m "Phase 3: Update plan-fidelity-evaluator.md to reference plan-structure-standards"`

## Phase 4: Update plan-fidelity-investigator.md

**SC:** SC-4
**Concern:** plan-fidelity-investigator-update
**Cost frame:** Grepping for the Read reference costs one search. Skipping means the plan-fidelity investigator still hard-codes evidence collection items that drift from the reference doc.

### Item 4 — Update plan-fidelity-investigator.md Steps 2-5

- [ ] **RED.** Write a behavioral enforcement test that verifies the investigator reads from `reference/plan-structure-standards.md` instead of hard-coding evidence collection items. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/plan-fidelity-investigator.md`:
  - Step 2: Remove 2.4 (phase descriptions), 2.5 (cross-references), 2.6 (delegation references), 2.7 (scope boundary). Replace with: `Read [spec-structure-standards.md](reference/spec-structure-standards.md). For each required section in the reference doc, collect evidence about its presence, content, and structure.` Update the `spec` YAML evidence structure to remove `phases`, `cross_references`, `delegation_refs`, `scope` fields.
  - Step 3: Remove 3.8 (admonishments), 3.9 (plan scope), 3.10 (cross-references from plan), 3.11 (delegation definitions), 3.12 (gate sequence), 3.13 (verification instructions), 3.14 (Z3 contract references), 3.15 (prescriptive content). Replace with: `Read [plan-structure-standards.md](reference/plan-structure-standards.md). For each structural element in the reference doc, collect evidence about its presence, content, and format.` Update the `plan` YAML evidence structure to remove `admonishments`, `plan_scope`, `cross_references`, `delegation_definitions`, `gate_sequence`, `verification_instructions`, `z3_contract_refs`, `prescriptive_content` fields.
  - Step 4: Remove 4.9 (one-step protocol) — now derived from plan-structure-standards.
  - Step 5: Remove 5.5 (delegation completeness), 5.6 (gate sequence), 5.7 (verification evidence types), 5.8 (cost-frame prose), 5.9 (SC gate language).
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for removed evidence collection items absent; grep for Read reference present.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/plan-fidelity-investigator.md && git commit -m "Phase 4: Update plan-fidelity-investigator.md to reference plan-structure-standards"`

## Phase 5: Verify reference doc paths

**SC:** SC-5
**Concern:** reference-doc-verification
**Cost frame:** Reading each referenced path costs one read call per path. Skipping means a missing reference doc isn't caught until the auditor fails at runtime.

### Item 5 — Verify all Read reference paths point to existing files

- [ ] **RED.** Write a test that verifies the reference doc paths exist. The test MUST fail if any path is missing.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Verify that all `Read [Text](path)` references in the updated auditor task files point to existing files:
  - `reference/spec-structure-standards.md` — must exist (created by `.opencode#2210`)
  - `reference/plan-structure-standards.md` — must exist (created by `.opencode#2210`)
  - `reference/cost-model-standards.md` — must exist (created by `.opencode#2210`)
  - If any path is missing, return BLOCKED with `MISSING_REFERENCE_DOC` and the missing path.
  - (**inline**) Read each path with the `read` tool and confirm the file exists.

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: read each referenced path — expect file exists.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit any changes (if verification found issues that needed fixing).
  - (**inline**) `git add .opencode/skills/audit/tasks/ && git commit -m "Phase 5: Verify reference doc paths"`

## Phase 6: Update spec-audit-evaluator.md SC-13 cost-frame

**SC:** SC-6
**Concern:** spec-audit-evaluator-cost-frame
**Cost frame:** Grepping for the Read reference to cost-model-standards costs one search. Skipping means the evaluator still hard-codes the cost-frame rule and drifts from the reference doc.

### Item 6 — Update spec-audit-evaluator.md SC-13 to reference cost-model-standards

- [ ] **RED.** Write a behavioral enforcement test that verifies the evaluator reads from `reference/cost-model-standards.md` for SC-13 instead of hard-coding the cost-frame rule. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/spec-audit-evaluator.md`:
  - SC-13 (cost-frame): Replace hard-coded evaluation rule with: `Read [cost-model-standards.md](reference/cost-model-standards.md) and verify each SC's cost frame follows the dark-prose-007 pattern.`
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for Read reference to cost-model-standards present; grep for old hard-coded rule removed.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/spec-audit-evaluator.md && git commit -m "Phase 6: Update SC-13 cost-frame to reference cost-model-standards"`

## Phase 7: Update plan-fidelity-evaluator.md PF-7a cost-frame

**SC:** SC-7
**Concern:** plan-fidelity-evaluator-cost-frame
**Cost frame:** Grepping for the Read reference to cost-model-standards costs one search. Skipping means the evaluator still hard-codes the cost-frame rule and drifts from the reference doc.

### Item 7 — Update plan-fidelity-evaluator.md PF-7a to reference cost-model-standards

- [ ] **RED.** Write a behavioral enforcement test that verifies the evaluator reads from `reference/cost-model-standards.md` for PF-7a instead of hard-coding the cost-frame rule. The test MUST fail at this point.
  - (**clean-room**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`

- [ ] **GREEN.** Modify `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`:
  - PF-7a (cost-frame): Replace hard-coded evaluation rule with: `Read [cost-model-standards.md](reference/cost-model-standards.md) and verify each phase's cost frame follows the dark-prose-007 pattern.`
  - (**clean-room**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`

- [ ] **Verify.** Run the RED test again — it MUST pass. Verify: grep for Read reference to cost-model-standards present; grep for old hard-coded rule removed.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Commit.** Stage and commit the changes.
  - (**inline**) `git add .opencode/skills/audit/tasks/plan-fidelity-evaluator.md && git commit -m "Phase 7: Update PF-7a cost-frame to reference cost-model-standards"`

## Post-Implementation Steps

- [ ] **Structural checks.** Run the finishing checklist to verify all changes are complete and consistent.
  - (**clean-room**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`

- [ ] **Verification.** Run verification-before-completion against all 7 SCs. Produce evidence artifacts for each SC. If any SC FAILs, return BLOCKED with the failing SC IDs.
  - (**clean-room**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`

- [ ] **Audit.** Dispatch the audit skill to verify the plan was executed faithfully against the spec.
  - (**clean-room**) `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`

- [ ] **Cross-validate.** Cross-validate the audit findings against the verification evidence.
  - (**clean-room**) `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`

- [ ] **Review prep.** Prepare the PR for review with a summary of all changes.
  - (**clean-room**) `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow-pr/tasks/review-prep.md\` first")`

- [ ] **Create PR.** Create the pull request with the completed changes.
  - (**clean-room**) `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`

- [ ] **Completion.** Append lifecycle event and report executive summary.
  - (**clean-room**) `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`

## Lifecycle Events

- `2026-07-31T23:10:00Z` — `plan_created` — Plan file at `.opencode/.issues/2211/plan.md` with 7 phases. Authorization scope: `for_plan`. Halt at: `plan_created`.
