# Plan: [SPEC-FIX] Plan Writer Stores Remotely Instead of Locally

**Issue:** michael-conrad/.opencode#1072
**Created:** 2026-06-07
**Plan source:** `.issues/1072/spec-artifacts/plan.md`

---

## Executive Summary

> **Problem:** The `writing-plans` skill stores plans via remote API (combined: appended to spec issue body; separate: creates `[PLAN]` GitHub Issue with sub-issues). Per architecture, only the exec summary goes to remote — plans, states, and tracking must live in the local `.issues/{N}/` workspace.
>
> **Scope:** Three affected files: `create-and-validate.md` (5 defects), `create.md` (1 defect), `SKILL.md` (1 defect). All are text/formatting changes — `string` evidence type, grep-verifiable.
>
> **All-or-Nothing Gate:** All 6 defects (D1–D6) must resolve for plan storage to be fully local. Partial resolution leaves the plan writer in a broken state where some paths go remote and some go local — producing inconsistent behavior that is worse than all-remote. This plan will not proceed unless all 6 defects are verifiably closed.

---

## Prior Concern (left): Spec Phase

The spec has been defined and approved. The plan writer operated under the assumption that plans are remote artifacts. This assumption is what we are correcting.

## Plan Concern (entered): Plan Storage Architecture

What concern being entered: Local storage inverted from remote. The plan writer must no longer touch the remote API for plan content — write to `.issues/{N}/spec-artifacts/plan.md` instead. Sub-issue tracking becomes phase sections in the local plan file.

### Handoff from Spec

The spec identifies 6 defects across 3 files, each with an explicit fix directive. No new defects may be introduced. The entry state is: all three files store plans remotely, and the fix is to invert each one to local storage.

---

## Phase 1: Fix `create-and-validate.md` (5 items)

**Why this phase exists:** This is the procedural core — `create-and-validate.md` is the task file that actually writes the plan. It has the most defects (D1–D4) and fixing it first resolves the most critical path. All subsequent phases reference this file, so getting it right avoids rework.

**What it must accomplish:** Remove all remote API calls (body append, `[PLAN]` issue creation, sub-issue linking, label ops, comment posting) from steps 6a, 7, 11, and 13. Replace with local `.issues/{N}/spec-artifacts/plan.md` writes and local path reports.

**How to verify completion:** Each item's GREEN phase produces a verified PASS via structural grep: the remote pattern no longer exists in the file. Verification cost is bounded — grep runs in ~1s per file, catches the defect at the edit stage. A behavioral test (`assert_semantic`) confirms that a clean-room agent instructed to write a plan produces a local artifact path, not a remote URL.

**What could go wrong:**
- Removing step 6a (sub-issue creation) breaks downstream step numbering (7→6, etc.) — all references must update
- The step numbering change propagates to cross-references in other files (`create.md`, `SKILL.md`)
- The `# Implementation Plan` header removal from combined path may affect agents that parse spec body for plan presence

**What must be done first:** None. This is the root phase — no prior dependencies.

### Item 1.1: Step 7 COMBINED — replace remote body append with local write (D1)

**RED condition (what must be false before starting):** The file `create-and-validate.md` contains the pattern `Append \`## Implementation Plan\` section to spec issue body` or equivalent remote-body-append language in Step 7.

**GREEN condition (what must be true when done):** Step 7 COMBINED path must reference `.issues/{N}/spec-artifacts/plan.md` as the write target. No remote issue body append language remains in the combined path.

#### Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | D1 fix addresses Step 7 combined path specifically — no overlap with other items |
| 2 | pre-red-baseline | `create-and-validate.md` is read and current Step 7 COMBINED text is captured as baseline |
| 3 | red-phase | grep fails: `create-and-validate.md` still contains remote body append pattern |
| 4 | red-doublecheck | Re-read confirms the remote pattern is still present (RED confirmed) |
| 5 | green-phase | Edit Step 7 COMBINED: replace remote body append with `.issues/{N}/spec-artifacts/plan.md` write |
| 6 | checkpoint-commit | `git add` + `git commit -m "fix(D1): Step 7 combined path writes locally instead of appending to remote body"` |
| 7 | structural-checks | `grep -n "spec issue body\|remote body\|Append.*Implementation Plan" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns empty |
| 8 | green-doublecheck | Re-read confirms only the combined path was modified — no side effects to separate path |
| 9 | green-vbc | `grep -q "\.issues/{N}/spec-artifacts/plan\.md" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns 0 |
| 10 | adversarial-audit | Auditor verifies D1 fix is complete and no remote pattern persists in combined path |
| 11 | cross-validate | Dual-auditor consensus: D1 resolved |
| 12 | regression-check | `create-and-validate.md` is well-formed markdown; no broken links or malformed step headings |
| 13 | review-prep | One sentence summarizing the change (structural: local write) |
| 14 | exec-summary | Item 1.1 complete — D1 resolved |

### Item 1.2: Step 7 SEPARATE — replace remote `[PLAN]` issue creation with local write (D2 part 1)

**RED condition (what must be false before starting):** Step 7 SEPARATE path in `create-and-validate.md` contains `Create GitHub Issue with \`[PLAN]\` title` or equivalent remote issue creation language.

**GREEN condition (what must be true when done):** Step 7 SEPARATE path writes to `.issues/{N}/spec-artifacts/plan.md` instead of creating a GitHub Issue.

#### Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | D2 fix part 1 addresses Step 7 separate path — distinct from item 1.1 (combined path) |
| 2 | pre-red-baseline | Current Step 7 SEPARATE text captured as baseline |
| 3 | red-phase | grep fails: `create-and-validate.md` still contains `Create GitHub Issue.*\[PLAN\]` |
| 4 | red-doublecheck | Re-read confirms remote plan issue creation pattern is present |
| 5 | green-phase | Edit Step 7 SEPARATE: replace `Create GitHub Issue` with write to `.issues/{N}/spec-artifacts/plan.md` |
| 6 | checkpoint-commit | `git commit -m "fix(D2-part1): Step 7 separate path writes locally instead of creating remote [PLAN] issue"` |
| 7 | structural-checks | `grep -n "Create GitHub Issue\|\[PLAN\] issue\|GitHub Issue.*plan" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns empty |
| 8 | green-doublecheck | Only separate path modified — combined path (item 1.1) unchanged |
| 9 | green-vbc | Local write path pattern exists in Step 7 SEPARATE |
| 10 | adversarial-audit | Auditor verifies no `[PLAN]` GitHub Issue creation remains |
| 11 | cross-validate | Dual-auditor consensus: D2 part 1 resolved |
| 12 | regression-check | All step references intact |
| 13 | review-prep | One sentence: separate path writes locally |
| 14 | exec-summary | Item 1.2 complete |

### Item 1.3: Remove Step 6a (sub-issue creation) — phases are local plan sections (D2 part 2)

**RED condition (what must be false before starting):** Step 6a exists in `create-and-validate.md` with sub-issue creation language.

**GREEN condition (what must be true when done):** Step 6a is removed. Subsequent step numbers re-indexed. No references to sub-issue creation remain.

#### Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | Distinct from items 1.1/1.2 — deleting a step, not editing one |
| 2 | pre-red-baseline | Step 6a content captured; verify step numbering before edit |
| 3 | red-phase | grep fails: `create-and-validate.md` contains Step 6a |
| 4 | red-doublecheck | Confirm step 6a is present at correct location |
| 5 | green-phase | Delete Step 6a; re-number subsequent steps (7→6, 8→7, etc.); update all cross-references within the file |
| 6 | checkpoint-commit | `git commit -m "fix(D2-part2): remove Step 6a sub-issue creation — phases are local plan sections"` |
| 7 | structural-checks | `grep -n "sub-issue\|sub_issue\|Step 6a\|Step 6.1" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns empty |
| 8 | green-doublecheck | Re-read confirms sequential step numbering (no gaps, no orphan references) |
| 9 | green-vbc | All internal cross-references point to valid step numbers |
| 10 | adversarial-audit | Auditor confirms no orphan sub-issue references |
| 11 | cross-validate | Dual-auditor consensus: step 6a removed, no gaps |
| 12 | regression-check | Cross-references from `create.md` and `SKILL.md` don't break (they reference `create-and-validate.md` by name, not step number — verified) |
| 13 | review-prep | One sentence: step 6a deleted, numbers realigned |
| 14 | exec-summary | Item 1.3 complete |

