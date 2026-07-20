> **Full spec and artifacts: `.opencode/.issues/169/`**

## Exec Summary

Agents cannot edit wiki pages on GitBucket and GitHub repositories because no skill or tool understands `.wiki.git` repos as editable markdown wikis. Wikis are stored as plain git repos of markdown files with layout conventions (`Home.md`, `_Sidebar.md`, `_Footer.md`) that require format-aware handling — generic file ops don't understand wiki semantics like double-bracket internal links (`[[Page Name]]`).

### Cards (dependency order)
1. **Detect wiki availability on GitHub and GitBucket repos**
2. **Read, create, update, delete wiki pages via git clone-modify-push workflow**
3. **Maintain sidebar navigation structure (parse/generate `[[...]]` wiki-links in `_Sidebar.md`)**
4. **Format neutrality: default to `.md` but respect existing file formats per-page**

### Key Decisions
- **Platform-agnostic skill with local git backend** — `local/SKILL.md` handles `.wiki.git` git workflow directly; `remote/SKILL.md` provides API fallback for platforms without `.wiki.git` repos
- **Three-phase implementation** — Detection/Read (High priority), Write (Medium), Advanced (Low)

### Risk Callouts
- **Platform compatibility** — wiki format support varies between GitHub and GitBucket (`.md` vs `.textile` vs `.markdown`)
- **Sidebar structure preservation** — write operations must update `_Sidebar.md` correctly to maintain navigation

## AI Agent Instructions

This issue is an executive summary for human stakeholders.
The authoritative spec and plan artifacts are at `.opencode/.issues/169/`.
After creation, `local-issues sync 169` MUST be run and the result committed to create the local `.issues/169/` entry.
The implementation plan will be created in `.issues/169/plan.md` after approval.
AI agents MUST read the local spec/plan files for implementation
and MUST NOT base implementation on this summary.

---
*Migrated from local tracking. Original local directory: `.opencode/.issues/169/`*