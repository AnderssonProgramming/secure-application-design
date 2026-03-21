#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <API_DOMAIN> <KEYSTORE_PASSWORD> <KEYSTORE_PATH>"
  echo "Example: $0 api.example.com MyStrongPass /home/ec2-user/keystore.p12"
  exit 1
fi

API_DOMAIN="$1"
KEYSTORE_PASSWORD="$2"
KEYSTORE_PATH="$3"

sudo certbot renew --quiet

openssl pkcs12 -export \
  -in "/etc/letsencrypt/live/${API_DOMAIN}/fullchain.pem" \
  -inkey "/etc/letsencrypt/live/${API_DOMAIN}/privkey.pem" \
  -out "${KEYSTORE_PATH}" \
  -name spring \
  -passout pass:"${KEYSTORE_PASSWORD}"

chmod 600 "${KEYSTORE_PATH}"
sudo systemctl reload httpd || true
sudo systemctl restart secure-api || true

echo "Certificates renewed and services reloaded"
