# AuthPolicy

Authentication and authorization policy.

- All API calls require Bearer token in Authorization header
- Tokens expire after 3600 seconds
- Refresh tokens are single-use
- Rate limit: 1000 requests per hour per token
- Failed auth attempts: lockout after 5 failures within 300 seconds
