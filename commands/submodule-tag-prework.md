# submodule-tag-prework

Tag all submodules at dev tip with `<parent-repo>/<issue-number>` format before starting work.

## Procedure

1. For each submodule path in `.gitmodules`
2. `cd <path> && git checkout dev && git pull`
3. `git tag -a "<parent-repo>/<issue-number>" -m "Pre-work: <path> at dev tip for issue #<issue-number>"`
4. `git push origin <tag>`
5. Verify: `git ls-remote --tags origin <tag>` shows the SHA

## Tag Naming

`<parent-repo-name>/<issue-number>` (e.g., `opencode-config/215`)

## Verification

```bash
git ls-remote --tags origin <tag>
# Output must show a SHA, not empty
```
