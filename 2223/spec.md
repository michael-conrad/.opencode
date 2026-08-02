---
number: 2223
title: "[SPEC] PR body template: standalone format, DiMo attestation, skill consolidation"
status: open
labels: []
created: 2026-08-02T02:04:17Z
updated: 2026-08-02T02:37:17Z
remote_issue: 2223
remote_url: "https://github.com/michael-conrad/.opencode/issues/2223"
promoted_at: 2026-08-02T02:04:17Z
promotion_type: retroactive_import
last_sync: 2026-08-02T02:37:17Z
author: michael-conrad
approved: true
authorization_scope: for_pr
---

## Intent and Executive Summary

### Problem Statement

The PR body template in `create-pr.md` has three structural defects:

1. **Hard-coded MCP call** — The PR body is embedded inside `github_create_pull_request()`, coupling content to transport. The body is the deliverable; the API call is transport. They must be separated.

2. **Stale dual-auditor references** — The audit pipeline was replaced with the DiMo 4-role chain (Investigator → Validator → Evaluator → Arbiter), but the PR body template still references "Dual-Auditor Cross-Validation" and "Auditor 1 / Auditor 2" columns. The attestation line claims "Dual independent auditors from different model families" — a fabrication.

3. **Ceremony skill** — `pr-creation-workflow` exists solely to check authorization scope, which is a one-line orchestrator conditional. It adds a dispatch round-trip for no unique value. Its authorization check should be folded into `git-workflow-pr`'s Workflows section.

4. **No PR body audit** — The audit skill has no task to verify a generated PR body conforms to the template, so structural defects in PR bodies go undetected.

### Root Cause/Motivation

The PR body template was originally written as inline content inside a platform-specific API call, coupling the deliverable (the PR body) to the transport (the MCP call). When the audit pipeline was upgraded from dual-auditor cross-validation to the DiMo 4-role chain, the template was not updated to reflect the new attestation model. The `pr-creation-workflow` skill was created as a thin authorization-check wrapper that adds ceremony without value. No PR body audit task was created when the audit skill was built, leaving a gap in the verification pipeline.

### Approach Chosen

Extract the PR body template to a standalone reference file decoupled from platform-specific API calls. Replace stale dual-auditor attestation with the DiMo 4-role chain. Eliminate the ceremony `pr-creation-workflow` skill by folding its authorization check into `git-workflow-pr`'s Workflows section. Add a PR body audit task to the audit skill. Update all stale terminology and cross-references across the codebase.

### Alternatives Considered & Why Discarded

- **Keep template inline, add a second copy for GitBucket**: Discarded because it doubles maintenance surface. A single standalone template referenced by both platform sections is strictly better.
- **Keep `pr-creation-workflow` but rename it**: Discarded because the skill has no unique value beyond a one-line authorization check. Folding that check into `git-workflow-pr` eliminates a dispatch round-trip with zero loss of functionality.
- **Leave dual-auditor references as-is, document as known stale**: Discarded because stale attestation language in PR bodies is a fabrication risk. The attestation line claims a process that no longer exists. It must be corrected.
- **Add PR body audit as a standalone skill**: Discarded because the audit skill already exists and has the right dispatch infrastructure. Adding a task to the existing skill is lower overhead than creating a new skill.

### Key Design Decisions

