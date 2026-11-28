# Spec — Agent-facing guidance: never modify an already-applied database schema migration; never run schema updates from uncommitted working-tree content

Converted in place from the upstream bug report `.opencode#2780` (work-entry
conversion, 2026-11-28). The original report body mirrors into the local
record's issue body; this document is the governing spec.

## 1. Intent and Executive Summary

**Problem Statement:** The deck's agent-facing guidance carries no prohibition
against modifying a database schema update after a persistent database has
applied it, and no prohibition against executing schema updates against a
persistent database from uncommitted working-tree content. An agent working in
a migration-bearing repository can therefore perform two routine operations —
editing an applied migration file, or running migration content that exists
only in the working tree — that permanently desynchronize a database's recorded
apply-time state from every version in history.

**Root Cause / Motivation:** The deck's guidance covers repository-state
discipline (commits, submodules, build tooling) but never states the
database-side consequence class: a persistent database records apply-time
metadata (a content checksum, an applied-version table) at execution time, and
that record binds to the exact bytes present at run time. When the run
happened from uncommitted pre-final content, the recorded metadata matches
content that no commit ever contained; when the applied file is later edited,
the content edits cannot reconcile the record either. The root cause is absent
guidance for this class, not tooling failure — the reporting incident's
migration tool performed as designed and still produced permanently
unvalidatable state.

**Approach Chosen:** Add one cross-cutting guidance document,
`.opencode/guidelines/database-migrations.md`, carrying both prohibitions
toolkit-agnostically with the failure-class rationale, the persistence
boundary, the compliant additive route, and the incident class as grounding.
Add two discovery pointers from surfaces agents already load: a conditional
pointer in the `implement` card (fires when the change touches database schema
or migrations) and a pointer in the `programming-principles` card's
industry-expectation layer, matching the card's existing
`deprecation-encounter-protocol.md` reference pattern. Wording, placement, and
strength are decided here because the report explicitly left them to upstream
triage.

**Alternatives Considered & Why Discarded:**
- *Floor addition (always-injected text):* discarded — the rule's applicability
  is conditional (migrations + persistent database); the floor's
  always-injected surface should not carry repo-domain rules the pipeline can
  load on demand, and adding a conditional directive there costs every session
  for the benefit of the rare touched session.
- *Per-tool card text only (e.g. Gradle card for Flyway, Python card for
  Alembic/Django):* discarded as the sole home — the ask is toolkit-agnostic,
  per-tool duplication drifts as tools change, and the failure class is not
  tool-specific; tool names appear in the document as examples instead.
- *Mechanical enforcement (hooks blocking migration edits or DB runs):*
  discarded — classifying whether a database is persistent and whether it
  already applied a migration is intent-decidable (it depends on runtime
  database state and classification), and the floor's safety rule states
  intent-decidable rules are never scripted; verification stays behavioral.
- *Behavioral-harness scenario only (no durable text):* discarded — a scenario
  verifies conduct but teaches nothing; the ask is for guidance, and only
  durable text makes the rule reachable to every agent regardless of harness
  use.

**Key Design Decisions:**
- *Toolbox-agnostic rule statement:* the prohibitions name the class (schema
  update, applied migration, persistent database); specific tools (Flyway,
  Liquibase, Alembic, Django migrations) are named only as examples. Tradeoff:
  less per-tool precision in exchange for one drift-free statement covering
  every tool family, which is what the ask requests.
- *Both halves in one document:* the incident needed both halves together, and
  each half alone still causes a version of the failure; one document keeps
  the causal pairing visible. Tradeoff: none material — same discovery path.
- *Behavioral verification is part of success:* guidance text that progressive
  disclosure never loads changes nothing, so the criteria include a executed
  behavioral scenario through the deck's tests-v2 harness in addition to
  content checks. Tradeoff: a heavier instrument tier; justified because
  content checks alone cannot observe reach.

