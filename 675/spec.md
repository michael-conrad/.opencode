# [SPEC] Weave behavioral test infrastructure references into verification task files

## Problem

Verification task files (`verify.md`, `start.md`, `checklist.md`) tell the agent *that* it must run behavioral tests for SC verification, but never *how*. The evidence table at `verify.md:190` shows `opencode-cli run` — bare CLI, no `with-test-home`, no `behavior_run`, no existing test script reference. Step 5.5c in `start.md` says "confirm it has been run and FAILS" without specifying the invocation mechanism.

A task file that specifies WHAT without specifying the existing infrastructure is a gap that produces waste: the agent reads the verification procedure, encounters "run `opencode-cli run`", and proceeds to recreate the entire test isolation framework from scratch for each SC check — writing ad-hoc scripts, creating isolated temp directories, reimplementing assertion helpers that already exist in `helpers.sh`. Every recreated test infrastructure is an infrastructure that was already built, tested, and verified to work. The `with-test-home` wrapper, `behavior_run()` function, and 40+ existing behavioral test scripts represent infrastructure that was paid for once and should be used every time.

The verification pipeline must carry the infrastructure reference to the agent. A verification instruction without the infrastructure reference is an instruction that produces duplicate, uncoordinated work.

## Current State (Verified 2026-07-09)

### verify.md (`skills/verification-before-completion/tasks/verify.md`)

- **Evidence types table (lines 190-195):** Shows `opencode-cli run` — no reference to `bash .opencode/tests/behaviors/.sh`, `helpers.sh`, `behavior_run()`, or `with-test-home`
- **No "How to Run Behavioral Tests" subsection:** No dedicated section after the Verification Rule section instructing the agent on the existing test infrastructure
- **No per-SC evidence table format note:** No instruction that the "Verification Command Run" column must show the full command path

### start.md (`skills/executing-plans/tasks/start.md`)

- **Step 5.5c (line 24):** "Confirm the enforcement test has been run and produced a FAILURE result (RED state)." No infrastructure reference to `bash .opencode/tests/behaviors/.sh` or `with-test-home`.

### checklist.md (`skills/finishing-a-development-branch/tasks/checklist.md`)

- **SC Verification section (lines 42-48):** 6 checklist items covering per-SC evidence table, PASS status, FORBIDDEN outcomes, VbC 4-column table, table format match, and artifact source. No re-run behavioral test step.

## Solution

Weave behavioral test infrastructure references into 3 task files so that when the agent reaches SC verification, the existing test infrastructure is the obvious, expected mechanism — not an optional optimization the agent must discover independently.

### Files Changed

#### 1. `skills/verification-before-completion/tasks/verify.md`

**Evidence Types table — Behavioral test run row (line 192):**

Change from bare `opencode-cli run` to reference the existing test script invocation mechanism. The behavioral test script `bash .opencode/tests/behaviors/<scenario>.sh` is the verified entry point — it wraps `behavior_run()` which wraps `with-test-home` which isolates XDG state. An agent that reads this table must find the infrastructure reference, not a generic command name.

**New subsection after §Verification Rule (after line 171, the "AUTHORITY" line):**

Insert "How to Run Behavioral Tests for SC Verification" with:
- The existing behavioral test scripts in `.opencode/tests/behaviors/` are the verified mechanism — source `helpers.sh`, call `behavior_run()`, use assertion helpers
- The `with-test-home` wrapper is baked into `behavior_run()` — no manual XDG isolation setup needed
- FORBIDDEN: Bare `opencode-cli run`, ad-hoc test recreation, inline test infrastructure from scratch
- REQUIRED: `bash .opencode/tests/behaviors/<scenario>.sh` for behavioral SC verification

**Per-SC Evidence Table format note (after the Invalid Evidence section, around line 250):**

"Verification Command Run" column must show the full command — e.g., `bash .opencode/tests/behaviors/my-scenario.sh`, not a generic "ran the test".

#### 2. `skills/executing-plans/tasks/start.md`

**Step 5.5c (line 24):**

Append infrastructure invocation: "For behavioral tests, run `bash .opencode/tests/behaviors/<scenario>.sh` — the `with-test-home` wrapper is baked into `behavior_run()` in `helpers.sh`. Do NOT run bare `opencode-cli run` or recreate the test infrastructure."

#### 3. `skills/finishing-a-development-branch/tasks/checklist.md`

**SC Verification section (after line 48, the VbC table source line):**

Add: "For behavioral SCs, re-run `bash .opencode/tests/behaviors/<scenario>.sh` and verify PASS — do NOT accept a prior run's output as evidence; agent state may have changed between implementation and completion."

## Success Criteria

