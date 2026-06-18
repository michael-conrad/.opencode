# [SPEC-FIX] pre-push Gate 0 must allow wiki submodule pushes to default branch

## Intent and Executive Summary

| Field | Description |
|-------|-------------|
| Problem Statement | The pre-push hook Gate 0 blocks all pushes to `main|master|dev`, including legitimate pushes from wiki submodules that have no PR workflow available |
| Root Cause / Motivation | Gate 0 inspects only `$REMOTE_BRANCH` — it never checks whether the push's remote URL indicates a wiki repo. Wiki repos across all major platforms (GitHub, GitLab, GitBucket, Bitbucket) do not support PR workflows — direct push is the only delivery mechanism |
| Approach Chosen | Add wiki remote URL detection to Gate 0 using a platform-agnostic pattern match on the remote URL; skip Gate 0 for wiki remotes only |
| Alternatives Considered & Why Discarded | (1) Broad submodule exemption — rejected because non-wiki submodules should follow branch protection. (2) `.wiki.git`-only pattern — rejected because Bitbucket uses `/wiki` suffix, not `.wiki.git` |
| Key Design Decisions | Pattern match for both `.wiki.git` (GitHub, GitLab, GitBucket) and `/wiki` (Bitbucket) URL suffixes; all non-wiki remote URLs remain subject to Gate 0 |

## Objective

Modify Gate 0 in `.opencode/hooks/pre-push` to permit pushes to `main|master|dev` when the target remote is a wiki repository (URL matches `.wiki.git` or `/wiki` suffix). All other pushes to these branches — from the main repo or non-wiki submodules — MUST remain blocked.

## Problem

The pre-push hook (Gate 0, lines 38-52) blocks ALL pushes to `main|master|dev` regardless of remote URL. When pushing from a git submodule working directory (e.g., `git -C wiki push origin master`), the hook fires against the main repo's hook file but the push target is a submodule's remote. Wiki repos across all major platforms do not support PRs — direct push is the only viable workflow.

## Context

- `.opencode/hooks/pre-push` — Gate 0, lines 35-53
- The original issue was filed with a broad "exempt all submodule pushes" fix, which would weaken branch protection for non-wiki submodules

### Wiki Repo URL Patterns (Verified)

Research was conducted via dedicated sub-agent with live-source verification:

