#!/usr/bin/env python3
from fractions import Fraction as F
from pathlib import Path
import runpy
import unittest
m=runpy.run_path(str(Path(__file__).with_name('phase95-root-sampler-correspondence.py')))


def texture(n):
    return tuple(tuple(32+((x*73+c*41+x*x*19)%192) for c in range(3)) for x in range(n))


def raster(source,q):
    j=q.numerator//q.denominator
    if j==len(source)-1:return source[j]
    t=q-j
    return tuple(int(F(source[j][c])*(1-t)+F(source[j+1][c])*t+F(1,2)) for c in range(3))


class SamplerTests(unittest.TestCase):
    def test_every_analytic_subpixel_truth_is_retained(self):
        source=texture(64)
        for tick in range(63*8+1):
            q=F(tick,8)
            pieces=m['inverse_intervals'](source,raster(source,q),0,63)
            self.assertTrue(any(lo<=q<=hi for lo,hi in pieces))

    def test_exact_noiseless_segments(self):
        source=((0,100,200),(100,200,0))
        self.assertEqual(m['inverse_intervals'](source,(25,125,150),0,1,F(0)),((F(1,4),F(1,4)),))

    def test_flat_and_repeated_ambiguity_is_retained(self):
        self.assertEqual(m['inverse_hull'](((40,40,40),)*32,(40,40,40),0,31),(F(0),F(31)))
        pieces=m['inverse_intervals'](((0,0,0),(100,100,100))*16,(50,50,50),0,31,F(0))
        self.assertEqual(len(pieces),31)
        self.assertEqual(m['inverse_hull'](((0,0,0),(100,100,100))*16,(50,50,50),0,31,F(0)),(F(1,2),F(61,2)))

    def test_quantization_error_bound_and_rgb_conjunction(self):
        source=((0,40,80),(100,140,180))
        self.assertEqual(m['inverse_hull'](source,(51,89,130),0,1),(F(1,2),F(1,2)))
        with self.assertRaises(m['Unavailable']):m['inverse_hull'](source,(51,80,130),0,1)

    def test_clipped_endpoints_are_included(self):
        source=((0,255,0),(255,0,255))
        for q in (F(0),F(1)):
            lo,hi=m['inverse_hull'](source,raster(source,q),0,1)
            self.assertLessEqual(lo,q);self.assertGreaterEqual(hi,q)

    def test_invalid_bools_bounds_and_noise_are_rejected(self):
        s=texture(32)
        for lo,hi,error in ((True,31,F(1)),(0,32,F(1)),(4,4,F(1)),(0,31,F(2)),(0,31,1)):
            with self.assertRaises(m['Unavailable']):m['inverse_hull'](s,s[4],lo,hi,error)
        with self.assertRaises(m['Unavailable']):m['inverse_hull'](((False,1,2),(3,4,5)),(1,2,3),0,1)

if __name__=='__main__':unittest.main()