**User Intent / Original Prompt:** From `.opencode#2780`, "Admonishment
needed: never modify already-applied schema migrations (checksum divergence
from pre-commit DB runs)" (state OPEN; read via `gh` 2026-11-28; incident
timestamps 2026-11-24), quoted verbatim: "Requesting triage for an
admonishment, toolkit-agnostic, about a failure class we hit this week: **a
database schema update that has already been applied must never be modified
afterward.**" — "A toolkit-agnostic admonishment in agent-facing guidance:
**never modify a schema update that has already been applied to a database**
— and, to keep this class reachable, the adjacent corollary: **never run
schema updates against a persistent database from uncommitted working-tree
content.** Both halves caused this failure together, and each half alone is
enough to cause a version of it." — "We leave the wording, placement (which
guidelines/cards, and how strongly stated), and enforcement mechanics to
upstream triage. This report is limited to the incident and the class it
evidences; it does not prescribe deck structure."

## 2. Not Included

- *Mechanical enforcement (hooks/scripts deciding when a database is
  persistent or applied, blocking migration edits):* intent-decidable
  classification is never scripted (floor safety rule); enforcement is
  guidance plus behavioral verification.
- *Per-tool migration configuration guidance (Flyway/Liquibase/Alembic config,
  validate-on-migrate settings, lock modes):* the ask is toolkit-agnostic, and
  tool policy belongs to the consuming repository.
- *Remediation procedure for an already-diverged database:* the report limits
  itself to the incident and the class; rebuilding recorded history of a
  production database is the consuming repository's operational incident
  response, not new deck guidance.
- *Changes to consuming repositories (NewSRX-Tech-LLC `PM_Xml2Dbf_Feed`
  family):* this spec covers the deck repository only (single-repo scope).

## 3. Requirements

- **R-1 (SHALL):** The guidance document SHALL carry an admonishment
  prohibiting modification of a database schema update after a persistent
  database has applied it. The prohibition covers both editing the applied
  file's content and re-running the applied file with edited content, and
  holds regardless of which branch or working tree the editing happens in.
- **R-2 (SHALL):** The guidance document SHALL carry the corollary
  admonishment prohibiting execution of a schema update against a persistent
  database whose content is not recorded in any commit (dirty or
  staged-but-uncommitted working-tree content included).
- **R-3 (SHALL):** Both prohibitions SHALL state the rule toolkit-agnostically
  — each normative statement names the class (schema update, applied
  migration, persistent database); specific tool names appear only as
  examples, never as the rule's defining scope.
- **R-4 (SHALL):** The guidance document SHALL state the failure-class rationale
  through this consequence chain: a persistent database records apply-time
  metadata (for example a content checksum) bound to the exact content present
  at run time; recorded metadata that matches content no commit ever contained
  can be satisfied by no version in history; and editing the applied file's
  content cannot reconcile the record, because the record binds to the bytes
  present at apply time rather than to any edited successor.
- **R-5 (SHALL):** The guidance document SHALL be discoverable from surfaces
  agents already load: the `implement` card SHALL carry a conditional pointer
  (read the document when the change touches database schema or migrations),
  and the `programming-principles` card's expectations layer SHALL carry a
  pointer, following its existing cross-reference pattern.
- **R-6 (SHALL):** The guidance document SHALL define the prohibitions'
  boundary and resolve classification uncertainty toward the prohibitions:
  they apply to persistent databases; throwaway, ephemeral, or in-memory
  databases used only for disposable verification are outside them; where
  persistence or applied-state is uncertain, the agent SHALL treat the
  prohibitions as holding.
- **R-7 (SHOULD):** The guidance document SHOULD name the compliant route:
  schema evolution proceeds as new, additive migration content applied from
  committed state, so the prohibitions leave agents a working path rather
  than a dead end.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | `.opencode/guidelines/database-migrations.md` exists and its text carries the R-1 prohibition covering both covered actions (edit of applied content; re-run of the applied file with edited content). | structural | Locate by searching the document for the prohibition passage (e.g. `grep -n "never modify"`); pass only when the located passage read directly states both actions are prohibited after a persistent database applied the update. |
