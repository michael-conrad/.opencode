# ErrorHandling

Error handling procedure for command execution.

1. Capture exit code and stderr output
2. Classify error by exit code:
   - Exit 1: General error — log and retry
   - Exit 2: Misuse of shell built-in — halt and report
   - Exit 126: Command not executable — halt and report
   - Exit 127: Command not found — halt and report
   - Exit 130: Interrupted by Ctrl+C — halt and report
   - Exit 137: Killed by SIGKILL (OOM) — retry with reduced memory
   - Exit 143: Killed by SIGTERM (timeout) — retry with increased timeout
3. For retryable errors: wait `retry_delay` seconds, then retry up to `max_retries` times
4. For non-retryable errors: report the error and halt
5. Log all errors with timestamp, exit code, and stderr content
