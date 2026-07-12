# Implementation Plan — [#1903](https://github.com/michael-conrad/.opencode/issues/1903) — spec-creation analytical artifacts: generate required artifacts before plan creation

**Issue:** #1903
**Spec path:** `.opencode/.issues/1903/spec.md`
**Target files:**
- `.opencode/skills/spec-creation/tasks/analytical-artifacts.md` (new)
- `.opencode/skills/spec-creation/tasks/create.md` (edit)
- `.opencode/skills/writing-plans/tasks/create.md` (edit)
- `.opencode/skills/writing-plans/SKILL.md` (edit)
- `.opencode/skills/spec-creation/SKILL.md` (edit)
- `.opencode/guidelines/010-approval-gate.md` (edit)
**Authorization scope:** `for_pr`
**Halt at:** `pr_created`
**Plan type:** Multi-phase (3 phases, split format)

## Goal

Add analytical artifact generation as a pipeline step between spec approval and plan creation. The spec-creation pipeline gains a post-spec step that produces the 7 artifacts (blast-radius, concern-map, code-path-inventory, cross-cutting-matrix, interface-compatibility, state-analysis, testability-assessment). The writing-plans pipeline gains artifact validation at entry criteria and auto-generation fallback on missing artifacts.

## Architecture

The 7 analytical artifacts are YAML files stored at `{project_root}/{path}/.issues/{N}/artifacts/{name}.yaml` (where `{path}` is the repo prefix from session-init). Each artifact is generated from the approved spec body by a clean-room sub-agent tasked through the spec-creation pipeline. Writing-plans entry criteria check for existence and non-empty content before plan creation begins, producing BLOCKED with `MISSING_SPEC_ARTIFACT` when absent. A retroactive mode supports backfilling artifacts for existing specs.

**Artifact directory:** `{project_root}/{path}/.issues/{N}/artifacts/`
**Artifact files:**

| File | Content |
|------|---------|
| `artifacts/blast-radius.yaml` | Affected components and ripple effects per phase |
| `artifacts/concern-map.yaml` | Concern boundaries and separation per phase |
| `artifacts/code-path-inventory.yaml` | Code paths touched by each phase |
| `artifacts/cross-cutting-matrix.yaml` | Cross-cutting concerns matrix |
| `artifacts/interface-compatibility.yaml` | Interface compatibility analysis |
| `artifacts/state-analysis.yaml` | State machine transitions per phase |
| `artifacts/testability-assessment.yaml` | Test strategy per phase |

## Files Affected

| File | Change Type | Risk |
|------|-------------|------|
| `.opencode/skills/spec-creation/tasks/analytical-artifacts.md` | Create (new) | Low — new file |
| `.opencode/skills/spec-creation/tasks/create.md` | Edit — add artifact generation step | Medium — pipeline order change |
| `.opencode/skills/spec-creation/SKILL.md` | Edit — add task reference | Low — metadata |
| `.opencode/skills/writing-plans/tasks/create.md` | Edit — entry criteria, auto-gen fallback | Medium — validation logic |
| `.opencode/skills/writing-plans/SKILL.md` | Edit — entry criteria update | Low — metadata |
| `.opencode/guidelines/010-approval-gate.md` | Edit — update analytical artifacts ref | Low — docs |

## Blast Radius

- **spec-creation pipeline**: Post-spec step added for artifact generation. Existing steps renumbered.
- **writing-plans pipeline**: Entry criteria gain validation gate. Auto-generation fallback changes error-to-recovery flow.
- **Guidelines**: 010-approval-gate.md critical-rules-010 references analytical artifacts — wording updated to reflect new pipeline step.
- **Approval gate**: No change to authorization model — artifacts are pipeline metadata, not approval gates.

## Concern Map Reference

| Concern | Phase | Files |
|---------|-------|-------|
| Analytical artifact generation task | 1 | `spec-creation/tasks/analytical-artifacts.md` |
| spec-creation pipeline wiring | 1 | `spec-creation/tasks/create.md`, `spec-creation/SKILL.md` |
| writing-plans artifact validation | 2 | `writing-plans/tasks/create.md`, `writing-plans/SKILL.md` |
| Pipeline guidance documentation | 2 | `010-approval-gate.md` |
| Retroactive artifact generation | 3 | `spec-creation/tasks/analytical-artifacts.md` |

