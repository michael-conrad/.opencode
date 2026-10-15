# Session 2026-10-15 — Correction Catalog

## LL-1: Supervision poll discipline regression — interval drift + updates leaving chat

**Classification:** systemic (fourth recurrence of the class: #2557, #2561, #2570, #2594, now #2619)

**What happened:** While supervising a long-running background job (ragsync `reindex` of the
deck's retrieval source, `.opencode#2617` SC-7), the supervising agent's poll interval drifted
60 → 90 → 120 → 150 → 180 → 240 → 270 seconds across consecutive polls, and status reports
rode inside tool outputs or were omitted instead of being delivered as substantive in-chat
text. The developer cannot read tool outputs or agent reasoning — the drift was invisible
until a developer abort stopped an unreported 270-second poll.

**Root cause:** Two gaps compose.
1. *Scope gap* — the 60-second Agent-Supervisor Mandate is written for behavioral runs
   (`opencode run` supervision); the agent classified the non-model background job (reindex)
   as outside the mandate and let the cadence decay "while just waiting." Anything actively
   supervised by the agent in a working turn is the same problem: the developer is waiting on
   an invisible process.
2. *Cadence-anchoring gap* — no prior correction bound the interval itself as a ceiling that
   never escalates while waiting, and none required the per-poll update when a poll yields no
   new evidence — which is exactly when skipping the update is most tempting.

**Remediation (implemented in this change, .opencode#2619):** behavioral-testing card §9
amended — the mandate now binds ANY actively supervised long-running operation (model runs
and background jobs), fixes 60 seconds as a ceiling that never escalates while pending, and
makes the per-poll in-chat update unconditional ("no change" stated plainly is the update).
Mirrored into tests-v2/AGENTS.md's Agent-Supervisor Mandate.

**Evidence artifacts:** the #2617 session's poll timestamps (launch epoch 1792072334; polls
at escalating gaps through the reindex supervision); developer correction verbatim:
"poll discipline has failed. this is a regression. poll every 60s. report in chat every
poll. the dev cannot read your thoughts and hidden shell outputs. file a fix spec to address
this constant regression in behavior."
