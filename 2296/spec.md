---
title: "[SPEC] Semantic dispatch link text as purpose-statement condensation"
remote_issue: 2296
remote_url: https://github.com/michael-conrad/.opencode/issues/2296
promoted_at: 2026-08-18T00:39:00Z
labels:
  - spec
  - needs-approval
---

> **Full spec and artifacts: [`.opencode/.issues/2296/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2296)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2296/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## 1. Intent and Executive Summary

### Problem Statement

Skill card task dispatch wording uses dead-weight link text. Across 50 SKILL.md files, 48 contain dispatch links and all 255 dispatch links use `[text]` that restates the path (e.g., `[gh-cli/tasks/authenticate.md](.opencode/skills/gh-cli/tasks/authenticate.md)`). The `[text]` duplicates the URL that is already present, providing the tasked sub-agent with zero semantic context about what it is about to do. The sub-agent receives no meaningful context anchor until it opens the file.

### Root Cause / Motivation

The deck already knows the correct semantic pattern — it is used in body cross-references (`Read [the full operating protocol](release-promoter/tasks/operating-protocol.md)`) and documented as the correct dispatch form in 7 of 8 skills' DISPATCH_GATE tables — but never applied to actual dispatch strings. This is an internal contradiction: documented pattern vs. shipped dead-weight links. The dispatch discovery directive in `reference/task-card-structure-standards.md` §4 and the base prompt format in `reference/skill-card-description-standards.md` both use the path-restatement template with no condensation/purpose-source requirement. This must be solved now because every new skill card created or edited inherits the dead-weight pattern, compounding the defect across the deck.

### Approach Chosen

Rewrite every dispatch link `[text]` as a condensation of the linked task card's Purpose statement, preserving the URL as the path. Correct purpose statements that fail the condensation audit. Convert the two legacy-format skills (playwright-cli, completion-core) to the canonical checkbox-list format. Convert the audit skill's placeholder dispatch links to semantic templates. Add a structural condensation-format validation gate to skill-creator and lock the condensation dispatch template in the two reference documents.

### Alternatives Considered & Why Discarded

- **Resolution-table + admonition pattern** — discarded. The research card `cross-reference-form-comparison.md` (confidence 0.95) shows this pattern achieves only 42-58% access rate; the agent reads the table as text but does not follow the links. The inline markdown link form is the only viable pattern at 100% Tier 1 access rate.
- **Behavioral RED/GREEN enforcement test** — discarded. This is a format/quality improvement, not a behavior fix. No gross failure exists today. Enforcement is a structural condensation-format check (validation gate in skill-creator), not a behavioral RED test.

### Key Design Decisions

- **Inline-link preservation:** SC-1 rewrites only the link `[text]`, never the URL. The dispatch discovery directive MUST keep the inline markdown link form (path stays a real link). This preserves routing integrity while improving semantic context.
- **Purpose statement as condensation source:** The task card's Purpose section (first content section after provenance/frontmatter) is the normative source for the condensation. This establishes a single, consistent source contract.
- **Structural enforcement, not behavioral:** The validation gate is a structural condensation-format check in skill-creator, not a behavioral RED test. Tradeoff: structural checks are cheaper but catch format defects only at card create/edit time, not at dispatch time.
- **Per-SC atomicity:** Each SC maps to exactly one implementation item with its own RED/GREEN/verify/commit cycle. Purpose corrections get their own SCs (SC-2) rather than being folded into the rewrite pass.

### User Intent / Original Prompt

The user requested that semantic dispatch link text be used as purpose-statement condensation — replacing the dead-weight path-restatement link text across the skill deck with meaningful semantic anchors derived from task card purpose statements.

## 2. Not Included

- **Behavioral RED/GREEN enforcement test for the condensation rule** — Rationale: this is a format/quality improvement, not a behavior fix; enforcement is a structural validation-gate check.
- **Change to the dispatch-link URL/path structure** — Rationale: only the `[text]` anchor content changes; the URL stays the task path.
- **Body cross-reference form** — Rationale: the `Read [the full operating protocol](path)` form is already correct and is NOT in scope for change.
- **Skills without dispatch links** — Rationale: 2 of the 50 SKILL.md files contain no dispatch links and are unaffected.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | All 255 dispatch link `[text]` values across the 48 affected SKILL.md files are rewritten as condensations of their task card's purpose statement. The `[text]` is outcome-oriented, concise, distinctive from sibling tasks, and faithful to the purpose's core outcome. The URL remains the path. | string | Structural condensation-format check: rg/regex over the 48 SKILL.md files verifying every dispatch link `[text]` is a purpose condensation (not a path restatement) and the URL is unchanged. | `.opencode/skills/*/SKILL.md` (48 files); `reference/task-card-structure-standards.md` §4 |
| SC-2 | Purpose statements that fail the audit criteria (not condensable, not outcome-as-subject, or not distinctive from siblings) are corrected. Each corrected purpose statement is a separate atomic work unit with its own SC. | string | Structural audit of corrected purpose statements: verify condensability, outcome-as-subject, distinctiveness from siblings; re-run the SC-1 condensation check on corrected purposes. | `.opencode/skills/*/tasks/*.md` Purpose sections |
| SC-3 | The `playwright-cli` and `completion-core` skills are converted from the legacy table dispatch format to the canonical checkbox list sub-bullets format. | string | Structural format check: verify playwright-cli and completion-core use canonical numbered-checkbox sub-bullets (no legacy Trigger Dispatch Table / Invocation sections). | `.opencode/skills/playwright-cli/SKILL.md`; `.opencode/skills/completion-core/SKILL.md` |
| SC-4 | Placeholder dispatch links (audit skill) use semantic templates (e.g., `[investigate <audit-type>]`) rather than path templates, with rewording to avoid the template allowed. | string | Structural check: verify audit dispatch links use semantic templates in `[text]` (no path-restatement in `[text]`); URL path template unchanged. | `.opencode/skills/audit/SKILL.md` |
| SC-5 | The `skill-creator` skill carries the normative rule that every new card created or existing card edited must use a condensation dispatch anchor, enforced via a validation gate that checks condensation format compliance on card create/edit. | structural | Unit-test the new validate_skill_cards.py condensation check (positive case: condensation `[text]` passes; negative case: path-restatement `[text]` FAILs). Run the script against sample rewritten cards. | `.opencode/skills/skill-creator/SKILL.md`; `.opencode/skills/skill-creator/scripts/validate_skill_cards.py`; `.opencode/skills/skill-creator/tasks/validate.md` |
| SC-6 | `reference/task-card-structure-standards.md` specifies the purpose statement as the dispatch-anchor source (condensable, outcome-as-subject, distinctive). | string | Structural doc review: verify §4 specifies purpose as dispatch-anchor source (condensable, outcome-as-subject, distinctive). | `.opencode/reference/task-card-structure-standards.md` §4 |
| SC-7 | `reference/skill-card-description-standards.md` specifies the locked dispatch template: `You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>`. | string | Structural doc review: verify locked condensation dispatch template present and consistent with SC-6. | `.opencode/reference/skill-card-description-standards.md` |

## 4. Requirements

- R-1. The system SHALL rewrite all 255 dispatch link `[text]` values across the 48 affected SKILL.md files as condensations of their task card's purpose statement.
- R-2. The condensation `[text]` SHALL be outcome-oriented, concise, distinctive from sibling tasks, and faithful to the purpose's core outcome.
- R-3. The dispatch link URL SHALL remain the task path; only the `[text]` anchor content SHALL change.
- R-4. Purpose statements that fail the audit criteria (not condensable, not outcome-as-subject, or not distinctive from siblings) SHALL be corrected, each as a separate atomic work unit.
- R-5. The `playwright-cli` and `completion-core` skills SHALL be converted from the legacy table dispatch format to the canonical checkbox list sub-bullets format.
- R-6. Placeholder dispatch links in the audit skill SHALL use semantic templates rather than path templates, with rewording to avoid the template allowed.
- R-7. The `skill-creator` skill SHALL carry the normative rule that every new card created or existing card edited uses a condensation dispatch anchor.
- R-8. The `skill-creator` validation gate SHALL check condensation format compliance on card create/edit.
- R-9. `reference/task-card-structure-standards.md` SHALL specify the purpose statement as the dispatch-anchor source (condensable, outcome-as-subject, distinctive).
- R-10. `reference/skill-card-description-standards.md` SHALL specify the locked dispatch template: `You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>`.
- R-11. The validation gate SHALL be a structural condensation-format check, not a behavioral RED test.
- R-12. Condensations SHALL be faithful to the purpose's core outcome — semantic, not decorative or path-derived.
- R-13. Condensations SHALL be distinctive from sibling tasks within the same skill to avoid ambiguous dispatch routing.

## 5. Items

### Item 1 (SC-1): Rewrite all 255 dispatch link [text] values as purpose-statement condensations

- RED: Structural condensation-format check fails — verify dispatch link `[text]` values are path-restatements (not condensations).
- GREEN: Rewrite every dispatch link `[text]` across the 48 affected SKILL.md files as a condensation of the linked task card's Purpose statement; URL remains the path.
- verify: Structural condensation-format check against purpose source; manifest diff review.
- commit: The 48 SKILL.md files with rewritten dispatch link `[text]` values.

### Item 2 (SC-2): Correct purpose statements failing audit criteria

- RED: Structural audit fails — identify purpose statements that are not condensable, not outcome-as-subject, or not distinctive from siblings.
- GREEN: Correct the flagged purpose statements in the affected task cards.
- verify: Structural audit of corrected purpose statements; re-run the SC-1 condensation check.
- commit: Corrected Purpose sections in affected task cards.

### Item 3 (SC-3): Convert playwright-cli and completion-core to canonical checkbox-list sub-bullets format

- RED: Structural format check fails — verify playwright-cli and completion-core use legacy table dispatch format.
- GREEN: Convert both skills to the canonical numbered-checkbox list with sub-bullet dispatch contracts (Prompt, Context, Returns, Execution mode).
- verify: Structural format check against canonical Workflows template.
- commit: playwright-cli/SKILL.md and completion-core/SKILL.md converted to canonical format.

### Item 4 (SC-4): Convert audit placeholder dispatch links to semantic templates

- RED: Structural check fails — verify audit dispatch links use path templates in `[text]`.
- GREEN: Rewrite the 4 audit/SKILL.md placeholder dispatch links from path templates to semantic templates (e.g., `[investigate <audit-type>]`); URL path template unchanged.
- verify: Structural check that `[text]` no longer restates the path.
- commit: audit/SKILL.md with semantic-template dispatch links.

### Item 5 (SC-5): Add normative condensation-anchor rule + validation gate to skill-creator

- RED: Unit test fails — verify no condensation-format check exists in validate_skill_cards.py.
- GREEN: Add the normative rule to skill-creator and a structural condensation-format validation check in validate_skill_cards.py and/or the validate.md workflow.
- verify: Run validate_skill_cards.py against a sample of rewritten cards; gate PASS on compliant cards, FAIL on path-restatement.
- commit: skill-creator/SKILL.md, scripts/validate_skill_cards.py, tasks/validate.md.

### Item 6 (SC-6): Specify purpose statement as dispatch-anchor source in task-card-structure-standards.md

- RED: Structural doc review fails — verify §4 lacks purpose-as-dispatch-anchor-source normative language.
- GREEN: Add to reference/task-card-structure-standards.md §4 the normative spec that the purpose statement is the dispatch-anchor source (condensable, outcome-as-subject, distinctive).
- verify: Structural doc review; cross-reference check with SC-7 template.
- commit: reference/task-card-structure-standards.md.

### Item 7 (SC-7): Specify locked condensation dispatch template in skill-card-description-standards.md

- RED: Structural doc review fails — verify base prompt format lacks the locked condensation dispatch template.
- GREEN: Add to reference/skill-card-description-standards.md the locked dispatch template: `You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>`.
- verify: Structural doc review; cross-reference check with SC-6 purpose-source spec.
- commit: reference/skill-card-description-standards.md.

## 6. Dependencies

- **Reference:** `reference/task-card-structure-standards.md` §4 — **Relationship:** SC-6 defines the purpose-as-dispatch-anchor-source contract that SC-1's condensation rewrites and SC-5's validation gate depend on. **Status:** Pending (must be updated in this spec).
- **Reference:** `reference/skill-card-description-standards.md` — **Relationship:** SC-7 defines the locked condensation dispatch template that SC-1's rewrites and SC-5's gate must conform to. **Status:** Pending (must be updated in this spec).
- **Reference:** `skill-creator/scripts/validate_skill_cards.py` — **Relationship:** SC-5's validation gate integrates into this existing mechanical gate. **Status:** Satisfied (existing file, 576 lines).
- **Reference:** `skill-creator/tasks/validate.md` — **Relationship:** SC-5's gate is documented in this workflow. **Status:** Satisfied (existing file).
- **Reference:** Research card `cross-reference-form-comparison.md` — **Relationship:** SC-1's inline-link preservation decision is grounded in this card's findings (confidence 0.95). **Status:** Satisfied.

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 2 |
| R-2 | SC-1 | Phase 2 |
| R-3 | SC-1 | Phase 2 |
| R-4 | SC-2 | Phase 2 |
| R-5 | SC-3 | Phase 2 |
| R-6 | SC-4 | Phase 2 |
| R-7 | SC-5 | Phase 3 |
| R-8 | SC-5 | Phase 3 |
| R-9 | SC-6 | Phase 3 |
| R-10 | SC-7 | Phase 3 |
| R-11 | SC-5 | Phase 3 |
| R-12 | SC-1 | Phase 2 |
| R-13 | SC-1 | Phase 2 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Skill card dispatch links | code | `.opencode/skills/*/SKILL.md` (48 files) | Live rg scan on 2026-08-18: 255 dispatch links confirmed |
| Task card Purpose sections | code | `.opencode/skills/*/tasks/*.md` | Live read of gh-cli/tasks/authenticate.md: Purpose is first content section |
| Task File Discovery Directive | doc | `reference/task-card-structure-standards.md` §4 | Live read: path template only, no condensation requirement |
| Base prompt format | doc | `reference/skill-card-description-standards.md` | Live read: line 309 uses `[<skill>/tasks/<task>.md]` |
| skill-creator validation script | code | `skill-creator/scripts/validate_skill_cards.py` | Live read: 576 lines, mechanical REQ-1/2/3 checks |
| skill-creator validate workflow | doc | `skill-creator/tasks/validate.md` | Live read: 7-phase review workflow |
| Cross-reference form research | research | `.opencode/.issues/research-cards/cross-reference-form-comparison.md` | Live read: confidence 0.95, inline-link is only viable pattern |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Verifying all 255 dispatch link `[text]` values are purpose condensations costs one rg/regex scan over the 48 files. Skipping means dead-weight link text ships unchanged, and the next sub-agent dispatched through it receives zero semantic context until it opens the file — a defect that surfaces at every dispatch, compounding across the deck.
- SC-2: Auditing corrected purpose statements costs a structural re-check of condensability, outcome-as-subject, and distinctiveness. Skipping means a non-condensable purpose produces a condensation that is either decorative or path-derived, defeating the semantic anchor the whole spec exists to create.
- SC-3: Verifying the two legacy-format skills use canonical checkbox sub-bullets costs a structural format check. Skipping means playwright-cli and completion-core remain the only two skills on the legacy table format, and their dispatch contracts drift from the canonical form every other skill follows.
- SC-4: Verifying audit placeholder links use semantic templates costs a structural check that `[text]` no longer restates the path. Skipping means the 4 DiMo roles remain indistinguishable in link text, and the sub-agent cannot tell which role it is being dispatched to until it opens the file.
- SC-5: Unit-testing the new condensation-format validation gate costs running validate_skill_cards.py against sample cards. Skipping means the gate ships untested — either too strict (flags valid condensations, blocking legitimate card creation) or too loose (path-restatement passes, letting the dead-weight pattern back in).
- SC-6: Verifying §4 specifies purpose as dispatch-anchor source costs a structural doc review. Skipping means the condensation source contract is undefined, and SC-1's rewrites and SC-5's gate have no normative basis to enforce against.
- SC-7: Verifying the locked condensation dispatch template is present and consistent with SC-6 costs a structural doc review. Skipping means the format contract is undefined, and future skill cards inherit the dead-weight path-restatement pattern the spec exists to eliminate.

## 11. Edge Cases

- **Condition:** A task card has no Purpose section. **Expected behavior:** The rewrite pass MUST NOT silently skip the link. **Resolution:** BLOCK the rewrite for that link and route to SC-2 correction (add a Purpose section).
- **Condition:** A purpose statement is not condensable (too long, not outcome-as-subject). **Expected behavior:** The condensation MUST NOT be decorative or path-derived. **Resolution:** Route the purpose to SC-2 correction before rewriting the link.
- **Condition:** A condensation is not distinctive from a sibling task within the same skill. **Expected behavior:** The condensation MUST be distinctive to avoid ambiguous dispatch routing. **Resolution:** Route the purpose to SC-2 correction to make it distinctive.
- **Condition:** A dispatch link shares a task path across multiple workflows (e.g., writing-plans links appear in multiple TDT entries). **Expected behavior:** Each link is individually rewritten; condensation remains distinctive per dispatch context. **Resolution:** Rewrite each occurrence independently with context-appropriate condensation.
- **Condition:** The validation gate flags a valid condensation (false positive). **Expected behavior:** The gate MUST NOT block legitimate card creation. **Resolution:** Tune the gate's condensation-format check to accept compliant condensations.
- **Condition:** The validation gate lets a path-restatement pass (false negative). **Expected behavior:** The gate MUST FAIL on path-restatement. **Resolution:** Strengthen the gate's check to reject path-restatement `[text]`.
- **Condition:** A purpose correction changes task semantics. **Expected behavior:** The correction MUST NOT alter the task's core outcome. **Resolution:** Block the correction and require intent preservation review.
- **Condition:** The audit skill's 4 placeholder links become ambiguous across DiMo roles after semantic templating. **Expected behavior:** The 4 roles (investigator/validator/evaluator/arbiter) MUST remain distinguishable. **Resolution:** Use role/outcome-based semantic templates that preserve role distinctiveness.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
