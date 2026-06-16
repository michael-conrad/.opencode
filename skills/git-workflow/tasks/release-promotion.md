# Task: release-promotion

## ⚠️ TIER 1 MANDATE: Human-Only Merge

Agents MUST NOT execute `git merge` into `main`, `master`, or any protected branch.
All promotions MUST go through PR-based merge. The agent prepares the release;
a human reviews and merges the PR. Direct merge to a protected branch is a
CRITICAL GUIDELINE VIOLATION per `000-critical-rules.md`.

## Purpose

Prepare dev → main promotion, semver tagging, and release creation via PR-based workflow. Supports both submodule-based repos (tag each submodule SHA with `<parent>/v<version>`) and non-submodule repos. The agent creates the release PR; a human must merge it. Tags and releases are created post-merge.

## Operating Protocol

- [ ] 1. **Submodule repos:** Tag submodule SHAs with `<parent>/v<version>` tags — no dev → main PRs needed for submodules
- [ ] 2. **Non-submodule repos:** Create release PR from dev targeting main, HALT for human merge, then tag and release
- [ ] 3. **Tag validation:** All semver tags must pass `validate-release-tags.sh --semver` before parent promotion proceeds

## Entry Criteria

- Repository is promoting dev → main (automatic or explicit)
- Post-merge: Human has merged the release PR and developer wants tagging + release creation

## Exit Criteria

### Submodule Path

- Each promoted submodule SHA is tagged with `<parent>/v<version>` (parent-repo-prefixed semver tag)
- Tags are verified reachable via `git tag -l '<parent>/v*'` per tag-if-untagged rule
- Parent submodule refs point to tagged SHAs
- `validate-release-tags.sh --semver` exits 0

### Non-Submodule Path

- Release PR created targeting main from release branch
- Agent has HALTed for human merge
- After human merge: Annotated semver tag created on main (auto-incremented patch or developer-specified)
- After human merge: Tags pushed to origin
- After human merge: GitHub/GitBucket release created

## Procedure

### Step 0: Route to Release Path

```bash
REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')
HAS_SUBMODULES=false
for RP in $REPO_PATHS; do
    [ "$RP" = "." ] && continue
    HAS_SUBMODULES=true
    break
done
```

- If submodules detected (`HAS_SUBMODULES=true`): Proceed to **Submodule Path** (Step 1)
- If no submodules detected: Proceed to **Non-Submodule Path** (Step N1)

______________________________________________________________________

## Submodule Path

### Step 0.5: Detect Default Branch for Submodules

For each submodule discovered via glob scan:

```bash
REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')
for RP in $REPO_PATHS; do
    [ "$RP" = "." ] && continue
    DEFAULT_BRANCH=$(git -C "$RP" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo "main")
done
```

### Step 0.75: Detect Semver Tags on Each Submodule

For each submodule discovered via glob scan:

```bash
REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')
SUBMODULE_PATHS=""
for RP in $REPO_PATHS; do
    [ "$RP" = "." ] && continue
    SUBMODULE_PATHS="$SUBMODULE_PATHS $RP"
done
```

For each submodule `<path>`, extract parent repo prefix for tag namespace:

```bash
PARENT_PREFIX=$(basename $(git rev-parse --show-toplevel))  # e.g. opencode-config
```

### Step 1: Lock Submodule SHAs

When promoting parent dev → main, submodule SHAs must be locked to their current checkout state — NOT a fresh pull:

```bash
git submodule update --init
```

**CRITICAL:** Do NOT use `--remote` flag. During release promotion, submodules must be at their committed SHAs, not advanced to the tip of their dev branches. Using `--remote` would silently advance submodules beyond the tested state, violating release integrity.

**Submodule SHA Locking Principle:** The SHA locked during release is exactly what was in the developer's checkout during the dev cycle — not a fresh pull, not an upstream sync performed after the fact. Changing submodule SHAs without integration testing creates untested combinations.

