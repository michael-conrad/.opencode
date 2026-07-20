## Observed Behavior

The pre-commit hook's Gate 2a (dispatch evidence check) blocks `git commit` on implementation branches (`feature/*`) when no `tmp/work-*.md` file exists. The error message says "Remediate: call skill({name: \"divide-and-conquer\"}) --task assemble-work" but this is a circular dependency — the agent cannot create a work state file without committing, and cannot commit without a work state file.

The only way past the gate is to manually create `tmp/work-*.md` with the correct frontmatter (`authorization_scope:`, `halt_at:`), which is a bypass, not a workflow.

## Expected Behavior

Either:
- The `git-workflow` skill's `pre-work` task should create the work state file automatically before any commit
- Or Gate 2a should have a creation path (e.g., `git commit --no-verify` for the first commit that creates the work state file)
- Or the work state file should be created by the authorization/approval gate when scope is set

## Steps to Reproduce

1. Create a feature branch: `git checkout -b feature/68-foo`
2. Make a change to any file
3. `git add` and `git commit`
4. Observe: Gate 2a blocks with "no work state file for branch"
5. No documented workflow exists to create the work state file without bypassing the gate

## Component

`.opencode/hooks/pre-commit` — Gate 2a (dispatch evidence check)

## Severity

High — every new feature branch hits this gate on the first commit, requiring manual workaround. The gate enforces a valid invariant (tracked work) but provides no creation path.