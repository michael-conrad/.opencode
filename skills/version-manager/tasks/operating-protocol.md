# Version Manager Operating Protocol

## Entry Criteria

- Version discovery or bump requested
- Project root known

## Procedure

- [ ] 1. **Dynamic discovery:** Use grep with version-pattern regex across the entire project — no hardcoded file list
- [ ] 2. **File type classification:** Classify each match by file type to determine correct update syntax
- [ ] 3. **Semver bump logic:** breaking→major, added→minor, fix/other→patch
- [ ] 4. **All locations updated:** Every discovered version string is updated — no partial updates

## Exit Criteria

- Version strings discovered
- Version bumped (if requested) in all locations
