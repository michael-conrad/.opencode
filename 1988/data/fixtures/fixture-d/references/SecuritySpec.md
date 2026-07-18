# SecuritySpec

Security requirements for command execution.

- No secrets in command arguments (redact before logging)
- No shell injection via user-supplied input
- No execution of untrusted scripts
- All file paths must be validated before access
- Temporary files must be cleaned up after execution
