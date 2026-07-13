---
title: Rename DiMo audit role names to match human semantic intent
status: draft
created: 2026-07-13
license: MIT
provenance: AI-generated
issue: 1921
authors:
  - OpenCode (ollama-cloud/deepseek-v4-pro)
---

**STATUS:** DRAFT
**CREATED:** 2026-07-13

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

## Problem

The 4 DiMo roles in the audit skill have names that do not match what they actually do. The pipeline is gather → validate → evaluate → judge, but the role names obscure this flow:

1. **Generator** — implies text generation, but it collects raw evidence from source data
2. **Knowledge Supporter** — awkward compound noun, sounds like a help desk role, but it validates evidence against source data
3. **Evaluator** — this one is fine, keep as-is
4. **Path Provider** (also called "Judger") — abstract name, "Judger" is not a real word, but it synthesizes upstream artifacts into final judgment

The role names are embedded in ~54 task files, the SKILL.md Trigger Dispatch Table, the DiMo Role Chain Dispatch section, and 2 behavioral test files. Every file that references these roles by name must be updated consistently.

## Root Cause Analysis

The role names were chosen during initial DiMo chain design without semantic alignment to the actual pipeline stages. The names describe implementation mechanics ("generates evidence.yaml") rather than the human-understandable role in the pipeline ("investigates and collects evidence"). This creates cognitive friction for agents reading the dispatch instructions — the name does not prime the correct behavior.

**Root cause:** Role naming prioritized mechanical description over semantic intent. The pipeline stages (gather → validate → evaluate → judge) are clear, but the role names (Generator → Knowledge Supporter → Evaluator → Path Provider) obscure them.

## Alternatives Considered & Why Discarded

| Alternative | Discard Rationale |
|-------------|-------------------|
| Keep all names as-is | Perpetuates cognitive friction; "Judger" is not a real word |
| Rename only Path Provider | Inconsistent — leaves Generator and Knowledge Supporter misaligned |
| Use pipeline stage names directly (Gatherer, Validator, Evaluator, Judger) | "Gatherer" is too passive; "Judger" is still not a real word |
| Investigator, Validator, Evaluator, Arbiter (proposed) | Selected — each name maps to a real English word that connotes the correct pipeline stage |

## Safety Considerations

This is a textual rename only. No dispatch logic changes. No file structure changes. The risk is missed references causing broken dispatch, mitigated by:
- Exhaustive grep verification before and after rename
- Behavioral test updates in the same change
- The DiMo chain dispatch logic is unchanged — only role name strings change

## Objectives

Rename the 4 DiMo audit roles to names that match human semantic intent, making the pipeline stages (gather → validate → evaluate → judge) immediately clear from the role names alone.

## Goals

- Generator → Investigator
- Knowledge Supporter → Validator
- Evaluator → Evaluator (unchanged)
- Path Provider → Arbiter
- All references updated consistently across all affected files
- Behavioral tests updated to use new names
- Audit chain dispatches correctly with new names

## Non-Goals

- No changes to the DiMo chain dispatch logic itself
- No changes to Evaluator role
- No changes to the pipeline stage order or semantics
- No changes to artifact names (evidence.yaml, reasoning.yaml, verdict.yaml, judgment.yaml)

## Constraints and Scope

**In scope:**
- All files in `.opencode/skills/audit/` that reference DiMo roles (~54 task files + SKILL.md)
- Behavioral test files in `.opencode/tests/behaviors/` that reference DiMo roles (2 files)
- Audit skill's Trigger Dispatch Table and DiMo Role Chain Dispatch section in SKILL.md
- File names containing old role names (e.g., `*-generator.md`, `*-knowledge-supporter.md`, `*-path-provider.md`)

**Out of scope:**
- Any files outside `.opencode/skills/audit/` and `.opencode/tests/behaviors/`
- Changes to dispatch logic, pipeline semantics, or artifact names
- Changes to Evaluator role (name stays the same)

## Affected Files

54 task files in `.opencode/skills/audit/tasks/`, the SKILL.md, and 2 behavioral test files — 56 files total. See `artifacts/affected-files.yaml` for the complete inventory.

## Implementation Approach

Systematic find-and-replace across all affected files:
1. Rename file names: `*-generator.md` → `*-investigator.md`, `*-knowledge-supporter.md` → `*-validator.md`, `*-path-provider.md` → `*-arbiter.md`
2. Replace role name strings in file contents: "Generator" → "Investigator", "Knowledge Supporter" → "Validator", "Path Provider" → "Arbiter", "Judger" → "Arbiter"
3. Update SKILL.md Trigger Dispatch Table and DiMo Role Chain Dispatch section
4. Update behavioral test files
5. Verify no broken references via grep

After this spec is approved, invoke `writing-plans` to create `.issues/1921/plan.md` before implementation begins.

## Anti-Lobotomization

