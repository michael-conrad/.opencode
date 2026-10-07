# Plan: Remove description truncation from buildSkillIndex()

**Spec:** https://github.com/michael-conrad/.opencode/issues/1124
**File:** `plugins/session-enforcement.ts` (1229 lines)
**Type:** Single-task (one phase)

---

## Phase 1: Remove truncation at session-enforcement.ts:568

**Concern:** The `buildSkillIndex()` function truncates skill descriptions to the first sentence only, silently removing routing mandates and procedural instructions from the Skill Index table in the system prompt.

**Files:** `plugins/session-enforcement.ts`
**SCs covered:** SC-1, SC-2, SC-3

**Routing key:** Orchestrator tasks sub-agents via task(). Pre-analysis sub-agents discover scope independently.

- [ ] 1. SC-COHERENCE-GATE — **orchestrator** routes to `pre-analysis` sub-agent: verify SC-1 and SC-3 are consistent and both satisfied by the same line change. Sub-agent returns PASS/BLOCKED.
- [ ] 2. PRE-RED-BASELINE — **orchestrator** routes to exploration sub-agent: run `PATH=.tools/node/bin:$PATH npx tsc --noEmit`, confirm PASS. Report return code.
- [ ] 3. RED-PHASE — **orchestrator** routes to RED sub-agent:
  - Write enforcement test at `.opencode/tests/behaviors/sc-1124-truncation.sh`:
    ```bash
    # SC-1: Verify no split(".")[0] truncation in .ts plugin files
    if grep -q 'split(".")\[0\]' plugins/session-enforcement.ts; then
        echo "FAIL: truncation pattern found"
        exit 1
    fi
    echo "PASS: no truncation pattern found"
    exit 0
    ```
  - Run test → expected FAIL (exit non-zero) → capture output to `./tmp/1124/artifacts/phase1-test-output.log`
  - Sub-agent returns test file path + artifact path + exit code
- [ ] 4. RED-DOUBLECHECK — **orchestrator** reads artifact `./tmp/1124/artifacts/phase1-test-output.log`, confirms non-zero exit. If PASS (exit 0), re-task RED sub-agent.
- [ ] 5. GREEN-PHASE — **orchestrator** routes to GREEN sub-agent (clean-room, receives only spec + test file path):
  - Edit `plugins/session-enforcement.ts:568-570`: replace `const shortDesc = s.description.split(".")[0].trim() + ".";` with full `s.description` usage (remove line 568, change line 570 from `shortDesc` to `s.description`)
  - Run test at `.opencode/tests/behaviors/sc-1124-truncation.sh` → expected PASS (exit 0) → append output to `./tmp/1124/artifacts/phase1-test-output.log`
  - Sub-agent returns artifact path + exit code + diff summary
- [ ] 6. CHECKPOINT-COMMIT — **orchestrator** inline: `git add . && git commit -m "phase 1 checkpoint: remove description truncation from buildSkillIndex()"`. Verify exit 0.
- [ ] 7. STRUCTURAL-CHECKS — **orchestrator** routes to structural sub-agent: run `PATH=.tools/node/bin:$PATH npx tsc --noEmit`. Report PASS/FAIL.
- [ ] 8. GREEN-DOUBLECHECK — **orchestrator** reads artifact `./tmp/1124/artifacts/phase1-test-output.log`, confirms exit 0 from GREEN run.
- [ ] 9. GREEN-VBC — **orchestrator** routes to VbC sub-agent: verify SC-1 (grep for `split(".")[0]` in plugins/ returns no matches), SC-3 (grep for `s.description` on line 570, not `shortDesc`). Sub-agent returns PASS/FAIL per SC.
- [ ] 10. ADVERSARIAL-AUDIT — **orchestrator** routes to resolve-models, dispatches 2 auditors for plan-fidelity + concern-separation. Auditors receive spec + deliverable only. Returns consensus.
- [ ] 11. CROSS-VALIDATE — **orchestrator** verifies dual-auditor consensus. No disagreement = proceed. DISAGREE = re-mediate.
- [ ] 12. REGRESSION-CHECK — **orchestrator** routes to regression sub-agent: run `PATH=.tools/node/bin:$PATH npx tsc --noEmit`. Confirm full project PASS.
- [ ] 13. REVIEW-PREP — **orchestrator** routes to review-prep sub-agent: generate compare URL `https://github.com/michael-conrad/.opencode/compare/dev...<branch>`, draft PR body describing the single-line change and why sentence truncation was harmful. Returns URL + body.
- [ ] 14. EXEC-SUMMARY — **orchestrator** reads all sub-agent result contracts, produces: SC-1 PASS, SC-3 PASS, no truncation pattern in plugins/, full description now displayed in Skill Index table.

---

## Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST — **orchestrator** routes to finishing sub-agent: git status clean, tsc --noEmit PASS. Returns PASS/BLOCKED.
- [ ] PR CREATION — **orchestrator** routes to git-workflow pr-creation: uses review-prep output from gate 13. Creates PR via `github_create_pull_request`, extracts `html_url` from response.
- [ ] POST-MERGE CLEANUP — **orchestrator** routes to git-workflow cleanup: delete merged branch, close issue #1124, sync dev. (Only after PR merge — not immediate.)