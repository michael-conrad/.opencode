# Task: progress

Report current progress and track execution state for plan-driven implementation workflows.

## Purpose

Progress reporting ensures that each step of a plan produces visible evidence, enabling the developer to verify implementation quality in real time. The progress task collects verification results, formats them for human readability, and posts them to the appropriate channels.

## Progress Reporting

### Standard Verifications

Each verification type produces evidence artifacts that must be collected before marking a step complete.

1. **Code verification:**
   ```bash
   uv run ruff check --fix src/ test/
   uv run ruff format src/ test/
   uv run pyright src/
   ```
   Evidence: lint pass/fail, format changes, typecheck results

2. **Test verification:**
   ```bash
   uv run pytest test/test_file.py::test_function_name
   ```
   Evidence: test pass/fail count, failure details

3. **File verification:**
   ```bash
   ls -la path/to/file
   head -20 path/to/file
   ```
   Evidence: file existence, size, first lines of content

4. **Coverage verification (when applicable):**
   ```bash
   uv run coverage run -m pytest test/test_file.py && uv run coverage report
   ```
   Evidence: coverage percentage for modified modules

### Custom Verifications

From plan's verification methods, each step may define its own verification:

```markdown
- ☐ Verification: Run unit tests and check coverage
  → Evidence: `pytest --cov=src/module`
```

Custom verifications take precedence over standard verifications when both are specified.

### Progress Comment Format

```markdown
**Progress:** Step N of M complete

**Evidence:**
- [Task 1]: [Evidence]
- [Task 2]: [Evidence]
- Verification: [Result]

**Next:** Step N+1 - [Next concern]

---
🤖 <AgentName> (<ModelId>) 🔄 working
```

Progress comments go to **chat only** — never post implementation progress to GitHub Issues (per `000-critical-rules.md` §Missing Progress Reports).

### Channel Routing

| Content Type | Channel |
|-------------|---------|
| Step completion + evidence | Chat only |
| Substantive findings/decisions | GitHub Issue comment |
| Blockers requiring developer action | GitHub Issue comment + chat |
| Final completion summary | Chat |

## Multi-Step Execution Example

```markdown
**Plan Issue #123:**

## Step 1: Database Schema
- ☑ Create users table
  Evidence: `users_table_created.sql`
- ☑ Add authentication fields
  Evidence: `auth_fields_added.sql`
- ☑ Write migration script
  Evidence: `migration_001.py`

**Verification:** Run migration in test environment
**Evidence:** Migration test passed

---
🤖 <AgentName> (<ModelId>) ✅ completed

## Step 2: API Endpoints
- ☐ Create login endpoint
- ☐ Create logout endpoint
- ☐ Create refresh endpoint

---
🤖 <AgentName> (<ModelId>) 🔄 working
```

## Evidence Collection Rules

| Evidence Type | Collection Method |
|---------------|-------------------|
| Code changes | `git diff --stat` output |
| Test results | Test pass/fail output with counts |
| Lint check | `ruff check` output |
| Type check | `pyright` output |
| File creation | Path, size, content hash |
| API response | Status code and body excerpt |
| Coverage | Percentage per module |

**Evidence storage:** All artifacts stored in `./tmp/` — never `/tmp/`.

## Enforcement

- Evidence missing for task → REQUIRE evidence before marking complete
- Verification not run → RUN verification before marking complete
- Verification failed → FIX issues before proceeding to next step
- No progress report after step → HALT and produce report

## Transition to Verification

After all steps complete:
- Run full test suite
- Run lint/format/typecheck
- Transition to `--task verify` for final evidence collection