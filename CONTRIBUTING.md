# Contributing

## Scope
This repository showcases Senior Cloud Engineer practices. Keep changes focused, secure, and reproducible.

## Commit Messages (Conventional Commits)
- feat, fix, docs, ci, refactor, test, chore, security
- Example: `feat(scripts): add VM network diagnostics CLI`

## Branching
- Use short branches: `feature/<topic>` or `fix/<topic>`.

## Scripts
- Bash: `set -euo pipefail`, long options, no secrets, pass ShellCheck.
- PowerShell: `Set-StrictMode -Version Latest`, `$ErrorActionPreference='Stop'`, no secrets.
- Provide inline comments explaining purpose and key flags.

## Security
- RBAC-first; avoid shared keys; prefer managed identities.
- No secrets in repo. Use Key Vault or local env for dev.
- Encrypt data in transit/at rest when possible.

## CI
- CI must be green. Add basic checks if you introduce new tooling.

## PR Checklist
- Problem statement and approach described.
- Tests or manual steps included.
- Security considerations acknowledged.
- Docs updated when applicable.
