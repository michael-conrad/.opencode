# Plan: Cross-Reference Rewrite — #1924

## Summary

Rewrite all citation-style cross-references (`See \`FILE.md\` §SECTION`, `See \`SKILLNAME\` skill`, `**Authority:** \`FILE.md\` §SECTION`) across the entire opencode deck to `Read [Text](path)` Markdown links.

**Total scope:** ~386 references across ~98 files
- Guidelines: 80 `See \`...\`` + 58 `§` = 138 refs across 19 files
- SKILL.md: 57 `See \`...\`` + 39 `§` = 96 refs across 27 files
- Task files: 34 `See \`...\`` + 113 `§` + 5 `**Authority:**` = 152 refs across ~60 files
- AGENTS.md: 8 `See \`...\`` + several `§` = ~10 refs

**Dependency:** BLOCKED BY #1923 (band-aid) — already merged. No other dependencies.

**PR strategy:** Stacked — one feature branch, one commit per phase, one PR.

---

## Phase 1: AGENTS.md + High-Density Guidelines

**Files:**
- `.opencode/AGENTS.md` (8 `See \`...\`` + several `§`)
- `.opencode/guidelines/000-critical-rules.md` (41 `See \`...\`` + 16 `§`)
- `.opencode/guidelines/020-go-prohibitions.md` (11 `See \`...\`` + 11 `§`)

**What to rewrite:** ~87 references. All `See \`FILE.md\` §SECTION`, `See \`SKILLNAME\` skill`, and `**Authority:**` patterns to `Read [Text](path)`.

**Verification:**
1. `rg -c 'See `'` on each file — verify zero matches
2. `rg -c '§'` on each file — verify zero matches (or only non-cross-reference uses)
3. Z3 SAT: extract old-form references, verify each has a corresponding new-form `Read [Text](path)` link
4. `bash .opencode/tests/test-enforcement.sh --changed` — verify no existing tests broken

**PR:** `feature/1924-phase-1-agents-md-guidelines`

---

## Phase 2: Medium-Density Guidelines

**Files:**
- `.opencode/guidelines/080-code-standards.md` (8 `See \`...\`` + 7 `§`)
- `.opencode/guidelines/065-verification-honesty.md` (1 `See \`...\`` + 5 `§`)
- `.opencode/guidelines/085-project-local-tools.md` (0 `See \`...\`` + 4 `§`)
- `.opencode/guidelines/091-incremental-build.md` (2 `See \`...\`` + 2 `§`)
- `.opencode/guidelines/140-planning-spec-creation.md` (2 `See \`...\`` + 1 `§`)
- `.opencode/guidelines/060-tool-usage.md` (2 `See \`...\`` + 1 `§`)
- `.opencode/guidelines/210-scripting.md` (2 `See \`...\`` + 1 `§`)
- `.opencode/guidelines/250-dark-prose-reference.md` (1 `See \`...\`` + 2 `§`)
- `.opencode/guidelines/141-planning-status-tracking.md` (1 `See \`...\`` + 2 `§`)
- `.opencode/guidelines/257-procedural-discipline-reference.md` (0 `See \`...\`` + 2 `§`)

**What to rewrite:** ~42 references.

**Verification:** Same as Phase 1.

**PR:** `feature/1924-phase-2-guidelines-medium`

---

## Phase 3: Low-Density Guidelines

**Files (1 reference each):**
- `.opencode/guidelines/010-approval-gate.md`
- `.opencode/guidelines/015-pre-spec-inspection.md`
- `.opencode/guidelines/016-srclight-preference.md`
- `.opencode/guidelines/070-environment.md`
- `.opencode/guidelines/075-docs-verification.md`
- `.opencode/guidelines/115-branch-naming.md`
- `.opencode/guidelines/116-pair-mode.md`
- `.opencode/guidelines/143-planning-spec-templates.md`
- `.opencode/guidelines/144-planning-spec-examples.md`
- `.opencode/guidelines/INDEX.md` (0 `See \`...\`` + 1 `§`)

