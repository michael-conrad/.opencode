# Task: collect

Collect evidence for incomplete success criteria when verification identifies gaps.

## Process

**EVIDENCE COLLECTION CLASSIFICATION:** All evidence collection defaults to Tier 1 (behavioral/functional test execution). Tier 2 (structural grep/read) is ONLY acceptable for explicit metadata/existence SCs.

| Tier | Classification | Default | Acceptable For |
|------|---------------|---------|----------------|
| 1 | Behavioral/Functional Test Execution | **DEFAULT — ALL SCs** | Any SC. REQUIRED for behavioral SCs (anything describing behavior, correctness, output, result, pass/fail) |
| 2 | Structural Existence Check | OPT-IN REQUIRED | Only metadata/existence SCs: "file X exists", "label Y present", "header Z present" |

**🚫 FAIL RULE:** If evidence collection uses Tier 2 (structural grep/read) for a Tier 1 SC (behavioral/correctness/output), the collection MUST be reclassified as FAIL with `STRUCTURAL_EVIDENCE` classification. The agent MUST re-run collection using behavioral test execution.

**Evidence type uplift defaults:** When collecting evidence, if a change affects runtime behavior, default the SC evidence type to `behavioral` regardless of declaration. Load [critical-rules-BEH-EV](guidelines/000-critical-rules.md).

**Preservation protocol:** Behavioral evidence artifacts written to `{project_root}/tmp/{issue-N}/behavioral-evidence-*.{log,json}` are NOT cleaned up until PR merge cleanup (`git-workflow --task cleanup`). Load [tool-usage guidelines](guidelines/060-tool-usage.md).

For each missing criterion:

### 1. Identify What Evidence Is Needed

| Need | Tier | Collection Method |
|------|------|-------------------|
| Test output? | 1 — REQUIRED | Run test, capture output |
| Test artifact output? | 1 — REQUIRED | Run test with `--junitxml` or equivalent, save to `{project_root}/tmp/{issue-N}/artifacts/` |
| File creation? | 2 — OPT-IN ONLY | Show file path and content hash |
| Code change? | 2 — OPT-IN ONLY | Show `git diff` output |
| API response? | 1 — REQUIRED | Show status code and body |

### 2. Collect Evidence

- Run required verification commands
- Store output in `{project_root}/tmp/{issue-N}/artifacts/` or post to issue
- Verify evidence is complete and accurate

### 3. Update Verification Status

- Mark criterion as verified
- Store evidence in `{project_root}/tmp/{issue-N}/artifacts/`
- Proceed to next missing criterion

### Test-Type Annotation Detection

When collecting evidence, the agent MUST detect and annotate the test type for each SC. The annotation is determined by inspecting the test infrastructure usage patterns.

#### Detection Table

| Pattern | Annotation | Detection Method |
| -- | -- | -- |
| `testcontainers` fixture, real DB instance | `(live DB)` | grep for testcontainers imports/fixtures |
| No fixtures, no mocks, no external dependencies | `(unit)` | Check for absence of mock/testcontainers imports |
| `unittest.mock`, `pytest-mock`, `mock.patch`, `MagicMock` | `(mock)` | grep for mock imports/decorators |
| `requests`, `httpx`, `docker`, filesystem I/O, network calls | `(integration)` | grep for network/filesystem imports |

#### Detection Procedure

1. Read the test source file
2. Scan for infrastructure patterns in priority order: `(live DB)` → `(mock)` → `(integration)` → `(unit)`
3. Classify the test type based on the first matching pattern
4. If no pattern matches, default to `(unit)`

#### Evidence Storage for Test-Type Annotations

Test-type annotations MUST be stored alongside the evidence artifact:

```
{project_root}/tmp/{issue-N}/artifacts/vbc-table-{timestamp}.md
```

Each row in the VbC table includes the annotation in the Test column (e.g., `pytest test_api.py::test_create -- (integration)`).

## Common Verification Commands

### Code Changes

```bash
# Show changed files
git diff --name-only

# Show changed content
git diff

# Show staged changes
git diff --cached
```

### Test Verification

```bash
# Run specific test
uv run pytest test/test_file.py::test_function_name

# Run with coverage
uv run pytest --cov=src/module test/
```

### Code Quality

```bash
# Lint check (advisory)
uv run ruff check src/ test/

# Format check (advisory)
uv run ruff format --check src/ test/

# Type check
uv run pyright src/
```

### File Verification

```bash
# File exists
ls -la path/to/file

# File content preview
head -20 path/to/file

# File hash
md5sum path/to/file
```

## Evidence Storage

- Store artifacts in `{project_root}/tmp/{issue-N}/artifacts/` (primary for all outputs)
- Report verification results to chat

## Integration

### Pipeline Order

```
executing-plans → verification-before-completion → (completion claim allowed)
```

### GitBucket Platform Adaptations

- Store verification reports in `{project_root}/tmp/{issue-N}/artifacts/`
- Report results to chat

### Git-Workflow Integration

- Verification happens BEFORE branch push
- Evidence collected during execution phase
- PR created only after all verification passes

## Analytical Artifact Evidence Collection

**For each analytical artifact produced during the pre-implementation phase, collect evidence that the implementation satisfies the artifact's claims.** Analytical artifacts (blast radius, concern map, code path inventory, cross-cutting matrix, interface compatibility, state analysis, testability assessment) make specific claims about the codebase — these claims MUST be verified against the actual implementation.

### Collection Procedure

For each analytical artifact, read the artifact file and verify each claim against the implementation:

