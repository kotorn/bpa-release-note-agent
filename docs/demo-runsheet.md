# Demo Run-Sheet

Hard limit: five minutes. Use only synthetic release identifiers and hide
notifications, browser profiles, tenant addresses, and user identities.

| Time | Screen | Narration |
|---|---|---|
| 0:00 | Problem and architecture | Release evidence, communication, and approval are usually fragmented. |
| 0:30 | `ReleaseChangeV1` schema | The contract requires before and after evidence, tests, impact, risk, rollback, and a canonical hash. |
| 1:05 | Validator success and hash failure | Invalid or modified evidence is blocked before a network request. |
| 1:40 | Submit the synthetic payload | The intake flow returns `202`, creates one review item, and uses the hash as its idempotency key. |
| 2:15 | Human approval and register | Approval is explicit; the register becomes Approved only after the decision. |
| 2:55 | Three Markdown files | Show the announcement, technical summary, and release README with the same release ID and hash. |
| 3:35 | Agent Q&A | Ask what changed and the rollback plan. Show the approved-note citation or the prepared fallback evidence. |
| 4:15 | Work IQ and governance | Show Work IQ actions, Needs Input, duplicate protection, and approved-only truth. |
| 4:40 | CI | Run `pwsh ./scripts/verify.ps1` and finish on the green workflow. |

## Recording Checklist

1. Record a backup take before polishing transitions.
2. Pre-stage the approved synthetic release and its three files.
3. Keep a Draft Needs Input item ready for the governance shot.
4. Prepare a broken payload under the operating system temporary directory.
5. Use a neutral terminal path and hide the clock and notifications.
6. If Work IQ retrieval is policy-blocked, show its configured actions and use
   the approved-note fallback.
7. If channel publication is blocked, use the Copilot Studio test canvas.
