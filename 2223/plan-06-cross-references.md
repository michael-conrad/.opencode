# Phase 6 — Update Cross-References

**Concern:** Remove all stale cross-references to the deleted `pr-creation-workflow` skill across the codebase.

**Files:**
- Codebase-wide: all files referencing `pr-creation-workflow`
- `.opencode/skills/git-workflow-pr/SKILL.md` (specific cross-reference removal)

**SCs:** SC-29, SC-30

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: `pr-creation-workflow` skill directory deleted
- Phase 2 VbC passed

**Exit Conditions:**
- No cross-references to `pr-creation-workflow` remain anywhere in the codebase
- Cross-reference from `git-workflow-pr` SKILL.md specifically removed

**Cost frame:** Implementation cost is measured in defect-discovery latency, not tool-call count. Removing cross-references to pr-creation-workflow costs ~2 grep-and-remove operations — each operation is a discovery point where a stale cross-reference would surface. Skipping either SC costs a broken link that routes agents to a deleted skill. Correctness is the only success metric — there is no score for speed.

---

### Item 29 — SC-29: All cross-references to pr-creation-workflow updated or removed

- [ ] 148. **RED (**sub-agent**).** Write a failing enforcement test asserting `grep` for "pr-creation-workflow" across the codebase returns zero results. **→ SC-29**
- [ ] 149. **GREEN (**sub-agent**).** Search the codebase for all occurrences of "pr-creation-workflow" and update or remove each one. **→ SC-29**
- [ ] 150. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 151. **Verify (**clean-room**).** Verify `grep` for "pr-creation-workflow" returns zero results. **→ SC-29**
- [ ] 152. **Commit (**inline**).** `git add -u && git commit -m "Phase 6 Item 29: Remove all cross-references to pr-creation-workflow"`

### Item 30 — SC-30: Cross-reference from git-workflow-pr SKILL.md removed

- [ ] 153. **RED (**sub-agent**).** Write a failing enforcement test asserting `grep` for "pr-creation-workflow" in `git-workflow-pr/SKILL.md` returns zero. **→ SC-30**
- [ ] 154. **GREEN (**sub-agent**).** Remove the cross-reference to `pr-creation-workflow` from `git-workflow-pr/SKILL.md`. **→ SC-30**
- [ ] 155. **Post-regression (**sub-agent**).** Run regression test patterns after GREEN phase. **→ post-regression**
- [ ] 156. **Verify (**clean-room**).** Verify "pr-creation-workflow" is absent from `git-workflow-pr/SKILL.md`. **→ SC-30**
- [ ] 157. **Commit (**inline**).** `git add .opencode/skills/git-workflow-pr/SKILL.md && git commit -m "Phase 6 Item 30: Remove cross-reference from git-workflow-pr SKILL.md"`

#### Phase 6 VbC

- [ ] 158. **VbC (**clean-room**).** Verify both SCs in Phase 6 (SC-29, SC-30) pass with correct evidence types. **→ SC-29, SC-30**

**Concern transition:** Leaving cross-reference update → entering post-implementation. All 6 phases complete.

---

## Post-Implementation

- [ ] 159. **Audit (**clean-room**).** Run adversarial audit of the deliverable. Dispatch: `task(..., prompt: "execute verification-audit DiMo investigator from audit. Read \`audit/tasks/verification-audit-investigator.md\` first")` — followed by validator, evaluator, arbiter in sequence. **→ audit**
- [ ] 160. **Z3 check (**inline**).** Run `.opencode/tools/solve check --state-path ... --contract-path ...` to verify constraint satisfaction. **→ z3-check**
- [ ] 161. **Structural checks (**sub-agent**).** Run finishing checklist (lint, typecheck, etc.). Dispatch: `task(..., prompt: "execute checklist task from finishing-a-development-branch")`. **→ structural-checks**
- [ ] 162. **Pre-PR gate (**clean-room**).** Verify all SC verdicts before PR creation. Dispatch: `task(..., prompt: "execute verify task from verification-before-completion")`. BLOCK if any SC verdict is FAIL. **→ pre-pr-gate**
- [ ] 163. **Regression check (**sub-agent**).** Final regression check before PR. Dispatch: `task(..., prompt: "execute phase-4 task from test-driven-development")`. **→ regression-check**
- [ ] 164. **Review prep (**sub-agent**).** Prepare PR review context. Dispatch: `task(..., prompt: "execute review-prep from git-workflow-pr. Read \`git-workflow-pr/tasks/review-prep.md\` first")`. **→ review-prep**
- [ ] 165. **Create PR (**sub-agent**).** Create the pull request. Dispatch: `task(..., prompt: "execute create task from pr-creation-workflow")`. **→ create-pr**
- [ ] 166. **Executive summary (**sub-agent**).** Generate completion executive summary. Dispatch: `task(..., prompt: "execute completion task from completion-core")`. **→ exec-summary**
