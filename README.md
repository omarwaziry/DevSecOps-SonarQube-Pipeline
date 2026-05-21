# Automated DevSecOps Code Quality & Compliance Pipeline

This project provides a robust, cloud-native CI pipeline for code quality and compliance, leveraging AWS, Docker, SonarQube, and Terraform. It intercepts developer commits and runs automated security profiling before code leaves your workspace.

---

## 🚀 System Architecture & Data Flow

```text
  [ Developer Workspace ]                    [ AWS Cloud Platform (VPC Target) ]
 ┌──────────────────────┐                    ┌─────────────────────────────────┐
 │ Local Machine        │                    │ EC2 Instance Compute Engine     │
 │ (Python Application) │                    │ (t3.medium Platform Sandbox)    │
 └──────────┬───────────┘                    └────────────────┬────────────────┘
            │                                                 ▲
      (git commit)                                            │
            ▼                                                 │
 ┌──────────────────────┐                                     │
 │ .git/hooks/          │                                     │
 │ pre-commit script    │                                     │
 └──────────┬───────────┘                                     │
            │                                                 │
       (auto-spawn)                                           │
            ▼                                                 │
 ┌──────────────────────┐                                     │
 │ Ephemeral Container  │                                     │
 │ (sonar-scanner-cli)  │ ───[ SAST Telemetry Payload ]───────┘
 │ Volume Mount: $(pwd) │     Inbound Route: TCP Port 8080
 └──────────────────────┘
```

---

## ✨ Key Features

- **Infrastructure as Code (IaC):** Automated AWS sandbox provisioning with Terraform.
- **Shift-Left Security:** Git pre-commit hooks for static application security testing (SAST).
- **Containerized Scanning:** Ephemeral Docker containers (`sonarsource/sonar-scanner-cli`) for isolated, repeatable analysis.
- **Production-Grade Containerization:** Uses an advanced multi-stage build design pattern, compiling dependencies in a build stage and transferring them to a minimal python:3.11-slim runner image to reduce the attack surface.

- **Non-Root Runtime Enforcement:** Containers execute processes using a dedicated, non-privileged system user (USER 10001) to eliminate container breakout risks.
- **Least Privilege AWS IAM:** Secure, minimal-permission roles for compute resources.
- **Automated Health Checks:** Docker healthcheck and API endpoint for runtime validation.

---

## 🛠️ Project Structure

```
├── app/
│   ├── main.py              # Flask API for health  and data endpoint
│   └── requirements.txt     # Python dependencies
├── scripts/
│   └── pre-commit           # Git pre-commit hook script
├── terraform/
│   ├── main.tf              # AWS infrastructure (EC2, SG, IAM, etc.)
│   ├── variables.tf         # Terraform variables
│   └── providers.tf         # Terraform provider config
├── dockerfile               # Multi-stage Docker build for secure runtime
├── sq-token                 # SonarQube token (DO NOT COMMIT SENSITIVE TOKENS)
└── README.md                # Project documentation
```

---

## ⚡ Quickstart

### 1. Clone & Configure

```bash
git clone <this-repo-url>
cd DevSecOps-SonarQube-Pipeline
```

### 2. Set Up Pre-commit Hook

```bash
cp scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

### 3. Build & Run Locally (Docker)

```bash
docker build -t devsecops-app .
docker run -p 8080:8080 devsecops-app
```

### 4. Deploy AWS Infrastructure

```bash
cd terraform
terraform init
terraform apply
```

---

## 🔒 Security & Compliance

- All secrets (e.g., SonarQube tokens) must be managed via environment variables or secure vaults.
- The pre-commit hook blocks commits if critical issues are found by SonarQube.
- AWS resources are provisioned with least-privilege IAM roles and strict security groups.

---

## 📦 API Endpoints

| Method | Endpoint     | Description                |
|--------|-------------|----------------------------|
| GET    | `/`         | Health check/status        |
| POST   | `/api/data` | Accepts `{ "input": str }` |

---

## 📝 Notes

- Ensure Docker and Terraform are installed locally.
- The `sq-token` file should **never** be committed to version control.
- For SonarQube integration, set the `SONAR_HOST` and `sq-token` environment variables.

---

## 👤 Author

*OmarWazery*

---


