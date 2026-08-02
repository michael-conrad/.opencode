# Plan — Skill Deck Completeness Validation

**Issue:** #2229
**Spec:** `.opencode/.issues/2229/spec.md`
**Research:** `.opencode/.issues/2229/artifacts/research.yaml`
**Reference:** `.opencode/skills/writing-plans/reference/implementation-workflow.md`

## Dependency DAG

```
Phase 1 (Tooling) ──┬──→ Phase 3 (CI test)
                     ├──→ Phase 4 (Behavioral test)
                     ├──→ Phase 5 (.opencode/AGENTS.md)
                     └──→ Phase 6 (root AGENTS.md)
Phase 2 (Critical rule) ──→ Phase 4 (Behavioral test)
```

**Parallelizable groups:**
- Group 1: Phase 1 + Phase 2 (roots, no dependencies)
- Group 2: Phase 3 + Phase 5 + Phase 6 (depend on Phase 1 only)
- Group 3: Phase 4 (depends on Phase 1 + Phase 2)

## Per-Task Cycle

Every phase follows the per-task cycle from the [implementation-workflow reference card](.opencode/skills/writing-plans/reference/implementation-workflow.md):

| Step | Skill | Dispatch | Description |
|------|-------|----------|-------------|
| RED | test-driven-development | `task(..., prompt: "execute red task from test-driven-development")` | Write a failing enforcement test for the SC |
| GREEN | test-driven-development | `task(..., prompt: "execute green task from test-driven-development")` | Implement the change that makes the test pass |
| verify | verification-before-completion | `task(..., prompt: "execute verify task from verification-before-completion")` | Verify implementation against success criteria |
| commit | (orchestrator) | `git add <files> && git commit -m "<message>"` | Stage and commit changes |

---

## Phase 1: Tooling — Extend skildeck lint

**SC:** SC-1 — `skildeck lint` extended with `--completeness` flag for structural checks
**Evidence type:** behavioral
**Depends on:** (none — root phase)
**Skill+task:** test-driven-development — RED then GREEN then verify

### RED
1. Dispatch `task(..., prompt: "execute red task from test-driven-development")`
2. Write a failing test that creates a temporary broken skill deck (missing SKILL.md, broken TDT reference, tasks/ dir without SKILL.md) and runs `skildeck lint --completeness` against it
3. Assert stderr contains `MISSING_SKILL_MD`, `MISSING_TASK_FILE`, `MISSING_SKILL_MD_FOR_TASKS_DIR` findings
4. Test FAILS because `--completeness` flag doesn't exist yet

### GREEN
1. Dispatch `task(..., prompt: "execute green task from test-driven-development")`
2. Add `--completeness` flag to `skildeck lint` CLI (argparse)
3. Implement `load_skilldeck_ignore()` — reads `.skilldeck-ignore` files for exception list
4. Implement `check_every_dir_has_skill_md()` — verifies every dir under `.opencode/skills/` has `SKILL.md` (excluding dirs in `.skilldeck-ignore`)
5. Implement `check_tdt_references_resolve()` — verifies every `SKILL.md` Trigger Dispatch Table reference resolves to an existent task file under `tasks/`
6. Implement `check_tasks_dir_has_skill_md()` — verifies every skill with a `tasks/` directory has a `SKILL.md`
7. Create `.opencode/skills/reference/.skilldeck-ignore` listing `reference/` as an intentionally non-skill directory
8. New finding codes: `MISSING_SKILL_MD`, `MISSING_TASK_FILE`, `MISSING_SKILL_MD_FOR_TASKS_DIR`

### verify
1. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
2. Verify RED test now PASSES
3. Verify `skildeck lint` without `--completeness` behaves identically to pre-change (backward compatibility)
4. Verify `.skilldeck-ignore` correctly excludes `reference/` from checks
5. Verify routing/orchestrator skills without `tasks/` (approval-gate, git-workflow, issue-operations) are NOT flagged

### commit
1. `git add .opencode/tools/impl/skildeck/skildeck-lint .opencode/skills/reference/.skilldeck-ignore`
2. `git commit -m "feat: add skildeck lint --completeness for structural skill deck validation"`

---

## Phase 2: Enforcement — Critical violation rule

**SC:** SC-6 — `critical-rules-074` added to `000-critical-rules.md`
**Evidence type:** string + behavioral
**Depends on:** (none — root phase)
**Skill+task:** test-driven-development — RED then GREEN then verify

### RED
1. Dispatch `task(..., prompt: "execute red task from test-driven-development")`
2. Write a failing test that greps for `critical-rules-074` in `.opencode/guidelines/000-critical-rules.md`
3. Test FAILS because section doesn't exist yet

### GREEN
1. Dispatch `task(..., prompt: "execute green task from test-driven-development")`
2. Add `critical-rules-074` section to `.opencode/guidelines/000-critical-rules.md` under Tier 1
3. Section text: "CRITICAL VIOLATION — Missing skill card or task card triggers investigation + fatal HALT with escalation. When `skildeck lint --completeness` reports a missing SKILL.md or task card, the agent MUST produce an investigation report documenting the missing cards, then HALT with escalation. The agent MUST NOT continue working until the missing cards are created."

### verify
1. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
2. Verify `critical-rules-074` text is present in `000-critical-rules.md`
3. Verify section is under Tier 1 (Safety-Critical)
4. Verify behavioral test (Phase 4) will exercise this rule

