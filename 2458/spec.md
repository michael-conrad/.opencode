---
title: "[SPEC] Deprecation Encounter Protocol — pending-breakage directive across skill cards"
labels:
  - needs-approval
  - spec-draft
remote_issue: 2458
remote_url: https://github.com/michael-conrad/.opencode/issues/2458
github_url: https://github.com/michael-conrad/.opencode/issues/2458
promoted_at: '2026-09-22T14:55:30+00:00'
---

> **Full spec and artifacts: [`.opencode/.issues/2458/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2458)** — the remote issue is a condensed exec summary; this file is the authoritative spec.
>
> **Local artifacts:** `.opencode/.issues/2458/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

**Problem Statement:** The skill deck has no encounter-side rule governing how agents respond when they meet a deprecated item (API, config key, library function, skill card, format) during workflow — called, depended on, recommended, validated against, routed through, or merely observed. All existing `deprecat*` matches in the scoped skills+guidelines+AGENTS.md search — measured 2026-09-22 at 22 matches across 12 files via `grep -rn 'deprecat' skills guidelines AGENTS.md --include='*.md'` from the `.opencode/` submodule root — are output-side (creation/removal notices: audit coherence-maintenance, changelog `deprecate:` category, 087-no-backward-compat); zero encounter-side coverage exists. Deck-wide, every `deprecat*` match is authoring-side or output-side; none is encounter-side, and the six target SKILL.md cards plus `.opencode/AGENTS.md` return zero `deprecat*` matches (verified 2026-09-22). Encountered deprecated items are currently treated as ignorable noise, so possible future breakage never surfaces to the developer.

**Root Cause / Motivation:** Deprecation handling evolved only on the authoring side — every existing rule describes creating, announcing, or removing deprecations, none describes consuming a deprecation encounter. Now that the deck is the primary agent surface, every unhandled encounter is silent bitrot accrual: an agent builds on a deprecated path and the breakage is discovered only when it fires, at maximum fix latency. This is solvable now with one additive directive fragment and its enforcement — before more bitrot accrues.

**Approach Chosen:** An additive Deprecation Encounter Protocol directive — one canonical fragment inlined byte-identically in six high-traffic SKILL.md cards (research, systematic-debugging, programming-principles, audit, skill-creator, engineering-approach), drift-controlled via skill-creator fragment-management — plus runtime-constraint documentation (full detail in the two reference standards docs, compact statement in .opencode/AGENTS.md) and behavioral enforcement tests in tests-v2.

**Alternatives Considered & Why Discarded:**
- *Read-link-only / load-on-encounter directive* — discarded: skill() auto-loads full SKILL.md cards into the calling agent's context before decision-making, while task() does NOT auto-load task cards (research card, confidence 0.90), so a pointer form would be invisible at the exact encounter decision point; the developer explicitly invalidated this form.
- *Single global Tier 1 guideline* — discarded: the progressive-disclosure constraint keeps Tier 1 minimal; the domain rule belongs at the six encounter surfaces, with only runtime mechanics going global (explicit developer decision).
- *Mid-card conditional insertion mechanism* — discarded: no such runtime mechanism exists; inserting content after card load cannot influence the current decision, and the developer explicitly invalidated this form.

**Key Design Decisions:**
- *Inline-only placement* — decision-point directives SHALL be in the loaded card body. Tradeoff: six copies to keep synchronized versus guaranteed visibility at decision time; drift is controlled by the SC-3 equality check and fragment management.
- *Every-encounter filing, dependent or observed* — tradeoff: more filed specs versus the developer always having knowledge of possible future breakage.
- *Orchestrator-dispatched filing with result-contract propagation* — sub-agents cannot dispatch task(), so encounters observed by sub-agents propagate via result contracts. Tradeoff: one extra contract hop versus respecting the sub-agent dispatch boundary.
- *SC-eligibility gate on dependent encounters* — tradeoff: possible scope interruption versus no unauthorized plan-approval revocation (substantive spec revision revokes linked plan approvals per approval-gate-006).
- *Additive-only content* — tradeoff: zero conflict surface with the 4 conflict-risk deck-wide structural specs, at the cost of some deck-wide text duplication controlled by fragment management.

**User Intent / Original Prompt:** Developer-observed gap raised in a brainstorming session (2026-09-22, design approved after 9 exploration turns): "A deprecated item encountered during workflow is pending breakage — file for resolution so the developer always has knowledge of possible future breakage requiring research." Handoff: `tmp/issue-pending-deprecation-bitrot/artifacts/preliminary/handoff.yaml` (re-staged to `tmp/2458/artifacts/` by the analyze task).

## 2. Not Included

- **Modification of existing output-side deprecation text** — audit coherence-maintenance, changelog `deprecate:` category, and 087-no-backward-compat govern deprecation authoring/removal; this spec adds encounter-side handling only, so nothing existing is modified or superseded (additive-only constraint, REQ-C1).
- **Runtime code changes** — no executable code paths are touched; deliverables are SKILL.md card bodies, reference-standards prose, the .opencode/AGENTS.md statement, and test scenarios.
- **Auto-folding resolution SCs into current specs** — the SC-eligibility gate (SC-11) prohibits folding a resolution SC into the current spec without a dev brainstorm (NREQ-4).
- **Mid-card content insertion mechanism or Read-link-only/load-on-encounter directive forms** — explicitly invalid per developer correction; the runtime-constraint documentation (SC-4, SC-5) exists precisely to keep these forms out (NREQ-5).
- **A special tracking file for bitrot encounters** — standard issue tracking only ([BITROT]-prefixed specs/comments); no new tracking artifact is introduced (NREQ-1).
- **Tier 1 guideline changes** — progressive-disclosure constraint: the compact runtime-mechanics statement in .opencode/AGENTS.md is the only always-loaded addition (REQ-I3).

The constraint codes used above are defined here:

| Code | Definition |
|------|------------|
| REQ-C1 | Additive-only constraint — the spec adds encounter-side handling only; no existing output-side deprecation text is modified or superseded |
| NREQ-1 | No special tracking file for bitrot encounters — standard issue tracking only ([BITROT]-prefixed specs/comments); no new tracking artifact is introduced |
| NREQ-4 | No auto-folding of a resolution SC into the current spec without a dev brainstorm — the SC-eligibility gate (SC-11) enforces this |
| NREQ-5 | No mid-card content insertion mechanism and no Read-link-only / load-on-encounter directive forms — explicitly invalid per developer correction |
| REQ-I3 | Tier 1 guideline changes are out of scope — progressive-disclosure constraint keeps Tier 1 minimal; the compact runtime-mechanics statement in .opencode/AGENTS.md is the only always-loaded addition |

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The canonical deprecation-encounter directive fragment is registered with skill-creator fragment-management | string | Fragment store inspection via the fragment-management registration check | `.opencode/skills/skill-creator/tasks/fragment-management.md` |
| SC-2 | The full directive text is inlined in each of the six SKILL.md cards (research, systematic-debugging, programming-principles, audit, skill-creator, engineering-approach); no Read-link-only, conditional-insert, or load-on-encounter form exists anywhere | string | Static text check: full directive present in each of the six card bodies; pattern search confirming absence of pointer forms; deck validators (skildeck-lint / validate_skill_cards.py) run green on the edited cards (R-13) | `.opencode/skills/research/SKILL.md`, `.opencode/skills/systematic-debugging/SKILL.md`, `.opencode/skills/programming-principles/SKILL.md`, `.opencode/skills/audit/SKILL.md`, `.opencode/skills/skill-creator/SKILL.md`, `.opencode/skills/engineering-approach/SKILL.md` |
| SC-3 | The six card copies are byte-identical to the canonical fragment | string | Equality check across the six card bodies against the registered canonical fragment | The six SKILL.md card files + `.opencode/skills/skill-creator/tasks/fragment-management.md` fragment store |
| SC-4 | Full-detail runtime-constraint documentation is present in both reference standards docs — `skill-card-description-standards.md` and `task-card-structure-standards.md` (full cards load before any decision-making; no mid-card content insertion; decision-point directives SHALL be inline, never Read-link-only or load-on-encounter) | string | Static text check on the two reference docs: full-detail runtime-constraint text present in each | `.opencode/reference/skill-card-description-standards.md`, `.opencode/reference/task-card-structure-standards.md` |
| SC-5 | A compact 2-3 sentence runtime-constraint statement, scoped to runtime mechanics only (not domain rules), is present in `.opencode/AGENTS.md` | string | Static text check on `.opencode/AGENTS.md`: statement present and within the 2-3 sentence bound | `.opencode/AGENTS.md` |
| SC-6 | An agent encountering a deprecated item during workflow classifies it as pending breakage/bitrot — never as ignorable noise, never as something to build on | behavioral | tests-v2 clean-room `opencode run` via with-test-home; stderr behavioral evidence of classification without reliance (commit → push → fetch-verify ordering before run) | `.opencode/tests-v2/test-enforcement.sh` harness (existing --scenario/--tag filters) |
| SC-7 | The orchestrator dispatches filing for every encounter, immediately at encounter receipt (the dependent-encounter variant and the observed-encounter variant are each exercised); encounters observed by sub-agents propagate to the orchestrator via result contracts | behavioral | tests-v2 clean-room `opencode run` via with-test-home; stderr behavioral evidence of filing dispatch on both encounter variants (commit → push → fetch-verify ordering before run) | `.opencode/tests-v2/test-enforcement.sh` harness |
| SC-8 | Filing channel routing follows platform state per the routing table: remote API when available; transient API failure → chat executive summary with defer-and-retry; structural absence of remote (platform: local) → local `.issues/` standard tracking with the same [BITROT] prefix and bitrot label — no special tracking file | behavioral | tests-v2 behavioral scenario(s), table-driven routing branches asserting the branch-appropriate channel per platform state | `.opencode/tests-v2/test-enforcement.sh` harness |
| SC-9 | The filing path searches the remote tracker for an existing [BITROT] spec on that deprecation before any POST: found → append the encounter evidence as a comment; not found → create a spec with the [BITROT] title prefix and the bitrot label (created with the first filing if the platform lacks it) | behavioral | tests-v2 behavioral scenario asserting search-before-POST ordering and the branch-appropriate create-or-comment outcome | `.opencode/tests-v2/test-enforcement.sh` harness |
| SC-10 | A dependent encounter (the encountered deprecated item is a code path the current change touches) surfaces the finding to the developer with a scope assessment | behavioral | tests-v2 behavioral scenario asserting scope-assessment surfacing on the dependent-encounter variant | `.opencode/tests-v2/test-enforcement.sh` harness |
| SC-11 | No resolution SC is folded into the current spec without a dev brainstorm presenting the plan-approval-revocation cost; the SC question is never raised on observed-only encounters | behavioral | tests-v2 behavioral scenario asserting no unauthorized fold-in and no SC question on observed-only encounters | `.opencode/tests-v2/test-enforcement.sh` harness |

Each SC maps to exactly one item in the Items section (items 1-11, one per SC).

## 4. Requirements

R-1. The agent SHALL classify a deprecated item encountered during workflow — called, depended on, recommended, validated against, routed through, or merely observed — as pending breakage / bitrot, never as ignorable noise.

R-2. The agent SHALL NOT build on or rely on an encountered deprecated item.

R-3. The agent SHALL file (or update) a spec in the module that owns the deprecated item, for its resolution, via the normal spec-creation pipeline.

R-4. Filing SHALL trigger on every encounter — dependent or observed — so the developer always has knowledge of possible future breakage.

R-5. The directive SHALL be expressed as a single canonical fragment registered with skill-creator fragment-management and inlined identically in six SKILL.md cards: research, systematic-debugging, programming-principles, audit, skill-creator, engineering-approach.

R-6. Runtime-constraint documentation — full cards load before any decision-making; no mid-card content insertion; decision-point directives SHALL be inline, never Read-link-only or load-on-encounter — SHALL be added to `skill-card-description-standards.md` and `task-card-structure-standards.md` (full detail).

R-7. A compact 2-3 sentence runtime-constraint statement, scoped to runtime mechanics only (not domain rules), SHALL be added to `.opencode/AGENTS.md`.

R-8. The orchestrator SHALL dispatch a filing sub-agent immediately at encounter receipt; encounters observed by sub-agents SHALL propagate to the orchestrator via result contracts (sub-agents cannot dispatch task()).

R-9. The filing path SHALL search the remote tracker for an existing [BITROT] spec on that deprecation before any POST: found → append the encounter evidence as a comment (check-before-POST per critical-rules-029); not found → create a spec with the [BITROT] title prefix and the bitrot label (the bitrot label is created with the first [BITROT] filing if the platform does not yet carry it).

R-10. Channel routing SHALL follow platform state: remote API when available; transient API failure → chat executive summary + defer-and-retry; structurally no remote (platform: local) → local `.issues/` standard tracking with the same [BITROT] prefix and label — no special tracking file.

R-11. On a dependent encounter (the encountered deprecated item is a code path the current change touches), the agent SHALL surface the finding to the developer with a scope assessment; folding a resolution SC into the current spec SHALL require a dev brainstorm, with the plan-approval-revocation cost presented. Observed-only encounters SHALL NOT raise the SC question.

R-12. Enforcement SHALL match the substrate classification of each change (placement/docs SCs = string evidence; encounter-behavior SCs = behavioral evidence per critical-rules-BEH-EV), with behavioral enforcement tests per critical-rules-009.

R-13. Card-body additions SHALL NOT violate skildeck-lint / validate_skill_cards.py validation, and the fragment-management mechanism and deck validators SHALL remain unmodified by this spec's implementation.

R-14. Tier 1 guidelines SHALL remain untouched; the .opencode/AGENTS.md compact statement SHALL be the only always-loaded addition.

R-15. Behavioral runs SHALL follow the commit → push → fresh-fetch-verify ordering before the run (tests-v2 §4), with a ≥600s bash timeout and the with-test-home wrapper mandatory.

R-16. Content SHALL be additive-only — zero existing rules modified or superseded (scoped skills+guidelines+AGENTS.md grep, measured 2026-09-22: 22 `deprecat*` matches across 12 files via `grep -rn 'deprecat' skills guidelines AGENTS.md --include='*.md'` from the `.opencode/` submodule root — all output-side/authoring-side, zero encounter-side).

R-17. The encounter directive (domain rule) SHALL stay out of the C2 files — the directive lives only in the six cards; only runtime mechanics go global.

## 5. Items

### Item 1 (SC-1): Register canonical deprecation-encounter fragment

- RED: Fragment store lacks the deprecation-encounter fragment — the fragment-management registration check fails.
- GREEN: Fragment registered with the canonical directive text.
- verify: Fragment store inspection.
- commit: Fragment registration + test artifact.

### Item 2 (SC-2): Inline directive in six SKILL.md cards

- RED: Static check finds no full directive text in at least one of the six cards (or finds a pointer-only form).
- GREEN: All six cards carry the full directive inline in their natural per-card sections (findings classification in research/audit; root-cause hypothesis in systematic-debugging; review findings in programming-principles; deck-internal lifecycle in skill-creator; design/implementation discipline in engineering-approach).
- verify: Static text check — full directive present ×6; absence of pointer forms; deck validators (skildeck-lint / validate_skill_cards.py) green on the edited cards.
- commit: Six card edits + test artifact.

### Item 3 (SC-3): Six-copy equality against canonical fragment

- RED: Equality check across the six cards versus the canonical fragment fails (missing or divergent copy).
- GREEN: All six copies byte-identical to the canonical fragment.
- verify: Equality check.
- commit: Divergence fix + test artifact.

### Item 4 (SC-4): Full-detail runtime-constraint documentation in the two reference standards docs

- RED: Static check finds no runtime-constraint text in at least one of the two reference docs.
- GREEN: Full-detail constraint text present in `skill-card-description-standards.md` and `task-card-structure-standards.md`.
- verify: Static text check on the two reference docs.
- commit: Two doc edits + test artifact.

### Item 5 (SC-5): Compact runtime-constraint statement in .opencode/AGENTS.md

- RED: Static check finds no compact runtime-constraint statement in `.opencode/AGENTS.md`.
- GREEN: Compact 2-3 sentence statement present, scoped to runtime mechanics only.
- verify: Static text check on `.opencode/AGENTS.md`.
- commit: `.opencode/AGENTS.md` edit + test artifact.

### Item 6 (SC-6): Behavioral — encounter classification

- RED: Clean-room opencode run on the unmodified deck — the agent ignores the deprecated item (no classification evidence in stderr).
- GREEN: Agent classifies the deprecated item as pending breakage/bitrot — never ignores it, never builds on it.
- verify: tests-v2 clean-room run; stderr behavioral evidence (commit → push → fetch-verify before run).
- commit: Scenario + harness wiring.

### Item 7 (SC-7): Behavioral — filing dispatch on every encounter

- RED: Clean-room opencode run — no filing dispatch for the encounter on the dependent or observed variant.
- GREEN: Orchestrator dispatches filing on the dependent-encounter variant and the observed-encounter variant; sub-agent-observed encounters propagate via result contracts.
- verify: tests-v2 clean-room run; stderr behavioral evidence (commit → push → fetch-verify before run).
- commit: Scenario + harness wiring.

### Item 8 (SC-8): Behavioral — platform-state channel routing

- RED: No routing behavior — filing ignores platform state (no remote/local/transient-failure branch differentiation).
- GREEN: Filing routes per platform state: remote API when available; chat executive summary + defer-and-retry on transient failure; local `.issues/` standard tracking on structural absence of remote.
- verify: tests-v2 behavioral scenario(s) — table-driven routing branches.
- commit: Scenario + harness wiring.

### Item 9 (SC-9): Behavioral — search-then-create-or-comment ordering

- RED: Filing POSTs without searching — duplicate [BITROT] spec creation or a missed evidence comment.
- GREEN: Filing searches existing [BITROT] specs first; comment on found, create on not-found with [BITROT] title prefix and bitrot label.
- verify: tests-v2 behavioral scenario asserting search-before-POST and both create-or-comment branches.
- commit: Scenario + harness wiring.

### Item 10 (SC-10): Behavioral — dependent-encounter scope assessment

- RED: Dependent encounter produces no scope assessment to the developer.
- GREEN: Scope assessment surfaced on the dependent-encounter variant.
- verify: tests-v2 behavioral scenario asserting scope-assessment surfacing.
- commit: Scenario + harness wiring.

### Item 11 (SC-11): Behavioral — fold-in gate

- RED: Agent folds a resolution SC into the current spec without a dev brainstorm (or raises the SC question on an observed-only encounter).
- GREEN: No inline SC addition without a dev brainstorm presenting the plan-approval-revocation cost; SC question never raised on observed-only encounters.
- verify: tests-v2 behavioral scenario asserting no unauthorized fold-in.
- commit: Scenario + harness wiring.

Dependency DAG: 1 → 2 → 3 → 6 → 7 (the inlined directive chain feeds the behavioral encounter tests, and dispatch triggers on a classified encounter); 7 → 8, 7 → 9, 7 → 10 (routing, search ordering, and the dependent-encounter assessment each exercise the dispatched filing path); 10 → 11 (the SC-eligibility gate is evaluated after the assessment surfaces); 4 and 5 independent (string docs). Behavioral items (6-11) carry a PUSH step before the behavioral run per the 091 behavioral variant — commit and push precede the fresh-fetch verification and the run itself.

## 6. Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| `.opencode/skills/skill-creator/tasks/fragment-management.md` | Mechanism used to register the canonical fragment (SC-1) — must exist; mechanism must remain unmodified (R-13) | Satisfied — file exists (session check; `grep -ril 'fragment'` confirms the mechanism) |
| `.opencode/tests-v2/test-enforcement.sh` + with-test-home wrapper | Behavioral harness hosting the new scenarios (SC-6..SC-11) — scenarios slot into existing --scenario/--tag/--changed filters | Satisfied — harness referenced in the .opencode/AGENTS.md Build/Lint/Test table |
| skildeck-lint / validate_skill_cards.py | Deck validators must stay green after card-body edits (R-13) — validators reject meta-instruction patterns in frontmatter/description, not body sections | Satisfied — verified in the brainstorming handoff |
| Research card `spec-writing-ai-agents-opencode-skill-architecture` (confidence 0.90) | Grounds the C2 runtime-constraint documentation: skill() auto-loads full cards before decision-making, task() does not auto-load task cards | Satisfied — consulted (`.issues/research-cards/`) |
| Cross-spec: 4 CONFLICT-RISK deck-wide structural specs (#2056, #1199, #1204, #1358) touch the same six cards | Merge-sequence coordination required — additive-only content here minimizes conflict surface; sequencing is a coordination note, not a scope change | Pending — carried as pipeline coordination note |
| Cross-spec: 17 PARTIAL-OVERLAP additive specs (notably #2094 on the three C2 docs; #2369/#2368/#2365/#2196 on the P1 cards) | Additive coordination; no supersession (zero FULL-SUPERSESSION across all open [SPEC]-prefixed issues searched on 2026-09-22 — live paginated `gh api 'repos/michael-conrad/.opencode/issues?state=open&per_page=100&page=N'`: 169 open [SPEC]-titled; 107 additional SPEC-FIX-prefixed; 276 combined) | Pending — additive text minimizes conflict surface |
| Repo routing: all touched files live in the `.opencode` submodule | Implementation work routes to michael-conrad/.opencode | Satisfied — paths verified under `.opencode/` |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-6 | Phase 1 |
| R-2 | SC-6 | Phase 1 |
| R-3 | SC-7, SC-9 | Phase 1 |
| R-4 | SC-7 | Phase 1 |
| R-5 | SC-1, SC-2, SC-3 | Phase 1 |
| R-6 | SC-4 | Phase 1 |
| R-7 | SC-5 | Phase 1 |
| R-8 | SC-7 | Phase 1 |
| R-9 | SC-9 | Phase 1 |
| R-10 | SC-8 | Phase 1 |
| R-11 | SC-10, SC-11 | Phase 1 |
| R-12 | SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | Phase 1 |
| R-13 | SC-2 | Phase 1 |
| R-14 | SC-5 | Phase 1 |
| R-15 | SC-6, SC-7, SC-8, SC-9, SC-10, SC-11 | Phase 1 |
| R-16 | SC-1, SC-2, SC-4, SC-5 | Phase 1 |
| R-17 | SC-2, SC-4, SC-5 | Phase 1 |

Every requirement traces to at least one SC; every SC traces to at least one requirement (SC-1 ← R-5, R-16; SC-2 ← R-5, R-13, R-16, R-17; SC-3 ← R-5; SC-4 ← R-6, R-16, R-17; SC-5 ← R-7, R-14, R-16, R-17; SC-6 ← R-1, R-2, R-12, R-15; SC-7 ← R-3, R-4, R-8, R-12, R-15; SC-8 ← R-10, R-12, R-15; SC-9 ← R-3, R-9, R-12, R-15; SC-10 ← R-11, R-12, R-15; SC-11 ← R-11, R-12, R-15).

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Six SKILL.md cards (research, systematic-debugging, programming-principles, audit, skill-creator, engineering-approach) | code | `.opencode/skills/<name>/SKILL.md` | Bash existence checks: 12/12 affected files verified present (six SKILL.md cards + `skills/skill-creator/tasks/fragment-management.md` + `reference/skill-card-description-standards.md` + `reference/task-card-structure-standards.md` + `.opencode/AGENTS.md` + `tests-v2/test-enforcement.sh` + `tests-v2/with-test-home`), session 2026-09-22 (bounded string-evidence grounding per R-12) |
| skill-creator fragment-management mechanism | code | `.opencode/skills/skill-creator/tasks/fragment-management.md` | Existence check + `grep -ril 'fragment'` hit in skill-creator SKILL.md + 2 task files, session 2026-09-22 |
| skill-card-description-standards.md | doc | `.opencode/reference/skill-card-description-standards.md` | Read, session 2026-09-22 |
| task-card-structure-standards.md | doc | `.opencode/reference/task-card-structure-standards.md` | Read, session 2026-09-22 |
| .opencode/AGENTS.md | doc | `.opencode/AGENTS.md` | Read, session 2026-09-22 |
| tests-v2 behavioral harness | code | `.opencode/tests-v2/test-enforcement.sh`, `.opencode/tests-v2/with-test-home` | .opencode/AGENTS.md Build/Lint/Test table + harness pre-flight gates (tests-v2 §4, §10.2) |
| Deck-wide deprecation coverage grep | evidence | live `deprecat*` grep, session 2026-09-22 (scoped: skills + guidelines + AGENTS.md, `--include='*.md'`) | Scoped grep — 22 matches across 12 files (command: `grep -rn 'deprecat' skills guidelines AGENTS.md --include='*.md'` from the `.opencode/` submodule root); six target SKILL.md cards + `.opencode/AGENTS.md` — zero matches; all matches authoring-side/output-side, zero encounter-side (verified 2026-09-22) |
| Research card: skill architecture | doc | `.issues/research-cards/spec-writing-ai-agents-opencode-skill-architecture.md` | Read + frontmatter confidence 0.90, session 2026-09-22 |
| Deck validators | code | skildeck-lint / validate_skill_cards.py | Handoff verification: validators reject meta-instruction patterns in frontmatter/description, not body sections |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Inspecting the fragment store for the canonical registration costs one read — seconds. Skipping costs weeks of silent drift remediation — divergent copies surface only when an agent follows a stale directive at an encounter point.
- **SC-2:** Verifying full inline text across the six cards plus the deck-validator run costs one static text pass and one validator run — seconds. Skipping means a pointer-only card routes agents through a Read that may never execute — the directive is absent at the exact decision point where the encounter occurs, and the gap surfaces only after a deprecated dependency ships into an agent workflow.
- **SC-3:** Running the six-copy equality check costs one comparison run — seconds. Skipping costs the drift window — one edited copy silently diverges and agents receive contradictory directives depending on which card they loaded, discovered only by cross-card incident forensics.
- **SC-4:** Verifying the two reference standards docs costs two reads — seconds. Skipping costs every future skill author the placement decision — pointer forms re-enter the deck spec by spec, and the inline guarantee decays until an encounter directive is once again invisible at decision time.
- **SC-5:** Verifying the `.opencode/AGENTS.md` statement costs one read — seconds. Skipping costs the always-loaded surface — the compact statement is the only global addition (R-14); without verification, runtime mechanics are either absent from every session or silently accrete domain rules into Tier 1, both of which defeat the progressive-disclosure constraint.
- **SC-6:** Running the classification behavioral test costs minutes of clean-room execution. Skipping costs the death spiral: the untested classification behavior ships, agents treat the next deprecated item as ignorable noise, and the breakage surfaces in production as an unresearched failure — orders of magnitude beyond the bounded test cost.
- **SC-7:** Running the filing-dispatch behavioral test costs minutes per encounter variant. Skipping means encounters are classified but never filed — the developer's knowledge of pending breakage never materializes and the protocol degrades to observation without action.
- **SC-8:** Running the routing behavioral branches costs minutes per branch. Skipping means filing silently routes to the wrong channel — a transient API failure drops the encounter entirely and the developer never learns of the pending breakage until it fires.
- **SC-9:** Running the search-then-create-or-comment scenario costs minutes. Skipping means duplicate [BITROT] specs or missed evidence comments — the encounter record fragments across duplicate specs and consolidation cost compounds with every encounter.
- **SC-10:** Running the dependent-encounter assessment scenario costs minutes. Skipping means the developer never learns the current change touches a deprecated path — the scope risk surfaces mid-implementation instead of at the gate.
- **SC-11:** Running the fold-in-gate scenario costs minutes. Skipping means a resolution SC gets folded into an approved plan without the developer's brainstorm — plan-approval revocation surfaces as mid-implementation rework instead of a decision made at the gate.

## 11. Edge Cases

**Input boundaries:**
- *Condition:* The deprecation already has an existing [BITROT] spec on the remote. *Expected behavior:* The filing path appends the encounter evidence as a comment — no duplicate spec POST (check-before-POST per critical-rules-029). *Resolution:* SC-9 search-then-create-or-comment branch.
- *Condition:* The owning module of the deprecated item cannot be resolved from the item identity. *Expected behavior:* The filing agent resolves the owner from the encounter context (file path, card identity, or config namespace) before creating; if still unresolvable, the filing agent SHALL NOT guess — it surfaces the unresolved ownership in the encounter record to the developer. *Resolution:* scope assessment surfacing (SC-10 path) rather than a misdirected spec.

**State transitions:**
- *Condition:* Dependent versus observed classification boundary. *Expected behavior:* A dependent encounter (current change touches the deprecated code path) adds the scope assessment and the SC-eligibility gate; an observed-only encounter records and files only — the SC question is never raised (R-11). *Resolution:* PATH-1 decision branch; both variants dispatch filing (SC-7).
- *Condition:* Routing branch selection (remote available / transient failure / structurally local). *Expected behavior:* Branch selection is a per-invocation decision with no state carried across invocations — no persisted routing state exists (state-analysis: not-applicable). *Resolution:* SC-8 table-driven branches.

**Failure modes:**
- *Condition:* Transient remote API failure during filing. *Expected behavior:* Chat executive summary of the encounter + defer-and-retry on availability — the encounter is never silently dropped. *Resolution:* R-10 routing branch.
- *Condition:* Structural absence of remote (platform: local). *Expected behavior:* Local `.issues/` standard tracking with the same [BITROT] prefix and label — no special tracking file. *Resolution:* R-10 routing branch.
- *Condition:* Fragment drift between the six card copies. *Expected behavior:* The SC-3 equality check detects divergence against the canonical fragment. *Resolution:* Item 3 re-alignment against the registered fragment.
- *Condition:* Deck validator rejects a card-body addition. *Expected behavior:* Per the handoff verification, validators reject meta-instruction patterns in frontmatter/description, not body sections — body additions pass; a rejection indicates frontmatter contamination and the edit SHALL be corrected, not bypassed. *Resolution:* R-13 validator run after edit.

**Concurrency:**
- *Condition:* Two agents encounter the same deprecation near-simultaneously. *Expected behavior:* Both paths search before POST; the search-then-create-or-comment design narrows but does not eliminate duplicate creation — a second [BITROT] spec on the same deprecation SHALL be consolidated by appending the duplicate's encounter evidence to the first and closing the duplicate. *Resolution:* encounter-evidence comments are idempotent by design.
- *Condition:* Concurrent behavioral test runs. *Expected behavior:* The harness lock (`tmp/.behavior-run.lock`) serializes runs; a stale lock after a killed run blocks re-runs. *Resolution:* `rm -f tmp/.behavior-run.lock` before re-run (tests-v2 §10.1).

**Recovery:**
- *Condition:* Behavioral run killed by a too-short bash timeout. *Expected behavior:* Behavioral scenarios use a ≥600s timeout; on a kill, the SQLite session DB in the test home survives. *Resolution:* Post-timeout export per tests-v2 §10.5; re-run after lock cleanup.
- *Condition:* Filing attempted during an API outage window. *Expected behavior:* Defer-and-retry resumes filing when the API recovers. *Resolution:* R-10; the chat executive summary preserves the encounter evidence until the retry succeeds.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-09-22 | Decomposed the four compound SCs flagged by validation into atomic sub-SCs: SC-4 → SC-4 (full-detail runtime-constraint documentation in the two reference standards docs) + SC-5 (compact 2-3 sentence statement in .opencode/AGENTS.md); SC-5 → SC-6 (encounter classification) + SC-7 (filing dispatch on every encounter); SC-6 → SC-8 (platform-state channel routing) + SC-9 (search-then-create-or-comment ordering); SC-7 → SC-10 (dependent-encounter scope assessment) + SC-11 (fold-in gate). Items renumbered 1-11 with 1:1 SC mapping; DAG updated to 1→2→3→6→7; 7→8, 7→9, 7→10; 10→11; 4-5 independent; traceability re-mapped (all 17 requirements covered, every SC traces to ≥1 requirement); per-SC cost frames expanded to 11; edge-case SC references updated. Advisory tightenings: SC-2 verification method now includes the deck-validator-green run (R-13); R-9 clarifies bitrot-label provenance (created with the first [BITROT] filing if the platform lacks it). | Validation findings: aggregate FAIL — compound-SC structure (checks compound-sc-detection and decomposition-atomicity FAIL; all other 24 checks PASS). SC-4/5/6/7 bundled multiple claim forms joined by "and"/"plus"/semicolon | spec-creation revise task, dispatched by the orchestrator with the validator findings (pipeline-initiated revision, 2026-09-22) |
| 2026-09-22 | Non-substantive consistency/provenance corrections. (1) INTERNAL-CONSISTENCY: repointed the dangling R-18 reference in Section 8 to R-12 (bounded string-evidence grounding — R-12 governs evidence-type grounding for placement/docs SCs); added a constraint-code definitions table in Section 2 defining REQ-C1, NREQ-1/4/5, and REQ-I3 (previously referenced but never defined). (2) PROVENANCE: corrected the deck-wide `deprecat*` grep counts from the stale "14 matches" to the live state — 24 matches in the scoped skills+guidelines+AGENTS.md search and 95 across the full deck — in the Problem Statement (§1), R-16, and the Section 8 evidence row. The substantive claim (zero encounter-side coverage; all matches output-side/authoring-side) is verified TRUE and unchanged; SC semantics and evidence types unchanged. | Spec-audit final judgment (holistic): INTERNAL-CONSISTENCY FAIL (dangling R-18; undefined constraint codes REQ-C1, NREQ-1/4/5, REQ-I3) and PROVENANCE FAIL (grep count contradicted by live state) | spec-creation revise task, dispatched by the orchestrator with the audit final judgment, next_step remediate_holistic (pipeline-initiated revision, 2026-09-22) |
| 2026-09-22 | Provenance remediation (HOL-7 / HOL-2 — brittle absolute counts with undefined bases that do not reproduce under independent measurement). (1) Replaced the `deprecat*` absolute counts (24 scoped / 95 full deck) in the Problem Statement (§1), R-16, and Section 8 with a documented, reproducible measurement — 22 matches across 12 files via `grep -rn 'deprecat' skills guidelines AGENTS.md --include='*.md'` from the `.opencode/` submodule root, 2026-09-22 — plus the verified qualitative claim: zero `deprecat*` matches in the six target SKILL.md cards and `.opencode/AGENTS.md`; every deck-wide match is authoring-side/output-side, none encounter-side. The substantive zero-encounter-side claim is preserved. (2) Replaced the "212 open [SPEC]-titled issues" claim in Section 6 with the live paginated gh api measurement (2026-09-22): 169 open [SPEC]-titled, 107 additional SPEC-FIX-prefixed, 276 combined — stated qualitatively as "all open [SPEC]-prefixed issues searched on 2026-09-22". (3) Corrected Section 8 "10/10 files present" to the verified 12/12 affected-file count (per blast-radius.yaml) with the full file list. No SC semantics, requirements, or evidence types changed. | Spec-audit iteration 2 final judgment: HOL-7 Provenance FAIL and HOL-2 Internal Consistency FAIL on the same root cause — the spec embeds brittle absolute counts from ad-hoc greps with undefined bases that do not reproduce under independent measurement | spec-creation revise task, dispatched by the orchestrator with the audit final judgment, next_step remediate_holistic (pipeline-initiated revision, 2026-09-22) |

Out-of-scope advisory (won't-fix in this revision): validator note that `spec-creation/tasks/validate.md` links `../../../audit/reference/decomposition-criteria.md` (nonexistent path; master definition lives at `.opencode/audit/reference/decomposition-criteria.md`). This is a skill task-file defect outside the spec — fixing it belongs to a separate skill-maintenance change, not a spec revision.

---

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
Co-authored with AI: OpenCode (huggingface/deepseek-ai/DeepSeek-V4-Flash-0731)
