# Implementation Plan — #1275

**Goal:** Replace `check-pr.md` Phase 3 single-step issue-close procedure with an 8-step multi-source extraction, live-verification, interdependency scan, supersession check, and depth-first closure procedure.

**Architecture:** Single file change to `.opencode/skills/git-workflow/tasks/check-pr.md`. The existing Phase 3 (lines 39-43) is replaced entirely. No new files, no structural changes to other phases.

**Tech Stack:** Markdown task file (opencode skill). No code changes.

**Plan structure decision:** combined — single-task spec, single file, single concern. Plan references spec content inline.

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Phase 1: Replace Phase 3 with Multi-Step Procedure

**Concern:** Editing `check-pr.md` Phase 3 — replacing the current single-step issue-close logic with the 8-step procedure defined in the spec.

**Files:** `.opencode/skills/git-workflow/tasks/check-pr.md`

**SCs covered:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-4, SC-5, SC-6 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-4, SC-5, SC-6 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-7, SC-8 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1275, "phase": 1}` | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8 |

### Concern Boundary Annotations

- **Prior concern:** Phase 2 (Verify Each Merge) — merge state confirmed, merge commit exists in dev history
- **Entering concern:** Phase 3 (Close Linked Issues) — issue reference extraction, live-verification, interdependency scan, supersession check, depth-first closure
- **Handoff:** Phase 2 produces a list of merged PRs with PR numbers, titles, branches, and merge timestamps. Phase 3 consumes this list to extract issue references.

### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Spec SCs are coherent with the existing `check-pr.md` structure — Phase 3 replacement is the correct scope |
| 2 | pre-red-baseline | Current Phase 3 content is documented as baseline; SC-ID cross-references are traceable |
| 3 | red-phase | Enforcement test exists and FAILS: agent given merged PR with issue reference, agent does NOT yet extract `#N` from PR body without `Fixes` prefix |
| 4 | red-doublecheck | RED-side SC evidence collected: test fails as expected |
| 5 | post-red-enforcement | No source files modified during RED phase (git diff --name-only -- src/ is empty) |
| 6 | green-phase | `check-pr.md` Phase 3 is replaced with the 8-step procedure; all 8 SCs implemented |
| 7 | post-green-enforcement | Test files modified during GREEN phase (git diff --name-only -- test/ is non-empty) |
| 8 | checkpoint-commit | All changes committed with checkpoint tag |
| 9 | structural-checks | Lint/typecheck/format pass on modified files |
| 10 | green-doublecheck | Behavioral SCs (SC-4, SC-5, SC-6) verified via semantic intent — agent behavior matches spec |
| 11 | green-vbc | All 8 SCs have PASS evidence artifacts |
| 12 | adversarial-audit | Dual cross-family auditors both return clean PASS on the Phase 3 replacement |
| 13 | cross-validate | Auditor artifacts cross-validated — no EVIDENCE_TYPE_MISMATCH |
| 14 | regression-check | Existing check-pr task behavior is preserved (Phases 1, 2, 4, 5, 6 unchanged) |
| 15 | review-prep | PR body written with Summary/Outcome/Fixes, compare URL verified |
| 16 | exec-summary | Push successful, PR created, issue comment posted |

### Z3 Contract

```
(declare-const P1_p1 Bool) ... (declare-const P1_p16 Bool)
(declare-const D_P1 Bool)

; Serial ordering: each gate implies the prior gate passed
(assert (=> P1_p2 P1_p1))
(assert (=> P1_p3 P1_p2))
(assert (=> P1_p4 P1_p3))
(assert (=> P1_p5 P1_p4))
(assert (=> P1_p6 P1_p5))
(assert (=> P1_p7 P1_p6))
(assert (=> P1_p8 P1_p7))
(assert (=> P1_p9 P1_p8))
(assert (=> P1_p10 P1_p9))
(assert (=> P1_p11 P1_p10))
(assert (=> P1_p12 P1_p11))
(assert (=> P1_p13 P1_p12))
(assert (=> P1_p14 P1_p13))
(assert (=> P1_p15 P1_p14))
(assert (=> P1_p16 P1_p15))

; Domain variable is True only when all 16 gates pass
(assert (=> D_P1 (and P1_p1 P1_p2 P1_p3 P1_p4 P1_p5 P1_p6 P1_p7 P1_p8 P1_p9 P1_p10 P1_p11 P1_p12 P1_p13 P1_p14 P1_p15 P1_p16)))

; Domain variable is False when any gate is false
(assert (=> (not (and P1_p1 P1_p2 P1_p3 P1_p4 P1_p5 P1_p6 P1_p7 P1_p8 P1_p9 P1_p10 P1_p11 P1_p12 P1_p13 P1_p14 P1_p15 P1_p16)) (not D_P1)))
```

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

---

## Authorization Context

```
authorization_scope: for_pr
halt_at: pr_created
pr_strategy: stacked
pipeline_phase: plan_created
authorization_source: "User approved #1275 on 2026-06-17"
```

## Approval Cascade

Scope `for_pr` (level 5) >= `for_plan` (level 3) → plan auto-approved. No separate approval needed.

🤖 OpenCode (deepseek-v4-flash)
