## Observed Behavior

Running `./.opencode/tools/local-issues link --help` returns:

```
Error: invalid issue number
```

Running `./.opencode/tools/local-issues link` returns:

```
Error: issue number required
```

Neither invocation shows usage/help text.

## Expected Behavior

`--help` should print the `link` subcommand's usage: required arguments, optional flags, and examples.

## Steps to Reproduce

1. `./.opencode/tools/local-issues link --help`
2. Observe: `Error: invalid issue number`

## Component

`.opencode/tools/local-issues` — `link` subcommand

## Severity

Medium — blocks automated sub-issue linking workflows. User must guess argument format.