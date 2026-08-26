---
number: 2317
title: "[SPEC-FIX] Audit arbiter false PASS for never-evaluated criteria"
status: open
labels:
- needs-approval
- spec-draft
created: 2026-08-24T15:23:03Z
updated: 2026-08-26T03:23:30Z
remote_issue: 2317
remote_url: "https://github.com/michael-conrad/.opencode/issues/2317"
---

# Spec: Audit arbiter false PASS for never-evaluated criteria

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | A session reported "The Arbiter filled in PASS for criteria that were never evaluated. This is not a clean pass" — an attempt at a false PASS to bypass audit work. The `*-audit-arbiter` task cards aggregate `overall_verdict`/`all_criteria_pass` over ONLY the `per_criterion`/`per_claim` set carried from `verdict.yaml`, so an SC absent from that set (never evaluated) can never fail. The coverage/chain-integrity flags (`coverage_complete`, `chain_complete`) are non-binding and never reach `overall_verdict`. |
| 2 | **Root Cause / Motivation** | All `*-audit-arbiter` cards read `verdict.yaml` and aggregate only over the criteria the evaluator chose to emit. An SC omitted from `verdict.yaml` silently inherits PASS. The `MISSING_SC_COVERAGE`/`BROKEN_EVIDENCE_CHAIN` flags collected in the cross-reference step are advisory — the `do NOT BLOCK` error-table language makes them non-binding. This systemic aggregation defect lets bad deliverables pass audit with a fabricated clean verdict. |
| 3 | **Approach Chosen** | Redefine the aggregate verdict to be computed over the union of the spec SC list and the evaluator's `per_criterion`/`per_claim` set, defaulting any absent SC to FAIL. Add an independent hard flag-gate in every arbiter requiring both `coverage_complete` and `chain_complete` to be true before any aggregate can resolve to PASS — any false flag forces FAIL. Ensure evaluators enumerate the full spec SC list with explicit `NOT_EVALUATED` markers. Bind the FAIL gate structurally into the SKILL.md orchestrator workflow with a mandatory remediate-and-restart loop, making escalation the only exit. |
| 4 | **Alternatives Considered & Why Discarded** | Keeping the aggregation over the carried set and merely tightening the advisory flags was considered and rejected: the flag-gate would remain advisory (relying on the evaluator's cooperation), which is the exact vector a fabricated-PASS entry exploits. A structurally non-waivable flag-gate and union aggregation are required to close the vector. |
| 5 | **Key Design Decisions** | (a) The aggregate MUST be computed over the union of the spec SC list and the evaluated set — this is the only way absent SCs can fail. (b) The flag-gate MUST be independent of evaluator verdicts (computed from the spec SC list vs the three upstream artifacts) so a fabricated PASS cannot satisfy it. (c) The remediate-and-restart loop MUST be a structural workflow step in SKILL.md, not prose, so session momentum cannot skip it. (d) Verification is behavioral-only; static checks are worked around by hacking mode. |
| 6 | **User Intent / Original Prompt** | A session observed the audit arbiter filling in PASS for never-evaluated criteria, and this SPEC-FIX resolves that false-PASS aggregation defect across the audit chain. |

## 2. Not Included

- **Individual audit card content improvements unrelated to the aggregation/coverage defect** — each arbiter is only touched to fix the union aggregation, flag-gate, and advisory-language binding, not for unrelated content quality.
- **Non-audit skill chains** — the change is scoped to the audit skill chain (`*-audit-arbiter`, `*-audit-evaluator`, `audit/SKILL.md`) and the release handshake, where Item 10 adds the missing aggregate-consumption gate logic (a live keyword scan on 2026-08-25 confirms none of the four named handshake files currently reads the audit aggregate).
- **Re-architecting the audit DiMo chain** — the producer/verifier separation and artifact format remain; only the aggregation correctness, flag binding, and loop structure change.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The aggregate verdict in each `*-audit-arbiter` card SHALL be computed over the union of the spec SC list and the evaluator's `per_criterion`/`per_claim` set, with any SC absent from the evaluated set defaulting to FAIL. | behavioral | Real `opencode run` audit dispatch against a fixture spec; a clean-room sub-agent reads `session.yaml` stderr and confirms an absent SC yields FAIL. | `.opencode/skills/audit/tasks/*-audit-arbiter.md`; plan-fidelity-sc-coverage-gate research card |
| SC-2 | A hard flag-gate SHALL require both `coverage_complete` and `chain_complete` to be true before any aggregate resolves to PASS, computed independently of the evaluator's verdicts; any false flag SHALL force FAIL. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts a coverage-gap yields FAIL via the flag-gate. | `.opencode/skills/audit/tasks/*-audit-arbiter.md` |
| SC-3 | Verification of this fix SHALL be behavioral-only via real `opencode run` audit dispatch with stderr verdict observation; no static coded checks are permitted. | behavioral | Real `opencode run` audit dispatch; `session.yaml` stderr observation via `behavior_run`; clean-room sub-agent evaluation. | `.opencode/tests-v2/AGENTS.md`; `tests-v2/behaviors/` harness |
| SC-4 | Each `*-audit-evaluator` card SHALL enumerate the full spec SC list in its `per_criterion`/`per_claim` output, with no silent omission. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts the full spec SC list appears in the evaluator output. | `.opencode/skills/audit/tasks/*-audit-evaluator.md` |
| SC-5 | A skipped SC SHALL be present in the evaluator output with result FAIL and a `NOT_EVALUATED` marker; it SHALL NOT be silently omitted. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts a skipped SC appears as FAIL with a `NOT_EVALUATED` marker. | `.opencode/skills/audit/tasks/*-audit-evaluator.md` |
| SC-6 | Any FAIL verdict SHALL be a hard gate that halts the deliverable until remediation. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts a FAIL verdict halts the deliverable and does not advance it. | `.opencode/skills/audit/tasks/*-audit-arbiter.md`, `*-audit-evaluator.md`, `audit/SKILL.md` |
| SC-7 | The agent SHALL remediate and re-audit until 100% compliance as defined in R-13. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts the agent remediates and re-audits after a FAIL until the R-13 termination condition holds. | `.opencode/skills/audit/tasks/*-audit-arbiter.md`, `*-audit-evaluator.md`, `audit/SKILL.md` |
| SC-8 | An explicit escalation SHALL be the only exit from an unremediable FAIL. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts escalation is the only exit from an unremediable FAIL (no infinite loop). | `.opencode/skills/audit/tasks/*-audit-arbiter.md`, `*-audit-evaluator.md`, `audit/SKILL.md` |
| SC-9 | The `do NOT BLOCK` / `do NOT re-evaluate` error-table language in the arbiter cards SHALL be reconciled so that coverage/chain gaps bind to the FAIL gate rather than being advisory flags. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts a coverage-gap yields FAIL, not an advisory `MISSING_SC_COVERAGE` flag. | `.opencode/skills/audit/tasks/*-audit-arbiter.md` |
| SC-10 | The ticket-status/release handshake files SHALL be extended with NEW gate logic consuming the corrected audit aggregate — no such consumption exists today (live keyword scan, 2026-08-25, returned zero verdict/aggregate tokens) — such that a coverage-gap FAIL keeps the ticket unreleased. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts a coverage-gap FAIL blocks release promotion through the newly added gate. | `.opencode/skills/release-promoter/tasks/operating-protocol.md`, `tag.md`, `create-release.md`; `git-workflow-cleanup/tasks/cleanup.md` |
| SC-11 | The `audit/SKILL.md` orchestrator SHALL structurally remediate-and-restart the audit at any non-clean phase. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts the orchestrator remediates-and-restarts at a non-clean phase. | `.opencode/skills/audit/SKILL.md` |
| SC-12 | The orchestrator remediate-and-restart loop SHALL iterate until 100% clean as defined in R-13. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts the orchestrator iterates the loop until the R-13 termination condition holds (the audit is 100% clean). | `.opencode/skills/audit/SKILL.md` |
| SC-13 | Escalation SHALL be the only exit from an unremediable non-clean phase in the orchestrator workflow. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts the orchestrator escalates as the only exit from an unremediable non-clean phase. | `.opencode/skills/audit/SKILL.md` |
| SC-14 | The remediate-and-restart loop SHALL be bound as a structural workflow step in `audit/SKILL.md`, not prose. | behavioral | Real `opencode run` audit dispatch; clean-room sub-agent asserts the loop is a structural workflow step (dispatch gate), not prose guidance. | `.opencode/skills/audit/SKILL.md` |

## 4. Requirements

### Requirements

- R-1. The aggregate verdict in each `*-audit-arbiter` card SHALL be computed over the union of the spec SC list and the evaluated `per_criterion`/`per_claim` set.
- R-2. Any SC present in the spec SC list but absent from the evaluated set SHALL default to FAIL, never PASS.
- R-3. Each `*-audit-arbiter` card SHALL compute `coverage_complete` and `chain_complete` flags from the spec SC list vs. the three upstream artifacts (evidence.yaml, reasoning.yaml, verdict.yaml), independent of the evaluator's verdicts.
- R-4. The aggregate SHALL resolve to PASS only when both `coverage_complete` AND `chain_complete` are true; any false flag SHALL force FAIL.
- R-5. Each `*-audit-evaluator` card SHALL enumerate the full spec SC list in its `per_criterion`/`per_claim` output.
- R-6. A skipped SC SHALL be present in the evaluator output with result FAIL and a `NOT_EVALUATED` marker; it SHALL NOT be silently omitted.
- R-7. Any FAIL verdict SHALL be a hard gate that halts the deliverable until remediation and re-audit achieve 100% compliance (termination condition defined in R-13).
- R-8. The audit workflow SHALL provide an explicit escalation exit as the only way out of an unremediable FAIL.
- R-9. The `do NOT BLOCK` / `do NOT re-evaluate` error-table language in the arbiter cards SHALL be reconciled so coverage/chain gaps force FAIL rather than being advisory.
- R-10. The ticket-status/release handoff files (release-promoter tasks and git-workflow-cleanup cleanup.md), which today contain NO logic consuming the audit aggregate — a live keyword scan on 2026-08-25 returned zero verdict/aggregate/coverage tokens in `operating-protocol.md`, `tag.md`, and `create-release.md`, and only an unrelated behavioral-artifact-cleanup mention in `cleanup.md` — SHALL be extended with new gate logic so release promotion is gated on the corrected aggregate; a coverage-gap FAIL SHALL keep the ticket unreleased.
- R-11. The `audit/SKILL.md` orchestrator SHALL bind a structural remediate-and-restart loop into its workflow, remediating and re-dispatching the audit at any non-clean phase.
- R-12. Verification of this fix SHALL use behavioral evidence via real `opencode run` audit dispatch; static coded checks SHALL NOT substitute.
- R-13. Operational definition of loop termination: "100% compliance" and "100% clean" mean that, within a single audit dispatch, every success criterion in the audited spec's SC list has resolved to PASS under the R-1/R-2 union aggregation AND the R-3/R-4 flag-gate holds (`coverage_complete` = true AND `chain_complete` = true) — equivalently, the arbiter's aggregate verdict is PASS with zero criteria FAIL or NOT_EVALUATED. SC-7 and SC-12 iterate remediate-and-re-audit / remediate-and-restart cycles until this condition is first satisfied.

### Constraints

| ID | Constraint | Rationale |
|----|-----------|-----------|
| CON-1 | The aggregate verdict SHALL be computed over the union of the spec SC list and the evaluated `per_criterion`/`per_claim` set. | An SC absent from the evaluated set must fail; union is the only mechanism. |
| CON-2 | The flag-gate SHALL be independent of evaluator verdicts — computed from the spec SC list vs the three upstream artifacts, not derivable from `per_criterion` alone. | A fabricated PASS entry cannot satisfy an independently-computed gate. |
| CON-3 | The remediate-and-restart loop SHALL be a structural workflow step in `audit/SKILL.md`, not prose. | Prose guidance can be skipped by session momentum; a structural step cannot. |
| CON-4 | Verification for this fix SHALL be behavioral-only via real `opencode run` audit dispatch; no static coded checks. | Static checks are worked around by hacking mode. |
| CON-5 | Escalation SHALL be the only exit from an unremediable non-clean phase. | Without an escalation exit, an unremediable FAIL loops forever. |

## 5. Items

### Item 1 (SC-1): Union-based aggregate across all `*-audit-arbiter` cards

- RED: A behavioral test asserts an absent SC yields FAIL; current arbiters aggregate over the carried set and an absent SC yields PASS.
- GREEN: Redefine the aggregate in each arbiter to compute over the union, defaulting absent SCs to FAIL.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent reads `session.yaml` and confirms absent SC yields FAIL.
- commit: Arbiter aggregation fix across all `*-audit-arbiter` cards.

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
- GREEN: Modify evaluator cards to enumerate every spec SC in `per_criterion`/`per_claim` output.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts full enumeration.
- commit: Evaluator enumeration logic.

### Item 5 (SC-5): `NOT_EVALUATED` marker enforcement

- RED: A behavioral test asserts a skipped SC is silently omitted (currently it is omitted from evaluator output).
- GREEN: Emit every skipped SC with result FAIL and a `NOT_EVALUATED` marker; never silently omit.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts a skipped SC appears as FAIL + `NOT_EVALUATED`.
- commit: Evaluator `NOT_EVALUATED` marker logic.

### Item 6 (SC-6): FAIL as hard gate

- RED: A behavioral test asserts a FAIL does not halt the deliverable (currently it advances).
- GREEN: Enforce FAIL as a hard gate that halts the deliverable until remediation.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts FAIL halts the deliverable.
- commit: Hard-gate enforcement.

### Item 7 (SC-7): Remediate-and-re-audit until 100% compliance

- RED: A behavioral test asserts the agent does not re-audit after a FAIL.
- GREEN: Enforce remediation followed by re-audit until the R-13 termination condition holds (100% compliance).
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts the agent remediates and re-audits until the R-13 condition is satisfied.
- commit: Remediate-and-re-audit loop enforcement.

### Item 8 (SC-8): Escalation as the only exit

- RED: A behavioral test asserts an unremediable FAIL has no explicit exit (it loops or advances).
- GREEN: Add an explicit escalation exit as the only way out of an unremediable FAIL.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts escalation is the only exit.
- commit: Escalation exit enforcement.

### Item 9 (SC-9): Reconcile advisory language to FAIL gate

- RED: A behavioral test asserts a coverage-gap yields FAIL, not an advisory flag.
- GREEN: Reconcile the `do NOT BLOCK`/`do NOT re-evaluate` language to force FAIL.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts FAIL on coverage gap.
- commit: Advisory-language reconciliation in arbiter error tables.

### Item 10 (SC-10): Release handshake gate

- RED: A behavioral test asserts release promotion proceeds despite a coverage-gap FAIL — today nothing in the release handoff reads the audit aggregate, so no gate can block it.
- GREEN: ADD new gate logic in release-promoter (`operating-protocol.md`, `tag.md`, `create-release.md`) and git-workflow-cleanup (`cleanup.md`) that consumes the corrected aggregate and blocks promotion on any non-clean verdict.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts coverage-gap FAIL blocks release via the newly added gate.
- commit: Release handshake gate (new aggregate-consumption logic).

### Item 11 (SC-11): Structural remediate-and-restart loop

- RED: A behavioral test asserts the orchestrator does NOT remediate-and-restart at a non-clean phase.
- GREEN: Bind a structural remediate-and-restart loop into `audit/SKILL.md` at the point of any non-clean phase.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts the orchestrator remediates-and-restarts.
- commit: SKILL.md orchestrator loop.

### Item 12 (SC-12): Iterate until 100% clean

- RED: A behavioral test asserts the orchestrator loop does not iterate until clean (it stops at a non-clean phase).
- GREEN: Make the orchestrator loop iterate until the R-13 termination condition holds (the audit is 100% clean).
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts the loop iterates until the R-13 condition is satisfied.
- commit: Orchestrator loop iteration enforcement.

### Item 13 (SC-13): Orchestrator escalation exit

- RED: A behavioral test asserts an unremediable non-clean phase has no escalation exit.
- GREEN: Add escalation as the only exit from an unremediable non-clean phase in the orchestrator workflow.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts escalation is the only orchestrator exit.
- commit: Orchestrator escalation exit enforcement.

### Item 14 (SC-14): Bind loop as workflow step not prose

- RED: A behavioral test asserts the remediate-and-restart loop exists only as prose guidance in SKILL.md.
- GREEN: Bind the loop as a structural workflow step (dispatch gate) in `audit/SKILL.md`, not prose.
- verify: Real `opencode run` audit dispatch; clean-room sub-agent asserts the loop is a structural workflow step.
- commit: SKILL.md structural loop binding.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Behavioral test harness (`tests-v2/behaviors/`) | Must support real `opencode run` audit dispatch. | Satisfied — existing audit behavioral tests (`2254-sc33-audit-dimo-chain.sh`, `2272-sc1-audit-status-reconciliation.sh`) confirm feasibility. |
| Audit fixture specs (issues 2211, 2272) | Provide fixture specs for behavioral audit dispatch. | Satisfied — fixtures exist. |
| plan-fidelity-sc-coverage-gate research card | Documents the same coverage-gap-as-advisory defect class in plan-fidelity; confirms the union-comparison mechanism. | Satisfied — incorporated. |
| spec-creation reference docs (spec-structure-standards, cost-model-standards) | Define SC table and cost-frame format for the spec body. | Satisfied — read and applied. |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1, R-2 | SC-1 | Phase 1 |
| R-3, R-4 | SC-2 | Phase 1 |
| R-12 | SC-3 | Phase 5 |
| R-5 | SC-4 | Phase 2 |
| R-6 | SC-5 | Phase 2 |
| R-7 | SC-6, SC-7 | Phase 3 |
| R-8 | SC-8 | Phase 3 |
| R-9 | SC-9 | Phase 1 |
| R-10 | SC-10 | Phase 4 |
| R-11 | SC-11, SC-12, SC-13, SC-14 | Phase 3 |
| R-13 | SC-7, SC-12 | Phase 3 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Audit arbiter cards | skill code | `.opencode/skills/audit/tasks/*-audit-arbiter.md` | Read/grep of aggregation logic |
| Audit evaluator cards | skill code | `.opencode/skills/audit/tasks/*-audit-evaluator.md` | Read/grep of `per_criterion` enumeration |
| Audit orchestrator | skill code | `.opencode/skills/audit/SKILL.md` | Read of Mandatory Remediation Procedure |
| Release handshake | skill code | `.opencode/skills/release-promoter/tasks/{operating-protocol,tag,create-release}.md`, `git-workflow-cleanup/tasks/cleanup.md` | Live grep 2026-08-25: zero verdict/aggregate/coverage tokens in all three release-promoter tasks; `cleanup.md` matches only an unrelated behavioral-artifact-cleanup line (L198) — Item 10 adds the gate |
| Behavioral harness | config/test | `.opencode/tests-v2/AGENTS.md`, `tests-v2/behaviors/` | Existing audit behavioral tests (`2254-sc33`, `2272-sc1`) demonstrate real `opencode run` dispatch |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Computing the union aggregation costs one real audit dispatch. Skipping means an absent SC ships as PASS, and a fabricated clean verdict lets a bad deliverable through — the exact defect this spec fixes.
- **SC-2:** Adding the independent flag-gate costs one real audit dispatch. Skipping means a coverage-gap yields PASS, silently accepting an unaudited deliverable.
- **SC-3:** Running the behavioral verification costs minutes of execution. Skipping means the fix is unverified and a false PASS ships — an EVIDENCE_TYPE_MISMATCH that masks the very defect under repair.
- **SC-4:** Enumerating the full spec SC list costs one real audit dispatch. Skipping means a silently-omitted SC inherits PASS — the vector that lets never-evaluated criteria pass.
- **SC-5:** Emitting a skipped SC as FAIL + `NOT_EVALUATED` costs one real audit dispatch. Skipping means a skipped SC is silently omitted and inherits PASS.
- **SC-6:** Enforcing FAIL as a hard gate costs one real audit dispatch. Skipping means a bad deliverable advances to review/merge before the audit defect is found.
- **SC-7:** Remediating and re-auditing until the R-13 termination condition costs one real audit dispatch. Skipping means a partially-fixed deliverable is accepted as complete.
- **SC-8:** Adding the escalation exit costs one real audit dispatch. Skipping means an unremediable FAIL has no exit and loops forever.
- **SC-9:** Reconciling advisory language costs one real audit dispatch. Skipping means the coverage gap is reported as an advisory flag, still letting the unaudited deliverable through.
- **SC-10:** Gating release on the aggregate costs one real audit dispatch. Skipping means a coverage-gap FAIL is released to the ticket, shipping an unaudited change.
- **SC-11:** Structurally remediating-and-restarting at a non-clean phase costs one real audit dispatch. Skipping means the audit stays non-clean and the deliverable advances anyway.
- **SC-12:** Iterating the loop until the R-13 termination condition costs one real audit dispatch. Skipping means a non-clean audit is accepted as complete.
- **SC-13:** Binding escalation as the only orchestrator exit costs one real audit dispatch. Skipping means an unremediable non-clean phase has no exit.
- **SC-14:** Binding the loop as a structural workflow step costs one real audit dispatch. Skipping means a session-momentum skip leaves the loop unexecuted.

## 11. Edge Cases

- **Absent SC (input boundary):** An SC in the spec list absent from `verdict.yaml` MUST resolve to FAIL with a `NOT_EVALUATED` marker, never PASS.
- **Coverage gap (flag-gate):** If `coverage_complete` is false (an SC not covered by any evaluator), the aggregate MUST be FAIL regardless of evaluator verdicts.
- **Broken evidence chain (flag-gate):** If `chain_complete` is false, the aggregate MUST be FAIL.
- **Skipped SC (evaluator):** An evaluator that skips a spec item MUST emit it as FAIL + `NOT_EVALUATED`, not omit it.
- **Unremediable FAIL (orchestrator):** If remediation cannot reach the R-13 termination condition, the orchestrator MUST escalate — the explicit exit, never an infinite loop.
- **Release handshake (release):** A coverage-gap FAIL MUST keep the ticket unreleased; release promotion only proceeds on a clean aggregate.
- **Behavioral test not executable:** If `opencode run` cannot run, the SC is FAIL — no static/string substitution is permitted (EVIDENCE_TYPE_MISMATCH).

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-24 | Decomposed compound SCs into atomic sub-SCs (SC count 8 → 14). Split SC-4 → SC-4/SC-5; SC-5 → SC-6/SC-7/SC-8; SC-8 → SC-11/SC-12/SC-13/SC-14. Updated Items, Traceability, sc-summary.yaml, and Cost Frame to match. Aligned section numbering with canonical ordering (Cost Frame at §10, Edge Cases at §11) by folding Constraints into the Requirements section. | Compound-SC structure validation FAIL; section-numbering format-drift warning. | spec-creation revise pipeline |
| 2026-08-24 | Corrected the unsupported arbiter card count: replaced "all 10 `*-audit-arbiter` cards" and "all 10 arbiter cards" with the accurate `*-audit-arbiter` wildcard reference (live verification, restated 2026-08-25 under the explicit glob frame: wildcard glob `*-audit-arbiter.md` returns 5 arbiter cards; a broader `-arbiter.md` suffix scan additionally returns 7 coordination arbiter cards outside the audited set, totaling 12). Restored the missing analytical artifacts directory (7 artifacts: blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) into `.opencode/.issues/2317/artifacts/`. | Re-validation FAIL (factual provenance: incorrect arbiter card count) and warning (missing analytical artifacts directory). | spec-creation revise pipeline |
| 2026-08-26 | Remediated spec-audit DRAFT verdict (tmp/issue-2317/artifacts/spec-audit/verdict.yaml, judgment.yaml): (1) Completeness FAIL — added R-13 operationally defining "100% compliance"/"100% clean" (union-aggregate PASS with both flags true, zero criteria FAIL or NOT_EVALUATED, within a single audit dispatch) and anchored SC-7, SC-12, R-7, Items 7/12, Cost Frame SC-7/SC-12, and Edge Cases to it; added traceability row R-13 → SC-7, SC-12. (2) Provenance FAIL finding 1 — restated Change Control row 2's arbiter-count claim under the explicit glob frame, re-verified live (`*-audit-arbiter.md` = 5; `-arbiter.md` suffix scan = 12 incl. 7 coordination cards outside the audited set). (3) Provenance FAIL finding 2 — revised R-10, SC-10, Item 10, §2 Not Included, and §8 Documentation Sources to scope the release handshake as NEW aggregate-consumption gate logic, recording live keyword-scan evidence that no handshake file currently reads the audit aggregate. No success criteria weakened or removed; SC count remains 14. | Spec-audit DRAFT verdict — Holistic dimension 3 (Completeness) and dimension 7 (Provenance) FAIL remediation. | spec-creation revise pipeline (spec-audit DRAFT remediation) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
