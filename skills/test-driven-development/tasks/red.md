<!-- SPDX-FileCopyrightText: 2026 michael-conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: Derived from majiayu000/claude-skill-registry (MIT) -->

# Task: red

## Invocation

`/skill test-driven-development --task red`

## Exit Criteria

Test written and confirmed FAILING (or ERROR if function doesn't exist yet).

## RED != FALSE Clause

RED is the event of writing an enforcement test, executing it, and observing it FAIL (non-zero exit). RED is not the absence of a feature. If there is no test file and no test run, there is no RED — there is only FALSE.

### Prohibited Patterns (FALSE, not RED)

The following patterns do NOT constitute RED:

- `grep | wc -l` — a count is not a test execution
- `grep -c` — same, a filter count is not a test
- `ls` — file existence does not verify behavior
- `"observe that X does not exist yet"` — observation without execution is not a test
- Any information query that does not produce a non-zero exit code

These are FALSE — they describe the absence of a feature, not the event of a test failing.

## Required RED Structure

| Field | Description |
|-------|-------------|
| Test file path | Permanent test storage path |
| Execution command | Command that produces exit code |
| Expected on FAIL | Exit code N (non-zero) |
| Artifact output | `./tmp/{issue-N}/artifacts/{phase}-test-output.log` |

Test files go to permanent storage (`.opencode/tests/` or `.issues/{N}/spec-artifacts/tests/`).
Test output artifacts (exit code, stdout, stderr) go to `./tmp/{issue-N}/artifacts/` for auditor consumption. Auditors inspect artifacts, they do NOT re-run tests.

## Task Context Schema

```json
{
  "spec_context": "<scope of behavior to test>",
  "test_path": "<path to test file>",
  "worktree.path": "<if set>",
  "github.owner": "<from session>",
  "github.repo": "<from session>"
}
```
