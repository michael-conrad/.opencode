---
plan_schema_version: "1.0"
issue: 2205
title: "Remove stale implementation-pipeline and executing-plans references"
authorization_scope: for_plan
pr_strategy: stacked
phase_count: 7
---

# Implementation Plan — #2205 — Remove stale implementation-pipeline and executing-plans references

**Goal:** Remove all references to the deleted `implementation-pipeline` skill and its vestigial forwarding layer `executing-plans` across 40 files in `.opencode/`.

**Architecture:** All SCs are string or structural evidence — grep-verifiable file edits and deletions. No runtime behavior changes. The plan uses a daisy-chain structure: one pre-regression baseline, then per-item RED/GREEN/VERIFY/COMMIT cycles in implementation order, then one post-regression + audit + Z3 check.

**Files:**
- `.opencode/skills/executing-plans/` (delete entire directory)
- `.opencode/dispatch-table.yaml`
- `.opencode/skills/` (multiple SKILL.md and task files)
- `.opencode/guidelines/065-verification-honesty.md`
- `.opencode/prompts/default.txt`
- `.opencode/scripts/session_context_triggers.py`
- `.opencode/README.md`
- `.opencode/tests-v2/behaviors/` (5 test files)
- `.opencode/skills/writing-plans/reference/` (2 files)

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On |
|-------|-------|------|--------|-----|------------|
| 1 — Delete executing-plans | `general` | `edit` | `skills/executing-plans/` directory | SC-1 | — |
| 2 — Remove dispatch-table entries | `general` | `edit` | `dispatch-table.yaml` | SC-2 | — |
| 3 — Bulk .md file cleanup | `general` | `edit` | All `.md` files with stale refs | SC-3 | — |
| 4 — Bulk non-md file cleanup | `general` | `edit` | yaml, py, txt, sh files | SC-4 | — |
| 5 — Remove obsolete test | `general` | `edit` | `rationalization-check-remediation.sh` | SC-5 | — |
| 6 — Update behavioral tests | `general` | `edit` | 5 behavioral test files | SC-6,7,8,9,10 | — |
| 7 — Individual file cleanup | `general` | `edit` | 8 individual files | SC-11,12,13,14,15,16,17,18 | — |

---

## Pre-implementation

- [ ] 1. **Coherence gate (**sub-agent**).** Dispatch coherence extraction to verify spec/plan coherence before any RED routing.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "execute coherence-extraction from audit. Read \`audit/tasks/coherence-extraction.md\` first")`
- [ ] 2. **Baseline check (**sub-agent**).** Verify baseline state: confirm all affected files exist, current git state is clean, no stale artifacts from prior runs.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify baseline state for issue 2205: check git status, confirm affected files exist, clean stale artifacts")`
- [ ] 3. **Pre-regression (**sub-agent**).** Run grep for `implementation-pipeline` across `.opencode/` to establish baseline match count. Capture to artifact.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "run grep for 'implementation-pipeline' across .opencode/ --include and --exclude patterns. Capture baseline match count and save to artifact")`
- [ ] 4. **Pre-regression-verify (**sub-agent**).** Verify pre-regression results: confirm baseline captured, match count recorded.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify pre-regression results for issue 2205. Confirm baseline match count was captured and saved to artifact")`

---

## Daisy Chain — Implementation Items

### Phase 1 — Delete executing-plans directory (SC-1)

**Concern:** Remove vestigial forwarding skill directory.

**Files:** `.opencode/skills/executing-plans/`

**SCs:** SC-1

**Entry Conditions:** Pre-regression baseline established.

**Exit Conditions:** `ls .opencode/skills/executing-plans/` returns error.

- [ ] 5. **RED (**sub-agent**).** Write enforcement test: `ls .opencode/skills/executing-plans/` — expect directory to exist (test fails because it does). **→ SC-1**
  - Context: `{issue_number: 2205, sc: SC-1}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-1: ls .opencode/skills/executing-plans/ — expect directory to exist. Test must fail initially because directory exists")`
- [ ] 6. **GREEN (**sub-agent**).** Delete `.opencode/skills/executing-plans/` directory via `rm -rf`. **→ SC-1**
  - Context: `{issue_number: 2205, sc: SC-1}`
  - Dispatch: `task(..., prompt: "delete .opencode/skills/executing-plans/ directory via rm -rf. Confirm deletion with ls")`
- [ ] 7. **VERIFY (**sub-agent**).** Confirm `ls .opencode/skills/executing-plans/` returns error. **→ SC-1**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-1: ls .opencode/skills/executing-plans/ — confirm 'No such file or directory'")`
- [ ] 8. **COMMIT (**inline**).** Commit Phase 1 changes.
  - Command: `git rm -r .opencode/skills/executing-plans/ && git commit -m "Phase 1: delete executing-plans skill directory"`

---

### Phase 2 — Remove dispatch-table entries (SC-2)

**Concern:** Remove 5 stale skill routing entries from dispatch-table.yaml.

**Files:** `.opencode/dispatch-table.yaml`

**SCs:** SC-2

**Entry Conditions:** Phase 1 committed.

**Exit Conditions:** `grep -c "implementation-pipeline" .opencode/dispatch-table.yaml` returns 0.

