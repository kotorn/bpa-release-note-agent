# SharePoint Mapping

This repository documents the sanitized target shape of the release register and
release notes library. It does not disclose tenant URLs, site names, or user
identities.

## Release Register Fields

| Concept | Field | Purpose |
|---|---|---|
| Release ID | `Title` | Primary synthetic release identifier |
| Change hash | `ChangeHash` | Idempotency and duplicate guard |
| Correlation ID | `CorrelationId` | End-to-end traceability |
| Component name | `SolutionName` | Human-readable component label |
| Environment | `Environment` | Target environment |
| Change summary | `ChangeSummary` | Short business-impact summary |
| Rollback plan | `RollbackPlan` | Recovery description |
| Ticket placeholder | `ServiceNowTicket` | Synthetic tracking value |
| UAT status | `UATStatus` | Passed or Pending |
| Status gate | `StatusGate` | Draft, Ready for Review, or Approved |
| Approval status | `ApprovalStatus` | Pending, Approved, or `N/A` |

## Notes Library Files

| File | Purpose |
|---|---|
| `announcement.md` | Business-facing release announcement |
| `tech-summary.md` | Developer-facing implementation summary |
| `README.md` | Correlation, status, and audit summary for the release |

## Status Rules

- `Ready for Review` means the release is validated and waiting on approval.
- `Approved` means the three Markdown files were published after approval.
- `Draft` means the change needs input, was rejected, or is otherwise not ready.

## Human Gate

Any list or library changes in the live tenant remain manual and approval-based.
This file only describes the intended mapping for the demo and submission
artifacts.
