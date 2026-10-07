<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2543 -->

# local-issues sync and worktree mechanics

## Store shape

Each repo's `.issues/` is a git worktree of that repo checked out on the
orphan branch `issues-data`. The branch is metadata-only: its tree holds
issue records and nothing else. It is not a submodule and never appears in
`.gitmodules`.

## Initialization (plumbing-based)

When no local `issues-data` branch exists, the tool creates it with git
plumbing only: `git hash-object -t tree /dev/null` → `git commit-tree` →
`git update-ref refs/heads/issues-data`. No temp worktree exists at any
point, no porcelain commit runs (hook contact is structurally impossible),
the branch tree is empty by construction, and zero-commit repositories are
supported. When the remote already has `issues-data`, the tool bootstraps
the local branch from `origin/issues-data` instead.

## Fail-fatal worktree contract

If worktree establishment fails, the tool exits non-zero with a diagnostic
naming the failure and the exact `git worktree add` remediation command.
There is no plain-directory fallback: the tool never writes issue records
outside the `issues-data` worktree.

## Remote-first number reservation

When a remote issue tracker exists, the remote issue is filed first — for
every issue creation — to reserve the number; the local `{N}/` folder is
then registered via `create --number repo#N`. Local-first reservation forks
the number space and is a violation. Remoteless stores pick the next free
number in that repo's own namespace.

## Sync cycle

- Mutation commands auto-commit in the worktree and push `issues-data` to
  `origin` (push is skipped when the remote is HTTPS without a credential
  helper).
- `sync` = commit pending + `pull --rebase origin issues-data` + push, per
  repo. On conflict it reports the qualifier and the exact
  `git -C <worktree> pull --rebase` command for manual resolution.
- `init` = ensure worktrees in all repos (root first, then `.gitmodules`
  children) + pull; pair it with `sync` at session start.
