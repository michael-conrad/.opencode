---
plan_schema_version: "1.0"
issue: 2129
title: "Compact 065-verification-honesty.md — remove sections, inline content, cross-reference cleanup"
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
    task: verify
---

# Implementation Plan: Compact 065-verification-honesty.md

## Pre-implementation

- [ ] **Coherence gate.** Dispatch `audit --task coherence-maintenance` to verify spec/plan coherence before any RED routing. (**sub-agent**)
  - Context: issue 2129, spec at `.opencode/.issues/2129/spec.md`, structure at `.opencode/.issues/2129/artifacts/structure.yaml`
- [ ] **Baseline check.** Verify current state of all target files before modification. (**inline**)
  - Run `wc -l .opencode/guidelines/065-verification-honesty.md` to record baseline line count
  - Run `grep -c "DONE_WITH_CONCERNS" .opencode/skills/writing-plans/reference/implementation-workflow.md` to record baseline
  - Run `grep -c "Cost explanation" .opencode/guidelines/080-code-standards.md` to record baseline
  - Run `grep -c "065.*Cost Model" .opencode/guidelines/020-go-prohibitions.md` to record baseline

---

## Phase 1: Remove 9 sections from 065

**Concern:** Remove explanatory/procedural sections from 065-verification-honesty.md  
**SCs covered:** SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8, SC-9b, SC-14

### Task 1.1 — Remove Problem section (SC-2)

- [ ] **RED.** Write a grep test that verifies `^## Problem$` heading exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -n "^## Problem$" .opencode/guidelines/065-verification-honesty.md` — must return a match
- [ ] **GREEN.** Edit 065 to remove the Problem section (from `## Problem` heading through the next `## ` heading). (**inline**)
  - SC-ID: SC-2
- [ ] **Verify.** Run grep test to confirm `^## Problem$` is absent from 065. (**inline**)
  - `grep -n "^## Problem$" .opencode/guidelines/065-verification-honesty.md` — must return no match
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove Problem section from 065 (SC-2)"` (**inline**)

### Task 1.2 — Remove What Constitutes Checking table (SC-3)

- [ ] **RED.** Write a grep test that verifies "What Constitutes" text exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -n "What Constitutes" .opencode/guidelines/065-verification-honesty.md` — must return a match
- [ ] **GREEN.** Edit 065 to remove the What Constitutes Checking section. (**inline**)
  - SC-ID: SC-3
- [ ] **Verify.** Run grep test to confirm "What Constitutes" is absent from 065. (**inline**)
  - `grep -n "What Constitutes" .opencode/guidelines/065-verification-honesty.md` — must return no match
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove What Constitutes Checking from 065 (SC-3)"` (**inline**)

### Task 1.3 — Remove Memory vs Verified table (SC-4)

- [ ] **RED.** Write a grep test that verifies "Memory vs" text exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -n "Memory vs" .opencode/guidelines/065-verification-honesty.md` — must return a match
- [ ] **GREEN.** Edit 065 to remove the Memory vs Verified section. (**inline**)
  - SC-ID: SC-4
- [ ] **Verify.** Run grep test to confirm "Memory vs" is absent from 065. (**inline**)
  - `grep -n "Memory vs" .opencode/guidelines/065-verification-honesty.md` — must return no match
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove Memory vs Verified from 065 (SC-4)"` (**inline**)

### Task 1.4 — Remove Single Exchange Window (SC-5)

- [ ] **RED.** Write a grep test that verifies "Single Exchange Window" text exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -n "Single Exchange Window" .opencode/guidelines/065-verification-honesty.md` — must return a match
- [ ] **GREEN.** Edit 065 to remove the Single Exchange Window section. (**inline**)
  - SC-ID: SC-5
- [ ] **Verify.** Run grep test to confirm "Single Exchange Window" is absent from 065. (**inline**)
  - `grep -n "Single Exchange Window" .opencode/guidelines/065-verification-honesty.md` — must return no match
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove Single Exchange Window from 065 (SC-5)"` (**inline**)

### Task 1.5 — Remove Relationship to Other Guidelines (SC-6)

