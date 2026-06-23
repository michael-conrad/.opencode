# [PLAN] Replace bespoke gitbucket-api Python tool with gb CLI

**Spec:** [michael-conrad/.opencode#1324](https://github.com/michael-conrad/.opencode/issues/1324)
**Authorization scope:** `for_pr` (auto-approves plan)
**PR strategy:** stacked
**Total phases:** 7

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Dependency Ordering

```
Phase 1 (delete) → Phase 2 (rewrite platform) → Phase 3 (fix dispatchers) → Phase 4 (fix git-workflow) → Phase 5 (fix local platform) → Phase 6 (AGENTS.md) → Phase 7 (test infra)
```

Phases 3, 4, 5 are independent of each other (all depend only on Phase 2). Phase 6 and 7 depend on all preceding phases.

---

### Phase 1: Delete bespoke tooling

**Concern:** Remove the old Python tool files. No new code — pure deletion.
**Files:** `.opencode/tools/gitbucket-api`, `.opencode/tools/impl/gitbucket_api.py`
**SCs covered:** SC-1

- [ ] 1. Pre-RED: Verify both files exist before deletion (**inline**). `test -f` for each file → SC-1
- [ ] 2. RED: Both files still exist — deletion has not occurred (**inline**). Confirm files are present → SC-1
- [ ] 3. GREEN: Delete both files (**clean-room**). `rm` each file; verify `test ! -f` for each → SC-1
- [ ] 4. Post-RED: Verify no remaining references to deleted files in other tool files (**clean-room**). grep for `gitbucket-api` in `.opencode/tools/` (excluding deleted files) → SC-1

---

### Phase 2: Rewrite gitbucket-api platform sub-skill

**Concern:** Replace all `gitbucket-api` CLI commands with `gb` equivalents in the platform sub-skill. Add TOOL_MISSING detection and version check.
**Files:** `issue-operations/platforms/gitbucket-api/tasks/*.md`, `issue-operations/platforms/gitbucket-api/SKILL.md`
**SCs covered:** SC-2, SC-7, SC-11

- [ ] 1. Pre-RED: Read all 6 task files + SKILL.md to discover current command references (**clean-room**). Glob `tasks/*.md` and read each → SC-2
- [ ] 2. RED: Task files still reference `gitbucket-api` commands — grep returns matches (**inline**). grep for `gitbucket-api` in platform task files → SC-2
- [ ] 3. GREEN: Rewrite all task files to use `gb` commands (**clean-room**). Replace each command with `gb` equivalent per `gb` CLI README; add `TOOL_MISSING` detection that returns BLOCKED when `gb` not found → SC-2, SC-7
- [ ] 4. GREEN: Add version check — verify `gb --version` >= 0.6.1 before proceeding (**clean-room**). Add version assertion to skill entry criteria → SC-11
- [ ] 5. GREEN: Update SKILL.md capability manifest (**clean-room**). List all supported `gb` commands and their mappings → SC-2
- [ ] 6. Post-RED: grep for `gitbucket-api` in platform task files returns 0 matches (**inline**). Verify all old command references removed → SC-2

---

### Phase 3: Fix dispatcher task files (GitBucket code paths only)

**Concern:** Replace incorrect command names in dispatcher task files. Preserve all GitHub MCP code paths untouched.
**Files:** `issue-operations/tasks/update-issue.md`, `body-edit.md`, `list-issues.md`, `read-issue.md`, `read-sub-issues.md`, `import-remote.md`, `link-sub-issue.md`, `close.md`, `comment.md`, `verify-merge.md`, `creation.md`, `pre-creation.md`
**SCs covered:** SC-3, SC-9

- [ ] 1. Pre-RED: Read all dispatcher task files to discover GitBucket code paths (**clean-room**). Glob `issue-operations/tasks/*.md` and read each → SC-3
- [ ] 2. RED: Dispatcher files still reference incorrect command names — grep returns matches (**inline**). grep for `update-issue`, `get-issue`, `list-issues`, `get-sub-issues`, `get-pull-request`, `list-pull-requests`, `get-repo` → SC-3
- [ ] 3. GREEN: Replace each incorrect command name with correct `gb` equivalent (**clean-room**). `update-issue` → `gb issue edit`, `get-issue` → `gb issue view`, `list-issues` → `gb issue list`, `get-sub-issues` → "not supported" note, `get-pull-request` → `gb pr view`, `list-pull-requests` → `gb pr list`, `get-repo` → `gb repo view` → SC-3
- [ ] 4. GREEN: Remove raw `gitbucket_api_post()` call from `issue-closure.md` (**clean-room**). Replace with `gb issue comment` → SC-9
- [ ] 5. Post-RED: grep for each incorrect command name returns 0 matches (**inline**). Verify all replacements correct → SC-3
- [ ] 6. Post-RED: grep for `gitbucket_api_post` returns 0 matches (**inline**). Verify raw Python call removed → SC-9

---

### Phase 4: Fix git-workflow task files

**Concern:** Replace incorrect command names in git-workflow task files. Preserve all non-GitBucket code paths.
**Files:** `git-workflow/tasks/check-pr.md`, `pr-creation/create-pr.md`, `provenance/platform-detection.md`, `cleanup/issue-closure.md`
**SCs covered:** SC-4

- [ ] 1. Pre-RED: Read all git-workflow task files to discover GitBucket code paths (**clean-room**). Glob `git-workflow/tasks/*.md` and read each → SC-4
- [ ] 2. RED: Git-workflow files still reference incorrect command names — grep returns matches (**inline**). grep for `list-pull-requests`, `get-pull-request`, `get-repo` → SC-4
- [ ] 3. GREEN: Replace each incorrect command name with correct `gb` equivalent (**clean-room**). `list-pull-requests` → `gb pr list`, `get-pull-request` → `gb pr view`, `get-repo` → `gb repo view` → SC-4
- [ ] 4. Post-RED: grep for each incorrect command name returns 0 matches (**inline**). Verify all replacements correct → SC-4

---

### Phase 5: Fix local platform sub-skill

**Concern:** Replace incorrect command names in local platform task files.
**Files:** `issue-operations/platforms/local/tasks/push-body.md`, `pull-body.md`
**SCs covered:** SC-5

- [ ] 1. Pre-RED: Read both local platform task files (**clean-room**). Read `push-body.md` and `pull-body.md` → SC-5
- [ ] 2. RED: Local platform files still reference incorrect command names — grep returns matches (**inline**). grep for `update-issue`, `get-issue` → SC-5
- [ ] 3. GREEN: Replace each incorrect command name with correct `gb` equivalent (**clean-room**). `update-issue` → `gb issue edit`, `get-issue` → `gb issue view` → SC-5
- [ ] 4. Post-RED: grep for each incorrect command name returns 0 matches (**inline**). Verify all replacements correct → SC-5

---

### Phase 6: Update AGENTS.md

**Concern:** Document `gb` install procedure, TOOL_MISSING retry pattern, env vars, and version pinning.
**Files:** `AGENTS.md`
**SCs covered:** SC-6

- [ ] 1. Pre-RED: Read current AGENTS.md to find tool install section (**clean-room**). Read AGENTS.md → SC-6
- [ ] 2. RED: AGENTS.md does not contain `gb` install instructions — grep returns no matches (**inline**). grep for `gb` install patterns → SC-6
- [ ] 3. GREEN: Add `gb` install procedure for all 4 platforms (**clean-room**). Linux x86_64, macOS x86_64, macOS arm64, Windows x86_64 with download URLs and install commands → SC-6
- [ ] 4. GREEN: Document TOOL_MISSING retry pattern, GB_USER/GB_PASSWORD env vars, version pinning to v0.6.1 (**clean-room**). Add to AGENTS.md → SC-6
- [ ] 5. Post-RED: grep for platform-specific install instructions for all 4 platforms (**inline**). Verify all 4 platforms documented → SC-6

---

### Phase 7: Update test infrastructure

**Concern:** Remove `gitbucket-api` from test validation lists.
**Files:** `tests/test-pep723-tools.sh`
**SCs covered:** SC-10

- [ ] 1. Pre-RED: Read test file to find `gitbucket-api` references (**clean-room**). Read `test-pep723-tools.sh` → SC-10
- [ ] 2. RED: Test file still references `gitbucket-api` — grep returns matches (**inline**). grep for `gitbucket-api` in test files → SC-10
- [ ] 3. GREEN: Remove `gitbucket-api` from validation list (**clean-room**). Edit test file to remove reference → SC-10
- [ ] 4. Post-RED: grep for `gitbucket-api` in test files returns 0 matches (**inline**). Verify all test references removed → SC-10

---

## Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST (**clean-room**). git status clean, lint/typecheck from scratch, coverage sweep
- [ ] PR CREATION (**clean-room**). Via `github_create_pull_request`, extract `html_url` from response
- [ ] POST-MERGE CLEANUP (**clean-room**). Delete merged branches, close issues, sync dev

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## SC-to-Phase Mapping

| SC | Phase(s) | Description |
|----|----------|-------------|
| SC-1 | Phase 1 | Delete bespoke tooling files |
| SC-2 | Phase 2 | Platform task files use `gb` commands |
| SC-3 | Phase 3 | Dispatcher task files use correct `gb` command names |
| SC-4 | Phase 4 | Git-workflow task files use correct `gb` commands |
| SC-5 | Phase 5 | Local platform task files use correct `gb` commands |
| SC-6 | Phase 6 | AGENTS.md documents `gb` install procedure |
| SC-7 | Phase 2 | TOOL_MISSING detection returns BLOCKED |
| SC-8 | Post-all-phases | Live `gb` command execution against test instance |
| SC-8.1 | Post-all-phases | Local GitBucket test instance running before SC-8 |
| SC-9 | Phase 3 | `issue-closure.md` no longer uses raw `gitbucket_api_post()` |
| SC-10 | Phase 7 | No dispatcher task files deleted |
| SC-11 | Phase 2 | Agent verifies `gb` version >= 0.6.1 |
