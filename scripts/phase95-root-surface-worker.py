#!/usr/bin/env python3
"""Internal bounded JSON pipe: in-memory surface registration and measurement."""
import base64, errno, hashlib, json, math, runpy, socket, sys
from fractions import Fraction as F
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]


def unique(pairs):
    value={}
    for k,v in pairs:
        if k in value:raise ValueError('duplicate')
        value[k]=v
    return value


def reject():raise ValueError('surface_worker')


def cohort_ids(ids,count):
    if (type(ids) is not list or len(ids)!=count or not 4<=count<=32
        or any(type(v) is not int or not 0<=v<=31 for v in ids)
        or ids!=sorted(set(ids))):reject()
    return ids


def commitment(source,cohort,ids):
    bound={key:source[key] for key in ('source_sha256','contracts_sha256','width','height','roi','crop','eyes')}
    bound.update({'schema':'phase95-surface-cohort-commitment-v1','pairs':cohort.points,
                  'ids':cohort_ids(ids,len(cohort.points)),'source_digest':cohort.source_digest})
    return hashlib.sha256(json.dumps(bound,sort_keys=True,separators=(',',':'),allow_nan=False).encode()).hexdigest()


def calibrate(value,module,horizontal=None):
    if type(value) is not dict or set(value)!={'schema','case_count','cases','private_source_accessed','measurement_admitted'}:reject()
    if (value['schema']!='phase95-root-surface-generated-v1' or value['case_count']!=6
        or type(value['case_count']) is not int or type(value['cases']) is not list or len(value['cases'])!=6
        or value['private_source_accessed'] is not False or value['measurement_admitted'] is not False):reject()
    import numpy as np
    expected={(size,strength) for size in (512,1024) for strength in (0,.125,.25)}
    seen=set();total=covered=evaluated=accepted=unavailable=mean_failures=moving=measured_moving=0
    maximum=maximum_truth=0.0;case_results=[]
    keys={'width','height','full_image_width','crop','strength','source','output','pairs','truth',
          'truth_mean_contraction_q16','truth_coordinate_tolerance','pixel_model_max_error',
          'extent_preserved','alpha_preserved','named_srgb','neutral_identity'}
    for case in value['cases']:
        if type(case) is not dict or set(case)!=keys:reject()
        width,height,full=case['width'],case['height'],case['full_image_width']
        strength=case['strength']
        if (any(type(v) is not int or not 32<=v<=1024 for v in (width,height,full))
            or type(strength) not in (int,float) or (full,strength) not in expected or (full,strength) in seen):reject()
        seen.add((full,strength));crop=case['crop']
        if (type(crop) is not list or len(crop)!=4 or any(type(v) is not int for v in crop)
            or not 0<=crop[0]<crop[2]<=full or not 0<=crop[1]<crop[3]<=full
            or crop[2]-crop[0]!=width or crop[3]-crop[1]!=height):reject()
        if any(case[k] is not True for k in ('extent_preserved','alpha_preserved','named_srgb')):reject()
        if case['neutral_identity'] is not (strength==0):reject()
        for k in ('truth_mean_contraction_q16','truth_coordinate_tolerance','pixel_model_max_error'):
            if type(case[k]) not in (int,float) or not math.isfinite(case[k]):reject()
        if not 0<=case['truth_coordinate_tolerance']<=.001 or not 0<=case['pixel_model_max_error']<=1:reject()
        images={}
        for role in ('source','output'):
            encoded=case[role]
            if type(encoded) is not str or len(encoded)>4*1048576:reject()
            raw=base64.b64decode(encoded,validate=True)
            if len(raw)!=width*height*3:reject()
            images[role]=np.frombuffer(raw,dtype=np.uint8).reshape(height,width,3).copy()
        if strength==0 and not np.array_equal(images['source'],images['output']):reject()
        if type(case['pairs']) is not list or not 4<=len(case['pairs'])<=96:reject()
        try:
            pairs=np.asarray(case['pairs'],dtype=float);truth=np.asarray(case['truth'],dtype=float)
        except (TypeError,ValueError):reject()
        if (pairs.shape!=(len(case['pairs']),2,2) or truth.shape!=pairs.shape
            or not np.all(np.isfinite(pairs)) or not np.all(np.isfinite(truth))):reject()
        declared=float(case['truth_mean_contraction_q16'])
        observed=float(np.mean((pairs[:,1,0]-pairs[:,0,0])-(truth[:,1,0]-truth[:,0,0])))*65536/full
        if abs(declared-observed)>1e-7:reject()
        truth_motion=np.max(np.abs(truth-pairs),axis=2).reshape(-1)
        moving_count=int(np.sum(truth_motion>.001))
        if (strength==0 and moving_count!=0) or (strength!=0 and moving_count==0):reject()
        moving+=moving_count;maximum_truth=max(maximum_truth,float(np.max(truth_motion)))
        total+=len(pairs)*2
        record={'full_image_width':full,'strength':float(strength),'point_count':len(pairs)*2,
                'moving_truth_points':moving_count,
                'status':'unavailable','covered_points':0,'maximum_error_millipixels':0,
                'mean_interval_contains_truth':False}
        try:
            if horizontal is None:
                cohort=module['register_points'](images['source'],case['pairs'])
                positions,errors=module['track'](images['source'],images['output'],cohort)
                delta=np.max(np.abs(positions-truth.reshape(-1,2)),axis=1)
                hits=int(np.sum(delta<=errors+case['truth_coordinate_tolerance']))
                outputs={role:images['source'] for role in module['OUTPUTS']};outputs['candidate']=images['output']
                measured=module['measure'](images['source'],cohort,outputs,full)
                lo,hi=measured['intervals_q16']['source']
            else:
                model=horizontal['HorizontalModel'](F(1,5),F(13,5),math.ceil(.032*full)+2)
                localized=horizontal['localize'](images['source'],images['output'],case['pairs'],model)
                flat=[point for pair in localized for point in pair]
                positions=np.array([[(float(p[0])+float(p[1]))/2,p[2]] for p in flat])
                delta=np.max(np.abs(positions-truth.reshape(-1,2)),axis=1)
                hits=int(sum(float(p[0])-case['truth_coordinate_tolerance']<=true[0]<=float(p[1])+case['truth_coordinate_tolerance'] and abs(p[2]-true[1])<=case['truth_coordinate_tolerance'] for p,true in zip(flat,truth.reshape(-1,2))))
                measured=horizontal['measure'](images['source'],images['output'],images['source'],case['pairs'],full,model)
                lo,hi=measured['source_interval_q16']
            mean_contains=lo<=declared<=hi
            covered+=hits;evaluated+=len(positions);accepted+=1;measured_moving+=moving_count
            maximum=max(maximum,float(np.max(delta)))
            mean_failures+=int(not mean_contains)
            record.update({'status':'measured','covered_points':hits,'maximum_error_millipixels':math.ceil(float(np.max(delta))*1000),
                           'mean_interval_contains_truth':bool(mean_contains)})
        except (module['Unavailable'],horizontal['Unavailable'] if horizontal else module['Unavailable']):
            unavailable+=1
        case_results.append(record)
    if seen!=expected:reject()
    return {'schema':'phase95-surface-calibration-v1','case_count':6,'total_points':total,
            'measured_cases':accepted,'unavailable_cases':unavailable,'evaluated_points':evaluated,'covered_points':covered,
            'moving_truth_points':moving,'measured_moving_points':measured_moving,
            'maximum_truth_motion_millipixels':math.ceil(maximum_truth*1000),
            'maximum_error_millipixels':math.ceil(maximum*1000),'mean_interval_failures':mean_failures,
            'precision_pass':accepted==6 and covered==evaluated and mean_failures==0 and moving>0 and measured_moving==moving,
            'cases':case_results,'private_source_accessed':False,'measurement_admitted':False}


