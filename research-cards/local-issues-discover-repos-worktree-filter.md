---
question: "What causes the nested .issues/.issues/ directory in local-issues sync for submodule repos?"
findings:
  - "`_discover_all_repos()` at local-issues:265 includes the root repo's `.issues/` git worktree as a child repo because it finds a `.git` file there with no filter to distinguish worktrees from submodules"
  - "A worktree `.git` file contains `worktrees/` in its gitdir path; a submodule `.git` file contains `modules/`"
  - "`_sync_repo()` at line 1603 probes `(issues_dir / '.git').is_file()` where `issues_dir = repo_path / ISSUES_DIR` = `.issues/.issues/` — a nested path that doesn't exist → reports `no_worktree`"
  - "`_ensure_worktree()` at line 669 has a guard that prevents actual nested directory creation in normal conditions, but the sync path still probes the wrong path"
  - "The bug description in #1296 is misidentified — it's not about worktree detection confusion between root and submodule, it's about `_discover_all_repos()` failing to filter out worktrees"
confidence: 0.95
sources:
  - "local-issues:265-297 — `_discover_all_repos()` scans all child dirs for `.git` files, no worktree filter"
  - "local-issues:710-720 — `_collect_repos()` includes `.issues/` as a child repo"
  - "local-issues:1598-1623 — `_sync_repo()` probes `repo_path / ISSUES_DIR / '.git'` which becomes `.issues/.issues/.git`"
  - "local-issues:651-685 — `_ensure_worktree()` guard at line 669 prevents actual nested creation"
  - "Filesystem evidence: `.issues/.git` → `worktrees/-issues`, `.opencode/.git` → `modules/.opencode`"
tags:
  - local-issues
  - worktree-detection
  - bug-fix
  - discover-repos
created: "2026-06-19"
confidence: 0.95
