# Phase 1 — Glob verified-semantics anchor documentation

**Concern:** Add the authoritative built-in glob semantics and silent-failure-modes section to `.opencode/guidelines/060-tool-usage.md` so it is the single source of truth every remediation site cites via Read-link (definition-lives-once).

**Files:**
- `.opencode/guidelines/060-tool-usage.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2334 approved (`approved-for-pr` label present in local `issue.yaml`)
- Feature branch exists and is at trunk-tip; submodules clean
- Structure artifact and dependency contract exist; pre-implementation steps 1-2 passed

**Exit Conditions:**
- The "Built-in glob: verified semantics and silent-failure modes" section exists in `060-tool-usage.md`
- The section documents LIM-1..LIM-6, the canonical path-parameter invocation idiom, and the empty-result disambiguation rule
- `pymarkdownlnt scan` and `mdformat --check` pass on the file

## Code Path Coverage

(from `code-path-inventory.yaml`)

- `.opencode/guidelines/060-tool-usage.md` — SC-1: session start loads the guideline via the instructions array; the agent consults the tool hierarchy before file search; the NEW glob-semantics section is read before choosing an invocation form.

## Cross-Cutting SCs

(from `cross-cutting-matrix.yaml`)

- `read-link-cross-references` (ALL): the anchor section is the citation target; remediation sites must reference it via Read `[Text](path)`, never restate semantics inline.
- `triple-co-application` (SC-1, SC-7): reference cards 250/255/257 consulted before authoring the section.
- `numbering` (SC-1): numbered lists start at 1; the limitation list is already LIM-1..LIM-6 compliant.
- `markdown-lint-format` (SC-1): `pymarkdownlnt` + `mdformat --check` on the touched guideline file.

## Interface Boundaries

(from `interface-compatibility.yaml`)

- `060-tool-usage.md guideline content` — consumed by every session via the instructions array; change is `NEW_SECTION_ONLY`, backward compatible, non-breaking (existing tier table untouched).
- `canonical glob invocation idiom` — new documentation-level interface introduced by SC-1 that all remediation sites consume via Read-link.

## State Transitions

(from `state-analysis.yaml`)

- SC-1 is documentation-only; no runtime state machines change. The agent decision state at each future file-search is enriched to consult the glob-semantics section before choosing an invocation form.

## Step-by-step

- [ ] 3. **RED (**sub-agent**).** Pre-clean stale artifacts: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-red-*`. Write a failing grep check asserting the "Built-in glob: verified semantics and silent-failure modes" section heading is absent from `.opencode/guidelines/060-tool-usage.md`. Test FAILS because the section does not exist yet. **→ SC-1**
  - Dispatch `task(..., prompt: "execute red task from test-driven-development")`
- [ ] 4. **GREEN (**sub-agent**).** Add the verified-semantics section documenting LIM-1 through LIM-6, the canonical path-parameter invocation idiom, and the empty-result disambiguation rule. **→ SC-1**
  - Dispatch `task(..., prompt: "execute green task from test-driven-development")`
  - Context: SC-1, section heading, six limitations, canonical idiom, disambiguation rule, triple co-application
- [ ] 5. **Post-regression (**sub-agent**).** Run regression test patterns to confirm the section addition did not alter the guideline hierarchy semantics. **→ SC-1**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-post-regression-*`
  - Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`
- [ ] 6. **Verify (**clean-room**).** Verify SC-1 against its structural evidence type: grep asserts the section heading and LIM-1..LIM-6 coverage are present; `pymarkdownlnt scan` and `mdformat --check` pass on the file. BLOCK on FAIL or EVIDENCE_TYPE_MISMATCH. **→ SC-1**
  - Clean previous-run artifacts: `rm -f {project_root}/tmp/{issue-2334}/artifacts/pipeline-verify-*`
  - Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
- [ ] 7. **COMMIT (**inline**).** Stage and commit the guideline section change together as one atomic slice. **→ SC-1**
  - Command: `git add .opencode/guidelines/060-tool-usage.md && git commit -m "<SC-1 message>"`
  - No co-author trailers during implementation commits

#### Phase 1 VbC

- [ ] 8. **VbC (**clean-room**).** Verify SC-1 passes its structural check: the section covers LIM-1..LIM-6, the canonical path-parameter idiom, and the empty-result disambiguation rule, and markdown lint/format are clean. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-1**

**Concern transition:** Leaving the verified-semantics anchor documentation → entering invocation remediation across the agent deck. Phase 2 depends on Phase 1's SC-1 anchor section, which every Phase 2 remediation site cites via Read-link.