- [ ] 9. **RED (**sub-agent**).** Write enforcement test: `grep -c "implementation-pipeline" .opencode/dispatch-table.yaml` — expect >0 (test fails because matches exist). **→ SC-2**
  - Context: `{issue_number: 2205, sc: SC-2}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-2: grep -c 'implementation-pipeline' .opencode/dispatch-table.yaml — expect >0. Test must fail initially because matches exist")`
- [ ] 10. **GREEN (**sub-agent**).** Remove 5 entries from `dispatch-table.yaml` that route to `implementation-pipeline`. **→ SC-2**
  - Context: `{issue_number: 2205, sc: SC-2, affected_file: ".opencode/dispatch-table.yaml"}`
  - Dispatch: `task(..., prompt: "edit .opencode/dispatch-table.yaml: remove 5 entries that route to skill: implementation-pipeline. Lines 126-133 and 192-204")`
- [ ] 11. **VERIFY (**sub-agent**).** Confirm `grep -c "implementation-pipeline" .opencode/dispatch-table.yaml` returns 0. **→ SC-2**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-2: grep -c 'implementation-pipeline' .opencode/dispatch-table.yaml — confirm 0 matches")`
- [ ] 12. **COMMIT (**inline**).** Commit Phase 2 changes.
  - Command: `git add .opencode/dispatch-table.yaml && git commit -m "Phase 2: remove implementation-pipeline entries from dispatch-table.yaml"`

---

### Phase 3 — Bulk .md file cleanup (SC-3)

**Concern:** Remove `implementation-pipeline` references from all `.md` files except CHANGELOG.md.

**Files:** All `.md` files in `.opencode/` with stale references (25+ files across skills, guidelines, tests).

**SCs:** SC-3

**Entry Conditions:** Phase 2 committed.

**Exit Conditions:** `grep -r "implementation-pipeline" .opencode/ --include="*.md" | grep -v CHANGELOG.md | wc -l` returns 0.

- [ ] 13. **RED (**sub-agent**).** Write enforcement test: `grep -r "implementation-pipeline" .opencode/ --include="*.md" | grep -v CHANGELOG.md | wc -l` — expect >0 (test fails because matches exist). **→ SC-3**
  - Context: `{issue_number: 2205, sc: SC-3}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-3: grep -r 'implementation-pipeline' .opencode/ --include='*.md' | grep -v CHANGELOG.md | wc -l — expect >0. Test must fail initially because matches exist")`
- [ ] 14. **GREEN (**sub-agent**).** For each `.md` file with `implementation-pipeline` references (excluding CHANGELOG.md), replace or remove the reference per the spec's remediation instructions. **→ SC-3**
  - Context: `{issue_number: 2205, sc: SC-3}`
  - Dispatch: `task(..., prompt: "find all .md files in .opencode/ with 'implementation-pipeline' references (exclude CHANGELOG.md). For each file, replace or remove the reference per the spec's remediation instructions. Files include: approval-gate/SKILL.md, approval-gate-scope/SKILL.md, approval-gate-scope/tasks/*.md, writing-plans/SKILL.md, writing-plans/tasks/create.md, writing-plans/reference/*.md, git-workflow-branch/tasks/*.md, git-workflow-cleanup/tasks/*.md, git-workflow-pr/tasks/*.md, pr-creation-workflow/tasks/*.md, finishing-a-development-branch/tasks/*.md, using-git-worktrees/tasks/*.md, pre-analysis/tasks/*.md, verification-enforcement/tasks/*.md, issue-operations-core/tasks/*.md, guidelines/065-verification-honesty.md, README.md")`
- [ ] 15. **VERIFY (**sub-agent**).** Confirm `grep -r "implementation-pipeline" .opencode/ --include="*.md" | grep -v CHANGELOG.md | wc -l` returns 0. **→ SC-3**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-3: grep -r 'implementation-pipeline' .opencode/ --include='*.md' | grep -v CHANGELOG.md | wc -l — confirm 0 matches")`
- [ ] 16. **COMMIT (**inline**).** Commit Phase 3 changes.
  - Command: `git add .opencode/ && git commit -m "Phase 3: remove implementation-pipeline references from .md files"`

---

### Phase 4 — Bulk non-md file cleanup (SC-4)

**Concern:** Remove `implementation-pipeline` references from yaml, py, txt, sh files.

**Files:** `.opencode/dispatch-table.yaml`, `.opencode/scripts/session_context_triggers.py`, `.opencode/prompts/default.txt`, `.opencode/tests-v2/behaviors/*.sh`

**SCs:** SC-4

**Entry Conditions:** Phase 3 committed.

**Exit Conditions:** `grep -r "implementation-pipeline" .opencode/ --include="*.yaml" --include="*.py" --include="*.txt" --include="*.sh" | wc -l` returns 0.

- [ ] 17. **RED (**sub-agent**).** Write enforcement test: `grep -r "implementation-pipeline" .opencode/ --include="*.yaml" --include="*.py" --include="*.txt" --include="*.sh" | wc -l` — expect >0 (test fails because matches exist). **→ SC-4**
  - Context: `{issue_number: 2205, sc: SC-4}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-4: grep -r 'implementation-pipeline' .opencode/ --include='*.yaml' --include='*.py' --include='*.txt' --include='*.sh' | wc -l — expect >0. Test must fail initially because matches exist")`
