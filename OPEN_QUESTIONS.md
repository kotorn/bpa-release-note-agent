# Open Questions

These production decisions are intentionally unresolved. The public repository
uses synthetic data and a loopback mock, so none of these choices are required
to run the demo or verification suite.

1. **Production authentication:** Which managed identity, workload identity, or
   signed request mechanism will protect the HTTP trigger?
2. **Trigger response contract:** Which fields and error codes should the
   production automation return after accepting a release change?
3. **Persistent duplicate store:** Which durable service will own accepted
   change hashes across deployments and regions?
4. **Risk and approval policy:** Which change types and environments require
   additional reviewers or prohibit automatic publication?

