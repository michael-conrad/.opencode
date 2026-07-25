---
plan_schema_version: "1.0"
issue: 2121
title: "Prune 000-critical-rules.md: move skill-specific rules to target files, keep 18 universal rules"
lifecycle_events:
  - timestamp: "2026-07-25T12:00:00Z"
    event: plan_created
    plan_path: ".opencode/.issues/2121/plan.md"
    phase_count: 6
dispatch:
  - phase: phase-1
    skill: test-driven-development
    task: green
  - phase: phase-2
    skill: test-driven-development
    task: green
  - phase: phase-3
    skill: test-driven-development
    task: green
  - phase: phase-4
    skill: test-driven-development
    task: green
  - phase: phase-5
    skill: test-driven-development
    task: green
  - phase: phase-6
    skill: verification-before-completion
    task: completion
---

# Implementation Plan: Prune 000-critical-rules.md

## Phase Table

| Phase | Name | Concern | SC Coverage | Dependencies |
|-------|------|---------|-------------|--------------|
| 1 | Embed moved rules into target files | embed-moved-rules | SC-3 | None |
| 2 | Remove intro cross-references and stubs | remove-intro-cross-refs | SC-1, SC-2 | Phase 1 |
| 3 | Remove moved rules from source | remove-moved-rules | SC-10 | Phase 2 |
| 4 | Strip dark prose from remaining rules | strip-dark-prose | SC-4, SC-5 | Phase 3 |
| 5 | Remove redundant FORBIDDEN/REQUIRED subsections | remove-redundant-paragraphs | SC-8 | Phase 4 |
| 6 | Verify all success criteria | verify-all-scs | SC-1 through SC-10 | Phase 5 |

## Exit Criteria

| SC ID | Criterion | Phase(s) | Verification Method |
|-------|-----------|----------|---------------------|
| SC-1 | No intro cross-references to AGENTS.md or guidelines directory | 2, 6 | grep count returns 0 |
| SC-2 | No Read[ cross-refs pointing to preloaded guidelines in moved rule bodies | 2, 6 | grep count returns 0 |
| SC-3 | All 123 moved rules embedded in target files with per-rule change reports | 1, 6 | grep confirmation per rule header |
| SC-4 | Per-entry dark prose framing replaced with direct rule statements | 4, 6 | grep count < 3 |
| SC-5 | All Why This Matters tables deleted | 4, 6 | grep count returns 0 |
| SC-6 | Mandate Tiering, Interaction Rule, Channel-Routing Table headings preserved | 6 | grep confirms all three present |
| SC-7 | All 18 universal rule headers present | 6 | grep confirms all 18 present |
| SC-8 | No title-restating paragraphs in remaining rules | 5, 6 | token-superset diff confirms none |
| SC-9 | No duplicate `### [critical-rules-` headers | 3, 6 | uniq -d returns 0 lines |
| SC-10 | Exactly 18 `### [critical-rules-` headers remain | 3, 6 | grep count returns 18 |

## Pre-implementation

### Coherence gate
- [ ] Dispatch `sc-coherence-gate` from implementation-pipeline
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
  - Verifies spec/plan coherence before any file modification

### Baseline check
- [ ] Dispatch `pre-red-baseline` from implementation-pipeline
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
  - Captures pre-change state of all affected files

---

## Phase 1: Embed moved rules into target files

**Concern:** For each (source rule, target file) entry in the Rules to Move table, append the rule's full header and body to the target file. Write per-rule change reports.
**SC coverage:** SC-3

### Item 1.1 — Append each moved rule's full header and body to its target file (SC-3)

- [ ] **sc-coherence-gate** — Verify coherence between spec and plan for this item
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **pre-red-baseline** — Capture pre-change state of target files
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **red-phase** — Write grep-based test that confirms each rule header is NOT yet in its target file
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-3
- [ ] **z3-check-red** — Verify RED state transition
  - (**inline**) Run `solve --task check` with RED contract
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **red-doublecheck** — Verify RED tests are correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-red-doublecheck** — Verify RED doublecheck state transition
  - (**inline**) Run `solve --task check` with RED doublecheck contract
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-red-enforcement** — Enforce RED gate
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-red** — Verify post-RED state transition
  - (**inline**) Run `solve --task check` with post-RED contract
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **green-phase** — For each of the 123 (source rule, target file) pairs: read the rule body from `000-critical-rules.md`, append the full `### [critical-rules-NNN]` header and body to the target file
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-3
- [ ] **z3-check-green** — Verify GREEN state transition
  - (**inline**) Run `solve --task check` with GREEN contract
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-green-enforcement** — Enforce GREEN gate
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-green** — Verify post-GREEN state transition
  - (**inline**) Run `solve --task check` with post-GREEN contract
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag for this item
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **checkpoint-commit** — Commit the changes
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **structural-checks** — Run lint/typecheck on modified files
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-doublecheck** — Verify GREEN implementation is correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-vbc** — Verification before completion for this item
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **sc-count-gate** — Verify SC-3 has a verdict
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2121}`

### Item 1.2 — Write per-rule change reports to `.opencode/.issues/2121/implementation-reports/<rule-id>.yaml` (SC-3)

- [ ] **sc-coherence-gate** — Verify coherence for this item
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **pre-red-baseline** — Capture pre-change state
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **red-phase** — Verify change report files do not exist
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-3
- [ ] **z3-check-red** — Verify RED state transition
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **red-doublecheck** — Verify RED tests
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-red-doublecheck** — Verify RED doublecheck state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-red-enforcement** — Enforce RED gate
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-red** — Verify post-RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **green-phase** — For each of the 123 moved rules, write a change report at `.opencode/.issues/2121/implementation-reports/<rule-id>.yaml` with: source line range, target line range, full header text, body byte count, tool-call evidence
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-3
- [ ] **z3-check-green** — Verify GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-green-enforcement** — Enforce GREEN gate
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-green** — Verify post-GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **checkpoint-commit** — Commit the change reports
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **structural-checks** — Run lint/typecheck
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-doublecheck** — Verify change reports are correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-vbc** — Verification before completion
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **sc-count-gate** — Verify SC-3 has a verdict
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2121}`

