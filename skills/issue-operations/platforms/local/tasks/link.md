<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->

<!-- SPDX-License-Identifier: MIT -->

<!-- Provenance: AI-generated -->

# Local Platform — Issue Link

## Overview

Link a local issue to another issue — remotely tracked GitHub issues, local child/parent issues, related references, or blocked-by relationships. Links are stored in `.issues/open/<N>/links.yaml` and managed via the `./.opencode/tools/local-issues` CLI.

**Primary tool:** `./.opencode/tools/local-issues`

**CLI:** `./.opencode/tools/local-issues link N --github GITHUB_NUM` or `--child N` or `--related N` or `--blocked-by N`

**Parameters:** `{ number: int, github?: int, child?: int, related?: int, blocked_by?: int }`
**Returns:** `{ number: int, links_updated: [string] }`

Per Card-020, link is a core local platform capability — without structured links, the issue graph is implicit and unmaintainable.

______________________________________________________________________

## Entry Criteria

- \[ \] Issue number N is known (positive integer)
- \[ \] `.issues/open/<N>/` or `.issues/closed/<N>/` directory exists
- \[ \] `./.opencode/tools/local-issues` CLI tool is available
- \[ \] At least one link target is specified (`github`, `child`, `related`, or `blocked_by`)
- \[ \] Child link target N must point to an existing local issue (open or closed)
- \[ \] GitHub link target is a positive integer (GitHub issue number)
- \[ \] Link is not already present in `links.yaml` (duplicate detection — warn but allow)
- \[ \] No circular parent-child relationship (child target cannot already have N as its parent)

______________________________________________________________________

## Procedure

| Step | Action                   | Command / Details                                                                                                                                                                |
| ---- | ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Read existing links      | `./.opencode/tools/local-issues read N --type links` — capture current `links.yaml` content                                                                                                        |
| 2    | Validate link targets    | For `--child T`: verify local issue T exists (`./.opencode/tools/local-issues read T`). For `--github T`: validate T > 0. For `--related T` and `--blocked-by T`: if T is local, verify existence. |
| 3    | Check for duplicates     | Compare each new link against existing links in `links.yaml`. Warn on duplicates but allow them (deduplication is the caller's responsibility).                                  |
| 4    | Check circular reference | For `--child T`: issue N's parent cannot be T. Verify by reading issue T's links. If circular, HALT.                                                                             |
| 5    | Run link CLI             | `./.opencode/tools/local-issues link N [--github N] [--child N] [--related N] [--blocked-by N]` — updates `links.yaml`                                                                             |
| 6    | Verify links             | `./.opencode/tools/local-issues read N --type links` — confirm all new link entries appear in YAML output                                                                                          |
| 7    | Report updated links     | Return `{ number: N, links_updated: [string] }` listing each link type + target                                                                                                  |

### Link Types and YAML Schema

Links are stored in `.issues/open/<N>/links.yaml`:

```yaml
parent:
children: []
related: []
blocked_by: []
github_links: []
```

After linking, the schema populates:

```yaml
parent:                         # Set by --child on the parent, not on the child
children:
  - number: 3                   # Local child issue number
    title: Child issue title
related:
  - number: 5
    title: Related issue title
  - url: https://github.com/owner/repo/issues/42
    number: 42
  - url: https://github.com/owner/repo/issues/99
    number: 99
blocked_by:
  - number: 7
    title: Blocking issue title
github_links:
  - url: https://github.com/owner/repo/issues/123
    number: 123
```

| Link Type     | CLI Flag           | Storage                                                         |
| ------------- | ------------------ | --------------------------------------------------------------- |
| GitHub issue  | `--github NUM`     | `github_links[]` — URL and number                               |
| Child issue   | `--child NUM`      | `children[]` — number and title                                 |
| Related issue | `--related NUM`    | `related[]` — number and title (local) or URL + number (remote) |
| Blocked by    | `--blocked-by NUM` | `blocked_by[]` — number and title                               |

### Circular Reference Detection

Before adding a `--child` link, the agent MUST verify that the proposed child is not already N's ancestor:

1. Read child target T's links (`./.opencode/tools/local-issues read T --type links`)
1. If T has `parent: { number: N }`, the link would create a cycle — HALT
1. If T already has record of N as a parent in `parent` field, the link would duplicate — warn but allow (caller may want explicit re-linking)

This prevents infinite traversal in the issue graph. The same check applies to `--blocked-by` links that would create a dependency loop.

### Child Link Is Asymmetric

Adding `--child T` to issue N records N as parent and T as child. The CLI updates BOTH files:

- N's `links.yaml` gets T in `children[]`
- T's `links.yaml` gets N in `parent` field

This ensures bidirectional navigation: reading N shows its children; reading T shows its parent. The agent MUST NOT need to call `link` on both sides — the CLI handles symmetry.

### GitHub Link Verification

For `--github GITHUB_NUM`, the CLI:

1. Constructs the remote URL from session-init values (`github.owner`, `github.repo`, `github.platform`)
1. Stores `{ url: string, number: int }` in `github_links[]`
1. Does NOT verify remote issue existence (remote API call is out of scope for a local-link operation)

______________________________________________________________________

## Exit Criteria

- \[ \] CLI tool returned exit code 0
- \[ \] `./.opencode/tools/local-issues read N --type links` shows all new link entries
- \[ \] For `--child T`: T's `links.yaml` has N as `parent`
- \[ \] `links_updated` array contains entries for each link type that was added
- \[ \] No duplicate links were created (or duplicates were explicitly warned)
- \[ \] Links.yaml is valid YAML with no corruption

______________________________________________________________________

## Error Handling

| Error                                | Cause                                                            | Resolution                                                                       |
| ------------------------------------ | ---------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `./.opencode/tools/local-issues link N` exits non-zero | CLI tool error — invalid args, YAML parse fail                   | HALT. Verify arguments. Check `links.yaml` format.                               |
| Issue N not found                    | `.issues/open/<N>/` does not exist                               | HALT. Verify issue number. Check closed directory.                               |
| Child target T not found             | `.issues/open/<T>/` does not exist                               | HALT. Report missing child target. Orchestrator must verify issue number.        |
| Circular reference detected          | Child T already has N as parent, or blocked-by link creates loop | HALT. Report the cycle. Orchestrator must resolve the parent-child relationship. |
| No link target specified             | No `--github`, `--child`, `--related`, or `--blocked-by` flag    | HALT. At least one link target is required.                                      |
| CLI tool not found                   | `./.opencode/tools/local-issues` missing                           | HALT. The tool must exist for local platform operations.                         |
| links.yaml corrupt                   | YAML parse failure during read                                   | HALT. Report corrupt state. Orchestrator must repair or delete `links.yaml`.     |
| Invalid GitHub number                | `--github 0` or negative                                         | HALT. GitHub issue numbers are positive integers.                                |

**General rule:** All errors must HALT and report the specific failure to the orchestrator. Never silently skip, fabricate link data, or inline YAML edits.

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
