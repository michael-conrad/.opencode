# Implementation Plan — [#1726](https://github.com/michael-conrad/.opencode/issues/1726) — Remove Dead yaml+symbolic Blocks from Guidelines

- **Goal:** Remove all `yaml+symbolic` code fence blocks from 30 guideline files in `.opencode/guidelines/`, leaving prose and frontmatter untouched.
- **Architecture:** Single concern — dead code removal. No runtime behavior changes. All SCs are `string` type (grep-based verification). Two sequential phases: removal then verification.
- **Files:** `.opencode/guidelines/*.md` (30 files with `yaml+symbolic` blocks; 3 excluded files + INDEX.md have none)

> **⚠️ Compliance Requirement — All Steps Mandatory**
>
> Every step in this plan is mandatory. Skipping, combining, optimizing out, or performing inline work that should be delegated to a sub-agent produces defective deliverables. Each step dispatches to a clean-room sub-agent via `task()` for independent execution. The orchestrator routes each step — it does not inline pipeline work.

> **⚠️ One-Step-at-a-Time Protocol**
>
> Execute steps sequentially. No parallel dispatch of chain-dependent steps. Each step's output is the next step's input. The "sub-agent dispatch implies independence" rationalization is explicitly prohibited.

> **⚠️ Step Status Tracking**
>
> Maintain `todowrite` lifecycle throughout execution: CREATE with status on entry, UPDATE on transition, CLEAR before HALT. Track `pipeline_phase` after each step.

## Phase Table

| Phase | Name | Concern | SCs | Dependencies | Steps |
|-------|------|---------|-----|--------------|-------|
| 1 | Remove yaml+symbolic blocks | Delete trailing `yaml+symbolic` code fence blocks from 30 guideline files | SC-1, SC-2, SC-3, SC-4 | None | 1–30 |
| 2 | Verify | Confirm all blocks removed, prose and frontmatter intact | SC-1, SC-2, SC-3, SC-4 | Phase 1 | 31–33 |

> **⚠️ Compliance Requirement — All Steps Mandatory**
>
> Every step in this plan is mandatory. Skipping, combining, or reordering steps produces defective deliverables. This is non-waivable — no exception for any reason.

> **⚠️ Self-Remediation Protocol**
>
> If a step fails, remediate before proceeding. FAIL is a hard gate — never reclassify, never soft-pass. Remediate → re-verify → proceed. HALT only on double-failure.

## Exit Criteria

- [ ] C1: No `yaml+symbolic` code blocks remain in any guideline file (`grep -r 'yaml+symbolic' guidelines/` returns zero)
- [ ] C2: All 30 files have their trailing YAML block removed (each file's last 10 lines contain no `yaml+symbolic` fence)
- [ ] C3: Prose content of every guideline file is unchanged (diff shows only deletions of YAML blocks)
- [ ] C4: Frontmatter (`---` delimited YAML at file top) is preserved in all files
- [ ] C5: All implementation-pipeline gate steps are enumerated in the plan
- [ ] C6: Plan committed to feature branch and cross-referenced in spec issue
