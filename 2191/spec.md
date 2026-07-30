## Intent and Executive Summary

### Problem Statement

The opencode skill deck lacks a dedicated skill for the GitHub CLI (`gh`). The agent currently relies on general bash knowledge for `gh` operations, which produces inconsistent results — incorrect flag usage, missing authentication checks, and suboptimal command patterns. A structured skill is needed.

An existing skill at [majiayu000/claude-skill-registry/skills/data/gh-cli-skill/SKILL.md](https://github.com/majiayu000/claude-skill-registry/blob/main/skills/data/gh-cli-skill/SKILL.md) provides comprehensive `gh` CLI reference material. This spec covers importing and adapting that content into the opencode skill system.

### Root Cause / Motivation

The opencode skill deck lacks a dedicated skill for the GitHub CLI (`gh`). The agent currently relies on general bash knowledge for `gh` operations, which produces inconsistent results — incorrect flag usage, missing authentication checks, and suboptimal command patterns. A structured skill is needed to provide consistent, verified gh CLI command patterns.

### Approach Chosen

Import and adapt the existing gh-cli skill from [majiayu000/claude-skill-registry](https://github.com/majiayu000/claude-skill-registry/blob/main/skills/data/gh-cli-skill/SKILL.md) into the opencode skill system, converting from Claude skill format (prose reference) to opencode routing-only format (SKILL.md + task cards).

### Alternatives Considered

1. **Writing from scratch**: Would require comprehensive research of all gh CLI commands and patterns, duplicating work already done in the source skill. Higher effort, higher risk of missing edge cases.
2. **Using a different source skill**: Other gh CLI skills exist but the claude-skill-registry version is the most comprehensive (20 command categories) and is actively maintained.
3. **Chosen approach (import + adapt)**: Leverages existing comprehensive reference material while adapting to opencode's routing-only format. Lowest risk, highest coverage.

### Key Design Decisions

- Routing-only SKILL.md with task cards (not monolithic skill card)
- Workflow-based task organization (not command-category-based) for real agent use cases
- Explicit delegation of git operations to git-workflow skill to avoid overlap
- `gh pr merge` prohibition enforced via CRITICAL VIOLATION block

## Preconditions

- gh CLI installed and authenticated (`gh auth status` succeeds)
- Opencode skill auto-discovery functional (skills in `.opencode/skills/` are automatically discovered)
- Write permissions to `.opencode/skills/` directory
- No existing `gh-cli` skill in `.opencode/skills/` (verify before creation)
- Target paths do not conflict with existing files

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | A new `gh-cli` skill exists at `.opencode/skills/gh-cli/SKILL.md` with valid YAML frontmatter (name, description, license) | `structural` | File exists, `name` matches directory name, description ≤1024 chars (boundary test: verify with `wc -c` that description does not exceed 1024 characters) |
| SC-2 | SKILL.md uses the routing-only template (no procedure text, only Workflows section with dispatch contracts) | `string` | grep for prohibited content patterns (no "Entry Criteria", "Procedure", "Operating Protocol" sections) |
| SC-3 | Description field uses agent-intent format (describes what agent needs to DO, not what user SAYS) — no "Load via skill() when", "User phrases:", or "Dispatch when" | `string` | grep description for prohibited meta-instruction patterns |
| SC-13 | The source skill's description is remediated from user-utterance format ("Use this skill when the user asks to...") to agent-intent format describing what the skill accomplishes | `string` | Compare source description against final description; confirm no "when the user asks", "Use this skill when", or equivalent user-utterance framing |
| SC-4 | Task cards exist for exactly 4 core workflows: authenticate, create-pr, triage-issues, review-pr | `structural` | `ls .opencode/skills/gh-cli/tasks/` shows exactly 4 task files |
| SC-5 | Each task card follows canonical structure: Purpose, Task Discipline, Entry Criteria, Procedure, Exit Criteria, Result Contract | `string` | grep each task card for all 6 required sections |
| SC-6 | Every gh command in gh-cli task cards is either (a) a `gh` CLI command not available as a git command, or (b) explicitly documented as a delegation to git-workflow in the task card's Cross-References section | `semantic` | Sub-agent reads both gh-cli and git-workflow task cards, classifies each gh command as (a) or (b), reports any unclassified commands as FAIL |
| SC-7 | Every task card whose Procedure section contains a `gh` command (excluding `gh auth *` and `gh completion *`) includes `gh auth status` as an entry criterion | `string` | grep all task cards for "auth status" or "auth" in Entry Criteria; count task cards with `gh` commands in Procedure; verify counts match |
| SC-8 | A behavioral test script exists at `.opencode/tests-v2/behaviors/2191-sc8-gh-cli-skill.sh` that follows the canonical template structure and references the gh-cli skill | `structural + string` | `ls` for file existence + `grep` for template structure (Purpose, Entry Criteria, Procedure, Exit Criteria sections) and skill reference (gh-cli) |
| SC-9 | The skill covers all 20 command categories from the source, organized into 16 workflow-based task cards (authenticate, create-pr, triage-issues, review-pr, do-release, search-investigate, manage-repo, run-ci-cd, manage-secrets, manage-codespaces, manage-org, manage-gists, manage-keys, manage-projects, manage-aliases, generate-completion) | `string` | grep task cards for each of the 20 command categories across the 16 workflow task cards |
| SC-10 | The skill includes a `common-workflows.md` task card with exactly 3 end-to-end workflow examples adapted from the source | `structural` | `ls .opencode/skills/gh-cli/tasks/common-workflows.md` exists; count workflow examples in the file (exactly 3) |
| SC-11 | The skill explicitly prohibits `gh pr merge` (delegating merge to human-only per critical-rules-merge) with a critical violation block | `string` | grep for "pr merge" prohibition or "critical-rules-merge" reference |
| SC-12 | All task cards include SPDX + provenance headers and AI co-authored byline | `string` | grep each task card for "SPDX-FileCopyrightText" and "Co-authored with AI" |
| SC-14 | After PR merge, the gh-cli skill appears in `<available_skills>` when running opencode in a clean environment | `behavioral` | Run the behavioral test at `.opencode/tests-v2/behaviors/2191-sc8-gh-cli-skill.sh` post-merge and confirm PASS. This is a post-merge acceptance criterion, not a pre-merge implementation gate. |

### Cost-Frame Justification

Each SC's evidence type is chosen based on defect-discovery-latency (DDL) cost:

| SC | Evidence Type | DDL Justification |
|----|---------------|-------------------|
| SC-1 | `structural` | File existence and character count are static properties — a structural check catches absence at the earliest gate. Behavioral testing would add minutes of execution time for a property that `ls` and `wc -c` verify in <1s. |
| SC-2 | `string` | Prohibited section patterns are deterministic text patterns — grep catches violations instantly. Behavioral testing would require running the agent and inspecting output, adding 1000× DDL for a pattern match. |
| SC-3 | `string` | Same rationale as SC-2: prohibited meta-instruction patterns are deterministic text matches. |
| SC-13 | `string` | Description format comparison is a text-pattern check — grep for user-utterance framing catches violations at string level. |
| SC-4 | `structural` | File count is a static property — `ls` verifies in <1s. Behavioral testing would add minutes for a property that cannot be wrong at runtime. |
| SC-5 | `string` | Section header presence is a deterministic text pattern — grep catches missing sections instantly. |
| SC-6 | `semantic` | Overlap detection requires understanding what each command does in context — a sub-agent must read both skill's task cards and judge whether procedures overlap. String matching alone would miss semantic duplicates (same operation, different flag order). |
| SC-7 | `string` | Entry criterion text is a deterministic pattern — grep for "auth status" catches missing auth checks. |
| SC-8 | `structural + string` | Skill discovery is a runtime behavior, but the test environment clones `.opencode` from the remote (not the feature branch), so a behavioral test would always fail pre-merge. The structural+string check verifies the test script exists, follows the template, and references the skill — catching script-absence and structural defects at the earliest gate. The behavioral verification is deferred to SC-14 (post-merge). |
| SC-9 | `string` | Command category coverage is a text-pattern check — grep for each category name across task cards. |
| SC-10 | `structural` | Workflow example count is a static property — counting sections in a file verifies in <1s. |
| SC-11 | `string` | Prohibition text is a deterministic pattern — grep for "pr merge" or "critical-rules-merge" catches missing prohibition. |
| SC-12 | `string` | Header presence is a deterministic text pattern — grep for SPDX and byline strings catches missing headers. |
| SC-14 | `behavioral` | Post-merge acceptance criterion. Behavioral testing is the only sufficient evidence type for runtime skill discovery — structural checks (file exists) would pass even if auto-discovery is broken. The DDL cost is acceptable post-merge because the test runs once after deployment, not on every pre-merge iteration. |

### Enforcement Gate

All SCs (SC-1 through SC-13) must pass verification for this spec to be considered complete. A single FAIL means the entire implementation is incomplete.

SC-14 is a post-merge acceptance criterion, not a pre-merge implementation gate. It does not block implementation or PR creation. SC-14 must pass after the PR is merged to confirm the skill is discoverable in a clean environment.

## Approach

### Phase 1: Create skill directory and SKILL.md

1. Create `.opencode/skills/gh-cli/` directory
2. Write `SKILL.md` using routing-only template with:
   - YAML frontmatter: `name: gh-cli`, `description` in agent-intent format, `license: MIT`, `compatibility: opencode`
   - Overview: 1-2 sentences
   - Mandatory Task Discipline (5 items)
   - Workflows section with dispatch contracts for each workflow
   - Cross-References to `git-workflow`, `issue-operations`, `release-promoter`
3. Verify no existing gh-cli skill in `.opencode/skills/` and target paths don't conflict with existing files

### Phase 2: Create task cards

Create task cards organized by **real agent workflows** (sequential, decision-aware procedures) rather than by `gh` command category. Each workflow task card contains the full sequential procedure the agent follows to accomplish a real goal, including auth checks, decision branches, and error handling. This keeps the SKILL.md routing-only (no procedure text) and avoids overloading context when the main skill is loaded — only the relevant workflow task card is dispatched to a sub-agent.

1. **authenticate.md** — Check `gh auth status` → if missing, `gh auth login` → verify → `gh config set` if needed
2. **create-pr.md** — `gh repo sync` → `gh pr create` with title/body/labels/reviewers → `gh pr view` to verify (NOT merge — prohibited per critical-rules-merge)
3. **triage-issues.md** — `gh issue list` → `gh issue view` → `gh issue edit` (label/assign) → `gh issue comment` → maybe `gh issue close`
4. **review-pr.md** — `gh pr list` → `gh pr view --diff` → `gh pr checkout` → `gh pr review` (approve/comment/request-changes)
5. **do-release.md** — `git tag` → `gh release create` → `gh release upload` assets → `gh release view --web`
6. **search-investigate.md** — `gh search repos/issues/prs/code` → `gh browse` to open
7. **manage-repo.md** — `gh repo create/fork` → `gh label create` → `gh repo edit` (topics/visibility)
8. **run-ci-cd.md** — `gh run list` → `gh run view` → `gh run rerun` / `gh run watch`
9. **manage-secrets.md** — `gh secret list` → `gh secret set/delete` → `gh variable list/set/delete`
10. **manage-codespaces.md** — `gh codespace list` → `gh codespace create` → `gh codespace ssh/code` → `gh codespace delete`
11. **manage-org.md** — `gh org view` → `gh org list-members` → `gh repo list/create` for org
12. **manage-gists.md** — `gh gist create` → `gh gist list` → `gh gist view/edit/delete`
13. **manage-keys.md** — `gh ssh-key list` → `gh ssh-key add/delete` → `gh gpg-key list/add/delete`
14. **manage-projects.md** — `gh project list` → `gh project view`
15. **manage-aliases.md** — `gh alias set/list/delete` → `gh extension install/list/remove`
16. **generate-completion.md** — `gh completion -s bash/zsh/fish/powershell` (single command, minimal workflow)

### Phase 3: Cross-reference integration

- PR creation/checkout tasks reference `git-workflow` for branch operations
- Issue management tasks reference `issue-operations` for issue CRUD
- Release tasks reference `release-promoter` for tag/release operations
- Add `gh-cli` to relevant cross-reference sections in `git-workflow`, `issue-operations`, `release-promoter`

### Phase 4: Behavioral enforcement tests

- Test that agent dispatches `gh-cli` skill when user asks for gh CLI operations
- Test that `gh pr merge` is NOT called (prohibition enforcement)
- Test that `gh auth status` is checked before gh operations

## Affected Files

- `.opencode/skills/gh-cli/SKILL.md` — NEW: skill card
- `.opencode/skills/gh-cli/tasks/authenticate.md` — NEW: auth task card
- `.opencode/skills/gh-cli/tasks/repo-operations.md` — NEW: repo task card
- `.opencode/skills/gh-cli/tasks/issue-management.md` — NEW: issue task card
- `.opencode/skills/gh-cli/tasks/pr-management.md` — NEW: PR task card
- `.opencode/skills/gh-cli/tasks/codespaces.md` — NEW: codespaces task card
- `.opencode/skills/gh-cli/tasks/actions.md` — NEW: Actions task card
- `.opencode/skills/gh-cli/tasks/release-management.md` — NEW: release task card
- `.opencode/skills/gh-cli/tasks/search-browse.md` — NEW: search task card
- `.opencode/skills/gh-cli/tasks/org-management.md` — NEW: org management task card
- `.opencode/skills/gh-cli/tasks/gist-management.md` — NEW: gist management task card
- `.opencode/skills/gh-cli/tasks/label-management.md` — NEW: label management task card
- `.opencode/skills/gh-cli/tasks/project-management.md` — NEW: project management task card
- `.opencode/skills/gh-cli/tasks/status.md` — NEW: status task card
- `.opencode/skills/gh-cli/tasks/aliases-extensions.md` — NEW: aliases/extensions task card
- `.opencode/skills/gh-cli/tasks/api-requests.md` — NEW: API task card
- `.opencode/skills/gh-cli/tasks/ssh-gpg-keys.md` — NEW: SSH/GPG keys task card
- `.opencode/skills/gh-cli/tasks/secrets-variables.md` — NEW: secrets/variables task card
- `.opencode/skills/gh-cli/tasks/completion.md` — NEW: completion task card
- `.opencode/skills/gh-cli/tasks/common-workflows.md` — NEW: workflows task card
- `.opencode/skills/git-workflow/SKILL.md` — MODIFY: add gh-cli cross-reference
- `.opencode/skills/issue-operations/SKILL.md` — MODIFY: add gh-cli cross-reference
- `.opencode/skills/release-promoter/SKILL.md` — MODIFY: add gh-cli cross-reference

## Source Material

The source skill at [majiayu000/claude-skill-registry](https://github.com/majiayu000/claude-skill-registry/blob/main/skills/data/gh-cli-skill/SKILL.md) covers 20 command categories. This spec adapts all 20 categories for opencode agent use, converting from Claude skill format to opencode routing-only format.

### Adaptations Required

| Source Format | Opencode Format |
|---------------|-----------------|
| Claude skill (prose reference) | Routing-only SKILL.md with task cards |
| Command reference with examples | Procedure steps in task cards |
| "When to Use" trigger phrases | Agent-intent description field |
| Prerequisites section | Entry Criteria in task cards |
| Tips & Best Practices | Procedure step guidance |
| Troubleshooting | Entry Criteria + Exit Criteria |

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Overlap with git-workflow skill | Explicit delegation: gh-cli handles gh-specific commands, git-workflow handles git operations. Cross-reference in both skills. |
| `gh pr merge` used by agent | CRITICAL VIOLATION block in pr-management task card. Behavioral test enforces prohibition. |
| Stale command flags (gh CLI evolves) | Task cards reference `gh <command> --help` as verification step before using flags. |
| Authentication not checked before operations | `gh auth status` verification as entry criterion in all auth-dependent task cards. |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| gh CLI not installed | Task cards include `gh auth status` as entry criterion; if command not found, task returns BLOCKED with TOOL_MISSING reason |
| Source URL becomes inaccessible | Source material is reference only; all task card content is self-contained. If source is down, implementation proceeds from spec content. |
| File write permission errors | Phase 1 includes write-permission check; if `.opencode/skills/` is not writable, task returns BLOCKED |
| Naming conflicts with existing skills | Phase 1 Step 3 includes conflict check: verify no existing `gh-cli` skill directory and no target path conflicts |

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-30 | Affected Files:  →  | Internal Consistency: filename mismatch between Affected Files and Approach Phase 2 item 1 | Spec audit |
| 2026-07-30 | Added Intent and Executive Summary preamble with 5 fields (Problem Statement, Root Cause/Motivation, Approach Chosen, Alternatives Considered, Key Design Decisions) | SC-12: missing preamble section | Spec audit |
| 2026-07-30 | Added Preconditions section documenting gh CLI, opencode auto-discovery, write permissions, and conflict checks | A5-implicit-conditions: missing preconditions | Spec audit |
| 2026-07-30 | Added Edge Cases section after Risks covering gh CLI not installed, source URL inaccessible, file write errors, naming conflicts | SC-8 / A4-edge-case-discovery: missing edge cases | Spec audit |
| 2026-07-30 | Fixed SC-6 determinism: replaced "do NOT overlap" with explicit operational criteria | SC-9 / SC-DET: non-deterministic SC wording | Spec audit |
| 2026-07-30 | Fixed SC-10 determinism: replaced "at least 3" with "exactly 3" | SC-9 / SC-DET: non-deterministic SC wording | Spec audit |
| 2026-07-30 | Added Cost-Frame Justification table after SC table explaining DDL rationale per SC | SC-13: missing cost-frame language | Spec audit |
| 2026-07-30 | Added Enforcement Gate statement after SC table: all SCs must pass for completion | SC-14: missing enforcement gate | Spec audit |
| 2026-07-30 | Added Alternatives Considered subsection to preamble documenting write-from-scratch, different-source, and chosen-approach | A4-investigation-breadth: missing alternatives | Spec audit |
| 2026-07-30 | Added recency check step to Phase 1: verify no existing gh-cli skill and no path conflicts | A4-recency-check: missing recency check | Spec audit |
| 2026-07-30 | Updated SC-1 with boundary test (≤1024 chars via wc -c), SC-4 with exact count (exactly 4), SC-10 with exact count (exactly 3) | A5-missing-coverage: missing boundary tests | Spec audit |
| 2026-07-30 | SC-8: changed from `behavioral` to `structural + string` evidence type; criterion now verifies test script existence, template structure, and skill reference instead of runtime skill discovery | SC-8 circular dependency: behavioral test requires post-merge environment (test clones .opencode from remote, not feature branch) | Revision request |
| 2026-07-30 | Added SC-14: post-merge acceptance criterion verifying gh-cli skill appears in `<available_skills>` in a clean environment | SC-8 circular dependency: behavioral verification deferred to post-merge | Revision request |
| 2026-07-30 | Updated Cost-Frame Justification table: added SC-14 entry, updated SC-8 DDL justification | SC-8 circular dependency | Revision request |
| 2026-07-30 | Updated Enforcement Gate statement: noted SC-14 is post-merge, not a pre-merge gate | SC-8 circular dependency | Revision request |
| 2026-07-30 | SC-6: replaced "also appears" with binary classification (gh command vs git delegation) | SC-DET: implicit_behavior — two auditors could disagree on "also appears" | Spec audit |
| 2026-07-30 | SC-7: replaced "all gh operations that require authentication" with explicit exclusion list (gh auth*, gh completion*) | SC-DET: open_ended_quality — subjective threshold | Spec audit |
| 2026-07-30 | SC-10: replaced "section or task card" with explicit `common-workflows.md` file path | SC-DET: either_or_ambiguity — implementor must choose | Spec audit |