---

## Phase 2: Remove intro cross-references and stubs

**Concern:** Delete the two intro cross-references to AGENTS.md and the guidelines directory. Replace or remove Read[ cross-refs pointing to preloaded guidelines in moved rule bodies.
**SC coverage:** SC-1, SC-2

### Item 2.1 — Delete the two intro cross-references to AGENTS.md and the guidelines directory (SC-1)

- [ ] **sc-coherence-gate** — Verify coherence
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **pre-red-baseline** — Capture pre-change state
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **red-phase** — `grep -cE "Read \[the authoritative list|Read \[detailed rules"` returns 2
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-1
- [ ] **z3-check-red** — Verify RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **red-doublecheck** — Verify RED test
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-red-doublecheck** — Verify RED doublecheck state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-red-enforcement** — Enforce RED gate
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-red** — Verify post-RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **green-phase** — Delete the two intro cross-reference lines from `000-critical-rules.md`
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-1
- [ ] **z3-check-green** — Verify GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-green-enforcement** — Enforce GREEN gate
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-green** — Verify post-GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **checkpoint-commit** — Commit the deletion
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **structural-checks** — Run lint/typecheck
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-doublecheck** — Verify deletion is correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-vbc** — Verification before completion
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **sc-count-gate** — Verify SC-1 has a verdict
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2121}`

### Item 2.2 — Replace or remove each Read[ cross-ref pointing to preloaded guidelines in moved rule bodies (SC-2)

- [ ] **sc-coherence-gate** — Verify coherence
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **pre-red-baseline** — Capture pre-change state
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **red-phase** — `grep -cE "Read \[.*guidelines/0(10|20|60|65|67|75|80|90|91|117|130)"` returns 18
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-2
- [ ] **z3-check-red** — Verify RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **red-doublecheck** — Verify RED test
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-red-doublecheck** — Verify RED doublecheck state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-red-enforcement** — Enforce RED gate
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-red** — Verify post-RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **green-phase** — For each matching cross-ref in moved rule bodies, replace with the rule's own text or remove the cross-ref entirely
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-2
- [ ] **z3-check-green** — Verify GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-green-enforcement** — Enforce GREEN gate
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-green** — Verify post-GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **checkpoint-commit** — Commit the cross-ref replacements
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **structural-checks** — Run lint/typecheck
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-doublecheck** — Verify replacements are correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-vbc** — Verification before completion
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **sc-count-gate** — Verify SC-2 has a verdict
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2121}`

