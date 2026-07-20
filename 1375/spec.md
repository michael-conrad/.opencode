## Problem

The glob tool is non-functional for this repository. It delegates to ripgrep, which by default respects git submodule boundaries — directories containing a `.git` file (gitlink) are treated as separate repositories and silently skipped. Since `.opencode/` is a git submodule, glob from the repo root returns "No files found" for any file inside `.opencode/`.

This was confirmed by source code analysis of `packages/core/src/ripgrep.ts` in the anomalyco/opencode repo. The ripgrep args are hardcoded with no `--no-require-git` flag and no `opencode.jsonc` configuration key to add it. The only workaround (passing the `path` parameter) is circular — the agent must already know the file is in a submodule to search for it.

## Root Cause

`packages/core/src/ripgrep.ts` in anomalyco/opencode hardcodes ripgrep arguments:
```
args: ["--no-config", "--files", "--glob=!**/.git/**", "."]
```
ripgrep's built-in submodule detection treats `.opencode/.git` (a gitlink file) as a repository boundary and skips the directory entirely. No `opencode.jsonc` configuration key exists to override this behavior.

## Fix

Add `"tools": { "glob": false }` to `.opencode/opencode.jsonc` to disable the glob tool. This is a one-line addition.

## Impact

- Agents will no longer be able to call the glob tool
- File discovery must use `find`, `ls`, or `bash` instead
- The `060-tool-usage.md` guideline should be updated to document that glob is disabled and specify the replacement tooling

## Success Criteria

| ID | Criterion | Evidence Type | Verification Method |
|----|-----------|---------------|---------------------|
| SC-1 | `.opencode/opencode.jsonc` contains `"tools": { "glob": false }` | structural | `grep` for `"glob": false` in `.opencode/opencode.jsonc` — present |
| SC-2 | `060-tool-usage.md` documents that glob is disabled and specifies `find`/`ls`/`bash` as replacement | structural | `grep` for `glob is disabled` in `060-tool-usage.md` — present |

## Labels

`[SPEC]`, `config`

🤖 Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)