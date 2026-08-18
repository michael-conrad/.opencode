> **Full spec and artifacts: [`.opencode/.issues/2295/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2295)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2295/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# Spec: Prevent agents from storing source/tests/fixtures in `.issues/` worktree

## 1. Intent and Executive Summary

| # | Field | Content |
|---|-------|---------|
| 1 | **Problem Statement** | The AI agent has begun storing tests, test fixtures, and other source/project items in the `.issues/` worktree folders. `.issues/` is a git worktree on the `issues-data` branch — a separate git repository gitignored in the parent repo. Any file written there never reaches the deployable repo and is lost. Confirmed misrouted test files exist on the issues-data branch: `.issues/1279/tests/`, `.issues/1308/tests/`, `.issues/1314/tests/`, `.issues/1321/tests/`, `.issues/1712/tests/`. **Evidence scope note:** this spec is a `.opencode` submodule change, so all evidence and citations reference the `.opencode` issues-data worktree only. The verified misrouted set in the `.opencode` worktree is exactly `{1279, 1308, 1314, 1321, 1712}` — confirmed via `git -C .opencode/.issues ls-tree -r --name-only origin/issues-data | grep '/tests/'`. A different set (`{1297, 1346, 2127}`) exists in the root repo's `.issues/` worktree but is out of scope for this spec. |
| 2 | **Root Cause / Motivation** | Primary defect: `.opencode/skills/test-driven-development/tasks/red.md` states "Test files go to permanent storage (`.opencode/tests-v2/` or `.issues/{N}/tests/`)." This explicitly authorizes placing test files in `.issues/{N}/tests/`, a path that does not exist in the canonical `.issues/` layout and is invisible to the parent repo's build system. Contributing defects: (a) `.opencode/skills/writing-plans/reference/implementation-workflow.md` labels `.issues/{N}/` "permanent" artifacts that "Never delete or clean" — inviting agents to persist anything there; (b) `.opencode/skills/spec-creation/tasks/create.md` copies "analytical artifacts" into `.issues/{N}/artifacts/` with an ambiguous term; (c) `.opencode/.issues/AGENTS.md` declares "Reading and writing `.issues/` is authorization-free" — reinforcing `.issues/` as a default landing zone with no content-type boundary; (d) `.opencode/skills/git-workflow-pr/tasks/review-prep.md` auto-commits dirty `.issues/<N>/` files into feature PRs. |
| 3 | **Approach Chosen** | Establish a universal principle: tests and source artifacts are tracked in the git repository that owns the code under test, never in `.issues/`. The `.issues/` worktree is a gitignored, non-deployable git repository — any source/test/fixture written there is lost. The fix removes the explicit authorization in `red.md`, corrects the misleading "permanent" framing in `implementation-workflow.md`, disambiguates the artifact copy in `create.md`, and stops auto-committing `.issues/` files into feature PRs. An explicit exclusions list in `.opencode/.issues/AGENTS.md` establishes the content-type boundary. A behavioral enforcement test verifies agents do not write test files under `.issues/`. |
| 4 | **Alternatives Considered & Why Discarded** | **Alternative: migrate/delete the already-misrouted test files** (`.issues/1279/tests/`, `.issues/1308/tests/`, `.issues/1314/tests/`, `.issues/1321/tests/`, `.issues/1712/tests/`). Discarded: migration/deletion of existing misrouted files is out of scope — it risks data loss on the issues-data branch and does not address the root cause (the authorization that caused the misrouting). The fix targets the authorization and enforcement, not the symptom. |
| 5 | **Key Design Decisions** | (1) **Owning-repo principle over fixed path** — tests are placed per the repo that owns the code under test, not a hardcoded path. Tradeoff: requires agents to resolve owning repo at runtime rather than follow a fixed rule, but prevents future misrouting. (2) **Universal prohibition** — `.issues/` holds issue metadata only, never source/test/fixture/code, in both root and submodule repos. Tradeoff: stricter than the prior "authorization-free" framing, but necessary because `.issues/` is a gitignored orphan-branch worktree. (3) **Behavioral enforcement** — a behavioral test asserts agents do not write `.issues/` test files, complementing the text fixes. Tradeoff: behavioral tests are slower and may be flaky, but they are the only evidence type that verifies actual agent behavior. |
| 6 | **User Intent / Original Prompt** | Prevent the AI agent from storing source/tests/fixtures in the `.issues/` worktree (non-deployable repos, lost work). |

## 2. Not Included

- **Migration or deletion of already-misrouted test files** (`.issues/1279/tests/`, `.issues/1308/tests/`, `.issues/1314/tests/`, `.issues/1321/tests/`, `.issues/1712/tests/`) — out of scope to avoid data loss on the issues-data branch; the fix targets the authorization, not the symptom.
- **Changes to the root repo (`opencode-config`)** — this is a `.opencode` submodule change only.
- **Changes to the `.issues/` worktree mechanism itself** — it remains a gitignored orphan-branch worktree.
- **Removal of valid analysis-artifact persistence** in `.issues/{N}/artifacts/` (spec, plan, cards, contracts remain metadata artifacts) — only the ambiguity of what counts as an "analytical artifact" vs source/test/fixture is disambiguated.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | `.opencode/.issues/AGENTS.md` contains an explicit exclusions list stating `.issues/` holds issue metadata only, never source/test/fixture/code. | string | grep AGENTS.md for the exclusions-list marker / content-type boundary statement | `.opencode/.issues/AGENTS.md` |
| SC-2 | `.opencode/skills/test-driven-development/tasks/red.md` no longer lists `.issues/{N}/tests/` as a valid test storage path. | string | grep red.md for absence of `.issues/{N}/tests/` | `.opencode/skills/test-driven-development/tasks/red.md` |
| SC-3 | `.opencode/skills/test-driven-development/tasks/red.md` directs test placement by the owning-repo principle (resolve the repo owning the code under test, then place per that repo's conventions). | string | grep red.md for presence of owning-repo reference | `.opencode/skills/test-driven-development/tasks/red.md` |
| SC-4 | `.opencode/skills/writing-plans/reference/implementation-workflow.md` Rule 1 clarifies `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts. | string | grep Rule 1 for metadata-only language | `.opencode/skills/writing-plans/reference/implementation-workflow.md` |
| SC-5 | `.opencode/skills/spec-creation/tasks/create.md` Step 6 disambiguates the "analytical artifacts" copy target so only analysis artifacts (not source/test/fixture) are copied to `.issues/{N}/artifacts/`. | string | grep Step 6 for unambiguous copy-target description | `.opencode/skills/spec-creation/tasks/create.md` |
| SC-6 | `.opencode/skills/git-workflow-pr/tasks/review-prep.md` Step 0 no longer auto-commits arbitrary dirty `.issues/<N>/` files into feature PRs. The unconditional `git add .issues/` auto-commit is removed entirely. | string | grep Step 0 for removal of unconditional `git add .issues/` auto-commit | `.opencode/skills/git-workflow-pr/tasks/review-prep.md` |
| SC-7 | A new behavioral enforcement test at `.opencode/tests-v2/behaviors/` asserts an agent does NOT write test files under `.issues/`. Artifact-only generator per canonical framework. | behavioral | Behavioral test execution via `with-test-home opencode run`; stderr-based assertions for absence of `.issues/` write actions; Bash tool timeout >= 600s | `.opencode/tests-v2/AGENTS.md` |

## 4. Requirements

- R-1. The `.opencode/.issues/AGENTS.md` workspace guide SHALL include an explicit exclusions list stating that `.issues/` holds issue metadata only and never source, test, fixture, or code content.
- R-2. The `.opencode/skills/test-driven-development/tasks/red.md` task card SHALL NOT list `.issues/{N}/tests/` as a valid test storage path.
- R-3. The `.opencode/skills/test-driven-development/tasks/red.md` task card SHALL direct test placement by the owning-repo principle (resolve the repo owning the code under test, then place per that repo's conventions).
- R-4. The `.opencode/skills/writing-plans/reference/implementation-workflow.md` Artifact Retention Rule 1 SHALL clarify that `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts.
- R-5. The `.opencode/skills/spec-creation/tasks/create.md` Step 6 SHALL disambiguate the "analytical artifacts" copy target so only analysis artifacts (not source/test/fixture) are copied to `.issues/{N}/artifacts/`.
- R-6. The `.opencode/skills/git-workflow-pr/tasks/review-prep.md` Step 0 SHALL NOT auto-commit arbitrary dirty `.issues/<N>/` files into feature PRs; the unconditional `git add .issues/` auto-commit SHALL be removed entirely.
- R-7. A behavioral enforcement test SHALL exist at `.opencode/tests-v2/behaviors/` asserting an agent does NOT write test files under `.issues/`.
- R-8. All text fixes SHALL use stable anchors (section names), not line numbers, given confirmed line-number drift.
- R-9. All changes SHALL be confined to the `.opencode` submodule; no root repo (`opencode-config`) changes.
- R-10. The behavioral enforcement test SHALL be an artifact-only generator (exit 0, no self-evaluation) per the canonical framework in `.opencode/tests-v2/AGENTS.md`.

## 5. Items

### Item 1 (SC-1): Add exclusions list to `.opencode/.issues/AGENTS.md`

- RED: grep AGENTS.md for the exclusions-list marker (e.g., "never source/test/fixture/code") — assert ABSENT (fails before change)
- GREEN: add the exclusions list stating `.issues/` holds issue metadata only, never source/test/fixture/code
- verify: grep AGENTS.md for the exclusions-list marker — assert PRESENT
- commit: the AGENTS.md exclusions-list addition

### Item 2 (SC-2): Remove `.issues/{N}/tests/` from `red.md`

- RED: grep red.md for `.issues/{N}/tests/` — assert PRESENT before change
- GREEN: remove `.issues/{N}/tests/` as a valid test storage path
- verify: grep red.md — assert `.issues/{N}/tests/` ABSENT
- commit: the red.md test-storage-path removal

### Item 3 (SC-3): Add owning-repo principle to `red.md`

- RED: grep red.md for owning-repo reference — assert ABSENT before change
- GREEN: add owning-repo principle directive for test placement
- verify: grep red.md — assert owning-repo reference PRESENT
- commit: the red.md owning-repo principle addition

### Item 4 (SC-4): Clarify artifact retention in `implementation-workflow.md`

- RED: grep Rule 1 for "metadata only" clarification — assert ABSENT before change
- GREEN: reframe Rule 1 to state `.issues/{N}/` holds issue metadata only, not arbitrary source/test/fixture artifacts
- verify: grep Rule 1 for metadata-only language — assert PRESENT
- commit: the implementation-workflow.md Rule 1 clarification

### Item 5 (SC-5): Disambiguate artifact copy target in `create.md`

- RED: grep Step 6 for unambiguous copy-target scope — assert ABSENT before change
- GREEN: disambiguate Step 6 so only analysis artifacts (not source/test/fixture) are copied to `.issues/{N}/artifacts/`
- verify: grep Step 6 for disambiguated copy-target description — assert PRESENT
- commit: the create.md Step 6 disambiguation

### Item 6 (SC-6): Remove auto-commit of `.issues/` files in `review-prep.md`

- RED: grep Step 0 for unconditional `git add .issues/` auto-commit — assert PRESENT before change
- GREEN: remove the unconditional auto-commit of dirty `.issues/<N>/` files entirely
- verify: grep Step 0 for removal of the unconditional `git add .issues/` auto-commit — assert PRESENT
- commit: the review-prep.md Step 0 auto-commit removal

### Item 7 (SC-7): Add behavioral enforcement test for `.issues/` test-write prohibition

- RED: behavioral test FAILS — agent writes `.issues/` test file (before text fixes, or scenario is unguarded)
- GREEN: add the behavioral enforcement test at `.opencode/tests-v2/behaviors/<scenario>.sh`; agent does NOT write `.issues/` test file
- verify: behavioral test PASSES via `with-test-home opencode run`; stderr-based assertions for absence of `.issues/` write actions; Bash tool timeout >= 600s
- commit: the behavioral enforcement test

## 6. Dependencies

- **Reference:** `.opencode/tests-v2/AGENTS.md` — **Relationship:** the behavioral enforcement test (SC-7) MUST follow the canonical artifact-only generator paradigm and prompt construction mandate defined here. **Status:** satisfied (canonical framework exists).
- **Reference:** `.opencode/.issues/AGENTS.md` — **Relationship:** SC-1 modifies this file; the exclusions list is the authoritative content-type boundary all other fixes reference. **Status:** satisfied (file exists).
- **Reference:** `.opencode/skills/test-driven-development/tasks/red.md` — **Relationship:** SC-2 and SC-3 modify this file. **Status:** satisfied (file exists).
- **Reference:** `.opencode/skills/writing-plans/reference/implementation-workflow.md` — **Relationship:** SC-4 modifies this file. **Status:** satisfied (file exists).
- **Reference:** `.opencode/skills/spec-creation/tasks/create.md` — **Relationship:** SC-5 modifies this file. **Status:** satisfied (file exists).
- **Reference:** `.opencode/skills/git-workflow-pr/tasks/review-prep.md` — **Relationship:** SC-6 modifies this file. **Status:** satisfied (file exists).

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Item 1 |
| R-2 | SC-2 | Item 2 |
| R-3 | SC-3 | Item 3 |
| R-4 | SC-4 | Item 4 |
| R-5 | SC-5 | Item 5 |
| R-6 | SC-6 | Item 6 |
| R-7, R-10 | SC-7 | Item 7 |
| R-8 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6 | Items 1-6 |
| R-9 | SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 | Items 1-7 |

## 8. Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `.opencode/.issues/AGENTS.md` | config | `.opencode/.issues/AGENTS.md` | read — Authorization section, exclusions list absent (confirmed gap) |
| `.opencode/skills/test-driven-development/tasks/red.md` | code | `.opencode/skills/test-driven-development/tasks/red.md` | read — the "Test files go to permanent storage" directive contains `.issues/{N}/tests/` |
| `.opencode/skills/writing-plans/reference/implementation-workflow.md` | code | `.opencode/skills/writing-plans/reference/implementation-workflow.md` | read — Rule 1 Artifact Retention ("Never delete or clean" permanent framing) |
| `.opencode/skills/spec-creation/tasks/create.md` | code | `.opencode/skills/spec-creation/tasks/create.md` | read — Step 6 analytical-artifacts copy target |
| `.opencode/skills/git-workflow-pr/tasks/review-prep.md` | code | `.opencode/skills/git-workflow-pr/tasks/review-prep.md` | read — Step 0 `git add .issues/` auto-commit |
| `.opencode/tests-v2/AGENTS.md` | config | `.opencode/tests-v2/AGENTS.md` | read — canonical behavioral test framework |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Verifying the exclusions list exists in AGENTS.md costs one grep call. Skipping means the content-type boundary is never authoritatively declared, and agents continue to misroute source/tests/fixtures into `.issues/` — a defect discovered only when the lost work surfaces in production, costing 1000× more to fix.
- **SC-2:** Verifying `.issues/{N}/tests/` is removed from red.md costs one grep call. Skipping means the explicit authorization to misroute test files remains, and RED-phase agents keep writing tests to a non-deployable path — a defect discovered only when the tests never reach the build, costing 1000× more to fix.
- **SC-3:** Verifying the owning-repo principle is present in red.md costs one grep call. Skipping means test placement reverts to a fixed-path rule that misroutes tests into `.issues/` — a defect discovered only when the tests never reach the build, costing 1000× more to fix.
- **SC-4:** Verifying Rule 1 clarifies metadata-only retention costs one grep call. Skipping means the "permanent / never delete" framing continues to invite arbitrary artifact persistence in `.issues/` — a defect discovered only when the build misses source artifacts, costing 1000× more to fix.
- **SC-5:** Verifying Step 6 disambiguates the copy target costs one grep call. Skipping means the ambiguous "analytical artifacts" term continues to permit copying source/test/fixture content into `.issues/{N}/artifacts/` — a defect discovered only when non-deployable content ships, costing 1000× more to fix.
- **SC-6:** Verifying Step 0 no longer auto-commits `.issues/` files costs one grep call. Skipping means feature PRs continue to auto-include arbitrary dirty `.issues/` files — a defect discovered only when a PR carries unintended content, costing 1000× more to fix.
- **SC-7:** Running the behavioral enforcement test costs minutes of execution time. Skipping means the aggregate `.issues/` content-type boundary is never verified against real agent behavior, and the misrouting defect ships to production — costing 1000× more to fix than the bounded behavioral test.

## 11. Edge Cases

- **Input boundaries:** The exclusions list in AGENTS.md MUST be explicit and unambiguous — an empty or vague list provides no boundary. The owning-repo principle MUST resolve to a concrete repo (root vs submodule) for every code-under-test; if the owning repo cannot be resolved, the agent MUST NOT default to `.issues/`.
- **State transitions:** The change transitions `.issues/` from "accepts anything" to "accepts issue metadata only." This is a monotonic restriction — no pre-existing valid behavior is removed, no state is lost. The misrouted test files on the issues-data branch remain untouched.
- **Failure modes:** If the behavioral enforcement test (SC-7) is flaky, it may produce false negatives in the enforcement suite. Mitigation: follow the canonical framework, use stderr-based assertions, and create fixtures before running. If a text fix is incomplete, the corresponding string grep fails.
- **Concurrency:** No runtime concurrency concerns — all changes are agent-facing text and a test harness addition. The behavioral test runs in isolation via `with-test-home`.
- **Recovery:** All changes are idempotent text/behavior edits; recovery is a revert of the diff. No data migration or rollback path beyond the text-change itself is required.

---

## 12. Change Control

| Date | Change | Reason | Authorized By |
|------|--------|--------|---------------|
| 2026-08-17 | Corrected misrouted test-file evidence paths in Problem Statement, Alternatives Considered, and Not Included sections from `.issues/1297/tests/`, `.issues/2127/tests/`, `.issues/1346/tests/` to the real verified paths `.issues/1279/tests/`, `.issues/1308/tests/`, `.issues/1314/tests/`, `.issues/1321/tests/`, `.issues/1712/tests/`. | Provenance validation finding: cited paths did not exist in the live issues-data worktree; corrected to real verified paths. | Validation pipeline |
| 2026-08-17 | Removed the erroneous `.issues/2254/tests/` path from all citations (Problem Statement, Alternatives Considered, Not Included, and the prior Change Control entry). The verified misrouted test-file set on the issues-data branch is exactly `.issues/1279/tests/`, `.issues/1308/tests/`, `.issues/1314/tests/`, `.issues/1321/tests/`, `.issues/1712/tests/` — confirmed via `git ls-tree -r --name-only origin/issues-data`. | Provenance validation finding: `.issues/2254/` does not contain a `tests/` directory on the live issues-data branch; corrected to the verified set. | Validation pipeline |
| 2026-08-17 | Decomposed SC-2 into two SCs: SC-2 (red.md no longer lists `.issues/{N}/tests/` as a test storage path) and SC-3 (red.md directs test placement by the owning-repo principle). Renumbered downstream SCs (SC-4..SC-7) and Items (Item 4..Item 7) accordingly; updated Requirements, Traceability, Dependencies, Cost Frame, and Edge Cases references. Removed the either/or escape hatch from the review-prep auto-commit SC (now SC-6): the unconditional `git add .issues/` auto-commit is removed entirely, a single deterministic outcome. Deleted stale `sc-summary.yaml` analytical artifact. | Structural validation findings: (1) SC-2 was compound, bundling two distinct verification targets; (2) SC-5 contained an either/or escape hatch. Fix intent and owning-repo principle unchanged. | Validation pipeline |
| 2026-08-17 | Reclassified SC-1 through SC-6 evidence type from `structural` to `string`, since every verification method is grep/pattern-match (string evidence per the canonical taxonomy). Replaced the exact line-number citations in the Section 8 Documentation Sources table (line 42, line 64, lines 126-135, lines 39-51) with stable anchors (directive text, Rule 1 Artifact Retention, Step 6, Step 0). Aligned the Edge Cases failure-mode reference from "structural grep" to "string grep". Fix intent, owning-repo principle, and SC verification methods unchanged. | Validation findings: (1) EVIDENCE_TYPE_MISMATCH — SC-1..SC-6 declared `structural` but verified via grep; (2) INTERNAL CONSISTENCY — Section 8 line-number citations contradict R-8 stable-anchor mandate. | Validation pipeline |
| 2026-08-17 | Added an explicit evidence-scope note to the Problem Statement stating this spec's evidence is scoped to the `.opencode` issues-data worktree only, with the verified misrouted set `{1279, 1308, 1314, 1321, 1712}` and the out-of-scope root-repo set `{1297, 1346, 2127}` disambiguated. Added a Documentation Sources column to the Section 3 SC table per spec-structure-standards.md canonical format. SCs, fix intent, owning-repo principle, and verification methods unchanged. | Validation findings: (1) WORKTREE DISAMBIGUATION — two separate `.issues/` worktrees with different misrouted test dirs; evidence must reference the `.opencode` worktree only; (2) STRUCTURE — Section 3 SC table lacked a Documentation Sources column. | Validation pipeline |

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
