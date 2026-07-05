# Task: pr-creation/create-pr

## Purpose

PR body creation IS verification evidence publishing. Every PR body requires preceding verification PASS. No valid PR exists without verification evidence embedded in the body — a PR without evidence is a PR that carries undiscovered defects into the codebase.

Create the pull request after squash/push, collect sub-issues, generate PR body, and extract PR URL from API response.

## --release Mode (Post-Merge Steps)

When invoked with `--release` flag, this task performs post-merge steps after PR merge:

- **Semver tagging:** Auto-increment patch version (or developer-specified), create annotated tag on `main`
- **Platform release creation:** Create GitHub/GitBucket release with synthesized release notes
- **Release notes synthesis:** Summarize changes since last release by category (features, fixes, maintenance)

## Entry Criteria

- Enforcement gates passed (pr-creation/enforcement-gate)
- Branch squashed and pushed (pr-creation/squash-push)
- `--release` mode: PR has been merged by human, developer requests post-merge steps

## Exit Criteria

- PR created via GitHub API or GitBucket CLI
- PR URL extracted from API response (NEVER constructed from template)
- Executive summary reported in chat
- Agent HALTs waiting for human merge
- `--release` mode: Semver tag created and pushed, platform release created, release notes posted

## Procedure

### Step 4.5: Dispatch Chain Compliance Gate (MANDATORY — Before PR Creation)

**The verification-evidence check is a gate, not a banner. A PR without evidence is not a PR with a warning label — it is a PR that does not exist.**

Before reading any artifacts or assembling the PR body, verify that the work was produced through the proper dispatch chain:

1. Check the dispatch log for `skill({name: "verification-before-completion"})` and `skill({name: "adversarial-audit"})` calls
2. If either `skill()` call is MISSING from the dispatch log: return BLOCKED with `DISPATCH_CHAIN_VIOLATION`
3. If both `skill()` calls are present: proceed to Step 4.75

**No override path exists.** A PR created from inline work carries undiscovered defects regardless of how correct the output looks.

### Step 4.75: Read Source Artifacts

The Summary section MUST be sourced from the issue ticket body that authorized the work — not from agent memory, free-form paraphrasing, or implementation details.

**Summary Sourcing Rule:**
1. Route through `issue-operations --task read-issue` on the parent issue
2. Extract the core problem statement or intent from the issue body
3. Rephrase into 1-2 succinct sentences describing stakeholder impact
4. NEVER use direct `github_issue_read` calls — all issue reads MUST route through the `issue-operations` dispatcher per `000-critical-rules.md` §critical-rules-platform-routing-bypass

**Forbidden:**
- Direct `github_*` calls bypassing `issue-operations` dispatcher
- Free-form paraphrasing from agent memory of what was implemented
- Implementation-detail summaries ("Added a method to class X that validates Y")
- Hallucinated intent not present in the source issue

**Data Flow:**

| Body Section | Source | Access Method |
|--------------|--------|---------------|
| **Summary** | Issue ticket body (spec/plan issue for this PR) | `issue-operations --task read-issue` on parent issue |
| **Outcome** | Issue ticket body + implementation knowledge | Synthesized from issue body + changesets |
| **Per-SC Evidence** | VbC verification report | `read {project_root}/tmp/{issue-N}/artifacts/verification-*.md` |
| **Dual-Auditor Cross-Validation** | Cross-validate result contract | `read {project_root}/tmp/{issue-N}/artifacts/audit-cross-validate-*.json` |
| **Tracking references** | Sub-issues from parent | `issue-operations --task read-sub-issues` on parent issue |

### Step 4.75: Verification-Evidence-Check Gate

The verification-evidence check is a gate, not a banner. A PR without evidence is not a PR with a warning label — it is a PR that does not exist. The create-pr sub-agent that produces an unverified PR is not creating a deliverable; it is routing a defect into the codebase under a label that no reviewer will read. Every unverified PR that reaches a reviewer is a quality failure that verification should have caught. No valid PR exists without a preceding verification PASS — the gate is the identity, not the label.

**Before proceeding to Step 5, check that required verification artifacts exist:**

1. Check `{project_root}/tmp/{issue-N}/artifacts/verification-*.md` exists and contains PASS for all SCs
2. Check `{project_root}/tmp/{issue-N}/artifacts/audit-cross-validate-*.json` exists and reports consensus PASS from both auditors
3. If any artifact is MISSING or reports FAIL: do NOT create a PR

**Blocked State (Missing or Failing Verification Evidence):**

If verification or audit evidence is missing or reports FAIL, return BLOCKED status with structured defect list:

```
Status: BLOCKED
Gate: verification-evidence-check
Blockers:
  - [MISSING|FAIL] <path> — <description>
    <details>
remediation: "<action to remediate>"
next_step: "remediate then re-audit"
```

