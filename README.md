# BPA Release Note Agent

A public, synthetic reference implementation for turning evidence-backed
application changes into a validated release-change event. It demonstrates the
contract and submission boundary used by a release-note agent without exposing
organization data or requiring access to a Microsoft tenant.

## What This Repository Contains

- `ReleaseChangeV1` JSON Schema using Draft 2020-12
- `bpa-release-validate` Python CLI with canonical hash and duplicate checks
- `Submit-BpaReleaseChange` PowerShell module
- Loopback-only HTTP trigger mock and offline tests
- Synthetic User Note and Developer Note examples
- Privacy, gitleaks, Python, and Pester verification gates

Note generation and tenant deployment are intentionally outside this public
acceptance scope. The schema and submission boundary are the reusable building
blocks demonstrated here.

## Architecture

```mermaid
flowchart LR
    A["UI or CLI change"] --> B["Evidence collector"]
    B --> C["ReleaseChangeV1 payload"]
    C --> D["Python validator"]
    D --> E["Submit-BpaReleaseChange"]
    E --> F["HTTP trigger"]
    F --> G["Copilot Studio release agent"]
    G --> H["Human approval"]
    H --> I["Release register and notes"]
    I --> J["Microsoft 365 Copilot with Work IQ"]
    K["Duplicate hash registry"] --> D
```

The public tests replace the HTTP trigger with a loopback mock. Production
authentication, approval policy, and storage choices remain explicit open
questions.

## Setup

Prerequisites:

- Python 3.12
- PowerShell 7.4 or later
- Go, winget, or another method to install gitleaks 8.30.1

Install pinned dependencies:

```powershell
pwsh ./scripts/bootstrap.ps1
```

Run every acceptance check:

```powershell
pwsh ./scripts/verify.ps1
```

## Validate A Payload

```powershell
bpa-release-validate ./samples/release-change-workflow.json
```

Multiple payload paths form a batch. Repeated hashes return exit code `3`.

```powershell
bpa-release-validate first.json second.json
bpa-release-validate --registry accepted-hashes.json payload.json
```

CLI exit codes:

| Code | Meaning |
|---:|---|
| `0` | Valid and not duplicated |
| `2` | Schema or canonical hash validation failed |
| `3` | Duplicate hash found in the batch or registry |
| `4` | File, JSON, schema, registry, or command usage error |

The canonical SHA-256 input excludes only top-level `releaseId`, `timestamp`,
and `changeHash`. All remaining fields are serialized as sorted, compact JSON.

## Submit A Payload

```powershell
Import-Module ./src/SubmitBpaReleaseChange/SubmitBpaReleaseChange.psd1

Submit-BpaReleaseChange `
  -PayloadPath ./samples/release-change-workflow.json `
  -TriggerUrl 'https://example.invalid/release-trigger'
```

The module validates before sending. Plain HTTP is accepted only for loopback
tests; all other destinations must use HTTPS. It never prints the trigger URL
or request headers.

## Security Model

- Every committed example is synthetic.
- Evidence uses `artifact://` references rather than internal URLs.
- The privacy scan rejects email addresses, canonical GUIDs, tenant domains,
  credential assignments, private keys, and absolute user paths.
- Gitleaks scans both the current directory and committed history.
- Public history must be created from this clean repository, never by
  sanitizing or rewriting a private repository.
- Runtime tests communicate only with `127.0.0.1`.

## Five-Minute Demo Script

**0:00-0:35 - Problem.** Explain that release communication is often assembled
manually and can omit evidence, impact, tests, or rollback information.

**0:35-1:20 - Contract.** Open `ReleaseChangeV1.schema.json` and highlight the
before/after evidence, test evidence, risk, rollback, and canonical hash.

**1:20-2:05 - Validation.** Run the validator against the synthetic sample,
then show an invalid copy returning exit code `2` and a duplicate batch
returning exit code `3`.

**2:05-3:00 - Submission.** Run the Pester success test. Show that the
PowerShell module validates first and posts only to the local trigger mock.

**3:00-3:45 - Communication.** Open the matching User Note and Developer Note,
pointing out their shared release ID and change hash.

**3:45-4:30 - Enterprise architecture.** Walk through the Mermaid diagram,
including Copilot Studio, approval, release storage, Microsoft 365 Copilot,
and Work IQ.

**4:30-5:00 - Reliability.** Run `verify.ps1`, show zero privacy or gitleaks
findings, and finish on the passing GitHub Actions workflow.

## Open Production Decisions

See [OPEN_QUESTIONS.md](OPEN_QUESTIONS.md). The repository does not invent
production authentication, trigger responses, durable storage, or approval
policy.

## License

MIT

