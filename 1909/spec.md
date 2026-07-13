---
title: "[SPEC-FIX] Restructure audit skill for DiMo 4-role chain dispatch based on agent intent"
status: draft
created: 2026-07-12
license: MIT
provenance: AI-generated
issue: 1909
authors:
  - OpenCode (ollama-cloud/deepseek-v4-pro)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-12

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The audit skill at `.opencode/skills/audit/SKILL.md` has a structural defect: the Trigger Dispatch Table dispatches to monolithic task files (one sub-agent per audit type), but the DiMo Role Chain Dispatch section (lines 110-119) documents a 4-role sequential chain (Generator → Knowledge Supporter → Evaluator → Path Provider) that is never wired into the dispatch mechanism. The approved design from [#1672](https://github.com/michael-conrad/.opencode/issues/1672)/[#1719](https://github.com/michael-conrad/.opencode/issues/1719) specifies "one agent dispatched sequentially through four different task files" — but the current implementation dispatches one sub-agent to one monolithic task file.

## Root Cause Analysis

The audit skill was built incrementally. The DiMo Role Chain Dispatch section was added as documentation of the intended architecture, but the Trigger Dispatch Table and Invocation table were never updated to route through it. The task files were written as monolithic procedures that embed multiple DiMo roles into a single file (e.g., Evaluator task files contain Knowledge Supporter Step 0a). The result is a dispatch mechanism that routes to monolithic task files while the documented architecture describes a 4-role chain — a structural contradiction that means the DiMo chain is documentation, not enforcement.

## Goals

- Rewrite the audit skill description to use agent-intent language per [#1899](https://github.com/michael-conrad/.opencode/issues/1899)
- Restructure the Trigger Dispatch Table to route to the DiMo 4-role workflow
- Create dedicated role-specific task files for each audit type
- Remove monolithic task files
- Resolve Path Provider role ambiguity
- Add behavioral enforcement test for 4-role chain dispatch

## Non-Goals

- **New audit types** — This spec restructures existing audit types only; no new audit capabilities are added
- **DiMo role procedure changes** — The 4-role chain procedure (Generator → Knowledge Supporter → Evaluator → Path Provider) is preserved as-is; this spec only wires it into dispatch
- **Other skill restructures** — Only the audit skill is restructured; other skills are unaffected

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Keep monolithic task files, add DiMo as an optional path | Creates two dispatch paths for the same audit — maintenance burden, ambiguity about which path to use |
| Merge all 4 roles into a single task file per audit type | Defeats the purpose of clean-room separation between roles; Generator bias contaminates Evaluator |
| Use a single sub-agent that internally sequences roles | No clean-room separation — the same context sees all roles, defeating independent verification |

## Safety Considerations

- **Rollback:** If the restructure breaks audit dispatch, revert to the previous SKILL.md and task files from git history
- **No data loss:** Old task files are deleted only after new role-specific files are created and verified
- **Behavioral test gate:** SC-8 behavioral test MUST pass before any file deletions

## Defects to Fix

1. **Description uses user-utterance matching** — "User phrases: audit spec, audit plan..." — MUST use agent-intent language per [#1899](https://github.com/michael-conrad/.opencode/issues/1899)
2. **Trigger Dispatch Table dispatches to monolithic task files** — one row per audit type, one sub-agent — MUST route to the 4-role DiMo chain
3. **Task files claim a single DiMo role but contain procedures for all roles** — Evaluator task files have Step 0a (Knowledge Supporter work) embedded
4. **No dedicated Generator, Knowledge Supporter, or Path Provider task files exist** for most audit types — only `coherence-extraction.md` correctly claims Generator
5. **Two task files claim Path Provider role** — `cross-validate.md` and `completion.md` both claim "Path Provider (Judger)"
6. **DiMo Role Chain Dispatch section is documentation, not a dispatch instruction** — the orchestrator reads the Trigger Dispatch Table, not the prose

## Solution

### Phase 1: SKILL.md Restructure
- Rewrite description to use agent-intent language: "Dispatch when the agent needs independent verification of a deliverable before claiming completion. The audit MUST use the DiMo 4-role chain (Generator → Knowledge Supporter → Evaluator → Path Provider) dispatched as sequential clean-room sub-agents."
- Restructure Trigger Dispatch Table to route to the DiMo workflow, not to individual monolithic task files
- Make the DiMo Role Chain Dispatch section the authoritative dispatch instruction
- Remove the Invocation table that dispatches to monolithic task files

### Phase 2: Create Role-Specific Task Files
For each audit type (spec-audit, verification-audit, plan-fidelity, concern-separation, coherence-maintenance, guideline-audit, drift-detection, content-audit, test-quality-audit), create 4 role-specific task files:
- `{audit-type}-generator.md` — collects raw evidence, writes evidence.yaml
- `{audit-type}-knowledge-supporter.md` — validates evidence, writes reasoning.yaml
- `{audit-type}-evaluator.md` — produces binary PASS/FAIL, writes verdict.yaml
- `{audit-type}-path-provider.md` — synthesizes final judgment, writes judgment.yaml

### Phase 3: Remove Monolithic Task Files
- Delete the old monolithic task files (spec-audit.md, verification-audit.md, etc.)
- Remove Knowledge Supporter Step 0a from Evaluator task files
- Resolve Path Provider role ambiguity — keep `cross-validate.md` as the Path Provider, remove the role claim from `completion.md`

### Phase 4: Behavioral Tests
- SC-8: Agent dispatches 4-role chain, not monolithic sub-agent

## Affected Files

| File | Change |
|------|--------|
| `audit/SKILL.md` | Rewrite description, restructure Trigger Dispatch Table, make DiMo section authoritative |
| `audit/tasks/{type}-generator.md` | New — 9 files, one per audit type |
| `audit/tasks/{type}-knowledge-supporter.md` | New — 9 files |
| `audit/tasks/{type}-evaluator.md` | New — 9 files (or rename existing, stripping Step 0a) |
| `audit/tasks/{type}-path-provider.md` | New — 9 files |
| `audit/tasks/spec-audit.md` | Delete — replaced by 4 role-specific files |
| `audit/tasks/verification-audit.md` | Delete |
| `audit/tasks/plan-fidelity.md` | Delete |
| `audit/tasks/concern-separation.md` | Delete |
| `audit/tasks/coherence-maintenance.md` | Delete |
| `audit/tasks/guideline-audit.md` | Delete |
| `audit/tasks/drift-detection.md` | Delete |
| `audit/tasks/content-audit.md` | Delete |
| `audit/tasks/test-quality-audit.md` | Delete |
| `audit/tasks/completion.md` | Remove Path Provider role claim |
| `audit/tasks/cross-validate.md` | Keep as Path Provider, remove ambiguity |

## Dispatch Flow (Post-Fix)

```
Orchestrator determines need for audit (agent intent)
  → skill({name: "audit"})
  → Trigger Dispatch Table routes to DiMo workflow
  → DiMo Role Chain Dispatch:
    1. task() Generator (clean-room, receives spec_local_dir)
       → writes evidence.yaml, returns artifact path
    2. task() Knowledge Supporter (clean-room, receives evidence.yaml path)
       → writes reasoning.yaml, returns artifact path
    3. task() Evaluator (clean-room, receives evidence.yaml + reasoning.yaml paths)
       → writes verdict.yaml, returns artifact path
    4. task() Path Provider (clean-room, receives all artifact paths)
       → writes judgment.yaml, returns final verdict
```

Each role is a separate task() call. No shared context between roles. The orchestrator only passes artifact paths.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| [#1672](https://github.com/michael-conrad/.opencode/issues/1672) | PREREQUISITE | Approved spec for DiMo-aligned audit architecture |
| [#1719](https://github.com/michael-conrad/.opencode/issues/1719) | PREREQUISITE | Approved plan for DiMo implementation |
| [#1899](https://github.com/michael-conrad/.opencode/issues/1899) | RELATED | Agent-intent description matching principle |
| [#1908](https://github.com/michael-conrad/.opencode/issues/1908) | RELATED | Post-remediation re-audit mandate |

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

SC-8 is behavioral — a behavioral PASS is a break. A structural-only PASS (grep for 4 task files without verifying the agent actually dispatches them) is a death spiral. The behavioral test MUST verify actual agent dispatch behavior.

## Revision Policy

| Artifact | Cascade Trigger | Action on Parent Revision |
|----------|----------------|---------------------------|
| Implementation plan | MUST | Revise to match revised spec |
| Behavioral tests | SHOULD | Review for continued validity |
| Role-specific task files | MUST | Regenerate if audit type list changes |

## Decomposition Classification

| Classification | Number of Phases | Phase Artifact Requirements | PR Strategy |
| -------------- | ---------------- | --------------------------- | ----------- |
| multi-phase | 4 | One `plan-{NN}.md` phase file per phase (local `.issues/` only) | stacked PRs per phase |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `read(.opencode/skills/audit/SKILL.md)` | Verify current Trigger Dispatch Table and DiMo section |
| Direct source search | `glob(.opencode/skills/audit/tasks/*.md)` | Verify current task file inventory |
| MCP search | `github_issue_read(method=get, issue_number=1672)` | Verify approved DiMo spec |
| MCP search | `github_issue_read(method=get, issue_number=1719)` | Verify approved DiMo plan |
| MCP search | `github_issue_read(method=get, issue_number=1899)` | Verify agent-intent description principle |

After this spec is approved, invoke `writing-plans` to create `.issues/1909/plan.md` before implementation begins.

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | Description uses agent-intent language, not "User phrases:" pattern | string | grep for "User phrases:" in description — must be absent |
| SC-2 | Trigger Dispatch Table routes to DiMo workflow, not to individual monolithic task files | string | grep Trigger Dispatch Table — no rows dispatching to old monolithic task names |
| SC-3 | Dedicated Generator task files exist for each audit type | structural | ls audit/tasks/*-generator.md — 9 files |
| SC-4 | Dedicated Knowledge Supporter task files exist for each audit type | structural | ls audit/tasks/*-knowledge-supporter.md — 9 files |
| SC-5 | Dedicated Path Provider task files exist for each audit type | structural | ls audit/tasks/*-path-provider.md — 9 files |
| SC-6 | Evaluator task files contain no Knowledge Supporter work (no Step 0a) | string | grep for "Knowledge Supporter" in *-evaluator.md — must be absent |
| SC-7 | DiMo Role Chain Dispatch section is the authoritative dispatch instruction | string | grep SKILL.md — DiMo section present, old Invocation table absent |
| SC-8 | Agent dispatches 4-role chain, not monolithic sub-agent | behavioral | opencode-cli run with audit prompt — assert 4 separate task() calls in stderr |
| SC-9 | Only one task file claims Path Provider role | string | grep for "Path Provider (Judger)" in audit/tasks/ — exactly one match in cross-validate.md |
| SC-10 | No monolithic task files remain | structural | ls audit/tasks/spec-audit.md — must be absent (same for all old monolithic files) |
| SC-11 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | behavioral | opencode-cli run — verify agent does not lobotomize behavioral SC-8 |

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
