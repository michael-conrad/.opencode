# [SPEC-FIX] Centralize Prose-Recall Prompt Prohibition in Behavioral Test Framework Documentation

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Value |
|-------|-------|
| **Problem Statement** | Behavioral test prompts that interview the agent about what it *would* do (prose-recall) instead of triggering natural agent behavior produce false PASS results. These "interview questions" test what the agent *says* it would do, not what it *actually does* — the agent can describe the correct procedure without executing it. |
| **Root Cause / Motivation** | The prohibition against prose-recall prompts exists in scattered locations (091-incremental-build.md, 080-code-standards.md §Rule 5, executing-plans/tasks/start.md, spec-creation/tasks/write.md) but there is NO centralized, enforceable mandate in the test framework documentation. The behavioral test harness specification at `.opencode/tests/AGENTS.md` has no section on prompt construction. The test template at `.opencode/tests/behaviors/template.sh` has no prompt construction guidance. |
| **Approach Chosen** | Centralize the prose-recall prohibition into a single authoritative §Prompt Construction Mandate section in `.opencode/tests/AGENTS.md`, add prompt construction guidance to the template, and add cross-references from the existing scattered locations. |
| **Alternatives Considered & Why Discarded** | Adding the rule to each existing location individually (rejected — perpetuates the scattering problem). Adding to 000-critical-rules.md (rejected — too heavy for a test methodology rule). |
| **Key Design Decisions** | The centralized section in AGENTS.md is the single source of truth; all other locations cross-reference it. The hard-fail rule is defined in AGENTS.md, not in guidelines. |

## Problem

Behavioral test prompts that interview the agent about what it *would* do (prose-recall) instead of triggering natural agent behavior are producing false PASS results. These "interview questions" test what the agent *says* it would do, not what it *actually does* — the agent can describe the correct procedure without executing it.

The prohibition against prose-recall prompts exists in scattered locations:
- `091-incremental-build.md` line 35 — "Prose-recall prompts are NOT accepted as behavioral tests"
- `080-code-standards.md` §Rule 5 — "Agent Output MUST Be Verified by Clean-Room Semantic Inspection — NEVER by grep/string on Prose"
- `executing-plans/tasks/start.md` — behavioral evidence definition
- `spec-creation/tasks/write.md` Step 0.5a — stderr-based evidence mandate

But there is NO centralized, enforceable mandate in the test framework documentation.

## Root Cause

The behavioral test harness specification at `.opencode/tests/AGENTS.md` has no section on prompt construction. The test template at `.opencode/tests/behaviors/template.sh` has no prompt construction guidance. Existing test scripts use interview-style prompts ("Explain how you would...", "Describe what X means", "List the steps for...") that are out of spec per the existing prose-recall prohibition but were never caught because there's no centralized rule.

## Scope

### In Scope

- Add §Prompt Construction Mandate section to `.opencode/tests/AGENTS.md` defining valid vs invalid behavioral test prompts, the interview/natural-behavior spectrum, and a hard-fail rule for prose-recall prompts
- Add prompt construction guidance comment block to `.opencode/tests/behaviors/template.sh`
- Add cross-reference in `.opencode/guidelines/080-code-standards.md` Enforcement Test Mandate section
- Add cross-reference in `.opencode/guidelines/091-incremental-build.md` Behavioral Variant section
- Create behavioral enforcement test verifying that an interview-style prompt produces a FAIL verdict

### Out of Scope

- Changes to existing behavioral test scripts (those are fixed in a separate pass)
- Changes to `helpers.sh` or `behavior_run()` logic
- Changes to the test harness infrastructure
- Changes to `executing-plans/tasks/start.md` or `spec-creation/tasks/write.md` (they already have the rule text)

## Affected Files

| File | Change Type | Anchor |
|------|-------------|--------|
| `.opencode/tests/AGENTS.md` | Add §Prompt Construction Mandate section | New section |
| `.opencode/tests/behaviors/template.sh` | Add prompt construction guidance comment block | Top of file |
| `.opencode/guidelines/080-code-standards.md` | Add cross-reference | "Enforcement Test Mandate" section |
| `.opencode/guidelines/091-incremental-build.md` | Add cross-reference | "Behavioral Variant" section |

## Approach

