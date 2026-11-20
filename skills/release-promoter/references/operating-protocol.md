<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: restored from the pre-rip release-promoter operating protocol (tag pre-rip; gate implemented as .opencode#2439), re-homed and root-agnosticized, .opencode#2557; gate moved pre-PR with no-retry rescope and TREE_MISMATCH re-check, .opencode#2590; parent-checkout boundary — the initial clone is of the parent repository and submodules resolve through its recorded pointers, .opencode#2592 -->

# Release Promotion — Operating Protocol

Promotion runs in three phases around the human merge gate: composition
promotes the release candidate from the submodules' remote trunk tips
before any analysis, branching, or gate; the clean-room gate proves the
release candidate before the release PR exists; and a reduced re-check
confirms the merge delivered exactly that verified state before any tag is
created. The release PR, the tag, and the GitHub
Release are parent-repository artifacts; a submodule repository never hosts
them.

## Phase C-0 — release-candidate composition

Composition runs before any release analysis, branching, or gate — it is
never performed against stale recorded pointers.

Procedure — pull and promote, then record:

1. Pull the parent repository's trunk to its remote tip (`git fetch origin`
   plus the fetch-compare of trunk freshness; record the verified tip in
   this phase's output).
2. For every registered submodule per the parent's `.gitmodules` (per-path
   and non-recursive — no `--remote`, no `--recursive`), run
   `git-workflow-branch` rule 2's executed per-submodule remote-tip
   comparison as the evidence instrument: fetch the submodule's origin
   (`git -C <submodule> fetch origin`); resolve the trunk branch — the
   `submodule.<name>.branch` field read from the parent repo's
   `.gitmodules`; when no branch field exists, the submodule remote's
   default branch (`refs/remotes/origin/HEAD`; guard ref existence before
   use) — the release path never resolves the trunk branch from the
   submodule checkout's current checked-out branch, however
   well-remoted the checkout's branch is; then compare the checkout's HEAD
   SHA against the fetched remote-tracking tip, recording `at-tip`,
   `behind`, or `unresolvable` (no branch field, no resolvable
   `refs/remotes/origin/HEAD`, or an unfetchable tip). `git submodule
   status` is pointer-state only and is never this comparison's evidence.
3. Promote: a `behind` checkout is synced to the resolved remote tip;
   `at-tip`
   is a no-op for that pointer; a registered submodule whose trunk branch is
   unresolvable (`unresolvable`) halts
   composition for developer direction — the release path carries no
   recorded-and-continue posture: the outcome is never "recorded as the
   instrument's own outcome" while composition proceeds, and the halt comes
   before any gate, release branch, or PR. Composition is done when the
   executed comparison returns `at-tip` for every registered submodule; that
   outcome is the composition's success evidence. `unresolvable` is exact: no
   `.gitmodules` branch field AND no resolvable `refs/remotes/origin/HEAD`
   after fetch (absent or pointing at a nonexistent ref), or a tip that
   cannot be fetched. There is no fallback: enumerated remote refs,
   `ls-remote` listings, and the checkout's own HEAD are never the trunk
   tip. Composition
   promotes only registered top-level pointers — nested submodules below a
   registered submodule are never promoted.
4. An unreachable submodule remote halts composition for developer direction
   — never a skip, and never a nothing-to-release verdict. This halt is the
   composition phase's own prescription, deliberately diverging from
   `git-workflow-branch` rule 2's bounded record-and-continue posture: a
   branch decision may proceed on recorded outcomes, but a release candidate
   cannot be composed from unverifiable pointers.
5. When the parent trunk has commits since the last release tag while
   submodules also moved, or when only one family moved, the composition
   composes both into the release either way; when every submodule is
   at-tip and the parent trunk has no commits since the last release tag,
   composition is a pointer-and-parent no-op and the composition outcome is
   stated explicitly — the phase never blocks a plain parent-only release by
   invention, and it never invents a nothing-to-release verdict by omission:
   the release that composes exists because the phase's promotion created it.
