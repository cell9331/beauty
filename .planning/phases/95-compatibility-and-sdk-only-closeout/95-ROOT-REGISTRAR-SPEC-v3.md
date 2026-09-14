# Source-only registrar transport revision v3

Inherits the unchanged source, geometry, canonicalization, registration, privacy,
limits and authority contract of `95-ROOT-REGISTRAR-SPEC-v2.md`, pinned at SHA-256
`93d37da3b4a17c6b5e5087ee54744bb67c5c8dd1ea009704be0e54f1f28db8db`.
No mathematics, source fixture, ROI, thresholds, exclusion or Swift adapter
change. Original v2 spec, reviewer receipt and failed attempt remain unchanged.

## Confirmed failure and narrow correction

The independently approved v2 driver was actually run on the source. Its merged
stdout/stderr stream returned `child_invalid_output`. A separately admitted,
source-only diagnostic reproduced exit 2 with one native nonrecord line and one
schema-valid `ambiguous_structure` rejection. The diagnostic did not issue a
registration or score any candidate. Thus the protocol error concealed a REAL
measurement rejection; fixing transport cannot make that source measurable.

Revision v3 reads stdout and stderr independently through the same selector.
Only stdout is the strict single-JSON protocol channel. stderr is drained and
discarded, not printed, parsed for success, or persisted. The same 16 MiB limit
counts BOTH streams together; wall/monotonic timeout, stdin bound, owned-group
termination, writer join and exit-code validation remain. Extra stdout text is
still rejected, even when it contains a valid-looking JSON suffix. Native stderr
does not alter the meaning of a valid stdout rejection or success. A nonzero
exit cannot become success because JSON says otherwise.

The admission schema and receipt advance to `phase95-root-registrar-review-v3`
and `95-ROOT-REGISTRAR-REVIEW-v3.json`. The complete snapshot binds the original
v2 spec and this successor spec as well as the unchanged reviewed dependencies.
A v2 receipt cannot admit modified code. Only an independent reviewer may issue
the new passing source-only receipt. Source registration still stops on the
first failure and cannot create a two-attempt registration from diagnostics.

Generated transport regression must prove: valid JSON + stderr is delivered as
JSON, typed rejection + stderr stays rejected, extra stdout stays invalid,
combined/individual stream overflow rejects, and exit-code failure cannot be
hidden. No private native message content may enter evidence.

Current generated self-test passes 8 adapter, 22 admission and 7 transport
checks, including all three overflow modes (stdout, stderr, combined). Current
independent transport review is pending; no new source registration is admitted
by this document or by the obsolete v2 machine receipt.
