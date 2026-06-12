# Plan: Remove description truncation from buildSkillIndex()

**Spec:** https://github.com/michael-conrad/.opencode/issues/1124
**File:** `plugins/session-enforcement.ts` (1229 lines)
**Type:** Single-task (one phase)

---

## Phase 1: Remove truncation at session-enforcement.ts:568

**Concern:** The `buildSkillIndex()` function truncates skill descriptions to the first sentence only, silently removing routing mandates and procedural instructions from the Skill Index table in the system prompt.

**Files:** `plugins/session-enforcement.ts`
**SCs covered:** SC-1, SC-3

- [ ] 1. SC-COHERENCE-GATE: verify SCs are internally consistent — SC-1 bans `split(".")[0]` in any `.ts` plugin file, SC-3 requires `full s.description`. One change (line 568) satisfies both.
- [ ] 2. PRE-RED-BASELINE: run `PATH=.tools/node/bin:$PATH npx tsc --noEmit` — confirm all TypeScript checks PASS before any changes.
- [ ] 3. RED-PHASE: write enforcement test at `.opencode/tests/behaviors/sc-1124-truncation.sh` → run → expected FAIL (exit non-zero) → output logged to `./tmp/1124/artifacts/phase1-test-output.log`

**Test script (.opencode/tests/behaviors/sc-1124-truncation.sh):**
```bash
# SC-1: Verify no split(".")[0] truncation in .ts plugin files
if grep -q 'split(".")\[0\]' plugins/session-enforcement.ts; then
    echo "FAIL: truncation pattern found"
    exit 1
fi
echo "PASS: no truncation pattern found"
exit 0
```

- [ ] 4. RED-DOUBLECHECK: confirm artifact `./tmp/1124/artifacts/phase1-test-output.log` shows non-zero exit (test FAILS because line 568 still has `split(".")[0]`)
- [ ] 5. GREEN-PHASE: remove line 568 (`const shortDesc = ...`) and replace `shortDesc` with `s.description` on line 570. Run enforcement test → expected PASS (exit 0) → output logged to `./tmp/1124/artifacts/phase1-test-output.log`
- [ ] 6. CHECKPOINT-COMMIT: `git commit -m "phase 1 checkpoint: remove description truncation from buildSkillIndex()"`
- [ ] 7. STRUCTURAL-CHECKS: `PATH=.tools/node/bin:$PATH npx tsc --noEmit`
- [ ] 8. GREEN-DOUBLECHECK: confirm artifact shows exit 0
- [ ] 9. GREEN-VBC: verify SC-1 (string) and SC-3 (string) — grep for `split(".")[0]` in plugins/ returns no matches, grep for `s.description` (not shortDesc) at line 570
- [ ] 10. ADVERSARIAL-AUDIT: resolve-models → plan-fidelity + concern-separation
- [ ] 11. CROSS-VALIDATE: dual-auditor consensus on SC-1 and SC-3
- [ ] 12. REGRESSION-CHECK: `PATH=.tools/node/bin:$PATH npx tsc --noEmit` — full project type check PASS
- [ ] 13. REVIEW-PREP: compare URL `https://github.com/michael-conrad/.opencode/compare/dev...<branch>` — PR body describing the single-line change and why sentence truncation was harmful
- [ ] 14. EXEC-SUMMARY: SC-1 PASS, SC-3 PASS, no truncation pattern in plugins/, full description now displayed in Skill Index table

---

## Post-All-Phases Sweep

- [ ] FINISHING CHECKLIST: git status clean, tsc --noEmit PASS
- [ ] PR CREATION: via github_create_pull_request, extract html_url from response
- [ ] POST-MERGE CLEANUP: delete merged branch, close issue #1124, sync dev