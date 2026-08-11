# Phase 1 — Promote critical-rules-PR-ORG to canonical location

**Concern:** canonical-rule

**Files:**
- `.opencode/guidelines/000-critical-rules.md`

**SCs:** SC-1

**Dependencies:** None

**Entry Conditions:**
- Spec #2271 is approved (`approved-for-for_pr` label present in local `issue.yaml`)
- Feature branch exists
- `grep -c "PR-ORG" .opencode/guidelines/000-critical-rules.md` returns `0` (rule confirmed missing)

**Exit Conditions:**
- `critical-rules-PR-ORG` rule with the "Stacked PR Is the Only Valid Organization" bright-line text exists in `000-critical-rules.md`
- `grep -c "PR-ORG" .opencode/guidelines/000-critical-rules.md` returns `>= 1`

---

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting `critical-rules-PR-ORG` exists in `.opencode/guidelines/000-critical-rules.md` with the "Stacked PR Is the Only Valid Organization" bright-line text. **→ SC-1**
- [ ] 2. **GREEN (**sub-agent**).** Promote the rule text from `.opencode/skills/git-workflow-pr/SKILL.md` line 89 (rule body) and lines 95-99 (bright-line companion) into `.opencode/guidelines/000-critical-rules.md` under the `critical-rules-PR-ORG` identifier. **→ SC-1**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify the promoted rule contains the exact bright-line text: one branch, N commits, one PR per authorization scope; N branches for N issues is a critical violation. **→ SC-1**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the rule promotion.

#### Phase 1 VbC

- [ ] 5. **VbC (**clean-room**).** Verify `critical-rules-PR-ORG` exists in `000-critical-rules.md` and `grep -c "PR-ORG"` returns `>= 1`. **→ SC-1**

**Concern transition:** Leaving canonical-rule promotion → entering behavioral-enforcement. Phase 2 depends on Phase 1's rule existing in the canonical location.
