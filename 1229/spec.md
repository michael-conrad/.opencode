---
number: 1229
title: "[SPEC-FIX] spec-creation/write: post-SC uplift check after initial creation with remediation and recheck"
status: approved
labels: ["[SPEC-FIX]", "approved-for-plan"]
created: 2026-06-15
---

## Problem

When a spec writer creates success criteria in `write.md`, the Evidence Type Classification Gate (§3) already instructs correct classification at authorship time. However, there is **no post-creation step** that systematically re-examines ALL SCs for missed runtime-behavioral misclassification, applies automatic uplift, provides structured remediation, and re-checks before the spec is considered complete.

The pipeline-readiness gate validates SC atomicity, dependency ordering, single concern, and phase DAG — but does **not** check evidence type correctness against the BEH-EV substrate classification ("does this change affect runtime behavior?").

This means: an SC misclassified as `structural` for a runtime-behavioral change will pass the pipeline-readiness gate, pass self-review, and only be caught downstream at VbC time — the exact death-spiral pattern the BEH-EV classification gate was designed to prevent.

## Approach

Add a post-SC uplift check step to `write.md`, positioned between self-review (Step 6) and the evidence artifact verification (Step 6.5).

The step:

1. **SC evidence type re-check**: For each SC in the spec body, evaluate the substrate question: "Does this change affect runtime behavior?"
2. **Uplift misclassified SCs**: If runtime-behavioral YES but evidence type is NOT behavioral → auto-uplift to `behavioral`. Log the uplift action as a finding.
3. **Downgrade flag (conditional)**: If runtime-behavioral NO but evidence type IS behavioral → flag for review.
4. **Remediation guidance**: For each uplifted SC, provide guidance on what changes the verification method needs.
5. **Re-check**: After remediation, re-run the classification check. Confirm no remaining misclassifications.
6. **Evidence artifact**: Write findings to `.issues/{N}/post-sc-uplift-check.yaml`

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | Post-SC uplift check substep exists in write.md between Step 6 and Step 6.5 | `string` |
| SC-2 | Uplift check performs SC evidence type re-check against BEH-EV substrate question | `string` |
| SC-3 | Auto-uplift structural/string SCs to behavioral when runtime-behavioral change detected | `string` |
| SC-4 | Downgrade flag path exists for behavioral→structural false positives (flag-for-review, no auto-change) | `string` |
| SC-5 | Remediation guidance provided for each uplifted SC | `string` |
| SC-6 | Re-check step runs after remediation to confirm no remaining misclassifications | `string` |
| SC-7 | Findings written to `.issues/{N}/post-sc-uplift-check.yaml` | `string` |
| SC-8 | completion.md verifies post-SC uplift check step ran before spec completion | `string` |
| SC-9 | write.md Operating Protocol checklist includes the new step | `string` |

## Phases

### Phase 1: Add Post-SC Uplift Check Substep

**Concern:** Insert the post-SC uplift check substep into spec-creation task files.

**Files:**
- `.opencode/skills/spec-creation/tasks/write.md` — substep between Step 6 and Step 6.5
- `.opencode/skills/spec-creation/tasks/completion.md` — add uplift check verification

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)