> **Compliance requirement — ALL steps are MANDATORY. Do NOT skip, reorder, or combine.**
>
> Every step has chain dependencies. Execute in sequence. No parallel dispatch of chain-dependent steps.
>
> **One-step-at-a-time protocol:** Execute exactly one step, then pause for verification before proceeding to the next. Do NOT batch steps. Do NOT combine edits. Do NOT assume the outcome of a step before it completes.
>
> **Step Status:** Every time you complete a step, you MUST update the step's status to reflect completion.

## Success Criteria Mapping

| SC ID | Criterion | Phase | Step(s) |
|-------|-----------|-------|---------|
| SC-1 | Analytical artifacts exist in `.issues/{N}/` | 1 | 4–9 |
| SC-2 | writing-plans entry criteria BLOCK with `MISSING_SPEC_ARTIFACT` | 2 | 10–13 |
| SC-3 | Artifacts contain non-empty, spec-specific content | 1 | 4–9 |
| SC-4 | Pipeline guidance documents which step generates/consumes each artifact | 2 | 14–15 |
| SC-5 | Retroactive generation for existing specs | 3 | 16–18 |

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Step Range | Dispatch |
|-------|------|---------|-----|--------------|------------|----------|
| 1 | Create analytical-artifacts task and wire into spec-creation | Analytical artifact generation task | SC-1, SC-3 | None | 1–9 | `spec-creation` |
| 2 | Update writing-plans to validate and consume artifacts | writing-plans artifact validation | SC-2, SC-4 | Phase 1 | 10–15 | `writing-plans` |
| 3 | Add retroactive artifact generation | Retroactive backfill | SC-5 | Phase 1 | 16–18 | `spec-creation` |

## Phase 1 — Create analytical-artifacts task and wire into spec-creation

### Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | Analytical artifact generation task |
| **Files** | `.opencode/skills/spec-creation/tasks/analytical-artifacts.md`, `.opencode/skills/spec-creation/tasks/create.md`, `.opencode/skills/spec-creation/SKILL.md` |
| **SCs** | SC-1, SC-3 |
| **Dependencies** | None |
| **Entry** | Approved spec exists for #1903 |
| **Exit** | New analytical-artifacts task exists and is wired into spec-creation pipeline |

### Code Path Coverage

- `spec-creation/tasks/analytical-artifacts.md` — new file, full content generated
- `spec-creation/tasks/create.md` — add artifact generation step after spec body write
- `spec-creation/SKILL.md` — add task reference to trigger dispatch table

### Cross-Cutting SCs

None applicable (Phase 1 is pure creation)

### Interface Boundaries

- `spec-creation/tasks/analytical-artifacts.md` consumes: spec body (from spec-creation pipeline)
- `spec-creation/tasks/analytical-artifacts.md` produces: 7 YAML artifact files
- `spec-creation/tasks/create.md` Step 11 becomes the artifact generation dispatching step

### State Transitions

| Before | After |
|--------|-------|
| spec-creation pipeline: spec body written, pipeline ends | spec-creation pipeline: spec body written → analytical artifacts generated → pipeline continues to completion |
| writing-plans entry: no artifacts to check | writing-plans entry: artifacts checked in Step 4a |

### Steps

- [ ] 1. (**inline**) Verify spec is approved — check `approved-for-*` label on #1903. Chain: `none`
- [ ] 2. (**sub-agent**) Research spec body and existing pipeline structure — read `spec-creation/tasks/create.md` and `writing-plans/tasks/create.md` to understand current step numbering and insertion points. Read spec body from `.opencode/.issues/1903/spec.md`. **→ SC-1, SC-3**
- [ ] 3. (**inline**) Z3 check — verify research output contains `evidence_artifacts`. Chain: `step_2`
- [ ] 4. (**sub-agent**) Create `spec-creation/tasks/analytical-artifacts.md` — write a new task file with:
  - Purpose: Generate 7 analytical artifacts from a completed spec body
  - Entry criteria: completed spec body at `.issues/{N}/spec.md`
  - Procedure: 7 sub-steps, one per artifact, each dispatching a clean-room sub-agent that reads the spec body and produces a YAML artifact
  - Artifact output path: `{project_root}/{path}/.issues/{N}/artifacts/{name}.yaml`
  - Each sub-step includes: artifact schema, evidence type, example output structure
  - Exit criteria: all 7 artifact files exist and are non-empty YAML
  - Cross-reference: consumed by `writing-plans/tasks/create.md` Step 4a
  - **→ SC-1, SC-3**
  Chain: `step_3`
