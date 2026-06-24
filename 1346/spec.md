# [SPEC] Plan file format: master ToC + per-phase sub-plans with flat step sequence

## Problem

The current plan format uses a single monolithic `plan.md` file with phases as sections. This forces the orchestrator to hold the entire plan in context (~300+ lines) even when only one phase is being executed. The format also lacks explicit dispatch contract fields (`must_receive`/`must_not_receive`), which means sub-agents receive inconsistent context — sometimes preloaded with orchestrator reasoning, sometimes missing required fields.

Additionally, the current format does not specify per-step commit boundaries or checkpoint tag creation as explicit checkboxes. The orchestrator only follows the checklist — if checkpoint tag creation is not a checkbox in the plan, it does not happen. The implementation-pipeline's dispatch routing table must include checkpoint tag creation as an explicit step so the plan writer generates the checkbox automatically.

Furthermore, the implementation-pipeline dispatch routing table contains implicit steps that are not exposed as checkboxes: post-step checkpoint tag creation, Z3 state updates, and phase-level checkpoint tag creation. All mandatory steps must be explicit entries in the dispatch routing table — if it's not in the table, the plan writer won't generate it, and the orchestrator won't execute it. Implicit steps produce defective work that must be discarded.

## Approach

Replace the single-file plan format with a multi-file format:

1. **Master ToC** (`plan.md`): A ~50-line routing index containing the phase list table, dependency ordering, and exit criteria. The orchestrator holds this in context as routing metadata.

2. **Per-phase sub-plans** (`plan-phase-N.md`): One self-contained file per phase with a flat step sequence. Each sub-plan includes:
   - A YAML header with phase, concern, depends_on, scs, checkpoint_tag
   - A flat sequence of checkboxes numbered sequentially across the entire plan (no restarting per phase)
   - Steps use `dispatch:`, `check:`, `inline:` prefixes
   - Section headers (`#### Pre-RED Common`, `#### Per-Item RED/GREEN Chains`, `#### Post-RED/green`) are human-readable markers only — orchestrator ignores them
   - No SC tables or output descriptions (SCs live in spec only)

3. **Work state file** (`.tmp/work-state-NNN.yaml`): Disk-persistent phase tracking with Z3-verifiable state transitions. Survives session resets.

4. **implementation-pipeline skill update**: Audit the dispatch routing table for implicit steps. Every mandatory step must be an explicit entry. This includes:
   - Post-step checkpoint tag creation (currently inline bash after every step)
   - Z3 state updates (currently inline orchestrator bookkeeping after every step)
   - Phase-level checkpoint tag creation (currently not in the table at all)
   - Any other steps that exist only as inline bash in pipeline-executor.md

5. **writing-plans skill update**: The skill produces the new multi-file format instead of the single-file format.

## Phases

### Phase 1 — Master ToC Format

Define the `plan.md` routing index file.

**SCs:** SC-1, SC-2, SC-3, SC-4

### Phase 2 — Sub-Plan File Format

Define the `plan-phase-N.md` structure with flat step sequence, dispatch/check/inline prefixes, and explicit checkpoint tag creation step.

**SCs:** SC-5, SC-6, SC-7, SC-8, SC-16, SC-17, SC-18, SC-22, SC-23, SC-24

### Phase 3 — Work State File

Define the `.tmp/work-state-NNN.yaml` format with Z3-verifiable contracts.

**SCs:** SC-9, SC-10, SC-11

### Phase 4 — implementation-pipeline Skill Update

Audit the dispatch routing table for implicit steps. Every mandatory step must be an explicit entry. Add checkpoint tag creation, Z3 state updates, and any other missing steps. Update the pipeline state machine (Z3 contract) to include new step transitions.

**SCs:** SC-19, SC-20, SC-21

### Phase 5 — writing-plans Skill Changes

Update the writing-plans skill to produce the new format.

