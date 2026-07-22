# Task: write

## Purpose

Write the plan document in split format: `{N}/plan.md` (index) + `{N}/plan-{NN}-{slug}.md` (one per phase), validate dispatch table references, apply approval cascade, and sync cross-references.

## Entry Criteria

- Solve step completed with SAT and SOLVED status
- Phase structure and TDD definitions available

## Exit Criteria

- Plan index written to `{N}/plan.md` with phase table
- Phase files written to `{N}/plan-{NN}-{slug}.md` (one per phase)
- Dispatch table validation passed
- Approval cascade applied
- Cross-reference synced to spec issue
- Output contract loaded from `contracts/write-output-template.yaml` and validated — all compliance fields populated

## Procedure

- [ ] 1. (**sub-agent**) Write plan index — Goal, Architecture, Phase table, admonishments
  - Command: write plan index to `{N}/plan.md`
  - SC: All
  - Expected: index with issue ref, goal, architecture, files list, phase table, exit criteria, all admonishments

- [ ] 2. (**sub-agent**) Write each phase file — one `{N}/plan-{NN}-{slug}.md` per phase
  - Command: write phase files per Plan Format Requirements
  - SC: All
  - Expected: each phase file has Concern, Files, SCs, Dependencies, Entry/Exit conditions, full step-by-step with globally sequential numbering

- [ ] 3. (**sub-agent**) Validate dispatch markers — every dispatch marker skill name exists under `.opencode/skills/`
  - Command: `ls .opencode/skills/<skill-name>/SKILL.md` for each dispatch marker
  - SC: SC-5
  - Expected: all referenced skills exist

- [ ] 4. (**sub-agent**) Apply approval cascade — per authorization_scope
  - Command: apply approval cascade matrix from spec
  - SC: All
  - Expected: approval cascade applied correctly

- [ ] 5. (**sub-agent**) Sync cross-reference — to spec issue body
  - Command: update spec issue with plan reference
  - SC: All
  - Expected: spec issue body updated

- [ ] 6.  Return PASS with plan file path — load output contract from `contracts/write-output-template.yaml`, validate compliance fields, and return
  - Command: validate against `contracts/write-output-template.yaml`
  - SC: SC-16, SC-18
  - Expected: all compliance fields populated, PASS returned

## Plan Format Requirements

Every plan document MUST follow this structure. Plans that deviate from this format are invalid and MUST be rejected.

### Split File Convention

Plans use a split file format:

- **`{N}/plan.md`** — Index file (required for multi-phase plans, optional for single-phase)
  - Title, Goal, Architecture, Files list
  - Phase table: each phase with name, concern, SCs, dependencies, step range
  - Exit criteria (C1-C{N})
  - All admonishments (compliance, one-step-at-a-time, step status, self-remediation)
  - Self-review evidence section

- **`{N}/plan-{NN}.md`** — Phase files (one per phase)
  - `{NN}` is zero-padded phase number (01, 02, ...)
  - Phase metadata (Concern, Files, SCs, Dependencies, Entry/Exit conditions)
  - Full step-by-step with globally sequential numbering
  - Dispatch indicators, RED/GREEN chains, Z3 checks, VbC blocks
  - Phase completion block
  - Concern transition to next phase

**Single-phase plans** may use `{N}/plan.md` as the sole file (no split needed).

### Required Sections in plan.md (Index)

1. **Title** — `# Implementation Plan — [<issue-ref>](<issue-url>) — <short-description>`
2. **Goal/Architecture/Files/Dispatch** — Bullet list with `**Goal:**`, `**Architecture:**`, `**Files:**`, `**Dispatch:**` entries
3. **Blast Radius** — Section listing affected files and impact zones from blast radius artifact
4. **Concern Map Reference** — Section listing concerns and their phase mappings from concern map artifact
5. **Admonishment** — Verbatim compliance requirement blockquote
6. **One-step-at-a-time protocol admonishment** — Verbatim blockquote
7. **Step Status instruction** — Verbatim blockquote
8. **Phase table** — Table with phase number, name, concern, SCs, dependencies, step range, dispatch
9. **Bottom admonishment** — Verbatim compliance requirement blockquote
10. **Self-remediation protocol admonishment** — Verbatim blockquote
11. **Exit Criteria** — Numbered checklist `C1` through `C{N}`

### Required Sections in plan-{NN}-{slug}.md (Phase File)

1. **Title** — `# Phase {NN} — {name}`
2. **Phase metadata** — Concern, Files, SCs, Dependencies, Entry/Exit conditions
3. **Code Path Coverage** — Per-phase list of code paths covered by this phase (from code path inventory artifact)
4. **Cross-Cutting SCs** — Cross-cutting SCs that apply to this phase (from cross-cutting matrix artifact)
5. **Interface Boundaries** — Interface boundaries relevant to this phase (from interface compatibility artifact)
6. **State Transitions** — State transitions handled by this phase (from state analysis artifact)
7. **Step-by-step** — Checkbox steps (`- [ ] N.`) with dispatch indicators
8. **Phase completion block** — VbC verification assertions
9. **Concern transition** — To next phase

