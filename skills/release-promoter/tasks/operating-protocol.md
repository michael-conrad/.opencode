# Release Promoter Operating Protocol

## Entry Criteria

- Release PR has been merged
- Next version determined

## Procedure

- [ ] 0. **Verification gate (before tag creation):** Verify the release tree against a clean, shallow temp-copy checkout of the release commit. This step runs BEFORE any tag is created and NEVER modifies the source tree.
  1. Determine the release commit (the commit to be tagged).
  2. Create a temp directory (e.g., `mktemp -d`) and perform a shallow clone of the root repo into it:
     ```bash
     git clone --depth 1 <repo-url-or-path> <tmpdir>
     ```
  3. Check out the release commit inside the temp copy:
     ```bash
     git -C <tmpdir> checkout <release-commit>
     ```
  4. State `CHECKOUT_OK` when the temp copy is at the release commit. If the clone or checkout fails, hard-fail and do not proceed to tagging.
  5. Initialize submodules inside the temp checkout at their gitlink-pinned SHAs:
     ```bash
     git -C <tmpdir> submodule update --init --depth 1
     ```
     This resolves every submodule to the exact SHA pinned by the release commit's gitlink. `--remote` and `--recursive` are FORBIDDEN anywhere in this gate — `--remote` would resolve submodules to branch tips instead of pinned SHAs, and `--recursive` would pull in unintended nested submodules.
   6. **Submodule drift assertion (resolved SHA == pinned SHA):** After `git submodule update --init --depth 1`, compare each resolved submodule SHA against the SHA pinned by the release commit's gitlink:
      ```bash
      resolved=$(git -C <tmpdir>/<submodule-path> rev-parse HEAD)
      pinned=$(git -C <tmpdir> ls-tree HEAD <submodule-path> | awk '{print $3}')
      [ "$resolved" = "$pinned" ] || { echo "DRIFT_FAIL: <submodule-path> resolved $resolved != pinned $pinned"; exit 1; }
      ```
      Repeat for EVERY submodule. Any mismatch is a hard fail: state `DRIFT_FAIL`, exit non-zero, and do NOT proceed to tagging — promotion is blocked. `git submodule status` may be used as a cross-check (a `+` prefix on a submodule line indicates drift from the gitlink).
   7. All verification work happens inside `<tmpdir>`. The gate is read-only with respect to the source working tree — never touch, checkout, or reset the source repo.
- [ ] 1. **Tag format:** `v{semver}` (v prefix — de facto standard, Semver FAQ)
- [ ] 2. **Annotated tags:** Always use `git tag -a` with a message
- [ ] 3. **Release body:** Changelog entries for that version (standard GitHub practice)
- [ ] 4. **Post-merge only:** Only create tags after the release PR has merged

## Exit Criteria

- Tag created and pushed
- GitHub Release created with changelog body
