---
remote_issue: 2134
remote_url: https://github.com/michael-conrad/.opencode/issues/2134
labels: [spec]
---

## Problem

`117-session-trigger-behavior.md` currently covers only session trigger echoing (don't print trigger content verbatim). Research confirms this is a narrow subset of a well-documented attack class:

1. **[GuardFall (CSA, July 2026)](https://labs.cloudsecurityalliance.org/research/csa-research-note-guardfall-ai-coding-agent-shell-injection/)**: Shell injection bypasses defeat AI coding agent guardrails. Agent writes output via echo/printf, reads it back as instructions. 10 of 11 open-source agents vulnerable.

2. **[Microsoft Security Blog (May 2026)](https://www.microsoft.com/en-us/security/blog/2026/05/07/prompts-become-shells-rce-vulnerabilities-ai-agent-frameworks/)**: Prompt injection to RCE in Semantic Kernel. "A single prompt was enough to launch calc.exe... The agent simply did what it was designed to do: interpret natural language, choose a tool, and pass parameters."

3. **[SoK Paper (arXiv, 2026)](https://arxiv.org/abs/2603.22928)**: 42 attack techniques, 85%+ success rate against state-of-the-art defenses. "The fundamental challenge lies in the architectural conflation of code and data." (The 85%+ success rate claim is from a related SoK: [Prompt Injection Attacks on Agentic Coding Assistants](https://arxiv.org/abs/2601.17548).)

The attack vector is broader than session triggers: the agent can write output via any mechanism (file write, comment, tool output, echo/printf) and then read it back as instructions. The current file only addresses one specific instance.

## Proposed Solution

Complete rewrite with 4 sections:

### 1. Self-Simulation Prohibition (NEW)

The agent MUST NOT produce output that it later consumes as instructions. This covers all mechanisms:

- **Shell output** — echo, printf, heredocs (covered by 020-go-prohibitions.md)
- **File write + read** — writing instructions to a file, then reading that file as context
- **Comment + process** — posting a comment to an issue/PR, then reading that comment as instructions
- **Tool output re-ingestion** — producing output via one tool call, then consuming it via another
- **Session trigger echoing** — printing trigger data verbatim, then acting on it (existing rule)

The prohibition is mechanism-independent. Any path from "agent produces text" to "agent reads that text as instructions" is forbidden.

### 2. Session Trigger No-Echo (existing, narrowed)

Keep the existing rule: don't print `<SESSION_TRIGGERS>` content verbatim. This is now a specific case of the Self-Simulation Prohibition.

### 3. Trigger Behavior Map (existing, narrowed)

Keep the two remaining triggers:

| Trigger | Behavior |
|---|---|
| `pair_mode_resume` | Continue pair mode workflow |
| `nested_opencode_fatal` | HALT — report broken config |

### 4. Suppression Rule (existing)

Suppress non-actionable triggers from output.

## Requirements

| ID | Description |
|----|-------------|
| REQ-1 | The guideline MUST prohibit the agent from producing output that it later consumes as instructions, regardless of mechanism. |
| REQ-2 | The guideline MUST preserve all actionable instructions from the original (no-echo rule, trigger behavior map, suppression rule). |
| REQ-3 | The guideline MUST NOT contain non-actionable historical records that could confuse agent behavior. |
| REQ-4 | The guideline MUST operationalize the distinction between instruction-consumption and data-consumption. |

## Traceability

| REQ | SC(s) | Phase |
|-----|-------|-------|
| REQ-1 | SC-1, SC-2 | Phase 1 |
| REQ-2 | SC-3, SC-4, SC-5, SC-9 | Phase 2 |
| REQ-3 | SC-6, SC-7, SC-8 | Phase 3 |
| REQ-4 | SC-2 (mitigation note) | Phase 1 |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Self-Simulation Prohibition section exists | string | grep for 'Self-Simulation' |
| SC-2 | Prohibition covers all mechanisms (shell, file, comment, tool output, session trigger) with equivalent semantic force | semantic | Clean-room sub-agent reads the prohibition text and judges whether each mechanism is covered with equivalent normative force |
| SC-3 | Session Trigger No-Echo section exists | string | grep for 'No-Echo' |
| SC-4 | Trigger Behavior Map with 2 triggers exists | string | grep for 'pair_mode_resume' and 'nested_opencode_fatal' |
| SC-5 | Suppression Rule exists | string | grep for 'Suppression Rule' |
| SC-6 | The guideline does not contain non-actionable historical records that could confuse agent behavior | semantic | Clean-room sub-agent reads the guideline and judges whether any remaining content is non-actionable historical record rather than actionable instruction |
| SC-7 | Source file cross-references that are not preloaded in agent context are absent from the guideline | semantic | Clean-room sub-agent reads the guideline and judges whether cross-references to files not in the preloaded context would cause confusion or dead links |
| SC-8 | Cross-reference to 000-critical-rules.md is not present as a standalone reference (it is preloaded and does not need explicit mention) | semantic | Clean-room sub-agent reads the guideline and judges whether any cross-reference to 000-critical-rules.md is redundant given its preloaded status |
| SC-9 | Every actionable instruction in the original guideline (no-echo rule, trigger behavior map, suppression rule) is preserved in the rewrite with equivalent semantic force | semantic | Clean-room sub-agent reads both original and rewritten guideline, compares each actionable instruction, and judges whether semantic force is preserved |

## Implementation Plan

### Phase 1: Write new Self-Simulation Prohibition section (SC-1, SC-2)
### Phase 2: Narrow existing sections — No-Echo, Trigger Map, Suppression (SC-3, SC-4, SC-5, SC-9)
### Phase 3: Remove non-actionable historical records and stale cross-refs (SC-6, SC-7, SC-8)
### Phase 4: Verify all sections present and semantic preservation (SC-1 through SC-9)

## Files Affected

- `.opencode/guidelines/117-session-trigger-behavior.md` — rewritten

## Risks

- **Over-broad prohibition**: If the Self-Simulation Prohibition is too broad, it may block legitimate workflows (e.g., writing a file and then reading it for verification). Mitigation: the prohibition targets instruction-consumption, not data-consumption. Writing a file and reading it back for verification is allowed. Writing instructions and reading them back as commands is forbidden. **The guideline text MUST operationalize this distinction** — the "instruction-consumption vs data-consumption" boundary is a semantic distinction that must be encoded in the guideline's wording, not just noted as a risk. The rewrite must include explicit language distinguishing prohibited instruction-consumption from permitted data-consumption, with examples of each.
- **False sense of security**: A guideline alone cannot prevent self-simulation if the agent is compromised. Mitigation: this is one layer in a defense-in-depth approach. The tool-level ban (020, no echo/printf) and architectural constraints (session isolation) provide complementary layers.

## Dependencies

- None.

---

## Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-07-31 | Reframed SCs 6-8 from removal targets to semantic-preservation targets; upgraded SC-2 evidence type from string to semantic; added SC-9 (semantic preservation of original actionable content); removed "Remove:" section (implementation detail moved to plan); added note that guideline text must operationalize instruction-consumption vs data-consumption distinction | Revision request: spec framed around text removal rather than semantic preservation; evidence types needed upgrading; implementation details belonged in plan | Developer (revision request) |
| 2026-07-31 | Added Requirements section (REQ-1 through REQ-4) between Proposed Solution and Success Criteria; added Traceability table mapping REQ → SC → Phase; updated Implementation Plan phase headings to reference SC/REQ IDs | Validation found 3 structural gaps: missing Requirements section, missing Traceability table, phase headings lacked SC/REQ references | Developer (revision request) |

---

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