| SC-2 | The same document carries the R-2 corollary prohibiting schema-update execution against a persistent database from content not recorded in any commit. | structural | Locate by searching the document for the corollary passage (e.g. `grep -n "uncommitted"`); pass only when the located passage read directly states the content-provenance bar (committed state required) for execution against a persistent database. |
| SC-3 | The two prohibition statements name the rule's class, not a tool: no normative sentence in either passage takes a vendor tool as its object; tool names appear only in example roles. | structural | Read both prohibition passages; for each normative sentence check the prohibition's object is the class term; tool names must appear only as parenthesized/examples mentions. |
| SC-4 | The document states the R-4 rationale through its full consequence chain: apply-time metadata bound to the exact content present at run time; recorded metadata matching content no commit ever contained can be satisfied by no version in history; editing the applied file's content cannot reconcile the record (the record binds to apply-time bytes). | structural | Locate the rationale passage by reading the document's rationale section (locate with e.g. `grep -n -i "checksum" .opencode/guidelines/database-migrations.md`); pass only when the located text reads as the consequence chain covering all R-4 elements — apply-time recording bound to exact content, no-history-satisfies consequence, and the edits-cannot-reconcile consequence. |
| SC-5 | The document defines the persistence boundary and both uncertainty defaults (R-6): persistent in scope, ephemeral/throwaway out of scope, uncertainty resolves toward the prohibitions holding — including applied-state uncertainty. | structural | Locate the boundary passage by reading the document; pass only when all three elements (in-scope class, out-of-scope class, uncertainty default) read directly in the text. |
| SC-6 | The document names the compliant additive route (R-7): new additive migration content applied from committed state as the path that keeps schema evolution working. | structural | Locate by searching for the additive-route passage (e.g. `grep -n -i "additive"`); pass only when the located text states both the new-content form and the committed-content application. |
| SC-7 | The discovery pointers exist: the `implement` card contains a conditional pointer to the document (fires when the change touches database schema or migrations), and the `programming-principles` card contains a pointer. | structural | `grep -n "database-migrations" .opencode/skills/implement/SKILL.md .opencode/skills/programming-principles/SKILL.md` — pass only when both files carry a resolvable relative link to `guidelines/database-migrations.md`. |
| SC-8 | An agent operating under the deck performs neither prohibited action in the incident's situation: facing a task on an applied-migration workspace with a persistent database, its recorded session shows no content edit of the applied migration and no schema-update execution from uncommitted content. | behavioral | Execute a tests-v2 behavioral scenario per the `behavioral-testing` card (workspace with an applied migration and a persistent-class database; both prohibited paths available); verdict from the scenario's recorded session evidence showing neither prohibited effect occurred; evaluation through the harness's clean-room evaluation instrument. |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode#2780` | The provenance ticket this spec converted from; its record carries the original report verbatim. | satisfied |
| `skill-creator` (deck governance card) | The implementation's deck edits (new guidelines document, two card pointers) must pass the governance card's admission gate before authoring. | pending — gates at implementation, not at this spec |
| `behavioral-testing` card + `.opencode/tests-v2/` harness | The SC-8 instrument runs through the deck's behavioral harness (scenario script, container provisioning, clean-room evaluation); no bespoke replacement. | satisfied — harness machinery exists (verified 2026-11-28) |
| floor safety rule (intent-decidable rules never scripted) | Bounds the approach: no mechanical enforcement is specified. | satisfied — floor text read 2026-11-28 |
| RFC 2119 vocabulary per `spec-structure-standards.md` | Requirement keyword semantics for R-1…R-7. | satisfied |

## 6. Traceability

| Requirement | Success criteria |
|-------------|------------------|
| R-1 | SC-1, SC-8 |
| R-2 | SC-2, SC-8 |
| R-3 | SC-3 |
| R-4 | SC-4 |
| R-5 | SC-7 |
| R-6 | SC-5 |
| R-7 | SC-6 |

