---
plan_schema_version: "1.0"
issue: 2191
title: "Import and adapt gh-cli skill from claude-skill-registry"
dispatch:
  - phase: phase-1
    skill: skill-creator
    task: create
  - phase: phase-2
    skill: skill-creator
    task: create
  - phase: phase-3
    skill: skill-creator
    task: create
  - phase: phase-4
    skill: skill-creator
    task: create
  - phase: phase-5
    skill: skill-creator
    task: update
  - phase: phase-6
    skill: test-driven-development
    task: behavioral-test
---

# Implementation Plan: gh-cli Skill Import

## Pre-Implementation

- [ ] **Coherence gate.** Dispatch `audit --task coherence-maintenance` to verify spec/plan coherence. Context: `{issue_number: 2191, project_root: /home/muksihs/git/opencode-config, issues_prefix: .opencode/.issues}`. (**sub-agent**)
- [ ] **Baseline check.** Verify no existing `gh-cli` skill at `.opencode/skills/gh-cli/`. Verify target paths do not conflict with existing files. (**inline**)

## Phase Table

| Phase | Name | Skill | Task | SCs | Depends On |
|-------|------|-------|------|-----|------------|
| 1 | Create skill directory and SKILL.md | skill-creator | create | SC-1, SC-2, SC-3, SC-13 | — |
| 2 | Core workflow task cards | skill-creator | create | SC-4, SC-5, SC-7, SC-11, SC-12 | Phase 1 |
| 3 | Extended workflow task cards | skill-creator | create | SC-5, SC-7, SC-9, SC-12 | Phase 1 |
| 4 | Common workflows and examples | skill-creator | create | SC-5, SC-10, SC-12 | Phase 1 |
| 5 | Cross-reference integration | skill-creator | update | SC-6 | Phase 2, Phase 3 |
| 6 | Behavioral enforcement tests | test-driven-development | behavioral-test | SC-8 | Phase 1 |

## Phase 1: Create skill directory and SKILL.md

Covers SC-1, SC-2, SC-3, SC-13. Skill: `skill-creator`, task: `create`.

- [ ] **Pre-regression.** Verify no existing `gh-cli` skill directory exists at `.opencode/skills/gh-cli/`. If exists, return BLOCKED. (**inline**)
- [ ] **Pre-regression-verify.** Confirm pre-regression result is clean. (**inline**)
- [ ] **Red.** Write a content-verification test that checks for the expected SKILL.md file structure (frontmatter, routing-only template, agent-intent description). (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-1, SC-2, SC-3, SC-13]}`
- [ ] **Green.** Create `.opencode/skills/gh-cli/` directory. Write `SKILL.md` with:
  - YAML frontmatter: `name: gh-cli`, `description` in agent-intent format, `license: MIT`, `provenance: AI-generated`
  - Overview: 1-2 sentences
  - Mandatory Task Discipline (5 items)
  - Workflows section with dispatch contracts for each workflow
  - Cross-References to `git-workflow`, `issue-operations`, `release-promoter`
  - SPDX + provenance headers and AI co-authored byline
- [ ] **Description remediation.** Remediate the description from user-utterance format to agent-intent format. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-3, SC-13]}`
- [ ] **Post-regression.** Verify SKILL.md exists, frontmatter is valid, description ≤1024 chars (`wc -c`), no prohibited sections (no "Entry Criteria", "Procedure", "Operating Protocol"). (**inline**)
- [ ] **Verify.** Verify against SC-1 (file exists, name matches, description ≤1024 chars), SC-2 (no prohibited sections), SC-3 (agent-intent description format), SC-13 (no user-utterance framing). (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-1, SC-2, SC-3, SC-13]}`
- [ ] **Commit inline.** `git add .opencode/skills/gh-cli/SKILL.md && git commit -m "feat(gh-cli): create SKILL.md with routing-only template"`. (**inline**)
- [ ] **Audit.** Dispatch audit task to verify SKILL.md against spec SCs. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-1, SC-2, SC-3, SC-13]}`
- [ ] **Z3-check.** Run `.opencode/tools/solve check` on phase state. (**inline**)
- [ ] **Structural checks.** Run lint/format on created files. (**sub-agent**)
  - Context: `{issue_number: 2191}`

## Phase 2: Core workflow task cards

