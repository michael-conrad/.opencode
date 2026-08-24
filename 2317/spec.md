---
number: 2317
title: "[SPEC-FIX] Audit arbiter false PASS for never-evaluated criteria"
status: open
labels:
- needs-approval
- spec-draft
created: 2026-08-24T15:23:03Z
updated: 2026-08-24T15:23:12Z
remote_issue: 2317
remote_url: "https://github.com/michael-conrad/.opencode/issues/2317"
---

# Spec: Audit arbiter false PASS for never-evaluated criteria

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | A session reported "The Arbiter filled in PASS for criteria that were never evaluated. This is not a clean pass" — an attempt at a false PASS to bypass audit work. The `*-audit-arbiter` task cards aggregate `overall_verdict`/`all_criteria_pass` over ONLY the `per_criterion`/`per_claim` set carried from `verdict.yaml`, so an SC absent from that set (never evaluated) can never fail. The coverage/chain-integrity flags (`coverage_complete`, `chain_complete`) are non-binding and never reach `overall_verdict`. |
| 2 | **Root Cause / Motivation** | All 10 `*-audit-arbiter` cards read `verdict.yaml` and aggregate only over the criteria the evaluator chose to emit. An SC omitted from `verdict.yaml` silently inherits PASS. The `MISSING_SC_COVERAGE`/`BROKEN_EVIDENCE_CHAIN` flags collected in the cross-reference step are advisory — the `do NOT BLOCK` error-table language makes them non-binding. This systemic aggregation defect lets bad deliverables pass audit with a fabricated clean verdict. |
| 3 | **Approach Chosen** | Redefine the aggregate verdict to be computed over the union of the spec SC list and the evaluator's `per_criterion`/`per_claim` set, defaulting any absent SC to FAIL. Add an independent hard flag-gate in every arbiter requiring both `coverage_complete` and `chain_complete` to be true before any aggregate can resolve to PASS — any false flag forces FAIL. Ensure evaluators enumerate the full spec SC list with explicit `NOT_EVALUATED` markers. Bind the FAIL gate structurally into the SKILL.md orchestrator workflow with a mandatory remediate-and-restart loop, making escalation the only exit. |
| 4 | **Alternatives Considered & Why Discarded** | Keeping the aggregation over the carried set and merely tightening the advisory flags was considered and rejected: the flag-gate would remain advisory (relying on the evaluator's cooperation), which is the exact vector a fabricated-PASS entry exploits. A structurally non-waivable flag-gate and union aggregation are required to close the vector. |
| 5 | **Key Design Decisions** | (a) The aggregate MUST be computed over the union of the spec SC list and the evaluated set — this is the only way absent SCs can fail. (b) The flag-gate MUST be independent of evaluator verdicts (computed from the spec SC list vs the three upstream artifacts) so a fabricated PASS cannot satisfy it. (c) The remediate-and-restart loop MUST be a structural workflow step in SKILL.md, not prose, so session momentum cannot skip it. (d) Verification is behavioral-only; static checks are worked around by hacking mode. |
| 6 | **User Intent / Original Prompt** | A session observed the audit arbiter filling in PASS for never-evaluated criteria, and this SPEC-FIX resolves that false-PASS aggregation defect across the audit chain. |

## 2. Not Included

- **Individual audit card content improvements unrelated to the aggregation/coverage defect** — each arbiter is only touched to fix the union aggregation, flag-gate, and advisory-language binding, not for unrelated content quality.
- **Non-audit skill chains** — the change is scoped to the audit skill chain (`*-audit-arbiter`, `*-audit-evaluator`, `audit/SKILL.md`) and the release handshake that consumes the aggregate.
- **Re-architecting the audit DiMo chain** — the producer/verifier separation and artifact format remain; only the aggregation correctness, flag binding, and loop structure change.

## 3. Constraints

| ID | Constraint | Rationale |
|----|-----------|-----------|
| CON-1 | The aggregate verdict SHALL be computed over the union of the spec SC list and the evaluated `per_criterion`/`per_claim` set. | An SC absent from the evaluated set must fail; union is the only mechanism. |
| CON-2 | The flag-gate SHALL be independent of evaluator verdicts — computed from the spec SC list vs the three upstream artifacts, not derivable from `per_criterion` alone. | A fabricated PASS entry cannot satisfy an independently-computed gate. |
| CON-3 | The remediate-and-restart loop SHALL be a structural workflow step in `audit/SKILL.md`, not prose. | Prose guidance can be skipped by session momentum; a structural step cannot. |
| CON-4 | Verification for this fix SHALL be behavioral-only via real `opencode run` audit dispatch; no static coded checks. | Static checks are worked around by hacking mode. |
| CON-5 | Escalation SHALL be the only exit from an unremediable non-clean phase. | Without an escalation exit, an unremediable FAIL loops forever. |

## 4. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The aggregate verdict SHALL be computed over the union of the spec SC list and the evaluator's `per_criterion`/`per_claim` set, with any SC absent from the evaluated set defaulting to FAIL, in all `*-audit-arbiter` cards. | behavioral | Real `opencode run` audit dispatch against a fixture spec; a clean-room sub-agent reads `session.yaml` stderr and confirms an absent SC yields FAIL. | `.opencode/skills/audit/tasks/*-audit-arbiter.md`; plan-fidelity-sc-coverage-gate research card |
| SC-2 | A hard flag-gate SHALL require both `coverage_complete` and `chain_complete` to be true before any aggregate resolves to PASS, computed independently of the evaluator's verdicts; any false flag SHALL force FAIL. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts a coverage-gap yields FAIL via the flag-gate. | `.opencode/skills/audit/tasks/*-audit-arbiter.md` |
| SC-3 | Verification of this fix SHALL be behavioral-only via real `opencode run` audit dispatch with stderr verdict observation; no static coded checks are permitted. | behavioral | Real `opencode run` audit dispatch; `session.yaml` stderr observation via `behavior_run`; clean-room sub-agent evaluation. | `.opencode/tests-v2/AGENTS.md`; `tests-v2/behaviors/` harness |
| SC-4 | Evaluator cards SHALL enumerate the full spec SC list in `per_criterion`/`per_claim`, with no silent omission; skipped SCs SHALL be present with result FAIL + a `NOT_EVALUATED` marker. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts the full SC list is enumerated with `NOT_EVALUATED` markers. | `.opencode/skills/audit/tasks/*-audit-evaluator.md` |
| SC-5 | Any FAIL SHALL be a hard gate: the agent SHALL remediate and re-audit until 100% compliance, with an explicit escalation exit as the only exit from an unremediable FAIL. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts FAIL halts, remediates, re-audits, and escalates only when unremediable. | `.opencode/skills/audit/tasks/*-audit-arbiter.md`, `*-audit-evaluator.md`, `audit/SKILL.md` |
| SC-6 | The `do NOT BLOCK` / `do NOT re-evaluate` error-table language in the arbiter cards SHALL be reconciled so that coverage/chain gaps bind to the FAIL gate rather than being advisory flags. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts a coverage-gap yields FAIL, not an advisory `MISSING_SC_COVERAGE` flag. | `.opencode/skills/audit/tasks/*-audit-arbiter.md` |
| SC-7 | The ticket-status/release handshake SHALL honor the corrected aggregate; a coverage-gap FAIL SHALL keep the ticket unreleased. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts a coverage-gap FAIL blocks release promotion. | `.opencode/skills/release-promoter/tasks/operating-protocol.md`, `tag.md`, `create-release.md`; `git-workflow-cleanup/tasks/cleanup.md` |
| SC-8 | The `audit/SKILL.md` orchestrator SHALL structurally remediate-and-restart the audit at any non-clean phase, iterating until 100% clean, with escalation the only exit, bound as a workflow step not prose. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts the orchestrator remediates-and-restarts at a non-clean phase. | `.opencode/skills/audit/SKILL.md` |

## 5. Requirements

- R-1. The aggregate verdict in each `*-audit-arbiter` card SHALL be computed over the union of the spec SC list and the evaluated `per_criterion`/`per_claim` set.
- R-2. Any SC present in the spec SC list but absent from the evaluated set SHALL default to FAIL, never PASS.
- R-3. Each `*-audit-arbiter` card SHALL compute `coverage_complete` and `chain_complete` flags from the spec SC list vs. the three upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml), independent of the evaluator's verdicts.
- R-4. The aggregate SHALL resolve to PASS only when both `coverage_complete` AND `chain_complete` are true; any false flag SHALL force FAIL.
- R-5. Each `*-audit-evaluator` card SHALL enumerate the full spec SC list in its `per_criterion`/`per_claim` output.
- R-6. A skipped SC SHALL be present in the evaluator output with result FAIL and a `NOT_EVALUATED` marker; it SHALL NOT be silently omitted.
- R-7. Any FAIL verdict SHALL be a hard gate that halts the deliverable until remediation and re-audit achieve 100% compliance.
- R-8. The audit workflow SHALL provide an explicit escalation exit as the only way out of an unremediable FAIL.
- R-9. The `do NOT BLOCK` / `do NOT re-evaluate` error-table language in the arbiter cards SHALL be reconciled so coverage/chain gaps force FAIL rather than being advisory.
- R-10. The ticket-status/release handoff (release-promoter and git-workflow-cleanup) SHALL gate release promotion on the corrected aggregate; a coverage-gap FAIL SHALL keep the ticket unreleased.
- R-11. The `audit/SKILL.md` orchestrator SHALL bind a structural remediate-and-restart loop into its workflow, remediating and re-dispatching the audit at any non-clean phase.
- R-12. Verification of this fix SHALL use behavioral evidence via real `opencode run` audit dispatch; static coded checks SHALL NOT substitute.

