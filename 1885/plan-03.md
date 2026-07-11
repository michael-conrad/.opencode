# Phase 3: Global Post-Phase — Audit, Cross-Validate, Review

**SCs:** SC-11 (spec audit), SC-12 (cross-validate), SC-13 (review)
**Concern:** Verification
**Evidence types:** SC-11, SC-12, SC-13 = `semantic`

## Entry Criteria

- Phase 2 complete (behavioral test PASSES)

## Steps

### Step 3.1: Spec Audit (SC-11)

**Type:** sub-task (audit skill)
**Dispatch:** `skill({name: "audit"})` → `task(subagent_type="general", prompt: "execute spec-audit task from audit for issue 1885")`
**Chain:** step_2.2
**Exit criteria:** Spec audit returns PASS for all 24 criteria
**Verification:** Read verdict.yaml from spec-audit output — all_criteria_pass: true

### Step 3.2: Cross-Validate (SC-12)

**Type:** sub-agent
**Dispatch:** `task(subagent_type="general", prompt="Cross-validate all verification evidence for issue 1885 against SC evidence type requirements. For each SC, confirm the submitted evidence type matches the declared evidence type. Flag any EVIDENCE_TYPE_MISMATCH. Return PASS or BLOCKED with mismatch details.")`
**Chain:** step_3.1
**Exit criteria:** No EVIDENCE_TYPE_MISMATCH found

### Step 3.3: Review — Deliverable Completeness (SC-13)

**Type:** sub-agent
**Dispatch:** `task(subagent_type="general", prompt="Review all deliverables for issue 1885 against the spec's 13 SCs. Verify: all file changes are complete (SC-1 through SC-6), behavioral test passes (SC-7, SC-8), coherence gate passed (SC-9), pre-flight checks passed (SC-10), spec audit passed (SC-11), cross-validate passed (SC-12). Return PASS with deliverable checklist or BLOCKED with missing items.")`
**Chain:** step_3.2
**Exit criteria:** All 13 SCs verified complete

## Scalable Review Gate

**MANDATORY:** Use `review-prep` task from `git-workflow` before PR creation.
**Dispatch:** `skill({name: "git-workflow"})` → `task(subagent_type="general", prompt: "execute review-prep task from git-workflow for issue 1885")`

## Phase Completion Gate

SC-11, SC-12, SC-13 MUST all be PASS.
PR body must include: Summary → Outcome → Fixes #1885 → SC table → Byline.
