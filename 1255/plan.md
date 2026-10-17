---
number: 1255
title: "Implementation plan — deviation-triggered worktree map in session-init"
---

# Plan — .opencode#1255

Source: `.opencode/.issues/1255/spec.md` (all items trace to its SCs; no untraceable items).
Deliverable files: `.opencode/tools/session-init` (map logic + emission), new test module
`.opencode/tests/test_session_init/test_worktree_map.py`. Test runner: `uv run pytest`
from `.opencode/` (pyproject testpaths `tests`, pythonpath `tools`); the session-init
script is loaded in tests via `SourceFileLoader` (pattern of the existing
`test_issue_artifact_paths.py`).

## Shared fixture helper (item 0 — test infrastructure, instrumented by every SC)

Every SC instrument runs in a scratch fixture workspace: a `tmp_path` git repo with an
initial commit, acting as the "project root"; a helper builds standard topology
(`.issues` worktree on `issues-data` where needed) and deviation variants. Real git
operations, real worktrees; each deviation fixture's teardown removes the worktree,
prunes, deletes created branches, and asserts zero residual registrations. Session-init
runs in-process via `main()` with cwd monkeypatched, stdout captured.

## Items (one per SC)

1. **SC-7 (core enumeration + completeness) — implement first; all other items build on it.**
   - Deliverable: `collect_worktree_map()` in session-init — per enumerated repo
     (exactly `collect_repo_info()`'s set, in its order), one group; rows are that
     repo's linked worktrees (porcelain rows after the main-worktree row, which is
     skipped — this also neutralizes the module-gitdir quirk), one row each,
     deduplicated.
   - RED: fixture with submodule + parent deviation trigger; expected ordered
     (group, row) set constructed from the fixture topology; emitted map differs.
   - GREEN: the function returns the exact expected structure.
   - Instrument: pytest — emitted groups/rows equal the expected ordered set exactly;
     **plus the SC-8 structural assertions** (no `.git/modules/` substring in the map;
     no main-worktree/module-gitdir row rendered; submodule rows resolve to real
     worktree paths) — SC-8's property is decided by this item's skip-the-main-row
     behavior, so its assertions run here, in the cycle where the behavior is created.

2. **SC-6 (map grammar).**
   - Deliverable: emitted section conforms line-by-line: `## Worktree Map` title,
     blank separators, group headers (`<owner>/<repo>:` for the root entry,
     `submodule <relpath>:` for submodule entries), rows
     (`  <relpath> [<branch>|detached] [current] [prunable]`); no SHA, no absolute
     path, no prose; whitespace-containing relpaths single-quoted.
   - RED: grammar parser test over a triggered fixture's map section fails on
     current (absent) output.
   - GREEN: zero non-conforming lines.
   - Instrument: pytest — parse section (title through next `## ` marker), assert
     zero non-conforming lines; includes a fixture worktree path with a space.

3. **SC-3 (non-standard worktree, actual branch).**
   - Deliverable: row `<relpath> [<branch>]` where branch is the worktree's checked-out
     branch without `refs/heads/`.
   - RED: fixture worktree on a new branch; map absent or branch wrong.
   - GREEN: displayed branch equals `git -C <wt> rev-parse --abbrev-ref HEAD`.
   - Instrument: pytest equality assertion; cleanup (remove, prune, delete branch).

4. **SC-4 (prunable marking).**
   - Deliverable: `prunable` flag on rows whose porcelain entry carries `prunable`.
   - RED: create worktree, delete its directory; row lacks `prunable`.
   - GREEN: row carries `prunable`; after `git worktree prune` the registration is gone.
   - Instrument: pytest both assertions.

5. **SC-5 (current flag).**
   - Deliverable: `current` flag on the row whose resolved toplevel equals the running
     `git rev-parse --show-toplevel`.
   - RED: run session-init with cwd inside a non-standard linked worktree; row lacks
     `current`.
   - GREEN: row carries `current` (and only that row does).
   - Instrument: pytest.

6. **SC-10 (detached HEAD).**
   - Deliverable: `[detached]` rendering, no hexadecimal string in the row.
   - RED: `git worktree add --detach` fixture; row not `[detached]` or leaks SHA.
   - GREEN: map emitted; row renders `[detached]` with no hex string.
   - Instrument: pytest regex assertion; cleanup.

7. **SC-11 (store branch anomaly, T4).**
   - Deliverable: `.issues` store row shows its actual branch; deviation trigger fires
     when it is not `issues-data`.
   - RED: store worktree on an alternate branch; no map or wrong branch shown.
   - GREEN: map emitted; store row shows the alternate branch.
   - Instrument: pytest; cleanup.

