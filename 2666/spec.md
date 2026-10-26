<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# [SPEC] Zola card set — deck-wide static-site workflow layer

## Problem

The deck has no card for working with Zola static sites; Zola-repo
sessions reconstruct the site workflow from each consuming root's
`AGENTS.md` alone, and the deck-wide root-agnostic layer (site creation,
build debugging, authoring, static i18n, existing-site modify/review,
bounded theme override) is missing. The developer directed adding the
CodeSigils/zola-skill card set with two adaptations: fit to the live
(pinned) Zola the deck must serve, and no agent-surfaced deployment path
(no provider, no publish). Survey evidence (store research card,
fetched live this session): the Zola project publishes nothing
agent-structured; `CodeSigils/zola-skill` is the only serious
purpose-built card in the wild (MIT, agentskills.io v1-spec, v1.0.0
pinned tag `6b279b3`; 5 KB router + six workflows + six references; it
already refuses deployment as a mode).

## Scope

Add `.opencode/skills/zola/` — router `SKILL.md` plus `references/` —
adapted from CodeSigils/zola-skill v1.0.0. No other deck content
changes.

## Requirements

- **R-1 (card set + structure)** — the card set under
  `.opencode/skills/zola/` with a lean router `SKILL.md` and content one
  level deep in `references/` (upstream's second workflows tier merged
  in; nothing upstream silently dropped); MIT license, retained upstream
  attribution, provenance line naming the pinned upstream commit.
- **R-2 (description in deck router dialect)** — `description` leads
  with load triggers in deck form, covers both abstraction levels, adds
  the pushy implementation-level trigger ("before any Zola/Tera file
  edit, however small") and the failure trigger ("when any Zola/Tera
  build, serve, or template behavior fails"), quotes no user phrases,
  carries no authorization predicate (the floor's vocabulary governs
  authorization), and retains the explicit negative gate (not general
  writing / CMS / backend / full theme authoring, and never deployment).
- **R-3 (version targeting to the live Zola)** — content written for the
  Tera/Zola 0.22 line as default semantics (live instance pins 0.22.1 as
  of 2026-10-24; upstream current is 0.23.6 with Tera v2); any ≥0.23
  behavior named only as version-dependent with explicit as-of dating;
  the version-aware source-registry reference retained for other pins.
- **R-4 (no deployment surface)** — no publish/deploy/provider steps or
  guidance anywhere in the card set; workflows terminate at the PR
  boundary; publish happens through CI after a human merge, in
  deck-generic terms.
- **R-5 (root-agnostic)** — no root-repo name, absolute path, `~/`
  path, or per-root pinned value in any card file; per-root facts stay
  in the consuming repo's `AGENTS.md`/session-init.
- **R-6 (cross-reference conformance)** — all in-card deck
  cross-references use the `Read [Text](path)` load-directive form with
  deck-relative paths, and resolve.
- **R-7 (preservation)** — no pre-existing deck file outside
  `.opencode/skills/zola/` changes.

## Success criteria

| ID | Criterion | Class | Instrument |
|---|---|---|---|
| SC-1 | SKILL.md exists; frontmatter parses (`name: zola` = folder, `description`, `license: MIT`, provenance naming the upstream pin) | structural | file-existence + frontmatter parse + grep |
| SC-2 | Each of the 12 upstream files (6 workflows + 6 references) maps to a card file (merges allowed, each mapping named in provenance notes); no card file empty | structural | upstream tree manifest vs `zola/` listing; size > 0 |
| SC-3 | Card name unique in the deck | structural | `ls .opencode/skills/` membership |
| SC-4 | Description begins with a load-trigger clause, single paragraph, negative gate present, no authorization predicate | structural | frontmatter extraction + grep |
| SC-5 | Zero root-repo names / absolute paths / `~/` paths / per-root pinned values in card files | structural | scripted pattern scan; zero matches |
| SC-6 | Every `Read [Text](path)` cross-reference resolves | structural | reference-integrity check |
| SC-7 | No deployment surface; workflows end at the PR boundary; refusal statement present | behavioral | fresh-context reviewer reads the card set (never a token scan) |
| SC-8 | Semantics match Zola 0.22.x/Tera-v1 defaults; every ≥0.23 mention version-flagged + as-of dated | behavioral | reviewer vs live 0.22/0.23 docs |
| SC-9 | A fresh opencode session lists `zola` in the available-skills listing | behavioral | `opencode run` smoke probe after config restart |
| SC-10 | Deck diff touches only `.opencode/skills/zola/**` (+ repo-convention bookkeeping); pre-existing cards untouched | structural | git diff path filter |

Full instrument and traceability detail: local `.issues/{N}/spec.md`
(authoritative).

## Impact

Every session in every root consuming the deck gains one skill-listing
description line (352 chars measured upstream — within the 300–500-char
band of the deck's 35 cards); Zola roots additionally load the ~5 KB
router on invoke with ~36 KB parked behind it. Static text — no runtime
dependency. Net addition; no card displaced (justification: the
deck-wide Zola gap recorded in the research card; per-root facts remain
root-local per R-5).

## Approach

Pin upstream v1.0.0; flatten to the deck two-tier layout; rewrite the
description per R-2; version-flag pass (R-3) and deployment-strip pass
(R-4); mechanical root-agnostic scrub (R-5); reference-integrity
verification (R-6). Implementation itself is out of scope for this
spec-stage filing — it follows on separate pipeline authorization.

## Out of scope

Implementation beyond this filing; cards for other static-site
generators; per-root `AGENTS.md` rework; deployment/provider/MCP
integration; upstream contribution to CodeSigils; Tera-v2 migration
guidance; deck governance-process changes.

---
*🤖 OpenCode (ollama-cloud/glm-5.3-flash)*