# Plan Writer Must Dispatch to Implementation Skills Instead of Emitting Inline Prose

**Scope:** `.opencode/skills/writing-plans/` — specifically `tasks/create/plan-structure.md` (structure generation), `tasks/create/create-and-validate.md` (format template + validation), and `tasks/create.md` (operating protocol).

## Problem

The plan writer's output format uses only two dispatch modes: `(**clean-room**)` and `(**inline**)`. These describe *execution isolation* (new sub-agent vs. same context) but not *which skill governs the work*. This causes three concrete defects:

**Defect 1 — Preloaded inline prose instead of skill routing.** Plan step bodies describe exact implementation details (function to modify, pattern to replace, file to edit) instead of routing to the skill that knows how to do that work. Example from opened #1309 plan: "In `main()` (or a helper called at the start of every command), add logic to scan `.issues/` for..." — this is a dispatch instruction masquerading as step prose. The sub-agent receives preloaded context, triggering `PRELOADED_CONTEXT_REJECTED`.

**Defect 2 — No skill-to-concern mapping in plan structure.** The `plan-structure` sub-agent defines phases and TDD items but never materializes a mapping of concern → skill. Every concern (Python code, TDD tests, task file updates, etc.) gets the same generic treatment. The `implementation-pipeline/SKILL.md` §Dispatch Routing Table documents which skills govern which gate types, but the plan writer never consumes this table at plan-creation time.

**Defect 3 — Missing mandatory pipeline skills in plan output.** Post-RED/green sections routinely omit `adversarial-audit` (mandatory per `implementation-pipeline/SKILL.md`), `completeness-gate` (mandatory bridge before audit), and `completion-core`. The template's checklist validation (`create-and-validate.md` Step 10) does not require every step label to exist in the Dispatch Routing Table.

## Skills Audit — Which Skills the Plan Writer Should Route To

| Concern | Skill | Why | Current Coverage |
|---------|-------|-----|------------------|
| Python/JS/etc. code implementation | `engineering-approach` | Design-before-code, verify-before-complete, no scope creep | Not referenced |
| Test creation (RED phase) | `test-driven-development` | RED/GREEN cycle, Phase 0/4 gates, behavioral RED for rule items | RED/GREEN steps exist structurally but are described inline, not dispatched |
| Test implementation (GREEN phase) | `test-driven-development` | Minimal impl to pass RED, refactor cycle | Same as above |
| Skill file / task file / markdown updates | `skill-creator` `validate` | Validated update workflow with frontmatter checks, fragment management | Not referenced |
| Design before code | `engineering-approach` `design-before-code` | Document approach, consider alternatives | Not referenced |
| Adversarial audit | `adversarial-audit` | Cross-family verification, cross-validate consensus | Missing from post-RED sections |
| Completeness check | `completeness-gate` | Bridge between RED/GREEN and adversarial audit | Not referenced |
| Verification | `verification-before-completion` | SC-level verification against spec | Referenced but as a generic step, not dispatched per the skill's task structure |
| Lint/typecheck/format | `finishing-a-development-branch` | Structural checks | Referenced |
| Review prep | `git-workflow --task review-prep` | PR readiness | Referenced |
| PR creation | `git-workflow` | Pull request creation | Referenced |
| Completion / exec summary | `completion-core` | Push, URL extraction, comment posting, byline | Not referenced |
| Dependency ordering | `solve` + `plan` | Z3-verified phase ordering, SAT-check, phase solvability | Handled (plan-structure Step 3.3/5.5) |
| Pipeline handoff | `implementation-pipeline` `pre-flight-handoff` | Validates plan-to-pipeline contract | Not referenced |
| Conflict resolution | `conflict-resolution` | Intent classification, rebase safety | N/A at plan time |
| Code size/composition | `programming-principles` | Size limits, SRP enforcement | Not referenced |
| Investigation | `brainstorming` → `spec-creation` | Pre-spec exploration | Not applicable to plan writer |
| Correspondence | `correspondence` | Stakeholder comms | N/A at plan time |

**Note on `engineering-approach` language agnosticism:** The `engineering-approach` skill's tasks (`verify-understanding`, `design-before-code`, `verify-before-complete`) contain no language-specific code. They enforce process discipline: read existing code before modifying, document approach, verify against live sources, verify success criteria. This is equally applicable to Python implementation, TypeScript implementation, and skill card / task file updates. The skill is **language-agnostic** — it governs the engineering process, not the implementation language. It applies any time code is written, regardless of language.

## Phase 1 — Dispatch Format Change

### SC-1: Plan step dispatch markers include skill name

The plan output format changes from:

```
- [ ] 3b. GREEN: Add legacy detection to dispatch (**clean-room**). In `main()` add logic...
```

To:

```
- [ ] 3b. GREEN — `engineering-approach` for Python implementation (**clean-room**)
    → dispatch: "execute design-before-code task from engineering-approach"
    → SC-2, SC-3
```

