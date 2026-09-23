#!/usr/bin/env python3
"""Independent latent step boundaries, not production geometry or a portrait."""
from pathlib import Path
import runpy
import unittest
m = runpy.run_path(str(Path(__file__).with_name('phase95-root-source-candidates.py')))


def stripe(left=24, right=72, background=40, interior=160):
    return tuple((interior if left <= x < right else background) * 256 for x in range(96))


class CandidateTests(unittest.TestCase):
    bounds = ((0, 48, 96),) * 16

    def test_independent_bright_dark_boundaries_included(self):
        for background, interior in ((40,160),(200,80)):
            result = m['hypotheses']((stripe(background=background,interior=interior),)*16,self.bounds)
            self.assertEqual(len(result),1)
            for row,left,right,sign in result[0]:
                self.assertEqual((left,right),(24,72))
                self.assertEqual(sign,1 if interior>background else -1)

    def test_stronger_internal_texture_does_not_take_outer_ownership(self):
        for contrast in (8,12,24):
            values=list(stripe(interior=40+contrast))
            for x in range(36,60):values[x]=220*256
            result=m['hypotheses']((tuple(values),)*16,self.bounds)
            self.assertEqual({(p[1],p[2]) for path in result for p in path},{(24,72)})

    def test_detectable_weak_outer_cannot_be_replaced_by_strong_inner(self):
        values=list(stripe(interior=46))
        for x in range(36,60):values[x]=220*256
        result=m['diagnostic']((tuple(values),)*16,self.bounds)
        self.assertEqual(result['status'],'metric_unavailable')

    def test_invisible_outer_exposes_model_limit_not_anatomical_approval(self):
        values=list(stripe(interior=42))
        for x in range(36,60):values[x]=220*256
        result=m['diagnostic']((tuple(values),)*16,self.bounds)
        # A below-noise outer boundary is not identifiable by this model.
        # Candidate existence is explicitly NEVER measurement admission.
        self.assertEqual(result['status'],'source_candidates')
        self.assertFalse(result['anatomical_boundary_qualified'])
        self.assertFalse(result['portrait_scoring_enabled'])

    def test_missing_rows_and_discontinuous_edges_abstain(self):
        blank=(40*256,)*96
        self.assertEqual(m['diagnostic']((stripe(),)*11+(blank,)*5,self.bounds)['status'],'metric_unavailable')
        self.assertEqual(m['diagnostic']((stripe(),stripe(left=32,right=64))*8,self.bounds)['status'],'metric_unavailable')

    def test_excluded_eye_side_cannot_supply_edge(self):
        self.assertEqual(m['diagnostic']((stripe(),)*16,((26,48,96),)*16)['status'],'metric_unavailable')

    def test_invalid_and_noninteger_carriers_reject(self):
        for p in ((),(True,)*96,(-1,)*96,(65536,)*96):
            self.assertEqual(m['diagnostic']((p,)*16,self.bounds)['status'],'metric_unavailable')

    def test_no_output_argument_or_effect_pass_in_diagnostic(self):
        result=m['diagnostic']((stripe(),)*16,self.bounds)
        self.assertEqual(set(result),{'status','hypotheses','registered_rows','anatomical_boundary_qualified','portrait_scoring_enabled'})

if __name__=='__main__':unittest.main()
