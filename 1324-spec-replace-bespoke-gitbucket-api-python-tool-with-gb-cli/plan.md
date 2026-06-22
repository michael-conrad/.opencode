# Implementation Plan — .opencode#1324

**Spec:** [Replace bespoke gitbucket-api Python tool with gb CLI](https://github.com/michael-conrad/.opencode/issues/1324)
**Authorization:** `for_plan` — halt at `plan_created`
**PR Strategy:** none
**Plan Structure:** separate (7 phases)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Goal

Replace the 955-line bespoke Python `gitbucket-api` tool with the maintained `gb` CLI across all platform task files, dispatcher task files, git-workflow task files, local platform task files, documentation, and test infrastructure. Delete the old Python tooling. Add `TOOL_MISSING` detection. Add behavioral tests against a local GitBucket instance.

## Architecture

The `.opencode/tools/gitbucket-api` wrapper and `.opencode/tools/impl/gitbucket_api.py` implementation are deleted. All GitBucket code paths in `issue-operations/platforms/gitbucket-api/`, `issue-operations/tasks/`, `git-workflow/tasks/`, and `issue-operations/platforms/local/tasks/` are rewritten to call `gb` CLI commands. The `gb` CLI is installed via AGENTS.md procedure. `TOOL_MISSING` detection is added to the gitbucket-api SKILL.md. Behavioral tests verify `gb` commands against a local GitBucket test instance.

## Tech Stack

- `gb` CLI (Masahiro-Obuchi/gitbucket-cli-rs) v0.6.1
- GitBucket latest release `.war` for test instance
- Java JDK 17+ (project-local `.tools/jdk/`)
- `curl` for test instance bootstrap
- Existing bash test infrastructure (`.opencode/tests/`)

## File Structure

| Sub-folder | Responsibility |
|---|---|
| `.opencode/tools/` | Delete `gitbucket-api` wrapper |
| `.opencode/tools/impl/` | Delete `gitbucket_api.py` implementation |
| `issue-operations/platforms/gitbucket-api/tasks/` | Rewrite 6 task files to use `gb` commands |
| `issue-operations/platforms/gitbucket-api/` | Update SKILL.md with capability manifest + TOOL_MISSING |
| `issue-operations/tasks/` | Fix 12 dispatcher task file GitBucket code paths |
| `git-workflow/tasks/` | Fix 4 git-workflow task file GitBucket code paths |
| `git-workflow/tasks/pr-creation/` | Fix create-pr.md GitBucket code path |
| `git-workflow/tasks/provenance/` | Fix platform-detection.md GitBucket code path |
| `git-workflow/tasks/cleanup/` | Fix issue-closure.md — remove raw `gitbucket_api_post()` |
| `issue-operations/platforms/local/tasks/` | Fix push-body.md and pull-body.md GitBucket code paths |
| `.opencode/` | Update AGENTS.md with `gb` install procedure |
| `.opencode/tests/` | Update test infrastructure, add behavioral tests |

---

### Phase 1: Delete bespoke tooling

**Concern:** Removal — delete Python-based gitbucket-api tool files. Entering from zero state (no prior phase). Exiting to Phase 2 where platform task files are rewritten.
**Files:** `.opencode/tools/gitbucket-api`, `.opencode/tools/impl/gitbucket_api.py`
**SCs covered:** SC-1

#### Pre-RED Common

- [ ] 1. Verify files to be deleted exist (**inline**). Confirm `.opencode/tools/gitbucket-api` and `.opencode/tools/impl/gitbucket_api.py` are present. → SC-1
- [ ] 2. Check test infrastructure references to gitbucket-api (**inline**). Grep for `gitbucket-api` in `.opencode/tests/` to identify files needing Phase 7 updates. → SC-1

#### Per-Item RED+green Chains

- [ ] TDD-1-1: Delete `.opencode/tools/gitbucket-api` wrapper script (SC-1)
  - [ ] 1. RED (**clean-room**). Verify the file `.opencode/tools/gitbucket-api` exists as a 51-line wrapper script. → SC-1
  - [ ] 2. GREEN (**clean-room**). Delete the file. Verify `.opencode/tools/gitbucket-api` does not exist. → SC-1
- [ ] TDD-1-2: Delete `.opencode/tools/impl/gitbucket_api.py` implementation (SC-1)
  - [ ] 1. RED (**clean-room**). Verify the file `.opencode/tools/impl/gitbucket_api.py` exists as a 955-line implementation. → SC-1
  - [ ] 2. GREEN (**clean-room**). Delete the file. Verify `.opencode/tools/impl/gitbucket_api.py` does not exist. → SC-1

#### Post-RED/green

- [ ] 1. Verify both files are deleted (**inline**). Structural check: `ls .opencode/tools/gitbucket-api .opencode/tools/impl/gitbucket_api.py` must both return "No such file or directory". → SC-1
- [ ] 2. Verify no remaining references to gitbucket-api in test infrastructure (**inline**). Record findings for Phase 7. → SC-1

---

### Phase 2: Rewrite gitbucket-api platform sub-skill

**Concern:** Platform — rewrite all gitbucket-api platform task files to use `gb` CLI commands. Entering from Phase 1 (bespoke tooling deleted). Exiting to Phase 3 (dispatcher fixes).
**Files:** `issue-operations/platforms/gitbucket-api/tasks/*.md`, `issue-operations/platforms/gitbucket-api/SKILL.md`
**SCs covered:** SC-2, SC-7

#### Pre-RED Common

- [ ] 1. Read current gitbucket-api platform task files to understand command patterns (**inline**). Read all 6 task files and SKILL.md. → SC-2
- [ ] 2. Read `gb` CLI help to map old commands to new `gb` equivalents (**inline**). Run `gb --help`, `gb issue --help`, `gb repo --help`, `gb label --help`, `gb auth --help`, `gb pr --help`. → SC-2
- [ ] 3. Map gitbucket-api subcommands to `gb` equivalents (**inline**). Create mapping table. → SC-2

#### Per-Item RED+green Chains

- [ ] TDD-2-1: Rewrite mcp-operations.md with `gb` command reference (SC-2)
  - [ ] 1. RED (**clean-room**). Verify `mcp-operations.md` references `gitbucket-api` subcommands instead of `gb`. → SC-2
  - [ ] 2. GREEN (**clean-room**). Rewrite to contain only `gb` commands as the canonical command reference. → SC-2
- [ ] TDD-2-2: Rewrite issue-operations.md to use `gb` (SC-2)
  - [ ] 1. RED (**clean-room**). Verify `issue-operations.md` uses `gitbucket-api` subcommands for issue operations. → SC-2
  - [ ] 2. GREEN (**clean-room**). Rewrite to use `gb issue` commands for all issue operations. → SC-2
- [ ] TDD-2-3: Rewrite repository-operations.md to use `gb` (SC-2)
  - [ ] 1. RED (**clean-room**). Verify `repository-operations.md` uses `gitbucket-api` subcommands for repo operations. → SC-2
  - [ ] 2. GREEN (**clean-room**). Rewrite to use `gb repo` commands for all repo operations. → SC-2
- [ ] TDD-2-4: Rewrite label-operations.md to use `gb` (SC-2)
  - [ ] 1. RED (**clean-room**). Verify `label-operations.md` uses `gitbucket-api` subcommands for label operations. → SC-2
  - [ ] 2. GREEN (**clean-room**). Rewrite to use `gb label` commands for all label operations. → SC-2
- [ ] TDD-2-5: Rewrite session-integration.md to use `gb` (SC-2)
  - [ ] 1. RED (**clean-room**). Verify `session-integration.md` uses `gitbucket-api` subcommands for session/auth. → SC-2
  - [ ] 2. GREEN (**clean-room**). Rewrite to use `gb auth` commands for session operations. → SC-2
- [ ] TDD-2-6: Rewrite error-recovery.md to use `gb` (SC-2)
  - [ ] 1. RED (**clean-room**). Verify `error-recovery.md` uses `gitbucket-api` subcommands for error recovery. → SC-2
  - [ ] 2. GREEN (**clean-room**). Rewrite to use `gb` commands for error recovery procedures. → SC-2
- [ ] TDD-2-7: Update SKILL.md capability manifest and add TOOL_MISSING detection (SC-2, SC-7)
  - [ ] 1. RED (**clean-room**). Verify SKILL.md references `gitbucket-api` tool and lacks `TOOL_MISSING` detection. → SC-2, SC-7
  - [ ] 2. GREEN (**clean-room**). Update SKILL.md to reference `gb` CLI and include `TOOL_MISSING` detection that returns `BLOCKED` when `gb` not found. → SC-2, SC-7

#### Post-RED/green

- [ ] 1. Verify no `gitbucket-api` references remain in platform task files (**inline**). `grep -r "gitbucket-api" issue-operations/platforms/gitbucket-api/tasks/` must return 0 matches. → SC-2
- [ ] 2. Verify `TOOL_MISSING` detection is documented in SKILL.md (**inline**). Structural check. → SC-7

---

### Phase 3: Fix dispatcher task files (GitBucket code paths only)

**Concern:** Dispatcher — fix incorrect command names in `issue-operations` dispatcher task files. Entering from Phase 2 (platform commands defined). Exiting to Phase 4 (git-workflow fixes). GitHub MCP code paths untouched.
**Files:** `issue-operations/tasks/*.md`
**SCs covered:** SC-3, SC-10

#### Pre-RED Common

- [ ] 1. Read each dispatcher task file to identify GitBucket code paths with incorrect command names (**inline**). Read all 12 dispatcher task files. → SC-3
- [ ] 2. Map each incorrect command to its `gb` equivalent (**inline**). Create mapping table. → SC-3

#### Per-Item RED+green Chains

- [ ] TDD-3-1: Fix update-issue.md — `update-issue` → `gb issue edit` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `update-issue.md` GitBucket code path calls `update-issue` which does not exist. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace `update-issue` with `gb issue edit` in GitBucket code path. → SC-3
- [ ] TDD-3-2: Fix body-edit.md — `update-issue` → `gb issue edit` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `body-edit.md` GitBucket code path calls `update-issue`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace `update-issue` with `gb issue edit` in GitBucket code path. → SC-3
- [ ] TDD-3-3: Fix list-issues.md — `list-issues` → `gb issue list` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `list-issues.md` GitBucket code path calls `list-issues`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace `list-issues` with `gb issue list` in GitBucket code path. → SC-3
- [ ] TDD-3-4: Fix read-issue.md — `get-issue` → `gb issue view` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `read-issue.md` GitBucket code path calls `get-issue`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace `get-issue` with `gb issue view` in GitBucket code path. → SC-3
- [ ] TDD-3-5: Fix read-sub-issues.md — `get-sub-issues` → "not supported by GitBucket API" note (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `read-sub-issues.md` GitBucket code path calls `get-sub-issues`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace `get-sub-issues` call with "not supported by GitBucket API" note. File stays, GitHub MCP path unchanged. → SC-3
- [ ] TDD-3-6: Fix import-remote.md — `get-issue` → `gb issue view` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `import-remote.md` GitBucket code path calls `get-issue`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace `get-issue` with `gb issue view` in GitBucket code path. → SC-3
- [ ] TDD-3-7: Fix link-sub-issue.md — `get-issue` → `gb issue view` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `link-sub-issue.md` GitBucket code path calls `get-issue`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace `get-issue` with `gb issue view` in GitBucket code path. → SC-3
- [ ] TDD-3-8: Fix close.md — verify uses `gb issue comment` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `close.md` GitBucket code path does not use `gb issue comment`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace with `gb issue comment` in GitBucket code path. → SC-3
- [ ] TDD-3-9: Fix comment.md — verify uses `gb issue comment` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `comment.md` GitBucket code path does not use `gb issue comment`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace with `gb issue comment` in GitBucket code path. → SC-3
- [ ] TDD-3-10: Fix verify-merge.md — verify uses `gb pr list` (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `verify-merge.md` GitBucket code path does not use `gb pr list`. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace with `gb pr list` in GitBucket code path. → SC-3
- [ ] TDD-3-11: Fix creation.md — verify references (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `creation.md` GitBucket code path has incorrect command references. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace with correct `gb` commands in GitBucket code path. → SC-3
- [ ] TDD-3-12: Fix pre-creation.md — verify references (SC-3)
  - [ ] 1. RED (**clean-room**). Verify `pre-creation.md` GitBucket code path has incorrect command references. → SC-3
  - [ ] 2. GREEN (**clean-room**). Replace with correct `gb` commands in GitBucket code path. → SC-3
- [ ] TDD-3-13: Verify no dispatcher task files deleted (SC-10)
  - [ ] 1. RED (**clean-room**). Verify any dispatcher task file has been deleted. → SC-10
  - [ ] 2. GREEN (**clean-room**). Confirm all dispatcher task files still exist with GitHub MCP code paths intact. → SC-10

#### Post-RED/green

- [ ] 1. Verify no incorrect command names remain in dispatcher task files (**inline**). `grep -E "(update-issue|get-issue|list-issues|get-sub-issues|get-pull-request|list-pull-requests|get-repo)" issue-operations/tasks/*.md` must return 0 matches. → SC-3
- [ ] 2. Verify all dispatcher task files exist (**inline**). Structural check against known file list. → SC-10

---

### Phase 4: Fix git-workflow task files

**Concern:** Git-workflow — fix incorrect command names in git-workflow task files. Entering from Phase 3 (dispatchers fixed). Exiting to Phase 5 (local platform fixes).
**Files:** `git-workflow/tasks/check-pr.md`, `git-workflow/tasks/pr-creation/create-pr.md`, `git-workflow/tasks/provenance/platform-detection.md`, `git-workflow/tasks/cleanup/issue-closure.md`
**SCs covered:** SC-4, SC-9

#### Pre-RED Common

- [ ] 1. Read each git-workflow task file to identify GitBucket code paths with incorrect command names (**inline**). Read all 4 task files. → SC-4

#### Per-Item RED+green Chains

- [ ] TDD-4-1: Fix check-pr.md — `list-pull-requests` → `gb pr list`, `get-pull-request` → `gb pr view` (SC-4)
  - [ ] 1. RED (**clean-room**). Verify `check-pr.md` GitBucket code path calls `list-pull-requests` or `get-pull-request`. → SC-4
  - [ ] 2. GREEN (**clean-room**). Replace with `gb pr list` and `gb pr view` in GitBucket code path. → SC-4
- [ ] TDD-4-2: Fix create-pr.md — verify uses `gb pr create` (SC-4)
  - [ ] 1. RED (**clean-room**). Verify `create-pr.md` GitBucket code path does not use `gb pr create`. → SC-4
  - [ ] 2. GREEN (**clean-room**). Replace with `gb pr create` in GitBucket code path. → SC-4
- [ ] TDD-4-3: Fix platform-detection.md — `get-repo` → `gb repo view` (SC-4)
  - [ ] 1. RED (**clean-room**). Verify `platform-detection.md` GitBucket code path calls `get-repo`. → SC-4
  - [ ] 2. GREEN (**clean-room**). Replace `get-repo` with `gb repo view` in GitBucket code path. → SC-4
- [ ] TDD-4-4: Fix issue-closure.md — remove raw `gitbucket_api_post()` Python call (SC-9)
  - [ ] 1. RED (**clean-room**). Verify `issue-closure.md` contains raw `gitbucket_api_post()` Python call. → SC-9
  - [ ] 2. GREEN (**clean-room**). Remove `gitbucket_api_post()` call, replace with `gb` command equivalent. → SC-9

#### Post-RED/green

- [ ] 1. Verify no incorrect command names remain in git-workflow task files (**inline**). `grep -E "(list-pull-requests|get-pull-request|get-repo)" git-workflow/tasks/ -r` must return 0 matches. → SC-4
- [ ] 2. Verify `gitbucket_api_post` returns 0 matches (**inline**). `grep -r "gitbucket_api_post" git-workflow/tasks/` must return 0 matches. → SC-9

---

### Phase 5: Fix local platform sub-skill

**Concern:** Local platform — fix incorrect command names in local platform task files. Entering from Phase 4 (git-workflow fixed). Exiting to Phase 6 (AGENTS.md update).
**Files:** `issue-operations/platforms/local/tasks/push-body.md`, `issue-operations/platforms/local/tasks/pull-body.md`
**SCs covered:** SC-5

#### Pre-RED Common

- [ ] 1. Read local platform task files to identify GitBucket code paths with incorrect command names (**inline**). Read `push-body.md` and `pull-body.md`. → SC-5

#### Per-Item RED+green Chains

- [ ] TDD-5-1: Fix push-body.md — `update-issue` → `gb issue edit` (SC-5)
  - [ ] 1. RED (**clean-room**). Verify `push-body.md` GitBucket code path calls `update-issue`. → SC-5
  - [ ] 2. GREEN (**clean-room**). Replace `update-issue` with `gb issue edit` in GitBucket code path. → SC-5
- [ ] TDD-5-2: Fix pull-body.md — `get-issue` → `gb issue view` (SC-5)
  - [ ] 1. RED (**clean-room**). Verify `pull-body.md` GitBucket code path calls `get-issue`. → SC-5
  - [ ] 2. GREEN (**clean-room**). Replace `get-issue` with `gb issue view` in GitBucket code path. → SC-5

#### Post-RED/green

- [ ] 1. Verify no incorrect command names remain in local platform task files (**inline**). `grep -E "(update-issue|get-issue)" issue-operations/platforms/local/tasks/*.md` must return 0 matches. → SC-5

---

### Phase 6: Update AGENTS.md

**Concern:** Documentation — add `gb` CLI install procedure to AGENTS.md. Entering from Phase 5 (local platform fixed). Exiting to Phase 7 (test infrastructure).
**Files:** `.opencode/AGENTS.md`
**SCs covered:** SC-6

#### Pre-RED Common

- [ ] 1. Read current AGENTS.md to identify where to add install procedure (**inline**). Locate the tools section. → SC-6
- [ ] 2. Determine `gb` CLI download URL and platform detection logic (**inline**). Research `gb` release assets and platform naming. → SC-6

#### Per-Item RED+green Chains

- [ ] TDD-6-1: Add `gb` install procedure to AGENTS.md (SC-6)
  - [ ] 1. RED (**clean-room**). Verify AGENTS.md does not document `gb` CLI install procedure. → SC-6
  - [ ] 2. GREEN (**clean-room**). Add `gb` install procedure including platform detection, download URL, and binary path. → SC-6
- [ ] TDD-6-2: Document `TOOL_MISSING` retry pattern in AGENTS.md (SC-6)
  - [ ] 1. RED (**clean-room**). Verify AGENTS.md does not document `TOOL_MISSING` retry pattern. → SC-6
  - [ ] 2. GREEN (**clean-room**). Add `TOOL_MISSING` retry pattern documentation for `gb`. → SC-6

#### Post-RED/green

- [ ] 1. Verify AGENTS.md contains `gb` install instructions (**inline**). Structural check. → SC-6

---

### Phase 7: Update test infrastructure and behavioral tests

**Concern:** Testing — update test infrastructure references and add behavioral tests for `gb`. Entering from Phase 6 (AGENTS.md updated). Exiting to completion.
**Files:** `.opencode/tests/`
**SCs covered:** SC-8

#### Pre-RED Common

- [ ] 1. Read test infrastructure files to identify `gitbucket-api` references (**inline**). Grep `.opencode/tests/` for `gitbucket-api`. → SC-8
- [ ] 2. Read `gb` CLI help to understand available commands for behavioral testing (**inline**). Run `gb --help` and subcommand help. → SC-8

#### Per-Item RED+green Chains

- [ ] TDD-7-1: Update test-pep723-tools.sh — remove `gitbucket-api` from validation list (SC-8)
  - [ ] 1. RED (**clean-room**). Verify `test-pep723-tools.sh` validates `gitbucket-api` tool. → SC-8
  - [ ] 2. GREEN (**clean-room**). Remove `gitbucket-api` from validation list. → SC-8
- [ ] TDD-7-2: Update any other test infrastructure references (SC-8)
  - [ ] 1. RED (**clean-room**). Verify other test files reference `gitbucket-api` tool. → SC-8
  - [ ] 2. GREEN (**clean-room**). Remove all `gitbucket-api` references from test files. → SC-8
- [ ] TDD-7-3: Add behavioral tests for `gb` CLI commands (SC-8)
  - [ ] 1. RED (**clean-room**). Verify no behavioral tests exist for `gb` CLI commands. → SC-8
  - [ ] 2. GREEN (**clean-room**). Add behavioral tests that verify `gb` can list issues, view issue, create issue, add comment, list PRs, create PR, list labels, list repos, get repo, and check auth against a local GitBucket test instance. → SC-8

#### Post-RED/green

- [ ] 1. Run behavioral tests and verify all `gb` commands exit 0 (**inline**). Execute against local GitBucket test instance. → SC-8
- [ ] 2. Clean up GitBucket test instance (**inline**). Stop GitBucket process, remove `./tmp/gitbucket-test/`. → SC-8

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Exit Criteria

| ID | Criterion |
|----|-----------|
| C1 | Plan header includes Goal, Architecture, Tech Stack |
| C2 | File structure lists all sub-folders with responsibilities |
| C3 | TDD tasks include mandatory Step 2 RED checkpoint |
| C4 | Phase descriptions include concern boundary annotations |
| C5 | Plan stored at `.opencode/.issues/1324-spec-replace-bespoke-gitbucket-api-python-tool-with-gb-cli/plan.md` |
| C6 | No TBD/TODO placeholders remain |
| C7 | Plan artifact created locally in `.opencode/.issues/1324-spec-replace-bespoke-gitbucket-api-python-tool-with-gb-cli/` |
| C8 | Status marker uses prose-driven format |
| C9 | Approval cascade honors `authorization_scope` — `for_plan`, halt at `plan_created` |