**What to rewrite:** ~10 references.

**Verification:** Same as Phase 1.

**PR:** `feature/1924-phase-3-guidelines-low`

---

## Phase 4: High-Density SKILL.md Files

**Files:**
- `.opencode/skills/git-workflow-cleanup/SKILL.md` (8 `See \`...\`` + 7 `§`)
- `.opencode/skills/git-workflow-pr/SKILL.md` (7 `See \`...\`` + 5 `§`)
- `.opencode/skills/git-workflow-commit/SKILL.md` (5 `See \`...\`` + 3 `§`)
- `.opencode/skills/git-workflow-branch/SKILL.md` (5 `See \`...\`` + 3 `§`)
- `.opencode/skills/playwright-cli/SKILL.md` (4 `See \`...\`` + 0 `§`)
- `.opencode/skills/test-driven-development/SKILL.md` (3 `See \`...\`` + 0 `§`)
- `.opencode/skills/git-workflow-conflict/SKILL.md` (3 `See \`...\`` + 1 `§`)
- `.opencode/skills/brainstorming/SKILL.md` (2 `See \`...\`` + 2 `§`)
- `.opencode/skills/approval-gate-scope/SKILL.md` (2 `See \`...\`` + 1 `§`)

**What to rewrite:** ~60 references.

**Verification:** Same as Phase 1.

**PR:** `feature/1924-phase-4-skills-high`

---

## Phase 5: Low-Density SKILL.md Files

**Files (1 reference each):**
- `.opencode/skills/version-manager/SKILL.md`
- `.opencode/skills/verification-enforcement/SKILL.md`
- `.opencode/skills/verification-before-completion/SKILL.md`
- `.opencode/skills/using-git-worktrees/SKILL.md`
- `.opencode/skills/systematic-debugging/SKILL.md`
- `.opencode/skills/sre-runbook/SKILL.md`
- `.opencode/skills/solve/SKILL.md`
- `.opencode/skills/skill-creator/SKILL.md`
- `.opencode/skills/release-promoter/SKILL.md`
- `.opencode/skills/pr-creation-workflow/SKILL.md`
- `.opencode/skills/mcp-tool-usage/SKILL.md`
- `.opencode/skills/issue-review/SKILL.md`
- `.opencode/skills/implementation-pipeline/SKILL.md`
- `.opencode/skills/finishing-a-development-branch/SKILL.md`
- `.opencode/skills/executing-plans/SKILL.md`
- `.opencode/skills/engineering-approach/SKILL.md`
- `.opencode/skills/correspondence/SKILL.md`
- `.opencode/skills/completion-core/SKILL.md`
- `.opencode/skills/issue-operations/SKILL.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/changelog-generator/SKILL.md` (0 `See \`...\`` + 1 `§`)
- `.opencode/skills/pre-analysis/SKILL.md` (0 `See \`...\`` + 1 `§`)
- `.opencode/skills/sync-guidelines/SKILL.md` (0 `See \`...\`` + 1 `§`)

**What to rewrite:** ~24 references.

**Verification:** Same as Phase 1.

**PR:** `feature/1924-phase-5-skills-low`

---

## Phase 6: High-Density Task Files

