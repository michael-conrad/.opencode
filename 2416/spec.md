> **Full spec and artifacts: [`.opencode/.issues/2416/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.opencode/.issues/2416/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2416/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Problem

The build-verification discipline in `Butter/AGENTS.md` can be satisfied with `-xtest`, which silently skips all test execution while still reporting `BUILD SUCCESSFUL`. An agent can pass the "build passes" gate, report release-ready, and produce a release with zero tests run — an untested/unusable release. This is a systemic gap distinct from #2340 (which assumes the canonical build/test command actually runs tests).

## Root Cause / Motivation

The documented convention in `Butter/AGENTS.md:79` normalizes `-xtest` as "the norm" across all build contexts. The build-verification gate checks only the exit code of `./gradlew build -xtest`, which produces `BUILD SUCCESSFUL` without executing any tests. The advisory "verify test execution" rule at `AGENTS.md:96-97` is not enforced as a hard gate. A known-broken test (`ConvertInnodbRowFormatDynamicValidationTest`) is invisible to this gate, so the release ships with a known-failing module.

## Approach Chosen

1. Fix the failing test case so the suite passes when tests actually execute.
2. Update the `Butter/AGENTS.md` release build command to remove `-xtest` for release/build verification contexts.
3. Add a test-report XML assertion to the CI or build script that enforces `tests > 0`, `skipped == 0`, `failures == 0`.
4. Add a dev-vs-release distinction in the AGENTS.md conventions section.

## Alternatives Considered & Why Discarded

- **Keep `-xtest` and add a separate test-only step:** Adds workflow complexity (two separate steps that must be kept in sync) and still allows the `-xtest` convention to produce a false green signal.

## Key Design Decisions

- The test-report XML assertion is a hard gate that fails closed — if the XML parser cannot find or parse the report, the build is blocked. This prevents silent passes from infrastructure failures.
- Dev builds retain `-xtest` for iteration speed — the change only affects release/build verification contexts.

## User Intent / Original Prompt

Bug report #2415: "Release/build verification gate satisfiable with `-xtest` — green build with zero tests run produces untested releases."

## Not Included

- **#2340 scope** (shallow temp-copy release verification) — this issue is orthogonal and complementary
- **Changes to the `.opencode` repo's own build system** — this spec targets the Butter project
- **Changes to local developer workflow** — `-xtest` remains valid for local iteration builds

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|-------------------|----------------------|
| SC-1 | Release/build verification gate for releases runs the test suite WITHOUT `-xtest` | behavioral | `git diff Butter/AGENTS.md` shows build commands for release contexts exclude `-xtest` | `Butter/AGENTS.md:79` — current `-xtest` norm |
| SC-2 | Build-verification gate asserts test-report XML has `tests > 0`, `skipped == 0`, `failures == 0` | behavioral | Add CI step or build script that parses test report XML; verify it blocks on empty/failed test run | Gradle XML test report format (standard) |
| SC-3 | `-xtest`-is-the-norm convention removed or gated for release contexts | structural | `Butter/AGENTS.md` updated to distinguish dev-build vs release-build command sets | `Butter/AGENTS.md:79,92,96-97` |
| SC-4 | `ConvertInnodbRowFormatDynamicValidationTest` passes without `-xtest` | behavioral | `./gradlew build :DaoCore2:test` passes | Issue body evidence of test failure (MariaDB DELIMITER issue) |
| SC-5 | Existing development workflow (`-xtest` for local builds) remains unaffected | structural | Local dev build commands in AGENTS.md still use `-xtest` | `Butter/AGENTS.md` dev command conventions |

## Requirements

R-1. The release/build verification build command SHALL execute the full test suite (no `-xtest` flag).
R-2. The build-verification gate SHALL assert the test-report XML shows `tests > 0`, `skipped == 0`, `failures == 0`.
R-3. The `-xtest`-is-the-norm convention SHALL be replaced with a dev-vs-release distinction in `Butter/AGENTS.md`.
R-4. The `ConvertInnodbRowFormatDynamicValidationTest` test SHALL pass when the full test suite is executed.
R-5. The dev build command SHALL remain unchanged from its current state (may continue using `-xtest`).

## Items

### Item 1 (SC-1): Update release build command to remove `-xtest`

- RED: Behavioral test confirms release build gate uses `-xtest` → FAIL
- GREEN: Update `Butter/AGENTS.md` release build command to run without `-xtest`
- verify: `git diff` shows release commands exclude `-xtest`
- commit: One commit for the AGENTS.md update

### Item 2 (SC-2): Add test-report XML assertion to build gate

- RED: Behavioral test asserts no test-report XML check exists → FAIL
- GREEN: Add test-report XML parsing step to release build script or CI config
- verify: Run release build with a skipped/failed test and assert gate blocks
- commit: One commit for the CI/build script change

### Item 3 (SC-3): Update AGENTS.md convention: distinguish dev vs release

- RED: Structural check confirms no dev-vs-release distinction → FAIL
- GREEN: Update AGENTS.md conventions section to add explicit dev-vs-release distinction
- verify: `grep` for dev and release command sets in AGENTS.md
- commit: One commit for the AGENTS.md convention update

### Item 4 (SC-4): Fix ConvertInnodbRowFormatDynamicValidationTest

- RED: Behavioral test — `./gradlew :DaoCore2:test` fails → FAIL
- GREEN: Fix the MariaDB DELIMITER issue (execute the script in a compatible manner)
- verify: `./gradlew :DaoCore2:test` passes
- commit: One commit for the test fix

### Item 5 (SC-5): Verify dev build commands unchanged

- RED: Structural check confirms dev commands unchanged or show change → FAIL
- GREEN: Verify dev build commands in AGENTS.md still include `-xtest`; add explicit section documenting the convention
- verify: `grep` for `-xtest` in dev build commands confirms they remain unchanged
- commit: Included with Item 3 commit (same file, related convention)

## Dependencies

| Reference | Relationship | Status |
|-----------|-------------|--------|
| #2340 | Orthogonal — assumes canonical command runs tests; this spec fixes that assumption | Parallel track |
| `Butter/AGENTS.md` | Primary target file for all documentation changes | External — requires Butter repo access |
| Butter CI pipeline | Target for SC-2 XML assertion step | External — requires Butter repo access |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-3 | Phase 3 |
| R-4 | SC-4 | Phase 1 |
| R-5 | SC-5 | Phase 3 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| Butter/AGENTS.md:79 | doc | Butter project | Issue body reference (external) |
| Butter/AGENTS.md:92 | doc | Butter project | Issue body reference (external) |
| Butter/AGENTS.md:96-97 | doc | Butter project | Issue body reference (external) |
| Gradle test report XML | code | Gradle build output | Standard Gradle `build/reports/tests/` format |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: Updating the build command costs one file edit and one CI run. Skipping means the release gate stays satisfiable with zero tests run — the same bug that motivated this spec.
- SC-2: Adding a test-report XML assertion costs one CI config edit. Skipping means the "build passes" signal remains decoupled from actual test execution, and the death spiral continues.
- SC-3: Updating the convention costs one documentation edit. Skipping means agents continue normalizing `-xtest` across all build contexts, including release.
- SC-4: Fixing the test costs one source-level fix. Skipping means any release build without `-xtest` fails on this known-broken test, rendering the gate unusable.
- SC-5: Preserving dev commands costs zero (no change). Skipping the explicit documentation means agents may remove `-xtest` from dev builds too, breaking local iteration speed.

## Edge Cases

- **Input boundaries:** The test-report XML assertion must handle empty test reports (zero tests executed under `-xtest`) — this is the primary failure mode the gate is designed to catch.
- **State transitions:** The build gate transitions from "green with no tests run" to "red until tests pass" — existing agents that relied on the `-xtest` convention must now use the dev-vs-release distinction.
- **Failure modes:** If the XML parser cannot find or parse the test report, the gate SHALL fail closed (block the build) rather than pass open.
- **Concurrency:** Test execution is sequential within a single build — no concurrency concern.
- **Recovery:** If the test-report XML assertion fails due to parser error (not actual test failure), the gate SHALL report a diagnostic message and allow override with explicit confirmation.
