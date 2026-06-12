# Video Script

This script matches the backup demo video and stays under five minutes.

## Scene 1 - Problem Statement

Narrate the fragmentation of release evidence across workflows, forms,
SharePoint, and database changes.

## Scene 2 - Contract

Introduce `ReleaseChangeV1`, explain the required evidence fields, and call out
the canonical `changeHash`.

## Scene 3 - Validation

Show the validator rejecting malformed or duplicated payloads before any
network request.

## Scene 4 - Intake and Approval

Show the synthetic payload entering the flow, the duplicate guard, the Needs
Input branch, and the human approval path.

## Scene 5 - Published Notes

Show `announcement.md`, `tech-summary.md`, and `README.md` as the approved
release artifacts.

## Scene 6 - Agent Q&A

Ask what changed, who is affected, and what the rollback plan is. Point out the
citation from approved notes.

## Scene 7 - Microsoft IQ Evidence

Show the configured Work IQ actions or the prepared fallback evidence, then
state the fallback decision tree.

## Scene 8 - Public Repo and Close

Show the sanitized public repository, the verification gate, and the business
value summary.

## Recording Rule

The live demo should record only synthetic or sanitized content. If a screen is
waiting on policy, switch to the prepared fallback instead of improvising.
