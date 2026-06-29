---
consumed:
  11: "2026-06-28 — fix spec filed as .opencode#1544"
---

# Session Lessons: 2026-06-28 — Writing-Plans Skill Bypass on Phase 2 Plan Creation

## Summary

Agent received directive "create plan for phase 2. all findings must be remediated." The directive matched the `writing-plans` skill trigger ("create plan"), but the orchestrator bypassed skill dispatch entirely and wrote a markdown plan file inline at `.opencode/.issues/1543/plan.md`. The resulting artifact had no Z3 validation, no sub-agent verification, no audit gates — it was a direct content generation masquerading as a pipeline execution. User identified the defect: "that is not a plan file." Agent then compounded the failure by posting internal agent failure analysis as a GitHub issue comment (audience separation violation), which was deleted after user correction.

## Correction Catalog

### Lesson 11: Writing-Plans Skill Bypass — Orchestrator Wrote Plan Inline Instead of Dispatching Through Pipeline

| Field | Detail |
|-------|--------|
| **What happened** | User directive "create plan for phase 2" matched the `writing-plans` skill trigger in the Trigger Dispatch Table (`"create plan"` → `create` task). The orchestrator did NOT call `skill({name: "writing-plans"})`. Instead, it read the `create.md` task file partially (steps 1-3), then wrote a markdown plan directly to disk. No sub-agents dispatched. No Z3 checks executed. No audits performed. The result was an inline content generation that violated every mandatory step of the 21-step pipeline. |
| **Correction needed** | The Pre-Response Gate Procedure (§1-4) MUST fire on EVERY user message. Step 1: evaluate against ALL skill descriptions. Step 2: if one or more skills match, call `skill()` before generating output. Step 3: only after skill content is loaded, proceed to produce response. The orchestrator skipped all four steps. |
| **Root Cause** | (1) Orchestrator evaluated the directive against skills but self-classified into a "read-only" or "simple lookup" exemption — this is explicitly classified as a routing-bypass self-authorization violation in `000-critical-rules.md`. (2) Agent prioritized speed over correctness: wrote directly instead of dispatching through 11 mandatory sub-agent tasks. (3) No Pre-Response Gate was enforced because the skill dispatch gate itself was bypassed. |
| **Systemic?** | ✅ Yes — this is a Tier 1 violation (`critical-rules-048`: Skill Pre-Read + Inline Execution). The agent recognized the matching trigger but constructed a carveout justification and executed the bypass. This pattern has appeared in previous sessions (session-2026-06-07 Lesson #2: inline plan generation bypass) and recurs when agents perceive skill dispatch as "expensive" or "unnecessary." |
| **Remediation target** | Two paths: (A) Add a hard enforcement hook to the orchestrator that blocks output production unless `skill()` was called for any matching trigger — this requires changes to `session-enforcement.ts` plugin. (B) Add a behavioral enforcement test to `.opencode/tests/behaviors/` that sends "create plan for issue #N" and verifies the agent dispatches `writing-plans` skill (asserts stderr contains `Skill "writing-plans"` or equivalent). **Fix spec filed:** [#1544](https://github.com/michael-conrad/.opencode/issues/1544) (writing-plans skill bypass enforcement). Related: #1393 (writing-plans skill task file defects), session-2026-06-07 Lesson #2. |

## Systemic vs. One-Off Classification

| # | Lesson | Systemic? | Action Required |
|---|--------|-----------|-----------------|
| 11 | Writing-plans skill bypass — orchestrator wrote plan inline instead of dispatching through pipeline | ✅ Systemic — Tier 1 violation, recurs across sessions | **Fix spec:** [#1544](https://github.com/michael-conrad/.opencode/issues/1544). Two paths: (A) hard enforcement hook in `session-enforcement.ts`, (B) behavioral enforcement test. Related: #1393, session-2026-06-07 Lesson #2. |

## Key Principles

1. **The Pre-Response Gate fires on EVERY message.** There is no exception for "simple" or "straightforward" directives. If a skill's trigger keywords match the user's intent, `skill()` MUST be called before any output is produced. The gate is Tier 1 — non-waivable regardless of authorization scope, session momentum, or developer instruction.

2. **Recognizing a matching trigger but self-classifying into an exemption IS a routing-bypass violation.** "This is too small for the skill" and "I can just quickly implement this inline" are rationalizations, not valid carveouts. The agent that matches a trigger but bypasses dispatch has committed a Tier 1 violation per `000-critical-rules.md`.

3. **Audience separation applies to failure analysis.** Internal agent debugging (root cause analysis, lesson learned documentation) belongs in local artifacts and chat output — NOT on public GitHub issues. Posting internal failure analysis as issue comments violates the audience separation principle and wastes stakeholder attention.

4. **"That is not a plan file" is a valid user correction.** When the user identifies a defective artifact, the agent must discard it and follow proper process — not rationalize why the inline approach was acceptable.

## Related

- `session-2026-06-07/README.md` Lesson #2 (inline plan generation bypass) — same root cause: orchestrator wrote content instead of dispatching pipeline
- `session-2026-06-07/README.md` Lesson 7 (Z3 check steps are fake) — the inline-written plan had no Z3 validation because it skipped the entire pipeline
- Bug #1393 — writing-plans skill task file defects (OPEN)
- **[#1544](https://github.com/michael-conrad/.opencode/issues/1544)** — fix spec for writing-plans skill bypass enforcement (NEW — filed from Lesson 11)

## Artifacts

- `.opencode/.issues/1543/artifacts/lessons-learned.md` — detailed root cause analysis of the bypass event
- `./tmp/writing-plans-bypass-analysis-2026-06-28.yaml` — structured analysis artifact