Covers SC-4, SC-5, SC-7, SC-11, SC-12. Skill: `skill-creator`, task: `create`.

- [ ] **Pre-regression.** Verify `.opencode/skills/gh-cli/tasks/` directory exists from Phase 1. (**inline**)
- [ ] **Pre-regression-verify.** Confirm pre-regression result is clean. (**inline**)
- [ ] **Red.** Write content-verification tests that check for expected task card structure (6 required sections, auth status entry criteria, merge prohibition, SPDX headers). (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-4, SC-5, SC-7, SC-11, SC-12]}`
- [ ] **Green.** Create 4 core task cards in `.opencode/skills/gh-cli/tasks/`. Each task card follows canonical structure: Purpose, Task Discipline, Entry Criteria, Procedure, Exit Criteria, Result Contract. Include `gh auth status` verification as entry criterion. Include `gh pr merge` prohibition with critical-rules-merge reference. Include SPDX + provenance headers and AI co-authored byline. Task cards:
  - `authenticate.md` — `gh auth status` → `gh auth login` → verify → `gh config set`
  - `create-pr.md` — `gh repo sync` → `gh pr create` → `gh pr view` (NOT merge)
  - `triage-issues.md` — `gh issue list` → `gh issue view` → `gh issue edit` → `gh issue comment` → `gh issue close`
  - `review-pr.md` — `gh pr list` → `gh pr view --diff` → `gh pr checkout` → `gh pr review`
- [ ] **Post-regression.** Verify all 4 task cards exist, each has 6 required sections, auth status in entry criteria, SPDX headers present, `gh pr merge` prohibition present. (**inline**)
- [ ] **Verify.** Verify against SC-4 (exactly 4 core task files: authenticate, create-pr, triage-issues, review-pr), SC-5 (6 required sections per task card), SC-7 (auth status in entry criteria), SC-11 (pr merge prohibition), SC-12 (SPDX + byline headers). (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-4, SC-5, SC-7, SC-11, SC-12]}`
- [ ] **Commit inline.** `git add .opencode/skills/gh-cli/tasks/authenticate.md .opencode/skills/gh-cli/tasks/create-pr.md .opencode/skills/gh-cli/tasks/triage-issues.md .opencode/skills/gh-cli/tasks/review-pr.md && git commit -m "feat(gh-cli): create core workflow task cards"`. (**inline**)
- [ ] **Audit.** Dispatch audit task to verify core task cards against spec SCs. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-4, SC-5, SC-7, SC-11, SC-12]}`
- [ ] **Z3-check.** Run `.opencode/tools/solve check` on phase state. (**inline**)
- [ ] **Structural checks.** Run lint/format on created files. (**sub-agent**)
  - Context: `{issue_number: 2191}`

## Phase 3: Extended workflow task cards

Covers SC-5, SC-7, SC-9, SC-12. Skill: `skill-creator`, task: `create`.

- [ ] **Pre-regression.** Verify `.opencode/skills/gh-cli/tasks/` directory exists. (**inline**)
- [ ] **Pre-regression-verify.** Confirm pre-regression result is clean. (**inline**)
- [ ] **Red.** Write content-verification tests that check for command category coverage across extended task cards. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-5, SC-7, SC-9, SC-12]}`
- [ ] **Green.** Create 12 extended task cards in `.opencode/skills/gh-cli/tasks/`. Each follows canonical structure with auth status entry criteria, SPDX headers, and AI byline. Task cards:
  - `do-release.md` — `git tag` → `gh release create` → `gh release upload` → `gh release view --web`
  - `search-investigate.md` — `gh search repos/issues/prs/code` → `gh browse`
  - `manage-repo.md` — `gh repo create/fork` → `gh label create` → `gh repo edit`
  - `run-ci-cd.md` — `gh run list` → `gh run view` → `gh run rerun` / `gh run watch`
  - `manage-secrets.md` — `gh secret list` → `gh secret set/delete` → `gh variable list/set/delete`
  - `manage-codespaces.md` — `gh codespace list` → `gh codespace create` → `gh codespace ssh/code` → `gh codespace delete`
  - `manage-org.md` — `gh org view` → `gh org list-members` → `gh repo list/create`
  - `manage-gists.md` — `gh gist create` → `gh gist list` → `gh gist view/edit/delete`
  - `manage-keys.md` — `gh ssh-key list` → `gh ssh-key add/delete` → `gh gpg-key list/add/delete`
  - `manage-projects.md` — `gh project list` → `gh project view`
  - `manage-aliases.md` — `gh alias set/list/delete` → `gh extension install/list/remove`
  - `generate-completion.md` — `gh completion -s bash/zsh/fish/powershell`
