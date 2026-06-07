# Card Catalogue — Artifact Infrastructure

**Status:** spec
**Scope:** artifact-infrastructure
**Issue:** 1061
**Dependencies:** [#850](https://github.com/michael-conrad/.opencode/issues/850), [#1060](https://github.com/michael-conrad/.opencode/issues/1060)
**Items Covered:** 10, 21, 22, 24, 29, 30, 33, 35, 37

## Cards

### Card 1: Dependency-Ordering Solve Contract (Item 10)

**Concern:** Phase ordering must be machine-validable as a Z3 constraint problem.

**Solution:** Create solve contract at `.issues/{issue-N}/spec-artifacts/dependency-ordering-verification/` with integer variables for each phase and inequality preconditions. `solve check` returns SAT (valid order) or UNSAT (cycle detected).

**Affected:**
- `writing-plans/tasks/create/plan-structure.md` — add solve contract creation after phase structure defined
- `.issues/{issue-N}/spec-artifacts/dependency-ordering-verification/` — new artifact path

**SC Linkage:** SC-1

---

### Card 2: Pre-Approval Exit Criteria Gate — Expanded (Item 21)

**Concern:** Existing pre-approval gate solve contract at `.opencode#1060` must be expanded with new column validations.

**Solution:** Add boolean variables for Pipeline Step Binding, Re-Entry Step, Verification Gate, Artifact Path, and Phase Binding presence checks. Tier-dependent precondition gates for standard/complex specs.

**Affected:**
- `approval-gate/SKILL.md` — expand gate with new columns
- `.issues/{issue-N}/spec-artifacts/pre-approval-gate-contract.yaml` — updated contract

**SC Linkage:** SC-2

---

### Card 3: Solve/Plan Utility Integration (Item 22)

**Concern:** spec-creation and writing-plans MUST invoke `solve` and `plan` proactively during artifact creation.

**Solution:**
- **spec-creation:** `solve` after requirements step (constraints contract), `plan` after decomposition classification (decomposition validation)
- **writing-plans:** `solve` for phase exit criteria, `plan` for phase structure solvability

**Affected:**
- `spec-creation/tasks/write.md` — add utility invocations after Step 5.5
- `writing-plans/tasks/create.md` — add utility invocations in Steps 0-5
- `writing-plans/tasks/create/plan-structure.md` — add phase dependency + solvability modeling

**SC Linkage:** SC-2, SC-3

---

### Card 4: Machine-Parseable SC Coverage Summary (Item 24)

**Concern:** Downstream consumers need a parseable YAML summary of the SC table, not prose.

**Solution:** Generate `.issues/{issue-N}/spec-artifacts/sc-summary.yaml` during spec assembly (Step 1) with SC IDs, requirement IDs, phase bindings, pipeline steps, verification gates, artifact paths, risk traceability, and decision cross-references. Validated during self-review (Step 6).

**Affected:**
- `spec-creation/tasks/write.md` — add SC coverage YAML generation to Step 1
- `spec-creation/tasks/write.md` — add YAML-vs-prose validation to Step 6
- `.issues/{issue-N}/spec-artifacts/sc-summary.yaml` — new artifact path
- `.issues/{issue-N}/spec-artifacts/sc-summary-schema.yaml` — new schema contract

**SC Linkage:** SC-4

---

### Card 5: Spec Revision Re-Entry Protocol (Item 29)

**Concern:** Revised specs must define which handoffs and pipeline steps must be replayed.

**Solution:** Solve contract at `.issues/{issue-N}/spec-artifacts/revision-re-entry-contract.yaml` with boolean variables for each revision scope and cascade consequences. `solve check` validates re-entry plan.

**Affected:**
- `.issues/{issue-N}/spec-artifacts/revision-re-entry-contract.yaml` — new artifact path
- `approval-gate/SKILL.md` — add re-entry protocol consultation before applying `approved-for-*` label

**SC Linkage:** SC-5

---

### Card 6: Artifact Retention Policy (Item 30)

**Concern:** Artifact lifecycle must be defined: what lives where, when is it cleaned.

**Solution:** Three rules: (1) `./tmp/{issue-N}/` preserved until PR merge, (2) step-specific pre-cleanup at each pipeline step, (3) `.issues/{issue-N}/spec-artifacts/` never cleaned.

**Affected:**
- `implementation-pipeline/SKILL.md` — add Artifact Retention section with three rules
- `git-workflow/tasks/cleanup.md` — add `./tmp/{issue-N}/` cleanup to PR merge cleanup

**SC Linkage:** SC-7

---

### Card 7: Spec Lifecycle Manifest (Item 33)

**Concern:** Spec lifecycle state must be tracked as a permanent, append-only artifact.

**Solution:** Append-only YAML at `.issues/{issue-N}/spec-artifacts/lifecycle.yaml`. Each pipeline stage appends its milestone event. Events: spec_created, spec_approved, pre_approval_gate, plan_created, spec_to_plan_handoff, plan_to_pipeline_handoff, pipeline_completed, spec_audit, sc_close_out, issue_closed.

**Affected:**
- `.issues/{issue-N}/spec-artifacts/lifecycle.yaml` — new artifact path
- `spec-creation/tasks/write.md` — add initialization in Step 1
- `implementation-pipeline/SKILL.md` — add event emission to each pipeline step
- `git-workflow/tasks/cleanup.md` — add issue_closed event

**SC Linkage:** SC-6

---

### Card 8: Blocker Documentation Protocol (Item 35)

**Concern:** Blockers at pipeline gates must be recorded as structured, append-only lifecycle manifest entries.

**Solution:** Blocker events appended to lifecycle manifest with stage, severity (`block` or `flag`), reason, and resolution fields. Seven mandatory emission stages defined.

**Affected:**
- `.issues/{issue-N}/spec-artifacts/lifecycle.yaml` — blocker entries appended (same file as Card 7)
- `implementation-pipeline/SKILL.md` — add blocker emission checkpoints at each pipeline gate

**SC Linkage:** SC-6

---

### Card 9: Verification Gate × Evidence Type Consistency Contract (Item 37)

**Concern:** Every SC's Verification Gate must be sufficient for its declared Evidence Type.

**Solution:** Solve contract at `.issues/{issue-N}/spec-artifacts/verification-consistency-contract.yaml` with compliance matrix as boolean variables. Pre-approval gate validates each SC against the matrix. `solve check` returns UNSAT for non-compliant pairings.

**Affected:**
- `.issues/{issue-N}/spec-artifacts/verification-consistency-contract.yaml` — new artifact path
- `spec-creation/tasks/write.md` — add contract generation in Step 1
- `spec-creation/tasks/write.md` — add consistency validation in Step 6 self-review

**SC Linkage:** SC-8

---

**Co-authored with AI: OpenCode (deepseek-v4-flash)**