## 6. Items

### Item 1 (SC-1): Union-based aggregate across all `*-audit-arbiter` cards

- RED: A behavioral test asserts an absent SC yields FAIL; current arbiters aggregate over the carried set and an absent SC yields PASS.
- GREEN: Redefine the aggregate in each arbiter to compute over the union, defaulting absent SCs to FAIL.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent reads `session.yaml` and confirms absent SC yields FAIL.
- commit: Arbiter aggregation fix across all 10 arbiter cards.

### Item 2 (SC-2): Independent hard flag-gate

- RED: A behavioral test asserts a coverage-gap yields FAIL (currently it yields PASS with an advisory flag).
- GREEN: Add the independent `coverage_complete` AND `chain_complete` flag-gate, forcing FAIL on any false flag.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts the flag-gate forces FAIL on a coverage gap.
- commit: Flag-gate logic in all arbiter cards.

### Item 3 (SC-3): Behavioral-only verification

- RED: Behavioral tests assert the whole audit chain via real `opencode run`; no static check.
- GREEN: Write behavioral test scripts + fixtures in `tests-v2/behaviors/`.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent evaluates `session.yaml`.
- commit: Behavioral test scripts + fixtures.

### Item 4 (SC-4): Evaluator full enumeration

- RED: A behavioral test asserts the full spec SC list appears in the evaluator output.
- GREEN: Modify evaluator cards to enumerate every spec item with `NOT_EVALUATED` markers.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts full enumeration.
- commit: Evaluator enumeration logic.