#### Blast Radius Artifact

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/blast-radius.yaml`
- [ ] 2. Extract the list of affected files and impact descriptions
- [ ] 3. For each affected file, verify the implementation actually modified it (or document why not)
- [ ] 4. For each impact description, verify the implementation addresses the described impact
- [ ] 5. Collect evidence: `git diff --name-only "$DEFAULT_BRANCH"` for file changes, `git diff` for impact verification

#### Concern Map Artifact

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/concern-map.yaml`
- [ ] 2. Extract the list of concern boundaries and their descriptions
- [ ] 3. For each concern boundary, verify the implementation respects the boundary (no cross-boundary violations)
- [ ] 4. For each concern description, verify the implementation addresses the concern
- [ ] 5. Collect evidence: file-level boundary checks, cross-reference against implementation files

#### Code Path Inventory Artifact

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/code-path-inventory.yaml`
- [ ] 2. Extract the list of code paths and their descriptions
- [ ] 3. For each code path, verify the implementation includes the path
- [ ] 4. For each code path description, verify the implementation behavior matches
- [ ] 5. Collect evidence: function-level path verification, test coverage for each path

#### Cross-Cutting Matrix Artifact

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/cross-cutting-matrix.yaml`
- [ ] 2. Extract the list of cross-cutting concerns and their component mappings
- [ ] 3. For each cross-cutting concern, verify the implementation applies it consistently across all mapped components
- [ ] 4. Collect evidence: per-component verification of cross-cutting concern implementation

#### Interface Compatibility Artifact

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/interface-compatibility.yaml`
- [ ] 2. Extract the list of interfaces and their compatibility requirements
- [ ] 3. For each interface, verify the implementation maintains backward compatibility
- [ ] 4. Collect evidence: signature verification via `srclight_get_signature`, diff analysis

#### State Analysis Artifact

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/state-analysis.yaml`
- [ ] 2. Extract the list of states, transitions, and transition conditions
- [ ] 3. For each state transition, verify the implementation handles the transition correctly
- [ ] 4. For each transition condition, verify the implementation checks the condition
- [ ] 5. Collect evidence: state machine verification, transition test coverage

#### Testability Assessment Artifact

- [ ] 1. Read `{project_root}/tmp/{issue-N}/artifacts/testability-assessment.yaml`
- [ ] 2. Extract the list of testability concerns and recommendations
- [ ] 3. For each testability recommendation, verify the implementation follows it
- [ ] 4. Collect evidence: test file structure, mock/fixture usage, test coverage metrics

### Evidence Storage for Analytical Artifacts

Store analytical artifact evidence alongside other verification artifacts:

```
{project_root}/tmp/{issue-N}/artifacts/analytical-evidence-{timestamp}.md
```

Each entry in the evidence file includes:
- Artifact name and path
- Claim from the artifact
- Verification method used
- PASS/FAIL verdict
- Evidence artifact path or explanation

### Finding Classification for Analytical Artifact Gaps

| Finding | Problem Class | Classification | Action |
|---------|---------------|----------------|--------|
| Artifact claim not satisfied by implementation | ANALYTICAL-GAP | FAIL | Add implementation to satisfy claim, or document as out-of-scope |
| Artifact file missing | MISSING-ARTIFACT | FAIL | Create artifact before proceeding |
| Artifact YAML invalid | INVALID-YAML | FAIL | Fix YAML syntax |
| Artifact claim partially satisfied | PARTIAL-GAP | FAIL | Complete implementation for the claim |

## Live Verification: Evidence Collection Claims (MANDATORY)

**Each collected evidence item MUST be verified as genuinely produced by a tool call. Assertions without tool-call artifacts are VERIFICATION-GAP findings per Load [verification-honesty guidelines](guidelines/065-verification-honesty.md).**

| Claim | Verification Action | Tool Call | Problem Class |
|-------|-------------------|-----------|---------------|
| "Evidence collected" | Verify tool-call artifacts exist for each criterion | Check tool-call records in collection output | MISSING-ELEMENT |
| "Verification report exists" | Verify report file in `{project_root}/tmp/{issue-N}/artifacts/` | `glob(pattern="{project_root}/tmp/{issue-N}/artifacts/verification-*")` | MISSING-ELEMENT |
| "All criteria have evidence" | Verify no criterion lacks tool-call proof | Cross-reference criteria list with evidence list | VERIFICATION-GAP |

**Evidence artifact:** Tool call results confirming each evidence item is genuine and complete.

### Behavioral Artifact Preservation (MANDATORY)

When collecting behavioral evidence, artifacts MUST be written to `{project_root}/tmp/{issue-N}/behavioral-evidence-<sc-id>.{log,json}` with the naming convention:

- `behavioral-evidence-SC-N.log` — Full behavioral test output
- `behavioral-evidence-SC-N.json` — Structured test result summary

These files are **exempt from mandatory cleanup** per `060-tool-usage.md` and MUST survive until PR merge cleanup (`git-workflow --task cleanup`). Deleting them before the auditor inspects them produces a false "no behavioral evidence found" verdict.

**🚫 FORBIDDEN:** Deleting `{project_root}/tmp/{issue-N}/behavioral-evidence-*` files at any pipeline stage before merger confirmation. The ONLY authorized cleanup point is `git-workflow --task cleanup` after PR merge.

**Authority:** Load [Temp Files & Cleanliness](guidelines/060-tool-usage.md), Issue #836

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Evidence missing for criterion | MISSING-ELEMENT | FAIL | Re-run tool call for missing evidence |
| Verification report not created | MISSING-ELEMENT | FAIL | Create report now |
| Placeholder evidence detected | VERIFICATION-GAP | FAIL | Replace with actual tool-call output |