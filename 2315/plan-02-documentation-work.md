# Phase 2 — Documentation and deck srclight purge

**Concern:** Document the RAGSync service configuration, per-source layout per §3.1, corpus scope, usage, offline/cache path, and validation step in the `.opencode` skill/guideline tree; purge srclight references from the deck tree per the §3.2 disposition rule; verify srclight-free tool-selection behavior.

**Files:**
- `.opencode/skills/` or `.opencode/guidelines/` tree (service documentation, new)
- `.opencode/` deck tree — srclight reference purge (§3.2 sweep scope: `guidelines/` (9 files), `skills/audit` tasks (12), `skills/brainstorming` tasks (4), misc `skills/` (15), `README.md`, `tools/session-init`, `tools/session-to-timeline`)
- `{project_root}/tmp/` (SC-9 behavioral evidence artifacts)

**SCs:** SC-6, SC-8, SC-9

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: RAGSync registered and configured; Phase 1 VbC passed (SC-1..SC-5, SC-7 clean PASS)
- Spec #2315 revised SC set (SC-6/SC-8/SC-9 in scope per R-6/R-9, R-13/R-14, CON-10)
- §3.2 footprint baseline available: 162 srclight matches across 46 files (enumerated 2026-09-24)
- Feature branch carries the phase-1 commits

