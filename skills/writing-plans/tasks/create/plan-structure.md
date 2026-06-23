# Task: create/plan-structure

## Purpose

Structure the implementation plan from approved spec: verification gate, combined/separate decision, file structure mapping, and TDD task definition with RED verification checkpoints.

## Entry Criteria

- Approved spec (verified by approval-gate)
- Spec stored as GitHub Issue
- Spec has explicit approval

## Exit Criteria

- Combined/separate decision made and documented
- Duplicate plan check completed
- File structure mapped with clear boundaries
- Item decomposition verified with dependency ordering
- TDD tasks defined with mandatory RED checkpoints

## Procedure

### Phase Dependency Solve Contract (SC-1)

After defining the phase structure, create a dependency-ordering solve contract:

- [ ] 1. Create `.issues/{issue-N}/dependency-ordering-verification/` directory
- [ ] 2. Write `phase-order.yaml` with Z3 variables for each phase position and ordering constraints
- [ ] 3. Run `solve model --contract-path ... --query "phase_1 < phase_2 and phase_1 < phase_3"`
- [ ] 4. Confirm SAT — the phase ordering is valid

### Plan Utility Validation (SC-3)

After phase dependency contract is confirmed SAT, validate phase solvability:

- [ ] 1. Create `./tmp/{issue-N}/artifacts/phase-plan-problem.yaml` with phase structure as planning problem
- [ ] 2. Run `.opencode/tools/plan plan --problem ./tmp/{issue-N}/artifacts/phase-plan-problem.yaml`
- [ ] 3. Confirm planner returns SOLVED_SATISFICING or SOLVED_OPTIMALLY
- [ ] 4. Save result to `./tmp/{issue-N}/artifacts/phase-plan-validated.yaml`
- [ ] 5. If utility unavailable: **HALT** with blocker report — refer to `plan` skill → `fallback.md` task for manual acyclic check procedure

### SC-ID Mapping (SC-4)

After phase structure validated, consume `sc-summary.yaml`:

- [ ] 1. Read `.issues/{issue-N}/sc-summary.yaml`
- [ ] 2. Map each SC to its corresponding plan item by SC-ID
- [ ] 3. Verify all SCs from the spec are covered
- [ ] 4. Flag orphan SCs (in YAML but not mapped) and missing SCs (in spec but not in YAML)

### Pre-Step: Verification Gate (MANDATORY FIRST)

- [ ] 1. Invoke `/skill verification-enforcement --task verify` — collect evidence artifacts for factual claims
    - [ ] 1a. Mark unverified claims with `⚠️ UNVERIFIED`

### Step 0.5: Pipeline-Readiness Gate Check (HARD GATE)

- [ ] 1. Read `.issues/{issue-N}/sc-pipeline-readiness.yaml`
- [ ] 2. Assert `status: PASS`
    - [ ] 2a. If status is FAIL or file does not exist: **HALT** with `SPEC_NOT_READY_FOR_PIPELINE`
    - [ ] 2b. If PASS: extract `sc_summary` and phase dependency declarations

### Step 1: Read Approved Spec

- [ ] 1. Query GitHub Issue for spec content
- [ ] 2. Extract objectives, constraints, success criteria
- [ ] 3. Extract all-or-nothing gate statement from spec's SC section
    - [ ] 3a. If spec lacks gate statement: flag as `SPEC_GAP`
- [ ] 4. Identify affected sub-folders (not individual file paths)
- [ ] 5. Extract spec's repo owner and repo from issue URL

<!-- Fragment ID: sc-enforcement-gate -->

### Step 1.5: Combined vs Separate Plan Decision Gate

- [ ] 1. Evaluate `single_task_determination` from post-creation
    - [ ] 1a. Multi-task spec → **Always separate**
    - [ ] 1b. Single-task + absorbable → **Candidate for combined**
    - [ ] 1c. Single-task + hard to read → **Separate**
- [ ] 2. Document decision output: `Plan structure decision: combined/separate` with reason
- [ ] 3. If COMBINED: write to `.issues/{N}/plan.md` (routing index) + `.issues/{N}/plan-phase-1.md` (single phase), retain `[SPEC]` title prefix
- [ ] 4. If SEPARATE: write to `.issues/{N}/plan.md` (routing index with phase list table) + `.issues/{N}/plan-phase-N.md` (one per phase with dispatch contracts, commit boundaries, checkpoint tag creation step)

### Step 1.6: Duplicate Plan Check

- [ ] 1. Run `ls .issues/*/plan.md 2>/dev/null` to find existing plans
- [ ] 2. For each plan referencing same spec: present choice to proceed or HALT

### Step 2: Map File Structure (Sub-Folder References — SC-9)

- [ ] 1. List sub-folders to create or modify (not individual files)
- [ ] 2. Define each sub-folder's responsibility and concern boundary
- [ ] 3. Ensure decomposition has clear boundaries across sub-folders
- [ ] 4. **NO hardcoded file lists** — agents discover by globbing

### Step 3: Item Decomposition (per `091-incremental-build.md`)

