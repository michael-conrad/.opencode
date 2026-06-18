# Task: cleanup/issue-closure

## Purpose

Hierarchical issue closure after PR merge verification. Handles plan→spec upward references, spec→plan downward closure, cross-references, and transitive graph reconciliation.

## Entry Criteria

- PR merge verified (cleanup/verify-merge completed)
- SC-verification and phase-completion gates passed

## Exit Criteria

- All referenced issues evaluated and closed where appropriate
- Orphaned sub-issues identified and flagged
- Transitive graph reconciliation complete

## Procedure

### Step 1: Collect Referenced Issues from PR Body with Keyword Classification

Parse the PR body for all issue reference patterns. **Each issue is classified by the keyword that introduced it.**

| Pattern | Matches | Purpose | Semantic Classification |
| -- | -- | -- | -- |
| `Spec:\s*#(\d+)` | `Spec: #959` | Plan→Spec upward | `spec_ref` |
| `Plan:\s*#(\d+)` | `Plan: #960` | Spec→Plan downward | `plan_ref` |
| `Fixes\s*#(\d+)` | `Fixes #968` | Cross-reference | `fixes` → unconditional close (subject to spec checks) |
| `Implements\s*#(\d+)` | `Implements #866` | Partial implementation | `implements` → completeness check required before close |
| `Related\s*#(\d+)` | `Related #100` | Weak reference (evaluate only) | `related` → never auto-close |

```python
patterns = {
    "spec_ref": r"Spec:\s*#(\d+)",
    "plan_ref": r"Plan:\s*#(\d+)",
    "fixes": r"Fixes\s*#(\d+)",
    "implements": r"Implements\s*#(\d+)",
    "related": r"Related\s*#(\d+)",
}

closure_candidates = {}
for pattern_name, pattern in patterns.items():
    for match in re.finditer(pattern, pr_body):
        issue_num = int(match.group(1))
        closure_candidates[issue_num] = pattern_name
```

**Keyword → Closure Behavior Routing Table:**

| Keyword | Closure Behavior |
|---|---|
| `fixes` | Proceed to phase/completeness check → close if ALL checks pass |
| `implements` | Proceed to phase/completeness check → do NOT close if ANY phases/SCs remain incomplete |
| `related` | Evaluate only — never auto-close |
| `spec_ref` | Follow spec closure path (Step 4) |
| `plan_ref` | Follow plan closure path (Step 3) |

**CRITICAL: `Implements` does NOT unconditionally close the issue.** A PR that "implements" an issue may only cover a subset of phases or SCs. The completeness check (Step 4a) determines whether the issue can be closed.

### Step 2: Classify Each Issue

| Classification | Detection | Closure Path |
| -- | -- | -- |
| Plan | Local plan file at `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` | Plan closure path (Step 3) |
| Spec / Spec-Fix | Has `[SPEC]` or `[SPEC-FIX]` label or title prefix | Spec closure path (Step 4) |
| Other | No plan/spec labels | Direct close |

### Step 3: Plan Closure Path

1. Read plan body from local file at `.issues/{N}/plan.md` or `*/.issues/{N}/plan.md` for spec reference: `Spec:\s*#(\d+)` or `For spec:\s*#(\d+)`
2. Add referenced spec to closure candidates
3. Get sub-issues via `issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues")` <!-- Routes through issue-operations per SPEC #683 -->
4. For each sub-issue:
   - If open and deliverables covered by PR files → close with evidence comment
   - If open and deliverables NOT in PR → flag for developer review, do NOT auto-close
5. Plans are local artifacts — no GitHub Issue closure needed. The plan file remains as a record.

**Deliverable check:** Verify each sub-issue's deliverables (file paths, descriptions) against the merged PR's file list.

### Step 4: Spec Closure Path

#### Step 4a: Phase-Completion Verification (MANDATORY FIRST)

Before closing any spec, verify ALL phases in the spec body are marked complete. This check prevents premature closure of multi-phase specs after partial implementation.

**Procedure:**

1. Fetch the spec issue body via `issue-operations -> read-issue (github_issue_read(method="get", issue_number=spec_num)` <!-- Routes through issue-operations per SPEC #683 -->
2. Parse the body for phase markers:
   - Markdown headings: `## Phase N:`, `### Phase N:`, `#### Phase N:`
   - Checkbox markers: `☐`, `☑`, `✅ Done`, `⬜ Not Done`
   - Inline lists: `- [ ]`, `- [x]`
3. Extract all phases and their completion status
4. **If ANY phase is incomplete (☐, ⬜ Not Done, or - [ ]):**
   - Do NOT close this issue
   - Post a comment: `Partially implemented by PR #N. Remaining phases: [list of incomplete phases]. Next phase continuation pending.`
   - Skip to next closure candidate
