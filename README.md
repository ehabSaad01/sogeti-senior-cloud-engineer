[![Repo CI](https://github.com/ehabSaad01/azure-cloud-engineering-portfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/ehabSaad01/azure-cloud-engineering-portfolio/actions/workflows/ci.yml)

# Azure Cloud Engineering Portfolio

## Purpose
This repository demonstrates practical Azure Cloud Engineering skills with a focus on infrastructure, security, networking, automation, and resilient cloud architecture.

## Repository Structure

├─ infra/                 # Infrastructure as Code (Bicep/Terraform)
├─ scripts/               # Azure CLI and PowerShell scripts
├─ docs/                  # Technical notes and diagrams
└─ .github/workflows/     # GitHub Actions (CI/CD)

## Conventions

- Prefer least privilege and RBAC-first.
- Avoid shared keys when a managed identity or service principal fits.
- Use explicit, long CLI options for readability.
- Include pre-checks and post-validation where applicable.

## Getting Started

- `scripts/` contains runnable Azure CLI and PowerShell scripts with inline comments.
- `infra/` contains IaC definitions to provision and configure Azure resources.
- `docs/` contains technical explanations, diagrams, and runbooks.

## Security

See `SECURITY.md` for vulnerability disclosure and baseline hardening guidance.

## Project Documentation

- [Issues & Fixes](docs/day02/day02-issues-and-fixes.md)