- [ ] 18. **GREEN (**sub-agent**).** For each non-md file with `implementation-pipeline` references, replace or remove the reference per the spec's remediation instructions. **→ SC-4**
  - Context: `{issue_number: 2205, sc: SC-4}`
  - Dispatch: `task(..., prompt: "find all non-md files in .opencode/ with 'implementation-pipeline' references (yaml, py, txt, sh). For each file, replace or remove the reference per the spec's remediation instructions. Files include: dispatch-table.yaml (already cleaned in Phase 2), session_context_triggers.py, default.txt, behavioral test .sh files")`
- [ ] 19. **VERIFY (**sub-agent**).** Confirm `grep -r "implementation-pipeline" .opencode/ --include="*.yaml" --include="*.py" --include="*.txt" --include="*.sh" | wc -l` returns 0. **→ SC-4**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-4: grep -r 'implementation-pipeline' .opencode/ --include='*.yaml' --include='*.py' --include='*.txt' --include='*.sh' | wc -l — confirm 0 matches")`
- [ ] 20. **COMMIT (**inline**).** Commit Phase 4 changes.
  - Command: `git add .opencode/ && git commit -m "Phase 4: remove implementation-pipeline references from non-md files"`

---

### Phase 5 — Remove obsolete behavioral test (SC-5)

**Concern:** Remove `rationalization-check-remediation.sh` which checks a non-existent file path.

**Files:** `.opencode/tests-v2/behaviors/rationalization-check-remediation.sh`

**SCs:** SC-5

**Entry Conditions:** Phase 4 committed.

**Exit Conditions:** `ls .opencode/tests-v2/behaviors/rationalization-check-remediation.sh` returns error.

- [ ] 21. **RED (**sub-agent**).** Write enforcement test: `ls .opencode/tests-v2/behaviors/rationalization-check-remediation.sh` — expect file to exist (test fails because it does). **→ SC-5**
  - Context: `{issue_number: 2205, sc: SC-5}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-5: ls .opencode/tests-v2/behaviors/rationalization-check-remediation.sh — expect file to exist. Test must fail initially because file exists")`
- [ ] 22. **GREEN (**sub-agent**).** Delete `rationalization-check-remediation.sh`. **→ SC-5**
  - Context: `{issue_number: 2205, sc: SC-5}`
  - Dispatch: `task(..., prompt: "delete .opencode/tests-v2/behaviors/rationalization-check-remediation.sh via git rm. Confirm deletion with ls")`
- [ ] 23. **VERIFY (**sub-agent**).** Confirm `ls .opencode/tests-v2/behaviors/rationalization-check-remediation.sh` returns error. **→ SC-5**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-5: ls .opencode/tests-v2/behaviors/rationalization-check-remediation.sh — confirm 'No such file or directory'")`
- [ ] 24. **COMMIT (**inline**).** Commit Phase 5 changes.
  - Command: `git rm .opencode/tests-v2/behaviors/rationalization-check-remediation.sh && git commit -m "Phase 5: remove obsolete rationalization-check-remediation.sh test"`

---

### Phase 6 — Update behavioral tests (SC-6, SC-7, SC-8, SC-9, SC-10)

**Concern:** Update grep patterns and prompts in 5 behavioral test files to reference the implementation-workflow reference card instead of the deleted skill.

**Files:**
- `.opencode/tests-v2/behaviors/rationalization-check-pipeline.sh`
- `.opencode/tests-v2/behaviors/writing-plans-create.sh`
- `.opencode/tests-v2/behaviors/writing-plans-structure.sh`
- `.opencode/tests-v2/behaviors/1246-sc3-resolve-models-preflight.sh`
- `.opencode/tests-v2/behaviors/2009-sc4-plan-fidelity-pipeline.sh`

**SCs:** SC-6, SC-7, SC-8, SC-9, SC-10

**Entry Conditions:** Phase 5 committed.

**Exit Conditions:** All 5 test files updated. No `implementation-pipeline` references remain in behavioral test files.

#### Item SC-6 — rationalization-check-pipeline.sh

- [ ] 25. **RED (**sub-agent**).** Write enforcement test: grep for `implementation-pipeline` in `rationalization-check-pipeline.sh` — expect matches (test fails because old patterns exist). **→ SC-6**
  - Context: `{issue_number: 2205, sc: SC-6}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-6: grep for 'implementation-pipeline' in .opencode/tests-v2/behaviors/rationalization-check-pipeline.sh — expect matches. Test must fail initially")`
- [ ] 26. **GREEN (**sub-agent**).** Update `rationalization-check-pipeline.sh`: change `SKILL_MD` path to reference card, update grep patterns to `implementation-workflow`. **→ SC-6**
  - Context: `{issue_number: 2205, sc: SC-6, affected_file: ".opencode/tests-v2/behaviors/rationalization-check-pipeline.sh"}`
  - Dispatch: `task(..., prompt: "edit .opencode/tests-v2/behaviors/rationalization-check-pipeline.sh: change SKILL_MD path from implementation-pipeline/SKILL.md to writing-plans/reference/implementation-workflow.md. Update grep patterns from 'implementation-pipeline' to 'implementation-workflow'")`
