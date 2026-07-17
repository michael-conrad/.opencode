# Implementation Plan — [#1977](https://github.com/michael-conrad/.opencode/issues/1977) — env-loader.ts: remove git commands that run every bash turn

**Goal:** Remove 3 git commands (`branch --show-current`, `remote get-url origin`, `config user.email`) from `env-loader.ts`'s `shell.env` hook, and update the 4 consumer task files to fetch the data on-demand via inline git commands.

**Architecture:** The env-loader plugin currently runs git commands on every `shell.env` invocation (every bash turn). The data is static and already available in LLM context via `session-init`. The change moves git data fetching from the plugin (pre-fetched env vars) to the point of use (on-demand git commands in task files).

**Files:**
- `.opencode/plugins/env-loader.ts` — remove git infrastructure
- `.opencode/skills/completion-core/completion-core.md` — replace env vars with inline git
- `.opencode/skills/completion-core/tasks/completion.md` — replace env vars with inline git
- `.opencode/skills/git-workflow-branch/tasks/pair-pre-work.md` — replace env vars with inline git
- `.opencode/skills/using-git-worktrees/tasks/create-worktree.md` — replace env var with inline git

**Dispatch:** `writing-plans-creation`

## Blast Radius

| File | Impact |
|------|--------|
| `.opencode/plugins/env-loader.ts` | Remove ~80 lines of git infrastructure; keep .env parsing and worktree path logic |
| `.opencode/skills/completion-core/completion-core.md` | URL construction changes from env vars to inline git remote parsing |
| `.opencode/skills/completion-core/tasks/completion.md` | Same URL construction changes |
| `.opencode/skills/git-workflow-branch/tasks/pair-pre-work.md` | Co-authored-by trailer uses inline git config instead of env vars |
| `.opencode/skills/using-git-worktrees/tasks/create-worktree.md` | Branch name resolution uses inline git command |

## Concern Map Reference

| Concern | Phase |
|---------|-------|
| Remove git infrastructure from env-loader.ts | 1 |
| Update completion-core consumers | 2 |
| Update pair-pre-work consumer | 3 |
| Update create-worktree consumer | 4 |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | `env-loader.ts` no longer imports `execSync` | 1 | 1.1, 1.2 |
| SC-2 | `env-loader.ts` no longer contains `gitCmd`, `resolveGitPath`, `GIT_FALLBACK_PATHS`, `GIT_CMD_TIMEOUT_MS` | 1 | 1.1, 1.2 |
| SC-3 | `env-loader.ts` no longer runs any git commands in `shell.env` | 1 | 1.1, 1.2 |
| SC-4 | `completion-core` consumers still produce correct compare URLs | 2 | 2.1, 2.2 |
| SC-5 | `pair-pre-work` still produces `Co-authored-by` with correct name/email | 3 | 3.1 |
| SC-6 | `create-worktree` still resolves correct branch name | 4 | 4.1 |

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1.1 | `.opencode/plugins/env-loader.ts` | ✅ | `read` confirmed file exists |
| 2.1 | `.opencode/skills/completion-core/completion-core.md` | ✅ | `read` confirmed file exists |
| 2.2 | `.opencode/skills/completion-core/tasks/completion.md` | ✅ | `read` confirmed file exists |
| 3.1 | `.opencode/skills/git-workflow-branch/tasks/pair-pre-work.md` | ✅ | `read` confirmed file exists |
| 4.1 | `.opencode/skills/using-git-worktrees/tasks/create-worktree.md` | ✅ | `read` confirmed file exists |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `env-loader.ts` imports `execSync` at line 25 | `read` of file | ✅ |
| `env-loader.ts` has `resolveGitPath()` at lines 35-54 | `read` of file | ✅ |
| `env-loader.ts` has `gitCmd()` at lines 292-308 | `read` of file | ✅ |
| `env-loader.ts` has git try block at lines 310-367 | `read` of file | ✅ |
| `completion-core.md` uses `$GIT_OWNER`, `$GIT_REPO`, `$GITHUB_HTML_URL`, `$GITBUCKET_HTML_URL` at line 43 | `read` of file | ✅ |
| `completion.md` uses same env vars at line 39 | `read` of file | ✅ |
| `pair-pre-work.md` uses `$DEV_NAME`, `$DEV_EMAIL` at line 28 | `read` of file | ✅ |
| `create-worktree.md` uses `$BRANCH_NAME` at lines 39-46, 138-139 | `read` of file | ✅ |

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|--------------|------------|----------|
| 1 | Remove git infrastructure from env-loader.ts | Remove git commands, constants, and functions from the plugin | SC-1, SC-2, SC-3 | None | 1-4 | `writing-plans-creation` |
| 2 | Update completion-core consumers | Replace env vars with inline git remote parsing in both completion-core files | SC-4 | Phase 1 | 5-8 | `writing-plans-creation` |
| 3 | Update pair-pre-work consumer | Replace `$DEV_NAME`/`$DEV_EMAIL` with inline `git config` | SC-5 | Phase 1 | 9-10 | `writing-plans-creation` |
| 4 | Update create-worktree consumer | Replace `$BRANCH_NAME` env var with inline `git branch --show-current` | SC-6 | Phase 1 | 11-12 | `writing-plans-creation` |

