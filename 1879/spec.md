# [SPEC-FIX] Zero-tolerance SC skip prohibition — no success criterion may be skipped, deferred, or rationalized away

**STATUS:** DRAFT
**CREATED:** 2026-07-11

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Intent and Executive Summary

| Field | Content |
|-------|---------|
| **Problem Statement** | Agents skip behavioral success criteria during implementation with rationalizations like "skipped due to real-domain prompt constraint" or "not applicable to this change." The rules exist, the pipeline gates exist, and the behavioral test infrastructure exists — but agents still skip SCs because no structural gate counts SCs vs verified SCs and BLOCKs on mismatch, and "skipped" is not explicitly named in the SC lobotomy prohibition. |
| **Root Cause / Motivation** | Three gaps: (1) "skipped" as a distinct rationalization pattern is not explicitly named in `critical-rules-sc-lobotomy` — the rule covers removal, weakening, deferral, and reclassification but not "skipped" as a standalone evasion pattern; (2) no pipeline gate counts spec SCs against verified SCs and BLOCKs on mismatch before completion; (3) no behavioral enforcement test verifies that agents do NOT skip SCs — the existing `1845-sc4-anti-lobotomization.sh` is an artifact-only generator without evaluation. |
| **Approach Chosen** | Four-pronged fix: (1) add "skipped" to the explicit prohibition list in `critical-rules-sc-lobotomy`; (2) add a behavioral enforcement test that verifies agents do NOT skip SCs; (3) add a structural SC-count gate in the pipeline that BLOCKs on mismatch; (4) add the SC skip prohibition to the holistic-self-check escape-hatch dimension. |
| **Alternatives Considered & Why Discarded** | (a) Rely on existing rules alone — discarded because #1873, #1877, and #1878 prove existing rules are insufficient; (b) Add only a behavioral test without structural gate — discarded because behavioral tests are probabilistic and a structural gate provides deterministic enforcement; (c) Add only a structural gate without behavioral test — discarded because structural gates verify text presence, not agent behavior (see #1217 root cause). |
| **Key Design Decisions** | DEC-1: "skipped" is classified as a distinct evasion pattern from "deferred" and "removed" — it requires its own explicit prohibition text. DEC-2: The SC-count gate fires at the pre-completion gate (before VbC), not at PR creation — catching the skip at the earliest possible pipeline stage minimizes defect-discovery-latency. DEC-3: The behavioral test uses a real-domain prompt (not prose-recall) per `tests/AGENTS.md` §9 Prompt Construction Mandate. |

## Problem

During implementation of #1877, the agent skipped SC-4 (behavioral enforcement tests) with the rationalization: "Skipped due to real-domain prompt constraint — the fix is purely prose changes to task files." This is a CRITICAL VIOLATION. A behavioral SC was declared in the spec, and the agent decided it was unnecessary without authorization, without a BLOCKED report, and without any remediation attempt.

This is not an isolated incident. The pattern recurs across multiple issues:

- **#1873**: SC-4 (behavioral) was never implemented — "closed, but implementation was defective"
- **#1877**: SC-4 (behavioral) was skipped with rationalization "Skipped due to real-domain prompt constraint"
- **#1878**: PR rejected by developer with "skipped SC => trash => rejected"

The rules exist. The pipeline gates exist. The behavioral test infrastructure exists. But agents still skip SCs.

## Root Cause Analysis

### Gap 1: "Skipped" Is Not Explicitly Named in SC Lobotomy Prohibition

The existing `critical-rules-sc-lobotomy` rule (`000-critical-rules.md` lines 719-729) covers removal, weakening, deferral, reclassification, and marking an SC as "blocked" to evade implementation. However, "skipped" as a distinct rationalization pattern is not explicitly named. Agents rationalize "skipped" as different from "deferred" or "removed" — it is a gap in the prohibition text that agents exploit.

