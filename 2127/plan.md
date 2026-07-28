---
plan_schema_version: "1.0"
issue: 2127
title: "Compact 020-go-prohibitions.md"
dispatch:
  - phase: 1
    skill: test-driven-development
    task: red
  - phase: 1
    skill: test-driven-development
    task: green
  - phase: 2
    skill: test-driven-development
    task: red
  - phase: 2
    skill: test-driven-development
    task: green
  - phase: 3
    skill: test-driven-development
    task: red
  - phase: 3
    skill: test-driven-development
    task: green
  - phase: 4
    skill: test-driven-development
    task: red
  - phase: 4
    skill: test-driven-development
    task: green
  - phase: 5
    skill: verification-before-completion
    task: verify
---

## Pre-Implementation

### Coherence Gate

- [ ] Dispatch `sc-coherence-gate` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Verifies spec/plan coherence before any RED routing
  - On FAIL: remediate root cause, re-dispatch

### Baseline Check

- [ ] Dispatch `pre-red-baseline` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Captures baseline state of files before modifications
  - On FAIL: HALT

---

## Phase 1: Remove duplicated sections (§5, §6, stop command, Channel-Routing Table)

**SCs:** SC-1, SC-2, SC-3, SC-4
**Files affected:** `.opencode/guidelines/020-go-prohibitions.md`

### Item 1: SC-1 — Remove §5 Multi-task Plan Without Sub-issues

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-1}`
  - Dispatch string: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Write grep-based test that asserts absence of "Multi-task Plan Without Sub-issues" in 020-go-prohibitions.md
  - Test MUST FAIL (section still exists)
- [ ] **Z3 check RED** (**inline**)
  - Context: `{issue_number: 2127}`
  - Run `solve --task check` to validate RED state
- [ ] **RED doublecheck** — verify RED (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Confirm RED test correctly fails
- [ ] **Z3 check RED doublecheck** (**inline**)
  - Context: `{issue_number: 2127}`
  - Run `solve --task check` to validate RED doublecheck state
- [ ] **Post-RED enforcement** (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Enforce RED gate: test must be failing
- [ ] **Z3 check post-RED** (**inline**)
  - Context: `{issue_number: 2127}`
  - Run `solve --task check` to validate post-RED state
- [ ] **GREEN phase** — implement removal (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-1}`
  - Dispatch string: `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Remove §5 Multi-task Plan Without Sub-issues from 020-go-prohibitions.md
- [ ] **Z3 check GREEN** (**inline**)
  - Context: `{issue_number: 2127}`
  - Run `solve --task check` to validate GREEN state
- [ ] **Post-GREEN enforcement** (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Enforce GREEN gate: test must now pass
- [ ] **Z3 check post-GREEN** (**inline**)
  - Context: `{issue_number: 2127}`
  - Run `solve --task check` to validate post-GREEN state
- [ ] **Create checkpoint tag** (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
- [ ] **Checkpoint commit** (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`

### Item 2: SC-2 — Remove §6 Progressive Iterative Implementation

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-2}`
  - Dispatch string: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Write grep-based test that asserts absence of "Progressive Iterative Implementation" in 020-go-prohibitions.md
  - Test MUST FAIL (section still exists)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement removal (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-2}`
  - Remove §6 Progressive Iterative Implementation from 020-go-prohibitions.md
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

### Item 3: SC-3 — Remove "stop" command section

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-3}`
  - Write grep-based test that asserts absence of "terminal halt" in 020-go-prohibitions.md
  - Test MUST FAIL (section still exists)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement removal (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-3}`
  - Remove "stop" command section from 020-go-prohibitions.md
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

### Item 4: SC-4 — Remove Channel-Routing Table

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-4}`
  - Write grep-based test that asserts absence of "Channel-Routing Table" in 020-go-prohibitions.md
  - Test MUST FAIL (section still exists)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement removal (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-4}`
  - Remove Channel-Routing Table from 020-go-prohibitions.md
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

---

## Phase 2: Remove internally-duplicated lines (3 restated ALWAYS DO lines)

**SCs:** SC-5
**Files affected:** `.opencode/guidelines/020-go-prohibitions.md`

### Item 5: SC-5 — Remove 3 restated ALWAYS DO lines

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-5}`
  - Dispatch string: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Write grep-based test that asserts absence of "Make a live tool call before every factual claim" in 020-go-prohibitions.md
  - Test MUST FAIL (lines still exist)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement removal (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-5}`
  - Remove the 3 restated ALWAYS DO lines from 020-go-prohibitions.md
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

---

## Phase 3: Collapse §1.2 and §1.5 into §1

**SCs:** SC-6, SC-7
**Files affected:** `.opencode/guidelines/020-go-prohibitions.md`

### Item 6: SC-6 — §1.2 merged into §1 as bullet

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-6}`
  - Dispatch string: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Write grep-based test that asserts presence of "interpretive question" within §1 of 020-go-prohibitions.md
  - Test MUST FAIL (text is still in §1.2, not §1)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement merge (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-6}`
  - Merge §1.2 content into §1 as a bullet, remove §1.2 header
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

### Item 7: SC-7 — §1.5 collapsed into §1

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-7}`
  - Write grep-based test that asserts absence of "Soliciting Authorization" header in 020-go-prohibitions.md
  - Test MUST FAIL (header still exists)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement collapse (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-7}`
  - Collapse §1.5 content into §1, remove §1.5 header
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

---

## Phase 4: Replace §4/§4.5 with general `.tools/` rule

**SCs:** SC-8
**Files affected:** `.opencode/guidelines/020-go-prohibitions.md`

