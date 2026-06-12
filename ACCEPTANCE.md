# Acceptance Checklist

- [x] ReleaseChangeV1 JSON Schema uses JSON Schema Draft 2020-12.
- [x] Validator CLI accepts valid payloads and rejects invalid payloads.
- [x] Validator tests cover valid, malformed, missing-evidence, hash mismatch, duplicate batch, and duplicate registry inputs.
- [x] SubmitBpaReleaseChange validates before POST and supports a configurable trigger URL.
- [x] Pester tests use only a loopback mock and cover success, blocked invalid input, blocked missing evidence, HTTPS enforcement, and HTTP failure handling.
- [x] Synthetic samples include a payload, User Note, and Developer Note with matching identifiers and hash.
- [x] README contains setup instructions, Mermaid architecture, security guidance, and a five-minute demo script.
- [x] OPEN_QUESTIONS.md records unresolved production decisions without inventing policy.
- [x] Privacy scan rejects personal or tenant-specific data.
- [x] Gitleaks scans the working tree and Git history with zero findings.
- [x] GitHub Actions runs all checks on every push and pull request.
- [x] `pwsh ./scripts/verify.ps1` exits 0.
