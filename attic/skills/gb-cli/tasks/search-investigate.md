<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Searches and investigates GitBucket repositories, issues, and pull requests using iterative listing with client-side filtering, plus `gb api` passthrough and `gb browse` for deeper inspection. GitBucket has no native search API — search is composed from list commands and client-side filters.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The search query and search target (issues, pull requests, repositories) are provided in the task context
- Any filter qualifiers (owner, state, label) are provided in the task context
- `gb` CLI must be installed and on PATH

## Procedure

1. Determine the search scope from the task context:
   - For issues: `gb issue list -R <owner/repo> --state <open|closed|all>`
   - For pull requests: `gb pr list -R <owner/repo> --state <open|closed|all>`
   - For repositories: `gb repo list [owner]`
2. Run the list command and capture the output.
   - GitBucket has no native search API (`gb search` does not exist). Search is performed by iterative listing plus client-side filtering. Document this limitation in the findings.
   - If the list returns zero results, return DONE with `finding_summary: "No results found for query: <query>"`.
3. Apply client-side filters to narrow the results by the query terms (title match, state, label, owner). Use the filter qualifiers provided in the task context.
4. For each result that requires deeper investigation, use a structured view command:
   - `gb issue view <number> -R <owner/repo> --comments`
   - `gb pr view <number> -R <owner/repo>`
   - `gb repo view <owner/repo>`
5. If a broader endpoint is needed, use the API passthrough: `gb api <endpoint> -R <owner/repo>` (e.g., `/repos/{owner}/{repo}/branches`).
6. If browser investigation is requested, use `gb browse` to open the repository in the web browser and capture the URL.
7. Write the search summary (query, result count, top results with URLs, any opened URLs) to the artifact path.

## Exit Criteria

- The search has been executed with iterative listing and client-side filtering
- Results have been parsed and key fields extracted
- Any requested results have been inspected via structured view or opened in the browser
- The search summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<search target, query, result count, top results>"
artifact_path: "<path to search summary>"
blocker_reason: "<reason if BLOCKED>"
```
