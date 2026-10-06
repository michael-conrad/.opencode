# Wiki Operations Support — Spec

> **Rev 3 — 2026-10-06:** absorbs the placement, provisioning, publish-discipline, and
> maintainer-posture decisions from the 2026-10-06 design discussion. Rev 2 refocused the
> deliverable from bespoke tooling to a progressive skill card set; rev 1's MCP-server
> architecture (`wiki-*` commands, SC-1..10) remains superseded and removed, not
> accumulated.

## Problem Statement

Agents can mechanically edit GitHub and GitBucket wikis — wikis are plain git
repos of markdown files (`.wiki.git`), so clone, edit files, commit, and push
all work through existing generic mechanisms (`git -C`, standard file tools).
What agents lack is the **domain knowledge to do it correctly**: Gollum layout
conventions, `[[Page Name]]` internal-link semantics, per-extension rendering
formats, the rendering differences between platforms, and the placement and
publish discipline a direct-publish, un-reviewable surface demands. Without
these rules, agents produce wiki pages that render incorrectly, break sidebar
navigation, or mutate the root repo in untracked ways.

## Architecture: Progressive Skill Card Set

The deliverable is a governed skill card set in the deck's existing
progressive-disclosure mechanism:

- One dispatchable card (`skills/wiki-operations/SKILL.md`) plus referenced
  detail cards — including a dedicated **remediation detail card** — routed by
  the routing index, SKILL.md loaded on match, detail cards loaded on demand.
- **No bespoke tooling.** All mechanics stay generic: existing file-editing
  tools for markdown edits; `git -C <wiki-repo>` for clone/commit/push; `gh` /
  `gb` for platform queries; the official gollum Docker image for optional
  local preview. No MCP server, no new CLI commands, no scripts, no new
  dependencies.
- The card enters through the skill-creator deck-governance admission gate;
  `routing.md` gains its dispatch entry through the same governance path.

## Scope

### In Scope — knowledge content the card set encodes

1. **Layout conventions:** `Home.<ext>` / `_Sidebar.<ext>` / `_Footer.<ext>`
   roles; the file extension controls that file's rendering format.