- [ ] 5. (**inline**) Verify file exists — `ls .opencode/skills/spec-creation/tasks/analytical-artifacts.md`. Chain: `step_4`
- [ ] 6. (**inline**) Z3 check — verify new task file conforms to expected contract. Chain: `step_5`
- [ ] 7. (**sub-agent**) Edit `spec-creation/tasks/create.md` — add artifact generation step. After the spec body write step (currently Step 10), insert a new step 11: "Generate analytical artifacts (sub-agent)". Renumber subsequent steps. Add Step 11 as a sub-agent dispatch to `analytical-artifacts` task with spec body as context. Add entry criteria note referencing analytical artifacts. **→ SC-1**
  Chain: `step_6`
- [ ] 8. (**sub-agent**) Edit `spec-creation/SKILL.md` — add `analytical-artifacts` to the trigger dispatch table. Add entry criteria noting that analytical artifacts are generated post-spec. **→ SC-1**
  Chain: `step_7`
- [ ] 9. (**sub-agent**) Verify Phase 1 — run `spec-creation/tasks/analytical-artifacts.md` on the #1903 spec body to confirm 7 artifact files are generated with non-empty content. **→ SC-3**
  Chain: `step_8`

#### Phase 1 VbC

- [ ] 9v. (**clean-room**) VbC — verify all Phase 1 SCs (SC-1, SC-3) PASS with evidence. **→ SC-1, SC-3**

**Concern transition:** Leaving analytical artifact generation task creation → entering writing-plans validation update. Phase 2 depends on Phase 1's `analytical-artifacts.md` task file existing.

## Phase 2 — Update writing-plans to validate and consume artifacts

### Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | writing-plans artifact validation |
| **Files** | `.opencode/skills/writing-plans/tasks/create.md`, `.opencode/skills/writing-plans/SKILL.md`, `.opencode/guidelines/010-approval-gate.md` |
| **SCs** | SC-2, SC-4 |
| **Dependencies** | Phase 1 (analytical-artifacts.md exists) |
| **Entry** | `spec-creation/tasks/analytical-artifacts.md` exists |
| **Exit** | writing-plans entry criteria validates artifacts; pipeline guidance documented |

### Code Path Coverage

- `writing-plans/tasks/create.md` — update entry criteria, add artifact validation step (Step 4a), add auto-generation fallback
- `writing-plans/SKILL.md` — update entry criteria in SKILL.md
- `010-approval-gate.md` — update critical-rules-010 reference to analytical artifacts

### Cross-Cutting SCs

- SC-4: Pipeline guidance must document which step generates and consumes each artifact

### Interface Boundaries

- `writing-plans/tasks/create.md` entry criteria: consume analytical artifacts from `{path}/.issues/{N}/artifacts/`
- `writing-plans/tasks/create.md` Step 4a: validate artifact existence before structure step

### State Transitions

| Before | After |
|--------|-------|
| writing-plans entry: no artifact validation | writing-plans entry: artifact validation gate in Step 4a |
| Missing artifacts: pipeline continues anyway | Missing artifacts: BLOCKED with `MISSING_SPEC_ARTIFACT` |
| No pipeline guidance for artifacts | Pipeline guidance documents generator → consumer chain |

### Steps

