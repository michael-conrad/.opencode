# Phase 3 — Task Cards Creation

**Concern:** Create workflow-based task cards adapted from the gh-cli reference, filtered by the Phase 1 investigation.

**Files:**
- `.opencode/skills/gb-cli/tasks/authenticate.md` (new)
- `.opencode/skills/gb-cli/tasks/create-pr.md` (new)
- `.opencode/skills/gb-cli/tasks/triage-issues.md` (new)
- `.opencode/skills/gb-cli/tasks/review-pr.md` (new)
- `.opencode/skills/gb-cli/tasks/manage-repo.md` (new)
- `.opencode/skills/gb-cli/tasks/manage-labels.md` (new)
- `.opencode/skills/gb-cli/tasks/manage-milestones.md` (new)
- `.opencode/skills/gb-cli/tasks/search-investigate.md` (new)
- `.opencode/skills/gb-cli/tasks/api-requests.md` (new)
- `.opencode/skills/gb-cli/tasks/completion.md` (new)
- `.opencode/skills/gb-cli/tasks/common-workflows.md` (new)

**SCs:** SC-6, SC-7, SC-8, SC-9, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16

**Dependencies:** Phase 2

**Entry Conditions:**
- Phase 2 complete: SKILL.md exists with Workflows section referencing task cards
- Phase 1 applicability assessment available to filter which workflows get task cards

**Exit Conditions:**
- 11 task cards exist in `.opencode/skills/gb-cli/tasks/`
- Each task card follows canonical 6-section structure (Purpose, Task Discipline, Entry Criteria, Procedure, Exit Criteria, Result Contract)
- No gb command duplicates git-workflow task cards for PR creation, branch management, or commit operations
- `gb auth status` verification is an entry criterion for all auth-requiring operations
- `gb pr merge` prohibited with CRITICAL VIOLATION block in create-pr and review-pr
- All task cards include SPDX-FileCopyrightText, Provenance, and AI co-authored byline headers

---

## Code Path Coverage

| Code Path | Coverage |
|-----------|----------|
| `.opencode/skills/gb-cli/tasks/authenticate.md` | gb auth status/login/config, version check ≥ 0.6.1, TOOL_MISSING BLOCKED |
| `.opencode/skills/gb-cli/tasks/create-pr.md` | gb pr create/view, NO merge, references git-workflow for branch ops |
| `.opencode/skills/gb-cli/tasks/triage-issues.md` | gb issue list/view/edit/comment/close |
| `.opencode/skills/gb-cli/tasks/review-pr.md` | gb pr list/diff/comment/view, NO merge |
| `.opencode/skills/gb-cli/tasks/manage-repo.md` | gb repo list/view/create/fork/delete (delete with confirmation) |
| `.opencode/skills/gb-cli/tasks/manage-labels.md` | gb label list/view/create/edit/delete, post-creation label mutation limitation documented |
| `.opencode/skills/gb-cli/tasks/manage-milestones.md` | gb milestone list/view/create/edit/delete (unique to gb) |
| `.opencode/skills/gb-cli/tasks/search-investigate.md` | Iterative listing + client-side filter, no native search API limitation documented |
| `.opencode/skills/gb-cli/tasks/api-requests.md` | gb api <endpoint> passthrough |
| `.opencode/skills/gb-cli/tasks/completion.md` | gb completion -s bash/zsh/fish/powershell |
| `.opencode/skills/gb-cli/tasks/common-workflows.md` | End-to-end workflow examples |

## Cross-Cutting SCs

| SC | Cross-Cutting Concern |
|----|----------------------|
| SC-6, SC-7, SC-12, SC-14, SC-15, SC-16 | File creation integrity — task cards exist, canonical structure, headers (verification gate: pre-commit) |
| SC-9, SC-13 | Safety and authentication guards — auth status entry criterion, merge prohibition (verification gate: pre-commit) |
| SC-8 | No overlap with git-workflow (verification gate: post-implementation) |
| SC-11 | Command coverage — all gb CLI command categories from capability manifest (verification gate: pre-commit) |

