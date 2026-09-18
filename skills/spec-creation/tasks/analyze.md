# Task: analyze

## Category

ANALYSIS

## Purpose

Perform pre-spec inspection, research card consultation, requirements extraction, problem decomposition, and analytical artifact generation. This task produces the analysis artifacts that the create task consumes. It does NOT write spec content, create remote issues, or run holistic checks.

## Entry Criteria

- [ ] `issue_number` and `project_root` received in dispatch context
- [ ] `issue_number` is a bound, real issue number — NOT an unbound/placeholder value (e.g., `N`, `TBD`, `0`, a literal placeholder token, or a number with no corresponding issue record)
- [ ] No preloaded analysis, orchestrator reasoning, or expected outcomes in the prompt
- [ ] Codebase is indexed (srclight available)

## BLOCK Precondition

**If `issue_number` is unbound or a placeholder** (a literal placeholder token such as `N`/`TBD`, a non-numeric value, `0`, or a number with no corresponding issue record in the project), the analyze task MUST BLOCK immediately. It MUST NOT proceed with pre-spec inspection, requirements extraction, decomposition, or artifact generation.

- **BLOCK reason:** `UNBOUND_ISSUE_NUMBER` — the analyze task cannot anchor its analysis to a real issue. Issue-number binding is NOT analyze.md's responsibility; it is handled upstream by issue-operations-core creation and by create.md remote-stub-first. The orchestrator MUST provide a bound issue number before dispatching analyze.
- **Result contract:** return `status: BLOCKED` with `blocker_reason` explaining that the issue number is unbound/placeholder and must be bound upstream before analyze can run.

## Procedure

### Step 1: Pre-spec inspection

- [ ] 1.1. Search the codebase for affected files, existing patterns, and conventions relevant to the spec topic. Use `srclight_hybrid_search` and `srclight_get_dependents` to identify:

  - Files that would be modified by the spec
  - Existing patterns and conventions in those files
  - Dependencies and callers of affected symbols

- [ ] 1.2. Write findings to `{project_root}/tmp/{issue_number}/artifacts/pre-spec-inspection.yaml`.

### Step 2: Research card consultation

- [ ] 2.1. Glob `.issues/research-cards/*.md` and grep frontmatter for research questions matching the spec topic. If a card exists with `confidence >= 0.7`, incorporate its findings into the analysis.

- [ ] 2.2. Write findings to `{project_root}/tmp/{issue_number}/artifacts/research-card-consultation.yaml`.

### Step 3: Requirements extraction

- [ ] 3.1. Extract requirements from the problem statement:

  - Explicit requirements (stated directly)
  - Implicit requirements (inferred from context)
  - Constraint requirements (boundary conditions)
  - Non-requirements (explicitly excluded)

- [ ] 3.2. Verify every requirement against the actual codebase using srclight, file reads, and config checks. Write structured YAML to `{project_root}/tmp/{issue_number}/contracts/requirements-output.yaml`.

### Step 4: Problem decomposition

- [ ] 4.1. Decompose the problem into discrete units with defined interfaces, inputs, outputs, invariants, and failure modes. Decompose until each unit is a single independently verifiable claim. For each SC in the spec's success criteria table, create one implementation item with its own RED/GREEN/verify/commit cycle. Items are numbered sequentially. Each item references exactly one SC-ID.

- [ ] 4.2. Write to `{project_root}/tmp/{issue_number}/contracts/decompose-output.yaml`.

### Step 5: Analytical artifact generation

- [ ] 5.1. Generate the 7 analytical artifacts consumed by `writing-plans`:

- [ ] 1. **Blast radius** — Affected components and ripple effects per phase. **Bounded-grounding rule (R-18):** Ground the blast radius from the spec's own affected-files/scope sections FIRST; only then inspect the primary target surface and its direct call sites (bounded reads). Record grounding coverage and any ungrounded assumptions in the artifact itself rather than exhaustively reading implementations. Deep code reading is warranted only when the spec's scope sections are insufficient to identify the affected surface.
- [ ] 2. **Concern map** — Concern boundaries and separation per phase
- [ ] 3. **Code path inventory** — Code paths touched by each phase
- [ ] 4. **Cross-cutting matrix** — Cross-cutting concerns matrix
- [ ] 5. **Interface compatibility** — Interface compatibility analysis (unchanged, modified, new, removed; backward compatible, breaking, internal only). Include a `dependency_contract` section with entries mapping `source` (from `interfaces`), `target` (from `removed_interfaces` or related), `type` ("artifact schema"), and `constraint` (from `breaking_changes` or implied coupling).
- [ ] 6. **State analysis** — State machine transitions per phase
- [ ] 7. **Testability assessment** — Test strategy per phase (unit, integration, behavioral, mixed)

- [ ] 5.2. Write each artifact to `{project_root}/tmp/{issue_number}/artifacts/{name}.yaml`.