def packet(value,render):
    if type(value) is not dict or set(value)!={'schema','source_sha256','contracts_sha256','width','height','roi','crop','eyes','mesh_input','images','signals','sampling'}:reject()
    if value['schema']!='phase95-root-surface-pixels-v1':reject()
    if value['source_sha256']!='707e9106e394421a00732b0efa2fbd2e1dc4dfee79d9244fcc763e2dbb106818' or value['contracts_sha256']!='68d192c37821c4c059ac3763722bea491e5dd27850c2ab0a69ec5aa6246cd168':reject()
    w,h=value['width'],value['height']
    if any(type(x) is not int or not 32<=x<=8192 for x in (w,h)):reject()
    for key in ('roi','crop'):
        b=value[key]
        if type(b) is not list or len(b)!=4 or any(type(x) is not int for x in b) or not 0<=b[0]<b[2]<=w or not 0<=b[1]<b[3]<=h:reject()
    roi,crop=value['roi'],value['crop']
    if not crop[0]<=roi[0]<roi[2]<=crop[2] or not crop[1]<=roi[1]<roi[3]<=crop[3]:reject()
    cw,ch=crop[2]-crop[0],crop[3]-crop[1]
    if cw*ch>1048576 or min(cw,ch)<32:reject()
    eyes=value['eyes']
    if type(eyes) is not list or len(eyes)!=2:reject()
    for b in eyes:
        if type(b) is not list or len(b)!=4 or any(type(x) is not int for x in b) or not 0<=b[0]<b[2]<=w or not 0<=b[1]<b[3]<=h:reject()
    expected={'source','neutral','candidate','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25'} if render else {'source'}
    if type(value['images']) is not dict or set(value['images'])!=expected:reject()
    import numpy as np
    result={}
    for key,encoded in value['images'].items():
        if type(encoded) is not str or len(encoded)>4*1048576:reject()
        raw=base64.b64decode(encoded,validate=True)
        if len(raw)!=cw*ch*3:reject()
        result[key]=np.frombuffer(raw,dtype=np.uint8).reshape(ch,cw,3).copy()
    return result