- [ ] **Post-regression.** Verify all 12 task cards exist, each has 6 required sections, auth status in entry criteria, SPDX headers present. (**inline**)
- [ ] **Verify.** Verify against SC-5 (6 required sections), SC-7 (auth status in entry criteria), SC-9 (20 command categories across all 16 workflow task cards), SC-12 (SPDX + byline headers). (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-5, SC-7, SC-9, SC-12]}`
- [ ] **Commit inline.** `git add .opencode/skills/gh-cli/tasks/do-release.md .opencode/skills/gh-cli/tasks/search-investigate.md .opencode/skills/gh-cli/tasks/manage-repo.md .opencode/skills/gh-cli/tasks/run-ci-cd.md .opencode/skills/gh-cli/tasks/manage-secrets.md .opencode/skills/gh-cli/tasks/manage-codespaces.md .opencode/skills/gh-cli/tasks/manage-org.md .opencode/skills/gh-cli/tasks/manage-gists.md .opencode/skills/gh-cli/tasks/manage-keys.md .opencode/skills/gh-cli/tasks/manage-projects.md .opencode/skills/gh-cli/tasks/manage-aliases.md .opencode/skills/gh-cli/tasks/generate-completion.md && git commit -m "feat(gh-cli): create extended workflow task cards"`. (**inline**)
- [ ] **Audit.** Dispatch audit task to verify extended task cards against spec SCs. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-5, SC-7, SC-9, SC-12]}`
- [ ] **Z3-check.** Run `.opencode/tools/solve check` on phase state. (**inline**)
- [ ] **Structural checks.** Run lint/format on created files. (**sub-agent**)
  - Context: `{issue_number: 2191}`

## Phase 4: Common workflows and examples

Covers SC-5, SC-10, SC-12. Skill: `skill-creator`, task: `create`.

- [ ] **Pre-regression.** Verify `.opencode/skills/gh-cli/tasks/` directory exists. (**inline**)
- [ ] **Pre-regression-verify.** Confirm pre-regression result is clean. (**inline**)
- [ ] **Red.** Write a content-verification test that checks for exactly 3 end-to-end workflow examples. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-5, SC-10, SC-12]}`
- [ ] **Green.** Create `common-workflows.md` in `.opencode/skills/gh-cli/tasks/` with exactly 3 end-to-end workflow examples adapted from the source. Each example follows canonical task card structure with SPDX headers and AI byline. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-5, SC-10, SC-12]}`
- [ ] **Post-regression.** Verify `common-workflows.md` exists, has 6 required sections, has exactly 3 workflow examples, SPDX headers present. (**inline**)
- [ ] **Verify.** Verify against SC-5 (6 required sections), SC-10 (exactly 3 workflow examples), SC-12 (SPDX + byline headers). (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-5, SC-10, SC-12]}`
- [ ] **Commit inline.** `git add .opencode/skills/gh-cli/tasks/common-workflows.md && git commit -m "feat(gh-cli): create common workflows task card"`. (**inline**)
- [ ] **Audit.** Dispatch audit task to verify common-workflows against spec SCs. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-5, SC-10, SC-12]}`
- [ ] **Z3-check.** Run `.opencode/tools/solve check` on phase state. (**inline**)
- [ ] **Structural checks.** Run lint/format on created files. (**sub-agent**)
  - Context: `{issue_number: 2191}`

## Phase 5: Cross-reference integration

Covers SC-6. Skill: `skill-creator`, task: `update`.

- [ ] **Pre-regression.** Verify Phase 2-4 task cards exist. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-6]}`
- [ ] **Pre-regression-verify.** Confirm pre-regression result is clean. (**inline**)
- [ ] **Red.** Write a content-verification test that checks for gh-cli cross-references in git-workflow, issue-operations, and release-promoter SKILL.md files. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-6]}`
- [ ] **Green.** Add `gh-cli` cross-references to:
  - `.opencode/skills/git-workflow/SKILL.md` — PR creation/checkout tasks reference gh-cli for gh-specific operations
  - `.opencode/skills/issue-operations/SKILL.md` — issue management tasks reference gh-cli for gh issue commands
  - `.opencode/skills/release-promoter/SKILL.md` — release tasks reference gh-cli for gh release commands
