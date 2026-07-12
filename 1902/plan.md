# Plan: SPEC-FIX — Align spec-creation create.md with de facto industry standards

**Issue:** #1902
**Spec path:** `.opencode/.issues/1902/spec.md`
**Target file:** `.opencode/skills/spec-creation/tasks/create.md`
**Authorization scope:** `for_pr`
**Halt at:** `pr_created`
**Plan type:** Single-phase (single concern — one file, 8 changes in dependency order)

## Goal

Edit `create.md` to implement 8 defined changes aligning local/remote spec formats with de facto industry standards (KEP, ADR, OpenSpec, Spec Kit, Better Specs, Open Specification). No structural changes to other files, no pipeline changes.

## Files Affected

| File | Change Type | Risk |
|------|-------------|------|
| `.opencode/skills/spec-creation/tasks/create.md` | Edit | All 8 changes applied to this single file |

## Success Criteria Mapping

| SC ID (from spec) | Criterion | Plan Steps |
|-------------------|-----------|------------|
| SC-1 | Step 7r removed (lines 611–669) | 5 |
| SC-2 | AI Agent Instructions in Step 7a | 4 |
| SC-3 | URL construction rules in Step 7a | 4 |
| SC-4 | Constraints table in Step 7a | 4 |
| SC-5 | Step 5 preamble = local spec.md only | 6 |
| SC-6 | No cross-references to Step 7r elsewhere | 2 |
| SC-7 | Behavioral test exists (RED before fix, GREEN after) | 8 |

## Phase 1: Edit create.md (8 Changes in Dependency Order)

### Step 1: Create feature branch

**Chain:** `none`
**Action:** Create a feature branch in the `.opencode` submodule for the implementation work.
**Command:** `git -C .opencode checkout -b spec-fix/1902-create-md-standardize`

### Step 2: Audit cross-references to Step 7r

**Chain:** `none` (prerequisite to Step 5 — verify no dangling refs before deletion)
**Action:** Search `create.md` for any references to "Step 7r" outside the Step 7r section itself (line 611). Document all cross-reference locations.
**Verification:** `grep -n "Step 7r" .opencode/skills/spec-creation/tasks/create.md` — only line 611 should match.

### Step 3: Add YAML frontmatter references

**Chain:** `none`
**Action:** In the local spec.md assembly instructions (Step 1 area, ~lines 29–50), add instructions to generate YAML frontmatter (`---` delimited: title, status, created, license, provenance, issue, authors) at the top of `.issues/{N}/spec.md`. Clarify that remote issue body remains markdown-only (no frontmatter).
**Rationale:** YAML frontmatter enables machine-parseable metadata for local spec.md without affecting the human-readable remote body.
**SC evidence type:** `string`

### Step 4: Add Goals/Non-Goals sections + AI Agent Instructions refactor + "Cards" → "Scope of Work" rename

**Chain:** `step_3`
**Action (3 sub-changes on same section):**
1. Add `## Goals` and `## Non-Goals` sections between `## Problem` and `## Proposed Changes` in both local spec.md template and remote exec summary template.
2. **AI Agent Instructions (Option B):** Remove the `## AI Agent Instructions` section from the remote issue body template (Step 7a example format). Move the instructions (URL construction rules, character-match verification, repo-awareness guard, substitution verification, constraints table) to a local-only section. Add a pre-PR gate note enforcing the constraint at the pipeline level.
3. Rename `### Cards (dependency order)` to `### Scope of Work (dependency order)` in the Step 7a example format. Also rename any other "Cards" heading in the file to "Scope of Work".
**SC evidence type:** `string`

### Step 5: Step 7 renumbering (unwrap to flat 7.1–7.4)

**Chain:** `step_4`
**Action:** Unwrap the current nested Step 7 format into flat substeps:
- Step 7.1: Local Spec Assembly — the local spec.md creation part
- Step 7.2: Remote Issue Body — the exec summary creation part, referencing the new merged format
- Step 7.3: Pre-PR Gate — the enforcement constraint for AI Agent Instructions
- Step 7.4: Post-Creation Sync — the `local-issues sync` and verification step
**Note:** All subsequent steps (8, 9, etc.) must be renumbered to account for the removed Step 7r and the flattened structure.

### Step 6: Remove Step 7r

**Chain:** `step_5` (must happen AFTER cross-reference audit and renumbering)
**Action:** Delete the entire Step 7r section (current lines 611–669) from `create.md`. This removes:
- The 6-part flat format (Problem/Scope/Approach/Impact)
- The redundant blank template
- The duplicate AI Agent Instructions template (content already merged into Step 7a in Step 4)
**Verification:** After deletion, `grep -n "Step 7r"` must return 0 matches.
**SC evidence type:** `string`

### Step 7: Fix Step 5 preamble wording

**Chain:** `step_6`
**Action:** In Step 5 (current line 51), change the preamble wording to explicitly state:
- The STATUS/CREATED preamble and compliance blockquote are for the **local `.issues/{N}/spec.md`** file ONLY
- Add a note: "The remote issue body uses the blockquote format from Step 6.8 followed by the exec summary format defined in Step 7. Do NOT include preamble (STATUS/CREATED) or compliance blockquote in the remote issue body."
**SC evidence type:** `string`

### Step 8: Write behavioral enforcement tests

**Chain:** `step_7`
**Action:** Create a behavioral test script at `.opencode/tests/behaviors/spec-creation-cards-format.sh` that:
1. Sends a "create a spec" prompt via `opencode-cli run`
2. Verifies the agent produces the cards-based format (Exec Summary → Scope of Work → Key Decisions → Risk Callouts) rather than the flat format (Problem/Scope/Approach/Impact)
3. Confirms RED state before implementation (test fails without changes)
4. Confirms GREEN state after implementation (test passes with changes)
**SC evidence type:** `behavioral`

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- **Destructive operations:** Deletion of Step 7r section (lines 611–669)
- **Rollback plan:** `git checkout -- .opencode/skills/spec-creation/tasks/create.md` restores the original file
- **Data loss risk:** None (git tracks all changes)

## Implementation Pipeline Gates

The following mandatory gates MUST be invoked after plan implementation:
1. **Implementation pipeline:** `skill({name: "implementation-pipeline"})` — dispatch stages to clean-room sub-agents
2. **Verification before completion:** `skill({name: "verification-before-completion"})` — verify all 7 SCs PASS
3. **Finishing checklist:** `skill({name: "finishing-a-development-branch"})` — branch readiness checks
4. **Review prep:** `skill({name: "git-workflow"}) --task review-prep`
5. **Cleanup:** `skill({name: "git-workflow"}) --task cleanup`

## Authorization

**Cascade status:** Auto-approved — `authorization_scope: for_pr` → plan auto-approves per Approval Cascade Matrix. Implementation auto-approved under same scope.
