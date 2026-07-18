# ValidationSpec

Validation criteria for command output verification.

- Output must be non-empty
- Output must not contain error-level log lines (ERROR, FATAL)
- Exit code must be 0
- Stderr must be empty (warnings permitted, errors not)
- Output format must match expected schema when specified
- Execution must complete within the configured timeout
