#!/usr/bin/env python3
"""Generated-only protocol, cohort commitment and calibration controls."""
import base64
import copy
import json
from pathlib import Path
import runpy
import unittest
import numpy as np

HERE=Path(__file__).parent
m=runpy.run_path(str(HERE/'phase95-root-surface-worker.py'))
t=runpy.run_path(str(HERE/'test-phase95-root-regional-motion.py'))


def encode(image):
    return base64.b64encode(image.tobytes()).decode()


def source_packet():
    image=t['image']()
    return {'schema':'phase95-root-surface-pixels-v1',
            'source_sha256':'707e9106e394421a00732b0efa2fbd2e1dc4dfee79d9244fcc763e2dbb106818',
            'contracts_sha256':'68d192c37821c4c059ac3763722bea491e5dd27850c2ab0a69ec5aa6246cd168',
            'width':256,'height':256,'roi':[20,20,236,236],'crop':[0,0,256,256],
            'eyes':[[2,2,10,10],[245,2,253,10]],'mesh_input':{},
            'images':{'source':encode(image)},'signals':{},'sampling':{}}


def source_points():
    points=[[.5,.5] for _ in range(478)]
    for chain,x in (((193,122,196),.30),((417,351,419),.70)):
        for index,y in zip(chain,(.28,.45,.65)):points[index]=[x,y]
    return points


def roundtrip(value):return json.loads(json.dumps(value))


def generated_packet():
    source=t['image']()
    pairs=np.array([((85.25,y+.2),(170.75,y+.2)) for y in range(72,185,16)])
    cases=[]
    for full in (512,1024):
        for strength in (0,.125,.25):
            amount=strength*.08
            output=t['warp'](source,compression=amount) if amount else source.copy()
            truth=pairs.copy();truth[:,:,0]=(truth[:,:,0]-127.5)*(1-amount)+127.5
            mean=float(np.mean((pairs[:,1,0]-pairs[:,0,0])-(truth[:,1,0]-truth[:,0,0])))*65536/full
            cases.append({'width':256,'height':256,'full_image_width':full,'crop':[0,0,256,256],
                          'strength':strength,'source':encode(source),'output':encode(output),
                          'pairs':pairs.tolist(),'truth':truth.tolist(),'truth_mean_contraction_q16':mean,
                          'truth_coordinate_tolerance':.001,'pixel_model_max_error':.5,
                          'extent_preserved':True,'alpha_preserved':True,'named_srgb':True,
                          'neutral_identity':strength==0})
    return {'schema':'phase95-root-surface-generated-v1','case_count':6,'cases':cases,
            'private_source_accessed':False,'measurement_admitted':False}


