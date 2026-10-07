# SPEC: local-first resolution of qualified issue references (`repo#N` → local `.issues/` artifacts)

## Why

Issue references in this workspace use the qualified `repo#N` form (e.g.
`.opencode#2543`, `opencode-config#373`). Authoritative issue data lives in
local `.issues/` stores — orphan-branch `issues-data` worktrees (root
`AGENTS.md:25-31`, `.opencode/skills/issues/references/sync-mirroring.md:9-12`)
— and the local-first mandate is explicit: "AI agents MUST read from
`.issues/` — never treat the remote issue body as authoritative"
(`.opencode/.issues/AGENTS.md:102`) and "When reading or acting on an issue,
always read from `.issues/{N}/` first" (`:105`).

What already works (verified):

- `local-issues read --number repo#N` emits a `spec_path` field — a direct
  reference-to-local-path mapping (emission at `local-issues:1264-1271`, path
  computation `:1253-1261`).
- `search` and `list` print one-line results carrying the qualified number and
  the local path (`local-issues:1524`, `1530-1531`, `1583`, `1594-1595`).
- Bare numbers are rejected with a self-teaching qualifier list including each
  store's absolute root (`local-issues:1146-1157`, `1553-1560`).
- `session-init` emits, every session, a `## Repo Information` table and a
  `## Local Issue Folders` section (`session-init:631-635`, `655-665`).

Where it still fails or creates friction:

1. **Not-found errors misdirect across stores and give no remote fallback.**
   `cmd_read` calls `_not_found(number)` without the resolved repo path
   (`local-issues:1298-1300`), so `_recent_issue_numbers` reads the *current*
   repo's store (`:1124-1135`): querying `.opencode#999999` lists recents
   `#2161, #2127, #1969, #1714, #1713` from the root `opencode-config` store
   (observed). The error never suggests `url --number repo#N`, the correct
   fallback for a remote-known/locally-unsynced reference — `cmd_url` needs no
   local record (`local-issues:1699-1714`).
2. **The always-injected surface never states the
   `repo#N → {path}/.issues/{N}/` mapping, and the store guide's derivation
   rule is dead doctrine.** Local Issue Folders lines are git-command hints
   only (`session-init:559`); the `{N}/` layout fact exists only in
   skill-gated docs. Worse, the canonical guide's rule for the remote-body
   pointer references a field that does not exist: "The `{issues_prefix}` is
   the repo entry's `issues:` field" (`.opencode/.issues/AGENTS.md:122`) — but
   repo entries emit only `path/owner/repo/platform/url` (+optional
   `fork_of`) (`session-init:657-665`). Observed consequence: remote bodies
   are inconsistent — `.opencode#2466` carries no local-store pointer at all,
   while `.opencode#2543` hardcodes its prefix.
