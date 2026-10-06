# [SPEC] Add email-management skill card with install and workflow details cards

## Problem Statement

The deck has no email-management capability: `routing.md` has no email row,
the skill deck contains no email card, and ecosystem research (2026-10-06,
`.issues/research-cards/thunderbird-cli-ecosystem.md` in the root store) found
zero email skills in `anthropics/skills` or the major awesome lists. When a
session needs to find, read, or draft mail, agents have no governed entry
point and reach for ad-hoc tooling.

The same research session live-validated the underlying tool read-only against
a real populated profile: the prebuilt Go `thunderbird-cli` v3.5.0
(SHA256-verified release artifact, zero runtime dependencies) searched 30
folders, returned JSON with self-describing follow-up commands, and performed
**zero writes to the Thunderbird profile** — its cache lives outside the
profile. The extension/MCP-based alternatives were rejected by the developer
specifically because they require installing an add-on into the Thunderbird
profile.

## Design Decision (developer-selected)

- **Underlying tool**: prebuilt Go `thunderbird-cli` release binary
  (v3.5.0 at spec time), checksum-verified at install time, no profile
  modification required.
- **Layering** (developer requirement): the skill description matches intent
  only — no platform or tooling tokens. The tool identity, install procedure,
  and command syntax live one level down in the details cards, so the router
  surface survives a future tool replacement.
- **Governance**: the card set enters through the skill-creator admission
  gate. Gate evidence:
  1. *Observed failure* — capability gap demonstrated 2026-10-06 (developer
     request + research card showing zero coverage anywhere).
  2. *Consumer* — agent sessions tasked with email search, reading, drafting.
  3. *Mechanism/trigger* — routing.md row + platform skill-description match.
  4. *Predicate classification* — install verification and checksum checks are
     fact-decidable (scripts allowed); send/move decisions are intent-decidable
     (no scripts — cards state the rule, judgment decides).
  5. *Domain match* — tool live-verified in THIS domain (read-only behavioral
     run on the reference machine, 2026-10-06).
  6. *Root-agnostic* — no repo names or absolute paths in any card.
  7. *What it replaces* — nothing displaced; first email capability in the
     deck (net-new, justified).

## Scope

### In Scope

- New card set `.opencode/skills/email-management/`:
  - `SKILL.md` — intent-phrased description (what the skill does AND when to
    load it, at both abstraction levels, deliberately pushy; no user-phrase
    matching; no tooling tokens). Lean body delegating to the details cards.
  - `references/install.md` — details card: checksum-verified prebuilt-binary
    install into a repo-local tools directory; runtime verification via the
    tool's doctor command; per-machine profile-root discovery including the
    documented override for non-standard roots (snap/flatpak); explicit
    no-profile-modification property.
  - `references/search-read.md` — details card: one-shot search (JSON when
    piped), following the returned self-describing read command verbatim,
    thread/message reading, attachment extraction.
  - `references/draft-send.md` — details card: reply/compose workflow with
    dry-run-by-default discipline; real send requires explicit developer
    instruction in the session; post-send verification (sent-check /
    auth-check).
- One `routing.md` row: email-management intent → the card (same PR; governed
  deck edit).
- Skill-creator governance record for the card set + routing edit; deck-debt
  ledger entry recording the admission.

### Out of Scope

- Installing the binary into any specific root's tools directory as a tracked
  artifact — adoption happens per-session by following the install card (SC-7
  exercises it in a scratch location).
- The extension/MCP-based alternatives (developer-rejected: profile
  modification required).
- Any change to the Thunderbird profile, extensions, or account configuration.
- `floor.md` changes.

## Success Criteria

- [ ] **SC-1 (structural):** `SKILL.md` exists with valid frontmatter (name,
  description, license, provenance line). Verification: `skildeck lint` over
  the card set, exit clean.
- [ ] **SC-2 (structural):** The `SKILL.md` description contains no
  platform/tooling tokens (thunderbird, betterbird, tb, go, golang, npm, cli,
  mail-client names) while stating what the skill does and when to load it at
  both abstraction levels. Verification: token grep over the description
  field; framing quality reviewed against card standards.
- [ ] **SC-3 (structural):** Details cards exist under `references/` — exactly
  one install card plus workflow cards covering search/read (incl.
  attachments) and draft/send (incl. send verification) — each linked from
  `SKILL.md`, one level deep. Underlying-tool command syntax appears only in
  details cards, never in `SKILL.md` body or description. Verification: file
  listing, link check (`reference-integrity`), token grep on `SKILL.md`.
- [ ] **SC-4 (structural):** All card files are root-agnostic: no repository
  names, no absolute machine paths; per-root facts arrive via session-init or
  runtime discovery (doctor). Verification: grep sweep for repo names and
  `/home/`-style absolute paths across the card set.
- [ ] **SC-5 (structural):** `routing.md` contains one new email-management
  intent row loading the card; no other routing rows changed. Verification:
  routing.md diff inspection.
- [ ] **SC-6 (structural):** Governance admission recorded: skill-creator gate
  evidence in the PR body and a deck-debt ledger entry. Verification: PR body
  inspection + ledger issue search.
- [ ] **SC-7 (behavioral):** A fresh-context agent given only the skill can
  execute the install details card on a clean location and reach a
  verified-working state (doctor success) without writing to any Thunderbird
  profile. Verification: behavioral run (`opencode run` per behavioral-testing
  card) with doctor exit-status assertion and profile-hash pre/post
  comparison.
- [ ] **SC-8 (behavioral):** A fresh-context agent can execute the search-read
  workflow against the populated local profile: produce search results, follow
  the returned read command, retrieve a message body and an attachment — with
  zero writes to the profile. Verification: behavioral run; profile integrity
  hash unchanged pre/post.
- [ ] **SC-9 (behavioral):** The draft-send workflow's documented default is
  dry-run: a behavioral run that drafts a reply WITHOUT explicit send
  authorization produces a dry-run/draft result and no sent message.
  Verification: behavioral run against a disposable profile fixture — never
  the production profile. (Fixture construction is plan-level work; if
  infeasible, the SC returns for revision rather than silent deletion.)

## Constraints (inherited)

- Floor safety: no production data access without explicit instruction in the
  current session; send/move operations documented in the cards must require
  explicit developer instruction (intent-decidable — no script enforcement).
- Progressive disclosure: details one level deep (`references/`).
- Tool-neutral router surface (SC-2) is the developer's stated layering
  requirement, not a style preference.

## References

- Research card: `.issues/research-cards/thunderbird-cli-ecosystem.md` (root
  store; live read-only test evidence, 2026-10-06)
- Upstream tool: `github.com/avikalpa/thunderbird-cli` v3.5.0 — its own
  `SKILL.md` / `AGENTS.md` / `PLAYBOOK.md` are reference material for the
  details cards, not adopted verbatim
- Deck: `skill-creator` (admission gate), `routing.md`, `behavioral-testing`
  (SC-7/8/9 instruments), `skildeck` (lint / verify-acceptance)

---

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