5. **If ALL phases are complete (☑, ✅ Done, or - [x]) OR no phase markers exist:**
   - Proceed to Step 4b (plan reference check)

**Phase marker regex patterns:**
```python
phase_patterns = [
    r"^(#{1,4}\s*Phase\s+\d+[:.]?\s*.*)$",  # ## Phase 1: Title
    r"^\s*[☐☑]\s*Phase\s+\d+[:.]?\s*.*$",  # ☑ Phase 1: Title
    r"^\s*-\s+\[([ x])\]\s*Phase\s+\d+[:.]?\s*.*$",  # - [x] Phase 1: Title
]

completion_patterns = [
    r"☑\s*Phase\s+\d+",
    r"✅\s*Done",
    r"- \[x\]",
    r"Phase\s+\d+[:.]?\s*✅\s*Done",
    r"Phase\s+\d+[:.]?\s*merged",
]

incomplete_patterns = [
    r"☐\s*Phase\s+\d+",
    r"⬜\s*Not\s*Done",
    r"- \[ \]",
    r"Phase\s+\d+[:.]?\s*(?:(?!✅|merged|Done).)*$",
]
```

**SC Checklist Coverage Check (for [SPEC-FIX] and [Bug] issues):**

For issues with `[SPEC-FIX]` or `[Bug]` labels/title prefixes, also verify:
1. Extract the "Success Criteria" or "Checklist" section from the issue body
2. Check ALL checkbox items (`- [ ]` or `☐`) are marked complete (`- [x]` or `☑`)
3. If ANY SC/checkbox is incomplete → do NOT close

**Classification of incomplete findings:**

| Finding | Action |
|---|---|
| Phase incomplete | Skip closure, post partial-implementation comment |
| SC checklist incomplete | Skip closure, post partial-implementation comment |
| No phase markers | Skip check, proceed to Step 4b |
| Single-phase spec (1 phase found, complete) | Proceed to Step 4b |

#### Step 4b: Plan Reference Check

After passing phase-completion verification:

1. Search for plans referencing this spec: `issue-operations -> search-issues (github_search_issues(query="Spec: #<N> repo:<owner>/<repo>")` <!-- Routes through issue-operations per SPEC #683 -->
2. For each plan found, verify it is closed
3. If ALL plans for the spec are closed → close the spec
4. If ANY plan is still open → do NOT close the spec

### Step 5: Cross-Reference Closure

For bug reports with `[SPEC-FIX]`, parse body for `Fixes #N`, `Related #N`. Evaluate linked issues.

### Step 6: Transitive Graph Reconciliation

After processing all direct closure candidates, traverse the issue graph for consistency:

```python
def reconcile_issue_graph(merged_pr_number, pr_files):
    root_issues = closure_candidates
    visited = set()
    queue = [(issue_num, 0) for issue_num in root_issues]
    orphaned = []
    reconciled = []

    while queue:
        issue_num, depth = queue.pop(0)
        if issue_num in visited or depth > 5:
            continue
        visited.add(issue_num)
        issue = issue-operations -> read-issue (github_issue_read(method="get", issue_number=issue_num) <!-- Routes through issue-operations per SPEC #683 -->

        sub_issues = issue-operations -> read-sub-issues (github_issue_read(method="get_sub_issues", issue_number=issue_num) <!-- Routes through issue-operations per SPEC #683 -->
        for sub in sub_issues:
            sub_detail = issue-operations -> read-issue (github_issue_read(method="get", issue_number=sub["number"]) <!-- Routes through issue-operations per SPEC #683 -->
            if sub_detail["state"] == "open" and issue["state"] == "closed":
                deliverables_covered = check_deliverables_in_pr(sub_detail, pr_files)
                if deliverables_covered:
                    issue-operations -> update-issue (github_issue_write(method="update", issue_number=sub["number"], state="closed", state_reason="completed") <!-- Routes through issue-operations per SPEC #683 -->
                    reconciled.append(sub["number"])
                else:
                    orphaned.append(sub["number"])
            queue.append((sub["number"], depth + 1))

        body = issue.get("body", "")
        for pattern in [r"Spec:\s*#(\d+)", r"Plan:\s*#(\d+)", r"Fixes\s*#(\d+)", r"Implements\s*#(\d+)"]:
            for match in re.finditer(pattern, body):
                ref = int(match.group(1))
                if ref not in visited:
                    queue.append((ref, depth + 1))

    return {"orphaned": orphaned, "reconciled": reconciled, "visited": visited}
```

**Reporting:** After reconciliation, report:
```
Issue Graph Reconciliation:
Reconciled (closed with PR evidence): #<n1>, #<n2>, ...
Orphaned (still open — deliverables not in PR): #<m1>, #<m2>, ...
Total nodes visited: <N>
```

### Step 7: Orphaned Task Issues

For issues with `[Task: #N]` or `Phase N:` patterns that reference a parent plan but are not formal sub-issues, include them in closure candidates by searching the issue body and PR body.