- [ ] **RED.** Write a grep test that verifies "Relationship to Other Guidelines" text exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -n "Relationship to Other Guidelines" .opencode/guidelines/065-verification-honesty.md` — must return a match
- [ ] **GREEN.** Edit 065 to remove the Relationship to Other Guidelines section. (**inline**)
  - SC-ID: SC-6
- [ ] **Verify.** Run grep test to confirm "Relationship to Other Guidelines" is absent from 065. (**inline**)
  - `grep -n "Relationship to Other Guidelines" .opencode/guidelines/065-verification-honesty.md` — must return no match
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove Relationship to Other Guidelines from 065 (SC-6)"` (**inline**)

### Task 1.6 — Remove Verification-Enforcement Boundary (SC-7)

- [ ] **RED.** Write a grep test that verifies "Verification-Enforcement Boundary" text exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -n "Verification-Enforcement Boundary" .opencode/guidelines/065-verification-honesty.md` — must return a match
- [ ] **GREEN.** Edit 065 to remove the Verification-Enforcement Boundary section. (**inline**)
  - SC-ID: SC-7
- [ ] **Verify.** Run grep test to confirm "Verification-Enforcement Boundary" is absent from 065. (**inline**)
  - `grep -n "Verification-Enforcement Boundary" .opencode/guidelines/065-verification-honesty.md` — must return no match
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove Verification-Enforcement Boundary from 065 (SC-7)"` (**inline**)

### Task 1.7 — Remove Hard Failure Discipline + DDL + DONE_WITH_CONCERNS + Remediation-First (SC-8)

- [ ] **RED.** Write a grep test that verifies "Hard Failure Discipline" text exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -n "Hard Failure Discipline" .opencode/guidelines/065-verification-honesty.md` — must return a match
- [ ] **GREEN.** Edit 065 to remove the Hard Failure Discipline section (including DDL cost model, DONE_WITH_CONCERNS, Remediation-First subsections). (**inline**)
  - SC-ID: SC-8
- [ ] **Verify.** Run grep test to confirm "Hard Failure Discipline" is absent from 065. (**inline**)
  - `grep -n "Hard Failure Discipline" .opencode/guidelines/065-verification-honesty.md` — must return no match
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove Hard Failure Discipline from 065 (SC-8)"` (**inline**)

### Task 1.8 — Remove Evidence Hierarchy table (SC-9b)

- [ ] **RED.** Write a grep test that verifies "Evidence Hierarchy" text exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -n "Evidence Hierarchy" .opencode/guidelines/065-verification-honesty.md` — must return a match
- [ ] **GREEN.** Edit 065 to remove the Evidence Hierarchy table section. (**inline**)
  - SC-ID: SC-9b
- [ ] **Verify.** Run grep test to confirm "Evidence Hierarchy" is absent from 065. (**inline**)
  - `grep -n "Evidence Hierarchy" .opencode/guidelines/065-verification-honesty.md` — must return no match
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove Evidence Hierarchy table from 065 (SC-9b)"` (**inline**)

### Task 1.9 — Remove critical-rules stubs + Fabricating URLs (SC-14)

- [ ] **RED.** Record current line count of 065. (**inline**)
  - `wc -l < .opencode/guidelines/065-verification-honesty.md` — record value
- [ ] **GREEN.** Edit 065 to remove the end-of-file critical-rules stubs and Fabricating URLs section. (**inline**)
  - SC-ID: SC-14
- [ ] **Verify.** Confirm 065 line count is under 375 lines. (**inline**)
  - `wc -l < .opencode/guidelines/065-verification-honesty.md` — must be < 375
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-1: remove critical-rules stubs and Fabricating URLs from 065 (SC-14)"` (**inline**)

---

## Phase 2: Collapse Zero Tolerance + Core Principle

**Concern:** Merge duplicate restatements into one section  
**SCs covered:** SC-1  
**Depends on:** Phase 1 (sections must be removed first)

### Task 2.1 — Collapse Zero Tolerance + Core Principle (SC-1)

- [ ] **RED.** Write a grep test that verifies both `## Zero Tolerance Rule` and `## Core Principle` headings exist in 065 (expect FAIL — both present). (**inline**)
  - `grep -c "^## Zero Tolerance Rule" .opencode/guidelines/065-verification-honesty.md` — must be 1
  - `grep -c "^## Core Principle" .opencode/guidelines/065-verification-honesty.md` — must be 1