class SurfaceWorkerTests(unittest.TestCase):
    def setUp(self):
        self.source=source_packet()
        self.cohort=roundtrip(m['main']({'mode':'register','source':self.source,'points':source_points()}))

    def measure_packet(self,cohort=None):
        rendered=copy.deepcopy(self.source)
        for role in ('neutral','candidate','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25'):
            rendered['images'][role]=self.source['images']['source']
        rendered['sampling']={role:{'kind':'identity','source_roi_identity':True} for role in ('neutral','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25')}
        rendered['sampling']['candidate']={'kind':'canonical_horizontal','minimum_slope':.2,'maximum_slope':2.6,'maximum_displacement_pixels':8,'maximum_byte_error':0.}
        rendered['signals']={'targetChangedPixels':0,'targetAbsoluteRGBDelta':0,'outsideChangedPixels':0,
                             'outsideAbsoluteRGBDelta':0,'neutralIdentity':True,
                             'protectedRegions':[{'id':name,'changedPixels':0,'absoluteRGBDelta':0}
                                                 for name in ('bridge','tip','background','watermark')]}
        return {'mode':'measure','source':self.source,'rendered':rendered,'cohort':cohort or self.cohort}

    def testCohortCommitmentSurvivesSerializationAndIsReturnedWithoutRawPoints(self):
        result=m['main'](self.measure_packet())
        self.assertEqual(result['cohort_sha256'],self.cohort['cohort_commitment'])
        self.assertEqual(len(result['cohort_sha256']),64)
        self.assertFalse(result['root_candidate_pass'])
        self.assertIsInstance(result['pairs'],int)
        self.assertNotIn('images',result)
        self.assertNotIn('source_digest',result)

    def testMalformedIdsAndDriftedPairCommitmentReject(self):
        for kind in ('duplicate','order','range','bool','length','point','digest','commitment'):
            cohort=copy.deepcopy(self.cohort)
            if kind=='duplicate':cohort['ids'][1]=cohort['ids'][0]
            if kind=='order':cohort['ids'].reverse()
            if kind=='range':cohort['ids'][-1]=32
            if kind=='bool':cohort['ids'][0]=True
            if kind=='length':cohort['ids'].pop()
            if kind=='point':cohort['pairs'][0][0][0]+=.25
            if kind=='digest':cohort['source_digest']='0'*64
            if kind=='commitment':cohort['cohort_commitment']='0'*64
            with self.subTest(kind=kind),self.assertRaises(ValueError):
                m['main'](self.measure_packet(cohort))

    def testClosedEyeFootprintTouchIsNotRegistered(self):
        points=source_points();source=copy.deepcopy(self.source)
        pairs,ids=m['definition_points'](source,points)
        # At x=76.3, center minus 11 touches a closed eye right boundary.
        for chain in ((193,122,196),(417,351,419)):
            for index in chain:points[index][0]=(.5+76)/256 if chain[0]==193 else (.5+180)/256
        source['eyes']=[[30,0,65,255],[220,0,245,255]]
        with self.assertRaises(ValueError):m['definition_points'](source,points)
        self.assertGreaterEqual(len(pairs),4)

    def testGeneratedCalibrationUsesActualPointsAndSignedMeanTruth(self):
        result=m['main']({'mode':'calibrate','generated':generated_packet()})
        self.assertTrue(result['precision_pass'])
        self.assertEqual(result['measured_cases'],6)
        self.assertEqual(result['evaluated_points'],result['covered_points'])
        self.assertGreater(result['moving_truth_points'],0)
        self.assertEqual(result['moving_truth_points'],result['measured_moving_points'])
        self.assertFalse(result['private_source_accessed'])
        self.assertFalse(result['measurement_admitted'])
        for item in result['cases']:
            self.assertNotIn('pairs',item);self.assertNotIn('source',item);self.assertNotIn('truth',item)

    def testDuplicateSizeStrengthBadTruthAndAllIdentityCalibrationReject(self):
        for kind in ('duplicate','mean','all_identity','metadata','bytes','truth_shape','extra'):
            packet=generated_packet();case=packet['cases'][1]
            if kind=='duplicate':packet['cases'][1]=copy.deepcopy(packet['cases'][0])
            if kind=='mean':case['truth_mean_contraction_q16']+=1
            if kind=='all_identity':
                for item in packet['cases']:
                    item['truth']=copy.deepcopy(item['pairs']);item['truth_mean_contraction_q16']=0
                    item['output']=item['source']
            if kind=='metadata':case['named_srgb']=False
            if kind=='bytes':case['output']=case['output'][:-4]
            if kind=='truth_shape':case['truth'].pop()
            if kind=='extra':case['unbound']=True
            with self.subTest(kind=kind),self.assertRaises(ValueError):
                m['main']({'mode':'calibrate','generated':packet})

    def testMissingModesAndDuplicateJsonKeysReject(self):
        for value in ({},[],{'mode':'calibrate','generated':{},'extra':0}):
            with self.assertRaises(ValueError):m['main'](value)
        with self.assertRaises(ValueError):m['unique']([('a',1),('a',2)])


if __name__=='__main__':unittest.main()
