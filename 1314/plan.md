---
issue: 1314
spec: .opencode/.issues/1314/spec.md
plan_structure: separate
authorization_scope: for_pr
halt_at: pr_created
pr_strategy: stacked
generated_at: "20260622020000"
---

# Plan: Playwright CLI as First-Class Browser Automation Entry Point

## Phase 1: Deletion

**Concern:** Remove `ui-design` and `ui-engineer` skill directories and all contents.

**SCs:** SC-1

**Affected Files:**
- `.opencode/skills/ui-design/` (entire directory)
- `.opencode/skills/ui-engineer/` (entire directory)

- [ ] 1. sc-coherence-gate — **sub-task**
  - [ ] Verify SC-1 maps to deletion concern
  - [ ] Confirm affected files listed correctly
  - [ ] Validate phase entry criteria met
- [ ] 2. pre-red-baseline — **sub-task**
  - [ ] Snapshot current state of deletion targets
  - [ ] Record baseline evidence artifact
  - [ ] Confirm no blocking dependencies
- [ ] 3. red-phase — **sub-task**
  - [ ] Implement RED conditions per SC-1
  - [ ] Verify failure condition exists
  - [ ] Record RED artifact to disk
- [ ] 4. red-doublecheck — **sub-task**
  - [ ] Independent verification of RED artifact
  - [ ] Confirm RED matches spec requirements
  - [ ] Flag discrepancies
- [ ] 5. post-red-enforcement — **sub-task**
  - [ ] Enforce RED quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 6. green-phase — **sub-task**
  - [ ] Implement GREEN conditions per SC-1
  - [ ] Delete target directories
  - [ ] Record GREEN artifact to disk
- [ ] 7. post-green-enforcement — **sub-task**
  - [ ] Enforce GREEN quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 8. checkpoint-commit — **inline**
  - [ ] Git commit deletion changes
  - [ ] Tag checkpoint
- [ ] 9. structural-checks — **inline**
  - [ ] Run ruff, pyright, mdformat
  - [ ] Record check results
- [ ] 10. green-doublecheck — **sub-task**
  - [ ] Independent verification of GREEN artifact
  - [ ] Confirm deletion complete
  - [ ] Flag discrepancies
- [ ] 11. green-vbc — **sub-task**
  - [ ] Verify behavioral correctness
  - [ ] Confirm SC-1 satisfied
  - [ ] Record VbC evidence
- [ ] 12. adversarial-audit — **sub-task**
  - [ ] Dual-auditor cross-validation
  - [ ] Independent SC-1 verification
  - [ ] Record audit findings
- [ ] 13. cross-validate — **sub-task**
  - [ ] Cross-validate audit findings
  - [ ] Confirm consensus
  - [ ] Record cross-validation evidence
- [ ] 14. regression-check — **inline**
  - [ ] Run existing tests
  - [ ] Verify no regressions
- [ ] 15. review-prep — **sub-task**
  - [ ] Prepare review artifacts
  - [ ] Generate review summary
- [ ] 16. exec-summary — **sub-task**
  - [ ] Generate executive summary
  - [ ] Post completion report

## Phase 2: Creation

**Concern:** Create `playwright-cli` skill directory adapted from upstream `microsoft/playwright-cli` repo.

**SCs:** SC-2

**Affected Files:**
- `.opencode/skills/playwright-cli/` (new directory)
- `.opencode/skills/playwright-cli/SKILL.md` (new)

- [ ] 1. sc-coherence-gate — **sub-task**
  - [ ] Verify SC-2 maps to creation concern
  - [ ] Confirm upstream reference identified
  - [ ] Validate phase entry criteria met
- [ ] 2. pre-red-baseline — **sub-task**
  - [ ] Snapshot upstream skill files
  - [ ] Record baseline evidence artifact
  - [ ] Confirm no blocking dependencies
