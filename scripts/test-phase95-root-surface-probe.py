"""Generated aggregate protocol mutations; contains no image payloads."""
import copy,runpy
from pathlib import Path
p=runpy.run_path(str(Path(__file__).with_name('phase95-root-surface-probe.py')))
roles=('source','neutral','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25')
v={'schema':'phase95-surface-observation-v1','source_sha256':'707e9106e394421a00732b0efa2fbd2e1dc4dfee79d9244fcc763e2dbb106818','contracts_sha256':'68d192c37821c4c059ac3763722bea491e5dd27850c2ab0a69ec5aa6246cd168','cohort_sha256':'1'*64,'pairs':31,'intervals_q16':{r:[16,20] for r in roles},'positive_pair_counts':{r:31 for r in roles},'targetChangedPixels':500,'targetAbsoluteRGBDelta':2000,'outsideChangedPixels':0,'outsideAbsoluteRGBDelta':0,'protectedRegions':[{'id':r,'changedPixels':0,'absoluteRGBDelta':0} for r in ('bridge','tip','background','watermark')],'neutralIdentity':True,'threshold_pass':True,'signal_protection_pass':True,'root_candidate_pass':True,'measurement_admitted':False,'milestone_acceptance':False}
if not p['clean_observation'](v)['root_candidate_pass']:raise ValueError('positive_control_rejected')
checks=1
for name in ('raw','bool_number','missing_sibling','cross_zero','negative','protected','source_drift','cohort','admitted','reversed'):
 a=copy.deepcopy(v)
 if name=='raw':a['pixels']=[1,2,3]
 if name=='bool_number':a['pairs']=True
 if name=='missing_sibling':a['intervals_q16'].pop(roles[-1])
 if name=='cross_zero':a['intervals_q16'][roles[-1]]=[-30,30]
 if name=='negative':a['intervals_q16']['source']=[-20,-16]
 if name=='protected':a['protectedRegions'][3]['changedPixels']=1
 if name=='source_drift':a['source_sha256']='0'*64
 if name=='cohort':a['cohort_sha256']='invalid'
 if name=='admitted':a['measurement_admitted']=True
 if name=='reversed':a['intervals_q16']['source']=[20,16]
 try:p['clean_observation'](a)
 except ValueError:checks+=1
 else:raise ValueError('accepted_mutation')
print({'protocol_checks':checks,'private_pixels':False})
