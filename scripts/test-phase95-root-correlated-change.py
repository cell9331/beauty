#!/usr/bin/env python3
"""Analytic truth, nonlinear containment and unchanged-boundary controls."""
from fractions import Fraction as F
from pathlib import Path
import runpy
import unittest

m=runpy.run_path(str(Path(__file__).with_name('phase95-root-correlated-change.py')))
f=runpy.run_path(str(Path(__file__).with_name('phase95-root-forward-span.py')))
change=m['change']; width_change=m['width_change']; Rejected=m['Rejected']


def affine(a=F(1),b=F(0)):
    return tuple((F(x),a*x+b,a*x+b) for x in (0,50,100)),a,a


class Tests(unittest.TestCase):
    def test_shared_uncertainty_is_not_two_independent_positions(self):
        source=affine(); candidate=affine(F(224,223))
        left=(F(20),F(22)); right=(F(76),F(78))
        out=width_change(left,right,source,candidate)
        self.assertEqual(out,(F(54,224),F(58,224)))
        self.assertGreaterEqual(out[0]*128,16)
        old_source=f['span'](left,right)
        old_candidate=f['span'](f['position'](left,*candidate),f['position'](right,*candidate))
        self.assertLess(old_source[0]-old_candidate[1],0)

    def test_affine_exact_truth_for_uncertain_anchors(self):
        for a in (F(4,5),F(1),F(6,5)):
            for b in (F(-2),F(0),F(3)):
                for c in (F(3,4),F(1),F(5,4)):
                    for d in (F(-1),F(2)):
                        out=change((F(20),F(25)),affine(a,b),affine(c,d))
                        exact=[(s-b)/a-(s-d)/c for s in (F(20),F(25))]
                        self.assertEqual(out,(min(exact),max(exact)))

    def test_zero_expansion_and_translation_do_not_narrow(self):
        source=affine();left=(F(20),F(20));right=(F(76),F(76))
        for target in (source,affine(F(1),F(2)),affine(F(4,5))):
            self.assertLessEqual(width_change(left,right,source,target)[0],0)
        self.assertEqual(width_change(left,right,source,source),(F(0),F(0)))

    def test_exact_threshold_keeps_original_full_image_scale(self):
        for q16 in (-32,0,15,16,17,32):
            target_width=F(56)-F(q16,128)
            actual=width_change((F(20),)*2,(F(76),)*2,affine(),affine(F(56)/target_width))
            self.assertEqual(actual,(F(q16,128),)*2)
            self.assertEqual(actual[0]*F(65536,512)>=16,q16>=16)

    def test_fixed_outer_boundary_with_internal_contraction(self):
        samples=tuple((F(x),F(q),F(q)) for x,q in ((0,0),(20,20),(40,38),(60,62),(80,80),(100,100)))
        model=(samples,F(9,10),F(6,5))
        out=width_change((F(20),)*2,(F(80),)*2,affine(),model)
        self.assertEqual(out,(F(0),F(0)))
        self.assertGreater(width_change((F(38),)*2,(F(62),)*2,affine(),model)[0],0)

    def test_nonlinear_truth_is_contained(self):
        knots=((F(0),F(0)),(F(30),F(24)),(F(70),F(76)),(F(100),F(100)))
        model=(tuple((x,q,q) for x,q in knots),F(3,5),F(7,5))
        out=change((F(10),F(60)),affine(),model,8)
        for i in range(501):
            s=F(10)+F(i,10)
            a,b=next((a,b) for a,b in zip(knots,knots[1:]) if a[1]<=s<=b[1])
            x=a[0]+(s-a[1])*(b[0]-a[0])/(b[1]-a[1])
            self.assertLessEqual(out[0],s-x);self.assertGreaterEqual(out[1],s-x)

    def test_ambiguous_correspondence_cannot_become_exact_motion(self):
        samples=tuple((F(x),F(x)-1,F(x)+1) for x in (0,50,100))
        model=(samples,F(1),F(1))
        out=change((F(20),F(25)),affine(),model)
        self.assertLessEqual(out[0],-1);self.assertGreaterEqual(out[1],1)
        copied=width_change((F(20),)*2,(F(76),)*2,model,model)
        self.assertLessEqual(copied[0],0);self.assertGreaterEqual(copied[1],0)

    def test_input_and_correspondence_rejections(self):
        for anchor in ((F(3),F(2)),(F(0),F(65)),(0,F(1)),(F(1<<130),)*2):
            with self.assertRaises(Rejected):change(anchor,affine(),affine())
        for cells in (False,0,33):
            with self.assertRaises(Rejected):change((F(20),F(21)),affine(),affine(),cells)
        with self.assertRaises(Rejected):change((F(-3),F(-1)),affine(),affine())
        with self.assertRaises(Rejected):width_change((F(20),F(30)),(F(25),F(35)),affine(),affine())
        bad=(tuple((F(x),F(100-x),F(100-x)) for x in (0,50,100)),F(1),F(1))
        with self.assertRaises(Rejected):change((F(20),F(21)),affine(),bad)


class CohortTests(unittest.TestCase):
    rows=tuple(range(16))
    def cohort(self,margin=32):
        return {role:{row:(F(margin,128),)*2 for row in self.rows} for role in m['REFERENCES']}

    def test_threshold_and_copied_sibling(self):
        for margin in (-32,0,15,16,17,32):
            self.assertEqual(m['measure_changes'](512,self.rows,self.cohort(margin))['structural_pass'],margin>=16)
        for role in m['REFERENCES']:
            value=self.cohort();value[role]={row:(F(0),F(0)) for row in self.rows}
            self.assertFalse(m['measure_changes'](512,self.rows,value)['structural_pass'])

    def test_signed_sibling_cancellation_before_absolute_distance(self):
        value=self.cohort()
        for row in self.rows:value['noseBridge_0p30'][row]=(F(1 if row%2 else -1),)*2
        result=m['measure_changes'](512,self.rows,value)
        self.assertFalse(result['structural_pass']);self.assertEqual(result['sibling_margin_q16'],0)
        value['noseBridge_0p30']={row:(F(-1),)*2 for row in self.rows}
        self.assertTrue(m['measure_changes'](512,self.rows,value)['structural_pass'])

    def test_uncertainty_and_exact_row_inventory(self):
        value=self.cohort();value['source'][0]=(F(-10),F(10))
        self.assertFalse(m['measure_changes'](512,self.rows,value)['structural_pass'])
        for role in m['REFERENCES']:
            value=self.cohort();del value[role][0]
            with self.assertRaises(Rejected):m['measure_changes'](512,self.rows,value)
        for rows in (tuple(range(11)),tuple(reversed(self.rows)),(False,)+self.rows[1:]):
            with self.assertRaises(Rejected):m['measure_changes'](512,rows,self.cohort())

    def test_affine_shared_anchor_cohort_integration(self):
        delta=width_change((F(20),F(22)),(F(76),F(78)),affine(),affine(F(224,223)))
        value={role:{row:delta for row in self.rows} for role in m['REFERENCES']}
        result=m['measure_changes'](512,self.rows,value)
        self.assertTrue(result['structural_pass']);self.assertEqual(result['source_margin_q16'],30)


if __name__=='__main__':unittest.main()
