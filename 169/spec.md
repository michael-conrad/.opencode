# Wiki Operations Support — Spec

> **Rev 2 — refocused 2026-10-06** per developer direction: no bespoke tooling; the
> deliverable is wiki rules and best practices packaged as a progressive skill card
> set. Rev 1's architecture (MCP server pattern exposing `wiki-check`/`wiki-list`/
> `wiki-get`/`wiki-create`/`wiki-update`/`wiki-delete`/`wiki-clone` commands,
> SC-1..10 command criteria, phased CLI plan) is superseded and removed, not
> accumulated.

## Problem Statement

Agents can mechanically edit GitHub and GitBucket wikis — wikis are plain git
repos of markdown files (`.wiki.git`), so clone, edit files, commit, and push
all work through existing generic mechanisms (`git -C`, standard file tools).
What agents lack is the **domain knowledge to do it correctly**: Gollum layout
conventions, `[[Page Name]]` internal-link semantics, per-extension rendering
formats, and the rendering differences between platforms. Without these rules,
agents produce wiki pages that render incorrectly or break sidebar navigation.

## Architecture: Progressive Skill Card Set

The deliverable is a governed skill card set in the deck's existing
progressive-disclosure mechanism:

- One dispatchable card (`skills/wiki-operations/SKILL.md`) plus referenced
  detail files — the routing index dispatches wiki-editing intent to it, the
  SKILL.md loads on match, and referenced detail files load on demand.
- **No bespoke tooling.** All mechanics stay generic: existing file-editing
  tools for markdown edits; `git -C <wiki-repo>` for clone/commit/push; `gh` /
  `gb` for platform queries. No MCP server, no new CLI commands, no scripts,
  no new dependencies.
- The card enters through the skill-creator deck-governance admission gate;
  `routing.md` gains its dispatch entry through the same governance path.

## Scope

### In Scope — knowledge content the card set encodes

- Layout conventions: `Home.<ext>` / `_Sidebar.<ext>` / `_Footer.<ext>` roles;
  the file extension controls that file's rendering format.
- `[[Page Name]]` link semantics: the double-bracket syntax both platforms
  parse for internal linking, plus GitHub wiki gotchas (extensionless
  `[text](Page)` links preferred; bare `---` frontmatter renders as a
  horizontal rule; `#NNN` issue references do not autolink on wikis).
- Platform rendering differences: GitHub's pre-render pipeline
  (`github/markup`) vs GitBucket's render-time format selection; supported
  format matrix; feature differences (tables, callouts/admonitions, Mermaid,
  math).
- Sidebar/footer maintenance rules: when to append `_Sidebar.md` entries on
  page creation; cleanup on page deletion or rename; preserving link syntax
  across edits.
- Page lifecycle best practices: page naming, layout patterns (flat vs
  hierarchical with subfolder landing pages), orphan/broken-link hygiene.
- Publish discipline as agent rules: verify the rendered diff before pushing;
  never force-push a wiki; confirm wiki availability before editing.

### Out of Scope

- Bespoke tooling of any kind — MCP servers, `wiki-*` CLI commands, helper
  scripts, new dependencies (supersedes rev 1).
- API-based wiki operations for platforms that expose HTTP endpoints but no
  public `.wiki.git` repo (future extension point).
- Migration of non-git wikis to git-backed format; multi-wiki synchronization.
- Disposition of the bespoke `tools/md` script (separate item; the card set
  must not depend on it).
- Generic git / `gh` / `gb` instruction — the agent already has this surface.

## Success Criteria

- [ ] **SC-1 (structural):** A dispatchable skill card exists at
  `skills/wiki-operations/SKILL.md` with a routing-index entry that dispatches
  wiki-editing intent to it, admitted through the skill-creator governance
  gate. Verification: reference-integrity check over the card's references +
  inspection of `routing.md` and the governance record.
- [ ] **SC-2 (structural):** The card set encodes the rule domains listed
  In Scope — layout conventions, `[[...]]` link semantics with platform-correct
  gotchas, GitHub-vs-GitBucket rendering differences, sidebar/footer
  maintenance, page lifecycle, publish discipline — with each rule traceable to
  the research card (Appendix A/B/C) or a fetched primary source. Verification:
  content check of card facts against their cited sources.
- [ ] **SC-3 (structural):** No bespoke tooling is introduced: the change
  touches only deck content (skills/, routing.md, governance artifacts) — no
  files under `tools/`, no MCP configuration entries, no new scripts or
  dependencies. Verification: diff inspection.
- [ ] **SC-4 (behavioral):** An agent session equipped only with the card set
  and existing generic tools performs a wiki edit on a GitHub test repo
  following the rules — correct link syntax, `_Sidebar.md` maintained, diff
  verified before publish. Verification: behavioral run with session evidence
  per the behavioral-testing card.

## References

- Research card: `.opencode/.issues/research-cards/wiki-operations-agent-tools-survey.md`
  — Appendix A (wiki-editing tool survey), Appendix B (syntax & layout
  conventions), Appendix C (skill-deck/registry landscape; `wk-j/skills/maintain-github-wiki`
  verified as a reference rule source, GitHub facet).
- GitHub wiki docs: https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis
- GitHub Markup library (pre-renderer): https://github.com/github/markup/blob/master/README.md
- GitBucket wiki editor (multi-format support): https://github.com/gitbucket/gitbucket/wiki
- Agent Skills standard (packaging format this deck already uses): https://agentskills.io

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
