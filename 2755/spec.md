<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->

# Spec — issues card: validate-yaml artifact-content defects join the agent-owned repair-on-discovery triggers

**Issue:** michael-conrad/.opencode#2755

## 1. Intent and Executive Summary

**Problem Statement.** The deck's on-discovery repair doctrine for issue
stores — the issues card's §6 ticket-state-hygiene and §7
mirror-repair/interrupted-sync triggers — enumerates no trigger for
store-artifact content defects: invalid YAML that the store's own validator
(`local-issues validate-yaml`) names. An agent that reads the cards faithfully
finds no instruction binding repair, so validator findings land in the
developer's chat as an unowned observation and the defective artifacts stay
defective. Field reproduction (consuming repo `NewsRx/hermes-ingest-pubmed`,
2026-11-18): a session's sweep named three defective store artifacts
(`283/audit/validation.yaml`, `31/problem.yaml`,
`89/post-sc-uplift-check.yaml`); the session reported the findings to the
developer as "not repaired — outside this flow's scope" and filed its own
new artifact without touching the defective ones — three findings reported,
zero repaired.

**Root Cause / Motivation.** Two layers compose. The authorization surface
already exists — `floor.md`'s issue-store workspace-maintenance exception
makes reading, writing, and repairing store data agent-owned work that needs
no scope-bearing token, and each store's own `AGENTS.md` carries a hygiene
mandate — but the deck's trigger inventory stops at state divergence and
absent-or-broken records, and the correct procedure (dispatch a sub-agent for
mechanical repairs; the discovering session verifies the clean sweep) lives
only in a developer correction (2026-11-19), not in the deck. The store-local
`AGENTS.md` is not the fix's surface: it is unreadable in a fresh clone before
`local-issues init` runs (its own git-quirks note states this), and it states
the duty without the trigger list, the dispatch procedure, the
sweep-completeness rule, or the emission guidance. It must be solved now:
every session that runs the store's own validator on a defective store
re-derives the disposition with no binding instruction, and the field
evidence shows the report-and-wait disposition recurring until a developer
corrected it.

**Approach Chosen.** Extend the issues card's repair doctrine with an
artifact-content-defect trigger in the same agent-owned class as the §6/§7
triggers: validator findings are repaired on discovery in the same workflow;
mechanical repairs dispatch to a sub-agent under the dispatch-scope doctrine;
the discovering session counts the full sweep, re-verifies it clean, and
records the disposition with the discovering work. Pair the trigger with
emission-side quoting guidance at the validation-record contract (the
dominant field defect source), and bind the disposition at the validator's
own contract — the issues card's CLI reference row.

**Alternatives Considered & Why Discarded.**

1. Rely on the store-local `AGENTS.md` hygiene mandate alone. Discarded: the
   guide lives on the `issues-data` branch and states the duty without the
   trigger list, the dispatch procedure, the sweep-completeness rule, or the
   emission guidance; the deck card is the always-loadable governance surface
   and the trigger family already lives there.
2. Make the `validate-yaml` tool auto-repair what it finds. Discarded: the
   validator's job is surfacing findings (its error taxonomy); repair is
   judgment work over defect shape — per-file root-cause diagnosis,
   content-preserving scalar rewrites — and the discovering session owns the
   verification duty; an auto-repairing tool would erase that duty and the
   repair's provenance record.
3. Add the trigger to `floor.md`. Discarded: the floor already carries the
   authorization surface (the workspace-maintenance exception); the missing
   piece is the owning card's trigger inventory and the tooling contract's
   disposition binding — a floor clause would duplicate a card-side trigger
   family the issues card already owns.

**Key Design Decisions.**

1. The trigger joins the issues card's §7 trigger family (beside
   mirror-repair and interrupted-sync) rather than a new card. Tradeoff: the
   card's trigger list grows — the alternative, a second card, fragments the
   doctrine the field failure showed agents already mis-read.
2. Mechanical repairs dispatch to a sub-agent; the discovering session keeps
   verification. Tradeoff: dispatch coordination costs a round trip; in
   exchange, the discovering session's context stays unburdened by per-file
   repair mechanics, and the verification duty stays with the party that owns
   the disposition record — the field procedure the developer ratified.