3. **Session-init presents the stores as repos in `## Repo Information`.**
   `collect_repo_info` adds any directory with a `.git` entry and an origin
   remote (`session-init:149-241`; nested-scan comment `:208` "Catches nested
   worktrees like .opencode/.issues/"), so both stores appear as repo entries
   duplicating their parent's identity — while `collect_issue_artifact_paths`
   skips the same entries as "the issue store, not repos" (`:549-552`). The
   two functions disagree about what `.issues` is; the store entries are
   routing duplicates (identical owner/repo/platform/url as the parent entry,
   which already prefix-matches `.issues/...` paths) and no in-repo consumer
   needs them.
4. **Local Issue Folders emits `git -C` pointers unconditionally.** The
   docstring claims "No setup hint is emitted for repo entries whose
   `.issues/` directory does not exist" (`session-init:542-543`), but the code
   (`:547-560`) appends without checking — a fresh clone gets pointers to
   stores that do not exist yet.
5. **The tool's always-visible description does not advertise resolution.**
   `DESCRIPTION: Local issue tracking CLI tool for .issues/ directory.`
   (`local-issues:18`) is what every session sees in `## Agent Tools` (built
   by `tools/help` — description extraction at `help:43-51`; embedded by
   `session-init:564-582`, `671-674`).
6. **The routing index does not match read/resolution intent.**
   `routing.md:24` routes "creating, commenting, linking, or closing issues"
   to the `issues` skill — reading/resolving is absent from the row, though
   the skill description covers it (`.opencode/skills/issues/SKILL.md:3`).

Note on slug/legacy store directories (`{N}-{slug}/`, `open/`, `closed/`):
their unresolvability under the current exact-match helpers is real
(`local-issues:191-209` vs `_parse_number:1486-1494`), but per the developer's
decision of 2026-10-07 such content is defect material to be **remediated**,
never accommodated — that remediation is owned by `.opencode#2548` (C5/SC-5).
This spec assumes the bare-`{N}/` layout post-remediation and adds the
duplicate-guard safety net by cross-reference.

## What

1. **Repo-aware not-found error with remote fallback hint.**
   `local-issues` — `cmd_read`/`cmd_read_comments`/`cmd_read_labels`/
   `cmd_read_sub_issues` pass the resolved repo path into `_not_found`
   (`:1285-1291`, call sites `:1298-1300`) so recents come from the queried
   store; when the repo has an origin remote, append one line:
   `Local record absent — remote mirror may know this number: local-issues url --number {repo}#{N}`.
2. **session-init `## Repo Information`: real repos only, each carrying the
   store path.** In `collect_repo_info` (`:149-241`), skip entries whose path
   is `.issues` or ends in `/.issues` (reuse the exact skip predicate already
   written in `collect_issue_artifact_paths`, `:549-552`); for each remaining
   repo entry emit `  issues: {path}/.issues/`. Stores are then represented
   only by the `## Local Issue Folders` section.
3. **Local Issue Folders: artifact-rule line + honest existence check.** Add
   one vocabulary line stating that local artifacts for a qualified reference
   `repo#N` live at that repo's `issues:` path under `{N}/`; fix the
   docstring/code drift by actually checking store existence and emitting a
   setup hint naming `local-issues init` when a store is absent
   (`:542-561`).
4. **Store guide: make the `{issues_prefix}` derivation true.** Reword
   `.opencode/.issues/AGENTS.md:122` minimally so the derivation names the
   now-emitted `issues:` field exactly, keeping the never-hardcode mandate.
   Issue-data hygiene territory, not source code. (The alternative of
   rewording the guide onto `url --artifacts` was rejected: the blockquote
   pattern needs the local store prefix, which only the field supplies.)
5. **Discoverability: DESCRIPTION line.** `local-issues:18` becomes e.g.
   `Local issue tracking CLI for .issues/ stores; resolves qualified repo#N
   references to local artifacts.` (surfaces in every session via `help` →
   `## Agent Tools`).
6. **Routing row.** `routing.md:24` issues row extends to "creating,
   reading/resolving, commenting, linking, or closing issues".
   Deck-governance-gated (floor.md deck-governance line); rides the deck's
   governance process, unlike changes 1-5.

Dropped by developer decision (2026-10-07): the `locate` subcommand idea
(`read`/`list`/`search` already emit `spec_path=`) and `read --type path`
(full-record `read` already carries the field; polish, not defect repair).

## Success criteria

| ID | Criterion | Evidence type | Verification instrument |
|---|---|---|---|
| SC-1 | A qualified not-found error cites recents from the queried repo's store and includes the remote-fallback `url` hint | behavioral | Run `./.opencode/tools/local-issues read --number .opencode#999999` from project root; assert exit 1, the listed recents all appear in `.opencode/.issues/` directory names, and output contains `url --number .opencode#999999` (currently lists root-store numbers `#2161, #2127, ...` with no hint) |
| SC-2 | `## Repo Information` contains no entry whose path is `.issues` or ends in `/.issues`; each remaining repo entry carries `issues: {path}/.issues/` | behavioral | Run `./.opencode/tools/session-init`; assert `grep -E '^- path: (.*\/)?\.issues$'` over the output has no matches, an `issues:` line follows the `path: .` and `path: .opencode` entries with values `.issues/` and `.opencode/.issues/` |
| SC-3 | `## Local Issue Folders` states the per-issue artifact rule linking qualified references to `{N}/` under each store | behavioral | Run `./.opencode/tools/session-init` and grep stdout for `.issues/{N}/` co-occurring with qualifier vocabulary (`repo#N` or `qualified`); assert ≥1 match |
| SC-4 | In a workspace where a store directory does not exist, Local Issue Folders includes a setup hint naming `local-issues init` instead of a bare `git -C` pointer | behavioral | Sandbox clone without `.issues/`: run session-init → output under `## Local Issue Folders` mentions `local-issues init` |
| SC-5 | The store guide's `{issues_prefix}` derivation sentence is true against current session-init output (references only fields session-init emits) | structural | Grep `.opencode/.issues/AGENTS.md` for `issues_prefix`; for every field the sentence names, confirm `./.opencode/tools/session-init` output emits that field on repo entries |
| SC-6 | The local-issues DESCRIPTION line advertises qualified-reference resolution | structural | `grep -n "DESCRIPTION:" .opencode/tools/local-issues` returns a line containing both `.issues/` and `repo#N` |
| SC-7 | The routing index routes read/resolution intent to the `issues` skill | structural | Grep `.opencode/routing.md` issues row for `reading` (or `resolving`); assert present |
| SC-8 | No regression on existing resolution surfaces | behavioral | Run, from project root: `./.opencode/tools/local-issues read --number .opencode#2466 --type full` (exit 0, `spec_path: .opencode/.issues/2466`); `./.opencode/tools/local-issues read --number 2466` (exit 1, qualifier list present); `./.opencode/tools/local-issues url --number .opencode#2466 --artifacts` (prints `https://github.com/michael-conrad/.opencode/tree/issues-data/2466/`) — all must match current observed behavior |

## Out of scope

- **Slug/legacy store content remediation** (`{N}-{slug}/`, `open/`,
  `closed/`, committed `.legacy-warned` sentinel) — owned by `.opencode#2548`
  (C5), per the developer's 2026-10-07 decision.
- **Remote-body authoring compliance for past issues** — `.opencode#2466`'s
  body lacks the mandated blockquote pointer while `.opencode#2543`'s follows
  it; fixing past bodies is content remediation, and the local-first contract
  already declares the remote body non-authoritative
  (`.opencode/.issues/AGENTS.md:102`). Change 4 makes future bodies derivable.
- **Qualifier = directory basename, not remote repo name**
  (`_resolve_repo_name` returns `PROJECT_DIR.name`, `local-issues:1549-1550`;
  `_resolve_repo_path` matches `child.name`, `:1160-1173`) — diverges only if
  a submodule is checked out under a foreign folder name; no such case exists
  in this workspace (`cat .gitmodules`: path `.opencode`).
- **Stray files in store roots** (`.opencode/.issues/test-untracked.md`) —
  store hygiene, `.opencode#2548` territory.
- **`web-search-mcp.py` missing DESCRIPTION** (shows "(no description
  available)" in `## Agent Tools`) — unrelated tooling polish.
- **Cross-store duplicate numbers** (e.g. `1124` existing in both stores) —
  by design per-repo namespaces (`local-issues-cli.md:35-36`); disambiguated
  by the qualified form.
- **Lessons-learned consumption workflow** (`.opencode/.issues/AGENTS.md:139-157`)
  — separate mandate, no bearing on reference resolution.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
