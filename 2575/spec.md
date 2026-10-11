---
number: 2575
title: "[REGRESSION] Spec validation lost the automatic-fail rule — any audit finding must force revision and re-audit until clean"
state: OPEN
labels: [needs-approval, bug, spec]
---

# [REGRESSION] Spec validation lost the automatic-fail rule — any audit finding must force revision and re-audit until clean

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The deck's spec-validation discipline has lost the automatic-fail rule. The pre-rip evaluator failed every criterion by default — a clean PASS required evidence with "no caveats, concerns, or notes", "no INCONCLUSIVE, no 'PASS with concerns'", and any check failure failed the aggregate — and the old audit loop repeated remediate → re-audit until clean. The rebuilt validation path passes a spec when none of seven enumerated defect classes is present, lets the reviewer suppress substantive observations, and caps remediation at one loop. Observed 2026-10-10: the on-demand audit of .opencode#2563 returned PASS while its reviewer disclosed a factual imprecision as a "non-finding observation". |
| 2 | **Root Cause / Motivation** | The #2490 rip-and-replace retired the old audit machinery wholesale; the #2550 restoration rebuilt the validation criteria but re-admitted only a defect-class taxonomy with an anti-churn binding and a one-bounded-loop cap — the automatic-fail consequence and the iterate-to-clean loop were not restored. |
| 3 | **Approach Chosen** | Amend the two files that carry the validation semantics — `.opencode/skills/spec/references/validation-standards.md` (Verdict contract + loop section) and `.opencode/skills/spec/SKILL.md` §6 (validate step) — restoring the zero-findings PASS bar, the automatic FAIL on any reported finding, the abolition of the non-finding-note disclosure path for substantive observations, and the revise → re-audit loop repeating until zero findings, with escalation when the audit cannot reach a zero-finding verdict by revision. Record the restoration in the deck-debt ledger. |
| 4 | **Alternatives Considered & Why Discarded** | (a) Restoring the old DiMo chain (Investigator → Validator → Evaluator → Arbiter with YAML artifact hand-offs) verbatim — discarded: the single-fresh-context-reviewer model is the #2550 restoration's deliberate shape; this item changes the verdict semantics and the loop, not the dispatch topology. (b) Extending the automatic-fail rule to the `verify` card's deliverable-review loop — discarded: that loop governs a different moment (post-implementation deliverable verification) with its own re-review rule; changing it is unrequested scope. (c) Deleting the anti-churn binding so reviewers must report everything including style — discarded: the reporting-layer filter is deliberate (style preferences are not findings); the regression was the missing automatic-fail consequence and the non-finding-note dodge, not the filter. (d) A behavioral enforcement test that an audit reviewer forced-FAILs on a disclosed note — discarded: the rule is intent-decidable in operation (judgment decides what is a finding); a scripted check on it would repeat the deck's founding defect; the structural SCs make the text falsifiable and every future audit applies it by judgment. |
| 5 | **Key Design Decisions** | (1) "Finding" is defined by the reviewer's report: anything the reviewer articulates as a correction, imprecision, factual error, or gap affecting the artifact's correctness or stated requirements — the seven defect classes remain the taxonomy for criterion defects but are not exhaustive. (2) The anti-churn binding is retained: style, ceremony, and imagined requirements are not findings — the regression was the PASS-despite-disclosed-finding, not the filter. (3) The loop terminates on a zero-finding verdict; escalation to the developer fires when the audit cannot reach a zero-finding verdict by revision — a finding persists after genuine remediation, or findings continue to surface across iterations without converging — replacing the fixed one-round cap; escalation and the clean PASS are the loop's only exits. (4) The amended bar governs both spec validation (spec card §6) and on-demand spec audits (the same criteria source is restated verbatim at every audit). (5) The non-finding-note disclosure path is abolished: a reviewer holding a substantive observation reports it as a finding. |
| 6 | **User Intent / Original Prompt** | "regression from old deck: any finding is an automatic fail requiring revision and re-auditing - file a regression bug fix spec; revise the spec based on findings. re-audit and revise until 100% clean." |

