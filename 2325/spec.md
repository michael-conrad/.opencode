> **Full spec and artifacts: [`.opencode/.issues/2325/`](https://github.com/michael-conrad/.opencode/tree/issues-data/.issues/2325/)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2325/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# SPEC-FIX: Built-in glob silent failures — document limitations and remediate broken invocations across agent deck

## Intent and Executive Summary

**Problem Statement:** The agent deck instructs agents to invoke the built-in glob tool in shapes that empirically cannot succeed at 4 sites and can silently mislead at 28 more — the 27 audit-family files enumerated in the SC-6 Invocation-Site Inventory plus the research-card catalogue clause — for 32 fragile invocation locations total, all counted by the reproducible method specified in this spec, while zero documentation of the tool's failure modes exists anywhere under `.opencode/**/*.md`. Live probing this session reproduced all six failure modes: hidden-directory traversal skip, gitignore filtering during traversal, silent-empty conflation of five distinct causes behind one "No files found" output, files-only matching that makes directory patterns structurally unmatchable, absolute-pattern rejection, and an opaque error for nonexistent path parameters.

**Root Cause / Motivation:** Deck authors wrote glob invocations assuming find-like traversal semantics. The built-in tool silently skips dot-prefixed and gitignored directories during pattern-from-CWD scanning and returns one identical output for every failure cause, so defective invocation shapes pass unnoticed until an agent acts on a false empty result. The entire agent deck lives under `.opencode/` — the worst possible location for this defect class — and every session that loads the deck propagates either the defect or the fix. Fixing now stops the compounding.

**Approach Chosen:** Three phases anchored on one documentation source of truth. Phase 1 adds a verified-semantics section to `.opencode/guidelines/060-tool-usage.md` covering all six limitations (LIM-1 through LIM-6), the canonical path-parameter invocation idiom, and the empty-result disambiguation rule. Phase 2 remediates all concrete invocation-syntax sites across sre-runbook, verification-before-completion, the audit task family (27 files — the complete SC-6 Invocation-Site Inventory), and the research-card catalogue instruction — each site citing the Phase 1 anchor via Read-link rather than restating semantics inline. Phase 3 proves the behavior change with a stderr-based behavioral enforcement test through the with-test-home harness.

**Alternatives Considered & Why Discarded:**
1. Standalone guideline file for glob limitations — rejected: `060-tool-usage.md` already owns built-in-tool hierarchy and loads via the instructions array; a new file adds INDEX churn and splits one concern across two Tier-1 files.
2. Wholesale replacement of glob with bash find/ls across the deck — rejected: glob remains the Tier-1 primary search tool; the defect is confined to specific invocation shapes, not the tool choice.
3. Platform-side fix to the glob implementation — rejected: the platform binary is outside this repository's control.
4. Structural-only verification without a behavioral test — rejected: guideline/skill changes mandate behavioral enforcement tests; structural-only evidence starts the death spiral defined in `cost-model-standards.md`.

**Key Design Decisions:**
1. Definition-lives-once: the disambiguation rule and canonical idiom are defined only in the SC-1 section; every remediated site cites it via Read-link. Tradeoff: single source of truth versus per-site context locality.
2. Behavioral test last (SC-8): one opencode-run scenario exercises the fully remediated deck after all fixes land. Tradeoff: later partial signal versus complete coverage of fix interactions.
3. Family-atomic commit for SC-6: all 27 inventoried audit files normalize in one TDD slice. Tradeoff: consistent family state versus finer-grained rollback granularity.
4. RB_PATH contract preserved: the discovery mechanism changes; the terminal fallback state does not. Tradeoff: downstream consumer stability versus a simpler rewrite.

**User Intent / Original Prompt:** Issue `.opencode#2325`, title only (body empty, no comments): "[SPEC-FIX] Built-in glob silent failures - document limitations and remediate broken invocations across agent deck".

## Not Included

- **Platform glob tool implementation** — outside repository control; remediation is documentation plus invocation fixes only.
- **Wholesale glob-to-find replacement across the deck** — glob remains Tier-1 primary; only broken shapes change.
- **tests-v2 shell scripts' internal rg/find usage** — harness scripts are not agent-facing instruction text.
- **AGENTS.md forbidden-patterns table entry (`glob(pattern='.issues/**/*.md')`)** — intentional anti-example documenting a prohibited pattern; altering it would erase the prohibition record.
- **Parent-repo files** — all changes land in the `.opencode` submodule; the parent pointer rides alongside the next real parent-repo change per AGENTS.md.

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|----------------------|
| SC-1 | `.opencode/guidelines/060-tool-usage.md` contains a "Built-in glob: verified semantics and silent-failure modes" section documenting LIM-1 through LIM-6, the canonical path-parameter invocation idiom, and the empty-result disambiguation rule | structural | grep assertions for section heading and LIM coverage; `pymarkdownlnt scan` + `mdformat --check` on the file | pre-spec-inspection.yaml `tool_semantics_verified`; `.opencode/guidelines/060-tool-usage.md` |
| SC-2 | The sre-runbook generate.md runbook-base-path discovery segment contains no directory-only glob pattern and uses a working discovery mechanism whose fallback terminates at docs/runbooks/, citing the SC-1 section via Read-link | structural | grep asserts directory-glob form absent and working mechanism present; live probe of replacement against this repo (no runbooks dir → fallback case) and a synthetic fixture dir (match case) | pre-spec-inspection.yaml `broken_invocations`; `.opencode/skills/sre-runbook/tasks/generate.md` |
| SC-3 | The sre-runbook generate.md format-matching dual-pattern gate uses path-parameter form with bracketed placeholders and an empty-result disambiguation step before any no-existing-runbooks conclusion, preserving both stamp checks | structural | grep shows bare `<RB_PATH>/**` pattern form absent; structural review confirms dual-pattern mandate intact | pre-spec-inspection.yaml; state-analysis.yaml `sc_3_format_matching_gate` |
| SC-4 | The verification-before-completion completion.md evidence-artifact existence check invokes a form that detects files under gitignored tmp/ artifact directories, citing the SC-1 section | behavioral | execute the documented check against real `{project_root}/tmp/<issue>/artifacts/` content and assert detection output present | pre-spec-inspection.yaml LIM-2 probes; `.opencode/skills/verification-before-completion/tasks/completion.md` |
| SC-5 | The verification-before-completion collect.md report-existence check receives the same working-form remediation as SC-4, preserving MISSING-ELEMENT classification semantics | behavioral | same execution procedure as SC-4 against real artifacts content | pre-spec-inspection.yaml; state-analysis.yaml `sc_4_sc_5_evidence_existence` |
| SC-6 | All 27 audit task files enumerated in the SC-6 Invocation-Site Inventory use plain-string path-parameter invocations with bracketed placeholders and contain an empty-result guard wherever a directory listing feeds downstream logic; role contracts unchanged | structural | grep sweep across the inventoried audit task files asserting f-string pseudo-syntax count equals zero, unbracketed placeholder count equals zero, and guard steps present at listing-fed decision points | pre-spec-inspection.yaml `fragile_invocations`; concern-map.yaml `audit-invocation-hygiene`; SC-6 Invocation-Site Inventory (below) |
| SC-7 | The research-card catalogue instruction in `.opencode/guidelines/020-go-prohibitions.md` specifies the path-parameter invocation form such that literal translation cannot produce a silently-empty call, leaving confidence-skip logic unchanged | structural | read-back review asserting explicit path-param phrasing present and catalogue protocol clauses intact | pre-spec-inspection.yaml `fragile_invocations` final entry; `.opencode/guidelines/020-go-prohibitions.md` |
| SC-8 | A registered behavioral enforcement test demonstrates via stderr assertions that an agent instructed to enumerate files under .opencode/ emits a working invocation action instead of concluding nonexistence from a silent-empty result | behavioral | `bash .opencode/tests-v2/with-test-home opencode run '<enumeration prompt>'`; stderr assertion helpers on captured actions; >=600000ms bash-tool timeout, no GNU timeout | testability-assessment.yaml `phase_3_sc_8`; tests-v2 framework requirements |

### SC-6 Invocation-Site Inventory and Counting Method

The audit-family file set for SC-6 is defined by reproducible enumeration, not ad-hoc inspection. Both methods below were executed this session against this repository and return the same file set.

**Method M-1 (invocation-shape match — primary).** Files carrying either fragile invocation shape:

```bash
rg -il 'glob `[^`]+` in `' .opencode/skills/audit/tasks/ | sort
rg -l 'path=f"<' .opencode/skills/audit/tasks/ | sort
```

Shape 1 matches directory-scoped listing instructions of the form "glob `<pattern>` in `<target>`" that lack the canonical path-parameter form and an empty-result guard — this captures both the `spec_local_dir` verification lines (24 files) and the coherence-maintenance baseline-artifact listing lines (2 files). Shape 2 matches f-string pseudo-syntax path parameters subject to literal copying (4 concern-separation files, all already inside shape 1). Union: **26 files**.

**Method M-2 (co-occurrence cross-check).**

```bash
comm -12 <(rg -l 'glob' .opencode/skills/audit/tasks/ | sort) \
         <(rg -l 'spec_local_dir' .opencode/skills/audit/tasks/ | sort)
```

Returns exactly the same 26-file set (`diff` of the two outputs is empty), confirming set equality through two independent predicates before any semantic interpretation is applied.

**Carried-over site.** `content-audit-investigator.md` was present in the original inspection inventory (per-directory listing iteration plus unguarded existence checks, including its error-table rule that treats an empty glob result as ordinary data rather than a blocked state). It matches neither M-1 pattern but remains in scope: removing it would narrow the spec without a finding mandating that. Total inventory: **27 files**.

**Complete file list (27):**

```text
.opencode/skills/audit/tasks/coherence-maintenance-investigator.md
.opencode/skills/audit/tasks/coherence-maintenance-validator.md
.opencode/skills/audit/tasks/concern-separation-arbiter.md
.opencode/skills/audit/tasks/concern-separation-evaluator.md
.opencode/skills/audit/tasks/concern-separation-investigator.md
.opencode/skills/audit/tasks/concern-separation-validator.md
.opencode/skills/audit/tasks/content-audit-investigator.md
.opencode/skills/audit/tasks/drift-detection-arbiter.md
.opencode/skills/audit/tasks/drift-detection-evaluator.md
.opencode/skills/audit/tasks/drift-detection-investigator.md
.opencode/skills/audit/tasks/drift-detection-validator.md
.opencode/skills/audit/tasks/plan-fidelity-arbiter.md
.opencode/skills/audit/tasks/plan-fidelity-evaluator.md
.opencode/skills/audit/tasks/plan-fidelity-investigator.md
.opencode/skills/audit/tasks/plan-fidelity-validator.md
.opencode/skills/audit/tasks/spec-audit-arbiter.md
.opencode/skills/audit/tasks/spec-audit-evaluator.md
.opencode/skills/audit/tasks/spec-audit-investigator.md
.opencode/skills/audit/tasks/spec-audit-validator.md
.opencode/skills/audit/tasks/test-quality-audit-arbiter.md
.opencode/skills/audit/tasks/test-quality-audit-evaluator.md
.opencode/skills/audit/tasks/test-quality-audit-investigator.md
.opencode/skills/audit/tasks/test-quality-audit-validator.md
.opencode/skills/audit/tasks/verification-audit-arbiter.md
.opencode/skills/audit/tasks/verification-audit-evaluator.md
.opencode/skills/audit/tasks/verification-audit-investigator.md
.opencode/skills/audit/tasks/verification-audit-validator.md
```

**Explicitly not counted** so that re-enumerations reconcile to this section: bare tool-menu mentions ("use `glob` or `read` to confirm"), guideline-audit pattern-expansion prose, intentional anti-examples, tests-v2 harness scripts, and non-audit broken sites (enumerated individually by SC-2, SC-3, SC-4, SC-5, and SC-7).

## Requirements

R-1. `060-tool-usage.md` SHALL contain the verified-semantics section covering LIM-1 through LIM-6, the canonical invocation idiom, and the disambiguation rule.

R-2. The sre-runbook generation task card SHALL replace its directory-only runbook-discovery glob with a working mechanism that cites the SC-1 guidance via Read-link.

R-3. The sre-runbook format-matching gate SHALL use canonical invocation form with bracketed placeholders and SHALL gate any absence conclusion behind an explicit empty-result disambiguation step.

R-4. The completion task card SHALL verify evidence-artifact presence via an invocation that reaches gitignored tmp/ targets.

R-5. The collect task card SHALL verify report existence via the same working invocation form as R-4.

R-6. All 27 audit task files enumerated in the SC-6 Invocation-Site Inventory SHALL normalize to canonical invocation shape and SHALL contain an empty-result guard wherever a listing feeds downstream logic.

R-7. The research-card catalogue instruction SHALL specify the path-parameter form unambiguously.

R-8. A behavioral enforcement test SHALL demonstrate the remediated invocation behavior end-to-end through the with-test-home harness.

R-9. Every changed agent-facing text block SHALL follow Read-link cross-reference style, triple co-application of reference cards 250/255/257, and 080-code-standards numbering rules.

The per-SC decomposition constraint binds structurally: each SC maps to exactly one item and one RED/GREEN/verify/commit cycle.

## Items

### Item 1 (SC-1): Guideline anchor section in 060-tool-usage.md

- RED: grep for the section heading in 060-tool-usage.md fails
- GREEN: add the verified-semantics section documenting LIM-1 through LIM-6, the canonical idiom, and the disambiguation rule
- verify: grep coverage assertions plus pymarkdownlnt scan plus mdformat --check
- commit: one slice — guideline file only

### Item 2 (SC-2): Runbook discovery mechanism in generate.md

- RED: grep finds the directory-only runbooks pattern in generate.md
- GREEN: replace discovery with a working mechanism (bash find -type d fallback or path-param glob) citing SC-1 via Read-link
- verify: grep asserts old form absent plus manual probe of the new mechanism in fallback and match cases
- commit: one slice

### Item 3 (SC-3): Format-matching gate hardening in generate.md

- RED: grep shows the bare RB_PATH-prefixed recursive pattern form present
- GREEN: rewrite to path-parameter form with bracketed placeholders plus the disambiguation step
- verify: grep plus structural review confirming both stamp checks preserved
- commit: one slice

### Item 4 (SC-4): Evidence-artifact check in vbc completion.md

- RED: the tool-call cell contains a gitignored-target pattern-form glob
- GREEN: replace with an invocation proven to reach tmp/ content, citing SC-1
- verify: execute the replacement against the real artifacts directory and assert detection
- commit: one slice

### Item 5 (SC-5): Report-existence check in vbc collect.md

- RED/GREEN/verify/commit: same structure as Item 4

### Item 6 (SC-6): Audit family invocation normalization

- RED: grep counts files matching f-string or unguarded shapes greater than zero across the inventory
- GREEN: normalize all 27 inventoried files to canonical shape with guards
- verify: grep count equals zero across the inventory plus spot probe
- commit: one slice — family atomically

### Item 7 (SC-7): Research-catalogue instruction clarity in 020-go-prohibitions.md

- RED: the text lacks an explicit path-parameter form
- GREEN: restate the instruction specifying the form
- verify: structural read-back review confirming catalogue clauses intact
- commit: one slice

### Item 8 (SC-8): Behavioral enforcement scenario

- RED: scenario run against the pre-change deck fails the invocation-action assertion
- GREEN: scenario passes post-change
- verify: full behavioral run under with-test-home with stderr assertions
- commit: scenario script plus registration in one slice

## Dependencies

| Reference | Relationship | Status |
|-----------|--------------|--------|
| Analysis artifacts (pre-spec-inspection, requirements, decomposition, 7 analytical artifacts) | empirical grounding consulted during implementation | copied to `.opencode/.issues/2325/artifacts/` |
| `spec-structure-standards.md`, `cost-model-standards.md` | read via Read-link during creation | loaded this session |
| Reference cards 250/255/257 | MUST be loaded before authoring any changed agent-facing text | required at implementation time |
| tests-v2 harness (with-test-home wrapper, test-enforcement.sh registration conventions) | hosts the SC-8 scenario | existing infrastructure |
| `060-tool-usage.md` current hierarchy content | anchor file the SC-1 section extends | exists in repository |

## Traceability

| Requirement | SC(s) | Phase(s) |
|-------------|-------|----------|
| R-1 | SC-1 | Phase 1 |
| R-2 | SC-2 | Phase 2 |
| R-3 | SC-3 | Phase 2 |
| R-4 | SC-4 | Phase 2 |
| R-5 | SC-5 | Phase 2 |
| R-6 | SC-6 | Phase 2 |
| R-7 | SC-7 | Phase 2 |
| R-8 | SC-8 | Phase 3 |
| R-9 | SC-1 through SC-8 | Phases 1-3 |

Every requirement traces to at least one SC; every SC traces to at least one requirement; the Items enumeration enforces the one-item-per-SC mapping.

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|--------------|
| Live glob probes (14 invocations, all reproduced) | code behavior | pre-spec-inspection.yaml `tool_semantics_verified` | executed this session against this repository |
| Tool hierarchy ownership | doc | `.opencode/guidelines/060-tool-usage.md` | read this session |
| Broken invocation sites | code | sre-runbook generate.md; verification-before-completion completion.md and collect.md | grep inventory + read |
| Fragile invocation family | code | `.opencode/skills/audit/tasks/*.md` (27 files — complete list and counting method in SC-6 Invocation-Site Inventory) | M-1/M-2 commands executed this session; set equality verified |
| Catalogue prose site | doc | `.opencode/guidelines/020-go-prohibitions.md` | read this session |
| Spec structure standard | doc | `.opencode/reference/spec-structure-standards.md` | read this session |
| Cost model standard | doc | `.opencode/reference/cost-model-standards.md` | read this session |

## Enforcement Gate

> **Enforcement gate:** All success criteria MUST pass before this spec is considered complete. Partial implementation is not permitted.

## Cost Frame

Cost is measured in defect-discovery-latency, not tool calls. Correctness is the only metric.

- SC-1: writing and linting the section costs minutes. Skipping costs weeks-to-months — every future naive invocation silently re-discovers the failure modes inside production agent runs, compounding at the structural-tier multiplier from `cost-model-standards.md`.
- SC-2: greping and probing the discovery rewrite costs minutes. Skipping costs a permanently dead discovery branch masquerading as a working fallback — diagnosed only when someone asks why every generated runbook lands in docs/runbooks/.
- SC-3: rewriting the gate costs minutes. Skipping costs false no-proven-format conclusions — a wrong-format runbook ships and every downstream reader pays.
- SC-4: executing the existence probe costs seconds. Skipping costs false VERIFICATION-GAP classifications — evidence declared missing that exists — triggering rework loops in every completion claim.
- SC-5: the same bounded probe cost as SC-4. Skipping costs the same false-MISSING-ELEMENT spiral from the staleness side.
- SC-6: normalizing 27 files costs a few hours including review. Skipping costs 27 independent chances for an auditor sub-agent to proceed on a silent-empty listing — each instance a corrupted verdict discovered days later.
- SC-7: restating one instruction clause costs minutes. Skipping costs a research dispatch that scans nothing and reports an empty catalogue — cached as a false gap by future sessions.
- SC-8: running the behavioral scenario costs minutes of model time. Skipping costs the full death spiral — seven structural PASSes while the runtime defect ships unchanged, discovered only when an agent concludes real files do not exist.

## Edge Cases

Input boundaries:

1. Condition: a remediated invocation returns an empty result. Expected behavior: the agent executes the disambiguation step before concluding absence. Resolution: the rule is defined once in the SC-1 section and cited via Read-link at each application site.
2. Condition: the target directory legitimately contains zero matching files. Expected behavior: disambiguation distinguishes true-empty from invocation-fault; the empty-list path proceeds only after confirmation. Resolution: the SC-6 guard step.

State transitions:

3. Condition: a repository contains no runbooks directory. Expected behavior: discovery terminates at the docs/runbooks/ fallback terminal state exactly as before the change. Resolution: invariant preserved by SC-2.

Failure modes:

4. Condition: a placeholder expands to a nonexistent directory during an audit listing. Expected behavior: the empty-result guard routes to a blocked-note state instead of proceeding on an empty list. Resolution: SC-6.
5. Condition: RB_PATH resolves to an absolute path string. Expected behavior: format-matching still functions because the invocation uses the path-parameter form. Resolution: SC-3 eliminates the absolute-pattern rejection exposure.

Concurrency:

6. Condition: multiple agents edit different audit task files simultaneously. Expected behavior: the single-slice family commit keeps the set consistent; untouched role contracts prevent semantic merge conflicts. Resolution: Item 6 commit scope.

Recovery:

7. Condition: an SC fails its verification step mid-phase. Expected behavior: work halts at that SC; checkpoint rollback applies per the Checkpoint Rollback Exception; re-dispatch follows from work state. Resolution: per-item commit isolation enables scoped rollback without discarding sibling SCs.
8. Condition: the behavioral harness times out or encounters lock contention. Expected behavior: framework discipline applies — >=600000ms timeout, no GNU timeout, stale-lock removal before reruns, post-timeout SQLite export. Resolution: tests-v2 AGENTS.md procedures govern recovery.

## Change Control

| Date | Change | Trigger | Authorization |
|------|--------|---------|---------------|
| 2026-08-26 | SC-6, R-6, Item 6, Key Design Decision 3, Cost Frame, and Documentation Sources updated from an incomplete 13-file audit inventory to the complete verified 27-file list; new "SC-6 Invocation-Site Inventory and Counting Method" section added with reproducible commands (M-1 shape match, M-2 co-occurrence cross-check), semantics, exclusions, and full file list; Problem Statement totals reconciled to 4 cannot-succeed sites + 28 silently-mislead locations = 32 fragile locations; Approach Chosen Phase 2 count synced | Validation findings: aggregate FAIL on internal_consistency, completeness, provenance, and correctness — root defect: invocation-site inventory wrong. Live enumeration found 26 identical-instruction carriers where SC-6 claimed 13; preamble arithmetic (4+15=19) reconciled with neither artifact inventory nor live deck; concern-map files scope and blast-radius file counts contradicted the enumeration | Validator-mandated remediation path via spec-creation revise dispatch (.opencode#2325 re-validation round) |

Artifacts synced in the same revision: `concern-map.yaml` (`audit-invocation-hygiene` files scope enumerated to the 27-file list), `blast-radius.yaml` (phase-2 direct counts and rationale reconciled to the inventory), `sc-summary.yaml` (SC-6 description synced to 27 files). Task-card Step 7 (mass artifact deletion) was intentionally NOT executed: the validation findings mandate syncing named artifacts for re-validation, so stale-count artifacts were preserved as historical evidence and superseded by the counting method now embedded in this spec.

Remote exec-summary regeneration (task Step 5) skipped with cause: no GitHub issue corresponds to this local `.opencode#2325` spec (verified via repository issue listing and title search, 2026-08-26). The remote object numbered `#2325` in `michael-conrad/.opencode` is a pull request for the local `#2320` submodule-pointer guidance work; an initial targeted update hit that PR by mistake and was fully reverted within the session (body restored byte-exact, 2125 chars, verified via REST read-back against the PR's user-content-edit history). Per the `.issues/` workspace doctrine the local spec remains authoritative; creating a brand-new remote issue is outside this revise task's scope and left to the pipeline's creation path if remote mirroring is later requested.

---

Co-authored with AI: OpenCode (x-preview-f-free)
Co-authored with AI: OpenCode (ox-alpha)
