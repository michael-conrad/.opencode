---
title: "Phase 1: Master decomposition criteria reference file"
issue: 2118
status: draft
created: 2026-07-25
phases:
  - id: phase-1
    sc: SC-1
    description: Create file with all 7 criteria headings
    evidence: structural
  - id: phase-2
    sc: SC-2
    description: Add PASS/FAIL binary decision tree format to each criterion
    evidence: string
  - id: phase-3
    sc: SC-3
    description: Spec-level criteria definitions (atomicity, single deliverable, binary verifiability, PR-gate viability)
    evidence: string
  - id: phase-4
    sc: SC-4
    description: Plan-level criteria definitions (acyclic DAG, file collision freedom, explicit dependency declaration)
    evidence: string
  - id: phase-5
    sc: SC-5
    description: Atomicity criterion trigger-word sub-check (and, or, comma-separated lists)
    evidence: string
  - id: phase-6
    sc: SC-6
    description: Binary verifiability disjunctive pattern and vague term sub-checks
    evidence: string
  - id: phase-7
    sc: SC-7
    description: PR-gate viability RED/GREEN meta principle reference
    evidence: string
  - id: phase-8
    sc: SC-8
    description: Maintainer note with inline copy locations
    evidence: string
  - id: phase-9
    sc: SC-9
    description: Behavioral test — sub-agent reads master reference and correctly identifies PASS/FAIL
    evidence: behavioral
---

# Implementation Plan — Issue #2118

## Overview

Create `audit/reference/decomposition-criteria.md` — a single source of truth for decomposition criteria definitions. 7 criteria total (4 spec-level + 3 plan-level), each with PASS/FAIL binary decision trees, trigger-word sub-checks, and examples.

## Phases

### Phase 1 — SC-1: File creation with all 7 criteria headings

| Step | Action |
|------|--------|
| RED | Write behavioral test: `opencode run` with prompt asking agent to create the file; assert file exists at `audit/reference/decomposition-criteria.md` |
| GREEN | Create `audit/reference/decomposition-criteria.md` with all 7 criteria as top-level headings (no content yet) |
| REFACTOR | Verify file path, heading count (7), no orphan content |
| COMMIT | `git add audit/reference/decomposition-criteria.md && git commit -m "feat: create decomposition-criteria.md with 7 criteria headings"` |

### Phase 2 — SC-2: PASS/FAIL binary decision tree format

| Step | Action |
|------|--------|
| RED | Write content-verification test: grep for `PASS` and `FAIL` branching in file |
| GREEN | Add binary decision tree format to each criterion heading — each criterion gets a `## Decision Tree` subsection with explicit `- PASS: ...` / `- FAIL: ...` branches |
| REFACTOR | Verify every criterion has at least one PASS and one FAIL branch; no prose-only criteria remain |
| COMMIT | `git commit -am "feat: add PASS/FAIL binary decision trees to all 7 criteria"` |

### Phase 3 — SC-3: Spec-level criteria definitions

| Step | Action |
|------|--------|
| RED | Write content-verification test: grep for headings `Atomicity`, `Single Deliverable`, `Binary Verifiability`, `PR-Gate Viability` |
| GREEN | Write full definitions for the 4 spec-level criteria under their headings. Each includes: purpose statement, decision tree, examples |
| REFACTOR | Verify all 4 headings present; verify each has PASS/FAIL from Phase 2 |
| COMMIT | `git commit -am "feat: add spec-level criteria definitions (atomicity, single deliverable, binary verifiability, PR-gate viability)"` |

### Phase 4 — SC-4: Plan-level criteria definitions

| Step | Action |
|------|--------|
| RED | Write content-verification test: grep for headings `Acyclic DAG`, `File Collision Freedom`, `Explicit Dependency Declaration` |
| GREEN | Write full definitions for the 3 plan-level criteria under their headings. Each includes: purpose statement, decision tree, examples |
| REFACTOR | Verify all 3 headings present; verify each has PASS/FAIL from Phase 2 |
| COMMIT | `git commit -am "feat: add plan-level criteria definitions (acyclic DAG, file collision freedom, explicit dependency declaration)"` |