3. Repairs preserve record content byte-exactly except the defect itself:
   syntax-only rewrites (folded or quoted scalars, separator removal, shape
   dedent), each asserted against the pre-repair recorded text. Tradeoff:
   byte-exactness costs the repair sub-agent a pre-repair capture step; it
   buys proof that the repair changed no record semantics — the field
   procedure asserted every repaired scalar byte-exact.
4. The sweep is counted, never sampled. Tradeoff: counting costs one
   verification pass over the validator's full output; the field evidence
   (8 of 47 files shown in the first view; the tail-truncated list became a
   stale repair-dispatch premise and the remainder surfaced as a second
   tranche) shows sampling costs a second repair tranche.
5. Emission-side guidance lives at the record contract (the spec card's
   validation-standards reference, which specifies the
   `audit/validation.yaml`-family records) with a cross-reference from the
   trigger. Tradeoff: two surfaces carry the pair — the record family's own
   contract is where an emitting agent reads the format, and the
   cross-reference keeps discovery and emission one doctrine.

**User Intent / Original Prompt.** The developer's statements and the filed
report this spec derives from, quoted verbatim:

- Developer correction, 2026-11-19 (recorded in the filed report):
  *"the agent is always supposed to manage the repairs and maintenance of the
  issues-data branch without user intervention; the issues-data branch is
  managed directly by the agent as a standalone orphaned branch — not kept
  defective."*
- Expected behavior, filed report .opencode#2755 (2026-11-19): *"Store-artifact
  defects surfaced by the store's own tooling (`validate-yaml`) trigger
  repair-on-discovery in the same workflow — the defect never needs a
  developer correction to act on, never stays knowingly defective across
  sessions, and the disposition (repaired, with the sweep re-verified clean)
  is recorded with the work that discovered it."* and *"The repair of
  mechanical content defects (YAML syntax) dispatches to a sub-agent under
  the dispatch-scope doctrine; the discovering session verifies the clean
  sweep and reports."*
- The filed report's lessons, both stated as belonging in the fix (2026-11-19):
  *"(1) … sweep output must be counted/verified, not sampled. (2) The
  record-emission pattern (plain scalars carrying `key:`-pattern prose) is
  the systemic source — … so the deck fix should pair the repair trigger
  with emission-side quoting guidance."*
- Observed failure, 2026-11-18 (the reproduction above: findings reported,
  zero repaired; correction received 2026-11-19).

## 2. Not Included

- The field findings themselves — repaired before the report was filed
  (2026-11-19; the report records the two-tranche evidence and the final
  store-wide clean sweep).
- `floor.md`'s authorization surface — the workspace-maintenance exception
  already carries it; the defect is trigger coverage and procedure, not
  permission.
- `validate-yaml` tool code changes — the validator's job stays surfacing
  findings; the disposition contract is card-side.
- The store-local `AGENTS.md` hygiene mandate — it already states the duty
  store-side; the deck card's trigger inventory is the gap this spec closes.
- ANSI-escape-specific emission rules — the field ReaderError family is named
  in the evidence, but the report's remediation names the dominant
  `key:`-pattern family only; quoting scalars covers that family, and record
  hygiene beyond it is not asked for.

## 3. Requirements

- **R-1:** The issues card's on-discovery repair doctrine SHALL carry an
  artifact-content-defect trigger in the same agent-owned class as the §6
  ticket-state-hygiene and §7 mirror-repair triggers: record-content defects
  that the store's own validator (`local-issues validate-yaml`) names in a
  store-holding repo are repaired on discovery in the same workflow — the
  discovering session never reports the findings to the developer and waits,
  and the store never stays knowingly defective across sessions.
