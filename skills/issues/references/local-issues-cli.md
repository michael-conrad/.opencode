<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2543 -->

# local-issues CLI reference

`./.opencode/tools/local-issues <command> [flags]` — the script's `--help`
remains the flag-level source of truth. All numbers use the qualified
`repo#N` form; bare numbers are rejected with the available-qualifier list.

## Commands

| Command | Flags | Behavior |
|---|---|---|
| `init` | — | Bootstrap `issues-data` worktrees in all repos (root + `.gitmodules` children); pull remote `issues-data` where present |
| `sync` | — | Per repo: commit pending, pull-rebase, push. Reports per-repo status (`ok`, `no_worktree`, `no_remote`, `conflict`, …) |
| `sync-file` | `--file`, `--message` | Commit + push one file into the correct repo's issues worktree; prints status/commit SHA/file URL |
| `create` | `--number repo#N` (required), `--title`, `--labels` | Registers the local `{N}/` folder after the remote-first reservation; duplicate in the target repo exits 1; uniqueness is per-repo only |
| `read` | `--number`, `--type full\|comments\|labels\|links\|all` | Read an issue as YAML |
| `read-comments` / `read-labels` / `read-sub-issues` | `--number` | Read one record kind |
| `update` | `--number`, `--title`, `--status`, `--phase`, `--labels`, `--body-file`, `--github`, `--remote-url` | Update metadata/body; writes `github_url` / `remote_url` |
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

## Store semantics

- Numbers are per-repo: `michael-conrad/.opencode#2543` and
  `opencode-config#2543` are distinct issues; the qualified form disambiguates.
- Issue directories are `{N}/` holding `issue.yaml`, `comments.yaml`,
  `links.yaml`, `spec.md`, plus artifact subdirectories.
- YAML validation taxonomy: `malformed-frontmatter`, `invalid-yaml`,
  `schema-violation` — canonical three files get schema checks, other YAML in
  the directory tree is parse-validated.