| Platform | URL Pattern | Default Branch | Supports PRs | Source |
|----------|-------------|---------------|-------------|--------|
| GitHub | `repo.wiki.git` | master (historical) | No | [GitHub Docs](https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages) |
| GitLab | `repo.wiki.git` | main (configurable) | No | [GitLab Docs](https://docs.gitlab.com/ee/user/project/wiki/) |
| Bitbucket | `repo/wiki` or `repo/wiki.git` | main | No | [Bitbucket Docs](https://support.atlassian.com/bitbucket-cloud/docs/clone-a-wiki/) |
| GitBucket | `repo.wiki.git` | main | No | [GitBucket Docs](https://github.com/gitbucket/gitbucket/blob/master/doc/directory.md) (shows `REPO_NAME.wiki.git` in directory structure) |
| Gitea/Gogs | NOT VERIFIED | — | — | — |

Cross-platform commonality: all verified platforms use a separate git repo for wiki content, none support PRs, and all require direct push to the default branch. The URL suffix is either `.wiki.git` (GitHub, GitLab, GitBucket) or `/wiki` (Bitbucket). The detection MUST handle both patterns.

## Fix Approach

In Gate 0, before the `case "$REMOTE_BRANCH"` check at line 38, add a remote URL inspection step. The pre-push hook receives the remote URL as its second argument (`$2`). If the remote URL matches `.wiki.git` suffix or `/wiki` path component, skip Gate 0 for the current refspec.

Specifically:

1. The pre-push hook receives `$2` as the remote URL (per `git help pre-push`)
2. For each refspec on stdin, check if `$2` matches `\.wiki\.git$` or `/wiki` (as path suffix)
3. If matched, `continue` past the `case` statement (skip Gate 0 for wiki refspecs)
4. All other refs proceed through the existing `case` check unchanged

## Affected Files

| File | Anchor | Purpose |
|------|--------|---------|
| `.opencode/hooks/pre-push` | Gate 0, case statement at line 38 | Add wiki remote URL check before branch match |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|-------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | Gate 0 blocks pushes to `main|master|dev` in the main repo (unchanged) | behavioral | `git push origin dev` from root → exit code 1 with BLOCKED message | Ensure wiki check does not short-circuit main-repo pushes | GREEN | `.opencode/hooks/pre-push` | Bug/Problem section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-2 | Gate 0 blocks pushes to `main|master|dev` in non-wiki submodules (unchanged) | behavioral | `git -C nonwiki push origin master` from test scenario → exit code 1 with BLOCKED message | Ensure wiki pattern is specific enough to exclude non-wiki submodule remotes | GREEN | `.opencode/hooks/pre-push` | Root Cause section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-3 | Gate 0 permits pushes to default branch in wiki repos with `.wiki.git` URLs (GitHub, GitLab, GitBucket) | behavioral | Simulate push with `.wiki.git` remote URL → exit code 0, push proceeds | Ensure `.wiki.git` pattern correctly identifies GitHub/GitLab/GitBucket wiki repos | GREEN | `.opencode/hooks/pre-push` | Fix Approach section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-4 | Gate 0 permits pushes to default branch in wiki repos with `/wiki` URLs (Bitbucket) | behavioral | Simulate push with `repo/wiki` remote URL → exit code 0, push proceeds | Ensure `/wiki` pattern correctly identifies Bitbucket wiki repos | GREEN | `.opencode/hooks/pre-push` | Fix Approach section | Phase 1 | pre-commit | unit | G0 | null | manual | phase-1 |
| SC-5 | Behavioral enforcement test verifies agent behavior: SC-3 and SC-4 pass with push simulation | behavioral | `bash .opencode/tests/behaviors/sc-1230-pre-push-wiki.sh` → exit code 0 | Before any implementation, write the behavioral test in `.opencode/tests/behaviors/`; confirm RED state (test fails before change); then implement | RED (behavioral) | `.opencode/tests/behaviors/sc-1230-pre-push-wiki.sh` | behavioral-test-mandate | Phase 1 | RED | unit | G0-BEHAVE | null | sc-1230-pre-push-wiki.sh | phase-1 |

**All-or-nothing gate:** ALL success criteria MUST pass for implementation to be considered complete. Any SKIPPED SC is treated as FAIL. Any FAILED SC triggers autonomous remediation by the producing agent. Gate holds position until remediation is verified. If re-verification also fails (double-failure), HALT with blocker report.

## Edge Cases

- **Custom remote names**: If a wiki remote is configured under a non-`origin` name, the remote URL is still passed as `$2` — check is on URL, not remote name
- **`.wiki` in non-wiki repo name**: Hypothetical non-wiki repo containing `.wiki` in its name (e.g., `my-wiki-tools`). The check is on `.wiki.git` and `/wiki` suffixes — `my-wiki-tools` would not match either pattern. No false positive risk.
- **Platforms with undocumented wiki URL patterns (Gitea, Gogs)**: If wiki repos on these platforms use different URL patterns, the hook will still block them. GitBucket has been verified to use `.wiki.git` — same pattern as GitHub and GitLab. Document `SKIP_BRANCH_PROTECTION=1` as a valid override mechanism — not as a routine bypass, but as an escape hatch for users who need it until the detection pattern can be extended.

## Dependencies

None. Single-file, single-gate change.

## Risk

| RISK-ID | Risk Description | Likelihood | Impact | Mitigation | Verifying SC |
|---------|-----------------|------------|--------|------------|--------------|
| RISK-1 | `.wiki.git`/`/wiki` patterns miss wiki repos on undocumented platforms (Gitea, Gogs) | Low | Medium | GitBucket has been verified to use `.wiki.git` (same pattern). Gitea/Gogs patterns unverified — `SKIP_BRANCH_PROTECTION=1` override exists for edge cases; report the gap so the pattern can be extended | SC-3, SC-4 |
| RISK-2 | False-positive on non-wiki URL containing `/wiki` path segment | Low | Low | `/wiki` must be a suffix of the repo path component, not any occurrence — most non-wiki URLs don't end in `/wiki` | SC-2 |

## Decision Rationale

| DEC-ID | Decision | Rationale | Requirement Key | Affected SCs |
|--------|----------|-----------|-----------------|--------------|
| DEC-1 | Dual pattern match (`.wiki.git` + `/wiki`) | `.wiki.git` covers GitHub, GitLab, and GitBucket; `/wiki` covers Bitbucket. All patterns verified against official documentation | MUST | SC-3, SC-4 |
| DEC-2 | No broad submodule exemption | Non-wiki submodules should follow same branch protection; only wiki repos lack PR workflow | MUST NOT | SC-1, SC-2 |
| DEC-3 | `continue` semantics, not `exit 0` | Skip Gate 0 for the matching refspec only; other gates still evaluate | MUST | SC-1 |
| DEC-4 | `SKIP_BRANCH_PROTECTION=1` documented as escape hatch only | The override exists for undocumented platforms, not routine wiki pushes — the patterns should cover all verified platforms | MAY | SC-1, SC-2 |

## Phases

Single phase. No decomposition needed.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `.opencode/hooks/pre-push` lines 35-53 | Inspect Gate 0 implementation |
| Web research | Dedicated sub-agent | Verify wiki URL patterns across GitHub, GitLab, Bitbucket |
| Official docs | [GitHub Wiki Docs](https://docs.github.com/en/communities/documenting-your-project-with-wikis/adding-or-editing-wiki-pages), [GitLab Wiki Docs](https://docs.gitlab.com/ee/user/project/wiki/), [Bitbucket Wiki Docs](https://support.atlassian.com/bitbucket-cloud/docs/clone-a-wiki/), [GitBucket Docs](https://github.com/gitbucket/gitbucket/blob/master/doc/directory.md) («`REPO_NAME.wiki.git`» in directory structure) | Verify URL format, PR support, and branch naming per platform |
| Git hook protocol | `git help pre-push` | Confirm `$2` is the remote URL argument |

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)