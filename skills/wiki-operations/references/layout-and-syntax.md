<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#169; sourced from .opencode/.issues/research-cards/wiki-operations-agent-tools-survey.md Appendix B -->

# Layout conventions & link syntax (detail card)

## Layout files — the only standardized filenames across both platforms

| File | Role | Notes |
|------|------|-------|
| `Home.<ext>` | Root/landing page, TOC anchor | `.md` most common |
| `_Sidebar.<ext>` | Site-wide navigation panel | leading underscore; rendered in a fixed-width column |
| `_Footer.<ext>` | Bottom footer | version/copyright/links |

The **extension** controls the rendering format *of that file* — formats can be
mixed within one wiki repo by choosing extensions. Default to `.md` but respect
the existing format of each file you touch.

## Link semantics

- **`[[Page Name]]`** is the internal-link form both GitHub and GitBucket parse;
  it auto-resolves to `.md` pages. This is what powers sidebar navigation.
- **GitHub wiki gotchas** (from the `maintain-github-wiki` reference pattern,
  research card Appendix C):
  - Extensionless `[text](Page)` links are preferred on GitHub wikis.
  - A bare `---` frontmatter block renders as a horizontal rule — do not write
    YAML frontmatter into wiki pages.
  - `#NNN` issue references do **not** autolink on wikis.
- **GitBucket sidebar rule:** inside `_Sidebar.md` use `[[...]]` or absolute
  links only — relative markdown links resolve to broken `_blob/` paths
  (gitbucket#2629, open since 2021-01).

## Platform rendering differences

| Aspect | GitHub wiki | GitBucket wiki |
|--------|-------------|----------------|
| Render pipeline | `github/markup` pre-render at commit; then sanitize + post-process (highlight, emoji, task lists, autolink) | render-time format selection per file |
| Formats | `.md`, `.markdown`, `.textile`, `.rdoc`, `.org`, `.creole`, `.wiki`, `.mediawiki`, `.rst`, `.asciidoc` | AsciiDoc, Creole, Markdown, MediaWiki, Org-mode, Pod, RDoc, Textile, reStructuredText |
| Tables | GFM tables | Markdown/Creole only |
| Callouts (`> [!NOTE]`) | GitHub-flavored | not supported natively |
| Math (KaTeX) | yes | no |
| Mermaid | yes | no |

Write to the lowest common denominator of the target platform; when a page must
be portable across both, stick to plain GFM plus `[[...]]` links and avoid
callouts, math, and Mermaid.

## Page lifecycle

- **Naming:** page names become `[[...]]` targets — use stable, human-readable
  page titles; hyphens for multiword slugs (`Getting-Started`).
- **Layout patterns:** flat (`Home` + `_Sidebar` + pages, most common) or
  hierarchical (subfolders each with a landing `Home.md`; sidebar links to
  `Section/Home`). Choose one pattern and keep the wiki consistent.
- **Link hygiene:** after creating, renaming, or deleting a page, sweep
  `[[...]]` references — including `_Sidebar` and `_Footer` — so no orphans or
  broken links remain. Renames need a page move *and* a sidebar update.

Primary sources: GitHub wiki docs (docs.github.com, about-wikis /
footer-or-sidebar pages); `github/markup` README; GitBucket wiki
(github.com/gitbucket/gitbucket/wiki); gitbucket#2629.
