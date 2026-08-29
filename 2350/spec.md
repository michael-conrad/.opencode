> **Full spec and artifacts: [`.opencode/.issues/2350/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2350/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2350/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Condense 060-tool-usage.md — move five-tier hierarchy & glob semantics

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The preloaded `.opencode/guidelines/060-tool-usage.md` guideline costs ~4.1k tokens of orchestrator context at every session start. Roughly 70% of its content — the five-tier tool priority hierarchy and the built-in glob semantics (LIM-1..6, canonical path-parameter idiom, empty-result disambiguation rule) — is procedural content that is either already duplicated in the `mcp-tool-usage` skill card (five-tier hierarchy) or belongs in a sub-agent-readable location (glob semantics). This spec condenses the guideline to its zero-tolerance safety cores, relocating the procedural content to its authoritative home, without removing the guideline from the `opencode.jsonc` instructions array. |
| 2 | **Root Cause / Motivation** | The guideline was written as a monolithic preloaded Tier 1 file before the skill-card/task-card architecture matured. The five-tier hierarchy is already duplicated verbatim in `mcp-tool-usage/SKILL.md` (line 115), making the guideline's copy redundant. The glob semantics (LIM-1..6) exist ONLY in the guideline §2 — they are not yet present in the skill — and 6 downstream task/guideline files Read-link to `guidelines/060-tool-usage.md` for the canonical glob semantics. Every session start pays ~4.1k tokens to preload content that a skill load or a task-card Read-link could provide on demand. Condensing now reduces orchestrator context load without losing enforcement. |
| 3 | **Approach Chosen** | Relocate the five-tier hierarchy out of the guideline §1 (it already lives verbatim in the `mcp-tool-usage` skill card) and condense §1 to a Read-link. Relocate the glob semantics (LIM-1..6, canonical path-parameter idiom, empty-result rule) out of guideline §2 into the `mcp-tool-usage/tasks/selection-guide.md` task card — the pinned, sub-agent-readable relocation target — and condense §2 to a pointer. Update all 6 downstream glob-semantics Read-links in lockstep. Retain all zero-tolerance safety cores (`.ipynb` mandate, API-client-mandatory, `project_root/tmp`-only, command restrictions, identity-source semantics, linter advisory-only) verbatim in the guideline. Add behavioral enforcement coverage. |
| 4 | **Alternatives Considered & Why Discarded** | **Relocate glob semantics to the SKILL.md card (as proposed by prerequisite #2364):** Discarded. Skill cards are orchestrator-only routing metadata loaded via `skill()` — sub-agents cannot call `skill()` and cannot Read-link a skill card. The 6 downstream task files that Read-link to the guideline for glob semantics would break if the semantics moved to a card sub-agents cannot read. The relocation target MUST be a sub-agent-readable file. **Relocate glob semantics to a dedicated reference file instead of the `selection-guide.md` task card:** Discarded. The `selection-guide.md` task card is the natural home because it already carries file-type tool boundary guidance and is Read-linkable by sub-agents; a separate reference file would add a location without benefit. The relocation target is pinned to `mcp-tool-usage/tasks/selection-guide.md`. |
| 5 | **Key Design Decisions** | **Glob-semantics relocation target is the `mcp-tool-usage/tasks/selection-guide.md` task card (pinned single target), NOT the SKILL.md card and NOT a separate reference file.** This decision is forced by the Read-link cross-reference rule: content referenced via `Read [Text](path)` must exist at a path sub-agents can read. The `mcp-tool-usage/tasks/selection-guide.md` task card already carries file-type tool boundary guidance and is Read-linkable by sub-agents. Tradeoff: glob semantics move out of preload (saving tokens) but require all 6 Read-links to be updated in lockstep to avoid link rot. |
| 6 | **User Intent / Original Prompt** | Condense `060-tool-usage.md` — move the five-tier hierarchy and glob semantics to their authoritative homes while retaining the zero-tolerance safety cores and preserving the guideline's membership in the `opencode.jsonc` instructions array. |

## 2. Not Included

- **[Condensing or removing any data-loss-prevention rule]** — The zero-tolerance safety cores (`.ipynb` mandate, API-client-mandatory, `project_root/tmp`-only, command restrictions, production-data protection, identity-source semantics, linter advisory-only) are retained verbatim. No safety-critical content is removed.
- **[Removing `060-tool-usage.md` from the `opencode.jsonc` instructions array]** — The guideline MUST remain preloaded in the array. Only the file's content is condensed, not its array membership.
- **[Relocating glob semantics to the SKILL.md card]** — Skill cards are orchestrator-only and not Read-linkable by sub-agents; relocating there would break 6 downstream Read-links.
- **[Relocating glob semantics to a separate reference file]** — The relocation target is pinned to `mcp-tool-usage/tasks/selection-guide.md`; no alternative relocation location is used.
- **[Duplicating glob semantics in more than one location]** — Each concern has exactly one authoritative location after relocation (single source of truth).
- **[Modifying the `mcp-tool-usage` skill card's five-tier hierarchy]** — The skill card already carries the hierarchy verbatim; it becomes the single source of truth and is not rewritten by this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1a | The five-tier tool priority hierarchy is removed from `060-tool-usage.md` §1 and replaced with a Read-link to the `mcp-tool-usage` skill. | structural | grep confirms the hierarchy is absent from guideline §1 and replaced with a Read-link. | `.opencode/guidelines/060-tool-usage.md` §1 |
| SC-1b | The five-tier hierarchy remains present verbatim in `mcp-tool-usage/SKILL.md` as the single source of truth. | structural | File read confirms the Five-Tier Tool Priority Hierarchy section is present verbatim in the skill card. | `.opencode/skills/mcp-tool-usage/SKILL.md` Five-Tier Tool Priority Hierarchy section |
| SC-1c | A behavioral enforcement test proves relocated five-tier hierarchy routing still works: RED before the change (agent does not dispatch the `mcp-tool-usage` skill), GREEN after (agent dispatches it). | behavioral | `opencode run` behavioral enforcement test with RED/GREEN assertion helpers on stderr asserting the agent dispatches the `mcp-tool-usage` skill. | `.opencode/tests-v2/behaviors/` test scenario |
| SC-2a | The glob semantics (LIM-1..6 table, canonical path-parameter idiom, forbidden shapes, empty-result disambiguation rule) are relocated from `060-tool-usage.md` §2 into the `mcp-tool-usage/tasks/selection-guide.md` task card, and NOT to the SKILL.md card. | structural | grep confirms glob semantics are present at `mcp-tool-usage/tasks/selection-guide.md` and absent from the SKILL.md card and from guideline §2. | `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md`; `.opencode/skills/mcp-tool-usage/SKILL.md`; `.opencode/guidelines/060-tool-usage.md` §2 |
| SC-2b | `060-tool-usage.md` §2 is condensed to a pointer to the new glob-semantics location (`mcp-tool-usage/tasks/selection-guide.md`). | structural | File read confirms §2 is a pointer to the new location. | `.opencode/guidelines/060-tool-usage.md` §2 |
| SC-2c | A behavioral enforcement test proves relocated glob-semantics routing still works: RED before the change (agent does not emit a canonical path-parameter invocation), GREEN after (agent emits a canonical path-parameter invocation for a hidden/gitignored target, no false absence conclusion). | behavioral | `opencode run` behavioral enforcement test (existing from #2334) with RED/GREEN assertion helpers on stderr asserting the agent emits a canonical path-parameter glob invocation for a hidden/gitignored target. | `.opencode/tests-v2/behaviors/` test scenario |
| SC-3a | All zero-tolerance safety cores are retained verbatim in `060-tool-usage.md` (`.ipynb` mandate, API-client-mandatory rule, `project_root/tmp`-only rule, command restrictions, identity-source semantics, linter advisory-only rule). | structural | File reads confirming each retained section is present verbatim. | `.opencode/guidelines/060-tool-usage.md` §1 PROHIBITED + API Client Mandatory, §3, §4, §9, linter advisory-only |
| SC-3b | `060-tool-usage.md` remains in the `opencode.jsonc` instructions array. | structural | Read of `opencode.jsonc` confirming the array entry for `060-tool-usage.md` is unchanged. | `.opencode/opencode.jsonc` instructions array |
| SC-4a | All 6 downstream glob-semantics Read-link sites are updated to point at the new sub-agent-readable glob-semantics location (`mcp-tool-usage/tasks/selection-guide.md`). | structural | Grep across `.opencode/**/*.md` confirming all 6 known sites point at the new location. | 6 Read-link sites: `verification-before-completion/tasks/completion.md`, `sre-runbook/tasks/generate.md`, `audit/tasks/coherence-maintenance-validator.md`, `audit/tasks/coherence-maintenance-investigator.md`, `audit/tasks/content-audit-investigator.md`, `020-go-prohibitions.md` |
| SC-4b | Zero stale references to the old glob-semantics location remain across `.opencode/**/*.md`. | structural | Grep across `.opencode/**/*.md` for stale references to the old glob-semantics location; confirm zero. | `.opencode/**/*.md` (grep) |
| SC-5b | All edited agent-facing text complies with Mandatory Triple Co-Application (250/255/257). | semantic | Triple Co-Application (250/255/257) reference-card consultation for every edited agent-facing file. | `.opencode/guidelines/250-dark-prose-reference.md`, `255-distribution-shifting-reference.md`, `257-procedural-discipline-reference.md` |

## 4. Requirements

- R-1. The system SHALL remove the five-tier tool priority hierarchy from `060-tool-usage.md` §1 and replace it with a Read-link to the `mcp-tool-usage` skill, leaving the skill card as the single source of truth, and SHALL provide a behavioral enforcement test proving relocated five-tier hierarchy routing still works (RED/GREEN assertion helpers on stderr).
- R-2. The system SHALL relocate the glob semantics (LIM-1..6 table, canonical path-parameter idiom, forbidden shapes, empty-result disambiguation rule) from `060-tool-usage.md` §2 into the `mcp-tool-usage/tasks/selection-guide.md` task card, and SHALL NOT relocate them to the SKILL.md card or any other location, and SHALL provide a behavioral enforcement test proving relocated glob-semantics routing still works (RED/GREEN assertion helpers on stderr).
- R-3. The system SHALL condense `060-tool-usage.md` §2 to a pointer to the new glob-semantics location (`mcp-tool-usage/tasks/selection-guide.md`).
- R-4. The system SHALL retain all zero-tolerance safety cores verbatim in `060-tool-usage.md` (`.ipynb` mandate, API-client-mandatory rule, `project_root/tmp`-only rule, command restrictions, identity-source semantics, linter advisory-only rule).
- R-5. The system SHALL keep `060-tool-usage.md` in the `opencode.jsonc` instructions array; condensation modifies the file's content only, not its array membership.
- R-6. The system SHALL update all 6 downstream glob-semantics Read-link sites that referenced `guidelines/060-tool-usage.md` for glob semantics to point at the new sub-agent-readable location (`mcp-tool-usage/tasks/selection-guide.md`).
- R-7. The system SHALL apply Mandatory Triple Co-Application (250/255/257 reference cards) to every edited agent-facing file.

## 5. Items

### Item 1 (SC-1a): Remove five-tier hierarchy from guideline §1

- RED: Behavioral enforcement test asserting the agent does NOT currently route via the relocated hierarchy (fails because hierarchy is still duplicated in guideline).
- GREEN: Condense `060-tool-usage.md` §1 to a Read-link to `mcp-tool-usage`; remove the duplicated hierarchy text.
- verify: grep confirms hierarchy absent from guideline §1, replaced with a Read-link.
- commit: Guideline §1 condensation.

### Item 2 (SC-1b): Verify hierarchy present in skill card

- RED: N/A (verification of existing state).
- GREEN: No change to the skill card; confirm the hierarchy is present verbatim.
- verify: File read confirms the Five-Tier Tool Priority Hierarchy section present verbatim in `mcp-tool-usage/SKILL.md`.
- commit: Verification evidence only (no content change).

### Item 3 (SC-1c): Behavioral RED/GREEN proof for hierarchy routing

- RED: Behavioral enforcement test fails before the change (agent does not dispatch `mcp-tool-usage` via the relocated routing).
- GREEN: Add/confirm behavioral test asserting the agent dispatches the `mcp-tool-usage` skill.
- verify: Behavioral test passes (agent dispatches the `mcp-tool-usage` skill).
- commit: Behavioral test.

### Item 4 (SC-2a): Relocate glob semantics to selection-guide.md

- RED: Behavioral enforcement test (existing from #2334) asserting an agent given a glob task with a hidden/gitignored target emits a canonical path-parameter invocation; fails while glob semantics remain only in guideline §2.
- GREEN: Move glob semantics (LIM-1..6, canonical path-parameter idiom, forbidden shapes, empty-result rule) to `mcp-tool-usage/tasks/selection-guide.md`.
- verify: grep confirms glob semantics present at `selection-guide.md`, absent from the SKILL.md card and guideline §2.
- commit: Glob-semantics relocation.

### Item 5 (SC-2b): Condense guideline §2 to pointer

- RED: N/A (content relocation).
- GREEN: Condense guideline §2 to a pointer to `mcp-tool-usage/tasks/selection-guide.md`.
- verify: File read confirms §2 is a pointer to the new location.
- commit: Guideline §2 condensation.

### Item 6 (SC-2c): Behavioral RED/GREEN proof for canonical glob invocation

- RED: Behavioral enforcement test (existing from #2334) fails while glob semantics remain only in guideline §2 (agent does not emit a canonical path-parameter invocation).
- GREEN: Confirm the behavioral test asserts the agent emits a canonical path-parameter glob invocation for a hidden/gitignored target.
- verify: Behavioral test passes (agent emits canonical path-parameter invocation, no false absence conclusion).
- commit: Behavioral test.

### Item 7 (SC-3a): Retain zero-tolerance cores

- RED: N/A (retention, no behavior change).
- GREEN: No change to retained sections; verify they remain verbatim.
- verify: File reads confirm each retained section present verbatim.
- commit: Verification evidence only (no content change).

### Item 8 (SC-3b): Verify opencode.jsonc array entry

- RED: N/A (verification of existing state).
- GREEN: No change to the array; confirm the entry is unchanged.
- verify: Read of `opencode.jsonc` confirms the array entry for `060-tool-usage.md` is unchanged.
- commit: Verification evidence only (no content change).

### Item 9 (SC-4a): Update 6 Read-links

- RED: N/A (link updates).
- GREEN: Update all 6 downstream glob-semantics Read-link sites to point at `mcp-tool-usage/tasks/selection-guide.md`.
- verify: Grep across `.opencode/**/*.md` confirms all 6 known sites point at the new location.
- commit: Read-link updates.

### Item 10 (SC-4b): Zero stale references

- RED: N/A (link updates).
- GREEN: No additional change beyond Item 9; confirm no stale references remain.
- verify: Grep across `.opencode/**/*.md` for stale references to the old glob-semantics location; confirm zero.
- commit: Verification evidence only (no content change).

### Item 11 (SC-5b): Triple Co-Application compliance

- RED: N/A (compliance check).
- GREEN: Apply Triple Co-Application (250/255/257) to every edited agent-facing file.
- verify: Triple Co-Application (250/255/257) compliance confirmed for all edited agent-facing files.
- commit: Edited agent-facing text.

## 6. Dependencies

- **Reference:** Issue #2364 (`[SPEC] Update mcp-tool-usage skill — anchor five-tier hierarchy & glob semantics`)
  - **Relationship:** Establishes the `mcp-tool-usage` skill as the canonical home for the five-tier hierarchy and glob semantics. This spec's condensation depends on that anchor existing. **Note:** #2364 proposes relocating glob semantics to the SKILL.md card; this spec resolves that the relocation target MUST be the sub-agent-readable `mcp-tool-usage/tasks/selection-guide.md` task card, NOT the SKILL.md card, because skill cards are orchestrator-only and not Read-linkable by sub-agents.
  - **Status:** Pending — must be reconciled before or alongside this spec's implementation.
- **Reference:** `.opencode/guidelines/060-tool-usage.md` §2 (source content for glob semantics)
  - **Relationship:** Source of the glob semantics being relocated.
  - **Status:** Satisfied (content exists).
- **Reference:** `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md` (pinned relocation target)
  - **Relationship:** The pinned sub-agent-readable home for glob semantics.
  - **Status:** Satisfied (file exists).
- **Reference:** `.opencode/guidelines/250-dark-prose-reference.md`, `255-distribution-shifting-reference.md`, `257-procedural-discipline-reference.md`
  - **Relationship:** Mandatory Triple Co-Application for all edited agent-facing text.
  - **Status:** Satisfied (files exist).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1a, SC-1b, SC-1c | Phase 1 |
| R-2 | SC-2a, SC-2c | Phase 2 |
| R-3 | SC-2b | Phase 2 |
| R-4 | SC-3a | Phase 3 |
| R-5 | SC-3b | Phase 3 |
| R-6 | SC-4a, SC-4b | Phase 5 |
| R-7 | SC-5b | Phase 6 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `060-tool-usage.md` | guideline | `.opencode/guidelines/060-tool-usage.md` | read |
| `mcp-tool-usage/SKILL.md` | skill card | `.opencode/skills/mcp-tool-usage/SKILL.md` | read |
| `mcp-tool-usage/tasks/selection-guide.md` | task card | `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md` | read |
| `opencode.jsonc` | config | `.opencode/opencode.jsonc` | read |
| 6 Read-link sites | task/guideline | `verification-before-completion/tasks/completion.md`, `sre-runbook/tasks/generate.md`, `audit/tasks/coherence-maintenance-validator.md`, `coherence-maintenance-investigator.md`, `content-audit-investigator.md`, `020-go-prohibitions.md` | grep |
| 250/255/257 reference cards | guideline | `.opencode/guidelines/250-dark-prose-reference.md`, `255-distribution-shifting-reference.md`, `257-procedural-discipline-reference.md` | read |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1a:** Verifying the hierarchy removal costs one grep. Skipping means the five-tier hierarchy is left duplicated in the guideline, fragmenting tool-selection routing and surfacing as behavioral FAIL in production at 1000× the cost.
- **SC-1b:** Verifying the hierarchy remains in the skill card costs one file read. Skipping means the single source of truth may be lost during condensation, breaking every downstream skill-card Read-link.
- **SC-1c:** Verifying the relocated hierarchy routing behaviorally (RED/GREEN) costs one behavioral test run. Skipping means tool-selection misrouting ships to production undetected.
- **SC-2a:** Verifying the glob-semantics relocation costs one grep. Skipping means glob semantics either move to a sub-agent-unreadable location (breaking 6 Read-links) or stay duplicated — agents conclude absence from silent-empty glob results.
- **SC-2b:** Verifying the §2 condensation costs one file read. Skipping means the guideline retains redundant glob content, defeating the token-savings purpose.
- **SC-2c:** Verifying the relocated glob-semantics routing behaviorally (RED/GREEN) costs one behavioral test run. Skipping means a hidden-dir lookup fails in production with a false absence conclusion.
- **SC-3a:** Verifying the retention of safety cores costs a few file reads. Skipping means a zero-tolerance rule (`.ipynb` mandate, API-client-mandatory, `project_root/tmp`-only) is silently dropped during condensation — a data-loss-prevention regression that ships unchanged.
- **SC-3b:** Verifying the `opencode.jsonc` array entry costs one file read. Skipping means the guideline could be dropped from preload, losing the safety cores at session start.
- **SC-4a:** Verifying the 6 Read-link updates costs one grep. Skipping means stale Read-links point at a condensed guideline lacking the glob definition — every downstream agent that follows the stale link operates without the canonical semantics.
- **SC-4b:** Verifying zero stale references costs one grep. Skipping means a leftover stale link silently routes agents to a location that no longer carries the glob definition.
- **SC-5b:** Verifying Triple Co-Application compliance costs reference-card consultation. Skipping means edited agent-facing text may contain dark-prose or distribution-shifting defects that degrade downstream agent behavior.

## 11. Edge Cases

- **Input boundaries — empty glob result:** An agent given a glob task with a hidden/gitignored target MUST NOT conclude absence from a silent-empty result. The relocated glob semantics must preserve the empty-result disambiguation rule (LIM-3): a silent-empty glob is not evidence of absence until the invocation shape is confirmed correct and the target path is reachable.
- **State transitions — condensation mid-flight:** If `060-tool-usage.md` §2 is condensed to a pointer before the 6 Read-links are updated (SC-4a not bundled with SC-2a), the Read-links dangle at the condensed guideline. Mitigation: SC-4a is bundled with SC-2a in the same phase so the relocation and link updates land together.
- **Failure modes — prerequisite #2364 divergence:** If #2364 relocates glob semantics to the SKILL.md card (sub-agent-unreadable), this spec's SC-2a relocation target conflicts. Mitigation: reconcile with #2364 before implementation; the pinned `mcp-tool-usage/tasks/selection-guide.md` relocation target is authoritative per the Read-link rule.
- **Concurrency — parallel skill-card edits:** If #2364 and this spec both edit `mcp-tool-usage` files concurrently, edits may conflict. Mitigation: dependency ordering — #2364 anchors the skill, this spec condenses the guideline; implement after #2364 or in a coordinated branch.
- **Recovery — stale Read-link discovery:** If a stale Read-link is found post-merge, the fix is a targeted Read-link update to the new glob-semantics location (`mcp-tool-usage/tasks/selection-guide.md`), verified by grep.

---

## Change Control

| Date | Change | Reason | Authorizer |
|------|--------|--------|------------|
| 2026-08-28 | Corrected SC-5 Read-link count from 8 to 6 (removed `collect.md`, whose `060-tool-usage.md` references are temp-files/cleanup, not glob semantics) and fixed the site enumeration to the 6 verified glob-semantics Read-link files. Decomposed compound SC-1/SC-2/SC-3/SC-5/SC-6 into atomic SCs (13 total: SC-1a/b/c, SC-2a/b/c, SC-3a/b, SC-4, SC-5a/b, SC-6a/b). Pinned the glob-semantics relocation target to `mcp-tool-usage/tasks/selection-guide.md` (removed the "or a dedicated reference file" escape hatch). Gave SC-4 a hard ≤1.2k token threshold (replaced "toward ~1.2k"). Updated Items (1:1 item-SC mapping, 13 items), Traceability, Cost Frame, Edge Cases, sc-summary.yaml, and the exec-summary remote body to match. | Validation findings: (1) factually wrong hard-coded Read-link count (8 → 6); (2) compound SCs bundling multiple independently verifiable claims; (3) non-deterministic targets (SC-2 either/or relocation, SC-4 no hard threshold). | Validation pipeline (spec revision) |
| 2026-08-28 | Pinned SC-1c to a single deterministic assertion: the criterion and verification method now assert the agent dispatches the `mcp-tool-usage` skill (removed the either/or "/" alternative "resolves via the five-tier hierarchy"). Reclassified SC-6b evidence type from `structural` to `semantic` (judgment-based Triple Co-Application compliance review). The `.opencode/.issues/2350/artifacts/` directory was NOT created — the 7 canonical analytical artifacts (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment) are absent from this spec. Updated Items (Item 3), Cost Frame (SC-1c), and sc-summary.yaml (SC-1c description, SC-6b evidence type) to match. | Validation findings: (1) SC-1c either/or "/" ambiguity in criterion and verification method — not a single deterministic assertion; (2) SC-6b evidence-type mismatch — declared "structural" but verified by judgment-based compliance review; (3) artifacts directory `.opencode/.issues/2350/artifacts/` absent — the Change Control entry falsely claimed the directory was created with the analytical artifacts; corrected to accurately state the artifacts are absent. | Validation pipeline (spec revision) |
| 2026-08-28 | Decomposed compound SC-6a by folding (Option B): the five-tier-hierarchy RED/GREEN proof folded into SC-1c and the glob-semantics RED/GREEN proof folded into SC-2c; SC-6a removed entirely (12 SCs total, down from 13). Updated the SC-1c and SC-2c criteria, verification methods, and evidence descriptions to carry the folded RED/GREEN routing proofs. Removed R-7 (renumbered R-8→R-7, R-9→R-8), removed Item 12 (SC-6a), renumbered Item 13 (SC-6b)→Item 12, and updated Traceability, Cost Frame, and sc-summary.yaml (sc_count 13→12, SC-1c/SC-2c descriptions, SC-6b plan_item 13→12) to match. | Validation findings: Aggregate FAIL on a single compound-SC defect — SC-6a bundled two distinct routing concerns (five-tier hierarchy routing AND glob-semantics routing) via "and", violating atomic-SC decomposition; each concern must have its own item/RED-GREEN cycle. | Validation pipeline (spec revision) |
| 2026-08-29 | Removed the false-target SC-4 (hard ≤1,200 token-count threshold) and all its coupled artifacts: the SC-4 row from Success Criteria, R-8 from Requirements, Item 9 (SC-4) from Items, the R-8 traceability row (Phase 4), the SC-4 Cost Frame entry, and the "Measurement boundary — token threshold" edge case. Removed the "Verify the token reduction against a hard ≤1.2k threshold" clause from the Approach Chosen. Renumbered subsequent elements to close the gap: SC-5a→SC-4a, SC-5b→SC-4b, SC-6b→SC-5b; Item 10→Item 9, Item 11→Item 10 (its GREEN now references Item 9), Item 12→Item 11; Traceability (R-6 → SC-4a/SC-4b, R-7 → SC-5b) and Cost Frame (SC-4a/SC-4b/SC-5b) updated to match. Updated sc-summary.yaml (sc_count 12→11, SC-4 removed, plan_item renumbering) to match. The condensation savings are now an emergent property of correctly implementing the content-based SCs, not a hard numerical target. | Revision reason: SC-4 imposed a hard token-count threshold. Condensation savings are an emergent property of correctly implementing the content-based SCs — a hard numerical threshold incentivizes aggressive trimming to hit a number rather than faithful implementation, causes agent malfunction, and improper reworking. | Spec revision (orchestrator dispatch) |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
