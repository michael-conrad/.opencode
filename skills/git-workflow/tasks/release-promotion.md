# Task: release-promotion

## ⚠️ TIER 1 MANDATE: Human-Only Merge

Agents MUST NOT execute `git merge` into `main`, `master`, or any protected branch.
All promotions MUST go through PR-based merge. The agent prepares the release;
a human reviews and merges the PR. Direct merge to a protected branch is a
CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md`.

## Purpose

Prepare dev → main promotion, semver tagging, and release creation via PR-based workflow. Supports both submodule-based repos (tag-based hash permanence) and non-submodule repos. The agent creates the release PR; a human must merge it. Tags and releases are created post-merge.

## Operating Protocol

1. **Submodule repos:** When parent repo promotes dev → main, submodule SHAs are guaranteed reachable via tags — no separate submodule PRs are needed
2. **Non-submodule repos:** Create release PR from dev targeting main, HALT for human merge, then tag and release
3. **Explicit trigger:** Developer can instruct promotion of individual submodules (tag-only, no PR)
4. **Tag validation:** All semver tags must pass `validate-release-tags.sh --semver` before parent promotion proceeds
5. **Idempotent tagging:** Release tags on submodule SHAs are created only if not already tagged — no duplicate tags, no errors on existing tags

## Entry Criteria

- Repository is promoting dev → main (automatic or explicit), OR
- Developer has explicitly instructed "promote submodule <X>" or "push submodule <Y>"
- Post-merge: Human has merged the release PR and developer wants tagging + release creation

## Exit Criteria

### Submodule Path

- All submodule SHAs are tagged with release tags (`<parent-repo>/v<N.N.N>`) or confirmed already reachable via existing tags
- Parent release PR created targeting main
- Agent has HALTed for human merge
- After human merge: Annotated semver tag created on main (auto-incremented patch or developer-specified)
- After human merge: Tags pushed to origin
- After human merge: GitHub/GitBucket release created
- `validate-release-tags.sh --semver` exits 0

### Non-Submodule Path

- Release PR created targeting main from release branch
- Agent has HALTed for human merge
- After human merge: Annotated semver tag created on main (auto-incremented patch or developer-specified)
- After human merge: Tags pushed to origin
- After human merge: GitHub/GitBucket release created

## Invariant

**At every transition point, all submodule SHAs referenced by the parent must be reachable via at least one tag. Tags are idempotent — skip if already tagged. Semantic tags on already-tagged SHAs are acceptable for documentation purposes.**

### Tag Layers

| Tag | When Created | Meaning | Already Exists? |
|-----|-------------|---------|-----------------|
| `<parent-repo>/<issue-number>` | Pre-work (feature dev start) | "Starting SHA for issue #N" | Only if same issue |
| `<parent-repo>/<issue-number>-<sub>` | Feature-branch push | "Submodule tip for issue #N" | Only if submodule changed |
| `<parent-repo>/v<N.N.N>` | Release promotion | "SHA included in release vN.N.N" | Only if version coincides |

All three layers guarantee reachability. Release tags add semantic documentation ("this SHA shipped in v0.1.1") on top of the reachability guarantee. If a SHA already has an issue tag, the release tag is a convenience addition — not a necessity for hash permanence.

### Idempotent Tag-If-Untagged Rule

At any transition point, for each submodule SHA:

```bash
TAGS_ON_SHA=$(cd <submodule-path> && git tag --contains <sha> | grep -E '<parent-repo>')
if [ -z "$TAGS_ON_SHA" ]; then
    # SHA is unreachable via parent-repo tags — tag it and push
    git tag -a "<parent-repo>/v<N.N.N>" -m "Release v<N.N.N>: <submodule-path>"
    git push origin "<parent-repo>/v<N.N.N>"
else
    # SHA is already reachable — add semantic release tag for documentation (optional, acceptable)
    # This is NOT an error condition
