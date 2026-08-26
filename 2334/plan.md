---
plan_schema_version: "1.0"
issue: 2334
title: "Built-in glob silent failures — document limitations and remediate broken invocations across agent deck"
authorization_scope: for_pr
pr_strategy: stacked
phase_count: 3
dispatch:
  - test-driven-development
  - verification-before-completion
  - audit
  - finishing-a-development-branch
  - git-workflow-pr
  - completion-core
---

# Implementation Plan — #2334 — Built-in glob silent failures

**Issue:** https://github.com/michael-conrad/.opencode/issues/2334

**Goal:** Document the built-in glob tool's six silent-failure modes in one authoritative anchor section, remediate every fragile invocation site across the agent deck to a working canonical form, and prove the behavior change with a stderr-based behavioral enforcement test through the with-test-home harness.

**Architecture:** Three phases. Phase 1 (SC-1) adds a verified-semantics section to `.opencode/guidelines/060-tool-usage.md` documenting LIM-1 through LIM-6, the canonical path-parameter invocation idiom, and the empty-result disambiguation rule — the single source of truth every remediation site cites via Read-link (definition-lives-once). Phase 2 (SC-2..SC-7) normalizes every concrete invocation-syntax site across sre-runbook, verification-before-completion, the 27-file audit task family (SC-6 Invocation-Site Inventory), and the research-card catalogue instruction; SC-6 commits family-atomic across all inventoried audit files. Phase 3 (SC-8) registers a behavioral enforcement scenario through `with-test-home opencode run` with stderr assertions that an agent emits a working path-parameter invocation action instead of concluding nonexistence from a silent-empty result. The phase DAG is acyclic: phase-1 → phase-2 → phase-3. RB_PATH terminal fallback state is preserved.

**Files:**
- `.opencode/guidelines/060-tool-usage.md` (SC-1)
- `.opencode/skills/sre-runbook/tasks/generate.md` (SC-2, SC-3)
- `.opencode/skills/verification-before-completion/tasks/completion.md` (SC-4)
- `.opencode/skills/verification-before-completion/tasks/collect.md` (SC-5)
- `.opencode/skills/audit/tasks/*.md` — 27-file SC-6 Invocation-Site Inventory (SC-6)
- `.opencode/guidelines/020-go-prohibitions.md` (SC-7)
- `.opencode/tests-v2/behaviors/<scenario>.sh` + `.opencode/tests-v2/test-enforcement.sh` registration (SC-8, new)

**Dispatch:** `test-driven-development`, `verification-before-completion`, `audit`, `finishing-a-development-branch`, `git-workflow-pr`, `completion-core`

---

## Blast Radius

Affected files and impact zones (from `blast-radius.yaml`):

- **Phase 1 (SC-1):** Direct `.opencode/guidelines/060-tool-usage.md`; ripple: `INDEX.md` trigger-pattern row if new section keywords warrant an index update; class NARROW (additive section in one Tier-1 guideline, no existing rule text modified).
- **Phase 2 (SC-2..SC-7):** Direct `generate.md`, `completion.md`, `collect.md`, `.opencode/skills/audit/tasks/*.md` (27 files), `.opencode/guidelines/020-go-prohibitions.md`; ripple to downstream RB_PATH consumers, audit role chains, vbc pipeline stages, and possibly `test-enforcement.sh FILE_SCENARIO_MAP`; class MODERATE (32 direct files deck-wide, edits confined to invocation syntax and guards, zero semantic protocol changes).
- **Phase 3 (SC-8):** Direct new behavioral scenario + test-enforcement.sh registration; class NARROW.
- **Cross-repo impact:** none — all changes land in the `.opencode` submodule; the parent-repo pointer rides alongside the next real parent-repo change per AGENTS.md.

> **Compliance:** All SCs must pass before completion. Partial implementation is not permitted. Each item is daisy-chained — item N's commit is precondition for item N+1's RED.

> **One step at a time.** Execute exactly one step. Report progress. Wait for instruction before the next step.

> **Step status:** Report `[item N] [PASS|FAIL]` after each step. If FAIL, report blocker and halt.

> **Enforcement gate:** All SCs must pass before this plan is complete.