- [ ] 10. (**sub-agent**) Edit `writing-plans/tasks/create.md` — update entry criteria section:
  - Add explicit check: "All 7 analytical artifacts exist in `{path}/.issues/{N}/artifacts/`"
  - Add BLOCKED return with `MISSING_SPEC_ARTIFACT` when any artifact is missing
  - Add Step 4a (artifact validation) as a sub-agent task between readiness (Step 4) and Z3 check (Step 5)
  - Step 4a validates artifact existence, non-empty content, and well-formed YAML
  - Add auto-generation fallback: when artifacts are missing, before BLOCKING, attempt auto-generation by dispatching `spec-creation/tasks/analytical-artifacts.md`
  - **→ SC-2**
  Chain: `step_9`
- [ ] 11. (**inline**) Z3 check — verify edit output conforms to expected contract. Chain: `step_10`
- [ ] 12. (**sub-agent**) Edit `writing-plans/SKILL.md` — update entry criteria section to reference "All 7 analytical artifacts exist in `.issues/{N}/`" and the `MISSING_SPEC_ARTIFACT` BLOCKED status. Add note about auto-generation fallback. **→ SC-2**
  Chain: `step_11`
- [ ] 13. (**sub-agent**) Audit entry criteria — verify writing-plans entry criteria produces `BLOCKED` with `MISSING_SPEC_ARTIFACT` when artifacts are absent. **→ SC-2**
  Chain: `step_12`
- [ ] 14. (**sub-agent**) Edit `010-approval-gate.md` — update critical-rules-010 "Professional engineers verify all 7 analytical artifacts exist before plan creation" to reference the new pipeline step and artifact location (`{path}/.issues/{N}/artifacts/`). **→ SC-4**
  Chain: `step_13`
- [ ] 15. (**sub-agent**) Add pipeline guidance — document in `writing-plans/tasks/create.md` and `spec-creation/tasks/analytical-artifacts.md` the generator→consumer chain for each artifact:
  - Generator: `spec-creation/tasks/analytical-artifacts.md` (Phase 1 of spec-creation)
  - Consumer: `writing-plans/tasks/create.md` Step 4a
  - Link each artifact file to its consuming step in writing-plans
  - **→ SC-4**
  Chain: `step_14`

#### Phase 2 VbC

- [ ] 15v. (**clean-room**) VbC — verify Phase 2 SCs (SC-2, SC-4) PASS. **→ SC-2, SC-4**

**Concern transition:** Leaving writing-plans validation update → entering retroactive artifact generation. Phase 3 depends on Phase 1's `analytical-artifacts.md` task file existing.

## Phase 3 — Add retroactive artifact generation

### Phase Metadata

| Field | Value |
|-------|-------|
| **Concern** | Retroactive backfill |
| **Files** | `.opencode/skills/spec-creation/tasks/analytical-artifacts.md` |
| **SCs** | SC-5 |
| **Dependencies** | Phase 1 (analytical-artifacts.md exists as base) |
| **Entry** | `spec-creation/tasks/analytical-artifacts.md` exists |
| **Exit** | Retroactive mode documented; existing specs can generate artifacts without breaking pipeline |

### Code Path Coverage

- `spec-creation/tasks/analytical-artifacts.md` — add retroactive mode section

### Cross-Cutting SCs

None

### Interface Boundaries

- Retroactive mode: reads spec body from existing `.issues/{N}/spec.md`, writes artifacts without modifying spec
- No pipeline state change — artifacts coexist with existing spec

### State Transitions

