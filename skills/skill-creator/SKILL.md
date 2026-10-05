---
name: skill-creator
description: "Load before creating or editing ANY file under skills/, guidelines/, floor.md, or routing.md — including adding or removing a rule, skill, artifact, or enforcement mechanism anywhere in the deck. Also load when writing or revising skill descriptions, or when deck content is found missing, stale, or conflicting. Enforces the admission gate, retirement gate, deck-debt ledger, predicate classification, and vendor-card boundary. This card governs the deck itself."
license: MIT
provenance: AI-authored, .opencode#2490
---

<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2490 -->

# skill-creator — deck governance

**Every deck edit passes this gate first.** The deck mutates through process,
not through casual edits — the historical record shows ~27,700 ungoverned
edits produced the doom loop this deck replaced.

## Admission gate — a new rule/skill/artifact enters only with ALL of:

1. **Observed failure** — a named incident or measured pattern, with evidence
   (session record, issue, database finding). No hypothetical failures.
2. **Consumer** — what reads or executes it, and when.
3. **Mechanism or trigger** — a routing entry, a skill reference, or a
   fact-decidable enforcement point.
4. **Predicate classification** — fact-decidable (scripts allowed: file
   exists, token in diff, tests pass) vs intent-decidable (scripts FORBIDDEN —
   judgment decides). Static checks on intent are the deck's founding defect.
5. **Domain match** — a protocol or paper adopted from another domain requires
   evidence in THIS domain (the DiMo lesson).
6. **Root-agnostic** — zero root-repo names or absolute paths; per-root facts
   arrive via session-init.
7. **What it replaces** — an admission that adds without retiring grows the
   deck; name the displaced content or justify the net-zero.

## Card standards

- Frontmatter: `name`, `description`, `license`; provenance line.
- **Descriptions are the router**: state what the skill does AND when to load
  it, at both abstraction levels (domain framing + implementation framing —
  "before any code that contacts GitHub" catches what "GitHub operations"
  misses), deliberately pushy (agents undertrigger). **No user-phrase
  matching anywhere** — the floor's vocabulary table defines utterance
  meanings; descriptions match agent intent.
- Bodies stay lean; details go one level deep in `references/`.
- No TDTs, no dispatch-gate boilerplate, no artifact chains, no numeric size
  targets.

## Retirement gate

Content with lost provenance (no consumer/trigger), a declining usage trend
across deployments, or structural obsolescence is retired. Absence in a live
database is NOT evidence — retention vacuums delete history; verdicts use
deep history or the cross-deployment ledger. Resurrection via git history is
cheap; hoarding is not.

## Deck-debt ledger

Usage observations, governance decisions, and retirement candidates are
recorded in the deck-debt issue (synced issue store) — the cross-deployment
evidence base.

## Vendor-card boundary

Vendor-generated cards (e.g. `hf skills add`) are referenced and regenerated
by their owning tool — never hand-edited. Card origins: deck-authored
(governed) / vendor-generated / project-local.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