- [ ] 3. red-phase — **sub-task**
  - [ ] Implement RED conditions per SC-2
  - [ ] Verify failure condition exists
  - [ ] Record RED artifact to disk
- [ ] 4. red-doublecheck — **sub-task**
  - [ ] Independent verification of RED artifact
  - [ ] Confirm RED matches spec requirements
  - [ ] Flag discrepancies
- [ ] 5. post-red-enforcement — **sub-task**
  - [ ] Enforce RED quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 6. green-phase — **sub-task**
  - [ ] Implement GREEN conditions per SC-2
  - [ ] Create skill directory from upstream
  - [ ] Record GREEN artifact to disk
- [ ] 7. post-green-enforcement — **sub-task**
  - [ ] Enforce GREEN quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 8. checkpoint-commit — **inline**
  - [ ] Git commit creation changes
  - [ ] Tag checkpoint
- [ ] 9. structural-checks — **inline**
  - [ ] Run ruff, pyright, mdformat
  - [ ] Record check results
- [ ] 10. green-doublecheck — **sub-task**
  - [ ] Independent verification of GREEN artifact
  - [ ] Confirm creation complete
  - [ ] Flag discrepancies
- [ ] 11. green-vbc — **sub-task**
  - [ ] Verify behavioral correctness
  - [ ] Confirm SC-2 satisfied
  - [ ] Record VbC evidence
- [ ] 12. adversarial-audit — **sub-task**
  - [ ] Dual-auditor cross-validation
  - [ ] Independent SC-2 verification
  - [ ] Record audit findings
- [ ] 13. cross-validate — **sub-task**
  - [ ] Cross-validate audit findings
  - [ ] Confirm consensus
  - [ ] Record cross-validation evidence
- [ ] 14. regression-check — **inline**
  - [ ] Run existing tests
  - [ ] Verify no regressions
- [ ] 15. review-prep — **sub-task**
  - [ ] Prepare review artifacts
  - [ ] Generate review summary
- [ ] 16. exec-summary — **sub-task**
  - [ ] Generate executive summary
  - [ ] Post completion report

## Phase 3: Reference Cleanup

**Concern:** Remove all references to deleted skills from guidelines, tests, and registry files.

**SCs:** SC-3

**Affected Files:**
- `.opencode/guidelines/INDEX.md`
- `.opencode/tests/` (all test files referencing ui-design or ui-engineer)
- `.opencode/AGENTS.md`
- Any other files referencing deleted skills

- [ ] 1. sc-coherence-gate — **sub-task**
  - [ ] Verify SC-3 maps to reference-cleanup concern
  - [ ] Confirm affected files listed correctly
  - [ ] Validate phase entry criteria met
- [ ] 2. pre-red-baseline — **sub-task**
  - [ ] Snapshot current state of reference files
  - [ ] Record baseline evidence artifact
  - [ ] Confirm no blocking dependencies
- [ ] 3. red-phase — **sub-task**
  - [ ] Implement RED conditions per SC-3
  - [ ] Verify failure condition exists
  - [ ] Record RED artifact to disk
- [ ] 4. red-doublecheck — **sub-task**
  - [ ] Independent verification of RED artifact
  - [ ] Confirm RED matches spec requirements
  - [ ] Flag discrepancies
- [ ] 5. post-red-enforcement — **sub-task**
  - [ ] Enforce RED quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 6. green-phase — **sub-task**
  - [ ] Implement GREEN conditions per SC-3
  - [ ] Remove deleted skill references
  - [ ] Record GREEN artifact to disk
- [ ] 7. post-green-enforcement — **sub-task**
  - [ ] Enforce GREEN quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 8. checkpoint-commit — **inline**
  - [ ] Git commit reference cleanup changes
  - [ ] Tag checkpoint
- [ ] 9. structural-checks — **inline**
  - [ ] Run ruff, pyright, mdformat
  - [ ] Record check results
