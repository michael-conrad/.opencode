> **Full spec and artifacts: [`.opencode/.issues/1672/`](https://github.com/michael-conrad/.opencode/tree/issues-data/1672)** — this issue is a condensed exec summary; the authoritative plan lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/1672/` — implementation plan, phase files, dependency contracts, audit findings

## Implementation Plan for #1672 — DiMo-Aligned Audit

**Goal:** Replace the cross-model-family audit system with role-differentiated task files. One agent (`subagent_type="general"`) dispatched sequentially through four different task files. The task files are the differentiators — each provides a hard persona with distinct point-of-view anchoring, rules, and constraints.

### Phases

| Phase | Name | SCs | Depends On |
|-------|------|-----|------------|
| 1 | Eliminate Cross-Model Infrastructure | SC-1, SC-2, SC-3, SC-9 | None |
| 2 | Rename Skill and Update Cross-References | SC-4, SC-10 | Phase 1 |
| 3 | Refactor 15 Task Files — DiMo Role Chain | SC-5, SC-6, SC-7, SC-8, SC-11, SC-12, SC-13 | Phase 1, 2 |
| 4 | Add Hard Persona Differentiation | SC-14 | Phase 1, 2, 3 |
| 5 | Update SKILL.md with DiMo Dispatch | SC-15 | Phase 1, 2, 3, 4 |
| 6 | Behavioral Tests | SC-10, SC-11 | Phase 1, 2, 3, 4, 5 |

### What Changed

- **Phase 1**: Deleted 4 auditor cards, `resolve-models`, `qualified-auditor-pool.sh`, removed `INSUFFICIENT_FAMILIES` references
- **Phase 2**: Renamed `adversarial-audit` to `audit`, updated 34 cross-referencing skills, updated 43 behavioral test files
- **Phase 3**: Refactored 15 task files — embedded DiMo role persona, removed `audit_phase`, added pre-clean steps, artifact paths, removed orchestrator routing content, removed "restart from step 0" instructions, added `remediation_required: true` to result contracts, added Knowledge Supporter phase to Evaluator files, updated `cross-validate.md` as Path Provider (Judger) task file, updated `resolve-models.md` as Path Provider reference
- **Phase 4**: Added hard persona differentiation to all 15 task files — Generator says "meticulous, non-judgmental", Evaluator says "decisive and binary", Path Provider says "synthesizer, not an evaluator". Removed all meta-labels ("Role Identity", "You own:", "Rules:", "Success:") — the sub-agent reads the persona and rules directly.
- **Phase 5**: Updated SKILL.md with DiMo role chain dispatch section
- **Phase 6**: Remaining behavioral test updates

### Authorization

- **Scope:** `for_pr` — plan auto-approved per approval cascade
- **PR strategy:** stacked
- **Halt at:** pr_created

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
