> **Full spec and artifacts: [`.issues/1921/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1921)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.issues/1921/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The 4 DiMo roles in the audit skill have names that don't match what they actually do. The pipeline is gather → validate → evaluate → judge, but the role names obscure this flow: "Generator" implies text generation (it collects evidence), "Knowledge Supporter" sounds like a help desk role (it validates evidence), and "Path Provider"/"Judger" are abstract names where "Judger" isn't even a real word.

## Goals

- Rename Generator → Investigator (investigates and collects evidence, connotes discovery not creation)
- Rename Knowledge Supporter → Validator (validates evidence integrity against source data, direct single word)
- Keep Evaluator as-is
- Rename Path Provider → Arbiter (renders final judgment after weighing all evidence, connotes authority and synthesis)
- Update all references consistently across ~54 task files, SKILL.md, 2 behavioral test files, and the Trigger Dispatch Table

## Non-Goals

- No changes to the DiMo chain dispatch logic itself — only role name strings change
- No changes to Evaluator role
- No changes to pipeline stage order, semantics, or artifact names

## Scope

All files in `.opencode/skills/audit/` that reference DiMo roles (~54 task files + SKILL.md), 2 behavioral test files in `.opencode/tests/behaviors/`, and the audit skill's Trigger Dispatch Table and DiMo Role Chain Dispatch section. File names containing old role names are also renamed.

## Approach

Systematic find-and-replace across all affected files: rename file names (`*-generator.md` → `*-investigator.md`, etc.), replace role name strings in file contents, update SKILL.md dispatch table, update behavioral tests, and verify no broken references via grep and behavioral test execution.

## Impact

- **Missed references cause broken dispatch** — mitigated by exhaustive grep verification and behavioral tests
- **Behavioral test assertions reference old names** — mitigated by updating test files in the same change
- **No dependencies** — this is a self-contained rename within the audit skill

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
