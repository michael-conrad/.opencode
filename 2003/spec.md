---
title: Orchestrator bypasses spec-creation pipeline — direct github_issue_write for spec content
status: revised-needs-approval
created: 2026-07-19
license: MIT
provenance: AI-generated
issue: 2003
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** 1.1 (REVISED - NEEDS APPROVAL)
**CREATED:** 2026-07-19

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The orchestrator treats `github_issue_write` as a valid spec-creation mechanism. There is no enforcement gate preventing direct issue body writes for spec content. The spec-creation pipeline exists and is functional — the orchestrator simply does not dispatch to it.

**Evidence:** Issue #2000 was created via direct `github_issue_write` with no analytical artifacts, no SC coverage YAML, no verification consistency contract, no lifecycle manifest, no holistic self-check, no spec audit.

## Root Cause Analysis

The orchestrator has no critical-rules entry classifying direct `github_issue_write` for spec content as a violation. The spec-creation pipeline is documented and functional, but the orchestrator treats `github_issue_write` as an acceptable shortcut. There is no behavioral enforcement test that catches this bypass pattern.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|------------------|
| Add a pre-commit hook to block direct issue writes | Pre-commit hooks cannot distinguish spec content from other issue writes (comments, status updates) |
| Modify the spec-creation pipeline to auto-detect bypass | Pipeline modification is more invasive than adding an enforcement gate at the orchestrator level |
| Add a guideline-only entry without behavioral test | Guideline-only entries are suggestions, not enforcement — #1217 proved content-verification alone is insufficient |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Load [Test Integrity Mandate](.opencode/guidelines/080-code-standards.md).

## Fix Approach

1. Add a behavioral enforcement test that verifies the agent dispatches to `spec-creation` when asked to create a spec
2. Add a critical-rules entry classifying direct `github_issue_write` for spec content as a Tier 2 violation
3. The existing #2000 should be replaced by a properly-created spec

## Affected Files

- `tests-v2/behaviors/` — New behavioral enforcement test
- `.opencode/guidelines/000-critical-rules.md` — New critical-rules entry

## Non-Goals

- Not changing the spec-creation pipeline itself
- Not adding new pipeline steps
- Not modifying existing critical-rules entries

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#2000](https://github.com/michael-conrad/.opencode/issues/2000) | SUPERSEDES | This spec supersedes the direct-write approach used in #2000 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Behavioral enforcement test exists in `tests-v2/behaviors/` that verifies agent dispatches to `spec-creation` when asked to create a spec | `behavioral` | `bash .opencode/tests-v2/with-test-home opencode run 'create a spec for X'` with stderr assertion for `Skill "spec-creation"` | If test fails: verify test prompt triggers spec-creation dispatch; re-run | RED-GREEN | `.opencode/tests-v2/behaviors/spec-creation-dispatch.sh` | Root cause: no enforcement gate | Phase 1 | pre-commit | sequential | — | Step 1 | `spec-creation-dispatch.sh` | Phase 1 |
| SC-2 | Critical-rules entry exists in `guidelines/000-critical-rules.md` classifying direct `github_issue_write` for spec content as a Tier 2 violation | `string` | `grep -n 'github_issue_write' .opencode/guidelines/000-critical-rules.md` | If missing: add entry with Tier 2 classification | RED-GREEN | `.opencode/guidelines/000-critical-rules.md` | Root cause: no prohibition exists | Phase 1 | pre-commit | sequential | — | Step 1 | — | Phase 1 |
| SC-3 | The behavioral test is in RED state before implementation (fails without the rule change) | `behavioral` | Run `bash .opencode/tests-v2/behaviors/spec-creation-dispatch.sh` before any implementation changes — MUST FAIL | If test passes before change: test is defective — fix test prompt | RED | `.opencode/tests-v2/behaviors/spec-creation-dispatch.sh` | TDD discipline | Phase 1 | pre-commit | sequential | — | Step 1 | `spec-creation-dispatch.sh` | Phase 1 |
| SC-4 | The behavioral test is in GREEN state after implementation (passes with the rule change) | `behavioral` | Run `bash .opencode/tests-v2/behaviors/spec-creation-dispatch.sh` after implementation — MUST PASS | If test fails after change: verify critical-rules entry is correct; re-run | GREEN | `.opencode/tests-v2/behaviors/spec-creation-dispatch.sh` | TDD discipline | Phase 1 | pre-commit | sequential | — | Step 1 | `spec-creation-dispatch.sh` | Phase 1 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/2003/plan.md` before implementation begins.

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Behavioral test flakes due to model variability | Medium | Medium | Use `assert_stderr_pattern_present_all_models` for robustness |
| Critical-rules entry too narrow — misses other bypass patterns | Low | Medium | Use broad language covering all direct API mutations for spec content |

## Decision Log

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Use behavioral test as primary enforcement | Content-verification alone is insufficient per #1217 | MUST | SC-1, SC-3, SC-4 |
| DEC-2 | Classify as Tier 2 (not Tier 1) | Direct issue write is a process-integrity defect, not a safety-critical violation | MUST | SC-2 |

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-07-19 | OpenCode (ollama-cloud/deepseek-v4-flash) | Initial spec |
| 1.1 | 2026-07-19 | OpenCode (ollama-cloud/deepseek-v4-flash) | **Defect 1:** Added Evidence Type column to SC table (SC-1: behavioral, SC-2: string, SC-3: behavioral, SC-4: behavioral). **Defect 2:** Fixed cross-reference path from `guidelines/080-code-standards.md` to `.opencode/guidelines/080-code-standards.md`. **Defect 3:** Removed SC-5 (meta-SC, not a testable criterion). STATUS updated to REVISED - NEEDS APPROVAL. |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -r "github_issue_write" .opencode/guidelines/` | Verify no existing prohibition |
| Direct source search | `ls .opencode/tests-v2/behaviors/` | Identify existing behavioral test patterns |
| MCP search | `srclight_search_symbols("spec-creation")` | Verify spec-creation pipeline exists |

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