7. The order is fixed and non-swappable: compose (promote pointers at trunk
   tips), record the release branch, run the clean-room gate on the composed
   tree, file the release PR. A release PR is never filed from pointers that
   were not promoted at composition time.
8. The promoted pointer bumps are the release's real content and are
   recorded in the release branch as pointer-capture commits — the recorded
   SHA carries its pushed hash-permanence tag per
   `git-workflow-branch` rule 3's tagged-SHA pointer discipline (the release
   exemption `git-workflow-pr` §2(e) already states), so every recorded
   pointer stays name-reachable. Read [git-workflow-branch — the tagged-SHA
   pointer discipline and its pull-only clause](../git-workflow-branch/SKILL.md)
   before recording any pointer bump, and govern every pull-only submodule
   origin by that clause.

   **Recording mechanism — plumbing-first, never `git add` over a divergent
   checkout:** a capture commit records a promoted pointer through index
   plumbing alone (`git rm --cached <path>` plus `git update-index --add
   --cacheinfo 160000,<promoted-SHA>,<path>`), or by checking out the
   promoted SHA in the submodule first — `git add <submodule-path>` is
   prohibited whenever the submodule checkout's HEAD differs from the
   promoted SHA; over a dirty foreign-HEAD checkout it silently re-resolves
   the gitlink from the checkout HEAD and reverts the promotion (the field
   failure this prohibition closes, 2026-11-19, commit `888d664`).
   **Mandatory post-capture assertion, before push:** after the capture
   commit, for every promoted submodule run
   ```bash
   recorded=$(git ls-tree HEAD <path> | awk '{print $3}')
   [ "$recorded" = "$promoted-SHA" ] || { echo "CAPTURE_ASSERT_FAIL: <path> recorded $recorded != promoted $promoted-SHA"; exit 1; }
   ```
   A failing assertion aborts the capture — name the mismatching submodule,
   exit non-zero, perform no push — and is remediated by re-recording via
   plumbing before the push attempt is retried.

## Phase A — clean-room verification gate

Entry criteria:

- The composition phase (Phase C-0) has run — pointers promoted at trunk
  tips
- The parent repository's release branch has been pushed to the remote
- The release branch records the submodule pointers for the release
  candidate (pointer capture — the promoted pointers)
- Next version determined
- The release PR has NOT been filed yet

Procedure — verify the release candidate in the composed consumption layout,
so the release PR is filed only for a state already proven from a clean room:

1. Determine the release candidate: the head of the pushed release branch of
   the parent repository.
2. Create a temp directory (`mktemp -d`) and perform a shallow clone of the
   **parent repository** into it, using the parent repository's remote URL —
   remote transport only:
   ```bash
   git clone --depth 1 --branch <branch> <parent-remote-url> <tmpdir>
   ```
   The clone flags are normative: `--depth 1` makes the clone shallow, and
   `--branch <branch>` selects and checks out the release branch's head in
   the clone itself — a shallow clone fetches only the named branch's tip,
   never full history. The initial clone is of the parent repository, never
   of a submodule repository directly: the parent clone is what carries every
   submodule at its recorded pointer (siblings included) and reproduces the
   real consumption layout; a direct submodule clone resolves nothing and
   stands in no parent. A local-path clone is FORBIDDEN: git resolves
   relative submodule URLs against the parent's origin, and a file-protocol
   origin is refused for submodule fetches by git's default security policy
   (`protocol.file.allow`), before any assertion runs; `--depth 1` is also
   ignored on local clones.
3. State `CHECKOUT_OK` when the temp copy is at the release branch's head. If
   the clone or checkout fails, hard-fail and do not proceed to PR creation —
   this is an environment/transport setup defect: diagnose it and re-run the
   gate.
4. Resolve submodules inside the temp checkout at the gitlink-pinned SHAs the
   parent's release branch records — this populates the release candidate and
   its sibling submodules exactly as in a real checkout:
   ```bash
   git -C <tmpdir> submodule update --init --depth 1
   ```
   `--remote` and `--recursive` are FORBIDDEN anywhere in this protocol —
   `--remote` would resolve submodules to branch tips instead of pinned SHAs,
   and `--recursive` would pull in unintended nested submodules.
