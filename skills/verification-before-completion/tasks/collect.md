# Task: collect

Collect evidence for incomplete success criteria when verification identifies gaps.

## Process

**EVIDENCE COLLECTION CLASSIFICATION:** All evidence collection defaults to Tier 1 (behavioral/functional test execution). Tier 2 (structural grep/read) is ONLY acceptable for explicit metadata/existence SCs.

| Tier | Classification | Default | Acceptable For |
|------|---------------|---------|----------------|
| 1 | Behavioral/Functional Test Execution | **DEFAULT — ALL SCs** | Any SC. REQUIRED for behavioral SCs (anything describing behavior, correctness, output, result, pass/fail) |
| 2 | Structural Existence Check | OPT-IN REQUIRED | Only metadata/existence SCs: "file X exists", "label Y present", "header Z present" |

**🚫 FAIL RULE:** If evidence collection uses Tier 2 (structural grep/read) for a Tier 1 SC (behavioral/correctness/output), the collection MUST be reclassified as FAIL with `STRUCTURAL_EVIDENCE` classification. The agent MUST re-run collection using behavioral test execution.

**Evidence type uplift defaults:** When collecting evidence, if a change affects runtime behavior, default the SC evidence type to `behavioral` regardless of declaration. See `guidelines/000-critical-rules.md` §critical-rules-BEH-EV.

**Preservation protocol:** Behavioral evidence artifacts written to `{project_root}/tmp/{issue-N}/behavioral-evidence-*.{log,json}` are NOT cleaned up until PR merge cleanup (`git-workflow --task cleanup`). See `guidelines/060-tool-usage.md`.

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

## Live Verification: Evidence Collection Claims (MANDATORY)

**Each collected evidence item MUST be verified as genuinely produced by a tool call. Assertions without tool-call artifacts are VERIFICATION-GAP findings per `065-verification-honesty.md`.**

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

**Authority:** `guidelines/060-tool-usage.md` §Temp Files & Cleanliness, Issue #836

### Finding Classification

| Finding | Problem Class | Classification | Action |
|--------|---------------|----------------|--------|
| Evidence missing for criterion | MISSING-ELEMENT | conditional | Re-run tool call for missing evidence |
| Verification report not created | MISSING-ELEMENT | auto-fix | Create report now |
| Placeholder evidence detected | VERIFICATION-GAP | conditional | Replace with actual tool-call output |