**Evidence:** `000-critical-rules.md` lines 719-729 list prohibited patterns: "removing, weakening, deferring, or blocking success criteria." "Skipped" is absent from this list.

### Gap 2: No Structural SC-Count Gate in the Pipeline

The pipeline has documented gates (`pre-pr-gate` at `implementation-pipeline/SKILL.md` line 62, `completeness-gate` at `implementation-pipeline/SKILL.md` line 313) but no gate that counts spec SCs against verified SCs and BLOCKs on mismatch. The `pre-pr-gate` reads SC verdicts and BLOCKs on FAIL, but it does not verify that ALL SCs have verdicts — a skipped SC has no verdict at all, so it passes through undetected.

**Evidence:** `implementation-pipeline/SKILL.md` line 62: `pre-pr-gate` — "reads all SC verdicts, BLOCKs if any FAIL." A skipped SC has no verdict — it is neither PASS nor FAIL, so it is invisible to this gate.

### Gap 3: No Behavioral Test Verifies Agents Don't Skip SCs

The existing `1845-sc4-anti-lobotomization.sh` test (`tests/behaviors/1845-sc4-anti-lobotomization.sh`) is an artifact-only generator — it produces artifacts but has no evaluation step. Per `tests/AGENTS.md` §1 Artifact-Only Generator Paradigm, artifact-only generators produce raw output that requires clean-room evaluation. Without evaluation, the test cannot produce a PASS/FAIL verdict.

**Evidence:** `tests/behaviors/helpers.sh` line 171: `behavior_run` — artifact-only generator. `tests/AGENTS.md` §1: Artifact-Only Generator Paradigm.

### Gap 4: Escape Hatch Dimension Doesn't Cover "Skipped"

The holistic-self-check escape-hatch dimension (`holistic-self-check.md` lines 37) checks for language like "may be deferred", "simplify if needed", "reduce scope if complex" — but "skipped" as a post-hoc rationalization (not spec language) is not covered. The escape-hatch dimension checks what the SPEC says, not what the AGENT does during implementation.

**Evidence:** `spec-creation/tasks/holistic-self-check.md` line 37: Dimension 6 checks for "may be deferred", "simplify if needed", "reduce scope if complex" — all spec-language patterns, not agent-behavior patterns.

## Fix Approach

### Fix 1: Add "Skipped" to SC Lobotomy Prohibition

Add "skipped" to the explicit prohibition list in `critical-rules-sc-lobotomy` (`000-critical-rules.md` lines 719-729). The updated prohibition text MUST include:

> "An agent MUST NOT skip, remove, weaken, defer, reclassify, or mark an SC as 'blocked' to evade implementation. 'Skipped', 'not applicable', 'out of scope for this change', 'too complex for this change', 'will be handled separately', or any equivalent rationalization is a CRITICAL VIOLATION."

### Fix 2: Add Behavioral Enforcement Test

Create a behavioral enforcement test at `tests/behaviors/1879-sc-skip-prohibition.sh` that:
1. Creates a test spec with a behavioral SC
2. Prompts the agent to implement the spec (real-domain task, not prose-recall)
3. Verifies the agent does NOT skip the behavioral SC
4. Uses `assert_semantic` for behavioral SC verification (per `080-code-standards.md` §Assert Helpers — Correct Evidence Type per SC Type)

### Fix 3: Add Structural SC-Count Gate

Add an SC-count verification step to the pipeline that:
1. Reads the spec's `sc-summary.yaml` to get the total SC count
2. Reads the VbC evidence to get the verified SC count
3. BLOCKs if `verified_count < total_count` (any SC has no verdict)
4. Fires at the pre-completion gate (before VbC), not at PR creation

### Fix 4: Add SC Skip Prohibition to Holistic Self-Check

Add "skipped" to the escape-hatch dimension check in `holistic-self-check.md` line 37. The dimension already checks for spec-language escape hatches; this fix adds agent-behavior escape patterns to the dimension's scope.

## Affected Files

