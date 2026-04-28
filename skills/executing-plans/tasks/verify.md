# Task: verify

Run verification for the current step, ensuring evidence is collected and quality gates are met. This task enforces the evidence-before-completion discipline for plan-driven execution.

## Purpose

Verification is the quality gate between steps. No step may be marked complete without producing tool-call evidence confirming the deliverable exists and behaves as specified. This task collects that evidence, classifies the results, and reports the verification state.

## Verification Process

### 1. Standard Verifications

Run appropriate verifications based on step type:

**Code verification:**
```bash
uv run ruff check --fix src/ test/
uv run ruff format src/ test/
uv run pyright src/
```

**Test verification:**
```bash
uv run pytest test/test_file.py::test_function_name -v
```

**File verification:**
```bash
ls -la path/to/file
head -20 path/to/file
```

**Coverage verification (when specified in plan):**
```bash
uv run coverage run -m pytest test/test_file.py
uv run coverage report --include=src/module.py
```

### 2. Custom Verifications

From plan's verification methods:

```markdown
- ☐ Verification: Run unit tests and check coverage
  → Evidence: `pytest --cov=src/module`
```

Custom verifications supersede standard verifications when both are defined. Always prefer the plan's specified verification method.

### 3. Collect Evidence

Each verification must produce an evidence artifact:

| Evidence Type | Collection Method | Required Output |
|---------------|-------------------|-----------------|
| Code changes | `git diff --stat` | File list with change counts |
| Test results | Test runner output | Pass/fail counts + failure details |
| Lint check | `ruff check` output | Violation count or "All checks passed" |
| Type check | `pyright` output | Error count or "0 errors" |
| File creation | Path + content hash | Existence confirmation + hash |
| API response | Status code and body | HTTP status + response excerpt |
| Coverage | Coverage report | Percentage per module |

**Evidence storage:** Artifacts go in `./tmp/` — never `/tmp/`.

### 4. Evaluate Verification Results

| Result | Action |
|--------|--------|
| All evidence collected, all verifications pass | Mark step ☑, proceed |
| Evidence incomplete | HALT — require evidence before marking complete |
| Verification failed | HALT — fix issues before proceeding |
| New test failures introduced | HALT — regression detected, revert and investigate |

### 5. Mark Step Complete

- All evidence collected → Mark step as ☑ in plan issue
- Evidence incomplete → HALT and require evidence
- Verification failed → Report failure and require fix
- Do NOT mark complete based on "it looks right" without tool-call evidence

## Enforcement Rules

- Evidence missing for task → REQUIRE evidence before marking complete
- Verification not run → RUN verification before marking complete
- Verification failed → FIX issues before proceeding
- Regression detected → REVERT and investigate before proceeding

## Verification Failure Protocol

When verification fails, produce a structured failure report:

```
Step verification failed.

Verification: [verification method]
Result: [failure output]
Classification: [ERROR | FAILURE | REGRESSION]

Action required: Fix issues before marking step complete.
```

### Common Failure Patterns

| Pattern | Root Cause | Resolution |
|---------|-----------|------------|
| Lint errors | Code style violation | Run `ruff check --fix` then re-verify |
| Type errors | Type mismatch | Fix type annotations, re-run pyright |
| Test failure | Incorrect implementation | Debug test, fix code, re-run test |
| Missing file | File not created | Create file, verify existence |
| Import error | Module structure issue | Check package structure, add __init__.py |