- **R-2:** The trigger SHALL state the repair procedure: mechanical content
  repairs (the validator's taxonomy) dispatch per file to a sub-agent under
  the dispatch-scope doctrine, each repair preserving the record's content
  byte-exactly except the defect itself; the discovering session — never the
  repair sub-agent alone — re-verifies the full store sweep clean
  (`validate-yaml` exit 0) and records the repair disposition with the work
  that discovered it.
- **R-3:** The trigger SHALL require sweep completeness: the discovering
  session counts the validator's full output and verifies the count before
  repairing; a sampled or tail-truncated view of the findings is never the
  repair dispatch's premise.
- **R-4:** The validate-yaml tooling contract — the issues card's CLI
  reference row for `validate-yaml` — SHALL bind the disposition: the
  validator's findings are the repair trigger's evidence instrument, and the
  reference names that trigger; the validator's contract carries no
  report-and-wait outcome.
- **R-5:** The deck SHALL pair the repair trigger with emission-side quoting
  guidance for the validation-record family: the spec card's
  validation-standards reference — the contract that specifies the
  `.issues/{N}/audit/validation.yaml`-family records — SHALL instruct that
  prose scalars carrying embedded `key:`-pattern text are emitted as quoted
  or folded scalars so the emitted record parses, and the issues card's
  trigger SHALL cross-reference that guidance.

## 4. Success criteria

| ID | Criterion | Class | Instrument |
|----|-----------|-------|------------|
| SC-1 | The issues card's repair doctrine carries the artifact-content-defect trigger in the same agent-owned class as the ticket-state-hygiene and mirror-repair triggers: validate-yaml findings are repaired on discovery in the same workflow, and no clause on that path permits reporting them to the developer and waiting. | Structural | Card-text fact check: read the issues card's repair-doctrine sections; the check fails if no trigger names the store's own validator's findings as a repair trigger, or if a report-and-wait disposition remains available for them. |
| SC-2 | The trigger states the repair procedure: mechanical repairs dispatch per file to a sub-agent under the dispatch-scope doctrine, each repair preserving record content byte-exactly except the defect; the discovering session re-verifies the full sweep clean and records the disposition with the discovering work. | Structural | Card-text fact check: read the trigger's procedure clause; the check fails if any of the dispatch step, the content-preservation rule, the discovering session's re-verification duty, or the disposition-recording duty is absent. |
| SC-3 | The trigger requires sweep completeness: the discovering session counts the validator's full output and verifies it before repairing; a sampled or tail-truncated view is never the repair dispatch's premise. | Structural | Card-text fact check: read the trigger for the sweep-completeness clause; the check fails if the full-output counting duty is absent. |
| SC-4 | The validate-yaml tooling contract row (the issues card's local-issues CLI reference) names the disposition: the validator's findings trigger the issues card's repair path. | Structural | Card-text fact check: read the CLI reference's validate-yaml row; the check fails if the row leaves the findings' disposition unbound or states a report-and-wait outcome. |
| SC-5 | The deck pairs the repair trigger with emission-side quoting guidance: the validation-standards reference instructs that validation-record prose scalars carrying embedded `key:`-pattern text are emitted quoted or folded, and the issues card's trigger cross-references that guidance. | Structural | Card-text fact check: read the validation-standards record contract and the trigger's cross-reference; the check fails if either surface lacks its half of the pair. |
| SC-6 | Under the revised deck, a session in a store-holding repo whose validate-yaml sweep names invalid-YAML store artifacts repairs them in the same workflow — dispatching the mechanical repairs to a sub-agent, re-verifying the full sweep clean, and recording the disposition — and does not report the findings to the developer as out-of-scope and leave the artifacts defective. | Behavioral | Tier-2 tests-v2 behavioral scenario (the behavioral-testing card's harness) with a fixture store seeding the field defect shapes (prose scalars carrying embedded `key:`-pattern text; a stray document separator) and a session flow that surfaces the findings; the standard clean-room evaluator dispatch reads session.yaml against this criterion. RED evidence: the field reproduction (2026-11-18 — findings reported, zero repaired). |

## 5. Dependencies

| Reference | Relationship | Status |
|-----------|---------------|--------|
| `floor.md` issue-store workspace-maintenance exception | Carries the authorization surface the trigger relies on — the repair class needs no scope-bearing token. Verified present as of 2026-11-19. | satisfied |
| The issue store's own `AGENTS.md` hygiene mandate (each store's `.issues/AGENTS.md`) | The store-local statement of the repair duty; the deck trigger binds the same duty card-side, adding the trigger list, dispatch procedure, sweep rule, and emission guidance the store guide does not carry. | satisfied |
| `local-issues` `validate-yaml` tool (deck tools) | The trigger's evidence instrument — the validator names the findings the trigger repairs. Present in the deck as of 2026-11-19. | satisfied |

## 6. Traceability

| Requirement | Success criteria |
|-------------|-------------------|
| R-1 | SC-1, SC-6 |
| R-2 | SC-2, SC-6 |
| R-3 | SC-3, SC-6 |
| R-4 | SC-4 |
| R-5 | SC-5 |

## 7. Documentation Sources

| Source | Type | Location | Verification |
|---------|------|----------|--------------|
| issues card | deck card | `skills/issues/SKILL.md` | Read and grepped 2026-11-19: §6/§7 trigger inventory carries no artifact-content-defect trigger; `validate-yaml` absent from the card. |
| local-issues CLI reference | card reference | `skills/issues/references/local-issues-cli.md` | Read 2026-11-19: the validate-yaml row carries only the error taxonomy, no disposition binding. |
| validation-standards reference | card reference | `skills/spec/references/validation-standards.md` | Read 2026-11-19: the validation-record contract specifies the `.issues/{N}/audit/validation.yaml` record; no emission quoting guidance present. |
| agent floor | deck floor | `floor.md` | Read 2026-11-19: the default-scope exception carries issue-store workspace maintenance as agent-owned. |
| Filed report .opencode#2755 | field report | remote tracker (`github.com/michael-conrad/.opencode/issues/2755`) | Read via `gh` CLI 2026-11-19: the 2026-11-18 reproduction (three findings reported, zero repaired), the 2026-11-19 developer correction, the 47-instance two-tranche repair record, and the final store-wide clean sweep. |

## 8. Cost Frame

- **SC-1..SC-5 (card-text checks):** acting costs read/grep passes over two
  card files and two references; skipping costs the doctrine gap persisting —
  every discovering session re-derives the disposition from scratch, and the
  field evidence shows the report-and-wait disposition recurring.
- **SC-6 (tier-2 run):** acting costs one supervised harness cycle — fixture
  store authoring with the field defect shapes, a supervised model run, and a
  clean-room evaluation dispatch; skipping costs shipping the trigger
  verified only by text judgment — the same evidence class that stood by
  while the report-and-wait disposition shipped in the field, and no
  card-text check can observe an agent repairing instead of reporting.

## 9. Edge Cases

| Condition | Expected behavior | Resolution |
|-----------|-------------------|------------|
| Findings surface on artifacts another concurrent session is writing (field deviation 2026-11-19: an auto-sync swept in-flight files mid-repair). | The repair trigger still binds the discovering session to the final verified state: full sweep clean at the store's synced HEAD. | Repairs sync through the store tooling per file; the discovering session verifies the final state, not the intermediate commit set. |
| The defective record is one the current flow is itself emitting (this round's validation record). | The emission guidance prevents the defect; a finding on the in-flight record is repaired in the authoring flow before the sweep re-verification. | R-5's quoting guidance is the emission-side half; the repair trigger is the discovery-side half. |
| The validator names findings beyond scalar syntax (frontmatter, schema, shape defects). | The same trigger class covers the validator's whole taxonomy (`malformed-frontmatter`, `invalid-yaml`, `schema-violation`); repairs diagnose per-file root cause. | The trigger's coverage is the validator's named findings, not a syntax-only subset. |
| The store sweeps clean (`validate-yaml` exit 0). | The trigger does not fire; no repair dispatch is invented; the clean sweep stands as the recording evidence. | No-op path. |
| A repair attempt fails on evidenced tool error. | The failure is reported with evidence, scoped to that store alone; the store is never left defective with the disposition unrecorded. | Mirrors the issues card's existing scoped-halt posture for store-maintenance repairs. |

## 10. Completion gate

Every success criterion passes before the deliverable is complete; partial
implementation is not permitted — a revision that adds the trigger without
the dispatch procedure and sweep-completeness rule, leaves the CLI
reference's disposition unbound, or ships the repair side without the
emission-side guidance, is not a complete deliverable.

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