- [ ] 1. Verify item enumeration — every unit listed with name, scope, deliverable
- [ ] 2. Verify dependency ordering — items ordered so dependencies satisfied
- [ ] 3. Verify acceptance criteria per item — each has testable criteria
- [ ] 4. Verify concern boundary annotations — cross-architectural items flagged

### Step 3.3: Phase Dependency-Ordering Solve Contract Creation (SC-1)

- [ ] 1. Run `./.opencode/tools/solve model` with phase dependency constraints
- [ ] 2. Write ordering contract to `.issues/{issue-N}/dependency-ordering-verification/ordering.yaml`
- [ ] 3. Confirm SAT — the phase ordering is valid

### Step 3.4: SC-ID Mapping Substep (SC-4 Consumption)

- [ ] 1. Read `.issues/{issue-N}/sc-summary.yaml`
- [ ] 2. For each phase, verify SC assignments match `sc_summary.phases[].sc_ids`
- [ ] 3. Annotate each plan item with corresponding SC-ID(s)
- [ ] 4. Flag orphan SCs (in YAML but not mapped) as MISSING-TRACEABILITY
- [ ] 5. Flag extra SCs (in plan but not in YAML) as SCOPE-CREEP

### Step 3.5: Phase-to-Skill Mapping Artifact (SC-4, SC-5, SC-6)

- [ ] 1. Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table
- [ ] 2. Build mapping of concern category → skill name per phase
- [ ] 3. Write `.issues/{issue-N}/phase-to-skill-mapping.yaml`
- [ ] 4. Verify mapping is exhaustive — no phase step assigned bare `(**clean-room**)`
- [ ] 5. Verify mapping includes `engineering-approach` for code-implementation concerns

### Step 3.6: RED/GREEN Condition Language (SC-2, SC-4 — Forward-Looking Stance)

- [ ] 1. Write RED conditions as failure state descriptions — NO line numbers, NO exact code, NO file paths
- [ ] 2. Write GREEN conditions as satisfaction state descriptions — "must be true" language
- [ ] 3. Keep RED and GREEN as separate steps — NEVER combined
- [ ] 4. For rule-changing items: use behavioral TDD (write test first, then implement)

### Step 4: Plan Phase Structure (PRIMARY)

Every plan phase MUST define a three-part structure using three discrete sections within ONE phase. This is the single-phase rule (SC-8): Pre-RED Common, Per-Item RED/GREEN Chains, Post-RED/green. These three sections are part of the same phase — never split into separate phases.

**Multi-file format:** Plans use a master ToC (`plan.md`) as routing index + per-phase sub-plans (`plan-phase-N.md`). The master ToC contains the phase list table, dependency ordering, and exit criteria. Each sub-plan is self-contained with its own Pre-RED Common, Per-Item RED/GREEN Chains, and Post-RED/green sections. Sub-plans include dispatch contract fields (`must_receive`/`must_not_receive`), per-step `commits: true` declarations, and a checkpoint tag creation step in Post-RED/green.

The gate labels and step sequence MUST be pulled from `implementation-pipeline/SKILL.md` §Dispatch Routing Table at the time of plan creation. Do NOT hardcode gate names — reference the canonical source.

#### Pre-RED Common

Shared pre-work that runs once per phase before any RED/GREEN chains begin. Every sub-step MUST use the `- [ ] N.` indented checkbox format — never `→` prose continuation lines:

```
- [ ] 1. Verification gate — `verification-enforcement` for spec content verification (**inline**)
    - [ ] 1a. Verify spec claims against live source files → SC-N
- [ ] 2. Read approved spec — `issue-review` for spec content (**inline**)
    - [ ] 2a. Extract objectives, constraints, success criteria, affected sub-folders → SC-N
- [ ] 3. Read routing table — `pre-analysis` for canonical gate discovery (**inline**)
    - [ ] 3a. Confirm gate labels and dispatch types → SC-N
```

##### Concern Boundary Annotations

When transitioning between architectural concerns, describe:
- What concern being left (prior scope)
- What concern being entered (new scope)
- What information the new concern needs from prior (handoff point)

##### File References

List the files affected by this phase. Agents glob to discover content — use sub-folder references, not individual file paths.

##### SC References

List the SCs covered by this phase. Each SC must be traceable to a spec success criterion.

#### Per-Item RED/GREEN Chains

This section contains one RED/GREEN pair per implementation item. Each pair is a sequential chain — RED then immediately GREEN — before the next item's RED begins. RED and GREEN MUST be separate steps (SC-6); they may NEVER be combined.

Each step in the Per-Item RED/GREEN Chains section follows this dispatch contract format:

```
- [ ] N. <STEP-LABEL>: <description> — `<skill-name>` (**<clean-room|inline>**)
    → dispatch: "execute <task> from <skill-name>"
    → must_receive: [<field_name>, ...]
    → must_not_receive: [<field_name>, ...]
    → commits: true
    → SC-<N>
```