Tests MUST NOT be lobotomized. Removing or weakening a behavioral test assertion to work around a timeout, failure, or infrastructure issue is a CRITICAL VIOLATION. SCs must achieve 100% clean PASS. No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation. See `080-code-standards.md` Test Integrity Mandate.

## Interdependency

| Issue | Classification | Description |
|-------|---------------|-------------|
| None | — | This is a self-contained rename with no dependencies on other issues |

## Documentation Sources

| Source Category | What Was Consulted | Purpose |
|----------------|-------------------|---------|
| Direct source search | `grep -rl "Generator\|Knowledge Supporter\|Path Provider\|Judger" skills/audit/` | Identify all affected task files |
| Direct source search | `grep -rl "Generator\|Knowledge Supporter\|Path Provider\|Judger" tests/behaviors/` | Identify affected behavioral test files |
| Direct source search | `grep "DiMo\|DiMo Role Chain\|Role Chain Dispatch" skills/audit/SKILL.md` | Verify DiMo chain dispatch structure |
| MCP search | `glob(pattern="skills/audit/**/*.md")` | Confirm file count and structure |

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Remediation | Pipeline Step Binding | Artifact Path | Requirement Traceability | Phase Binding | Verification Gate | Integration Mode | Affinity Group | Re-Entry Step | Test File | Phase Mapping |
|----|-----------|---------------|---------------------|-------------|----------------------|--------------|-------------------------|--------------|-----------------|----------------|--------------|-------------|-----------|--------------|
| SC-1 | All 54 task files in `skills/audit/tasks/` have old role names replaced with new names (Generator→Investigator, Knowledge Supporter→Validator, Path Provider→Arbiter, Judger→Arbiter) | `string` | `grep -r "Generator\|Knowledge Supporter\|Path Provider\|Judger" skills/audit/tasks/` returns zero matches | Re-run find-and-replace on missed files | red-green | `.issues/1921/string/` | Root cause: role names in task files | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-2 | SKILL.md Trigger Dispatch Table and DiMo Role Chain Dispatch section use new role names | `string` | `grep "Investigator\|Validator\|Arbiter" skills/audit/SKILL.md` returns matches; `grep "Generator\|Knowledge Supporter\|Path Provider\|Judger" skills/audit/SKILL.md` returns zero matches | Re-run find-and-replace on SKILL.md | red-green | `.issues/1921/string/` | Root cause: role names in dispatch table | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-3 | File names containing old role names are renamed: `*-generator.md` → `*-investigator.md`, `*-knowledge-supporter.md` → `*-validator.md`, `*-path-provider.md` → `*-arbiter.md` | `structural` | `ls skills/audit/tasks/*-generator.md skills/audit/tasks/*-knowledge-supporter.md skills/audit/tasks/*-path-provider.md` returns no such file; `ls skills/audit/tasks/*-investigator.md skills/audit/tasks/*-validator.md skills/audit/tasks/*-arbiter.md` returns files | Rename missed files | red-green | `.issues/1921/structural/` | Root cause: file names encode old role names | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-4 | Behavioral test files in `tests/behaviors/` that reference DiMo roles are updated to use new names | `string` | `grep -r "Generator\|Knowledge Supporter\|Path Provider\|Judger" tests/behaviors/` returns zero matches | Re-run find-and-replace on test files | red-green | `.issues/1921/string/` | Root cause: role names in behavioral tests | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-5 | Audit chain dispatches correctly with new role names — behavioral test verifies agent dispatches Investigator → Validator → Evaluator → Arbiter chain | `behavioral` | `opencode-cli run` with audit dispatch prompt; `assert_stderr_pattern_present 'Skill "audit"'` and `assert_semantic` verifies correct 4-role chain dispatch with new names | Diagnose dispatch failure, fix missed references, re-run | red-green | `.issues/1921/behavioral/` | Root cause: dispatch must work with new names | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-6 | No broken cross-references — all task files that reference other DiMo role task files use new file names in their cross-reference sections | `string` | `grep -r "generator\|knowledge-supporter\|path-provider" skills/audit/tasks/ --include="*.md"` returns zero matches (checking lowercase file name references) | Re-run find-and-replace on cross-reference sections | red-green | `.issues/1921/string/` | Root cause: cross-references use old file names | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-7 | No SC may be weakened, deferred, or reclassified to a lower evidence type to evade implementation | `behavioral` | `opencode-cli run` with implementation prompt; `assert_semantic` verifies agent does not lobotomize tests | Remediate any lobotomization, re-run | red-green | `.issues/1921/behavioral/` | Anti-lobotomization mandate | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |
| SC-8 | Before any implementation, write behavioral enforcement tests that verify the new role names; confirm RED state (test fails before change) | `behavioral` | `opencode-cli run` with pre-change prompt; `assert_semantic` verifies agent dispatches OLD names (RED), then after change dispatches NEW names (GREEN) | Re-create missing behavioral tests | red-green | `.issues/1921/behavioral/` | TDD mandate from `091-incremental-build.md` | Phase 1 | pre-commit | standalone | — | — | — | Phase 1 |

> **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)
