number: 2544
title: "[SPEC] session-init: exclude wiki checkouts (origin *.wiki.git) from hook installation + inventory, with self-healing removal"
state: OPEN
---

# Plan — session-init strict submodule discovery + wiki exclusion + self-heal

Source: `.opencode/.issues/2544/spec.md` (items 1–5). Target file:
`.opencode/tools/session-init` (single-file Python script; pytest suite at
`.opencode/tests/test_session_init/`).

## Dependency graph

```
P1 strict discovery ──► P2 wiki exclusion ──► P3 cleanup enumeration + self-heal ──► P4 regression suite
```

## P1 — Strict discovery (spec item 1)

RED: `tests/test_session_init/test_repo_discovery.py` — fixture workspace with
root repo + registered submodule + ignored sub-repo (plain dir with `.git` and
origin). Assert `collect_repo_info()` contains root + registered submodule
with checkout and parseable origin; does NOT contain the ignored sub-repo.

GREEN: replace the `os.listdir` `.git`-entry scan (both depth loops) with
registered-tree traversal:

- `_registered_submodule_paths(repo_dir)` — paths from `git -C <dir> config
  -f .gitmodules --get-regexp submodule\..*\.path`, each verified present in
  `git -C <dir> submodule status` output.
- Recursion over the registered tree (transitive): for each registered entry,
  cover only when checkout present (not `-` status, `.git` entry exists) and
  `remote.origin.url` parses to owner/repo (existing `parse_repo_url`, no
  `.gitmodules` fallback). Then recurse into that checkout.
- `_is_issues_store_path` guards become moot in discovery (worktrees are not
  registered submodules) — removed from the discovery path; behavior
  preserved (they were never enumerated as covered entries).

## P2 — Wiki exclusion (spec item 2)

RED: fixture with a registered submodule whose origin ends in `.wiki.git` —
assert no inventory entry, no hook install target, and (cleanup-adjacent)
it lands in cleanup scope.

GREEN: `_is_wiki_origin(url)` — final path segment (after `/` and `:` split,
trailing `/` stripped) ends in `.wiki` or `.wiki.git` → excluded at every
level of the traversal. Exclusion happens inside discovery so
`install_hooks()` and `collect_hook_inventory()` inherit it automatically.

## P3 — Cleanup enumeration + self-heal (spec items 3–4)

RED: fixture with rogue sub-repo (not registered) containing hooks dir with a
file whose name+content match a committed historical hook in a fixture deck
repo (`.opencode`-shaped git repo with `hooks/<name>` history). Assert file
removed and removal event reported. Foreign-name and foreign-content files
untouched. Coverage-set hooks dirs (root, covered submodule, linked
worktree aliases) untouched.

GREEN:

- `_legacy_scan_candidates()` — bounded enumeration mirroring the old scan:
  immediate child dirs with `.git` entry (pollution-test when parseable
  origin; descend regardless) + depth-2 dirs with `.git` entry and parseable
  origin. Used solely for cleanup.
- `_historical_hook_signatures(deck_root)` — from the deck repo's git
  history: names ever carried under `hooks/` (`git log --all --name-only`)
  and, per name, every blob sha1 ever recorded (`git log --format=%H` +
  `git rev-parse <sha>:hooks/<name>`); content hash via `git hash-object`
  equivalent (blob-sha1 in Python).
- `self_heal_hooks()` — called from `install_hooks()`; classification by
  resolved hooks dir (`_resolve_hooks_target`); skips anything resolving to
  a coverage-set hooks dir (root + covered submodules; linked worktrees
  dedupe); removes matching files, reports `removed <path>: <name>
  (self-heal)` to stderr; repos stay out of inventory.

## P4 — Regression invariant (spec item 5) + suite

- Fixture asserts: root + non-wiki registered submodule keep coverage and
  hooks; `.issues/`-shaped worktree produces no entry and no install.
- Full `.opencode` pytest suite green; script smoke-run
  (`./.opencode/tools/session-init --description`, plus a live run in the
  workspace) clean.