## Interface Boundaries

| Boundary | Status |
|----------|--------|
| task(..., prompt: 'execute <workflow> from gb-cli') | ADDED — dispatches to gb-cli task cards |
| git-workflow | UNCHANGED — gb-cli create-pr/review-pr reference git-workflow for branch operations (SC-8) |
| issue-operations | UNCHANGED — triage-issues references issue-operations for issue CRUD patterns |
| gb pr merge | PROHIBITED — human-only per critical-rules-merge (SC-13) |

## State Transitions

| Entity | Before | After |
|--------|--------|-------|
| `.opencode/skills/gb-cli/tasks/authenticate.md` | Does not exist | Exists — auth task card |
| `.opencode/skills/gb-cli/tasks/create-pr.md` | Does not exist | Exists — PR creation task card, no merge |
| `.opencode/skills/gb-cli/tasks/triage-issues.md` | Does not exist | Exists — issue triage task card |
| `.opencode/skills/gb-cli/tasks/review-pr.md` | Does not exist | Exists — PR review task card, no merge |
| `.opencode/skills/gb-cli/tasks/manage-repo.md` | Does not exist | Exists — repo management task card |
| `.opencode/skills/gb-cli/tasks/manage-labels.md` | Does not exist | Exists — label management task card |
| `.opencode/skills/gb-cli/tasks/manage-milestones.md` | Does not exist | Exists — milestone management task card |
| `.opencode/skills/gb-cli/tasks/search-investigate.md` | Does not exist | Exists — search/investigation task card |
| `.opencode/skills/gb-cli/tasks/api-requests.md` | Does not exist | Exists — API passthrough task card |
| `.opencode/skills/gb-cli/tasks/completion.md` | Does not exist | Exists — shell completion task card |
| `.opencode/skills/gb-cli/tasks/common-workflows.md` | Does not exist | Exists — common workflows task card |

---

## Step-by-step

- [ ] 1. **RED (**sub-agent**).** Write a failing enforcement test asserting the task card files do not yet exist. **→ SC-6**
- [ ] 2. **GREEN (**sub-agent**).** Create the 11 task cards in `.opencode/skills/gb-cli/tasks/` following the canonical 6-section structure (Purpose, Task Discipline, Entry Criteria, Procedure, Exit Criteria, Result Contract), adapted from the gh-cli reference and filtered by the Phase 1 applicability assessment. Include `gb auth status` as an entry criterion in all auth-dependent task cards. Include the `gb pr merge` CRITICAL VIOLATION block in create-pr and review-pr. Reference `git-workflow` for branch operations (no duplicate gb commands). Include SPDX-FileCopyrightText, Provenance, and AI co-authored byline headers in every task card. **→ SC-6, SC-7, SC-8, SC-9, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16**
- [ ] 3. **GREEN doublecheck (**clean-room**).** Verify each task card has all 6 canonical sections, auth entry criteria present, merge prohibition present, no duplicate gb commands vs git-workflow, all gb command categories covered, headers present. **→ SC-7, SC-8, SC-9, SC-11, SC-13, SC-14, SC-15, SC-16**
- [ ] 4. **Checkpoint commit (**inline**).** Commit the task cards creation.

#### Phase 3 VbC

- [ ] 5. **VbC (**clean-room**).** Verify all 11 task cards exist with canonical structure, auth entry criteria, merge prohibition, command coverage, and headers. **→ SC-6, SC-7, SC-8, SC-9, SC-11, SC-12, SC-13, SC-14, SC-15, SC-16**

**Cost frame:** Verifying the task cards' structure, auth guards, merge prohibition, and headers costs a grep of each task card. Skipping means an auth-dependent task card ships without `gb auth status` verification — the agent runs gb operations unauthenticated and the defect surfaces as a runtime failure in production.

**Concern transition:** Leaving task cards creation → entering cross-reference integration. Phase 4 depends on Phase 2's gb-cli skill existing to reference.
