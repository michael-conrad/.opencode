> **Full spec and artifacts: [`.opencode/.issues/2201/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2201)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2201/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

## Intent and Executive Summary

### Problem Statement

The opencode skill deck lacks a dedicated skill for the GitBucket CLI (`gb`). The agent currently relies on the `gitbucket-api` platform sub-skill (under `issue-operations`) for GitBucket operations, which provides only issue/PR/label/repo CRUD patterns. A standalone `gb-cli` skill is needed — analogous to the `gh-cli` skill from .opencode#2191 — providing workflow-based task cards for the full `gb` CLI command surface: authentication, issues, pull requests, labels, milestones, repositories, API passthrough, shell completion, and common end-to-end workflows.

### Root Cause / Motivation

The `gb` CLI tool (v0.6.1) is already documented in `.opencode/AGENTS.md` and used by the `gitbucket-api` platform sub-skill. However, there is no standalone skill that provides workflow-based task cards for `gb` operations. The agent must either use the `gitbucket-api` sub-skill (which is scoped to issue-operations patterns) or fall back to general bash knowledge — producing inconsistent results, missing authentication checks, and suboptimal command patterns.

### Approach Chosen

Create a new `gb-cli` skill at `.opencode/skills/gb-cli/` using the `gh-cli` skill (from .opencode#2191) as a reference template. Phase 1 investigates against a local test GitBucket instance to determine which `gh-cli` workflows apply to `gb`, which need revision, and which should be discarded. Subsequent phases create the SKILL.md, task cards, cross-references, and behavioral enforcement tests.

### Alternatives Considered

1. **Extending gitbucket-api sub-skill**: The existing sub-skill is scoped to issue-operations patterns. Adding workflow-based task cards would violate its single-concern boundary and create a mixed-purpose skill.
2. **Writing from scratch without gh-cli reference**: Would require comprehensive research of all `gb` CLI commands and workflow patterns, duplicating work already done in the gh-cli skill. Higher effort, higher risk of missing edge cases.
3. **Chosen approach (gh-cli reference + local investigation)**: Leverages the existing gh-cli structure as a template while using a local test GitBucket instance to validate which workflows apply. Lowest risk, highest coverage.

### Key Design Decisions

- Routing-only SKILL.md with task cards (not monolithic skill card)
- Workflow-based task organization adapted from gh-cli, filtered by local GitBucket investigation
- Explicit delegation of git operations to `git-workflow` skill to avoid overlap
- `gb pr merge` prohibition enforced via CRITICAL VIOLATION block (per critical-rules-merge)
- Post-creation label mutation documented as broken (per gitbucket-api capability manifest)
- No native search API — use iterative listing + client-side filter

### User Intent / Original Prompt

Create a dedicated `gb-cli` skill for the GitBucket CLI (`gb`), analogous to the `gh-cli` skill from .opencode#2191, with workflow-based task cards covering the full `gb` CLI command surface (authentication, issues, pull requests, labels, milestones, repositories, API passthrough, shell completion, and common end-to-end workflows), and integrate it into the skill deck so agents route GitBucket operations through it.

## Preconditions

- `gb` CLI v0.6.1 installed and authenticated (`gb auth status` succeeds)
- Local test GitBucket instance available for Phase 1 investigation
- Opencode skill auto-discovery functional (skills in `.opencode/skills/` are automatically discovered)
- Write permissions to `.opencode/skills/` directory
- No existing `gb-cli` skill in `.opencode/skills/` (verify before creation)
- Target paths do not conflict with existing files
- .opencode#2191 (gh-cli skill) must be implemented first — this spec depends on it as the reference template

## Not Included

- Full migration or deprecation of the existing `gitbucket-api` platform sub-skill — it is adapted to delegate to `gb-cli` but not removed
- Changes to the `gb` CLI tool itself (version pinning, installation, or configuration)
- GitBucket server administration or setup documentation
- GitHub CLI (`gh`) operations — those belong in the `gh-cli` skill

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method | Documentation Sources |
|----|-----------|---------------|---------------------|-----------------------|
| SC-1 | File exists at `.opencode/skills/gb-cli/SKILL.md` | `structural` | `ls .opencode/skills/gb-cli/SKILL.md` returns success | `.opencode/skills/gb-cli/SKILL.md` (target path) |
| SC-2 | `name` field in frontmatter matches directory name `gb-cli` | `string` | grep frontmatter for `name: gb-cli` | `.opencode/reference/skill-card-schema.md` (name constraint) |
| SC-3 | `description` field ≤ 1024 characters | `string` | Verify with `wc -c` that description does not exceed 1024 characters | `.opencode/reference/skill-card-schema.md` (description constraint) |
| SC-4 | SKILL.md uses the routing-only template (no procedure text, only Workflows section with dispatch contracts) | `string` | grep for prohibited content patterns (no "Entry Criteria", "Procedure", "Operating Protocol" sections) | `.opencode/skills/gh-cli/SKILL.md` (routing-only template reference) |
| SC-5 | Description field uses agent-intent format (describes what agent needs to DO, not what user SAYS) — no "Load via skill() when", "User phrases:", or "Dispatch when" | `string` | grep description for prohibited meta-instruction patterns | `.opencode/reference/skill-card-description-standards.md` (description-as-semantic-router format) |
| SC-6 | Task cards exist for all 11 workflows from the Phase 1 investigation: authenticate, create-pr, triage-issues, review-pr, manage-repo, manage-labels, manage-milestones, search-investigate, api-requests, completion, common-workflows | `structural` | `ls .opencode/skills/gb-cli/tasks/` shows all 11 task files | `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` (Phase 1 workflow set) |
| SC-7 | Each task card follows canonical structure: Purpose, Task Discipline, Entry Criteria, Procedure, Exit Criteria, Result Contract | `string` | grep each task card for all 6 required sections | `.opencode/reference/task-card-structure-standards.md` (canonical task card structure) |
| SC-8 | No `gb` command in gb-cli task cards that also appears in git-workflow task cards for PR creation, branch management, or commit operations | `semantic` | Sub-agent reads both gb-cli and git-workflow task cards, confirms no duplicate procedure steps | `.opencode/skills/git-workflow/tasks/` (git-workflow task cards) |
| SC-9 | Task cards include `gb auth status` verification as an entry criterion for all gb operations that require authentication | `string` | grep all task cards for "auth status" or "auth" in Entry Criteria | `.opencode/AGENTS.md` (gb auth requirement) |
| SC-10 | A `gb-cli` entry appears in `<available_skills>` after deployment (opencode discovers it from the directory) | `behavioral` | `opencode run` with prompt that triggers gb CLI intent, verify skill appears in available_skills via stderr | `.opencode/tests-v2/behaviors/` (behavioral test harness) |
| SC-11 | The skill covers all gb CLI commands from the capability manifest, organized into workflow-based task cards determined by Phase 1 investigation | `string` | grep task cards for each gb command category across the task cards | `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` (capability manifest) |
| SC-12 | The skill includes a "Common Workflows" task card (`.opencode/skills/gb-cli/tasks/common-workflows.md`) with end-to-end workflow examples adapted from the gh-cli reference and validated against local GitBucket instance | `structural` | `ls .opencode/skills/gb-cli/tasks/common-workflows.md` returns success; file contains end-to-end workflow examples | `.opencode/skills/gb-cli/tasks/common-workflows.md` (target file) |
| SC-13 | The skill explicitly prohibits `gb pr merge` (delegating merge to human-only per critical-rules-merge) with a critical violation block | `string` | grep for "pr merge" prohibition or "critical-rules-merge" reference | `.opencode/guidelines/000-critical-rules.md` (critical-rules-merge) |
| SC-14 | All task cards include SPDX-FileCopyrightText header | `string` | grep each task card for "SPDX-FileCopyrightText" | `.opencode/reference/task-card-structure-standards.md` (SPDX header standard) |
| SC-15 | All task cards include Provenance header | `string` | grep each task card for "Provenance:" | `.opencode/reference/task-card-structure-standards.md` (Provenance header standard) |
| SC-16 | All task cards include AI co-authored byline | `string` | grep each task card for "Co-authored with AI" | `.opencode/guidelines/080-code-standards.md` (AI co-authored attribution) |
| SC-17 | Phase 1 investigation produces a per-workflow applicability assessment artifact documenting which gh-cli workflows apply to gb, which need revision, and which are discarded, with rationale for each decision | `string` | Artifact file exists at `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` with entries for each gh-cli workflow | `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` (target artifact) |
| SC-18a | Cross-references to `gb-cli` appear in `git-workflow`, `issue-operations`, `gitbucket-api`, and `release-promoter` SKILL.md files | `string` | grep each of the 4 SKILL.md files for `gb-cli` cross-reference entry | `.opencode/skills/git-workflow/SKILL.md`, `.opencode/skills/issue-operations/SKILL.md`, `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`, `.opencode/skills/release-promoter/SKILL.md` |
| SC-18b | The `.opencode/AGENTS.md` gb CLI tool documentation section references the `gb-cli` skill | `string` | grep `.opencode/AGENTS.md` gb CLI tool documentation section for `gb-cli` skill reference | `.opencode/AGENTS.md` (gb CLI tool documentation section) |
| SC-19a | `gb-cli` skill takes precedence as the primary entry point for `gb` workflows | `semantic` | Sub-agent reads both `gb-cli` SKILL.md and `gitbucket-api` SKILL.md, confirms that `gb-cli` is the primary entry point for `gb` workflows | `.opencode/skills/gb-cli/SKILL.md`, `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` |
| SC-19b | `gitbucket-api` sub-skill delegates to `gb-cli` for workflow-level operations | `semantic` | Sub-agent reads both `gb-cli` SKILL.md and `gitbucket-api` SKILL.md, confirms that `gitbucket-api` delegates workflow-level operations to `gb-cli` | `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`, `.opencode/skills/gb-cli/SKILL.md` |
| SC-20 | The 7 `gitbucket-api` task files have duplicated `gb` CLI command reference tables removed or replaced with cross-references to `gb-cli` | `string` | grep the 7 `gitbucket-api` task files for `gb` CLI command reference tables — confirm they are removed or replaced with cross-references to `gb-cli` | `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/` (7 task files) |

### Cost Frame

Cost is measured in defect-discovery-latency (DDL), not tool calls. Correctness is the only metric — there is no score for tool-call economy.

- **SC-1 (`structural`):** Verifying the SKILL.md file exists costs one `ls` call at the earliest gate. Skipping means a missing skill file ships and breaks skill discovery at runtime, costing 1000× more in diagnose-fix-reverify rework.
- **SC-2 (`string`):** Verifying the frontmatter `name` field matches the directory costs one grep call. Skipping means the skill is undiscoverable under the wrong name, surfacing only when dispatch routing fails.
- **SC-3 (`string`):** Verifying the description length costs one `wc -c` call in <1s. Skipping means an over-long description is truncated by skill routing, losing dispatch-critical intent.
- **SC-4 (`string`):** Verifying the routing-only template costs one grep for prohibited sections. Skipping means the skill card carries procedure text the orchestrator cannot route, producing dispatch failures at every entry.
- **SC-5 (`string`):** Verifying agent-intent description format costs one grep for meta-instruction patterns. Skipping means the description routes on user-utterance framing instead of agent intent, misrouting skill dispatch.
- **SC-6 (`structural`):** Verifying all 11 task card files exist costs one `ls` call in <1s. Skipping means a missing workflow task card surfaces only when a workflow dispatch fails at runtime.
- **SC-7 (`string`):** Verifying each task card has all 6 canonical sections costs one grep per file. Skipping means task cards without canonical structure produce execution gaps the agent discovers mid-procedure.
- **SC-8 (`semantic`):** Verifying no command overlap costs a sub-agent read of both skills' task cards. Skipping means duplicate gb/git commands drift out of sync and the agent executes stale procedures.
- **SC-9 (`string`):** Verifying the `gb auth status` entry criterion costs one grep across task cards. Skipping means unauthenticated gb operations fail at runtime after the workflow has already started.
- **SC-10 (`behavioral`):** Verifying skill discovery costs one `opencode run` execution. Skipping means an undiscoverable skill is "implemented but unreachable" — the costliest possible failure mode, found only in production.
- **SC-11 (`string`):** Verifying gb command category coverage costs one grep per category across task cards. Skipping means uncovered gb commands force the agent back to general bash knowledge.
- **SC-12 (`structural`):** Verifying the common-workflows file exists costs one `ls` call. Skipping means end-to-end examples are absent and agents improvise multi-step workflows.
- **SC-13 (`string`):** Verifying the `gb pr merge` prohibition costs one grep for "pr merge" or "critical-rules-merge". Skipping means an agent could invoke the human-only merge operation.
- **SC-14 (`string`):** Verifying the SPDX header costs one grep per task card. Skipping means provenance tracking is lost across task cards.
- **SC-15 (`string`):** Verifying the Provenance header costs one grep per task card. Skipping means origin classification is absent from AI-generated task cards.
- **SC-16 (`string`):** Verifying the AI co-authored byline costs one grep per task card. Skipping means attribution requirements are violated silently.
- **SC-17 (`string`):** Verifying the applicability assessment artifact costs one grep for per-workflow entries with rationale. Skipping means Phase 1 applicability decisions are undocumented and unreviewable.
- **SC-18a (`string`):** Verifying the `gb-cli` cross-references in 4 SKILL.md files costs one grep per file. Skipping means the skill is orphaned from its routing neighbors and never discovered from related skills.
- **SC-18b (`string`):** Verifying the `.opencode/AGENTS.md` gb CLI section references the skill costs one grep. Skipping means the documented tool has no skill entry point, and agents fall back to general bash knowledge.
- **SC-19a (`semantic`):** Verifying `gb-cli` precedence costs a sub-agent read of both SKILL.md files. Skipping means agents route gb workflows through `gitbucket-api` and get issue-scoped patterns for workflow operations.
- **SC-19b (`semantic`):** Verifying `gitbucket-api` delegation costs a sub-agent read of both SKILL.md files. Skipping means two skills drift with conflicting gb command coverage that fails at runtime.
- **SC-20 (`string`):** Verifying the duplicated command tables are removed costs one grep across the 7 task files. Skipping means duplication persists and the two skills diverge in command references.

### Enforcement Gate

All SCs (SC-1 through SC-17, SC-18a, SC-18b, SC-19a, SC-19b, SC-20) must pass verification for this spec to be considered complete. A single FAIL means the entire implementation is incomplete.

## Requirements

1. The gb-cli skill SHALL be created at `.opencode/skills/gb-cli/`
2. The SKILL.md SHALL use the routing-only template with valid YAML frontmatter
3. The description field SHALL use agent-intent format
4. Task cards SHALL follow the canonical 6-section structure
5. All auth-dependent task cards SHALL include `gb auth status` as an entry criterion
6. The skill SHALL explicitly prohibit `gb pr merge` per critical-rules-merge
7. All new files SHALL include SPDX-FileCopyrightText header
8. All new files SHALL include Provenance header
9. All new files SHALL include AI co-authored byline
10. The skill SHALL NOT duplicate git-workflow procedures
11. Phase 1 SHALL produce a per-workflow applicability assessment artifact
12. The skill SHALL cover all gb CLI commands from the capability manifest
13. The skill SHALL include a common-workflows task card with end-to-end workflow examples
14. Cross-references SHALL be added to git-workflow, issue-operations, gitbucket-api, and release-promoter SKILL.md files, and the `.opencode/AGENTS.md` gb CLI tool documentation section SHALL reference the `gb-cli` skill
15. Behavioral enforcement tests SHALL verify skill discovery, auth checks, and merge prohibition
16. The `gb-cli` skill SHALL take precedence as the primary entry point for all `gb` CLI workflows; the `gitbucket-api` sub-skill SHALL delegate to `gb-cli` for workflow-level operations
17. The 7 `gitbucket-api` task files SHALL be adapted to remove duplicated `gb` CLI command reference tables and replace workflow-level `gb` command sequences with cross-references to `gb-cli` task cards, retaining only platform-specific routing logic

## Items

| Item | SC | Description |
|------|-----|-------------|
| 1 | SC-17 | Phase 1: Investigate against local test GitBucket instance, produce workflow applicability assessment |
| 2 | SC-1, SC-2, SC-3 | Create `.opencode/skills/gb-cli/SKILL.md` with valid YAML frontmatter (file exists, name matches, description ≤1024 chars) |
| 3 | SC-4 | Ensure SKILL.md uses routing-only template (no procedure text) |
| 4 | SC-5 | Ensure description field uses agent-intent format |
| 5 | SC-6 | Create task card files for workflows determined by Phase 1 |
| 6 | SC-7 | Ensure each task card follows canonical 6-section structure |
| 7 | SC-8 | Verify no overlap with git-workflow task cards |
| 8 | SC-9 | Add `gb auth status` entry criterion to all auth-dependent task cards |
| 9 | SC-11 | Ensure all gb CLI commands from capability manifest are covered |
| 10 | SC-12 | Create common-workflows task card with end-to-end examples |
| 11 | SC-13 | Add `gb pr merge` prohibition with CRITICAL VIOLATION block |
| 12 | SC-14, SC-15, SC-16 | Add SPDX-FileCopyrightText, Provenance, and AI co-authored byline to all files |
| 13 | SC-10 | Create and pass behavioral enforcement tests for skill discovery |
| 14 | SC-18a, SC-18b | Add `gb-cli` cross-references to git-workflow, issue-operations, gitbucket-api, and release-promoter SKILL.md files and update `.opencode/AGENTS.md` gb CLI tool documentation section to reference `gb-cli` |
| 15 | SC-19a, SC-19b | Adapt `gitbucket-api` SKILL.md to delegate to `gb-cli` for workflow-level operations, update description to indicate delegation |
| 16 | SC-20 | Audit 7 `gitbucket-api` task files, remove duplicated `gb` CLI command reference tables, replace workflow-level `gb` command sequences with cross-references to `gb-cli` |

## Dependencies

| Dependency | Type | Status | Notes |
|------------|------|--------|-------|
| .opencode#2191 | Spec | OPEN | gh-cli skill spec — must be implemented first as the reference template |
| gb CLI v0.6.1 | Tool | INSTALLED | Verified at `/home/muksihs/.local/bin/gb` |
| Local test GitBucket instance | Infrastructure | REQUIRED | Needed for Phase 1 investigation of workflow applicability |
| gitbucket-api sub-skill | Skill | EXISTING | Capability manifest documents gb CLI commands — reference source for command coverage |

## Traceability

| Requirement | SCs | Phase |
|-------------|-----|-------|
| R1 (skill location) | SC-1, SC-2, SC-3 | Phase 2 |
| R2 (routing-only template) | SC-4 | Phase 2 |
| R3 (agent-intent description) | SC-5 | Phase 2 |
| R4 (canonical task card structure) | SC-6, SC-7 | Phase 3 |
| R5 (auth entry criterion) | SC-6, SC-9 | Phase 3 |
| R6 (merge prohibition) | SC-13 | Phase 3 |
| R7 (SPDX header) | SC-14 | Phase 2, 3 |
| R8 (Provenance header) | SC-15 | Phase 2, 3 |
| R9 (AI co-authored byline) | SC-16 | Phase 2, 3 |
| R10 (no git-workflow overlap) | SC-8 | Phase 3 |
| R11 (investigation artifact) | SC-17 | Phase 1 |
| R12 (command coverage) | SC-11 | Phase 3 |
| R13 (common-workflows task card) | SC-12 | Phase 3 |
| R14 (cross-references) | SC-18a, SC-18b | Phase 4 |
| R15 (behavioral tests) | SC-10 | Phase 5 |
| R16 (gb-cli precedence) | SC-19a, SC-19b | Phase 6 |
| R17 (gitbucket-api adaptation) | SC-20 | Phase 6 |

## Documentation Sources

| Source | Type | Location | Verification |
|--------|------|----------|-------------|
| `.opencode/AGENTS.md` | config | `.opencode/AGENTS.md` — gb CLI tool documentation section | Verified via grep for `gb-cli` skill reference in the gb CLI section (2026-08-12) |
| gh-cli skill (reference template) | skill card | `.opencode/skills/gh-cli/SKILL.md` and `.opencode/skills/gh-cli/tasks/` | Read — routing-only template and task card structure reference from .opencode#2191 |
| gitbucket-api sub-skill (capability manifest) | skill card | `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` | Read — documents gb CLI command coverage and label mutation limitation |
| gitbucket-api task files | skill task cards | `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/` (7 files) | Read — adaptation targets for removing duplicated gb CLI command tables |
| Phase 1 applicability assessment | investigation artifact | `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml` | Read — per-workflow APPLIES/REVISED/DISCARDED classification with rationale |
| skill-card-schema | reference | `.opencode/reference/skill-card-schema.md` | Read — frontmatter constraints (name, description, license) |
| skill-card-description-standards | reference | `.opencode/reference/skill-card-description-standards.md` | Read — description field as semantic router, agent-intent format |
| task-card-structure-standards | reference | `.opencode/reference/task-card-structure-standards.md` | Read — canonical task card structure and header requirements |
| critical-rules-merge | guideline | `.opencode/guidelines/000-critical-rules.md` — critical-rules-merge | Read — human-only merge prohibition grounding for the `gb pr merge` prohibition |
| gb CLI v0.6.1 | tool | `/home/muksihs/.local/bin/gb` | Verified via `gb --version` → 0.6.1; `gb <command> --help` per command during Phase 1 |
| GitBucket test instance | infrastructure | Local instance (port 33905) | Verified via live gb commands in Phase 1 investigation (per gb-workflow-applicability.yaml) |

## Approach

### Phase 1: Local test GitBucket instance investigation (REQ R11)

1. Verify `gb` CLI v0.6.1 is installed and authenticated against a local test GitBucket instance
2. For each workflow from the gh-cli reference template, run the corresponding `gb` commands against the test instance to determine:
   - **APPLIES**: Workflow works as-is with gb command equivalents
   - **REVISED**: Workflow needs modification (different flags, different behavior, different output format)
   - **DISCARDED**: Workflow has no gb equivalent (e.g., gists, codespaces, secrets, org management, CI/CD runs)
3. Document gb-specific workflows not present in gh-cli (milestones, repo fork/delete, browse)
4. Produce per-workflow applicability assessment artifact at `.opencode/.issues/2201/artifacts/gb-workflow-applicability.yaml`
5. Expected gh-cli workflows to DISCARD (no gb equivalent): do-release, run-ci-cd, manage-secrets, manage-codespaces, manage-org, manage-gists, manage-keys, manage-projects, manage-aliases
6. Expected gb-specific workflows to ADD: manage-milestones, manage-repo (with fork/delete), api-requests

### Phase 2: Create skill directory and SKILL.md (REQ R1, R2, R3, R7, R8, R9)

1. Create `.opencode/skills/gb-cli/` directory
2. Write `SKILL.md` using routing-only template with:
   - YAML frontmatter: `name: gb-cli`, `description` in agent-intent format, `license: MIT`, `compatibility: opencode`
   - Overview: 1-2 sentences
   - Mandatory Task Discipline (5 items)
   - Workflows section with dispatch contracts for each workflow (determined by Phase 1)
   - Cross-References to `git-workflow`, `issue-operations`, `gitbucket-api`
   - SPDX-FileCopyrightText header, Provenance header, and AI co-authored byline
3. Verify no existing gb-cli skill in `.opencode/skills/` and target paths don't conflict with existing files

### Phase 3: Create task cards (REQ R4, R5, R6, R7, R8, R9, R10, R12, R13)

Create task cards organized by real agent workflows, adapted from gh-cli reference and filtered by Phase 1 investigation:

1. **authenticate.md** — Check `gb auth status` → if missing, `gb auth login` → verify → `gb config set` if needed
2. **create-pr.md** — `gb pr create` with title/body/head/base → `gb pr view` to verify (NOT merge — prohibited per critical-rules-merge)
3. **triage-issues.md** — `gb issue list` → `gb issue view` → `gb issue edit` (label/assign) → `gb issue comment` → maybe `gb issue close`
4. **review-pr.md** — `gb pr list` → `gb pr diff` → `gb pr comment` → `gb pr view`
5. **manage-repo.md** — `gb repo list/view/create` → `gb repo fork` → `gb repo delete` (with confirmation)
6. **manage-labels.md** — `gb label list/view/create/edit/delete` (document post-creation label limitation)
7. **manage-milestones.md** — `gb milestone list/view/create/edit/delete` (unique to gb, no gh equivalent)
8. **search-investigate.md** — Iterative listing + client-side filter (no native search API)
9. **api-requests.md** — `gb api <endpoint>` passthrough for unsupported operations
10. **completion.md** — `gb completion -s bash/zsh/fish/powershell`
11. **common-workflows.md** — End-to-end workflow examples

### Phase 4: Cross-reference integration (REQ R14)

- PR creation/checkout tasks reference `git-workflow` for branch operations
- Issue management tasks reference `issue-operations` for issue CRUD patterns
- Label management tasks reference `issue-operations` for label patterns
- Add `gb-cli` to relevant cross-reference sections in `git-workflow`, `issue-operations`, `gitbucket-api`, and `release-promoter`
- Update `.opencode/AGENTS.md` to reference `gb-cli` skill in the gb CLI tool documentation section

### Phase 5: Behavioral enforcement tests (REQ R15)

- Test that agent dispatches `gb-cli` skill when user asks for gb CLI operations
- Test that `gb auth status` is checked before gb operations
- Test that `gb pr merge` is NOT called (prohibition enforcement)

### Phase 6: Adapt gitbucket-api sub-skill to delegate to gb-cli (REQ R16, R17)

1. Audit all 7 task files in `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/` for duplicated `gb` CLI command content
2. For each file, replace workflow-level `gb` command sequences with cross-references to the corresponding `gb-cli` task card
3. Keep platform-specific routing logic (owner/repo resolution, auth verification, error recovery patterns specific to GitBucket)
4. Add cross-references to `gb-cli` in the `gitbucket-api` SKILL.md
5. Update the `gitbucket-api` SKILL.md description to indicate it delegates to `gb-cli` for workflow operations

## Affected Files

- `.opencode/skills/gb-cli/SKILL.md` — NEW: skill card
- `.opencode/skills/gb-cli/tasks/authenticate.md` — NEW: auth task card
- `.opencode/skills/gb-cli/tasks/create-pr.md` — NEW: PR creation task card
- `.opencode/skills/gb-cli/tasks/triage-issues.md` — NEW: issue triage task card
- `.opencode/skills/gb-cli/tasks/review-pr.md` — NEW: PR review task card
- `.opencode/skills/gb-cli/tasks/manage-repo.md` — NEW: repo management task card
- `.opencode/skills/gb-cli/tasks/manage-labels.md` — NEW: label management task card
- `.opencode/skills/gb-cli/tasks/manage-milestones.md` — NEW: milestone management task card
- `.opencode/skills/gb-cli/tasks/search-investigate.md` — NEW: search/investigation task card
- `.opencode/skills/gb-cli/tasks/api-requests.md` — NEW: API passthrough task card
- `.opencode/skills/gb-cli/tasks/completion.md` — NEW: shell completion task card
- `.opencode/skills/gb-cli/tasks/common-workflows.md` — NEW: common workflows task card
- `.opencode/skills/git-workflow/SKILL.md` — MODIFY: add gb-cli cross-reference
- `.opencode/skills/issue-operations/SKILL.md` — MODIFY: add gb-cli cross-reference
- `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` — MODIFY: add gb-cli cross-reference, update description to indicate delegation
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/tool-detection.md` — MODIFY: delegate to gb-cli
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md` — MODIFY: delegate to gb-cli
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/session-integration.md` — MODIFY: delegate to gb-cli
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md` — MODIFY: delegate to gb-cli
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/error-recovery.md` — MODIFY: delegate to gb-cli
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md` — MODIFY: delegate to gb-cli
- `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/repository-operations.md` — MODIFY: delegate to gb-cli
- `.opencode/skills/release-promoter/SKILL.md` — MODIFY: add gb-cli cross-reference
- `.opencode/AGENTS.md` — MODIFY: add gb-cli to gb CLI tool documentation section (separate from cross-references)
- `.opencode/tests-v2/behaviors/gb-cli-skill-discovery.sh` — NEW: behavioral test
- `.opencode/tests-v2/behaviors/gb-cli-auth-check.sh` — NEW: behavioral test
- `.opencode/tests-v2/behaviors/gb-cli-merge-prohibition.sh` — NEW: behavioral test

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Overlap with git-workflow skill | Explicit delegation: gb-cli handles gb-specific commands, git-workflow handles git operations. Cross-reference in both skills. |
| `gb pr merge` used by agent | CRITICAL VIOLATION block in create-pr and review-pr task cards. Behavioral test enforces prohibition. |
| Stale command flags (gb CLI evolves) | Task cards reference `gb <command> --help` as verification step before using flags. |
| Authentication not checked before operations | `gb auth status` verification as entry criterion in all auth-dependent task cards. |
| Post-creation label mutation broken | Document limitation in manage-labels task card; labels must be added at issue creation time. |
| No native search API | Document limitation in search-investigate task card; use iterative listing + client-side filter. |
| Local test GitBucket instance unavailable | Phase 1 investigation is blocked without test instance. Document as hard prerequisite. |
| .opencode#2191 not yet implemented | This spec depends on gh-cli as reference template. Implementation must wait for #2191 to be complete. |

## Edge Cases

| Edge Case | Handling |
|-----------|----------|
| gb CLI not installed | Task cards include `gb auth status` as entry criterion; if command not found, task returns BLOCKED with TOOL_MISSING reason |
| gb CLI version < 0.6.1 | Version check in authenticate task card; return BLOCKED if version is below minimum |
| File write permission errors | Phase 2 includes write-permission check; if `.opencode/skills/` is not writable, task returns BLOCKED |
| Naming conflicts with existing skills | Phase 2 Step 3 includes conflict check: verify no existing `gb-cli` skill directory and no target path conflicts |
| GitBucket instance returns errors | Error recovery patterns from gitbucket-api sub-skill; document in relevant task cards |
| gh-cli skill structure changes | This spec references gh-cli as a template; if gh-cli structure changes, this spec's task card structure may need revision |

## Change Control

| Date | Change | Reason | Author |
|------|--------|--------|--------|
| 2026-07-30 | Initial spec creation | New gb-cli skill for GitBucket CLI operations | Spec creation pipeline |
| 2026-07-30 | Decomposed SC-1 into SC-1/SC-2/SC-3 (atomicity), renumbered SC-2→SC-4 through SC-13→SC-15, added SC-16 for cross-reference traceability (R11), added REQ references to phase headings, added release-promoter to cross-reference targets | Validation findings: atomicity FAIL (SC-1 compound), traceability FAIL (R11 no SC mapping), structural FAIL (Phase 4 heading lacks REQ references) | Spec revision pipeline |
| 2026-07-30 | Consistency fix: SC-16/Item 14/Affected Files now list all 4 cross-reference targets (git-workflow, issue-operations, gitbucket-api, release-promoter). Traceability fix: SC-6 mapped to R4 and R5. Structural fix: Phase 5 heading now includes (REQ R12). AGENTS.md separated from cross-references in Affected Files. | Validation findings: consistency FAIL (SC-16 vs R11 vs Affected Files mismatch), traceability FAIL (SC-6 no requirement mapping), structural FAIL (Phase 5 heading missing REQ R12) | Spec revision pipeline |
| 2026-07-30 | Traceability fix: added R13 (common-workflows task card), mapped SC-12 to R13. Atomicity fix: decomposed SC-14 into SC-14 (SPDX), SC-15 (Provenance), SC-16 (byline). Renumbered SC-15→SC-17, SC-16→SC-18. Updated all cross-references (Items, Traceability, Cost-Frame, Enforcement Gate, Phase REQ references). | Validation findings: traceability FAIL (SC-12 no requirement mapping), atomicity FAIL (SC-14 compound) | Spec revision pipeline |
| 2026-07-30 | Added R16 (gb-cli precedence), R17 (gitbucket-api adaptation), SC-19 (gb-cli takes precedence), SC-20 (gitbucket-api task files adapted), Phase 6 (gitbucket-api sub-skill adaptation), Items 15-16, updated Traceability, Cost-Frame, Enforcement Gate, Affected Files, and Not Included section. | Developer feedback: gitbucket-api sub-skill must delegate to gb-cli for workflow-level operations rather than duplicating gb CLI commands | Spec revision pipeline |
| 2026-08-12 | Extended SC-18 criterion text to include `.opencode/AGENTS.md` (gb CLI tool documentation section must reference the gb-cli skill). Updated Cost-Frame justification and Item 14 for consistency. | Pre-PR gate VERIFICATION-GAP: SC-18 criterion covered only the 4 SKILL.md files while the Affected Files section and plan Phase 4 also target `.opencode/AGENTS.md`; non-substantive SC wording fix — no scope, evidence type, or implementation intent changes | Spec revision pipeline |
| 2026-08-12 | Reworded SC-12 criterion to pin the `common-workflows.md` task card as the sole deliverable (removed the "Common Workflows section or task card" alternative) and aligned the verification method to a deterministic `ls` check on the task card file | Spec validation FAIL on determinism defect: SC-12 criterion contained either/or ambiguity ("Common Workflows section or task card") creating a criterion/verification mismatch — the structural verification method only tests the common-workflows.md task card file. Non-substantive wording fix — no scope, evidence type, or implementation intent changes; the common-workflows.md task card already exists and is verified | Spec revision pipeline |
| 2026-08-12 | Added "User Intent / Original Prompt" to the preamble (6th required field). Added Documentation Sources column to the SC table and a Documentation Sources section. Restructured the Cost Frame to add the computation frame ("cost is measured in defect-discovery-latency, not tool calls"), per-SC action + skipping cost, and the identity anchor ("correctness is the only metric"). Reworded SC-6 to state the 11-task-card set deterministically (removed the "expected:" hedge). Decomposed SC-18 into SC-18a (4 SKILL.md cross-references) and SC-18b (AGENTS.md reference); decomposed SC-19 into SC-19a (gb-cli precedence) and SC-19b (gitbucket-api delegation). Updated Items, Traceability, Enforcement Gate, and Cost Frame to match. | Spec validation FAIL with 5 hard structural defects: (1) dark-prose-007 cost-frame incomplete — missing computation frame, skipping cost, and identity anchor; (2) Documentation Sources section and SC table column missing; (3) preamble missing "User Intent / Original Prompt" field; (4) SC-6 determinism — "expected:" hedge; (5) compound SCs — SC-18 and SC-19. Non-substantive structural fixes — no scope, evidence type, or implementation intent changes; SC-18 AGENTS.md coverage preserved via SC-18b | Spec revision pipeline |
