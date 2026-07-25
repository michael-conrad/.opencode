> **Full spec and artifacts: [`.opencode/.issues/2144/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2144)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2144/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Objective

Add per-SC triplet integrity checks to the `writing-plans` pipeline to prevent phase decompositions where RED tests and their corresponding GREEN implementations are split across different phases.

## Background

The `writing-plans` pipeline has a systemic defect: the `structure` task produces phase decompositions where RED tests and their corresponding GREEN implementations can be split across different phases. The `self-review` and `validate` tasks do not detect this violation. This causes plans where all RED tests are batched in one phase and all GREENS in another — violating per-item TDD (091-incremental-build.md) and producing RED tests that assert against uncommitted code.

Root cause: The `structure` task produces unverified artifacts. The `self-review` and `validate` tasks check per-task step ordering within a single task but do not check that each SC's RED/GREEN/COMMIT triplet is self-contained within the same phase.

## Not Included

- Changes to the `writing-plans` pipeline orchestration layer (SKILL.md or dispatcher)
- Changes to plan execution or implementation pipeline
- Changes to the `spec-creation` pipeline
- Changes to the `audit` skill

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `structure.md` rejects phase decomposition where any SC's RED and GREEN are in different phases | `behavioral` | `opencode run` with prompt that triggers structure task on a spec with split SCs → stderr shows BLOCKED |
| SC-2 | `structure.md` rejects phase decomposition where a RED test depends on uncommitted SC output | `behavioral` | `opencode run` with prompt that triggers structure task on a spec with cross-phase RED dependency → stderr shows BLOCKED |
| SC-3 | `self-review.md` detects and BLOCKs on any SC whose RED/GREEN/COMMIT steps are split across phases | `behavioral` | `opencode run` with prompt that triggers self-review on a plan with split SCs → stderr shows SELF_REVIEW_FAILED |
| SC-4 | `validate.md` detects and FAILs on any SC whose RED/GREEN/COMMIT steps are split across phases | `behavioral` | `opencode run` with prompt that triggers validate on a plan with split SCs → stderr shows FAIL |
| SC-5 | `structure.md` documents the triplet integrity rule in its procedure: "Each SC's RED, GREEN, and COMMIT steps MUST be in the same phase. No SC may have its test in one phase and its implementation in another." | `string` | grep for the rule text in structure.md |
| SC-6 | `self-review.md` documents the triplet integrity check in its procedure | `string` | grep for the check in self-review.md |
| SC-7 | `validate.md` documents the triplet integrity check in its procedure | `string` | grep for the check in validate.md |
| SC-8 | Behavioral enforcement test exists that verifies the triplet integrity check fires on a defective plan | `behavioral` | `opencode run` with prompt that produces a plan with split SCs → stderr shows BLOCKED/FAIL |

## Requirements

1. The `structure.md` task SHALL reject any phase decomposition where a single SC's RED, GREEN, and COMMIT steps are not all in the same phase.
2. The `structure.md` task SHALL reject any phase decomposition where a RED test depends on SC output that is not yet committed in the same phase.
3. The `self-review.md` task SHALL detect and report any SC whose RED/GREEN/COMMIT steps are split across phases.
4. The `validate.md` task SHALL detect and FAIL any SC whose RED/GREEN/COMMIT steps are split across phases.
5. The triplet integrity rule SHALL be documented in the procedure section of `structure.md`.
6. The triplet integrity check SHALL be documented in the procedure section of `self-review.md`.
7. The triplet integrity check SHALL be documented in the procedure section of `validate.md`.
8. A behavioral enforcement test SHALL exist that verifies the triplet integrity check fires on a defective plan.

## Items

| Item | SC | Description |
|------|-----|-------------|
| 1 | SC-1 | Add triplet co-location check to structure.md |
| 2 | SC-2 | Add cross-phase dependency check to structure.md |
| 3 | SC-3 | Add triplet split detection to self-review.md |
| 4 | SC-4 | Add triplet split detection to validate.md |
| 5 | SC-5 | Document triplet rule in structure.md procedure |
| 6 | SC-6 | Document triplet check in self-review.md procedure |
| 7 | SC-7 | Document triplet check in validate.md procedure |
| 8 | SC-8 | Create behavioral enforcement test |

## Dependencies

- `091-incremental-build.md` — Per-item TDD cycle mandate
- `writing-plans` skill — Target pipeline for the fix

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1 | SC-1 | 1 |
| R2 | SC-2 | 1 |
| R3 | SC-3 | 2 |
| R4 | SC-4 | 2 |
| R5 | SC-5 | 1 |
| R6 | SC-6 | 2 |
| R7 | SC-7 | 2 |
| R8 | SC-8 | 3 |
