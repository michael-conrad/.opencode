# Task: write

## Purpose

Write the plan document to `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`, validate dispatch table references, apply approval cascade, and sync cross-references.

## Entry Criteria

- Solve step completed with SAT and SOLVED status
- Phase structure and TDD definitions available

## Exit Criteria

- Plan document written to `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md`
- Dispatch table validation passed
- Approval cascade applied
- Cross-reference synced to spec issue
- Output contract loaded from `contracts/write-output-template.yaml` and validated — all compliance fields populated

## Procedure

- [ ] 1. (**sub-agent**) Write plan document header — Goal, Architecture, Tech Stack
  - Command: write plan header to `.issues/{N}/plan.md`
  - SC: All
  - Expected: header with issue ref, goal, architecture, files list

- [ ] 2. (**sub-agent**) Write each phase section — Pre-RED Common, Per-Item RED+green Chains, Post-RED/green
  - Command: write phase sections per Plan Format Requirements
  - SC: All
  - Expected: each phase has Concern, Files, SCs, Dependencies, Entry/Exit conditions

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

- [ ] 6. (**inline**) Return PASS with plan file path — load output contract from `contracts/write-output-template.yaml`, validate compliance fields, and return
  - Command: validate against `contracts/write-output-template.yaml`
  - SC: SC-16, SC-18
  - Expected: all compliance fields populated, PASS returned

## Plan Format Requirements

Every plan document MUST follow this structure. Plans that deviate from this format are invalid and MUST be rejected.

### Required Sections (in order)

1. **Title** — `# Implementation Plan — [<issue-ref>](<issue-url>) — <short-description>`
2. **Goal/Architecture/Files** — Bullet list with `**Goal:**`, `**Architecture:**`, `**Files:**` entries
3. **Admonishment** — Verbatim compliance requirement blockquote:
   ```
   > **Compliance Requirement:** All steps and sub-steps in this document MUST be followed in order. Failure to comply with any step — including but not limited to verification gates, test phases, audit checkpoints, and review steps — will result in the feature branch being rejected and discarded, requiring a full rework from scratch and loss of all prior work. There is no valid reason to skip, compress, reorder, or omit any step. If a step appears redundant or unnecessary, follow it anyway — the cost of following an extra step is negligible compared to the cost of rework from a skipped step.
   ```
4. **One-step-at-a-time protocol admonishment** — Verbatim blockquote:
   ```
    > **One-step-at-a-time protocol:** Each numbered step is a single unit of work. The orchestrator completes step N, reports completion to chat, then proceeds to step N+1. Steps MUST NOT be combined, batched, or executed in parallel.
   ```
5. **Phase sections** — One `## Phase N — <name>` per phase, each with:
   - Phase metadata (Concern, Files, SCs, Dependencies, Entry/Exit conditions)
   - Checkbox steps (`- [ ] N.`) with dispatch indicators
   - Sub-steps indented under parent steps
   - RED+green item chains with interleaved ordering, including ALL mandatory implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` §Dispatch Routing Table (sc-coherence-gate, pre-red-baseline, red-phase, z3-check-red, red-doublecheck, z3-check-red-doublecheck, post-red-enforcement, z3-check-post-red, green-phase, z3-check-green, post-green-enforcement, z3-check-post-green, checkpoint-tag-create, checkpoint-commit, structural-checks, green-doublecheck, green-vbc, adversarial-audit, cross-validate, regression-check, review-prep, exec-summary)
   - SC annotations on each step
   - Phase completion block
   - Concern transition to next phase
6. **Bottom admonishment** — Verbatim compliance requirement blockquote
7. **Self-remediation protocol admonishment** — Verbatim blockquote:
   ```
   > **One step at a time protocol:** Each numbered step is a single unit of work. The orchestrator completes exactly one step, reports the result, and proceeds to the next step without asking for permission. "Combining steps" means performing work that spans multiple plan step numbers in a single operation — regardless of how many tool calls, dispatches, or response turns it takes. The self-check is: "does the work I just completed correspond to exactly one plan step number?" If the work touches files or concerns from step N and step N+1, it is combined. The RED→GREEN transition is a zero-tolerance gate: the RED test MUST be verified as FAILING (by reading its artifact output) before any GREEN implementation begins. Skipping this verification invalidates the entire phase and all work in it.
   >
   > **Self-remediation protocol:** If the orchestrator combines steps or skips a gate, it MUST self-remediate by reverting only the work belonging to the incorrectly-combined step and re-dispatching from the failed step. Do NOT revert work from correctly-executed prior steps. No halting, no asking for permission, no "should I?" — the answer is always revert the offending step and re-dispatch.
   ```
8. **Exit Criteria** — Numbered checklist `C1` through `C{N}`
9. **Global sequential numbering** — Steps are numbered sequentially across the entire plan file. Each phase does NOT restart at 1. The first step of Phase 2 continues from the last step of Phase 1.

### Three-Tier Plan Structure

Every plan document MUST use a three-tier structure:

| Tier | Level | Format | Purpose |
|------|-------|--------|---------|
| 1 — Global | Plan-wide | `- [ ] N.` (sequential across all phases) | Pre-RED common steps, global post-steps |
| 2 — Per-Phase | Phase sections | `## Phase N — <name>` | Phase metadata + per-file RED+green chains |
| 3 — Per-Item | Item chains | `- [ ] N.M.` (sub-steps) | RED → GREEN → doublecheck → commit per item |