**SCs:** SC-12, SC-13, SC-14, SC-15

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `plan.md` exists as routing index, ≤50 lines, with phase list table and exit criteria | `structural` | File existence + `wc -l` + grep for table columns |
| SC-2 | Phase list table includes `Depends On` column, acyclic dependency graph | `string` | Extract Depends On values, verify acyclic, Phase 1 has no deps |
| SC-3 | Exit criteria per phase are verifiable (not subjective) | `string` | Grep for Exit Criteria column, verify non-empty, verifiable language |
| SC-4 | ToC is orchestrator-loadable without opening sub-plan files | `behavioral` | Agent reads only plan.md to list phases (stderr evidence) |
| SC-5 | `plan-phase-N.md` files have YAML header with phase, concern, depends_on, scs, checkpoint_tag fields | `string` | Verify YAML frontmatter present with all required fields |
| SC-6 | Plan steps use `dispatch:`, `check:`, `inline:` prefixes with correct syntax | `string` | Grep for step prefix patterns, verify no bare checkbox descriptions without prefix |
| SC-7 | Checkboxes numbered sequentially across entire plan (no restarting per phase) | `string` | Extract checkbox numbers, verify monotonic increasing sequence across all phases |
| SC-8 | Sub-plan files are self-contained, no cross-file references | `string` | Grep for cross-file reference patterns, zero matches |
| SC-9 | Work state file format defined with required fields | `structural` | File path pattern match, YAML parse, required fields present |
| SC-10 | Z3-verifiable contract fields for state transitions | `string` | State transition rules documented, Z3 can load contract |
| SC-11 | Session-resilient disk persistence (not memory-only) | `behavioral` | Simulate session boundary, verify orchestrator resumes from work state file |
| SC-12 | writing-plans skill produces master ToC + sub-plans (not monolithic) | `behavioral` | Invoke skill for 3-phase spec, verify plan.md + 3 sub-plan files output |
| SC-13 | Dispatch contract fields included in generated sub-plans | `behavioral` | Invoke skill, verify must_receive/must_not_receive in generated files |
| SC-14 | Work state file contract created by writing-plans | `behavioral` | Invoke skill, verify .tmp/work-state-NNN.yaml created with required fields |
| SC-15 | plan-structure.md and create-and-validate.md updated for new format | `string` | Verify both files reference multi-file format, dispatch contracts, commit boundaries, and checkpoint tag creation step |
| SC-16 | Every step declares `commits: true` | `string` | Grep for `commits: true` on every step. Verify no step lacks this declaration |
| SC-17 | Each sub-plan declares a phase-level `checkpoint_tag` in its header | `string` | Grep for `checkpoint_tag:` in sub-plan header. Verify tag format: `<parent>/checkpoint/<issue>/phase-<N>-<submodule>`. Verify values are placeholders (e.g., `<parent>`, `<issue>`), not resolved values |
| SC-18 | Each sub-plan has an explicit checkbox step in Post-RED/green that creates the checkpoint tag | `string` | Grep for a checkbox in the Post-RED/green section containing `checkpoint_tag` creation. Verify the step references the tag format from the sub-plan header |
| SC-19 | implementation-pipeline dispatch routing table includes checkpoint tag creation as an explicit step | `string` | Grep the dispatch routing table for a step entry with label `checkpoint-tag-create` or equivalent. Verify it appears between the last TDD item step and the Post-RED/green gates |
| SC-20 | Pipeline state machine (Z3 contract) includes the new checkpoint-tag-create step with valid transitions | `string` | Verify the Z3 state machine YAML includes the new step. Verify transitions: from last TDD step → checkpoint-tag-create, from checkpoint-tag-create → next gate step |
| SC-21 | All mandatory steps are explicit entries in the dispatch routing table — no implicit steps | `behavioral` | Audit the dispatch routing table in `pipeline-executor.md`. For every operation the pipeline performs (including post-step checkpoint tag creation, Z3 state updates, phase-level tag creation, and any inline bash procedures), verify it has a corresponding entry in the dispatch routing table. If any mandatory step exists only as inline bash in pipeline-executor.md without a dispatch table entry, it is a violation. The dispatch table is the single source of truth for what the plan writer generates. Implicit steps produce defective work that must be discarded |
| SC-22 | Plan steps use `dispatch:`, `check:`, `inline:` prefixes — no other step prefix formats are used | `string` | Grep for step prefixes, verify only `dispatch:`, `check:`, `inline:` appear |
| SC-23 | Plan has single flat enumeration across all phases (no restarting per phase) | `string` | Extract checkbox numbers from all sub-plans, verify monotonic increasing sequence with no resets |
| SC-24 | Plan contains no SC tables or output descriptions (SCs in spec only) | `string` | Grep for table patterns and output description patterns, zero matches in sub-plan files |

