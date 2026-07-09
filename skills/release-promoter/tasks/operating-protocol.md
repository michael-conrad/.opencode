# Release Promoter Operating Protocol

## Entry Criteria

- Release PR has been merged
- Next version determined

## Procedure

- [ ] 1. **Tag format:** `v{semver}` (v prefix — de facto standard, Semver FAQ)
- [ ] 2. **Annotated tags:** Always use `git tag -a` with a message
- [ ] 3. **Release body:** Changelog entries for that version (standard GitHub practice)
- [ ] 4. **Post-merge only:** Only create tags after the release PR has merged

## Exit Criteria

- Tag created and pushed
- GitHub Release created with changelog body