> **⚠️ COMPLIANCE REQUIREMENT:** This plan MUST be executed one step at a time. Each step MUST complete (PASS) before the next step begins. No parallel execution of steps within a phase. No skipping steps. No reordering steps. Every step is mandatory.

> **⚠️ ONE STEP AT A TIME:** Execute exactly one step per assistant turn. After each step, report PASS or FAIL. On FAIL, remediate before proceeding. Do not batch steps. Do not skip ahead. Do not assume next step's outcome.

> **⚠️ STEP STATUS:** Each step MUST be reported as PASS or FAIL after execution. On PASS, proceed to the next step. On FAIL, remediate the failure and re-run the step before proceeding. Do not proceed past a FAIL without remediation.

### Phase 1 — Remove git infrastructure from env-loader.ts

**Concern:** Remove all git-related code from `env-loader.ts` — the `execSync` import, `GIT_FALLBACK_PATHS`, `resolveGitPath()`, `GIT_CMD_TIMEOUT_MS`, `gitCmd()`, the entire git try block, and the URL parsing functions that are only used by git commands.

**Files:** `.opencode/plugins/env-loader.ts`

**SCs:** SC-1, SC-2, SC-3

**Dependencies:** None

**Entry conditions:** Spec approved, feature branch created

**Exit conditions:** `env-loader.ts` compiles with `tsc --noEmit`, no git-related code remains

- [ ] 1. **Remove `execSync` import (**inline**).** Replace `import { execSync } from "child_process";` with removal of the import line entirely. **→ SC-1**
- [ ] 2. **Remove git constants and functions (**inline**).** Remove `GIT_FALLBACK_PATHS` (lines 29-33), `resolveGitPath()` (lines 35-54), `GIT_CMD_TIMEOUT_MS` (line 289), `gitCmd()` (lines 292-308), and the entire git try block (lines 310-367). **→ SC-2, SC-3**
- [ ] 3. **Remove URL parsing functions only used by git commands (**inline**).** Remove `parseGitHubUrl()` (lines 159-171), `parseGitBucketUrl()` (lines 173-220), and `readGitBucketUrlFromEnv()` (lines 222-242) — these are only called from the removed git try block. **→ SC-2**
- [ ] 4. **Update header comment and verify compilation (**inline**).** Update the header comment to remove references to git input sources. Run `PATH=.tools/node/bin:$PATH npx tsc --noEmit` to verify compilation. **→ SC-1, SC-2, SC-3**

**Phase 1 — Safety/Rollback:**
- Destructive operations: File edits to `env-loader.ts`
- Rollback plan: `git checkout .opencode/plugins/env-loader.ts` restores original
- Data loss risk: None — git data is still available via session-init in LLM context

### Phase 2 — Update completion-core consumers

**Concern:** Replace `$GIT_OWNER`, `$GIT_REPO`, `$GITHUB_HTML_URL`, `$GITBUCKET_HTML_URL` env vars in both `completion-core.md` and `completion.md` with inline `git remote get-url origin` parsing.

**Files:**
- `.opencode/skills/completion-core/completion-core.md`
- `.opencode/skills/completion-core/tasks/completion.md`

**SCs:** SC-4

**Dependencies:** Phase 1 complete (env-loader no longer provides these env vars)

**Entry conditions:** Phase 1 verified PASS

**Exit conditions:** Both files use inline git remote parsing, compare URL construction verified