- [ ] **Post-regression.** Verify cross-references exist in all 3 target files. (**inline**)
- [ ] **Verify.** Verify against SC-6 (no gh command in gh-cli task cards that duplicates git-workflow task card procedures). (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-6]}`
- [ ] **Commit inline.** `git add .opencode/skills/git-workflow/SKILL.md .opencode/skills/issue-operations/SKILL.md .opencode/skills/release-promoter/SKILL.md && git commit -m "feat(gh-cli): add cross-references to related skills"`. (**inline**)
- [ ] **Audit.** Dispatch audit task to verify cross-references against spec SCs. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-6]}`
- [ ] **Z3-check.** Run `.opencode/tools/solve check` on phase state. (**inline**)
- [ ] **Structural checks.** Run lint/format on modified files. (**sub-agent**)
  - Context: `{issue_number: 2191}`

## Phase 6: Behavioral enforcement tests

Covers SC-8. Skill: `test-driven-development`, task: `behavioral-test`.

- [ ] **Pre-regression.** Verify gh-cli skill directory exists. Verify behavioral test infrastructure is available. (**inline**)
- [ ] **Pre-regression-verify.** Confirm pre-regression result is clean. (**inline**)
- [ ] **Red.** Write a behavioral enforcement test that sends a prompt triggering gh CLI intent and verifies the skill appears in available_skills via stderr. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-8]}`
- [ ] **Green.** Create behavioral test script at `.opencode/tests-v2/behaviors/gh-cli-skill.sh` using `with-test-home` wrapper. Test that `gh-cli` entry appears in `<available_skills>` after deployment. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-8]}`
- [ ] **Post-regression.** Verify behavioral test script exists and is executable. (**inline**)
- [ ] **Verify.** Run the behavioral test and confirm PASS. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-8]}`
- [ ] **Commit inline.** `git add .opencode/tests-v2/behaviors/gh-cli-skill.sh && git commit -m "test(gh-cli): add behavioral enforcement test for skill discovery"`. (**inline**)
- [ ] **Audit.** Dispatch audit task to verify behavioral tests against spec SCs. (**sub-agent**)
  - Context: `{issue_number: 2191, scs: [SC-8]}`
- [ ] **Z3-check.** Run `.opencode/tools/solve check` on phase state. (**inline**)
- [ ] **Structural checks.** Run lint/format on created files. (**sub-agent**)
  - Context: `{issue_number: 2191}`

## Exit Criteria

| SC | Criterion | Phase | Verification Method |
|----|----------|-------|-------------------|
| SC-1 | gh-cli SKILL.md exists with valid frontmatter | Phase 1 | `ls` + `wc -c` |
| SC-2 | SKILL.md uses routing-only template (no prohibited sections) | Phase 1 | grep for prohibited patterns |
| SC-3 | Description uses agent-intent format | Phase 1 | grep for prohibited meta-instruction patterns |
| SC-4 | Exactly 4 core task cards exist | Phase 2 | `ls` count |
| SC-5 | Each task card has 6 required sections | Phase 2, 3, 4 | grep for section headers |
| SC-6 | No gh command overlap with git-workflow | Phase 5 | Sub-agent semantic comparison |
| SC-7 | Auth status check in entry criteria | Phase 2, 3 | grep for "auth status" |
| SC-8 | gh-cli appears in available_skills at runtime | Phase 6 | Behavioral test via `opencode run` |
| SC-9 | All 20 command categories covered across 16 task cards | Phase 3 | grep for category names |
| SC-10 | Exactly 3 end-to-end workflow examples | Phase 4 | Section count in common-workflows.md |
| SC-11 | `gh pr merge` prohibition with critical-rules-merge reference | Phase 2 | grep for prohibition |
| SC-12 | SPDX + provenance headers and AI byline in all task cards | Phase 2, 3, 4 | grep for SPDX and byline |
| SC-13 | Description remediated from user-utterance to agent-intent format | Phase 1 | grep for user-utterance framing |

## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-07-30T17:24:00Z | plan_created | 6 phases, skill-creator (phases 1-5), test-driven-development (phase 6), mixed inline/sub-agent dispatch |