- [ ] 27. **VERIFY (**sub-agent**).** Confirm `rationalization-check-pipeline.sh` references `implementation-workflow.md` not `implementation-pipeline`. **→ SC-6**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-6: grep for 'implementation-workflow' in .opencode/tests-v2/behaviors/rationalization-check-pipeline.sh — confirm matches. grep for 'implementation-pipeline' — confirm 0 matches")`
- [ ] 28. **COMMIT (**inline**).** Commit SC-6 changes.
  - Command: `git add .opencode/tests-v2/behaviors/rationalization-check-pipeline.sh && git commit -m "Phase 6 SC-6: update rationalization-check-pipeline.sh to reference implementation-workflow card"`

#### Item SC-7 — writing-plans-create.sh

- [ ] 29. **RED (**sub-agent**).** Write enforcement test: grep for `implementation-pipeline` in `writing-plans-create.sh` — expect matches (test fails because old patterns exist). **→ SC-7**
  - Context: `{issue_number: 2205, sc: SC-7}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-7: grep for 'implementation-pipeline' in .opencode/tests-v2/behaviors/writing-plans-create.sh — expect matches. Test must fail initially")`
- [ ] 30. **GREEN (**sub-agent**).** Update `writing-plans-create.sh`: change grep patterns from `implementation-pipeline.*TDT` to `implementation-workflow.*reference.*card`. **→ SC-7**
  - Context: `{issue_number: 2205, sc: SC-7, affected_file: ".opencode/tests-v2/behaviors/writing-plans-create.sh"}`
  - Dispatch: `task(..., prompt: "edit .opencode/tests-v2/behaviors/writing-plans-create.sh: update grep patterns from 'implementation-pipeline.*TDT' to 'implementation-workflow.*reference.*card'. Update comments to match")`
- [ ] 31. **VERIFY (**sub-agent**).** Confirm `writing-plans-create.sh` references `implementation-workflow` not `implementation-pipeline`. **→ SC-7**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-7: grep for 'implementation-workflow' in .opencode/tests-v2/behaviors/writing-plans-create.sh — confirm matches. grep for 'implementation-pipeline' — confirm 0 matches")`
- [ ] 32. **COMMIT (**inline**).** Commit SC-7 changes.
  - Command: `git add .opencode/tests-v2/behaviors/writing-plans-create.sh && git commit -m "Phase 6 SC-7: update writing-plans-create.sh grep patterns"`

#### Item SC-8 — writing-plans-structure.sh

- [ ] 33. **RED (**sub-agent**).** Write enforcement test: grep for `implementation-pipeline` in `writing-plans-structure.sh` — expect matches (test fails because old patterns exist). **→ SC-8**
  - Context: `{issue_number: 2205, sc: SC-8}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-8: grep for 'implementation-pipeline' in .opencode/tests-v2/behaviors/writing-plans-structure.sh — expect matches. Test must fail initially")`
- [ ] 34. **GREEN (**sub-agent**).** Update `writing-plans-structure.sh`: change grep patterns from `implementation-pipeline` to `implementation-workflow`. **→ SC-8**
  - Context: `{issue_number: 2205, sc: SC-8, affected_file: ".opencode/tests-v2/behaviors/writing-plans-structure.sh"}`
  - Dispatch: `task(..., prompt: "edit .opencode/tests-v2/behaviors/writing-plans-structure.sh: update grep patterns from 'implementation-pipeline' to 'implementation-workflow'. Update comments to match")`
- [ ] 35. **VERIFY (**sub-agent**).** Confirm `writing-plans-structure.sh` references `implementation-workflow` not `implementation-pipeline`. **→ SC-8**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-8: grep for 'implementation-workflow' in .opencode/tests-v2/behaviors/writing-plans-structure.sh — confirm matches. grep for 'implementation-pipeline' — confirm 0 matches")`
- [ ] 36. **COMMIT (**inline**).** Commit SC-8 changes.
  - Command: `git add .opencode/tests-v2/behaviors/writing-plans-structure.sh && git commit -m "Phase 6 SC-8: update writing-plans-structure.sh grep patterns"`

#### Item SC-9 — 1246-sc3-resolve-models-preflight.sh

- [ ] 37. **RED (**sub-agent**).** Write enforcement test: grep for `implementation-pipeline` in `1246-sc3-resolve-models-preflight.sh` — expect matches (test fails because old patterns exist). **→ SC-9**
  - Context: `{issue_number: 2205, sc: SC-9}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-9: grep for 'implementation-pipeline' in .opencode/tests-v2/behaviors/1246-sc3-resolve-models-preflight.sh — expect matches. Test must fail initially")`
- [ ] 38. **GREEN (**sub-agent**).** Update `1246-sc3-resolve-models-preflight.sh`: replace tool-recipe prompt with real-domain task "Do an implementation audit on #1246." **→ SC-9**
  - Context: `{issue_number: 2205, sc: SC-9, affected_file: ".opencode/tests-v2/behaviors/1246-sc3-resolve-models-preflight.sh"}`
  - Dispatch: `task(..., prompt: "edit .opencode/tests-v2/behaviors/1246-sc3-resolve-models-preflight.sh: replace the SCENARIO_PROMPT with 'Do an implementation audit on #1246.' Remove all tool-recipe scaffolding (resolve-models, subagent_type, dispatch routing table references)")`
- [ ] 39. **VERIFY (**sub-agent**).** Confirm `1246-sc3-resolve-models-preflight.sh` has no `implementation-pipeline` references. **→ SC-9**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-9: grep for 'implementation-pipeline' in .opencode/tests-v2/behaviors/1246-sc3-resolve-models-preflight.sh — confirm 0 matches")`
- [ ] 40. **COMMIT (**inline**).** Commit SC-9 changes.
  - Command: `git add .opencode/tests-v2/behaviors/1246-sc3-resolve-models-preflight.sh && git commit -m "Phase 6 SC-9: update 1246-sc3-resolve-models-preflight.sh prompt to real-domain task"`