### Global Sequential Numbering

Steps are numbered sequentially across all phase files. Each phase does NOT restart at 1. The first step of Phase 2 continues from the last step of Phase 1. This ensures no ambiguity about what follows what.

### Three-Tier Plan Structure

Every plan document MUST use a three-tier structure:

| Tier | Level | Format | Purpose |
|------|-------|--------|---------|
| 1 — Global | Plan-wide | `- [ ] N.` (sequential across all phases) | Pre-RED common steps, global post-steps |
| 2 — Per-Phase | Phase sections | `## Phase N — <name>` | Phase metadata + per-file RED+green chains |
| 3 — Per-Item | Item chains | `- [ ] N.M.` (sub-steps) | RED → GREEN → doublecheck → commit per item |

**Tier 1 (Global):** Steps numbered sequentially across the entire plan. Includes global pre-steps (coherence gate, pre-red-baseline) and global post-steps (collect behavioral evidence from `{project_root}/tmp/behavioral-evidence-*/` into `{project_root}/tmp/{issue-N}/artifacts/`, audit, cross-validate, regression check, review-prep, exec-summary).

**Tier 2 (Per-Phase):** Each phase section contains phase metadata and per-file RED+green item chains. Phase steps continue the global sequence number.

**Tier 3 (Per-Item):** Each implementation item within a phase follows RED → GREEN → GREEN doublecheck → Checkpoint commit. Sub-steps are indented under the parent step.

### Dispatch Indicators

Every step MUST use one of three dispatch indicators:

| Indicator | Meaning | Context | Example |
|-----------|---------|---------|---------|
| `` | Orchestrator executes directly (no sub-agent) | Orchestrator executes directly | `- [ ] 6. **Checkpoint commit .**` |
| `(**sub-agent**)` | Dispatch via `task()` with phase file + orchestrator-provided context | Phase file + orchestrator-provided context | `- [ ] 3. **RED (**sub-agent**).**` |
| `(**clean-room**)` | Dispatch via `task()` with phase file only (routing metadata) | Phase file only (routing metadata) | `- [ ] 1. **Coherence gate (**clean-room**).**` |

### Prohibited Patterns

- **No dispatch tables** — do not include implementation-pipeline dispatch tables in plan files. The plan defines WHAT to do; the orchestrator determines HOW to dispatch.
- **No TBD/TODO** — all file paths, function names, and commands must be exact.
- **No shared cross-references** — each phase is self-contained. Do not reference steps from other phases.
- **No zero-indexed numbering** — phases start at 1, steps start at 1.
- **No line number references** — use stable anchors (function names, section headers).
- **No multi-dispatch steps** — every step dispatches exactly one sub-agent or executes inline. A step MUST NOT bundle multiple dispatches (e.g., "resolve-models → dispatch auditor_1 → remediate → dispatch auditor_2"). Each dispatch is a separate numbered step with its own dispatch indicator.
- **No non-standard dispatch indicators** — only `(**sub-agent**)`, `(**clean-room**)`, and `` are valid. `(**orchestrator**)`, `(**orchestrator**)`, or any other indicator is prohibited.
- **No omitted mandatory gates** — All implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` dispatch routing table are mandatory. No step may be omitted because the plan writer judges it "not needed." If a step appears unnecessary, include it anyway — skipping a step produces defective deliverables that must be discarded, requiring full rework.

### Validation Rules

1. Title matches issue number and description
2. Goal/Architecture/Files present and non-empty
3. Admonishment present verbatim at top and bottom
4. At least one phase section
5. Each phase has Concern, Files, SCs, Dependencies metadata
6. Each phase has checkbox steps (`- [ ] N.`)
7. Each step has a dispatch indicator
8. RED+green items have interleaved ordering (RED → GREEN → doublecheck → commit)
9. SC annotations reference valid SC IDs from the spec
10. Phase completion block present after last step
11. Concern transition present between phases
12. Exit criteria present and numbered C1-C{N}
13. One-step-at-a-time protocol admonishment present verbatim after the compliance admonishment
14. Dispatch indicators match step content — `` steps must not contain sub-agent dispatch language; `(**sub-agent**)` steps must dispatch a sub-agent via `task()`
15. Step Status instruction present verbatim as section 5 between one-step-at-a-time protocol admonishment and phase sections

### RED+green Item Chain Specification

Refer to `implementation-pipeline/SKILL.md` §Dispatch Routing Table for the canonical gate sequence. The plan references gate labels by name only — the dispatch routing table defines the chain.

### Phase Completion Block

After the last step of each phase, include a completion block:
```
#### Phase N VbC

- [ ] {N}. **VbC (**clean-room**).** <verification assertions> **→ SC-{ids}**
```

### Concern Transition

Between phases, include a concern transition line:
```
**Concern transition:** Leaving <prior concern> → entering <new concern>. Phase N+1 depends on Phase N <deliverable>.
```

### Exit Criteria

Numbered checklist C1 through C{N} at the end of the plan, after the bottom admonishment.

## Context Required

- Related tasks: `create` (21-step pipeline)
- Related skills: `issue-operations`
