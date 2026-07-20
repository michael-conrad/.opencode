## Observed Behavior

Running `./.opencode/tools/local-issues create --title "test" --body "body text" --parent 15` silently ignores `--body` and `--parent` flags. The tool's `--help` output shows only `--number`, `--title`, and `--labels` as accepted arguments.

The created issue has no body content and no parent linkage.

## Expected Behavior

Either:
- `--body` and `--parent` should be supported flags for `create`
- Or the tool should error on unrecognized flags instead of silently ignoring them

## Steps to Reproduce

1. `./.opencode/tools/local-issues create --help`
2. Observe: only `--number`, `--title`, `--labels` listed
3. `./.opencode/tools/local-issues create --title "test" --body "body" --parent 15`
4. Observe: created with no body, no parent

## Component

`.opencode/tools/local-issues` — `create` subcommand

## Severity

Medium — sub-issues created via `local-issues create` have no body content and must be manually edited to add spec content.