**Files (2+ references each):**
- `.opencode/skills/spec-creation-validation/tasks/create.md` (7 `See \`...\`` + 2 `§`)
- `.opencode/skills/writing-plans-creation/tasks/operating-protocol.md` (4 `See \`...\`` + 4 `§`)
- `.opencode/skills/verification-before-completion/tasks/verify.md` (0 `See \`...\`` + 5 `§` + 1 `**Authority:**`)
- `.opencode/skills/verification-before-completion/tasks/collect.md` (2 `See \`...\`` + 2 `§` + 1 `**Authority:**`)
- `.opencode/skills/pr-creation-workflow/tasks/pre-pr-checklist.md` (0 `See \`...\`` + 5 `§`)
- `.opencode/skills/audit/tasks/test-quality-audit-arbiter.md` (0 `See \`...\`` + 5 `§`)
- `.opencode/skills/audit/tasks/cross-validate.md` (0 `See \`...\`` + 2 `§` + 2 `**Authority:**`)
- `.opencode/skills/approval-gate-scope/tasks/verify-closed-issue.md` (1 `See \`...\`` + 5 `§`)
- `.opencode/skills/audit/tasks/test-quality-audit-evaluator.md` (0 `See \`...\`` + 4 `§`)
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md` (1 `See \`...\`` + 4 `§`)
- `.opencode/skills/issue-operations-core/tasks/creation.md` (1 `See \`...\`` + 3 `§`)
- `.opencode/skills/git-workflow-branch/tasks/provenance.md` (1 `See \`...\`` + 3 `§`)
- `.opencode/skills/audit/tasks/test-quality-audit-validator.md` (0 `See \`...\`` + 3 `§`)
- `.opencode/skills/audit/tasks/test-quality-audit-investigator.md` (0 `See \`...\`` + 3 `§`)
- `.opencode/skills/audit/tasks/spec-audit-evaluator.md` (0 `See \`...\`` + 3 `§`)
- `.opencode/skills/audit/tasks/spec-audit-arbiter.md` (0 `See \`...\`` + 3 `§`)
- `.opencode/skills/approval-gate-scope/tasks/pre-implementation-analysis.md` (0 `See \`...\`` + 3 `§`)
- `.opencode/skills/executing-plans/tasks/start.md` (2 `See \`...\`` + 1 `§`)
- `.opencode/skills/sre-runbook/tasks/track.md` (2 `See \`...\`` + 0 `§`)
- `.opencode/skills/approval-gate-scope/tasks/verify-sub-issues.md` (2 `See \`...\`` + 1 `§`)
- `.opencode/skills/verification-before-completion/tasks/structural-verify.md` (1 `See \`...\`` + 1 `§`)
- `.opencode/skills/spec-creation-validation/tasks/create.md` (7 `See \`...\`` + 2 `§` + 1 `**Authority:**`)

**What to rewrite:** ~80 references.

**Verification:** Same as Phase 1.

**PR:** `feature/1924-phase-6-tasks-high`

---

## Phase 7: Medium-Density Task Files

**Files (2 references each):**
- `.opencode/skills/writing-plans-creation/tasks/validate.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/verification-before-completion/tasks/behavioral-test-evaluation.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/spec-creation-decomposition/tasks/decompose.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/issue-operations-core/tasks/body-edit.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/implementation-pipeline/tasks/pipeline-executor.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/git-workflow-pr/tasks/review-prep.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/git-workflow-branch/tasks/pre-work.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/engineering-approach/tasks/verify-before-complete.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/audit/tasks/guideline-audit-arbiter.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/audit/tasks/content-audit-arbiter.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/approval-gate-scope/tasks/verify-qa-mode.md` (1 `See \`...\`` + 2 `§`)
- `.opencode/skills/approval-gate-scope/tasks/reconcile-issue-graph.md` (0 `See \`...\`` + 2 `§`)
- `.opencode/skills/approval-gate-scope/tasks/completion.md` (1 `See \`...\`` + 2 `§`)

**What to rewrite:** ~26 references.

**Verification:** Same as Phase 1.

**PR:** `feature/1924-phase-7-tasks-medium`

---

## Phase 8: Low-Density Task Files

