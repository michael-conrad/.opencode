---
number: 2619
title: "Fix spec: supervision poll discipline regression — 60s cycle drifts and updates leave chat"
state: OPEN
labels: [spec]
---

# Fix Spec — supervision poll discipline regression (.opencode#2619)

## 1. Intent and Executive Summary

| # | Field | Description |
|---|-------|-------------|
| 1 | **Problem Statement** | The agent-supervisor poll discipline keeps regressing despite the behavioral-testing card's mandates and four prior corrections (#2557, #2561, #2570, #2594). Observed again 2026-10-15 during #2617: while supervising a long-running background reindex, the poll interval drifted 60 → 90 → 120 → 150 → 180 → 240 → 270 seconds across consecutive polls, and status reports rode inside tool outputs or were omitted — the developer cannot read tool outputs or agent reasoning, so an unreported interval is invisible time. A developer abort was required to stop an unreported 270-second poll. |
| 2 | **Root Cause / Motivation** | Two gaps compose. (a) **Scope gap:** the 60-second mandate is written as the "Agent-Supervisor Mandate" for behavioral runs (`opencode run` supervision); the supervising agent classified non-model background jobs (a ragsync reindex) as outside the mandate and let the cadence decay "while just waiting." Anything under active supervision by the agent in a working turn is the same discipline problem: the developer is waiting on an invisible process. (b) **Cadence-anchoring gap:** nothing states that the interval is a ceiling that never escalates while waiting — each prior correction fixed a specific failure mode (filtered output, mid-cycle yield, past-confirmation polling, long sleeps) but none bound the interval itself across operation kinds, and none required the per-poll update when a poll yields no new evidence, which is exactly when the update is most likely to be skipped. |
| 3 | **Approach Chosen** | One card amendment + one lessons-learned record. (1) Amend the `behavioral-testing` card's supervise-every-run rule (§9) to bind **any actively supervised long-running operation** — model runs and background jobs alike — to the fixed 60-second cycle; state that the interval never escalates while waiting; require a substantive in-chat text update after EVERY poll, where "no change" is a valid and required update. Mirror the same three clauses into `tests-v2/AGENTS.md`'s Agent-Supervisor Mandate section (the mirror site the card already references). (2) Record the 2026-10-15 correction in `.opencode/.issues/lessons-learned/session-2026-10-15/` with root-cause analysis. Developer-directed item (skill-creator carve-out applies; content standards bind). |
| 4 | **Alternatives Considered & Why Discarded** | (a) Scripted enforcement (a wrapper that blocks >60s) — discarded: cadence discipline is agent behavior; a script cannot read the chat channel, and the deck's founding-defect rule prohibits static enforcement of intent-decidable behavior. (b) Floor-level rule — discarded: the discipline governs supervised operations, a card-scoped concern; the floor's always-loaded criterion (visible before any card dispatch) is not met — the failure occurs only after a card (behavioral-testing) is loaded and a run launched. (c) Lessons-learned entry only — discarded: the entry records the instance; the scope gap that produced it would remain unbound in the governing card. |
| 5 | **Key Design Decisions** | (1) The 60-second interval is a **ceiling**, not a target to stretch: intervals never escalate while the supervised operation is pending. (2) The per-poll in-chat update is **unconditional** — no new evidence still produces the update ("no change" stated plainly). (3) The mandate binds **any actively supervised long-running operation**, not only model runs — the classification boundary that caused this regression. (4) Card amendment, not new card — the discipline already lives in behavioral-testing; growing a new surface would duplicate it. (5) The chat channel is the only delivery surface — tool outputs and todo lists are insufficient (established #2557). |

## 2. Not Included

- Mechanical enforcement of the cadence (Design Decision: intent-decidable, never scripted).
- Changes to poll-run.sh or harness monitor mechanics — the harness side behaved correctly in the observed instance.
- Retroactive tooling for past sessions — the lessons-learned record is the artifact.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The behavioral-testing card's supervise rule binds any actively supervised long-running operation (model runs and background jobs), fixes 60 seconds as a ceiling that never escalates while waiting, and requires an in-chat text update after every poll including no-change polls. | structural | Inspect the card text for all three clauses |
| SC-2 | tests-v2/AGENTS.md's Agent-Supervisor Mandate mirrors the same three clauses. | structural | Inspect the mirror section |
| SC-3 | The 2026-10-15 correction is recorded in lessons-learned with root-cause analysis naming the scope gap and the cadence-anchoring gap. | structural | The session record exists with the analysis |

## Cost Frame

One card amendment (three clauses in one rule), one mirror-section amendment, one lessons-learned record. No new cards, no new mechanisms, no scripted enforcement.

---
*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
