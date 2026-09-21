# Plan Input Verification Ledger — .opencode#2457

Written once by writing-plans/tasks/create, 2026-09-21. Re-read THIS ledger; do not re-verify sources.

## Issue state + labels (from issue.yaml)

- Issue .opencode#2457, title "[SPEC] stacked into existing work (#2456)", status open
- Labels: needs-approval, spec-draft, approved-for-pr
- After plan creation: add `spec-cleared` (local-issues update .opencode#2457 --labels needs-approval spec-draft approved-for-pr spec-cleared — replaces whole array)

## SC list with evidence types (from spec.md)

| SC | Criterion (condensed) | Evidence type | Verification method |
|----|----------------------|---------------|---------------------|
| SC-1 | Explore deck defines explicit finalization gate at Step 6→7: non-finalization classified as discussion input, agent holds discussion mode | behavioral (via SC-2/SC-3) | Behavioral runs via `with-test-home opencode run`, clean-room session.yaml inspection |
| SC-2 | Behavioral scenario registered in test-enforcement.sh (SCENARIOS, SCENARIO_TAGS, FILE_SCENARIO_MAP); refinement-only run → spec-creation dispatch ABSENT | behavioral | `test-enforcement.sh --scenario <name>`; session.yaml inspection; `--list`/`--list-tags` for registration |
| SC-3 | Same scenario's finalization run → spec-creation dispatch PRESENT | behavioral | `test-enforcement.sh --scenario <name>`; session.yaml inspection |

## Structure artifact mappings (structure.yaml)

- Phase A: "Finalization gate in brainstorming explore deck" — SC-1 — files: .opencode/skills/brainstorming/tasks/explore.md + explore/exploration-workflow.md
- Phase B: "Behavioral enforcement scenarios" — SC-2, SC-3 — files: .opencode/tests-v2/behaviors/<scenario>.sh + test-enforcement.sh registrations
- DAG: A → B (SC-2/SC-3 behavioral runs require SC-1 gate committed AND pushed: commit → push → fresh fetch → remote-ref containment → run, per 091 behavioral ordering)
- No circular dependencies; no RED depends on later-phase output

## Per-task cycle steps (implementation-workflow reference card)

Pre-implementation: pre-regression, pre-regression-verify.
Per-item: red, green, post-regression, verify, commit-inline (orchestrator direct).
Post-implementation: audit, z3-check, structural-checks, pre-pr-gate, regression-check, review-prep, create-pr, exec-summary.
Behavioral variant ordering: COMMIT + PUSH precede behavioral run.

## CLI surface flags needed

- `./.opencode/tools/local-issues update .opencode#2457 --labels <all labels + spec-cleared>`
- `bash .opencode/tests-v2/test-enforcement.sh --scenario <name>` / `--list` / `--list-tags`
- Behavioral runs: `bash .opencode/tests-v2/with-test-home opencode run '<message>'`
- Z3: `.opencode/tools/solve check --state-path ... --contract-path ...`
- Push gates: `git push`, fresh `git fetch`, `git branch -r --contains <sha>`
- Stale-lock hygiene: `rm -f tmp/.behavior-run.lock` before behavioral runs

## Authorization context

Stacked into existing for_pr work on .opencode#2456 (spec §6). pr_strategy: stacked. Feature branch shared with #2456.
