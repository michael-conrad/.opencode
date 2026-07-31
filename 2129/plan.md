---
issue: 2129
spec: Compact 065-verification-honesty.md
authorization_scope: for_plan
halt_at: plan_created
created: 2026-07-30
---

# Plan: Compact 065-verification-honesty.md

## Overview

Compact `065-verification-honesty.md` by removing 12 sections (explanatory, stubs, or procedural), collapsing Zero Tolerance + Core Principle, removing Evidence Hierarchy table, removing Metadata Verification master table and distributing rows to skill task files, removing critical-rules stubs and Fabricating URLs orphan. Cross-reference cleanup: remove DDL footnotes from 080 and 020, remove DONE_WITH_CONCERNS coercion rule from implementation-pipeline. Inline 3 sections to skill task files.

All 17 SCs are string-type grep verifications.

## Phases

### Phase 1: Remove sections from 065 (SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9b, SC-14)

Remove the following sections from `065-verification-honesty.md`:
- `## Problem` (SC-2)
- `## What Constitutes "Checking"` (SC-3)
- `## Memory vs. Verified Distinction` (SC-4)
- `## Single Exchange Window` (SC-5)
- `## Relationship to Other Guidelines` (SC-6)
- `## Verification-Enforcement Boundary` (SC-7)
- `## Hard Failure Discipline — Universal Invariant` (SC-8)
- `## Evidence Hierarchy` (SC-9b)
- End-of-file critical-rules stubs + Fabricating URLs (SC-14)

**Files affected:** `.opencode/guidelines/065-verification-honesty.md`

**Verification:** grep each removed heading — must not be found.

### Phase 2: Collapse Zero Tolerance + Core Principle (SC-1)

Merge `## Zero Tolerance Rule` and `## Core Principle` into a single `## Zero Tolerance Rule` section. Keep the core principle text as the first paragraph under the heading. Remove the `## Core Principle` heading.

**Files affected:** `.opencode/guidelines/065-verification-honesty.md`

**Verification:** Only one `## Zero Tolerance Rule` heading exists; no `## Core Principle` heading remains.

### Phase 3: Inline content to task files (SC-11, SC-12, SC-13)

**SC-11:** Inline Verification Comparison Semantics into `verification-before-completion/tasks/operating-protocol.md`. Add sections for "Verification Comparison Semantics", "exact match for external", and "Per-Field Independence".

**SC-12:** Inline Anti-Evasion Rules + verification artifact manifest into `verification-before-completion/tasks/operating-protocol.md`. Add sections for "Anti-Evasion Rules" and "verification artifact manifest".

**SC-13:** Inline Metadata Verification subsets into:
- `verification-before-completion/tasks/operating-protocol.md`
- At least one `audit/tasks/` file
- At least one `issue-operations-core/tasks/` file

**Files affected:**
- `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`
- `.opencode/skills/audit/tasks/` (one or more files)
- `.opencode/skills/issue-operations-core/tasks/` (one or more files)

**Verification:** grep for "Verification Comparison", "exact match for external", "Per-Field Independence" in operating-protocol.md; "Anti-Evasion" and "verification artifact manifest" in operating-protocol.md; "Metadata Verification" or "No Metadata Trust" in operating-protocol.md AND audit/task file AND issue-operations-core/task file.

### Phase 4: Remove Metadata Verification master table from 065 (SC-10)

Remove the `## Metadata Verification Extension` section (including the master table) from `065-verification-honesty.md`.

**Files affected:** `.opencode/guidelines/065-verification-honesty.md`

**Verification:** No "Metadata Categories Requiring Verification" text exists in 065.

### Phase 5: Cross-reference cleanup (SC-15, SC-16, SC-17)

**SC-15:** Remove DDL cross-reference footnote from `080-code-standards.md` Evidence Type Taxonomy. Remove the "Cost explanation" text that references 065.

**SC-16:** Remove DDL cross-reference from `020-go-prohibitions.md` cost-blind section. Remove the "065.*Cost Model" reference.

**SC-17:** Remove DONE_WITH_CONCERNS coercion rule from `implementation-pipeline/SKILL.md`. Remove any "DONE_WITH_CONCERNS" text.

**Files affected:**
- `.opencode/guidelines/080-code-standards.md`
- `.opencode/guidelines/020-go-prohibitions.md`
- `.opencode/skills/implementation-pipeline/SKILL.md`

**Verification:** grep for "Cost explanation" in 080 — not found; grep for "065.*Cost Model" in 020 — not found; grep for "DONE_WITH_CONCERNS" in implementation-pipeline/SKILL.md — not found.

### Phase 6: Verify kept sections (SC-9a)

Verify that the following sections remain in `065-verification-honesty.md`:
- `## Evidence Requirement`
- `## No Exceptions`
- `## Pre-Response Factual Claim Gate`
- `## 🚫 FORBIDDEN`
- `## ✅ REQUIRED`

**Files affected:** `.opencode/guidelines/065-verification-honesty.md`

**Verification:** grep for each heading — all must be present.

### Phase 7: Final verification (all SCs)

Run all SC verifications:
- SC-1: One `## Zero Tolerance Rule`, no `## Core Principle`
- SC-2: No `^## Problem$`
- SC-3: No "What Constitutes"
- SC-4: No "Memory vs"
- SC-5: No "Single Exchange Window"
- SC-6: No "Relationship to Other Guidelines"
- SC-7: No "Verification-Enforcement Boundary"
- SC-8: No "Hard Failure Discipline"
- SC-9a: All 5 kept headings present
- SC-9b: No "Evidence Hierarchy"
- SC-10: No "Metadata Categories Requiring Verification"
- SC-11: "Verification Comparison", "exact match for external", "Per-Field Independence" in operating-protocol.md
- SC-12: "Anti-Evasion" and "verification artifact manifest" in operating-protocol.md
- SC-13: "Metadata Verification" or "No Metadata Trust" in operating-protocol.md AND audit/task file AND issue-operations-core/task file
- SC-14: 065 line count under 375
- SC-15: No "Cost explanation" in 080
- SC-16: No "065.*Cost Model" in 020
- SC-17: No "DONE_WITH_CONCERNS" in implementation-pipeline/SKILL.md

## TDD Cycle

Each SC is string-type — RED/GREEN per SC via grep verification. All phases are independent (no cross-phase dependencies), so they can be executed in any order.

## Execution Strategy

Sequential: Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7
