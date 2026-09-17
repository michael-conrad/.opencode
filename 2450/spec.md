> **Full spec and artifacts: [`.opencode/.issues/2450/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2450/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2450/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC-FIX] local-issues validate-yaml scoped validation mode (`--number repo#N`) — pipelines verify their own issue records independent of workspace drift

## 1. Intent and Executive Summary

- **Problem Statement:** `.opencode/tools/local-issues validate-yaml` is all-or-nothing workspace-wide — it scans every issue directory in all tracked repos and exits 1 on any violation anywhere, with no scoping option (verified 2026-09-17: `validate-yaml --help` accepts zero flags). Unrelated record drift therefore blocks unrelated pipelines. Observed live 2026-09-17: the spec-creation analyze step for issue 2451 was BLOCKED at the R-13 gate by 374 legacy files (bare-list `comments.yaml`/`links.yaml` from the 2026-05-15 migration) with zero violations in 2451's own records. The R-13 gate contract then required workspace-wide remediation before any pipeline could proceed — the rejection→discard→restart cost the workflow exists to prevent, triggered by unrelated state. Provenance: remote issue 2450 body records the live block and the raw report baseline (`tmp/2450/validate-yaml-root-report.txt`, `tmp/2450/validate-yaml-submodule-report.txt` — captured at ticket creation, since removed from the working tree).
- **Root Cause / Motivation:** Two defects compound. (a) `cmd_validate_yaml()` in `.opencode/tools/local-issues` has no per-issue scoping — it walks `ISSUES_DIR` and gates on the union of all findings, so the working issue's clean records cannot be distinguished from unrelated legacy drift. (b) The R-13 gate contract in the spec-creation task cards (`analyze.md` Step 5.3, `create.md` Step 6.1) invokes that unscoped form as a hard pipeline gate, converting any workspace-wide drift into a blocker for every pipeline. The legacy drift itself (bare YAML lists emitted by the 2026-05-15 mass migration, never backported when the validator schema tightened) is real but is a maintenance concern — it becomes a pipeline emergency only because the gate is unscoped. Why now: as long as the gate stays workspace-wide, the next drift — wherever it lands — re-blocks every spec-creation pipeline.
- **Approach Chosen:** Add a scoped validation mode to `local-issues validate-yaml`: `--number repo#N` (qualified form, consistent with the tool's existing number conventions) validates only that issue directory's records — the same checks the workspace scan applies (`issue.yaml`, `comments.yaml`, `links.yaml` schema validation plus `spec.md` frontmatter) — and exits 0/1 for those files alone, reporting violations with the same `<path>: <error-class>` format and error-class taxonomy. Default invocation with no flags remains the full workspace scan, preserving the existing guarantee for maintenance use. The spec-creation analyze task card's R-13 gate invocation consumes the scoped form (validating the issue the pipeline is about to write), so unrelated workspace drift can never again block a pipeline; the workspace-wide form remains available to the gate as a secondary maintenance check but MUST NOT gate pipeline progress on unrelated issues' records.
- **Alternatives Considered & Why Discarded:**
  - **One-time data migration wrapping legacy bare lists in the dict envelope (old Direction 1) — completed as background, not a spec alternative:** the repair leg was completed 2026-09-17, committed via `local-issues sync` (commit `95488dff` on the `.opencode` issues-data branch plus a companion root-repo commit), and both repos' `validate-yaml` now exit 0 (verified live 2026-09-17 during this revision). It is recorded as completed background in §2 and Dependencies — not as an SC — because the repair addresses the historical data, while this spec addresses the structural gate defect that let that data block pipelines.
  - **Validator dual-format tolerance (accept bare lists as a legacy comments/links form, old Direction 2) — REJECTED:** it weakens the record-schema guarantee to avoid a repair — an escape hatch, not a fix. Listed in §2 Not Included with this rationale; non-negotiable within this spec.
  - **Keep the gate workspace-wide and require remediation before any pipeline proceeds (status quo) — REJECTED:** this is the defect under repair; it converts unrelated maintenance debt into a universal pipeline blocker, and the observed 2451 block is the direct cost.
- **Key Design Decisions:**
  - **Qualified `repo#N` flag form:** consistent with the tool's post-2432 qualifier enforcement — every command requires `repo#N`; the scoped flag inherits that convention rather than introducing a bare-number variant.
  - **Default stays workspace-wide:** no-flag invocation is byte-for-byte the current full scan. The maintenance guarantee is preserved; only the pipeline-facing gate changes its consumption of the tool.
  - **One taxonomy, two modes:** scoped mode reuses the same scan machinery (`_scan_issue_dir_errors`), the same error classes (`invalid-yaml`, `schema-violation`, `malformed-frontmatter`), and the same `<path>: <error-class>` report format. Format parity is an SC (SC-2), not an implementation hope — a single shared code path makes divergence structurally impossible.
  - **Scoped exit-code semantics:** scoped mode gates only on the target issue's own files — exit 0 when the target is clean even if the rest of the workspace violates the schema; exit 1 only when the target's own files have findings.
  - **Gate contract is scoped-primary, workspace-secondary:** the R-13 gate's progress check is the scoped invocation of the issue the pipeline is about to write; the workspace-wide scan remains available as a secondary maintenance check that MUST NOT gate pipeline progress on unrelated issues' records.
  - **Data repair is background, not scope:** the completed repair leg is documented for provenance only; no SC covers it (it cannot be re-verified as RED/GREEN — the drift no longer exists).
- **User Intent / Original Prompt:** Issue 2450 was created 2026-09-17 as `[SPEC-FIX] local-issues validate-yaml gate is workspace-wide with no scoping — 356 pre-existing legacy schema violations block all spec-creation pipelines at the R-13 gate` — a bug-report deliberation dump listing three unresolved "Fix Directions (for review)" with the decision deferred to the developer. Revised 2026-09-17 per developer directive: restructure into a full specification per spec-structure-standards with the solution DECIDED, not deliberated — scoped validation mode (`--number repo#N`) + R-13 gate scoping; data-repair leg recorded as completed background; dual-format tolerance rejected. (The file count drifted between observations — 356 at ticket creation, 374 at the directive — as more issues accumulated; both figures cite their observation dates.) Revised again 2026-09-17 per developer directive: two additional success criteria added — the issues-data hygiene mandate (SC-5) and the remote-first spec-number reservation mandate (SC-6) — see Change Control.

## 2. Not Included

- **Validator dual-format tolerance for bare lists** — REJECTED: accepting a bare YAML list as a legacy `comments.yaml`/`links.yaml` form weakens the record-schema guarantee to avoid a repair. An escape hatch, not a fix; the schema stays strict and the data was repaired instead.
- **The legacy data repair itself** — completed 2026-09-17 (commit `95488dff` plus companion root-repo commit; both repos' `validate-yaml` exit 0 verified live). Background, not an SC: it is historical data work that cannot be re-run as a RED/GREEN cycle, and re-verifying it belongs to `validate-yaml`, not to this spec's items.
- **Changing comment/link record semantics beyond the envelope shape** — the schema definition is untouched; only the scan's scoping is added (carried from the original ticket).
- **Removing or weakening the workspace-wide default scan** — the no-flag invocation stays exactly as delivered; the maintenance guarantee is a feature, not a defect.
- **Changes to the error-class taxonomy or report format** — parity with the existing taxonomy is required (SC-2); introducing new classes or formats for scoped mode would create two dialects of one report.
- **Modifying issue 2450's own records** — verified clean in the original observation (zero violations involved 2450); the issue's tracking files are not implementation surface.

## 3. Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|---|---|---|---|---|
| SC-1 | `local-issues validate-yaml --number <repo>#N` validates only the target issue directory's records and applies scoped exit-code semantics: exit 0 when the target issue's own files are clean even when other issues' records elsewhere in the workspace violate the schema; exit 1 only when the target issue's own files have findings. | behavioral | executed pytest unit tests under `.opencode/tests/test_local_issues/` (extending the existing `test_validate_yaml_exit_codes.py` patterns) exercising a fixture workspace with a clean target amid violating neighbors — exit 0 — and a violating target — exit 1 | `.opencode/tools/local-issues` (`cmd_validate_yaml`, `_find_issue_dir`); `.opencode/tests/test_local_issues/test_validate_yaml_exit_codes.py` (existing suite, verified 2026-09-17) |
| SC-2 | Violation reporting format parity: scoped mode emits `<path>: <error-class>` report lines using the same error-class taxonomy as the workspace scan (`invalid-yaml`, `schema-violation`, `malformed-frontmatter`), restricted to the target issue's files. | behavioral | executed pytest unit tests asserting scoped-mode report lines match the workspace scan's line format and error classes for identical fixture files; scoped output equals the workspace scan's output filtered to the target's paths | `.opencode/tools/local-issues` (`_scan_issue_dir_errors`, error-class constants); `.opencode/tests/test_local_issues/` |
| SC-3 | The spec-creation analyze task card's R-13 gate text invokes the scoped form — `validate-yaml --number <repo>#<issue-under-analysis>` validating the issue the pipeline is about to write — as the progress-gating check. | string | grep-class content-verification assertion over `.opencode/skills/spec-creation/tasks/analyze.md` Step 5.3 for the scoped invocation and absence of the unscoped form as the gating command | `.opencode/skills/spec-creation/tasks/analyze.md` (Step 5.3, verified 2026-09-17) |
| SC-4 | The R-13 gate contract language at every site that mandates workspace-wide gating is updated to scoped gating: the scoped check gates pipeline progress; the workspace-wide scan is a secondary maintenance check that MUST NOT gate pipeline progress on unrelated issues' records. Sites: `analyze.md` (Step 5.3 body, exit criteria, result-contract `gate_evidence`/`blocker_reason` wording) and `create.md` (Step 6.1 body, exit criteria, result-contract wording). | string | grep-class assertions over both task cards for the scoped-primary/secondary-maintenance contract language and the MUST-NOT-gate clause; absence of contract language requiring workspace-wide remediation before pipeline progress | `.opencode/skills/spec-creation/tasks/analyze.md`; `.opencode/skills/spec-creation/tasks/create.md` (both verified by grep 2026-09-17) |
| SC-5 | Issues-data hygiene mandate stated in the governing issues-data docs — the `.opencode/.issues/AGENTS.md` workspace guide and the issues-data/`.issues/` section of `.opencode/AGENTS.md` that describes repair authority for the issues-data worktrees (the `### .issues/ Is a Worktree — NOT a Regular Directory` section; both target files verified to exist 2026-09-17 by `ls`/`grep` before being named here): it is the AGENT'S RESPONSIBILITY to repair, remediate, and revise as needed ALL files in the issues-data branches as needed to prevent problems — issue-ticket data repairs are authorization-free agent hygiene and do NOT require a spec. Rationale encoded in the docs: the observed 374-file legacy schema drift sat unrepaired and blocked pipelines; the developer directive "issue ticket repairs don't require specs" (2026-09-17) made this the agent's standing responsibility. | string | grep-class content-verification assertions over both docs for the agent-responsibility mandate ("repair, remediate, and revise"), the ALL-files-in-the-issues-data-branches scope, and the authorization-free/no-spec-required clause | `.opencode/.issues/AGENTS.md` (Authorization and Workflow sections); `.opencode/AGENTS.md` (`.issues/` worktree guidance section, line 216) — both verified by ls/grep 2026-09-17 |
| SC-6 | Remote-first spec-number reservation mandate stated and reinforced at every governing site — the `.opencode/.issues/AGENTS.md` Workflow section, `.opencode/skills/spec-creation/tasks/create.md` (Step 3, remote-number-first), and `.opencode/skills/issue-operations-core/tasks/creation.md` (Step 2.1, Remote-First Flow; all three target files verified to exist 2026-09-17 by `ls`/`grep` before being named here): WHEN a remote spec system exists (platform is not local), a remote spec MUST be filed FIRST — with clear intent and context sufficient for a clean-room restart (problem statement, intent, and enough context that any agent can resume without the original conversation) — to reserve the spec number, BEFORE any local spec folder setup is performed; local-first reservation is a violation. Observed live 2026-09-17: a local `.opencode#2450` stub was created before the remote issue existed; the remote then independently assigned 2450 to a different issue, producing a split-brain number collision requiring a local renumber to 2451. Cross-references (not duplicates): numbers-must-match (`.opencode#2403` family), `.counter` drift defect. | string | grep-class assertions over the three named sites for the MUST-be-filed-FIRST reservation language, the clean-room-restart context requirement (problem statement, intent, resumable context), the BEFORE-any-local-setup ordering clause, and the local-first-is-a-violation clause | `.opencode/.issues/AGENTS.md` (Workflow section, line 68); `.opencode/skills/spec-creation/tasks/create.md` (Step 3, line 71); `.opencode/skills/issue-operations-core/tasks/creation.md` (Step 2.1, line 162) — all verified by ls/grep 2026-09-17 |

## 4. Requirements

R-1. `local-issues validate-yaml` SHALL accept `--number <repo>#N` (qualified form, consistent with the tool's number conventions) restricting validation to that issue directory's records.
R-2. Scoped mode SHALL apply the same checks the workspace scan applies — `issue.yaml`, `comments.yaml`, `links.yaml` schema validation via the shared scan machinery, plus the `spec.md` frontmatter check — using the same error-class taxonomy (`invalid-yaml`, `schema-violation`, `malformed-frontmatter`).
R-3. Scoped mode SHALL exit 0 when the target issue's own files are clean regardless of any other issues' record state in the workspace, and SHALL exit 1 only when the target issue's own files have findings.
R-4. Scoped mode SHALL emit `<path>: <error-class>` report lines identical in format to the workspace scan's, restricted to the target issue's files.
R-5. Default invocation with no flags SHALL remain the full workspace scan with unchanged exit-code semantics (0 clean, 1 on any violation anywhere) — the existing maintenance guarantee is preserved.
R-6. The spec-creation analyze task card's R-13 gate SHALL invoke the scoped form `--number <repo>#<issue-under-analysis>` as its progress-gating check, validating the issue the pipeline is about to write.
R-7. The R-13 gate contract language in the spec-creation task cards (`analyze.md` and `create.md`) SHALL state that the workspace-wide scan is a secondary maintenance check and MUST NOT gate pipeline progress on unrelated issues' records.
R-8. Unit tests covering the scoped flag's exit-code semantics (SC-1) and reporting format parity (SC-2) SHALL be added to the tool's existing pytest suite under `.opencode/tests/test_local_issues/`, following its existing fixture and assertion patterns.
R-9. Scoped mode SHALL fail fast when given a number with no issue directory: a clear error naming the missing directory and a non-zero exit code, with no workspace scan performed.
R-10. Scoped mode SHALL reject unqualified bare numbers (e.g. `--number 2450`) per the tool's qualifier enforcement, consistent with every other command's `repo#N` requirement.
R-11. The governing issues-data docs — the `.opencode/.issues/AGENTS.md` workspace guide and the `.issues/`-worktree guidance section of `.opencode/AGENTS.md` that describes repair authority — SHALL state the issues-data hygiene mandate: it is the agent's responsibility to repair, remediate, and revise as needed ALL files in the issues-data branches as needed to prevent problems, and issue-ticket data repairs are authorization-free agent hygiene that do NOT require a spec.
R-12. The governing spec-setup docs/cards — the `.opencode/.issues/AGENTS.md` Workflow section, `.opencode/skills/spec-creation/tasks/create.md` Step 3, and `.opencode/skills/issue-operations-core/tasks/creation.md` Step 2.1 — SHALL state the remote-first spec-number reservation mandate: when a remote spec system exists (platform is not local), a remote spec MUST be filed FIRST, with clear intent and context sufficient for a clean-room restart (problem statement, intent, and enough context that any agent can resume without the original conversation), to reserve the spec number BEFORE any local spec folder setup is performed, and local-first reservation SHALL be stated as a violation.

## 5. Items

### Item 1 (SC-1): Scoped validation mode with scoped exit-code semantics

- RED: pytest test in `.opencode/tests/test_local_issues/` asserting `validate-yaml --number <repo>#N` exits 0 on a clean target issue amid a fixture workspace with violating neighbors, and exits 1 on a violating target. Fails today — the flag does not exist (`validate-yaml --help` accepts zero flags, verified 2026-09-17).
- GREEN: add `--number` to the `validate-yaml` parser in `.opencode/tools/local-issues` (qualified `repo#N` resolution per R-1/R-10); route to the target issue directory via the existing exact-match directory lookup; scan only that directory via the shared scan machinery; apply scoped exit semantics per R-3. Fail fast per R-9 when the directory is absent.
- verify: `uv run pytest .opencode/tests/test_local_issues/` — the new tests pass and the existing suite (including `test_validate_yaml_exit_codes.py`) remains green; no-flag default behavior unchanged.
- commit: tool change plus tests as one working slice.

### Item 2 (SC-2): Reporting format parity between scoped and workspace modes

- RED: pytest test asserting scoped-mode report lines match the `<path>: <error-class>` format and the same error classes the workspace scan emits for identical fixture files. Fails today — no scoped mode exists.
- GREEN: emit scoped findings through the same code path the workspace scan uses (the shared per-directory scan collector), so format parity is structural: scoped output equals the workspace scan's output filtered to the target's paths (R-4).
- verify: pytest; plus a manual cross-check on a fixture comparing scoped output to the filtered workspace output.
- commit: tests plus any emitted-line adjustment as one working slice.
- depends: Item 1 (the flag must exist to report through it).

### Item 3 (SC-3): analyze task card R-13 gate consumes the scoped invocation

- RED: grep-class assertion that `.opencode/skills/spec-creation/tasks/analyze.md` Step 5.3 gates on the unscoped workspace-wide invocation. Passes-as-defect today (the text mandates the unscoped form); after GREEN the assertion asserts the scoped form and the old text is gone.
- GREEN: update Step 5.3 to invoke `validate-yaml --number <repo>#<issue-under-analysis>` as the progress-gating check, validating the issue the pipeline is about to write (R-6); preserve the gate's action-first (R-21) wording and the command+exit-code evidence requirement.
- verify: grep `analyze.md` for the scoped invocation and for absence of the unscoped form as the gating command.
- commit: task card change.
- depends: Item 1 (the flag must exist before the card instructs its use).

### Item 4 (SC-4): R-13 gate contract language updated to scoped gating at all sites

- RED: grep-class assertions that the R-13 gate contract text in `analyze.md` (Step 5.3, exit criteria, result-contract wording) and `create.md` (Step 6.1, exit criteria, result-contract wording) mandates the workspace-wide scan as the gate without a scoped-primary/secondary-maintenance distinction. Fails-as-defect today; after GREEN the assertions assert the updated contract.
- GREEN: update every R-13 gate site in both task cards: the scoped check gates pipeline progress; the workspace-wide scan is a secondary maintenance check that MUST NOT gate pipeline progress on unrelated issues' records (R-7). Keep the BLOCKED-on-target-violations semantics: a scoped exit 1 still blocks the pipeline for the issue being written — only unrelated records lose blocking power.
- verify: grep both cards for the scoped-primary/secondary-maintenance language and the MUST-NOT-gate clause; confirm no contract sentence still requires workspace-wide remediation before pipeline progress.
- commit: task card changes.
- depends: Item 3 (Step 5.3's invocation text is one of the sites; contract wording lands with it).

### Item 5 (SC-5): Issues-data hygiene mandate in the governing issues-data docs

- RED: grep-class assertions that the governing docs lack the hygiene mandate: `.opencode/.issues/AGENTS.md` contains no statement that repairing, remediating, and revising ALL files in the issues-data branches is the agent's responsibility, and no authorization-free/no-spec-required clause for issue-ticket data repairs; the `.issues/`-worktree guidance section of `.opencode/AGENTS.md` likewise lacks both. Passes-as-defect today; after GREEN the assertions assert the mandate is present in both docs.
- GREEN: update both docs to state the mandate (R-11): it is the agent's responsibility to repair, remediate, and revise as needed ALL files in the issues-data branches as needed to prevent problems — issue-ticket data repairs are authorization-free agent hygiene and do NOT require a spec. In `.opencode/.issues/AGENTS.md` the mandate extends the existing Authorization section (which already establishes reading/writing `.issues/` as authorization-free); in `.opencode/AGENTS.md` it lands in the `.issues/` worktree guidance section that governs repair rules for the worktrees. Encode the rationale in the doc text: the observed 374-file legacy schema drift sat unrepaired and blocked pipelines; the developer directive "issue ticket repairs don't require specs" (2026-09-17) made this the agent's standing responsibility.
- verify: grep both docs for the responsibility mandate ("repair, remediate, and revise"), the ALL-files scope, and the authorization-free/no-spec clause.
- commit: doc changes.
- depends: none (disjoint from Items 1-4 — different files, no tool dependency).

### Item 6 (SC-6): Remote-first spec-number reservation mandate reinforced at all governing sites

- RED: grep-class assertions that the three governing sites do not state the full mandate: `.opencode/.issues/AGENTS.md` Workflow section, `.opencode/skills/spec-creation/tasks/create.md` Step 3, and `.opencode/skills/issue-operations-core/tasks/creation.md` Step 2.1 lack (individually or jointly) the remote-filed-FIRST reservation language, the clean-room-restart context requirement, the BEFORE-any-local-setup ordering clause, or the local-first-is-a-violation clause. Passes-as-defect today — the sites carry partial remote-number-first mechanics (creation.md Step 2.1 already orders remote before local) without the reservation intent, the clean-room-restartable-context requirement, or the violation statement; after GREEN the assertions assert the full mandate at all three sites.
- GREEN: update all three sites with the mandate (R-12): when a remote spec system exists (platform is not local), file the remote spec FIRST — with clear intent and context sufficient for a clean-room restart (problem statement, intent, and enough context that any agent can resume without the original conversation) — to reserve the spec number, BEFORE any local spec folder setup is performed; local-first reservation is a violation. Record the observed 2026-09-17 split-brain collision as the motivating defect: a local `.opencode#2450` stub created before the remote issue existed, the remote independently assigning 2450 to a different issue, and the local renumber to 2451 required to repair it. Cross-reference (not duplicate) the numbers-must-match mandate (`.opencode#2403` family) and the `.counter` drift defect.
- verify: grep all three sites for the MUST-be-filed-FIRST language, the clean-room-restart context clause, the BEFORE-local-setup ordering, and the violation clause.
- commit: doc/card changes.
- depends: none (disjoint from Items 1-4; `create.md` Step 3 is a different section than Item 4's Step 6.1 site).

Phases: Phase 1 (tool) = Items 1-2; Phase 2 (gate text) = Items 3-4; Phase 3 (governance docs) = Items 5-6.

## 6. Dependencies

| Reference | Relationship | Status |
|---|---|---|
| `.opencode/tools/local-issues` (`cmd_validate_yaml`, `_scan_issue_dir_errors`, `_schema_problem`, `_find_issue_dir`, error-class constants, `YAML_FILES`) | the tool under modification; the scoped mode extends the existing scan machinery and exact-match directory lookup | satisfied — exists; verified by read 2026-09-17 |
| `.opencode/tests/test_local_issues/test_validate_yaml_exit_codes.py` (and suite siblings) | existing pytest suite whose fixture/assertion patterns the new scoped tests extend | satisfied — exists; verified 2026-09-17 |
| Issue `.opencode#2432` (open, `approved-for-pr`) | prior work that delivered the `validate-yaml` gate, the `repo#N` qualifier enforcement the new flag follows, and the error-class taxonomy — overlap classified PARTIAL-OVERLAP (shared file, different core concern: qualifier/anchoring/parse-hardening vs scoped validation mode); no supersession | satisfied — gate and qualifier machinery in place; verified 2026-09-17 |
| Data-repair leg (completed background) | the 374-file legacy drift this spec's problem statement cites was repaired 2026-09-17 — commit `95488dff` on the `.opencode` issues-data branch plus a companion root-repo commit; both repos' `validate-yaml` exit 0 | satisfied — completed and verified live 2026-09-17 (this revision session); background, not an SC |
| `.opencode/skills/spec-creation/tasks/analyze.md` (Step 5.3) and `.opencode/skills/spec-creation/tasks/create.md` (Step 6.1) | R-13 gate hosts whose text Items 3-4 update | satisfied — exist; verified by grep 2026-09-17 |
| `.opencode/.issues/AGENTS.md` (Authorization and Workflow sections) | issues-data hygiene mandate host (SC-5, R-11) and reservation-mandate host (SC-6, R-12); the issues-data workspace guide | satisfied — exists; verified by ls + grep 2026-09-17 |
| `.opencode/AGENTS.md` (`### .issues/ Is a Worktree — NOT a Regular Directory`, line 216) | hygiene-mandate host (SC-5, R-11); the section describing repair rules for the issues-data worktrees | satisfied — exists; verified by grep 2026-09-17 |
| `.opencode/skills/spec-creation/tasks/create.md` (Step 3, remote-number-first, line 71) | reservation-mandate host (SC-6, R-12) | satisfied — exists; verified by grep 2026-09-17 |
| `.opencode/skills/issue-operations-core/tasks/creation.md` (Step 2.1, Remote-First Flow, line 162) | reservation-mandate host (SC-6, R-12) | satisfied — exists; verified by grep 2026-09-17 |
| Local-first split-brain collision (observed 2026-09-17) | motivating defect for SC-6: a local `.opencode#2450` stub pre-dated the remote issue; the remote assigned 2450 to a different issue; the local record was renumbered to 2451 | observed — recorded in this revision's dispatch context |
| Remote issue [2450](https://github.com/michael-conrad/.opencode/issues/2450) | the original ticket this spec revises; its body records the live 2451 block and the original raw-report baseline | satisfied — read via `gh` 2026-09-17 |
| Developer revision directive 2026-09-17 | authoritative decision: scoped mode decided, dual-format tolerance rejected, repair recorded as background | satisfied — received as this revision's dispatch context |
| Developer revision directive 2026-09-17 (second) | authoritative addition: SC-5 (issues-data hygiene mandate — "issue ticket repairs don't require specs") and SC-6 (remote-first reservation mandate, reinforced after the observed 2450 split-brain collision) | satisfied — received as this revision's dispatch context |
| `.opencode/guidelines/080-code-standards.md` | evidence-type taxonomy governing SC classification (behavioral vs string) | satisfied — exists; consulted 2026-09-17 |

## 7. Traceability

| Requirement | SC(s) | Phase(s) |
|---|---|---|
| R-1 (qualified `--number` flag) | SC-1 | Phase 1 |
| R-2 (same checks + taxonomy) | SC-2 | Phase 1 |
| R-3 (scoped exit-code semantics) | SC-1 | Phase 1 |
| R-4 (report format parity) | SC-2 | Phase 1 |
| R-5 (default stays workspace-wide) | SC-1 | Phase 1 |
| R-6 (analyze gate scoped invocation) | SC-3 | Phase 2 |
| R-7 (contract: scoped-primary, workspace-secondary, MUST NOT gate on unrelated) | SC-4 | Phase 2 |
| R-8 (pytest unit tests added to existing suite) | SC-1, SC-2 | Phase 1 |
| R-9 (fail fast on missing directory) | SC-1 | Phase 1 |
| R-10 (bare-number rejection) | SC-1 | Phase 1 |
| R-11 (issues-data hygiene mandate in governing docs) | SC-5 | Phase 3 |
| R-12 (remote-first reservation mandate in docs/cards) | SC-6 | Phase 3 |

Bidirectional coverage: SC-1 ← R-1, R-3, R-5, R-8, R-9, R-10; SC-2 ← R-2, R-4, R-8; SC-3 ← R-6; SC-4 ← R-7; SC-5 ← R-11; SC-6 ← R-12. Every requirement maps to at least one SC and every SC maps back to at least one requirement.

## 8. Documentation Sources

| Source | Type | Location | Verification |
|---|---|---|---|
| `local-issues` tool source | code | `.opencode/tools/local-issues` (`_schema_problem` ~line 77, `_scan_issue_dir_errors` ~line 112, `cmd_validate_yaml` ~line 143, `YAML_FILES` line 51, error-class constants lines 55-57) | read 2026-09-17 (this revision session) |
| `validate-yaml` CLI surface | code | `./tools/local-issues validate-yaml --help` — accepts zero flags today | executed 2026-09-17 (this revision session) |
| Live workspace state | command output | root repo `validate-yaml` exit 0; submodule `validate-yaml` exit 0 | executed 2026-09-17 (this revision session) — confirms the repair leg's end state |
| Existing scoped-flag test suite | test code | `.opencode/tests/test_local_issues/test_validate_yaml_exit_codes.py`, `test_bare_number_rejection.py`, `test_counter_targeting.py` | `ls` 2026-09-17 (this revision session) |
| R-13 gate site (analyze) | task card | `.opencode/skills/spec-creation/tasks/analyze.md` Step 5.3 (line 82), exit criteria (line 103), result contract (line 114) | grep 2026-09-17 (this revision session) |
| R-13 gate site (create) | task card | `.opencode/skills/spec-creation/tasks/create.md` Step 6.1 (lines 185-191), exit criteria (line 212), result contract (lines 229-230) | grep 2026-09-17 (this revision session) |
| Issues-data workspace guide | doc | `.opencode/.issues/AGENTS.md` — Authorization section (line 157) and Workflow section (line 68) host the SC-5/SC-6 mandates | `ls` + grep of section headers 2026-09-17 (this revision session) |
| `.opencode/AGENTS.md` `.issues/` guidance | doc | `.issues/ Is a Worktree — NOT a Regular Directory` section (line 216) hosts the SC-5 mandate | grep 2026-09-17 (this revision session) |
| Remote-number-first step | task card | `.opencode/skills/spec-creation/tasks/create.md` Step 3 (line 71) hosts the SC-6 mandate | grep 2026-09-17 (this revision session) |
| Remote-First Flow | task card | `.opencode/skills/issue-operations-core/tasks/creation.md` Step 2.1 (line 162) hosts the SC-6 mandate | grep 2026-09-17 (this revision session) |
| Local-first split-brain observation | dispatch context | revision directive 2026-09-17: a local `.opencode#2450` stub was created before the remote issue existed; the remote independently assigned 2450 to a different issue; the local record was renumbered to 2451 | received in this revision's dispatch context |
| Original ticket (deliberation dump) | remote issue | [michael-conrad/.opencode#2450](https://github.com/michael-conrad/.opencode/issues/2450) — records the live 2451 block, the 356-file baseline counts, and raw report paths `tmp/2450/validate-yaml-root-report.txt` / `tmp/2450/validate-yaml-submodule-report.txt` (captured at ticket creation; no longer present in the working tree, verified 2026-09-17) | read via `gh issue view` 2026-09-17 (this revision session) |
| Repair commit | git history | `95488dff` ("auto: sync") on `origin/issues-data` of the `.opencode` issues worktree | `git log` 2026-09-17 (this revision session) |
| Developer revision directive | dispatch context | revision reason received 2026-09-17: solution decided (scoped mode + gate scoping), repair as background, dual-format tolerance rejected, SC sketch with evidence types | received in this revision's dispatch context |
| Developer revision directive (second) | dispatch context | revision reason received 2026-09-17: two additional SCs — issues-data hygiene mandate (SC-A → SC-5) and remote-first reservation mandate (SC-B → SC-6) | received in this revision's dispatch context |
| Evidence-type taxonomy | guideline | `.opencode/guidelines/080-code-standards.md` | read 2026-09-17 (agent system instructions) |
| Spec structure standards | reference doc | `.opencode/reference/spec-structure-standards.md`; `.opencode/reference/cost-model-standards.md` | read 2026-09-17 (this revision session) |

## 9. Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## 10. Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- **SC-1:** Running the scoped-exit-code pytest suite costs minutes of execution time — a bounded delay that surfaces the semantics defect at gate 1. Skipping costs the death-spiral tier: a flag that exits on workspace state instead of target state ships silently, every pipeline block recurs on the next drift, and the rejection→discard→restart cost returns with no test to catch it — the 1000×+ discovery latency.
- **SC-2:** Running the format-parity pytest suite costs minutes. Skipping costs the report's single-dialect guarantee: scoped and workspace modes drift into two formats, every grep-class consumer of the gate output bifurcates, and the divergence surfaces days later as misrouted failure triage — the 100×–1000× tier.
- **SC-3:** Verifying the analyze card's scoped invocation costs one grep — seconds. Skipping costs the observed defect its causal fix: the gate keeps invoking the unscoped form, and the 2451-style block re-manifests on the very next unrelated drift, blocking every spec-creation pipeline — the exact failure this spec exists to prevent.
- **SC-4:** Verifying the contract-language updates costs two greps — seconds. Skipping leaves contract sentences that still mandate workspace-wide remediation before pipeline progress, so an agent reading the cards restores the blocking behavior even with the flag delivered — prose overriding code, discovered only after the next blocked pipeline.
- **SC-5:** Verifying the hygiene mandate costs one grep over two docs — seconds. Skipping leaves repair authority unstated, so the next schema drift sits unrepaired until it blocks a pipeline again — the exact "sat unrepaired and blocked pipelines" failure the developer directive closed; discovery latency reverts from "agent responsibility, prevented early" to "whenever something breaks."
- **SC-6:** Verifying the reservation mandate costs three greps — seconds. Skipping leaves the local-first path unmarked as a violation, and the next agent repeats the 2450-style split-brain collision — a remote number assigned to a different issue, a local renumber, and a spec rewrite to repair, discovered only after the collision has already happened.

## 11. Edge Cases

**Input boundaries:**

- Condition: `--number <repo>#N` where no issue directory `N` exists.
  Expected behavior: fail fast — clear error naming the missing directory, non-zero exit, no workspace scan performed (R-9).
  Resolution: the caller corrects the number; the gate does not silently validate nothing.
- Condition: `--number 2450` (bare, unqualified).
  Expected behavior: rejected with a qualifier error, consistent with every other command's `repo#N` requirement (R-10).
  Resolution: caller supplies the qualified form.
- Condition: the target issue directory exists but contains no YAML files (empty directory).
  Expected behavior: vacuously clean — exit 0 with no report lines, mirroring the workspace scan's skip-missing behavior.
  Resolution: none required; missing files are skipped, not errors (existing shared-machinery semantics).
- Condition: a target YAML file is present but blank.
  Expected behavior: skipped, matching `_scan_issue_dir_errors`' existing blank-content handling.
  Resolution: none required.

**State transitions:**

- Condition: target issue clean, other issues in the workspace violate the schema.
  Expected behavior: scoped mode exits 0 — this is the core semantic the spec delivers (R-3); the workspace-wide default scan still exits 1 for maintenance purposes (R-5).
  Resolution: pipelines proceed; maintenance audit remains available.
- Condition: target issue has violations.
  Expected behavior: scoped mode exits 1 with only the target's `<path>: <error-class>` lines; the pipeline writing that issue still blocks (BLOCKED on target violations is preserved).
  Resolution: remediate the target's records before proceeding.
- Condition: workspace fully clean, target has violations.
  Expected behavior: scoped mode still exits 1 — scoping narrows what is examined, never what counts as a violation.
  Resolution: remediation on the target.

**Failure modes:**

- Condition: legacy-style drift recurs after the completed repair (future bare-list writes).
  Expected behavior: the workspace-wide default scan reports it for maintenance; pipelines are unaffected because the R-13 gate gates on scoped results only (post-Item-3/4); per the SC-5 hygiene mandate, repairing the drift is the agent's authorization-free standing responsibility — no pipeline block, no spec required.
  Resolution: an agent hygiene repair pass, driven by the maintenance audit — never again by a pipeline block.
- Condition: the analyze step's issue number is unavailable or malformed at gate time.
  Expected behavior: the gate fails fast on the malformed qualifier (R-10) rather than silently falling back to the workspace-wide scan — a fallback would silently restore the defect this spec removes.
  Resolution: fix the dispatch context; re-run the gate.
- Condition: a spec pipeline starts local folder setup before the remote spec is filed (platform is not local).
  Expected behavior: the SC-6 reservation mandate marks this as a violation — the remote must be filed first to reserve the number; a local-first stub risks the observed split-brain collision (remote assigns the same number to a different issue).
  Resolution: renumber the local record to match the remotely reserved number (the observed 2450→2451 repair) and file the remote spec first going forward.

**Concurrency:**

- Condition: two pipelines validate different issues concurrently.
  Expected behavior: scoped mode is read-only and per-directory; concurrent invocations on different targets do not interfere.
  Resolution: none required — the tool's read-only guarantee (never mutates files) is preserved.
- Condition: two spec pipelines file remote specs concurrently.
  Expected behavior: remote-first reservation is the number source of record — each pipeline takes its number from the remote create response, so concurrent filings cannot collide (the `.counter`-based local numbering is used only in local-only mode, per the SC-6 mandate and the existing remote-number-first rules).
  Resolution: none required — remote reservation serializes numbering by construction.

**Recovery:**

- Condition: the scoped flag is delivered but a task card still references the unscoped form somewhere the revision missed.
  Expected behavior: the SC-3/SC-4 grep-class assertions cover the enumerated sites; a miss surfaces in the content-verification pass as a FAIL routed to remediation, not as silent drift.
  Resolution: extend the assertion set to the missed site and fix the card text.
- Condition: a governing doc site for the SC-5/SC-6 mandates is missed by the enumerated assertion set.
  Expected behavior: the grep-class assertions cover the verified sites; a missed doc surfaces in the content-verification pass as a FAIL routed to remediation.
  Resolution: extend the assertion set to the missed doc and fix its text — per the SC-5 hygiene mandate, that repair is itself authorization-free.

## 12. Change Control

| Date | Change | Reason | Authorized By |
|---|---|---|---|
| 2026-09-17 | Initial body: bug-report deliberation dump — problem, root cause, three unresolved "Fix Directions (for review)" with the decision deferred to the developer. | Creation (bug report). | Spec-creation pipeline |
| 2026-09-17 | Full restructure into spec-structure-standards format with the solution DECIDED: scoped validation mode (`--number repo#N`, qualified form) with scoped exit-code semantics and format parity (SC-1/SC-2, behavioral pytest); analyze task card R-13 gate scoped invocation (SC-3, string); R-13 gate contract updated to scoped-primary/workspace-secondary MUST-NOT-gate at all sites (SC-4, string). Data-repair leg (old fix direction 1) recorded as completed background — commit `95488dff` + companion root commit, both repos' `validate-yaml` exit 0 verified live. Dual-format tolerance (old fix direction 2) listed in Not Included with rejection rationale. Default workspace-wide scan preserved (R-5). Local record created at `.opencode/.issues/2450/` bound to remote 2450. | Developer directive: the ticket was a bug-report deliberation dump, not a spec with a decided solution; restructuring into a full specification with the agent-resolved structural decision (scoping) per the directive. | Developer (revision directive 2026-09-17) |
| 2026-09-17 | Added SC-5/SC-6 (the directive's SC-A/SC-B) with requirements R-11/R-12 (numbered R-11/R-12 rather than R-13+ to avoid colliding with the external "R-13 gate" identifier used throughout), Items 5-6, Phase 3 (governance docs), traceability rows, cost-frame entries, dependency and documentation-source rows, and two edge cases. SC-5 (string/grep-class): issues-data hygiene mandate — it is the agent's responsibility to repair, remediate, and revise as needed ALL files in the issues-data branches to prevent problems; issue-ticket data repairs are authorization-free agent hygiene, no spec required — stated in `.opencode/.issues/AGENTS.md` and the `.issues/`-worktree guidance section of `.opencode/AGENTS.md` (both verified to exist by ls/grep before being named). SC-6 (string/grep-class): remote-first spec-number reservation mandate — when a remote spec system exists, the remote spec MUST be filed FIRST with clean-room-restartable context (problem statement, intent, resumable context) to reserve the number, BEFORE any local spec folder setup; local-first reservation is a violation — stated in `.opencode/.issues/AGENTS.md` Workflow, `create.md` Step 3, and `creation.md` Step 2.1 (all verified to exist), cross-referencing numbers-must-match (`.opencode#2403` family) and `.counter` drift, with the observed 2450 split-brain collision (local stub pre-dated remote; remote assigned 2450 elsewhere; local renumber to 2451) recorded as the motivating defect. SC-1..SC-4 and R-1..R-10 untouched. | Developer directive 2026-09-17: add two additional success criteria — issue-ticket data repairs are authorization-free agent hygiene (the observed 374-file drift sat unrepaired and blocked pipelines), and the remote-first reservation mandate was ignored (observed live: local-first stub collision requiring renumber to 2451). | Developer (revision directive 2026-09-17) |

---

*Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)*
