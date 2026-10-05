<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Searches GitHub repositories, issues, pull requests, and code using `gh search` with structured filters, then opens results in the browser for investigation.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The search query and search type (repos, issues, prs, code) are provided in the task context
- Any filter qualifiers (language, owner, state, label, topic, path, org) are provided in the task context
- `gh` CLI must be installed and on PATH

## Procedure

1. Determine the search scope and construct the query:
   - For repositories: `gh search repos "<query>" --owner <owner> --language <lang> --topic <topic> --limit <N> --json name,owner,description,url,language,stars,updatedAt`
   - For issues: `gh search issues "<query>" --owner <owner> --repo <owner/repo> --state <open|closed> --label "<label>" --author <user> --assignee <user> --limit <N> --json number,title,state,url,labels,updatedAt`
   - For pull requests: `gh search prs "<query>" --owner <owner> --repo <owner/repo> --state <open|closed> --label "<label>" --author <user> --assignee <user> --draft <true|false> --limit <N> --json number,title,state,url,labels,updatedAt`
   - For code: `gh search code "<query>" --owner <owner> --repo <owner/repo> --language <lang> --path "<path>" --limit <N> --json path,repository,url`
2. Run the search command and capture the JSON output.
   - If the search returns zero results, return DONE with `finding_summary: "No results found for query: <query>"`.
   - If the search returns results, parse the JSON to extract key fields (name, URL, state, etc.).
3. For each result that requires deeper investigation, open it in the browser:
   - `gh browse <url>`
   - Note: this opens the browser; the agent captures the URL for the artifact.
   - Alternatively, use `gh <subcommand> view <id> --repo <owner/repo> --json <fields>` for structured inspection without the browser.
4. If the search type is `code`, inspect the matched code snippet:
   - `gh search code "<query>" --repo <owner/repo> --path "<path>" --match <file|path>` to narrow results.
   - Read the matched file content using `gh api` or the file path from the search results.
5. Write the search summary (query, result count, top results with URLs, any opened URLs) to the artifact path.

## Exit Criteria

- The search has been executed with the correct query and filters
- Results have been parsed and key fields extracted
- Any requested results have been opened in the browser or inspected via structured view
- The search summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<search type, query, result count, top results>"
artifact_path: "<path to search summary>"
blocker_reason: "<reason if BLOCKED>"
```
