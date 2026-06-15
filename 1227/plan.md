# [SPEC-FIX] Sub-agent Task File Discovery Directive for DISPATCH_GATE Protocol

## Goal

Update the DISPATCH_GATE protocol block in all eligible skill SKILL.md files to include a "Sub-agent Task File Discovery Directive" rule, ensuring dispatched sub-agents know where to find the task file defining their requirements.

## Architecture

This is a content-verification fix to DISPATCH_GATE protocol tables — adding a new required pattern row ("Sub-agent Task File Discovery Directive") and a new forbidden pattern entry to each affected SKILL.md. No behavioral logic, no runtime changes.

## Tech Stack

- Markdown editing only (SKILL.md files)

## File Structure

| File | Responsibility |
|------|---------------|
| `.opencode/skills/approval-gate/SKILL.md` | DISPATCH_GATE — add new "Sub-agent Task File Discovery Directive" row to Forbidden/Correct table |
| `.opencode/skills/git-workflow/SKILL.md` | DISPATCH_GATE — same addition |
| `.opencode/skills/writing-plans/SKILL.md` | DISPATCH_GATE — same addition (reference skill for this plan) |
| `.opencode/skills/brainstorming/SKILL.md` | DISPATCH_GATE — same addition |
| `.opencode/skills/implementation-pipeline/SKILL.md` | DISPATCH_GATE — same addition |
| `.opencode/skills/issue-operations/SKILL.md` | DISPATCH_GATE — same addition |
| `.opencode/skills/verification-before-completion/SKILL.md` | DISPATCH_GATE — same addition |

## SCs Covered

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-F1 | DISPATCH_GATE protocol in ALL skill SKILL.md files includes the "Sub-agent Task File Discovery Directive" rule | string |
| SC-F2 | Orchestrator prompts for skill tasks include task file discovery directive (verified by grep of task() calls) | behavioral |
| SC-F3 | Sub-agent that receives no discovery directive returns BLOCKED with `PRELOADED_CONTEXT_REJECTED` | behavioral |

---

## Phase 1: Add Sub-agent Task File Discovery Directive to DISPATCH_GATE Protocol

**Concern:** Content update — add the "Sub-agent Task File Discovery Directive" rule and new Forbidden/Correct table row to DISPATCH_GATE sections across 7 SKILL.md files. Same structural change applied identically to each file.

**Files:** `.opencode/skills/{approval-gate,git-workflow,writing-plans,brainstorming,implementation-pipeline,issue-operations,verification-before-completion}/SKILL.md`

**SCs covered:** SC-F1, SC-F2, SC-F3

| Gate | Dispatch Type | Blind? | Sub-Agent Type | Receives Context | SCs |
|------|--------------|--------|----------------|-----------------|-----|
| G1: sc-coherence-gate | sub-task | yes (blind) | general | `{"task": "run coherence-extraction on DISPATCH_GATE sections across 7 SKILL.md files", "issue_number": 1227, "phase": 1}` | SC-F1 |
| G2: pre-red-baseline | sub-task | yes (blind) | general | `{"task": "pre-red-baseline: verify doc-source currency for 7 SKILL.md files and SC-F1/F2/F3 traceability", "issue_number": 1227, "phase": 1}` | SC-F1, SC-F2, SC-F3 |
| G3: red-phase | sub-task | yes (blind) | general | `{"task": "execute red-phase from test-driven-development for SC-F1, SC-F2, SC-F3", "issue_number": 1227, "phase": 1}` | SC-F1, SC-F2, SC-F3 |
| G4: red-doublecheck | sub-task | yes (blind) | general | `{"task": "verify SC-F1, SC-F2, SC-F3: verify RED-side evidence — confirm SC-F1/F2/F3 test assertions exist and fail (RED)", "issue_number": 1227, "phase": 1}` | SC-F1, SC-F2, SC-F3 |
| G5: post-red-enforcement | sub-task | yes (blind) | general | `{"task": "post-red-enforcement: git diff --name-only -- src/ | wc -l — confirm no source code modified", "issue_number": 1227, "phase": 1}` | SC-F1 |
| G6: green-phase | sub-task | yes (blind) | general | `{"task": "execute green-phase from test-driven-development: add Sub-agent Task File Discovery Directive to DISPATCH_GATE in 7 SKILL.md files, then make SC-F2/F3 behavioral tests pass", "issue_number": 1227, "phase": 1}` | SC-F1, SC-F2, SC-F3 |
| G7: post-green-enforcement | sub-task | yes (blind) | general | `{"task": "post-green-enforcement: git diff --name-only -- test/ | wc -l — confirm test files modified", "issue_number": 1227, "phase": 1}` | SC-F2, SC-F3 |
| G8: checkpoint-commit | inline | N/A | N/A | — | SC-F1 |
| G9: structural-checks | sub-task | yes (blind) | general | `{"task": "finishing-checklist: lint/typecheck/format on all modified SKILL.md files", "issue_number": 1227, "phase": 1}` | SC-F1 |
| G10: green-doublecheck | sub-task | yes (blind) | general | `{"task": "verify SC-F1, SC-F2, SC-F3: GREEN-side semantic-intent verification — confirm 7 SKILL.md files have the Discovery Directive and behavioral test passes", "issue_number": 1227, "phase": 1}` | SC-F1, SC-F2, SC-F3 |
| G11: green-vbc | sub-task | yes (blind) | general | `{"task": "completion from verification-before-completion for SC-F1, SC-F2, SC-F3 on issue 1227", "issue_number": 1227, "phase": 1}` | SC-F1, SC-F2, SC-F3 |
| G12: adversarial-audit | sub-task | yes (blind) | general | `{"task": "verification-audit on DISPATCH_GATE update for issue 1227", "issue_number": 1227, "phase": 1, "audit_phase": "implementation"}` | SC-F1, SC-F2, SC-F3 |
| G13: cross-validate | sub-task | yes (blind) | general | `{"task": "cross-validate: compare GREEN-side evidence against spec SCs for issue 1227", "issue_number": 1227, "phase": 1, "audit_phase": "cross_validate"}` | SC-F1, SC-F2, SC-F3 |
| G14: regression-check | sub-task | yes (blind) | general | `{"task": "execute patterns regression from test-driven-development for DISPATCH_GATE protocol changes", "issue_number": 1227, "phase": 1}` | SC-F1 |
| G15: review-prep | sub-task | yes (blind) | general | `{"task": "review-prep from git-workflow for issue 1227 DISPATCH_GATE fix", "issue_number": 1227, "phase": 1}` | SC-F1, SC-F2, SC-F3 |
| G16: exec-summary | sub-task | yes (blind) | general | `{"task": "completion from completion-core: push, URL generation, comment for issue 1227", "issue_number": 1227, "phase": 1}` | SC-F1, SC-F2, SC-F3 |