Example:
```
Status: BLOCKED
Gate: verification-evidence-check
Blockers:
  - [MISSING] {project_root}/tmp/{issue-N}/artifacts/verification-*.md — VbC evidence not found
  - [FAIL] {project_root}/tmp/{issue-N}/artifacts/audit-cross-validate-*.json — auditor consensus reports FAIL
    SC-1: Auditor 1 PASS, Auditor 2 FAIL
    Remediation: Re-audit SC-1 with fresh model pair
remediation: "Run verification-before-completion --task verify, then adversarial-audit before retrying PR creation"
next_step: "remediate then re-audit"
```

**No PR is created in this state.** The orchestrator receives the BLOCKED contract and routes to remediation.

### Step 4.8: Rebase Before PR Creation

Before creating the PR, rebase on the target branch to ensure mergability:

```bash
git fetch origin <target>
git rebase origin/<target>
```

### Step 5: Collect Sub-Issues (Multi-Task Specs)

```python
sub_issues = issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=<parent>) <!-- Routes through issue-operations per SPEC #683 -->
autoclose_issues = [<parent>] + [sub["number"] for sub in sub_issues]
```

**Scope-dependent PR strategy:**

| `pr_strategy` | PR Behavior |
| -- | -- |
| `stacked` | Single PR for all issues in work set |
| `none` | No PR creation — halt_at boundary |

**⚠️ CRITICAL: Sub-issues are closed by the cleanup task via API, NOT by autoclose.** GitHub autoclose is inert for `dev`-branch merges.

### Step 6: Create PR (Platform-Agnostic)

**GitHub (`github.platform=github`):**

```python
github_create_pull_request(
    owner=<github.owner>,
    repo=<github.repo>,
    title="[SPEC] <description>",  # When is_release: true, use "Release v<version>: promote <target> → main"
    body="""**Summary:**

<1-2 sentences describing impact and stakeholder value, sourced from issue body via issue-operations --task read-issue>

**Outcome:** <What changed for stakeholders>

**Verification Attestation:** All success criteria verified PASS — exact-match against live evidence. Dual independent auditors from different model families returned consensus PASS on every criterion. No caveats. No qualifications. Every PASS is a binary exact match. This deliverable is ready for merge.

**Detail: Per-SC Evidence**

| SC ID | Success Criterion | Evidence Type | Command | Result |
|-------|-------------------|---------------|---------|--------|
| SC-1 | ... | structural | ... | PASS |
| SC-2 | ... | behavioral | ... | PASS |

**Detail: Dual-Auditor Cross-Validation**

| Criterion | Evidence Type | Auditor 1 | Auditor 2 | Consensus |
|-----------|---------------|-----------|-----------|-----------|
| SC-1 | PASS | PASS | PASS |
| SC-2 | PASS | PASS | PASS |

**Detail: Spec-Card-Mapped Commits**

| Commit | Issue | Spec Card | Description |
|--------|-------|-----------|-------------|
| <sha> | #<N> | SC-<M> | <description> |

Implements #<parent>
""",  # When is_release: true, synthesize release notes from commit log and include in body
    head=branch_name,
    base="<target>"
)
```

**GitBucket (`github.platform=gitbucket`):**

```bash
./.opencode/tools/gitbucket-api create-pr <owner> <repo> "[SPEC] <description>" <branch-name> <target> --body "<PR body>"
```

### Step 6.1: Rebase After Push

After pushing and creating the PR, rebase again to double-check for remote conflicts:

```bash
git fetch origin <target>
git rebase origin/<target>
```

### PR Body Requirements

A Summary sourced from the issue ticket through the issue-operations dispatcher is what correct attribution looks like. A free-formed summary means the reviewer cannot verify intent against the authorizing issue — the summary is an unverifiable assertion. Professional-grade PRs derive their Summary from the authorizing issue; bodies that fabricate it introduce scope the reviewer never approved.

- **Summary** section: 1-2 sentences describing stakeholder value (NOT implementation details) — sourced from issue body via `issue-operations --task read-issue`
- **Outcome** section: What changed for stakeholders
- **Verification Attestation**: Binary PASS language — no caveats, no justifications, no false-fail remediation language
- **Per-SC Evidence Table**: SC ID, Success Criterion, Evidence Type, Command, Result columns — the Evidence Type column is MANDATORY per `080-code-standards.md` §Evidence Type Taxonomy
- **Dual-Auditor Cross-Validation Table**: Criterion, Auditor 1, Auditor 2, Consensus columns
- **Spec-Card-Mapped Commits Table**: Commit, Issue, Spec Card, Description columns — maps each commit to the spec card it implements
- `Fixes #N` or `Implements #N` annotations at bottom (informational — autoclose is inert for `<target>` merges)
- Target branch is `<target>` for feature work

**Use `Implements #N` instead of `Fixes #N` when the issue has sub-issues or is part of a plan-bridge hierarchy.**