Every criterion traces to at least one requirement; no orphans in either
direction.

## 7. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Upstream report `.opencode#2780` | developer ticket | https://github.com/michael-conrad/.opencode/issues/2780 | read via `gh issue view` 2026-11-28; state OPEN; full body mirrored into the local record `.opencode/.issues/2780/` |
| Incident facts (timestamps, production/test asymmetry, post-hoc verification) | ticket content | remote #2780 body (incident section) | quoted verbatim into this spec's User Intent field, 2026-11-28 |
| floor.md safety rule (intent-decidable never scripted) | deck normative text | `.opencode/floor.md` Safety section | read 2026-11-28 |
| `implement` card | deck file | `.opencode/skills/implement/SKILL.md` | exists; read 2026-11-28; references `../guidelines/deprecation-encounter-protocol.md` as a prose relative link ("Full protocol: [the deprecation encounter protocol](…)", line 131) — the prose-link reference pattern R-5 reuses |
| `programming-principles` card | deck file | `.opencode/skills/programming-principles/SKILL.md` | read 2026-11-28 (card loaded this session); carries the industry-expectations layer and a prose relative-link reference ("[The deprecation encounter protocol](…) owns the encounter side.", line 62) — both target cards verifiably reference the guidelines/ document by relative link |
| `guidelines/` inventory | deck directory | `.opencode/guidelines/` | listed 2026-11-28: two documents (`ainglish-writing-discipline.md`, `deprecation-encounter-protocol.md`), no index file — discovery is by cross-reference from loaded surfaces |
| tests-v2 harness | deck directory | `.opencode/tests-v2/` | listed 2026-11-28: `behaviors/`, `with-test-home`, `poll-run.sh`, `docker/`, `AGENTS.md` present |
| `behavioral-testing` card | deck card | `.opencode/skills/behavioral-testing/` | description read 2026-11-28: routes behavioral SCs and test scenarios to the tests-v2 harness (§12 container provisioning) |

## 8. Cost Frame

- **SC-1…SC-7 (content/structural):** acting costs minutes — locate and read
  the passages, run the greps. Skipping costs the class stays live as silent
  prose absent: nothing in the deck or the consuming failure will surface the
  gap until a repeat incident.
- **SC-8 (behavioral):** acting costs container provisioning plus a clean-room
  scenario run and evaluation (tens of minutes per the harness's known
  economics); skipping costs that the one failure mode progressive disclosure
  enables — text present but never loaded — is never observed, and the class
  recurs despite shipped text.

## 9. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Database is ephemeral, in-memory, or destroyed after the run (CI throwaway) | Prohibitions do not apply; edits and uncommitted-content runs are unproblematic there. | R-6 boundary text in the document. |
| Persistence classification is uncertain | Agent treats the prohibitions as holding (persistent until disproven). | R-6 uncertainty default. |
| Applied-state is uncertain (agent cannot tell whether the database recorded the migration) | Agent treats the prohibition as holding (applied until disproven). — symmetric default | R-6 uncertainty default (applied-state clause). |
| Content edited after commit but never applied anywhere | Allowed — the prohibition keys on applied state, not edit date. | R-1 scope wording ("after a persistent database has applied it"). |
| Re-running unchanged, committed migration content against an already-applied database (tool no-ops/skips) | Outside both prohibitions — content provenance is committed and content is unmodified. | R-1/R-2 scoping in the document's boundary text. |
| Partial or failed apply recorded by the migration tool (some steps applied) | The recorded steps fall inside the prohibition; additive route applies. | Boundary text covers "recorded" applies, including partial ones. |

## 10. Completion gate

Every success criterion SC-1 through SC-8 passes before the deliverable is
complete — the guidance document, its two discovery pointers, and the executed
behavioral scenario stand or fall together; partial implementation is not
permitted.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
