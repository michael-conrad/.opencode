---
title: "[SPEC-FIX] Change default test model from gpt-oss:20b-cloud to qwen3.6:35b-256k"
status: draft
created: 2026-07-15
license: MIT
provenance: AI-generated
issue: 1956
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-15

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. Read [Test Integrity Mandate](guidelines/080-code-standards.md).

## Problem

The default test model in `.opencode/tests-v2/default-model.sh` is `ollama/gpt-oss:20b-cloud`, a cloud model that hits rate limits during behavioral test runs. `ollama/qwen3.6:35b-256k` is a local model that is faster and more reliable for behavioral test runs.

## Root Cause Analysis

`default-model.sh` line 4 was set to `ollama/gpt-oss:20b-cloud` when the v2 test framework was created. The model was chosen as a capable default but its cloud nature introduces rate-limit failures during automated test runs. The file has never been updated since creation.

## Goals

- Change the default test model from `ollama/gpt-oss:20b-cloud` to `ollama/qwen3.6:35b-256k` in `.opencode/tests-v2/default-model.sh`

## Non-Goals

- **No changes to any other file** — this is a single-line, single-file change
- **No changes to the v2 test framework** — only the default model string changes
- **No migration of behavioral tests** — existing tests continue to work with the new default

## Alternatives Considered & Why Discarded

1. **Keep gpt-oss:20b-cloud and add retry logic** — Adds complexity to the test harness. The model is cloud-based and rate limits are inherent to its architecture.
2. **Use ornith:35b-256k** — Faster but less thorough (did not dispatch approval-gate-scope skill in Read-link experiment). qwen3.6:35b-256k was more thorough.
3. **No default, require explicit model override** — Breaks all tests that rely on the default. Increases friction for developers running tests.

## Scope

Single-line change to `.opencode/tests-v2/default-model.sh`: replace `ollama/gpt-oss:20b-cloud` with `ollama/qwen3.6:35b-256k`.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1941](https://github.com/michael-conrad/.opencode/issues/1941) | SUPERSEDES | Previous spec-fix for same file proposed qwen3.6 but was closed as already-fixed with ornith value |

## Success Criteria

| ID | Criterion | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `default-model.sh` contains `ollama/qwen3.6:35b-256k` as the default model | `grep "DEFAULT_TEST_MODEL.*qwen3.6:35b-256k" .opencode/tests-v2/default-model.sh` — exit code 0 | Replace the model string on line 4 | red-green | `.opencode/tests-v2/default-model.sh` | Root cause: model string was wrong | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-2 | `ollama/gpt-oss:20b-cloud` is no longer present in `default-model.sh` | `grep "gpt-oss:20b-cloud" .opencode/tests-v2/default-model.sh` — exit code 1 | Verify replacement removed old string | red-green | `.opencode/tests-v2/default-model.sh` | Root cause: old model string must be removed | Phase 1 | pre-commit | sequential | — | — | — | Phase 1 |
| SC-3 | Behavioral test using default model runs without rate-limit errors | Run `bash .opencode/tests-v2/with-test-home --setup` and verify setup completes without timeout | Increase timeout or switch model | post-implementation | `tmp/behavioral-evidence-*/` | Root cause: cloud model caused rate-limit failures | Phase 1 | post-implementation | sequential | — | — | — | Phase 1 |
| SC-4 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | Audit of implementation confirms all SCs achieved 100% clean PASS | Remediate any weakened SC | audit | `.issues/1956/` | Anti-lobotomization mandate | Phase 1 | pre-approval-gate | sequential | — | — | — | Phase 1 |

## Risk and Edge Cases

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| qwen3.6:35b-256k not available on all systems | Low | Medium | The default is overridable via `DEFAULT_TEST_MODEL` env var |
| Model name typo in replacement | Low | Low | SC-1 and SC-2 verify both presence and absence |
| Other files reference gpt-oss:20b-cloud as default | Low | Low | `default-model.sh` is the single source of truth per its header comment |

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Use qwen3.6:35b-256k over ornith:35b-256k | qwen3.6 was more thorough in Read-link experiment (dispatched approval-gate-scope skill) | MUST | SC-1 |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read(.opencode/tests-v2/default-model.sh)` | Verify current value |
| Live verification | `opencode models \| grep qwen3.6` | Verify qwen3.6:35b-256k exists in available models |
| Live verification | `opencode models \| grep gpt-oss` | Verify gpt-oss:20b-cloud exists in available models |
| GitHub Issues | `github_search_issues` for default model | Check for existing specs on this change |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.issues/1956/plan.md` before implementation begins.

Co-authored with AI: OpenCode (deepseek-v4-flash)