> **Self-Remediation Protocol:** If a step FAILs: diagnose root cause, fix the deliverable, re-verify. If the fix requires spec revision, update the spec and re-enter the plan. Escalate only after remediation failure.

---

## Pre-implementation Steps

- [ ] 1. **Coherence gate (**inline**).** Verify the spec's SCs (SC-1..SC-8), the structure artifact's items (8 items, 3 phases), and the dependency contract are mutually consistent: every SC maps to exactly one item, every item's RED/GREEN/verify/commit steps are in the same phase (triplet colocation), the phase DAG is acyclic (phase_1 → phase_2 → phase_3), and no RED test depends on output from a later phase. If any inconsistency is found, HALT and report before proceeding. **→ all SCs**
- [ ] 2. **Baseline check (**inline**).** Verify the working tree is clean, the feature branch exists, and all affected files are present at their expected paths (060-tool-usage.md, generate.md, completion.md, collect.md, the 27-file audit inventory, 020-go-prohibitions.md). Confirm the RED preconditions: 060-tool-usage.md lacks the section heading; generate.md retains the directory-glob and bare `<RB_PATH>/**` forms; completion.md and collect.md retain the gitignored-target pattern-form cells; the audit inventory still carries f-string/unbracketed/unguarded shapes; 020-go-prohibitions.md lacks explicit path-param phrasing. If the baseline is not met, HALT and report. **→ all SCs**

---

## Phase Table

| Phase | Skill | Task | Target | SCs | Depends On | Step Range | Dispatch |
|-------|-------|------|--------|-----|------------|------------|----------|
| 1 — Glob verified-semantics anchor | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `.opencode/guidelines/060-tool-usage.md` | SC-1 | — | 3–8 | sub-agent / clean-room |
| 2 — Remediate broken invocation sites | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `generate.md`, `completion.md`, `collect.md`, `audit/tasks/*.md` (27), `020-go-prohibitions.md` | SC-2..SC-7 | 1 | 9–39 | sub-agent / clean-room |
| 3 — Behavioral enforcement test | `test-driven-development`, `verification-before-completion` | `red`, `green`, `verify` | `.opencode/tests-v2/behaviors/<scenario>.sh`, `test-enforcement.sh` | SC-8 | 2 | 40–45 | sub-agent / clean-room |

---

## Phase Details

### Phase 1 — Glob verified-semantics anchor documentation

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green, post-regression), `verification-before-completion` (verify) |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/guidelines/060-tool-usage.md` |
| Concern | `tool-semantics-documentation` |
| SCs | SC-1 |
| Depends On | — |

**Context:**
```yaml
files_to_modify:
  - .opencode/guidelines/060-tool-usage.md
sc_ids: [SC-1]
section_heading: "Built-in glob: verified semantics and silent-failure modes"
limitations_documented: [LIM-1, LIM-2, LIM-3, LIM-4, LIM-5, LIM-6]
canonical_idiom: "path-parameter invocation form"
empty_result_rule: "empty-result disambiguation rule"
evidence_type: structural
markdown_tools: [pymarkdownlnt scan, mdformat --check]
```

**Procedure:**
- [ ] 3. **RED — item-1 (SC-1) (**sub-agent**).** Pre-clean stale artifacts: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-red-*`. Write a failing check asserting the "Built-in glob: verified semantics and silent-failure modes" section heading is absent from `.opencode/guidelines/060-tool-usage.md`. Test FAILS because the section does not exist. **→ SC-1**
- [ ] 4. **GREEN — item-1 (SC-1) (**sub-agent**).** Add the verified-semantics section documenting LIM-1 through LIM-6, the canonical path-parameter invocation idiom, and the empty-result disambiguation rule. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-1**
- [ ] 5. **Post-regression — item-1 (**sub-agent**).** Run regression test patterns to confirm the section addition did not alter the guideline hierarchy semantics. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-1**
- [ ] 6. **Verify — item-1 (**clean-room**).** Verify SC-1 against its structural evidence type: grep asserts the section heading and LIM-1..LIM-6 coverage are present; `pymarkdownlnt scan` and `mdformat --check` pass on the file. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1**
- [ ] 7. **COMMIT — item-1 (**inline**).** Commit the guideline section change (test + change together as one atomic slice). `git add .opencode/guidelines/060-tool-usage.md && git commit -m "<SC-1 message>"`. **→ SC-1**
- [ ] 8. **VbC — Phase 1 (**clean-room**).** Verify SC-1 passes its structural check: the section covers LIM-1..LIM-6, the canonical idiom, and the disambiguation rule, and markdown lint/format are clean. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1**

