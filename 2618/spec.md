---
title: "[SPEC] Deprecation Encounter Protocol — code-facing deprecation triage for the live deck"
labels:
  - needs-approval
  - spec-draft
remote_issue: 2618
remote_url: https://github.com/michael-conrad/.opencode/issues/2618
github_url: https://github.com/michael-conrad/.opencode/issues/2618
promoted_at: '2026-10-15T04:10:46+00:00'
---

> **Full spec and artifacts: [`.opencode/.issues/2618/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2618)** — the remote issue is a condensed exec summary; this file is the authoritative spec.
>
> **Local artifacts:** `.opencode/.issues/2618/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

**Problem Statement:** The live skill deck has no encounter-side rule governing what an agent does when it meets a deprecated item — a library API, language feature, config key, or wire format — during workflow. Every `deprecat*` match in the live deck is authoring-side or a factual note: measured 2026-10-15 at 10 matches across 4 files via `grep -rn 'deprecat' skills floor.md routing.md AGENTS.md --include='*.md'` from the `.opencode/` submodule root (programming-principles owns the authoring side — clean breaks vs. deprecation cycles; gh-cli and java carry factual notes; `floor.md`, `routing.md`, and `AGENTS.md` return zero). Nothing tells the agent what to do when it *encounters* a deprecation. New code gets written against deprecated surface, and existing reliance on deprecated paths accrues invisibly until it breaks.

**Root Cause / Motivation:** Deprecation handling evolved only on the authoring side. The predecessor spec (.opencode#2458, closed-moot in the local store) identified the same encounter-side gap but targeted retired old-deck machinery — byte-identical six-card inlining, fragment-management registration, reference-standards docs, rules in `.opencode/AGENTS.md` — so the delivery mechanism no longer exists while the gap itself persists in the live deck. The developer re-opened the design in exploration (2026-10-15 session) and re-shaped the contract around one goal: **new code is not developed against deprecated code**; existing reliance is either migrated when effectively free with the work already being done, or made visible via a lightweight ticket.

**Approach Chosen:** A Deprecation Encounter Protocol delivered as progressive disclosure: one canonical protocol document (`guidelines/deprecation-encounter-protocol.md`) carrying the full contract, and compact domain-appropriate slices inlined in the seven encounter-prone skill cards (`implement`, `programming-principles`, `research`, `systematic-debugging`, `spec`, `plan`, `work`), each linked to the canonical doc via the deck's Read-link convention. Slices differ by design, so drift control is link integrity (`reference-integrity` tool), not byte-equality. `floor.md` and `routing.md` are untouched.

**Key Design Decisions** (developer rulings, 2026-10-15 exploration session):

- *Bright line on new code only* — the strict never-build-on-anything rule was rejected as too strict; the absolute rule protects new code, existing reliance is triaged.
- *In-passing swap is compliance, not expansion* — migrating a drop-in replacement inside code already being rewritten needs no ceremony; a non-drop-in migration stops being in-passing.
- *Temporary-use exception, not migration expansion* — when a change cannot proceed without the deprecated item, the agent adjusts the spec with a temporary-use exception carve-out cross-referencing the owning ticket and escalates; the plan's implementable content is unchanged so the approval cascade stays dormant. ("This one seems least intrusive and disruptive to the workflow: a temporary-use exception.")
- *Ticket as the default fallback* — light `[BITROT]` initial spec, triage-and-promote path to a full spec, filed via sub-agent for minimal interruption; proximity/mechanical-ness recorded as metadata. The "closely related / close enough" scope-expansion criterion was abandoned as too vague ("I can't come up with a better criteria, so abandon it") — the agent never widens approved scope on its own judgment; triage authority stays with the developer at the ticket queue.
- *Not-in-use observations are ticketed* — cross-project usage is unknowable from one repository's perspective; tickets also trigger documentation corrections when the real usage picture is known.
- *Evidence-based trigger only* — a deprecation counts when witnessed in the current environment (annotations, doc notices, changelog entries, compiler/linter warnings, live research with sources); "training data and memory don't count as evidence-based source items normally"; developer-supplied knowledge enters tickets as information, never as trigger evidence.
- *Code-facing scope* — deck-internal staleness stays with the `reference-currency` card; this protocol covers code-facing deprecations only.
- *Pickup-only enforcement* — "only test the core portions to ensure the new directive is picked up properly, we do not need to test multiple scenarios, the real test will be its usage and any bug reports coming back from the dev."
- *Delivery* — "progressive disclosure in the specific domain skill cards (with appropriate markdown links). we do not want to fatten floor.md."

## 2. Not Included

- **Deck-internal staleness** — retired cards, dead links, stale routing references remain `reference-currency`'s territory; this protocol covers code-facing deprecations only (R-7).
- **Changes to `floor.md` or `routing.md`** — progressive disclosure keeps the always-injected surfaces untouched (NREQ-1).
- **Modification of existing authoring-side deprecation text** — programming-principles' compatibility guidance and all other output-side text is unchanged (additive-only, REQ-A1).
- **Byte-identical inlining and fragment-management machinery** — retired old-deck mechanism, absent from the live deck; slices differ by design and drift control is link integrity (NREQ-3).
- **A multi-scenario behavioral matrix** — the triage branches (ticketing variants, platform routing branches, carve-out choreography) are production-verified through usage and developer bug reports, not clean-room scenarios (NREQ-2).
- **A ticket urgency/severity taxonomy** — tickets carry encounter metadata as defined; urgency classification is the developer's triage call.
- **Agent-initiated scope expansion** — the "closely related" criterion is abandoned; cheap nearby migrations surface as ticket metadata, never as agent-initiated expansion proposals.

| Code | Definition |
|------|------------|
| REQ-A1 | Additive-only constraint — the spec adds encounter-side handling only; no existing deck rule or authoring-side deprecation text is modified or superseded |
| NREQ-1 | No changes to `floor.md` or `routing.md` — the always-injected surfaces stay byte-identical |
| NREQ-2 | No multi-scenario behavioral matrix — enforcement is placement string evidence plus one pickup behavioral check (developer ruling) |
| NREQ-3 | No fragment-management machinery and no byte-identical inlining — retired old-deck mechanism, absent from the live deck |

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The canonical protocol document exists at `guidelines/deprecation-encounter-protocol.md` and states the complete protocol defined by R-1 through R-7 and R-13 | string | Static text check: each requirement's protocol element present in the document |
| SC-2 | Each of the seven SKILL.md cards (implement, programming-principles, research, systematic-debugging, spec, plan, work) carries its domain-appropriate protocol slice with a Read-link to the canonical document | string | Static text check: slice + link present in each of the seven card bodies |
| SC-3 | All agent-facing Read-links introduced by SC-1/SC-2 resolve to existing files and sections | string | `./.opencode/tools/reference-integrity --scan` exits 0 |
| SC-4 | No existing rule in any touched file is modified or superseded, and `floor.md` and `routing.md` are byte-identical to their pre-change state | string | `git diff <feature-branch-base> -- floor.md routing.md` is empty; reviewed diff of touched files shows additive-only hunks |
| SC-5 | Deck validation is green after all edits | string | `./.opencode/tools/skildeck lint` exits 0 |
| SC-6 | An agent whose context includes a slice-carrying card encounters a deprecated item witnessed by live evidence in the environment and evidences registration of the directive — the encounter is treated as a deprecation encounter (classified, not ignorable noise), with no new code written against the deprecated surface in the scenario's task | behavioral | tests-v2 clean-room `opencode run` via with-test-home; stderr behavioral evidence of registration and non-reliance (single pickup scenario, per the `behavioral-testing` card) |

Each SC maps to exactly one item in the Items section (items 1-6).

## 4. Requirements

R-1. New code SHALL NOT be developed against deprecated surface: when writing new code, the agent does not reach for a deprecated API, language feature, config key, or wire format.

R-2. Migrating a deprecated usage to its drop-in replacement inside code the change is already rewriting SHALL NOT require ceremony (spec adjustment, escalation, or ticket) — it is compliance with R-1, not scope expansion. A migration that is not drop-in (behavioral differences, new testing obligations) stops being in-passing and follows R-3 or R-4.

R-3. When the current change cannot proceed without a deprecated item (load-bearing in the touched path, no route around), the agent SHALL adjust the current spec with a temporary-use exception carve-out that cross-references the owning `[BITROT]` ticket, and SHALL escalate to the developer with the proposed carve-out text. The deprecation-touching portion pauses until the developer ratifies; the remainder of the change proceeds. The plan's implementable content is unchanged, so linked plan approvals are not revoked by the carve-out itself.

R-4. Any encountered deprecated usage that is neither handled by R-2 nor R-3 SHALL be recorded as a light `[BITROT]` initial spec in the module that owns the deprecated item, filed via a sub-agent for minimal interruption. Filing SHALL search the tracker for an existing `[BITROT]` ticket on that deprecation before any POST: found → append the encounter evidence as a comment; not found → create with the `[BITROT]` title prefix and the bitrot label (the bitrot label is created with the first filing if the platform does not yet carry it). The ticket cites the witnessed evidence and carries proximity/mechanical-ness metadata; it follows the triage-and-promote path — developer triage may promote it to a full spec via the normal pipeline.

R-5. Deprecated items not currently used in this repository SHALL also be ticketed (R-4 path): usage may exist in sibling projects and is unknowable from one repository's perspective; when raised, the developer may direct documentation updates reflecting actual usage.

R-6. The protocol SHALL trigger only on evidence witnessed in the current environment — deprecation annotations, documentation notices, changelog entries, compiler or linter warnings, or live research findings with sources. Training data and agent memory SHALL NOT count as evidence-based source items (normally). Developer-supplied knowledge enters a ticket as information, never as trigger evidence.

R-7. The protocol SHALL apply to code-facing deprecations (library APIs, language features, config keys, wire formats). Deck-internal staleness (retired cards, dead links, stale references) remains governed by the `reference-currency` card.

R-8. The protocol SHALL be delivered as progressive disclosure: compact domain-appropriate slices inlined in seven SKILL.md cards — implement, programming-principles, research, systematic-debugging, spec, plan, work — each linked to the one canonical protocol document. Slice content differs per domain by design: implement carries the in-passing/ticket/carve-out trigger set; programming-principles extends its existing Compatibility and deprecation section with the consuming-side mirror; research and systematic-debugging carry observed/dependent encounter handling; spec and plan carry authoring-time encounter handling; work carries a pointer-level mention so the protocol is in context before any file modification.

R-9. Every agent-facing link introduced by the delivery SHALL resolve — validated by `reference-integrity`.

R-10. Content SHALL be additive-only (REQ-A1), and `floor.md`/`routing.md` SHALL remain untouched (NREQ-1).

R-11. Card and guideline edits SHALL keep deck validation green (`skildeck lint`).

R-12. Enforcement SHALL be classified by change nature: placement SCs are string evidence; the pickup SC is behavioral evidence per the `behavioral-testing` card; no multi-scenario behavioral matrix exists (NREQ-2). Production usage and developer-reported bugs are the living verification and sit outside this spec's gate.

R-13. The light `[BITROT]` ticket is a spec-format initial artifact: `[BITROT]`-prefixed title, bitrot label, witnessed evidence with its live source, proximity/mechanical-ness metadata, and a stated promotion path (developer triage → full spec via the normal pipeline). Filing mechanics inherit the `issues` card's platform routing (remote-first reservation, local mirror) rather than re-specifying channel branches; on transient API failure the encounter is never silently dropped — a chat executive summary preserves it for defer-and-retry.

## 5. Items

### Item 1 (SC-1): Author the canonical protocol document

- RED: `guidelines/deprecation-encounter-protocol.md` does not exist, or lacks one of the protocol elements R-1..R-7, R-13 define.
- GREEN: The document states the complete protocol.
- verify: Static text check — each requirement's protocol element present.
- commit: Canonical doc + test artifact.

### Item 2 (SC-2): Inline domain slices in the seven cards

- RED: Static check finds no protocol slice (or no Read-link to the canonical doc) in at least one of the seven cards.
- GREEN: All seven cards carry their domain-appropriate slice with the link, per R-8's per-card content guidance.
- verify: Static text check — slice + link present in each of the seven cards.
- commit: Seven card edits + test artifact.

### Item 3 (SC-3): Link integrity passes

- RED: `reference-integrity --scan` reports broken or malformed references among the introduced links.
- GREEN: Exit 0 — all new agent-facing links resolve.
- verify: Tool run.
- commit: Link fix + test artifact.

### Item 4 (SC-4): Untouched-surface verification

- RED: `git diff <feature-branch-base>` shows modifications to `floor.md`/`routing.md`, or non-additive hunks in touched files.
- GREEN: Both always-injected files byte-identical; all hunks in touched files additive.
- verify: git diff review against the feature-branch base.
- commit: Verification artifact.

### Item 5 (SC-5): Deck validators green

- RED: `skildeck lint` reports findings on the modified deck.
- GREEN: Exit 0.
- verify: Tool run.
- commit: Validator run artifact.

### Item 6 (SC-6): Behavioral — directive pickup

- RED: Clean-room `opencode run` on the unmodified deck — the agent treats the deprecated item as ignorable noise or builds new code on it (no registration evidence in stderr).
- GREEN: Clean-room `opencode run` post-change — the agent evidences registration of the directive: classified encounter, no new code against the deprecated surface.
- verify: tests-v2 clean-room `opencode run` via with-test-home; stderr behavioral evidence; single pickup scenario; `behavioral-testing` card requirements apply.
- commit: Scenario + harness wiring.

Dependency DAG: 1 → 2 (slices link to the doc) → 3, 4, 5, 6 (each downstream of the slices; 3-6 mutually independent).

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `guidelines/` directory | Canonical doc home — pattern precedent `guidelines/ainglish-writing-discipline.md` | Satisfied — exists (session check 2026-10-15) |
| Seven SKILL.md cards | Slice targets (SC-2) | Satisfied — all seven exist (session check 2026-10-15) |
| `.opencode/tools/reference-integrity` | Link-integrity instrument (SC-3) | Satisfied — exists; usage read (2026-10-15) |
| `.opencode/tools/skildeck` | Deck validator (SC-5) | Satisfied — exists; `lint` action confirmed (2026-10-15) |
| `.opencode/tests-v2/test-enforcement.sh` + `tests-v2/with-test-home` | Behavioral harness hosting the pickup scenario (SC-6); the `behavioral-testing` card governs run requirements | Satisfied — both exist (session check 2026-10-15) |
| Deck governance (`skill-creator` card) | Implementation edits deck content (cards + guidelines doc) — the admission gate applies at implement time | Process note — pipeline requirement, not a file dependency |
| Predecessor: `.opencode#2458` | Identified the encounter-side gap; closed-moot locally (delivery mechanism retired); remote still open as of 2026-10-15 — its disposition is a separate developer decision | Informational — this spec carries the gap forward under the live deck's contract |
| Cross-spec coordination | Other open deck specs may touch the same seven cards; additive-only slices minimize conflict surface; sequencing is a coordination note, not a scope change | Qualitative — no counts asserted (prior-session measurements are stale) |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1, SC-6 | Phase 1 |
| R-2 | SC-1 | Phase 1 |
| R-3 | SC-1 | Phase 1 |
| R-4 | SC-1 | Phase 1 |
| R-5 | SC-1 | Phase 1 |
| R-6 | SC-1 | Phase 1 |
| R-7 | SC-1 | Phase 1 |
| R-8 | SC-2 | Phase 1 |
| R-9 | SC-3 | Phase 1 |
| R-10 | SC-4 | Phase 1 |
| R-11 | SC-5 | Phase 1 |
| R-12 | SC-6 | Phase 1 |
| R-13 | SC-1 | Phase 1 |

Every requirement traces to at least one SC; every SC traces to at least one requirement (SC-1 ← R-1..R-7, R-13; SC-2 ← R-8; SC-3 ← R-9; SC-4 ← R-10; SC-5 ← R-11; SC-6 ← R-1, R-12).

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Live `deprecat*` grep | evidence | scoped grep from the `.opencode/` submodule root | 10 matches across 4 files (programming-principles SKILL.md + references/practices.md — authoring side; gh-cli SKILL.md, java SKILL.md — factual notes); zero matches in floor.md, routing.md, AGENTS.md; zero encounter-side (command: `grep -rn 'deprecat' skills floor.md routing.md AGENTS.md --include='*.md'`, 2026-10-15) |
| Seven SKILL.md cards | code | `.opencode/skills/{implement,programming-principles,research,systematic-debugging,spec,plan,work}/SKILL.md` | Existence checks 2026-10-15; header-structure scan (programming-principles uses `##` sections incl. "Compatibility and deprecation"; other six use flat numbered-rule style) |
| `guidelines/` directory | doc | `.opencode/guidelines/` (contains `ainglish-writing-discipline.md`) | Existence check 2026-10-15 — pattern precedent for the canonical doc home |
| reference-integrity tool | code | `.opencode/tools/reference-integrity` | Usage docstring read 2026-10-15 — validates agent-facing Read-links resolve; fails closed on malformed input |
| skildeck tool | code | `.opencode/tools/skildeck` | `--help` read 2026-10-15 — `lint` action confirmed |
| tests-v2 behavioral harness | code | `.opencode/tests-v2/test-enforcement.sh`, `.opencode/tests-v2/with-test-home` | Existence checks 2026-10-15 |
| Predecessor spec #2458 | doc | `.opencode/.issues/2458/spec.md` | Read 2026-10-15 — closed-moot locally (sweep verdict: delivery mechanism retired); remote confirmed open via `gh issue view` 2026-10-15 |
| Exploration session | developer rulings | this conversation, 2026-10-15 | Every design decision in §1 Key Design Decisions quotes or paraphrases a developer statement from the session |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery latency, not tool calls. Correctness is the only metric.

- **SC-1:** One static read of the canonical doc — seconds. Skipping costs the protocol its single source: slices point at nothing, and every encounter decision falls back to whatever the agent recalls.
- **SC-2:** One static pass over seven cards — seconds. Skipping means the directive is absent at the surfaces where encounters happen, and the protocol exists only as a document nobody loads.
- **SC-3:** One tool run — seconds. Skipping costs broken-link drift: a moved or renamed doc silently orphans every slice, discovered only when an agent follows a dead link mid-encounter.
- **SC-4:** One diff review — seconds. Skipping risks silent erosion of the always-injected surfaces — exactly the fattening the developer prohibited.
- **SC-5:** One tool run — seconds. Skipping means a malformed card ships and every subsequent deck operation inherits the defect.
- **SC-6:** Minutes of clean-room execution — the single behavioral spend. Skipping means "picked up properly" is asserted, not shown; the protocol ships as text with no evidence any agent acts on it. Deeper triage behavior (ticketing variants, carve-out choreography) is deliberately production-verified per the developer's ruling.

## 11. Edge Cases

**Input boundaries:**
- *Condition:* An existing `[BITROT]` ticket already covers the deprecation. *Expected behavior:* The filing path appends the encounter evidence as a comment — no duplicate ticket (search-before-POST). *Resolution:* R-4.
- *Condition:* The owning module of the deprecated item cannot be resolved. *Expected behavior:* The filing agent resolves ownership from encounter context (file path, config namespace, dependency identity); if still unresolvable, it SHALL NOT guess — the unresolved ownership is surfaced in the ticket for the developer. *Resolution:* R-4 metadata; a misdirected ticket is worse than an unresolved one.

**State transitions:**
- *Condition:* Encounter classification at the moment of writing new code. *Expected behavior:* The bright line applies pre-emptively — the agent does not wait for a completed encounter to trigger triage; choosing a deprecated call for new code is itself the encounter. *Resolution:* R-1.
- *Condition:* In-passing vs. migration boundary. *Expected behavior:* A drop-in replacement inside already-rewritten code is compliance (R-2); anything requiring new testing or behavioral reconciliation exits the in-passing path to R-3 or R-4. *Resolution:* R-2's second sentence.

**Failure modes:**
- *Condition:* Transient API failure during ticket filing. *Expected behavior:* A chat executive summary preserves the encounter; defer-and-retry on availability — never silently dropped. *Resolution:* R-13.
- *Condition:* Developer declines the proposed carve-out. *Expected behavior:* The deprecation-touching portion reshapes or stops; the `[BITROT]` ticket stands regardless — the pending breakage exists independent of this change's fate. *Resolution:* R-3.
- *Condition:* Behavioral run killed by timeout or stale harness lock. *Expected behavior:* Harness recovery per the `behavioral-testing` card. *Resolution:* SC-6 instrument.

**Concurrency:**
- *Condition:* Two encounters of the same deprecation near-simultaneously. *Expected behavior:* Search-before-POST narrows but does not eliminate duplicate creation; a duplicate `[BITROT]` ticket SHALL be consolidated by appending its evidence to the first and closing the duplicate. *Resolution:* R-4 plus the consolidation rule.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-10-15 | Initial spec authored from the exploration session (design finalized by the developer's "proceed to spec creation"). Contract re-shaped from predecessor .opencode#2458: bright line narrowed to new code; in-passing swap legalized; carve-out re-scoped to a temporary-use exception; "closely related" criterion abandoned; delivery re-based onto progressive slices + canonical guideline doc; enforcement reduced to pickup-only. | Developer-directed exploration and rulings, 2026-10-15 session | Developer |

---

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
