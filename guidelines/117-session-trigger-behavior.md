---
trigger_on: session trigger, trigger, trigger warning, SESSION_TRIGGER
tier: 1
load_when: sub-agent
---

# Session Trigger Behavior

**The agent MUST follow the normative instructions in this guideline when handling session trigger data.**

## Self-Simulation Prohibition (Tier 1 Mandate)

**The agent MUST NOT produce output that it later consumes as instructions without passing through an authorization boundary.** This prohibition is mechanism-independent — it covers every path from "agent produces text" to "agent reads that text as instructions." The forbidden UNAUTHORIZED self-simulation mechanisms include:

- **Shell output** — writing instructions to stdout/stderr via `echo`, `printf`, heredocs, or any shell command, then consuming that output as instructions
- **File write + read** — writing instructions to a file, then reading that file back as context or instructions
- **Comment + process** — posting a comment to an issue or PR, then reading that comment back as instructions
- **Tool output re-ingestion** — producing output via one tool call, then consuming it via another tool call as instructions
- **Session trigger echoing** — printing `<SESSION_TRIGGERS>` data verbatim, then acting on it as instructions

The prohibition targets UNAUTHORIZED self-simulation — output the agent produces and then consumes as instructions WITHOUT an authorization gate. It does NOT forbid consuming output through an authorization boundary.

**Three-way distinction.** The guideline distinguishes three categories of instruction-consumption:

| Category | Status | Example |
|---|---|---|
| UNAUTHORIZED self-simulation | FORBIDDEN | Agent writes instructions and reads them back as commands without an authorization gate |
| AUTHORIZED pipeline | PERMITTED | Agent writes a spec/plan through the approved pipeline (spec-creation, writing-plans) with `approved-for-*` labels, then follows it |
| DATA consumption | PERMITTED | Agent writes file content as data, reads it back for verification |

**Authorization-provenance carve-out — PERMITTED.** The following project items the agent both produces and consumes are explicitly permitted because they pass through the authorization-gated pipeline:

- **Spec→plan→implementation pipeline** — spec files the agent writes and later implements against (via the spec-creation pipeline with `approved-for-*` labels) and plan files the agent writes and later follows (via the writing-plans pipeline with an approved spec)
- **Task tracking files** — task tracking files the agent creates for its own workflow (git-workflow work state files, checkpoint tags)
- **Spec and plan files** — spec files and plan files the agent writes and later implements against or follows
- **Authorization-gated project items** — any other project-related items the agent both produces and consumes through the authorization-gated pipeline

## Session Trigger No-Echo (Tier 1 Mandate)

**The agent MUST NOT print `<SESSION_TRIGGERS>` content verbatim in chat output.** This rule is a specific case of the Self-Simulation Prohibition above — echoing trigger content verbatim is one mechanism of producing output that the agent later consumes as instructions. This includes:

- Copying trigger section headings (e.g., "Pair Mode Resumed")
- Parroting trigger data (e.g., "Pair mode branch detected")
- Acknowledging triggers with a "Session triggers acknowledged" section
- Printing content from the `### NESTED_OPENCODE_FATAL` block

Triggers are internal state data for decision-making. The agent processes them and takes action — the trigger text itself never appears in the agent's response.

## Trigger Behavior Map

Only two triggers remain:

| Trigger Type | Agent Behavior |
|---|---|
| `pair_mode_resume` | Continue pair mode workflow (already works correctly — no change needed) |
| `nested_opencode_fatal` | **HALT all operations.** Report to developer immediately. Do NOT continue working. |

### `nested_opencode_fatal` — Critical Configuration Error

When the `### NESTED_OPENCODE_FATAL` block appears, the agent MUST:

1. **HALT immediately** — do not proceed with any operations
2. **Report to the developer** — inform them that the AI agent configuration is broken due to a nested `.opencode/.opencode/` directory
3. **Instruct the developer** to delete the nested `.opencode/.opencode/` directory
4. **Verify** that `.opencode/.gitignore` contains `.opencode/` to prevent recurrence

This is not a suggestion — it is a hard halt. A nested `.opencode/` directory completely breaks skill discovery and makes the agent non-functional for its primary purpose.

## Suppression Rule

Triggers that cannot drive meaningful action in the current context should be processed internally and suppressed from the agent's response entirely. The `<SESSION_TRIGGERS>` block remains in the user message for internal reasoning, but if a trigger provides no actionable insight, the agent should not mention it.

**Only `pair_mode_resume` produces visible agent behavior** — `nested_opencode_fatal` produces a hard halt.



---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
