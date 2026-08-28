> **Full spec and artifacts: [`.opencode/.issues/2350/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2350/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2350/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Condense 060-tool-usage.md — move five-tier hierarchy & glob semantics

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The preloaded `.opencode/guidelines/060-tool-usage.md` guideline costs ~4.1k tokens of orchestrator context at every session start. Roughly 70% of its content — the five-tier tool priority hierarchy and the built-in glob semantics (LIM-1..6, canonical path-parameter idiom, empty-result disambiguation rule) — is procedural content that is either already duplicated in the `mcp-tool-usage` skill card (five-tier hierarchy) or belongs in a sub-agent-readable location (glob semantics). This spec condenses the guideline to its zero-tolerance safety cores, relocating the procedural content to its authoritative home, without removing the guideline from the `opencode.jsonc` instructions array. |
| 2 | **Root Cause / Motivation** | The guideline was written as a monolithic preloaded Tier 1 file before the skill-card/task-card architecture matured. The five-tier hierarchy is already duplicated verbatim in `mcp-tool-usage/SKILL.md` (line 115), making the guideline's copy redundant. The glob semantics (LIM-1..6) exist ONLY in the guideline §2 — they are not yet present in the skill — and 8 downstream task files Read-link to `guidelines/060-tool-usage.md` for the canonical glob semantics. Every session start pays ~4.1k tokens to preload content that a skill load or a task-card Read-link could provide on demand. Condensing now reduces orchestrator context load without losing enforcement. |
| 3 | **Approach Chosen** | Relocate the five-tier hierarchy out of the guideline §1 (it already lives verbatim in the `mcp-tool-usage` skill card) and condense §1 to a Read-link. Relocate the glob semantics (LIM-1..6, canonical path-parameter idiom, empty-result rule) out of guideline §2 into a sub-agent-readable file — the `mcp-tool-usage/tasks/selection-guide.md` task card or a dedicated reference file — and condense §2 to a pointer. Update all 8 downstream Read-links in lockstep. Retain all zero-tolerance safety cores (`.ipynb` mandate, API-client-mandatory, `project_root/tmp`-only, command restrictions, identity-source semantics, linter advisory-only) verbatim in the guideline. Verify token savings and add behavioral enforcement coverage. |
| 4 | **Alternatives Considered & Why Discarded** | **Relocate glob semantics to the SKILL.md card (as proposed by prerequisite #2364):** Discarded. Skill cards are orchestrator-only routing metadata loaded via `skill()` — sub-agents cannot call `skill()` and cannot Read-link a skill card. The 8 downstream task files that Read-link to the guideline for glob semantics would break if the semantics moved to a card sub-agents cannot read. The relocation target MUST be a sub-agent-readable file (a task card or a dedicated reference file). |
| 5 | **Key Design Decisions** | **Glob-semantics relocation target is sub-agent-readable (task card or dedicated reference), NOT the SKILL.md card.** This decision is forced by the Read-link cross-reference rule: content referenced via `Read [Text](path)` must exist at a path sub-agents can read. The `mcp-tool-usage/tasks/selection-guide.md` task card is the natural home because it already carries file-type tool boundary guidance and is Read-linkable by sub-agents. Tradeoff: glob semantics move out of preload (saving tokens) but require all 8 Read-links to be updated in lockstep to avoid link rot. |
| 6 | **User Intent / Original Prompt** | Condense `060-tool-usage.md` — move the five-tier hierarchy and glob semantics to their authoritative homes while retaining the zero-tolerance safety cores and preserving the guideline's membership in the `opencode.jsonc` instructions array. |

## 2. Not Included

- **[Condensing or removing any data-loss-prevention rule]** — The zero-tolerance safety cores (`.ipynb` mandate, API-client-mandatory, `project_root/tmp`-only, command restrictions, production-data protection, identity-source semantics, linter advisory-only) are retained verbatim. No safety-critical content is removed.
- **[Removing `060-tool-usage.md` from the `opencode.jsonc` instructions array]** — The guideline MUST remain preloaded in the array. Only the file's content is condensed, not its array membership.
- **[Relocating glob semantics to the SKILL.md card]** — Skill cards are orchestrator-only and not Read-linkable by sub-agents; relocating there would break 8 downstream Read-links.
- **[Duplicating glob semantics in more than one location]** — Each concern has exactly one authoritative location after relocation (single source of truth).
- **[Modifying the `mcp-tool-usage` skill card's five-tier hierarchy]** — The skill card already carries the hierarchy verbatim; it becomes the single source of truth and is not rewritten by this spec.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | The five-tier tool priority hierarchy is removed from `060-tool-usage.md` §1 and replaced with a Read-link to the `mcp-tool-usage` skill; the hierarchy remains present verbatim in `mcp-tool-usage/SKILL.md` as the single source of truth; a behavioral test proves tool-selection routing still dispatches the `mcp-tool-usage` skill / resolves via the five-tier hierarchy. | behavioral | `opencode run` behavioral enforcement test asserting (via stderr) the agent dispatches `mcp-tool-usage` / routes via the five-tier hierarchy; structural grep confirms hierarchy absent from guideline §1 and present in skill card. | `.opencode/guidelines/060-tool-usage.md` §1; `.opencode/skills/mcp-tool-usage/SKILL.md` Five-Tier Tool Priority Hierarchy section |
| SC-2 | The glob semantics (LIM-1..6 table, canonical path-parameter idiom, forbidden shapes, empty-result disambiguation rule) are relocated from `060-tool-usage.md` §2 into a sub-agent-readable file — the `mcp-tool-usage/tasks/selection-guide.md` task card or a dedicated reference file — and guideline §2 is condensed to a pointer; a behavioral test proves an agent given a glob task with a hidden/gitignored target emits a working canonical path-parameter invocation (stderr), not a false absence conclusion. | behavioral | `opencode run` behavioral enforcement test (existing from #2334) asserting the agent emits a canonical path-parameter glob invocation for a hidden/gitignored target; structural grep confirms glob semantics present at the new location and absent from guideline §2. | `.opencode/guidelines/060-tool-usage.md` §2; relocation target file (task card or dedicated reference) |
| SC-3 | All zero-tolerance safety cores are retained verbatim in `060-tool-usage.md` (`.ipynb` mandate, API-client-mandatory rule, `project_root/tmp`-only rule, command restrictions, identity-source semantics, linter advisory-only rule), and `060-tool-usage.md` remains in the `opencode.jsonc` instructions array. | structural | File reads confirming each retained section is present verbatim; read of `opencode.jsonc` confirming the array entry for `060-tool-usage.md` is unchanged. | `.opencode/guidelines/060-tool-usage.md` §1 PROHIBITED + API Client Mandatory, §3, §4, §9, linter advisory-only; `.opencode/opencode.jsonc` instructions array |
| SC-4 | The condensed `060-tool-usage.md` shows a measurable token reduction from the baseline ~4.1k tokens (target ~1.2k tokens) while retaining all safety cores. | structural | Token-count measurement (`wc -w` or tokenizer) of the guideline before and after condensation. | `.opencode/guidelines/060-tool-usage.md` (whole-file token count) |
| SC-5 | All 8 downstream Read-link sites that referenced `guidelines/060-tool-usage.md` for glob semantics are updated to point at the new sub-agent-readable glob-semantics location, and zero stale references to the old location remain. | structural | Grep across `.opencode/**/*.md` for stale references to the old glob-semantics location; confirm zero. Confirm all 8 known sites point at the new location. | 8 Read-link sites: `verification-before-completion/tasks/completion.md`, `collect.md` ×2, `sre-runbook/tasks/generate.md` ×2, `audit/tasks/coherence-maintenance-validator.md`, `coherence-maintenance-investigator.md`, `content-audit-investigator.md`, `020-go-prohibitions.md` |
| SC-6 | A behavioral enforcement test proves relocated tool routing still works: RED before the change (agent does not follow the new routing), GREEN after (agent does follow it), covering the relocated five-tier hierarchy and glob-semantics routing; all edited agent-facing text complies with Mandatory Triple Co-Application (250/255/257). | behavioral | `opencode run` behavioral enforcement test with RED/GREEN assertion helpers on stderr; Triple Co-Application (250/255/257) reference-card consultation for every edited agent-facing file. | `.opencode/tests-v2/behaviors/` test scenarios; `.opencode/guidelines/250-dark-prose-reference.md`, `255-distribution-shifting-reference.md`, `257-procedural-discipline-reference.md` |

## 4. Requirements

- R-1. The system SHALL remove the five-tier tool priority hierarchy from `060-tool-usage.md` §1 and replace it with a Read-link to the `mcp-tool-usage` skill, leaving the skill card as the single source of truth.
- R-2. The system SHALL relocate the glob semantics (LIM-1..6 table, canonical path-parameter idiom, forbidden shapes, empty-result disambiguation rule) from `060-tool-usage.md` §2 into a sub-agent-readable file — a task card or a dedicated reference file — and SHALL NOT relocate them to the SKILL.md card.
- R-3. The system SHALL condense `060-tool-usage.md` §2 to a pointer to the new glob-semantics location.
- R-4. The system SHALL retain all zero-tolerance safety cores verbatim in `060-tool-usage.md` (`.ipynb` mandate, API-client-mandatory rule, `project_root/tmp`-only rule, command restrictions, identity-source semantics, linter advisory-only rule).
- R-5. The system SHALL keep `060-tool-usage.md` in the `opencode.jsonc` instructions array; condensation modifies the file's content only, not its array membership.
- R-6. The system SHALL update all 8 downstream Read-link sites that referenced `guidelines/060-tool-usage.md` for glob semantics to point at the new sub-agent-readable location.
- R-7. The system SHALL provide a behavioral enforcement test proving relocated tool routing (five-tier hierarchy and glob semantics) still works, with RED/GREEN assertion helpers on stderr.
- R-8. The system SHALL apply Mandatory Triple Co-Application (250/255/257 reference cards) to every edited agent-facing file.
- R-9. The system SHOULD achieve a measurable token reduction of `060-tool-usage.md` from the ~4.1k baseline toward ~1.2k while retaining all safety cores.

## 5. Items

### Item 1 (SC-1): Relocate five-tier hierarchy

- RED: Behavioral enforcement test asserting the agent does NOT currently route via the relocated hierarchy (fails because hierarchy is still duplicated in guideline).
- GREEN: Condense `060-tool-usage.md` §1 to a Read-link to `mcp-tool-usage`; skill card already carries the hierarchy verbatim.
- verify: Behavioral test passes (agent dispatches `mcp-tool-usage` / routes via five-tier hierarchy); grep confirms hierarchy absent from guideline §1, present in skill card.
- commit: Guideline §1 condensation + behavioral test.

### Item 2 (SC-2): Relocate glob semantics

- RED: Behavioral enforcement test (existing from #2334) asserting an agent given a glob task with a hidden/gitignored target emits a canonical path-parameter invocation; fails while glob semantics remain only in guideline §2.
- GREEN: Move glob semantics (LIM-1..6, canonical path-parameter idiom, forbidden shapes, empty-result rule) to a sub-agent-readable file (task card or dedicated reference); condense guideline §2 to a pointer.
- verify: Behavioral test passes; grep confirms glob semantics present at new location, absent from guideline §2.
- commit: Glob-semantics relocation + guideline §2 condensation + behavioral test.

### Item 3 (SC-3): Retain zero-tolerance cores

- RED: N/A (retention, no behavior change).
- GREEN: No change to retained sections; verify they remain verbatim.
- verify: File reads confirm each retained section present verbatim; read of `opencode.jsonc` confirms array entry unchanged.
- commit: Verification evidence only (no content change).

### Item 4 (SC-4): Token savings verification

- RED: N/A (measurement).
- GREEN: Measure token count of condensed guideline.
- verify: `wc -w` or tokenizer measurement confirms reduction from ~4.1k toward ~1.2k.
- commit: Measurement evidence only.

### Item 5 (SC-5): Update 8 Read-links

- RED: N/A (link updates).
- GREEN: Update all 8 downstream Read-link sites to point at the new glob-semantics location.
- verify: Grep across `.opencode/**/*.md` for stale references to the old location; confirm zero.
- commit: Read-link updates.

### Item 6 (SC-6): Behavioral enforcement test

- RED: Behavioral enforcement test fails before the change (agent does not follow new routing).
- GREEN: Add/update behavioral enforcement test covering relocated five-tier hierarchy and glob-semantics routing; apply Triple Co-Application to edited agent-facing text.
- verify: Behavioral test passes (GREEN); Triple Co-Application (250/255/257) compliance confirmed for all edited agent-facing files.
- commit: Behavioral test + edited agent-facing text.

## 6. Dependencies

- **Reference:** Issue #2364 (`[SPEC] Update mcp-tool-usage skill — anchor five-tier hierarchy & glob semantics`)
  - **Relationship:** Establishes the `mcp-tool-usage` skill as the canonical home for the five-tier hierarchy and glob semantics. This spec's condensation depends on that anchor existing. **Note:** #2364 proposes relocating glob semantics to the SKILL.md card; this spec resolves that the relocation target MUST be a sub-agent-readable file (task card or dedicated reference), NOT the SKILL.md card, because skill cards are orchestrator-only and not Read-linkable by sub-agents.
  - **Status:** Pending — must be reconciled before or alongside this spec's implementation.
- **Reference:** `.opencode/guidelines/060-tool-usage.md` §2 (source content for glob semantics)
  - **Relationship:** Source of the glob semantics being relocated.
  - **Status:** Satisfied (content exists).
- **Reference:** `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md` (candidate relocation target)
  - **Relationship:** Candidate sub-agent-readable home for glob semantics.
  - **Status:** Satisfied (file exists).
- **Reference:** `.opencode/guidelines/250-dark-prose-reference.md`, `255-distribution-shifting-reference.md`, `257-procedural-discipline-reference.md`
  - **Relationship:** Mandatory Triple Co-Application for all edited agent-facing text.
  - **Status:** Satisfied (files exist).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-2 | Phase 2 |
| R-4 | SC-3 | Phase 3 |
| R-5 | SC-3 | Phase 3 |
| R-6 | SC-5 | Phase 5 |
| R-7 | SC-6 | Phase 6 |
| R-8 | SC-6 | Phase 6 |
| R-9 | SC-4 | Phase 4 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `060-tool-usage.md` | guideline | `.opencode/guidelines/060-tool-usage.md` | read |
| `mcp-tool-usage/SKILL.md` | skill card | `.opencode/skills/mcp-tool-usage/SKILL.md` | read |
| `mcp-tool-usage/tasks/selection-guide.md` | task card | `.opencode/skills/mcp-tool-usage/tasks/selection-guide.md` | read |
| `opencode.jsonc` | config | `.opencode/opencode.jsonc` | read |
| 8 Read-link sites | task/guideline | `verification-before-completion/tasks/completion.md`, `collect.md`, `sre-runbook/tasks/generate.md`, `audit/tasks/coherence-maintenance-validator.md`, `coherence-maintenance-investigator.md`, `content-audit-investigator.md`, `020-go-prohibitions.md` | grep |
| 250/255/257 reference cards | guideline | `.opencode/guidelines/250-dark-prose-reference.md`, `255-distribution-shifting-reference.md`, `257-procedural-discipline-reference.md` | read |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the hierarchy relocation costs one behavioral test run plus a grep. Skipping means the five-tier hierarchy is either lost in condensation or left duplicated — tool-selection routing fragments and agents misroute, surfacing as behavioral FAIL in production at 1000× the cost.
- **SC-2:** Verifying the glob-semantics relocation costs one behavioral test run plus a grep. Skipping means glob semantics either move to a sub-agent-unreadable location (breaking 8 Read-links) or stay duplicated — agents conclude absence from silent-empty glob results, a defect discovered only when a hidden-dir lookup fails in production.
- **SC-3:** Verifying the retention of safety cores costs a few file reads. Skipping means a zero-tolerance rule (`.ipynb` mandate, API-client-mandatory, `project_root/tmp`-only) is silently dropped during condensation — a data-loss-prevention regression that ships unchanged.
- **SC-4:** Verifying the token reduction costs one measurement command. Skipping means the condensation's benefit (reduced orchestrator context load) is unproven — the change ships with no evidence it achieved its purpose.
- **SC-5:** Verifying the Read-link updates costs one grep. Skipping means stale Read-links point at a condensed guideline lacking the glob definition — every downstream agent that follows the stale link operates without the canonical semantics.
- **SC-6:** Running the behavioral enforcement test costs minutes of execution time. Skipping means the relocated routing regression ships to production and costs 1000× more to fix.

## 11. Edge Cases

- **Input boundaries — empty glob result:** An agent given a glob task with a hidden/gitignored target MUST NOT conclude absence from a silent-empty result. The relocated glob semantics must preserve the empty-result disambiguation rule (LIM-3): a silent-empty glob is not evidence of absence until the invocation shape is confirmed correct and the target path is reachable.
- **State transitions — condensation mid-flight:** If `060-tool-usage.md` §2 is condensed to a pointer before the 8 Read-links are updated (SC-5 not bundled with SC-2), the Read-links dangle at the condensed guideline. Mitigation: SC-5 is bundled with SC-2 in the same phase so the relocation and link updates land together.
- **Failure modes — prerequisite #2364 divergence:** If #2364 relocates glob semantics to the SKILL.md card (sub-agent-unreadable), this spec's SC-2 relocation target conflicts. Mitigation: reconcile with #2364 before implementation; the sub-agent-readable relocation target is authoritative per the Read-link rule.
- **Concurrency — parallel skill-card edits:** If #2364 and this spec both edit `mcp-tool-usage` files concurrently, edits may conflict. Mitigation: dependency ordering — #2364 anchors the skill, this spec condenses the guideline; implement after #2364 or in a coordinated branch.
- **Recovery — stale Read-link discovery:** If a stale Read-link is found post-merge, the fix is a targeted Read-link update to the new glob-semantics location, verified by grep.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
