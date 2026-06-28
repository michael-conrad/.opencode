# Wiki Operations Support — Spec

## Problem Statement

Agents cannot edit wiki pages on GitBucket and GitHub repositories because no skill or tool understands `.wiki.git` repos as editable markdown wikis. Wikis are stored as plain git repos of markdown files with layout conventions (`Home.md`, `_Sidebar.md`, `_Footer.md`) that require format-aware handling — generic file ops don't understand wiki semantics like double-bracket internal links (`[[Page Name]]`).

## Scope

### In Scope
- Detect wiki availability on GitHub and GitBucket repos
- Read, create, update, delete wiki pages via git clone-modify-push workflow
- Maintain sidebar navigation structure (parse/generate `[[...]]` wiki-links in `_Sidebar.md`)
- Format neutrality: default to `.md` but respect existing file formats per-page

### Out of Scope
- API-based wiki operations for platforms that expose HTTP endpoints (future extension point)
- Migration of non-git wikis to git-backed format
- Multi-wiki synchronization or cross-repo wiki management

## Architecture Decision: Platform-Agnostic Skill with Local Git Backend

**Decision:** Implement `wiki-operations` skill using the existing MCP server pattern with two platform implementations:

```
.opencode/skills/wiki-operations/
├── SKILL.md                          # Platform-agnostic operations (unchanged from spec)
└── platforms/
    ├── local/SKILL.md                # git clone → modify markdown files → commit → push
    └── remote/SKILL.md               # API fallback for platforms without .wiki repos
```

**Rationale:** `local/SKILL.md` handles the `.wiki.git` git workflow directly — no external dependency needed since it's just standard git + markdown ops on known file conventions. `remote/SKILL.md` provides API-based wiki access for platforms that expose HTTP endpoints but don't have a public `.wiki.git` repo (future-proofing). The MCP server exposes the same tools regardless of backend, so agents call `wiki-list`, `wiki-get`, etc. without knowing which platform they're on.

## Success Criteria

- [ ] **SC-1:** `wiki-check` detects wiki availability via git probe (`git ls-remote --exit-code <repo>.wiki.git HEAD`) with API heuristic fallback
- [ ] **SC-2:** `wiki-list` returns list of pages by parsing `_Sidebar.md` for `[[...]]` links (not just glob files) — preserves sidebar navigation structure
- [ ] **SC-3:** `wiki-get` retrieves page content respecting existing file format per-page (`.md`, `.markdown`, `.textile`, etc.)
- [ ] **SC-4:** `wiki-create` creates new pages with auto-detected layout conventions (`Home.md` if no Home exists, `_Sidebar.md` entry if sidebar present)
- [ ] **SC-5:** `wiki-update` modifies existing pages and updates `_Sidebar.md` to append new entries when appropriate
- [ ] **SC-6:** `wiki-delete` removes wiki page and cleans up `_Sidebar.md` references
- [ ] **SC-7:** `wiki-clone` clones wiki repo for manual editing workflow
- [ ] **SC-8:** All commands support auth options (token, SSH, basic)
- [ ] **SC-9:** Documentation added to skill manifest
- [ ] **SC-10:** Integration tests for wiki operations

## Implementation Plan

### Phase 1: Detection & Read Operations (Priority: High)
- Add `_wiki_repo_url()` helper that detects `.wiki.git` availability via git probe
- Add `wiki_check()` detection with API heuristic fallback
- Add `wiki_list_pages()` method — parses `_Sidebar.md` for `[[...]]` wiki-links to build page tree, falls back to directory glob if no sidebar
- Add `wiki_get_page()` method — respects existing file format per-page
- Add CLI commands: `wiki-check`, `wiki-list`, `wiki-get`

### Phase 2: Write Operations (Priority: Medium)
- Add `wiki_create_page()` method — creates `.md` files by default, auto-detects layout conventions (`Home.md` if missing, appends to `_Sidebar.md`)
- Add `wiki_update_page()` method — modifies existing pages and updates sidebar entries
- Add `wiki_delete_page()` method — removes page and cleans up sidebar references
- Add CLI commands: `wiki-create`, `wiki-update`, `wiki-delete`

### Phase 3: Advanced Features (Priority: Low)
- Add `wiki_clone()` for manual editing workflow
- Add batch operations
- Add wiki history/revisions support if platform exposes it

## Layout Conventions — Implementation Details

Both GitHub and GitBucket wikis share these de facto standard filenames:

| Filename | Purpose | Semantic Role |
|----------|---------|---------------|
| `Home.<ext>` | Root/landing page | Entry point, TOC anchor |
| `_Sidebar.<ext>` | Left sidebar navigation panel | Site-wide table of contents / navigation tree |
| `_Footer.<ext>` | Bottom footer content | Copyright, version info, links |

The extension on these files controls the rendering format. Both platforms parse `[[Page Name]]` double-bracket wiki-links for internal linking — this is what enables sidebar navigation and must be maintained by all write operations.

### Layout Patterns Found in Real `.wiki` Repos
- **Pattern A: Flat structure** (most common) — all pages at repo root with `_Sidebar.md`
- **Pattern B: Hierarchical with folders** — `Home.md`, `_Sidebar.md` + subfolder landing pages (`Getting-Started/Home.md`)

## Authentication
- HTTPS: Inject token into git URL (`https://token@host/...`)
- SSH: Use existing SSH keys from main repo

## References
- GitHub Wiki docs: https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis
- GitHub Markup library (pre-renderer): https://github.com/github/markup/blob/master/README.md
- GitBucket wiki editor (multi-format support): https://github.com/gitbucket/gitbucket/wiki
- Research card: `.opencode/.issues/research-cards/wiki-operations-agent-tools-survey.md`

---

🤖 Co-authored with AI: <AgentName> (<ModelId>)
