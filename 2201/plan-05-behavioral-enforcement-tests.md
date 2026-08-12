# Phase 5 — Behavioral Enforcement Tests

**Concern:** Behavioral tests for skill discovery, auth checks, and merge prohibition.

**Files:**
- `.opencode/tests-v2/behaviors/gb-cli-skill-discovery.sh` (new)
- `.opencode/tests-v2/behaviors/gb-cli-auth-check.sh` (new)
- `.opencode/tests-v2/behaviors/gb-cli-merge-prohibition.sh` (new)

**SCs:** SC-10

**Dependencies:** Phase 2, Phase 3

**Entry Conditions:**
- Phase 2 complete: gb-cli skill exists for discovery test
- Phase 3 complete: task cards exist for auth check and merge prohibition tests

**Exit Conditions:**
- 3 behavioral test scripts exist in `.opencode/tests-v2/behaviors/`
- `gb-cli` entry appears in `<available_skills>` after deployment

---

## Code Path Coverage

| Code Path | Coverage |
|-----------|----------|
| `.opencode/tests-v2/behaviors/gb-cli-skill-discovery.sh` | Behavioral test: prompt with gb CLI intent, verify gb-cli appears in available_skills via session.yaml |
| `.opencode/tests-v2/behaviors/gb-cli-auth-check.sh` | Behavioral test: verify gb auth status checked before gb operations |
| `.opencode/tests-v2/behaviors/gb-cli-merge-prohibition.sh` | Behavioral test: verify gb pr merge is NOT called |

## Cross-Cutting SCs

| SC | Cross-Cutting Concern |
|----|----------------------|
| SC-10 | Skill discovery — gb-cli appears in `<available_skills>` after deployment (verification gate: post-implementation) |

## Interface Boundaries

| Boundary | Status |
|----------|--------|
| available_skills discovery | AUTO — opencode auto-discovers skills in `.opencode/skills/`; gb-cli appears after deployment |
| Test harness | `bash .opencode/tests-v2/with-test-home opencode run '<message>'` — artifact-only generator paradigm |

## State Transitions

| Entity | Before | After |
|--------|--------|-------|
| `.opencode/tests-v2/behaviors/gb-cli-skill-discovery.sh` | Does not exist | Exists — behavioral test for gb-cli skill discovery |
| `.opencode/tests-v2/behaviors/gb-cli-auth-check.sh` | Does not exist | Exists — behavioral test for gb auth status check |
| `.opencode/tests-v2/behaviors/gb-cli-merge-prohibition.sh` | Does not exist | Exists — behavioral test for gb pr merge prohibition |

---

## Step-by-step

- [ ] 1. **RED (**sub-agent**).** Write the 3 behavioral test scripts as artifact-only generators following the harness specification: `gb-cli-skill-discovery.sh` (prompt triggering gb CLI intent, verify gb-cli appears in available_skills), `gb-cli-auth-check.sh` (verify gb auth status checked before gb operations), `gb-cli-merge-prohibition.sh` (verify gb pr merge is NOT called). Each script sets `SCENARIO_NAME`, `SCENARIO_PROMPT`, calls `behavior_run`, and exits 0. **→ SC-10**
- [ ] 2. **GREEN (**sub-agent**).** Run the behavioral tests via `bash .opencode/tests-v2/with-test-home opencode run '<message>'` with bash tool timeout ≥ 600s. Verify the gb-cli entry appears in `<available_skills>` after deployment. **→ SC-10**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify the 3 test scripts exist, follow the artifact-only generator paradigm (no assertion helpers, exit 0), and the skill discovery test produces evidence that gb-cli appears in available_skills. **→ SC-10**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the behavioral enforcement tests.

#### Phase 5 VbC

- [ ] 5. **VbC (**clean-room**).** Verify the 3 behavioral test scripts exist and the gb-cli entry appears in `<available_skills>` after deployment. **→ SC-10**

**Cost frame:** Running the behavioral tests costs minutes of execution time per test. Skipping means the skill discovery defect ships — gb-cli never appears in available_skills, the skill is unusable, and the defect is discovered only when an agent fails to dispatch it in production, costing 1000× more to fix.

**Concern transition:** Leaving behavioral enforcement tests → entering gitbucket-api adaptation. Phase 6 depends on Phases 2-3 (gb-cli skill and task cards exist as delegation targets).