1. **Standalone reference file**: The template lives at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md` — a single file referenced by both platform invocations (GitHub MCP, GitBucket CLI). This decouples content from transport and ensures a single source of truth.
2. **DiMo 4-role chain attestation**: The attestation table uses columns Criterion, Evidence Type, Investigator, Validator, Evaluator, Arbiter — matching the existing DiMo pipeline.
3. **Workflows section format**: `git-workflow-pr` SKILL.md replaces Trigger Dispatch Table and DISPATCH_GATE with a Workflows section containing 5 separate workflows, each starting with an orchestrator inline authorization scope check.
4. **Authorization check as orchestrator inline**: The authorization scope check is a one-line conditional in the orchestrator context — no task() call needed. This eliminates the `pr-creation-workflow` dispatch round-trip.
5. **`closing-keywords.md` preserved**: Moved from `pr-creation-workflow/reference/` to `git-workflow-pr/reference/` to avoid losing existing closing keyword patterns.

### User Intent/Original Prompt

Standardize the PR body template as a standalone reference file decoupled from platform-specific API calls, replace stale dual-auditor attestation with the DiMo 4-role chain, eliminate the ceremony `pr-creation-workflow` skill, and add a PR body audit task to the audit skill.

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| `create-pr.md` | Source file | `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` | Contains inline PR body template and stale dual-auditor references |
| `pr-creation-workflow` skill | Source directory | `.opencode/skills/pr-creation-workflow/` | Contains SKILL.md + task files to be deleted |
| `git-workflow-pr` SKILL.md | Source file | `.opencode/skills/git-workflow-pr/SKILL.md` | Contains Trigger Dispatch Table to be replaced with Workflows section |
| Audit skill SKILL.md | Source file | `.opencode/skills/audit/SKILL.md` | Contains Trigger Dispatch Table to receive pr-body-audit task |
| `000-critical-rules.md` | Guideline | `.opencode/guidelines/000-critical-rules.md` | Contains stale "dual-auditor" reference |
| `250-dark-prose-reference.md` | Guideline | `.opencode/guidelines/250-dark-prose-reference.md` | Contains stale "dual-auditor" references (2 occurrences) |
| `255-distribution-shifting-reference.md` | Guideline | `.opencode/guidelines/255-distribution-shifting-reference.md` | Contains stale "dual-auditor" reference |
| `257-procedural-discipline-reference.md` | Guideline | `.opencode/guidelines/257-procedural-discipline-reference.md` | Contains stale "dual-auditor" reference |
| `branch-cleanup.md` | Task file | `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` | Contains stale "dual-auditor" reference |

## Cost Frame

Implementation cost is measured in defect-discovery latency, not tool-call count.

- **SC-1 through SC-12**: Extracting the template and updating attestation costs ~12 file-creation and text-replacement operations — each operation is a discovery point where a stale reference or wrong column header would be caught. Skipping any SC costs a structural defect in the template that propagates to every future PR body. Correctness is the only success metric — there is no score for speed.
- **SC-13, SC-14**: Deleting the skill directory and moving closing-keywords.md costs 2 file-system operations — each operation is a discovery point where an orphaned cross-reference would surface. Skipping either SC costs a stale directory that breaks skill discovery or a lost reference file. Correctness is the only success metric — there is no score for speed.
- **SC-15 through SC-19**: Rewriting the SKILL.md with Workflows section costs ~5 structural edits — each edit is a discovery point where a missing workflow or wrong section format would be caught. Skipping any SC costs a broken dispatch table that silently routes to the wrong workflow. Correctness is the only success metric — there is no score for speed.
- **SC-20, SC-21**: Creating the pr-body-audit task and Trigger Dispatch Table entry costs ~2 file operations — each operation is a discovery point where a missing section check or wrong table entry would surface. Skipping either SC costs an unverifiable PR body pipeline where structural defects go undetected. Correctness is the only success metric — there is no score for speed.
- **SC-22 through SC-26**: Replacing stale terminology across 5 files costs ~5 find-and-replace operations — each operation is a discovery point where a missed occurrence would be caught. Skipping any SC costs a stale "dual-auditor" reference that propagates fabrication risk. Correctness is the only success metric — there is no score for speed.
- **SC-27, SC-28**: Updating the verification-evidence-check gate and Data Flow table costs ~2 text-replacement operations — each operation is a discovery point where a wrong file reference would be caught. Skipping either SC costs a broken gate that checks a non-existent file. Correctness is the only success metric — there is no score for speed.
- **SC-29, SC-30**: Removing cross-references to pr-creation-workflow costs ~2 grep-and-remove operations — each operation is a discovery point where a stale cross-reference would surface. Skipping either SC costs a broken link that routes agents to a deleted skill. Correctness is the only success metric — there is no score for speed.

## Enforcement Gate

**All-or-nothing:** This spec's success criteria are individually verifiable but collectively required. No SC may be skipped, deferred, or weakened. If any SC cannot be implemented, the entire spec is BLOCKED and must be reported as such. Partial implementation is not an acceptable outcome.

## Not Included

- Changes to the DiMo 4-role chain pipeline itself (prerequisite, not in scope)
- Changes to the `git-workflow-pr` task files beyond the Workflows section and description
- Changes to the audit skill beyond adding the `pr-body-audit` task entry
- Any changes to PR body content semantics — only format, attestation, and sourcing are in scope
- Any changes to the `git-workflow-cleanup` skill beyond the `branch-cleanup.md` terminology update

## Requirements

| ID | Requirement |
|----|-------------|
| REQ-1 | PR body template SHALL be a standalone reference file, not embedded in an API call |
| REQ-2 | PR body SHALL use DiMo chain attestation, not dual-auditor cross-validation |
| REQ-3 | Both platform invocations (GitHub MCP, GitBucket CLI) SHALL reference the same template |
| REQ-4 | `pr-creation-workflow` skill SHALL be removed; its authorization check folded into `git-workflow-pr` |
| REQ-5 | `git-workflow-pr` SHALL use Workflows section format replacing Trigger Dispatch Table |
| REQ-6 | `git-workflow-pr` description SHALL use agent-intent format |
| REQ-7 | Audit skill SHALL have a task to verify PR body template conformance |
| REQ-8 | All stale "dual-auditor" terminology in the 5 files that contain it SHALL be replaced with "DiMo chain" |
| REQ-9 | Verification-evidence-check gate SHALL reference `judgment.yaml` not `audit-cross-validate-*.json` |
| REQ-10 | All cross-references to `pr-creation-workflow` SHALL be updated or removed |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | PR body template extracted from `github_create_pull_request()` call to standalone reference file at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md` | structural | File exists at target path |
| SC-2 | Standalone template contains Summary section | string | grep for `**Summary:**` in template file |
| SC-3 | Standalone template contains Outcome section | string | grep for `**Outcome:**` in template file |
| SC-4 | Standalone template contains Verification Attestation section | string | grep for `**Verification Attestation:**` in template file |
| SC-5 | Standalone template contains VbC Table section | string | grep for `**Detail: VbC Table**` in template file |
| SC-6 | Standalone template contains DiMo Chain Attestation section | string | grep for `**Detail: DiMo Chain Attestation**` in template file |
| SC-7 | Standalone template contains Spec-Card-Mapped Commits section | string | grep for `**Detail: Spec-Card-Mapped Commits**` in template file |
| SC-8 | Standalone template contains closing keywords (`Fixes #N` or `Implements #N`) | string | grep for `Fixes #` or `Implements #` in template file |
| SC-9 | DiMo Chain Attestation table uses columns: Criterion, Evidence Type, Investigator, Validator, Evaluator, Arbiter | string | grep for table header in template file |
| SC-10 | Verification Attestation line references "DiMo 4-role audit chain" not "Dual independent auditors" | string | grep for "DiMo 4-role" in template file |
| SC-11 | Attestation line states "The Arbiter accepted all Evaluator verdicts as final — no synthesis corrections were needed or applied" | string | grep for "no synthesis corrections" in template file |
| SC-12 | Both platform sections (GitHub MCP, GitBucket CLI) reference the same standalone template, not duplicating it | structural | Template file is referenced by both platform sections in create-pr.md |
| SC-13 | `pr-creation-workflow` skill directory deleted (SKILL.md + all task files) | structural | Directory does not exist |
| SC-14 | `closing-keywords.md` from `pr-creation-workflow` preserved — moved to `git-workflow-pr/reference/` | structural | File exists at target path |
| SC-15 | Authorization scope check added as orchestrator inline Step 1 in `git-workflow-pr` Workflows section | string | grep for "Verify authorization scope" in SKILL.md |
| SC-16 | `git-workflow-pr` SKILL.md has Workflows section replacing Trigger Dispatch Table and DISPATCH_GATE | string | grep for "## Workflows" in SKILL.md, no "## Trigger Dispatch Table" |
| SC-17 | Workflows section contains 5 separate workflows: Create PR, Prepare review, Create pair mode PR, Post-implementation, Complete workflow | string | grep for each workflow heading in SKILL.md |
| SC-18 | Each workflow starts with orchestrator inline authorization scope check (no task() call) | string | grep for "orchestrator inline" after each workflow heading |
| SC-19 | `git-workflow-pr` description field uses agent-intent format — no "Load via skill() when", "Also load when", or "User phrases:" patterns | string | grep description field for absence of prohibited patterns |
| SC-20 | `pr-body-audit` task added to audit skill Trigger Dispatch Table | string | grep for "pr-body-audit" in audit SKILL.md |
| SC-21 | `pr-body-audit` task verifies: (a) Summary section present, (b) Outcome section present, (c) Verification Attestation section present, (d) VbC Table section present, (e) DiMo Chain Attestation section present, (f) Spec-Card-Mapped Commits section present, (g) closing keywords present, (h) DiMo Chain Attestation table uses correct columns, (i) attestation line references DiMo 4-role chain, (j) attestation line states no synthesis corrections, (k) byline present in correct format | behavioral | opencode run with prompt to create PR body, verify audit catches structural defects |
| SC-22 | `000-critical-rules.md` "dual-auditor" reference updated to "DiMo chain" | string | grep for absence of "dual-auditor" in file |
| SC-23 | `250-dark-prose-reference.md` "dual-auditor" references (2 occurrences) updated to "DiMo chain" | string | grep for absence of "dual-auditor" in file |
| SC-24 | `255-distribution-shifting-reference.md` "dual-auditor" reference updated to "DiMo chain" | string | grep for absence of "dual-auditor" in file |
| SC-25 | `257-procedural-discipline-reference.md` "dual-auditor" reference updated to "DiMo chain" | string | grep for absence of "dual-auditor" in file |
| SC-26 | `branch-cleanup.md` "dual-auditor" reference updated to "DiMo chain" | string | grep for absence of "dual-auditor" in file |
| SC-27 | Verification-evidence-check gate in `create-pr.md` checks for `judgment.yaml` with `overall_verdict: PASS` instead of `audit-cross-validate-*.json` | string | grep for "judgment.yaml" in gate section |
| SC-28 | Data Flow table in `create-pr.md` references DiMo Chain Attestation → `judgment.yaml` instead of Dual-Auditor Cross-Validation → `audit-cross-validate-*.json` | string | grep for "DiMo Chain Attestation" in Data Flow table |
| SC-29 | All cross-references to `pr-creation-workflow` skill updated or removed across the codebase | string | grep for "pr-creation-workflow" returns zero results |
| SC-30 | Cross-reference from `git-workflow-pr` SKILL.md to `pr-creation-workflow` removed | string | grep for "pr-creation-workflow" in git-workflow-pr SKILL.md returns zero |