**Tier 1 (Global):** Steps numbered sequentially across the entire plan. Includes global pre-steps (coherence gate, pre-red-baseline) and global post-steps (collect behavioral evidence from `./tmp/behavioral-evidence-*/` into `./tmp/{issue-N}/artifacts/`, adversarial audit, cross-validate, regression check, review-prep, exec-summary).

**Tier 2 (Per-Phase):** Each phase section contains phase metadata and per-file RED+green item chains. Phase steps continue the global sequence number.

**Tier 3 (Per-Item):** Each implementation item within a phase follows RED → GREEN → GREEN doublecheck → Checkpoint commit. Sub-steps are indented under the parent step.

### Dispatch Indicators

Every step MUST use one of three dispatch indicators:

| Indicator | Meaning | Example |
|-----------|---------|---------|
| `(**sub-agent**)` | Orchestrator dispatches a clean-room sub-agent via `task()` | `- [ ] 3. **RED (**sub-agent**).**` |
| `(**clean-room**)` | Orchestrator dispatches a clean-room sub-agent (same as sub-agent) | `- [ ] 1. **Coherence gate (**clean-room**).**` |
| `(**inline**)` | Orchestrator executes directly (no sub-agent) | `- [ ] 6. **Checkpoint commit (**inline**).**` |

### Prohibited Patterns

- **No dispatch tables** — do not include implementation-pipeline dispatch tables in plan files. The plan defines WHAT to do; the orchestrator determines HOW to dispatch.
- **No TBD/TODO** — all file paths, function names, and commands must be exact.
- **No shared cross-references** — each phase is self-contained. Do not reference steps from other phases.
- **No zero-indexed numbering** — phases start at 1, steps start at 1.
- **No line number references** — use stable anchors (function names, section headers).
- **No multi-dispatch steps** — every step dispatches exactly one sub-agent or executes inline. A step MUST NOT bundle multiple dispatches (e.g., "resolve-models → dispatch auditor_1 → remediate → dispatch auditor_2"). Each dispatch is a separate numbered step with its own dispatch indicator.
- **No non-standard dispatch indicators** — only `(**sub-agent**)`, `(**clean-room**)`, and `(**inline**)` are valid. `(**orchestrator**)`, `(**orchestrator**)`, or any other indicator is prohibited.
- **No omitted mandatory gates** — All implementation-pipeline gate steps from `implementation-pipeline/SKILL.md` dispatch routing table are mandatory. No step may be omitted because the plan writer judges it "not needed." If a step appears unnecessary, include it anyway — the cost of an extra step is negligible compared to the cost of rework from a skipped step.

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
14. Dispatch indicators match step content — `(**inline**)` steps must not contain sub-agent dispatch language; `(**sub-agent**)` steps must dispatch a sub-agent via `task()`

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
