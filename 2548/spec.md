# SPEC: `.issues/` worktree-store operational friction

Date: 2026-10-07 · Scope: current-state defects INSIDE the settled worktree-based
issue-store architecture (`.issues/`, `.opencode/.issues/`, both on orphan branch
`issues-data`, managed by `.opencode/tools/local-issues`). Architecture itself is
out of scope.

---

## Why

### F1 — Every `sync`/`init` mints an empty commit on `issues-data` (history pollution)

`.opencode/tools/local-issues:1717-1735` (`_fetch_issues_branch`, used by
`_sync_repo` for both `sync` and `init`) runs `git add -A` then
`git commit --allow-empty -m "auto: sync"` **unconditionally** — `--allow-empty`
creates a commit even when nothing changed (contrast `_stage_issues_changes`,
lines 931-950, which correctly returns early when `git status --porcelain` is
empty; the mutation path does not have this defect).

Live evidence:

```
$ git -C .issues log --oneline -15        # 15 consecutive "auto: sync"
60d9ba73 auto: sync
e74c854c auto: sync
...
$ tree-comparison over last 60 parented commits: empty=47 of 60
$ git -C .issues rev-list --count HEAD    → 1060
$ git -C .opencode/.issues rev-list --count HEAD → 2438
```

47 of the last 60 commits in the root store carry no change. Consequences:
meaningless history noise, an outbound push on every sync even when idle
(extra network round-trips per repo per invocation), and more divergence
surface for F2 to bite on. Store totals (1060 / 2438 commits) are inflated
mostly by this pattern.

### F2 — Transient push failures leave silent local-ahead divergence; no retry, no exit-code signal

Mutation path: `_auto_commit` (local-issues:1001-1020) stages, commits, then
`_push_issues_changes` (969-998) pushes once; on failure it only prints
`warn: push issues branch failed: <stderr>` and returns — the commit remains
local, nothing retries or reconciles, and the command still exits 0. Sync
path: `_push_issues_branch_safe` (1757-1769) returns `{"status":
"push_failed", ...}` which `_sync_repo` (1790-1792) embeds in the YAML — but
`cmd_sync` (1812-1817) and `cmd_init` (1800-1809) never set an exit code;
`main()` (2263-2296) falls through to exit 0 even when **every** repo reports
`push_failed`/`conflict`/`timeout`.

This matches the developer-observed transient from 2026-10-07: an `init` logged
`push_failed: Connection to github.com closed by remote host` on one repo and a
subsequent `sync` cleared it (doctor now reports `merge_base_delta=0/0` on both
stores). The failure mode is real and recoverable, but recovery depends entirely
on the agent noticing a stderr warn or a YAML status field — a shell-level check
(`local-issues sync && next-step`) sees success. For agents, a transient that
"looks like success" is a trust hazard: the next mutation auto-pushes against a
stale remote assumption, and a rejected non-fast-forward push (remote moved
ahead) surfaces the same way — mutations never pull-rebase before pushing.

### F3 — Conflict path can strand a mid-rebase worktree; the recovery hint re-runs the failing command

`_rebase_issues_branch` (local-issues:1738-1754) runs
`git -C <worktree> pull --rebase origin issues-data`; on failure it returns
`status: conflict` with `conflict_hint: "git -C <worktree> pull --rebase origin
issues-data"` — i.e., the same command that just failed. If the pull got as far
as starting a rebase and stopping on a conflict, the worktree is mid-rebase
(`rebase-merge` state); re-running `pull --rebase` then fails with "cannot
pull with rebase" / "already a rebase-merge directory", and the correct remedy
(`git rebase --abort` or resolve + `--continue`) is never suggested. The tool
has no rebase-state detection anywhere (grep for `rebase` in local-issues
yields only lines 1738-1754, 1787, 1813, 2109 — one call site, no state check),
and `_sync_repo`'s add/commit/push steps would run blindly against a
mid-rebase worktree on the next invocation.