**Incremental-emission rule (R-18):** Emit each artifact immediately upon deriving it — one artifact per write. Do NOT batch-derive all artifacts and then emit them in a single large turn. **Hard ordering — write before expand:** derive each artifact from the spec's scope sections plus the reads already performed, then WRITE it BEFORE any further reads; expanded grounding (additional reads) after a write is permitted only to fill an artifact section that could not be derived from what was already gathered, and the assumption being filled MUST be recorded in the artifact itself. Before deriving an artifact, check the artifacts directory for artifacts already written (e.g., by a prior interrupted run); on resumption, emit only the remaining artifacts without re-deriving artifacts already on disk.

**Skeleton-first write (R-21):** For each artifact, immediately after reading the spec's scope sections and BEFORE any grounding reads, write a minimal valid skeleton artifact to the target path — the YAML header plus empty placeholder sections, a few lines long. All subsequent work on that artifact APPENDS to and refines the skeleton section-by-section, with one small write per section. Never accumulate a full artifact body across multiple reasoning turns before the first write: the skeleton on disk guarantees that an interrupt at any later point leaves a valid artifact (empty sections) rather than nothing. This rule refines the emission path only — grounding requirements are unchanged and still occur, only AFTER the skeleton write.

**Action-first transition rule (R-21):** When a write is due — the skeleton write or any section append/refine — the agent's next assistant action MUST be the write tool call itself. No restating what will be written, no summarizing what was derived, no pre-write verification prose between the decision to write and the write call. The write transition is a tool call, not a paragraph.

**Incident recovery (R-22):** if you make an unintended edit outside the artifact target, revert it with ONE immediate corrective tool call, record a one-line incident note in the artifact, and continue the task — deliberating about revert mechanics, re-reading policy rules, or re-planning before resuming is prohibited. Excessive deliberation over an incident is a deck-defect signal, not a model characteristic.

- [ ] 5.3. **validate-yaml gate (R-13):** After the artifacts are written, run the scoped check `./.opencode/tools/local-issues validate-yaml --number <repo>#<issue_number>` where `<repo>#<issue_number>` is the qualified name of the issue under analysis (e.g., `opencode-config#42` for the root repo, `.opencode#42` for the `.opencode` submodule). This scoped check is the progress-gating check — it validates only the target issue's own records. This gate is read-only — it NEVER mutates files. **Gate action-first (R-21):** when you have decided to run this gate, your next tool call MUST be the gate command itself — no intervening read, inspection, verification, or scoping call between the decision and the gate execution; record the command and its exit code immediately from that call's result.
  - The gate MUST be executed directly by the agent performing this task — do NOT delegate it to another agent and report the outcome second-hand. A second-hand claim that the gate ran is NOT gate evidence.
  - The result contract MUST include the literal gate invocation evidence: the exact command executed and its exit code (and, on exit 1, the malformed-file report lines). A prose claim that the gate ran — without the recorded command + exit code in the result contract — is treated as gate-not-run: return BLOCKED (or re-run the gate and capture the evidence).
  - Exit 0 → continue to Step 6.
  - Exit 1 → return the BLOCKED result contract with `blocker_reason: VALIDATE_YAML_FAILED`, naming each malformed file with its path and the error class from the report line. Do NOT fix or rewrite the malformed files.

### Step 6: Pipeline readiness gate

- [ ] 6.1. Validate:

  - **Atomicity:** Every SC maps to exactly one RED→GREEN→COMMIT cycle
  - **Dependency ordering:** SC dependency DAG is acyclic
  - **Single concern:** Every SC targets one file category and one verification domain
  - **Phase dependency:** Phase dependency graph is acyclic
  - **Three-tier structure:** Multi-phase specs have pre/per-file/post structure

- [ ] 6.2. Write to `{project_root}/tmp/{issue_number}/artifacts/pipeline-readiness.yaml`.

## Exit Criteria

- [ ] All 7 analytical artifacts written to `{project_root}/tmp/{issue_number}/artifacts/`
- [ ] validate-yaml gate (R-13) executed directly by this agent after artifact generation, with the gate command + exit code recorded in the result contract — or BLOCKED with `VALIDATE_YAML_FAILED` naming malformed files
- [ ] Requirements extracted and verified against codebase
- [ ] Pipeline readiness gate passed (or BLOCKED with findings)
- [ ] No spec content written, no remote issue created, no holistic check run

## Result Contract

```yaml
status: DONE | BLOCKED
analysis_artifact_path: "{project_root}/tmp/{issue_number}/artifacts/"
finding_summary: "Brief summary of analysis findings, key requirements, and decomposition structure"
gate_evidence: "validate-yaml gate invocation: exact command executed (e.g., `./.opencode/tools/local-issues validate-yaml --number <repo>#<issue_number>`) and its literal exit code (and, on exit 1, the malformed-file report lines). A result contract without this evidence is treated as gate-not-run."
blocker_reason: "If BLOCKED: why the analysis could not complete (e.g., VALIDATE_YAML_FAILED — lists malformed file paths and error classes from the validate-yaml report)"
```
