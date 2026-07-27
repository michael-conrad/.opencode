---
plan_schema_version: "1.0"
issue: 2153
title: "Per-task-card PRELOADED_CONTEXT_REJECTED — remove global sub-agent directive, encode per-task-card entry criteria"
dispatch:
  - phase: 1
    skill: editing
    task: edit-file
  - phase: 2
    skill: audit
    task: content-audit
  - phase: 3
    skill: skill-creator
    task: update
  - phase: 4
    skill: test-driven-development
    task: behavioral-enforcement
---

# Plan for #2153: Per-task-card PRELOADED_CONTEXT_REJECTED

## Pre-implementation

### Coherence gate
- [ ] Dispatch `implementation-pipeline` → `sc-coherence-gate` (**sub-agent**) via `task(..., prompt: "sc-coherence-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - Verifies spec coherence before any implementation begins

### Baseline check
- [ ] Dispatch `implementation-pipeline` → `pre-red-baseline` (**sub-agent**) via `task(..., prompt: "pre-red-baseline from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - Confirms clean working tree and baseline state

## Phase 1: Remove global sub-agent directive from guidelines

**SCs:** SC-1, SC-2, SC-3
**Concern:** Guideline text surgery — remove global sub-agent mandate from 020-go-prohibitions.md, no-op for 000-critical-rules.md, preserve orchestrator-facing rule

### SC-1: Remove global PRELOADED_CONTEXT_REJECTED sub-agent directive from 020-go-prohibitions.md §1.2

- [ ] **RED phase** — Write failing test (**sub-agent**) via `task(..., prompt: "red-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-1
  - Create behavioral enforcement test or content-verification test that checks 020-go-prohibitions.md §1.2 no longer contains the global sub-agent PRELOADED_CONTEXT_REJECTED directive
- [ ] **Z3 check RED** (**inline**) via `.opencode/tools/solve --task check`
  - Context: `{issue_number: 2153, contract_path}`
- [ ] **RED doublecheck** (**sub-agent**) via `task(..., prompt: "red-doublecheck from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Z3 check RED doublecheck** (**inline**) via `.opencode/tools/solve --task check`
  - Context: `{issue_number: 2153, contract_path}`
- [ ] **Post-RED enforcement** (**sub-agent**) via `task(..., prompt: "post-red-enforcement from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - Verifies RED test genuinely fails
- [ ] **GREEN phase** — Remove directive (**sub-agent**) via `task(..., prompt: "green-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-1
  - Edit 020-go-prohibitions.md: remove lines 237-242 (global PRELOADED_CONTEXT_REJECTED sub-agent directive and FORBIDDEN/REQUIRED sub-bullets; remove the SC_CONFLICT exception block)
  - Keep orchestrator-facing canonical dispatch rule (the part about "orchestrator MUST use canonical dispatch string") intact
  - Target file: `.opencode/guidelines/020-go-prohibitions.md §1.2`
  - Verify removal: `rg -n "PRELOADED_CONTEXT_REJECTED" .opencode/guidelines/020-go-prohibitions.md` returns only the orchestrator-facing reference (line ~588), not the sub-agent directive
- [ ] **Z3 check GREEN** (**inline**) via `.opencode/tools/solve --task check`
  - Context: `{issue_number: 2153, contract_path}`
- [ ] **Post-GREEN enforcement** (**sub-agent**) via `task(..., prompt: "post-green-enforcement from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint tag create** (**sub-agent**) via `task(..., prompt: "checkpoint-tag-create from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint commit** (**sub-agent**) via `task(..., prompt: "checkpoint-commit from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Structural checks** (**sub-agent**) via `task(..., prompt: "structural-checks from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN doublecheck** (**sub-agent**) via `task(..., prompt: "green-doublecheck from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN VbC** (**sub-agent**) via `task(..., prompt: "green-vbc from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **SC count gate** (**sub-agent**) via `task(..., prompt: "sc-count-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Pre-PR gate** (**sub-agent**) via `task(..., prompt: "pre-pr-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`

### SC-2: Remove sub-agent-facing references from 000-critical-rules.md (NO-OP)

- [ ] **RED phase** — Verify no sub-agent-facing PRELOADED_CONTEXT_REJECTED exists (**sub-agent**) via `task(..., prompt: "red-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-2
  - Search 000-critical-rules.md for sub-agent-facing PRELOADED_CONTEXT_REJECTED references
  - Current state: NO references found (verified by `rg -n "PRELOADED_CONTEXT_REJECTED" .opencode/guidelines/000-critical-rules.md` returns empty)
  - This SC is a NO-OP — no change needed
- [ ] **GREEN phase** — Confirm NO-OP (**sub-agent**) via `task(..., prompt: "green-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-2
  - Document in work state that no changes were needed; log the `rg` command output as evidence
- [ ] **Post-GREEN enforcement** (**sub-agent**) via `task(..., prompt: "post-green-enforcement from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint commit** (**sub-agent**) via `task(..., prompt: "checkpoint-commit from implementation-pipeline")`
  - Context: `{issue_number: 2153}`

### SC-3: Keep orchestrator-facing canonical dispatch rule intact

- [ ] **RED phase** — Write test that canonical dispatch rule persists (**sub-agent**) via `task(..., prompt: "red-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-3
  - Content-verification test: grep both 020-go-prohibitions.md and 000-critical-rules.md for orchestrator-facing canonical dispatch language (the "orchestrator MUST use exact Invocation strings, do not preload" rule)
  - The test MUST PASS on the unchanged codebase (confirming the rule is intact)
- [ ] **GREEN phase** — Confirm orchestrator rule intact (**sub-agent**) via `task(..., prompt: "green-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-3
  - No edits needed — the orchestrator-facing rule was preserved in Phase 1 (we only removed the sub-agent directive)
  - Verify with `rg` that canonical dispatch string language remains
- [ ] **Post-GREEN enforcement** (**sub-agent**) via `task(..., prompt: "post-green-enforcement from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint commit** (**sub-agent**) via `task(..., prompt: "checkpoint-commit from implementation-pipeline")`
  - Context: `{issue_number: 2153}`

## Phase 2: Audit SKILL.md DISPATCH_GATE sections

**SCs:** SC-4
**Concern:** Audit ~48 files (39 SKILL.md + 4 audit task files + 3 platform SKILL.md + 2 guideline references) — classify each PRELOADED_CONTEXT_REJECTED as cargo-cult or justified

### SC-4: Classify each file — remove cargo-cult, keep justified

- [ ] **RED phase** — Establish baseline of all PRELOADED_CONTEXT_REJECTED locations (**sub-agent**) via `task(..., prompt: "red-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-4
  - Run `rg -l "PRELOADED_CONTEXT_REJECTED" .opencode/` to catalog all occurrences
  - For each file, extract context: is it in a SKILL.md DISPATCH_GATE section, or a task card entry criteria?

- [ ] **GREEN phase** — Audit each file (**sub-agent**) via `task(..., prompt: "green-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-4
  - For each file, classify PRELOADED_CONTEXT_REJECTED as:
    - **REMOVE (cargo-cult):** The directive appeared in the DISPATCH_GATE Sub-Agent Entry Criteria section but was copied from the global directive without independent justification. The task card has no legitimate reason to receive preloaded context that would require rejection. These are the ~39 "count: 1" SKILL.md files.
    - **REMOVE (cargo-cult):** The directive appears in a task card without independent justification. Applies to `content-audit-*` task files where the directive is boilerplate.
    - **KEEP (justified):** The skill has tasks that legitimately receive context (verification tasks receive deliverables+SCs; completion tasks receive pipeline state; issue ops receive issue numbers). The directive remains but MUST be moved to the task card entry criteria.
    - **KEEP (justified — platform):** Platform sub-skills (`gitbucket-api`, `github-mcp`, `local`) have independent DISPATCH_GATE sections. Keep if the task card genuinely needs clean-room isolation; move to task card entry criteria.

  - **Files to audit (48 total):**
    - `020-go-prohibitions.md` — Already processed in Phase 1 (subset of SC-1 coverage)
    - `000-critical-rules.md` — Already confirmed NO references (SC-2)

    - **SKILL.md files (count: 1 — isolated occurrence in DISPATCH_GATE):**
      - approval-gate-scope/SKILL.md
      - brainstorming/SKILL.md
      - changelog-generator/SKILL.md
      - completeness-gate/SKILL.md
      - completion-core/SKILL.md (count: 2 — two DISPATCH_GATE blocks)
      - conflict-resolution/SKILL.md
      - correspondence/SKILL.md
      - engineering-approach/SKILL.md
      - executing-plans/SKILL.md
      - finishing-a-development-branch/SKILL.md
      - git-workflow-branch/SKILL.md
      - git-workflow-cleanup/SKILL.md
      - git-workflow-commit/SKILL.md
      - git-workflow-conflict/SKILL.md
      - git-workflow-pr/SKILL.md
      - implementation-pipeline/SKILL.md (count: 2 — two DISPATCH_GATE blocks)
      - issue-operations-comments/SKILL.md
      - issue-operations-core/SKILL.md
      - issue-operations/SKILL.md
      - issue-operations-sub-issues/SKILL.md
      - issue-operations-sync/SKILL.md
      - issue-review/SKILL.md
      - mcp-tool-usage/SKILL.md
      - multimodal-dispatch/SKILL.md
      - plan-creation-pipeline/SKILL.md
      - plan/SKILL.md
      - playwright-cli/SKILL.md
      - pr-creation-workflow/SKILL.md
      - pre-analysis/SKILL.md
      - programming-principles/SKILL.md
      - receiving-code-review/SKILL.md
      - release-promoter/SKILL.md
      - requesting-code-review/SKILL.md
      - research/SKILL.md
      - skill-creator/SKILL.md
      - sre-runbook/SKILL.md
      - sync-guidelines/SKILL.md
      - systematic-debugging/SKILL.md
      - test-driven-development/SKILL.md
      - using-git-worktrees/SKILL.md
      - verification/SKILL.md
      - verification-before-completion/SKILL.md
      - verification-enforcement/SKILL.md
      - version-manager/SKILL.md

    - **Platform SKILL.md files (count: 3 — independent DISPATCH_GATE sections):**
      - issue-operations/platforms/gitbucket-api/SKILL.md
      - issue-operations/platforms/github-mcp/SKILL.md
      - issue-operations/platforms/local/SKILL.md

    - **Audit task files (count: 4 — PRELOADED_CONTEXT_REJECTED in entry criteria):**
      - audit/tasks/content-audit-arbiter.md
      - audit/tasks/content-audit-evaluator.md
      - audit/tasks/content-audit-investigator.md
      - audit/tasks/content-audit-validator.md

  - **Classification heuristics:**
    - **Cargo-cult if:** The SKILL.md task dispatches to skills where the sub-agent receives task objectives (not pre-processed data). The PRELOADED_CONTEXT_REJECTED was clearly copied from the global directive template. No task card independently evaluates preloaded context rejection.
    - **Justified if:** The task card has sub-agents that must reject preloaded context because their entry criteria specify clean-room evaluation (e.g., auditors, verifiers that receive deliverables). The task card independently documents what context must NOT be preloaded.
    - **Platform sub-skills:** These have independent DISPATCH_GATE sections that were written independently of the global directive. Evaluate on their own merits — they are NOT cargo-cult.

  - **Expected outcome:** Most SKILL.md files will be REMOVE (cargo-cult). The audit task files and potentially a few others (verification-before-completion, verification-enforcement, audit) may be KEEP (justified). The platform sub-skills may be KEEP depending on their task card structure.

  - **Exit criteria:** After GREEN, the count of `rg -l "PRELOADED_CONTEXT_REJECTED" .opencode/skills/` should be significantly reduced (estimated from ~48 to ~5-8 justified cases).

- [ ] **Post-GREEN enforcement** (**sub-agent**) via `task(..., prompt: "post-green-enforcement from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint tag create** (**sub-agent**) via `task(..., prompt: "checkpoint-tag-create from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint commit** (**sub-agent**) via `task(..., prompt: "checkpoint-commit from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Structural checks** (**sub-agent**) via `task(..., prompt: "structural-checks from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN doublecheck** (**sub-agent**) via `task(..., prompt: "green-doublecheck from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN VbC** (**sub-agent**) via `task(..., prompt: "green-vbc from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **SC count gate** (**sub-agent**) via `task(..., prompt: "sc-count-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Pre-PR gate** (**sub-agent**) via `task(..., prompt: "pre-pr-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`

## Phase 3: Encode per-task-card entry criteria where justified

**SCs:** SC-5
**Concern:** For PRELOADED_CONTEXT_REJECTED that survives the Phase 2 audit, ensure the directive exists in the task card entry criteria (not just the SKILL.md DISPATCH_GATE)

### SC-5: Task-card-level entry criteria for remaining directives

- [ ] **RED phase** — Identify files needing entry criteria migration (**sub-agent**) via `task(..., prompt: "red-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-5
  - After Phase 2 GREEN, identify all files where PRELOADED_CONTEXT_REJECTED was KEPT
  - For each, check if the corresponding task card (`tasks/<name>.md`) has an Entry Criteria section documenting the preloaded context rejection
  - If task card lacks entry criteria for preloaded context rejection: document as finding

- [ ] **GREEN phase** — Add entry criteria to task cards (**sub-agent**) via `task(..., prompt: "green-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-5
  - For each file where PRELOADED_CONTEXT_REJECTED was KEPT and the task card lacks entry criteria:
    1. Read the task card
    2. Add `- PRELOADED_CONTEXT_REJECTED: Sub-agent MUST return BLOCKED with PRELOADED_CONTEXT_REJECTED if task() prompt contains preloaded context (inline file paths, step definitions, expected outcomes, or orchestrator-derived conclusions)` to the task card's Entry Criteria section
    3. Keep the SKILL.md DISPATCH_GATE reference as the orchestrator-facing routing hint, but the canonical rejection directive lives in the task card
  - Files expected to need entry criteria: audit task files (content-audit-*), verification task files, and any other justified cases from Phase 2

- [ ] **Post-GREEN enforcement** (**sub-agent**) via `task(..., prompt: "post-green-enforcement from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint tag create** (**sub-agent**) via `task(..., prompt: "checkpoint-tag-create from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint commit** (**sub-agent**) via `task(..., prompt: "checkpoint-commit from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Structural checks** (**sub-agent**) via `task(..., prompt: "structural-checks from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN doublecheck** (**sub-agent**) via `task(..., prompt: "green-doublecheck from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN VbC** (**sub-agent**) via `task(..., prompt: "green-vbc from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **SC count gate** (**sub-agent**) via `task(..., prompt: "sc-count-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Pre-PR gate** (**sub-agent**) via `task(..., prompt: "pre-pr-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`

## Phase 4: Update behavioral enforcement test

**SCs:** SC-6
**Concern:** Create or update dispatch-gate-rejection.sh to test only the remaining PRELOADED_CONTEXT_REJECTED cases

### SC-6: dispatch-gate-rejection.sh updated to match reduced set

- [ ] **RED phase** — Write updated dispatch-gate-rejection.sh that FAILS (**sub-agent**) via `task(..., prompt: "red-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-6
  - Read `.opencode/tests-v2/behaviors/helpers.sh` to understand assertion helpers
  - Read an existing behavioral test (e.g., `template.sh` or `task-card-inline-execution.sh`) as a reference
  - Write (or update) `.opencode/tests-v2/behaviors/dispatch-gate-rejection.sh`:
    - **If test doesn't exist:** Create it
    - **If test exists:** Modify it to match the reduced set of PRELOADED_CONTEXT_REJECTED cases
    - Test design: Send a `task()` prompt with preloaded context to a skill whose task card has PRELOADED_CONTEXT_REJECTED in entry criteria
    - Also send a `task()` prompt with preloaded context to a skill whose PRELOADED_CONTEXT_REJECTED was REMOVED — verify the sub-agent does NOT reject
    - Use `assert_stderr_pattern_present` and `assert_stderr_pattern_absent` from helpers.sh
    - SC-4 is `behavioral` evidence type, so use `assert_semantic` as PRIMARY assertion with `assert_stderr_pattern_*` as secondary corroboration
  - The test MUST FAIL on unchanged codebase (because PRELOADED_CONTEXT_REJECTED is still in the global directive and cargo-cult SKILL.md files)

- [ ] **Z3 check RED** (**inline**) via `.opencode/tools/solve --task check`
  - Context: `{issue_number: 2153, contract_path}`
- [ ] **RED doublecheck** (**sub-agent**) via `task(..., prompt: "red-doublecheck from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Post-RED enforcement** (**sub-agent**) via `task(..., prompt: "post-red-enforcement from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN phase** — Write updated behavioral test that PASSES (**sub-agent**) via `task(..., prompt: "green-phase from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - SC-ID: SC-6
  - After phases 1-3 are complete, the dispatch-gate-rejection.sh test should now reference only the remaining PRELOADED_CONTEXT_REJECTED cases
  - The test MUST PASS on the modified codebase
  - Run the test with `bash .opencode/tests-v2/with-test-home bash .opencode/tests-v2/behaviors/dispatch-gate-rejection.sh`

- [ ] **Z3 check GREEN** (**inline**) via `.opencode/tools/solve --task check`
  - Context: `{issue_number: 2153, contract_path}`
- [ ] **Post-GREEN enforcement** (**sub-agent**) via `task(..., prompt: "post-green-enforcement from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint tag create** (**sub-agent**) via `task(..., prompt: "checkpoint-tag-create from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Checkpoint commit** (**sub-agent**) via `task(..., prompt: "checkpoint-commit from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Structural checks** (**sub-agent**) via `task(..., prompt: "structural-checks from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN doublecheck** (**sub-agent**) via `task(..., prompt: "green-doublecheck from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **GREEN VbC** (**sub-agent**) via `task(..., prompt: "green-vbc from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **SC count gate** (**sub-agent**) via `task(..., prompt: "sc-count-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Pre-PR gate** (**sub-agent**) via `task(..., prompt: "pre-pr-gate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`

## Post-implementation

- [ ] **Audit** (**sub-agent**) via `task(..., prompt: "audit from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
  - Dispatches the appropriate audit task (verification-audit or plan-fidelity)
- [ ] **Cross-validate** (**sub-agent**) via `task(..., prompt: "cross-validate from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Regression check** (**sub-agent**) via `task(..., prompt: "regression-check from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Rationalization check** (**sub-agent**) via `task(..., prompt: "rationalization-check from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Review prep** (**sub-agent**) via `task(..., prompt: "review-prep from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
- [ ] **Create PR** (**sub-agent**) via `task(..., prompt: "create-pr from implementation-pipeline")`
  - Context: `{issue_number: 2153, authorization_scope: for_pr, halt_at: pr_created}`
- [ ] **Executive summary** (**sub-agent**) via `task(..., prompt: "exec-summary from implementation-pipeline")`
  - Context: `{issue_number: 2153}`