---

## Phase 3: Remove moved rules from 000-critical-rules.md

**Concern:** For each moved rule, delete the `### [critical-rules-NNN]` block from the source file. After all removals, verify exactly 18 headers remain.
**SC coverage:** SC-10

### Item 3.1 — Delete each moved rule's `### [critical-rules-NNN]` block from source file; verify exactly 18 headers remain (SC-10)

- [ ] **sc-coherence-gate** — Verify coherence
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **pre-red-baseline** — Capture pre-change state
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **red-phase** — `grep -cE "^### \[critical-rules-"` returns > 18
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-10
- [ ] **z3-check-red** — Verify RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **red-doublecheck** — Verify RED test
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-red-doublecheck** — Verify RED doublecheck state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-red-enforcement** — Enforce RED gate
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-red** — Verify post-RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **green-phase** — Delete each moved rule's `### [critical-rules-NNN]` block from `000-critical-rules.md`
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-10
- [ ] **z3-check-green** — Verify GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-green-enforcement** — Enforce GREEN gate
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-green** — Verify post-GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **checkpoint-commit** — Commit the removals
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **structural-checks** — Run lint/typecheck
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-doublecheck** — Verify removals are correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-vbc** — Verification before completion
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **sc-count-gate** — Verify SC-10 has a verdict
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2121}`

---

## Phase 4: Remove per-entry dark prose and Why This Matters tables

**Concern:** Replace per-entry "Professional engineers... amateurs..." framing with direct rule statements. Delete all Why This Matters tables.
**SC coverage:** SC-4, SC-5

### Item 4.1 — Replace per-entry dark prose framing with direct rule statements; keep file-level framing (SC-4)

- [ ] **sc-coherence-gate** — Verify coherence
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **pre-red-baseline** — Capture pre-change state
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **red-phase** — `grep -cE "Professional engineers|amateurs"` returns >= 3
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-4
- [ ] **z3-check-red** — Verify RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **red-doublecheck** — Verify RED test
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-red-doublecheck** — Verify RED doublecheck state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-red-enforcement** — Enforce RED gate
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-red** — Verify post-RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **green-phase** — Replace per-entry dark prose with direct rule statements in the 18 remaining universal rules
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-4
- [ ] **z3-check-green** — Verify GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-green-enforcement** — Enforce GREEN gate
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-green** — Verify post-GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **checkpoint-commit** — Commit dark prose replacements
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **structural-checks** — Run lint/typecheck
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-doublecheck** — Verify replacements are correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-vbc** — Verification before completion
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **sc-count-gate** — Verify SC-4 has a verdict
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2121}`

### Item 4.2 — Delete all Why This Matters tables (headers and bodies) (SC-5)

