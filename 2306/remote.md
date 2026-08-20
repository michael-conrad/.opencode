---
remote_issue: 2306
remote_url: "https://github.com/michael-conrad/.opencode/issues/2306"
last_sync: 2026-08-20T18:26:04Z
source: github
---

**Problem:** The task card `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md` instructs syncing "dirty submodule pointers to latest trunk tip." An orchestrator acting on this (plus a "do this for all submodules" directive) attempted to recurse into submodules — including nested ones — to pull each to remote trunk tip. This is a regression because:

1. It violates the standing guideline in `.opencode/guidelines/060-tool-usage.md` §4: "NEVER use `--recursive` with any git submodule command ... Always use `git submodule update --init` (without `--recursive`) or explicit per-submodule operations."

2. The task card's step 2 iterates submodule paths but does NOT explicitly prohibit recursion into nested submodules (e.g., `ButterApi/DaoCore2`, `WeekliesPDFs/ProcessFinishedNotify`, nested `.issues/` worktrees). A literal reading invites `git submodule foreach` recursion.

3. Recursion produces a false "changed submodule" (`+`) flag in the parent: after syncing each submodule to its own trunk tip, the parent sees each submodule pointer diverge from the committed SHA, showing all as `M`/`+` — a false-changed-state that triggers needless re-pointer churn and can corrupt branch/PR intent.

**Expected behavior:** The task card should explicitly bound scope to the parent repo's direct submodule pointers and forbid recursion (mirroring 060-tool-usage.md), and direct the agent to use explicit per-submodule operations rather than recursive/foreach iteration.

**Affected file:** `.opencode/skills/git-workflow-branch/tasks/submodule-sync.md`

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)