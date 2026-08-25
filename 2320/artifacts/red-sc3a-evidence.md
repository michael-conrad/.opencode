# RED Evidence — SC-3a

**Scenario:** `2320-sc3a-pre-commit-pointer-check-staging`
**Phase:** RED
**Model:** ollama/qwen3.6:35b-256k
**Issue:** #2320 (`.opencode` submodule)

## Criterion Under Test (SC-3a)

`pre-commit-pointer-check.md` uses unambiguous pointer-rides-alongside language: a dirty
pointer is staged **AND COMMITTED** alongside a real root change, never dropped and never
committed standalone.

## RED Premise (confirmed via grep)

Current `pre-commit-pointer-check.md` contains NONE of: "never dropped", "never standalone",
"never committed standalone", "committed alongside", "rides alongside", "real root change".
The procedure's terminal step is "verify staged files" — it never instructs the pointer be
COMMITTED alongside the real root change.

## Model Behavior (session.yaml / timeline.yaml)

Agent sequence (timeline.yaml):
1. skill git-workflow
2. read `pre-commit-pointer-check.md`
3. `git status --short && git submodule status && git branch --show-current`
4. `git submodule status | grep '^ '`
5. `git add .opencode src/` — staged pointer alongside real change ✓
6. `git diff --cached --name-only | grep ...` / `git diff --cached -- .opencode` — verified staged

**Agent stopped here (Step 3 verify). NO `git commit` was executed.**
stdout.log final line: "The procedure is complete. The next step is `git commit` with both
items staged. Ready for that command."

## Verdict: RED (confirmed FAIL)

The agent staged the pointer alongside the real change but did **NOT commit** it alongside
the real change. The current file's procedure ends at staging/verification; it never
instructs the pointer be committed alongside the real root change (nor the never-dropped /
never-committed-standalone language). The agent's behavior therefore does NOT satisfy
SC-3a's commit requirement. Confirmed RED — test is genuinely needed.
