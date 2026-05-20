# Automated DevSecOps Code Quality & Compliance Pipeline

A robust continuous integration (CI) code-quality gate mechanism built on AWS infrastructure, designed to intercept developer commits and run automated security profiling natively before code leaves the workspace.
## System Architecture & Data Flow

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
## Key Features
* **Infrastructure as Code (IaC):** Automated provisioning of the underlying AWS sandbox environment.
* **Shift-Left Automation:** Custom Git pre-commit hooks to automate static application security testing (SAST).
* **Containerized Scanner Execution:** Using ephemeral Docker spaces (`sonarsource/sonar-scanner-cli`) to run analysis independent of host runtimes.

## How It Works
1. A developer stages changes and triggers `git commit`.
2. The local pre-commit hook captures execution flow and runs the `sonar-scanner-cli` container.
3. Code metrics and compliance gates are checked directly against the central SonarQube server.
4. If a severe bug, code smell, or credential leak is found, the hook returns a non-zero exit code, breaking the execution chain and blocking the commit.

## Local Configuration
To activate the automation hook locally on a fresh clone, link the tracked script configuration back to your active Git folder:
```bash
cp .githooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
