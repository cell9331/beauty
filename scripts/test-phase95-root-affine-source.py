#!/usr/bin/env python3
from fractions import Fraction as F
from pathlib import Path
import runpy
import unittest
m=runpy.run_path(str(Path(__file__).with_name('phase95-root-affine-source.py')))


def plane(left=F(24),right=F(72),width=F(8),amplitude=F(64),slope=F(1,8)):
    values=[]
    for x in range(96):
        shape=max(F(0),min(F(1),(F(x)-left)/width,(right-F(x))/width))
        value=F(80)+slope*x+amplitude*shape
        values.append(int(value*256+F(1,2)))
    return tuple(values)


class AffineSourceTests(unittest.TestCase):
    bounds=((0,48,96),)*16

    def test_slopes_polarities_phases_contain_independent_boundary(self):
        for slope in (F(-1,8),F(0),F(1,8)):
            for amplitude in (F(-48),F(64)):
                for phase in (F(0),F(1,4),F(1,2),F(3,4)):
                    for width in (F(4),F(8),F(16)):
                        left,right=24+phase,72+phase
                        layers,_=m['register']((plane(left,right,width=width,amplitude=amplitude,slope=slope),)*16,self.bounds)
                        self.assertTrue(all(any(a<=left<=b and c<=right<=d for a,b,c,d,sign in pairs) for _,pairs in layers))

    def test_single_affine_ramp_keeps_null(self):
        row=tuple(int((F(40)+F(x,3))*256) for x in range(96))
        self.assertTrue(m['side'](row[:48])['null'])
        self.assertEqual(m['diagnostic']((row,)*16,self.bounds)['status'],'metric_unavailable')

    def test_visible_outer_transition_not_replaced_by_stronger_internal(self):
        row=list(plane(amplitude=F(16),width=F(4)))
        for x in range(36,60):row[x]+=80*256
        try:
            layers,_=m['register']((tuple(row),)*16,self.bounds)
        except m['Unavailable'] as error:
            self.assertEqual(str(error),'affine_visible_coverage')
            return
        self.assertTrue(all(any(a<=24<=b and c<=72<=d for a,b,c,d,sign in pairs) for _,pairs in layers))
        self.assertTrue(all(b<36 and c>60 for _,pairs in layers for a,b,c,d,sign in pairs))

    def test_noise_and_missing_rows_do_not_create_credit(self):
        row=plane()
        noisy=tuple(v+(256 if i%2 else -256) for i,v in enumerate(row))
        result=m['diagnostic']((noisy,)*16,self.bounds)
        self.assertFalse(result['anatomical_boundary_qualified'])
        self.assertFalse(result['portrait_scoring_enabled'])
        blank=(80*256,)*96
        self.assertEqual(m['diagnostic']((row,)*11+(blank,)*5,self.bounds)['status'],'metric_unavailable')

    def test_invalid_carriers_reject(self):
        for value in ((),(True,)*96,(-1,)*96):
            self.assertEqual(m['diagnostic']((value,)*16,self.bounds)['status'],'metric_unavailable')

    def test_diagnostic_distinguishes_null_coverage_and_partial_scan(self):
        from unittest.mock import patch
        row=plane();blank=(80*256,)*96
        result=m['diagnostic']((row,)*11+(blank,)*5,self.bounds)
        self.assertEqual(result['scan']['processed_rows'],16)
        self.assertEqual(result['scan']['null_rows'],5)
        self.assertEqual(result['scan']['paired_candidate_rows'],11)
        self.assertTrue(result['scan']['scan_complete'])
        self.assertFalse(result['scan']['continuity_complete'])
        with patch.object(m['time'],'monotonic',side_effect=[0,121]):
            result=m['diagnostic']((row,)*16,self.bounds)
        self.assertEqual(result['reason'],'work_limit')
        self.assertFalse(result['scan']['scan_complete'])
        self.assertEqual(result['scan']['processed_rows'],0)
        positive=m['diagnostic']((row,)*16,self.bounds)
        self.assertTrue(positive['scan']['continuity_complete'])
        self.assertEqual(positive['scan']['paired_candidate_rows'],16)
        self.assertGreaterEqual(positive['scan']['candidate_nodes_after'],16)

if __name__=='__main__':unittest.main()