The format template in `create-and-validate.md` and the output format spec in `plan-structure.md` must be updated to require a skill name in the marker. Validation (Step 10) must reject steps with bare `(**clean-room**)` that lack a skill name.

Evidence type: `string` — grep for bare `(**clean-room**)` patterns in generated plans; `behavioral` — plan writer produces plans with skill-dispatch markers.

### SC-2: Step bodies describe dispatch targets, not implementation detail

Every `(**clean-room**)` step body must contain only: the skill dispatch instruction (e.g., `→ dispatch: "execute <task> from <skill>"`), the SC references, and the unit-scope exit criterion. Implementation prose (e.g., "In `main()` add logic to scan...") is prohibited in plan step bodies. This eliminates the preloaded-context pattern that currently causes `PRELOADED_CONTEXT_REJECTED`.

Evidence type: `behavioral` — generated plan steps tagged `clean-room` contain dispatch targets and SC references only, no inline implementation prose.

### SC-3: Skill name maps to an existing skill in the skill deck

The Step 10 validation in `create-and-validate.md` must verify that every skill name referenced in a dispatch marker exists as a directory under `.opencode/skills/`. Steps referencing non-existent skill names fail validation and HALT with `MISSING-TRACEABILITY`.

Evidence type: `behavioral` — validation rejects non-existent skill names.

## Phase 2 — Concern-to-Skill Mapping at Plan-Creation Time

### SC-4: `plan-structure` sub-agent produces phase-to-skill-mapping.yaml artifact

Before defining TDD items, the `plan-structure` sub-agent must:
1. Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table
2. Build a mapping of concern category → skill name per phase
3. Write `.issues/{N}/phase-to-skill-mapping.yaml`

The mapping controls which dispatch markers appear in the generated plan. A phase that produces Python code gets `engineering-approach` markers. A phase that updates skill task files gets `skill-creator` markers. A phase with RED/GREEN cycles gets `test-driven-development` markers for the test steps.

The mapping is materialized (a file on disk), not ephemeral. The plan-writer sub-agent reads this file when generating step markers.

Evidence type: `string` — file exists and contains valid mapping per concern.

### SC-5: Mapping is exhaustive per the dispatch routing table

The mapping covers all concern types present in the spec's phases. No phase step is assigned bare `(**clean-room**)` without a named skill. Validation in Step 10 verifies exhaustiveness.

Evidence type: `behavioral` — plan with mixed concern types (Python + task files + tests) produces all three skill markers.

### SC-6: Concern categories include engineering-process skills, not just code-writing

The mapping accounts for `engineering-approach` (design-before-code, verify-before-complete) as a generic engineering discipline applicable to any implementation type, not just Python. The plan writer does not need to know what language the implementation uses — it maps the *concern* (e.g., "new code implementation") to the *skill* (`engineering-approach`).

Evidence type: `string` — mapping file includes `engineering-approach` for code-implementation concerns regardless of language.

## Phase 3 — Post-RED/green Pipeline Gate Coverage

### SC-7: Post-RED/green sections include adversarial-audit

Every phase's Post-RED/green section must include a step for adversarial audit with expanded sub-steps (no collapsed arrow-chain prose):

```
- [ ] N. ADVERSARIAL AUDIT — `adversarial-audit` (**orchestrator**)
    - [ ] Na. Run resolve-models to select cross-family auditors → SC-all
    - [ ] Nb. Dispatch audit task with auditor_1 → SC-all
    - [ ] Nc. If auditor_1 returned non-clean-pass: remediate root cause, restart from Na → SC-all
    - [ ] Nd. Dispatch audit task with auditor_2 → SC-all
    - [ ] Ne. If auditor_2 returned non-clean-pass: remediate root cause, restart from Na → SC-all
    - [ ] Nf. Both auditors clean PASS. Collect artifact_path values, pass to cross-validate → SC-all
```

The multi-dispatch sub-steps are expanded from `implementation-pipeline/SKILL.md` §Dispatch Routing Table. Arrow-chain prose (`→ resolve-models → auditor 1 → remediate → auditor 2 → cross-validate`) is prohibited — each sub-step is its own indented checkbox.

Evidence type: `string` — grep for adversarial-audit step with expanded sub-step checkboxes in plan post-RED sections.

### SC-8: Post-RED/green sections include completeness-gate bridge

Between the last GREEN step and the adversarial audit step, a completeness gate step with expanded sub-steps:

```
- [ ] N. COMPLETENESS GATE — `completeness-gate` (**clean-room**)
    - [ ] Na. Verify all SCs in this phase covered before audit → SC-all
```

Evidence type: `string` — grep for completeness-gate with checkbox sub-step in plan post-RED sections.

### SC-9: Post-RED/green sections include completion-core for exec summary

At the end of each phase (and at the final phase end), a step for `completion-core` with expanded sub-steps:

```
- [ ] N. EXEC SUMMARY — `completion-core` (**clean-room**)
    - [ ] Na. Push changes → SC-all
    - [ ] Nb. Extract URL from API response (never construct from template) → SC-all
    - [ ] Nc. Post phase-complete issue comment with byline → SC-all
```

