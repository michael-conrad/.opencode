# Finishing a Development Branch Operating Protocol

## Entry Criteria

- Implementation is complete
- All changes committed to the feature branch

## Procedure

- [ ] 1. **All changes committed:** `git status` shows clean.
- [ ] 2. **All tests pass:** `uv run pytest` green.
- [ ] 3. **Lint clean:** `uvx ruff check` zero errors.
- [ ] 4. **Type check:** `uvx pyright` clean.
- [ ] 5. **Branch pushed:** up to date with remote.
- [ ] 6. **Plan sub-issue closure verification:** matched against implementation.
- [ ] 7. **Correctness over speed.** Every code path with runtime behavior requires live-wire testing against real systems. A slow correct answer is strictly better than a fast incorrect one. Static analysis alone is NOT acceptable verification — behavioral compliance requires actual execution with cross-validated PASS verdict.

## Exit Criteria

- git status clean
- All tests pass
- Lint and type checks pass
- Branch pushed
- Plan sub-issues verified