### Item: DISPATCH_GATE Discovery Directive Content

**Scope:** Add the "Sub-agent Task File Discovery Directive" rule to the DISPATCH_GATE Forbidden/Correct table and a new required-pattern prose block.

**RED:** grep on each SKILL.md DISPATCH_GATE section confirms "Sub-agent Task File Discovery Directive" does NOT appear.

**GREEN:** grep on each SKILL.md DISPATCH_GATE section confirms "Sub-agent Task File Discovery Directive" IS present.

**Per-unit pipeline gate verification:**

| Gate | Name | Exit Criterion |
|------|------|---------------|
| 1 | sc-coherence-gate | Coherence extraction confirms DISPATCH_GATE protocol is a routing concern, not implementation |
| 2 | pre-red-baseline | Source currency: all 7 SKILL.md files exist and have DISPATCH_GATE sections; SC-F1/F2/F3 IDs verified against spec |
| 3 | red-phase | RED test fails: `grep "Sub-agent Task File Discovery Directive"` returns empty for all 7 files |
| 4 | red-doublecheck | RED-side evidence confirms no Discovery Directive exists in any file |
| 5 | post-red-enforcement | `git diff --name-only -- src/` returns 0 lines — no source code modified |
| 6 | green-phase | All 7 SKILL.md files updated with Discovery Directive; behavioral tests for SC-F2/F3 pass |
| 7 | post-green-enforcement | `git diff --name-only -- test/` returns lines > 0 — test files modified for SC-F2/F3 |
| 8 | checkpoint-commit | Commit with message `feat: add Sub-agent Task File Discovery Directive to DISPATCH_GATE` |
| 9 | structural-checks | Lint/format pass on all modified files |
| 10 | green-doublecheck | Semantic-intent: all 7 files have Directive; behavioral test for F2/F3 passes |
| 11 | green-vbc | VbC completion artifact produced |
| 12 | adversarial-audit | Dual-auditor verdict: PASS on all SCs |
| 13 | cross-validate | Cross-validate: no evidence type mismatch, no findings |
| 14 | regression-check | Regression: no existing tests broken |
| 15 | review-prep | PR body, compare URL, byline ready |
| 16 | exec-summary | Push complete, issue comment posted, URL reported |

### Item: Behavioral Tests for SC-F2 and SC-F3

**Scope:** Write behavioral enforcement tests verifying orchestrator includes discovery directive (SC-F2) and sub-agent rejects prompts without it (SC-F3).

**RED:** Behavioral test for SC-F2 fails: orchestrator prompt for skill task does NOT include discovery directive. Behavioral test for SC-F3 fails: sub-agent given a prompt without discovery directive does NOT reject it.

**GREEN:** Both behavioral tests pass — orchestrator prompt includes directive, sub-agent rejects bare prompts.

**Per-unit pipeline gate verification (applied CC-wise, merged into the single-phase table above):**

| Gate | Name | Exit Criterion |
|------|------|---------------|
| G3 | red-phase | `bash .opencode/tests/behaviors/task-file-discovery-F2.sh` fails (RED); `bash .opencode/tests/behaviors/task-file-discovery-F3.sh` fails (RED) |
| G4 | red-doublecheck | RED-side evidence: test assertions fail as expected |
| G6 | green-phase | Both behavioral tests pass (GREEN); enforcement test assertions succeed |
| G10 | green-doublecheck | Semantic: behavioral tests verify correct agent behavior |

### Concern Boundary Annotations

- **Prior scope:** Plan creation (no code modified yet)
- **Current scope:** DISPATCH_GATE protocol content update across 7 skill files
- **Handoff:** Plan defines the change pattern (add Discovery Directive row + prose block to each DISPATCH_GATE table). Implementation uses that pattern identically for each file.

### Inter-Phase Handoff

Single-phase plan — no inter-phase handoff needed. After Phase 1 completion, proceed to Post-All-Phases Sweep.

## Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — orchestrator routes to finishing sub-agent: git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION — orchestrator routes to git-workflow pr-creation: via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP — orchestrator routes to git-workflow cleanup: delete merged branches, close issues, sync dev

---

**Authorization:** `for_plan` scope — plan is auto-approved per approval cascade (scope_level >= for_plan).
**Halt at:** `plan_created` — do NOT proceed to implementation.

🤖 OpenCode (deepseek-v4-flash) ✅ completed