#### Item SC-10 — 2009-sc4-plan-fidelity-pipeline.sh

- [ ] 41. **RED (**sub-agent**).** Write enforcement test: grep for `implementation-pipeline` in `2009-sc4-plan-fidelity-pipeline.sh` — expect matches (test fails because old patterns exist). **→ SC-10**
  - Context: `{issue_number: 2205, sc: SC-10}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-10: grep for 'implementation-pipeline' in .opencode/tests-v2/behaviors/2009-sc4-plan-fidelity-pipeline.sh — expect matches. Test must fail initially")`
- [ ] 42. **GREEN (**sub-agent**).** Update `2009-sc4-plan-fidelity-pipeline.sh`: replace tool-recipe prompt with real-domain task "Verify that the plan for #2009 includes proper pipeline stage references." **→ SC-10**
  - Context: `{issue_number: 2205, sc: SC-10, affected_file: ".opencode/tests-v2/behaviors/2009-sc4-plan-fidelity-pipeline.sh"}`
  - Dispatch: `task(..., prompt: "edit .opencode/tests-v2/behaviors/2009-sc4-plan-fidelity-pipeline.sh: replace the SCENARIO_PROMPT with 'Verify that the plan for #2009 includes proper pipeline stage references.' Remove all tool-recipe scaffolding and implementation-pipeline references")`
- [ ] 43. **VERIFY (**sub-agent**).** Confirm `2009-sc4-plan-fidelity-pipeline.sh` has no `implementation-pipeline` references. **→ SC-10**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-10: grep for 'implementation-pipeline' in .opencode/tests-v2/behaviors/2009-sc4-plan-fidelity-pipeline.sh — confirm 0 matches")`
- [ ] 44. **COMMIT (**inline**).** Commit SC-10 changes.
  - Command: `git add .opencode/tests-v2/behaviors/2009-sc4-plan-fidelity-pipeline.sh && git commit -m "Phase 6 SC-10: update 2009-sc4-plan-fidelity-pipeline.sh prompt to real-domain task"`

---

### Phase 7 — Individual file cleanup (SC-11 through SC-18)

**Concern:** Remove `implementation-pipeline` references from 8 individual files that require targeted edits.

**Files:**
- `.opencode/prompts/default.txt`
- `.opencode/README.md`
- `.opencode/scripts/session_context_triggers.py`
- `.opencode/guidelines/065-verification-honesty.md`
- `.opencode/skills/writing-plans/reference/plan-artifact-format.md`
- `.opencode/skills/writing-plans/reference/implementation-workflow.md` (3 SCs: SC-16, SC-17, SC-18)

**SCs:** SC-11 through SC-18

**Entry Conditions:** Phase 6 committed.

**Exit Conditions:** All 8 individual files updated. No `implementation-pipeline` references remain in any file.

#### Item SC-11 — prompts/default.txt

- [ ] 45. **RED (**sub-agent**).** Write enforcement test: `grep "implementation-pipeline" .opencode/prompts/default.txt` — expect match (test fails because it exists). **→ SC-11**
  - Context: `{issue_number: 2205, sc: SC-11}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-11: grep 'implementation-pipeline' .opencode/prompts/default.txt — expect match. Test must fail initially")`
- [ ] 46. **GREEN (**sub-agent**).** Remove line 205 from `default.txt` that references `implementation-pipeline`. **→ SC-11**
  - Context: `{issue_number: 2205, sc: SC-11, affected_file: ".opencode/prompts/default.txt"}`
  - Dispatch: `task(..., prompt: "edit .opencode/prompts/default.txt: remove the line 'For sub-agent orchestration, load the implementation-pipeline skill.' (line 205)")`
- [ ] 47. **VERIFY (**sub-agent**).** Confirm `grep "implementation-pipeline" .opencode/prompts/default.txt` returns empty. **→ SC-11**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-11: grep 'implementation-pipeline' .opencode/prompts/default.txt — confirm empty result")`
- [ ] 48. **COMMIT (**inline**).** Commit SC-11 changes.
  - Command: `git add .opencode/prompts/default.txt && git commit -m "Phase 7 SC-11: remove implementation-pipeline reference from default.txt"`

#### Item SC-12 — README.md

- [ ] 49. **RED (**sub-agent**).** Write enforcement test: `grep "implementation-pipeline" .opencode/README.md` — expect match (test fails because it exists). **→ SC-12**
  - Context: `{issue_number: 2205, sc: SC-12}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-12: grep 'implementation-pipeline' .opencode/README.md — expect match. Test must fail initially")`
- [ ] 50. **GREEN (**sub-agent**).** Remove `implementation-pipeline` from the Planning skills table in `README.md`. **→ SC-12**
  - Context: `{issue_number: 2205, sc: SC-12, affected_file: ".opencode/README.md"}`
  - Dispatch: `task(..., prompt: "edit .opencode/README.md: remove 'implementation-pipeline' from the Planning skills table (line 101)")`
