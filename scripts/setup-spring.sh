#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <API_DOMAIN> <FRONTEND_ORIGIN> <KEYSTORE_PASSWORD>"
  echo "Example: $0 api.example.com https://frontend.example.com MyStrongPass"
  exit 1
fi

API_DOMAIN="$1"
FRONTEND_ORIGIN="$2"
KEYSTORE_PASSWORD="$3"
PROJECT_DIR="${HOME}/secure-application-design"
APP_DIR="${PROJECT_DIR}/spring-api"
KEYSTORE_PATH="${HOME}/keystore.p12"

if [[ "${API_DOMAIN}" == *.compute.amazonaws.com || "${API_DOMAIN}" == *.compute-1.amazonaws.com ]]; then
  echo "ERROR: Let's Encrypt cannot issue certificates for AWS EC2 public hostnames (${API_DOMAIN})."
  echo "Use a domain you control (for example api.yourdomain.com) and point its A record to this EC2 instance."
  exit 2
fi

sudo dnf update -y
sudo dnf install -y java-17-amazon-corretto-devel maven git certbot openssl

if [[ ! -d "${PROJECT_DIR}" ]]; then
  git clone https://github.com/AnderssonProgramming/secure-application-design.git "${PROJECT_DIR}"
fi

pushd "${APP_DIR}" > /dev/null
mvn clean package
popd > /dev/null

sudo systemctl stop secure-api || true
sudo certbot certonly --standalone -d "${API_DOMAIN}" --non-interactive --agree-tos -m "admin@${API_DOMAIN}"

openssl pkcs12 -export \
  -in "/etc/letsencrypt/live/${API_DOMAIN}/fullchain.pem" \
  -inkey "/etc/letsencrypt/live/${API_DOMAIN}/privkey.pem" \
  -out "${KEYSTORE_PATH}" \
  -name spring \
  -passout pass:"${KEYSTORE_PASSWORD}"

chmod 600 "${KEYSTORE_PATH}"

sudo tee /etc/systemd/system/secure-api.service > /dev/null <<EOF
[Unit]
Description=Secure Spring API
After=network.target

[Service]
User=ec2-user
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/java -jar target/secure-api-1.0.0.jar --spring.profiles.active=prod
Restart=always
RestartSec=5
Environment=SERVER_PORT=443
Environment=KEYSTORE_PATH=${KEYSTORE_PATH}
Environment=KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
Environment=KEYSTORE_ALIAS=spring
Environment=APP_CORS_ALLOWED_ORIGINS=${FRONTEND_ORIGIN}
Environment=APP_AUTH_TOKEN_TTL_HOURS=8

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable secure-api
sudo systemctl start secure-api

echo "Spring API ready on https://${API_DOMAIN}"