5. **Submodule drift assertion (resolved SHA == pinned SHA):** after
   `git submodule update --init --depth 1`, compare each resolved submodule
   SHA against the SHA pinned by the parent's recorded gitlink:
   ```bash
   resolved=$(git -C <tmpdir>/<submodule-path> rev-parse HEAD)
   pinned=$(git -C <tmpdir> ls-tree HEAD <submodule-path> | awk '{print $3}')
   [ "$resolved" = "$pinned" ] || { echo "DRIFT_FAIL: <submodule-path> resolved $resolved != pinned $pinned"; exit 1; }
   ```
   Repeat for EVERY submodule. Any mismatch is a hard fail: state
   `DRIFT_FAIL`, exit non-zero, and do NOT proceed — the release PR is
   blocked. `git submodule status` may be used as a cross-check (a `+`
   prefix on a submodule line indicates drift from the gitlink). The
   `DRIFT_FAIL` triage names which failure class fired, and its route:
   - **Composition defect** — the pinned SHA is not fetchable from the
     submodule's remote at all (the remote refuses the object: `Server does
     not allow request for unadvertised object`) — the recorded pointer was
     never consumable and is behind the submodule's real trunk tip. Route:
     recompose per Phase C-0 (promote the submodule to its resolved remote
     trunk tip), re-record the pointer, and file no PR this run.
   - **Candidate defect** — the pinned SHA is fetchable remotely but the
     resolved SHA mismatches it (stale or altered release branch content):
     fetch works, pointer does not. Route: release blocked for developer
     direction — the gate's no-retry rule stands.
   Either route files no release PR; the no-retry rule is unchanged in both
   classes.
6. Record the verified state for the post-merge re-check: the release
   branch's head SHA and its tree SHA
   (`git -C <tmpdir> rev-parse HEAD HEAD^{tree}`) go into the release work
   record.
7. **Canonical build and test command discovery (sanctioned sources):**
   discover the canonical build and test commands from sanctioned, documented
   sources in this fixed order: (a) first the **declared build manifest** of
   the release tree, when one exists — the file the parent repository itself
   declares as the source of its canonical commands (its AGENTS.md or an
   equivalent the repository names); (b) next the **session-init per-root
   facts**, where they supply build/test commands; (c) last the
   **repository's own documented build framework** — the wrapper the floor's
   build-tooling exclusivity rule sanctions for the repository's build
   system. The parent's build framework governs how the composed tree is
   built and tested; the gate never hardcodes a specific build system and
   never substitutes a submodule's own tooling run in isolation for the
   parent's framework.
   1. Read the root build manifest of the temp checkout (the parent
      repository's) first and look for a build/test commands section.
   2. If the root manifest has no build commands section, fall back to the
      submodule manifests it names for the declared commands.
   3. Identify the canonical build command and the canonical test command
      from the discovered section.
   4. If the manifest supplies no commands, resolve from the next sanctioned
      source: the session-init per-root facts where they supply build/test
      commands, else the repository's own documented build framework.
      Manifest absence is NOT a blocking failure — only real failures block
      the release (step 10).
   5. Terminal no-source case: when no sanctioned source yields build/test
      commands — no manifest, no session-init facts, no documented build
      framework — the candidate cannot be proven tested: state
      `NO_SOURCE_FAIL`, exit non-zero, and do NOT proceed — no PR is filed
      for an unproven candidate. `NO_SOURCE_FAIL` is a real blocking failure
      (an equivalent verified failure under the step-10 rule): no retry
      within the release.
   6. Record the resolved build and test commands and the sanctioned source
      that supplied each in the release work record, so the zero-failure
      assertion's provenance is auditable.
   7. All discovery reads happen inside `<tmpdir>` against the composed
      checkout — never against the source working tree.
8. **Build and test execution with zero-failure assertion:** execute the
   discovered build command, then the discovered test command, inside the
   temp checkout `<tmpdir>` — through the parent's build framework in the
   composed layout, never in the source working tree and never against a
   submodule checked out in isolation:
   ```bash
   (cd <tmpdir> && <build-command>) || { echo "BUILD_FAIL: build command exited non-zero"; exit 1; }
   (cd <tmpdir> && <test-command>) || { echo "BUILD_FAIL: test command exited non-zero"; exit 1; }
   ```
   Both commands MUST exit zero. Any non-zero exit is `BUILD_FAIL`: exit
   non-zero, state `BUILD_FAIL` with the failing command and its exit code,
   and do NOT proceed — the release PR is blocked; no PR is filed for an
   unproven candidate.
9. All verification work happens inside `<tmpdir>`. The gate is read-only
   with respect to the source working tree — never touch, checkout, or
   reset the source repo.
10. **Invocation guarantee:** real failures — assertion failures
    (`DRIFT_FAIL`, `BUILD_FAIL`, `TREE_MISMATCH` in Phase B), an actual
    build or test non-zero exit, a tree mismatch, or an equivalent verified
    failure, including the terminal `NO_SOURCE_FAIL` — block the release
    with NO retries within the release run — a failed assertion must not be
    re-run, remediated inline, or re-attempted in the same release. Environment/transport setup
    failures (clone, checkout, transport policy) are NOT release-blockers:
    they are diagnosed and the gate is re-run. Only when the gate completes
    clean (`CHECKOUT_OK`, drift asserted, build and test zero-failure) is the
    release PR filed — from the verified release branch head, in the parent
    repository.

## Phase B — post-merge pre-tag re-check

Entry criteria:

- Release PR has been merged (the merge is a human gate)

Procedure — confirm the merge delivered exactly the verified state before any
tag is created:

1. Determine the merged commit (the commit to be tagged) — the parent
   repository's trunk tip after the merge.
2. Create a temp directory (`mktemp -d`) and perform a shallow clone from the
   same parent repository remote URL, remote transport only:
   ```bash
   git clone --depth 1 <parent-remote-url> <tmpdir>
   ```
   State `CHECKOUT_OK` when the temp copy is at the merged commit. Clone or
   checkout failures are environment/transport setup defects: diagnose and
   re-run.
3. **Submodule drift assertion** against the merged commit: resolve submodules
   (`git -C <tmpdir> submodule update --init --depth 1`) and run the same
   resolved-SHA == pinned-SHA comparison as in Phase A step 5, against the
   parent's recorded gitlinks as updated by the merge. Any mismatch is
   `DRIFT_FAIL`: exit non-zero, no tag — promotion is blocked.
4. **Tree-content-identity re-check:** compare the merged tree against the
   tree the clean-room gate recorded (Phase A step 6):
   ```bash
   merged_tree=$(git -C <tmpdir> rev-parse HEAD^{tree})
   [ "$merged_tree" = "$verified_tree" ] || { echo "TREE_MISMATCH: merged tree $merged_tree != verified tree $verified_tree"; exit 1; }
   ```
   A mismatch is `TREE_MISMATCH`: it blocks promotion with no tag — the
   merged tree was never clean-room-verified — and the release stops for
   developer direction. Identical trees inherit the branch head's
   verification.
5. Environment/transport setup failures in this phase are diagnosed and the
   re-check re-run; assertion failures (`DRIFT_FAIL`, `TREE_MISMATCH`) block
   with no retry within the release run.

## Tag and release

1. **Tag format:** `v{semver}` (v prefix — de facto standard, Semver FAQ)
2. **Release conversion:** the release PR strips the dev suffix and carries
   the bare version; the release number is re-derived from the changelog,
   authoritative over the dev base's claim
3. **Annotated tags:** always use `git tag -a` with a message
4. **Release body:** changelog entries for that version (standard practice)
5. **Post-merge only:** only create tags after the release PR has merged

## Exit criteria

- Tag created and pushed
- Release created with the changelog body

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