- [ ] 51. **VERIFY (**sub-agent**).** Confirm `grep "implementation-pipeline" .opencode/README.md` returns empty. **→ SC-12**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-12: grep 'implementation-pipeline' .opencode/README.md — confirm empty result")`
- [ ] 52. **COMMIT (**inline**).** Commit SC-12 changes.
  - Command: `git add .opencode/README.md && git commit -m "Phase 7 SC-12: remove implementation-pipeline from README.md"`

#### Item SC-13 — session_context_triggers.py

- [ ] 53. **RED (**sub-agent**).** Write enforcement test: `grep "implementation-pipeline" .opencode/scripts/session_context_triggers.py` — expect match (test fails because it exists). **→ SC-13**
  - Context: `{issue_number: 2205, sc: SC-13}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-13: grep 'implementation-pipeline' .opencode/scripts/session_context_triggers.py — expect match. Test must fail initially")`
- [ ] 54. **GREEN (**sub-agent**).** Remove `implementation-pipeline` from the error message list in `session_context_triggers.py` line 142. **→ SC-13**
  - Context: `{issue_number: 2205, sc: SC-13, affected_file: ".opencode/scripts/session_context_triggers.py"}`
  - Dispatch: `task(..., prompt: "edit .opencode/scripts/session_context_triggers.py: remove 'implementation-pipeline' from the top-level skills list in the error message (line 142)")`
- [ ] 55. **VERIFY (**sub-agent**).** Confirm `grep "implementation-pipeline" .opencode/scripts/session_context_triggers.py` returns empty. **→ SC-13**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-13: grep 'implementation-pipeline' .opencode/scripts/session_context_triggers.py — confirm empty result")`
- [ ] 56. **COMMIT (**inline**).** Commit SC-13 changes.
  - Command: `git add .opencode/scripts/session_context_triggers.py && git commit -m "Phase 7 SC-13: remove implementation-pipeline from session_context_triggers.py"`

#### Item SC-14 — 065-verification-honesty.md

- [ ] 57. **RED (**sub-agent**).** Write enforcement test: `grep "implementation-pipeline" .opencode/guidelines/065-verification-honesty.md` — expect match (test fails because it exists). **→ SC-14**
  - Context: `{issue_number: 2205, sc: SC-14}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-14: grep 'implementation-pipeline' .opencode/guidelines/065-verification-honesty.md — expect match. Test must fail initially")`
- [ ] 58. **GREEN (**sub-agent**).** Replace `implementation-pipeline/SKILL.md` with `implementation-workflow reference card` in `065-verification-honesty.md` line 413. **→ SC-14**
  - Context: `{issue_number: 2205, sc: SC-14, affected_file: ".opencode/guidelines/065-verification-honesty.md"}`
  - Dispatch: `task(..., prompt: "edit .opencode/guidelines/065-verification-honesty.md: replace 'implementation-pipeline/SKILL.md' with 'implementation-workflow reference card' (line 413)")`
- [ ] 59. **VERIFY (**sub-agent**).** Confirm `grep "implementation-pipeline" .opencode/guidelines/065-verification-honesty.md` returns empty. **→ SC-14**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-14: grep 'implementation-pipeline' .opencode/guidelines/065-verification-honesty.md — confirm empty result")`
- [ ] 60. **COMMIT (**inline**).** Commit SC-14 changes.
  - Command: `git add .opencode/guidelines/065-verification-honesty.md && git commit -m "Phase 7 SC-14: remove implementation-pipeline from 065-verification-honesty.md"`

#### Item SC-15 — plan-artifact-format.md

- [ ] 61. **RED (**sub-agent**).** Write enforcement test: `grep "implementation-pipeline" .opencode/skills/writing-plans/reference/plan-artifact-format.md` — expect match (test fails because it exists). **→ SC-15**
  - Context: `{issue_number: 2205, sc: SC-15}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-15: grep 'implementation-pipeline' .opencode/skills/writing-plans/reference/plan-artifact-format.md — expect match. Test must fail initially")`
- [ ] 62. **GREEN (**sub-agent**).** Remove `implementation-pipeline` from the consumer list in `plan-artifact-format.md` line 7. **→ SC-15**
  - Context: `{issue_number: 2205, sc: SC-15, affected_file: ".opencode/skills/writing-plans/reference/plan-artifact-format.md"}`
  - Dispatch: `task(..., prompt: "edit .opencode/skills/writing-plans/reference/plan-artifact-format.md: remove 'implementation-pipeline' from the plan consumers list (line 7)")`
- [ ] 63. **VERIFY (**sub-agent**).** Confirm `grep "implementation-pipeline" .opencode/skills/writing-plans/reference/plan-artifact-format.md` returns empty. **→ SC-15**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-15: grep 'implementation-pipeline' .opencode/skills/writing-plans/reference/plan-artifact-format.md — confirm empty result")`
- [ ] 64. **COMMIT (**inline**).** Commit SC-15 changes.
  - Command: `git add .opencode/skills/writing-plans/reference/plan-artifact-format.md && git commit -m "Phase 7 SC-15: remove implementation-pipeline from plan-artifact-format.md"`

#### Item SC-16 — implementation-workflow.md (skill() reference)

- [ ] 65. **RED (**sub-agent**).** Write enforcement test: `grep "skill.*implementation-pipeline" .opencode/skills/writing-plans/reference/implementation-workflow.md` — expect match (test fails because it exists). **→ SC-16**
  - Context: `{issue_number: 2205, sc: SC-16}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-16: grep 'skill.*implementation-pipeline' .opencode/skills/writing-plans/reference/implementation-workflow.md — expect match. Test must fail initially")`
