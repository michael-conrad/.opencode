# Phase 1 — Rewrite Reference File as Data Catalog

**Concern:** Strip orchestrator-level routing content and consolidate 5 redundant data representations into 3 focused tables.

**Files:**
- `skills/writing-plans/reference/implementation-workflow.md`

**SCs:** SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8

**Dependencies:** None

**Entry Conditions:**
- Spec #2214 is approved
- Feature branch exists
- Current file state read and confirmed

**Exit Conditions:**
- File contains only 3 focused tables (Pre-implementation, RED-GREEN Daisy-Chain, Post-implementation) plus cross-cutting sections
- No YAML frontmatter with `name:`, `license:`, or `provenance:`
- All 4 columns present in each table
- Per-Task Cycle, Coercion Rules, Artifact Retention preserved

**Cost frame:** Single-file rewrite (~86 lines → ~80 lines). All SCs verified by grep — no behavioral tests needed. Low risk, low revert cost.

---

- [ ] 1. **RED (**sub-agent**).** Write enforcement test that greps for absence of prohibited sections (Pipeline Step Catalog, Trigger Dispatch Table, Gate Sequence, Audit Sequence Exception, Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing) and frontmatter delimiters. Test FAILS because prohibited content still exists. **→ SC-1, SC-2**
- [ ] 2. **GREEN (**sub-agent**).** Rewrite `skills/writing-plans/reference/implementation-workflow.md`:
  - Remove YAML frontmatter (lines 1-6)
  - Remove Persona, Worktree Mode, Mandatory Task Discipline, DISPATCH_GATE, Sub-Agent Routing sections
  - Consolidate Pipeline Step Catalog + Trigger Dispatch Table + Gate Sequence + Audit Sequence Exception + Artifact Pre-Cleanup into 3 tables:
    - Pre-implementation table (pre-regression, pre-regression-verify)
    - RED-GREEN Daisy-Chain table (red, green, post-regression, verify, commit-inline)
    - Post-implementation table (audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary)
  - Each table has all 4 columns: step name, owning skill, dispatch string, description
  - Preserve Per-Task Cycle, Coercion Rules, Artifact Retention sections as-is
  - Remove Gate Sequence section (ordering implicit in 3-table grouping)
  - Remove Audit Sequence Exception section (content in Post-implementation audit row)
  - Keep Artifact Pre-Cleanup content under Artifact Retention section
  - Keep SPDX and Provenance comment headers (lines 3-5)
  - Keep `# Implementation Workflow Reference Card` title (line 1)
  - **→ SC-1, SC-2, SC-3, SC-4, SC-5, SC-6, SC-7, SC-8**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify:
  - No prohibited sections remain (grep for section headers)
  - No frontmatter delimiters remain
  - 3 tables exist with correct column headers
  - Per-Task Cycle, Coercion Rules, Artifact Retention sections preserved
  - All 15 dispatch entries present across the 3 tables (pre-regression, pre-regression-verify, red, green, post-regression, verify, commit-inline, audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary)
  - **→ SC-1 through SC-8**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the rewrite.

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Verify all 8 SCs (SC-1 through SC-8) pass with string evidence (grep). **→ SC-1 through SC-8**

**Concern transition:** Leaving file rewrite → entering cross-reference verification. Phase 2 depends on Phase 1's rewritten file.