## Items

| # | SC ID | Description |
|---|-------|-------------|
| 1 | SC-1 | Extract PR body template to standalone reference file |
| 2 | SC-2 | Template contains Summary section |
| 3 | SC-3 | Template contains Outcome section |
| 4 | SC-4 | Template contains Verification Attestation section |
| 5 | SC-5 | Template contains VbC Table section |
| 6 | SC-6 | Template contains DiMo Chain Attestation section |
| 7 | SC-7 | Template contains Spec-Card-Mapped Commits section |
| 8 | SC-8 | Template contains closing keywords |
| 9 | SC-9 | DiMo Chain Attestation table uses correct columns |
| 10 | SC-10 | Verification Attestation references DiMo 4-role chain |
| 11 | SC-11 | Attestation line states no synthesis corrections needed |
| 12 | SC-12 | Both platform sections reference same standalone template |
| 13 | SC-13 | Delete pr-creation-workflow skill directory |
| 14 | SC-14 | Preserve closing-keywords.md in git-workflow-pr/reference/ |
| 15 | SC-15 | Authorization scope check as orchestrator inline Step 1 |
| 16 | SC-16 | Workflows section replaces Trigger Dispatch Table |
| 17 | SC-17 | Workflows section contains 5 separate workflows |
| 18 | SC-18 | Each workflow starts with orchestrator inline auth check |
| 19 | SC-19 | git-workflow-pr description uses agent-intent format |
| 20 | SC-20 | pr-body-audit task added to audit skill |
| 21 | SC-21 | pr-body-audit verifies all 11 enumerated PR body requirements (a) through (k) |
| 22 | SC-22 | Update 000-critical-rules.md dual-auditor reference |
| 23 | SC-23 | Update 250-dark-prose-reference.md dual-auditor references |
| 24 | SC-24 | Update 255-distribution-shifting-reference.md dual-auditor reference |
| 25 | SC-25 | Update 257-procedural-discipline-reference.md dual-auditor reference |
| 26 | SC-26 | Update branch-cleanup.md dual-auditor reference |
| 27 | SC-27 | Verification-evidence-check gate references judgment.yaml |
| 28 | SC-28 | Data Flow table references DiMo Chain Attestation |
| 29 | SC-29 | All cross-references to pr-creation-workflow updated or removed |
| 30 | SC-30 | Cross-reference from git-workflow-pr SKILL.md removed |

