---
title: "[SPEC-FIX] Remediate implementation audit failures from #2009/#2020/#2032/#2064"
status: draft
created: 2026-07-22
license: MIT
provenance: AI-generated
issue: 2067
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-22

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem Statement

An implementation audit of 5 issues revealed 11 specific failures across 4 issues (#2009, #2020, #2032, #2064). These failures fall into four categories:

1. **Missing guideline enforcement** — No Tier 1 CRITICAL VIOLATION rule exists in `000-critical-rules.md` prohibiting direct `github_issue_write` calls for spec content that bypass the spec-creation pipeline. The existing rules cover inline issue creation (line 686) and defective deliverable fixes (lines 918-922), but there is no explicit Tier 1 CRITICAL VIOLATION for using `github_issue_write` to write spec content directly instead of dispatching through the spec-creation pipeline.

2. **Missing behavioral test** — No behavioral enforcement test exists at `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` to verify the agent routes spec content through the spec-creation pipeline rather than writing it directly.

3. **Task card structural defects** — 4 task cards are missing mandatory sections (## Entry Criteria, ## Procedure, ## Exit Criteria, ## Result Contract). 1 task card contains an `(orchestrator)` marker. 1 task card contains 3 `(**sub-agent**)` markers. 1 task card contains orchestrator-dispatch language. 6 task cards reference sub-agent or dispatch concepts inappropriately.

4. **SKILL.md Invocation under-count** — `writing-plans/SKILL.md` lists 7 Invocation entries instead of 13 individual task cards. `spec-creation/SKILL.md` lists 11 Invocation entries instead of 19 individual task cards.

5. **Missing plan template mandate** — `write.md` lacks a mandatory ## Pipeline Steps section enumerating all 15 implementation pipeline stages from `implementation-pipeline/SKILL.md`.

## Root Cause Analysis

The root cause is a combination of specification gaps and implementation drift:

1. **No explicit prohibition (SC-1):** The existing `000-critical-rules.md` has rules about inline issue creation (line 686) and not fixing defective deliverables directly (lines 918-922), but neither is a Tier 1 CRITICAL VIOLATION specifically targeting `github_issue_write` for spec content. The gap is that an agent could use `github_issue_write` to create or update a spec issue body directly, bypassing the spec-creation pipeline entirely, without triggering any existing CRITICAL VIOLATION.

2. **No behavioral test (SC-2):** The `dispatch-boundary-spec-creation.sh` behavioral test exists but tests the spec-creation dispatcher routing. There is no test that specifically verifies the agent does NOT use `github_issue_write` directly for spec content.

3. **Task card section drift (SC-4):** Task cards were created or modified without the mandatory section structure (## Entry Criteria, ## Procedure, ## Exit Criteria, ## Result Contract). The `completion.md` files use non-standard section names (State Check Phase, Skill-Specific Completion, etc.) instead of the standard sections. The `operating-protocol.md` has Entry/Exit/Result Contract but no ## Procedure. The `validate.md` has no standard sections at all.

4. **Orchestrator markers in task cards (SC-5, SC-6, SC-7):** Task cards are sub-agent-facing documents that must be fully self-contained. The presence of `(orchestrator)` markers, `(**sub-agent**)` markers, and orchestrator-dispatch language ("The orchestrator dispatches this task once per...") violates the clean-room sub-agent contract. A sub-agent receiving a task card with orchestrator language cannot execute it independently.

5. **SKILL.md Invocation drift (SC-8, SC-9):** The Invocation tables in `writing-plans/SKILL.md` and `spec-creation/SKILL.md` were not updated when new task cards were added to sub-skills. The tables list only the dispatcher-level tasks, not the individual task cards in each sub-skill.

6. **Missing Pipeline Steps section (SC-3):** The `write.md` plan template was created without a ## Pipeline Steps section. This section is mandatory per the plan format requirements to ensure all 15 implementation pipeline stages are enumerated in every plan.

## Goals

1. Add a Tier 1 CRITICAL VIOLATION rule to `000-critical-rules.md` prohibiting direct `github_issue_write` for spec content that bypasses the spec-creation pipeline
2. Create a behavioral enforcement test at `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh`
3. Add ## Pipeline Steps section to `write.md` with all 15 implementation pipeline stages
4. Restore mandatory sections (## Entry Criteria, ## Procedure, ## Exit Criteria, ## Result Contract) to 4 task cards
5. Remove `(orchestrator)` marker from `clean-room.md`
6. Remove `(**sub-agent**)` markers from `write.md` (lines 131, 142, 160)
7. Remove orchestrator-dispatch language from `behavioral-sc-evaluator.md`
8. Fix sub-agent/dispatch references in 6 task cards
9. Expand `writing-plans/SKILL.md` Invocation from 7 to 13 entries
10. Expand `spec-creation/SKILL.md` Invocation from 11 to 19 entries

## Non-Goals

- Rewriting task card content beyond the specific structural fixes listed
- Changing the DiMo chain architecture of the audit skill
- Adding new task cards or sub-skills
- Modifying behavioral test infrastructure or helpers
- Changes to non-listed task cards or skill files

## Constraints and Scope

**In scope:**
- `000-critical-rules.md` — add one Tier 1 CRITICAL VIOLATION rule
- `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` — new behavioral test
- `.opencode/skills/writing-plans-creation/tasks/write.md` — add ## Pipeline Steps section, remove `(**sub-agent**)` markers, fix sub-agent/dispatch references
- `.opencode/skills/writing-plans-creation/tasks/completion.md` — add missing sections, fix sub-agent/dispatch references
- `.opencode/skills/writing-plans-creation/tasks/operating-protocol.md` — add ## Procedure section
- `.opencode/skills/writing-plans-creation/tasks/validate.md` — add missing sections, fix sub-agent/dispatch references
- `.opencode/skills/writing-plans-creation/tasks/clean-room.md` — remove `(orchestrator)` marker
- `.opencode/skills/writing-plans-creation/tasks/update.md` — fix sub-agent/dispatch references
- `.opencode/skills/writing-plans-creation/tasks/solve.md` — fix sub-agent/dispatch references
- `.opencode/skills/writing-plans-holistic/tasks/holistic-self-check.md` — fix sub-agent/dispatch references
- `.opencode/skills/spec-creation-validation/tasks/completion.md` — add missing sections, fix sub-agent/dispatch references
- `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` — remove orchestrator-dispatch language
- `.opencode/skills/writing-plans/SKILL.md` — expand Invocation from 7 to 13 entries
- `.opencode/skills/spec-creation/SKILL.md` — expand Invocation from 11 to 19 entries

**Out of scope:**
- Non-listed task cards or skill files
- Changes to behavioral test harness or helpers
- Changes to `implementation-pipeline/SKILL.md`
- Changes to other guideline files beyond `000-critical-rules.md`

## Approach

### Phase 1: Guideline rule + behavioral test (depends on nothing)

**Step 1.1:** Add Tier 1 CRITICAL VIOLATION rule to `000-critical-rules.md` for direct `github_issue_write` for spec content bypassing spec-creation pipeline.

The rule should be placed in the Tier 1 section and read:

```
### [critical-rules-XXX] CRITICAL VIOLATION — Direct `github_issue_write` for spec content bypassing spec-creation pipeline

Using `github_issue_write` to create or update spec issue content (issue body, title, or description for a [SPEC] or [SPEC-FIX] issue) instead of dispatching through the `spec-creation` pipeline is a CRITICAL VIOLATION. All spec content MUST be created and revised through `skill({name: "spec-creation"})` → `task(..., prompt: "execute create from spec-creation-validation")` or the equivalent revision task. Direct `github_issue_write` calls for spec content bypass the spec-creation pipeline's quality gates (brainstorming, decomposition, analytical artifacts, holistic self-check, spec-auditor).

**Exception:** Non-substantive metadata updates (labels, assignees, status markers) via `github_issue_write` are permitted. Spec body content (problem statement, success criteria, approach, affected files) MUST go through the spec-creation pipeline.

**🚫 FORBIDDEN:**
- `github_issue_write(method=create, title="[SPEC] ...", body="...")` — creating a spec issue directly
- `github_issue_write(method=update, body="...")` — updating spec body content directly
- Any direct mutation of spec issue body content outside the spec-creation pipeline

**✅ REQUIRED:**
- `skill({name: "spec-creation"})` → `task(..., prompt: "execute create from spec-creation-validation")` for new specs
- `skill({name: "spec-creation"})` → `task(..., prompt: "execute revise from spec-creation-validation")` for spec revisions
- `github_issue_write` for labels, assignees, comments, and status markers only
```

**Step 1.2:** Create behavioral test at `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh`.

The test sends a real-domain prompt asking the agent to create a spec for a simple change and verifies the agent dispatches through the spec-creation pipeline rather than using `github_issue_write` directly. The test is an artifact-only generator per the v2 test harness specification.

### Phase 2: Task card remediation (independent file edits)

**Step 2.1:** Add missing sections to `writing-plans-creation/tasks/completion.md`:
- Add ## Entry Criteria section before State Check Phase
- Add ## Procedure section wrapping the existing checklist items
- Add ## Exit Criteria section after Procedure
- Ensure ## Result Contract section is present and correct
- Fix sub-agent/dispatch references (SC-7)

**Step 2.2:** Add missing sections to `writing-plans-creation/tasks/operating-protocol.md`:
- Add ## Procedure section with concrete steps (currently the file only has ## Entry Criteria, ## Exit Criteria, ## Result Contract and references to the SKILL.md for the actual protocol)

**Step 2.3:** Add missing sections to `writing-plans-creation/tasks/validate.md`:
- Add ## Entry Criteria section before Validation Checks
- Add ## Procedure section wrapping the validation check items
- Add ## Exit Criteria section after Procedure
- Ensure ## Result Contract section is present and correct
- Fix sub-agent/dispatch references (SC-7)

**Step 2.4:** Add missing sections to `spec-creation-validation/tasks/completion.md`:
- Add ## Entry Criteria section before State Check Phase
- Add ## Procedure section wrapping the existing checklist items
- Add ## Exit Criteria section after Procedure
- Ensure ## Result Contract section is present and correct
- Fix sub-agent/dispatch references (SC-7)

**Step 2.5:** Remove `(orchestrator)` marker from `writing-plans-creation/tasks/clean-room.md`.

**Step 2.6:** Remove `(**sub-agent**)` markers from `writing-plans-creation/tasks/write.md` lines 131, 142, 160. Replace with appropriate dispatch indicators (`` for orchestrator-direct steps, `(**clean-room**)` for clean-room sub-agent steps).

**Step 2.7:** Remove orchestrator-dispatch language from `audit/tasks/behavioral-sc-evaluator.md` lines 7-11. Replace the "Orchestrator Dispatch Entry" section with a standard "## Entry Criteria" section. The task card must be self-contained — a sub-agent reading it should not see "The orchestrator dispatches this task once per."

**Step 2.8:** Fix sub-agent/dispatch references in 6 task cards:
- `writing-plans-creation/tasks/validate.md` — remove or rephrase references to sub-agents, dispatch, sub-task
- `writing-plans-creation/tasks/update.md` — remove or rephrase references to sub-agents, dispatch, sub-task
- `writing-plans-creation/tasks/solve.md` — remove or rephrase references to sub-agents, dispatch, sub-task
- `writing-plans-creation/tasks/completion.md` — remove or rephrase references to sub-agents, dispatch, sub-task
- `writing-plans-creation/tasks/write.md` — remove or rephrase references to sub-agents, dispatch, sub-task
- `writing-plans-holistic/tasks/holistic-self-check.md` — remove or rephrase references to sub-agents, dispatch, sub-task

### Phase 3: SKILL.md Invocation expansion (independent file edits)

**Step 3.1:** Expand `writing-plans/SKILL.md` Invocation table from 7 to 13 entries.

The 13 entries should cover all individual task cards across sub-skills:
1. `create` → `writing-plans-creation`
2. `update` → `writing-plans-creation`
3. `retroactive` → `writing-plans-creation`
4. `validate` → `writing-plans-creation`
5. `solve` → `writing-plans-creation`
6. `pre-plan-readiness` → `writing-plans-creation`
7. `clean-room` → `writing-plans-creation`
8. `write` → `writing-plans-creation`
9. `completion` → `writing-plans-creation`
10. `operating-protocol` → `writing-plans-creation`
11. `holistic-self-check` → `writing-plans-holistic`
12. `pre-red-baseline` → `writing-plans-creation` (if exists)
13. `post-plan-audit` → `writing-plans-creation` (if exists)

**Step 3.2:** Expand `spec-creation/SKILL.md` Invocation table from 11 to 19 entries.

The 19 entries should cover all individual task cards across sub-skills:
1. `create` → `spec-creation-validation`
2. `requirements` → `spec-creation-requirements`
3. `decompose` → `spec-creation-decomposition`
4. `analytical-artifacts` → `spec-creation-decomposition`
5. `holistic-self-check` → `spec-creation-validation`
6. `pipeline-readiness-gate` → `spec-creation-validation`
7. `risk` → `spec-creation-validation`
8. `traceability` → `spec-creation-validation`
9. `change-control` → `spec-creation-change-control`
10. `operating-protocol` → `spec-creation-operating-protocol`
11. `completion` → `spec-creation-validation`
12. `revise` → `spec-creation-validation`
13. `validate` → `spec-creation-validation`
14. `pre-spec-inspection` → `spec-creation-decomposition`
15. `blast-radius` → `spec-creation-decomposition`
16. `code-path-inventory` → `spec-creation-decomposition`
17. `cross-cutting-matrix` → `spec-creation-decomposition`
18. `interface-compatibility` → `spec-creation-decomposition`
19. `state-analysis` → `spec-creation-decomposition`

### Phase 4: Plan template pipeline mandate

**Step 4.1:** Add ## Pipeline Steps section to `write.md` with all 15 implementation pipeline stages.

The section should enumerate all stages from `implementation-pipeline/SKILL.md` dispatch routing table:

```
## Pipeline Steps

Every plan MUST enumerate all 15 implementation pipeline stages from the `implementation-pipeline/SKILL.md` dispatch routing table. No stage may be omitted. Stages are:

1. **Pre-work** — `git-workflow --task pre-work`: trunk-tip verification, feature branch creation, submodule sync, checkpoint tagging
2. **Coherence gate** — `skill({name: "completeness-gate"})`: verify spec-to-plan coherence before RED phase
3. **Pre-RED baseline** — `skill({name: "test-driven-development"}) --task pre-red-baseline`: verify existing tests pass before any changes
4. **RED phase** — `skill({name: "test-driven-development"}) --task red`: write enforcement test that FAILS
5. **GREEN phase** — `skill({name: "test-driven-development"}) --task green`: implement change that makes test PASS
6. **GREEN doublecheck** — `skill({name: "test-driven-development"}) --task green-doublecheck`: verify test still passes after implementation
7. **Checkpoint commit** — `git-workflow --task commit`: commit with checkpoint tag
8. **Verification-before-completion (VbC)** — `skill({name: "verification-before-completion"})`: verify all SCs against evidence
9. **Audit** — `skill({name: "audit"})`: adversarial audit of deliverables
10. **Cross-validate** — `skill({name: "audit"}) --task cross-validate`: cross-validate audit findings
11. **Regression check** — `skill({name: "test-driven-development"}) --task regression`: verify no regressions
12. **Finishing checklist** — `skill({name: "finishing-a-development-branch"})`: branch finishing gate
13. **Review prep** — `skill({name: "git-workflow"}) --task review-prep`: PR readiness verification
14. **PR creation** — `skill({name: "git-workflow"}) --task pr-creation`: create pull request
15. **Cleanup** — `skill({name: "git-workflow"}) --task cleanup`: post-merge cleanup
```

## Affected Files

| File | Change | Phase |
|------|--------|-------|
| `.opencode/guidelines/000-critical-rules.md` | Add Tier 1 CRITICAL VIOLATION rule for direct `github_issue_write` for spec content | Phase 1 |
| `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` | New behavioral test file | Phase 1 |
| `.opencode/skills/writing-plans-creation/tasks/completion.md` | Add ## Entry Criteria, ## Procedure, ## Exit Criteria; fix sub-agent/dispatch references | Phase 2 |
| `.opencode/skills/writing-plans-creation/tasks/operating-protocol.md` | Add ## Procedure section | Phase 2 |
| `.opencode/skills/writing-plans-creation/tasks/validate.md` | Add ## Entry Criteria, ## Procedure, ## Exit Criteria; fix sub-agent/dispatch references | Phase 2 |
| `.opencode/skills/spec-creation-validation/tasks/completion.md` | Add ## Entry Criteria, ## Procedure, ## Exit Criteria; fix sub-agent/dispatch references | Phase 2 |
| `.opencode/skills/writing-plans-creation/tasks/clean-room.md` | Remove `(orchestrator)` marker | Phase 2 |
| `.opencode/skills/writing-plans-creation/tasks/write.md` | Remove `(**sub-agent**)` markers (lines 131, 142, 160); fix sub-agent/dispatch references; add ## Pipeline Steps section | Phase 2, Phase 4 |
| `.opencode/skills/audit/tasks/behavioral-sc-evaluator.md` | Remove orchestrator-dispatch language from lines 7-11 | Phase 2 |
| `.opencode/skills/writing-plans-creation/tasks/update.md` | Fix sub-agent/dispatch references | Phase 2 |
| `.opencode/skills/writing-plans-creation/tasks/solve.md` | Fix sub-agent/dispatch references | Phase 2 |
| `.opencode/skills/writing-plans-holistic/tasks/holistic-self-check.md` | Fix sub-agent/dispatch references | Phase 2 |
| `.opencode/skills/writing-plans/SKILL.md` | Expand Invocation from 7 to 13 entries | Phase 3 |
| `.opencode/skills/spec-creation/SKILL.md` | Expand Invocation from 11 to 19 entries | Phase 3 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `000-critical-rules.md` has Tier 1 CRITICAL VIOLATION rule for direct `github_issue_write` for spec content bypassing spec-creation pipeline | `string` | `grep -n "github_issue_write.*spec.*content\|spec.*content.*github_issue_write\|CRITICAL VIOLATION.*github_issue_write" .opencode/guidelines/000-critical-rules.md` returns at least one match in the Tier 1 section |
| SC-2 | `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` exists and is executable | `structural` | `ls .opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` confirms file exists; `head -1` shows `#!/bin/bash` |
| SC-3 | `write.md` has ## Pipeline Steps section with all 15 implementation pipeline stages | `string` | `grep "## Pipeline Steps" .opencode/skills/writing-plans-creation/tasks/write.md` returns a match; section contains at least 15 numbered stages |
| SC-4 | All 4 task cards (`writing-plans-creation/tasks/completion.md`, `writing-plans-creation/tasks/operating-protocol.md`, `writing-plans-creation/tasks/validate.md`, `spec-creation-validation/tasks/completion.md`) have ## Entry Criteria, ## Procedure, ## Exit Criteria, ## Result Contract sections | `string` | For each file: `grep -c "## Entry Criteria\|## Procedure\|## Exit Criteria\|## Result Contract"` returns 4 |
| SC-5 | `clean-room.md` has no `(orchestrator)` marker | `string` | `grep -c "(orchestrator)" .opencode/skills/writing-plans-creation/tasks/clean-room.md` returns 0 |
| SC-6 | `write.md` has no `(**sub-agent**)` markers | `string` | `grep -c "(**sub-agent**)" .opencode/skills/writing-plans-creation/tasks/write.md` returns 0 |
| SC-7 | `behavioral-sc-evaluator.md` has no "orchestrator dispatches" language | `string` | `grep -c "orchestrator dispatches\|The orchestrator dispatches" .opencode/skills/audit/tasks/behavioral-sc-evaluator.md` returns 0 |
| SC-8 | 6 task cards (`validate.md`, `update.md`, `solve.md`, `completion.md`, `write.md`, `holistic-self-check.md`) have no inappropriate sub-agent/dispatch references | `string` | For each file: grep for "sub-agent\|dispatch\|sub-task" returns only appropriate references (e.g., `(**clean-room**)` dispatch indicators, skill dispatch table references). No references to sub-agents as external entities that the task card itself dispatches. |
| SC-9 | `writing-plans/SKILL.md` Invocation lists 13 entries | `string` | Count Invocation table rows in `.opencode/skills/writing-plans/SKILL.md` — 13 task entries |
| SC-10 | `spec-creation/SKILL.md` Invocation lists 19 entries | `string` | Count Invocation table rows in `.opencode/skills/spec-creation/SKILL.md` — 19 task entries |
| SC-11 | All 10 SCs above verified PASS | `string` | Combined verification of SC-1 through SC-10 |

## Safety Considerations

- **Guideline changes are enforcement-critical:** Adding a Tier 1 CRITICAL VIOLATION rule to `000-critical-rules.md` changes agent behavior. The behavioral test (SC-2) must be created first (RED phase) to verify the agent does NOT follow the rule yet, then the guideline change (GREEN phase) makes the test pass.
- **Task card structural changes:** Adding sections to task cards changes their structure but not their behavior. The existing content is preserved and wrapped in the standard section structure. No behavioral change is expected.
- **SKILL.md Invocation expansion:** Expanding the Invocation tables is a documentation-only change. The Trigger Dispatch Table already routes to the correct sub-skills. The Invocation table is a reference for the orchestrator to know which canonical dispatch strings to use.
- **Behavioral test infrastructure:** The new behavioral test at `.opencode/tests-v2/behaviors/spec-creation-pipeline-routing.sh` follows the v2 artifact-only generator paradigm. It does NOT evaluate its own output — evaluation is the orchestrator's job.

## Labels

- `SPEC-FIX`
- `audit-remediation`
- `task-card-fix`
- `guideline-enforcement`

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