**Files (1 reference each):**
- `.opencode/skills/test-driven-development/tasks/operating-protocol.md`
- `.opencode/skills/issue-review/tasks/analyze-and-spec.md`
- `.opencode/skills/issue-operations-core/tasks/creation.md`
- `.opencode/skills/git-workflow-pr/tasks/post-implementation.md`
- `.opencode/skills/git-workflow-branch/tasks/provenance.md`
- `.opencode/skills/executing-plans/tasks/step.md`
- `.opencode/skills/audit/tasks/plan-fidelity-evaluator.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-qa-mode.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-open-questions.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-fix-spec.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-closed-issue.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-blockers.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-already-implemented.md`
- `.opencode/skills/approval-gate-scope/tasks/completion.md`
- `.opencode/skills/writing-plans-creation/tasks/write.md`
- `.opencode/skills/verification-before-completion/tasks/structural-verify.md`
- `.opencode/skills/verification-before-completion/tasks/completion.md`
- `.opencode/skills/spec-creation-validation/tasks/pipeline-readiness-gate.md`
- `.opencode/skills/issue-operations-sync/tasks/sync-pull-to-local.md`
- `.opencode/skills/issue-operations-core/tasks/completion.md`
- `.opencode/skills/implementation-pipeline/tasks/sc-count-gate.md`
- `.opencode/skills/implementation-pipeline/tasks/checkpoint-tag-create.md`
- `.opencode/skills/implementation-pipeline/tasks/assemble-work.md`
- `.opencode/skills/git-workflow-cleanup/tasks/check-pr.md`
- `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md`
- `.opencode/skills/git-workflow-branch/tasks/operating-protocol.md`
- `.opencode/skills/executing-plans/tasks/step.md`
- `.opencode/skills/executing-plans/tasks/start.md`
- `.opencode/skills/engineering-approach/tasks/design-before-code.md`
- `.opencode/skills/completeness-gate/tasks/check.md`
- `.opencode/skills/audit/tasks/verification-audit-validator.md`
- `.opencode/skills/audit/tasks/verification-audit-investigator.md`
- `.opencode/skills/audit/tasks/verification-audit-evaluator.md`
- `.opencode/skills/audit/tasks/verification-audit-arbiter.md`
- `.opencode/skills/audit/tasks/spec-audit-validator.md`
- `.opencode/skills/audit/tasks/spec-audit-investigator.md`
- `.opencode/skills/audit/tasks/guideline-audit-investigator.md`
- `.opencode/skills/audit/tasks/drift-detection-evaluator.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-sub-issues.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-authorization.md`
- `.opencode/skills/approval-gate-scope/tasks/verify-already-implemented.md`

**What to rewrite:** ~41 references.

**Verification:** Same as Phase 1.

**PR:** `feature/1924-phase-8-tasks-low`

---

## Phase 9: Final Verification Sweep

**Action:** Run full grep sweep across entire `.opencode/` tree to confirm zero remaining citation-style cross-references.

**Commands:**
```bash
rg -n 'See `[^`]\+`' .opencode/ --type md    # expect 0 matches
rg -n '§' .opencode/ --type md                 # expect 0 matches (or only non-cross-reference uses)
rg -n '\*\*Authority:\*\*' .opencode/ --type md  # expect 0 matches
```

**If any remain:** Create a cleanup phase for the remaining files.

**PR:** None (verification only, no file changes).

---

## Z3 SAT Verification (per Phase)

Each phase produces a Z3 model with:
- **Old-form constraints:** One boolean variable per old-form reference found in the phase's files
- **New-form constraints:** One boolean variable per `Read [Text](path)` link added in the phase
- **Equivalence constraint:** For every old-form reference, at least one new-form link must reference the same target file+section
- **SAT check:** Model must be satisfiable (all old references have corresponding new links)

The Z3 model is stored at `.opencode/.issues/1924/artifacts/z3-phase-N.smt2` and run via `./.opencode/tools/solve`.

---

## Reference Extraction Decision

The spec says: for cross-references to files pre-loaded via `instructions` array in `opencode.jsonc`, the referenced section may need extraction into a `references/` subdirectory.

**Assessment:** The band-aid (#1923) adds a text mandate in `default.txt` and `AGENTS.md` telling the agent that cross-references are load directives. This should be sufficient for the agent to follow `Read [Text](path)` links to files already in its pre-loaded context. **No reference extraction is needed** — the `Read [Text](path)` links point to the existing file paths, and the band-aid mandate ensures the agent treats them as load directives.

If behavioral testing (#1926) reveals the agent still doesn't load referenced sections from pre-loaded files, reference extraction can be added as a follow-up phase.