## Edge Cases

- **Template file already exists at target path**: If `.opencode/skills/git-workflow-pr/reference/pr-body-template.md` already exists from a previous partial implementation, the existing file must be overwritten with the correct template content.
- **`pr-creation-workflow` directory already deleted**: If the directory was already removed by another change, SC-13 is trivially satisfied but SC-14 (closing-keywords.md preservation) must still be verified.
- **`closing-keywords.md` already exists at target**: If `git-workflow-pr/reference/closing-keywords.md` already exists, verify it matches the source content before deleting the source.
- **Cross-references in files outside the affected list**: If `grep` for `pr-creation-workflow` or `dual-auditor` finds matches in files not listed in Affected Files, those must also be updated to satisfy SC-29 and SC-8 respectively.
- **`git-workflow-pr` SKILL.md has no Trigger Dispatch Table**: If the file was already updated to use Workflows format, SC-16 is trivially satisfied but SC-17 and SC-18 must still be verified.
- **Audit skill already has `pr-body-audit` task**: If the task entry already exists, SC-20 is trivially satisfied but SC-21 must still be verified (the task file must exist and function correctly).

## Traceability

| REQ | SCs | Phase |
|-----|-----|-------|
| REQ-1 | SC-1, SC-12 | Phase 1 |
| REQ-2 | SC-2 through SC-11 | Phase 1 |
| REQ-3 | SC-12 | Phase 1 |
| REQ-4 | SC-13, SC-14, SC-15 | Phase 2 |
| REQ-5 | SC-16, SC-17, SC-18 | Phase 3 |
| REQ-6 | SC-19 | Phase 3 |
| REQ-7 | SC-20, SC-21 | Phase 4 |
| REQ-8 | SC-22 through SC-26 | Phase 5 |
| REQ-9 | SC-27, SC-28 | Phase 1 |
| REQ-10 | SC-29, SC-30 | Phase 6 |

