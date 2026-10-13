<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: restored from the pre-rip release-promoter operating protocol (tag pre-rip; gate implemented as .opencode#2439), re-homed and root-agnosticized, .opencode#2557; gate moved pre-PR (after branch push, before PR filing), remote-transport-only clone, no-retry rescope, TREE_MISMATCH re-check, .opencode#2590 -->

# Release Promotion — Operating Protocol

Promotion runs in two verification phases around the human merge gate: the
clean-room gate proves the release candidate before the PR exists, and a
reduced re-check confirms the merge delivered exactly that verified tree
before any tag is created.

## Phase A — clean-room verification gate

Entry criteria:

- Release branch has been pushed to the remote
- Next version determined
- The release PR has NOT been filed yet

Procedure — verify the release candidate (the release branch's head) so the
PR is filed only for a state already proven from a clean room:

1. Determine the release candidate: the head of the pushed release branch.
2. Create a temp directory (`mktemp -d`) and perform a shallow clone of the
   repository into it, using the SAME parent URL the root project repo itself
   is cloned from — remote transport only:
   ```bash
   git clone --depth 1 --branch <branch> <remote-url> <tmpdir>
   ```
   The clone flags are normative: `--depth 1` makes the clone shallow, and
   `--branch <branch>` selects and checks out the release branch's head in the
   clone itself — a shallow clone fetches only the named branch's tip, never
   full history. A local-path clone is FORBIDDEN: git resolves relative
   submodule URLs against the parent's origin, and a file-protocol origin is
   refused for submodule fetches by git's default security policy
   (`protocol.file.allow`), before any assertion runs; `--depth 1` is also
   ignored on local clones.
3. State `CHECKOUT_OK` when the temp copy is at the release branch's head. If
   the clone or checkout fails, hard-fail and do not proceed to PR creation —
   this is an environment/transport setup defect: diagnose it and re-run the
   gate.
4. Resolve submodules inside the temp checkout at their gitlink-pinned SHAs:
   ```bash
   git -C <tmpdir> submodule update --init --depth 1
   ```
   This resolves every submodule to the exact SHA pinned by the release
   candidate's gitlink. `--remote` and `--recursive` are FORBIDDEN anywhere in
   this protocol — `--remote` would resolve submodules to branch tips instead
   of pinned SHAs, and `--recursive` would pull in unintended nested
   submodules.
5. **Submodule drift assertion (resolved SHA == pinned SHA):** after
   `git submodule update --init --depth 1`, compare each resolved submodule
   SHA against the SHA pinned by the release candidate's gitlink:
   ```bash
   resolved=$(git -C <tmpdir>/<submodule-path> rev-parse HEAD)
   pinned=$(git -C <tmpdir> ls-tree HEAD <submodule-path> | awk '{print $3}')
   [ "$resolved" = "$pinned" ] || { echo "DRIFT_FAIL: <submodule-path> resolved $resolved != pinned $pinned"; exit 1; }
   ```
   Repeat for EVERY submodule. Any mismatch is a hard fail: state
   `DRIFT_FAIL`, exit non-zero, and do NOT proceed — the PR is blocked.
   `git submodule status` may be used as a cross-check (a `+` prefix on a
   submodule line indicates drift from the gitlink).
6. Record the verified state for the post-merge re-check: the release
   branch's head SHA and its tree SHA
   (`git -C <tmpdir> rev-parse HEAD HEAD^{tree}`) go into the release work
   record.
7. **Canonical build and test command discovery (build manifest):** discover
   the repository's canonical build and test commands from the repo's **build
   manifest** — the file the repository itself declares as the source of its
   canonical commands (its AGENTS.md or an equivalent the repository names).
   Never assume or hardcode a specific build system.
   1. Read the root build manifest of the temp checkout first and look for a
      build/test commands section.
   2. If the root manifest has no build commands section, fall back to the
      submodule manifests it names for the declared commands.
   3. Identify the canonical build command and the canonical test command
      from the discovered section.
   4. If the commands cannot be discovered from the manifest, hard-fail:
      state `MANIFEST_FAIL`, exit non-zero, and do NOT proceed — the PR is
      blocked. Manifest discoverability is a property of the release tree, so
      `MANIFEST_FAIL` is an assertion failure: no retry within the release.
   5. All discovery reads happen inside `<tmpdir>` against the
      release-branch checkout — never against the source working tree.
8. **Build and test execution with zero-failure assertion:** execute the
   discovered build command, then the discovered test command, inside the
   temp checkout `<tmpdir>` — never in the source working tree:
   ```bash
   (cd <tmpdir> && <build-command>) || { echo "BUILD_FAIL: build command exited non-zero"; exit 1; }
   (cd <tmpdir> && <test-command>) || { echo "BUILD_FAIL: test command exited non-zero"; exit 1; }
   ```
   Both commands MUST exit zero. Any non-zero exit is `BUILD_FAIL`: exit
   non-zero, state `BUILD_FAIL` with the failing command and its exit code,
   and do NOT proceed — the PR is blocked; no PR is filed for an unproven
   candidate.
9. All verification work happens inside `<tmpdir>`. The gate is read-only
   with respect to the source working tree — never touch, checkout, or
   reset the source repo.
10. **Invocation guarantee:** assertion failures (`DRIFT_FAIL`,
    `MANIFEST_FAIL`, `BUILD_FAIL`) block the release with NO retries within
    the release run — a failed assertion must not be re-run, remediated
    inline, or re-attempted in the same release. Environment/transport setup
    failures (clone, checkout, transport policy) are NOT release-blockers:
    they are diagnosed and the gate is re-run. Only when the gate completes
    clean (`CHECKOUT_OK`, drift asserted, build and test zero-failure) is the
    release PR filed — from the verified branch head.

## Phase B — post-merge pre-tag re-check

Entry criteria:

- Release PR has been merged (the merge is a human gate)

Procedure — confirm the merge delivered exactly the verified tree before any
tag is created:

1. Determine the merged commit (the commit to be tagged) — the trunk tip
   after the merge.
2. Create a temp directory (`mktemp -d`) and perform a shallow clone from the
   same parent URL, remote transport only:
   ```bash
   git clone --depth 1 <remote-url> <tmpdir>
   ```
   State `CHECKOUT_OK` when the temp copy is at the merged commit. Clone or
   checkout failures are environment/transport setup defects: diagnose and
   re-run.
3. **Submodule drift assertion** against the merged commit: resolve submodules
   (`git -C <tmpdir> submodule update --init --depth 1`) and run the same
   resolved-SHA == pinned-SHA comparison as in Phase A step 5, against the
   merged commit's gitlinks. Any mismatch is `DRIFT_FAIL`: exit non-zero, no
   tag — promotion is blocked.
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
2. **Annotated tags:** always use `git tag -a` with a message
3. **Release body:** changelog entries for that version (standard practice)
4. **Post-merge only:** only create tags after the release PR has merged

## Exit criteria

- Tag created and pushed
- Release created with the changelog body

🤖 Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