1. Add a new §Prompt Construction Mandate section to `.opencode/tests/AGENTS.md` that defines:
   - The interview/natural-behavior spectrum
   - Valid prompt types (real-domain task prompts that trigger natural agent behavior)
   - Invalid prompt types (interview questions, prose-recall prompts, "describe how you would" prompts)
   - The hard-fail rule: any behavioral test using a prose-recall prompt is FAIL
   - Examples of valid vs invalid prompts
2. Add a comment block to `.opencode/tests/behaviors/template.sh` with prompt construction guidance
3. Add cross-references in `080-code-standards.md` and `091-incremental-build.md` pointing to the centralized section
4. Create a behavioral enforcement test that verifies an interview-style prompt produces FAIL

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `.opencode/tests/AGENTS.md` has a new §Prompt Construction Mandate section defining valid vs invalid behavioral test prompts, with the interview/natural-behavior spectrum and a hard-fail rule for prose-recall prompts | `string` | `grep` for "Prompt Construction Mandate" in AGENTS.md | If missing, add the section | Phase 1 | `.opencode/tests/AGENTS.md` | REQ-1 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | `.opencode/tests/behaviors/template.sh` includes a comment block with prompt construction guidance | `string` | `grep` for "prompt" in template.sh | If missing, add the comment block | Phase 1 | `.opencode/tests/behaviors/template.sh` | REQ-2 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | `.opencode/guidelines/080-code-standards.md` Enforcement Test Mandate section cross-references the centralized prompt guidelines | `string` | `grep` for "AGENTS.md" or "Prompt Construction" in 080-code-standards.md | If missing, add cross-reference | Phase 1 | `.opencode/guidelines/080-code-standards.md` | REQ-3 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | `.opencode/guidelines/091-incremental-build.md` Behavioral Variant section cross-references the centralized prompt guidelines | `string` | `grep` for "AGENTS.md" or "Prompt Construction" in 091-incremental-build.md | If missing, add cross-reference | Phase 1 | `.opencode/guidelines/091-incremental-build.md` | REQ-4 | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | Behavioral enforcement test verifies that an interview-style prompt ("Describe how you would handle authorization") produces a FAIL verdict from the test framework | `behavioral` | `bash .opencode/tests/behaviors/prose-recall-rejection.sh` | If test fails, fix the test script or the AGENTS.md section | Phase 1 | `.opencode/tests/behaviors/prose-recall-rejection.sh` | REQ-5 | Phase 1 | pre-commit | standalone | — | — | `prose-recall-rejection.sh` | Phase 1 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/1616/plan.md` before implementation begins.

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| Existing test scripts use interview prompts | Out of scope — fixed in a separate pass |
| Agent uses prose-recall in stderr (not stdout) | Stderr tool dispatch strings are not prose-recall; only stdout prose counts |
| Mixed prompt (part interview, part natural) | Classified by the dominant mode; if the prompt asks the agent to describe rather than do, it's invalid |

## Risk Traceability

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Centralized section is ignored by agents writing tests | Medium | High | Cross-references from 080 and 091 ensure visibility; behavioral test SC-5 enforces at runtime | SC-5 |
| RISK-2 | Existing interview prompts not caught | High | Medium | Out of scope for this spec; separate cleanup pass required | — |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Centralize in AGENTS.md, not guidelines | AGENTS.md is the test framework documentation — the rule belongs with the methodology, not in agent behavior rules | MUST | SC-1 |
| DEC-2 | Hard-fail rule in AGENTS.md, not in critical-rules.md | The rule is test methodology, not agent behavior — too heavy for Tier 1 | MUST | SC-1 |
| DEC-3 | Cross-references from 080 and 091 only | Those are the two locations that already define behavioral evidence; other locations (executing-plans, spec-creation) already have the rule text | MUST | SC-3, SC-4 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Sub-Issue Requirements | PR Strategy |
| -------------- | ---------------- | ---------------------- | ----------- |
| single-task | 1 | None | single PR |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep` for "prose-recall" in `.opencode/` | Identify existing scattered locations |
| Direct source search | `grep` for "behavioral evidence" in `.opencode/` | Identify existing behavioral evidence definitions |
| Local docs | `.opencode/tests/AGENTS.md` | Verify no existing prompt construction section |
| Local docs | `.opencode/tests/behaviors/template.sh` | Verify no existing prompt construction guidance |

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `https://github.com/michael-conrad/.opencode/tree/issues-data/1616/`.
After creation, `local-issues sync 1616` MUST be run and the result committed to create the local `.issues/1616/` entry.
The implementation plan will be created in `.issues/1616/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation and MUST NOT base implementation on this summary.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