- [ ] **GREEN.** Edit 065 to merge the two sections: keep the `## Zero Tolerance Rule` heading, remove the `## Core Principle` heading, and consolidate content under the single heading. (**inline**)
  - SC-ID: SC-1
- [ ] **Verify.** Confirm only one `## Zero Tolerance Rule` heading exists and no `## Core Principle` heading remains. (**inline**)
  - `grep -c "^## Zero Tolerance Rule" .opencode/guidelines/065-verification-honesty.md` — must be 1
  - `grep -c "^## Core Principle" .opencode/guidelines/065-verification-honesty.md` — must be 0
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-2: collapse Zero Tolerance and Core Principle into one section (SC-1)"` (**inline**)

---

## Phase 3: Inline content to task files

**Concern:** Move procedural content from 065 to skill task files where sub-agents read it  
**SCs covered:** SC-11a, SC-11b, SC-12a, SC-12b  
**Depends on:** Phase 1 (sections must be removed from 065 first)

### Task 3.1 — Inline Verification Comparison Semantics in operating-protocol.md (SC-11a)

- [ ] **RED.** Verify "Verification Comparison" text is NOT yet present in operating-protocol.md (expect FAIL — not yet inlined). (**inline**)
  - `grep -c "Verification Comparison" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be 0
- [ ] **GREEN.** Read the Verification Comparison Semantics section from 065, then append it to `operating-protocol.md` as a new subsection. (**sub-agent**)
  - SC-ID: SC-11a
  - Dispatch: `execute green from test-driven-development. Read test-driven-development/tasks/green.md first`
  - Context: read 065 section "Verification Comparison Semantics", append to `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`
- [ ] **Verify.** Confirm "Verification Comparison", "exact match for external", and "Per-Field Independence" are all present in operating-protocol.md. (**inline**)
  - `grep -c "Verification Comparison" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be >= 1
  - `grep -c "exact match for external" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be >= 1
  - `grep -c "Per-Field Independence" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be >= 1
- [ ] **Commit.** `git add .opencode/skills/verification-before-completion/tasks/operating-protocol.md && git commit -m "phase-3: inline Verification Comparison Semantics to operating-protocol.md (SC-11a)"` (**inline**)

### Task 3.2 — Remove Verification Comparison Semantics from 065 (SC-11b)

- [ ] **RED.** Verify "Verification Comparison" text still exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -c "Verification Comparison" .opencode/guidelines/065-verification-honesty.md` — must be >= 1
- [ ] **GREEN.** Edit 065 to remove the Verification Comparison Semantics section. (**inline**)
  - SC-ID: SC-11b
- [ ] **Verify.** Confirm "Verification Comparison" is absent from 065. (**inline**)
  - `grep -c "Verification Comparison" .opencode/guidelines/065-verification-honesty.md` — must be 0
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-3: remove Verification Comparison Semantics from 065 (SC-11b)"` (**inline**)

### Task 3.3 — Inline Anti-Evasion Rules + verification artifact manifest in operating-protocol.md (SC-12a)

- [ ] **RED.** Verify "Anti-Evasion" text is NOT yet present in operating-protocol.md (expect FAIL — not yet inlined). (**inline**)
  - `grep -c "Anti-Evasion" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be 0
- [ ] **GREEN.** Read the Anti-Evasion Rules section from 065, then append it to `operating-protocol.md` as a new subsection. (**sub-agent**)
  - SC-ID: SC-12a
  - Dispatch: `execute green from test-driven-development. Read test-driven-development/tasks/green.md first`
  - Context: read 065 section "Anti-Evasion Rules", append to `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`
- [ ] **Verify.** Confirm "Anti-Evasion" and "verification artifact manifest" are both present in operating-protocol.md. (**inline**)
  - `grep -c "Anti-Evasion" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be >= 1
  - `grep -c "verification artifact manifest" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be >= 1
- [ ] **Commit.** `git add .opencode/skills/verification-before-completion/tasks/operating-protocol.md && git commit -m "phase-3: inline Anti-Evasion Rules to operating-protocol.md (SC-12a)"` (**inline**)

### Task 3.4 — Remove Anti-Evasion Rules from 065 (SC-12b)

- [ ] **RED.** Verify "Anti-Evasion" text still exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -c "Anti-Evasion" .opencode/guidelines/065-verification-honesty.md` — must be >= 1
- [ ] **GREEN.** Edit 065 to remove the Anti-Evasion Rules section. (**inline**)
  - SC-ID: SC-12b
