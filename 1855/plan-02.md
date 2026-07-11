# Phase 2: Rewrite All 43 SKILL.md Descriptions

**Phase ID:** description-rewrites
**Issue:** .opencode#1855
**Dependencies:** Phase 1 (validator must exist to validate rewrites)
**SC Coverage:** SC-5, SC-6, SC-10, SC-11

## Step 5: Rewrite pipeline/process skills (15 files)

**Files:**
- `.opencode/skills/approval-gate/SKILL.md`
- `.opencode/skills/audit/SKILL.md`
- `.opencode/skills/brainstorming/SKILL.md`
- `.opencode/skills/changelog-generator/SKILL.md`
- `.opencode/skills/completeness-gate/SKILL.md`
- `.opencode/skills/completion-core/SKILL.md`
- `.opencode/skills/conflict-resolution/SKILL.md`
- `.opencode/skills/engineering-approach/SKILL.md`
- `.opencode/skills/executing-plans/SKILL.md`
- `.opencode/skills/finishing-a-development-branch/SKILL.md`
- `.opencode/skills/implementation-pipeline/SKILL.md`
- `.opencode/skills/pre-analysis/SKILL.md`
- `.opencode/skills/verification/SKILL.md`
- `.opencode/skills/verification-before-completion/SKILL.md`
- `.opencode/skills/verification-enforcement/SKILL.md`

**Transformation rule for each file:**
1. Read the current `description` field from YAML frontmatter
2. Extract: primary use case, secondary use cases, task list, enforcement statement, trigger phrases, exclusion clauses
3. Rewrite using the new pattern:
   - Convert "Use when <X>" to a noun phrase: what the skill IS
   - Convert "Also use when <Y>" to "Also dispatch when <Y>"
   - Remove "Invoke for:" — replace with "Dispatch when" prose
   - Preserve enforcement statement as-is
   - Convert "Trigger phrases:" to "User phrases:" with same content
   - Preserve exclusion clauses as-is
4. Verify: ≤ 1024 characters
5. Run validator: must pass

**RED/GREEN:** Write content-verification grep for each file. RED: grep for "Use when" at start → matches. GREEN: grep for "Use when" at start → no match.

## Step 6: Rewrite git/PR skills (5 files)

**Files:**
- `.opencode/skills/git-workflow/SKILL.md`
- `.opencode/skills/pr-creation-workflow/SKILL.md`
- `.opencode/skills/receiving-code-review/SKILL.md`
- `.opencode/skills/requesting-code-review/SKILL.md`
- `.opencode/skills/using-git-worktrees/SKILL.md`

Same transformation as Step 5.

## Step 7: Rewrite content/planning skills (6 files)

**Files:**
- `.opencode/skills/correspondence/SKILL.md`
- `.opencode/skills/plan/SKILL.md`
- `.opencode/skills/plan-creation-pipeline/SKILL.md`
- `.opencode/skills/spec-creation/SKILL.md`
- `.opencode/skills/writing-plans/SKILL.md`
- `.opencode/skills/sre-runbook/SKILL.md`

Same transformation as Step 5.

## Step 8: Rewrite tool/utility skills (13 files)

**Files:**
- `.opencode/skills/issue-operations/SKILL.md`
- `.opencode/skills/issue-review/SKILL.md`
- `.opencode/skills/mcp-tool-usage/SKILL.md`
- `.opencode/skills/multimodal-dispatch/SKILL.md`
- `.opencode/skills/playwright-cli/SKILL.md`
- `.opencode/skills/programming-principles/SKILL.md`
- `.opencode/skills/research/SKILL.md`
- `.opencode/skills/skill-creator/SKILL.md`
- `.opencode/skills/solve/SKILL.md`
- `.opencode/skills/sync-guidelines/SKILL.md`
- `.opencode/skills/systematic-debugging/SKILL.md`
- `.opencode/skills/test-driven-development/SKILL.md`
- `.opencode/skills/version-manager/SKILL.md`

Same transformation as Step 5.

## Step 9: Rewrite platform sub-skills (3 files)

**Files:**
- `.opencode/skills/issue-operations/platforms/local/SKILL.md`
- `.opencode/skills/issue-operations/platforms/github-mcp/SKILL.md`
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`

Same transformation as Step 5.

## Step 10: Rewrite release/ops skills (1 file)

**Files:**
- `.opencode/skills/release-promoter/SKILL.md`

Same transformation as Step 5.

## Step 11: Bulk validation pass

Run `uv run .opencode/skills/skill-creator/scripts/validate_skill_cards.py` on all 43 files. Verify exit code 0.

## Phase 2 Completion

- [ ] All 43 SKILL.md descriptions rewritten
- [ ] SC-5: Zero "Use when" at start, zero "Invoke for:", zero "Trigger phrases:", zero "Also use when" (string)
- [ ] SC-6: All 43 contain "User phrases:" with preserved trigger phrases (string)
- [ ] SC-10: validate_skill_cards.py passes on all 43 files (behavioral)
- [ ] SC-11: All descriptions ≤ 1024 characters (structural)
- [ ] Z3 check: verify phase output has PASS status
