<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Generate shell completion scripts for `gh` using `gh completion -s <shell>`. Supports bash, zsh, fish, and powershell. Single-command workflow — no multi-step pipeline.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The target shell (`bash`, `zsh`, `fish`, or `powershell`) is provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. Determine the target shell from the task context. Supported values: `bash`, `zsh`, `fish`, `powershell`.
2. Run `gh completion -s <shell>` to generate the completion script.
   - If the shell is not supported, `gh` will print an error. Return BLOCKED with the error message.
3. Write the completion script output to the artifact path.
   - The output is a shell script that can be sourced or installed.
   - Use the filename pattern: `gh-completion.<shell>` (e.g., `gh-completion.bash`).
4. Verify the output file is non-empty and starts with a valid shell comment or completion directive.
   - For bash: should contain `#compdef gh` or `complete -o` directives.
   - For zsh: should contain `#compdef gh` or `_gh` function definitions.
   - For fish: should contain `complete -c gh` directives.
   - For powershell: should contain `Register-ArgumentCompleter` or function definitions.
   - If the file is empty or does not contain expected patterns, return BLOCKED with details.

## Exit Criteria

- The completion script has been generated and written to disk
- The output file has been verified as non-empty with expected shell-specific content

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<shell, output file path, line count>"
artifact_path: "<path to completion script>"
blocker_reason: "<reason if BLOCKED>"
```
