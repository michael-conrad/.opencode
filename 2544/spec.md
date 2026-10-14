number: 2544
title: "[SPEC] session-init: exclude wiki checkouts (origin *.wiki.git) from hook installation + inventory, with self-healing removal"
state: OPEN
labels: [needs-approval]
---

# [SPEC] session-init: exclude wiki checkouts (origin *.wiki.git) from hook installation + inventory, with self-healing removal

## Bug (upstream report per developer directive, hermes-admin session 2026-10-07)

**Ruling (Michael Conrad, 2026-10-07):** *"session-init should only be doing registered submodules, not ignored sub-repos, it should be strictly on git submodule for listing the submodules correctly."* And the same session: *"git hooks are to never be applied to wiki repos."*

### Reproduced failure (evidence trail)

1. Agent cloned `NewsRx/hermes-admin.wiki.git` → `hermes-admin/hermes-admin.wiki/` (ignored in-tree sub-repo per the wiki-operations card, which forbids registering a wiki as a submodule; the same card's provisioning ladder documents **inherited submodule wikis** — existing `.gitmodules` entries wiring a wiki are operated in place — so a wiki checkout can also exist as a registered submodule). Fresh clone: hooks dir contains samples only.
2. Next session-init run discovered the checkout via the **filesystem scan** in `collect_repo_info()` (any immediate subdir with a `.git` entry + origin remote) and `install_hooks()` installed trunk-protection `pre-commit`/`pre-push` into it.
3. Result: every wiki publish (commit + push) was blocked by the hooks. This is structurally unsatisfiable — GitHub/GitBucket wikis render only from the default branch and have **no branch/PR mechanism**; the wiki-operations card defines pre-push diff review + rule-based checks as the review substitute, by design.
4. Proof points: hook files hash-identical to `.opencode/hooks/` sources across parent repo and wiki checkout (`md5sum` match); hook mtimes are inherited source mtimes (copy2), not install times; session-init inventory output policed the wiki (`hermes-admin.wiki: pre-commit ok; pre-push ok`); reflog shows clone→blocked-commit sequence same morning.

### Root cause

`collect_repo_info()` + `collect_hook_inventory()` in `.opencode/tools/session-init` use a **path-shape heuristic** ("immediate subdir with `.git` + origin remote") where **git's own registered-submodule mechanism** is the authoritative answer to "which child repos does this workspace orchestrate." Filesystem shape ≠ orchestration intent: ignored sub-repos (wikis, independent repos like `.opencode/` itself in other workspaces, worktrees) all match the heuristic.

Registration alone does not exclude wikis: the wiki-operations card's provisioning reference documents inherited submodule wikis — existing `.gitmodules` entries wiring a wiki, operated in place. A wiki-origin registered submodule under strict registration-based discovery would be hooked and inventoried like any other submodule, reproducing this failure. The wiki rule is therefore origin-based, not wiring-based: a child repo whose origin matches `*.wiki.git` is a wiki repo whether it is an ignored sub-repo or a registered submodule.

### Required fix

1. **Strict discovery (coverage set)**: `collect_repo_info()` enumerates child repos exclusively via git's registered-submodule mechanism — each repo's `.gitmodules` entries verified with `git submodule status`, applied recursively into each registered submodule (submodules of submodules stay covered, as they are today). Registered entries without a checkout present (uninitialized submodules — today they produce no inventory line) are skipped: not hooked, not inventoried. The `os.listdir` `.git`-entry scan is deleted from discovery, not feature-flagged.
2. **Wiki exclusion (origin-based, every level)**: hook installation and inventory cover the root repo and every registered submodule with a checkout, excluding every child repo whose wiki identity matches at every level: an origin URL — or, for a registered submodule, the URL recorded in `.gitmodules` (authoritative even before checkout) — whose final path segment ends in `.wiki` or `.wiki.git`. Wiki repos are never hooked and never inventoried, whether wired as ignored sub-repos or registered submodules (the wiki-operations card documents inherited submodule wikis, so registration alone does not exclude them). Ignored sub-repos receive nothing, appear nowhere.
3. **Cleanup enumeration (cleanup only)**: locating pollution uses a bounded filesystem enumeration mirroring the old scan's traversal exactly: every immediate child dir with a `.git` entry — pollution-tested when it has an origin remote (the only ones the old installer reached) and descended into regardless of origin — and every depth-2 dir with a `.git` entry and an origin remote inside them (the old nested recursion required no origin on the container). It is used solely to find repos outside the coverage set for pollution removal; it installs nothing and inventories nothing. The old installer never reached anything else, so this bound is complete for cleanup.
4. **Self-healing**: in the hooks dirs of enumerated repos outside the coverage set, session-init pollution is removed and reported: a file whose name matches any hook name the `.opencode/hooks/` source directory has ever carried (the current source hook set or any name in its git history — the filesystem-scan-era installer copied every file present, and the source set also included `post-commit`, `pre-merge-commit`, and `prepare-commit-msg` until 2026-10-04), and whose content matches any blob hash ever recorded in the deck's git history at that hook name's source path under `.opencode/hooks/` (prior installs pin the source content at install time, and both the name set and the source content drift). Classification is by the resolved hooks dir (`git rev-parse --git-path hooks`): cleanup never acts on a hooks dir that resolves to a coverage-set repo's hooks dir — linked worktrees (`.issues/`, `.opencode/.issues/`) alias the root/submodule common hooks dir and must dedupe out of cleanup scope exactly as they dedupe out of double-install today. Removals are reported as removal events in session-init's output; the affected repos themselves still appear nowhere in inventory (item 2). Samples and files matching no historical source name-plus-version — foreign hooks — are untouched.
5. **Regression invariant**: root / registered non-wiki submodules at every depth / `.issues/` carve-outs behave exactly as today.

---
*🤖 OpenCode (ollama-cloud/glm-5.3-flash) — filed from hermes-admin session per developer directive*
