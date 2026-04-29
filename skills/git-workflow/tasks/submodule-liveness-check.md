# Task: submodule-liveness-check

## Purpose

Verify that all submodule SHAs referenced by the parent repo are reachable via tags. If a submodule SHA is unreachable, tag it with the appropriate tag for the current context, push the tag, then re-verify. Liveness check is idempotent and self-healing — it never blocks for an unreachable SHA without attempting remediation first.

## Invariant

**At every transition point, all submodule SHAs referenced by the parent must be reachable via at least one tag.** Tags are idempotent — skip if already tagged. Semantic tags on already-tagged SHAs are acceptable for documentation purposes.

## Entry Criteria

- Parent repo has `.gitmodules` (submodules present)
- Agent is at a verification checkpoint (enforcement gate, review-prep, release promotion)

## Exit Criteria

- All submodule SHAs are reachable via at least one tag
- `tags_added` field lists any new tags created during the check
- Status is `DONE` (all reachable) or `BLOCKED` (unreachable and tagging failed)

## Tag Format by Context

| Context | Tag Format | When |
|---------|-----------|------|
| Pre-work | `<parent-repo>/<issue-number>` | Feature dev start |
| Feature-branch push | `<parent-repo>/<issue-number>-<sub>` | Submodule changes pushed |
| PR-time / enforcement-gate | Inherit from pre-work or feature push | Liveness verification |
| Release promotion | `<parent-repo>/v<N.N.N>` | Dev → main release |

## Procedure

### Step 1: Collect Submodule SHAs

For each submodule listed in `.gitmodules`:

```bash
git config --file .gitmodules --get-regexp path | awk '{print $2}'
```

For each `<path>`, collect the committed SHA:

```bash
git ls-tree HEAD <path> | awk '{print $3}'
```

### Step 2: Check Reachability (Idempotent Tag-If-Untagged)

For each submodule `<path>` and its `<sha>`:

#### 2a: Check if SHA has existing parent-repo tags

```bash
cd <path>
TAGS_ON_SHA=$(git tag --contains <sha> | grep -E '<parent-repo-short>')
cd ..
```

#### 2b: If SHA has parent-repo tags → PASS (no action needed)

```yaml
path: <submodule-path>
committed_sha: <sha>
reachable: true
reachable_via: <existing-tag-name>
tags_added: []
```

The SHA is already reachable via an existing tag. No further action needed.

#### 2c: If SHA has NO parent-repo tags → TAG and push

Determine the appropriate tag format based on context:

| Context | Tag Format | Source |
|---------|-----------|--------|
| Pre-work | `<parent-repo-short>/<issue-number>` | From authorization context |
| Feature-branch push | `<parent-repo-short>/<issue-number>-<submodule-name>` | From authorization context |
| PR-time / enforcement-gate | Inherit from pre-work or feature push tags | Reuse existing tags if present |
| Release promotion | `<parent-repo-short>/v<N.N.N>` | From release version |

```bash
cd <path>
git tag -a "<tag-format>" -m "<description>"
git push origin "<tag-format>"
cd ..
```

Then re-verify:

```bash
cd <path>
TAGS_ON_SHA=$(git tag --contains <sha> | grep -E '<parent-repo-short>')
cd ..
```

If tags are now present → PASS with `tags_added` field populated.

#### 2d: If tagging fails → BLOCK (report failure)

```yaml
path: <submodule-path>
committed_sha: <sha>
reachable: false
reachable_via: "unreachable"
tags_added: []
error: "<error message from tagging attempt>"
```

### Step 3: Verify All Submodules Pass

If ALL submodule hashes are reachable → Status: DONE

If ANY submodule hash is NOT reachable and tagging also failed → Status: BLOCKED

Report the full results including any tags added.

## Result Contract

```yaml
status: DONE | BLOCKED
task: submodule-liveness-check
tags_added:
  - path: <submodule-path>
    tag_name: <tag-created>
    sha_tagged: <sha>
    context: <pre-work|feature-push|enforcement-gate|release-promotion>
submodule_results:
  - path: <submodule-path>
    committed_sha: <sha>
    reachable: bool
    reachable_via: <tag-name or ref-name or "unreachable">
    tags_added: [<tag-names>]
evidence_artifacts:
  - tool: git ls-tree HEAD <path>
    output: <sha>
  - tool: git tag --contains <sha>
    output: <tag list>
  - tool: git tag -a (if tagging occurred)
    output: <tag creation confirmation>
  - tool: git push origin <tag> (if tagging occurred)
    output: <push confirmation>
```

## Key Differences from Previous Version

| Previous Behavior | New Behavior |
|-----------------|--------------|
| Report PASS/FAIL per SHA | Tag unreachable SHAs, then verify → always PASS unless tagging fails |
| FAIL blocks the PR | Liveness check is self-healing: tags first, then verifies |
| No `tags_added` field | `tags_added` field lists all tags created during the check |
| Idempotent tags not supported | Tags are idempotent — skip if already tagged |
| Context-specific tags not supported | Tag format varies by context (pre-work, feature-push, release) |
| Submodule PR workflow was blocking | Tags replace submodule PRs entirely |

## Sub-Agent Boundary

| Field | Value |
|-------|-------|
| **must_receive** | Submodule paths from `git submodule status`, `github.owner`, `github.repo`, parent repo short name, issue number, context (pre-work/feature-push/enforcement-gate/release-promotion) |
| **must_not_receive** | Implementation context, agent memory, full task file contents |

## Context Required

- Related skills: `git-workflow --task pre-work` (initial submodule tagging), `git-workflow --task release-promotion` (release-time tagging), `git-workflow --task pr-creation/enforcement-gate` (PR-time verification)
- Related tasks: `submodule-tag-prework` (initial tags at pre-work), `submodule-feature-push` (feature-branch tags)