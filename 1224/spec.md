---
number: 1224
title: "[SPEC-FIX] Replace .gitmodules-based repo discovery in local-issues tool with filesystem glob scan including parent repo"
status: approved
labels: ["spec-fix", "approved-for-pr", "approved-for-plan"]
created: 2026-06-15
---

## Problem

`.opencode/tools/local-issues` has two submodule/repo discovery functions that both have defects:

### 1. `_discover_submodules()` — `.gitmodules`-based (line 265)

Parses `.gitmodules` via `configparser`. Same failure mode as `opencode#1217`: stale/missing `.gitmodules` → silently returns empty. Must be removed in favor of filesystem glob scan.

### 2. `_discover_repos()` — omits the parent repo (line 322)

Returns **only** child sub-repos. The parent repo (`.git/` at project root) is never included. At least 7 callers are affected, 5 of which manually work around this with `repos.insert(0, current)`.

### 3. `_discover_subrepos()` — misses the `.git/` root pattern

Scans `*/.git` files/dirs in child directories but never checks `.git/` at the project root.

## Solution

Replace all three functions with a single `_discover_all_repos()` function using a pure filesystem glob scan. Parent repo always first. No `.gitmodules` parsing. Remove all `repos.insert(0, current)` workarounds.

## Success Criteria

| ID | Criterion | Evidence Type |
|----|-----------|---------------|
| SC-1 | `_discover_submodules()` function removed | `string` |
| SC-2 | `_discover_subrepos()` function removed | `string` |
| SC-3 | `_discover_repos()` replaced by `_discover_all_repos()` inclusive of parent repo | `string` |
| SC-4 | All `repos.insert(0, current)` workarounds removed | `string` |
| SC-5 | No `.gitmodules` references remain in tools/ | `string` |
| SC-6 | `_discover_all_repos()` scans all three glob patterns (`.git/`, `*/.git/`, `*/.git`) | `structural` |

## Phases

### Phase 1: Replace repo discovery with clean filesystem glob

**Concern:** Replace three functions with one clean `_discover_all_repos()` and remove `.gitmodules` parsing and `insert(0, current)` workarounds (SC-1 through SC-6).

**Files:**
- `.opencode/tools/local-issues` — replace functions, remove workarounds, remove gitmodules references

---

Co-authored with AI: OpenCode (deepseek-v4-flash)