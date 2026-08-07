> **Full spec and artifacts: [`.opencode/.issues/2257/`](https://github.com/michael-conrad/.opencode/tree/issues-data/2257)** — this issue is a condensed exec summary; the authoritative spec lives in the `issues-data` branch.
>
> **Local artifacts:** `.opencode/.issues/2257/` — implementation plan, card catalogue, dependency contracts, research, designs, audit findings

# [SPEC] Fix GitBucket label operation documentation (local test instance validation)

## Objective

Empirically determine the actual GitBucket label-operation workflow against a live local GitBucket instance, then update the `gitbucket-api` platform sub-skill cards (`label-operations.md`, `SKILL.md` capability manifest, and downstream `issue-operations.md` / `mcp-operations.md` references) to reflect the verified truth — replacing the currently documented-BROKEN status with evidence-based capability claims.

## Background

The GitBucket platform sub-skill documents post-creation label mutation (issue-level `POST/PUT/DELETE /repos/{owner}/{repo}/issues/{number}/labels`) as **BROKEN**:

- `label-operations.md` (lines 18-56): POST and PUT documented as returning HTTP 200 with an empty array but NOT adding/setting labels; remove-specific and remove-all documented as having no `gb` command.
- `SKILL.md` capability manifest (lines 44-45): "Post-creation labels" → ❌ "Returns empty array — labels NOT added".
- `issue-operations.md` (lines 109-124): "CRITICAL: Post-creation label APIs are BROKEN in GitBucket"; workaround is "Delete and recreate the issue if labels need to change".
- `mcp-operations.md` (lines 115-125): "Labels Can ONLY Be Set During Creation".

However, a `gb api` REST call with `{"labels":[...]}` reportedly **WORKED reliably** in practice. The OpenAPI v4.42.1 reference (`openapi-v4.42.1.json`) documents ONLY repo-level label endpoints (`/repos/{owner}/{repo}/labels` GET/POST) — no issue-level `/issues/{number}/labels` sub-resource paths exist in the bundled spec (total 23 paths, zero issue sub-resource paths).

The truth is therefore **UNCONFIRMED**. The documented-BROKEN status and the anecdotal-WORKING report cannot both be correct. This spec resolves the contradiction by empirically testing against a live local GitBucket instance and correcting the skill cards to the verified workflow.

### Current State (last verified: 2026-08-07 via live file reads)

| Component | Documented Status | Evidence |
|-----------|-------------------|----------|
| `label-operations.md` | POST/PUT BROKEN (returns `[]`); remove/remove-all BROKEN (no gb command) | `label-operations.md:18-56` |
| `SKILL.md` capability manifest | "Post-creation labels" → ❌ "Returns empty array — labels NOT added" | `SKILL.md:44-45` |
| `issue-operations.md` | "CRITICAL: Post-creation label APIs are BROKEN"; workaround = delete-and-recreate | `issue-operations.md:109-124` |
| `mcp-operations.md` | "Labels Can ONLY Be Set During Creation" | `mcp-operations.md:115-125` |
| OpenAPI v4.42.1 reference | Only repo-level `/repos/{owner}/{repo}/labels` endpoints; zero issue sub-resource paths | `openapi-v4.42.1.json` (23 paths) |
| Prior live-test record | POST/PUT → 200, `[]`, labels NOT added; creation-time labels WORK | `API-DEFICIENCIES.md` (GitBucket v4.42.1, 2026-04-06) |

## Not Included

- Changes to the OpenAPI reference spec file itself (`openapi-v4.42.1.json`) — it is a bundled vendor artifact, not a skill card.
- Re-architecting GitBucket API behavior — only documenting the verified actual behavior.
- Changing the local `issue.yaml` canonical-authorization doctrine from #2241 (remote labels remain best-effort/advisory).
- Modifying the `gb` CLI tool source (external dependency).

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | The sanctioned GitBucket harness (`__ensure_gitbucket` in `.opencode/tests-v2/behaviors/helpers.sh`) provisions a reachable, authenticated GitBucket instance with a test repository | `behavioral` | Run harness; assert `gb auth status` succeeds and `gb repo view O/R` returns the test repo against the instance |
| SC-2 | Issue-level label mutation behavior is empirically determined: `POST/PUT/DELETE /repos/{owner}/{repo}/issues/{number}/labels` via `gb api` with `{"labels":[...]}` either confirmed to apply labels (WORKING) or confirmed to return empty/no-op (BROKEN), with `get_issue` label readback evidence | `behavioral` | Execute `gb api` REST probes against the live instance; readback via `gb issue view` after each write to confirm actual label state |
| SC-3 | Repo-level label CRUD (`gb label list/create/view/edit/delete`) is confirmed WORKING against the instance | `behavioral` | Execute `gb label` commands against the live instance; confirm each succeeds |
| SC-4 | The correct issue-level vs repo-level capability split is synthesized from SC-2 + SC-3 empirical results | `structural` | Derive the separation from the verified empirical outcomes of SC-2 and SC-3 |
| SC-5 | `label-operations.md` is updated to the verified workflow (add/replace/remove/remove-all plus repo-level section), removing false BROKEN claims if issue-level works | `string` | Deterministic grep for corrected operation status in `label-operations.md` matches verified truth |
| SC-6 | `SKILL.md` capability manifest "Post-creation labels" row (and any label-related rows) is corrected to the verified workflow | `string` | Deterministic grep of the capability manifest row in `gitbucket-api/SKILL.md` matches verified truth |
| SC-7 | Downstream references in `issue-operations.md` and `mcp-operations.md` are corrected to match the verified workflow | `string` | Deterministic grep for corrected label guidance in both files matches verified truth |

## Requirements

1. The agent SHALL provision a live local GitBucket instance using the sanctioned self-contained harness (`.opencode/tests-v2/behaviors/helpers.sh` `__ensure_gitbucket`, `BEHAVIOR_NEEDS_REMOTE=1`) — NOT ad-hoc manual instance spin-up outside the harness.
2. The agent SHALL empirically test issue-level label mutation (`POST/PUT/DELETE /repos/{owner}/{repo}/issues/{number}/labels` via `gb api` with `{"labels":[...]}`) against the live instance.
3. The agent SHALL empirically test repo-level label CRUD (`gb label list/create/view/edit/delete`) against the live instance.
4. The agent SHALL read back actual label state via `get_issue` / `gb issue view` after every label write — no self-deception.
5. The agent SHALL synthesize the correct issue-level vs repo-level capability split from the empirical results.
6. The agent SHALL update `label-operations.md`, `SKILL.md` capability manifest, `issue-operations.md`, and `mcp-operations.md` to reflect the verified workflow.
7. The correction SHALL be evidence-based from the live test — NOT assumed from prior docs.
8. Any behavioral verification SHALL go through `bash .opencode/tests-v2/with-test-home opencode run ...` (never direct `opencode run`); bash tool timeout SHALL be >= 600000ms for behavioral runs.
9. The `gb` CLI v0.6.1 version check SHALL be enforced at skill entry.
10. The correction SHALL NOT re-introduce remote-dependence as canonical — #2241 made local `issue.yaml` the canonical authorization source; remote labels remain best-effort/advisory.
11. The change targets the `.opencode` submodule; a submodule pointer update SHALL accompany any parent-repo change (per submodule discipline).

## Items

| Item | SC | Description |
|------|-----|-------------|
| 1 | SC-1 | Provision live GitBucket instance via `__ensure_gitbucket`; verify reachable + authed + test repo |
| 2 | SC-2 | Empirically probe issue-level label mutation (POST/PUT/DELETE `/issues/{number}/labels` via `gb api`); readback via `get_issue` |
| 3 | SC-3 | Empirically verify repo-level label CRUD (`gb label list/create/view/edit/delete`) |
| 4 | SC-4 | Synthesize issue-level vs repo-level capability split from SC-2 + SC-3 results |
| 5 | SC-5 | Update `label-operations.md` to verified workflow (add/replace/remove/remove-all + repo-level section) |
| 6 | SC-6 | Correct `SKILL.md` capability manifest "Post-creation labels" row and label rows |
| 7 | SC-7 | Correct `issue-operations.md` and `mcp-operations.md` label claims to verified workflow |

## Edge Cases

| Condition | Expected Behavior | Recovery |
|-----------|-------------------|----------|
| Live instance unreachable | Item-01 BLOCKED; spec cannot proceed | Verify harness, port, token; re-run `__ensure_gitbucket` |
| Issue-level label mutation genuinely broken | SC-2 confirms BROKEN; keeps current docs mostly, records precise behavior, adds repo-level as only valid path | Document verified BROKEN with readback evidence |
| Issue-level label mutation actually works | SC-2 confirms WORKING; items 05-07 remove false BROKEN claims | Document verified WORKING with readback evidence |
| Test leaves dirty state | Harness `__reset_gitbucket` for clean state between scenarios | Run `__reset_gitbucket` between scenarios |
| `gb` CLI missing or < 0.6.1 | TOOL_MISSING / VERSION_CHECK_FAILED at skill entry | Install gb v0.6.1 from https://github.com/Masahiro-Obuchi/gitbucket-cli-rs |

## Documentation Sources

| Source | Path | Purpose |
|--------|------|---------|
| `label-operations.md` | `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md` | Current BROKEN label-ops documentation to correct |
| `SKILL.md` | `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md` | Capability manifest "Post-creation labels" row to correct |
| `issue-operations.md` | `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md` | Downstream BROKEN label claims to correct |
| `mcp-operations.md` | `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md` | Downstream "Labels Can ONLY Be Set During Creation" claim to correct |
| `helpers.sh` | `.opencode/tests-v2/behaviors/helpers.sh` | `__ensure_gitbucket` harness for live instance provisioning |
| `API-DEFICIENCIES.md` | `tmp/test-project-*/.../gitbucket-api/API-DEFICIENCIES.md` | Prior live-test record (GitBucket v4.42.1, 2026-04-06) |
| `openapi-v4.42.1.json` | `.opencode/skills/issue-operations/platforms/gitbucket-api/reference/` | Bundled OpenAPI reference (repo-level label endpoints only) |
| `gb` CLI | https://github.com/Masahiro-Obuchi/gitbucket-cli-rs | GitBucket API client (v0.6.1) |

## Cost Frame

Verification cost is measured in **defect-discovery-latency (DDL)** — the time between defect introduction and discovery. Shorter DDL means cheaper fixes; longer DDL means exponentially compounding cost.

| SC | DDL Frame | Death Spiral Risk | Break Point |
|----|-----------|-------------------|-------------|
| SC-1 | Behavioral harness run — ~2min execution, catches unreachable/unauthed instance at provisioning | High — a broken harness invalidates all downstream empirical results | Pre-PR |
| SC-2 | Behavioral live REST probe — ~2min execution, catches wrong issue-level label capability claim | High — a wrong BROKEN/WORKING claim propagates to all four skill cards | Pre-PR |
| SC-3 | Behavioral live REST probe — ~2min execution, catches wrong repo-level label capability claim | High — a wrong repo-level claim misroutes label operations | Pre-PR |
| SC-4 | Structural synthesis — derived from SC-2 + SC-3 verified results | Medium — wrong split misdocuments capability boundaries | Pre-PR |
| SC-5 | String grep — ~1s execution, catches stale BROKEN claim in `label-operations.md` | Low — structural check at pre-commit gate | Pre-commit |
| SC-6 | String grep — ~1s execution, catches stale capability manifest row in `SKILL.md` | Low — structural check at pre-commit gate | Pre-commit |
| SC-7 | String grep — ~1s execution, catches stale label guidance in downstream cards | Low — structural check at pre-commit gate | Pre-commit |

## SC Enforcement Gate

**All SCs MUST pass before this fix is considered complete. No partial delivery is permitted — if any SC fails, the entire fix is BLOCKED until remediation resolves the failure.** This is a hard gate: a single FAIL among the 7 SCs blocks advancement to PR creation. The 3 behavioral SCs (SC-1, SC-2, SC-3) require clean-room semantic evaluation against live GitBucket instance output — grep/string evidence is insufficient for behavioral SCs.

## Dependencies

- **#2165** (provision GitBucket for remote API tests) — provides the harness infrastructure reused by SC-1.
- **#2161** (verify needs-approval label on remote) — related label verification work.
- **#2241** (local issue.yaml canonical; remote labels advisory/best-effort) — constrains the correction to not re-introduce remote-dependence as canonical.

## Traceability

| Requirement | SCs | Items |
|-------------|-----|-------|
| REQ-1, REQ-8, REQ-9 | SC-1 | 1 |
| REQ-2, REQ-4 | SC-2 | 2 |
| REQ-3, REQ-4 | SC-3 | 3 |
| REQ-5 | SC-4 | 4 |
| REQ-6, REQ-7 | SC-5 | 5 |
| REQ-6, REQ-7 | SC-6 | 6 |
| REQ-6, REQ-7 | SC-7 | 7 |
| REQ-10, REQ-11 | (constraint) | (all) |
