---
remote_issue: 1272
remote_url: "https://github.com/michael-conrad/.opencode/issues/1272"
last_sync: "2026-06-17T22:54:36Z"
source: github
---

## Problem

`_discover_all_repos()` in `.opencode/tools/local-issues` uses `iterdir()` with a dot-directory skip:

```python
for entry in sorted(root.iterdir()):
    if not entry.is_dir() or entry.name.startswith("."):
        continue
```

This skips `.opencode/` (a valid submodule with a `.git` gitlink file), so `.opencode/.issues/` is never discovered and never synced. The `*/.issues/` sync is broken for any dot-prefixed submodule.

### Root Cause

Commit `67052b08` ("fix: replace .gitmodules discovery with glob scan in local-issues (#1224)") replaced the old `_discover_submodules()` (which parsed `.gitmodules` and found `.opencode/` correctly) with a glob scan that skips dot-directories. The old `_discover_subrepos()` also had the dot-skip, but it was only for non-submodule repos — submodules were handled separately by `_discover_submodules()`. When the two were merged into `_discover_all_repos()`, the submodule path was lost and the dot-skip was applied to everything.

## Fix

Replace the `iterdir()` dot-skip with explicit pattern matching against the three valid git repo indicators:

- `/.git/` — parent repo (already handled by `repos.append(root)`)
- `/*/.git` — immediate child with a `.git` **file** (submodule gitlink, e.g., `.opencode/.git`)
- `/*/.git/` — immediate child with a `.git` **directory** (non-bare sub-repo)

### Current code (lines 282-283):

```python
for entry in sorted(root.iterdir()):
    if not entry.is_dir() or entry.name.startswith("."):
        continue
```

### Replacement:

```python
for entry in sorted(root.iterdir()):
    if not entry.is_dir():
        continue
    git_ref = entry / ".git"
    if not git_ref.exists():
        continue
    # git_ref is either a file (submodule gitlink) or directory (non-bare repo)
    resolved = entry.resolve()
    if resolved in repos:
        continue
    result = subprocess.run(
        ["git", "-C", str(resolved), "rev-parse", "--is-bare-repository"],
        capture_output=True, text=True, timeout=15,
    )
    if result.returncode == 0 and result.stdout.strip() == "false":
        repos.append(resolved)
```

The key change: remove `entry.name.startswith(".")` — a `.git` file or directory is the only signal needed. A dot-prefixed directory without a `.git` ref is correctly ignored (no false positives), and a dot-prefixed directory WITH a `.git` ref (like `.opencode/`) is correctly included.

## Affected Files

| File | Change |
|------|--------|
| `.opencode/tools/local-issues` | Replace `_discover_all_repos()` dot-skip with `/*/.git` pattern matching |

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `_discover_all_repos()` includes `.opencode/` when it has a `.git` gitlink file | behavioral |
| SC-2 | `_discover_all_repos()` does NOT include non-git dot-directories (e.g., `.git/`, `__pycache__/`) | behavioral |
| SC-3 | `_discover_all_repos()` still includes non-dot sub-repos (unchanged behavior) | behavioral |
| SC-4 | `local-issues sync` successfully syncs `.opencode/.issues/` when it exists | behavioral |
| SC-5 | `local-issues list` shows issues from `.opencode/.issues/` | behavioral |

## Labels

- `spec`

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)