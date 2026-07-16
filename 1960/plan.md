# Implementation Plan — [#1960](https://github.com/michael-conrad/.opencode/issues/1960) — Plugins fail under snap: resolve git binary path at startup

- **Goal:** Make `session-enforcement.ts` and `env-loader.ts` resolve the git binary path at startup using `Bun.which("git")` with fallback to common full paths, so that git commands work under snap confinement where the embedded bun runtime has a restricted PATH.
- **Architecture:** Single-phase, single-file change. Both plugins independently resolve `gitPath` at module/startup scope using a shared resolution pattern (not a shared utility — each plugin is self-contained). All `execSync("git ...")` and `$.nothrow()` git calls use the resolved path. Graceful degradation when no git binary is found.
- **Files:** `plugins/session-enforcement.ts`, `plugins/env-loader.ts`
- **Dispatch:** `implementation-pipeline` → `git-workflow` → `verification-before-completion` → `finishing-a-development-branch` → `git-workflow-pr`

## Blast Radius

- **Affected files:** `plugins/session-enforcement.ts`, `plugins/env-loader.ts`
- **Impact zones:** Git command execution in both plugins — all `execSync` and `Bun.$` calls that invoke git. No plugin API changes (hook signatures, export names unchanged). No other plugins or files affected.

## Concern Map

| Concern | Phase | Description |
|---------|-------|-------------|
| Git path resolution | 1 | Resolve git binary path at startup in both plugins |
| execSync migration | 1 | Replace bare `"git"` with resolved path in session-enforcement.ts |
| Bun.$ migration | 1 | Replace bare `"git"` with resolved path in env-loader.ts |
| Graceful degradation | 1 | Handle null gitPath: skip git ops, log diagnostic, no crash |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **One-step-at-a-time protocol:** Execute exactly one step at a time. After each step, verify the result before proceeding. Do not batch steps. Do not skip verification. Each step's output is the next step's input.

> **Step Status:** Each step MUST be marked with its status: `[ ]` = not started, `[~]` = in progress, `[x]` = completed, `[!]` = blocked. Update the status immediately before and after each step.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|--------------|------------|----------|
| 1 | Git path resolution and migration | All concerns | SC-1, SC-2, SC-3, SC-4, SC-5 | None | 1-10 | `implementation-pipeline` |

## SC-to-Step Traceability

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Both plugins resolve git path at startup using `Bun.which("git")` with fallback to `/usr/bin/git`, `/usr/local/bin/git`, `/snap/bin/git`, verifying each candidate with `--version` | 1 | 1, 2, 3, 4 |
| SC-2 | All `execSync` git calls in `session-enforcement.ts` use the resolved path (not bare `"git"`) | 1 | 5, 6 |
| SC-3 | All `$.nothrow()` git calls in `env-loader.ts` use the resolved path (not bare `"git"`) | 1 | 7, 8 |
| SC-4 | Graceful fallback when no git binary is found: plugin loads without crash, skips git operations, logs diagnostic | 1 | 9 |
| SC-5 | Plugin loads without `command not found` errors in normal (non-snap) environments | 1 | 10 |

## Safety/Rollback

**Phase 1 — Safety/Rollback:**
- Destructive operations: None — all changes are additive (adding path resolution logic) or replacement (replacing bare `"git"` with resolved path variable). No files are deleted. No data is mutated.
- Rollback plan: `git checkout -- plugins/session-enforcement.ts plugins/env-loader.ts` restores original state.
- Data loss risk: None

## Feasibility Verification

| Step | Reference | Verified? | Evidence |
|------|-----------|-----------|----------|
| 1 | `plugins/session-enforcement.ts` `execSync` | ✅ | grep found 5 `execSync("git` call sites |
| 2 | `plugins/env-loader.ts` `gitCmd` | ✅ | grep found 5 `gitCmd` references, 4 call sites |
| 3 | `Bun.which` API | ✅ | Bun docs: `Bun.which("git")` returns full path or null |
| 4 | `fs.existsSync` | ✅ | Already imported in both plugins |
| 5 | `execSync` with full path | ✅ | Node.js docs: `execSync` accepts full path strings |