| SC-ID | Criterion | Evidence Type | Verification Method |
|-------|-----------|---------------|---------------------|
| SC-1 | `verify.md` behavioral evidence row references `bash .opencode/tests/behaviors/<scenario>.sh` instead of bare `opencode-cli run` | `string` | grep for `tests/behaviors/` in the evidence types table area (lines 190-195) |
| SC-2 | `verify.md` contains subsection instructing agent to use existing behavioral test scripts with `with-test-home`/`behavior_run` baked in | `string` | Read subsection (after line 171) — verify it references helpers.sh, behavior_run, with-test-home |
| SC-3 | `verify.md` subsection includes FORBIDDEN (bare `opencode-cli run`, ad-hoc) and REQUIRED patterns | `string` | Read subsection — verify both FORBIDDEN and REQUIRED patterns present |
| SC-4 | `start.md` Step 5.5c specifies `bash .opencode/tests/behaviors/<scenario>.sh` | `string` | Read line area 24 — verify infrastructure invocation appended |
| SC-5 | `checklist.md` SC Verification section includes re-run behavioral test step after the VbC table source line | `string` | Read checklist section (after line 48) — verify re-run step present |
| SC-6 | Per-SC evidence table format note in `verify.md` requires full command in Verification Command Run column | `string` | Read note (after Invalid Evidence section, around line 250) — verify full command requirement |
| SC-7 | No blame-adjacent language in any insertion — e.g., no "you chose to skip", no "cutting corners" | `string` | grep for blame-adjacent patterns across all 3 files |
| SC-8 | No tool-control in any insertion — no line-number instructions, no copy-paste templates | `string` | Read each insertion point — verify no line numbers, no copy-paste templates |

## Enforcement Gate — SC_FAIL_ALL Clause

**ALL success criteria MUST pass before implementation is considered complete. There is NO exception, NO deferral, NO partial credit.**

- If ANY SC fails, ALL SCs are marked as FAIL. The PR MUST be immediately rejected and trashed as defective and unusable.
- Skipping, deferring, or otherwise attempting to bypass an SC marks ALL SCs as FAIL.
- A skipped SC is indistinguishable from a failed SC — both produce the same result: the implementation is not complete.
- The only valid path from FAIL is remediation: diagnose the root cause, fix it, re-verify all SCs from scratch, and confirm 100% clean PASS.
- If remediation fails after 2+ attempts: report BLOCKED with all failure evidence. Do NOT proceed past FAIL.

## Non-Goals

- Changes to any other file beyond the 3 task files listed
- Creating or modifying behavioral test scripts
- Changes to `with-test-home`, `helpers.sh`, or any test infrastructure file
- Backfilling existing content in these files beyond the specific insertion points
- Dark prose reference card, goal hijacking, confirmshaming weave, or tier recalibration (separate specs)
- Adding the behavioral-test-evaluation dispatch step to verify.md (that is #1789's scope — #675 is sequenced AFTER #1789)

## Risk Analysis

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Insertion point drift — file edits change line numbers before implementation | High | Low | Insertions are anchor-identified (after "AUTHORITY" line, after Invalid Evidence section, line 24, after VbC table source line) with surrounding context in SC text |
| Agent copies exact text from spec into files as copy-paste template | Medium | Medium | SC-7 and SC-8 verify result avoids anti-patterns, not that it matches spec text |
| #1789 modifies verify.md before #675 is implemented | High | Low | #675 is sequenced AFTER #1789. The dispatch step added by #1789 should reference the infrastructure that #675 documents. If #1789 is implemented first, #675's insertion points may shift — use anchor-based references, not line numbers. |

## Interdependency Map

### Backward Dependencies (issues that #675 depends on)

| Issue | Relationship | Dependency Type | Action Required |
|-------|-------------|-----------------|-----------------|
| #1789 | Add behavioral-test-evaluation dispatch step to verify.md Steps 1-4 | **SEQUENCE** — #675 modifies the same verify.md file (evidence table, new subsection, per-SC table note). The dispatch step added by #1789 must exist before #675 can weave infrastructure references into it. | Implement #1789 first, then #675. The dispatch step should reference the infrastructure (helpers.sh, behavior_run, with-test-home) that #675 documents. |

### Forward Dependencies (issues that depend on #675)

None identified.

### Dependency Type Definitions

| Type | Meaning | Sequencing Rule |
|------|---------|-----------------|
| **SEQUENCE** | Issue B must be implemented after Issue A (file conflict or logical dependency) | A → B |
| **INDEPENDENT** | No file or logical dependency | Any order |

## References

- `tests/README.md` — `with-test-home` isolation rationale
- `tests/behaviors/helpers.sh` — `behavior_run()` function
- `tests/behaviors/` — 40+ existing behavioral test scripts
- `guidelines/080-code-standards.md` §Behavioral Enforcement Tests (PRIMARY) — behavioral test hierarchy
- `guidelines/080-code-standards.md` §Test Integrity Mandate — no lobotomizing tests
- `guidelines/060-tool-usage.md` §3 Temp Files & Cleanliness — behavioral evidence artifact preservation

---

> **Full spec and artifacts: [`.opencode/.issues/675/`](https://github.com/michael-conrad/.opencode/tree/issues-data/675)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/675/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

---

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)
