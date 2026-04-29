# Task: step

Execute a single step from the plan, collect evidence, and report progress. This task implements the step-by-step execution model for plan-driven implementation.

## Purpose

Each step in a plan represents a discrete, verifiable unit of work. The step task ensures that:
- Implementation actions are performed according to the plan
- Evidence is collected for each task within the step
- Verification is run at step completion
- Progress is reported to the appropriate channels

## Step Execution Process

### 1. Read Step Content

Parse the step from the plan issue:
- Extract specific tasks described in the step
- Identify the verification method specified
- Identify acceptance criteria or success conditions
- Determine dependencies on previous steps

Read the full step body, not just the title. Step descriptions often contain critical implementation details, edge case handling, and verification specifics that the title alone does not convey.

### 2. Execute Tasks

Perform implementation actions for each task in the step:

- Write or modify code files using the `edit` or `write` tools
- Create new files as specified in the plan
- Update existing files to implement required behavior
- Follow the plan's specified approach (don't deviate into alternative implementations)

**Collect evidence during execution:**
- Record each file modified and its content hash
- Capture output from verification runs
- Store test results (pass/fail counts, failure details)
- Document any deviations from the plan (with justification)

**Run static analysis as you go:**
```bash
uv run ruff check --fix src/ test/
uv run ruff format src/ test/
uv run pyright src/
```

### 3. Verify Step

Run the step's verification method:
- Execute the specified verification command
- Check all evidence collected during execution
- Confirm acceptance criteria are met
- Update step status to ☑ in the plan issue

If verification fails:
- Document the failure with specific details
- Attempt to fix the issue immediately
- Re-run verification after fixes
- If still failing, HALT and report the failure

### 4. Report Progress

Report step completion to chat:

```markdown
**Progress:** Step N of M complete

**Evidence:**
- [Task 1]: [Evidence]
- [Task 2]: [Evidence]
- Verification: [Result]

**Next:** Step N+1 - [Next concern]
```

Update the STATUS in the plan issue body:
- Change `☐` to `☑` for completed tasks
- Add evidence references to the step body

**Channel routing:**
- Step completion + evidence → **chat only** (never post implementation progress to GitHub Issues)
- Substantive findings/decisions → **GitHub Issue comment**
- Blockers → **GitHub Issue comment + chat**

### 5. Proceed to Next

- User says `next step` → Continue to next step
- User says `continue` → Continue to next step
- All steps done → Transition to `--task verify` for final evidence collection

## Evidence Collection

| Evidence Type | Collection Method |
|---------------|-------------------|
| Code changes | `git diff --stat` output |
| Test results | Test pass/fail output |
| Lint check | `ruff check` output |
| Type check | `pyright` output |
| File creation | Path and content hash |
| API response | Status code and body |

**Evidence storage:** All artifacts stored in `./tmp/` — never `/tmp/`.

## Enforcement

During execution, enforce these rules:
- Is evidence collected for each task? If not → REQUIRE evidence before marking complete
- Is verification run for each step? If not → RUN verification before marking complete
- Is progress reported to chat? If not → HALT and produce progress report

### Enforcement Messages

**Missing evidence:**
```
Step verification requires evidence.

Task: [Task description]
Expected evidence: [What to collect]

Please provide evidence before marking step complete.
```

**Verification failed:**
```
Step verification failed.

Verification: [Verification method]
Result: [Failure output]

Fix issues before marking step complete.
```

## Error Recovery

| Error | Recovery |
|-------|---------|
| Test failure after implementation | Debug, fix, re-run test |
| Lint error | Run `ruff check --fix`, re-verify |
| Type error | Fix type annotations, re-run `pyright` |
| File not created | Create the missing file, verify existence |
| Plan step unclear | Re-read plan body for details, proceed with best interpretation |