### ❌ WRONG (Implementation Details)
```
Add adversarial-audit --task plan-fidelity as the first auditor in the mandatory audit chain. It generates independent clean-room plans from problem statements and compares them against existing spec plans to identify substantive gaps.
```

### ✅ CORRECT (Executive Summary)
```
**Summary:**

Ensures specs are audited for plan fidelity before implementation, catching missing phases and scope misalignment early.

**Outcome:** Developers will catch spec quality issues before code changes begin.

Fixes #505
```

### Step 6.5: Verify Byline in PR Body (MANDATORY)

The byline is the authorship check — the verification table is the quality check. A PR body with a byline but without verification evidence is incomplete — it carries authorship attribution without quality attestation. The implementing agent reads #627 Section 3 to derive the exact confirmshaming formula; the consequence assertion must match the PR domain. The verification evidence tables in this PR body satisfy the quality check requirement.

**Before calling the PR creation API, verify the PR body contains an AI co-authored byline.**

All AI-authored PR bodies MUST contain one of the following byline patterns:

| Format | Pattern |
|--------|---------|
| Emoji format | `🤖 Co-authored with AI: <AgentName> (<ModelId>)` |
| Non-emoji format | `Co-authored with AI: <AgentName> (<ModelId>)` |

**Verification:**
1. Scan the assembled PR `body` string for `Co-authored with AI:` before the API call
2. If missing: append a byline footer to the body:

```
🤖 Co-authored with AI: <AgentName> (<ModelId>)
```

3. If present: proceed to the API call

**Per `000-critical-rules.md` §Critical Violation: Posting AI-Authored Content Without Byline Verification.**

### Step 6.75: Check for --release Flag

If `is_release: true`, proceed to post-merge steps (Step 7.x). Otherwise, continue to Step 7.

### Step 7: EXTRACT URL FROM API RESPONSE

**🚫 CRITICAL VIOLATION: Fabricating URLs from template is a CRITICAL GUIDELINE VIOLATION.**

1. Copy PR URL verbatim from the `github_create_pull_request` response `html_url` field
2. Do NOT retype, reconstruct, or assemble from known values
3. Verification checkpoint: Compare pasted URL character-by-character against `html_url`

### Step 7.1: Post-Merge Steps (--release Mode)

When `is_release: true` and the PR has been merged by a human:

#### Step 7.1.1: Determine Version

1. Fetch latest tag matching `<parent>/v*` from `main`
2. Auto-increment patch version (e.g., `v0.1.1` → `v0.1.2`)
3. If developer specified a version, use that instead

#### Step 7.1.2: Create Annotated Tag

```bash
git tag -a <parent>/v<version> -m "Release <parent>/v<version>"
git push origin <parent>/v<version>
```

#### Step 7.1.3: Create Platform Release

**GitHub:**
```python
github_create_release(
    owner=<github.owner>,
    repo=<github.repo>,
    tag_name="<parent>/v<version>",
    name="Release v<version>",
    body="<synthesized release notes>"
)
```

**GitBucket:**
```bash
./.opencode/tools/gitbucket-api create-release <owner> <repo> <parent>/v<version> --body "<release notes>"
```

#### Step 7.1.4: Synthesize Release Notes

Summarize changes since last release tag by category:
- **Features:** New capabilities added
- **Fixes:** Bug fixes and corrections
- **Maintenance:** Refactoring, documentation, tooling

Source: `git log <last-release-tag>..HEAD --oneline --no-merges`

### Step 7.5: Report PR URL and HALT

**Mandatory format:**

```
**Summary:**

<1-2 sentences describing impact and stakeholder value>

**Outcome:** <What changed for stakeholders>

**PR URL:** <html_url from API response>


```

**Format requirements:**
- Executive summary FIRST
- PR URL LAST (before byline)
- Label MUST be "PR URL" (post-creation context)

### Agent Merge Prohibition

**🚫 ABSOLUTE PROHIBITION: AGENTS MUST NEVER MERGE PRs.**

- ALL PRs require human review before merge
- "go" does NOT authorize merging
- After PR creation: report URL and HALT

### Sub-Issue Autoclose Table

| Spec Type | PR Body Format |
| -- | -- |
| Single-task | `Fixes #<parent>` |
| Multi-task | `Fixes #<parent>` AND `Fixes #<child>` for each sub-issue |
| Work | `## Work Items\n\n#<issue1>\n#<issue2>\n\nFixes #<parent1>\nFixes #<child1>` |

### Common Issues

| Issue | Resolution |
| -- | -- |
| No commits between branches | Report: "Branch has no commits. Changes may already be merged." |
| Branch conflicts | Rebase on <target>: `git rebase origin/<target>` |
| Wrong base branch | Close PR, create new one with `base="<target>"` |

## Context Required

- Related tasks: `pr-creation/enforcement-gate`, `pr-creation/squash-push`
- Related guidelines: `000-critical-rules.md` (URL sourcing, PR body format)
