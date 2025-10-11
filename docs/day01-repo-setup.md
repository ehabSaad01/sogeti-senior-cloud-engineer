# Day 01 — Repository Setup and Structure

## Overview
This document explains the initial repository layout and the rationale behind each component. It also records the exact commands executed today and what they do.

## Structure
- infra/: Infrastructure as Code (Bicep/Terraform to be added later)
- scripts/: Azure CLI and PowerShell scripts with inline comments
- docs/: Technical notes, diagrams, runbooks
- .github/workflows/: GitHub Actions workflows for CI/CD
- README.md: Quick start and conventions
- SECURITY.md: Responsible disclosure and baseline hardening

## Rationale
- Clarity: predictable paths and clear separation of concerns.
- Security-by-default: RBAC-first, managed identities, encrypted data, private endpoints when feasible.
- Automation: CI checks prevent regressions and enforce minimum quality before merging.

## Commands Executed Today
1) Create local repo and directories
   - `git init` → initialize a Git repository by creating the .git folder.
   - `mkdir -p infra scripts docs .github/workflows` → create the core directory structure.

2) Add documentation and security policy
   - `cat > README.md << 'EOF' ... EOF` → write the README file content.
   - `cat > SECURITY.md << 'EOF' ... EOF` → write the security policy.
   - `git add README.md SECURITY.md` → stage files for commit.
   - `git commit -m "docs: add README ..."; git commit -m "security: add SECURITY policy"` → record snapshots in history.

3) CI workflow
   - `.github/workflows/ci.yml` → defines a workflow triggered on push and pull_request to main.
   - Steps:
     - Checkout repository
     - Verify structure (presence of README.md, SECURITY.md, and directories)
     - Optionally run ShellCheck on Bash scripts
   - `git add .github/workflows/ci.yml && git commit -m "ci: add basic GitHub Actions workflow"`

4) Track empty directories
   - `.gitkeep` placeholders inside infra/, scripts/, docs/ because Git does not track empty folders.
   - `git add infra/.gitkeep scripts/.gitkeep docs/.gitkeep && git commit -m "chore: track empty dirs"`

5) Remote and push
   - `git remote add origin <repo-url>` → define GitHub as the remote "origin".
   - `git push --set-upstream origin main` → publish main and establish upstream tracking.

6) Environment check script
   - `scripts/az-env-check.sh` → verifies Azure CLI installation, login status, and current subscription.
   - Executed with `./scripts/az-env-check.sh`.

## CI Notes
- The workflow name is "Repo CI".
- A passing run shows "Success" and confirms repo health.

## Next
- Add script templates (CLI and PowerShell) for Day 02.
- Introduce basic IaC scaffolding in infra/ when needed.
