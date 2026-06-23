# Task: create/plan-structure

## Purpose

Structure the implementation plan from approved spec: verification gate, combined/separate decision, file structure mapping, and flat step sequence definition with multi-file format (master ToC + per-phase sub-plans).

## Entry Criteria

- Approved spec (verified by approval-gate)
- Spec stored as GitHub Issue
- Spec has explicit approval

## Exit Criteria

- Combined/separate decision made and documented
- Duplicate plan check completed
- File structure mapped with clear boundaries
- Item decomposition verified with dependency ordering
- Flat step sequence defined with dispatch/check/inline prefixes

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
    - [ ] 1a. Multi-task spec → **Multi-file format** (master ToC + sub-plans)
    - [ ] 1b. Single-task + absorbable → **Single-file format**
    - [ ] 1c. Single-task + hard to read → **Multi-file format**
- [ ] 2. Document decision output: `Format: multi-file (master ToC + sub-plans) / single-file` with reason
- [ ] 3. If multi-file: write master ToC to `.issues/{N}/plan.md` (≤50 lines, phase table with Depends On and Exit Criteria columns) + per-phase sub-plans to `.issues/{N}/plan-phase-{N}.md`
- [ ] 4. If single-file: write to `.issues/{N}/plan.md`, retain `[SPEC]` title prefix

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

### Step 3.6: RED/GREEN Condition Discovery (SC-2, SC-4)

RED/GREEN conditions are NOT written into the plan. Sub-agents discover failure/satisfaction conditions from the spec during execution. The plan records only the step sequence — conditions are derived at dispatch time.

- [ ] 1. Verify spec SCs are sufficient for sub-agents to derive RED/GREEN conditions
- [ ] 2. Flag any SC that is too vague for condition derivation as `SC_UNDERSPECIFIED`

### Step 4: Plan Phase Structure (PRIMARY)

Every plan phase defines a flat step sequence using three prefix types. Section headers (`#### Pre-RED Common`, `#### Per-Item RED/GREEN Chains`, `#### Post-RED/green`) are human-readable markers only — they carry no semantic meaning for execution. Steps are enumerated in a single flat sequence across the entire plan (no restarting per phase).

The gate labels and step sequence MUST be pulled from `implementation-pipeline/SKILL.md` §Dispatch Routing Table at the time of plan creation. Do NOT hardcode gate names — reference the canonical source.

#### Step Prefix Types

| Prefix | Meaning | Example |
|--------|---------|---------|
| `dispatch:` | Orchestrator calls `task()` with skill + task + context fields | `dispatch: engineering-approach implement { phase: 1, scs: [SC-1, SC-2] }` |
| `check:` | Orchestrator runs Z3 verification | `check: solve check --state-path ... --contract-path ...` |
| `inline:` | Orchestrator executes directly | `inline: git tag <parent>/checkpoint/<issue>/phase-<N>-<submodule>` |

#### Flat Step Sequence Format

```
- [ ] N. dispatch: <skill> <task> { <context_fields> }
- [ ] N. check: solve check --state-path <path> --contract-path <path>
- [ ] N. inline: <command>
- [ ] N. dispatch: adversarial-audit <task> { <context_fields>, auditor: <N> }
```

No SC tables, no output descriptions, no RED/GREEN condition text in the plan. Sub-agents discover conditions from the spec at dispatch time.

#### Concern Boundary Annotations

When transitioning between architectural concerns, describe:
- What concern being left (prior scope)
- What concern being entered (new scope)
- What information the new concern needs from prior (handoff point)

#### File References

List the files affected by this phase. Agents glob to discover content — use sub-folder references, not individual file paths.

#### SC References

List the SCs covered by this phase. Each SC must be traceable to a spec success criterion.

#### Validation Rules

| Rule | Description |
|------|-------------|
| Flat enumeration | Steps are numbered in a single sequence — no restarting per section |
| Prefix required | Every step MUST use one of `dispatch:`, `check:`, `inline:` |
| No RED/GREEN text | Conditions are NOT written in the plan — sub-agents derive from spec |
| No SC tables | SC references are listed in the phase header, not inline in steps |
| No output descriptions | Steps describe what to dispatch, not what the sub-agent produces |

### Step 5: Define Tasks Within Each Phase (Per-Unit Gates — SC-3)

- Each step is one action (2-5 minutes)
- Steps use the three-prefix format — no RED/GREEN condition descriptions in the plan

#### Step Type Format

Every step MUST use one of these three formats:

```
- [ ] N. dispatch: <skill> <task> { <context_fields> }
- [ ] N. check: solve check --state-path <path> --contract-path <path>
- [ ] N. inline: <command>
```

**dispatch:** — Routes to a sub-agent via `task()`. The skill name MUST reference an existing directory under `.opencode/skills/`. Context fields are passed as a JSON-like object in curly braces.

**check:** — Runs Z3 verification against a state contract. The state path points to the current pipeline state file; the contract path points to the expected post-condition contract.

**inline:** — Executes directly in the orchestrator context. Used for git operations, file writes, and other non-dispatch actions.

**Adversarial audit dispatch** uses the same `dispatch:` prefix with the adversarial-audit skill and an `auditor` context field:

```
- [ ] N. dispatch: adversarial-audit <task> { <context_fields>, auditor: <N> }
```

**Discovery directive:** Read `implementation-pipeline/SKILL.md` §Dispatch Routing Table for the canonical gate sequence and dispatch types. Do NOT hardcode gate names — reference the canonical source at plan-creation time.

**Sub-step expansion directive:** Gates with sub-steps (e.g., `adversarial-audit` with resolve-models → auditor_1 → remediate → auditor_2 → cross-validate) MUST be expanded into multiple `- [ ] N.` entries. Prohibit collapsing sub-steps into prose.

### Step 5.5: Sub-Plan YAML Header Format

Each sub-plan file (`.issues/{N}/plan-phase-{N}.md`) MUST begin with a YAML frontmatter header:

```yaml
---
phase: <N>
concern: <description>
depends_on: [<phase-N>, ...]
scs: [SC-<N>, ...]
checkpoint_tag: <parent>/checkpoint/<issue>/phase-<N>-<submodule>
---
```

| Field | Description |
|-------|-------------|
| `phase` | Phase number (1-indexed) |
| `concern` | One-line description of what this phase addresses |
| `depends_on` | List of phase numbers this phase depends on (empty for first phase) |
| `scs` | List of SC-IDs covered by this phase |
| `checkpoint_tag` | Git tag to create on PASS for rollback recovery. Format: `<parent>/checkpoint/<issue>/phase-<N>-<submodule>` |

The master ToC file (`.issues/{N}/plan.md`) does NOT use a YAML header — it is a phase table with Depends On and Exit Criteria columns, ≤50 lines.

### Step 5.6: Post-RED/green Checkpoint Tag Creation

After each phase completes successfully (all steps PASS), create a checkpoint tag for rollback recovery:

```
- [ ] N. inline: git tag <parent>/checkpoint/<issue>/phase-<N>-<submodule>
    → commits: false
```

The `commits: false` annotation means this step does NOT create a commit — it only creates a lightweight git tag. The tag format matches the `checkpoint_tag` field in the sub-plan YAML header.

### Step 5.7: `plan` Utility Invocation for Phase Solvability

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

Implementation checklist generation has been removed. The flat step sequence format (Step 4) and step type format (Step 5) provide sufficient execution guidance. No separate checklist artifact is needed.

## Context Required

- Related tasks: `create/create-and-validate`
- Related skills: `verification-enforcement` (Step 0), `approval-gate` (Step 4.5)
