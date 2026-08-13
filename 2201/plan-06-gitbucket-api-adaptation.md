# Phase 6 — gitbucket-api Adaptation

**Concern:** Adapt the gitbucket-api sub-skill to delegate to gb-cli for workflow-level operations.

**Files:**
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` (modify)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/tool-detection.md` (modify)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md` (modify)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/session-integration.md` (modify)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md` (modify)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/error-recovery.md` (modify)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md` (modify)
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/repository-operations.md` (modify)

**SCs:** SC-19a, SC-19b, SC-20

**Dependencies:** Phase 2, Phase 3

**Entry Conditions:**
- Phase 2 complete: gb-cli SKILL.md exists as delegation target
- Phase 3 complete: gb-cli task cards exist as delegation references

**Exit Conditions:**
- gitbucket-api SKILL.md description updated to indicate delegation to gb-cli for workflow-level operations
- 7 gitbucket-api task files have duplicated gb CLI command reference tables removed or replaced with cross-references to gb-cli
- Platform-specific routing logic retained in gitbucket-api task files

---

## Code Path Coverage

| Code Path | Coverage |
|-----------|----------|
| `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` | Add gb-cli cross-reference, update description to indicate delegation |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/tool-detection.md` | Remove duplicated gb CLI command reference tables; replace workflow-level gb command sequences with gb-cli cross-references; retain owner/repo resolution and auth verification |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md` | Remove duplicated gb CLI command reference tables; replace workflow-level gb command sequences with gb-cli cross-references; retain platform-specific routing |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/session-integration.md` | Remove duplicated gb CLI command reference tables; replace workflow-level gb command sequences with gb-cli cross-references; retain session credential handling |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md` | Remove duplicated gb CLI command reference tables; replace workflow-level gb command sequences with gb-cli cross-references; retain issue CRUD routing |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/error-recovery.md` | Remove duplicated gb CLI command reference tables; replace workflow-level gb command sequences with gb-cli cross-references; retain error recovery patterns |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md` | Remove duplicated gb CLI command reference tables; replace workflow-level gb command sequences with gb-cli cross-references; retain label routing logic |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/repository-operations.md` | Remove duplicated gb CLI command reference tables; replace workflow-level gb command sequences with gb-cli cross-references; retain repo routing logic |

## Cross-Cutting SCs

| SC | Cross-Cutting Concern |
|----|----------------------|
| SC-19a | Precedence — gb-cli is the primary entry point for gb workflows (verification gate: post-implementation) |
| SC-19b | Delegation — gitbucket-api delegates workflow-level operations to gb-cli (verification gate: post-implementation) |
| SC-20 | No duplicated command tables — 7 gitbucket-api task files adapted (verification gate: post-implementation) |

## Interface Boundaries

| Boundary | Status |
|----------|--------|
| delegation_contract | NEW — gitbucket-api delegates workflow-level gb command sequences to gb-cli task cards |
| precedence | gb-cli is the PRIMARY entry point for gb workflows (SC-19a) |
| git_operation_boundary | UNCHANGED — git operations remain owned by git-workflow |
| regression_invariant | gitbucket-api retains platform-scoped routing role (owner/repo resolution, auth verification, error recovery) |

## State Transitions

| Entity | Before | After |
|--------|--------|-------|
| `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` | Standalone gb CLI command coverage; description does not indicate delegation | Adds gb-cli cross-reference; description updated to indicate delegation |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/tool-detection.md` | Contains duplicated gb CLI command reference tables | Duplicated tables removed; workflow-level gb command sequences replaced with gb-cli cross-references; platform routing retained |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md` | Contains duplicated gb CLI command reference tables | Duplicated tables removed; workflow-level gb command sequences replaced with gb-cli cross-references; platform routing retained |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/session-integration.md` | Contains duplicated gb CLI command reference tables | Duplicated tables removed; workflow-level gb command sequences replaced with gb-cli cross-references; session credential handling retained |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md` | Contains duplicated gb CLI command reference tables | Duplicated tables removed; workflow-level gb command sequences replaced with gb-cli cross-references; issue CRUD routing retained |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/error-recovery.md` | Contains duplicated gb CLI command reference tables | Duplicated tables removed; workflow-level gb command sequences replaced with gb-cli cross-references; error recovery patterns retained |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md` | Contains duplicated gb CLI command reference tables | Duplicated tables removed; workflow-level gb command sequences replaced with gb-cli cross-references; label routing retained |
| `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/repository-operations.md` | Contains duplicated gb CLI command reference tables | Duplicated tables removed; workflow-level gb command sequences replaced with gb-cli cross-references; repo routing retained |

---

## Step-by-step

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting the gitbucket-api SKILL.md does not yet delegate to gb-cli and the 7 task files still contain duplicated gb CLI command reference tables. **→ SC-19a, SC-19b, SC-20**
- [ ] 2. **GREEN (**sub-agent**).** Update the gitbucket-api SKILL.md description to indicate delegation to gb-cli for workflow-level operations and add a gb-cli cross-reference. For each of the 7 task files, remove duplicated gb CLI command reference tables and replace workflow-level gb command sequences with cross-references to the corresponding gb-cli task cards, retaining platform-specific routing logic (owner/repo resolution, auth verification, error recovery patterns). **→ SC-19a, SC-19b, SC-20**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify gb-cli is the primary entry point for gb workflows and gitbucket-api delegates correctly (read both SKILL.md files). Verify the 7 task files have no remaining duplicated gb CLI command reference tables. **→ SC-19a, SC-19b, SC-20**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the gitbucket-api adaptation.

#### Phase 6 VbC

- [ ] 5. **VbC (**clean-room**).** Verify gitbucket-api SKILL.md delegates to gb-cli, the 7 task files have duplicated gb CLI command tables removed/replaced, and platform routing is retained. **→ SC-19a, SC-19b, SC-20**

**Cost frame:** Verifying the delegation and removal of duplicated command tables costs a sub-agent read of both SKILL.md files and a grep of the 7 task files. Skipping means the gitbucket-api sub-skill retains duplicated gb command coverage — two skills drift out of sync, and the agent gets conflicting command references that fail at runtime.

**Concern transition:** This is the terminal phase. All 22 SCs are covered. Proceed to post-implementation steps (structural checks, verification, audit, Z3 check, pre-PR gate, regression check, review-prep, PR creation, exec summary).
