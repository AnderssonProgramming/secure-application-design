# Secure Application Design

![Workshop](https://img.shields.io/badge/Enterprise-Architecture%20Workshop-0A66C2?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-TLS%20Everywhere-0E9F6E?style=for-the-badge)
![Deployment](https://img.shields.io/badge/Deployment-AWS%20EC2-FF9900?style=for-the-badge)

![Java](https://img.shields.io/badge/Java-17-red?logo=openjdk&logoColor=white)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.x-6DB33F?logo=springboot&logoColor=white)
![Apache](https://img.shields.io/badge/Apache-HTTPD-D22128?logo=apache&logoColor=white)
![Let's Encrypt](https://img.shields.io/badge/TLS-Let%27s%20Encrypt-003A70?logo=letsencrypt&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow)

## Secure by Design, Proven with Evidence

Welcome to my final secure full-stack delivery for the Enterprise Architecture workshop.

This project combines:

- 🔐 End-to-end HTTPS with Let's Encrypt
- 🧠 Secure authentication with BCrypt hashing
- 🧱 Split architecture with two isolated EC2 servers
- ⚡ Async frontend calls from Apache to Spring API
- ✅ Complete evidence pack (screenshots + video)

---

## Quick Navigation

1. [Project Snapshot](#project-snapshot)
2. [Architecture at a Glance](#architecture-at-a-glance)
3. [Evidence Gallery](#evidence-gallery)
4. [Video Walkthrough](#video-walkthrough)
5. [AWS Deployment Runbook](#aws-deployment-runbook)
6. [Security Controls](#security-controls)
7. [Validation Matrix](#validation-matrix)
8. [Rubric Coverage](#rubric-coverage)
9. [Repository Structure](#repository-structure)

---

## Project Snapshot

| Area | Delivery |
| --- | --- |
| Frontend | Apache serves async HTML/CSS/JS over HTTPS |
| Backend | Spring Boot secure API over HTTPS |
| Auth | Register/Login with BCrypt password verification |
| TLS | Certificates installed on both frontend and backend |
| Infra | 2 EC2 instances + least-privilege SG rules |
| Evidence | All required screenshots + final video |

---

## Architecture at a Glance

### Context Diagram

```mermaid
flowchart LR
    U[User Browser] -->|HTTPS 443| A[EC2 Apache Frontend]
    A -->|Static Client| U
    U -->|HTTPS 443 async fetch| S[EC2 Spring API]
    S -->|JSON| U
    S --> D[(Users DB)]

    classDef secure fill:#fff3e0,stroke:#ef6c00,stroke-width:2px,color:#5d4037;
    class A,S secure;
```

### Deployment Diagram

```mermaid
flowchart TB
    subgraph AWS[AWS VPC]
        AP[EC2 Apache\n80 443\nweb-sg]
        SP[EC2 Spring\n22 443\napi-sg]
    end

    DNS1[apache-ander.duckdns.org] --> AP
    DNS2[spring-ander.duckdns.org] --> SP
    Internet((Internet)) --> AP
    Internet --> SP
```

### Authentication Sequence

```mermaid
sequenceDiagram
    autonumber
    participant B as Browser
    participant A as Apache
    participant S as Spring API
    participant R as User Repository

    B->>A: GET index.html over TLS
    A-->>B: Client bundle
    B->>S: POST /api/auth/login
    S->>R: Find user by email
    R-->>S: User + BCrypt hash
    S->>S: BCrypt.matches(raw, hash)
    alt Valid credentials
        S-->>B: 200 + bearer token
    else Invalid credentials
        S-->>B: 401 Unauthorized
    end
```

---

## Evidence Gallery

All evidence files are in [images](images).

| # | Evidence | Description | File |
| --- | --- | --- | --- |
| 1 | EC2 Instances | Both frontend and backend servers running | [images/aws-01-ec2-list.png](images/aws-01-ec2-list.png) |
| 2 | Security Groups | Inbound rules correctly configured | [images/aws-02-security-groups.png](images/aws-02-security-groups.png) |
| 3 | DNS Records | DuckDNS records for both servers | [images/dns-01-records.png](images/dns-01-records.png) |
| 4 | Frontend HTTPS | Apache client loaded with TLS | [images/apache-02-frontend-https.png](images/apache-02-frontend-https.png) |
| 5 | API HTTPS Health | Public health endpoint over TLS | [images/spring-03-api-health-https.png](images/spring-03-api-health-https.png) |
| 6 | Certbot Apache | Certificate workflow on Apache server | [images/tls-01-certbot-apache.png](images/tls-01-certbot-apache.png) |
| 7 | Certbot Spring | Certificate workflow on Spring server | [images/tls-02-certbot-spring.png](images/tls-02-certbot-spring.png) |
| 8 | Register Success | User registration successful | [images/auth-02-register-success.png](images/auth-02-register-success.png) |
| 9 | Login Success | Authentication with valid credentials | [images/auth-02-login-success.png](images/auth-02-login-success.png) |
| 10 | Login Failure | Invalid credentials correctly rejected | [images/auth-03-login-failed.png](images/auth-03-login-failed.png) |
| 11 | BCrypt Proof | Password stored as BCrypt hash | [images/auth-04-db-password-hash.png](images/auth-04-db-password-hash.png) |
| 12 | Protected Endpoint | Access granted with valid token | [images/api-01-protected-with-token.png](images/api-01-protected-with-token.png) |
| 13 | Tests Passing | Maven test suite completed successfully | [images/ci-01-tests-passing.png](images/ci-01-tests-passing.png) |

### Visual Highlights

#### Frontend over TLS 🔒

![Frontend HTTPS](images/apache-02-frontend-https.png)

#### API Health over TLS 💚

![API HTTPS Health](images/spring-03-api-health-https.png)

#### Register/Login Flow 👤

![Register Success](images/auth-02-register-success.png)
![Login Success](images/auth-02-login-success.png)
![Login Failure](images/auth-03-login-failed.png)

#### Token-Protected Endpoint 🛡️

![Protected Endpoint](images/api-01-protected-with-token.png)

#### Test Execution ✅

![Tests Passing](images/ci-01-tests-passing.png)

---

## Video Walkthrough

The full demonstration video is included in the repository:

- 🎬 [secure-application-design.mp4](https://youtu.be/Y3e6ZtWets8)

Video flow:

1. Objective and architecture boundaries
2. AWS resources and security groups
3. Frontend over HTTPS
4. API over HTTPS
5. Register/Login success and failure
6. BCrypt evidence in storage
7. Protected endpoint behavior
8. Certbot dry-run and tests
9. Rubric mapping and close

---

## AWS Deployment Runbook

Detailed deployment instructions are available in:

- [AWS_DEPLOYMENT_GUIDE.md](AWS_DEPLOYMENT_GUIDE.md)

The runbook includes prerequisites, exact commands, TLS setup, renewal flow, and troubleshooting.

---

## Security Controls

| Control | Implementation |
| --- | --- |
| Data in transit | HTTPS/TLS on frontend and backend |
| Credential protection | BCrypt password hashing |
| Access control | Token-protected secure endpoints |
| Network hardening | Isolated SG rules per server role |
| Certificate lifecycle | Let's Encrypt + renewal script |
| Config hygiene | Environment-driven secure runtime config |

---

## Validation Matrix

| Test | Expected Result |
| --- | --- |
| GET frontend over HTTPS | 200 and valid certificate |
| GET /api/public/health | 200 and JSON status UP |
| POST /api/auth/register | 201 and token issued |
| POST /api/auth/login (valid) | 200 and token issued |
| POST /api/auth/login (invalid) | 401 Unauthorized |
| GET /api/secure/me with token | 200 and profile payload |
| GET /api/secure/me without token | 401 or 403 |
| certbot renew --dry-run | Success |
| mvn test | BUILD SUCCESS |

---

## Rubric Coverage

### Class Work

- ✅ Two-server AWS deployment completed
- ✅ Apache and Spring configured independently
- ✅ TLS for frontend and API communication
- ✅ Secure login with hashed password storage
- ✅ Let's Encrypt certificates active in both tiers
- ✅ Full repository delivery with proof artifacts

### Homework

- ✅ Architecture and secure design clearly documented
- ✅ Correct Apache-Spring-async client interaction
- ✅ Working secure implementation demonstrated
- ✅ Final assets include README, screenshots, and video

---

## Repository Structure

```text
secure-application-design/
├── README.md
├── AWS_DEPLOYMENT_GUIDE.md
├── secure-application-design.mp4
├── LICENSE
├── .gitignore
├── images/
│   ├── aws-01-ec2-list.png
│   ├── aws-02-security-groups.png
│   ├── dns-01-records.png
│   ├── apache-02-frontend-https.png
│   ├── spring-03-api-health-https.png
│   ├── tls-01-certbot-apache.png
│   ├── tls-02-certbot-spring.png
│   ├── auth-02-register-success.png
│   ├── auth-02-login-success.png
│   ├── auth-03-login-failed.png
│   ├── auth-04-db-password-hash.png
│   ├── api-01-protected-with-token.png
│   └── ci-01-tests-passing.png
├── apache-client/
├── spring-api/
└── scripts/
```

---

## Authors and Credits

- Student: Andersson David Sanchez Mendez
- Course: Enterprise Architectures / Secure Application Design
- Instructor: Luis Daniel Benavides Navarro
- Institution: Escuela Colombiana de Ingenieria Julio Garavito

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
