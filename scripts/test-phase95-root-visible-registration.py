#!/usr/bin/env python3
from fractions import Fraction as F
from pathlib import Path
import runpy
import unittest

m = runpy.run_path(str(Path(__file__).with_name('phase95-root-visible-registration.py')))
change = runpy.run_path(str(Path(__file__).with_name('phase95-root-correlated-change.py')))


def generated(left=F(24), right=F(72), texture=False, curved_exterior=False):
    # Truth is declared by this independent shape generator, not the registrar.
    values = []
    for x in range(96):
        ridge = max(F(0), min(F(1), (x-left)/4, (right-x)/4))
        outside = F(max(0, 16-x, x-80)**2, 16) if curved_exterior else F(0)
        inside = F(70) if texture and 36 <= x < 60 else F(0)
        values.append(int((80 + F(x, 8) + 24*ridge + outside + inside)*256))
    return tuple(values)


class VisibleRegistrationTests(unittest.TestCase):
    def test_declared_truth_survives_subpixel_phases_and_curved_exterior(self):
        for phase in (F(0), F(1,4), F(1,2), F(3,4)):
            left, right = 24+phase, 72+phase
            pairs = m['row_candidates'](generated(left,right,curved_exterior=True),
                                        (0,48,96), ((22,26),(21,25)))
            self.assertTrue(any(a <= left <= b and c <= right <= d
                                for a,b,c,d,_ in pairs))

    def test_stronger_internal_texture_cannot_remove_outer_truth(self):
        pairs = m['row_candidates'](generated(texture=True), (0,48,96),
                                    ((22,26),(21,25)))
        self.assertTrue(any(a <= 24 <= b and c <= 72 <= d for a,b,c,d,_ in pairs))
        # A prior attracted to a discontinuous interior step may abstain. If
        # admitted, it still cannot discard the stationary outer interpretation.
        try:
            pairs = m['row_candidates'](generated(texture=True), (0,48,96),
                                        ((34,38),(34,38)))
        except m['Unavailable'] as error:
            self.assertEqual(str(error), 'prior_without_visible_support')
        else:
            self.assertTrue(any(a <= 24 <= b and c <= 72 <= d for a,b,c,d,_ in pairs))

    def test_flat_occluded_side_and_wrong_prediction_abstain(self):
        with self.assertRaises(m['Unavailable']):
            m['row_candidates']((80*256,)*96, (0,48,96), ((22,26),(21,25)))
        with self.assertRaises(m['Unavailable']):
            m['row_candidates'](generated(), (0,48,96), ((4,7),(4,7)))
        with self.assertRaises(m['Unavailable']):
            m['row_candidates'](generated()[:48]+(80*256,)*48,
                                (0,48,96), ((22,26),(21,25)))

    def test_fixed_outer_structure_cannot_pass_actual_change_reducer(self):
        pairs = m['row_candidates'](generated(texture=True), (0,48,96),
                                    ((22,26),(21,25)))
        identity = (tuple((F(x),F(x),F(x)) for x in (0,48,96)),F(1),F(1))
        knots = ((0,0),(24,24),(40,38),(56,58),(72,72),(96,96))
        moving_inside = (tuple((F(x),F(q),F(q)) for x,q in knots),F(7,8),F(5,4))
        intervals = [change['width_change']((a,b),(c,d),identity,moving_inside)
                     for a,b,c,d,_ in pairs]
        conservative = min(v[0] for v in intervals),max(v[1] for v in intervals)
        self.assertLessEqual(conservative[0],0)
        rows=tuple(range(16))
        cohort={role:{row:conservative for row in rows} for role in change['REFERENCES']}
        self.assertFalse(change['measure_changes'](512,rows,cohort)['structural_pass'])

    def test_asymmetric_lighting_preserves_mixed_polarity_outer_pair(self):
        left=tuple((180-5*max(x-20,0)+5*max(x-32,0))*256 for x in range(48))
        right=tuple((20+5*max(x-20,0)+5*max(x-32,0))*256 for x in range(48))
        pairs=m['row_candidates'](left+tuple(reversed(right)),(0,48,96),
                                  ((30,34),(30,34)))
        self.assertTrue(any(a<=20<=b and c<=75<=d and signs==(-1,1)
                            for a,b,c,d,signs in pairs))

    def test_visible_true_contraction_survives_registration_uncertainty(self):
        pairs = m['row_candidates'](generated(),(0,48,96),((22,26),(21,25)))
        identity=(tuple((F(x),F(x),F(x)) for x in (0,48,96)),F(1),F(1))
        scale=F(32,31)
        contraction=(tuple((F(x),scale*x,scale*x) for x in (0,48,96)),scale,scale)
        intervals=[change['width_change']((a,b),(c,d),identity,contraction)
                   for a,b,c,d,_ in pairs]
        conservative=min(v[0] for v in intervals),max(v[1] for v in intervals)
        rows=tuple(range(16))
        cohort={role:{row:conservative for row in rows} for role in change['REFERENCES']}
        self.assertTrue(change['measure_changes'](512,rows,cohort)['structural_pass'])

    def test_malformed_inputs_and_expired_work_budget_reject(self):
        for prior in ((True,24),(-1,24),(25,24),(0,100),(float('nan'),24),(0,F(1,1<<200))):
            with self.assertRaises(m['Unavailable']):
                m['supported_side'](generated()[:48], prior)
        for values in (None,[],(True,)*48,(-1,)*48,(),(256*256,)*48):
            with self.assertRaises(m['Unavailable']):
                m['supported_side'](values, (22,26))
        with self.assertRaises(m['Unavailable']):
            m['supported_side'](generated()[:48], (22,26), deadline=0)


if __name__ == '__main__':
    unittest.main()
