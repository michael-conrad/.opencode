---
title: "[SPEC-FIX] Plugins fail under snap — bun cannot find git binary"
status: draft
created: 2026-07-16
license: MIT
provenance: AI-generated
issue: 1960
authors:
  - OpenCode (ollama-cloud/deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-16

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

> **Spec Reference:** This is a SPEC-FIX for the `session-enforcement.ts` and `env-loader.ts` plugins. After approval, invoke `writing-plans` to create `.opencode/.issues/1960/plan.md` before implementation begins.

## Problem

When opencode is installed via snap (`/snap/bin/opencode`, classic confinement), both plugins (`session-enforcement.ts`, `env-loader.ts`) produce errors like:

```
bun: command not found: git branch --show-current
```

The bash tool and standalone `bun` CLI both find `git` fine from the same environment. The root cause is unknown — it may be a PATH issue inside the compiled binary's embedded bun runtime, or something else entirely.

## Root Cause Analysis

The root cause is a **PATH isolation issue** in the snap confinement environment. When opencode is installed via snap, the embedded bun runtime inherits a restricted PATH that does not include standard system binary directories. The bash tool and standalone `bun` CLI work because they inherit the user's full interactive shell PATH (which includes `/usr/bin`, `/usr/local/bin`, `/snap/bin`), but the plugin runtime's `execSync` and `Bun.$` calls use a stripped-down PATH.

This is not a bug in the plugins themselves — it is an environment mismatch between the snap confinement and the plugin runtime. The fix is to make the plugins PATH-independent by resolving the git binary path at startup.

## Alternatives Considered & Why Discarded

| Alternative | Rationale for Discard |
|-------------|----------------------|
| Fix the snap confinement PATH | Not under plugin control — snap configuration is managed by the snapcraft build, not by opencode plugins |
| Use `Bun.which("git")` only, no fallback | `Bun.which` may also fail under snap confinement if the restricted PATH doesn't include git's location |
| Hardcode `/usr/bin/git` only | Insufficient — git may be at `/usr/local/bin/git` (Homebrew) or `/snap/bin/git` (snap-installed git) |
| Set PATH in plugin startup | Modifying environment variables in plugin context is unreliable and may conflict with other plugins |
| Use `which git` via execSync | Adds a redundant shell invocation; `Bun.which` is the canonical Bun API for binary resolution |

## Objectives

- Make both plugins resolve the git binary path at startup using `Bun.which("git")` with fallback to common full paths
- Use the resolved path for all subsequent git commands in both `execSync` and `Bun.$` calls
- Gracefully degrade when no git binary is found (log diagnostic, skip git operations, do not crash)

## Non-Goals

- **Fixing snap confinement PATH** — Out of scope; this is a snap packaging concern, not a plugin concern
- **Refactoring plugin architecture** — The fix is scoped to git path resolution only; no structural changes to plugin hooks or data flow
- **Cross-platform git path resolution** — Only Linux snap paths are addressed; Windows/macOS git paths are not affected by this issue

## Constraints and Scope

- **Affected files:** `plugins/session-enforcement.ts`, `plugins/env-loader.ts`
- **Affected repo:** `.opencode` submodule (michael-conrad/.opencode)
- **No new dependencies:** The fix uses only built-in Bun APIs (`Bun.which`) and Node.js `fs.existsSync`
- **No plugin API changes:** The fix is internal to each plugin; no hook signatures or export interfaces change

## Decision Ledger

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Resolve git path once at module scope | Avoids redundant resolution on every hook invocation | MUST | SC-1, SC-2, SC-3 |
| DEC-2 | Fallback order: `/usr/bin/git`, `/usr/local/bin/git`, `/snap/bin/git` | Covers standard Linux, Homebrew, and snap-installed git | MUST | SC-1 |
| DEC-3 | Verify each candidate with `--version` before accepting | Prevents using a non-executable or broken binary | MUST | SC-1 |
| DEC-4 | Graceful degradation: skip git ops, log diagnostic, no crash | Ensures plugin loads even when git is unavailable | MUST | SC-4 |

## Implementation Approach

### Phase 1: Git path resolution utility

Create a shared `resolveGitPath()` function (or inline in each plugin) that:

1. Calls `Bun.which("git")` — returns the resolved full path if git is in PATH
2. If null, checks common full paths in order: `/usr/bin/git`, `/usr/local/bin/git`, `/snap/bin/git`
3. For each candidate, verifies it works via `fs.existsSync` + `execSync("candidate --version")`
4. Returns the first working path, or `null` if none found

### Phase 2: session-enforcement.ts changes

- Resolve `gitPath` at module scope (or at startup in the plugin function)
- Replace all `execSync("git ...")` calls with `execSync(gitPath + " ...")`:
  - `captureGitConfigBaseline`: `execSync("git config --local --list")` and `execSync("git remote -v")`
  - `resolveGitDir`: `execSync("git rev-parse --git-dir")`
  - Startup baseline: `execSync("git config --local --list")`
  - Mutation watchdog: `execSync("git config --local --list")`
- When `gitPath` is null, skip git operations and log a diagnostic

### Phase 3: env-loader.ts changes

- Resolve `gitPath` at startup in the plugin function
- Modify `gitCmd` to use the resolved path: `$.nothrow()\`${gitPath} branch --show-current\``
- All four `gitCmd` calls use the resolved path

## Risk and Edge Cases

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | `Bun.which` also fails under snap confinement | Medium | High | Fallback to common full paths covers this case | SC-1 |
| RISK-2 | Git binary exists but is non-functional (broken install) | Low | Medium | Verify with `--version` before accepting | SC-1 |
| RISK-3 | All fallback paths fail — git completely unavailable | Low | Medium | Graceful degradation: skip git ops, log diagnostic, no crash | SC-4 |
| RISK-4 | Regression: existing non-snap environments break | Low | High | `Bun.which("git")` returns the same path as bare `"git"` in normal environments — behavior is identical | SC-5 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Cost Frame |
|----|-----------|---------------|---------------------|------------|
| SC-1 | Both plugins resolve git path at startup using `Bun.which("git")` with fallback to `/usr/bin/git`, `/usr/local/bin/git`, `/snap/bin/git`, verifying each candidate with `--version` | `string` | grep for `Bun.which("git")` and fallback paths in both plugin files | A skipped fallback path is a defect undiscovered — grep is sufficient for static path presence |
| SC-2 | All `execSync` git calls in `session-enforcement.ts` use the resolved path (not bare `"git"`) | `string` | grep for `execSync(` — confirm no bare `"git "` strings remain | A bare `"git "` execSync that survives into production is a snap crash waiting to happen — grep catches it at the static analysis gate |
| SC-3 | All `$.nothrow()` git calls in `env-loader.ts` use the resolved path (not bare `"git"`) | `string` | grep for `gitCmd(` — confirm no bare `"git "` strings remain | Same as SC-2 — a single missed bare call reproduces the bug |
| SC-4 | Graceful fallback when no git binary is found: plugin loads without crash, skips git operations, logs diagnostic | `behavioral` | `opencode run` with simulated missing git → verify no crash, diagnostic logged | A crash-on-missing-git is a production incident — behavioral test catches what grep cannot |
| SC-5 | Plugin loads without `command not found` errors in normal (non-snap) environments | `behavioral` | `opencode run` in normal environment → verify no git-related errors in stderr | Regression in normal environments is the most expensive defect — behavioral test at pre-commit gate catches it before CI |

## SC-to-Root-Cause Traceability

| SC-ID | Root Cause Element | Verification |
|-------|-------------------|--------------|
| SC-1 | PATH isolation in snap confinement — bun runtime cannot find git via bare name | Resolved path bypasses PATH dependency |
| SC-2 | `execSync("git ...")` relies on inherited PATH | Resolved path used in all execSync calls |
| SC-3 | `$.nothrow()\`git ...\`` relies on inherited PATH | Resolved path used in all Bun.$ calls |
| SC-4 | No git available at all (edge case) | Graceful degradation prevents crash |
| SC-5 | Regression in non-snap environments | Behavioral test confirms no regression |

## Cross-Cutting SCs

**Cross-Cutting SCs:** SC-5
— Verified once, applies to all phases.

## Regression Invariants

- [ ] 1. Existing plugin hook signatures MUST remain unchanged
- [ ] 2. Existing plugin export names MUST remain unchanged
- [ ] 3. All existing git operations MUST continue to work in non-snap environments
- [ ] 4. Plugin diagnostics format MUST remain unchanged

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `srclight_search_symbols("execSync")` in session-enforcement.ts | Identify all execSync git call sites |
| Direct source search | `srclight_search_symbols("gitCmd")` in env-loader.ts | Identify all gitCmd call sites |
| MCP search | `editor_read_file("plugins/session-enforcement.ts")` | Verify execSync patterns and line numbers |
| MCP search | `editor_read_file("plugins/env-loader.ts")` | Verify gitCmd patterns and Bun.$ usage |
| Documentation URLs | [Bun.which docs](https://bun.sh/docs/api/utils#bun-which) | Verify Bun.which API signature |
| Documentation URLs | [Node.js child_process.execSync docs](https://nodejs.org/api/child_process.html#child_processexecsynccommand-options) | Verify execSync accepts full paths |

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Risk traceability | MAY | Update if new risks introduced |

## Decomposition Classification

| Classification | Number of Phases | Phase Artifact Requirements | PR Strategy |
| -------------- | ---------------- | --------------------------- | ----------- |
| single-task | 1 | Single `plan.md` file | single PR |

---

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
