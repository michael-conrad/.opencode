# RetryPolicy

Retry behavior for transient failures.

- `max_attempts=3` — Total attempts including the first
- `backoff=exponential` — Backoff strategy (exponential, linear, fixed)
- `base_delay=1` — Initial delay in seconds
- `max_delay=30` — Maximum delay cap in seconds
- Retry on: 429, 502, 503, 504 status codes
