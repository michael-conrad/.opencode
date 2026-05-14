# submodule-tag-feat

Tag submodule feature-branch tip with `<parent-repo>/<issue-number>-<sub>` format.

## Procedure

1. Only if submodule has changes
2. Push submodule feature branch to remote
3. `git tag -a "<parent-repo>/<issue-number>-<sub>" -m "Feature: <path> tip for issue #<issue-number>"`
4. `git push origin <tag>`
5. Verify: `git ls-remote --tags origin <tag>` shows the SHA

## Tag Naming

`<parent-repo-name>/<issue-number>-<submodule-name>` (e.g., `opencode-config/215-opencode`)

## Verification

```bash
git ls-remote --tags origin <tag>
# Output must show a SHA, not empty
```