**Cost frame:** Writing and linting the anchor section costs minutes of execution time. Skipping it means every future naive invocation silently re-discovers the failure modes inside production agent runs — a weeks-to-months defect-discovery latency compounded at the structural-tier multiplier (1000×+). Correctness is the only metric.

### Phase 2 — Remediate broken invocation sites across agent deck

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green, post-regression), `verification-before-completion` (verify) |
| Task | `red`, `green`, `verify` |
| Target | generate.md, completion.md, collect.md, audit/tasks/*.md (27), 020-go-prohibitions.md |
| Concern | `runbook-discovery-mechanics`, `verification-evidence-existence`, `audit-invocation-hygiene`, `research-catalogue-instruction-clarity` |
| SCs | SC-2, SC-3, SC-4, SC-5, SC-6, SC-7 |
| Depends On | 1 |

**Context:**
```yaml
sc_ids: [SC-2, SC-3, SC-4, SC-5, SC-6, SC-7]
read_link_citation: "Read [Text](path) pattern to SC-1 section; no inline restatement of semantics"
sc_2_target: ".opencode/skills/sre-runbook/tasks/generate.md runbook-base-path discovery"
sc_3_target: ".opencode/skills/sre-runbook/tasks/generate.md format-matching dual-pattern gate"
sc_4_target: ".opencode/skills/verification-before-completion/tasks/completion.md evidence check"
sc_5_target: ".opencode/skills/verification-before-completion/tasks/collect.md report check"
sc_6_target: ".opencode/skills/audit/tasks/*.md (27 SC-6 inventory files)"
sc_7_target: ".opencode/guidelines/020-go-prohibitions.md research-card catalogue clause"
sc_6_family_atomic: "one TDD slice across all 27 inventoried audit files"
sc_4_sc_5_behavioral: "live-probe against real {project_root}/tmp/<issue>/artifacts/ content"
```

**Procedure (steps 9–46):**

- [ ] 9. **RED — item-2 (SC-2) (**sub-agent**).** Pre-clean stale artifacts: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-red-*`. Write a failing grep test asserting the directory-only runbook-discovery glob pattern is present in `generate.md` runbook-base-path discovery. Test FAILS because the pattern is still there. **→ SC-2**
- [ ] 10. **GREEN — item-2 (SC-2) (**sub-agent**).** Replace the directory-only runbook discovery with a working mechanism (bash find `-type d` fallback or path-parameter glob) whose fallback terminates at `docs/runbooks/`, citing the SC-1 section via Read-link. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-2**
- [ ] 11. **Post-regression — item-2 (**sub-agent**).** Run regression test patterns to confirm the discovery rewrite preserves RB_PATH semantics. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-2**
- [ ] 12. **Verify — item-2 (**clean-room**).** Verify SC-2: grep asserts the directory-glob form is absent and a working mechanism present; live probe the replacement against this repo (no runbooks/ → fallback) and a synthetic fixture dir (match case). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-2**
- [ ] 13. **COMMIT — item-2 (**inline**).** Commit the discovery-mechanism change. `git add .opencode/skills/sre-runbook/tasks/generate.md && git commit -m "<SC-2 message>"`. **→ SC-2**

- [ ] 14. **RED — item-3 (SC-3) (**sub-agent**).** Pre-clean stale artifacts. Write a failing grep test asserting the bare `<RB_PATH>/**` pattern form is present in the generate.md format-matching dual-pattern gate. Test FAILS because the bare pattern is still there. **→ SC-3**
- [ ] 15. **GREEN — item-3 (SC-3) (**sub-agent**).** Rewrite the format-matching dual-pattern gate to path-parameter form with bracketed placeholders, and add an empty-result disambiguation step before any no-existing-runbooks conclusion; preserve both stamp checks. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-3**
- [ ] 16. **Post-regression — item-3 (**sub-agent**).** Run regression test patterns to confirm the gate preserves both stamp checks. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-3**
- [ ] 17. **Verify — item-3 (**clean-room**).** Verify SC-3: grep shows the bare pattern form absent and canonical path-parameter form present; structural review confirms both stamp checks intact. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-3**
- [ ] 18. **COMMIT — item-3 (**inline**).** Commit the format-matching gate rewrite. `git add .opencode/skills/sre-runbook/tasks/generate.md && git commit -m "<SC-3 message>"`. **→ SC-3**

- [ ] 19. **RED — item-4 (SC-4) (**lead**).** Pre-clean stale artifacts. Write a failing check asserting the completion.md evidence-artifact existence check uses a gitignored-target pattern-form glob (cannot see `tmp/` artifacts). Test FAILS because the cell currently cannot reach the gitignored target. **→ SC-4**
- [ ] 20. **GREEN — item-4 (SC-4) (**sub-agent**).** Replace the completion.md evidence-artifact check with an invocation proven to reach `{project_root}/tmp/<issue>/artifacts/` content, citing the SC-1 section via Read-link. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-4**
- [ ] 21. **Post-regression — item-4 (**sub-agent**).** Run regression test patterns to confirm the replacement preserves VERIFICATION-GAP classification semantics. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-4**
- [ ] 22. **Verify — item-4 (**clean-room**).** Verify SC-4 (behavioral via live probe): execute the documented replacement check against real `{project_root}/tmp/<issue>/artifacts/` content and assert detection output is present. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-4**
- [ ] 23. **COMMIT — item-4 (**inline**).** Commit the evidence check remediation. `git add .opencode/skills/verification-before-completion/tasks/completion.md && git commit -m "<SC-4 message>"`. **→ SC-4**

- [ ] 24. **RED — item-5 (SC-5) (**sub-agent**).** Pre-clean stale artifacts. Write a failing check asserting the collect.md report-existence check still contains the pattern-form invocation. Test FAILS because the report-existence cell is un-remediated. **→ SC-5**
- [ ] 25. **GREEN — item-5 (SC-5) (**sub-agent**).** Apply the same working-form remediation as SC-4 to the collect.md report-existence check, preserving MISSING-ELEMENT classification semantics. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-5**
- [ ] 26. **Post-regression — item-5 (**sub-agent**).** Run regression test patterns to confirm the report-existence remediation preserves MISSING-ELEMENT semantics. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-5**
- [ ] 27. **Verify — item-5 (**clean-room**).** Verify SC-5 (behavioral via live probe): execute the same probe as SC-4 against real artifacts content and assert detection works, MISSING-ELEMENT intact. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-5**
- [ ] 28. **COMMIT — item-5 (**inline**).** Commit the report-existence change. `git add .opencode/skills/verification-before-completion/tasks/collect.md && git commit -m "<SC-5 message>"`. **→ SC-5**

- [ ] 29. **RED — item-6 (SC-6) (**sub-agent**).** Pre-clean stale artifacts. Write a failing grep sweep asserting f-string pseudo-syntax or unbracketed placeholder or unguarded listing shapes are present in the inventoried audit task files (count > 0). Test FAILS while any inventoried file retains a fragile shape. **→ SC-6**
- [ ] 30. **GREEN — item-6 (SC-6) (**sub-agent**).** Normalize all 27 inventoried audit files to plain-string path-parameter invocations with bracketed placeholders and empty-result guards wherever a listing feeds downstream logic. This is the family-atomic slice — all 27 files in one TDD slice. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-6**
- [ ] 31. **Post-regression — item-6 (**sub-agent**).** Run regression patterns to confirm role contracts and verdict schemas are unchanged across the audit family. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-6**
- [ ] 32. **Verify — item-6 (**clean**).** Verify SC-6: grep count equals zero for f-string pseudo-syntax, zero for unbracketed placeholders, and guard steps present at listing-fed decision points across the 27 files; spot probe confirms canonical shape. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6**
- [ ] 33. **COMMIT — item-6 (**inline**).** Commit the audit family normalization as one atomic slice across all 27 files. `git add .opencode/skills/audit/tasks/ && git commit -m "<SC-6 message>"`. **→ SC-6**

- [ ] 34. **RED — item-7 (SC-7) (**sub-agent**).** Pre-clean stale artifacts. Write a failing check asserting the research-card catalogue instruction in `020-go-prohibitions.md` lacks an explicit path-parameter invocation form. Test FAILS because the clause is un-specified. **→ SC-7**
- [ ] 35. **GREEN — item-7 (SC-7) (**sub-agent**).** Restate the research-card catalogue instruction to specify the path-parameter invocation form such that literal translation cannot produce a silently-empty call, leaving the confidence-skip logic unchanged. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-7**
- [ ] 36. **Post-regression — item-7 (**sub-agent**).** Run regression patterns to confirm the catalogue protocol clauses (frontmatter grep, confidence skip) are intact. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-7**
- [ ] 37. **Verify — item-7 (**clean**).** Verify SC-7: read-back review asserting explicit path-param phrasing present and catalogue protocol clauses intact. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-7**
- [ ] 38. **COMMIT — item-7 (**inline**).** Commit the catalogue instruction clarification. `git add .opencode/guidelines/020-go-prohibitions.md && git commit -m "<SC-7 message>"`. **→ SC-7**

#### Phase 2 VbC

- [ ] 39. **VbC — Phase 2 (**clean-room**).** Verify SC-2..SC-7 all pass against their evidence types: SC-2 structural, SC-3 structural, SC-4 behavioral (live probe), SC-5 behavioral (live probe), SC-6 structural, SC-7 structural. BLOCK on any FAIL or EVIDENCE_TYPE_MISMATCH. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-2, SC-3, SC-4, SC-5, SC-6, SC-7**

**Cost frame:** Remediating the 27 audit files and four skill/guideline sites costs minutes to a few hours including review. Skipping the family normalization gives 27 independent chances for an auditor sub-agent to proceed on a silent-empty listing — each a corrupted verdict discovered days later, compounding at the structural-tier multiplier (1000×+). Correctness is the only metric.

**Concern transition:** Leaving invocation remediation → entering the behavioral proof. Phase 3 depends on the fully remediated deck from Phase 2.

### Phase 3 — Behavioral enforcement test

| Field | Value |
|-------|-------|
| Skill | `test-driven-development` (red, green), `verification-before-completion` (verify) |
| Task | `red`, `green`, `verify` |
| Target | `.opencode/tests-v2/behaviors/<scenario>.sh` + `.opencode/tests-v2/test-enforcement.sh` registration |
| Concern | `behavioral-enforcement` |
| SCs | SC-8 |
| Depends On | 2 |

**Context:**
```yaml
sc_ids: [SC-8]
test_scenario: ".opencode/tests-v2/behaviors/<scenario>.sh (new)"
registration: ".opencode/tests-v2/test-enforcement.sh FILE_SCENARIO_MAP entry"
prompt: "ask the agent to enumerate files under .opencode/"
evidence: "stderr assertion helpers assert path-param-form glob action present; absence of a silent-empty nonexistence conclusion"
harness: "bash .opencode/tests-v2/with-test-home opencode run '<enumeration prompt>'"
timeout: ">=600000ms bash-tool timeout; no GNU timeout"
```

**Procedure:**

- [ ] 40. **RED — item-8 (SC-8) (**sub-agent**).** Pre-clean stale artifacts: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-red-*`. Write a failing behavioral enforcement scenario (new `<scenario>.sh` + test-enforcement.sh registration) asserting the agent emits a working path-parameter invocation action. The scenario FAILS against the pre-change deck (agent emits naive pattern-from-root call then concludes absence). **→ SC-8**
- [ ] 41. **GREEN — item-8 (SC-8) (**sub-agent**).** Make the scenario pass against the remediated deck by running `bash .opencode/tests-v2/with-test-home opencode run '<enumeration prompt>'` and asserting the stderr shows a path-parameter-form invocation action (no silent-empty nonexistence conclusion). Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-8**
- [ ] 42. **Post-regression — item-8 (**sub-agent**).** Run regression test patterns to confirm the new scenario does not regress the enforcement suite. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-8**
- [ ] 43. **Verify — item-8 (**clean-room**).** Verify SC-8 (behavioral): full `with-test-home opencode run` with stderr assertion helpers, Bash tool timeout >= 600000ms, no GNU timeout. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-8**
- [ ] 44. **COMMIT — item-8 (**inline**).** Commit the behavioral scenario plus its test-enforcement.sh registration as one atomic slice. `git add .opencode/tests-v2/behaviors/<scenario>.sh .opencode/tests-v2/test-enforcement.sh && git commit -m "<SC-8 message>"`. **→ SC-8**
- [ ] 45. **VbC — Phase 3 (**clean-room**).** Verify SC-8 passes its behavioral check: the scenario runs clean under the with-test-home harness with stderr assertions proving the agent emits a working invocation action instead of a false nonexistence conclusion. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-8**

**Cost frame:** Running the behavioral scenario costs minutes of model time. Skipping it starts the full death spiral — seven structural PASSes while the runtime defect ships unchanged, discovered only when an agent concludes real files do not exist, at a 1000× multiplier. Correctness is the only metric.

---

## Post-implementation Steps

- [ ] 46. **audit (**sub-agent**).** Run the adversarial audit of the deliverable via the DiMo 4-role chain (investigator, validator, evaluator, arbiter). **→ all SCs**
  - Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence
  - Context: all SC verdicts, evidence artifacts
- [ ] 47. **z3-check (**inline**).** Run the Z3 constraint solver verification against the dependency contract. **→ all SCs**
  - Command: `.opencode/tools/solve check --state-path ... --contract-path ...`
- [ ] 48. **structural-checks (**sub-agent**).** Run the finishing checklist (lint, typecheck, format) on all modified files. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`
  - Context: all modified files
- [ ] 49. **pre-pr-gate (**sub-agent**).** Verify all SC verdicts; BLOCK if any FAIL. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`
  - Context: all SC verdicts
- [ ] 50. **regression-check (**sub-agent**).** Run the final regression check before PR. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`
  - Context: all SCs, final regression
- [ ] 51. **review-prep (**sub-agent**).** Prepare the PR review context. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`
  - Context: all SCs, PR scope
- [ ] 52. **create-pr (**sub-agent**).** Create the pull request. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute create task from git-workflow-pr")`
  - Context: all SCs, PR scope
- [ ] 53. **exec-summary (**sub-agent**).** Generate the completion executive summary. **→ all SCs**
  - Dispatch: `task(..., prompt: "execute completion task from completion-core")`
  - Context: all SCs, PR status

---

## Exit Criteria

- [ ] C1. `.opencode/guidelines/060-tool-usage.md` contains the "Built-in glob: verified semantics and silent-failure modes" section covering LIM-1..LIM-6, the canonical path-parameter idiom, and the empty-result disambiguation rule (SC-1).
- [ ] C2. The sre-runbook generate.md runbook-base-path discovery uses a working mechanism (no directory-only glob), citing SC-1, with the fallback terminating at `docs/runbooks/` (SC-2).
- [ ] C3. The sre-runbook generate.md format-matching gate uses path-parameter form with bracketed placeholders plus an empty-result disambiguation step, preserving both stamp checks (SC-3).
- [ ] C4. The verification-before-completion completion.md evidence-artifact check reaches gitignored `tmp/` content, citing SC-1 (SC-4).
- [ ] C5. The verification-before-completion collect.md report-existence check uses the same working form, preserving MISSING-ELEMENT classification (SC-5).
- [ ] C6. All 27 audit task files use plain-string path-parameter invocations with bracketed placeholders and empty-result guards; role contracts unchanged (SC-6).
- [ ] C7. The research-card catalogue instruction in 020-go-prohibitions.md specifies the path-parameter form; confidence-skip logic unchanged (SC-7).
- [ ] C8. A registered behavioral enforcement test proves via stderr assertions that an agent instructed to enumerate files under `.opencode/` emits a working invocation action instead of concluding nonexistence (SC-8).
- [ ] C9. All SCs pass the verification gate; the plan is complete with no partial implementation.

---

*Co-authored with AI: OpenCode (deepseek-v4-flash)*
## Lifecycle Events

| Timestamp | Event | Details |
|-----------|-------|---------|
| 2026-08-26 | `plan_created` | Plan file: `.opencode/.issues/2334/plan.md`, phase count: 3 |