### Step 8: Pre-Closure Sub-Issue Verification

**🚫 CRITICAL: Before closing ANY issue, verify that closed sub-issues were legitimately closed via merged PR.**

| Finding | Problem Class | Action |
| -- | -- | -- |
| Closed + merged PR | VERIFIED | auto-proceed |
| Closed "completed" + no merged PR | VERIFICATION-GAP | flag-for-review |
| Closed "not_planned" | VERIFIED | auto-proceed |
| Closed "duplicate" | VERIFICATION-GAP | conditional |
| Open sub-issue | MISSING-ELEMENT | conditional |

**Only proceed to parent closure after ALL sub-issues are verified.**

### Step 8.5: Submodule Issue Closure Routing

**Routes issue closure API calls to the correct repository when affected files live under a submodule path.**

#### Requirements

1. Accept `submodule_paths` routing context (from `cleanup.md` Step 0 — list of `{path, owner, repo, platform}` mappings) for per-submodule API routing
2. Accept `verify_merge_output` structured context (from `verify-merge.md` Step 1) containing `merged_pr_number`, `merged_in_repo`, and `pr_files` for cross-referencing
3. For each closure candidate whose affected files (from PR file diff) are under a submodule path, route the closure API call to the submodule's `owner/repo` instead of the parent repo
4. Use `submodule_paths` context OR session-init sub-folder repo mappings (`issue-operations -> read-issue (github_issue_read` with resolved `owner`/`repo`) — never hardcode owner/repo values <!-- Routes through issue-operations per SPEC #683 -->
5. Include evidence artifacts table tracking each routed closure call
6. Be platform-agnostic (works for both GitHub and GitBucket)

#### Procedure

```python
# Context inputs:
#   verify_merge_output — from verify-merge.md Step 1 (contains pr_number, merged_in_repo, pr_files, submodule_context)
#   submodule_paths — from cleanup.md Step 0 (list of {path, owner, repo, platform})

def resolve_submodule_owner_repo(issue_num, pr_files, submodule_paths):
    """Find matching submodule for a closure candidate based on PR file paths."""
    for file_path in pr_files:
        for sub in submodule_paths:
            if file_path.startswith(sub["path"]):
                return {"owner": sub["owner"], "repo": sub["repo"], "platform": sub["platform"]}
    return None

parent_pr_number = verify_merge_output.get("pr_number")
pr_files = verify_merge_output.get("pr_files", [])

for issue_num, classification in closure_candidates.items():
    sub_info = resolve_submodule_owner_repo(issue_num, pr_files, submodule_paths)
    
    if sub_info:
        # Route closure to submodule's owner/repo
        if sub_info["platform"] == "github":
            issue-operations -> creation/update (github_issue_write( <!-- Routes through issue-operations per SPEC #683 -->
                method="update",
                owner=sub_info["owner"],
                repo=sub_info["repo"],
                issue_number=issue_num,
                state="closed",
                state_reason="completed"
            )
            issue-operations -> comment (github_add_issue_comment( <!-- Routes through issue-operations per SPEC #683 -->
                owner=sub_info["owner"],
                repo=sub_info["repo"],
                issue_number=issue_num,
                body=f"Closed via parent PR #{parent_pr_number}."
            )
        elif sub_info["platform"] == "gitbucket":
            gitbucket_api_post(endpoint=f"/issues/{issue_num}", payload={
                "state": "closed"
            })
    else:
        # Standard parent-repo closure (existing logic applies)
        close_in_parent_repo(issue_num, classification)
```

**Evidence artifacts table:**

| Issue | Submodule Path | Routed Owner/Repo | Closure Posted? | Comment Posted? |
|-------|---------------|-------------------|-----------------|-----------------|
| `#N` | `.opencode/` | `michael-conrad/.opencode` | ✅ | ✅ |
| `#M` | (none — parent) | `michael-conrad/opencode-config` | ✅ | ✅ |

#### Fallback: Session-Init Repo Mappings

If `submodule_paths` is not provided, resolve sub-folder repo mappings from session-init context:
- `issue-operations -> read-issue (github_issue_read(method="get", issue_number=N)` with resolved `owner`/`repo` per submodule <!-- Routes through issue-operations per SPEC #683 -->
- Glob scan discovered repos used for `path → owner/repo` mapping:
  ```bash
  REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')
  for RP in $REPO_PATHS; do
      [ "$RP" = "." ] && continue
      REMOTE_URL=$(git -C "$RP" remote get-url origin 2>/dev/null || echo "")
      # Parse owner/repo and build fallback submodule_paths
  done
  ```
- Reject any hardcoded owner/repo values — always use live resolution

## Context Required

- Related tasks: `cleanup/verify-merge`, `cleanup/branch-cleanup`
- Related skill: `issue-operations`