## 2. Not Included

- **The `verify` card's deliverable-review loop** — post-implementation verification has its own re-review rule; this item restores spec-validation discipline only (Alternative (b)).
- **The old DiMo dispatch topology** — the single-fresh-context-reviewer model stays (Alternative (a)).
- **Behavioral enforcement tests** — intent-decidable rule; structural text SCs are the evidence (Alternative (d)).
- **Changes to `floor.md` or `routing.md`** — routing already lands spec authoring/revision — and the validation those flows require — on the spec card; an on-demand spec audit of a prior spec restates the same criteria source per the validation-standards reference's criteria-invariance section, so no routing entry is needed for this item.
- **A standing retroactive re-audit mandate for window specs** — the #2550 admission ruled window specs forward-only; this item does not reopen that decision. The #2563 re-audit executed on 2026-10-10 was a direct developer directive in the filing session (the observed failure's remediation), not a retroactive sweep.

## 3. Success Criteria

All structural (card text and ledger state are file facts). RED states verified against the live deck on 2026-10-10.

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `validation-standards.md`'s Verdict contract states the automatic-fail rule with all three elements: (a) PASS is returned only when the reviewer reports zero findings, with no caveats, concerns, or notes attached to any criterion's verdict; (b) any reported finding — an enumerated defect class or any other correction, imprecision, factual error, or gap affecting correctness or the stated requirements — produces FAIL, and the verdict names each finding and its ground; (c) a substantive observation about the artifact is always reported as a finding — the non-finding-note disclosure path no longer exists. | structural | Inspect the Verdict contract for the three elements; each must be present and unambiguous |
| SC-2 | `validation-standards.md`'s loop section states: the revise → re-audit cycle repeats until a verdict with zero findings; each iteration revises the named findings in the artifact in place; escalation to the developer fires only when the audit cannot reach a zero-finding verdict by revision — a finding persists after genuine remediation, or findings continue to surface across iterations without converging — and the escalation carries the specific findings, their root cause, and what is needed; findings are never negotiated away — revision genuinely fixes each one. | structural | Inspect the loop section for all properties: the repeat-until-zero-findings termination, the in-place revision, the escalation trigger (both forms) and payload, and the no-negotiation clause; the one-bounded-loop cap text is gone |
| SC-3 | The `spec` card's validate step (§6) states loop semantics consistent with the amended standards — the validation loop repeats until zero findings — and carries no one-round-cap or persists-then-halt language contradicting it. | structural | Inspect §6 for the consistent loop statement and the absence of contradicting cap language |
| SC-4 | The deck-debt ledger (.opencode#2534) records this restoration: the old rule text and its source (attic spec-audit-evaluator), the #2490 retirement, the observed failure (2026-10-10 #2563 audit PASS with disclosed imprecision), and the placement decisions. | structural | Inspect the ledger issue's comments for the admission entry |

### Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1 through SC-3: each is a read of an edited deck file — one read each. Skipping one means every future spec validation runs on a bar that passes specs carrying disclosed, unfixed defects — the exact failure observed on 2026-10-10.
- SC-4: one ledger read. Skipping it breaks the governance chain the admission gate requires — the next auditor cannot distinguish a deliberate bar from a lost rule.

## 4. Requirements

- R-1. A reviewer-reported finding of any kind in a spec validation or on-demand spec audit SHALL produce a FAIL verdict naming each finding and its ground.
- R-2. A PASS SHALL be returned only on a verdict with zero findings and no caveats, concerns, or notes attached to any criterion's verdict.
- R-3. The reviewer SHALL report every substantive observation — one affecting the artifact's correctness or the stated requirements — as a finding; disclosing a substantive observation as a non-finding note SHALL NOT occur.
- R-4. The revise → re-audit cycle SHALL repeat until a zero-finding verdict; each iteration SHALL remediate the named findings in the artifact in place, and findings SHALL NOT be negotiated away.
- R-5. Escalation to the developer SHALL fire only when the audit cannot reach a zero-finding verdict by revision — a finding persists after genuine remediation, or findings continue to surface across iterations without converging — and SHALL carry the specific findings, their root cause, and what is needed to resolve.
- R-6. The deck-debt ledger SHALL record this restoration's provenance and placement decisions.

## 5. Phases and Items

Single phase — all four items are deck-governance edits under the skill-creator admission gate (observed failure: the 2026-10-10 #2563 audit outcome; consumers: every spec validator and on-demand spec auditor; mechanism: the verdict contract every dispatch restates verbatim; predicate classification: intent-decidable, judgment-only; root-agnostic; replaces the one-bounded-loop cap and the defect-only PASS bar within the same files — net-zero; no always-loaded-surface growth).

#### Item 1 (SC-1): Verdict contract amendment
- RED: structural check asserts the Verdict contract's PASS bar is "no defect below is present in any criterion" (enumerated classes only), with no zero-findings statement and no prohibition of the non-finding-note disclosure path — verified 2026-10-10.
- GREEN: amend the Verdict contract to the three elements of SC-1.
- verify: structural inspection finds all three elements.
- commit: governed card edit (`.opencode/skills/spec/references/validation-standards.md`).

#### Item 2 (SC-2): Loop section amendment
- RED: structural check asserts the loop section caps remediation at one round ("One bounded loop ... not retried indefinitely") and halts to the developer after a persistent FAIL — verified 2026-10-10.
- GREEN: amend to the iterate-until-clean loop with the escalation condition — unremediable findings or non-convergence — and its payload (the specific findings, their root cause, and what is needed).
- verify: structural inspection finds all SC-2 properties; the cap text is gone.
- commit: governed card edit (`.opencode/skills/spec/references/validation-standards.md`).

#### Item 3 (SC-3): Spec card §6 alignment
- RED: structural check asserts §6 states "a FAIL that persists after revision halts to the developer" with no iterate-until-clean language — verified 2026-10-10.
- GREEN: amend §6 to state the loop repeats until zero findings, deferring loop semantics to the standards reference without contradiction.
- verify: structural inspection finds the consistent loop statement and no contradicting cap language.
- commit: governed card edit (`.opencode/skills/spec/SKILL.md`).

#### Item 4 (SC-4): Ledger admission
- RED: the deck-debt ledger carries no automatic-fail-restoration entry — verified 2026-10-10 (two admissions present: #2550 and #1195; neither covers this rule).
- GREEN: record the admission per the ledger's entry format.
- verify: ledger inspection.
- commit: ledger update via `local-issues`.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/skills/spec/references/validation-standards.md` | amendment target (SC-1, SC-2) | Satisfied (present) |
| `.opencode/skills/spec/SKILL.md` | amendment target (SC-3) | Satisfied (present) |
| Deck-debt ledger (.opencode#2534) | receives the SC-4 admission record | Satisfied (present) |
| Attic rule text (`.opencode/attic/skills/audit/tasks/spec-audit-evaluator.md`, `.opencode/attic/skills/audit/SKILL.md`, tag `pre-rip`) | preserved governing copy of the restored rule — evidence source, not a live routing target | Satisfied (present, read 2026-10-10) |
| skill-creator admission gate | governs every edit in Items 1–3 | Satisfied (present) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-2, SC-3 | Phase 1 |
| R-5 | SC-2 | Phase 1 |
| R-6 | SC-4 | Phase 1 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Old default-FAIL rule | preserved governing copy | `.opencode/attic/skills/audit/tasks/spec-audit-evaluator.md` (line 14: "Default assumption: FAIL ... no caveats, concerns, or notes"; line 43: "no INCONCLUSIVE, no 'PASS with concerns'") | Read 2026-10-10 |
| Old FAIL loop | preserved governing copy | `.opencode/attic/skills/audit/SKILL.md` (Diagnose → Remediate → Re-audit → Escalate → Never proceed past FAIL) | Read 2026-10-10 |
| Old aggregate verdict | preserved governing copy | `.opencode/attic/skills/spec-creation/tasks/validate.md` (Step 4: FAIL = one or more checks fail) | Read 2026-10-10 |
| Current validation standards | code (amendment target) | `.opencode/skills/spec/references/validation-standards.md` | Read 2026-10-10 — RED states verified |
| Current spec card | code (amendment target) | `.opencode/skills/spec/SKILL.md` | Read 2026-10-10 — RED state verified |
| Observed failure | session record | 2026-10-10 on-demand spec audit of `.opencode#2563` — reviewer returned PASS while disclosing Item 1's RED-narrative imprecision as a "non-finding observation" | Executed 2026-10-10; the record is the developer-session chat transcript (verdicts record once — chat or PR description — per the verify card; no store artifacts); not independently re-verifiable in a clean room; corroborated by the #2563 spec's 2026-10-10 RED-narrative corrections, which implement the described remediation |
| Old-chain session evidence | issue record | `.opencode#2332` comment (spec audit xBaseJ#60: DiMo chain validator → evaluator → arbiter behavior) | Read 2026-10-10 |
| Developer directive | session record | 2026-10-10 dispatch: "regression from old deck: any finding is an automatic fail requiring revision and re-auditing - file a regression bug fix spec; revise the spec based on findings. re-audit and revise until 100% clean." | Received 2026-10-10; verbatim, identical to §1 field 6 |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Edge Cases

### Input boundaries

- **Condition:** The reviewer observes a style preference or a hypothetical improvement.
- **Expected behavior:** Not a finding — the anti-churn binding stands; the audit does not fail on it.
- **Resolution:** Key Design Decision (2): the reporting-layer filter is deliberate; the regression was the missing automatic-fail consequence, not the filter.

- **Condition:** The reviewer is unsure whether an observation is substantive.
- **Expected behavior:** The observation is reported as a finding; the revise step resolves it — fix the text or record why it is not a defect.
- **Resolution:** Default-to-FAIL discipline restored from the old evaluator: uncertainty resolves toward FAIL and revision, never toward PASS.

### State transitions

- **Condition:** A revision fixes the named findings but the next reviewer surfaces new ones.
- **Expected behavior:** The loop continues — previously named findings must remain fixed; each newly surfaced finding is named, remediated, and the cycle repeats until a zero-finding verdict.
- **Resolution:** R-4's termination condition; non-convergence — findings continuing to surface across iterations after genuine remediation — is R-5's escalation: the audit cannot reach a zero-finding verdict by revision. Escalation and the clean PASS are the loop's only exits.

### Failure modes

- **Condition:** A finding cannot be remediated by revision — for example, the finding exposes a conflict between the spec and a developer constraint.
- **Expected behavior:** Escalation to the developer with the specific finding, its root cause, and what is needed.
- **Resolution:** R-5 — escalation replaces the fixed one-round cap as the loop's only exit besides a clean PASS.

- **Condition:** A reviser "fixes" a finding by rewording it into unfalsifiable prose rather than correcting the substance.
- **Expected behavior:** The next reviewer reports the evasion as a finding; the loop does not converge on negotiated text.
- **Resolution:** R-4's "never negotiated away" clause.

### Concurrency

- **Condition:** Two audits of the same artifact run concurrently and produce different findings.
- **Expected behavior:** Each audit's loop is independent; both must reach zero findings before the artifact advances.
- **Resolution:** Standard artifact contention; the zero-finding bar is per-verdict.

### Recovery

- **Condition:** A PASS was recorded for an artifact later found to carry a disclosed-but-unfixed observation — the 2026-10-10 #2563 case.
- **Expected behavior:** The developer directive reopens the loop: revise per the findings, re-audit until clean.
- **Resolution:** The observed-failure remediation path; the amended bar prevents recurrence.

---
<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated; restored rule text: attic skills/audit/tasks/spec-audit-evaluator.md, attic skills/audit/SKILL.md (tag pre-rip); observed failure: 2026-10-10 .opencode#2563 spec audit; developer directive 2026-10-10 -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