Note: a live mid-rebase worktree was not reproduced during research (that
requires mutations, which the research scope prohibited); the code-path
analysis above is conclusive about the missing detection and the misleading
hint, but the exact behavior of a mutation commit issued during a rebase stop
is unverified.

### F4 — Bootstrap transient can mint a fresh empty orphan branch diverging from a real remote branch

`_create_issues_worktree` (local-issues:735-746): if the local `issues-data`
branch is absent, `_bootstrap_from_remote` (566-632) fetches
`origin/issues-data`; **a failed fetch (transient network) is indistinguishable
from "remote branch absent"** — both return False (warn at 588-594) — and the
caller falls through to `_create_orphan_branch` (525-563), which mints a brand
new empty orphan branch via plumbing. `_push_orphan_if_needed` (859-890) then
pushes it with `git push -u origin issues-data` (non-fast-forward rejected
against real remote history → stderr warn only, per F2's exit semantics).

Resulting state after a transient fetch failure on first establishment: local
`issues-data` exists with an empty tree, remote has the real history; every
later run sees `_issues_branch_exists` → True (738) and never re-attempts
bootstrap; the agent operates on a locally-empty store whose mutations can
never push (non-FF), with only stderr warns as signals. `_fail_worktree`
(749-764) exists precisely to fail-fatal here, but this ambiguity path bypasses
it.

### F5 — Legacy-format store content is live, contradicted by doctrine, and permanently muted

Current store state (all read-only observations):

```
$ ls -d .issues/open .opencode/.issues/open .opencode/.issues/closed
.issues/open  .opencode/.issues/open  .opencode/.issues/closed   # all exist
$ ls .issues/open | head     # full slug-format issue dirs inside
100-stacked-branch-for-pr  101-restore-frontmatter-triggers-...
$ ls -d .issues/[0-9]*-*/    # top-level slug dirs also present
1075-test-issue/ 1076-test-issue/ ... 1158-forbid-pre-existing-.../
$ git -C .issues log --oneline -2 -- .legacy-warned
b2921874 auto: create #opencode-config#3      # sentinel is COMMITTED to the branch
```

Three stacked defects:

1. **Split visibility.** `_parse_number` (local-issues:1486-1494) accepts
   `NNN-slug` dirs (int of the part before the first `-`), so `list`/`search`/
   `_count_issues` see them — but `_find_issue_dir` (191-200) matches **exact**
   `.issues/<N>` only, and `issue_exists`/`_check_duplicate_issue`
   (273-275, 1023-1036) build on it. Observable contradiction, same tool, same
   run:
   ```
   $ local-issues list | grep 1075
   opencode-config#1075 [open] Test Issue spec_path=      # advertised, empty spec_path
   $ local-issues read --number opencode-config#1075
   Issue #1075 not found. Recent issue numbers: #2161, #2127, ...
   ```
   Same for `.opencode#7` (dir `7-testissue`). Conversely, three slug dirs
   collide with existing flat dirs in the root store —
   `.issues/1158-forbid-.../` vs `.issues/1158/`, `.issues/4-spec-.../` vs
   `.issues/4/`, `.issues/9-spec-.../` vs `.issues/9/` — where the flat dir
   shadows the twin in list order (`sorted()` puts `1075` before
   `1075-test-issue`), and a future `create opencode-config#1075` would pass
   duplicate detection and mint a second dir parsing to 1075.
2. **Permanently silenced warning.** `_check_legacy_formats`
   (local-issues:2221-2260) fires "at most once" via a `.issues/.legacy-warned`
   sentinel — which `git add -A` sweeps into the branch (evidence: commits
   `b2921874`, `840ef044` touching it), so the warning fired once, ever, and is
   now muted in every clone and every future session while the legacy content
   it warned about is still present.
3. **Doctrine contradiction.** The canonical guide
   (`.opencode/.issues/AGENTS.md`, "Directory Layout") documents `open/` and
   `closed/` as part of the layout ("open/ — Symlinks or references to open
   issues"), while the tool classifies exactly those directories as legacy
   format (local-issues:2237-2240). An agent following the guide produces what
   the tool warns about — and the guide's hygiene mandate makes the agent
   responsible for repairing data the guide itself sanctions.

`open/`/`closed/` contents are also invisible to all tooling (list/search only
iterate the store's top level), so they are dead weight on the branch that
nothing enumerates.

Per the developer's decision of 2026-10-07, this content is defect material:
it is remediated (C5), never accommodated by tooling.

### F7 — No deck-side protection of `issues-data` from branch operations; branch list clutter raises the odds

`git branch -a` in the parent shows `+ issues-data` among ~9 feature branches
and a stale `master` (874c7ebc, an old commit; no `origin/master` exists);
`git worktree list` shows `.issues 60d9ba73 [issues-data]`. The only
protections today:

- **Solid:** the pre-commit hook carve-out (`.opencode/hooks/pre-commit`,
  lines 17-22): `if [ "$branch" = "issues-data" ]; then exit 0; fi` with the
  `.opencode#2512` rationale — store commits are never policed. The pre-push
  hook needs no carve-out (it blocks only trunk-ref pushes, so `issues-data`
  pushes pass by construction).
- **Missing:** `git-workflow-cleanup/SKILL.md` (28 lines) instructs "Delete the
  feature branch locally and on the remote" and never mentions `issues-data`;
  `git-workflow-branch/SKILL.md` and `git-workflow-pr/SKILL.md` contain zero
  occurrences of "issues"/"issues-data" (grep-verified). Nothing tells an agent
  scanning `git branch -a` that `+ issues-data` (the `+` = checked out in
  another worktree) is a reserved store ref and never a cleanup candidate.
  The stale `master` branch sitting in the same listing increases the odds an
  agent generalizes "delete stale branches" into the store branch.

The store-path reference gate in pre-commit (blocking tracked files that
reference `.issues/<digit>` paths) is **holding**: `git grep -nE
'\.issues/[0-9]'` over tracked files finds matches only under
`tests-v2/behaviors/fixtures/` — the gate's sanctioned exclusion.

### F8 — Nesting quirks with no documented explanation

- `git -C .opencode worktree list --porcelain` reports the submodule's main
  worktree path as `/home/muksihs/git/opencode-config/.git/modules/.opencode`
  (the gitdir — not a worktree at all), while `git -C .opencode rev-parse
  --show-toplevel` correctly returns `.opencode`. Observed output; any agent
  parsing `git worktree list` inside the submodule sees a bogus main-worktree
  row. No deck document mentions this.
- `git submodule status` shows `+b2f357f7...` (checked-out b2f357f7 vs
  recorded gitlink c6beaee; parent `git status --porcelain` shows
  ` M .opencode` accordingly). An agent can misread the `+` as "needs `git
  submodule update`", which would check out the recorded SHA in the module —
  disruptive to in-progress submodule work. The pointer-discipline rule
  (root AGENTS.md; `git-workflow-branch/SKILL.md` step 3) addresses pointer
  commits but not this misread.
- The canonical doctrine chain is store → store → deck: root
  `.issues/AGENTS.md` points to `.opencode/.issues/AGENTS.md` as "the
  canonical guide", which points back out to the tracked `issues` skill cards.
  Both store AGENTS.md files live **only on `issues-data` worktrees**
  (gitignored: `.issues/` in root `.gitignore`, `/.issues/` in
  `.opencode/.gitignore`) — in a fresh clone before `local-issues init`, the
  "canonical guide" is unreadable from the filesystem. The tracked skill card
  (`skills/issues/SKILL.md` + `references/`) already carries the operating
  contract, so the store-resident canonical layer adds a bootstrap-ordering
  dependency without adding content the deck lacks.

### F9 — Not-found hints are repo-blind (owned by `.opencode#2549`)

`cmd_read` (local-issues:1298-1300) calls `_not_found(number)` **without**
`repo_path`; `_recent_issue_numbers(None)` (1124-1135) then reads the
PROJECT_DIR root store. Observable: `read --number .opencode#7` lists
root-store numbers. The repair (repo-aware `_not_found` + remote fallback
hint) is change 1 of `.opencode#2549` and is not duplicated here.

### F10 — Areas probed and found already solid (absence of a problem is a finding)

- **Fail-fatal contract:** `_ensure_worktree` (767-804) + `_fail_worktree`
  (749-764) exit non-zero with the exact `git worktree add` remediation and
  never fall back to plain-file mode; `SystemExit` propagates through
  `_ensure_all_worktrees`'s `except Exception` (519-521), so `init` still dies
  on establishment failure. Matches the skill-card contract
  (`skills/issues/SKILL.md:50-51`).
- **Orphan creation is hook-free by construction:** `_create_orphan_branch`
  (525-563) uses `hash-object`/`commit-tree`/`update-ref` plumbing — no
  porcelain commit, so pre-commit contact is impossible, as documented
  (`skills/issues/references/sync-mirroring.md:16-21`).
- **Both stores healthy today:** `local-issues doctor` →
  `branch_state=HEALTHY merge_base_delta=0/0 worktree=active` for both repos;
  both worktrees on `issues-data...origin/issues-data`, clean.
- **Worktree naming documented accurately:** `.git/worktrees/-issues` exists
  (leading dash is git's auto-name from `.issues`); both AGENTS.md guides cite
  this path correctly.
- **Gitignore coverage:** `.issues/` ignored in root, `/.issues/` in
  `.opencode/.gitignore` — store worktrees never leak into parent `git status`.
- **Hooks installed for both repos:** `pre-commit`/`pre-push` present in
  `.git/hooks/` and `.git/modules/.opencode/hooks/`; session-init's hook
  inventory verified them `ok`.

(F6 — session-init presenting stores as repos — is likewise owned by
`.opencode#2549`, changes 2-3, which drop the store entries and add the
`issues:` field; the evidence there covers it.)

---

## What

Proposed changes, each scoped to evidence above. `local-issues` changes are
submodule (`.opencode`) changes and ride the submodule's PR process; skill-file
changes additionally follow deck governance. Session-init changes and the
repo-aware not-found repair live in `.opencode#2549` and are not repeated here.

- **C1 — Stop minting empty sync commits.** In `_fetch_issues_branch`
  (local-issues:1717-1735), skip the commit when `git status --porcelain` is
  empty (reuse the `_stage_issues_changes` check, 931-950). `sync`/`init` then
  commit only real changes.
- **C2 — Make push-failure visible at the shell and retry once.** In
  `_push_issues_changes` (969-998) and `_push_issues_branch_safe`
  (1757-1769): one bounded retry on transient-looking failures; and make
  `cmd_sync`/`cmd_init` exit non-zero when any repo's status is not `ok`
  (YAML status fields unchanged). Shell-level `sync && …` then can't sail
  past a divergence (F2).
- **C3 — Detect and report mid-rebase state.** Before `_rebase_issues_branch`
  runs (and in `_sync_repo`'s entry check), test for the worktree's
  `rebase-merge`/`rebase-apply` state dirs; if present, return
  `status: rebase_in_progress` with guidance `git -C <worktree> rebase
  --abort` (or resolve + `--continue`), replacing the current pull-again
  `conflict_hint` (1738-1754, 1787). Update the conflict guidance in
  `skills/issues/references/sync-mirroring.md` ("Sync cycle" bullet) to
  match.
- **C4 — Disambiguate bootstrap failure from remote-absent.** In
  `_bootstrap_from_remote` (566-632), distinguish "fetch failed" from "remote
  ref absent" (e.g., `git ls-remote origin issues-data`, or verify a cached
  `refs/remotes/origin/issues-data`): on fetch failure with a possibly
  existing remote branch, do **not** fall through to `_create_orphan_branch`;
  fail-fatal via `_fail_worktree` with remediation (retry when the network
  recovers). Only a verified absent remote branch proceeds to orphan creation
  (F4).
- **C5 — Remediate legacy store content and unmute the check.** (a) Per the
  existing hygiene mandate, flatten/remove from both stores: `open/`,
  `closed/`, and top-level `NNN-slug` dirs — preserving any content whose
  number has no flat twin (e.g. archive under a non-parseable name like
  `_legacy/…` or fold into the flat namespace), collision twins (`4`, `9`,
  `1158`) resolved by explicit content comparison before deletion. (b) Change
  `_check_legacy_formats` (2221-2260) to warn on **every** run without writing
  any sentinel into the tracked tree (drop the `.legacy-warned` mechanism; a
  stderr warn per invocation is cheap and self-healing). (c) Align the
  canonical guide's "Directory Layout" section (`.opencode/.issues/AGENTS.md`)
  with the tool's legacy classification — remove `open/`/`closed/` from the
  documented layout. (F5; developer decision 2026-10-07.)
- **C6 — Duplicate detection must honor `_parse_number` semantics.** In
  `_check_duplicate_issue` (1023-1036), refuse when any dir in the target
  store parses to the requested number, not only exact `{N}`; after C5's
  remediation this becomes a dormant safety net rather than a live hazard
  (F5).
- **C8 — Protect the store branch in deck guidance.** Add to
  `git-workflow-cleanup/SKILL.md` (step 2 area) and `git-workflow-branch/SKILL.md`
  (branch-scanning context): `issues-data` is a reserved orphan-branch store
  ref, checked out in a linked worktree (`+` marker in `git branch -a`); it is
  never a feature-branch cleanup candidate and never receives worktree
  removal. (F7. The stale `master` deletion itself is out of scope — see
  below — but the protection language is in scope.)
- **C10 — Documentation currency in deck references.** Fix
  `skills/issues/references/sync-mirroring.md`: describe `init` accurately
  (ensure worktrees + commit + pull-rebase + push, not "+ pull"). (The
  `{issues_prefix}` derivation line in the canonical guide is owned by
  `.opencode#2549` change 4, which makes it true once the `issues:` field is
  emitted.)
- **C11 — Document the nesting quirks.** In the canonical guide
  (`.opencode/.issues/AGENTS.md`) add a short "Git display quirks inside this
  workspace" note: (a) `git worktree list` inside `.opencode` shows the
  module gitdir as the main worktree row (verified output); (b) `git submodule
  status` `+` means checked-out-vs-recorded pointer drift, not a needed
  `git submodule update`; (c) the canonical guide itself lives on the
  `issues-data` worktree and is unreadable before `local-issues init` — the
  tracked `issues` skill card is the bootstrap-order-independent entry point.

---

## Success criteria

| ID | Criterion | Evidence type | Verification instrument |
|----|-----------|---------------|-------------------------|
| SC-1 | Running `local-issues sync` twice consecutively on an up-to-date store creates zero new commits on `issues-data` in both repos. | behavioral | In a sandbox copy: record `git -C .issues rev-list --count HEAD` and `git -C .opencode/.issues rev-list --count HEAD`; run `./.opencode/tools/local-issues sync` twice; both counts unchanged, and no new `auto: sync` commits in `git -C .issues log --oneline -3`. |
| SC-2 | `sync` exits 0 only when every repo reports `ok`; any `push_failed`/`conflict`/`timeout`/`rebase_in_progress` status produces a non-zero exit while still printing the per-repo YAML. | behavioral | Sandbox: temporarily point one store's origin at an unreachable URL, run `./.opencode/tools/local-issues sync; echo $?` → non-zero, YAML still contains `status: push_failed`; restore origin, re-run → exit 0. |
| SC-3 | A mid-rebase worktree is detected and reported as `rebase_in_progress` with abort/continue guidance; the tool never suggests re-running `pull --rebase` into an in-progress rebase. | behavioral | Sandbox store: start a `pull --rebase` that stops on a conflict (divergent test commits), then run `sync` → YAML contains `status: rebase_in_progress` and the hint names `git rebase --abort`/`--continue`, not `pull --rebase`. |
| SC-4 | When the local `issues-data` branch is absent and the remote branch's existence cannot be verified (fetch fails), worktree establishment fails fatally with the remediation message instead of creating a fresh orphan branch. | behavioral | Sandbox clone with network-blocked fetch and no local `issues-data`: run `local-issues init` → non-zero exit, stderr contains `failed to establish` remediation, and `git branch --list issues-data` in the sandbox is empty (no orphan minted). |
| SC-5 | Both stores contain no legacy-format content: no `open/`, no `closed/`, and no top-level directory matching `^[0-9]+-.+`; any preserved legacy content lives under a name `_parse_number` rejects. | structural | `ls -d .issues/open .issues/closed .opencode/.issues/open .opencode/.issues/closed` → all absent; `ls -d .issues/[0-9]*-* .opencode/.issues/[0-9]*-*` → no matches; `local-issues list` output contains no row with an empty `spec_path=` for an advertised issue. |
| SC-6 | The legacy-format check runs on every relevant invocation and writes no sentinel file into either store. | structural | `grep -n "legacy-warned" .opencode/tools/local-issues` → no sentinel write path remains (or only a removal/cleanup path); `git -C .issues ls-tree HEAD --name-only | grep legacy` → empty after the committed sentinel is removed during C5 remediation. |
| SC-7 | `list` and `read` agree: every issue number advertised by `list` resolves via `read --number <repo>#<N>` in the same tool run. | behavioral | Loop over `./.opencode/tools/local-issues list` rows in a sandbox; for each `repo#N`, run `read --number repo#N` → zero "not found" results. |
| SC-8 | `git-workflow-cleanup/SKILL.md` and `git-workflow-branch/SKILL.md` contain explicit `issues-data` protection language naming it a reserved store ref that is never a branch-deletion or worktree-removal candidate. | structural | `grep -n "issues-data" .opencode/skills/git-workflow-cleanup/SKILL.md .opencode/skills/git-workflow-branch/SKILL.md` → each file has ≥1 match whose context states the protection. |
| SC-9 | Deck references match tool behavior: `sync-mirroring.md` describes `init` as ensure-worktrees + commit + pull-rebase + push. | structural | `sed -n '/## Sync cycle/,/^- `/p' .opencode/skills/issues/references/sync-mirroring.md` → init description includes commit and push. |
| SC-10 | The canonical guide documents the observed nesting quirks: the submodule `git worktree list` gitdir-display behavior and the meaning of `+` in `git submodule status` / parent `git status`. | structural | `grep -n "worktree list\|submodule status" .opencode/.issues/AGENTS.md` → ≥1 match covering each quirk. |

---

## Out of scope

- **Replacing or re-shaping the worktree architecture** (peer clones, sibling
  stores, abolishing worktrees) — settled direction per the developer,
  2026-10-07; this spec operates strictly inside it.
- **Session-init Repo Information changes and the repo-aware not-found
  repair** — owned by `.opencode#2549` (changes 1-3).
- **Deleting the stale `master` branch or aged `feature/*` branches in the
  parent repo** — destructive branch hygiene requiring explicit developer
  authorization; only the protection language (C8) is in scope.
- **Remote tracker (GitHub) mirror content quality** — the remote-body exec
  summary convention is doctrine-settled; only doc references touch it
  (C10, `.opencode#2549` change 4).
- **`.opencode/.gitignore` cosmetic defects** (duplicated `/.issues/` line;
  self-referential `.opencode/` entry) — harmless, submodule hygiene noise.
- **Hook-inventory redundancy** (session-init reporting the same hooks dir
  under four paths) — cosmetic; resolved as a side effect of `.opencode#2549`'s
  store-entry drop at most.
- **`sync-file`'s github-only `file_url` construction** (local-issues:1901-1912)
  — platform-generality polish; both current repos are GitHub.
- **`lessons-learned` consumption workflow and store doctrine content** —
  governed by the canonical guide's own process, not by this friction spec.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
