# Phase 2 — Remediate broken invocation sites across agent deck

**Concern:** Normalize every fragile glob invocation across sre-runbook, verification-before-completion, the 27-file audit family (SC-6 Invocation-Site Inventory), and the research-card catalogue instruction to the canonical path-parameter form, each citing the SC-1 anchor via Read-link.

**Files:**
- `.opencode/skills/sre-runbook/tasks/generate.md` (SC-2, SC-3)
- `.opencode/skills/verification-before-completion/tasks/completion.md` (SC-4)
- `.opencode/skills/verification-before-completion/tasks/collect.md` (SC-5)
- `.opencode/skills/audit/tasks/*.md` — 27-file SC-6 Invocation-Site Inventory (SC-6)
- `.opencode/guidelines/020-go-prohibitions.md` (SC-7)

**SCs:** SC-2, SC-3, SC-4, SC-5, SC-6, SC-7

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: the SC-1 anchor section exists in `060-tool-usage.md` and its VbC passed (steps 3-8)
- Feature branch is at trunk-tip; working tree clean

**Exit Conditions:**
- All six Phase 2 SCs (SC-2..SC-7) verified PASS and committed
- No fragile invocation shape remains at any remediated site; all cite SC-1 via Read-link
- RB_PATH fallback, both stamp checks, VERIFICATION-GAP/MISSING-ELEMENT semantics, audit role contracts, and confidence-skip logic preserved

## Code Path Coverage

(from `code-path-inventory.yaml`)

- `generate.md` Format-Matching Glob gate — SC-3: dual-pattern search → results collected → format decision (invocation form changes; decision logic order preserved).
- `generate.md` File-Replace-on-Revision pre-generation check — SC-3: dual-glob → OLD_FILE identification (form changes).
- `generate.md` Agent-Detected Runbook Base Path — SC-2: `**/runbooks/` scan → RB_PATH resolution → all subsequent file ops base off RB_PATH (form changes; RB_PATH contract preserved).
- `completion.md` / `collect.md` live-verification table rows — SC-4, SC-5: tool-call cells executed during completion claims (cell values change only).
- `.opencode/skills/audit/tasks/*.md` — SC-6: `spec_local_dir` listing step → spec_files collection → per-file read loop; `plan_local_dir` listing; evidence-artifact existence checks (invocation block syntax + guard steps change; role contracts unchanged).
- `020-go-prohibitions.md` research dispatch decision — SC-7: catalogue consultation glob `*.md` → frontmatter grep (one instruction clause clarified).

## Cross-Cutting SCs

(from `cross-cutting-matrix.yaml`)

- `read-link-cross-references` (ALL): every remediation site cites the SC-1 section via Read `[Text](path)`; bare mentions forbidden.
- `triple-co-application` (SC-1, SC-7): reference cards 250/255/257 consulted before authoring changed agent-facing text.
- `attribution-byline` (SC-1..SC-7): existing Co-authored lines preserved verbatim; append only on substantive new creative content.
- `markdown-lint-format` (SC-1, SC-7): `pymarkdownlnt` + `mdformat --check` on touched guideline files.
- `submodule-pointer-discipline` (commit phase): all changes land in `.opencode`; no parent-repo edits fabricated.

## Interface Boundaries

(from `interface-compatibility.yaml`)

- `sre-runbook RB_PATH contract` — `UNCHANGED_SEMANTICS_NEW_RESOLUTION_MECHANISM`; RB_PATH still resolves to a runbooks directory path or `docs/runbooks/` fallback; consumers unchanged (SC-2).
- `format-matching dual-pattern mandate` — `MODIFIED_INVOCATION_FORM_SAME_MANDATE`; both stamp patterns still required; empty-result conclusion now gated (SC-3).
- `verification-before-completion live-verification table schema` — `CELL_VALUE_ONLY`; internal-only (SC-4, SC-5).
- `audit task role contracts` — `UNCHANGED`; only invocation syntax and guard steps normalized (SC-6).
- `research-card catalogue protocol` — `CLARIFIED_INVOCATION_FORM`; confidence-skip intact (SC-7).

## State Transitions

(from `state-analysis.yaml`)

