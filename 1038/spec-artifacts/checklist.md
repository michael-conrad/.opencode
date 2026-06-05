# Pipeline Checklist — #1038

## Phase 1: Pre-Work

- [ ] 1.1 Sync dev: `git checkout dev && git pull`
- [ ] 1.2 Sync submodule: `git submodule update --init && git -C .opencode checkout dev && git -C .opencode pull`
- [ ] 1.3 Issue info: #1038
- [ ] 1.4 Search for existing plan
- [ ] 1.5 Create feature branch: `feature/1038-session-init-tools`
- [ ] 1.6 Tag submodule: `opencode-config/checkpoint/1038/phase-1-.opencode`
- [ ] 1.7 Apply `approved-for-pr` label

## Phase 2: Verify Authorization

- [ ] 2.1 Read all issue comments
- [ ] 2.2 Confirm authorization scope: `for_pr`, halt_at `pr_created`
- [ ] 2.3 Check for superseding issues
- [ ] 2.4 Verify SC evidence types declared
- [ ] 2.5 Verify SC-to-test traceability
- [ ] 2.6 Gap-fill cascade: spec exists → create plan

## Phase 3: Create Plan

- [ ] 3.1 Load `writing-plans` skill
- [ ] 3.2 Task sub-agent: create plan
- [ ] 3.3 Verify plan has all items, TDD steps, file paths
- [ ] 3.4 Push plan to `.opencode/.issues/1038/spec-artifacts/`

## Phase 4: Adversarial Audit — Plan

- [ ] 4.1 Resolve models for dual cross-family auditors
- [ ] 4.2 Task `plan-fidelity` audit (gemma4)
- [ ] 4.3 Task `concern-separation` audit (deepseek-flash)
- [ ] 4.4 Resolve any audit findings before proceeding

## Phase 5: Implementation Items

### Item A: session-init emission (SC-1, SC-3)

- [ ] 5.1 Pre-analysis: inspect session-init code structure
- [ ] 5.2 RED: verify section absent: `grep -q '## Agent Tools'` → exit 1
- [ ] 5.3 GREEN: add `get_agent_tools_help()` + emit block after ## Repo Information
- [ ] 5.4 VERIFY: grep confirms section, lint + typecheck pass

### Item B: content-verification test (SC-3)

- [ ] 5.5 RED: verify `session-init-tools-section` absent → exit 1
- [ ] 5.6 GREEN: register SCENARIOS + FILE_SCENARIO_MAP entries
- [ ] 5.7 VERIFY: `grep -c` → 2+ matches

### Item C: behavioral test (SC-2)

- [ ] 5.8 RED: verify `tool-injection-red.sh` exists with correct prompt
- [ ] 5.9 GREEN: confirm no changes needed (behavioral diff from session-init)
- [ ] 5.10 VERIFY: SPDX header, helpers.sh, behavior_run, exit 0

## Phase 6: Completeness Gate

- [ ] 6.1 All 3 items present and verified
- [ ] 6.2 All SCs addressed
- [ ] 6.3 No scope creep (nothing outside spec)
- [ ] 6.4 File changes match spec's affected files list

## Phase 7: Adversarial Audit — Implementation

- [ ] 7.1 Task `spec-audit` — verify implementation matches spec SCs
- [ ] 7.2 Task `coherence-maintenance` — verify no existing behavior broken
- [ ] 7.3 Resolve any audit findings

## Phase 8: Verification-Before-Completion

- [ ] 8.1 SC-1: `grep -q '## Agent Tools' <(./.opencode/tools/session-init 2>/dev/null)` → exit 0
- [ ] 8.2 SC-2: Behavioral test artifacts generated; stdout shows `.opencode/tools/*` names
- [ ] 8.3 SC-3: `bash .opencode/tests/test-enforcement.sh --scenario session-init-tools-section` → PASS
- [ ] 8.4 Ruff: `ruff check --fix .opencode/tools/session-init` → clean
- [ ] 8.5 Pyright: `pyright .opencode/tools/session-init` → clean
- [ ] 8.6 Per-SC evidence table written to `./tmp/`

## Phase 9: Finishing Checklist

- [ ] 9.1 All changes committed
- [ ] 9.2 `git status` clean
- [ ] 9.3 Branch ahead of dev: `git log origin/dev..HEAD`
- [ ] 9.4 Commit message references issue #1038
- [ ] 9.5 No debug artifacts in working tree

## Phase 10: Review Prep

- [ ] 10.1 Single commit for all items
- [ ] 10.2 Compare URL base branch is `dev`
- [ ] 10.3 PR body: Summary → Changes → SC Status → Byline
- [ ] 10.4 `html_url` extracted from API response, not constructed

## Phase 11: PR Creation

- [ ] 11.1 Push branch: `git push -u origin feature/1038-session-init-tools`
- [ ] 11.2 Create PR via `github_create_pull_request`
- [ ] 11.3 Extract PR URL from API response `html_url`
- [ ] 11.4 Report: Summary → Outcome → URL → Byline

## Phase 12: Post-Halt

- [ ] 12.1 `todowrite(todos=[])`
- [ ] 12.2 Structured halt message with SC status table