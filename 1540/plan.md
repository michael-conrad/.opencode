# Implementation Plan — [#1540](https://github.com/michael-conrad/.opencode/issues/1540) — Replace mandatory three-branch model with single-path branch workflow

- **Goal:** Remove the mandatory three-branch model (`feature → dev → main`) from the skill deck, replacing it with a single-path branch workflow where `dev` is optional, PRs accept any target branch, squash is mandatory for all branches at PR time, commit messages are standardized, rebase timing is defined at three fixed points, and release-promotion is removed or unified.
- **Architecture:** Seven sequential phases, each targeting a distinct file with a single concern boundary. Phases 1–5 form a linear dependency chain (1 → 2+3 → 4 → 5). Phases 6 and 7 depend only on Phase 1 and are independent of each other. All target files are under `.opencode/skills/`.
- **Files:**
  - `.opencode/skills/git-workflow/tasks/pre-work.md` (Phases 1, 6)
  - `.opencode/skills/pr-creation-workflow/SKILL.md` (Phase 2, 7)
  - `.opencode/skills/git-workflow/SKILL.md` (Phase 3, 7)
  - `.opencode/skills/git-workflow/tasks/pr-creation/squash-push.md` (Phase 4)
  - `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` (Phases 5, 6, 7)
  - `.opencode/skills/git-workflow/tasks/release-promotion.md` (Phase 7 — DELETE)
  - `.opencode/skills/git-workflow/tasks/provenance.md` (Phase 7)
  - `.opencode/skills/git-workflow/tasks/provenance/promotion-provenance.md` (Phase 7)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.

## Phase 1 — Remove mandatory dev bootstrap

- **Concern:** Pre-work no longer auto-creates `dev` branch
- **Files:** `.opencode/skills/git-workflow/tasks/pre-work.md`
- **SCs:** SC-1 (behavioral)
- **Dependencies:** None (foundational)
- **Entry:** Spec approved, feature branch `feature/1540-single-path-workflow` created from `dev`
- **Exit:** Pre-work Step 1.5 (dev creation block at lines 86-113) removed; Step 2 (sync dev) updated to not require dev existence; behavioral test for SC-1 passes