## Evidence/Provenance

| Claim | Evidence Source | Verified? |
|-------|----------------|----------|
| `session-enforcement.ts` has 5 `execSync("git` calls | grep on plugins/session-enforcement.ts | ✅ |
| `env-loader.ts` has 4 `gitCmd` call sites | grep on plugins/env-loader.ts | ✅ |
| `env-loader.ts` uses `$.nothrow()` for git commands | grep on plugins/env-loader.ts line 266 | ✅ |
| `Bun.which` returns full path or null | Bun.sh docs | ✅ |
| `fs.existsSync` already imported in both plugins | Read of import lines | ✅ |

## Step-by-Step

- [ ] 1. **Pre-flight: verify spec approval** — Check `approved-for-*` label on issue #1960 via `github_issue_read(method=get_labels, issue_number=1960)`. Chain: none. Expected: label present.
- [ ] 2. **Research: identify all git call sites** — Read both plugin files, confirm all `execSync("git` and `gitCmd("git` call sites. Chain: step 1. Expected: complete list of call sites.
- [ ] 3. **Implement git path resolution in session-enforcement.ts** — Add `resolveGitPath()` function at module scope that: (a) calls `Bun.which("git")`, (b) if null, checks `/usr/bin/git`, `/usr/local/bin/git`, `/snap/bin/git` via `fs.existsSync` + `execSync("candidate --version")`, (c) returns first working path or null. Chain: step 2. Expected: function added, all 5 `execSync("git` calls use `gitPath` variable.
- [ ] 4. **Implement git path resolution in env-loader.ts** — Add `resolveGitPath()` function at startup scope with same resolution pattern. Chain: step 3. Expected: function added, all 4 `gitCmd` calls use resolved path.
- [ ] 5. **Replace bare git calls in session-enforcement.ts** — Replace all 5 `execSync("git ...")` with `execSync(gitPath + " ...")`. Add null-guard: when `gitPath` is null, skip git operations and log diagnostic. Chain: step 4. Expected: no bare `"git "` strings remain in execSync calls.
- [ ] 6. **Replace bare git calls in env-loader.ts** — Modify `gitCmd` to use resolved path: `$.nothrow()\`${gitPath} ...\``. Add null-guard: when `gitPath` is null, return null from `gitCmd` and log diagnostic. Chain: step 5. Expected: no bare `"git "` strings remain in gitCmd calls.
- [ ] 7. **SC-1 verification (string)** — grep both plugin files for `Bun.which("git")` and all three fallback paths. Chain: step 6. Expected: all paths present in both files.
- [ ] 8. **SC-2 verification (string)** — grep `session-enforcement.ts` for `execSync(` — confirm no bare `"git "` strings remain. Chain: step 7. Expected: zero bare `"git "` execSync calls.
- [ ] 9. **SC-3 verification (string)** — grep `env-loader.ts` for `gitCmd(` — confirm no bare `"git "` strings remain. Chain: step 8. Expected: zero bare `"git "` gitCmd calls.
- [ ] 10. **SC-4 and SC-5 behavioral verification** — Run `opencode run` with simulated missing git (SC-4) and in normal environment (SC-5). Chain: step 9. Expected: no crash with missing git, no git-related errors in normal environment.

## Exit Criteria

- [ ] C1: Plan index written to `.opencode/.issues/1960/plan.md`
- [ ] C2: All 5 SCs have corresponding verification steps
- [ ] C3: SC-1 verified by grep for `Bun.which("git")` and fallback paths
- [ ] C4: SC-2 verified by grep for no bare `"git "` in execSync calls
- [ ] C5: SC-3 verified by grep for no bare `"git "` in gitCmd calls
- [ ] C6: SC-4 verified by behavioral test (simulated missing git)
- [ ] C7: SC-5 verified by behavioral test (normal environment)
- [ ] C8: Plan approved via cascade (authorization_scope: for_pr → auto-approved)

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Self-remediation protocol:** If any step fails, the agent MUST self-remediate before proceeding. Do not skip the failed step. Do not ask the developer for guidance unless remediation has been exhausted. After remediation, re-verify the step before proceeding to the next step.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