fi
```

No redundant tags are created for already-reachable hashes (unless semantic documentation is desired). Adding a semantic release tag to an already-tagged SHA is idempotent — it provides version documentation without creating duplicate reachability.

## Procedure

### Step 0: Route to Release Path

```bash
test -f .gitmodules
```

- If `.gitmodules` EXISTS: Proceed to **Submodule Path** (Step 1)
- If `.gitmodules` does NOT exist: Proceed to **Non-Submodule Path** (Step N1)

---

## Submodule Path

### Step 1: Lock Submodule SHAs

When promoting parent dev → main, submodule SHAs must be locked to their current checkout state — NOT a fresh pull:

```bash
git submodule update --init
```

**CRITICAL:** Do NOT use `--remote` flag. During release promotion, submodules must be at their committed SHAs, not advanced to the tip of their dev branches. Using `--remote` would silently advance submodules beyond the tested state, violating release integrity.

**Submodule SHA Locking Principle:** The SHA locked during release is exactly what was in the developer's checkout during the dev cycle — not a fresh pull, not an upstream sync performed after the fact. Changing submodule SHAs without integration testing creates untested combinations.

**Parent repo dev tip does NOT require tagging** — only submodule SHAs need tags. Parent commits are reachable via branch history (`git checkout dev` reaches any parent commit).

### Step 2: Tag Submodule SHAs for Release

For each submodule listed in `.gitmodules`:

```bash
git config --file .gitmodules --get-regexp path | awk '{print $2}'
```

For each submodule `<path>`:

**a. Collect the committed SHA:**

```bash
git ls-tree HEAD <path> | awk '{print $3}'
```

**b. Check if SHA has existing parent-repo tags (idempotent check):**

```bash
cd <path>
TAGS_ON_SHA=$(git tag --contains <sha> | grep -E '<parent-repo-short>')
cd ..
```

**c. If no parent-repo tags exist on this SHA → tag with release tag and push:**

```bash
cd <path>
git tag -a "<parent-repo-short>/v<N.N.N>" -m "Release v<N.N.N>: <path> promoted from dev"
git push origin "<parent-repo-short>/v<N.N.N>"
cd ..
```

**d. If parent-repo tags already exist on this SHA → add semantic release tag for documentation (optional, acceptable, NOT required):**

```bash
# Optional: add semantic release tag for documentation
cd <path>
git tag -a "<parent-repo-short>/v<N.N.N>" -m "Release v<N.N.N>: <path>"
git push origin "<parent-repo-short>/v<N.N.N>"
cd ..
# If the tag already exists, git push will return "already exists" — this is NOT an error
```

**e. Verify all SHAs are reachable via tags (liveness check):**

Invoke `submodule-liveness-check` sub-agent to verify reachability. The liveness check is now idempotent — if a SHA is unreachable, it tags it first, then re-verifies. It never blocks for unreachable SHAs.

**Key invariant:** Submodule dev → main PRs are NOT part of this workflow. Tags guarantee hash permanence. A submodule SHA referenced by the parent is already reachable via its issue/feature tags. A separate dev → main PR adds no reachability guarantee.

### Step 2.5: Create Provenance Tracking

After tagging submodule SHAs, invoke provenance tracking:

Invoke: `/skill git-workflow --task provenance --mode=promotion`

**Provenance tracking uses the same three-tier model as dev-push.** The promotion mode creates issue/PR records in submodule repos documenting the release, but these are tracking records, not merge gates.

**Important:** Provenance is fire-and-forget. It never blocks the parent release workflow. Failures at any tier result in silent downgrade, never HALT.

### Step 3: Validate Tags

After all submodule SHAs are tagged:

```bash
./.opencode/scripts/validate-release-tags.sh --semver
```

**MUST exit 0.** If it exits non-zero:

1. Report which submodule failed validation
2. HALT — do not proceed with parent promotion
3. Developer must resolve the tag issue before retrying

### Step 4: Proceed with Parent Promotion

After Step 3 passes, the parent repository proceeds with its own dev → main promotion via the Non-Submodule Path below.

**The parent release PR has NO dependency on submodule repo merges.** Parent PR can be created and merged independently once submodule SHAs are verified reachable via tags.

---

## Non-Submodule Path

### Step N1: Determine Next Semver Tag

**Auto-increment patch version:**

```bash
LATEST_TAG=$(git tag --sort=-v:refname | head -1)

if [ -z "$LATEST_TAG" ]; then
    NEXT_TAG="v0.1.0"
