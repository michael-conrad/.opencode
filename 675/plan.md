# Plan: #675 — Weave behavioral test infrastructure references

## Sequencing

**Must be implemented AFTER #1789.** #675 adds infrastructure references (helpers.sh, behavior_run, with-test-home) to the behavioral-test-evaluation dispatch step that #1789 introduces. If #1789 is not yet implemented, the insertion points in verify.md will be in the wrong location.

## RED Phase — Behavioral Tests

No behavioral tests required for #675. All SCs are `string` evidence type (text presence in files). Content-verification via grep is sufficient.

## GREEN Phase — Implementation Steps

### File 1: `skills/verification-before-completion/tasks/verify.md`

#### Change 1.1 — Evidence types table: update behavioral row

**Anchor:** Line 192 (current behavioral evidence row: `| Testable code (logic, behavior, runtime) | Behavioral/functional/regression test execution | pytest, opencode-cli run, lint, typecheck — all with saved artifacts in {project_root}/tmp/{issue-N}/artifacts/ |`)

**Change:** Replace `opencode-cli run` with the infrastructure reference:

```
| Testable code (logic, behavior, runtime) | Behavioral/functional/regression test execution | `bash .opencode/tests/behaviors/<scenario>.sh` (wraps `behavior_run()` → `with-test-home` for XDG isolation), `pytest`, lint, typecheck — all with saved artifacts in `{project_root}/tmp/{issue-N}/artifacts/` |
```

#### Change 1.2 — New subsection: "How to Run Behavioral Tests for SC Verification"

**Anchor:** After line 171 (the `**AUTHORITY:**` line ending the Cross-Model Validation Gate section), before the `## Evidence Types` heading (line 172)

**Insertion point:** Insert a new subsection:

```
### How to Run Behavioral Tests for SC Verification

When an SC requires behavioral verification, use the existing behavioral test infrastructure:

- **Test scripts:** `.opencode/tests/behaviors/<scenario>.sh` — each script is a self-contained artifact-only generator
- **Infrastructure:** `helpers.sh` provides `behavior_run()` which wraps `with-test-home` for XDG-isolated `opencode-cli run` execution
- **Assertion helpers:** `helpers.sh` provides `assert_stderr_pattern_present`, `assert_stderr_pattern_absent`, `assert_tool_calls_made`, `assert_forbidden_pattern_absent`, `assert_required_pattern_present` for stderr-based behavioral evidence

**🚫 FORBIDDEN:**
- Running bare `opencode-cli run` without `with-test-home` — causes SQLite session conflicts with the desktop app
- Recreating test infrastructure from scratch (ad-hoc temp directories, custom isolation scripts)
- Writing inline assertion logic in the verification task — use `helpers.sh` assertion helpers

**✅ REQUIRED:**
- `bash .opencode/tests/behaviors/<scenario>.sh` for behavioral SC verification
- Source `helpers.sh` and use `behavior_run()` for model invocation
- Use `with-test-home` (baked into `behavior_run()`) for all `opencode-cli run` invocations
```

#### Change 1.3 — Per-SC evidence table format note

**Anchor:** After the Invalid Evidence section (after line 206, the "File exists / test file present" row), before the `### Verification Rule: Behavioral vs Structural Evidence` heading (line 208)

**Insertion point:** Add a format note:

```
**Per-SC Evidence Table Format Note:** The "Verification Command Run" column in the per-SC evidence table MUST show the full command path — e.g., `bash .opencode/tests/behaviors/my-scenario.sh`, not a generic "ran the test" or "verified". This ensures the evidence table is reproducible and the exact infrastructure invocation is traceable.
```

### File 2: `skills/executing-plans/tasks/start.md`

#### Change 2.1 — Step 5.5c infrastructure invocation

**Anchor:** Line 24 (current Step 5.5c: "Confirm the enforcement test has been run and produced a FAILURE result (RED state) — the test must fail because the implementation change does not yet exist.")

**Change:** Append infrastructure invocation to Step 5.5c:

```
- **5c.** Confirm the enforcement test has been run and produced a FAILURE result (RED state) — the test must fail because the implementation change does not yet exist. For behavioral tests, run `bash .opencode/tests/behaviors/<scenario>.sh` — the `with-test-home` wrapper is baked into `behavior_run()` in `helpers.sh`. Do NOT run bare `opencode-cli run` or recreate the test infrastructure.
```

### File 3: `skills/finishing-a-development-branch/tasks/checklist.md`

#### Change 3.1 — Re-run behavioral test step

**Anchor:** After line 48 (current last SC Verification item: "VbC table populated from VbC output artifacts, not hand-written (verify source is `tmp/behavioral-evidence-*` or equivalent artifact path)")

**Insertion point:** Add a new checklist item after line 48:

```
- [ ] For behavioral SCs, re-run `bash .opencode/tests/behaviors/<scenario>.sh` and verify PASS — do NOT accept a prior run's output as evidence; agent state may have changed between implementation and completion
```

## Post-GREEN Verification

| SC | Verification Method | Expected Result |
|----|-------------------|-----------------|
| SC-1 (string) | `grep` for `tests/behaviors/` in evidence types table (lines 190-195) | Behavioral row references `bash .opencode/tests/behaviors/<scenario>.sh` |
| SC-2 (string) | Read subsection after line 171 | Subsection references helpers.sh, behavior_run, with-test-home |
| SC-3 (string) | Read subsection | Both FORBIDDEN and REQUIRED patterns present |
| SC-4 (string) | Read start.md line 24 area | Step 5.5c specifies `bash .opencode/tests/behaviors/<scenario>.sh` |
| SC-5 (string) | Read checklist.md after line 48 | Re-run behavioral test step present |
| SC-6 (string) | Read verify.md after Invalid Evidence section (after line 206) | Format note requires full command in Verification Command Run column |
| SC-7 (string) | `grep` for blame-adjacent patterns across all 3 files | No "you chose to skip", "cutting corners", or similar |
| SC-8 (string) | Read each insertion point | No line-number instructions, no copy-paste templates |