### Item 8: SC-8 — §4 replaced with general `.tools/` rule

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-8}`
  - Dispatch string: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Write grep-based test that asserts presence of ".tools/" in §4 of 020-go-prohibitions.md
  - Test MUST FAIL (old Node.js-specific text still present)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement replacement (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-8}`
  - Replace §4 Node.js-specific prohibition with general `.tools/` rule
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

---

## Phase 5: Verify all keep sections remain, no content loss, remove duplicate Node.js section from 070-environment.md, update 085-project-local-tools.md cross-references

**SCs:** SC-9, SC-10, SC-11, SC-12, SC-13
**Files affected:** `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/070-environment.md`, `.opencode/guidelines/085-project-local-tools.md`

### Item 9: SC-9 — All 4 keep categories remain

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-9}`
  - Dispatch string: `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Write grep-based test that asserts presence of all 4 keep categories in 020-go-prohibitions.md:
    - §1.1 Orchestrator Context Discipline
    - Live tool call/training data/metadata lines (lines 277-279)
    - Cost-blind/evidence substitution/continue waiver/silent halt/escalate lines
    - All ALWAYS DO items unique to 020
  - Also assert absence of sections NOT in keep list (§5, §6, "stop" command, Channel-Routing Table, §4/§4.5)
  - Test MUST FAIL (some keep sections may be missing or removed sections may remain)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement fixes (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-9}`
  - Restore any keep sections that were accidentally removed
  - Remove any sections that should have been removed but remain
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

### Item 10: SC-10 — No content loss — removed sections verified as duplicated in 000

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-10}`
  - Write semantic test that compares removed section content against 000-critical-rules.md equivalents
  - Verify every rule text from removed sections exists verbatim in 000
  - Test MUST FAIL (some rule text may be missing from 000)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement fixes (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-10}`
  - If any rule text from removed sections is missing from 000, add it
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

### Item 11: SC-11 — No orphaned cross-references to removed section names

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-11}`
  - Write grep-based test that searches `.opencode/` for references to removed section names
  - Only 000-critical-rules.md may reference them
  - Test MUST FAIL (orphaned cross-references exist)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement fixes (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-11}`
  - Update any orphaned cross-references to point to 000-critical-rules.md equivalents
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

### Item 12: SC-12 — No line-count or word-count metrics used as success measurement

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-12}`
  - Write grep-based test that asserts absence of "wc -l", "file size", "Final file size" in the spec
  - Test MUST FAIL (metrics still present)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement fix (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-12}`
  - Remove any line-count or word-count metrics from the spec
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

### Item 13: SC-13 — Remove duplicate Node.js Prohibition section from 070-environment.md

- [ ] **RED phase** — write failing test (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-13}`
  - Write grep-based test that asserts absence of "Node.js Prohibition" section in 070-environment.md
  - Test MUST FAIL (section still exists)
- [ ] **Z3 check RED** (**inline**)
- [ ] **RED doublecheck** (**sub-agent**)
- [ ] **Z3 check RED doublecheck** (**inline**)
- [ ] **Post-RED enforcement** (**sub-agent**)
- [ ] **Z3 check post-RED** (**inline**)
- [ ] **GREEN phase** — implement removal (**sub-agent**)
  - Context: `{issue_number: 2127, sc_id: SC-13}`
  - Remove the duplicate Node.js Prohibition section (lines 224-257) from 070-environment.md
  - Update 085-project-local-tools.md cross-references to point to the new `.tools/` rule in 020 §4
- [ ] **Z3 check GREEN** (**inline**)
- [ ] **Post-GREEN enforcement** (**sub-agent**)
- [ ] **Z3 check post-GREEN** (**inline**)
- [ ] **Create checkpoint tag** (**sub-agent**)
- [ ] **Checkpoint commit** (**sub-agent**)

---

## Post-Implementation

### Structural Checks

- [ ] Dispatch `structural-checks` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Run lint, typecheck, and format checks on modified files

### Green Doublecheck

- [ ] Dispatch `green-doublecheck` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Verify all GREEN implementations are correct

### Verification Before Completion

- [ ] Dispatch `green-vbc` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Run full verification against all success criteria

### SC Count Gate

- [ ] Dispatch `sc-count-gate` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Reads `sc-summary.yaml` total SC count (13), counts verified SCs from VbC evidence
  - BLOCKs if `verified_count < 13`

### Pre-PR Gate

- [ ] Dispatch `pre-pr-gate` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Reads all SC verdicts, BLOCKs if any FAIL

### Audit

- [ ] Dispatch audit task from audit skill (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch via `task(subagent_type="general")` with `{spec_local_dir, artifact_evidence_dir}`
  - On non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, restart audit
  - On clean PASS: collect `artifact_path` for cross-validate

### Cross-Validate

- [ ] Dispatch `cross-validate` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127, auditor_artifact_paths}`
  - Dispatch string: `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`
  - Produce cross-validate findings

### Regression Check

- [ ] Dispatch `regression-check` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
  - Generate and run regression test patterns

### Review Prep

- [ ] Dispatch `review-prep` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`
  - Prepare PR for review

### Create PR

- [ ] Dispatch `create-pr` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127, authorization_scope: for_pr, halt_at: pr_created}`
  - Dispatch string: `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
  - Create pull request

### Completion

- [ ] Dispatch `exec-summary` from implementation-pipeline (**sub-agent**)
  - Context: `{issue_number: 2127}`
  - Dispatch string: `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`
  - Generate executive summary and append lifecycle event

## Lifecycle Events

- `2026-07-27T19:46:00Z` — `plan_created`
  - Plan file: `.opencode/.issues/2127/plan.md`
  - Phase count: 5
  - Dispatch mode: sub-agent (clean-room) for RED/GREEN phases, inline for Z3 checks
  - Pipeline signal: route to implementation-pipeline for execution