- [ ] **Verify.** Confirm "Anti-Evasion" is absent from 065. (**inline**)
  - `grep -c "Anti-Evasion" .opencode/guidelines/065-verification-honesty.md` — must be 0
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-3: remove Anti-Evasion Rules from 065 (SC-12b)"` (**inline**)

---

## Phase 4: Remove Metadata Verification master table + distribute rows

**Concern:** Remove master table from 065 and distribute rows to skill task files  
**SCs covered:** SC-10a, SC-10b, SC-10c, SC-10d, SC-10e  
**Depends on:** Phase 1 (sections must be removed from 065 first)

### Task 4.1 — Remove Metadata Verification master table from 065 (SC-10a)

- [ ] **RED.** Verify "Metadata Categories Requiring Verification" text exists in 065 (expect FAIL — content still present). (**inline**)
  - `grep -c "Metadata Categories Requiring Verification" .opencode/guidelines/065-verification-honesty.md` — must be >= 1
- [ ] **GREEN.** Edit 065 to remove the Metadata Verification Extension section (including the master table). (**inline**)
  - SC-ID: SC-10a
- [ ] **Verify.** Confirm "Metadata Categories Requiring Verification" is absent from 065. (**inline**)
  - `grep -c "Metadata Categories Requiring Verification" .opencode/guidelines/065-verification-honesty.md` — must be 0
- [ ] **Commit.** `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "phase-4: remove Metadata Verification master table from 065 (SC-10a)"` (**inline**)

### Task 4.2 — Distribute Metadata Verification rows to VbC operating-protocol.md (SC-10b)