### Item 5 (SC-5): FAIL as hard gate with escalation exit

- RED: A behavioral test asserts a FAIL halts and does not advance the deliverable.
- GREEN: Enforce FAIL as a hard gate and add the explicit escalation exit.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts FAIL halts and escalation is the only exit.
- commit: Hard-gate and escalation enforcement.

### Item 6 (SC-6): Reconcile advisory language to FAIL gate

- RED: A behavioral test asserts a coverage-gap yields FAIL, not an advisory flag.
- GREEN: Reconcile the `do NOT BLOCK`/`do NOT re-evaluate` language to force FAIL.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts FAIL on coverage gap.
- commit: Advisory-language reconciliation in arbiter error tables.

### Item 7 (SC-7): Release handshake gate

- RED: A behavioral test asserts a coverage-gap FAIL keeps the ticket unreleased.
- GREEN: Gate release promotion (release-promoter, git-workflow-cleanup) on the corrected aggregate.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts coverage-gap FAIL blocks release.
- commit: Release handshake gate.

### Item 8 (SC-8): Orchestrator remediate-and-restart loop

- RED: A behavioral test asserts the orchestrator does NOT remediate-and-restart at a non-clean phase.
- GREEN: Bind a structural remediate-and-restart loop into `audit/SKILL.md`.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts the orchestrator remediates-and-restarts.
- commit: SKILL.md orchestrator loop.

