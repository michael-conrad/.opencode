# Work State: 11-Issue Batch Authorization for PR

**Created:** 2026-04-29
**Authorization scope:** for_pr
**Authorization phrase:** "approved for pr 239 240 232 229 228 227 225 224 219 217 201"
**Branch:** feature/238-240-232-229-228-227-225-224-219-217-201
**Dev base:** d32d892 (Merge pull request #15)
**Submodule base:** 4f09fa0 (dev tip at time of pre-work)
**pr_strategy:** stacked

## Issues (Dependency Order)

### Phase 1 (Independent — no upstream dependencies)
| # | Issue | Type | Target Repo | Classification |
|---|-------|------|-------------|----------------|
| 239 | Shell scripts hardcoded depth | SPEC-FIX | michael-conrad/.opencode | clearly_simple |
| 240 | Enforcement gaps (spec-checklist, for_pr evidence, uncommitted-work) | SPEC-FIX | michael-conrad/.opencode | clearly_simple |
| 219 | Spec/Plan mandatory tasks checkboxes | SPEC-FIX | michael-conrad/.opencode | complex (6 phases) |
| 227 | Bug: Question-response gate | SPEC-FIX | michael-conrad/.opencode | complex (behavioral) |
| 228 | Bug: Issue-operations routing gate | BUG | michael-conrad/.opencode | complex (routing) |
| 217 | Pre-push hook for branch topology | FEATURE | michael-conrad/.opencode | complex (new code) |
| 201 | Plan: Submodule-aware workflow | PLAN | michael-conrad/.opencode | complex (multi-phase) |

### Phase 2 (Independent but stacked after Phase 1)
| # | Issue | Type | Target Repo | Classification |
|---|-------|------|-------------|----------------|
| 232 | Submodule-aware workflow state discovery | SPEC | michael-conrad/.opencode | complex (new workflow) |
| 224 | Cleanup must document submodule handling | SPEC | michael-conrad/.opencode | clearly_simple |
| 225 | Release-promotion no pointer-bump PRs | SPEC-FIX | michael-conrad/.opencode | clearly_simple |

### Phase 3 (Depends on Phase 1 — #227 and #228)
| # | Issue | Type | Target Repo | Classification |
|---|-------|------|-------------|----------------|
| 229 | Plan: Fix Bugs #227+#228 | PLAN | michael-conrad/.opencode | complex (orchestration) |

## Gap Fill Actions
- All issues: for_pr scope auto-approves and auto-creates plans where missing
- #227, #228: Bug reports need fix-spec sub-issues (gap-fill creates)
- #229: Plan needs sub-issues for Phase 1 (Q-response gate) and Phase 2 (routing gate)
- #219: 6-phase plan needs sub-issues
- #201: 4-phase plan needs sub-issues

## Routing
- All files under .opencode/ → michael-conrad/.opencode (GitHub owner: michael-conrad, repo: .opencode)
- Parent repo changes (only .opencode submodule pointer) → michael-conrad/opencode-config