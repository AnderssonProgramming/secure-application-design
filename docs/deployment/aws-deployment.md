# AWS Deployment Notes

This guide summarizes script-driven deployment:

1. On the Apache server:
   - Run scripts/setup-apache.sh <FRONTEND_DOMAIN> <API_ORIGIN>
2. On the Spring server:
   - Run scripts/setup-spring.sh <API_DOMAIN> <FRONTEND_ORIGIN> <KEYSTORE_PASSWORD>
3. Configure renewal:
   - scripts/renew-certs.sh <API_DOMAIN> <KEYSTORE_PASSWORD> <KEYSTORE_PATH>

Review README.md for DNS and Security Group prerequisites.