- SC-2: `SCAN_ROOT_WITH_DIR_GLOB`/`ALWAYS_EMPTY`/`FALLBACK_DOCS_RUNBOOKS` → `DISCOVER_VIA_WORKING_MECHANISM`/`MATCH_FOUND_SET_RB_PATH`/`NO_MATCH_FALLBACK_DOCS_RUNBOOKS`; terminal fallback preserved.
- SC-3: `DUAL_GLOB_BARE_PATTERN`/`RESULTS_MAYBE_FALSE_EMPTY`/`DECIDE_FORMAT` → `DUAL_GLOB_PATH_PARAM`/`EMPTY_DISAMBIGUATION_CHECK`/`RESULTS_VERIFIED`/`DECIDE_FORMAT`; new state `EMPTY_DISAMBIGUATION_CHECK`.
- SC-4/SC-5: `PATTERN_GLOB_TMP_TARGET`/`SILENT_EMPTY`/`FALSE_MISSING_ELEMENT` → `WORKING_EXISTENCE_CHECK`/`PRESENT`/`ABSENT_CONFIRMED`; ABSENT_CONFIRMED reachable only after a form that can see gitignored artifacts.
- SC-6: `F_STRING_PSEUDO_CALL`/`LIST_RETURNED_OR_SILENT_EMPTY_UNGUARDED`/`PROCEED_ON_LIST` → `CANONICAL_CALL`/`EMPTY_GUARD_CHECK`/`LIST_VERIFIED_NONEMPTY_OR_BLOCKED_NOTE`/`PROCEED_ON_LIST`; new state `EMPTY_GUARD_CHECK`.

## Step-by-step

### Item 2 (SC-2): Runbook discovery mechanism in generate.md

