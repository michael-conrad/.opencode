---
title: Implementation Plan — Rename DiMo Audit Role Names
issue: 1921
status: draft
created: 2026-07-14
license: MIT
provenance: AI-generated
phase_count: 1
---

**STATUS:** DRAFT
**CREATED:** 2026-07-14

## Goal

Rename 4 DiMo audit role names across ~57 files in `.opencode/skills/audit/` and `.opencode/tests/behaviors/` to match human semantic intent: Generator→Investigator, Knowledge Supporter→Validator, Path Provider→Arbiter. Evaluator stays unchanged.

## Architecture

This is a purely textual rename with zero dispatch logic changes. The DiMo chain uses position-based routing (1st, 2nd, 3rd, 4th in chain), not role name strings. The rename affects only human-readable labels and file names — no behavioral or structural changes to the audit pipeline.

### Role Rename Map

| Old Name | New Name | File Name Change | Files Affected |
|----------|----------|-----------------|----------------|
| Generator | Investigator | `*-generator.md` → `*-investigator.md` | ~8 flat + 3 subdir |
| Knowledge Supporter | Validator | `*-knowledge-supporter.md` → `*-validator.md` | ~8 flat + 3 subdir |
| Path Provider | Arbiter | `*-path-provider.md` → `*-arbiter.md` | ~8 flat + 3 subdir |
| Judger | Arbiter | No file name change | Content only |
| Evaluator | Evaluator (unchanged) | None | 0 |

### File Categories

| Category | Count | Action |
|----------|-------|--------|
| SKILL.md | 1 | Content string replacement |
| Flat task files with role in name | 24 | File rename + content replacement |
| Flat task files without role in name | 21 | Content replacement (cross-references) |
| Subdirectory role files | 9 | File rename + content replacement |
| Subdirectory parent files | 3 | Content replacement (cross-references) |
| Behavioral test files | 2 | Content replacement |

## Affected Files

All files in `.opencode/skills/audit/` (SKILL.md + 54 task files) and `.opencode/tests/behaviors/` (2 files). See `artifacts/code-path-inventory.yaml` for the complete inventory.

## Phase Table

| Phase | Description | Steps | SC Coverage |
|-------|-------------|-------|-------------|
| 1 | Rename all role names and files | 1.1–1.12 | SC-1 through SC-8 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | All 54 task files have old role names replaced | 1 | 1.1, 1.2, 1.3 |
| SC-2 | SKILL.md uses new role names | 1 | 1.4 |
| SC-3 | File names renamed correctly | 1 | 1.5 |
| SC-4 | Behavioral test files updated | 1 | 1.6 |
| SC-5 | Audit chain dispatches correctly with new names | 1 | 1.10 |
| SC-6 | No broken cross-references | 1 | 1.7, 1.8 |
| SC-7 | No lobotomized tests | 1 | 1.9 |
| SC-8 | RED/GREEN behavioral test cycle | 1 | 1.9, 1.10 |

## Exit Criteria

