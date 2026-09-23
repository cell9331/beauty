#!/usr/bin/env python3
"""In-memory prototype: distributed root material compression from actual RGB.

This is not an anatomical boundary detector and never reads an image file. A
caller supplies source-anatomy row bounds. Source-only texture registration
owns the entire spatial cohort; every output must track every registered point.
PyrLK is a local image-correspondence estimator, not a certified global oracle.
The returned intervals are conditional empirical error envelopes, supported by
the generated validation suite, and are NOT automatic measurement admission.
"""
from dataclasses import dataclass
import math

import cv2
import numpy as np


REFERENCES = ('source', 'neutral', 'noseBridge_0p30', 'noseSlim_0p35', 'noseTipLift_0p25')
OUTPUTS = ('candidate',) + REFERENCES[1:]
LATERAL_BINS = 3
PATCH_RADIUS = 5
MIN_EIGENVALUE = 0.00001
# A conditional floor, in full-resolution pixels, not a confidence probability.
# FB and independent window agreement can only enlarge this floor.
ERROR_FLOOR = 0.20
MAX_FB_ERROR = 0.30
MAX_WINDOW_DISAGREEMENT = 0.35
MAX_PATCH_RMS = 14.0
MAX_MOTION = 32.0
PHOTOMETRIC_BYTE_RESIDUAL = 2.0


class Unavailable(ValueError):
    """Fixed reasons only; no pixels, point coordinates or locators."""


@dataclass(frozen=True)
class Cohort:
    shape: tuple
    points: tuple
    rows: tuple
    source_digest: str


def _image(value):
    if (not isinstance(value, np.ndarray) or value.dtype != np.uint8
            or value.ndim != 3 or value.shape[2] != 3
            or not 32 <= value.shape[0] <= 8192 or not 32 <= value.shape[1] <= 8192
            or value.size > 50_000_000 * 3):
        raise Unavailable('invalid_rgb')
    return np.ascontiguousarray(value)


def _digest(image):
    from hashlib import sha256
    return sha256(image.tobytes()).hexdigest()


def _gray(image):
    return cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)


def register_points(source, pairs):
    """Register caller's fixed source-semantic material pairs, without moving them.

    Pair coordinates are full-resolution canonical pixel-center indices, NOT
    normalized edge coordinates. Texture validation may reject the cohort but
    never shifts a semantic point onto a more convenient corner. A mesh caller
    must choose and validate its semantic paths independently of this module.
    """
    source = _image(source)
    h, w, _ = source.shape
    if not isinstance(pairs, (list, tuple, np.ndarray)) or not 4 <= len(pairs) <= 96:
        raise Unavailable('invalid_points')
    try:
        points = np.asarray(pairs, dtype=np.float64)
    except (TypeError, ValueError):
        raise Unavailable('invalid_points') from None
    if (points.ndim != 3 or points.shape[1:] != (2, 2)
            or not 4 <= len(points) <= 96 or not np.all(np.isfinite(points))
            or np.any(points[:, 0, 0] >= points[:, 1, 0])
            or np.any(points[:, :, 0] < PATCH_RADIUS + 2)
            or np.any(points[:, :, 0] >= w - PATCH_RADIUS - 2)
            or np.any(points[:, :, 1] < PATCH_RADIUS + 2)
            or np.any(points[:, :, 1] >= h - PATCH_RADIUS - 2)):
        raise Unavailable('invalid_points')
    raw = tuple(tuple(tuple(float(v) for v in p) for p in pair) for pair in points)
    if len(set(p for pair in raw for p in pair)) != len(points) * 2:
        raise Unavailable('invalid_points')
    eigen = cv2.cornerMinEigenVal(_gray(source), blockSize=7, ksize=3)
    for pair in points:
        for point in pair:
            quality = cv2.getRectSubPix(eigen, (1, 1), tuple(float(v) for v in point))[0, 0]
            if float(quality) < MIN_EIGENVALUE:
                raise Unavailable('source_texture_unavailable')
    # A fixed pair is a unit; rows here are bookkeeping, never an output filter.
    rows = tuple((float(pair[0, 1]), float(pair[1, 1])) for pair in points)
    return Cohort(tuple(source.shape), raw, rows, _digest(source))


