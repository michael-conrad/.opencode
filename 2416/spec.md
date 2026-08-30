> **Full spec and artifacts: [`.opencode/.issues/2416/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2416/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2416/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The build-verification discipline in `.opencode/AGENTS.md` relies on the `timeout` command as a substitute for a real build/test gate. An agent can claim "build passes" by running a command that exits cleanly without actually executing any tests. This is a systemic gap distinct from #2340 (which assumes the canonical build/test command actually runs tests).

The root problem is that `.opencode/AGENTS.md` documents build/lint/test commands but does not enforce that they were actually executed before a completion claim. The verification-before-completion gate can be satisfied with zero tests run.

## Root Cause / Motivation

The documented convention in `.opencode/AGENTS.md` lists build/lint/test commands but the verification gate checks only that a command was invoked — not that it produced meaningful test results. The advisory "run tests" instruction is not enforced as a hard gate with verifiable evidence output.

## Approach Chosen

1. Add a test-report evidence assertion to the verification-before-completion pipeline that enforces `tests_run > 0` and `all_passed == true`.
2. Update `.opencode/AGENTS.md` to document that verifiable test execution (not just command exit codes) is required before any completion claim.
3. Add behavioral enforcement tests that verify an agent cannot bypass the test-execution gate.

## Alternatives Considered & Why Discarded

- **Keep the status quo (rely on agent integrity):** Already demonstrated insufficient — the bug report was filed because an agent skipped test execution.

## Key Design Decisions

- The test-report evidence assertion is a hard gate that fails closed — if no test evidence artifact exists, the verification-before-completion gate BLOCKs.
- Only verification-before-completion gates (the pipeline gate before completion/PR) are affected — local development iteration is unchanged.

## User Intent / Original Prompt

Bug report #2415: "Build-verification gate satisfiable with zero tests run — agent can claim 'build passes' without executing any tests."

## Not Included

- **#2340 scope** (shallow temp-copy release verification) — this issue is orthogonal and complementary
- **Changes to any external project** — this spec targets `.opencode`'s own build/test discipline only

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|-------------------|----------------------|
| SC-1a | Verification-before-completion gate asserts that at least one test was executed before accepting a completion claim | behavioral | Behavioral test: agent attempts to claim completion without running tests → gate BLOCKs | `.opencode/AGENTS.md` build/lint/test commands |
| SC-1b | Verification-before-completion gate asserts that all executed tests passed before accepting a completion claim | behavioral | Behavioral test: agent attempts to claim completion with a failing test → gate BLOCKs | `.opencode/AGENTS.md` build/lint/test commands |
| SC-2 | Test-execution evidence artifact (`tests-run.yaml` summary) is required by the verification-before-completion pipeline | structural | Verify verification-before-completion task files require test evidence before proceeding | verification-before-completion skill task files |
| SC-3 | `.opencode/AGENTS.md` documents that verifiable test execution is a mandatory pre-condition to any completion claim | structural | `grep` for mandatory test-execution language in `.opencode/AGENTS.md` | `.opencode/AGENTS.md` |
| SC-4 | Behavioral enforcement test asserts that an agent following the previous (unenforced) convention would produce a BLOCKED verification result | behavioral | `opencode run` with a scenario that attempts bypass; verify gate BLOCKs | Behavioral test scenario configuration |

## Requirements

R-1. The verification-before-completion gate SHALL check for test-execution evidence before accepting a completion claim.
R-2. The test-execution evidence artifact SHALL be a file (`tests-run.yaml`) or structured record showing at minimum: what test(s) were run, how many, and the pass count.
R-3. `.opencode/AGENTS.md` SHALL explicitly state that verifiable test execution is mandatory before any completion claim.
R-4. A behavioral enforcement test SHALL verify that an agent attempting to bypass test execution is blocked by the gate.

## Items

### Item 1 (SC-1a): Add test-execution count assertion to verification-before-completion gate

- RED: Behavioral test confirms completion claimed without test execution → PASS (no gate yet)
- GREEN: Add test-execution count check to verification-before-completion task
- verify: Behavioral test shows gate BLOCKs on zero test execution
- commit: One commit

### Item 2 (SC-1b): Add all-passed assertion to verification-before-completion gate

- RED: Behavioral test confirms completion claimed with a failing test → PASS (no gate yet)
- GREEN: Add all-passed check to verification-before-completion task
- verify: Behavioral test shows gate BLOCKs on failing test
- commit: One commit

### Item 3 (SC-2): Require test-execution evidence artifact in verification pipeline

- RED: Structural check confirms no test evidence requirement in pipeline → FAIL
- GREEN: Update verification-before-completion task files to require `tests-run.yaml` evidence artifact
- verify: Verify task file contains evidence requirement
- commit: One commit

### Item 4 (SC-3): Update AGENTS.md mandatory test-execution documentation

- RED: Structural check confirms no mandatory test-execution language → FAIL
- GREEN: Add explicit mandatory test-execution language to `.opencode/AGENTS.md`
- verify: `grep` confirms required language present
- commit: One commit

### Item 5 (SC-4): Behavioral enforcement test

- RED: No behavioral test exists for bypass scenario → FAIL
- GREEN: Write behavioral test that dispatches a bypass scenario and asserts BLOCKED
- verify: `opencode run` with new scenario produces BLOCKED result
- commit: One commit

## Dependencies

| Reference | Relationship | Status |
|-----------|-------------|--------|
| #2340 | Orthogonal — assumes canonical command runs tests; this spec fixes that assumption | Parallel track |
| verification-before-completion skill | Primary target for pipeline changes | Internal — `.opencode/skills/verification-before-completion/` |
| `.opencode/AGENTS.md` | Documentation target | Internal — `.opencode/AGENTS.md` |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1a, SC-1b | Phase 1 |
| R-2 | SC-2 | Phase 1 |
| R-3 | SC-3 | Phase 2 |
| R-4 | SC-4 | Phase 3 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `.opencode/AGENTS.md` | doc | `.opencode/AGENTS.md` | Internal repo file |
| verification-before-completion tasks | task | `.opencode/skills/verification-before-completion/tasks/` | Internal repo files |

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1a: Adding the test-count assertion costs one verification-before-completion task edit. Skipping means an agent can claim completion having run zero tests — the primary failure mode.
- SC-1b: Adding the all-passed assertion costs one verification-before-completion task edit. Skipping means an agent whose tests all fail can still claim completion — the gate validates presence, not quality.
- SC-2: Adding the `tests-run.yaml` evidence requirement costs one pipeline config update. Skipping means "verification passed" remains decoupled from actual test execution.
- SC-3: Updating AGENTS.md costs one documentation edit. Skipping means agents continue treating tests as optional.
- SC-4: Writing the behavioral test costs one scenario + assertion file. Skipping means there is no enforcement mechanism to prevent regression.

## Edge Cases

- **Input boundaries:** The test-execution evidence assertion must handle empty or missing evidence artifacts (zero tests recorded) — this is the primary failure mode the gate is designed to catch.
- **State transitions:** The verification gate transitions from "passes with no test evidence" to "BLOCKED until test evidence exists" — agents that relied on the unenforced convention must now produce evidence.
- **Failure modes:** If no evidence artifact path is configured or the path does not exist, the gate SHALL BLOCK rather than pass open.
- **Recovery:** If the evidence assertion fails due to configuration error (not actual test omission), the gate SHALL report a diagnostic message.

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Change Control

| Date | Change | Reason | Authorizer |
|------|--------|--------|------------|
| 2026-08-30 | Initial spec | Spec creation from bug report #2415 | Developer (bug report) |
| 2026-08-30 | Complete rewrite: removed all Butter/gradle/external repo references; retargeted at `.opencode`'s own build/test discipline; repo-agnostic framing (verifiable test execution required before completion claims) | Revision reason: issue #2415 targets the `.opencode` repo, not external projects. Problem is that `.opencode`'s own build verification can be satisfied with zero tests run. Key changes: remove all external repo paths, target `.opencode` test framework (bash scripts, `opencode run`, behavioral tests), make spec repo-agnostic by focusing on the principle. | developer (revision request) |
| 2026-08-30 | Split SC-1 into SC-1a (test count) and SC-1b (all passed); changed SC-2 evidence type from 'e.g.' to specific `tests-run.yaml` artifact name; confirmed Cost Frame section exists with per-SC cost statements | Fix 3 validation failures from spec-auditor | sub-agent (revision task) |
