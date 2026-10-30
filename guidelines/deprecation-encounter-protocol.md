<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-authored, .opencode#2618 (Deprecation Encounter Protocol, spec .opencode#2618); encounter-evidence routing to the store record, .opencode#2662 -->

# Deprecation Encounter Protocol

This document is the deck's canonical protocol for what an agent does when it
**meets** a deprecated item during workflow — a library API, language feature,
config key, or wire format. It covers the consuming (encounter) side only:
authoring-side deprecation practice (clean breaks vs. deprecation cycles for
items this deck itself owns) remains with `programming-principles`, and
deck-internal staleness (retired cards, dead links, stale references) remains
with the `reference-currency` card. Domain skill cards carry compact slices of
this protocol linked here; this document is the single authoritative statement.

## R-1 — The bright line: new code

New code SHALL NOT be developed against deprecated surface. When writing new
code, the agent does not reach for a deprecated API, language feature, config
key, or wire format. The bright line applies pre-emptively: choosing a
deprecated call for new code is itself the encounter — the agent does not wait
for a completed encounter to trigger triage.

## R-2 — In-passing swap

Migrating a deprecated usage to its drop-in replacement inside code the change
is already rewriting SHALL NOT require ceremony — no spec adjustment, no
escalation, no ticket. It is compliance with R-1, not scope expansion. A
migration that is not drop-in (behavioral differences, new testing
obligations) stops being in-passing and follows R-3 or R-4.

## R-3 — Load-bearing: temporary-use exception

When the current change cannot proceed without a deprecated item (load-bearing
in the touched path, no route around), the agent SHALL:

1. file the owning `[BITROT]` ticket per R-4;
2. adjust the current spec with a temporary-use exception carve-out that
   cross-references that ticket; and
3. escalate to the developer with the proposed carve-out text.

The deprecation-touching portion pauses until the developer ratifies; the
remainder of the change proceeds. The plan's implementable content is
unchanged, so linked plan approvals are not revoked by the carve-out itself.

## R-4 — Ticket: the default fallback

Any encountered deprecated usage that R-2 does not already resolve SHALL be
recorded as a light `[BITROT]` initial spec in the module that owns the
deprecated item, filed via a sub-agent for minimal interruption.

- **Search before POST.** The agent searches the tracker for an existing
  `[BITROT]` ticket on that deprecation before creating one. Found → the
  encounter evidence goes to the existing ticket's local store record,
  through the
  `.opencode/tools/local-issues comment --number <repo>#<N> --type internal`
  command — it is never appended as a tracker comment. Not found → the agent
  creates the ticket with the `[BITROT]` title prefix
  and the bitrot label (the bitrot label is created with the first filing if
  the platform does not yet carry it).
- **Ownership.** Resolve the item's owning module from encounter context (file
  path, config namespace, dependency identity). If still unresolvable, do NOT
  guess — surface the unresolved ownership in the ticket for the developer.
- **Ticket shape.** Per R-13: `[BITROT]`-prefixed title, bitrot label,
  witnessed evidence with its live source, proximity/mechanical-ness metadata,
  and a stated promotion path (developer triage → full spec via the normal
  pipeline).
- **Duplicates.** The agent consolidates a duplicate `[BITROT]` ticket on
  the same deprecation by appending the duplicate's encounter evidence to
  the first ticket's local store record — through the
  `.opencode/tools/local-issues comment --number <repo>#<N> --type internal`
  command, never as a tracker comment — and closing the duplicate.

## R-5 — Not-in-use observations

Deprecated items not currently used in this repository SHALL also be ticketed
(R-4 path): usage may exist in sibling projects and is unknowable from one
repository's perspective. When raised, the developer may direct documentation
updates reflecting actual usage.

## R-6 — Evidence-based trigger

The protocol SHALL trigger only on evidence witnessed in the current
environment: deprecation annotations, documentation notices, changelog entries,
compiler or linter warnings, or live research findings with sources. Training
data and agent memory SHALL NOT count as evidence-based source items. The sole
exception: a deprecation the developer explicitly designates as trigger-grade
in the current session acts as a directive and bypasses the evidence gate; any
other developer-supplied knowledge enters a ticket as information, never as
trigger evidence.

## R-7 — Scope: code-facing only

The protocol applies to code-facing deprecations: library APIs, language
features, config keys, and wire formats. Deck-internal staleness (retired
cards, dead links, stale references) remains governed by the `reference-currency` card.

## R-13 — Ticket format and filing mechanics

The light `[BITROT]` ticket is a spec-format initial artifact: `[BITROT]`-
prefixed title, bitrot label, witnessed evidence with its live source,
proximity/mechanical-ness metadata, and a stated promotion path (developer
triage → full spec via the normal pipeline). Filing mechanics inherit the
`issues` card's platform routing (remote-first reservation, local mirror)
rather than re-specifying channel branches. On transient API failure the
encounter is never silently dropped — a chat executive summary preserves it
for defer-and-retry.

## Encounter decision path (summary)

1. Witnessed deprecation in the current environment? No (and no
   developer-designated trigger) → nothing fires; developer-supplied knowledge
   may enter a ticket as information.
2. Writing new code against it? → R-1: do not. Choose the non-deprecated path.
3. Already-rewritten code, drop-in replacement available? → R-2: swap
   in-passing; done.
4. Change cannot proceed without it? → R-3: ticket (R-4), carve-out, escalate;
   deprecation-touching portion pauses.
5. Otherwise — used here or observed not-in-use? → R-4 (with R-5): file or
   append to the `[BITROT]` ticket via a sub-agent.

Triage authority stays with the developer at the ticket queue: the agent never
widens approved scope on its own judgment, and never proposes scope expansion
from an encounter — cheap nearby migrations surface as ticket metadata only.

---

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