8. **SC-1 (no map in standard shape).**
   - Deliverable: deviation triggers evaluate to no-emission when only main + standard
     `.issues` store exist, no prunable, no detached, store on `issues-data`.
   - RED: standard-shape fixture run emits `## Worktree Map`.
   - GREEN: marker absent.
   - Instrument: pytest — assert `## Worktree Map` not in stdout.

9. **SC-2 (pre-existing surface preserved) — regression guard, not a RED/GREEN cycle.**
   - Deliverable: no changes to existing sections; `Worktree:` line conditional as today.
   - Nature: SC-2 asserts *unchanged* behavior; no falsifiable RED exists against
     current behavior by design. The item is a regression guard executed outside the
     RED/GREEN framing: the guard test is written and run **pre-change** (recorded
     green as evidence), then must remain green after every subsequent item.
   - Guard: two fixture runs (main worktree cwd; inside a linked worktree cwd) assert
     ordered markers `## CLI Auth Status` (when present) → `## Hook Inventory` →
     `## Local Issue Folders` → `## Repo Information` → `## Agent Tools`, plus
     `Worktree:` line inside the linked worktree.
   - Instrument: pytest ordered-marker assertions in both runs; pre-change green run
     recorded in the work record.

10. **SC-12 (placement).**
    - Deliverable: map section emitted between `## Local Issue Folders` and
      `## Repo Information` in `main()`.
    - RED: in a triggered fixture, marker not between the two section markers.
    - GREEN: `## Local Issue Folders` < `## Worktree Map` < `## Repo Information`.
    - Instrument: pytest marker-order assertions.

11. **SC-8 (no `.git/modules/` leakage) — regression guard; assertions live in item 1.**
    - Deliverable: none of its own — the skip-the-main-row behavior that decides
      SC-8 is item 1's, and the module gitdir only ever appears in that row, so
      SC-8's assertions are part of item 1's RED/GREEN cycle (see item 1's
      instrument). This item exists to keep SC-8 traceable and to re-assert the
      property as a regression guard after all later items.
    - Guard: after all items land, re-run the SC-8 structural assertions
      (`.git/modules` absent from any emitted map; submodule rows show real paths)
      against the submodule-bearing fixture.
    - Instrument: the same pytest assertions, executed in the final full-suite run.

12. **SC-9 (embedded repo excluded) — regression guard, not a RED/GREEN cycle.**
    - Deliverable: no discovery beyond `collect_repo_info()` — an embedded `git init`
      repo under an ignored path neither triggers the map nor appears in it or in
      `## Repo Information`.
    - Nature: the pre-change state already satisfies both assertions (the map does not
      exist yet and `## Repo Information` is already clean), so no falsifiable RED
      exists; the item is a regression guard executed outside the RED/GREEN framing:
      written and run pre-change (recorded green as evidence), then must remain green
      after every subsequent item — the post-change run is the real check that the
      map implementation introduces no embedded-repo leakage.
    - Guard: standard topology + embedded repo (`git init` under an ignored path);
      assert no `## Worktree Map` and no entry naming the embedded path anywhere in
      the output.
    - Instrument: pytest; post-change green run is the deliverable evidence.

## Dependency order

Item 0's fixture helper and the guards (items 9, 12) are written and run pre-change
(recorded green). Item 1 (which carries SC-7 and SC-8's assertions) → 2 →
3,4,5,6,7 (row/flag features over the core structure) → 8,10 (emission gating and
placement). RED/GREEN cycles run in that order; the guards (items 9, 11, 12) re-run
after every subsequent item; the full suite runs green at the end.

## Existing test surface (spec "Affected Files")

The spec requires the tool's existing unit tests (#2088) to be "extended for the map
and kept green." The extension is the new test module `test_worktree_map.py` in the
same `tests/test_session_init/` directory — the map has no pre-existing behavior to
extend inside the old files, and the old files test other functions unchanged. Each
existing file (`test_repo_discovery.py`, `test_issue_artifact_paths.py`,
`test_auth.py`, `test_fork_stamp.py`, `test_fork_annotation.py`) runs unchanged in
the final full-suite gate and must stay green; any red there blocks the PR gate.

## Final gates

- Full suite: `uv run pytest` in `.opencode/` — all green, output captured.
- Fresh-context `verify` dispatch against the spec's SCs before PR creation.

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