### Phase 5 — SC-5: Atomicity trigger-word sub-check

| Step | Action |
|------|--------|
| RED | Write content-verification test: grep for trigger-word sub-check under Atomicity section (and, or, comma-separated lists) |
| GREEN | Add trigger-word sub-check to Atomicity criterion: check for `and`, `or`, comma-separated lists as indicators of non-atomic SCs |
| REFACTOR | Verify sub-check is under Atomicity heading; verify it references all 3 trigger patterns |
| COMMIT | `git commit -am "feat: add atomicity trigger-word sub-check (and, or, comma-separated lists)"` |

### Phase 6 — SC-6: Binary verifiability disjunctive and vague term sub-checks

| Step | Action |
|------|--------|
| RED | Write content-verification test: grep for disjunctive patterns (either/or, alternatively, one of) and vague terms (should, could, ideally, as appropriate) |
| GREEN | Add two sub-checks to Binary Verifiability criterion: (1) disjunctive pattern check — flag `either/or`, `alternatively`, `one of`; (2) vague term check — flag `should`, `could`, `ideally`, `as appropriate` |
| REFACTOR | Verify both sub-checks present under Binary Verifiability heading |
| COMMIT | `git commit -am "feat: add binary verifiability disjunctive and vague term sub-checks"` |

### Phase 7 — SC-7: PR-gate viability RED/GREEN reference

| Step | Action |
|------|--------|
| RED | Write content-verification test: grep for `RED` and `GREEN` reference under PR-Gate Viability |
| GREEN | Add meta RED/GREEN principle to PR-Gate Viability criterion: each spec is a RED, each PR merge is a GREEN |
| REFACTOR | Verify RED/GREEN reference is under PR-Gate Viability heading |
| COMMIT | `git commit -am "feat: add PR-gate viability RED/GREEN meta principle reference"` |

### Phase 8 — SC-8: Maintainer note

| Step | Action |
|------|--------|
| RED | Write content-verification test: grep for maintainer note referencing all 3 inline copy locations |
| GREEN | Add maintainer note at top or bottom of file listing the 3 files that maintain inline copies: `spec-creation/tasks/validate.md`, `audit/tasks/spec-audit-evaluator.md`, `writing-plans/tasks/validate.md` |
| REFACTOR | Verify all 3 file paths present in maintainer note |
| COMMIT | `git commit -am "feat: add maintainer note with inline copy locations"` |

### Phase 9 — SC-9: Behavioral test

| Step | Action |
|------|--------|
| RED | Write behavioral test: `opencode run` with prompt asking sub-agent to evaluate a sample SC against the master reference; assert correct PASS/FAIL classification |
| GREEN | Ensure the file content is complete enough that a sub-agent can correctly classify sample SCs. (Should already be complete after Phases 1-8.) |
| REFACTOR | Run behavioral test multiple times; verify consistent PASS/FAIL classification |
| COMMIT | `git commit -am "feat: add behavioral test for decomposition criteria classification"` |

## Dependency Graph

```
Phase 1 (SC-1) ──→ Phase 2 (SC-2) ──→ Phase 3 (SC-3) ──→ Phase 5 (SC-5)
                                        └──→ Phase 4 (SC-4)
                                        └──→ Phase 6 (SC-6)
                                        └──→ Phase 7 (SC-7)
                              Phase 8 (SC-8) ──→ Phase 9 (SC-9)
```

Phases 3-7 depend on Phase 2 (decision tree format must exist before content). Phase 5 depends on Phase 3 (Atomicity heading must exist). Phase 6 depends on Phase 3 (Binary Verifiability heading must exist). Phase 7 depends on Phase 3 (PR-Gate Viability heading must exist). Phase 9 depends on Phase 8 (maintainer note must exist before behavioral test).

## Result Contract

On completion: `status: DONE`, `artifact_path: audit/reference/decomposition-criteria.md`, `finding_summary: Created master decomposition criteria reference file with 7 criteria, PASS/FAIL decision trees, trigger-word sub-checks, maintainer note, and behavioral test.`