- [ ] All 8 success criteria verified PASS
- [ ] grep for old role names returns zero matches in affected directories
- [ ] grep for old file name patterns returns zero matches in cross-references
- [ ] Behavioral tests PASS with new role names
- [ ] Audit fidelity and concern separation audits PASS
- [ ] Feature branch created, committed, pushed
- [ ] PR created

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: File renames (git mv) — reversible via `git mv` back
- Rollback plan: `git checkout <checkpoint-tag>` restores all files to pre-rename state
- Data loss risk: None (git preserves history through renames)

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/skills/audit/tasks/*-generator.md` | ✅ | `ls` confirmed |
| 1.2 | `.opencode/skills/audit/tasks/*-knowledge-supporter.md` | ✅ | `ls` confirmed |
| 1.3 | `.opencode/skills/audit/tasks/*-path-provider.md` | ✅ | `ls` confirmed |
| 1.4 | `.opencode/skills/audit/SKILL.md` | ✅ | `ls` confirmed |
| 1.5 | Subdirectory role files | ✅ | `ls` confirmed |
| 1.6 | `.opencode/tests/behaviors/dimo-role-chain-dispatch.sh` | ✅ | `ls` confirmed |
| 1.7 | `.opencode/tests/behaviors/1246-sc3-resolve-models-preflight.sh` | ✅ | `ls` confirmed |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| 54 task files exist | `artifacts/code-path-inventory.yaml` | ✅ |
| 24 files need renaming | `artifacts/blast-radius.yaml` | ✅ |
| 2 behavioral test files | `artifacts/blast-radius.yaml` | ✅ |
| Dispatch logic is position-based | `artifacts/interface-compatibility.yaml` | ✅ |
| No runtime state affected | `artifacts/state-analysis.yaml` | ✅ |

## Admonishments

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work.

> **Escape Hatch Prohibition:** Plan step descriptions MUST NOT contain language that lets the agent short-circuit steps. No "skip if fails", "verify manually", "TBD", "if time permits", or "simplify if needed".

> **Anti-Lobotomization:** Behavioral test assertions MUST NOT be removed, weakened, or replaced with structural/string evidence. SC-7 and SC-8 require behavioral evidence.

---

# Phase 1: Rename All Role Names and Files

**Phase 1 — Safety/Rollback:**
- Destructive operations: File renames (git mv) — reversible via `git mv` back
- Rollback plan: `git checkout <checkpoint-tag>` restores all files to pre-rename state
- Data loss risk: None (git preserves history through renames)

## Step 1.1 — Pre-work: Create feature branch and checkpoint

**Dispatch:** `git-workflow --task pre-work`
- Create feature branch: `feature/1921-rename-dimo-roles`
- Tag submodule: `<parent>/checkpoint/1921/phase-1-<submodule>`
- Verify clean working tree before starting

**Chain:** none
**SC:** none (infrastructure)

## Step 1.2 — RED: Run behavioral tests to confirm they fail with old names

**Dispatch:** `test-driven-development --task red`
- Run `bash .opencode/tests/behaviors/dimo-role-chain-dispatch.sh`
- Run `bash .opencode/tests/behaviors/1246-sc3-resolve-models-preflight.sh`
- Confirm both FAIL (old role names still in effect)
- Record failure output as evidence

**Chain:** step_1.1
**SC:** SC-8 (RED/GREEN cycle)

## Step 1.3 — Rename flat task files (24 files)

**Dispatch:** sub-agent via `task()`
- `git mv` all `*-generator.md` → `*-investigator.md` (8 files)
- `git mv` all `*-knowledge-supporter.md` → `*-validator.md` (8 files)
- `git mv` all `*-path-provider.md` → `*-arbiter.md` (8 files)
- Verify: `ls *-{investigator,validator,arbiter}.md` shows 24 files

**Chain:** step_1.2
**SC:** SC-3 (file names renamed correctly)

## Step 1.4 — Rename subdirectory role files (9 files)

**Dispatch:** sub-agent via `task()`
- In each subdirectory (`closure-verification/`, `coherence-extraction/`, `spec-summary/`):
  - `git mv generator.md` → `investigator.md`
  - `git mv knowledge-supporter.md` → `validator.md`
  - `git mv path-provider.md` → `arbiter.md`
- Verify: `ls */{investigator,validator,arbiter}.md` shows 9 files

**Chain:** step_1.3
**SC:** SC-3

## Step 1.5 — Replace role name strings in all task file contents

**Dispatch:** sub-agent via `task()`
- In all 54 task files (flat + subdirectory), replace:
  - `Generator` → `Investigator` (case-sensitive, whole word)
  - `Knowledge Supporter` → `Validator`
  - `Path Provider` → `Arbiter`
  - `Judger` → `Arbiter`
- Do NOT replace `Evaluator` (unchanged)
- Verify: `grep -rn 'Generator\|Knowledge Supporter\|Path Provider\|Judger' .opencode/skills/audit/tasks/` returns zero

**Chain:** step_1.4
**SC:** SC-1 (all task files updated)

## Step 1.6 — Update SKILL.md

**Dispatch:** sub-agent via `task()`
- Replace role name strings in Trigger Dispatch Table
- Replace role name strings in DiMo Role Chain Dispatch section
- Replace role name strings in role descriptions and purpose statements
- Verify: `grep 'Generator\|Knowledge Supporter\|Path Provider\|Judger' .opencode/skills/audit/SKILL.md` returns zero
- Verify: `grep 'Investigator\|Validator\|Arbiter' .opencode/skills/audit/SKILL.md` shows expected occurrences

**Chain:** step_1.5
**SC:** SC-2 (SKILL.md updated)

## Step 1.7 — Update cross-references in task files

**Dispatch:** sub-agent via `task()`
- In all task files, replace old file name references:
  - `-generator.md` → `-investigator.md`
  - `-knowledge-supporter.md` → `-validator.md`
  - `-path-provider.md` → `-arbiter.md`
  - `generator.md` → `investigator.md` (subdirectory references)
  - `knowledge-supporter.md` → `validator.md`
  - `path-provider.md` → `arbiter.md`
- Verify: `grep -rn '\-generator\.md\|generator\.md\|-knowledge-supporter\.md\|knowledge-supporter\.md\|-path-provider\.md\|path-provider\.md' .opencode/skills/audit/tasks/` returns zero

**Chain:** step_1.6
**SC:** SC-6 (no broken cross-references)

## Step 1.8 — Update behavioral test files

**Dispatch:** sub-agent via `task()`
- In `.opencode/tests/behaviors/dimo-role-chain-dispatch.sh`:
  - Replace old role names in prompts, assertions, expected output patterns
- In `.opencode/tests/behaviors/1246-sc3-resolve-models-preflight.sh`:
  - Replace old role names in prompts, assertions, expected output patterns
- Verify: `grep 'Generator\|Knowledge Supporter\|Path Provider\|Judger' .opencode/tests/behaviors/` returns zero
- Verify: `grep 'Investigator\|Validator\|Arbiter' .opencode/tests/behaviors/` shows expected occurrences

**Chain:** step_1.7
**SC:** SC-4 (behavioral tests updated)

## Step 1.9 — Verify no lobotomized tests

**Dispatch:** `verification-before-completion --task verify`
- Compare behavioral test assertions before and after rename
- Confirm no assertions were removed, weakened, or replaced with structural evidence
- Confirm behavioral evidence type is preserved for SC-5, SC-7, SC-8
- Verify: test structure is identical except role name strings

**Chain:** step_1.8
**SC:** SC-7 (no lobotomized tests)

## Step 1.10 — GREEN: Run behavioral tests to confirm they pass with new names

**Dispatch:** `test-driven-development --task green`
- Run `bash .opencode/tests/behaviors/dimo-role-chain-dispatch.sh`
- Run `bash .opencode/tests/behaviors/1246-sc3-resolve-models-preflight.sh`
- Confirm both PASS with new role names
- Record PASS output as evidence

**Chain:** step_1.9
**SC:** SC-5 (audit chain dispatches correctly), SC-8 (RED/GREEN cycle)

## Step 1.11 — Exhaustive grep verification

**Dispatch:** sub-agent via `task()`
- `grep -rn 'Generator\|Knowledge Supporter\|Path Provider\|Judger' .opencode/skills/audit/ .opencode/tests/behaviors/` → zero matches
- `grep -rn '\-generator\.md\|generator\.md\|-knowledge-supporter\.md\|knowledge-supporter\.md\|-path-provider\.md\|path-provider\.md' .opencode/skills/audit/tasks/` → zero matches
- `ls .opencode/skills/audit/tasks/*-{generator,knowledge-supporter,path-provider}.md` → no such file
- `ls .opencode/skills/audit/tasks/*-{investigator,validator,arbiter}.md` → 24 files exist
- `ls .opencode/skills/audit/tasks/*/{generator,knowledge-supporter,path-provider}.md` → no such file
- `ls .opencode/skills/audit/tasks/*/{investigator,validator,arbiter}.md` → 9 files exist

**Chain:** step_1.10
**SC:** SC-1, SC-2, SC-3, SC-4, SC-6

## Step 1.12 — Finishing checklist and PR creation

**Dispatch:** `finishing-a-development-branch --task checklist`
- Run finishing checklist
- Verify all changes committed
- Verify branch readiness

**Dispatch:** `git-workflow --task pr-creation`
- Create PR with stacked strategy
- PR body: Summary → Outcome → Fixes #1921
- Extract PR URL from API response

**Chain:** step_1.11
**SC:** none (completion)

## Verification-Before-Completion Block

After all steps complete, dispatch `verification-before-completion --task verify` to verify all 8 SCs:

| SC ID | Evidence Type | Verification Method |
|-------|---------------|-------------------|
| SC-1 | string | `grep` for old role names in task files → zero |
| SC-2 | string | `grep` for old names in SKILL.md → zero; new names present |
| SC-3 | structural | `ls` for old file patterns → no such file; new patterns exist |
| SC-4 | string | `grep` for old names in test files → zero |
| SC-5 | behavioral | `opencode-cli run` with audit dispatch prompt → PASS |
| SC-6 | string | `grep` for old file name patterns in cross-references → zero |
| SC-7 | behavioral | Compare test assertions pre/post → no weakening |
| SC-8 | behavioral | RED/GREEN cycle: pre-rename FAIL, post-rename PASS |

## Phase Completion Block

- [ ] All 12 steps completed
- [ ] All 8 SCs verified PASS
- [ ] Checkpoint tag created at step 1.1
- [ ] Feature branch committed and pushed
- [ ] PR created with correct base branch
- [ ] Audit fidelity and concern separation audits PASS
