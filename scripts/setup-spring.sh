#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "Usage: $0 <API_DOMAIN> <FRONTEND_ORIGIN> <KEYSTORE_PASSWORD>"
  echo "Example: $0 api.example.com https://frontend.example.com MyStrongPass"
  exit 1
fi

API_DOMAIN_RAW="$1"
FRONTEND_ORIGIN_RAW="$2"
KEYSTORE_PASSWORD="$3"

# Resolve project directory from this script location so sudo does not redirect to /root paths.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJECT_DIR="$(cd -- "${SCRIPT_DIR}/.." >/dev/null 2>&1 && pwd)"
APP_DIR="${PROJECT_DIR}/spring-api"
SERVICE_USER="ec2-user"
SERVICE_HOME="$(getent passwd "${SERVICE_USER}" | cut -d: -f6)"
if [[ -z "${SERVICE_HOME}" ]]; then
  SERVICE_HOME="/home/${SERVICE_USER}"
fi
KEYSTORE_PATH="${SERVICE_HOME}/keystore.p12"

# Normalize inputs so users can pass hostnames with or without scheme.
API_DOMAIN="${API_DOMAIN_RAW#http://}"
API_DOMAIN="${API_DOMAIN#https://}"
API_DOMAIN="${API_DOMAIN%%/*}"

FRONTEND_HOST="${FRONTEND_ORIGIN_RAW#http://}"
FRONTEND_HOST="${FRONTEND_HOST#https://}"
FRONTEND_HOST="${FRONTEND_HOST%%/*}"
FRONTEND_ORIGIN="https://${FRONTEND_HOST}"

if [[ "${API_DOMAIN}" == *.compute.amazonaws.com || "${API_DOMAIN}" == *.compute-1.amazonaws.com ]]; then
  echo "ERROR: Let's Encrypt cannot issue certificates for AWS EC2 public hostnames (${API_DOMAIN})."
  echo "Use a domain you control (for example api.yourdomain.com) and point its A record to this EC2 instance."
  exit 2
fi

sudo dnf update -y
sudo dnf install -y java-17-amazon-corretto-devel maven git certbot openssl libcap

# Keep Java binary free of file capabilities; systemd grants bind capability safely.
JAVA_BIN="$(readlink -f "$(command -v java)")"
if [[ -n "${JAVA_BIN}" && -f "${JAVA_BIN}" ]]; then
  sudo setcap -r "${JAVA_BIN}" || true
fi

if [[ ! -d "${APP_DIR}" ]]; then
  echo "ERROR: spring-api directory not found at ${APP_DIR}."
  echo "Run this script from inside the cloned repository."
  exit 3
fi

pushd "${APP_DIR}" > /dev/null
mvn clean package
popd > /dev/null

if systemctl list-unit-files secure-api.service --no-pager | grep -q "secure-api.service"; then
  sudo systemctl stop secure-api || true
fi
sudo certbot certonly --standalone -d "${API_DOMAIN}" --non-interactive --agree-tos -m "admin@${API_DOMAIN}"

sudo openssl pkcs12 -export \
  -in "/etc/letsencrypt/live/${API_DOMAIN}/fullchain.pem" \
  -inkey "/etc/letsencrypt/live/${API_DOMAIN}/privkey.pem" \
  -out "${KEYSTORE_PATH}" \
  -name spring \
  -passout pass:"${KEYSTORE_PASSWORD}"

sudo chown "${SERVICE_USER}:${SERVICE_USER}" "${KEYSTORE_PATH}"
sudo chmod 600 "${KEYSTORE_PATH}"

sudo tee /etc/systemd/system/secure-api.service > /dev/null <<EOF
[Unit]
Description=Secure Spring API
After=network.target

[Service]
User=${SERVICE_USER}
WorkingDirectory=${APP_DIR}
ExecStart=/usr/bin/java -jar target/secure-api-1.0.0.jar --spring.profiles.active=prod
Restart=always
RestartSec=5
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
NoNewPrivileges=true
Environment=SERVER_PORT=443
Environment=KEYSTORE_PATH=${KEYSTORE_PATH}
Environment=KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
Environment=KEYSTORE_ALIAS=spring
Environment=APP_CORS_ALLOWED_ORIGINS=${FRONTEND_ORIGIN}
Environment=APP_AUTH_TOKEN_TTL_HOURS=8

[Install]
WantedBy=multi-user.target
EOF

sudo chown -R ec2-user:ec2-user "${PROJECT_DIR}"

sudo systemctl daemon-reload
sudo systemctl enable secure-api
sudo systemctl start secure-api

echo "Spring API ready on https://${API_DOMAIN}"