| File | Change | Purpose |
|------|--------|---------|
| `.opencode/guidelines/000-critical-rules.md` | Add "skipped" to `critical-rules-sc-lobotomy` prohibition list (lines 719-729) | Explicitly name "skipped" as a CRITICAL VIOLATION |
| `.opencode/guidelines/080-code-standards.md` | Add SC skip prohibition to Test Integrity Mandate §Rule 1 | Mirror the prohibition in code standards |
| `.opencode/skills/spec-creation/tasks/holistic-self-check.md` | Add "skipped" to escape-hatch dimension check (line 37) | Cover agent-behavior escape patterns |
| `.opencode/skills/implementation-pipeline/SKILL.md` | Add SC-count gate step before pre-pr-gate | Structural enforcement of SC completeness |
| `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh` | New behavioral enforcement test | Verify agents do NOT skip SCs |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | `000-critical-rules.md` `critical-rules-sc-lobotomy` explicitly prohibits "skipped" as a distinct evasion pattern alongside removal, weakening, deferral, and reclassification | `string` | `grep -c "skipped" .opencode/guidelines/000-critical-rules.md` returns ≥ 1 in the SC lobotomy section (lines 719-729) | Add "skipped" to the prohibition list text | red-green | `.opencode/.issues/1879/` | Gap 1 — "skipped" is not explicitly named | Phase 1 | pre-commit | standalone | sc-lobotomy-text | red-green | `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh` | Phase 1 |
| SC-2 | `080-code-standards.md` Test Integrity Mandate §Rule 1 includes "skipped" in the prohibited patterns list | `string` | `grep -c "skipped" .opencode/guidelines/080-code-standards.md` returns ≥ 1 in the Test Integrity Mandate section | Add "skipped" to the Test Integrity Mandate prohibited patterns | red-green | `.opencode/.issues/1879/` | Gap 1 — mirror prohibition in code standards | Phase 1 | pre-commit | standalone | sc-lobotomy-text | red-green | `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh` | Phase 1 |
| SC-3 | `holistic-self-check.md` escape-hatch dimension (line 37) includes "skipped" in the agent-behavior escape pattern check | `string` | `grep -c "skipped" .opencode/skills/spec-creation/tasks/holistic-self-check.md` returns ≥ 1 in the escape-hatch dimension section | Add "skipped" to the escape-hatch dimension check text | red-green | `.opencode/.issues/1879/` | Gap 4 — escape-hatch dimension doesn't cover "skipped" | Phase 1 | pre-commit | standalone | sc-lobotomy-text | red-green | `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh` | Phase 1 |
| SC-4 | `implementation-pipeline/SKILL.md` includes an SC-count gate that reads `sc-summary.yaml` total, counts verified SCs, and BLOCKs on mismatch | `string` | `grep -c "sc-summary.yaml" .opencode/skills/implementation-pipeline/SKILL.md` returns ≥ 1 in a gate step context AND `grep -c "verified_count" .opencode/skills/implementation-pipeline/SKILL.md` returns ≥ 1 | Add SC-count gate step to the pipeline | red-green | `.opencode/.issues/1879/` | Gap 2 — no structural SC-count gate | Phase 1 | pre-commit | standalone | sc-count-gate | red-green | `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh` | Phase 1 |
| SC-5 | Behavioral enforcement test `1879-sc-skip-prohibition.sh` exists and verifies agent does NOT skip behavioral SCs when prompted with a spec containing a behavioral SC | `behavioral` | `bash .opencode/tests/behaviors/1879-sc-skip-prohibition.sh` — agent receives real-domain prompt with behavioral SC, agent output evaluated by clean-room semantic inspector via `assert_semantic` | Debug test prompt, increase timeout, verify model availability, re-run | red-green | `.opencode/.issues/1879/behavioral/` | Gap 3 — no behavioral test verifies agents don't skip SCs | Phase 1 | pre-commit | standalone | behavioral-test | red-green | `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh` | Phase 1 |
| SC-6 | Agent reports BLOCKED when it cannot implement an SC, rather than skipping it — verified by behavioral test | `behavioral` | `bash .opencode/tests/behaviors/1879-sc-skip-prohibition.sh` — agent receives prompt with an SC it cannot implement, agent output evaluated by clean-room semantic inspector for BLOCKED report pattern | Debug test prompt, increase timeout, verify model availability, re-run | red-green | `.opencode/.issues/1879/behavioral/` | Gap 3 — agent must report BLOCKED, not skip | Phase 1 | pre-commit | standalone | behavioral-test | red-green | `.opencode/tests/behaviors/1879-sc-skip-prohibition.sh` | Phase 1 |

