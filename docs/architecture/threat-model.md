# Basic Threat Model

## Assets

- User credentials
- Sessions/tokens
- TLS certificates
- Web client integrity

## Covered threats

- Traffic interception (MitM): mitigated with HTTPS/TLS.
- Password theft from repository/DB: mitigated with BCrypt and no plaintext storage.
- Unauthorized API access: mitigated with authentication and protected endpoints.
- Open CORS exposure: mitigated with explicit allowed origins.

## Recommended additional controls

- WAF or AWS Shield
- Login rate limiting
- Secret and certificate rotation
- Centralized logs and alerts