## Step Type Format

Each step in the sub-plan body uses one of three prefixes:

```
- [ ] N. dispatch: <skill> <task> { <context_fields> }
- [ ] N. check: solve check --state-path <path> --contract-path <path>
- [ ] N. inline: <command>
- [ ] N. dispatch: adversarial-audit <task> { <context_fields>, auditor: <N> }
```

Where:
- `dispatch:` — orchestrator calls `task()` with the specified skill and task, passing the listed context fields
- `check:` — orchestrator runs Z3 verification against the work state file
- `inline:` — orchestrator executes the command directly (bash, git, etc.)
- `dispatch: adversarial-audit` — auditor dispatch with specific model selection

Context fields are field names (e.g., `sc_ids`, `affected_files`, `spec_body`), not concrete values. The `must_receive`/`must_not_receive` contract is not in the plan — sub-agents discover required context from the spec independently.

## Sub-Plan Header Format

Each `plan-phase-N.md` begins with a YAML header block:

```yaml
---
phase: <N>
concern: <description>
depends_on: [<phase-N>, ...]
scs: [SC-<N>, ...]
checkpoint_tag: /checkpoint/<issue>/phase-<N>-<submodule>
---
```

The body is a flat sequence of checkboxes numbered sequentially across the entire plan (no restarting per phase). Section headers (`#### Pre-RED Common`, `#### Per-Item RED/GREEN Chains`, `#### Post-RED/green`) are human-readable markers only — the orchestrator ignores them and follows the flat enumeration.

## Post-RED/green Section — Checkpoint Tag Creation Step

The Post-RED/green section of each sub-plan MUST include an explicit checkbox for creating the checkpoint tag:

```
- [ ] N. inline: git tag <parent>/checkpoint/<issue>/phase-<N>-<submodule>
    → commits: false
```

This step runs after all TDD items in the phase complete and before the next phase begins. The orchestrator resolves the placeholder values (`<parent>`, `<issue>`, `<N>`, `<submodule>`) at execution time using the tag format from the sub-plan header.

Tag convention per `000-critical-rules.md` §Checkpoint Rollback Exception: `<parent>/checkpoint/<issue>/phase-<N>-<submodule>`.

## Out of Scope

- Orchestrator execution model (how the orchestrator consumes the new format) — except that the format must support sequential single-step execution with per-step commits and explicit checkpoint tag creation steps
- Migration from old single-file plans to the new format
- Additional tooling beyond Z3 verification

## Constraints

- Steps use `dispatch:`, `check:`, `inline:` prefixes — no other prefix formats
- Single flat enumeration across entire plan (no restarting per phase)
- No SC tables in plan — SCs live in spec only
- Plan describes steps, not outputs
- Markdown checkbox format preserved (`- [ ] N. ...`)
- Master ToC ≤ 50 lines (orchestrator context discipline)
- Pre-RED/Post-RED sections duplicated per sub-plan (no shared/abstracted sections)
- Every step must declare `commits: true` — this is not optional
- Checkpoint tag creation must be an explicit checkbox in Post-RED/green — the orchestrator only follows the checklist
- The implementation-pipeline dispatch routing table must include all mandatory steps as explicit entries — no implicit steps. Implicit steps produce defective work that must be discarded
- Steps must never be combined — each checkbox is exactly one step, one commit

## Dependencies

- `writing-plans` skill is the sole producer of the new format
- `implementation-pipeline` skill dispatch routing table must include all mandatory steps as explicit entries
- `plan-structure.md` and `create-and-validate.md` task files define the canonical format
- Z3 solve tool for work state file verification
- Checkpoint tag convention from `000-critical-rules.md` §Checkpoint Rollback Exception

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
