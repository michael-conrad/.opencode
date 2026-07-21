# Phase 1 — Universal question tool prohibition

## Phase Metadata

- **Concern:** Remove all scope qualifiers from the question tool prohibition across 5 files. Add top-level Tier 1 prohibition in `020-go-prohibitions.md`. Update `critical-rules-037` in `000-critical-rules.md` to remove `for_pr` scope qualifier. Update `010-approval-gate.md` edge case table reference. Remove scope qualifier from `pre-implementation-analysis.md`. Remove contradictory question tool instruction from `140-planning-spec-creation.md`.
- **Files:** `.opencode/guidelines/020-go-prohibitions.md`, `.opencode/guidelines/000-critical-rules.md`, `.opencode/guidelines/010-approval-gate.md`, `.opencode/skills/approval-gate-scope/tasks/pre-implementation-analysis.md`, `.opencode/guidelines/140-planning-spec-creation.md`
- **SCs:** SC-1 (behavioral), SC-6 (string)
- **Dependencies:** Spec approved, all 7 analytical artifacts exist
- **Entry conditions:** Spec approved, feature branch created, all artifacts non-empty
- **Exit conditions:** All 5 files modified and committed to feature branch

## Code Path Coverage

| File | Change Type | Code Path |
|------|------------|-----------|
| 020-go-prohibitions.md | Add + edit | Top-level Tier 1 prohibition + §1.6 scope qualifier removal |
| 000-critical-rules.md | Edit | critical-rules-037 — remove `for_pr` scope qualifier |
| 010-approval-gate.md | Edit | Edge case table — update critical-rules-037 reference |
| pre-implementation-analysis.md | Edit | Remove `after presenting the execution plan` qualifier |
| 140-planning-spec-creation.md | Edit | Remove `Use the question tool with a list of available specs` instruction |

## Cross-Cutting SCs

- **020-go-prohibitions.md modification integrity:** Phase 1 adds top-level prohibition and edits §1.6. Subsequent phases add more entries. Edits must be targeted to specific sections.

## Interface Boundaries

- `020-go-prohibitions.md §1 🚫 NEVER DO section` — modified (add top-level prohibition)
- `020-go-prohibitions.md §1.6 Discussion Mode section` — modified (remove scope qualifier)
- `000-critical-rules.md critical-rules-037` — modified (remove scope qualifier)
- `010-approval-gate.md Key Edge Cases table` — modified (update reference)
- `pre-implementation-analysis.md question tool prohibition line` — modified (remove qualifier)
- `140-planning-spec-creation.md question tool instruction` — modified (remove instruction)

## State Transitions

- **From:** question tool prohibited in discussion mode only (020-go-prohibitions §1.6) + for_pr scope only (critical-rules-037)
- **To:** question tool prohibited universally — all contexts, all scopes
- **Invariant:** Existing prohibition text remains intact — only scope qualifiers are removed

## Step-by-step

- [ ] 1. **Coherence gate (**clean-room**).** Verify spec SCs are coherent with current codebase state. Read `000-critical-rules.md` critical-rules-037, `020-go-prohibitions.md` §1.6, `010-approval-gate.md` edge case table, `pre-implementation-analysis.md` line 46, `140-planning-spec-creation.md` line 57. Confirm all 5 scope qualifiers exist and are modifiable. **→ SC-1, SC-6**

- [ ] 2. **Pre-RED baseline (**clean-room**).** Run `bash .opencode/tests-v2/behaviors/` to establish baseline test state. Record which behavioral tests pass/fail before any changes. Save baseline to `{project_root}/tmp/2037/baseline-pre-phase1.log`.

- [ ] 3. **RED — Write behavioral enforcement test for SC-1 (**sub-agent**).** Create `.opencode/tests-v2/behaviors/universal-question-tool-prohibition.sh` that sends a prompt where the agent would previously have used the question tool (e.g., authorization with `for_pr` scope, structural decision context). Assert via `assert_semantic` that the agent does NOT use the question tool. Test MUST FAIL at this point (rule change doesn't exist yet). **→ SC-1**

- [ ] 4. **GREEN — Add top-level Tier 1 prohibition to 020-go-prohibitions.md (**sub-agent**).** Add a new top-level bullet under `## 1. What GO Is Not & Self-Authorization Prohibitions` in the `🚫 NEVER DO` section: "Never use the `question` tool." — no scope qualifier, no context limitation. **→ SC-1**

- [ ] 5. **GREEN — Remove scope qualifier from §1.6 in 020-go-prohibitions.md (**sub-agent**).** Edit the existing question tool prohibition in §1.6 to remove any scope qualifier (e.g., "in discussion mode"). The prohibition must be universal. **→ SC-1**

- [ ] 6. **GREEN — Update critical-rules-037 in 000-critical-rules.md (**sub-agent**).** Edit the critical-rules-037 entry to remove the `for_pr` scope qualifier. The rule must state the question tool is prohibited universally. **→ SC-1**

- [ ] 7. **GREEN — Update 010-approval-gate.md edge case table (**sub-agent**).** Edit the Key Edge Cases table row for `for_pr scope → no halt for structural decisions` to reference the universal critical-rules-037 (no scope qualifier). **→ SC-1**

- [ ] 8. **GREEN — Remove scope qualifier from pre-implementation-analysis.md (**sub-agent**).** Edit line 46 of `.opencode/skills/approval-gate-scope/tasks/pre-implementation-analysis.md` to remove the `after presenting the execution plan` qualifier. The question tool prohibition must be universal. **→ SC-1**

- [ ] 9. **GREEN — Remove contradictory instruction from 140-planning-spec-creation.md (**sub-agent**).** Edit line 57 of `.opencode/guidelines/140-planning-spec-creation.md` to remove or replace the `Use the question tool with a list of available specs` instruction. **→ SC-6**

- [ ] 10. **GREEN doublecheck (**clean-room**).** Verify all 5 files have correct changes:
  - `020-go-prohibitions.md` has top-level Tier 1 question tool prohibition (no scope qualifier)
  - `000-critical-rules.md` critical-rules-037 has no `for_pr` scope qualifier
  - `010-approval-gate.md` edge case table references universal critical-rules-037
  - `pre-implementation-analysis.md` has no `after presenting the execution plan` qualifier
  - `140-planning-spec-creation.md` has no question tool instruction
  - **→ SC-1, SC-6**

- [ ] 11. **Checkpoint commit (**inline**).** `git add .opencode/guidelines/020-go-prohibitions.md .opencode/guidelines/000-critical-rules.md .opencode/guidelines/010-approval-gate.md .opencode/skills/approval-gate-scope/tasks/pre-implementation-analysis.md .opencode/guidelines/140-planning-spec-creation.md .opencode/tests-v2/behaviors/universal-question-tool-prohibition.sh && git commit -m "Phase 1: Universal question tool prohibition — remove scope qualifiers from 5 files"`

#### Phase 1 VbC

- [ ] 12. **VbC (**clean-room**).** Verify SC-1 (behavioral): dispatch `behavioral-test-evaluation` from `verification-before-completion`. Clean-room sub-agent reads `{project_root}/tmp/behavioral-evidence-*/` artifacts and evaluates whether the agent's behavior matches SC-1 (question tool prohibited universally). Verify SC-6 (string): grep `140-planning-spec-creation.md` for absence of question tool reference. **→ SC-1, SC-6**

**Concern transition:** Leaving universal question tool prohibition → entering pigeon-holing in natural language prohibition. Phase 2 depends on Phase 1's modified `020-go-prohibitions.md` and `000-critical-rules.md` as the baseline for adding new rules.
