<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2543; local-only boundary statement, .opencode#2382 -->

# local-issues CLI reference

`./.opencode/tools/local-issues <command> [flags]` — the script's `--help`
remains the flag-level source of truth. All numbers use the qualified
`repo#N` form; bare numbers are rejected with the available-qualifier list.

## Commands

| Command | Flags | Behavior |
|---|---|---|
| `init` | — | Bootstrap `issues-data` worktrees in all store-holding repos (root + its registered submodules per `git submodule status`); pull remote `issues-data` where present. A repository classified pull-only (effective `http`/`https` origin) is excluded — it receives no store, no fetch, and no push (#2667) |
| `sync` | — | Per repo: commit pending, pull-rebase, push. Reports per-repo status (`ok`, `no_worktree`, `no_remote`, `conflict`, …) |
| `sync-file` | `--file`, `--message` | Commit + push one file into the correct repo's issues worktree; prints status/commit SHA/file URL |
| `create` | `--number repo#N` (required), `--title`, `--labels` | Registers the local `{N}/` folder after the remote-first reservation; duplicate in the target repo exits 1; uniqueness is per-repo only |
| `read` | `--number`, `--type full\|comments\|labels\|links\|all` | Read an issue as YAML |
| `read-comments` / `read-labels` / `read-sub-issues` | `--number` | Read one record kind |
| `update` | `--number`, `--title`, `--status`, `--phase`, `--labels`, `--body-file`, `--github`, `--remote-url` | Update metadata/body **in the local store only** — `--github`/`--remote-url` write the local `github_url` / `remote_url` metadata fields and never contact any remote issues-system API on any platform; remote issue-body edits go through the platform-appropriate card (gh-cli / gb-cli) |
| `comment` | `--number`, `--type internal\|stakeholder`, `--body` | Append a comment (short text only) |
| `close` | `--number`, `--reason completed\|not_planned\|duplicate`, `--duplicate-of` | Close with reason |
| `delete` | `--number`, `--force` | Delete an issue directory; blocked when links exist without `--force` |
| `search` | `--query` | Search all repos' stores |
| `list` | — | List all issues across repos |
| `link` | `--number`, `--sub N ...`, `--type` | Link sub-issues to a parent |
| `renumber` | `--from repo#N`, `--to repo#M` | Rename the directory; rewrites matching links |
| `url` | `--number repo#N`, `--artifacts` | Emit the platform-correct issue URL; `--artifacts` emits the branch-root artifacts URL (`tree/issues-data/N/`) |
| `doctor` | — | Per-repo health markers (read-only): branch state, merge-base delta, worktree presence |
| `validate-yaml` | `--number` (optional) | Validate YAML across issue directories; `**/*.yaml` subtree sweep; scoped mode on a remote-only issue prints `no-local-records` and exits 0 |

### Host→browser-base mapping (`url`)

`url` derives the https browser base from the repo's `origin` remote. When the
web face is not derivable from the remote URL — the ssh host differs from the
web host, or the URL carries a non-standard port — a committed mapping table
ships beside the tool at `.opencode/tools/local-issues-host-maps.conf`:
`hostname[:port] = https://browser-base` per line. Matching is on the hostname
only and is scheme-independent — every origin form (ssh://, git+ssh://,
scp-form, https) carrying a mapped hostname resolves to the mapped base. Hosts
with no entry convert to same-host `https://host/owner/repo`; a malformed
config line is warn-and-skipped on stderr (the tool's warn-and-skip taxonomy)
and never crashes the command. Family platforms add their entry to that file —
the file ships with the deck to every mount.

## Store semantics

- Numbers are per-repo: `michael-conrad/.opencode#2543` and
  `opencode-config#2543` are distinct issues; the qualified form disambiguates.
- Issue directories are `{N}/` holding `issue.yaml`, `comments.yaml`,
  `links.yaml`, `spec.md`, plus artifact subdirectories.
- YAML validation taxonomy: `malformed-frontmatter`, `invalid-yaml`,
  `schema-violation` — canonical three files get schema checks, other YAML in
  the directory tree is parse-validated.