### Item 1.4: Step 13 — remove label-removal and comment-posting for auto-approval (D3)

**RED condition (what must be false before starting):** Step 13 in `create-and-validate.md` contains `needs-approval` label removal and/or auto-approval comment posting.

**GREEN condition (what must be true when done):** Step 13 performs no remote API calls. Approval is on the spec, not a plan artifact — no label operations, no comment posts.

#### Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | D3 is distinct — label/comment ops on remote plan; no overlap with D1/D2 |
| 2 | pre-red-baseline | Current Step 13 text captured |
| 3 | red-phase | grep fails: step 13 contains `needs-approval` or label removal |
| 4 | red-doublecheck | Confirm label/comment operations are present |
| 5 | green-phase | Replace Step 13 with local-only auto-approval logic: if scope >= `for_plan`, record approval in chat report; no API calls |
| 6 | checkpoint-commit | `git commit -m "fix(D3): Step 13 auto-approval is local — no remote label ops or comment posts"` |
| 7 | structural-checks | `grep -n "needs-approval\|remove_label\|post.*comment\|approval.*comment" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns empty |
| 8 | green-doublecheck | Local approval logic is present and coherent |
| 9 | green-vbc | No `github_issue_write` or label/comment API calls in step 13 |
| 10 | adversarial-audit | Auditor confirms no remote API refs in step 13 |
| 11 | cross-validate | Dual-auditor consensus |
| 12 | regression-check | Approval cascade still functions (local logic only) |
| 13 | review-prep | One sentence: step 13 uses local-only auto-approval |
| 14 | exec-summary | Item 1.4 complete |

### Item 1.5: Step 11 — replace remote URL report with local path (D4)

**RED condition (what must be false before starting):** Step 11 in `create-and-validate.md` reports plan creation with a remote GitHub Issue URL.

**GREEN condition (what must be true when done):** Step 11 reports plan creation with local path `.issues/{N}/spec-artifacts/plan.md`.

#### Pipeline Gate Table

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | D4 is distinct — reporting format change only |
| 2 | pre-red-baseline | Current Step 11 text captured |
| 3 | red-phase | grep fails: step 11 contains remote URL pattern |
| 4 | red-doublecheck | Confirm URL is a `github.com/.../issues/N` reference |
| 5 | green-phase | Replace remote URL with `.issues/{N}/spec-artifacts/plan.md` |
| 6 | checkpoint-commit | `git commit -m "fix(D4): Step 11 reports local path instead of remote URL"` |
| 7 | structural-checks | `grep -n "github.com.*issue\|issues.*url\|plan.*url\|Issue.*URL" .opencode/skills/writing-plans/tasks/create/create-and-validate.md` returns empty for plan-reporting lines |
| 8 | green-doublecheck | Local path is correctly formatted |
| 9 | green-vbc | Local path pattern present in step 11 |
| 10 | adversarial-audit | Auditor confirms no remote URL for plan reporting |
| 11 | cross-validate | Dual-auditor consensus |
| 12 | regression-check | Chat report still provides a findable artifact path |
| 13 | review-prep | One sentence: plan reported via local path |
| 14 | exec-summary | Item 1.5 complete |

---

## Phase 2: Fix `create.md` — Prerequisites, Exit Criteria, Cross-References (3 items)

**Why this phase exists:** `create.md` is the parent task file. Its prerequisites, exit criteria, and cross-references currently assume remote GitHub Issue storage. After Phase 1 changes the procedural core, the parent file must reflect the new local-storage reality. Doing this after Phase 1 ensures the parent references match the actual procedure.

**What must be done first:** Phase 1 complete (items 1.1–1.5). Phase 2 references `create-and-validate.md` which must already be fixed.

**What it must accomplish:** Update all references from remote (GitHub Issue, URL) to local (`.issues/{N}/` path) in prerequisites, exit criteria, and cross-references.

**How to verify completion:** Grep for remote patterns in `create.md` returns empty. All references use `.issues/{N}/` paths.

**What could go wrong:** The `create.md` may reference `create-and-validate.md` step numbers that changed due to Phase 1 item 1.3 (step 6a deletion). Must verify step number alignment after Phase 1.

### Item 2.1: Prerequisites line 10 — change remote spec reference to local (D5)

**RED condition:** Prerequisites line 10 in `create.md` says "Spec stored as GitHub Issue" or equivalent remote reference.

**GREEN condition:** Prerequisites reference `.issues/{N}/spec.md` as the spec location.

| Gate | Name | Exit Criterion |
|------|------|----------------|
| 1 | sc-coherence-gate | D5 line 10 — distinct addressing |
| 2 | pre-red-baseline | Line 10 text captured |
| 3 | red-phase | grep fails: line 10 contains "GitHub Issue" |
| 4 | red-doublecheck | Remote spec reference confirmed |
| 5 | green-phase | Edit to: "Spec stored as `.issues/{N}/spec.md` in local workspace" |
| 6 | checkpoint-commit | `git commit -m "fix(D5-part1): Prerequisites reference local .issues/{N}/spec.md"` |
| 7 | structural-checks | `grep -n "GitHub Issue\|remote.*spec\|spec.*URL" .opencode/skills/writing-plans/tasks/create.md` returns empty |
| 8 | green-doublecheck | Local path format correct |
| 9 | green-vbc | Local path pattern present in prerequisites |
| 10-14 | (audit through exec-summary) | Standard per-item gates |

### Item 2.2: Exit Criteria line 31 — change URL-based report to local path (D5)

**RED condition:** Exit Criteria says "Plan reported in chat with URL" or equivalent.

**GREEN condition:** Exit Criteria references "Plan reported in chat with local artifact path".

### Item 2.3: Step 5 cross-references — update to local `.issues/` paths (D5)

**RED condition:** Step 5 contains remote URLs or GitHub Issue references for cross-referencing.

**GREEN condition:** All cross-references use `.issues/` workspace paths.

---

## Phase 3: Fix `SKILL.md` — Plan Issue Model and Approval Cascade (3 items)

**Why this phase exists:** The SKILL.md is the entry point — it describes the plan architecture to agents. If it still describes remote `[PLAN]` issues, every agent loading the skill will be misled. Fixing SKILL.md last ensures the description matches the actual behavior after Phases 1 and 2.

**What must be done first:** Phases 1 and 2 complete. SKILL.md must reflect the actual procedure, not a future state.

**What it must accomplish:** Update Plan Issue Model, Operating Protocol rule 5, and approval cascade matrix to describe local-only artifacts at `.issues/{N}/spec-artifacts/plan.md` with no sub-issues.

**How to verify completion:** Structural grep: no `[PLAN]` issue, sub-issue, or remote plan references remain in SKILL.md plan model description. Sub-issue phase references removed from Operating Protocol.

**What could go wrong:** SKILL.md is read by many other skills/tasks — removing sub-issue language must not imply sub-issues are universally removed from the workflow (specs still use sub-issues via `issue-operations`).

### Item 3.1: Plan Issue Model — describe local artifact (D6)

**RED condition:** Overview §Plan Issue Model references "separate `[PLAN]` issue → phase sub-issues" or similar remote artifact model.

**GREEN condition:** Plan Issue Model describes `.issues/{N}/spec-artifacts/plan.md` as the plan location with phase sections instead of sub-issues.

### Item 3.2: Operating Protocol rule 5 — remove sub-issue phase references (D6)

**RED condition:** Rule 5 says "Phase structure: phases for sub-issues, tasks within phases for TDD steps."

**GREEN condition:** Rule 5 describes phases as sections in the local plan file, not sub-issues.

### Item 3.3: Approval cascade matrix — remove remote plan issue assumptions (D6)

**RED condition:** Approval cascade section assumes auto-approval on a remote plan issue.

**GREEN condition:** Cascade states: plan is local, approval is on the spec, no remote plan issue exists.

---

## Z3 Contracts

Each unit has a Z3 contract generated by `tools/solve`. Contracts verify the serial gate ordering invariant: no gate N may pass before gate N-1.

### File Layout

```
.opencode/.issues/1072/artifacts/solve/
  contracts/
    item-1-1.yaml
    item-1-2.yaml
    ...
  states/
    item-1-1-pass.yaml
    item-1-2-pass.yaml
    ...
