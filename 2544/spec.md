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

1. **Strict discovery**: `collect_repo_info()` enumerates child repos exclusively via `git config --file .gitmodules` + `git submodule status` verification; the `os.listdir` `.git`-entry scan is deleted, not feature-flagged.
2. **Hooks + inventory cover root repo + registered submodules, minus wikis**: hook installation and inventory cover the root repo and registered submodules, excluding every child repo whose origin matches `*.wiki.git` — wiki repos are never hooked and never inventoried, whether wired as ignored sub-repos or registered submodules. Ignored sub-repos receive nothing, appear nowhere.
3. **Self-healing**: in the hooks dirs of repos outside the coverage set — non-registered repos and wiki-origin repos (registered or not) — session-init pollution is removed and reported: a file named for the source hook set (`pre-commit`, `pre-push`) whose content matches **any version the corresponding `.opencode/hooks/` source has ever had** — the current source hash or any historical blob hash of that source path in the deck's git history (prior installs pin the source content at install time, and the sources drift). Removals are reported as removal events in session-init's output; the affected repos themselves still appear nowhere in inventory (item 2). Samples and files matching no source version — foreign hooks — are untouched.
4. Regression invariant: root / registered non-wiki submodules / `.issues/` carve-outs behave exactly as today.

---
*🤖 OpenCode (ollama-cloud/glm-5.3-flash) — filed from hermes-admin session per developer directive*