## Dependencies
- .opencode#2223 (original spec — superseded by this revision)
- Audit skill DiMo 4-role chain must already be implemented (prerequisite for SC-20, SC-21)

## Approach

### Phase 1 [REQ-1, REQ-2, REQ-3, REQ-9]: Extract PR body template to standalone reference file, update attestation and table format, update gates
Extract the PR body template from `create-pr.md` to standalone reference file at `.opencode/skills/git-workflow-pr/reference/pr-body-template.md`. Update attestation language and table format to use DiMo 4-role chain. Both platform sections (GitHub MCP, GitBucket CLI) reference the same standalone template. Update verification-evidence-check gate and Data Flow table.

### Phase 2 [REQ-4]: Delete pr-creation-workflow skill, preserve closing-keywords.md
Delete the entire `.opencode/skills/pr-creation-workflow/` directory. Preserve `closing-keywords.md` — move to `git-workflow-pr/reference/`.

### Phase 3 [REQ-5, REQ-6]: Add Workflows section to git-workflow-pr SKILL.md, fix description
Replace Trigger Dispatch Table and DISPATCH_GATE with a Workflows section containing 5 separate workflows. Each workflow starts with orchestrator inline authorization scope check (no task() call). Fix description field to use agent-intent format. Remove cross-reference to pr-creation-workflow.