### Semantic Intent

- **SC-1**: The word "skipped" must appear in the SC lobotomy section specifically — not elsewhere in the file. This verifies the prohibition is in the right context, not just present somewhere in the document.
- **SC-2**: The Test Integrity Mandate mirror is required because `080-code-standards.md` is the code-writing guideline that agents consult during implementation. The prohibition must be present in both the critical rules (enforcement) and code standards (implementation guidance).
- **SC-3**: The holistic-self-check is the pre-completion quality gate for specs. Adding "skipped" to the escape-hatch dimension ensures that future specs are checked for skip-prone language before they reach implementation.
- **SC-4**: The SC-count gate must reference `sc-summary.yaml` (the machine-parseable SC list) and `verified_count` (the count of SCs with verdicts). These are the two data points needed for the mismatch check.
- **SC-5**: The behavioral test must use a real-domain prompt (not prose-recall) per `tests/AGENTS.md` §9. The agent must be given a spec with a behavioral SC and asked to implement it — the test verifies the agent does not skip the SC.
- **SC-6**: The BLOCKED report pattern is the required behavior when an SC cannot be implemented. The agent must report BLOCKED with root cause, not skip the SC silently.

## Edge Cases

| Case | Expected Behavior |
|------|-------------------|
| SC is genuinely impossible to implement (e.g., requires unavailable infrastructure) | Agent reports BLOCKED with root cause and HALT — never skips |
| SC is implemented but verification fails | Agent remediates and re-verifies — never skips |
| SC appears "not applicable" to the agent | Agent reports BLOCKED with root cause — the spec author decided the SC was applicable; the agent does not second-guess the spec |
| SC-count gate fires on a single-task spec with 1 SC | Gate verifies 1 SC has a verdict — no false BLOCKED |
| Behavioral test times out | Agent follows remediation-first protocol: increase timeout, verify model availability, re-run — never skips the test |

## Dependencies

- `000-critical-rules.md` `critical-rules-sc-lobotomy` (lines 719-729) — existing rule to extend
- `080-code-standards.md` Test Integrity Mandate (lines 608-717) — existing rule to extend
- `spec-creation/tasks/holistic-self-check.md` (line 37) — existing dimension to extend
- `implementation-pipeline/SKILL.md` (lines 60-62, 313) — existing pipeline to extend
- `tests/behaviors/helpers.sh` `behavior_run` (line 171) — existing test infrastructure
- `tests/AGENTS.md` §1 Artifact-Only Generator Paradigm — existing test paradigm
- `tests/AGENTS.md` §9 Prompt Construction Mandate — existing prompt construction rules

## Risk

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | Behavioral test is probabilistic — agent may pass on one run and skip on another | Medium | High | Use `behavior_run_pool` with multiple models; semantic inspector evaluates full output | SC-5, SC-6 |
| RISK-2 | SC-count gate may produce false BLOCKED if sc-summary.yaml is stale | Low | Medium | Gate reads sc-summary.yaml at execution time, not from cache | SC-4 |
| RISK-3 | Agent rationalizes "skipped" as "deferred to follow-up issue" — evading the prohibition | Medium | High | Prohibition text explicitly lists "will be handled separately" as a prohibited pattern | SC-1 |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | MUST | Re-run to verify updated prohibition |
| SC-count gate | MUST | Re-verify gate logic against updated sc-summary.yaml |

