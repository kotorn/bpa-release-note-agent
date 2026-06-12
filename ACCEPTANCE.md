# Acceptance Checklist

- [ ] ReleaseChangeV1 JSON Schema uses JSON Schema Draft 2020-12.
- [ ] Validator CLI accepts valid payloads and rejects invalid payloads.
- [ ] Validator tests cover valid, malformed, missing-evidence, hash mismatch, duplicate batch, and duplicate registry inputs.
- [ ] SubmitBpaReleaseChange validates before POST and supports a configurable trigger URL.
- [ ] Pester tests use only a loopback mock and cover success, blocked invalid input, blocked missing evidence, HTTPS enforcement, and HTTP failure handling.
- [ ] Synthetic samples include a payload, User Note, and Developer Note with matching identifiers and hash.
- [ ] README contains setup instructions, Mermaid architecture, security guidance, and a five-minute demo script.
- [ ] OPEN_QUESTIONS.md records unresolved production decisions without inventing policy.
- [ ] Privacy scan rejects personal or tenant-specific data.
- [ ] Gitleaks scans the working tree and Git history with zero findings.
- [ ] GitHub Actions runs all checks on every push and pull request.
- [ ] `pwsh ./scripts/verify.ps1` exits 0.

