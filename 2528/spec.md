# Remove Bespoke md Tool — Spec

## Problem Statement

`.opencode/tools/md` (dispatcher: `read`/`write`/`add`/`delete`/`new` section operations)
and its impl helpers (`.opencode/tools/impl/md-add`, `md-delete`, `md-new`, `md-read`,
`md-write`) are a bespoke section-oriented markdown editor duplicating capability the
agent already has through generic file-editing tools.

A removal of this tool was directed at an earlier point but never landed: no removal
commit exists anywhere in the current `.opencode` lineage (verified 2026-10-06 by history
sweep including `--diff-filter=D`), and session-init still advertises the tool in its
agent-tools inventory — drift between direction and trunk.

Developer direction 2026-10-06: a spec to remove the md tool is in order.

## Scope

### In Scope

- Remove `.opencode/tools/md` and `.opencode/tools/impl/md-{add,delete,new,read,write}`.
- Remediate any dangling agent-facing references to the tool (skills/, guidelines/,
  AGENTS.md files, other tools' cross-references) — via the reference-integrity check
  plus a content sweep.
- session-init's agent-tools inventory no longer lists `md`.

### Out of Scope

- Replacement tooling of any kind — generic file-editing tools suffice.
- Changes to any other tool.

## Success Criteria

- [ ] **SC-1 (structural):** `.opencode/tools/md` and the five `impl/md-*` helpers no
  longer exist. Verification: file-absence check.
- [ ] **SC-2 (structural):** No dangling references to `tools/md` or the `md-*` impl
  helpers remain in agent-facing surfaces. Verification: reference-integrity check +
  content sweep + session-init output inspection.

## References

- Related: `.opencode/.issues/169/` — the wiki-operations card set out-of-scopes
  dependence on this tool

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