- [ ] 5. **Update `completion-core.md` URL construction (**inline**).** Replace the `COMPARE_URL` line (line 43) and the character-match verification step (lines 35-40) with inline `git remote get-url origin` parsing that extracts owner/repo directly. **→ SC-4**
- [ ] 6. **Update `completion.md` URL construction (**inline**).** Apply the same changes as step 5 to `completion.md` (lines 31-39). **→ SC-4**
- [ ] 7. **Verify `DEFAULT_BRANCH` resolution is present (**inline**).** Confirm both files have the `DEFAULT_BRANCH` resolution block (from `completion-core.md` lines 5-8) before the URL construction. **→ SC-4**
- [ ] 8. **VbC — verify compare URL correctness (**clean-room**).** Dispatch a clean-room sub-agent to verify that the updated URL construction produces correct compare URLs matching the pattern `<html_url>/<owner>/<repo>/compare/$DEFAULT_BRANCH...<branch>`. **→ SC-4**

**Phase 2 — Safety/Rollback:**
- Destructive operations: File edits to completion-core files
- Rollback plan: `git checkout` on each modified file
- Data loss risk: None

### Phase 3 — Update pair-pre-work consumer

**Concern:** Replace `$DEV_NAME` and `$DEV_EMAIL` env vars in `pair-pre-work.md` with inline `git config user.name` / `git config user.email` commands.

**Files:** `.opencode/skills/git-workflow-branch/tasks/pair-pre-work.md`

**SCs:** SC-5

**Dependencies:** Phase 1 complete

**Entry conditions:** Phase 1 verified PASS

**Exit conditions:** WIP commit `Co-authored-by` trailer uses inline git config values

- [ ] 9. **Update `pair-pre-work.md` Co-authored-by line (**inline**).** Replace `$DEV_NAME <$DEV_EMAIL>` on line 28 with inline `$(git config user.name) <$(git config user.email)>`. **→ SC-5**
- [ ] 10. **VbC — verify Co-authored-by correctness (**clean-room**).** Dispatch a clean-room sub-agent to verify the updated command produces a valid `Co-authored-by` trailer with the correct name and email. **→ SC-5**

**Phase 3 — Safety/Rollback:**
- Destructive operations: File edit to pair-pre-work.md
- Rollback plan: `git checkout` on the modified file
- Data loss risk: None

### Phase 4 — Update create-worktree consumer

**Concern:** Replace `$BRANCH_NAME` env var references in `create-worktree.md` with inline `git branch --show-current` where the env var was previously consumed.

**Files:** `.opencode/skills/using-git-worktrees/tasks/create-worktree.md`

**SCs:** SC-6

**Dependencies:** Phase 1 complete

**Entry conditions:** Phase 1 verified PASS

**Exit conditions:** Worktree path resolution uses inline git branch command

- [ ] 11. **Update `create-worktree.md` branch name resolution (**inline**).** In the worktree collision check (lines 39-46) and the export block (lines 137-141), ensure `BRANCH_NAME` is resolved via `git branch --show-current` rather than relying on the env var. The local `BRANCH_NAME` assignment at line 71 is already explicit — the change is in the collision check and export sections where the env var was the implicit source. **→ SC-6**
- [ ] 12. **VbC — verify branch name resolution (**clean-room**).** Dispatch a clean-room sub-agent to verify that the worktree path contains the correct branch name after the update. **→ SC-6**

**Phase 4 — Safety/Rollback:**
- Destructive operations: File edit to create-worktree.md
- Rollback plan: `git checkout` on the modified file
- Data loss risk: None

---

> **⚠️ COMPLIANCE REQUIREMENT:** This plan MUST be executed one step at a time. Each step MUST complete (PASS) before the next step begins. No parallel execution of steps within a phase. No skipping steps. No reordering steps. Every step is mandatory.

> **⚠️ SELF-REMEDIATION PROTOCOL:** If any step fails, the agent MUST self-remediate: diagnose the failure, fix the root cause, and re-run the step. Only after 2+ remediation attempts may the agent escalate. Escalation is the last resort, not the first response.

## Exit Criteria

- [ ] C1. `env-loader.ts` no longer imports `execSync` (SC-1)
- [ ] C2. `env-loader.ts` no longer contains `gitCmd`, `resolveGitPath`, `GIT_FALLBACK_PATHS`, or `GIT_CMD_TIMEOUT_MS` (SC-2)
- [ ] C3. `env-loader.ts` no longer runs any git commands in `shell.env` (SC-3)
- [ ] C4. `completion-core` consumers produce correct compare URLs (SC-4)
- [ ] C5. `pair-pre-work` produces `Co-authored-by` with correct name/email (SC-5)
- [ ] C6. `create-worktree` resolves correct branch name (SC-6)
- [ ] C7. All modified files pass `tsc --noEmit` (TypeScript compilation)
- [ ] C8. All changes committed to feature branch
