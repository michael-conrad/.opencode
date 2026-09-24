# Phase 2 — Documentation and deck-purge work

**Concern:** Document the RAGSync service configuration, per-source layout, corpus scope, usage, offline/cache path, and validation step in the `.opencode` skill/guideline tree; purge srclight references from the deck tree per the §3.2 disposition rule; verify srclight-free tool-selection behavior.

**Files:**
- `.opencode/` skill/guideline tree (documentation file, new)
- `.opencode/` deck tree srclight purge (§3.2 sweep scope: `guidelines/`, `skills/`, `tools/`, `README.md`)

**SCs:** SC-6, SC-8, SC-9

**Dependencies:** Phase 1

**Entry Conditions:**
- Phase 1 complete: RAGSync registered and configured
- Phase 1 VbC passed (SC-1..SC-5, SC-7 PASS)
- Deck purge scope per spec §3.2 (footprint baseline: 162 matches across 46 files, enumerated 2026-09-24)

**Exit Conditions:**
- SC-6, SC-8, SC-9 verified PASS and committed (SC-9 has no commit beyond Item 8's purge commit)
- Documentation exists covering service config, per-source layout, corpus scope, usage, offline/cache path, and validation step
- §3.2 deck sweep returns zero srclight matches; genericized sites carry capability-only wording with intact fallback rows
- Behavioral run shows srclight-free tool selection with zero `srclight_*` tool-call attempts in the session evidence

---

### Item 6 (SC-6): Document service configuration and usage

- [ ] 40. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-6**
- [ ] 41. **RED (**task-card**).** Write a failing check asserting the RAGSync documentation file does not yet exist. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-6**
- [ ] 42. **GREEN (**task-card**).** Write documentation in the `.opencode` skill/guideline tree covering service configuration, per-source layout, corpus scope, usage, offline/cache path, and validation step. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-6**
- [ ] 43. **Post-regression (**task-card**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-6**
- [ ] 44. **Verify (**task-card**).** Verify SC-6: the documentation file exists and covers service configuration, per-source layout, corpus scope, usage, offline/cache path, and validation step. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6**
- [ ] 45. **Commit (**direct**).** Commit the documentation change as one atomic slice. `git add .opencode/ && git commit -m "<documentation message>"`. **→ SC-6**

### Item 9 RED (SC-9): behavioral pre-purge run

- [ ] 46. **RED (**task-card**).** Behavioral RED against the pre-purge deck state, executed BEFORE Item 8's GREEN lands: run an isolated opencode code-verification task (signature/blast-radius lookup) while the deck still carries srclight references, and assert zero `srclight_*` tool-call attempts in the session evidence — the assertion FAILS (the stale tier-table/task-card guidance misroutes the agent into `srclight_*` attempts), which is the RED evidence. Evidence artifacts recorded under `{project_root}/tmp/`. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-9**

### Item 8 (SC-8): Purge srclight references from the deck tree

- [ ] 47. **Pre-clean (**direct**).** Remove stale artifacts: `rm -f {project_root}/tmp/{issue-2315}/artifacts/pipeline-red-* pipeline-green-* pipeline-post-regression-* pipeline-verify-*`. **→ SC-8**
- [ ] 48. **RED (**task-card**).** Run the §3.2 deck sweep (`rg -i 'srclight' .opencode/ --hidden --no-ignore` with the §3.2 exclusions: `.opencode/.git/**`, `.opencode/.issues/**`, `node_modules/**`, `tmp/**`, `.pytest_cache/**`, `.ruff_cache/**`) and write a failing check asserting zero matches — the check fails because the 162-match/46-file footprint is still present. Dispatch `task(..., prompt: "execute red task from test-driven-development")`. **→ SC-8**
- [ ] 49. **GREEN (**task-card**).** Apply the §3.2 disposition rule per site across all 46 enumerated files: genericize capability-bearing references to capability-class wording (symbol/signature lookup, callers/callees/dependents blast-radius lookup, code search) with no product-name hardwiring — no `ragsync` or replacement-product naming in deck tool-selection text (CON-10, R-14); remove product-specific references outright (srclight CLI troubleshooting commands, retired-service tier-table entries, `check_srclight()` probe and its startup message, `session-to-timeline` srclight normalizers, the README mcp-block srclight line). Preserve equivalent graceful-degradation unavailability fallback rows wherever they exist today. Dispatch `task(..., prompt: "execute green task from test-driven-development")`. **→ SC-8**
- [ ] 50. **Post-regression (**task-card**).** Run regression test patterns. Dispatch `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ SC-8**
- [ ] 51. **Verify (**task-card**).** Verify SC-8 (structural): the §3.2 deck sweep returns zero matches; spot-check genericized sites for capability-only wording and intact fallback rows. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-8**
- [ ] 52. **Commit (**direct**).** Commit the deck srclight purge as one atomic slice. `git add .opencode/ && git commit -m "<deck srclight purge message>"`. **→ SC-8**
- [ ] 53. **Push (**direct**).** Push the commit to its remote branch, then run a fresh `git fetch` and verify the effective commit is contained in a remote ref — the behavioral-item ordering gate that must pass before the SC-9 verify run executes. **→ SC-8, SC-9**

### Item 9 verify (SC-9): behavioral post-purge run

- [ ] 54. **Verify (**task-card**).** Behavioral verify against the purged, pushed deck state: run an isolated opencode code-verification task (signature/blast-radius lookup) and assert tool selection via available tooling or the built-in `read`/`grep` fallback, with zero `srclight_*` tool-call attempts in the session evidence. Evidence artifacts recorded under `{project_root}/tmp/`. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-9**

#### Phase 2 VbC

- [ ] 55. **VbC (**task-card**).** Verify SC-6, SC-8, and SC-9 verdicts are all clean PASS (SC-6/SC-8 evidence is `structural`; SC-9 evidence is `behavioral`; any `DONE_WITH_CONCERNS` is coerced to FAIL per the implementation-workflow coercion rules). Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`. **→ SC-6, SC-8, SC-9**

---

### Post-implementation (one-time, after last phase)

- [ ] 56. **Audit (**task-card**).** Run adversarial audit of the deliverable (DiMo investigator → validator → evaluator → arbiter). Dispatch `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")`, followed by validator, evaluator, arbiter in sequence. **→ audit**
- [ ] 57. **Z3 check (**direct**).** Run Z3 constraint solver verification: `.opencode/tools/solve check --state-path ... --contract-path ...`. Confirm the phase dependency DAG and state transitions are satisfied. **→ z3-check**

**Concern transition:** Leaving documentation and deck-purge work → entering post-implementation verification. The audit consumes the full deliverable across both phases.
