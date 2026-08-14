# Legacy UI Archive Contract

This directory is the repository-owned historical boundary for the two legacy
application/UI trees. The archives preserve history; they are not active SDK
build inputs, UI requirements, or evidence that the SDK supports application
navigation and visual layout.

## Exact source scope

`scripts/archive-legacy-ui.py` accepts exactly these live source roots:

- `BeautyDemo/`: the former Xcode application project, SwiftUI application
  sources, and application tests.
- `meituxiuxiu/`: the legacy UI-reference maps, offline HTML reference, and all
  19 ignored PNG references (`IMG_0856.PNG` through `IMG_0870.PNG` plus
  `home/IMG_0871.PNG` through `home/IMG_0874.PNG`).

Inventory comes from an independent walk of the live filesystem, not
`git ls-files`, so intentionally ignored reference images remain in scope.
Every source symlink or non-regular filesystem entry is rejected.

The only excluded classes are:

- `.DS_Store` files;
- `.build` directories;
- cache directories named `.cache`, `cache`, `caches`, `Caches`, or
  `__pycache__`;
- `xcuserdata` directories; and
- files whose name ends in `.xcuserstate`.

Each source produces three retained artifacts: `<source>-v1.16.zip`,
`<source>-v1.16.manifest.tsv`, and `<source>-v1.16.zip.sha256`. ZIP entries are sorted,
file-only, rooted under the exact source name, timestamped `1980-01-01 00:00:00`,
and normalized to regular mode `0644`. The manifest records each archive path,
byte size, and content SHA-256 in sorted order.

The post-retirement verifier does not trust those three adjacent files to
authenticate one another. The tool independently pins each ZIP SHA-256,
manifest SHA-256, exact path inventory, file count, compressed size, total
uncompressed size, maximum entry size, and a `20:1` compression-ratio ceiling.
The canonical bounds are:

| Bundle | Files | ZIP bytes | Uncompressed bytes | Largest entry |
| --- | ---: | ---: | ---: | ---: |
| `BeautyDemo-v1.16` | 45 | 79,721 | 342,685 | 38,963 |
| `meituxiuxiu-v1.16` | 26 | 88,210,543 | 88,650,871 | 5,089,061 |

An empty manifest or any artifact, count, path, size, digest, metadata, CRC, or
resource-bound drift fails before extraction.

## Create and verify

Creation writes atomically and verifies source → manifest → ZIP agreement. A
dry run calculates the same inventory and digest without writing archives:

```bash
python3 scripts/archive-legacy-ui.py create --output archives/legacy-ui --dry-run
python3 scripts/archive-legacy-ui.py create --output archives/legacy-ui
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
python3 scripts/archive-legacy-ui.py reproduce --output archives/legacy-ui
```

`verify` checks the recorded ZIP SHA-256, CRC/integrity, safe paths, normalized
metadata, exact ZIP/manifest inventory, and extracted byte hashes in a temporary
directory. `reproduce` independently walks both live sources, rebuilds all six
artifacts in a temporary directory, and requires byte-for-byte agreement.
Neither creation nor verification removes a source tree.

The tool's destructive-path, tamper, extraction, determinism, and guarded
retirement tests run entirely in a temporary Git repository:

```bash
python3 scripts/archive-legacy-ui.py self-test
```

## Guarded retirement

Retirement is intentionally verbose. First obtain the two printed digests from
`verify` or the `-v1.16.zip.sha256` files. Then bind approval to both exact archives:

```bash
python3 scripts/archive-legacy-ui.py retire \
  --approve-digest BeautyDemo=<64-hex-sha256> \
  --approve-digest meituxiuxiu=<64-hex-sha256> \
  --yes-retire-exact-sources
```

Before moving either source, `retire` resolves the Git root, validates the two
exact non-symlink directories, rejects every pre-existing tracked deletion,
verifies both pinned archive snapshots, and compares both approved digests. It
precomputes the absolute tracked deletion allowlist and fingerprints SDK,
documentation, planning, and private-fixture sentinels. The two directories are
renamed into an outside-repository quarantine before their exact file-descriptor
inventories and deterministic ZIP digests are compared with the pinned bundles.
The absolute deletion set and sentinels are checked only against that frozen
snapshot, and only then is quarantine removed. A late untracked addition or any
other mismatch restores both roots rather than deleting the changed bytes.

Do not run retirement as part of archive creation or review. The phase plan that
owns original-source removal must record the fresh digest-bound gate separately.

## Restore historical material

First verify and restore through the archive tool into a nonexistent child of a
fresh, private temporary directory. The tool opens one pinned snapshot of every
artifact, validates all entries and resource bounds before creating the
destination, and uses its bounded safe writer. Do not invoke `unzip` or another
general extractor first.

```bash
python3 scripts/archive-legacy-ui.py verify --output archives/legacy-ui
restore_parent="$(mktemp -d "${TMPDIR:-/tmp}/beauty-legacy-ui-restore.XXXXXX")"
python3 scripts/archive-legacy-ui.py restore \
  --output archives/legacy-ui \
  --destination "${restore_parent}/legacy-ui"
```

The restored trees are historical review material. Reintroducing either tree to
the active repository violates the SDK-only boundary.