def register(source, row_bounds):
    """Select one source texture point per side/bin in EVERY supplied row.

    Bounds are inclusive integer x positions for material centers:
    (y, left_min, left_max, right_min, right_max). They must be source-defined
    before seeing any output. No unsupported cell can silently disappear.
    """
    source = _image(source)
    h, w, _ = source.shape
    if (type(row_bounds) not in (tuple, list) or not 4 <= len(row_bounds) <= 32
            or any(type(r) not in (tuple, list) or len(r) != 5
                   or any(type(x) is not int for x in r) for r in row_bounds)):
        raise Unavailable('invalid_rows')
    if any(a[0] >= b[0] for a, b in zip(row_bounds, row_bounds[1:])):
        raise Unavailable('invalid_rows')
    gray = _gray(source)
    eigen = cv2.cornerMinEigenVal(gray, blockSize=7, ksize=3)
    points = []
    for y, l0, l1, r0, r1 in row_bounds:
        if (not PATCH_RADIUS + 2 <= y < h - PATCH_RADIUS - 2
                or not PATCH_RADIUS + 2 <= l0 < l1 < r0 < r1 < w - PATCH_RADIUS - 2
                or min(l1 - l0 + 1, r1 - r0 + 1) < LATERAL_BINS * 3):
            raise Unavailable('invalid_rows')
        sides = []
        for low, high in ((l0, l1), (r0, r1)):
            edges = np.linspace(low, high + 1, LATERAL_BINS + 1).astype(int)
            side = []
            for a, b in zip(edges, edges[1:]):
                # Deterministic source-only choice; ties use the leftmost x.
                x = int(a + np.argmax(eigen[y, a:b]))
                if float(eigen[y, x]) < MIN_EIGENVALUE:
                    raise Unavailable('source_texture_unavailable')
                side.append((float(x), float(y)))
            sides.append(side)
        # Left outer pairs with right outer; each side has equal spatial weight.
        points.extend(zip(sides[0], reversed(sides[1])))
    cohort = register_points(source, tuple(points))
    return Cohort(cohort.shape, cohort.points, tuple(tuple(r) for r in row_bounds), cohort.source_digest)


def _lk(a, b, points, window):
    tracked, status, _ = cv2.calcOpticalFlowPyrLK(
        a, b, points.reshape(-1, 1, 2).astype(np.float32), None,
        winSize=(window, window), maxLevel=3,
        criteria=(cv2.TERM_CRITERIA_EPS | cv2.TERM_CRITERIA_COUNT, 60, 0.001),
        flags=0, minEigThreshold=MIN_EIGENVALUE)
    if tracked is None or status is None or not np.all(status):
        raise Unavailable('correspondence_missing')
    tracked = tracked.reshape(-1, 2).astype(np.float64)
    if not np.all(np.isfinite(tracked)):
        raise Unavailable('correspondence_nonfinite')
    return tracked


def _patch(image, point):
    return cv2.getRectSubPix(image, (2 * PATCH_RADIUS + 1,) * 2,
                             tuple(float(v) for v in point)).astype(np.float64)


def _zero_motion_photometry(source_patch, output_patch):
    """Keep a same-position affine-photometry explanation, when feasible.

    Subpixel patch extraction rounds each image independently, so a bounded
    two-byte residual is allowed. This is a competing explanation, never a
    permission to subtract exposure then report the geometric fit alone.
    """
    for channel in range(3):
        a = source_patch[:, :, channel].reshape(-1)
        b = output_patch[:, :, channel].reshape(-1)
        epsilon = PHOTOMETRIC_BYTE_RESIDUAL
        # Existence, not best-fit selection: eliminate offset from EVERY pair
        # of inequalities b-e <= gain*a+offset <= b+e. The remaining interval
        # is the complete feasible gain set in [.5,2], with offset in [-32,32].
        da = a[:, None] - a[None, :]
        db = b[:, None] - b[None, :] - 2 * epsilon
        positive, negative, zero = da > 0, da < 0, da == 0
        if np.any(db[zero] > 0):
            return False
        low, high = 0.5, 2.0
        if np.any(positive): low = max(low, float(np.max(db[positive] / da[positive])))
        if np.any(negative): high = min(high, float(np.min(db[negative] / da[negative])))
        nonzero = a > 0
        if np.any(nonzero):
            low = max(low, float(np.max((b[nonzero] - epsilon - 32) / a[nonzero])))
            high = min(high, float(np.min((b[nonzero] + epsilon + 32) / a[nonzero])))
        if np.any((a == 0) & ((b - epsilon > 32) | (b + epsilon < -32))):
            return False
        if np.nextafter(low, -np.inf) > np.nextafter(high, np.inf):
            return False
    return True