- [ ] 1. **SC coherence gate (**clean-room**).** Verify SC-1 is well-formed: behavioral evidence type, testable via `opencode-cli run`, success criterion matches spec. **→ SC-1**
- [ ] 2. **Pre-RED baseline (**inline**).** Read `.opencode/skills/git-workflow/tasks/pre-work.md` to establish baseline content. Record the dev creation block at Step 1.5 (lines 86-113) and Step 2 (lines 123-141) as the target for removal. **→ SC-1**
- [ ] 3. **RED phase — behavioral test (**sub-agent**).** Dispatch a sub-agent to write a behavioral enforcement test that sends a pre-work prompt and asserts `dev` branch is NOT auto-created. Write to `./tmp/behavioral-evidence-SC-1-red.sh`. **→ SC-1**
- [ ] 4. **Z3 check — RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid assertion syntax. **→ SC-1**
- [ ] 5. **RED doublecheck (**sub-agent**).** Dispatch a sub-agent to run the RED test via `bash .opencode/tests/with-test-home opencode-cli run '<pre-work prompt>'` and confirm it FAILS (dev is still auto-created). **→ SC-1**
- [ ] 6. **Z3 check — RED doublecheck (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-1**
- [ ] 7. **Post-RED enforcement (**inline**).** Confirm RED test artifact is committed to the feature branch. **→ SC-1**
- [ ] 8. **Z3 check — post-RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test is committed and the working tree is clean. **→ SC-1**
- [ ] 9. **GREEN phase — remove dev creation (**sub-agent**).** Dispatch a sub-agent to:
  - Remove Step 1.5 (Pre-flight — Verify `dev` branch exists on remote, lines 82-113) from `.opencode/skills/git-workflow/tasks/pre-work.md`
  - Update Step 2 (Sync Dev Branch, lines 123-141) to sync from `origin/main` or the default branch instead of requiring `dev`
  - Update the "Three-Branch Workflow Context" section (lines 62-74) to remove mandatory dev references
  - Update the "Enforcement Checklist" section (lines 546-556) to remove dev-specific checks
  - Update all references to `dev` as the base branch to use the default branch or a configurable target
  - **→ SC-1**
- [ ] 10. **Z3 check — GREEN (**sub-agent**).** Dispatch a sub-agent to verify the GREEN changes are present in the file and no dev-creation logic remains. **→ SC-1**
- [ ] 11. **Post-GREEN enforcement (**inline**).** Confirm all changes are staged and the working tree is clean. **→ SC-1**
- [ ] 12. **Z3 check — post-GREEN (**sub-agent**).** Dispatch a sub-agent to verify the working tree is clean and only the intended files are modified. **→ SC-1**
- [ ] 13. **Checkpoint tag create (**inline**).** Create checkpoint tag: `git tag -a opencode-config/checkpoint/1540/phase-1-opencode -m "Phase 1 complete: dev bootstrap removed"`. **→ SC-1**
- [ ] 14. **Checkpoint commit (**inline**).** Commit all Phase 1 changes with message: `Phase 1: Remove mandatory dev bootstrap from pre-work.md`. **→ SC-1**
- [ ] 15. **Structural checks (**sub-agent**).** Dispatch a sub-agent to verify: (a) Step 1.5 block is removed from `pre-work.md`, (b) Step 2 no longer references dev creation, (c) Three-Branch Workflow Context section updated. **→ SC-1**
- [ ] 16. **GREEN doublecheck (**sub-agent**).** Dispatch a sub-agent to re-run the behavioral test and confirm it now PASSES (dev is no longer auto-created). **→ SC-1**
- [ ] 17. **GREEN VbC (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-1 against the behavioral test output. **→ SC-1**
- [ ] 18. **Adversarial audit — Phase 1 (**sub-agent**).** Dispatch adversarial auditor pair (resolve-models → auditor_1 + auditor_2) to audit Phase 1 changes. **→ SC-1**
- [ ] 19. **Cross-validate — Phase 1 (**sub-agent**).** Dispatch a sub-agent to cross-validate auditor consensus for SC-1. **→ SC-1**
- [ ] 20. **Regression check — Phase 1 (**sub-agent**).** Dispatch a sub-agent to run existing enforcement tests and confirm no regressions. **→ SC-1**
- [ ] 21. **Review prep — Phase 1 (**sub-agent**).** Dispatch a sub-agent to prepare review summary for Phase 1 changes. **→ SC-1**
- [ ] 22. **Executive summary — Phase 1 (**inline**).** Report Phase 1 completion: dev bootstrap removed from `pre-work.md`, SC-1 behavioral test passes. **→ SC-1**

#### Phase 1 VbC

- [ ] 23. **VbC (**clean-room**).** Verify SC-1: pre-work no longer auto-creates `dev` branch. Behavioral test confirms PASS. **→ SC-1**

**Concern transition:** Leaving dev bootstrap removal → entering PR path unification. Phase 2 depends on Phase 1 (PR routing changes after dev bootstrap removal).

## Phase 2 — Unify PR creation path

- **Concern:** PR creation accepts any target branch, not just `dev`
- **Files:** `.opencode/skills/pr-creation-workflow/SKILL.md`
- **SCs:** SC-2 (behavioral)
- **Dependencies:** Phase 1
- **Entry:** Phase 1 complete, checkpoint tag exists
- **Exit:** Overview line 15 updated, `pr-workflow-002` enforcement gate removed, routing table updated; behavioral test for SC-2 passes

- [ ] 24. **SC coherence gate (**clean-room**).** Verify SC-2 is well-formed: behavioral evidence type, testable via `opencode-cli run`, success criterion matches spec. **→ SC-2**
- [ ] 25. **Pre-RED baseline (**inline**).** Read `.opencode/skills/pr-creation-workflow/SKILL.md` to establish baseline. Record Overview line 15 (`Feature PRs target \`dev\` only.`), `pr-workflow-002` enforcement gate (lines 155-160), and Operating Protocol item 2 (`Base branch = dev` at line 59). **→ SC-2**
- [ ] 26. **RED phase — behavioral test (**sub-agent**).** Dispatch a sub-agent to write a behavioral enforcement test that sends a PR creation prompt targeting a non-dev branch and asserts the agent accepts it. Write to `./tmp/behavioral-evidence-SC-2-red.sh`. **→ SC-2**
- [ ] 27. **Z3 check — RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid assertion syntax. **→ SC-2**
- [ ] 28. **RED doublecheck (**sub-agent**).** Dispatch a sub-agent to run the RED test and confirm it FAILS (PR creation still enforces dev-only target). **→ SC-2**
- [ ] 29. **Z3 check — RED doublecheck (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-2**
- [ ] 30. **Post-RED enforcement (**inline**).** Confirm RED test artifact is committed. **→ SC-2**
- [ ] 31. **Z3 check — post-RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test is committed and working tree is clean. **→ SC-2**
- [ ] 32. **GREEN phase — unify PR path (**sub-agent**).** Dispatch a sub-agent to:
  - Update Overview line 15: replace `Feature PRs target \`dev\` only. Release PRs (dev→main) handled by \`git-workflow --task release-promotion\`.` with `Feature PRs target any branch. Release PRs handled by \`git-workflow --task release-promotion\`.`
  - Remove `pr-workflow-002` enforcement gate (lines 155-160) from the yaml+symbolic rules block
  - Update Operating Protocol item 2 (line 59): replace `Base branch = dev` with `Base branch = target branch`
  - Update the Overview section Persona text if it references dev-only targeting
  - **→ SC-2**
- [ ] 33. **Z3 check — GREEN (**sub-agent**).** Dispatch a sub-agent to verify the GREEN changes are present: Overview updated, `pr-workflow-002` removed, Operating Protocol updated. **→ SC-2**
- [ ] 34. **Post-GREEN enforcement (**inline**).** Confirm all changes are staged and working tree is clean. **→ SC-2**
- [ ] 35. **Z3 check — post-GREEN (**sub-agent**).** Dispatch a sub-agent to verify working tree is clean and only intended files modified. **→ SC-2**
- [ ] 36. **Checkpoint tag create (**inline**).** Create checkpoint tag: `git tag -a opencode-config/checkpoint/1540/phase-2-opencode -m "Phase 2 complete: PR creation path unified"`. **→ SC-2**
- [ ] 37. **Checkpoint commit (**inline**).** Commit all Phase 2 changes with message: `Phase 2: Unify PR creation path to accept any target branch`. **→ SC-2**
- [ ] 38. **Structural checks (**sub-agent**).** Dispatch a sub-agent to verify: (a) Overview line 15 updated, (b) `pr-workflow-002` removed, (c) Operating Protocol item 2 updated. **→ SC-2**
- [ ] 39. **GREEN doublecheck (**sub-agent**).** Dispatch a sub-agent to re-run the behavioral test and confirm it now PASSES (PR creation accepts non-dev target). **→ SC-2**
- [ ] 40. **GREEN VbC (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-2 against the behavioral test output. **→ SC-2**
- [ ] 41. **Adversarial audit — Phase 2 (**sub-agent**).** Dispatch adversarial auditor pair to audit Phase 2 changes. **→ SC-2**
- [ ] 42. **Cross-validate — Phase 2 (**sub-agent**).** Dispatch a sub-agent to cross-validate auditor consensus for SC-2. **→ SC-2**
- [ ] 43. **Regression check — Phase 2 (**sub-agent**).** Dispatch a sub-agent to run existing enforcement tests and confirm no regressions. **→ SC-2**
- [ ] 44. **Review prep — Phase 2 (**sub-agent**).** Dispatch a sub-agent to prepare review summary for Phase 2 changes. **→ SC-2**
- [ ] 45. **Executive summary — Phase 2 (**inline**).** Report Phase 2 completion: PR creation path unified, `pr-workflow-002` removed. **→ SC-2**

#### Phase 2 VbC

- [ ] 46. **VbC (**clean-room**).** Verify SC-2: PR creation accepts any target branch. Behavioral test confirms PASS. **→ SC-2**

**Concern transition:** Leaving PR path unification → entering three-branch model removal. Phase 3 depends on Phase 1 (workflow model changes after dev bootstrap removal).

## Phase 3 — Remove three-branch model from git-workflow

- **Concern:** git-workflow SKILL.md no longer references three-branch model or mandatory dev
- **Files:** `.opencode/skills/git-workflow/SKILL.md`
- **SCs:** SC-6 (semantic + string)
- **Dependencies:** Phase 1
- **Entry:** Phase 1 complete, checkpoint tag exists
- **Exit:** Overview line 13 updated, three-branch model definition removed, PR routing table updated, dev-specific rules removed; content-verification test for SC-6 passes

- [ ] 47. **SC coherence gate (**clean-room**).** Verify SC-6 is well-formed: semantic + string evidence type, testable via grep + semantic inspection, success criterion matches spec. **→ SC-6**
- [ ] 48. **Pre-RED baseline (**inline**).** Read `.opencode/skills/git-workflow/SKILL.md` to establish baseline. Record Overview line 13 (`Three-branch model: feature → dev → main`), Persona line 41 (`three-branch workflow`), Routing table lines 64-68 (Feature PR vs Release PR), and all dev-specific references. **→ SC-6**
- [ ] 49. **RED phase — content-verification test (**sub-agent**).** Dispatch a sub-agent to write a content-verification test that greps `git-workflow/SKILL.md` for "three-branch" and dev-mandatory patterns. Write to `./tmp/behavioral-evidence-SC-6-red.sh`. **→ SC-6**
- [ ] 50. **Z3 check — RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid grep assertions. **→ SC-6**
- [ ] 51. **RED doublecheck (**sub-agent**).** Dispatch a sub-agent to run the RED test and confirm it FAILS (three-branch text still present). **→ SC-6**
- [ ] 52. **Z3 check — RED doublecheck (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-6**
- [ ] 53. **Post-RED enforcement (**inline**).** Confirm RED test artifact is committed. **→ SC-6**
- [ ] 54. **Z3 check — post-RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test is committed and working tree is clean. **→ SC-6**
- [ ] 55. **GREEN phase — remove three-branch model (**sub-agent**).** Dispatch a sub-agent to:
  - Update Overview line 13: replace `Git Workflow Enforcer. Three-branch model: feature → dev → main.` with `Git Workflow Enforcer. Single-path workflow: feature branches target any branch.`
  - Update Persona line 41: replace `three-branch workflow` with `single-path workflow`
  - Update Routing table (lines 64-68): replace `Feature PR (feature/* → dev)` with `Feature PR (feature/* → target)` and `Release PR (dev → main)` with `Release PR (target → main)`
  - Update Operating Protocol item 2 (line 103): replace `Protected branches: never commit to \`main\`/\`dev\`.` with `Protected branches: never commit to \`main\`.`
  - Update Operating Protocol item 5 (line 106): replace `Compare URL base: feature → \`compare/dev...<branch>\`. Release → \`compare/main...dev\`.` with `Compare URL base: feature → \`compare/<target>...<branch>\`. Release → \`compare/main...<target>\`.`
  - Update `git-workflow-003` enforcement gate (lines 228-233): replace `base_branch != 'dev'` with `base_branch != '<target>'`
  - Remove any remaining dev-specific references in the yaml+symbolic rules block
  - **→ SC-6**
- [ ] 56. **Z3 check — GREEN (**sub-agent**).** Dispatch a sub-agent to verify the GREEN changes are present: Overview updated, Persona updated, Routing table updated, Operating Protocol updated, enforcement gates updated. **→ SC-6**
- [ ] 57. **Post-GREEN enforcement (**inline**).** Confirm all changes are staged and working tree is clean. **→ SC-6**
- [ ] 58. **Z3 check — post-GREEN (**sub-agent**).** Dispatch a sub-agent to verify working tree is clean and only intended files modified. **→ SC-6**
- [ ] 59. **Checkpoint tag create (**inline**).** Create checkpoint tag: `git tag -a opencode-config/checkpoint/1540/phase-3-opencode -m "Phase 3 complete: three-branch model removed from git-workflow"`. **→ SC-6**
- [ ] 60. **Checkpoint commit (**inline**).** Commit all Phase 3 changes with message: `Phase 3: Remove three-branch model from git-workflow SKILL.md`. **→ SC-6**
- [ ] 61. **Structural checks (**sub-agent**).** Dispatch a sub-agent to verify: (a) "three-branch" absent from Overview, (b) Persona updated, (c) Routing table updated, (d) Operating Protocol dev references removed. **→ SC-6**
- [ ] 62. **GREEN doublecheck (**sub-agent**).** Dispatch a sub-agent to re-run the content-verification test and confirm it now PASSES (three-branch text removed). **→ SC-6**
- [ ] 63. **GREEN VbC (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-6: no dev-specific rules remain in skill deck. **→ SC-6**
- [ ] 64. **Adversarial audit — Phase 3 (**sub-agent**).** Dispatch adversarial auditor pair to audit Phase 3 changes. **→ SC-6**
- [ ] 65. **Cross-validate — Phase 3 (**sub-agent**).** Dispatch a sub-agent to cross-validate auditor consensus for SC-6. **→ SC-6**
- [ ] 66. **Regression check — Phase 3 (**sub-agent**).** Dispatch a sub-agent to run existing enforcement tests and confirm no regressions. **→ SC-6**
- [ ] 67. **Review prep — Phase 3 (**sub-agent**).** Dispatch a sub-agent to prepare review summary for Phase 3 changes. **→ SC-6**
- [ ] 68. **Executive summary — Phase 3 (**inline**).** Report Phase 3 completion: three-branch model removed from `git-workflow/SKILL.md`. **→ SC-6**

#### Phase 3 VbC

- [ ] 69. **VbC (**clean-room**).** Verify SC-6: no dev-specific rules remain in skill deck. Content-verification and semantic inspection confirm PASS. **→ SC-6**

**Concern transition:** Leaving three-branch model removal → entering mandatory squash and commit message standardization. Phase 4 depends on Phase 2 + Phase 3 (squash and commit changes depend on PR path and workflow changes).

## Phase 4 — Make squash mandatory and standardize commit message format

- **Concern:** Squash-at-PR is mandatory for all branches, no conditional path; commit messages standardized to `#<issue> <title> — <summary>` format
- **Files:** `.opencode/skills/git-workflow/tasks/pr-creation/squash-push.md`
- **SCs:** SC-3 (behavioral), SC-4 (string + semantic)
- **Dependencies:** Phase 2, Phase 3
- **Entry:** Phases 2 and 3 complete, checkpoint tags exist
- **Exit:** Conditional paths at lines 41 and 60 removed; squash is mandatory for all branches; commit message format standardized to `#<issue> <title> — <summary>`; behavioral test for SC-3 passes; content-verification test for SC-4 passes

> **Coordination note:** Both SC-3 and SC-4 modify `squash-push.md` — this is by spec design (Required Actions 4 and 5 both target squash-push.md). Changes are applied in a single GREEN phase.

- [x] 70. **SC coherence gate — SC-3 (**clean-room**).** Verify SC-3 (behavioral) is well-formed: behavioral evidence type, testable via `opencode-cli run`, success criterion matches spec. **→ SC-3**
- [x] 71. **SC coherence gate — SC-4 (**clean-room**).** Verify SC-4 (string + semantic) is well-formed: string + semantic evidence type, testable via grep + semantic inspection, success criterion matches spec. **→ SC-4**
- [x] 72. **Pre-RED baseline (**inline**).** Read `.opencode/skills/git-workflow/tasks/pr-creation/squash-push.md` to establish baseline. Record conditional paths at line 41 (work branch no-squash) and line 60 (work.md skip-squash), and the current commit message format. **→ SC-3, SC-4**
- [x] 73. **RED phase — behavioral test SC-3 (**sub-agent**).** Dispatch a sub-agent to write a behavioral enforcement test that sends a multi-issue PR creation prompt and asserts one commit per issue. Write to `./tmp/behavioral-evidence-SC-3-red.sh`. **→ SC-3**
- [x] 74. **Z3 check — RED SC-3 (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid assertion syntax. **→ SC-3**
- [x] 75. **RED doublecheck — SC-3 (**sub-agent**).** Dispatch a sub-agent to run the SC-3 behavioral test and confirm it FAILS (conditional squash path still present). **→ SC-3**
- [x] 76. **Z3 check — RED doublecheck SC-3 (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-3**
- [x] 77. **RED phase — content-verification test SC-4 (**sub-agent**).** Dispatch a sub-agent to write a content-verification test that asserts commit messages match `#\d+ .+ — .+` pattern. Write to `./tmp/behavioral-evidence-SC-4-red.sh`. **→ SC-4**
- [x] 78. **Z3 check — RED SC-4 (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid assertions. **→ SC-4**
- [x] 79. **RED doublecheck — SC-4 (**sub-agent**).** Dispatch a sub-agent to run the SC-4 content-verification test and confirm it FAILS (commit message format not standardized). **→ SC-4**
- [x] 80. **Z3 check — RED doublecheck SC-4 (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-4**
- [x] 81. **Post-RED enforcement (**inline**).** Confirm both RED test artifacts are committed. **→ SC-3, SC-4**
- [x] 82. **Z3 check — post-RED (**sub-agent**).** Dispatch a sub-agent to verify both RED tests are committed and working tree is clean. **→ SC-3, SC-4**
- [x] 83. **GREEN phase — mandatory squash + commit format (**sub-agent**).** Dispatch a sub-agent to:
  - Collapse the work-branch/squash-detection conditional paths: remove the "Feature/Work Branch" section (lines 39-56) and the "Work Branch" section (lines 58-60)
  - Replace with a single mandatory squash-at-PR rule for all branches: one commit per implementation item via `git reset --soft origin/<target>` followed by `git commit`
  - Standardize commit message format to `#<issue> <title> — <summary>` generated from combined diffs
  - Update the squash-push.md commit instruction to use the standardized format
  - Update Step 3.5 (Rebase on Current Dev, lines 62-71) to reference `<target>` instead of `dev`
  - Update the Exit Criteria section (lines 12-17) to remove dev-specific references
  - **→ SC-3, SC-4**
- [x] 84. **Z3 check — GREEN (**sub-agent**).** Dispatch a sub-agent to verify: (a) conditional paths removed, (b) mandatory squash rule present, (c) commit message format standardized to `#\d+ .+ — .+` pattern, (d) rebase target updated. **→ SC-3, SC-4**
- [x] 85. **Post-GREEN enforcement (**inline**).** Confirm all changes are staged and working tree is clean. **→ SC-3, SC-4**
- [x] 86. **Z3 check — post-GREEN (**sub-agent**).** Dispatch a sub-agent to verify working tree is clean and only intended files modified. **→ SC-3, SC-4**
- [x] 87. **Checkpoint tag create (**inline**).** Create checkpoint tag: `git tag -a opencode-config/checkpoint/1540/phase-4-opencode -m "Phase 4 complete: squash mandatory, commit format standardized"`. **→ SC-3, SC-4**
- [x] 88. **Checkpoint commit (**inline**).** Commit all Phase 4 changes with message: `Phase 4: Make squash mandatory and standardize commit message format`. **→ SC-3, SC-4**
- [x] 89. **Structural checks (**sub-agent**).** Dispatch a sub-agent to verify: (a) conditional paths at lines 41 and 60 removed, (b) mandatory squash rule present, (c) commit message format follows `#\d+ .+ — .+`. **→ SC-3, SC-4**
- [x] 90. **GREEN doublecheck — SC-3 (**sub-agent**).** Dispatch a sub-agent to re-run the SC-3 behavioral test and confirm it PASSES (multi-issue PR produces one commit per issue). **→ SC-3**
- [x] 91. **GREEN doublecheck — SC-4 (**sub-agent**).** Dispatch a sub-agent to re-run the SC-4 content-verification test and confirm it PASSES (commit messages match pattern). **→ SC-4**
- [x] 92. **GREEN VbC — SC-3 (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-3 against the behavioral test output. **→ SC-3**
- [x] 93. **GREEN VbC — SC-4 (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-4 against the content-verification test output. **→ SC-4**
- [x] 94. **Adversarial audit — Phase 4 (**sub-agent**).** Dispatch adversarial auditor pair to audit Phase 4 changes. **→ SC-3, SC-4**
- [x] 95. **Cross-validate — Phase 4 (**sub-agent**).** Dispatch a sub-agent to cross-validate auditor consensus for SC-3 and SC-4. **→ SC-3, SC-4**
- [x] 96. **Regression check — Phase 4 (**sub-agent**).** Dispatch a sub-agent to run existing enforcement tests and confirm no regressions. **→ SC-3, SC-4**
- [x] 97. **Review prep — Phase 4 (**sub-agent**).** Dispatch a sub-agent to prepare review summary for Phase 4 changes. **→ SC-3, SC-4**
- [x] 98. **Executive summary — Phase 4 (**inline**).** Report Phase 4 completion: squash mandatory for all branches, commit messages standardized to `#<issue> <title> — <summary>`. **→ SC-3, SC-4**

#### Phase 4 VbC

- [x] 99. **VbC — SC-3 (**clean-room**).** Verify SC-3: squash mandatory for all branches at PR time. Behavioral test confirms PASS. **→ SC-3**
- [x] 100. **VbC — SC-4 (**clean-room**).** Verify SC-4: commit messages follow `#\d+ .+ — .+`. Content-verification test confirms PASS. **→ SC-4**

### Phase 4a — Fix Phase 4 RED test infrastructure

- **Concern:** RED tests for SC-3 and SC-4 must follow artifact-only generator paradigm per `.opencode/tests/AGENTS.md`
- **Files:** `.opencode/tests/behaviors/` (new files)
- **SCs:** SC-9 (structural)
- **Dependencies:** Phase 4 (fixes are pre-implementation for Phase 4 GREEN)
- **Entry:** Phase 4 RED tests identified as defective
- **Exit:** SC-3 RED test is artifact-only generator in `.opencode/tests/behaviors/1540-sc3-squash-mandatory-red.sh`; SC-4 RED test is in `.opencode/tests/behaviors/1540-sc4-commit-format-red.sh`; both pass syntax check; SC-4 RED doublecheck confirmed FAIL

- [x] **4a.1. SC coherence gate — SC-9 (**clean-room**).** Verify SC-9 is well-formed: structural evidence type, testable via file existence + grep for prohibited patterns (no `assert_*`, no `OVERALL_RESULT`, no `exit $OVERALL_RESULT`). **→ SC-9**
- [x] **4a.2. Pre-RED baseline (**inline**).** Read the two defective RED tests at `./tmp/behavioral-evidence-SC-3-red.sh` and `./tmp/behavioral-evidence-SC-4-red.sh`. Record violations: SC-3 uses inline evaluation (`assert_*`, `OVERALL_RESULT`, `exit $OVERALL_RESULT`), references `$SCRIPT_DIR/helpers.sh` (wrong path), uses unsupported regex negative lookbehind. SC-4 uses `#!/usr/bin/env bash`, missing cross-reference header. **→ SC-9**
- [x] **4a.3. RED phase — content-verification test (**sub-agent**).** Write a content-verification test that checks the new RED test files for prohibited patterns. Write to `./tmp/behavioral-evidence-SC-9-red.sh`. **→ SC-9**
- [x] **4a.4. Z3 check — RED (**sub-agent**).** Verify RED test artifact exists and contains valid assertions. **→ SC-9**
- [x] **4a.5. RED doublecheck (**sub-agent**).** Run the RED test and confirm it FAILS (prohibited patterns still present in old tests). **→ SC-9**
- [x] **4a.6. Z3 check — RED doublecheck (**sub-agent**).** Verify doublecheck produced FAIL result artifact. **→ SC-9**
- [x] **4a.7. Post-RED enforcement (**inline**).** Confirm RED test artifact is committed. **→ SC-9**
- [x] **4a.8. Z3 check — post-RED (**sub-agent**).** Verify RED test committed and working tree clean. **→ SC-9**
- [x] **4a.9. GREEN phase — write corrected RED tests (**sub-agent**).** Write two corrected RED test files to `.opencode/tests/behaviors/`:
  - `1540-sc3-squash-mandatory-red.sh`: Artifact-only generator. Uses `behavior_run` only, exits 0 unconditionally. No `assert_*`, no `OVERALL_RESULT`, no `exit $OVERALL_RESULT`. Includes cross-reference header per `.opencode/tests/AGENTS.md`. Uses `#!/bin/bash`. Sources `helpers.sh` from `$SCRIPT_DIR`.
  - `1540-sc4-commit-format-red.sh`: Content-verification test. Uses `#!/bin/bash`. Includes cross-reference header. Greps for `#\d+ .+ — .+` pattern in `squash-push.md`. Exits 1 when absent.
  - **→ SC-9**
- [x] **4a.10. Z3 check — GREEN (**sub-agent**).** Verify: (a) SC-3 test has no `assert_*`, `OVERALL_RESULT`, or `exit $OVERALL_RESULT`; (b) SC-4 test has `#!/bin/bash` and cross-reference header; (c) both files exist in `.opencode/tests/behaviors/`. **→ SC-9**
- [x] **4a.11. Post-GREEN enforcement (**inline**).** Confirm all changes staged and working tree clean. **→ SC-9**
- [x] **4a.12. Z3 check — post-GREEN (**sub-agent**).** Verify working tree clean and only intended files modified. **→ SC-9**
- [x] **4a.13. Checkpoint tag create (**inline**).** Create checkpoint tag: `git tag -a opencode-config/checkpoint/1540/phase-4a-opencode -m "Phase 4a complete: RED test infrastructure fixed"`. **→ SC-9**
- [x] **4a.14. Checkpoint commit (**inline**).** Commit all Phase 4a changes with message: `Phase 4a: Fix Phase 4 RED test infrastructure to follow artifact-only generator paradigm`. **→ SC-9**
- [x] **4a.15. Structural checks (**sub-agent**).** Verify: (a) SC-3 test in `.opencode/tests/behaviors/` has no prohibited patterns, (b) SC-4 test has correct shebang and header, (c) old `./tmp/` tests remain for reference. **→ SC-9**
- [x] **4a.16. GREEN doublecheck (**sub-agent**).** Re-run SC-4 content-verification test and confirm it FAILS (commit format not yet standardized). **→ SC-9**
- [x] **4a.17. GREEN VbC (**clean-room**).** Verify SC-9: RED tests follow artifact-only generator paradigm. **→ SC-9**
- [x] **4a.18. Adversarial audit — Phase 4a (**sub-agent**).** Dispatch adversarial auditor pair to audit Phase 4a changes. **→ SC-9**
- [x] **4a.19. Cross-validate — Phase 4a (**sub-agent**).** Cross-validate auditor consensus for SC-9. **→ SC-9**
- [x] **4a.20. Regression check — Phase 4a (**sub-agent**).** Run existing enforcement tests and confirm no regressions. **→ SC-9**
- [x] **4a.21. Review prep — Phase 4a (**sub-agent**).** Prepare review summary for Phase 4a changes. **→ SC-9**
- [x] **4a.22. Executive summary — Phase 4a (**inline**).** Report Phase 4a completion: RED tests fixed to follow artifact-only generator paradigm. **→ SC-9**

#### Phase 4a VbC

- [x] **4a.23. VbC (**clean-room**).** Verify SC-9: RED tests follow artifact-only generator paradigm. Content-verification confirms PASS. **→ SC-9**

**Concern transition:** Leaving mandatory squash and commit format → entering PR body template update. Phase 5 depends on Phase 4 (PR body depends on squash and commit format changes being in place).

## Phase 5 — Update PR body template

- **Concern:** PR body includes all 6 required sections
- **Files:** `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md`
- **SCs:** SC-5 (structural)
- **Dependencies:** Phase 4
- **Entry:** Phase 4 complete, checkpoint tag exists
- **Exit:** PR body template updated with all 6 sections; content-verification test for SC-5 passes

- [x] 101. **SC coherence gate (**clean-room**).** Verify SC-5 is well-formed: structural evidence type, testable via grep for section headers, success criterion matches spec. **→ SC-5**
- [x] 102. **Pre-RED baseline (**inline**).** Read `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` to establish baseline. Record the current PR body template at Step 6 (lines 120-152) and the PR Body Requirements section (lines 160-171). **→ SC-5**
- [x] 103. **RED phase — content-verification test (**sub-agent**).** Dispatch a sub-agent to write a content-verification test that checks `create-pr.md` for all 6 required PR body sections: intent, overview, VbC results table, adversarial auditor results, spec-card-mapped commits table, AI byline. Write to `./tmp/behavioral-evidence-SC-5-red.sh`. **→ SC-5**
- [x] 104. **Z3 check — RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid grep assertions for all 6 sections. **→ SC-5**
- [x] 105. **RED doublecheck (**sub-agent**).** Dispatch a sub-agent to run the RED test and confirm it FAILS (template incomplete). **→ SC-5**
- [x] 106. **Z3 check — RED doublecheck (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-5**
- [x] 107. **Post-RED enforcement (**inline**).** Confirm RED test artifact is committed. **→ SC-5**
- [x] 108. **Z3 check — post-RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test is committed and working tree is clean. **→ SC-5**
- [x] 109. **GREEN phase — update PR body template (**sub-agent**).** Dispatch a sub-agent to:
  - Update the PR body template in Step 6 (lines 120-152) to include all 6 required sections:
    1. **Summary** — 1-2 sentences describing stakeholder value, sourced from issue body
    2. **Outcome** — What changed for stakeholders
    3. **VbC results table** — Per-SC evidence with SC ID, Criterion, Evidence Type, Command, Result
    4. **Adversarial auditor results** — Dual-auditor cross-validation table
    5. **Spec-card-mapped commits table** — Commit-to-issue mapping
    6. **AI byline** — `🤖 Co-authored with AI: <AgentName> (<ModelId>)`
  - Update the PR Body Requirements section (lines 160-171) to document all 6 sections
  - Update the base branch reference from `dev` to `<target>` in Step 6
  - **→ SC-5**
- [x] 110. **Z3 check — GREEN (**sub-agent**).** Dispatch a sub-agent to verify all 6 required sections are present in the PR body template. **→ SC-5**
- [x] 111. **Post-GREEN enforcement (**inline**).** Confirm all changes are staged and working tree is clean. **→ SC-5**
- [x] 112. **Z3 check — post-GREEN (**sub-agent**).** Dispatch a sub-agent to verify working tree is clean and only intended files modified. **→ SC-5**
- [x] 113. **Checkpoint tag create (**inline**).** Create checkpoint tag: `git tag -a opencode-config/checkpoint/1540/phase-5-opencode -m "Phase 5 complete: PR body template updated"`. **→ SC-5**
- [x] 114. **Checkpoint commit (**inline**).** Commit all Phase 5 changes with message: `Phase 5: Update PR body template with 6 required sections`. **→ SC-5**
- [x] 115. **Structural checks (**sub-agent**).** Dispatch a sub-agent to verify all 6 sections present in the PR body template: Summary, Outcome, VbC results, Adversarial auditor results, Commits table, AI byline. **→ SC-5**
- [x] 116. **GREEN doublecheck (**sub-agent**).** Dispatch a sub-agent to re-run the content-verification test and confirm it PASSES (all 6 sections present). **→ SC-5**
- [x] 117. **GREEN VbC (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-5 against the content-verification test output. **→ SC-5**
- [x] 118. **Adversarial audit — Phase 5 (**sub-agent**).** Dispatch adversarial auditor pair to audit Phase 5 changes. **→ SC-5**
- [x] 119. **Cross-validate — Phase 5 (**sub-agent**).** Dispatch a sub-agent to cross-validate auditor consensus for SC-5. **→ SC-5**
- [x] 120. **Regression check — Phase 5 (**sub-agent**).** Dispatch a sub-agent to run existing enforcement tests and confirm no regressions. **→ SC-5**
- [x] 121. **Review prep — Phase 5 (**sub-agent**).** Dispatch a sub-agent to prepare review summary for Phase 5 changes. **→ SC-5**
- [x] 122. **Executive summary — Phase 5 (**inline**).** Report Phase 5 completion: PR body template updated with all 6 required sections. **→ SC-5**

#### Phase 5 VbC

- [ ] 123. **VbC (**clean-room**).** Verify SC-5: PR body includes all 6 required sections. Content-verification test confirms PASS. **→ SC-5**

**Concern transition:** Leaving PR body template update → entering rebase timing definition. Phase 6 depends on Phase 1 (rebase timing is independent of PR path).

## Phase 6 — Define rebase timing

- **Concern:** Rebase at three fixed points (before branch creation, before PR creation, after push)
- **Files:** `.opencode/skills/git-workflow/tasks/pre-work.md`, `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md`
- **SCs:** SC-8 (behavioral)
- **Dependencies:** Phase 1
- **Entry:** Phase 1 complete, checkpoint tag exists
- **Exit:** Rebase steps added to `pre-work.md` (before branch creation) and `create-pr.md` (before PR creation, after push); behavioral test for SC-8 passes

- [x] 124. **SC coherence gate (**clean-room**).** Verify SC-8 is well-formed: behavioral evidence type, testable via `opencode-cli run`, success criterion matches spec. **→ SC-8**
- [x] 125. **Pre-RED baseline (**inline**).** Read `.opencode/skills/git-workflow/tasks/pre-work.md` and `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` to establish baseline. Record current rebase-related content (none defined at the three fixed points). **→ SC-8**
- [x] 126. **RED phase — behavioral test (**sub-agent**).** Dispatch a sub-agent to write a behavioral enforcement test that sends a full workflow prompt and asserts rebase at three points: before branch creation, before PR creation, after push. Write to `./tmp/behavioral-evidence-SC-8-red.sh`. **→ SC-8**
- [x] 127. **Z3 check — RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid assertion syntax. **→ SC-8**
- [x] 128. **RED doublecheck (**sub-agent**).** Dispatch a sub-agent to run the RED test and confirm it FAILS (rebase timing not defined). **→ SC-8**
- [x] 129. **Z3 check — RED doublecheck (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-8**
- [x] 130. **Post-RED enforcement (**inline**).** Confirm RED test artifact is committed. **→ SC-8**
- [x] 131. **Z3 check — post-RED (**sub-agent**).** Dispatch a sub-agent to verify the RED test is committed and working tree is clean. **→ SC-8**
- [x] 132. **GREEN phase — add rebase timing (**sub-agent**).** Dispatch a sub-agent to:
  - In `.opencode/skills/git-workflow/tasks/pre-work.md`: Add a rebase step before branch creation (before Step 3) that syncs with the target branch: `git fetch origin <target> && git rebase origin/<target>`
  - In `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md`: Add a rebase step before PR creation (before Step 6) that ensures mergability: `git fetch origin <target> && git rebase origin/<target>`
  - In `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md`: Add a rebase step after push (after Step 4 equivalent in squash-push) that double-checks remote for conflicts: `git fetch origin <target> && git rebase origin/<target>`
  - **→ SC-8**
- [x] 133. **Z3 check — GREEN (**sub-agent**).** Dispatch a sub-agent to verify rebase steps are present at all three points: (a) before branch creation in `pre-work.md`, (b) before PR creation in `create-pr.md`, (c) after push in `create-pr.md`. **→ SC-8**
- [x] 134. **Post-GREEN enforcement (**inline**).** Confirm all changes are staged and working tree is clean. **→ SC-8**
- [x] 135. **Z3 check — post-GREEN (**sub-agent**).** Dispatch a sub-agent to verify working tree is clean and only intended files modified. **→ SC-8**
- [x] 136. **Checkpoint tag create (**inline**).** Create checkpoint tag: `git tag -a opencode-config/checkpoint/1540/phase-6-opencode -m "Phase 6 complete: rebase timing defined"`. **→ SC-8**
- [x] 137. **Checkpoint commit (**inline**).** Commit all Phase 6 changes with message: `Phase 6: Define rebase timing at three fixed points`. **→ SC-8**
- [x] 138. **Structural checks (**sub-agent**).** Dispatch a sub-agent to verify rebase steps at all three points in both files. **→ SC-8**
- [x] 139. **GREEN doublecheck (**sub-agent**).** Dispatch a sub-agent to re-run the behavioral test and confirm it PASSES (rebase at all three points). **→ SC-8**
- [x] 140. **GREEN VbC (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-8 against the behavioral test output. **→ SC-8**
- [x] 141. **Adversarial audit — Phase 6 (**sub-agent**).** Dispatch adversarial auditor pair to audit Phase 6 changes. **→ SC-8**
- [x] 142. **Cross-validate — Phase 6 (**sub-agent**).** Dispatch a sub-agent to cross-validate auditor consensus for SC-8. **→ SC-8**
- [x] 143. **Regression check — Phase 6 (**sub-agent**).** Dispatch a sub-agent to run existing enforcement tests and confirm no regressions. **→ SC-8**
- [x] 144. **Review prep — Phase 6 (**sub-agent**).** Dispatch a sub-agent to prepare review summary for Phase 6 changes. **→ SC-8**
- [x] 145. **Executive summary — Phase 6 (**inline**).** Report Phase 6 completion: rebase timing defined at three fixed points. **→ SC-8**

#### Phase 6 VbC

- [ ] 146. **VbC (**clean-room**).** Verify SC-8: rebate at three fixed points (before branch creation, before PR creation, after push). Behavioral test confirms PASS. **→ SC-8**

**Concern transition:** Leaving rebase timing definition → entering release-promotion removal. Phase 7 depends on Phase 1 (release-promotion changes after dev bootstrap removal).

## Phase 7 — Unify release into single PR path (delete release-promotion.md)

- **Concern:** Release IS a PR — same `create-pr` workflow, different target branch (`main`). `release-promotion.md` deleted. `create-pr.md` absorbs release-specific post-merge steps (semver tagging, platform release creation, release notes synthesis) gated by `--release` flag. Submodule SHA locking (Steps 1-3 of former `release-promotion.md`) removed — already handled by tag-based hash permanence system.
- **Files:**
  - `.opencode/skills/git-workflow/tasks/release-promotion.md` — DELETE
  - `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` — ADD `--release` mode with post-merge steps
  - `.opencode/skills/git-workflow/SKILL.md` — UPDATE routing table, trigger dispatch, tasks list, invocation
  - `.opencode/skills/git-workflow/tasks/provenance.md` — UPDATE cross-references
  - `.opencode/skills/git-workflow/tasks/provenance/promotion-provenance.md` — UPDATE cross-references
  - `.opencode/skills/pr-creation-workflow/SKILL.md` — UPDATE Overview line 15
- **SCs:** SC-7 (behavioral), SC-10 (behavioral), SC-11 (structural), SC-12 (structural — no implementation needed)
- **Dependencies:** Phase 1
- **Entry:** Phase 1 complete, checkpoint tag exists
- **Exit:** `release-promotion.md` deleted; `create-pr.md` has `--release` mode with post-merge steps; `git-workflow/SKILL.md` routing table dispatches release to `pr-creation` with `{is_release: true}`; `provenance.md` and `promotion-provenance.md` have no stale cross-references; `pr-creation-workflow/SKILL.md` Overview line 15 updated; behavioral tests for SC-7 and SC-10 pass; content-verification test for SC-11 passes

- [ ] 147. **SC coherence gate — SC-7 (**clean-room**).** Verify SC-7 is well-formed: behavioral evidence type, testable via `opencode-cli run`, success criterion matches spec (agent routes release PR through `pr-creation-workflow`, not `release-promotion`). **→ SC-7**
- [ ] 148. **SC coherence gate — SC-10 (**clean-room**).** Verify SC-10 is well-formed: behavioral evidence type, testable via `opencode-cli run`, success criterion matches spec (routing table dispatches release PR to `pr-creation-workflow`). **→ SC-10**
- [ ] 149. **SC coherence gate — SC-11 (**clean-room**).** Verify SC-11 is well-formed: structural evidence type, testable via grep for stale `release-promotion.md` references, success criterion matches spec. **→ SC-11**
- [ ] 150. **SC coherence gate — SC-12 (**clean-room**).** Verify SC-12 is well-formed: structural evidence type, testable via grep for non-goals and invariants in spec, success criterion matches spec. Confirm SC-12 requires no implementation (non-goals and invariants already updated in spec). **→ SC-12**
- [ ] 151. **Pre-RED baseline (**inline**).** Read all target files to establish baseline:
  - `.opencode/skills/git-workflow/tasks/release-promotion.md` — full content
  - `.opencode/skills/git-workflow/SKILL.md` — Trigger Dispatch Table line 33 (`release-promotion`), Tasks list line 52, Invocation table line 82, Routing section lines 64-68
  - `.opencode/skills/git-workflow/tasks/pr-creation/create-pr.md` — current content (no `--release` mode)
  - `.opencode/skills/git-workflow/tasks/provenance.md` — cross-references to `release-promotion` (line 97)
  - `.opencode/skills/git-workflow/tasks/provenance/promotion-provenance.md` — cross-references to `release-promotion` (line 138)
  - `.opencode/skills/pr-creation-workflow/SKILL.md` — Overview line 15
  - **→ SC-7, SC-10, SC-11**
- [ ] 152. **RED phase — behavioral test SC-7 (**sub-agent**).** Dispatch a sub-agent to write a behavioral enforcement test that sends a "release PR" / "promote to main" prompt and asserts the agent routes through `pr-creation-workflow` (not `release-promotion`). Write to `./tmp/behavioral-evidence-SC-7-red.sh`. **→ SC-7**
- [ ] 153. **Z3 check — RED SC-7 (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid assertion syntax. **→ SC-7**
- [ ] 154. **RED doublecheck — SC-7 (**sub-agent**).** Dispatch a sub-agent to run the SC-7 behavioral test and confirm it FAILS (agent still routes to `release-promotion`). **→ SC-7**
- [ ] 155. **Z3 check — RED doublecheck SC-7 (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-7**
- [ ] 156. **RED phase — behavioral test SC-10 (**sub-agent**).** Dispatch a sub-agent to write a behavioral enforcement test that sends a "release" / "promote to main" prompt and asserts the `git-workflow/SKILL.md` routing table dispatches to `pr-creation` with `{is_release: true}`. Write to `./tmp/behavioral-evidence-SC-10-red.sh`. **→ SC-10**
- [ ] 157. **Z3 check — RED SC-10 (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid assertion syntax. **→ SC-10**
- [ ] 158. **RED doublecheck — SC-10 (**sub-agent**).** Dispatch a sub-agent to run the SC-10 behavioral test and confirm it FAILS (routing table still dispatches to `release-promotion`). **→ SC-10**
- [ ] 159. **Z3 check — RED doublecheck SC-10 (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-10**
- [ ] 160. **RED phase — content-verification test SC-11 (**sub-agent**).** Dispatch a sub-agent to write a content-verification test that greps `provenance.md` and `promotion-provenance.md` for stale `release-promotion.md` references. Write to `./tmp/behavioral-evidence-SC-11-red.sh`. **→ SC-11**
- [ ] 161. **Z3 check — RED SC-11 (**sub-agent**).** Dispatch a sub-agent to verify the RED test artifact exists and contains valid grep assertions. **→ SC-11**
- [ ] 162. **RED doublecheck — SC-11 (**sub-agent**).** Dispatch a sub-agent to run the SC-11 content-verification test and confirm it FAILS (stale references still present). **→ SC-11**
- [ ] 163. **Z3 check — RED doublecheck SC-11 (**sub-agent**).** Dispatch a sub-agent to verify the doublecheck produced a FAIL result artifact. **→ SC-11**
- [ ] 164. **Post-RED enforcement (**inline**).** Confirm all RED test artifacts are committed. **→ SC-7, SC-10, SC-11**
- [ ] 165. **Z3 check — post-RED (**sub-agent**).** Dispatch a sub-agent to verify all RED tests are committed and working tree is clean. **→ SC-7, SC-10, SC-11**
- [ ] 166. **GREEN phase — delete release-promotion.md and unify release path (**sub-agent**).** Dispatch a sub-agent to:

  **1. Delete `release-promotion.md`:**
  - `rm .opencode/skills/git-workflow/tasks/release-promotion.md`

  **2. Update `git-workflow/SKILL.md`:**
  - Trigger Dispatch Table line 33: Replace `"release" / "promote to main" / "target to main"` → `release-promotion` with `"release" / "promote to main" / "target to main"` → `pr-creation` with `{is_release: true}`
  - Tasks list: Remove `release-promotion` from the tasks list
  - Invocation table: Remove the `release-promotion` row
  - Routing section (lines 64-68): Replace `Release PR (target → main) | git-workflow --task release-promotion` with `Release PR (target → main) | pr-creation-workflow skill with {is_release: true}`

  **3. Update `create-pr.md` — Add `--release` mode with post-merge steps:**
  - Add a new section at the top (after Purpose, before Entry Criteria): `## --release Mode (Post-Merge Steps)`
  - Document that when invoked with `--release` flag, the task performs post-merge steps after PR merge:
    - **Semver tagging:** Auto-increment patch version (or developer-specified), create annotated tag on `main`
    - **Platform release creation:** Create GitHub/GitBucket release with synthesized release notes
    - **Release notes synthesis:** Summarize changes since last release by category (features, fixes, maintenance)
  - Add to Entry Criteria: `--release mode: PR has been merged by human, developer requests post-merge steps`
  - Add to Exit Criteria: `--release mode: Semver tag created and pushed, platform release created, release notes posted`
  - Add a new Step 7 (after Step 6.5): `### Step 6.75: Check for --release Flag` — if `is_release: true`, proceed to post-merge steps; otherwise, continue to Step 7
  - Add post-merge steps as Step 7.x sub-steps (tag, push tags, create platform release)
  - Update Step 6 PR body template: When `is_release: true`, use release-style title (`Release v<version>: promote <target> → main`) and synthesize release notes from commit log

  **4. Update `provenance.md`:**
  - Line 97: Replace `Related skills: \`git-workflow --task release-promotion\`` with `Related skills: \`git-workflow --task pr-creation\` (with \`--release\` flag)`

  **5. Update `promotion-provenance.md`:**
  - Line 138: Replace `Related skill: \`git-workflow --task release-promotion\`` with `Related skill: \`git-workflow --task pr-creation\` (with \`--release\` flag)`

  **6. Update `pr-creation-workflow/SKILL.md`:**
  - Overview line 15: Replace `Feature PRs target any branch. Release PRs handled by \`git-workflow --task release-promotion\`.` with `Feature PRs target any branch. Release PRs handled by \`git-workflow --task pr-creation\` with \`{is_release: true}\` flag.`

  **→ SC-7, SC-10, SC-11**
- [ ] 167. **Z3 check — GREEN (**sub-agent**).** Dispatch a sub-agent to verify:
  - (a) `release-promotion.md` no longer exists
  - (b) `git-workflow/SKILL.md` Trigger Dispatch Table routes release to `pr-creation` with `{is_release: true}`
  - (c) `git-workflow/SKILL.md` Tasks list has no `release-promotion`
  - (d) `git-workflow/SKILL.md` Invocation table has no `release-promotion`
  - (e) `git-workflow/SKILL.md` Routing section routes release to `pr-creation-workflow`
  - (f) `create-pr.md` has `--release` mode section with post-merge steps (semver tagging, platform release creation, release notes synthesis)
  - (g) `provenance.md` has no stale `release-promotion` references
  - (h) `promotion-provenance.md` has no stale `release-promotion` references
  - (i) `pr-creation-workflow/SKILL.md` Overview line 15 updated
  - **→ SC-7, SC-10, SC-11**
- [ ] 168. **Post-GREEN enforcement (**inline**).** Confirm all changes are staged and working tree is clean. **→ SC-7, SC-10, SC-11**
- [ ] 169. **Z3 check — post-GREEN (**sub-agent**).** Dispatch a sub-agent to verify working tree is clean and only intended files modified. **→ SC-7, SC-10, SC-11**
- [ ] 170. **Checkpoint tag create (**inline**).** Create checkpoint tag: `git tag -a opencode-config/checkpoint/1540/phase-7-opencode -m "Phase 7 complete: release-promotion deleted, release unified into single PR path"`. **→ SC-7, SC-10, SC-11**
- [ ] 171. **Checkpoint commit (**inline**).** Commit all Phase 7 changes with message: `Phase 7: Unify release into single PR path — delete release-promotion.md, add --release mode to create-pr.md, update routing`. **→ SC-7, SC-10, SC-11**
- [ ] 172. **Structural checks — SC-11 (**sub-agent**).** Dispatch a sub-agent to verify: (a) `provenance.md` has no stale `release-promotion` references, (b) `promotion-provenance.md` has no stale `release-promotion` references, (c) `pr-creation-workflow/SKILL.md` Overview line 15 updated. **→ SC-11**
- [ ] 173. **GREEN doublecheck — SC-7 (**sub-agent**).** Dispatch a sub-agent to re-run the SC-7 behavioral test and confirm it PASSES (agent routes release PR through `pr-creation-workflow`). **→ SC-7**
- [ ] 174. **GREEN doublecheck — SC-10 (**sub-agent**).** Dispatch a sub-agent to re-run the SC-10 behavioral test and confirm it PASSES (routing table dispatches release to `pr-creation` with `{is_release: true}`). **→ SC-10**
- [ ] 175. **GREEN doublecheck — SC-11 (**sub-agent**).** Dispatch a sub-agent to re-run the SC-11 content-verification test and confirm it PASSES (no stale cross-references). **→ SC-11**
- [ ] 176. **GREEN VbC — SC-7 (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-7 against the behavioral test output. **→ SC-7**
- [ ] 177. **GREEN VbC — SC-10 (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-10 against the behavioral test output. **→ SC-10**
- [ ] 178. **GREEN VbC — SC-11 (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-11 against the content-verification test output. **→ SC-11**
- [ ] 179. **GREEN VbC — SC-12 (**clean-room**).** Dispatch a clean-room sub-agent to verify SC-12: non-goals and invariants already updated in spec (no implementation needed). **→ SC-12**
- [ ] 180. **Adversarial audit — Phase 7 (**sub-agent**).** Dispatch adversarial auditor pair to audit Phase 7 changes across all 4 SCs. **→ SC-7, SC-10, SC-11, SC-12**
- [ ] 181. **Cross-validate — Phase 7 (**sub-agent**).** Dispatch a sub-agent to cross-validate auditor consensus for SC-7, SC-10, SC-11, SC-12. **→ SC-7, SC-10, SC-11, SC-12**
- [ ] 182. **Regression check — Phase 7 (**sub-agent**).** Dispatch a sub-agent to run existing enforcement tests and confirm no regressions. **→ SC-7, SC-10, SC-11, SC-12**
- [ ] 183. **Review prep — Phase 7 (**sub-agent**).** Dispatch a sub-agent to prepare review summary for Phase 7 changes. **→ SC-7, SC-10, SC-11, SC-12**
- [ ] 184. **Executive summary — Phase 7 (**inline**).** Report Phase 7 completion: `release-promotion.md` deleted, `create-pr.md` has `--release` mode with post-merge steps, routing table updated, cross-references cleaned. **→ SC-7, SC-10, SC-11, SC-12**

#### Phase 7 VbC

- [ ] 185. **VbC — SC-7 (**clean-room**).** Verify SC-7: agent routes release PR through `pr-creation-workflow`, not `release-promotion`. Behavioral test confirms PASS. **→ SC-7**
- [ ] 186. **VbC — SC-10 (**clean-room**).** Verify SC-10: routing table dispatches release PR to `pr-creation-workflow`. Behavioral test confirms PASS. **→ SC-10**
- [ ] 187. **VbC — SC-11 (**clean-room**).** Verify SC-11: no stale cross-references to `release-promotion.md` in `provenance.md` or `promotion-provenance.md`. Content-verification test confirms PASS. **→ SC-11**
- [ ] 188. **VbC — SC-12 (**clean-room**).** Verify SC-12: non-goals and invariants already updated in spec. No implementation needed. **→ SC-12**

**Concern transition:** Leaving release-promotion removal → entering global post-phase verification and PR creation.

### Global Post-Phase

- [ ] 189. **Collect behavioral evidence (**sub-agent**).** Dispatch a sub-agent to collect all behavioral evidence artifacts from `./tmp/behavioral-evidence-*/` into `./tmp/1540/artifacts/`. **→ All SCs**
- [ ] 190. **Full regression test suite (**sub-agent**).** Dispatch a sub-agent to run the full enforcement test suite: `bash .opencode/tests/test-enforcement.sh --changed` and all behavioral tests. **→ All SCs**
- [ ] 191. **Lint and format checks (**sub-agent**).** Dispatch a sub-agent to run lint/format on all modified files: `uvx ruff check .opencode/skills/` and `uvx pymarkdownlnt scan -r .opencode/skills/`. **→ All SCs**
- [ ] 192. **Final adversarial audit — all phases (**sub-agent**).** Dispatch adversarial auditor pair to audit all 7 phases together for cross-phase consistency. **→ All SCs**
- [ ] 193. **Cross-validate — all phases (**sub-agent**).** Dispatch a sub-agent to cross-validate auditor consensus across all SCs. **→ All SCs**
- [ ] 194. **Review prep — all phases (**sub-agent**).** Dispatch a sub-agent to prepare the final review summary covering all 7 phases. **→ All SCs**
- [ ] 195. **Executive summary — all phases (**inline**).** Report final completion: all 7 phases complete, all SCs verified PASS. **→ All SCs**

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
>
> **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.

## Exit Criteria

- C1. Phase 1 complete: Pre-work no longer auto-creates `dev` branch (SC-1 behavioral PASS)
- C2. Phase 2 complete: PR creation accepts any target branch (SC-2 behavioral PASS)
- C3. Phase 3 complete: No dev-specific rules remain in git-workflow SKILL.md (SC-6 semantic + string PASS)
- [x] C4. Phase 4 complete: Squash mandatory for all branches at PR time, commit messages follow `#<issue> <title> — <summary>` (SC-3 behavioral PASS, SC-4 string + semantic PASS)
- C4a. Phase 4a complete: RED tests follow artifact-only generator paradigm (SC-9 structural PASS)
- [x] C5. Phase 5 complete: PR body includes all 6 required sections (SC-5 structural PASS)
- [x] C6. Phase 6 complete: Rebase at three fixed points (SC-8 behavioral PASS)
- C7. Phase 7 complete: Release-promotion deleted, release unified into single PR path (SC-7 behavioral PASS, SC-10 behavioral PASS, SC-11 structural PASS, SC-12 structural PASS)
- C8. All behavioral enforcement tests pass for SC-1, SC-2, SC-3, SC-4, SC-7, SC-8, SC-10
- C9. All content-verification tests pass for SC-5, SC-6, SC-11
- C10. Lint/format checks pass on all modified files
- C11. No regressions in existing enforcement tests
- C12. All changes committed to feature branch `feature/1540-single-path-workflow`
- C13. PR created targeting `dev` with complete summary of all 7 phases
