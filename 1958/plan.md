# Implementation Plan — [#1958](https://github.com/michael-conrad/.opencode/issues/1958) — Imperative verb forms for cross-reference load directive

**Goal:** Systematically test 13 verb forms (12 verbs + 1 checkbox-only) × 2 variants (plain/checkbox) × 4 models × 2 contexts (orchestrator/sub-agent) × 2 runs = 416 minimum test runs to identify the verb form that most reliably triggers `read` tool invocation.

**Architecture:** Sequential per-model test execution using `test-verb-variant.sh` harness. No parallel tasking — only one model can be loaded into GPU memory at a time. Preflight warmup required on model switch.

**Files:**
- `.opencode/tests-v2/behaviors/test-verb-variant.sh` — Test harness
- `.opencode/tests-v2/behaviors/helpers.sh` — Assertion helpers
- `.opencode/.issues/1958/plan.md` — This index
- `.opencode/.issues/1958/plan-01-orchestrator-tests.md` — Phase 1
- `.opencode/.issues/1958/plan-02-sub-agent-tests.md` — Phase 2
- `.opencode/.issues/1958/plan-03-analysis.md` — Phase 3
- `.opencode/.issues/1958/test-record.md` — Test record table (output)
- `.opencode/.issues/1958/winning-verb-analysis.md` — Analysis document (output)

**Dispatch:** All test execution steps dispatch via `bash .opencode/tests-v2/behaviors/test-verb-variant.sh`. Analysis steps are inline sub-agent tasks.

## Blast Radius

- `.opencode/tests-v2/behaviors/test-verb-variant.sh` — May be modified if harness needs adjustment
- `.opencode/.issues/1958/` — All plan and analysis artifacts
- `.opencode/guidelines/000-critical-rules.md` — Future: winning verb form replaces `Read [Text](path)` pattern
- `.opencode/prompts/default.txt` — Future: winning verb form injected into system prompt

## Concern Map Reference

| Concern | Phase | Description |
|---------|-------|-------------|
| Orchestrator context tests | 1 | Test all verb forms with directive in `default.txt` (system prompt) |
| Sub-agent context tests | 2 | Test all verb forms with directive in Tier 2 guideline (loaded on-demand) |
| Analysis and recommendation | 3 | Identify winning verb, document findings, produce recommendation |

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. Do NOT batch, combine, or parallelize steps. Each step must complete and be verified before the next step begins. The "sub-agent dispatch implies independence" rationalization is explicitly prohibited.

> **Step Status:** Every step MUST be marked with its current status: `- [ ]` = not started, `- [x]` = completed, `- [~]` = in progress. No step may be skipped or marked complete without verification.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|-------------|------------|----------|
| 1 | Orchestrator Context Tests | Test all 13 verb forms × 2 variants × 4 models × 2 runs in orchestrator context (208 runs) | SC-1, SC-3, SC-8, SC-9 | None | 1.1–1.12 | `test-verb-variant.sh` |
| 2 | Sub-agent Context Tests | Test all 13 verb forms × 2 variants × 4 models × 2 runs in sub-agent context (208 runs) | SC-2, SC-3, SC-8 | Phase 1 complete | 2.1–2.12 | `test-verb-variant.sh` |
| 3 | Analysis and Recommendation | Identify winning verb, document findings, produce recommendation | SC-4, SC-5, SC-6, SC-7 | Phase 2 complete | 3.1–3.5 | Inline sub-agent |

> **Compliance Requirement:** All steps and sub-steps in this plan MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** If a step fails, diagnose the root cause, fix it, and re-run the step. Do NOT skip the step or mark it as "pass with caveats." If the failure cannot be remediated after 2 attempts, escalate to the developer with the failure details and proposed resolution.

## Exit Criteria

- [ ] C1: Phase 1 complete — all 208 orchestrator context test runs completed with behavioral evidence artifacts
- [ ] C2: Phase 2 complete — all 208 sub-agent context test runs completed with behavioral evidence artifacts
- [ ] C3: Test record table produced at `.opencode/.issues/1958/test-record.md` with all required columns
- [ ] C4: Winning verb form identified based on file-loading call rate and zero grep/search substitution
- [ ] C5: Winning verb analysis documented at `.opencode/.issues/1958/winning-verb-analysis.md` with recommendation
- [ ] C6: Remediation research conducted if adherence rate ≤ 25%
- [ ] C7: No SC weakened, deferred, or reclassified
- [ ] C8: Behavioral enforcement tests written and confirmed RED before implementation changes
