# Phase 4 — Verify end-to-end

**Concern:** End-to-end verification — behavioral test that creates a spec through the new pipeline and verifies output at correct path

**Files:**
- `.opencode/tests-v2/behaviors/` — New behavioral test file

**SCs:** SC-9, SC-13, SC-14, SC-15

**Dependencies:** Phase 3

**Entry conditions:** All previous phases complete, sub-skill directories removed

**Exit conditions:** Behavioral test passes, clean-room separation verified

## Code Path Coverage

- Behavioral test script — verify spec creation pipeline
- Clean-room context verification — each sub-agent receives only scoped context

## Cross-Cutting SCs

- SC-13, SC-14, SC-15: Clean-room context — applies to analyze, create, validate respectively

## Interface Boundaries

- Behavioral test must use `with-test-home` wrapper
- Test must verify spec file at correct `.issues/{N}/` path

## State Transitions

- Pipeline implemented → behavioral test passes → spec ready for approval

## Step-by-step

- [ ] 8. **Write and run behavioral test (**sub-agent**).** Create a behavioral test that:
  - Dispatches the spec-creation pipeline (analyze → create → validate)
  - Verifies the spec file is written to the correct `.issues/{N}/` or `<sub-repo>/.issues/{N}/` path
  - Verifies each sub-agent receives only its scoped context (analyze: {issue_number, project_root}; create: {issue_number, analysis_artifact_path}; validate: {issue_number, spec_path})
  - Runs via `bash .opencode/tests-v2/with-test-home opencode run '<message>'`
  - **→ SC-9, SC-13, SC-14, SC-15**

#### Phase 4 VbC

- [ ] 8a. **VbC (**clean-room**).** Verify: behavioral test passes; spec file exists at correct path; clean-room context verified. **→ SC-9, SC-13, SC-14, SC-15**

**Concern transition:** Leaving end-to-end verification → done. All phases complete.