def track(source, output, cohort):
    """Return ephemeral point estimates/errors; all fixed points are mandatory."""
    source, output = _image(source), _image(output)
    if (type(cohort) is not Cohort or tuple(source.shape) != cohort.shape
            or source.shape != output.shape or _digest(source) != cohort.source_digest):
        raise Unavailable('cohort_mismatch')
    try:
        raw = np.asarray(cohort.points, dtype=np.float64)
    except (TypeError, ValueError):
        raise Unavailable('cohort_mismatch') from None
    if (raw.ndim != 3 or raw.shape[1:] != (2, 2) or not 4 <= len(raw) <= 96
            or not np.all(np.isfinite(raw))):
        raise Unavailable('cohort_mismatch')
    points = raw.reshape(-1, 2)
    if np.array_equal(source, output):
        return points.copy(), np.zeros(len(points), dtype=np.float64)
    a, b = _gray(source), _gray(output)
    narrow = _lk(a, b, points, 15)
    broad = _lk(a, b, points, 21)
    back = _lk(b, a, narrow, 15)
    fb = np.linalg.norm(back - points, axis=1)
    disagreement = np.linalg.norm(narrow - broad, axis=1)
    movement = np.linalg.norm(narrow - points, axis=1)
    h, w, _ = source.shape
    if np.max(fb) > MAX_FB_ERROR:
        raise Unavailable('forward_backward_mismatch')
    if np.max(disagreement) > MAX_WINDOW_DISAGREEMENT:
        raise Unavailable('window_mismatch')
    if np.max(movement) > MAX_MOTION:
        raise Unavailable('motion_out_of_range')
    if (np.any(narrow[:, 0] < PATCH_RADIUS + 1) or np.any(narrow[:, 0] >= w - PATCH_RADIUS - 1)
            or np.any(narrow[:, 1] < PATCH_RADIUS + 1) or np.any(narrow[:, 1] >= h - PATCH_RADIUS - 1)):
        raise Unavailable('correspondence_out_of_bounds')
    zero_competitor = np.zeros(len(points), dtype=bool)
    for index, (original, moved) in enumerate(zip(points, narrow)):
        pa, pb = _patch(source, original), _patch(output, moved)
        zero_competitor[index] = _zero_motion_photometry(pa, _patch(output, original))
        # A constant per-channel exposure shift is irrelevant to material motion.
        # This check still rejects nonconstant photometry or local patch loss.
        difference = pa - pb
        difference -= difference.mean(axis=(0, 1), keepdims=True)
        if math.sqrt(float(np.mean(difference * difference))) > MAX_PATCH_RMS:
            raise Unavailable('patch_residual')
    error = np.maximum(ERROR_FLOOR, 2 * np.maximum(fb, disagreement))
    # A ramp may support an excellent, self-consistent WRONG flow under exposure.
    # The zero-motion competitor must remain inside the returned envelope.
    error = np.where(zero_competitor, np.maximum(error, movement), error)
    return narrow, error


def measure(source, cohort, outputs, full_image_width):
    """Signed equal-weight pair mean, then distance-to-zero for each sibling.

    No output-specific inliers, median selection, or point replacement. Width is
    the operational distributed material-span, NOT a physical outside boundary.
    Fixed spatial-cell evidence is returned to expose localized-only changes.
    """
    if type(outputs) is not dict or set(outputs) != set(OUTPUTS):
        raise Unavailable('missing_output_roles')
    source = _image(source)
    if type(full_image_width) is not int or not source.shape[1] <= full_image_width <= 8192:
        raise Unavailable('invalid_full_image_width')
    tracks = {'source': track(source, source, cohort)}
    for role in OUTPUTS:
        tracks[role] = track(source, outputs[role], cohort)
    candidate, ce = tracks['candidate']
    candidate_width = candidate[1::2, 0] - candidate[::2, 0]
    candidate_error = ce[1::2] + ce[::2]
    scale = 65536.0 / full_image_width
    intervals, cells = {}, {}
    for role in REFERENCES:
        positions, error = tracks[role]
        value = positions[1::2, 0] - positions[::2, 0] - candidate_width
        bound = error[1::2] + error[::2] + candidate_error
        lo, hi = float(np.mean(value - bound)), float(np.mean(value + bound))
        intervals[role] = (math.floor(lo * scale), math.ceil(hi * scale))
        # Positive support is diagnostic; never discard the other cells.
        cells[role] = int(np.sum(value - bound >= 16.0 / scale))
    sibling = min(max(0, intervals[r][0], -intervals[r][1]) for r in REFERENCES[2:])
    passing = min(intervals['source'][0], intervals['neutral'][0], sibling) >= 16
    return {'schema': 'phase95-regional-material-prototype-v1',
            'pair_count': len(cohort.points), 'row_count': len(cohort.rows),
            'intervals_q16': intervals, 'positive_pair_counts': cells,
            'threshold_pass': passing, 'measurement_admitted': False,
            'error_model': 'generated-calibrated-conditional-envelope'}