else
    VERSION=${LATEST_TAG#v}
    MAJOR=$(echo "$VERSION" | cut -d. -f1)
    MINOR=$(echo "$VERSION" | cut -d. -f2)
    PATCH=$(echo "$VERSION" | cut -d. -f3)
    NEXT_TAG="v${MAJOR}.${MINOR}.$((PATCH + 1))"
fi
```

**Developer-specified version:** If developer provided an explicit version (e.g., "promote as v2.0.0"), use that version instead of auto-increment.

### Step N2: Create Release Branch from Dev

```bash
RELEASE_BRANCH="release/dev-to-master-v${NEXT_TAG#v}"
git checkout dev
git checkout -b "$RELEASE_BRANCH"
```

### Step N3: Push Release Branch

```bash
git push origin "$RELEASE_BRANCH"
```

### Step N4: Create PR Targeting Master

Create a release PR targeting `master` (or `main`):

**For GitHub:**

```
github_create_pull_request(
    owner=<github.owner>,
    repo=<github.repo>,
    title="Release $NEXT_TAG: promote dev → main",
    head="$RELEASE_BRANCH",
    base="master",
    body="Release $NEXT_TAG\n\nAutomated dev → main promotion.\n\n⚠️ This PR was prepared by an AI agent. Human review required before merge."
)
```

**For GitBucket:** Use GitBucket API per `gitbucket-api` skill.

### Step N5: HALT — Wait for Human Merge

Report the PR URL to chat. HALT and wait for the human to merge the PR.

After human merges the PR, proceed to post-merge steps (N6-N8). These may be invoked in a subsequent session using `--task release-promotion --post-merge`.

### Step N6: (Post-merge) Tag Master with Semver Tag

```bash
git checkout master
git pull origin master
git tag -a "$NEXT_TAG" -m "Release $NEXT_TAG"
```

### Step N7: (Post-merge) Push Tags

```bash
git push origin master --tags
```

### Step N8: (Post-merge) Create Platform Release

**For GitHub:**

Use GitHub MCP to create release:

```
github_get_latest_release(owner=<github.owner>, repo=<github.repo>)
```

Then create release via GitHub API with:

```markdown
Release $NEXT_TAG

Automated dev → main promotion.
```

**For GitBucket:** Use GitBucket API per `gitbucket-api` skill.

**Release body template:**

```markdown
Release $NEXT_TAG

Automated dev → main promotion.
```

---

## Explicit Developer Instruction

Developers can target individual submodules without promoting all:

| Instruction | Action |
| -- | -- |
| "promote submodule shared-skills" | Tag only the `shared-skills` submodule SHA with release tag |
| "push submodule shared-templates" | Tag and push only `shared-templates` |
| "promote submodule X as v2.0.0" | Tag X with developer-specified version |

**Explicit instructions do NOT require all submodules to be promoted.** Only the named submodule(s) are processed.

**Explicit instructions do NOT create submodule dev → main PRs.** Tagging replaces PRs for hash permanence.

## Acceptance Criteria

| ID | Criterion |
| -- | -- |
| T19 | Submodule SHAs are tagged with release tags (`<parent-repo>/v<N.N.N>`), NOT promoted via separate submodule PRs |
| T20 | Semver tag is auto-incremented (patch version) when no developer-specified version |
| T21 | GitHub/GitBucket release is created post-merge for the parent repo |
| T22 | Parent submodule refs remain at their locked SHAs (no `--remote` flag) |
| T23 | `validate-release-tags.sh --semver` passes after tagging |
| T24 | Developer can explicitly instruct tagging of individual submodules |
| T25 | Submodule SHAs are locked (no `--remote` flag) during release promotion |
| T26 | Non-submodule repos: agent creates release PR; human merges |
| T27 | Non-submodule repos: semver tag is created post-merge and pushed |
| T28 | Non-submodule repos: platform release is created post-merge |
| T29 | Tagging is idempotent — no errors on already-tagged SHAs |
| T30 | Semantic release tags on already-tagged SHAs are acceptable (no error, no skip requirement) |
| T31 | Parent release PR has NO dependency on submodule repo merges |
| T32 | Liveness check is idempotent: tags unreachable SHAs instead of just reporting FAIL |
| T33 | Parent repo dev tip does NOT require tagging — only submodule SHAs do |

## Common Issues

| Issue | Resolution |
| -- | -- |
| Tag already exists on SHA | Acceptable — semantic tag adds documentation, idempotent operation |
| `validate-release-tags.sh` fails | HALT; report which submodule failed and why |
| No previous tag exists | Default to `v0.1.0` as first release tag |
| Submodule has no dev branch | HALT; report that dev branch must exist before promotion |
| Human merges but forgets to tag | Re-invoke `--task release-promotion --post-merge` for tagging + release |
| Release branch name collision | Append timestamp or short SHA to branch name |
| Pre-merge hook blocks direct merge | N/A — PR-based approach avoids this; skill never directs direct merge |
| Submodule SHA not on dev branch (only on feature branch) | Issue tags from pre-work guarantee reachability even if feature branch is deleted |

## Context Required

- Related skills: `conflict-resolution` (merge conflict classification), `gitbucket-api` (GitBucket release creation)
- Related tasks: `pre-work` (submodule initialization and tagging), `submodule-liveness-check` (idempotent tag-if-untagged verification), `cleanup` (post-merge cleanup)
- Related scripts: `validate-release-tags.sh` (tag validation)