- [ ] **RED.** Verify "Metadata Verification" or "No Metadata Trust" is NOT yet present in operating-protocol.md (expect FAIL — not yet distributed). (**inline**)
  - `grep -c -E "Metadata Verification|No Metadata Trust" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be 0
- [ ] **GREEN.** Append the Metadata Verification rows relevant to VbC (Metadata Categories Requiring Verification table, No Metadata Trust Exceptions) to `operating-protocol.md`. (**sub-agent**)
  - SC-ID: SC-10b
  - Dispatch: `execute green from test-driven-development. Read test-driven-development/tasks/green.md first`
  - Context: read 065 section "Metadata Verification Extension", extract rows relevant to VbC, append to `.opencode/skills/verification-before-completion/tasks/operating-protocol.md`
- [ ] **Verify.** Confirm "Metadata Verification" or "No Metadata Trust" is present in operating-protocol.md. (**inline**)
  - `grep -c -E "Metadata Verification|No Metadata Trust" .opencode/skills/verification-before-completion/tasks/operating-protocol.md` — must be >= 1
- [ ] **Commit.** `git add .opencode/skills/verification-before-completion/tasks/operating-protocol.md && git commit -m "phase-4: distribute Metadata Verification rows to operating-protocol.md (SC-10b)"` (**inline**)

### Task 4.3 — Distribute Metadata Verification rows to audit task files (SC-10c)

- [ ] **RED.** Verify "Metadata Verification" or "No Metadata Trust" is NOT yet present in any audit task file (expect FAIL — not yet distributed). (**inline**)
  - `grep -c -r -E "Metadata Verification|No Metadata Trust" .opencode/skills/audit/tasks/` — must be 0
- [ ] **GREEN.** Append the Metadata Verification rows relevant to audit (Metadata Categories Requiring Verification table, No Metadata Trust Exceptions) to the appropriate audit task file(s). (**sub-agent**)
  - SC-ID: SC-10c
  - Dispatch: `execute green from test-driven-development. Read test-driven-development/tasks/green.md first`
  - Context: read 065 section "Metadata Verification Extension", extract rows relevant to audit, append to `.opencode/skills/audit/tasks/`
- [ ] **Verify.** Confirm "Metadata Verification" or "No Metadata Trust" is present in at least one audit task file. (**inline**)
  - `grep -c -r -E "Metadata Verification|No Metadata Trust" .opencode/skills/audit/tasks/` — must be >= 1
- [ ] **Commit.** `git add .opencode/skills/audit/tasks/ && git commit -m "phase-4: distribute Metadata Verification rows to audit task files (SC-10c)"` (**inline**)

### Task 4.4 — Distribute Metadata Verification rows to issue-operations-core task files (SC-10d)

- [ ] **RED.** Verify "Metadata Verification" or "No Metadata Trust" is NOT yet present in any issue-operations-core task file (expect FAIL — not yet distributed). (**inline**)
  - `grep -c -r -E "Metadata Verification|No Metadata Trust" .opencode/skills/issue-operations-core/tasks/` — must be 0
- [ ] **GREEN.** Append the Metadata Verification rows relevant to issue-operations-core (Metadata Categories Requiring Verification table, No Metadata Trust Exceptions) to the appropriate issue-operations-core task file(s). (**sub-agent**)
  - SC-ID: SC-10d
  - Dispatch: `execute green from test-driven-development. Read test-driven-development/tasks/green.md first`
  - Context: read 065 section "Metadata Verification Extension", extract rows relevant to issue-operations-core, append to `.opencode/skills/issue-operations-core/tasks/`
- [ ] **Verify.** Confirm "Metadata Verification" or "No Metadata Trust" is present in at least one issue-operations-core task file. (**inline**)
  - `grep -c -r -E "Metadata Verification|No Metadata Trust" .opencode/skills/issue-operations-core/tasks/` — must be >= 1
- [ ] **Commit.** `git add .opencode/skills/issue-operations-core/tasks/ && git commit -m "phase-4: distribute Metadata Verification rows to issue-operations-core task files (SC-10d)"` (**inline**)

### Task 4.5 — Verify no back-links from 065 to Metadata Verification (SC-10e)

- [ ] **RED.** Verify "Metadata Verification" text still exists in 065 (expect FAIL — content still present from SC-10a removal). (**inline**)
  - `grep -c "Metadata Verification" .opencode/guidelines/065-verification-honesty.md` — must be 0
- [ ] **GREEN.** No edit needed — SC-10a already removed the section. This is a verification-only task. (**inline**)
  - SC-ID: SC-10e
- [ ] **Verify.** Confirm "Metadata Verification" is absent from 065. (**inline**)
  - `grep -c "Metadata Verification" .opencode/guidelines/065-verification-honesty.md` — must be 0
- [ ] **Commit.** No commit needed — verification-only task. (**inline**)

---

## Phase 5: Cross-reference cleanup

**Concern:** Remove DDL cross-references from 080, 020, and writing-plans/reference/implementation-workflow.md  
**SCs covered:** SC-15, SC-16, SC-17

### Task 5.1 — Remove DDL cross-reference footnote from 080-code-standards.md (SC-15)

- [ ] **RED.** Verify "Cost explanation" text exists in 080-code-standards.md (expect FAIL — content still present). (**inline**)
  - `grep -c "Cost explanation" .opencode/guidelines/080-code-standards.md` — must be >= 1
- [ ] **GREEN.** Edit 080-code-standards.md to remove the DDL cross-reference footnote (the "Cost explanation: Read §Cost Model" reference). (**inline**)
  - SC-ID: SC-15
- [ ] **Verify.** Confirm "Cost explanation" is absent from 080-code-standards.md. (**inline**)
  - `grep -c "Cost explanation" .opencode/guidelines/080-code-standards.md` — must be 0
- [ ] **Commit.** `git add .opencode/guidelines/080-code-standards.md && git commit -m "phase-5: remove DDL cross-reference footnote from 080 (SC-15)"` (**inline**)

### Task 5.2 — Remove DDL cross-reference from 020-go-prohibitions.md (SC-16)

- [ ] **RED.** Verify "065.*Cost Model" pattern exists in 020-go-prohibitions.md (expect FAIL — content still present). (**inline**)
  - `grep -c -E "065.*Cost Model" .opencode/guidelines/020-go-prohibitions.md` — must be >= 1
- [ ] **GREEN.** Edit 020-go-prohibitions.md to remove the DDL cross-reference to 065. (**inline**)
  - SC-ID: SC-16
- [ ] **Verify.** Confirm "065.*Cost Model" pattern is absent from 020-go-prohibitions.md. (**inline**)
  - `grep -c -E "065.*Cost Model" .opencode/guidelines/020-go-prohibitions.md` — must be 0
- [ ] **Commit.** `git add .opencode/guidelines/020-go-prohibitions.md && git commit -m "phase-5: remove DDL cross-reference from 020 (SC-16)"` (**inline**)

### Task 5.3 — Remove DONE_WITH_CONCERNS coercion rule from writing-plans/reference/implementation-workflow.md (SC-17)

- [ ] **RED.** Verify "DONE_WITH_CONCERNS" text exists in writing-plans/reference/implementation-workflow.md (expect FAIL — content still present). (**inline**)
  - `grep -c "DONE_WITH_CONCERNS" .opencode/skills/writing-plans/reference/implementation-workflow.md` — must be >= 1
- [ ] **GREEN.** Edit writing-plans/reference/implementation-workflow.md to remove the DONE_WITH_CONCERNS Coercion Rule section. (**inline**)
  - SC-ID: SC-17
- [ ] **Verify.** Confirm "DONE_WITH_CONCERNS" is absent from writing-plans/reference/implementation-workflow.md. (**inline**)
  - `grep -c "DONE_WITH_CONCERNS" .opencode/skills/writing-plans/reference/implementation-workflow.md` — must be 0
- [ ] **Commit.** `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "phase-5: remove DONE_WITH_CONCERNS coercion rule from writing-plans reference (SC-17)"` (**inline**)

---

## Phase 6: Verify kept sections remain in 065

**Concern:** Verify that core enforcement sections were preserved during compaction  
**SCs covered:** SC-9a1, SC-9a2, SC-9a3, SC-9a4  
**Depends on:** Phase 1 (removal must be complete)

### Task 6.1 — Verify Evidence Requirement heading (SC-9a1)

- [ ] **Verify.** Confirm `## Evidence Requirement` heading is present in 065. (**inline**)
  - `grep -c "^## Evidence Requirement" .opencode/guidelines/065-verification-honesty.md` — must be >= 1
  - SC-ID: SC-9a1

