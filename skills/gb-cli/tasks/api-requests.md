<!-- SPDX-FileCopyrightText: 2026 Michael Conrad -->
<!-- SPDX-License-Identifier: MIT -->
<!-- Provenance: AI-generated -->

Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

## Purpose

Makes authenticated GitBucket REST API requests using `gb api` with configurable HTTP method, endpoint, and JSON input for structured data extraction and operations without a dedicated `gb` command.

## Task Discipline

- [ ] 1. Execute every step in this task sequentially — none are optional
- [ ] 2. Do not dispatch sub-agents from within this task
- [ ] 3. If blocked, return BLOCKED with reason — do not work around it
- [ ] 4. Return only: `status`, `finding_summary`, `artifact_path`, `blocker_reason`. Full evidence goes to disk.

## Entry Criteria

- `gb auth status` exits 0 (authenticated session)
- The HTTP method (GET, POST, PUT, PATCH, DELETE) and API endpoint (e.g., `/repos/owner/repo/issues`) are provided in the task context
- Any required request body or JSON input is provided
- `gb` CLI must be installed and on PATH

## Procedure

1. Construct and execute the API request:
   - **GET request**: `gb api <endpoint> -R <owner/repo>`
   - **POST/PUT/PATCH request**: `gb api <endpoint> -X <POST|PUT|PATCH> -i <body-file> -R <owner/repo>`
     - If the request body is a JSON object, write it to a temp file and use `-i <path>`.
     - Alternatively, pass `-i -` to read the JSON body from stdin.
   - **DELETE request**: `gb api <endpoint> -X DELETE -R <owner/repo>`
2. Handle the response:
   - The endpoint path is relative to `/api/v3`, or a full URL under the configured GitBucket API base.
   - Parse the JSON output and extract the fields relevant to the task.
   - If the response is large, write the full response to a separate file and reference it in the summary.
3. Handle errors:
   - If the response status is 4xx or 5xx, parse the error message and return BLOCKED with the failure reason.
   - Use `--json-errors` to emit structured error output on stderr when diagnosing failures.
4. Verify any mutating operation:
   - For POST/PUT/PATCH/DELETE requests, verify the resulting state with a follow-up GET request to the same or related endpoint.
5. Write the API response summary (endpoint, method, status code, result count, key extracted fields) to the artifact path.

## Exit Criteria

- The API request has been executed with the correct method, endpoint, and parameters
- The response has been parsed and key fields extracted
- Mutating operations have been verified with a follow-up GET
- Errors have been handled appropriately
- The API response summary has been written to disk

## Result Contract

```yaml
status: DONE | BLOCKED
finding_summary: "<endpoint, method, status code, result count, key fields>"
artifact_path: "<path to API response summary>"
blocker_reason: "<reason if BLOCKED>"
```