- [ ] 66. **GREEN (**sub-agent**).** Replace `skill({name: "implementation-pipeline"})` in `implementation-workflow.md` line 80 with "The orchestrator reads the plan and dispatches each step per the Trigger Dispatch Table below. Dispatch strings are baked into the plan." **→ SC-16**
  - Context: `{issue_number: 2205, sc: SC-16, affected_file: ".opencode/skills/writing-plans/reference/implementation-workflow.md"}`
  - Dispatch: `task(..., prompt: "edit .opencode/skills/writing-plans/reference/implementation-workflow.md: replace 'skill({name: \"implementation-pipeline\"})' with 'The orchestrator reads the plan and dispatches each step per the Trigger Dispatch Table below. Dispatch strings are baked into the plan.' (line 80)")`
- [ ] 67. **VERIFY (**sub-agent**).** Confirm `grep "skill.*implementation-pipeline" .opencode/skills/writing-plans/reference/implementation-workflow.md` returns empty. **→ SC-16**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-16: grep 'skill.*implementation-pipeline' .opencode/skills/writing-plans/reference/implementation-workflow.md — confirm empty result")`
- [ ] 68. **COMMIT (**inline**).** Commit SC-16 changes.
  - Command: `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Phase 7 SC-16: remove skill() reference from implementation-workflow.md"`

#### Item SC-17 — implementation-workflow.md (Trigger Dispatch Table)

- [ ] 69. **RED (**sub-agent**).** Write enforcement test: `grep "## Trigger Dispatch Table" .opencode/skills/writing-plans/reference/implementation-workflow.md` — expect match (test fails because it exists). **→ SC-17**
  - Context: `{issue_number: 2205, sc: SC-17}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-17: grep '## Trigger Dispatch Table' .opencode/skills/writing-plans/reference/implementation-workflow.md — expect match. Test must fail initially")`
- [ ] 70. **GREEN (**sub-agent**).** Remove the Trigger Dispatch Table section from `implementation-workflow.md` (lines 46-77). **→ SC-17**
  - Context: `{issue_number: 2205, sc: SC-17, affected_file: ".opencode/skills/writing-plans/reference/implementation-workflow.md"}`
  - Dispatch: `task(..., prompt: "edit .opencode/skills/writing-plans/reference/implementation-workflow.md: remove the '## Trigger Dispatch Table' section (lines 46-77) and the '## Step Labels' section (lines 74-76)")`
- [ ] 71. **VERIFY (**sub-agent**).** Confirm `grep "## Trigger Dispatch Table" .opencode/skills/writing-plans/reference/implementation-workflow.md` returns empty. **→ SC-17**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-17: grep '## Trigger Dispatch Table' .opencode/skills/writing-plans/reference/implementation-workflow.md — confirm empty result")`
- [ ] 72. **COMMIT (**inline**).** Commit SC-17 changes.
  - Command: `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Phase 7 SC-17: remove Trigger Dispatch Table from implementation-workflow.md"`

#### Item SC-18 — implementation-workflow.md (OVERFLOW section)

- [ ] 73. **RED (**sub-agent**).** Write enforcement test: `grep "implementation-pipeline" .opencode/skills/writing-plans/reference/implementation-workflow.md | grep -v "former\|This is a static"` — expect matches beyond self-description (test fails because they exist). **→ SC-18**
  - Context: `{issue_number: 2205, sc: SC-18}`
  - Dispatch: `task(..., prompt: "write enforcement test for SC-18: grep 'implementation-pipeline' .opencode/skills/writing-plans/reference/implementation-workflow.md | grep -v 'former\|This is a static' — expect matches beyond self-description. Test must fail initially")`
- [ ] 74. **GREEN (**sub-agent**).** Replace "When the implementation-pipeline per the Trigger Dispatch Table receives an OVERFLOW result" with "When the orchestrator receives an OVERFLOW result during plan execution" in `implementation-workflow.md` line 505. **→ SC-18**
  - Context: `{issue_number: 2205, sc: SC-18, affected_file: ".opencode/skills/writing-plans/reference/implementation-workflow.md"}`
  - Dispatch: `task(..., prompt: "edit .opencode/skills/writing-plans/reference/implementation-workflow.md: replace 'When the implementation-pipeline per the Trigger Dispatch Table receives an OVERFLOW result' with 'When the orchestrator receives an OVERFLOW result during plan execution' (line 505)")`