2. **Link semantics:** the `[[Page Name]]` double-bracket syntax both platforms
   parse; GitHub wiki gotchas (extensionless `[text](Page)` links preferred;
   bare `---` frontmatter renders as a horizontal rule; `#NNN` issue references
   do not autolink on wikis); GitBucket sidebar rule — `[[...]]` or absolute
   links only, relative markdown links inside `_Sidebar.md` resolve to broken
   `_blob/` paths (gitbucket#2629).
3. **Platform rendering differences:** GitHub's pre-render pipeline
   (`github/markup`) vs GitBucket's render-time format selection; supported
   format matrix; feature differences (tables, callouts/admonitions, Mermaid,
   math).
4. **Page lifecycle best practices:** page naming, layout patterns (flat vs
   hierarchical with subfolder landing pages), orphan/broken-link hygiene.
5. **Placement and provisioning:** default arrangement is an **ignored
   sub-repo** — a foreign clone of `<derived>.wiki.git` at a deterministic
   fixed in-tree path, gitignored, never registered as a submodule
   (`git submodule add` against a wiki is forbidden); the ignore entry exists
   before the clone lands; **lazy provisioning** — setup only when a wiki
   operation is actually needed and no checkout exists (detection ladder:
   inherited submodule → existing sub-repo → probe availability → provision →
   stand down when no wiki exists); the sub-repo is kept after use.
6. **Checkout currency:** sync — including conflict resolution — before any
   edit; commit and push immediately after editing; never force-push; never
   discard remote edits wholesale (remote tip is the rendered state and human
   web-UI edits are likely).
7. **Inherited submodule wikis:** if a repo's wiki is already wired as a
   submodule (`.gitmodules` entry), operate it in place under the same rules —
   observed state, never created, never converted as a side effect.
8. **Remediation detail card:** converting a wiki submodule to the ignored
   sub-repo arrangement — executed only when the developer directs and
   authorizes it for a specific repo, never opportunistically; procedure:
   push local wiki work first (git's submodule up-to-date check does not cover
   unpushed commits), `git submodule deinit` + `git rm` (removes worktree,
   gitlink, and stages the `.gitmodules` removal — verified against git-rm
   docs), remove the leftover `.git/modules/<path>` admin directory, add the
   ignore line in the **same** parent commit (real parent change, so pointer
   discipline holds), fresh sub-repo clone (at remote tip by definition), then
   verify: clean parent status, no wiki entry in `.gitmodules`, path confirmed
   ignored via `git check-ignore`.
9. **Publish discipline:** wiki pushes are direct-publish — no branch, PR, or
   hook can gate them — so verify-before-push (diff review plus the card's
   rule-based checks) is the review substitute; **local preview** via the
   official gollum Docker image (`gollumwiki/gollum`) is an opportunistic
   enhancement used only when Docker is available, never a blocker when it is
   not; the approximation validates structure, links, and sidebar behavior
   (gollum↔GitHub divergence acknowledged), and the live page remains the
   final look.
10. **Maintainer posture:** the agent is the primary maintainer of any wiki it
    manages — it owns **styling and semantic structuring**; human edits own
    content intent (adapt means integrate-and-normalize, never revert human
    meaning); the posture is **responsive only** — structure is maintained
    within the footprint of the task being performed, and structural debt
    beyond it is not searched for.

### Out of Scope

- Bespoke tooling of any kind — MCP servers, `wiki-*` CLI commands, helper
  scripts, new dependencies (supersedes rev 1).
- API-based wiki operations for platforms that expose HTTP endpoints but no
  public `.wiki.git` repo (future extension point).
- Migration of non-git wikis to git-backed format; multi-wiki synchronization.
- Disposition of the bespoke `tools/md` script (tracked separately in
  `.opencode#2528`; the card set must not depend on it).
- Proactive structural-debt audits (per the responsive-only posture).
- Generic git / `gh` / `gb` instruction — the agent already has this surface.

## Success Criteria

- [ ] **SC-1 (structural):** A dispatchable skill card exists at
  `skills/wiki-operations/SKILL.md` with a routing-index entry that dispatches
  wiki-editing intent to it, admitted through the skill-creator governance
  gate. Verification: reference-integrity check over the card's references +
  inspection of `routing.md` and the governance record.
- [ ] **SC-2 (structural):** The card set encodes the ten rule domains listed
  In Scope, with each rule traceable to the research card
  (`.opencode/.issues/research-cards/wiki-operations-agent-tools-survey.md`,
  Appendices A–D), a fetched primary source, or a developer direction from the
  2026-10-06 design discussion. Verification: content check of card facts
  against their cited sources.
- [ ] **SC-3 (structural):** No bespoke tooling is introduced: the change
  touches only deck content (skills/, routing.md, governance artifacts) — no
  files under `tools/`, no MCP configuration entries, no new scripts or
  dependencies. Verification: diff inspection.
- [ ] **SC-4 (behavioral):** An agent session equipped only with the card set
  and existing generic tools performs a correct wiki edit on a GitBucket wiki
  hosted on the **local GitBucket container provisioned by the tests-v2
  harness** (`tests-v2/AGENTS.md` §12, `__ensure_gitbucket()`), following the
  card's rules — correct link syntax, `_Sidebar.md` maintained, sync before
  edit, verified before push. Verification: behavioral run with session
  evidence per the behavioral-testing card (two-SC pattern: artifact generation
  + clean-room evaluation).

## References

- Research card: `.opencode/.issues/research-cards/wiki-operations-agent-tools-survey.md`
  — Appendix A (wiki-editing tool survey), Appendix B (syntax & layout
  conventions), Appendix C (skill-deck/registry landscape; `wk-j/skills/maintain-github-wiki`
  verified as a reference rule source, GitHub facet), Appendix D (local preview
  tooling: gollum Docker image, fidelity caveats, GitBucket sidebar gotcha).
- GitHub wiki docs: https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis
- GitHub Markup library (pre-renderer): https://github.com/github/markup/blob/master/README.md
- GitBucket wiki editor (multi-format support): https://github.com/gitbucket/gitbucket/wiki
- GitBucket sidebar defect: https://github.com/gitbucket/gitbucket/issues/2629
- Agent Skills standard (packaging format this deck already uses): https://agentskills.io
- tests-v2 harness: `tests-v2/AGENTS.md` §12 (local GitBucket container) — SC-4's instrument
- Related: `.opencode#2527` (behavioral-testing card capability gap), `.opencode#2528` (md tool removal)

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
