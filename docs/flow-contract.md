# Flow Contract

The tenant implementation keeps the public `ReleaseChangeV1` contract intact.
Power Automate adapts the flat evidence-backed payload into the release drafting
and approval workflow.

## Processing Order

1. Receive a schema-compatible payload over an authenticated or signed request.
2. Read `metadata.correlationId`, or create a run correlation identifier.
3. Query the release register by `changeHash`.
4. Return the existing item when the hash is already registered.
5. Create a Draft item when the AI decision is `NeedsInput`.
6. Otherwise create a Ready for Review item and return HTTP `202`.
7. Wait for human approval after the caller has received the response.
8. Publish `announcement.md`, `tech-summary.md`, and `README.md` only after
   approval.
9. Return rejected items to Draft without publishing files.

## Response Semantics

| Code | Meaning |
|---:|---|
| `202` | Ready for Review or Needs Input |
| `200` | Duplicate hash; the existing item is reused |
| `400` | The request does not satisfy the trigger schema |
| `401` or `403` | The request is not authorized |
| `500` | Processing failed; production responses expose only correlation data |

## Duplicate Protection

The flow queries by `changeHash` before creation. The register also enforces a
unique, indexed `ChangeHash` field as the final concurrency guard.

The public validator remains the authoritative canonical hash implementation.
The PowerShell submitter runs it before any network request.
