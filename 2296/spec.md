---
title: "[SPEC] Semantic dispatch link text as purpose-statement condensation"
remote_issue: 2296
remote_url: https://github.com/michael-conrad/.opencode/issues/2296
promoted_at: 2026-08-18T00:39:00Z
labels:
  - spec
  - needs-approval
---

## Problem Statement

Skill card task dispatch wording uses dead-weight link text. Across 50 SKILL.md files, 48 contain dispatch links and all 255 dispatch links use `[text]` that restates the path (e.g., `[gh-cli/tasks/authenticate.md](.opencode/skills/gh-cli/tasks/authenticate.md)`). The `[text]` duplicates the URL that is already present, providing the tasked sub-agent with zero semantic context about what it is about to do. The sub-agent receives no meaningful context anchor until it opens the file.

The deck already knows the correct semantic pattern — it is used in body cross-references (`Read [the full operating protocol](release-promoter/tasks/operating-protocol.md)`) and documented as the correct dispatch form in 7 of 8 skills' DISPATCH_GATE tables — but never applied to actual dispatch strings. This is an internal contradiction: documented pattern vs. shipped dead-weight links.

## Success Criteria

- SC-1: All 255 dispatch link `[text]` values across the 48 affected SKILL.md files are rewritten as condensations of their task card's purpose statement. The `[text]` is outcome-oriented, concise, distinctive from sibling tasks, and faithful to the purpose's core outcome. The URL remains the path.
- SC-2: Purpose statements that fail the audit criteria (not condensable, not outcome-as-subject, or not distinctive from siblings) are corrected. Each corrected purpose statement is a separate atomic work unit with its own SC.
- SC-3: The `playwright-cli` and `completion-core` skills are converted from the legacy table dispatch format to the canonical checkbox list sub-bullets format.
- SC-4: Placeholder dispatch links (audit skill) use semantic templates (e.g., `[investigate <audit-type>]`) rather than path templates, with rewording to avoid the template allowed.
- SC-5: The `skill-creator` skill carries the normative rule that every new card created or existing card edited must use a condensation dispatch anchor, enforced via a validation gate that checks condensation format compliance on card create/edit.
- SC-6: `reference/task-card-structure-standards.md` specifies the purpose statement as the dispatch-anchor source (condensable, outcome-as-subject, distinctive).
- SC-7: `reference/skill-card-description-standards.md` specifies the locked dispatch template: `You are a sub-agent. Follow the instructions in [<condensation>](<path>). <context-fields>`.

## Approach

1. Run a pre-spec investigation audit: a scripted scan produces a structured manifest of purpose statements and dispatch texts; per-skill sub-agents review the manifest against the audit criteria; findings drive the SC decomposition.
2. The SC decomposition is determined by atomic work units and separation of concerns — one SC per atomic, verifiable unit; purpose corrections get their own SCs.
3. Rewrite dispatch link texts as purpose condensations.
4. Convert playwright-cli and completion-core to canonical checkbox format.
5. Update skill-creator (normative rule + validation gate) and the two reference docs.

## Affected Files

- .opencode/skills/*/SKILL.md (48 files with dispatch links)
- .opencode/skills/skill-creator/SKILL.md
- .opencode/reference/task-card-structure-standards.md
- .opencode/reference/skill-card-description-standards.md

## Notes

- This is a format/quality improvement, not a behavior fix. No gross failure exists today. Enforcement is a structural condensation-format check (validation gate in skill-creator), not a behavioral RED test.

🤖 OpenCode (deepseek-v4-flash) created