- [ ] 9. **RED (**sub-agent**).** Pre-clean stale artifacts: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-red-*`. Write a failing grep check asserting the directory-only runbook-discovery glob pattern is present in `generate.md`. Test FAILS because the pattern is still there. **→ SC-2**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
- [ ] 10. **GREEN (**sub-agent**).** Replace the directory-only runbook discovery with a working mechanism (bash find `-type d` fallback or path-parameter glob) whose fallback terminates at `docs/runbooks/`, citing the SC-1 section via Read-link. **→ SC-2**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 11. **Post-regression (**sub-agent**).** Run regression patterns to confirm the discovery rewrite preserves RB_PATH semantics. **→ SC-2**
  - Clean: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 12. **Verify (**clean-room**).** Verify SC-2: grep asserts directory-glob form absent and working mechanism present; live probe the replacement against this repo (no runbooks/ → fallback) and a synthetic fixture dir (match case). BLOCK on FAIL or EVIDENCE_TYPE_MISMATCH. **→ SC-2**
  - Clean: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 13. **COMMIT (**inline**).** Commit the discovery-mechanism change as one atomic slice. `git add .opencode/skills/sre-runbook/tasks/generate.md && git commit -m "<SC-2 message>"`. **→ SC-2**

### Item 3 (SC-3): Format-matching dual-pattern gate hardening

- [ ] 14. **RED (**sub-agent**).** Pre-clean stale artifacts. Write a failing grep check asserting the bare `<RB_PATH>/**` pattern form is present in the generate.md format-matching gate. Test FAILS because the bare pattern is still there. **→ SC-3**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
- [ ] 15. **GREEN (**sub-agent**).** Rewrite the format-matching dual-pattern gate to path-parameter form with bracketed placeholders and add an empty-result disambiguation step before any no-existing-runbooks conclusion; preserve both stamp checks. **→ SC-3**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 16. **Post-regression (**sub-agent**).** Run regression patterns to confirm the gate preserves both stamp checks. **→ SC-3**
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 17. **Verify (**clean-room**).** Verify SC-3: grep shows the bare pattern absent and canonical path-parameter form present; structural review confirms both stamp checks intact. **→ SC-3**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 18. **COMMIT (**inline**).** Commit the format-matching gate rewrite as one atomic slice. `git add .opencode/skills/sre-runbook/tasks/generate.md && git commit -m "<SC-3 message>"`. **→ SC-3**

### Item 4 (SC-4): Evidence-artifact check in completion.md

- [ ] 19. **RED (**sub-agent**).** Pre-clean stale artifacts. Write a failing check asserting the completion.md evidence-artifact existence check uses a gitignored-target pattern-form glob (cannot reach `tmp/` artifacts). Test FAILS because the cell cannot currently reach the gitignored target. **→ SC-4**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
- [ ] 20. **GREEN (**sub-agent**).** Replace the completion.md evidence check with an invocation proven to reach `{project_root}/tmp/<issue>/artifacts/` content, citing the SC-1 section via Read-link. **→ SC-4**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 21. **Post-regression (**sub-agent**).** Run regression patterns to confirm the replacement preserves VERIFICATION-GAP classification semantics. **→ SC-4**
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 22. **Verify (**clean-room**).** Verify SC-4 (behavioral via live probe): execute the documented replacement check against real `{project_root}/tmp/<issue>/artifacts/` content and assert detection output is present. BLOCK on FAIL. **→ SC-4**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 23. **COMMIT (**inline**).** Commit the evidence check remediation. `git add .opencode/skills/verification-before-completion/tasks/completion.md && git commit -m "<SC-4 message>"`. **→ SC-4**

### Item 5 (SC-5): Report-existence check in collect.md

- [ ] 24. **RED (**sub-agent**).** Pre-clean stale artifacts. Write a failing check asserting the collect.md report-existence check still contains the pattern-form invocation. Test FAILS because the report-existence cell is un-remediated. **→ SC-5**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
- [ ] 25. **GREEN (**sub-agent**).** Apply the same working-form remediation as SC-4 to the collect.md report-existence check, preserving MISSING-ELEMENT classification semantics. **→ SC-5**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 26. **Post-regression (**sub-agent**).** Run regression patterns to confirm the report-existence remediation preserves MISSING-ELEMENT semantics. **→ SC-5**
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 27. **Verify (**clean-room**).** Verify SC-5 (behavioral via live probe): execute the same probe as SC-4 against real artifacts content and assert detection works, MISSING-ELEMENT classification intact. **→ SC-5**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 28. **COMMIT (**inline**).** Commit the report-existence change as one atomic slice. `git add .opencode/skills/verification-before-completion/tasks/collect.md && git commit -m "<SC-5 message>"`. **→ SC-5**

### Item 6 (SC-6): Audit family invocation normalization (family-atomic)

- [ ] 29. **RED (**sub-agent**).** Pre-clean stale artifacts. Write a failing grep sweep asserting f-string pseudo-syntax, unbracketed placeholder, or unguarded listing shapes are present in the inventoried audit task files (count > 0). Test FAILS while any inventoried file retains a fragile shape. **→ SC-6**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
- [ ] 30. **GREEN (**sub-agent**).** Normalize all 27 inventoried audit files to plain-string path-parameter invocations with bracketed placeholders and empty-result guards wherever a listing feeds downstream logic. One family-atomic slice — all 27 files together. **→ SC-6**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 31. **Post-regression (**sub-agent**).** Run regression patterns to confirm role contracts and verdict schemas are unchanged across the audit family. **→ SC-6**
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 32. **Verify (**clean**).** Verify SC-6: grep count equals zero for f-string pseudo-syntax and unbracketed placeholders, guard steps present at listing-fed decision points across the 27 files; spot probe confirms canonical shape. **→ SC-6**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 33. **COMMIT (**inline**).** Commit the audit family normalization as one atomic slice across all 27 files. `git add .opencode/skills/audit/tasks/ && git commit -m "<SC-6 message>"`. **→ SC-6**

### Item 7 (SC-7): Research-catalogue instruction clarity in 020-go-prohibitions.md

- [ ] 34. **RED (**sub-agent**).** Pre-clean stale artifacts. Write a failing check asserting the research-card catalogue instruction in `020-go-prohibitions.md` lacks an explicit path-parameter invocation form. Test FAILS because the clause is unspecified. **→ SC-7**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
- [ ] 35. **GREEN (**sub-agent**).** Restate the research-card catalogue instruction to specify the path-parameter invocation form so literal translation cannot produce a silently-empty call; leave confidence-skip logic unchanged. **→ SC-7**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
- [ ] 36. **Post-regression (**sub-agent**).** Run regression patterns to confirm catalogue protocol clauses (frontmatter grep, confidence skip) are intact. **→ SC-7**
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 37. **Verify (**clean-room**).** Verify SC-7: read-back review asserting explicit path-param phrasing present and catalogue protocol clauses intact. **→ SC-7**
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 38. **COMMIT (**inline**).** Commit the catalogue instruction clarification as one atomic slice. `git add .opencode/guidelines/020-go-prohibitions.md && git commit -m "<SC-7 message>"`. **→ SC-7**

#### Phase 2 VbC

- [ ] 39. **VbC (**clean-room**).** Verify SC-2..SC-7 all pass against their evidence types: SC-2 structural, SC-3 structural, SC-4 behavioral (live probe), SC-5 behavioral (live probe), SC-6 structural, SC-7 structural. BLOCK on any FAIL or EVIDENCE_TYPE_MISMATCH. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-2, SC-3, SC-4, SC-5, SC-6, SC-7**

**Concern transition:** Leaving invocation remediation → entering the behavioral proof. Phase 3 depends on the fully remediated deck from Phase 2.