- [ ] 75. **VERIFY (**sub-agent**).** Confirm `grep "implementation-pipeline" .opencode/skills/writing-plans/reference/implementation-workflow.md | grep -v "former\|This is a static"` returns empty. **→ SC-18**
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "verify SC-18: grep 'implementation-pipeline' .opencode/skills/writing-plans/reference/implementation-workflow.md | grep -v 'former\|This is a static' — confirm only self-description lines remain")`
- [ ] 76. **COMMIT (**inline**).** Commit SC-18 changes.
  - Command: `git add .opencode/skills/writing-plans/reference/implementation-workflow.md && git commit -m "Phase 7 SC-18: remove implementation-pipeline OVERFLOW reference from implementation-workflow.md"`

---

## Post-implementation

- [ ] 77. **Post-regression (**sub-agent**).** Re-run the baseline grep for `implementation-pipeline` across `.opencode/`. Compare against baseline — confirm 0 matches.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "run grep for 'implementation-pipeline' across .opencode/ with same patterns as baseline. Compare match count against baseline — confirm 0 matches")`
- [ ] 78. **Audit DiMo (**sub-agent**).** Run DiMo audit on the deliverable.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "execute audit from audit. Read \`audit/tasks/verification-audit.md\` first")`
- [ ] 79. **Z3 check (**inline**).** Inline Z3 check on phase state after AUDIT.
  - Command: `.opencode/tools/solve check --state-path ./tmp/2205/state/ --contract-path .opencode/skills/writing-plans/reference/implementation-workflow.md`
- [ ] 80. **Structural checks (**sub-agent**).** Run lint/typecheck across all modified files.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "execute checklist from finishing-a-development-branch. Read \`finishing-a-development-branch/tasks/checklist.md\` first")`
- [ ] 81. **VbC (**sub-agent**).** Run VbC gate across all SCs. Verify each SC has a PASS verdict with appropriate evidence.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "execute completion from verification-before-completion. Read \`verification-before-completion/tasks/completion.md\` first")`
- [ ] 82. **Pre-PR gate (**sub-agent**).** Verify no SC has FAIL verdict. All SCs must have PASS.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] 83. **Rationalization check (**sub-agent**).** Check for rationalization patterns in implementation.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "execute verify from verification-before-completion. Read \`verification-before-completion/tasks/verify.md\` first")`
- [ ] 84. **Audit (**orchestrator**).** Dispatch audit task for post-implementation verification.
  - Dispatch: `task(subagent_type="general")` with `{spec_local_dir: ".opencode/.issues/2205/", artifact_evidence_dir: ".opencode/.issues/2205/artifacts/"}`
  - If non-clean-pass (FAIL or DONE_WITH_CONCERNS): remediate root cause, restart audit
  - On clean PASS: proceed to regression check
- [ ] 85. **Z3 check (**inline**).** Inline Z3 check on phase state after AUDIT.
  - Command: `.opencode/tools/solve check --state-path ./tmp/2205/state/ --contract-path .opencode/skills/writing-plans/reference/implementation-workflow.md`
- [ ] 86. **Regression check (**sub-agent**).** Run regression tests across all modified areas.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "execute patterns from test-driven-development. Read \`test-driven-development/tasks/patterns.md\` first")`
- [ ] 87. **Exec summary (**sub-agent**).** Report completion summary.
  - Context: `{issue_number: 2205}`
  - Dispatch: `task(..., prompt: "execute completion from completion-core. Read \`completion-core/tasks/completion.md\` first")`

---

## Exit Criteria

- [ ] C1. `executing-plans/` skill directory deleted — `ls .opencode/skills/executing-plans/` returns error
- [ ] C2. No `dispatch-table.yaml` entries reference `implementation-pipeline` — `grep -c "implementation-pipeline" .opencode/dispatch-table.yaml` returns 0
- [ ] C3. No `implementation-pipeline` references in `.md` files outside CHANGELOG.md — `grep -r "implementation-pipeline" .opencode/ --include="*.md" | grep -v CHANGELOG.md | wc -l` returns 0
- [ ] C4. No `implementation-pipeline` references in non-md files — `grep -r "implementation-pipeline" .opencode/ --include="*.yaml" --include="*.py" --include="*.txt" --include="*.sh" | wc -l` returns 0
- [ ] C5. `rationalization-check-remediation.sh` removed — `ls .opencode/tests-v2/behaviors/rationalization-check-remediation.sh` returns error
- [ ] C6. `rationalization-check-pipeline.sh` updated to check reference card — grep for `implementation-workflow.md` in the test file
- [ ] C7. `writing-plans-create.sh` grep patterns updated to `implementation-workflow`
- [ ] C8. `writing-plans-structure.sh` grep patterns updated to `implementation-workflow`
- [ ] C9. `1246-sc3-resolve-models-preflight.sh` prompt updated to real-domain task — no `implementation-pipeline` in prompt text
- [ ] C10. `2009-sc4-plan-fidelity-pipeline.sh` prompt updated to real-domain task — no `implementation-pipeline` in prompt text
- [ ] C11. `prompts/default.txt` no longer references `implementation-pipeline`
- [ ] C12. `README.md` no longer lists `implementation-pipeline`
- [ ] C13. `session_context_triggers.py` no longer references `implementation-pipeline`
- [ ] C14. `065-verification-honesty.md` no longer references `implementation-pipeline`
- [ ] C15. `plan-artifact-format.md` no longer lists `implementation-pipeline` as consumer
- [ ] C16. `implementation-workflow.md` no longer references `skill({name: "implementation-pipeline"})`
- [ ] C17. `implementation-workflow.md` no longer has Trigger Dispatch Table
- [ ] C18. `implementation-workflow.md` no longer references `implementation-pipeline` in OVERFLOW section (only self-description lines remain)

---

## Lifecycle Events

- **2026-07-31T03:45:00Z** — `plan_created` — Plan created at `.opencode/.issues/2205/plan.md` with 7 phases (18 SCs). Daisy-chain structure: common pre-regression, per-item RED/GREEN/VERIFY/COMMIT, common post-regression + audit + Z3.

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