### Task 6.2 — Verify No Exceptions heading (SC-9a2)

- [ ] **Verify.** Confirm `## No Exceptions` heading is present in 065. (**inline**)
  - `grep -c "^## No Exceptions" .opencode/guidelines/065-verification-honesty.md` — must be >= 1
  - SC-ID: SC-9a2

### Task 6.3 — Verify Pre-Response Factual Claim Gate heading (SC-9a3)

- [ ] **Verify.** Confirm `## Pre-Response Factual Claim Gate` heading is present in 065. (**inline**)
  - `grep -c "^## Pre-Response Factual Claim Gate" .opencode/guidelines/065-verification-honesty.md` — must be >= 1
  - SC-ID: SC-9a3

### Task 6.4 — Verify FORBIDDEN/REQUIRED headings (SC-9a4)

- [ ] **Verify.** Confirm `## 🚫 FORBIDDEN` and `## ✅ REQUIRED` headings are present in 065. (**inline**)
  - `grep -c "^## 🚫 FORBIDDEN" .opencode/guidelines/065-verification-honesty.md` — must be >= 1
  - `grep -c "^## ✅ REQUIRED" .opencode/guidelines/065-verification-honesty.md` — must be >= 1
  - SC-ID: SC-9a4

---

## Post-implementation

- [ ] **Structural checks.** Dispatch `finishing-a-development-branch --task checklist` to run the finishing checklist. (**sub-agent**)
  - Context: branch name, files changed list
- [ ] **Verification.** Dispatch `verification-before-completion --task verify` to verify all SCs pass. (**sub-agent**)
  - Context: issue 2129, all SCs with evidence types
- [ ] **Audit.** Dispatch `audit --task verification-audit` for adversarial review. (**sub-agent**)
  - Context: spec at `.opencode/.issues/2129/spec.md`, plan at `.opencode/.issues/2129/plan.md`
- [ ] **Cross-validate.** Dispatch audit cross-validation to reconcile any divergent findings. (**sub-agent**)
- [ ] **Review-prep.** Dispatch `git-workflow --task review-prep` to prepare PR review context. (**sub-agent**)
- [ ] **Create PR.** Dispatch `pr-creation-workflow --task create` to create the PR. (**sub-agent**)
- [ ] **Executive summary.** Dispatch `completion-core --task completion` to generate the completion summary. (**sub-agent**)