def definition_points(source,points):
    if type(points) is not list or len(points)!=478:reject()
    if any(type(p) is not list or len(p)!=2 or any(type(v) is not float or not math.isfinite(v) or not 0<=v<=1 for v in p) for p in points):reject()
    w,h=source['width'],source['height'];roi=source['roi'];crop=source['crop'];eyes=source['eyes']
    chains=((193,122,196),(417,351,419));result=[];ids=[]
    # Project-defined dorsal surface chains, not official bone/outer boundaries.
    # Sixteen midpoint parameters per topological segment, source-only clipping.
    for segment in range(2):
        for i in range(16):
            t=(i+.5)/16;pair=[]
            for chain in chains:
                a,b=points[chain[segment]],points[chain[segment+1]]
                ay,by=a[1]*h-.5,b[1]*h-.5
                if abs(by-ay)<1e-8:raise ValueError('source_surface_geometry')
                y=math.floor(ay*(1-t)+by*t+.5)
                tt=(y-ay)/(by-ay)
                if not 0<=tt<=1:raise ValueError('source_surface_geometry')
                pair.append(((a[0]*(1-tt)+b[0]*tt)*w-.5,float(y)))
            pair.sort(key=lambda p:p[0])
            # Keep the complete 21px matching footprint inside root and off eyes.
            valid=all(roi[0]+11<=x<roi[2]-11 and roi[1]+11<=y<roi[3]-11 and
                all(x+11<e[0] or x-11>e[2] or y+11<e[1] or y-11>e[3] for e in eyes) for x,y in pair)
            if valid and pair[1][0]-pair[0][0]>=8:
                result.append(tuple((x-crop[0],y-crop[1]) for x,y in pair));ids.append(segment*16+i)
    if len(result)<4:raise ValueError('source_surface_coverage')
    return result,ids


