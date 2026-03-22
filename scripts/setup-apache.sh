#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <FRONTEND_DOMAIN> <API_ORIGIN>"
  echo "Example: $0 frontend.example.com https://api.example.com"
  exit 1
fi

FRONTEND_DOMAIN_RAW="$1"
API_ORIGIN_RAW="$2"
PROJECT_DIR="${HOME}/secure-application-design"
WEB_ROOT="/var/www/secure-app"

# Normalize inputs so users can paste values with or without scheme.
FRONTEND_DOMAIN="${FRONTEND_DOMAIN_RAW#http://}"
FRONTEND_DOMAIN="${FRONTEND_DOMAIN#https://}"
FRONTEND_DOMAIN="${FRONTEND_DOMAIN%%/*}"

API_HOST="${API_ORIGIN_RAW#http://}"
API_HOST="${API_HOST#https://}"
API_HOST="${API_HOST%%/*}"
API_ORIGIN="https://${API_HOST}"

if [[ "${FRONTEND_DOMAIN}" == *.compute.amazonaws.com || "${FRONTEND_DOMAIN}" == *.compute-1.amazonaws.com ]]; then
  echo "ERROR: Let's Encrypt cannot issue certificates for AWS EC2 public hostnames (${FRONTEND_DOMAIN})."
  echo "Use a domain you control (for example frontend.yourdomain.com) and point its A record to this EC2 instance."
  exit 2
fi

sudo dnf update -y
sudo dnf install -y httpd git certbot python3-certbot-apache

if [[ ! -d "${PROJECT_DIR}" ]]; then
  git clone https://github.com/AnderssonProgramming/secure-application-design.git "${PROJECT_DIR}"
fi

sudo mkdir -p "${WEB_ROOT}"
sudo cp -r "${PROJECT_DIR}/apache-client/." "${WEB_ROOT}/"
sudo sed -i "s|https://api.tudominio.com|${API_ORIGIN}|g" "${WEB_ROOT}/js/config.js"
sudo sed -i "s|https://api.example.com|${API_ORIGIN}|g" "${WEB_ROOT}/js/config.js"
sudo sed -i "s|http://api.example.com|${API_ORIGIN}|g" "${WEB_ROOT}/js/config.js"

sudo tee /etc/httpd/conf.d/secure-app.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName ${FRONTEND_DOMAIN}
    DocumentRoot ${WEB_ROOT}

    <Directory ${WEB_ROOT}>
        AllowOverride All
        Require all granted
    </Directory>

    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set Referrer-Policy no-referrer

    ErrorLog /var/log/httpd/secure-app-error.log
    CustomLog /var/log/httpd/secure-app-access.log combined
</VirtualHost>
EOF

sudo systemctl enable httpd
sudo systemctl restart httpd

sudo certbot --apache -d "${FRONTEND_DOMAIN}" --non-interactive --agree-tos -m "admin@${FRONTEND_DOMAIN}" --redirect

echo "Apache ready on https://${FRONTEND_DOMAIN}"
