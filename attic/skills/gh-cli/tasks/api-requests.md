<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Makes authenticated GitHub API requests using `gh api` with configurable HTTP method, endpoint, parameters, pagination, and jq filtering for structured data extraction.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gh auth status` exits 0 (authenticated session)
- The HTTP method (GET, POST, PUT, PATCH, DELETE) and API endpoint (e.g., `/repos/owner/repo/issues`) are provided in the task context
- Any required request body, query parameters, or headers are provided
- `gh` CLI must be installed and on PATH
- `jq` must be installed and on PATH (for filtering steps)

## Procedure

1. Construct and execute the API request:
   - **GET request**: `gh api <endpoint> --method GET --jq '<jq-filter>'`
     - Append query parameters: `--field <key>=<value>` or `--raw-field '<key>=<value>'`.
     - Use `--paginate` to automatically fetch all pages of results.
   - **POST/PUT/PATCH request**: `gh api <endpoint> --method <POST|PUT|PATCH> --input <body-file> --field <key>=<value>`
     - If the request body is a JSON object, write it to a temp file and use `--input <path>`.
     - Alternatively, pass fields directly: `--field <key>=<value>` for simple values, `--raw-field '<key>=<value>'` for complex values.
   - **DELETE request**: `gh api <endpoint> --method DELETE`
     - Use `--silent` to suppress output for successful deletes.
2. Handle pagination for list endpoints:
   - Use `--paginate` to automatically traverse all pages.
   - Without `--paginate`, check the response headers for `Link` pagination headers and iterate manually if needed.
   - Combine results across pages into a single JSON array for analysis.
3. Apply jq filtering to extract specific fields:
   - `gh api <endpoint> --jq '.[] | {number: .number, title: .title, state: .state}'`
   - For nested data: `--jq '.items[] | {name: .name, url: .html_url}'`
   - For aggregation: `--jq '[group_by(.state)[] | {state: .[0].state, count: length}]'`
   - Verify the jq filter produces valid JSON output before writing to the artifact.
4. Handle errors and rate limits:
   - If the response status is 4xx or 5xx, parse the error message and return BLOCKED with the failure reason.
   - If rate limited (status 403 with `X-RateLimit-Remaining: 0`), note the reset time and return BLOCKED.
5. Write the API response summary (endpoint, method, status code, result count, key extracted fields) to the artifact path.
   - If the response is large, write the full response to a separate file and reference it in the summary.

## Exit Criteria

- The API request has been executed with the correct method, endpoint, and parameters
- Pagination has been handled (if applicable)
- jq filtering has been applied and produced valid output
- Errors and rate limits have been handled appropriately
- The API response summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<endpoint, method, status code, result count, key fields>"
artifact_path: "<path to API response summary>"
blocker_reason: "<reason if BLOCKED>"
```
