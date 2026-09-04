<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->
---
trigger_on: discussion, question tool, pigeon-hole, brainstorming mode, open-ended, single topic, research card, card catalogue
tier: 2
load_when: sub-agent
---

# Discussion Mode Mandates

> Demoted from [020-go-prohibitions.md §1.6](020-go-prohibitions.md) — reach this content through the one-line pointer retained in the 020 core. Authorization law itself (what constitutes GO, prohibited solicitation patterns, halt rules) remains in the 020 core.

## 🚫 NEVER DO

- **Never use the `question` tool.** Structured multi-option prompts (e.g., "Which approach: A, B, or C?") are forbidden. The `question` tool forces the developer into a constrained choice — it is a pigeon-hole mechanism, not a discussion tool. All discussion must be open-ended.
- **Never pigeon-hole in natural language either.** Even without the `question` tool, presenting constrained options in prose ("Should we do X or Y?") is the same anti-pattern. Discussion must remain open-ended — the developer's answer may be "neither" or "something else entirely."
- **Never mix topics.** Every discussion addresses exactly one topic at a time. Multi-topic messages must be decomposed into single-topic turns. If the developer raises multiple topics, address them sequentially — one per response.
- **Never default to structured output.** Assume chat mode (open-ended discussion) unless the developer explicitly requests structured output (spec, plan, checklist, table). Brainstorming is the default — structured output is the exception.
- **Never answer without a live tool call.** Before every factual claim, the agent MUST make at least one live tool call (read, grep, srclight, GitHub API, bash) to verify the claim. Training data is not a source — it is a liability.
- **Never trust training data.** Assume training data is full of errors, omissions, and hallucinations. Discard it entirely. Every claim must be verified against live sources in the current session.
- **Never trust metadata without a live API call.** Issue state, PR merge status, labels, and all other metadata are assumed stale and false until verified by a live API call in the current session. Cached or remembered metadata is not evidence.
- **Never halt discussion to research.** Research during active discussions is expected — dispatch a sub-agent to investigate while continuing the conversation. The agent does not need to halt the discussion to look something up.
- **No skill-routing solicitation after authorization.** After receiving any unambiguous authorization phrase (`approved`, `go`, `approved for X`, etc.), the agent MUST NOT ask "should I invoke skill Y?" or present options for which skill to invoke. The authorization→skill mapping is deterministic: `approved` → `approval-gate` skill. The agent autonomously dispatches without soliciting the routing decision. This prohibition applies to ALL authorization modes — not just `for_pr` scope.

  | Prohibited Pattern | Why It Violates |
  |--|--|
  | "Should I invoke a skill to handle this authorization?" | The mapping is deterministic; no agent judgment needed |
  | "Should I invoke approval-gate?" | Same class as scope solicitation — the answer is always the same |
  | Using `question` tool with "Invoke skill" vs "Proceed directly" options | No decision branch exists — invoke the mandatory skill |

## ✅ ALWAYS DO

- Use open-ended questions and natural language for all discussion.
- Decompose multi-topic messages into single-topic turns.
- Default to brainstorming mode — structured output only on explicit request.
- Dispatch research sub-agents during active discussions without halting.
- **Research card catalogue — `.issues/research-cards/`**: Before dispatching research, list the cards using the canonical path-parameter glob form — `glob(pattern="*.md", path=".issues/research-cards")` — then grep frontmatter for the exact research question. Do NOT use a pattern-from-CWD form (e.g. `glob(pattern=".issues/research-cards/*.md")`), which silently cannot reach the hidden `.issues/` directory (LIM-1). Read [the canonical glob semantics](060-tool-usage.md) for the full limitation set. If an active card exists with acceptable confidence (`confidence >= 0.7`), skip the research dispatch and return cached findings. If no matching card or stale/insufficient confidence, dispatch research. After research, create or update the card with new findings, confidence score, source URLs, and tags.
