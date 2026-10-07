# Spec: .opencode#2554 — Ainglish-informed writing discipline: consumer-side evergreen ambiguity-grammar reference, floor trigger line, forwards-only whole-card adoption

Provenance: developer brainstorm 2026-10-07, authorized for spec creation in-session ("approved for spec creation"). Observed failure: ambient accidental ambiguity in normative prose — invisible to the developer's own review, because the developer reads intent while the agent reads words — producing agent misexecution. Mined evidence from this deck's own stores (all read 2026-10-07): scope/utterance misbinding dominates the strongest incidents — `.opencode#1011` (sub-agent executed a referenced cleanup task in full, deleting unrequested branches), `.opencode#1860`/`.opencode#492` ("This PR seems to contain other work. Why?" read as fix-authorization → force-push), `.opencode#2293` ("NEVER create a submodule-only PR in ANY context" misapplied to block submodule repos' own PRs — "the prohibition language does not scope itself to the parent repo"), `.opencode#1031` (user's "fail" mapped to a proceed signal), `.opencode#2319` (bare `#N` references → wrong-repo epidemic, ~25 migrated issues), `lessons-learned/session-2026-06-29` Defect 2 with the `writing-plans-skill-contradiction` research card (the deck's own wording "executes steps inline" overrode the abstract gate rule), `.opencode#2322` (solve/plan tool-model conflation), `.opencode#1650` audit (plan writer treated spec omission as invitation to elaborate). Patterned recurrence: the "complaint = authorization" family recurs verbatim across ≥4 dated sessions; deck-debt ledger `#2534`: "lexical checks are gameable; the founding defect." Developer goals for the fix, stated this session: more accurate and better context-anchored text for the agent; fewer tokens secondary.

## Problem

Ambiguity is a property of English itself, not of individual defective sentences ("ambiguity is built into English, so it is everywhere" — developer, this session). Incident-by-incident remediation therefore never converges: the deck fixed each mined instance and the same misbinding family recurred across sessions. The failure is invisible at exactly the layer that reviews it — human review sees intent, so it cannot catch ambiguity it cannot perceive. Detection must live with the agent, at write-time (authoring) and read-time (consuming).

The Ainglish register (ainglish.org — an agent-built, measurement-gated, CC0 dialect of English for agent-to-agent communication; verified live 2026-10-07) offers a consumer-ready grammar of ambiguity whose rule families map onto the dominant incident classes. The deck has no writing discipline for normative prose today: precision practices exist scattered (RFC-2119 keyword usage, provenance lines, imperative-form research) with no shared home and no trigger that reaches every authoring context.

## Decisions (developer-stated unless noted)

1. **Discipline, not dialect adoption.** General dialect rules — the ambiguity grammar: (a) actor binding of "we"/pronouns; (b) distributive vs collective plurals; (c) missing evidence vs unmade decision; (d) claim confidence + falsifier anchoring. Applied by judgment wherever the agent writes normative prose. Ainglish constructs are optional instrumentation: plain English that achieves the same disambiguation satisfies the discipline equally. No construct-counting, no mechanical enforcement anywhere in the deck ("general dialect rules being used. not some sort of fan-boy adherence pedantically").
2. **Consumer-side only.** No Colony identity, no write path, no participation in the register's development ("only interested in using it. consumer side only").
3. **Evergreen.** The reference material cites the live register and flagship catalogue; consumers consult latest available data at use-time ("evergreen based on latest available data"). The register's own rules make this safe: amendment is declared supersession and deprecation is visible, so live consumption cannot silently change meaning — the residual obligation is read-time consultation, not snapshotting.
4. **Cite-not-mirror.** The deck declares the trigger and the boundary conditions; the register carries its own rules. Self-apparent register rules (losslessness, "passed ≠ applied", rejection-as-evidence) bind without re-declaration in deck law ("Ainglish should have some self-apparent rules in addition to anything formally declared"). No register content is copied into the deck.
5. **Scope: everything the agent writes or acts on** ("anything the opencode agent touchs and uses") — deck cards, specs, plans, chat, commits, PRs, issues, code comments. Intensity follows normativity: rules, authorizations, and scope statements get the full discipline; descriptive prose gets none.
6. **Forwards-only, whole-card-on-touch.** Existing content is grandfathered ("forwards only usage. not retroactive unless a card is 'touched'"). A substantive write to a card converts the entire card under the discipline ("whole-card-on-touch"). Touch = substantive write — an edit that carries or alters normative content; purely mechanical fixes (typos, link rot, formatting) do not convert. The threshold was delegated ("don't care") and is resolved here as stated; the definition rides in the reference material so it governs all future touches.
7. **Trigger placement (author position, carried for review).** A minimal floor line carries the trigger — consult the writing discipline when authoring normative prose — pointing to the reference material; the discipline itself lives in the reference file, not the floor. Rationale: universal scope requires reachability in cardless contexts (chat responses load no skill cards), and chat is where the dominant incident class lives; a pointer line preserves floor leanness while buying universal reach.
8. **Losslessness safeguard.** Deck prose stays plain English that happens to be precise; a disambiguation unreadable to a reader without the register loaded has failed the register's own anti-cipher charter and does not belong in deck prose.
9. **Risks named for the record:** register deprecation stranding deck usage (visible under evergreen consumption; remediable); avoidance pressure from the whole-card conversion tax (accepted via the whole-card choice); decoration dependence (the discipline is dead unless actually consulted — the behavioral criteria watch for this).

## Fix shape

| Artifact | Change |
|---|---|
| `floor.md` | Gains exactly one trigger line: when authoring normative prose in any channel — anything binding an actor, granting or withholding authorization, or stating scope — consult the deck's writing discipline at `guidelines/ainglish-writing-discipline.md`. Pointer form only; no worked content. |
| `guidelines/ainglish-writing-discipline.md` (new) | The reference material: the four ambiguity-rule families with worked examples mapped to the incident classes; the losslessness boundary; the anti-pedantry boundary (constructs optional, plain-English disambiguation equally satisfying, no construct-counting); the scope statement; the adoption rules (forwards-only, whole-card-on-touch, substantive-touch definition); the consumer/evergreen posture with live register URLs (ainglish.org register and flagship catalogue) and the read-time consult instruction. Provisions the `guidelines/` surface, which the floor's governance line and the routing index already name and govern. |
| deck-debt ledger (issue store) | Admission-gate record per the deck-governance card: observed-failure evidence, consumer, mechanism, predicate classification, domain match, what-it-replaces accounting, always-loaded surface analysis. |

Untouched by this change: `routing.md` (already routes `guidelines/` edits to deck governance), every skill card (the floor line is the single trigger; no per-card citations), and the tests-v2 harness (used as-is).

## Admission gate (deck-governance card)

1. **Observed failure** — the incident record in Provenance: patterned, traceable to store paths, recurring across sessions.
2. **Consumer** — the opencode agent, at every authoring moment (floor trigger); agents consuming marked prose (read-time consult).
3. **Mechanism** — the floor trigger line plus the referenced guideline file; no routing-entry change needed.
4. **Predicate classification** — the discipline is intent-decidable: judgment decides when a sentence is high-risk and which rule applies; scripts are forbidden. The fact-decidable components are file facts (existence, pointer, links) verified about the change's own artifacts — not runtime scripted enforcement of prose.
5. **Domain match** — Ainglish targets agent-to-agent prose; deck and spec prose is agent-facing (agents are the primary readers) — same domain. In-domain evidence: the mined incidents are deck-domain ambiguity failures, and the rule families map onto the dominant classes (actor binding → #2293/#1011/#1031; claim confidence → the unhedged-claim lessons; known-vs-decided → #1650's omission-as-invitation). The distributive/collective family has no clean recorded incident; it is taught as general grammar, without an incident-backed construct-adoption claim.
6. **Root-agnostic** — the new deck content carries no root-repo names and no absolute paths; the register URLs are public external resources, not per-root facts.
7. **What it replaces** — nothing is displaced; net growth is one pointer line plus one reference file. The alternative shape (per-card mandates in every authoring card) would be strictly larger. The floor's halt-on-unsure rule is armed with concrete vocabulary, not replaced.
8. **Always-loaded surface discipline** — the floor line qualifies because it must be visible before any card dispatch (it shapes every authoring moment, including cardless ones); it is held to pointer form so the slip cost is one line.

## Success criteria

### SC-1 (structural) — scope containment

The change touches only `floor.md` and `guidelines/ainglish-writing-discipline.md` in the deck tree.

- **Verify:** `git diff --stat` for the change shows exactly those two paths and no others.

### SC-2 (structural) — floor trigger line

`floor.md` contains a trigger line directing consultation of the writing discipline when authoring normative prose, pointing at `guidelines/ainglish-writing-discipline.md` by relative path; all other floor content is byte-identical to its pre-change state.

- **Verify:** read `floor.md`; the directive and the relative-path pointer are present; the diff shows no other floor modification.

### SC-3 (structural) — discipline content complete

`guidelines/ainglish-writing-discipline.md` states: (a) the four ambiguity-rule families — actor binding of "we"/pronouns, distributive vs collective plurals, missing evidence vs unmade decision, claim confidence + falsifier — with worked examples mapped to the incident classes; (b) the losslessness boundary; (c) the anti-pedantry boundary — constructs optional, plain-English disambiguation equally satisfying, no construct-counting; (d) the scope statement — all agent-authored prose, intensity following normativity; (e) the adoption rules — forwards-only, whole-card-on-touch, touch = substantive write with mechanical fixes exempt; (f) the read-time instruction to consult the current register when consuming marked prose.

- **Verify:** read the file; all six elements present.

### SC-4 (structural) — cite-not-mirror, evergreen

The guidelines file embeds no register entry definitions and no snapshot of register content; it cites the live register and flagship catalogue by URL and instructs use-time consultation of latest available data.

- **Verify:** read the file; live URLs present; no copied construct definitions.

### SC-5 (structural) — root-agnostic, links resolve

The new content contains no root-repo names and no absolute paths; every link the change adds resolves.

- **Verify:** grep the two changed deck paths for the root repository name and absolute-path patterns (zero hits); `./.opencode/tools/reference-integrity --scan` exits 0.

### SC-6 (behavioral) — write-side binding

An agent authoring normative prose under the loaded discipline produces text whose actor bindings are explicit: in a fixture sentence where bare "we" would misbind, the produced artifact leaves no actor binding to inference.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — artifact-generating behavioral run via a scenario in `tests-v2/behaviors/` with a fixture requiring the agent to author a normative statement carrying an actor-binding hazard; clean-room evaluation of `session.yaml` confirms explicit binding. A clarification halt counts as compliant only where the fixture genuinely underdetermines the actor.

### SC-7 (behavioral) — no pedantry

The agent satisfies the discipline with plain English where that is the natural solution; it does not insert Ainglish constructs ritually, and no deck artifact counts or scores construct presence.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run with a plain-English-solvable fixture; clean-room evaluation confirms disambiguated plain English with no ritual construct insertion; grep over the change confirms no construct-counting script exists.

### SC-8 (behavioral) — mechanical fix does not convert

An agent making a purely mechanical fix (typo, link rot, formatting) to a grandfathered card leaves the card otherwise unconverted — no whole-card rewrite occurs.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run with a mechanical-fix fixture on a grandfathered card; clean-room evaluation confirms the fix landed and the card's other content is unchanged.

### SC-9 (behavioral) — substantive edit converts the whole card

An agent making a substantive edit to a grandfathered card delivers the entire card under the discipline, not just the edited passage.

- **Verify:** two-SC pattern per `tests-v2/AGENTS.md` — behavioral run with a substantive-edit fixture on a grandfathered card; clean-room evaluation confirms the whole card's normative prose comes back disciplined.

### SC-10 (structural) — governance compliance

The change passes the deck's own admission gate as recorded: the deck-debt ledger entry carries the observed-failure evidence, consumer, mechanism, predicate classification (intent-decidable, judgment-only), domain match, and what-it-replaces accounting; the new guidelines file carries provenance and license headers.

- **Verify:** read the ledger entry and the two changed files; the six ledger elements and both headers are present.

## Out of scope

- Participation in the register's development (proposing, measuring, voting, Colony identity) — consumer side only, per the developer.
- Retroactive conversion of untouched deck content — forwards-only; whole-card-on-touch governs future edits only.
- Pinning or snapshotting register content into the deck — the evergreen posture replaces snapshots with use-time consultation of the live, verifiable register.
- Per-card discipline citations across the skill cards — the single floor trigger reaches every authoring context; duplicating it per card would fatten each card and drift between copies.
- A dedicated dispatch skill card for Ainglish — the trigger is already universal via the floor line; a second dispatch surface would duplicate it.
- Any scripted ambiguity detection, lexical scanning, or construct-counting enforcement — intent-decidable; scripts forbidden; static checks on judgment are the deck's founding defect.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