- [ ] 10. green-doublecheck — **sub-task**
  - [ ] Independent verification of GREEN artifact
  - [ ] Confirm reference cleanup complete
  - [ ] Flag discrepancies
- [ ] 11. green-vbc — **sub-task**
  - [ ] Verify behavioral correctness
  - [ ] Confirm SC-3 satisfied
  - [ ] Record VbC evidence
- [ ] 12. adversarial-audit — **sub-task**
  - [ ] Dual-auditor cross-validation
  - [ ] Independent SC-3 verification
  - [ ] Record audit findings
- [ ] 13. cross-validate — **sub-task**
  - [ ] Cross-validate audit findings
  - [ ] Confirm consensus
  - [ ] Record cross-validation evidence
- [ ] 14. regression-check — **inline**
  - [ ] Run existing tests
  - [ ] Verify no regressions
- [ ] 15. review-prep — **sub-task**
  - [ ] Prepare review artifacts
  - [ ] Generate review summary
- [ ] 16. exec-summary — **sub-task**
  - [ ] Generate executive summary
  - [ ] Post completion report

## Phase 4: Gitignore

**Concern:** Add `.tools/` entry to `.gitignore` to prevent tracking project-local tool installations.

**SCs:** SC-4

**Affected Files:**
- `.gitignore`

- [ ] 1. sc-coherence-gate — **sub-task**
  - [ ] Verify SC-4 maps to gitignore concern
  - [ ] Confirm .gitignore affected
  - [ ] Validate phase entry criteria met
- [ ] 2. pre-red-baseline — **sub-task**
  - [ ] Snapshot current .gitignore state
  - [ ] Record baseline evidence artifact
  - [ ] Confirm no blocking dependencies
- [ ] 3. red-phase — **sub-task**
  - [ ] Implement RED conditions per SC-4
  - [ ] Verify failure condition exists
  - [ ] Record RED artifact to disk
- [ ] 4. red-doublecheck — **sub-task**
  - [ ] Independent verification of RED artifact
  - [ ] Confirm RED matches spec requirements
  - [ ] Flag discrepancies
- [ ] 5. post-red-enforcement — **sub-task**
  - [ ] Enforce RED quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 6. green-phase — **sub-task**
  - [ ] Implement GREEN conditions per SC-4
  - [ ] Add .tools/ to .gitignore
  - [ ] Record GREEN artifact to disk
- [ ] 7. post-green-enforcement — **sub-task**
  - [ ] Enforce GREEN quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 8. checkpoint-commit — **inline**
  - [ ] Git commit gitignore changes
  - [ ] Tag checkpoint
- [ ] 9. structural-checks — **inline**
  - [ ] Run ruff, pyright, mdformat
  - [ ] Record check results
- [ ] 10. green-doublecheck — **sub-task**
  - [ ] Independent verification of GREEN artifact
  - [ ] Confirm gitignore update complete
  - [ ] Flag discrepancies
- [ ] 11. green-vbc — **sub-task**
  - [ ] Verify behavioral correctness
  - [ ] Confirm SC-4 satisfied
  - [ ] Record VbC evidence
- [ ] 12. adversarial-audit — **sub-task**
  - [ ] Dual-auditor cross-validation
  - [ ] Independent SC-4 verification
  - [ ] Record audit findings
- [ ] 13. cross-validate — **sub-task**
  - [ ] Cross-validate audit findings
  - [ ] Confirm consensus
  - [ ] Record cross-validation evidence
- [ ] 14. regression-check — **inline**
  - [ ] Run existing tests
  - [ ] Verify no regressions
- [ ] 15. review-prep — **sub-task**
  - [ ] Prepare review artifacts
  - [ ] Generate review summary
- [ ] 16. exec-summary — **sub-task**
  - [ ] Generate executive summary
  - [ ] Post completion report

## Phase 5: Verification

**Concern:** Confirm zero references to deleted skills, directories absent, new skill exists with correct content.

**SCs:** SC-5

**Affected Files:** None (verification phase — reads all modified files)

