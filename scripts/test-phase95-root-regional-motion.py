#!/usr/bin/env python3
"""Generated truth for the in-memory regional material-motion prototype."""
import runpy
from pathlib import Path
import unittest
import cv2
import numpy as np

m = runpy.run_path(str(Path(__file__).with_name('phase95-root-regional-motion.py')))


def image(seed=42, size=256):
    rng = np.random.default_rng(seed)
    # Smooth, textured, non-clipped RGB. No real image or model output is used.
    noise = rng.integers(25, 230, (size, size, 3), dtype=np.uint8)
    return cv2.GaussianBlur(noise, (5, 5), 0.8)


def warp(source, compression=0.0, dx=0.0, dy=0.0):
    h, w, _ = source.shape
    # Exact independent forward truth: X'=(X-center)*(1-compression)+center+dx.
    matrix = np.array([[1 - compression, 0, compression * (w - 1) / 2 + dx],
                       [0, 1, dy]], dtype=np.float64)
    return cv2.warpAffine(source, matrix, (w, h), flags=cv2.INTER_LINEAR,
                          borderMode=cv2.BORDER_REFLECT_101)


class RegionalMotionTests(unittest.TestCase):
    def setUp(self):
        self.source = image()
        self.rows = tuple((y, 62, 110, 145, 193) for y in (80, 96, 112, 128, 144, 160, 176))
        self.cohort = m['register'](self.source, self.rows)

    def measure(self, candidate, siblings=None):
        outputs = {r: self.source.copy() for r in m['OUTPUTS']}
        outputs['candidate'] = candidate
        outputs.update(siblings or {})
        return m['measure'](self.source, self.cohort, outputs, 256)

    def testIdentityAndFixedCohort(self):
        self.assertEqual(self.cohort, m['register'](self.source, self.rows))
        result = self.measure(self.source)
        self.assertFalse(result['threshold_pass'])
        self.assertEqual(result['pair_count'], 21)
        self.assertEqual(result['intervals_q16']['source'], (0, 0))

    def testTrueDistributedContractionContainsIndependentTruth(self):
        for seed in (2, 7, 42):
            source = image(seed)
            cohort = m['register'](source, self.rows)
            points = np.array(cohort.points)
            for amount in (0.0075, 0.015, 0.025):
                outputs = {r: source.copy() for r in m['OUTPUTS']}
                outputs['candidate'] = warp(source, compression=amount)
                result = m['measure'](source, cohort, outputs, 256)
                truth = float(np.mean(points[:, 1, 0] - points[:, 0, 0])) * amount * 65536 / 256
                lo, hi = result['intervals_q16']['source']
                self.assertLessEqual(lo, truth)
                self.assertGreaterEqual(hi, truth)
                self.assertTrue(result['threshold_pass'])
                self.assertFalse(result['measurement_admitted'])

    def testTranslationAndExpansionCannotPass(self):
        for dx, dy in ((1.25, 0), (-1.25, 0.75), (0, -1.5)):
            result = self.measure(warp(self.source, dx=dx, dy=dy))
            lo, hi = result['intervals_q16']['source']
            self.assertLessEqual(lo, 0); self.assertGreaterEqual(hi, 0)
            self.assertFalse(result['threshold_pass'])
        self.assertFalse(self.measure(warp(self.source, compression=-0.015))['threshold_pass'])

    def testExposureCannotBecomeNarrowing(self):
        exposed = np.clip(self.source.astype(np.int16) + 12, 0, 255).astype(np.uint8)
        try:
            result = self.measure(exposed)
        except m['Unavailable']:
            return
        self.assertFalse(result['threshold_pass'])
        lo, hi = result['intervals_q16']['source']
        self.assertLessEqual(lo, 0); self.assertGreaterEqual(hi, 0)

    def testExposureOnOppositeRampsRetainsZeroMotionCompetitor(self):
        yy, xx = np.mgrid[:256, :256]
        value = np.rint(70 + (127.5 - np.abs(xx - 127.5)) + 20 * np.sin(yy / 5)).astype(np.uint8)
        source = np.repeat(value[:, :, None], 3, axis=2)
        pairs = tuple(((70.25, y + .2), (184.75, y + .2)) for y in range(70, 183, 16))
        cohort = m['register_points'](source, pairs)
        for gain, offset in ((1, -3), (1, 3), (.95, 2), (1.05, -5)):
            output = np.rint(source.astype(float) * gain + offset).clip(0, 255).astype(np.uint8)
            outputs = {r: source.copy() for r in m['OUTPUTS']}
            outputs['candidate'] = output
            try:
                result = m['measure'](source, cohort, outputs, 256)
            except m['Unavailable']:
                self.assertNotEqual((gain, offset), (1, -3), 'Original regression must exercise retained competitor')
                continue
            self.assertFalse(result['threshold_pass'])
            lo, hi = result['intervals_q16']['source']
            self.assertLessEqual(lo, 0); self.assertGreaterEqual(hi, 0)

    def testEverySiblingCopyFails(self):
        narrow = warp(self.source, compression=0.015)
        for role in m['REFERENCES'][2:]:
            result = self.measure(narrow, {role: narrow.copy()})
            self.assertFalse(result['threshold_pass'])
            lo, hi = result['intervals_q16'][role]
            self.assertLessEqual(lo, 0); self.assertGreaterEqual(hi, 0)

    def testMissingTextureOcclusionAndRolesFailWholeCohort(self):
        with self.assertRaises(m['Unavailable']):
            m['register'](np.full_like(self.source, 120), self.rows)
        damaged = self.source.copy(); damaged[60:100, 50:120] = 120
        with self.assertRaises(m['Unavailable']):
            self.measure(damaged)
        with self.assertRaises(m['Unavailable']):
            m['measure'](self.source, self.cohort, {'candidate': self.source}, 256)

    def testSmallCentralTextureEditDoesNotReplaceSpatialCohort(self):
        narrow = warp(self.source, compression=0.025)
        local = self.source.copy()
        # Interior stripe avoids most registered spatial cells. It is not a
        # distributed material-span contraction and cannot replace the cohort.
        local[110:135, 115:141] = narrow[110:135, 115:141]
        try:
            result = self.measure(local)
        except m['Unavailable']:
            return
        self.assertFalse(result['threshold_pass'])
        self.assertEqual(result['pair_count'], 21)

    def testChangedSourceAndMalformedRowsFail(self):
        changed = self.source.copy(); changed[0, 0, 0] ^= 1
        with self.assertRaises(m['Unavailable']):
            m['track'](changed, changed, self.cohort)
        for rows in (self.rows[::-1], self.rows[:3], ((True, 62, 110, 145, 193),) * 4):
            with self.assertRaises(m['Unavailable']): m['register'](self.source, rows)

    def testFixedSemanticPointsAreNotMovedToTextureCorners(self):
        pairs = tuple(((85.25, y + .2), (170.75, y + .2)) for y in range(72, 185, 16))
        cohort = m['register_points'](self.source, pairs)
        self.assertEqual(cohort.points, pairs)
        for invalid in (pairs[:3], pairs + (pairs[0],),
                        tuple(((170.75, y), (85.25, y)) for y in range(72, 185, 16))):
            with self.assertRaises(m['Unavailable']):
                m['register_points'](self.source, invalid)
        # One-dimensional texture has no two-dimensional material localization.
        aperture = np.broadcast_to(np.arange(256, dtype=np.uint8)[None, :, None],
                                   (256, 256, 3)).copy()
        with self.assertRaises(m['Unavailable']):
            m['register_points'](aperture, pairs)

    def testPointEnvelopesContainIndependentFractionalTwoDimensionalTruth(self):
        pairs = tuple(((85.25, y + .2), (170.75, y + .2)) for y in range(72, 185, 16))
        for seed in range(12):
            source = image(seed)
            cohort = m['register_points'](source, pairs)
            original = np.array(pairs).reshape(-1, 2)
            for amount, dx, dy in ((.025, 0, 0), (.01, .3, .7),
                                  (-.015, -1.4, 1.2), (0, 1.25, -.75)):
                output = warp(source, compression=amount, dx=dx, dy=dy)
                tracked, error = m['track'](source, output, cohort)
                truth = original.copy()
                truth[:, 0] = (original[:, 0] - 127.5) * (1 - amount) + 127.5 + dx
                truth[:, 1] += dy
                self.assertTrue(np.all(np.abs(tracked - truth) <= error[:, None]))

    def testOppositeRegionalChangesCancelBeforeSiblingDistance(self):
        # Equal-width semantic pairs above and below a symmetry line. The
        # sibling's true signed average is zero although each row moves.
        pairs = tuple(((85.25, float(y)), (170.75, float(y)))
                      for y in (64, 80, 96, 112, 143, 159, 175, 191))
        cohort = m['register_points'](self.source, pairs)
        yy, xx = np.mgrid[:256, :256].astype(np.float32)
        compression = 0.025 * np.tanh((yy - 127.5) / 25)
        mapx = (xx - 127.5) / (1 - compression) + 127.5
        sibling = cv2.remap(self.source, mapx, yy, cv2.INTER_LINEAR,
                            borderMode=cv2.BORDER_REFLECT_101)
        outputs = {r: self.source.copy() for r in m['OUTPUTS']}
        outputs['noseBridge_0p30'] = sibling
        result = m['measure'](self.source, cohort, outputs, 256)
        lo, hi = result['intervals_q16']['noseBridge_0p30']
        self.assertLessEqual(lo, 0); self.assertGreaterEqual(hi, 0)
        self.assertFalse(result['threshold_pass'])

    def testFullImageWidthOwnsQ16NormalizationEvenForSameCrop(self):
        outputs = {r: self.source.copy() for r in m['OUTPUTS']}
        outputs['candidate'] = warp(self.source, compression=.01)
        a = m['measure'](self.source, self.cohort, outputs, 1024)
        b = m['measure'](self.source, self.cohort, outputs, 4096)
        self.assertTrue(a['threshold_pass'])
        self.assertFalse(b['threshold_pass'])
        self.assertGreater(a['intervals_q16']['source'][0], b['intervals_q16']['source'][0])
        for invalid in (255, 8193, True, 256.0):
            with self.assertRaises(m['Unavailable']):
                m['measure'](self.source, self.cohort, outputs, invalid)

    def testLowContrastBlurCalibrationDoesNotUnderstateAcceptedErrors(self):
        pairs = tuple(((85.25, y + .2), (170.75, y + .2)) for y in range(72, 185, 16))
        accepted = rejected = 0
        for blur in (0, 1, 2, 3):
            for contrast in (1, .5, .25, .1):
                for seed in range(8):
                    source = image(seed)
                    if blur: source = cv2.GaussianBlur(source, (0, 0), blur)
                    source = np.rint(128 + (source.astype(float) - 128) * contrast).astype(np.uint8)
                    try:
                        cohort = m['register_points'](source, pairs)
                        output = warp(source, compression=.025, dx=.3, dy=.7)
                        tracked, error = m['track'](source, output, cohort)
                    except m['Unavailable']:
                        rejected += 1
                        continue
                    truth = np.array(pairs).reshape(-1, 2)
                    truth[:, 0] = (truth[:, 0] - 127.5) * .975 + 127.5 + .3
                    truth[:, 1] += .7
                    self.assertTrue(np.all(np.abs(tracked - truth) <= error[:, None]))
                    accepted += 1
        self.assertGreater(accepted, 0)
        self.assertGreater(rejected, 0)


if __name__ == '__main__':
    unittest.main()