- [ ] **sc-coherence-gate** — Verify coherence
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **pre-red-baseline** — Capture pre-change state
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **red-phase** — `grep -cE "Why This Matters"` returns > 0
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-5
- [ ] **z3-check-red** — Verify RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **red-doublecheck** — Verify RED test
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-red-doublecheck** — Verify RED doublecheck state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-red-enforcement** — Enforce RED gate
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-red** — Verify post-RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **green-phase** — Delete all Why This Matters table headers and bodies from the 18 remaining universal rules
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-5
- [ ] **z3-check-green** — Verify GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-green-enforcement** — Enforce GREEN gate
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-green** — Verify post-GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **checkpoint-commit** — Commit table deletions
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **structural-checks** — Run lint/typecheck
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-doublecheck** — Verify table deletions are correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-vbc** — Verification before completion
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **sc-count-gate** — Verify SC-5 has a verdict
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2121}`

---

## Phase 5: Remove redundant FORBIDDEN/REQUIRED subsections

**Concern:** For each remaining universal rule, check whether FORBIDDEN/REQUIRED subsections add content beyond the rule header. Delete title-restating paragraphs per SC-8 token-superset definition.
**SC coverage:** SC-8

### Item 5.1 — For each remaining `### [critical-rules-NNN]` rule, tokenize title, diff each paragraph's token set against title's set, delete paragraphs that are title-restatements (SC-8)