### Phase 4 [REQ-7]: Add pr-body-audit task to audit skill
Add `pr-body-audit` task to audit skill Trigger Dispatch Table. Task verifies all 11 enumerated PR body requirements: (a) Summary section, (b) Outcome section, (c) Verification Attestation section, (d) VbC Table section, (e) DiMo Chain Attestation section, (f) Spec-Card-Mapped Commits section, (g) closing keywords, (h) correct DiMo Chain Attestation table columns, (i) DiMo 4-role chain attestation line, (j) no synthesis corrections attestation line, (k) byline in correct format.

### Phase 5 [REQ-8]: Update stale dual-auditor terminology across all affected files
Update all stale "dual-auditor" references to "DiMo chain" across: 000-critical-rules.md, 250-dark-prose-reference.md, 255-distribution-shifting-reference.md, 257-procedural-discipline-reference.md, branch-cleanup.md.

### Phase 6 [REQ-10]: Update cross-references
Update all cross-references to `pr-creation-workflow` skill across the codebase. Remove cross-reference from `git-workflow-pr` SKILL.md.

## Affected Files

- `.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md` — extract template, update attestation, update gates
- `.opencode/skills/git-workflow-pr/reference/pr-body-template.md` — NEW: standalone template
- `.opencode/skills/git-workflow-pr/reference/closing-keywords.md` — MOVED from pr-creation-workflow
- `.opencode/skills/git-workflow-pr/SKILL.md` — Workflows section, fix description, remove cross-ref
- `.opencode/skills/pr-creation-workflow/` — DELETE entire directory
- `.opencode/skills/audit/SKILL.md` — add pr-body-audit task
- `.opencode/guidelines/000-critical-rules.md` — dual-auditor → DiMo chain
- `.opencode/guidelines/250-dark-prose-reference.md` — dual-auditor → DiMo chain
- `.opencode/guidelines/255-distribution-shifting-reference.md` — dual-auditor → DiMo chain
- `.opencode/guidelines/257-procedural-discipline-reference.md` — dual-auditor → DiMo chain
- `.opencode/skills/git-workflow-cleanup/tasks/cleanup/branch-cleanup.md` — dual-auditor → DiMo chain

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-02T02:37Z | Expanded scope from "Remove stale dual-auditor references" to full structural reform: standalone template, DiMo attestation, skill consolidation, PR body audit | Developer revision request | michael-conrad |
| 2026-08-01T22:39Z | Added Objective, Requirements, Traceability, Dependencies sections; added Verification Method column to SC table; decomposed SC-2 and SC-16 into individual SCs; added formal Traceability table mapping REQ → SC → Phase | Spec validation failures: missing sections, missing Verification Method column, compound SCs, no formal traceability | michael-conrad |
| 2026-08-01T22:42Z | Removed SC-27 (verify.md does not contain "dual-auditor"), updated REQ-8 to specify 5 files, removed verify.md from Affected Files, updated Traceability REQ-8 to SC-22 through SC-26 only, updated SC count to 30, added REQ references to phase headings | Validation failures: non-existent SC-27, missing REQ references in phase headings | michael-conrad |
| 2026-08-01T23:01Z | Replaced ## Objective and ## Problem with ## Intent and Executive Summary (6 required fields); added ## Documentation Sources, ## Cost Frame, ## Enforcement Gate, ## Not Included, ## Items, ## Edge Cases sections; added alternatives considered and edge case discovery to preamble | Spec-audit structural completeness: 8 FAIL criteria | michael-conrad |
| 2026-08-02T03:15Z | SC-21: replaced open-ended wording with exact 11-item enumeration (a) through (k); REQ-1 through REQ-10: replaced lowercase 'must' with uppercase 'SHALL'; Cost Frame: replaced table format with per-SC dark-prose-007 pattern sentences | Re-audit found 3 remaining FAIL criteria | michael-conrad |