```

### Contract Template (per item)

```yaml
# Generated by: tools/solve contract
item: "1.1"
variables:
  p1: "sc-coherence-gate"
  p2: "pre-red-baseline"
  p3: "red-phase"
  p4: "red-doublecheck"
  p5: "green-phase"
  p6: "checkpoint-commit"
  p7: "structural-checks"
  p8: "green-doublecheck"
  p9: "green-vbc"
  p10: "adversarial-audit"
  p11: "cross-validate"
  p12: "regression-check"
  p13: "review-prep"
  p14: "exec-summary"
domain_variable: "D_1_1"
serial_ordering:
  - "=> p2 p1"
  - "=> p3 p2"
  - ...
  - "=> p14 p13"
domain_condition: "D_1_1 == (and p1 p2 ... p14)"
```

### Verification

Before Phase 1 starts: `tools/solve check` on all-false initial state — MUST return SAT.
After each item: `tools/solve check` with that item's gates marked True — MUST return SAT.
If any gate passes out of order: `tools/solve check` must return UNSAT (detected violation).

---

## Domain Model (tools/plan)

Governed by `tools/plan` for schedule generation:

```
Problem: plan-storage-inversion
Domain: writing-plans
Actions:
  edit-file(file, pattern_remove, pattern_add)
  delete-step(file, step_id)
  renumber-steps(file, from_step, to_step)
  grep-verify(file, pattern, expected_result)
