# Plan: Spec writer must embed compliance requirement notice in all generated specs

## Classification
- **Type:** single-task (combined)
- **Phases:** 1
- **PR Strategy:** stacked
- **Plan structure decision:** combined
- **Reason:** Single-task spec with 1 phase, 3 SCs, all targeting one file. Plan content is concise enough to absorb into a combined document without readability loss.

## Phase 1: Template Update

### Concern
Add compliance requirement blockquote to spec body template at two positions in `write.md`.

### Concern Boundary
- **Leaving:** Spec definition (what needs to change is already specified)
- **Entering:** Template implementation (modifying the generated spec body template)
- **Handoff:** The spec defines the blockquote text and two positions; the plan defines the exact template locations

### Dispatch Table

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "execute sc-coherence-gate from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2, SC-3 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "execute pre-red-baseline from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2, SC-3 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "execute red-doublecheck from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-red-enforcement from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-3 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "execute post-green-enforcement from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-3 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-1, SC-2, SC-3 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "execute structural-checks from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-3 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "execute green-doublecheck from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "execute green-vbc from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2, SC-3 |
| G12: adversarial-audit | sub-task | yes (blind) | resolve-models | `{"task": "execute adversarial-audit from implementation-pipeline", "issue_number": 1261, "phase": 1, "audit_phase": "verification-audit"}` | SC-1, SC-2, SC-3 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "execute cross-validate from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2, SC-3 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute regression-check from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-3 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "execute review-prep from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2, SC-3 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "execute exec-summary from implementation-pipeline", "issue_number": 1261, "phase": 1}` | SC-1, SC-2, SC-3 |

### Items

#### Item 1: Add blockquote at top position (after STATUS/CREATED header)
- **RED:** The spec writer does NOT include the compliance requirement blockquote at the top of generated specs (after STATUS/CREATED header). A behavioral test sending a spec-creation prompt must show the agent produces a spec body without the blockquote at the top position.
- **GREEN:** The spec writer MUST include the compliance requirement blockquote at the top of generated specs (after STATUS/CREATED header). A behavioral test must show the blockquote appears at the top position.
- **REFACTOR:** Verify SC-1 passes via `grep -c "Compliance Requirement" .opencode/skills/spec-creation/tasks/write.md` returns at least 2.

#### Item 2: Add blockquote before success criteria table
- **RED:** The spec writer does NOT include the compliance requirement blockquote before the success criteria table. A behavioral test must show the agent produces a spec body without the blockquote at the bottom position.
- **GREEN:** The spec writer MUST include the compliance requirement blockquote before the success criteria table. A behavioral test must show the blockquote appears before the SC table.
- **REFACTOR:** Verify SC-2 passes via `grep -c "Compliance Requirement" .opencode/skills/spec-creation/tasks/write.md` returns at least 2.

#### Item 3: Verify only write.md changed
- **REFACTOR:** Run `git diff --name-only` to confirm only `write.md` is modified.
- **REFACTOR:** Verify SC-3 passes.

### Per-Unit Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Spec/plan coherence verified: the spec's two-position blockquote requirement matches the plan's two-item decomposition |
| 2 | pre-red-baseline | Source currency confirmed: `write.md` current state read and documented; SC-ID cross-ref traceability verified |
| 3 | red-phase | Behavioral test written that sends spec-creation prompt and verifies agent does NOT include blockquote at either position |
| 4 | red-doublecheck | RED-side SC evidence collected: test output confirms agent behavior without the change |
| 5 | post-red-enforcement | `git diff --name-only -- src/ | wc -l` returns 0 (no source changes during RED phase) |
| 6 | green-phase | `write.md` edited to include blockquote at both template positions |
| 7 | post-green-enforcement | `git diff --name-only -- test/ | wc -l` returns 0 (no test file changes during GREEN phase) |
| 8 | checkpoint-commit | All changes committed with checkpoint tag |
| 9 | structural-checks | Lint/typecheck/format pass on modified file |
| 10 | green-doublecheck | Semantic-intent verification: blockquote appears at correct positions in template, not just anywhere in file |
| 11 | green-vbc | VbC completion artifact produced with SC-1, SC-2, SC-3 evidence |
| 12 | adversarial-audit | Dual cross-family auditor consensus: both auditors confirm blockquote placement matches spec requirements |
| 13 | cross-validate | Cross-validate findings YAML: both auditor artifacts compared, consensus reached |
| 14 | regression-check | No regressions in existing spec-creation behavior |
| 15 | review-prep | Review-prep status: compare URL generated, PR body drafted |
| 16 | exec-summary | Push status confirmed, issue comment posted |

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

; Verification: initial state (all false) → SAT expected
; Verification: defective state (D_P1=true, p1=false) → UNSAT expected
```

### Success Criteria Mapping
| ID | Criterion | Item |
|----|----------|------|
| SC-1 | Compliance requirement blockquote appears at top of generated spec body (after STATUS/CREATED header) | Item 1 |
| SC-2 | Compliance requirement blockquote appears before success criteria table in generated spec body | Item 2 |
| SC-3 | Only write.md changed | Item 3 |

### Files Affected
- `.opencode/skills/spec-creation/tasks/write.md`