- [ ] **sc-coherence-gate** — Verify coherence
  - (**sub-agent**) `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **pre-red-baseline** — Capture pre-change state
  - (**sub-agent**) `task(..., prompt: "execute pre-red-baseline from implementation-pipeline. Read \`implementation-pipeline/tasks/pre-red-baseline.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **red-phase** — Run token-superset analysis, identify restating paragraphs
  - (**sub-agent**) `task(..., prompt: "execute red from test-driven-development. Read \`test-driven-development/tasks/red.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-8
- [ ] **z3-check-red** — Verify RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **red-doublecheck** — Verify RED test
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-red-doublecheck** — Verify RED doublecheck state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-red-enforcement** — Enforce RED gate
  - (**sub-agent**) `task(..., prompt: "execute post-red-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-red-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-red** — Verify post-RED state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **green-phase** — Delete identified title-restating paragraphs from the 18 remaining universal rules
  - (**sub-agent**) `task(..., prompt: "execute green from test-driven-development. Read \`test-driven-development/tasks/green.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-8
- [ ] **z3-check-green** — Verify GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **post-green-enforcement** — Enforce GREEN gate
  - (**sub-agent**) `task(..., prompt: "execute post-green-enforcement from implementation-pipeline. Read \`implementation-pipeline/tasks/post-green-enforcement.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **z3-check-post-green** — Verify post-GREEN state
  - (**inline**) Run `solve --task check`
  - Context: `{issue_number: 2121, contract_path: <path>}`
- [ ] **checkpoint-tag-create** — Create checkpoint tag
  - (**sub-agent**) `task(..., prompt: "execute checkpoint-tag-create from implementation-pipeline. Read \`implementation-pipeline/tasks/checkpoint-tag-create.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **checkpoint-commit** — Commit paragraph deletions
  - (**sub-agent**) `task(..., prompt: "execute commit-prep from git-workflow. Read \`git-workflow/tasks/commit-prep.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **structural-checks** — Run lint/typecheck
  - (**sub-agent**) `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-doublecheck** — Verify paragraph deletions are correct
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **green-vbc** — Verification before completion
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
- [ ] **sc-count-gate** — Verify SC-8 has a verdict
  - (**sub-agent**) `task(..., prompt: "execute sc-count-gate from implementation-pipeline. Read \`implementation-pipeline/tasks/sc-count-gate.md\` first")`
  - Context: `{issue_number: 2121}`

---

## Phase 6: Verify all SCs

**Concern:** Run each SC's verification method and confirm PASS for all 10 SCs.
**SC coverage:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9, SC-10

### Item 6.1 — grep intro cross-refs — expect 0 (SC-1)

- [ ] **green-vbc** — Run `grep -cE "Read \[the authoritative list|Read \[detailed rules"` on `000-critical-rules.md`, confirm returns 0
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-1

### Item 6.2 — grep preloaded guideline cross-refs — expect 0 (SC-2)

- [ ] **green-vbc** — Run `grep -cE "Read \[.*guidelines/0(10|20|60|65|67|75|80|90|91|117|130)"` on `000-critical-rules.md`, confirm returns 0
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-2

### Item 6.3 — Verify 123 per-rule change reports exist with full-header grep confirmation (SC-3)

- [ ] **green-vbc** — For each (source rule, target file) pair, `grep -qF "<full header text>" <target file>`, confirm all 123 return 0
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-3

### Item 6.4 — grep dark prose count — expect < 3 (SC-4)

- [ ] **green-vbc** — Run `grep -cE "Professional engineers|amateurs"` on `000-critical-rules.md`, confirm returns < 3
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-4

### Item 6.5 — grep Why This Matters — expect 0 (SC-5)

- [ ] **green-vbc** — Run `grep -cE "Why This Matters"` on `000-critical-rules.md`, confirm returns 0
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-5

### Item 6.6 — Verify Mandate Tiering, Interaction Rule, Channel-Routing Table headings remain (SC-6)

- [ ] **green-vbc** — Run `grep -qE "^## Mandate Tiering"`, `grep -qE "^### Interaction Rule"`, `grep -qE "^### Channel-Routing Table"` on `000-critical-rules.md`, confirm all three return 0
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-6

### Item 6.7 — Verify all 18 universal rule headers are present (SC-7)

- [ ] **green-vbc** — For each of the 18 universal rule headers, `grep -qF "<full header text>"` on `000-critical-rules.md`, confirm all 18 return 0
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-7

### Item 6.8 — Re-run token-superset analysis — confirm no title-restating paragraphs (SC-8)

- [ ] **green-vbc** — Run token-superset diff for each remaining rule body, confirm no title-restating paragraphs found
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-8

### Item 6.9 — Verify no duplicate headers (SC-9)

- [ ] **green-vbc** — Run `grep -E "^### \[critical-rules-" | sort | uniq -d` on `000-critical-rules.md`, confirm returns 0 lines
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-9

### Item 6.10 — Verify exactly 18 rule headers (SC-10)

- [ ] **green-vbc** — Run `grep -cE "^### \[critical-rules-"` on `000-critical-rules.md`, confirm returns 18
  - (**sub-agent**) `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
  - SC-ID: SC-10

---

## Post-implementation

### Pre-PR gate
- [ ] Dispatch `pre-pr-gate` from implementation-pipeline
  - (**sub-agent**) `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
  - Context: `{issue_number: 2121}`
  - Reads all SC verdicts, BLOCKs if any FAIL

### Audit
- [ ] Dispatch audit task from audit skill
  - (**sub-agent**) `task(subagent_type="general")`
  - Context: `{spec_local_dir: ".opencode/.issues/2121", artifact_evidence_dir: ".opencode/.issues/2121/artifacts"}`
  - If non-clean-pass (FAIL): remediate root cause, then restart audit
  - `DONE_WITH_CONCERNS` coerced to FAIL

### Cross-validate
- [ ] Dispatch `cross-validate` from audit
  - (**sub-agent**) `task(..., prompt: "execute cross-validate from audit. Read \`audit/tasks/cross-validate.md\` first")`
  - Context: `{issue_number: 2121}`

### Regression check
- [ ] Dispatch `regression-check` from implementation-pipeline
  - (**sub-agent**) `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
  - Context: `{issue_number: 2121}`

### Review prep
- [ ] Dispatch `review-prep` from git-workflow
  - (**sub-agent**) `task(..., prompt: "execute review-prep from git-workflow. Read \`git-workflow/tasks/review-prep.md\` first")`
  - Context: `{issue_number: 2121}`

### Create PR
- [ ] Dispatch `create-pr` from pr-creation-workflow
  - (**sub-agent**) `task(..., prompt: "execute create from pr-creation-workflow. Read \`pr-creation-workflow/tasks/create.md\` first")`
  - Context: `{issue_number: 2121, authorization_scope: for_pr, halt_at: pr_created}`

### Completion
- [ ] Dispatch `exec-summary` from completion-core
  - (**sub-agent**) `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`
  - Context: `{issue_number: 2121}`