- [ ] 1. sc-coherence-gate — **sub-task**
  - [ ] Verify SC-5 maps to verification concern
  - [ ] Confirm all phase artifacts available
  - [ ] Validate phase entry criteria met
- [ ] 2. pre-red-baseline — **sub-task**
  - [ ] Snapshot post-phase-1-4 state
  - [ ] Record baseline evidence artifact
  - [ ] Confirm no blocking dependencies
- [ ] 3. red-phase — **sub-task**
  - [ ] Implement RED conditions per SC-5
  - [ ] Verify failure condition exists
  - [ ] Record RED artifact to disk
- [ ] 4. red-doublecheck — **sub-task**
  - [ ] Independent verification of RED artifact
  - [ ] Confirm RED matches spec requirements
  - [ ] Flag discrepancies
- [ ] 5. post-red-enforcement — **sub-task**
  - [ ] Enforce RED quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 6. green-phase — **sub-task**
  - [ ] Implement GREEN conditions per SC-5
  - [ ] Verify zero references, directories absent, new skill exists
  - [ ] Record GREEN artifact to disk
- [ ] 7. post-green-enforcement — **sub-task**
  - [ ] Enforce GREEN quality gates
  - [ ] Verify artifact format compliance
  - [ ] Record enforcement evidence
- [ ] 8. checkpoint-commit — **inline**
  - [ ] Git commit verification changes
  - [ ] Tag checkpoint
- [ ] 9. structural-checks — **inline**
  - [ ] Run grep, ls verification
  - [ ] Record check results
- [ ] 10. green-doublecheck — **sub-task**
  - [ ] Independent verification of GREEN artifact
  - [ ] Confirm verification complete
  - [ ] Flag discrepancies
- [ ] 11. green-vbc — **sub-task**
  - [ ] Verify behavioral correctness
  - [ ] Confirm SC-5 satisfied
  - [ ] Record VbC evidence
- [ ] 12. adversarial-audit — **sub-task**
  - [ ] Dual-auditor cross-validation
  - [ ] Independent SC-5 verification
  - [ ] Record audit findings
- [ ] 13. cross-validate — **sub-task**
  - [ ] Cross-validate audit findings
  - [ ] Confirm consensus
  - [ ] Record cross-validation evidence
- [ ] 14. regression-check — **inline**
  - [ ] Run existing tests
  - [ ] Verify no regressions
- [ ] 15. review-prep — **sub-task**
  - [ ] Prepare review artifacts
  - [ ] Generate review summary
- [ ] 16. exec-summary — **sub-task**
  - [ ] Generate executive summary
  - [ ] Post completion report

## Dependency Graph

```
Phase 1 (deletion) ─────┬──→ Phase 2 (creation)
                        ├──→ Phase 3 (reference-cleanup)
Phase 4 (gitignore) ────┤
                        └──→ Phase 5 (verification) ←── all phases
```

- Phase 1 → Phase 2: creation depends on deletion completing (directories must be gone before new skill is created)
- Phase 1 → Phase 3: reference cleanup depends on deletion (references point to deleted files)
- Phase 4: independent (can run in parallel with Phase 1-3)
- Phase 5: depends on all prior phases (final verification)

## Dependency Ordering Contract

See `.opencode/.issues/1314/dependency-ordering-verification/ordering.yaml` for Z3-verified ordering.

## SC-ID Mapping

| SC-ID | Phase | Concern | Evidence Type |
|-------|-------|---------|---------------|
| SC-1 | 1 (deletion) | Delete ui-design and ui-engineer directories | structural |
| SC-2 | 2 (creation) | Create playwright-cli skill from upstream | behavioral |
| SC-3 | 3 (reference-cleanup) | Remove deleted skill references | string |
| SC-4 | 4 (gitignore) | Add .tools/ to .gitignore | structural |
| SC-5 | 5 (verification) | Confirm zero references, directories absent | behavioral |