| Before | After |
|--------|-------|
| Existing specs (e.g., #1902): no artifacts, writing-plans BLOCKED | Existing specs: can retroactively generate artifacts via `analytical-artifacts --retroactive` |
| Artifact generation: only works during spec creation | Artifact generation: works at any point post-spec-creation |

### Steps

- [ ] 16. (**sub-agent**) Edit `spec-creation/tasks/analytical-artifacts.md` — add `retroactive` entry point section:
  - Entry criteria: spec.md exists at `{path}/.issues/{N}/spec.md` (no approval check)
  - Mode: reads spec body only, generates artifacts, no pipeline insertion
  - Output: same 7 artifacts at `{path}/.issues/{N}/artifacts/{name}.yaml`
  - Safety: must NOT modify existing spec, issue, or pipeline state
  - Add CLI example: `skill({name: "spec-creation"}) --task analytical-artifacts --mode retroactive --issue N`
  - **→ SC-5**
  Chain: `step_15`
- [ ] 17. (**inline**) Verify retroactive mode — run `spec-creation/tasks/analytical-artifacts.md` in retroactive mode against an existing spec (e.g., #1902) to confirm artifacts are generated without pipeline errors. **→ SC-5**
  Chain: `step_16`
- [ ] 18. (**sub-agent**) Write behavioral enforcement tests for SC-5 — create test script that verifies retroactive artifact generation produces non-empty artifacts without modifying spec body. **→ SC-5**
  Chain: `step_17`

#### Phase 3 VbC

- [ ] 18v. (**clean-room**) VbC — verify Phase 3 SC (SC-5) PASS. **→ SC-5**

## Safety/Rollback Considerations

**Phase 1 — Safety/Rollback:**
- **Destructive operations:** New file creation only (no deletions)
- **Rollback plan:** `git checkout -- .opencode/skills/spec-creation/tasks/` restores original files. Delete new file: `rm .opencode/skills/spec-creation/tasks/analytical-artifacts.md`
- **Data loss risk:** None (git tracks all changes)

**Phase 2 — Safety/Rollback:**
- **Destructive operations:** Edits to existing files
- **Rollback plan:** `git checkout -- .opencode/skills/writing-plans/tasks/create.md .opencode/skills/writing-plans/SKILL.md .opencode/guidelines/010-approval-gate.md`
- **Data loss risk:** Low (git tracks all changes; full revert available)

**Phase 3 — Safety/Rollback:**
- **Destructive operations:** Edit to existing file only
- **Rollback plan:** `git checkout -- .opencode/skills/spec-creation/tasks/analytical-artifacts.md`
- **Data loss risk:** None

## Implementation Pipeline Gates

After all phases complete, invoke:
1. **Implementation pipeline:** `skill({name: "implementation-pipeline"})` — dispatch stages to clean-room sub-agents
2. **Verification before completion:** `skill({name: "verification-before-completion"})` — verify all 5 SCs PASS
3. **Finishing checklist:** `skill({name: "finishing-a-development-branch"})` — branch readiness checks
4. **Review prep:** `skill({name: "git-workflow"}) --task review-prep`
5. **Cleanup:** `skill({name: "git-workflow"}) --task cleanup`

## Authorization

**Cascade status:** Auto-approved — `authorization_scope: for_pr` → plan auto-approves per Approval Cascade Matrix. Implementation auto-approved under same scope. Label `approved-for-pr` on #1903 confirms scope.

## Exit Criteria

- [ ] C1: `spec-creation/tasks/analytical-artifacts.md` exists with 7 artifact generation sub-steps
- [ ] C2: `spec-creation/tasks/create.md` has artifact generation step (Step 11)
- [ ] C3: `spec-creation/SKILL.md` has analytical-artifacts in trigger dispatch table
- [ ] C4: `writing-plans/tasks/create.md` entry criteria validates artifacts and returns BLOCKED with `MISSING_SPEC_ARTIFACT`
- [ ] C5: `writing-plans/tasks/create.md` Step 4a validates artifact existence
- [ ] C6: `writing-plans/SKILL.md` entry criteria updated with artifact check
- [ ] C7: `010-approval-gate.md` critical-rules-010 updated with new pipeline reference
- [ ] C8: Pipeline guidance documents generator→consumer chain for each artifact
- [ ] C9: Retroactive mode documented in `analytical-artifacts.md`
- [ ] C10: Behavioral test verifies retroactive generation for existing specs
- [ ] C11: All 5 SCs (SC-1 through SC-5) verified PASS
- [ ] C12: Plan reported in chat with path

> **Compliance requirement — ALL steps are MANDATORY. Do NOT skip, reorder, or combine.**
>
> Every step has chain dependencies. Execute in sequence. No parallel dispatch of chain-dependent steps.

> **Self-remediation protocol:** If any step fails, diagnose the root cause. If the failure is a spec defect (the spec is wrong or incomplete), file a SPEC-FIX issue, update the spec, and re-dispatch. If the failure is an implementation defect (the code doesn't match the spec), fix the code within the current step. Do not escalate to the developer unless the failure is irrecoverable.
