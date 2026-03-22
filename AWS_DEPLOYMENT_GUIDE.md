# AWS Deployment Guide

This guide is the operational runbook for deploying the lab in AWS and capturing the required evidence.

## Deployment Values (Current)

- Apache domain: ec2-54-82-9-48.compute-1.amazonaws.com
- Spring domain: ec2-34-233-121-121.compute-1.amazonaws.com
- Frontend origin: https://ec2-54-82-9-48.compute-1.amazonaws.com
- API origin: https://ec2-34-233-121-121.compute-1.amazonaws.com

Important:

- If Let's Encrypt fails for these `compute-1.amazonaws.com` hostnames (CAA/domain policy), use your own domain/subdomains and point them to the same EC2 instances.

## 1) Prerequisites

1. Two EC2 instances (Amazon Linux 2023):
   - Apache server (frontend)
   - Spring server (API)
2. Two DNS records:
   - frontend.yourdomain.com -> Apache public IP
   - api.yourdomain.com -> Spring public IP
3. Security groups:
   - Apache SG: 22 (admin IP), 80, 443
   - Spring SG: 22 (admin IP), 443, optional 80 for certbot standalone
4. SSH key pair with access to both instances.

## 2) Apache Server Setup

```bash
ssh -i your-key.pem ec2-user@<APACHE_IP>
git clone https://github.com/AnderssonProgramming/secure-application-design.git
cd secure-application-design
chmod +x scripts/setup-apache.sh
./scripts/setup-apache.sh frontend.yourdomain.com https://api.yourdomain.com
```

Exact command for your current domain:

```bash
./scripts/setup-apache.sh ec2-54-82-9-48.compute-1.amazonaws.com https://ec2-34-233-121-121.compute-1.amazonaws.com
```

Validation:

```bash
curl -I https://frontend.yourdomain.com
sudo systemctl status httpd
```

## 3) Spring Server Setup

```bash
ssh -i your-key.pem ec2-user@<SPRING_IP>
git clone https://github.com/AnderssonProgramming/secure-application-design.git
cd secure-application-design
chmod +x scripts/setup-spring.sh
./scripts/setup-spring.sh api.yourdomain.com https://frontend.yourdomain.com YOUR_KEYSTORE_PASSWORD
```

Exact command for your current domain:

```bash
./scripts/setup-spring.sh ec2-34-233-121-121.compute-1.amazonaws.com https://ec2-54-82-9-48.compute-1.amazonaws.com YOUR_KEYSTORE_PASSWORD
```

Validation:

```bash
curl -I https://api.yourdomain.com/api/public/health
sudo systemctl status secure-api
```

## 4) Certificate Renewal

```bash
chmod +x scripts/renew-certs.sh
./scripts/renew-certs.sh api.yourdomain.com YOUR_KEYSTORE_PASSWORD /home/ec2-user/keystore.p12
sudo certbot renew --dry-run
```

Exact renewal command for your current domain:

```bash
./scripts/renew-certs.sh ec2-34-233-121-121.compute-1.amazonaws.com YOUR_KEYSTORE_PASSWORD /home/ec2-user/keystore.p12
```

## 5) Functional Validation Flow

1. Open <https://ec2-54-82-9-48.compute-1.amazonaws.com>.
2. Register a user.
3. Login with the same user.
4. Call /api/secure/me from the UI.
5. Confirm unauthorized behavior without token.

## 6) Screenshot Checklist (execution order)

1. EC2 instances list
2. Security groups
3. DNS records
4. Apache service running
5. Frontend HTTPS in browser
6. Spring service running
7. API health endpoint HTTPS
8. Certbot output on Apache
9. Certbot output on Spring
10. PKCS12 conversion step
11. Login success
12. Login failure
13. BCrypt hash stored in DB
14. Protected endpoint with token
15. Protected endpoint without token
16. Test suite passing
