# Plan Input Verification Ledger — Issue #2447

Verified once at plan-creation entry; all downstream steps read THIS file, not the sources.

## Issue state
- Issue: 2447 (`michael-conrad/.opencode#2447`, remote URL https://github.com/michael-conrad/.opencode/issues/2447)
- status: open
- labels (local issue.yaml, canonical): `approved-for-pr`, `needs-approval`, `spec-draft`
- issues_prefix: `.opencode/.issues`

## SC list (from spec.md, verified)
| SC | Criterion summary | Evidence type |
|----|-------------------|---------------|
| SC-1 | `collect_issue_artifact_paths()` emits no worktree-creation setup hint for repo entries whose `.issues` dir is absent | behavioral |
| SC-2 | Root-repo `.issues/` entry emission unchanged after hint removal | behavioral |
| SC-3 | `.opencode/AGENTS.md` states `.opencode` tickets filed via GitHub API against `michael-conrad/.opencode` | semantic |
| SC-4 | No `.opencode#N → .opencode/.issues/` local-issues routing mapping remains in `.opencode/AGENTS.md` | string |
| SC-5 | `.opencode/.issues/` worktree registration removed — ⛔ authorization-gated (critical-rules-052) | structural |

## Structure artifact mappings (verified)
- Phase 1 "session-init hint removal" — SC-1, SC-2
- Phase 2 "AGENTS.md routing rewrite" — SC-3, SC-4
- Phase 3 "worktree deregistration (authorization-gated)" — SC-5
- DAG: 1→2, 2→3 (linear; no cycles)

## CLI surface flags needed
- `./.opencode/tools/local-issues update .opencode#2447 --labels <full-label-array>` — replaces entire labels array; must include all existing labels plus `spec-cleared`
- Existing labels to preserve: `approved-for-pr`, `needs-approval`, `spec-draft`

## Key delivery constraint (from spec Key Design Decisions)
- Fix delivery is a PR against `michael-conrad/.opencode`; defective files live inside the read-only `.opencode/` tree. SC-5 destructive step HALTs until explicit developer authorization beyond `approved-for-pr`.