**Exit Conditions:**
- SC-6, SC-8, SC-9 verified clean PASS (SC-9 has no commit beyond Item 8's purge commit)
- Documentation exists covering service configuration, per-source layout per §3.1, corpus scope, usage, offline/cache path, and validation step
- §3.2 deck sweep returns zero srclight matches within the sweep boundary; genericized sites carry capability-only wording with intact fallback rows
- Isolated behavioral run shows srclight-free tool selection with zero `srclight_*` tool-call attempts in the session evidence; purge commit pushed and fresh-fetch-verified before that run

**Dispatch summary:** direct (steps 40, 45, 47, 52, 53) + task-card (steps 41-44, 46, 48-51, 54, 55). Corrected 2026-09-30 per validate-findings F-2: the prior inclusive range "41-46" double-listed step 45 (Commit, direct) as task-card; direct and task-card enumerations are now disjoint and match the normative per-step indicators above.

**Phase sections (from analytical artifacts):**
- Code path coverage: static documentation path with the five topic-presence criteria (SC-6); text-state path across the 46 §3.2 files with per-site dispositions and the sweep boundary (SC-8); agent tool-selection runtime path reading genericized deck text and selecting available tooling or the built-in `read`/`grep` fallback (SC-9)
- Cross-cutting SCs: SC-6 (documentation crossed with all phase-1 config concerns — CON-5); SC-8 (purge spans guidelines, task cards, README, and executable session tooling — script-side removal changes script behavior); SC-9 (behavioral evidence validity depends on SC-8's purge being committed and pushed to a remote ref)
- Interface boundaries: genericized deck text ↔ agent tool-selection behavior (capability-class wording; fallback rows preserved; no replacement product naming); deck purge ↔ historical evidence artifacts (`.opencode/.issues/**` excluded — MUST NOT be rewritten)
- State transitions: documentation file absent → present with five topics (SC-6); deck text 162 matches/46 files → zero matches within the sweep boundary with capability-only wording (SC-8); agent behavior from `srclight_*` routing to built-in-fallback/available-tooling selection with zero `srclight_*` attempts (SC-9)

**Cost frame:** The zero-match sweep costs one grep pass, the documentation topic check costs one file read, and the SC-9 behavioral run costs minutes in an isolated test home. Skipping the sweep leaves the retired service's tool names as live agent-facing instructions misrouting every future agent; skipping the behavioral run reduces the purge to a text-only claim — an agent following genericized guidance that cannot fall back to built-in tooling halts where graceful degradation should keep it working, and the defect ships to every subsequent session. Correctness is the only metric.

---

### Item 6 (SC-6): Document service configuration and usage

- [ ] 40. **Pre-clean (**direct**).** Remove stale prior-run artifacts for this and subsequent steps: `rm -f {project_root}/tmp/2315/artifacts/pipeline-red-* {project_root}/tmp/2315/artifacts/pipeline-green-* {project_root}/tmp/2315/artifacts/pipeline-post-regression-* {project_root}/tmp/2315/artifacts/pipeline-verify-*`. **→ SC-6**
- [ ] 41. **RED (**task-card**).** Write a failing check asserting a RAGSync service documentation file exists in the `.opencode` skill/guideline tree — the check FAILS because no RAGSync documentation is present yet. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-6**
- [ ] 42. **GREEN (**task-card**).** Write documentation in the `.opencode` skill/guideline tree covering the five required topics: service configuration, per-source layout per §3.1, corpus scope (CON-8), usage, and the offline/cache embedding-path plus the validation step (R-6, R-9; CON-5, CON-7). The documentation describes the landed phase-1 configuration — no new config surface invented here. Minimum change only. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-6**
- [ ] 43. **Post-regression (**task-card**).** Run regression patterns after GREEN. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-6**
- [ ] 44. **Verify (**task-card**).** Verify SC-6 (structural): the documentation file exists and contains the topic-presence criteria for service configuration, per-source layout per §3.1, usage, offline/cache path, and the validation step — file read is the evidence. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6**
- [ ] 45. **Commit (**direct**).** Stage and commit the documentation + test as one atomic slice: `git add .opencode/ && git commit -m "<documentation message>"`. This commit is the precondition for the SC-9 RED behavioral run. **→ SC-6**

### Item 9 RED (SC-9): behavioral pre-purge run

- [ ] 46. **RED behavioral (**task-card**).** Execute BEFORE Item 8's GREEN lands in the working tree: run an isolated opencode code-verification task (signature/blast-radius lookup) against the PRE-purge deck state (which still carries the §3.2 srclight references) and assert zero `srclight_*` tool-call attempts in the session evidence — the assertion FAILS (the stale tier-table/task-card guidance misroutes the agent into `srclight_*` attempts), which is the RED behavioral evidence. Runs use the `with-test-home` wrapper per repo test discipline; behavioral evidence is agent actions in session evidence, never prose recall; evidence artifacts recorded under `{project_root}/tmp/`. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-9**

### Item 8 (SC-8): Purge srclight references from the deck tree

- [ ] 47. **Pre-clean (**direct**).** `rm -f {project_root}/tmp/2315/artifacts/pipeline-red-* {project_root}/tmp/2315/artifacts/pipeline-green-* {project_root}/tmp/2315/artifacts/pipeline-post-regression-* {project_root}/tmp/2315/artifacts/pipeline-verify-*`. **→ SC-8**
- [ ] 48. **RED (**task-card**).** Run the §3.2 deck sweep (`rg -i 'srclight' .opencode/ --hidden --no-ignore` with the §3.2 exclusion list: `.opencode/.git/**`, `.opencode/.issues/**`, `node_modules/**`, `tmp/**`, `.pytest_cache/**`, `.ruff_cache/**`) and write a failing check asserting zero matches — the check FAILS because the 162-match/46-file footprint is still present. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-8**
- [ ] 49. **GREEN (**task-card**).** Apply the §3.2 disposition rule per site across all 46 enumerated files: GENERICIZE capability-bearing references to capability-class wording (symbol/signature lookup, symbol lookup, callers/callees/dependents blast-radius lookup, code search, symbol enumeration, test-coverage lookup, recent-changes lookup, index-tool call enumeration) with NO replacement-product naming in deck tool-selection text — no `ragsync` (R-14); REMOVE product-specific references outright (srclight CLI troubleshooting commands and table rows in `mcp-tool-usage/tasks/selection-guide.md`, retired-service tier-table entries in `guidelines/060-tool-usage.md` and `mcp-tool-usage/SKILL.md`, the `check_srclight()` probe + `srclight_status` wiring + startup message in `tools/session-init`, the `srclight_*` tool-name normalizers in `tools/session-to-timeline`, the README mcp-block srclight line). Preserve equivalent graceful-degradation unavailability fallback rows wherever they exist today — removing a fallback row would hard-halt agents when no index tool exists (R-13, CON-10). The sweep exclusion list is the determinate boundary — `.opencode/.issues/**` MUST NOT be rewritten. Minimum change per site; no unrelated edits. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-8**
- [ ] 50. **Post-regression (**task-card**).** Run regression patterns after GREEN (script-side removals in `tools/session-init` and `tools/session-to-timeline` change script behavior, not just prose — regression must cover both). Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-8**
- [ ] 51. **Verify (**task-card**).** Verify SC-8 (structural): the §3.2 deck sweep returns zero matches; spot-check genericized sites for capability-only wording (no product name) and intact fallback rows. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-8**
- [ ] 52. **Commit (**direct**).** Commit the deck srclight purge + test as one atomic slice: `git add .opencode/ && git commit -m "<deck srclight purge message>"`. **→ SC-8**
- [ ] 53. **Push (**direct**).** Push the purge commit to its remote branch: `git push -u origin <feature branch>`. Then run a fresh `git fetch` and verify the effective commit is contained in a remote ref (e.g., verify the pushed SHA appears under `git branch -r --contains <sha>` after fetch) — this push-and-verify gate is the behavioral-item ordering precondition that MUST pass before step 54's SC-9 verify behavioral run executes; the SC-9 verify run MUST NOT start until containment is confirmed. **→ SC-8**

### Item 9 verify (SC-9): behavioral post-purge run

- [ ] 54. **Verify behavioral (**task-card**).** Behavioral verify against the purged, PUSHED, fresh-fetch-verified deck state: run an isolated opencode code-verification task (signature/blast-radius lookup) and assert the agent selects available tooling or the built-in `read`/`grep` fallback, with ZERO `srclight_*` tool-call attempts in the session evidence. Runs use the `with-test-home` wrapper; evidence artifacts recorded under `{project_root}/tmp/`. If the run cannot execute, the outcome is FAIL — no structural substitute may stand in for the behavioral evidence. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-9**

#### Phase 2 VbC

- [ ] 55. **VbC (**task-card**).** Verify all phase-2 SC verdicts are clean PASS with matching evidence types — SC-6 and SC-8 structural; SC-9 behavioral — and that any `DONE_WITH_CONCERNS` verdict is treated as FAIL per the implementation-workflow coercion rules. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6, SC-8, SC-9**

**Concern transition:** Leaving documentation and deck-purge work → entering post-implementation verification and delivery (audit, z3-check, structural checks, pre-PR gate, regression check, review prep, PR creation, completion summary — steps 56-63 in the plan index). The audit consumes the full deliverable across both phases.