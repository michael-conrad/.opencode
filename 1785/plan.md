# Implementation Plan — [#1785](https://github.com/michael-conrad/.opencode/issues/1785) — Audit invocation verification

- **Goal:** Create 16 behavioral test scripts verifying correct audit dispatch at all 7 pipeline touchpoints, plus 5 structural file updates (rename `adversarial-audit` → `audit`, update `audit/SKILL.md` §Blind Dispatch).
- **Architecture:** 6 phases — core dispatch (6 scenarios) → pipeline touchpoints (7 scenarios) → cross-validate (2 scenarios) → bidirectional finding (1 scenario) → structural changes (SC-17, SC-18) → auto-invocation (SC-19). Each behavioral test is an artifact-only generator per `.opencode/tests/AGENTS.md`. Structural changes are direct file edits.
- **Files:**
  - `.opencode/tests/behaviors/NEW-sc1-audit-unified-invocation.sh`
  - `.opencode/tests/behaviors/NEW-sc2-audit-cleanroom-dispatch.sh`
  - `.opencode/tests/behaviors/NEW-sc3-audit-consensus-pass.sh`
  - `.opencode/tests/behaviors/NEW-sc4-audit-consensus-fail.sh`
  - `.opencode/tests/behaviors/NEW-sc5-audit-consensus-disagree.sh`
  - `.opencode/tests/behaviors/NEW-sc6-audit-multi-type.sh`
  - `.opencode/tests/behaviors/NEW-sc7-audit-touchpoint-spec-creation.sh`
  - `.opencode/tests/behaviors/NEW-sc8-audit-touchpoint-writing-plans.sh`
  - `.opencode/tests/behaviors/NEW-sc9-audit-touchpoint-issue-operations.sh`
  - `.opencode/tests/behaviors/NEW-sc10-audit-touchpoint-implementation-pipeline.sh`
  - `.opencode/tests/behaviors/NEW-sc11-audit-touchpoint-verification-before-completion.sh`
  - `.opencode/tests/behaviors/NEW-sc12-audit-touchpoint-pr-creation.sh`
  - `.opencode/tests/behaviors/NEW-sc13-audit-touchpoint-git-workflow.sh`
  - `.opencode/tests/behaviors/NEW-sc14-audit-cross-validate-evidence-type-gate.sh`
  - `.opencode/tests/behaviors/NEW-sc15-audit-cross-validate-frugal-contract.sh`
  - `.opencode/tests/behaviors/NEW-sc16-audit-bidirectional-finding.sh`
  - `.opencode/skills/audit/SKILL.md` — update §Blind Dispatch
  - `.opencode/skills/implementation-pipeline/pipeline-state-machine.yaml` — rename `adversarial-audit` → `audit`
  - `.opencode/.guidelines/registry.yaml` — update paths
  - `.opencode/CHANGELOG.md` — update reference
  - `.opencode/README.md` — update reference
  - `.opencode/docs/adversarial-audit-sc6959-verification.md` — rename + update content

> **Compliance requirement:** This plan MUST be followed step by step. Every step is mandatory. No step may be skipped, combined, or reordered. The orchestrator MUST dispatch each step to a clean-room sub-agent via `task()` — no inline execution. If a step produces a FAIL or BLOCKED result, the orchestrator MUST discard all work from that sub-agent and re-task clean-room with the same scoped context. This is a NON-WAIVABLE hard gate.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step completes, verify its output before proceeding to the next. Do NOT batch steps, do NOT parallelize, do NOT skip ahead. Each step's output is the next step's input.

> **Step Status:** Before each step, update `todowrite` to mark the current step as `in_progress`. After each step, update it to `completed`. Before halting, call `todowrite(todos=[])` to clear state.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Core audit dispatch | 6 behavioral tests for unified invocation, cleanroom dispatch, consensus gates, multi-type | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | None | 5–16 |
| 2 | Pipeline touchpoints | 7 behavioral tests for each consuming skill's audit dispatch | SC-7, SC-8, SC-9, SC-10, SC-11, SC-12, SC-13 | Phase 1 (test infrastructure pattern) | 17–30 |
| 3 | Cross-validate behavior | 2 behavioral tests for evidence type gate and frugal contract | SC-14, SC-15 | Phase 1 (test infrastructure pattern) | 31–34 |
| 4 | Bidirectional finding | 1 behavioral test for plan-spec mismatch revision options | SC-16 | Phase 1 (test infrastructure pattern) | 35–36 |
| 5 | Structural changes | Update audit/SKILL.md Blind Dispatch + rename stale `adversarial-audit` references | SC-17, SC-18 | None | 37–42 |
| 6 | Auto-invocation | 1 behavioral test verifying audit fires without explicit user request | SC-19 | Phase 1 (test infrastructure pattern) | 43–44 |

> **Compliance requirement:** This plan MUST be followed step by step. Every step is mandatory. No step may be skipped, combined, or reordered. The orchestrator MUST dispatch each step to a clean-room sub-agent via `task()` — no inline execution. If a step produces a FAIL or BLOCKED result, the orchestrator MUST discard all work from that sub-agent and re-task clean-room with the same scoped context. This is a NON-WAIVABLE hard gate.

> **Self-remediation protocol:** If a step fails, the orchestrator MUST NOT halt immediately. It MUST: (1) diagnose the root cause, (2) discard the failed sub-agent's output, (3) re-task clean-room with the same scoped context, (4) if re-task also fails, report double-failure and HALT. This is a NON-WAIVABLE hard gate.

## Exit Criteria

- [ ] C1. All 16 behavioral test scripts exist at `.opencode/tests/behaviors/NEW-sc*-audit-*.sh`
- [ ] C2. Each test script is an artifact-only generator (exit 0 unconditionally, uses `behavior_run`)
- [ ] C3. Each test script has `# SC-N:` comment annotations for its SCs
- [ ] C4. `audit/SKILL.md` §Blind Dispatch documents `audit_phase` as optional field
- [ ] C5. No stale `adversarial-audit` references remain in tracked files
- [ ] C6. All 6 pipeline touchpoint tests pass via `--tag audit-touchpoint`
- [ ] C7. All 16 tests pass individually via `bash .opencode/tests/behaviors/NEW-sc*-audit-*.sh`
- [ ] C8. Verification-before-completion confirms all 19 SCs
- [ ] C9. Finishing checklist passes
- [ ] C10. Review-prep completed with compare URL
- [ ] C11. PR created targeting `dev` branch