def main(value):
    if type(value) is not dict:reject()
    module=runpy.run_path(str(ROOT/'scripts/phase95-root-regional-motion.py'))
    if value.get('mode') in ('calibrate','calibrate-horizontal'):
        if set(value)!={'mode','generated'}:reject()
        horizontal=runpy.run_path(str(ROOT/'scripts/phase95-root-surface-horizontal.py')) if value['mode']=='calibrate-horizontal' else None
        return calibrate(value['generated'],module,horizontal)
    horizontal=runpy.run_path(str(ROOT/'scripts/phase95-root-surface-horizontal.py'))
    if value.get('mode')=='register':
        if set(value)!={'mode','source','points'}:reject()
        source=value['source'];images=packet(source,False)
        pairs,ids=definition_points(source,value['points'])
        cohort=horizontal['register'](images['source'],pairs)
        return {'schema':'phase95-surface-cohort-ephemeral-v1','pairs':cohort.points,'ids':cohort_ids(ids,len(cohort.points)),
                'source_digest':cohort.source_digest,'cohort_commitment':commitment(source,cohort,ids)}
    if value.get('mode')=='measure':
        if set(value)!={'mode','source','rendered','cohort'}:reject()
        a,b=value['source'],value['rendered'];first=packet(a,False);images=packet(b,True)
        if any(a[k]!=b[k] for k in ('source_sha256','contracts_sha256','width','height','roi','crop','eyes')) or a['images']['source']!=b['images']['source']:reject()
        c=value['cohort']
        if type(c) is not dict or set(c)!={'schema','pairs','ids','source_digest','cohort_commitment'} or c['schema']!='phase95-surface-cohort-ephemeral-v1':reject()
        cohort=horizontal['register'](first['source'],c['pairs'])
        cohort_ids(c['ids'],len(cohort.points))
        identity=commitment(a,cohort,c['ids'])
        if cohort.source_digest!=c['source_digest'] or identity!=c['cohort_commitment']:reject()
        roles=('candidate','neutral','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25')
        sampling=b['sampling'];models={}
        if type(sampling) is not dict or set(sampling)!=set(roles):reject()
        for role in roles:
            proof=sampling[role]
            if role=='candidate':
                if (type(proof) is not dict or set(proof)!={'kind','minimum_slope','maximum_slope','maximum_displacement_pixels','maximum_byte_error'}
                    or proof['kind']!='canonical_horizontal' or proof['minimum_slope']!=.2 or proof['maximum_slope']!=2.6
                    or type(proof['maximum_byte_error']) not in (int,float) or not 0<=proof['maximum_byte_error']<=1
                    or type(proof['maximum_displacement_pixels']) is not int or not 1<=proof['maximum_displacement_pixels']<=96):reject()
                models[role]=horizontal['HorizontalModel'](F(1,5),F(13,5),proof['maximum_displacement_pixels'])
            else:
                if type(proof) is not dict or set(proof)!={'kind','source_roi_identity'} or proof['kind']!='identity' or proof['source_roi_identity'] is not True:
                    raise ValueError('sibling_sampling_unsupported')
                models[role]='identity'
        roi=a['roi'];crop=a['crop'];region=[roi[0]-crop[0],roi[1]-crop[1],roi[2]-crop[0],roi[3]-crop[1]]
        result=horizontal['measure_roles'](images['source'],{k:images[k] for k in roles},c['pairs'],a['width'],models,region)
        signals=b['signals']
        if type(signals) is not dict or set(signals)!={'targetChangedPixels','targetAbsoluteRGBDelta','outsideChangedPixels','outsideAbsoluteRGBDelta','protectedRegions','neutralIdentity'}:reject()
        if signals['neutralIdentity'] is not True:reject()
        for k in ('targetChangedPixels','targetAbsoluteRGBDelta','outsideChangedPixels','outsideAbsoluteRGBDelta'):
            if type(signals[k]) is not int or not 0<=signals[k]<2**63:reject()
        protected=signals['protectedRegions']
        if type(protected) is not list or len(protected)!=4 or {p.get('id') for p in protected}!={'bridge','tip','background','watermark'}:reject()
        clean=[];protection=True
        for p in protected:
            if set(p)!={'id','changedPixels','absoluteRGBDelta'} or any(type(p[k]) is not int or not 0<=p[k]<2**63 for k in ('changedPixels','absoluteRGBDelta')):reject()
            cp,delta=(64,256) if p['id'] in ('bridge','tip') else (0,0)
            protection &= p['changedPixels']<=cp and p['absoluteRGBDelta']<=delta
            clean.append(dict(p))
        passes=signals['targetChangedPixels']>=500 and signals['targetAbsoluteRGBDelta']>=2000 and signals['outsideChangedPixels']<=128 and signals['outsideAbsoluteRGBDelta']<=512 and protection
        return {'schema':'phase95-surface-observation-v1','source_sha256':a['source_sha256'],'contracts_sha256':a['contracts_sha256'],
            'cohort_sha256':identity,
            'pairs':result['pair_count'],'intervals_q16':result['intervals_q16'],'positive_pair_counts':result['positive_pair_counts'],
            'targetChangedPixels':signals['targetChangedPixels'],'targetAbsoluteRGBDelta':signals['targetAbsoluteRGBDelta'],
            'outsideChangedPixels':signals['outsideChangedPixels'],'outsideAbsoluteRGBDelta':signals['outsideAbsoluteRGBDelta'],
            'protectedRegions':clean,'neutralIdentity':True,'threshold_pass':result['threshold_pass'],
            'signal_protection_pass':bool(passes),'root_candidate_pass':bool(passes and result['threshold_pass']),
            'measurement_admitted':False,'milestone_acceptance':False}
    reject()


if __name__=='__main__':
    try:
        if not sys.flags.isolated:reject()
        try:
            with socket.socket() as s:s.bind(('127.0.0.1',0))
        except OSError as error:
            if error.errno not in (errno.EPERM,errno.EACCES):reject()
        else:reject()
        raw=sys.stdin.buffer.read(32*1024*1024+1)
        if len(raw)>32*1024*1024:reject()
        value=json.loads(raw,object_pairs_hook=unique)
        if type(value) is not dict:reject()
        print(json.dumps(main(value),sort_keys=True))
    except Exception as error:
        allowed={'source_surface_geometry','source_surface_coverage','sibling_sampling_unsupported',
            'insufficient_crop_context','no_sampler_correspondence','inconsistent_correspondence',
            'unavailable_forward_position','ambiguous_pair_order','integer_source_rows_required',
            'identity_region_changed','invalid_pairs','unordered_pairs'}
        reason=str(error) if str(error) in allowed else 'surface_worker'
        print(json.dumps({'status':'rejected','reason':reason}));sys.exit(1)
