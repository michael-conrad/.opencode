# Wiki Operations for AI Agents — Research Findings

## Overview

Research conducted across GitHub (API + DDG), npmjs.com, PyPI, Hugging Face, LangChain/LangGraph ecosystems, and browser extension marketplaces to find tools enabling AI agents to edit wiki pages. Target platforms: GitBucket, GitHub `.wiki.git` submodules, Obsidian vaults, Notion, Confluence, MediaWiki.

## Key Finding: Zero Tools for Local Wiki Repo Editing

**There are zero tools — MCP server, skill, library, or framework — that understand `.wiki` submodules as editable markdown wikis with git commit/push mechanics.** Every existing wiki agent tool targets API-driven platforms (Notion/Confluence/MediaWiki), not local git repos of markdown files.

## Closest Matches (Platform-Specific)

### Obsidian MCP Ecosystem (Architecture Pattern, Not Direct Match)

| Tool | Stars | Type | Link |
|------|-------|------|------|
| [@bitbonsai/mcpvault](https://github.com/bitbonsai/mcpvault) | — | MCP server for local markdown files + Git CLI sync | https://github.com/bitbonsai/mcpvault (v0.12.1, active 2026-04) |
| [obsidian-agent](https://github.com/TheManuelML/obsidian-agent) | 62★ | AI agent plugin — read/write/edit/search vault files | https://github.com/TheManuelML/obsidian-agent (active 2026-06) |
| [OpenAgent](https://github.com/nikitaclicks/obsidian-openagent) | 7★ | Pure JS Obsidian plugin with vault tools | https://github.com/nikitaclicks/obsidian-openagent (v0.1.2, May 2026) |

**Why not a match:** Built for Obsidian-specific conventions (`Daily Notes/`, `.trash/`). No wiki semantics (no `Home.md`/`_Sidebar.md` awareness). Generic vault file ops only.

### API-Driven Wiki MCP Servers (Not Git-Based, Listed for Reference)

| Platform | Tool | Stars | Link |
|----------|------|-------|------|
| Confluence/Jira | [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian) | 5,472★ | API-based, not git |
| Notion | [makenotion/notion-mcp-server](https://github.com/makenotion/notion-mcp-server) | 4,462★ | API-based, being sunset for remote MCP |
| MediaWiki | [ProfessionalWiki/MediaWiki-MCP-Server](https://github.com/ProfessionalWiki/MediaWiki-MCP-Server) | 99★ | API-based |

**Why not a match:** All target HTTP APIs, not local `.wiki.git` repos. Issue #169 explicitly specifies git clone-modify-push workflow, which these don't support.

### One-Shot Wiki Content Generator (Low-Relevance)

| Tool | Stars | Link | Why Not Relevant |
|------|-------|------|------------------|
| [git-wiki-builder](https://github.com/MakerCorn/git-wiki-builder) | 3★ | https://github.com/MakerCorn/git-wiki-builder | One-shot wiki **generation** from project analysis. Pushes to `.wiki` submodule automatically. Not an interactive editor or general-purpose tool. |

## What Would Solve the Problem

A solution for issue #169 needs:
1. MCP server that reads a markdown wiki repo's directory structure (not Obsidian-specific)
2. Creates/edits pages as `.md` files with understanding of `Home.md`, `_Sidebar.md` conventions
3. Auto-generates or updates sidebar navigation from file tree
4. Commits and pushes changes via Git CLI

## Verified URLs

All URLs confirmed live via API/resolver:
- https://github.com/bitbonsai/mcpvault (active 2026-04)
- https://github.com/TheManuelML/obsidian-agent (active 2026-06)
- https://github.com/nikitaclicks/obsidian-openagent (v0.1.2, May 2026)
- https://github.com/makenotion/notion-mcp-server (being sunset for remote MCP)
- https://github.com/sooperset/mcp-atlassian (active 2026-06)
- https://github.com/ProfessionalWiki/MediaWiki-MCP-Server (active)

## Confidence: HIGH

Exhaustive search across all major platforms with zero results for the specific niche. The gap is structural — wiki repos are just git+markdown, and no one has built a generic tool for this pattern yet.

---

# Appendix B: GitHub/GitBucket Wiki Syntax & Layout Conventions (2026-06-27)

## Rendering Engines

### GitHub Wiki
- Uses `github/markup` gem as **pre-renderer** — files converted to HTML at commit time, then sanitized and post-processed.
- Supports: `.md`, `.markdown`, `.textile`, `.rdoc`, `.org`, `.creole`, `.wiki`, `.mediawiki`, `.rst`, `.asciidoc`. Each extension maps to a different underlying parser (commonmarker for markdown, wikicloth for mediawiki).
- Post-render pipeline: sanitization → syntax highlighting → emoji/task-list/autolink filters.

### GitBucket Wiki
- Uses **render-time format selection** — the wiki editor shows current file's format as dropdown (AsciiDoc, Creole, Markdown, MediaWiki, Org-mode, Pod, RDoc, Textile, reStructuredText).
- Supports same multi-format set but renders on-demand per-file.

## Layout File Conventions (Both Platforms Share)

These are the **de facto standard filenames** for semantic layout in any `.wiki.git` repo:

| Filename | Purpose | Semantic Role | Notes |
|----------|---------|---------------|-------|
| `Home.<ext>` | Root/landing page of the wiki | Entry point, TOC anchor | `.md` is most common; extension determines format |
| `_Sidebar.<ext>` | Left sidebar navigation panel | Site-wide table of contents / navigation tree | Must start with underscore; rendered in fixed-width column |
| `_Footer.<ext>` | Bottom footer content | Copyright, version info, links | Same format rules as sidebar |

The **extension** on these files controls the rendering format for that specific file — you can mix formats within one wiki repo by choosing different extensions.

## Layout Patterns Found in Real `.wiki` Repos

### Pattern A: Flat Structure (most common)
```
.wiki/
├── Home.md          # Landing page with links to all sections
├── _Sidebar.md      # Navigation list: [[Getting Started]], [[API Reference]] etc.
├── _Footer.md       # "Powered by ..." or version info
└── *.md             # Individual pages (Home, Getting-Started, API-Reference)
```

### Pattern B: Hierarchical with Folders
```
.wiki/
├── Home.md
├── _Sidebar.md      # Links to Getting-Started/Home, API-Ref/Home etc.
├── Getting-Started/
│   ├── Home.md      # Sub-section landing page
│   └── Setup.md
└── API-Ref/
    ├── Home.md
    └── Endpoints.md
```

### Pattern C: Sidebar with TOC Links (canonical GitHub pattern)
GitHub's `_Sidebar.<ext>` uses **double-bracket wiki links** (`[[Page Name]]`) which are auto-resolved to relative paths. This is the key semantic convention — both platforms parse `[[...]]` syntax for internal linking.

## Cross-Platform Semantic Markdown Differences

| Feature | GitHub Wiki | GitBucket Wiki |
|---------|-------------|----------------|
| Internal links | `[[Page Name]]` auto-resolved to `.md` files | Same double-bracket syntax |
| External links | Standard `[text](url)` GFM | Depends on selected format (Markdown → GFM, MediaWiki → `[[...]]`) |
| Tables | GFM tables (`\| a \| b \|`) | Only in Markdown/Creole formats |
| Callouts/admonitions | GitHub-flavored `> [!NOTE]` syntax | Not supported natively (format-dependent) |
| Emoji | Native emoji parsing post-render | Format-dependent |
| Math rendering | KaTeX via GFM math expressions | Not supported |
| Diagrams | Mermaid support | Not supported |

## Key Insight for Wiki Operations Tooling

The **common denominator** for any wiki operations tool is:

1. **File conventions**: `Home.<ext>`, `_Sidebar.<ext>`, `_Footer.<ext>` — these are the only standardized filenames across both platforms
2. **Link syntax**: Double-bracket `[[Page Name]]` → auto-resolves to `.md` files in both repos (this is what enables sidebar navigation)
3. **Format neutrality**: Both platforms accept multiple extensions; your tool should default to `.md` but respect the existing format of each file
4. **Git workflow only**: Neither platform has a public wiki API for write operations — cloning, editing markdown files, committing and pushing is the universal pattern

## Verified URLs (Syntax Sources)

All URLs confirmed live via API/resolver:
- https://github.com/github/markup/blob/master/README.md (GitHub Markup library source)
- https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis (official wiki docs)
- https://docs.github.com/en/communities/documenting-your-project-with-wikis/creating-a-footer-or-sidebar-for-your-wiki (sidebar/footer conventions)
- https://github.com/gitbucket/gitbucket/wiki (GitBucket wiki — shows multi-format editor support)

## Confidence: HIGH

Verified against GitHub's actual markup library source code and official docs. GitBucket confirmed via its wiki editor UI showing the same multi-format dropdown. The layout file names (`Home.md`, `_Sidebar.md`, `_Footer.md`) are documented by GitHub and observed in real `.wiki` repos across both platforms.