```

Initial state: `has_defect(create-and-validate.md, D1)`, `has_defect(create-and-validate.md, D2)`, ..., `not local(create-and-validate.md)`
Goal state: `local(create-and-validate.md) AND local(create.md) AND local(SKILL.md) AND not has_defect(any, any)`

## Dependency Graph

```
Phase 1 (all items serial, no parallelism possible — same file)
  Item 1.1 ──> Item 1.2 ──> Item 1.3 ──> Item 1.4 ──> Item 1.5
                                                          │
Phase 2 depends on Phase 1 complete                       │
  Item 2.1 ──> Item 2.2 ──> Item 2.3                      │
                                                          │
Phase 3 depends on Phase 1 + 2 complete                   │
  Item 3.1 ──> Item 3.2 ──> Item 3.3                      │
```

Phase 1 is serial (all edits to same file — sequential to avoid merge conflicts in the edit tool).
Phase 2 depends on Phase 1 (references step numbers that may change from item 1.3).
Phase 3 depends on both prior phases (describes the result of both).

---

## Verification Cost-Frame Identity

Verification of this plan uses structural evidence (grep, file existence) per the spec's own evidence-type declaration (`string`). This is correct for text-formatting changes — the cost is bounded and the defect is caught at the edit stage (gate 7: structural-checks). No behavioral test is required for each individual unit unless the change affects agent runtime behavior.

However, a behavioral test (`assert_semantic`) on the final state is warranted: a clean-room agent loaded with the fixed skill must produce a local plan path, not a remote URL, when asked to write a plan for a new issue. This catches the systemic defect that #1072 addresses — the agent's plan-writing behavior, not just text presence.

---

## Affected Files Summary

| File | Items | Defects |
|------|-------|---------|
| `skills/writing-plans/tasks/create/create-and-validate.md` | 1.1–1.5 | D1, D2, D3, D4 |
| `skills/writing-plans/tasks/create.md` | 2.1–2.3 | D5 |
| `skills/writing-plans/SKILL.md` | 3.1–3.3 | D6 |