**Post-merge integration (if performed):** If upstream submodule changes were pulled and integration tests passed during the post-merge integration step (`git submodule foreach "git checkout dev && git pull"`), those updated SHAs become part of the tested state. The release then locks whatever is current at release time — which includes any integration-tested upstream changes.

**Hotfix submodule discipline:** Hotfixes against `main` MUST NOT modify submodule state. The pinned SHAs in `main` represent the released versions and must remain stable.

### Step 2: Tag Each Submodule SHA with Release Tag

For each submodule discovered via glob scan, use `RP` as the submodule path:

```bash
REPO_PATHS=$(ls -d .git/ */.git/ */.git 2>/dev/null | sed 's|/\.git$||' | sed 's|/$||')
for RP in $REPO_PATHS; do
    [ "$RP" = "." ] && continue

    # 2a: Determine Parent-Prefixed Semver Tag
    PARENT_PREFIX=$(basename $(git rev-parse --show-toplevel))
    SUB_SHA=$(git -C "$RP" rev-parse HEAD)
    LATEST_TAG=$(git -C "$RP" tag --sort=-v:refname | grep "^${PARENT_PREFIX}/v" | head -1)

    if [ -z "$LATEST_TAG" ]; then
        NEXT_TAG="${PARENT_PREFIX}/v0.1.0"
    else
        VERSION=${LATEST_TAG#${PARENT_PREFIX}/v}
        MAJOR=$(echo "$VERSION" | cut -d. -f1)
        MINOR=$(echo "$VERSION" | cut -d. -f2)
        PATCH=$(echo "$VERSION" | cut -d. -f3)
        NEXT_TAG="${PARENT_PREFIX}/v${MAJOR}.${MINOR}.$((PATCH + 1))"
    fi

    # Tag-if-untagged check
    EXISTING_TAG=$(git -C "$RP" tag --points-at "$SUB_SHA" | grep "^${PARENT_PREFIX}/v" | head -1)
    if [ -z "$EXISTING_TAG" ]; then
        git -C "$RP" tag -a "$NEXT_TAG" -m "Release $NEXT_TAG: promoted from dev"
        git -C "$RP" push origin "$NEXT_TAG"
    else
        echo "SHA $SUB_SHA already tagged as $EXISTING_TAG — skipping"
    fi

    # 2c: Verify reachability
    git -C "$RP" tag -l "$NEXT_TAG" | grep -q "$NEXT_TAG"

    # 2d: Return to parent and update ref
    git add "$RP"
done
```

**Developer-specified version:** If developer provided an explicit version (e.g., "promote submodule X as v2.0.0"), use `{PARENT_PREFIX}/v2.0.0`.

The parent repo now records the tagged submodule SHA. No submodule PR needed.

### Step 3: Validate Tags

After all submodules are tagged:

```bash
./.opencode/scripts/validate-release-tags.sh --semver
```

**MUST exit 0.** If it exits non-zero:

- [ ] 1. Report which submodule failed validation
- [ ] 2. HALT — do not proceed with parent promotion
- [ ] 3. Developer must resolve the tag issue before retrying

### Step 4: Proceed with Parent Promotion

After Step 3 passes, the parent repository may proceed with its own dev → main promotion via the Non-Submodule Path below. Submodule SHAs are already tagged and reachable — no submodule PR dependencies block parent promotion.

______________________________________________________________________

## Non-Submodule Path

### Step N0: Detect Default Branch

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
```

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
RELEASE_BRANCH="release/dev-to-${DEFAULT_BRANCH}-v${NEXT_TAG#v}"
git checkout dev
git checkout -b "$RELEASE_BRANCH"
```

### Step N3: Push Release Branch

```bash
git push origin "$RELEASE_BRANCH"
```

### Step N4: Create PR Targeting $DEFAULT_BRANCH

Create a release PR targeting `$DEFAULT_BRANCH`. The PR body MUST summarize what changed, why, and the functional impact — not just dump raw commit messages.

**Synthesize the PR body from issue context:**

