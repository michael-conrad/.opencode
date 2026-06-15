# [SPEC-FIX] pre-push Gate 0 must allow .wiki submodule pushes to master

## Intent and Executive Summary

| Field | Description |
|-------|-------------|
| Problem Statement | The pre-push hook Gate 0 blocks all pushes to `main|master|dev`, including legitimate pushes from GitHub wiki submodules (`.wiki.git` repos) that have no PR workflow available |
| Root Cause / Motivation | Gate 0 inspects only `$REMOTE_BRANCH` — it never checks whether the push's remote URL indicates a wiki repo. Wiki repos (`/pulls` returns 404) require direct push to `master` |
| Approach Chosen | Add `.wiki.git` substring detection on the remote URL passed to the pre-push hook; skip Gate 0 for wiki remote URLs only |
| Alternatives Considered & Why Discarded | (1) Broad submodule exemption — rejected because non-wiki submodules should follow branch protection. (2) Allowlisting specific remotes — rejected as fragile to remote URL changes |
| Key Design Decisions | Narrow `.wiki.git` pattern match only; all other remote URLs remain subject to Gate 0 |

## Objective

Modify Gate 0 in `.opencode/hooks/pre-push` to permit pushes to `main|master|dev` when the target remote is a GitHub wiki repository (URL contains `.wiki.git`). All other pushes to these branches — from the main repo or non-wiki submodules — MUST remain blocked.

## Problem

The pre-push hook (Gate 0, lines 38-52) blocks ALL pushes to `main|master|dev` regardless of remote URL. When pushing from a git submodule working directory (e.g., `git -C wiki push origin master`), the hook fires against the main repo's hook file but the push target is a submodule's remote. GitHub wiki repos may not support PRs (`/pulls` returns 404), making direct push the only viable workflow.

## Context

- `.opencode/hooks/pre-push` — Gate 0, lines 35-53
- Wiki repos have URLs ending in `.wiki.git`
- `SKIP_BRANCH_PROTECTION=1` exists as a manual override but is not suitable for routine wiki pushes
- The original issue was filed with a broad "exempt all submodule pushes" fix, which would weaken branch protection for non-wiki submodules

## Fix Approach

In Gate 0, before the `case "$REMOTE_BRANCH"` check at line 38, add a remote URL inspection step. The pre-push hook receives the remote URL as its second argument (`$2`). If the remote URL contains `.wiki.git`, skip Gate 0 for the current refspec.

Specifically:

1. Capture the remote URL from the hook argument at function scope
2. For each refspec in stdin, check if `$remote_url` contains `.wiki.git`
3. If matched, `continue` past the `case` statement (skip Gate 0)
4. All other refs proceed through the existing `case` check unchanged

## Affected Files

| File | Anchor | Purpose |
|------|--------|---------|
| `.opencode/hooks/pre-push` | Gate 0, case statement at line 38 | Add `.wiki` remote URL check before branch match |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Gate 0 blocks pushes to `main|master|dev` in the main repo (unchanged) | behavioral | `git push origin dev` from root → exit code 1 with BLOCKED message | Ensure .wiki check does not short-circuit main-repo pushes | GREEN | `.opencode/hooks/pre-push` | Bug/Problem section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-2 | Gate 0 blocks pushes to `main|master|dev` in non-wiki submodules (unchanged) | behavioral | `git -C nonwiki push origin master` from test scenario → exit code 1 with BLOCKED message | Ensure .wiki pattern is specific enough to exclude non-wiki submodule remotes | GREEN | `.opencode/hooks/pre-push` | Root Cause section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-3 | Gate 0 permits pushes to `master` in `.wiki` repos | behavioral | Simulate push with `.wiki.git` remote URL → exit code 0, push proceeds | Ensure the `.wiki.git` pattern check correctly identifies wiki remote URLs | GREEN | `.opencode/hooks/pre-push` | Fix Approach section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-4 | Behavioral enforcement test verifies agent behavior: SC-3 passes with push simulation | behavioral | `bash .opencode/tests/behaviors/sc-1230-pre-push-wiki.sh` → exit code 0 | Before any implementation, write the behavioral test in `.opencode/tests/behaviors/`; confirm RED state (test fails before change); then implement | RED (behavioral) | `.opencode/tests/behaviors/sc-1230-pre-push-wiki.sh` | behavioral-test-mandate | Phase 1 | RED | unit | G0-BEHAVE | null | sc-1230-pre-push-wiki.sh | phase-1 |

**All-or-nothing gate:** ALL success criteria MUST pass for implementation to be considered complete. Any SKIPPED SC is treated as FAIL. Any FAILED SC triggers autonomous remediation by the producing agent. Gate holds position until remediation is verified. If re-verification also fails (double-failure), HALT with blocker report.

## Edge Cases

- **Remote URL format variation**: SSH URLs (`git@github.com:user/repo.wiki.git`) and HTTPS URLs (`https://github.com/user/repo.wiki.git`) both contain `.wiki.git` — substring match handles both
- **Custom remote names**: If a wiki remote is configured under a non-`origin` name, the remote URL is still passed as `$2` — check is on URL, not remote name
- **No `.wiki` repo at remote**: If the URL matches `.wiki.git` but the remote does not accept the push (e.g., branch protection on GitHub side), GitHub rejects the push independently — no false PASS risk

## Dependencies

None. Single-file, single-gate change.

## Risk

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | `.wiki.git` pattern misses wiki repo with custom hostname/URL format | Low | Medium | `SKIP_BRANCH_PROTECTION=1` override exists as documented fallback | SC-3 |
| RISK-2 | `.wiki.git` pattern false-positive triggers on non-wiki URL containing `.wiki` | Low | Low | Pattern matches `.wiki.git` specifically, not bare `.wiki` | SC-2 |

## Decision Rationale

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | `.wiki.git` substring match | Most reliable indicator of GitHub wiki repos; covers both SSH and HTTPS URL formats | MUST | SC-3 |
| DEC-2 | No broad submodule exemption | Non-wiki submodules should follow same branch protection; only wiki repos lack PR workflow | MUST NOT | SC-1, SC-2 |
| DEC-3 | `continue` semantics, not `exit 0` | Skip Gate 0 for the matching refspec only; other gates still evaluate | MUST | SC-1 |

## Phases

Single phase. No decomposition needed.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `.opencode/hooks/pre-push` lines 35-53 | Inspect Gate 0 implementation |
| Live verification | `git -C wiki push origin master` (reported in original bug) | Confirm the bug exists |
| Git hook protocol | `git help pre-push` | Confirm `$2` is the remote URL argument |

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)