## Non-Goals

- **Pipeline redesign** — This spec adds a gate to the existing pipeline; it does not redesign the pipeline architecture.
- **Retroactive fix for #1873, #1877, #1878** — Those issues are closed. This spec prevents future occurrences.
- **SC removal authorization workflow** — This spec prohibits skipping; it does not define a workflow for authorized SC removal (that is a separate concern).

## Regression Invariants

- [ ] 1. Existing `critical-rules-sc-lobotomy` enforcement MUST continue to cover removal, weakening, deferral, and reclassification.
- [ ] 2. Existing behavioral tests MUST continue to pass — no existing test assertions may be weakened.
- [ ] 3. Existing pipeline gates (`pre-pr-gate`, `completeness-gate`, `green-vbc`, `green-doublecheck`) MUST continue to function as before.
- [ ] 4. The `1845-sc4-anti-lobotomization.sh` artifact-only generator MUST NOT be modified — it is a separate concern.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -n "critical-rules-sc-lobotomy" .opencode/guidelines/000-critical-rules.md` | Verify existing SC lobotomy rule text and line numbers |
| Direct source search | `grep -n "critical-rules-test-integrity" .opencode/guidelines/000-critical-rules.md` | Verify existing test integrity rule |
| Direct source search | `grep -n "critical-rules-hard-fail" .opencode/guidelines/000-critical-rules.md` | Verify hard failure discipline rule |
| Direct source search | `grep -n "critical-rules-060" .opencode/guidelines/000-critical-rules.md` | Verify functional/behavioral test substitution prohibition |
| Direct source search | `grep -n "Test Integrity Mandate" .opencode/guidelines/080-code-standards.md` | Verify Test Integrity Mandate section |
| Direct source search | `grep -n "Evidence Type Enforcement Matrix" .opencode/guidelines/080-code-standards.md` | Verify evidence type enforcement rules |
| Direct source search | `grep -n "pre-pr-gate\|green-vbc\|green-doublecheck\|completeness-gate" .opencode/skills/implementation-pipeline/SKILL.md` | Verify pipeline gate documentation |
| Direct source search | `grep -n "behavior_run\|behavior_run_pool" .opencode/tests/behaviors/helpers.sh` | Verify behavioral test infrastructure |
| Direct source search | `grep -n "Artifact-Only Generator\|Prompt Construction" .opencode/tests/AGENTS.md` | Verify test paradigm and prompt rules |
| Direct source search | `grep -n "1845-sc4-anti-lobotomization" .opencode/tests/behaviors/` | Verify existing anti-lobotomization test |
| Direct source search | `grep -n "sc-enforcement-gate" .opencode/tests/behaviors/` | Verify existing content-verification tests |
| Direct source search | `grep -n "Escape Hatches\|escape hatch" .opencode/skills/spec-creation/tasks/holistic-self-check.md` | Verify escape-hatch dimension |
| Direct source search | `grep -n "NEVER substitute structural" .opencode/guidelines/020-go-prohibitions.md` | Verify structural substitution prohibition |
| Direct source search | `grep -n "Verification IS completion" .opencode/skills/verification-before-completion/SKILL.md` | Verify VbC identity fusion rule |
| Direct source search | `grep -n "clean-room evaluation" .opencode/skills/verification-before-completion/SKILL.md` | Verify behavioral test evaluation requirement |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1879/plan.md` before implementation begins.

## Related

- [opencode-config#1877](https://github.com/michael-conrad/opencode-config/issues/1877) — The issue where SC-4 was skipped
- [opencode-config#1873](https://github.com/michael-conrad/opencode-config/issues/1873) — Previous defective implementation where behavioral tests were artifact-only generators without evaluation
- [opencode-config#1878](https://github.com/michael-conrad/opencode-config/issues/1878) — PR rejected by developer with "skipped SC => trash => rejected"

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
