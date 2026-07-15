---
title: Replace bare §N cross-reference links with descriptive text
status: draft
created: 2026-07-15
license: MIT
provenance: AI-generated
issue: 1953
authors:
  - OpenCode (deepseek-v4-flash)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-15

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unavoidable, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

`Read [§1](guidelines/020-go-prohibitions.md)` — bare section numbers as link text provide zero semantic signal to an AI agent about what the link points to. The agent sees "§1" and must follow the link to discover the content, wasting context and routing bandwidth.

## Investigation

An audit of all `Read [§N](...)` cross-reference links across `.opencode/` found 7 instances in `guidelines/000-critical-rules.md` where link text uses bare `§N` instead of descriptive text. The `Read-Link Cross-Reference Rule` in `AGENTS.md` mandates that cross-references use descriptive text so the agent knows what it's linking to.

### Affected File

`guidelines/000-critical-rules.md` — 7 instances:

| Line | Current Link | Replace With |
|------|-------------|--------------|
| 38 | `Read [§1](guidelines/020-go-prohibitions.md)` | `Read [the GO Prohibitions section](guidelines/020-go-prohibitions.md)` |
| 42 | `Read [§1](guidelines/020-go-prohibitions.md)` | `Read [the GO Prohibitions section](guidelines/020-go-prohibitions.md)` |
| 155 | `Read [§2](guidelines/060-tool-usage.md)` | `Read [the Path Rules section](guidelines/060-tool-usage.md)` |
| 504 | `Read [§1](guidelines/020-go-prohibitions.md)` | `Read [the GO Prohibitions section](guidelines/020-go-prohibitions.md)` |
| 813 | `Read [§1.1](guidelines/020-go-prohibitions.md)` | `Read [the Orchestrator Context Discipline section](guidelines/020-go-prohibitions.md)` |
| 818 | `Read [§1.1](guidelines/020-go-prohibitions.md)` | `Read [the Orchestrator Context Discipline section](guidelines/020-go-prohibitions.md)` |
| 1099 | `Read [§1.1 Terminology Standardization](guidelines/020-go-prohibitions.md)` | `Read [the Terminology Standardization section](guidelines/020-go-prohibitions.md)` |

Note: Line 1099 uses `§1.1 Terminology Standardization` which already has trailing descriptive text. The replacement uses the descriptive text as link text, dropping the `§1.1` prefix.

### Files Not Affected

Other files listed in the initial investigation scope (210-scripting.md, INDEX.md, 250-dark-prose-reference.md, 257-procedural-discipline-reference.md, 085-project-local-tools.md, 065-verification-honesty.md, skills/approval-gate-scope/tasks/, skills/git-workflow-*/SKILL.md, skills/mcp-tool-usage/SKILL.md) do not contain `Read [§N]` patterns in the current codebase state. The root `AGENTS.md` in opencode-config has only 2 Read links, both already descriptive — no changes needed.

## Goals

- Every `Read [§N](...)` link in `.opencode/` uses descriptive link text naming the target section
- No functional changes to any file — only link text modified

## Non-Goals

- Changing non-`Read` cross-reference patterns (e.g., `See file.md §N`) — only `Read [§N]` patterns are in scope
- Updating the root `AGENTS.md` in opencode-config — already has descriptive links

## Scope

Single file: `.opencode/guidelines/000-critical-rules.md` — 7 link text replacements.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Every `Read [§N](...)` link in `.opencode/guidelines/000-critical-rules.md` is replaced with `Read [<descriptive text>](...)` where descriptive text names the target section | `string` | `grep -n 'Read \[§' .opencode/guidelines/000-critical-rules.md` — zero matches |
| SC-2 | Links that already use descriptive text (e.g., `Read [§Cost Model](...)`, `Read [§Monolithic Implementation](...)`) are left unchanged | `string` | `grep -n 'Read \[§[A-Z]' .opencode/guidelines/000-critical-rules.md` — existing matches preserved |
| SC-3 | Link text accurately describes the target section's content | `semantic` | Sub-agent spot-check of 3 random replacements |
| SC-4 | No functional changes to any file — only link text modified | `structural` | `git diff --stat` shows only link text changes in a single file |

## Risk and Edge Cases

- **Over-replacement risk:** A `Read [§` pattern that is NOT a bare section reference (e.g., `Read [§Cost Model]`) could be incorrectly matched. Mitigation: SC-2 explicitly verifies that descriptive `§[A-Z]` patterns are preserved.
- **Line number drift:** The line numbers in the investigation table may shift if the file is edited between investigation and implementation. Mitigation: Use exact string matching, not line numbers, for replacements.

## Implementation Approach

One-shot find-and-replace across 7 instances in a single file. Each replacement is a simple link text change — no structural or semantic changes to content.

After this spec is approved, invoke `writing-plans` to create `.opencode/.issues/1953/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unavoidable, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Interdependency

No interdependencies — this spec is independent of other open issues.

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `rg -n 'Read \[§' .opencode/ --type md` | Identify all `Read [§N]` patterns in the codebase |
| Direct source search | `rg -n 'Read \[§' AGENTS.md` | Verify root AGENTS.md has no bare §N links |

🤖 Co-authored with AI: OpenCode (deepseek-v4-flash)