Evidence type: `string` — grep for completion-core with checkbox sub-steps in plan post-RED sections.

## Phase 4 — Plan Format Template and Validation Updates

### SC-10: `create-and-validate.md` Step 10 validation checks skill names exist

The checklist validation rule set (Step 10, rules 1-8) gains an additional rule:

9. **Skill name exists:** Every dispatch marker with skill name (`(**skill-name**)`) must reference a directory under `.opencode/skills/`. HALT with `SKILL_NOT_FOUND` if any marker references a non-existent skill.

Evidence type: `behavioral` — plan with `engineering-approach` marker passes validation; plan with `engineering-appraoch` (typo) fails.

### SC-11: `create-and-validate.md` format template requires skill-dispatch format

The "Phase body requirements" section in `create-and-validate.md` updates from:

```
- [ ] 1. <STEP-LABEL> (**<clean-room|inline>**). <description> → SC-N
```

To:

```
- [ ] 1. <STEP-LABEL> — `<skill-name>` for <concern> (**<clean-room|inline>**)
    → dispatch: "execute <task> from <skill-name>"
    → SC-N
```

Evidence type: `string` — template text updated.

### SC-12: `plan-structure.md` Step 5 output format requires skill-dispatch markers

The per-unit output format in `plan-structure.md` Step 5 must include the skill name and dispatch directive alongside the existing `(**clean-room**)`/`(**inline**)` marker.

Evidence type: `string` — output format spec updated.

### SC-13: Pre-RED common sub-steps use indented checkbox format

Every sub-step in Pre-RED Common sections uses the `- [ ] N.` indented checkbox format — never `→` prose continuation lines. This applies to verification gate, read-spec, read-routing-table, and all other pre-RED sub-steps across every phase.

Evidence type: `behavioral` — generated plan's pre-RED sections contain `- [ ] Na.` sub-steps instead of `→ prose` lines.

### SC-14: Post-RED gate sub-steps are expanded into indented checkboxes

Every post-RED gate with sub-steps (adversarial-audit multi-dispatch sequence, completeness-gate, completion-core) MUST expand sub-steps into indented `- [ ] N.` checkboxes per `plan-structure.md` Step 5 sub-step expansion directive. Arrow-chain prose (e.g., `→ resolve-models → auditor 1 → remediate → ...`) is prohibited.

Evidence type: `string` — grep for `^\s+→ [^d]` (arrow lines that are not `→ dispatch:`) in plan post-RED sections returns zero.

### SC-15: Step 10 validation rejects prose-format sub-steps

The Step 10 validation rule set gains a rule verifying that no plan step body contains prose-format sub-steps (matched by `^\s+→ [^d]` pattern — arrow continuations that are not `→ dispatch:` or `→ SC-N`). Any prose-format sub-step causes HALT with `PROSE_SUBSTEPS_DETECTED`.

Evidence type: `behavioral` — plan with prose sub-steps fails validation; plan with checkbox sub-steps passes.

## SC-ID Summary

| ID | Phase | Evidence Type | Verification Method |
|----|-------|---------------|---------------------|
| SC-1 | 1 | `string + behavioral` | grep for bare `(**clean-room**)` + plan writer output with skill markers |
| SC-2 | 1 | `behavioral` | Plan step bodies contain dispatch targets only, no implementation prose |
| SC-3 | 1 | `behavioral` | Validation HALT on non-existent skill name in marker |
| SC-4 | 2 | `string` | `.issues/{N}/phase-to-skill-mapping.yaml` exists |
| SC-5 | 2 | `behavioral` | Mixed-concern plan produces all matching skill markers |
| SC-6 | 2 | `string` | Mapping includes `engineering-approach` for code-implementation concerns |
| SC-7 | 3 | `string` | Post-RED section contains adversarial-audit step |
| SC-8 | 3 | `string` | Post-RED section contains completeness-gate step |
| SC-9 | 3 | `string` | Post-RED section contains completion-core step |
| SC-10 | 4 | `behavioral` | Validation rejects non-existent skill name |
| SC-11 | 4 | `string` | Format template updated to require skill-dispatch |
| SC-12 | 4 | `string` | Output format spec updated to require skill-dispatch |
| SC-13 | 4 | `behavioral` | Pre-RED common sub-steps are indented checkboxes, not `→ prose` |
| SC-14 | 4 | `string` | Post-RED gate sub-steps are expanded indented checkboxes, no arrow-chains |
| SC-15 | 4 | `behavioral` | Step 10 validation rejects prose-format sub-steps with `PROSE_SUBSTEPS_DETECTED` |

## Non-Goals

- No changes to how `engineering-approach` works — it is already language-agnostic. The plan writer just needs to route to it.
- No changes to the skills themselves — only to the plan writer's output format and planning-time mapping.
- No changes to `(**inline**)` steps — these are orchestrator operations (read spec, verify label) that don't need skill routing.