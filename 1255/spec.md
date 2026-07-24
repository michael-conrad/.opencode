---
number: 1255
title: "[SPEC] Add git worktree list output to session init injection"
state: OPEN
---

## Problem

The session-init tool (`session-init`) and the session-enforcement plugin (`session-enforcement.ts`) currently provide limited visibility into the git worktree topology. The `## Repo Information` section lists repos by path/owner/repo/platform/url, and the `buildPreImplementationGate()` function shows `worktree=none` as a static string. Neither provides the actual `git worktree list` output for the main repo, submodules, or ignored sub-repos.

This means the agent cannot reliably determine:
- Which worktrees exist and what branches they are on
- Whether a submodule has its own worktrees (e.g., `.opencode/.issues/`, `newsrx-genai-python/.issues/`)
- Whether ignored sub-repos (like `.worktrees/main/`) have worktrees
- The relationship between worktree paths and their branches

## Proposed Change

Add a `## Worktree Topology` section to the session-init output that includes `git worktree list` output for:

1. **Main repo** — the primary repository's worktrees (e.g., `.issues/`, `.worktrees/main/`)
2. **Submodules** — each submodule's worktrees (e.g., `.opencode/.issues/`, `newsrx-genai-python/.issues/`, `wiki/.issues/`)
3. **Ignored sub-repos** — repos under `.worktrees/` or other ignored paths that have their own `.git` entries

## Implementation

### Changes to `session-init` (Python)

Add a `collect_worktree_info()` function that:

1. Runs `git worktree list --porcelain` for the main repo
2. For each submodule directory (detected via `.git` file/ref), runs `git -C <path> worktree list --porcelain`
3. For each ignored sub-repo directory (e.g., `.worktrees/main/`), runs `git -C <path> worktree list --porcelain`
4. Returns structured data: path, branch, HEAD SHA, and whether it's prunable

### Changes to `session-enforcement.ts` (TypeScript)

Update `buildPreImplementationGate()` to include the worktree topology in the `## Worktree Topology` section. The function currently hardcodes `worktree=none` — it should instead read the worktree topology from the session-init output or run `git worktree list` directly.

### Output Format

```
## Worktree Topology

Main repo (/home/user/git/hermes-ingest-pubmed):
  /home/user/git/hermes-ingest-pubmed             77062ba [dev]
  /home/user/git/hermes-ingest-pubmed/.issues     985f533 [issues-data]
  /home/user/git/hermes-ingest-pubmed/.worktrees/main 9e780bb [main]

Submodule .opencode:
  /home/user/git/hermes-ingest-pubmed/.opencode          8de51c1a [dev]
  /home/user/git/hermes-ingest-pubmed/.opencode/.issues  e9bbce49 [issues-data]

Submodule newsrx-genai-python:
  /home/user/git/hermes-ingest-pubmed/.git/modules/newsrx-genai-python  6fd5215 [dev]
  /home/user/git/hermes-ingest-pubmed/newsrx-genai-python/.issues       a5f5093 [issues-data] prunable

Submodule wiki:
  /home/user/git/hermes-ingest-pubmed/.git/modules/wiki  1d516bb [issues-data]
```

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `session-init` outputs a `## Worktree Topology` section with main repo worktrees | `behavioral` | Run `session-init` and grep for `## Worktree Topology` |
| SC-2 | Main repo worktrees include `.issues/` and `.worktrees/main/` when they exist | `behavioral` | Run `session-init` and verify both paths appear |
| SC-3 | Submodule worktrees are listed for each submodule with `.issues/` worktrees | `behavioral` | Run `session-init` and verify `.opencode/.issues/` appears |
| SC-4 | Ignored sub-repo worktrees (`.worktrees/main/`) are listed | `behavioral` | Run `session-init` and verify `.worktrees/main/` appears |
| SC-5 | `buildPreImplementationGate()` in `session-enforcement.ts` includes worktree topology instead of hardcoded `worktree=none` | `behavioral` | Run `session-enforcement.ts` and verify output contains worktree paths |
| SC-6 | Prunable worktrees are flagged with `prunable` annotation | `behavioral` | Run `session-init` and verify `prunable` appears for stale worktrees |
| SC-7 | Output format matches the specified format (path, SHA, [branch], optional annotations) | `string` | Grep for `\[` and `prunable` patterns in output |

## Files Affected

- `.opencode/tools/session-init` — add `collect_worktree_info()` function and `## Worktree Topology` output section
- `.opencode/plugins/session-enforcement.ts` — update `buildPreImplementationGate()` to include worktree topology

## Risks

- **Submodule worktree detection**: Submodules may have their `.git` as a file (gitlink) or directory. The `git -C <path> worktree list` command works for both, but the path resolution differs. Must handle both cases.
- **Performance**: `git worktree list` is fast (sub-millisecond), but running it for N submodules adds N subprocess calls. Acceptable for <20 submodules.
- **Ignored sub-repos**: `.worktrees/main/` is gitignored but has a real `.git` directory. The function must explicitly scan ignored directories.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

*Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)*