- [ ] 1. Capture the commit log: `git log "$DEFAULT_BRANCH"..dev --oneline`
- [ ] 2. For each commit, extract the issue number from the commit message and read the corresponding issue body to determine the change's intent and impact
- [ ] 3. Categorize changes by type: new features, bug fixes, refactors, maintenance
- [ ] 4. Generate a structured PR body with:
   - Summary paragraph: what this release encompasses (1-3 sentences synthesizing intent across all changes)
   - Changes section: per-category breakdown with issue references and functional impact descriptions
   - Files changed: `git diff "$DEFAULT_BRANCH"...dev --stat`
- [ ] 5. If no unreleased changes exist (`git log` output is empty), state that explicitly

**For GitHub:**

```
github_create_pull_request(
    owner=<github.owner>,
    repo=<github.repo>,
    title="Release $NEXT_TAG: promote dev → $DEFAULT_BRANCH",
    head="$RELEASE_BRANCH",
    base="$DEFAULT_BRANCH",
    body=<synthesized body per above>
)
```

**For GitBucket:** Use GitBucket API per `gitbucket-api` skill.

### Step N5: HALT — Wait for Human Merge

Report the PR URL to chat. HALT and wait for the human to merge the PR.

After human merges the PR, proceed to post-merge steps (N6-N8). These may be run in a subsequent session using `--task release-promotion --post-merge`.

### Step N6: (Post-merge) Tag $DEFAULT_BRANCH with Semver Tag

```bash
git checkout "$DEFAULT_BRANCH"
git pull origin "$DEFAULT_BRANCH"
git tag -a "$NEXT_TAG" -m "Release $NEXT_TAG"
```

### Step N7: (Post-merge) Push Tags

```bash
git push origin "$DEFAULT_BRANCH" --tags
```

### Step N8: (Post-merge) Create Platform Release

Generate the release body by summarizing what changed since the last release, organized by category with functional impact. Do not dump raw commit messages — synthesize intent from commit messages and any linked issue context.

**Capture release context:**

```bash
RELEASE_DATE=$(date +%Y-%m-%d)
LAST_TAG=$(git tag --sort=-v:refname | head -1)
RELEASE_COMMITS=$(git log "$LAST_TAG..$DEFAULT_BRANCH" --oneline 2>/dev/null)
```

Then synthesize a release body with:
- Release version and date
- Summary paragraph of what this release encompasses
- Changes section: category grouping by feature/fix/maintenance with per-item descriptions
- No boilerplate, no raw commit dumps, no disclaimers

```
github_get_latest_release(owner=<github.owner>, repo=<github.repo>)
```

Then create release via GitHub API with the `$RELEASE_BODY` content above.

**For GitBucket:** Use GitBucket API per `gitbucket-api` skill.

______________________________________________________________________

## Acceptance Criteria

| ID | Criterion |
| -- | -- |
| T19 | Submodule SHAs tagged with `<parent>/v<version>` (no submodule PR needed) |
| T20 | Semver tag is auto-incremented (patch version) when no developer-specified version |
| T22 | Parent submodule refs point to tagged SHAs |
| T23 | `validate-release-tags.sh --semver` passes after tagging |
| T25 | Submodule SHAs are locked (no `--remote` flag) during release promotion |
| T26 | Non-submodule repos: agent creates release PR; human merges |
| T27 | Non-submodule repos: semver tag is created post-merge and pushed |
| T28 | Non-submodule repos: platform release is created post-merge |

## Common Issues

| Issue | Resolution |
| -- | -- |
| Tag already exists | Report error; developer must specify a different version |
| `validate-release-tags.sh` fails | HALT; report which submodule failed and why |
| No previous tag exists for parent prefix | Default to `<parent>/v0.1.0` as first release tag |
| Submodule has no dev branch | HALT; report that dev branch must exist before promotion |
| Tag push fails (permission) | HALT; report that developer must push tag manually |

## Context Required

- Related skills: `conflict-resolution` (merge conflict classification), `gitbucket-api` (GitBucket release creation)
- Related tasks: `pre-work` (submodule initialization), `cleanup` (post-merge cleanup)
- Related scripts: `validate-release-tags.sh` (tag validation)