### commit
1. `git add .opencode/guidelines/000-critical-rules.md`
2. `git commit -m "feat: add critical-rules-074 for missing skill card detection"`

---

## Phase 3: CI — Content-verification test

**SC:** SC-2 — Content-verification test scenario in `test-enforcement.sh`
**Evidence type:** string + structural
**Depends on:** Phase 1 (skildeck lint extended)
**Skill+task:** test-driven-development — RED then GREEN then verify

### RED
1. Dispatch `task(..., prompt: "execute red task from test-driven-development")`
2. Write a failing test that greps for `skill-deck-completeness` in `.opencode/tests-v2/test-enforcement.sh` scenario dict
3. Test FAILS because entry doesn't exist yet

### GREEN
1. Dispatch `task(..., prompt: "execute green task from test-driven-development")`
2. Add `skill-deck-completeness` scenario entry to `test-enforcement.sh` associative array
3. Create scenario file at `.opencode/tests-v2/scenarios/skill-deck-completeness.sh` that maps skill deck structural files to the content-verification test

### verify
1. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
2. Verify scenario name is present in `test-enforcement.sh` dict
3. Verify scenario file exists at expected path
4. Verify `bash .opencode/tests-v2/test-enforcement.sh --scenario skill-deck-completeness` runs without error

### commit
1. `git add .opencode/tests-v2/test-enforcement.sh .opencode/tests-v2/scenarios/skill-deck-completeness.sh`
2. `git commit -m "test: add skill-deck-completeness content-verification scenario"`

---

## Phase 4: Behavioral enforcement test

**SC:** SC-3 — Behavioral enforcement test for missing skill card detection
**Evidence type:** behavioral
**Depends on:** Phase 1 (skildeck lint extended) + Phase 2 (critical-rules-074 exists)
**Skill+task:** test-driven-development — RED then GREEN then verify

### RED
1. Dispatch `task(..., prompt: "execute red task from test-driven-development")`
2. Write a failing behavioral test that sends a prompt triggering missing-skill-card investigation
3. Test FAILS because agent doesn't have `critical-rules-074` yet (Phase 2 must be complete)

### GREEN
1. Dispatch `task(..., prompt: "execute green task from test-driven-development")`
2. Create `.opencode/tests-v2/behaviors/skill-deck-completeness.sh` following the artifact-only generator paradigm
3. Script uses `behavior_run()` to send a prompt that triggers the agent to investigate skill deck completeness
4. Script uses `assert_semantic()` with a clean-room AI inspector to verify the agent produces an investigation report and fatal HALT with escalation
5. Test creates its own broken skill deck in the test home (no production files modified)
6. Produces `manifest.yaml`, `session.yaml`, `stdout.log`, `stderr.log`

### verify
1. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
2. Verify `bash .opencode/tests-v2/behaviors/skill-deck-completeness.sh` produces artifacts
3. Verify clean-room semantic inspector returns PASS for agent behavior
4. Verify test does not modify production skill deck files

### commit
1. `git add .opencode/tests-v2/behaviors/skill-deck-completeness.sh`
2. `git commit -m "test: add behavioral enforcement test for skill deck completeness"`

---

## Phase 5: Documentation — .opencode/AGENTS.md

**SC:** SC-4 — `.opencode/AGENTS.md` updated with references
**Evidence type:** string
**Depends on:** Phase 1 (skildeck lint command exists)
**Skill+task:** test-driven-development — RED then GREEN then verify

### RED
1. Dispatch `task(..., prompt: "execute red task from test-driven-development")`
2. Write a failing test that greps for `skildeck lint --completeness` in `.opencode/AGENTS.md`
3. Test FAILS because entry doesn't exist yet

### GREEN
1. Dispatch `task(..., prompt: "execute green task from test-driven-development")`
2. Add row to Reference Documents table: `| Skill deck completeness | `.opencode/.issues/2229/` | Structural validation of skill deck (SKILL.md + task card existence) |`
3. Add row to Build/Lint/Test Commands table: `| Structural completeness check | `.opencode/tools/impl/skildeck/skildeck-lint --completeness` | opencode |`

### verify
1. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
2. Verify both table entries are present in `.opencode/AGENTS.md`
3. Verify command name matches actual `skildeck lint --completeness` implementation

### commit
1. `git add .opencode/AGENTS.md`
2. `git commit -m "docs: add skill deck completeness references to .opencode/AGENTS.md"`

---

## Phase 6: Documentation — root AGENTS.md

**SC:** SC-5 — Root `AGENTS.md` updated with references
**Evidence type:** string
**Depends on:** Phase 1 (skildeck lint command exists)
**Skill+task:** test-driven-development — RED then GREEN then verify

### RED
1. Dispatch `task(..., prompt: "execute red task from test-driven-development")`
2. Write a failing test that greps for skill deck completeness reference in root `AGENTS.md`
3. Test FAILS because entry doesn't exist yet

### GREEN
1. Dispatch `task(..., prompt: "execute green task from test-driven-development")`
2. Add row to Reference Files table: `| `.opencode/.issues/2229/` | Skill deck completeness validation — structural checks, enforcement, and tests |`

### verify
1. Dispatch `task(..., prompt: "execute verify task from verification-before-completion")`
2. Verify reference entry is present in root `AGENTS.md`
3. Verify reference is consistent with `.opencode/AGENTS.md` entry

### commit
1. `git add AGENTS.md`
2. `git commit -m "docs: add skill deck completeness reference to root AGENTS.md"`
