#!/usr/bin/env python3
from fractions import Fraction as F
from pathlib import Path
import runpy
import unittest
import cv2
import numpy as np

m=runpy.run_path(str(Path(__file__).with_name('phase95-root-surface-horizontal.py')))


def source_image():
    rng=np.random.default_rng(71)
    return rng.integers(24,231,(96,256,3),dtype=np.uint8)


def render(source,compression=0,shift=0):
    # Scalar exact unrounded inverse sampling independent of OpenCV quantized maps.
    h,w,_=source.shape;xs=(np.arange(w)-127.5-shift)/(1-compression)+127.5
    xs=np.clip(xs,0,w-1);lo=np.floor(xs).astype(int);hi=np.minimum(lo+1,w-1);f=xs-lo
    return np.floor(source[:,lo,:]*(1-f[None,:,None])+source[:,hi,:]*f[None,:,None]+.5).astype(np.uint8)


class HorizontalSurfaceTests(unittest.TestCase):
    def setUp(self):
        self.source=source_image()
        self.pairs=tuple(((80.25,y),(175.75,y)) for y in (24,36,48,60))
        self.model=m['HorizontalModel'](F(1,5),F(13,5),8)

    def testExactIdentityAndIntegerRowRequirement(self):
        result=m['measure'](self.source,self.source,self.source,self.pairs,256,self.model)
        lo,hi=result['source_interval_q16']
        self.assertLessEqual(lo,0);self.assertGreaterEqual(hi,0)
        self.assertFalse(result['source_threshold_pass'])
        wrong=tuple(((a[0],a[1]+.2),(b[0],b[1]+.2)) for a,b in self.pairs)
        with self.assertRaisesRegex(m['Unavailable'],'integer_source_rows_required'):
            m['localize'](self.source,self.source,wrong,self.model)

    def testActualRgbIntervalsContainIndependentAffineMotion(self):
        for compression,shift in ((.03,0),(-.03,0),(0,1.2),(.01,-.7)):
            output=render(self.source,compression,shift)
            positions=m['localize'](self.source,output,self.pairs,self.model)
            for pair,bounds in zip(self.pairs,positions):
                for (x,y),(lo,hi,observed_y) in zip(pair,bounds):
                    truth=F(str((x-127.5)*(1-compression)+127.5+shift))
                    self.assertLessEqual(lo,truth);self.assertGreaterEqual(hi,truth)
                    self.assertEqual(observed_y,y)
            result=m['measure'](self.source,output,self.source,self.pairs,256,self.model)
            if compression>.02:self.assertTrue(result['source_threshold_pass'])
            if compression<=0:self.assertFalse(result['source_threshold_pass'])

    def testExposureRampRetainsZeroMotionAlternative(self):
        yy,xx=np.mgrid[:96,:256]
        a=np.rint(70+127.5-np.abs(xx-127.5)+20*np.sin(yy/5)).astype(np.uint8)
        source=np.repeat(a[:,:,None],3,axis=2);output=source-3
        try:result=m['measure'](source,output,source,self.pairs,256,self.model)
        except m['Unavailable']:return
        self.assertLessEqual(result['source_interval_q16'][0],0)
        self.assertFalse(result['source_threshold_pass'])

    def testUnrelatedPhotometryAndMissingCropContextReject(self):
        output=255-self.source
        with self.assertRaises(m['Unavailable']):m['localize'](self.source,output,self.pairs,self.model)
        pairs=tuple(((10.25,y),(245.25,y)) for y in (24,36,48,60))
        with self.assertRaisesRegex(m['Unavailable'],'insufficient_crop_context'):
            m['localize'](self.source,render(self.source,.01),pairs,self.model)

    def testAllAmbiguousSourceCellsRemainPossible(self):
        source=np.full_like(self.source,120);output=source.copy();output[1,1]=119
        try:positions=m['localize'](source,output,self.pairs,self.model)
        except m['Unavailable']:return
        for pair,bounds in zip(self.pairs,positions):
            for (x,_),(lo,hi,_) in zip(pair,bounds):
                self.assertLessEqual(lo,F(str(x))-7);self.assertGreaterEqual(hi,F(str(x))+7)

    def testEqualFlatPixelsCannotBecomeExactMaterialIdentity(self):
        source=np.full_like(self.source,120)
        try:positions=m['localize'](source,source.copy(),self.pairs,self.model)
        except m['Unavailable']:return
        for pair,bounds in zip(self.pairs,positions):
            for (x,_),(lo,hi,_) in zip(pair,bounds):
                self.assertLess(lo,F(str(x)));self.assertGreater(hi,F(str(x)))

    def testEqualPeriodicPixelsRetainNonzeroPlausibleMotion(self):
        source=np.empty_like(self.source)
        pattern=np.array(((40,80,120),(100,130,160),(180,210,90),(100,130,160)),dtype=np.uint8)
        source[:]=pattern[np.arange(source.shape[1])%4][None,:,:]
        try:positions=m['localize'](source,source.copy(),self.pairs,self.model)
        except m['Unavailable']:return
        for pair,bounds in zip(self.pairs,positions):
            for (x,_),(lo,hi,_) in zip(pair,bounds):
                self.assertLessEqual(lo,F(str(x))-4);self.assertGreaterEqual(hi,F(str(x))+4)

    def testNormalizedMarginUsesFullImageWidth(self):
        output=render(self.source,.03)
        a=m['measure'](self.source,output,self.source,self.pairs,256,self.model)
        b=m['measure'](self.source,output,self.source,self.pairs,4096,self.model)
        self.assertGreater(a['source_interval_q16'][0],b['source_interval_q16'][0])
        self.assertEqual(a['includes_siblings'],False)
        self.assertEqual(a['measurement_admitted'],False)

    def testTighteningRetainsEveryIndependentSecantMap(self):
        samples=tuple((F(x),F(2*x-2),F(2*x+3)) for x in range(12))
        tightened=m['_tighten'](samples,F(1,2),F(5,2))
        for x,lo,hi in tightened:self.assertLessEqual(lo,2*x);self.assertGreaterEqual(hi,2*x)

    def testRasterAliasesKeepWeightsWithoutPretendingIndependentError(self):
        original=m['register'](self.source,self.pairs)
        repeated=m['register'](self.source,self.pairs*2)
        self.assertEqual(len(repeated.points),8)
        self.assertEqual(original.source_digest,repeated.source_digest)
        output=render(self.source,.03)
        a=m['measure'](self.source,output,self.source,original.points,256,self.model)
        b=m['measure'](self.source,output,self.source,repeated.points,256,self.model)
        self.assertEqual(a['source_interval_q16'],b['source_interval_q16'])

    def testAllRolesRequireActualCompleteIdentityRegionAndCopiedSiblingFails(self):
        outputs={r:self.source.copy() for r in ('candidate',*m['REFERENCES'][1:])}
        outputs['candidate']=render(self.source,.03)
        models={r:'identity' for r in outputs};models['candidate']=self.model
        region=(60,16,200,72)
        result=m['measure_roles'](self.source,outputs,self.pairs,256,models,region)
        self.assertTrue(result['threshold_pass'])
        changed=outputs['noseBridge_0p30'].copy();changed[20,65,0]^=1
        outputs['noseBridge_0p30']=changed
        with self.assertRaisesRegex(m['Unavailable'],'identity_region_changed'):
            m['measure_roles'](self.source,outputs,self.pairs,256,models,region)
        outputs['noseBridge_0p30']=outputs['candidate'].copy();models['noseBridge_0p30']=self.model
        result=m['measure_roles'](self.source,outputs,self.pairs,256,models,region)
        self.assertFalse(result['threshold_pass'])

    def testNonlinearConeSamplingDoesNotRequireConstantOrAffinePatchMotion(self):
        def inverse(x,y):
            left=max(0,1-np.hypot(x-94.0,y-48.0)/16)
            right=max(0,1-np.hypot(x-161.0,y-48.0)/16)
            return x-10.5*left+10.5*right
        output=self.source.copy()
        for y in range(96):
            for x in range(256):
                q=inverse(x,y);lo=int(np.floor(q));hi=min(255,lo+1);weight=q-lo
                output[y,x]=np.floor(self.source[y,lo]*(1-weight)+self.source[y,hi]*weight+.5)
        model=m['HorizontalModel'](F(1,5),F(13,5),11)
        positions=m['localize'](self.source,output,self.pairs,model)
        moved=0
        for pair,bounds in zip(self.pairs,positions):
            for (x,y),(lo,hi,_) in zip(pair,bounds):
                a,b=0.0,255.0
                for _ in range(60):
                    mid=(a+b)/2
                    if inverse(mid,y)<x:a=mid
                    else:b=mid
                truth=(a+b)/2
                self.assertLessEqual(float(lo)-1e-9,truth)
                self.assertGreaterEqual(float(hi)+1e-9,truth)
                moved+=int(abs(truth-x)>1)
        self.assertGreater(moved,0)


if __name__=='__main__':unittest.main()