Where:
- `must_receive` values are field names (e.g., `sc_ids`, `affected_files`, `spec_body`), not concrete values
- `must_not_receive` always includes `orchestrator_reasoning` and `expected_outcomes` at minimum
- `commits: true` means this step produces a commit before the next step starts

#### Post-RED/green

Post-cycle validation that runs once per phase after all RED/GREEN chains complete. This section MUST contain the following three mandatory pipeline gates in order, each expanded into indented checkbox sub-steps:

```
- [ ] N. COMPLETENESS GATE — `completeness-gate` (**clean-room**)
    - [ ] Na. Verify all SCs in this phase covered before audit → SC-all
- [ ] N. ADVERSARIAL AUDIT — `adversarial-audit` (**orchestrator**)
    - [ ] Na. Run resolve-models to select cross-family auditors → SC-all
    - [ ] Nb. Dispatch audit task with auditor_1 → SC-all
    - [ ] Nc. If auditor_1 returned non-clean-pass: remediate root cause, restart from Na → SC-all
    - [ ] Nd. Dispatch audit task with auditor_2 → SC-all
    - [ ] Ne. If auditor_2 returned non-clean-pass: remediate root cause, restart from Na → SC-all
    - [ ] Nf. Both auditors clean PASS. Collect artifact_path values, pass to cross-validate → SC-all
- [ ] N. EXEC SUMMARY — `completion-core` (**clean-room**)
    - [ ] Na. Write completion event to lifecycle manifest at `./tmp/{N}/lifecycle.yaml` → SC-all
    - [ ] Nb. Report completion in chat with byline → SC-all
```

Arrow-chain prose is prohibited — every sub-step is its own indented checkbox.

#### Validation Rules

| Rule | Description |
|------|-------------|
| Pre-RED once per phase | Pre-RED Common section appears exactly once per phase |
| Post-RED once per phase | Post-RED/green section appears exactly once per phase |
| Chains sequential | Per-Item RED+green Chains execute in order, one pair at a time |
| No section mixing | Content from one section MUST NOT appear in another section |
| RED/GREEN separate | RED and GREEN are always separate steps — never combined |

### Step 5: Define Tasks Within Each Phase (Per-Unit Gates — SC-3)

- Each step is one action (2-5 minutes)
- RED/GREEN condition descriptions per Step 3.5 — NO exact code, commands, or file paths
- **Step 2 RED checkpoint is MANDATORY** — plans without it fail validation

#### Per-Unit Output Format (SC-3 — MUST be embedded in EACH unit)

Every unit gets its own numbered checklist with dispatch indicators. NOT a single shared cross-reference. Each unit MUST use this output format:

**Dispatch mode mapping:**
- `sub-task` → `(**clean-room**)`
- Everything else (orchestrator, inline) → `(**inline**)`

**Discovery directive:** Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table for the canonical gate sequence and dispatch types. Do NOT hardcode gate names — reference the canonical source at plan-creation time.

**Sub-step expansion directive:** Gates with sub-steps (e.g., `adversarial-audit` with resolve-models → auditor_1 → remediate → auditor_2 → cross-validate) MUST be expanded into multiple `- [ ] N.` entries. Prohibit collapsing sub-steps into prose.

**Output format:**

```
- [ ] 1. <gate-label> — `<skill-name>` for <concern> (**<dispatch-mode>**)
    → dispatch: "execute <task> from <skill-name>"
    → SC-N
  - <sub-step description> (**<dispatch-mode>**)
  - <sub-step description> (**<dispatch-mode>**)
- [ ] 2. <gate-label> — `<skill-name>` for <concern> (**<dispatch-mode>**)
    → dispatch: "execute <task> from <skill-name>"
    → SC-N
...
```

Every step MUST include a skill name in the dispatch marker. Bare `(**clean-room**)` or `(**inline**)` without a preceding `— <skill-name> for <concern>` is invalid. The skill name MUST reference an existing directory under `.opencode/skills/`.

### Step 5.5: `plan` Utility Invocation for Phase Solvability

Invoke the `plan` utility to validate phase solvability. Load the `plan` skill for subcommand details and status code interpretation:

```bash
skill({name: "plan"})   # load reference for plan subcommands, status codes, and fallback procedures
```

Then run the phase solvability check:

```bash
./.opencode/tools/plan plan \
  --problem ./tmp/{issue-N}/artifacts/phase-plan-problem.yaml \
  --output ./tmp/{issue-N}/artifacts/phase-plan-validated.yaml
```

Refer to `plan` skill → `plan.md` task for SOLVED_SATISFICING/OPTIMALLY/UNSOLVABLE interpretation. Refer to `fallback.md` task when planner is unavailable.

### Step 6: Generate Implementation Checklist — REMOVED

Implementation checklist generation has been removed. The checklist format (Step 4) and per-unit output format (Step 5) provide sufficient execution guidance. No separate checklist artifact is needed.

## Context Required

- Related tasks: `create/create-and-validate`
- Related skills: `verification-enforcement` (Step 0), `approval-gate` (Step 4.5)
