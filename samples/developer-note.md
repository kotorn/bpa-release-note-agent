# Developer Release Note: Synthetic Order Approval

**Release ID:** `RN-SYNTH-0001`  
**Change hash:** `fe672a80ea16c69f2cda2fec74f3f5896cba26448e2eafd800976dcc1a134e1c`  
**Component:** `WF-SYNTH-ORDER-APPROVAL`  
**Environment:** `test`

## Technical change

The workflow now routes synthetic requests through two approval stages. The
change package contains normalized before and after snapshots plus a diff.

## Evidence

- `artifact://synthetic/workflow/before.json`
- `artifact://synthetic/workflow/after.json`
- `artifact://synthetic/workflow/change.diff`
- `artifact://synthetic/tests/routing-result.json`

## Verification

The approval routing test passed and confirmed both stages were reached.

## Risk

Medium. Routing behavior changes for every synthetic test request.

## Rollback

Restore the prior synthetic workflow snapshot and rerun the routing test.
Estimated recovery time: 15 minutes.
