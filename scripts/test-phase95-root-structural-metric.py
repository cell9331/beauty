#!/usr/bin/env python3
"""Independent analytic cohort truth and semantic rejection controls."""
import copy
from fractions import Fraction as F
from pathlib import Path
import runpy
import unittest

m=runpy.run_path(str(Path(__file__).with_name('phase95-root-structural-metric.py')))
f=runpy.run_path(str(Path(__file__).with_name('phase95-root-forward-span.py')))
measure=m['measure']; Rejected=m['Rejected']; ROLES=m['ROLES']

class MetricTests(unittest.TestCase):
    rows=tuple(range(12))
    def cohort(self,margin=32):
        return {role:{y:(F(56)-F(margin,128),)*2 if role=='candidate' else (F(56),)*2
                      for y in self.rows} for role in ROLES}

    def test_exact_signed_threshold(self):
        for value in (-32,0,15,16,17,20,32,1024):
            out=measure(512,self.rows,self.cohort(value))
            self.assertEqual(out['source_margin_q16'],value)
            self.assertEqual(out['structural_pass'],value>=16)

    def test_every_reference_required_and_copies_reject(self):
        for role in ROLES:
            c=self.cohort();del c[role]
            with self.assertRaises(Rejected):measure(512,self.rows,c)
        for role in ROLES:
            if role=='candidate':continue
            c=self.cohort();c[role]=copy.deepcopy(c['candidate'])
            self.assertFalse(measure(512,self.rows,c)['structural_pass'])

    def test_rows_cannot_be_selected_from_outputs(self):
        c=self.cohort();del c['candidate'][11]
        with self.assertRaises(Rejected):measure(512,self.rows,c)
        for rows in (tuple(range(3)),tuple(range(11)),tuple(range(11))+(10,),tuple(reversed(self.rows)),(False,)+self.rows[1:]):
            with self.assertRaises(Rejected):measure(512,rows,self.cohort())

    def test_uncertainty_retains_zero_motion(self):
        c=self.cohort()
        for y in self.rows:c['candidate'][y]=(F(55),F(56))
        self.assertFalse(measure(512,self.rows,c)['structural_pass'])
        self.assertEqual(measure(512,self.rows,c)['source_margin_q16'],0)

    def test_round_only_after_equal_weight_aggregation(self):
        c=self.cohort(0)
        # Alternating widths have margins15,17; exactly16 after cohort mean.
        for y in self.rows:c['candidate'][y]=(F(56)-F(15+2*(y%2),128),)*2
        self.assertEqual(measure(512,self.rows,c)['source_margin_q16'],16)
        # High-weight/proxy row selection would pass; full cohort must fail.
        for y in self.rows:c['candidate'][y]=(F(56)-F(32 if y==0 else 0,128),)*2
        self.assertFalse(measure(512,self.rows,c)['structural_pass'])

    def test_sibling_distance_remains_absolute(self):
        c=self.cohort(32)
        for y in self.rows:c[ROLES[3]][y]=(F(56)-F(64,128),)*2
        self.assertTrue(measure(512,self.rows,c)['structural_pass'])

    def test_forward_correspondence_across_registered_generated_rows(self):
        c=self.cohort()
        # Independent analytic affine source/output geometry, different for
        # every row. No production-provider field or private image is read.
        for y in self.rows:
            left=F(20)+F(y,32);right=left+56
            slope=F(224,223) # true forward width55.75 =>32Q16 at512px.
            samples=[(F(x),F(x)*slope,F(x)*slope) for x in range(100)]
            a=f['position']((left,left),samples,slope,slope)
            b=f['position']((right,right),samples,slope,slope)
            width=f['span'](a,b)
            self.assertEqual(width,(F(223,4),)*2)
            c['candidate'][y]=width
        self.assertEqual(measure(512,self.rows,c)['source_margin_q16'],32)
        self.assertTrue(measure(512,self.rows,c)['structural_pass'])

    def test_invalid_widths(self):
        for pair in ((F(0),F(0)),(F(58),F(57)),(F(56),F(513)),(56,56),(F(1,2**129),F(56))):
            c=self.cohort();c['candidate'][0]=pair
            with self.assertRaises(Rejected):measure(512,self.rows,c)

    def test_manifest_siblings_are_exact(self):
        import json
        manifest=json.loads(Path(__file__).with_name('face-feature-batch-manifest.json').read_text())
        def objects(v):
            if isinstance(v,dict):
                yield v
                for x in v.values():yield from objects(x)
            elif isinstance(v,list):
                for x in v:yield from objects(x)
        root=next(x for x in objects(manifest) if x.get('caseID')=='noseRootNarrowing_0p25')
        self.assertEqual(root['comparisonCaseIDs'],['source','geometryBaseline_noop',*ROLES[3:]])

class HypothesisTests(unittest.TestCase):
    rows = MetricTests.rows
    cohort = MetricTests.cohort
    def test_fixed_outer_structure_prevents_internal_motion_credit(self):
        # Independent latent widths: outer56 stays56, interior56 shrinks.
        # Ordering, stronger interior contrast or additional moving candidates
        # cannot remove the fixed outer explanation from the conjunction.
        fixed = self.cohort(0)
        moved = self.cohort(32)
        for candidates in ((fixed, moved), (moved, fixed), (moved, moved, fixed)):
            result = m['measure_hypotheses'](512, self.rows, candidates)
            self.assertFalse(result['structural_pass'])
            self.assertEqual(result['source_margin_q16'], 0)

    def test_all_interpretations_must_meet_threshold(self):
        for margin in (15, 16, 17):
            result = m['measure_hypotheses'](512, self.rows,
                (self.cohort(32), self.cohort(margin)))
            self.assertEqual(result['source_margin_q16'], margin)
            self.assertEqual(result['structural_pass'], margin >= 16)

    def test_one_missing_correspondence_cannot_be_dropped(self):
        invalid = self.cohort()
        del invalid['candidate'][0]
        with self.assertRaises(Rejected):
            m['measure_hypotheses'](512, self.rows, (self.cohort(), invalid))

    def test_one_copied_sibling_prevents_distinctness_credit(self):
        copied = self.cohort()
        copied[ROLES[3]] = copy.deepcopy(copied['candidate'])
        result = m['measure_hypotheses'](512, self.rows, (self.cohort(), copied))
        self.assertFalse(result['structural_pass'])
        self.assertEqual(result['sibling_margin_q16'], 0)

    def test_bounded_nonempty_hypothesis_inventory(self):
        for value in ((), [], (self.cohort(),) * 65):
            with self.assertRaises(Rejected):
                m['measure_hypotheses'](512, self.rows, value)

if __name__=='__main__':unittest.main()