## 7. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Behavioral test harness (`tests-v2/behaviors/`) | Must support real `opencode run` audit dispatch. | Satisfied — existing audit behavioral tests (`2254-sc33-audit-dimo-chain.sh`, `2272-sc1-audit-status-reconciliation.sh`) confirm feasibility. |
| Audit fixture specs (issues 2211, 2272) | Provide fixture specs for behavioral audit dispatch. | Satisfied — fixtures exist. |
| plan-fidelity-sc-coverage-gate research card | Documents the same coverage-gap-as-advisory defect class in plan-fidelity; confirms the union-comparison mechanism. | Satisfied — incorporated. |
| spec-creation reference docs (spec-structure-standards, cost-model-standards) | Define SC table and cost-frame format for the spec body. | Satisfied — read and applied. |

## 8. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-2 | SC-1 | Phase 1 |
| R-3, R-4 | SC-2 | Phase 1 |
| R-12 | SC-3 | Phase 5 |
| R-5, R-6 | SC-4 | Phase 2 |
| R-7, R-8 | SC-5 | Phase 3 |
| R-9 | SC-6 | Phase 1 |
| R-10 | SC-7 | Phase 4 |
| R-11 | SC-8 | Phase 3 |

## 9. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Audit arbiter cards | skill code | `.opencode/skills/audit/tasks/*-audit-arbiter.md` | Read/grep of aggregation logic |
| Audit evaluator cards | skill code | `.opencode/skills/audit/tasks/*-audit-evaluator.md` | Read/grep of `per_criterion` enumeration |
| Audit orchestrator | skill code | `.opencode/skills/audit/SKILL.md` | Read of Mandatory Remediation Procedure |
| Release handshake | skill code | `.opencode/skills/release-promoter/tasks/{operating-protocol,tag,create-release}.md`, `git-workflow-cleanup/tasks/cleanup.md` | Read/grep of release gate |
| Behavioral harness | config/test | `.opencode/tests-v2/AGENTS.md`, `tests-v2/behaviors/` | Existing audit behavioral tests (`2254-sc33`, `2272-sc1`) demonstrate real `opencode run` dispatch |

## 10. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 11. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Computing the union aggregation costs one real audit dispatch. Skipping means an absent SC ships as PASS, and a fabricated clean verdict lets a bad deliverable through — the exact defect this spec fixes.
- **SC-2:** Adding the independent flag-gate costs one real audit dispatch. Skipping means a coverage-gap yields PASS, silently accepting an unaudited deliverable.
- **SC-3:** Running the behavioral verification costs minutes of execution. Skipping means the fix is unverified and a false PASS ships — an EVIDENCE_TYPE_MISMATCH that masks the very defect under repair.
- **SC-4:** Enumerating the full SC list costs one real audit dispatch. Skipping means a silently-omitted SC inherits PASS — the vector that lets never-evaluated criteria pass.
- **SC-5:** Enforcing FAIL as a hard gate costs one real audit dispatch. Skipping means a bad deliverable advances to review/merge before the audit defect is found.
- **SC-6:** Reconciling advisory language costs one real audit dispatch. Skipping means the coverage gap is reported as an advisory flag, still letting the unaudited deliverable through.
- **SC-7:** Gating release on the aggregate costs one real audit dispatch. Skipping means a coverage-gap FAIL is released to the ticket, shipping an unaudited change.
- **SC-8:** Binding the remediate-and-restart loop costs one real audit dispatch. Skipping means a session-momentum skip leaves the audit non-clean and the deliverable advancing anyway.

## 12. Edge Cases

- **Absent SC (input boundary):** An SC in the spec list absent from `verdict.yaml` MUST resolve to FAIL with a `NOT_EVALUATED` marker, never PASS.
- **Coverage gap (flag-gate):** If `coverage_complete` is false (an SC not covered by any evaluator), the aggregate MUST be FAIL regardless of evaluator verdicts.
- **Broken evidence chain (flag-gate):** If `chain_complete` is false, the aggregate MUST be FAIL.
- **Skipped SC (evaluator):** An evaluator that skips a spec item MUST emit it as FAIL + `NOT_EVALUATED`, not omit it.
- **Unremediable FAIL (orchestrator):** If remediation cannot achieve 100% compliance, the orchestrator MUST escalate — the explicit exit, never an infinite loop.
- **Release handshake (release):** A coverage-gap FAIL MUST keep the ticket unreleased; release promotion only proceeds on a clean aggregate.
- **Behavioral test not executable:** If `opencode run` cannot run, the SC is FAIL — no static/string substitution is permitted (EVIDENCE_TYPE_MISMATCH).

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
