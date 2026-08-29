> Full spec and plan artifacts: https://github.com/michael-conrad/.opencode/tree/issues-data/2408/

## Problem

Three confirmed defects in the `skildeck` CLI tooling degrade deck-validation reliability for every agent that uses it:

1. **8 of 17 documented actions are broken** — `skildeck analyze`, `skildeck export`, and the `exhaustive|entailment|guards|enforcement|triggers|decomposition` sub-actions all crash or fail because the `sym-*` analysis modules they dispatch to do not exist in `.opencode/tools/impl/` (that directory contains only `jupyter-*`, `md-*`, `py-*`, and `skildeck/`). The `sym-*` backing scripts were deleted from disk as part of a deleted analysis engine system.
2. **`skildeck validate` produces false `MISSING_DISPATCH_TABLE` verdicts** — it hard-codes `## Trigger Dispatch Table` as the only recognized dispatch-table heading, while `reference/skill-card-schema.md` documents `## Workflows` as the canonical format. 14 skills with valid `## Workflows` dispatch tables are flagged.
3. **`skildeck lint` fires `MISSING_SKILL_MD_FOR_TASKS_DIR` on 46/51 skills** — the rule requires a `SKILL.md` inside every `tasks/` directory, but zero skills have one; the canonical structure places `SKILL.md` at the skill root.

All findings verified by direct file inspection and tool execution; full evidence in `tmp/opencode-defects-investigation.md`.

## Scope

- **A1 — Dead `sym-*` analysis dispatch entries.** `.opencode/tools/skildek` defines an `ANALYSIS` dict (lines 54-61) mapping `exhaustive→sym-exhaustive`, `entailment→sym-entailment`, `guards→sym-guards`, `enforcement→sym-enforcement`, `triggers→sym-triggers`, `decomposition→sym-decomposition`. None of these `sym-*` scripts exist under `.opencode/tools/impl/` — they were deleted as part of a removed analysis engine system. The help text prints them as available actions, and `main()` checks `ANALYSIS` before `ACTIONS`, routing to non-existent scripts. Remove the dead dispatch entries, the `ANALYSIS` dict, the help text section that prints analysis modules, and the ANALYSIS dispatch logic in `main()`.
- **A2 — `skildeck validate` false positives.** `.opencode/tools/impl/skildeck/skildeck-validate` hard-codes `REQUIRED_HEADING = "## Trigger Dispatch Table"` (line 34) and the legacy `REQUIRED_COLUMNS` set. `reference/skill-card-schema.md` ("Workflows Section (Replaces Trigger Dispatch Table + Invocation)") documents `## Workflows` as the canonical heading. The 14 skills using `## Workflows` — audit, completion-core, executing-plans, gb-cli, gh-cli, git-workflow, git-workflow-branch, git-workflow-cleanup, git-workflow-commit, git-workflow-conflict, git-workflow-pr, playwright-cli, spec-creation, writing-plans — all report `MISSING_DISPATCH_TABLE` despite containing valid dispatch tables (verified by reading each SKILL.md).
- **A3 — `skildeck lint` noise rule.** `.opencode/tools/impl/skildeck/skildeck-lint` (lines 560-569) Check 2 requires every `tasks/` dir to contain its own `SKILL.md` (`tasks_dir / "SKILL.md"`). Zero skills in the deck have a SKILL.md inside `tasks/` (find count = 0). The canonical skill-card structure places SKILL.md at the skill root, not inside `tasks/`. The rule fires on every skill with a `tasks/` dir (46 findings) — pure noise that drowns real findings.

**Out of scope:** A4 lint noise (skill-word-count / provenance unknown-field), Section B broken dispatch references (missing task files), Section C TDT/Invocation incompleteness, Section D workflow/contract lint findings, Section E guideline broken references — documented in the investigation artifact, tracked separately.

## Approach

- **A1:** The `sym-*` backing scripts were deleted from disk (part of a deleted analysis engine system). The correct fix is to **remove the dead dispatch entries** from `.opencode/tools/skildeck`: delete the `ANALYSIS` dict, delete the help text section that prints "Analysis modules:", and delete the dispatch block in `main()` that checks `if action in ANALYSIS` before routing to `ACTIONS`. The advertised action list in the help docstring (`exhaustive, entailment, guards, enforcement, triggers, decomposition`) must also be removed. `analyze`, `export`, and `watch` also internally load a `sym-extract` module that no longer exists — their internal `_load_module("sym-extract")` calls must be removed or replaced with safe fallback since the analysis engine they depend on is deleted.
- **A2:** Update `skildeck-validate` to accept `## Workflows` as a valid dispatch-table heading (the canonical format per `reference/skill-card-schema.md`), keeping backward compatibility for the legacy `## Trigger Dispatch Table` heading so older decks do not regress.
- **A3:** Remove or re-scope the `MISSING_SKILL_MD_FOR_TASKS_DIR` check — it encodes a structure the deck never uses; the rule must not fire on the canonical skill-root SKILL.md layout.

## Impact

Top risks:
1. Agents running `skildeck` against the deck get crashes or false verdicts that mask genuine deck defects and erode trust in the tool → mitigate by fixing A1-A3 so output reflects real deck state.
2. Changing validate/lint rules without updating their tests could silently break legacy `## Trigger Dispatch Table` decks → mitigate by retaining backward-compatible handling of the legacy heading and adding regression coverage.
3. Existing skildeck-related specs (#1213, #1208, #1222) touch the same linter code → coordinate changes to avoid merge conflicts on `skildeck-lint` / `skildeck-validate`.

Dependencies: `reference/skill-card-schema.md`, `.opencode/tools/impl/skildeck/*`, `.opencode/tools/skildeck`, related skildeck specs (#1213, #1208, #1222).

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-08-28 | Revised A1 approach: from "re-create sym-* modules" to "remove dead ANALYSIS dispatch entries" | Correct approach is removal, not re-creation — the sym-* backing scripts were deleted from disk as part of a deleted analysis engine system | OpenCode (DeepSeek-V4-Flash) |
