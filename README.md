![Repo CI](https://github.com/ehabSaad01/sogeti-senior-cloud-engineer/actions/workflows/ci.yml/badge.svg)

# Sogeti Senior Cloud Engineer — Portfolio

## Purpose
This repository demonstrates practical skills for a Senior Cloud Engineer role targeting Sogeti (Capgemini). It focuses on clarity, security-by-default, and reproducible execution.

## Repository Structure
.
├─ infra/                # Infrastructure as Code (Bicep/Terraform later)
├─ scripts/              # Azure CLI and PowerShell scripts
├─ docs/                 # Technical notes and diagrams
└─ .github/workflows/    # GitHub Actions (CI/CD)

## Conventions
- Prefer least privilege and RBAC-first.
- Avoid shared keys when a managed identity or service principal fits.
- Use explicit, long CLI options for readability.
- Include pre-checks and post-validation where applicable.

## Getting Started
- scripts/ will contain runnable Azure CLI and PowerShell with inline comments.
- infra/ will hold IaC definitions to provision and configure resources.
- docs/ will include technical explanations, diagrams, and runbooks.

## Security
A SECURITY.md file will describe vulnerability disclosure and baseline hardening.
