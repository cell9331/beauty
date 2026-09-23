#!/usr/bin/env python3
"""Bounded surface-measurement integration. Pixels exist only in internal pipes."""
from pathlib import Path
import base64, hashlib, json, os, runpy, selectors, signal, subprocess, sys, tempfile, threading, time
ROOT=Path(__file__).resolve().parents[1]
PHASE=ROOT/'.planning/phases/95-compatibility-and-sdk-only-closeout'
LAB=Path('/tmp/beauty-root-mesh-lab')
mesh=runpy.run_path(str(ROOT/'scripts/phase95-root-mesh-source-diagnostic.py'))
gate=runpy.run_path(str(ROOT/'scripts/phase95-genuine-gate.py'))


def pipe(command,payload=b'',seconds=180,maximum=32*1024*1024):
    child=subprocess.Popen(command,cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,start_new_session=True,
        env=dict(os.environ,MPLCONFIGDIR=str(LAB/'mpl-cache')))
    def feed():
        try:child.stdin.write(payload);child.stdin.close()
        except (OSError,BrokenPipeError):pass
    writer=threading.Thread(target=feed,daemon=True);writer.start();data=bytearray();total=0;start=time.monotonic()
    try:
        with selectors.DefaultSelector() as selector:
            selector.register(child.stdout,selectors.EVENT_READ,True);selector.register(child.stderr,selectors.EVENT_READ,False)
            while selector.get_map():
                if time.monotonic()-start>seconds:raise ValueError('child_timeout')
                for key,_ in selector.select(.1):
                    chunk=os.read(key.fileobj.fileno(),8192)
                    if not chunk:selector.unregister(key.fileobj);continue
                    total+=len(chunk)
                    if total>maximum:raise ValueError('child_limit')
                    if key.data:data.extend(chunk)
        if child.wait(timeout=3)!=0:
            try:failure=json.loads(data)
            except (ValueError,UnicodeDecodeError):failure={}
            allowed={'surface_worker','source_surface_geometry','source_surface_coverage','sibling_sampling_unsupported',
                'insufficient_crop_context','no_sampler_correspondence','inconsistent_correspondence',
                'unavailable_forward_position','ambiguous_pair_order','integer_source_rows_required',
                'identity_region_changed','invalid_pairs','unordered_pairs'}
            if type(failure) is dict and set(failure)=={'status','reason'} and failure.get('status')=='rejected' and failure.get('reason') in allowed:
                raise ValueError(failure['reason'])
            raise ValueError('child_failed')
        return bytes(data)
    finally:
        try:os.killpg(child.pid,signal.SIGKILL)
        except ProcessLookupError:pass
        child.wait(timeout=3);writer.join(timeout=2);child.stdout.close();child.stderr.close()


def compile_native(directory):
    comparator=(ROOT/'scripts/compare-face-feature-batches.swift').read_bytes()
    # The current reviewed source snapshot owns this dependency. The historical
    # ROI receipt retains its original comparator hash and is never rewritten.
    expected=gate['snapshot']()['files']['scripts/compare-face-feature-batches.swift']
    if hashlib.sha256(comparator).hexdigest()!=expected:raise ValueError('comparator_identity')
    marker=b'\nlet commandArguments = Array(CommandLine.arguments.dropFirst())\n'
    if comparator.count(marker)!=1:raise ValueError('definition')
    entry='''
    do {
      if CommandLine.arguments == [CommandLine.arguments[0], "--generated-control"] {
        let color=CGColorSpace(name:CGColorSpace.sRGB)!
        let context=CIContext(options:[.workingColorSpace:color,.outputColorSpace:color])
        let ci=CIImage(color:CIColor(red:0.25,green:0.5,blue:0.75,alpha:1)).cropped(to:CGRect(x:0,y:0,width:64,height:64))
        let image=try RootSurfaceNative.image(ci,context:context)
        guard image.width==64,image.height==64,Data(base64Encoded:try RootSurfaceNative.rgb(image,box:[8,8,40,40]))?.count==3072 else { throw SemanticContractError.admission }
        print("{\\"generated_control\\":true}")
      } else if CommandLine.arguments == [CommandLine.arguments[0], "--generated-root"] {
        print(String(decoding:try JSONSerialization.data(withJSONObject:RootSurfaceGenerated.run(),options:[.sortedKeys]),as:UTF8.self))
      } else {
        guard CommandLine.arguments.count==2,["--source","--render"].contains(CommandLine.arguments[1]) else { throw SemanticContractError.admission }
        let result=try RootSurfaceNative.run(render:CommandLine.arguments[1]=="--render")
        print(String(decoding:try JSONSerialization.data(withJSONObject:result,options:[.sortedKeys]),as:UTF8.self))
      }
    } catch { print("{\\"status\\":\\"rejected\\"}"); exit(1) }
    '''
    source=Path(directory)/'surface.swift';binary=Path(directory)/'surface'
    source.write_bytes(comparator.split(marker)[0]+b'\n'+(ROOT/'scripts/phase95-root-surface-native.swift').read_bytes()+b'\n'+(ROOT/'scripts/phase95-root-surface-generated.swift').read_bytes()+entry.encode())
    scratch=Path(directory)/'sdk'
    status,_=gate['bounded'](['/usr/bin/swift','build','--package-path',str(ROOT/'BeautySDK'),'--scratch-path',str(scratch),'--target','BeautySDK'],240)
    if status:raise ValueError('sdk_build_failed')
    build=scratch/'arm64-apple-macosx/debug'
    targets=('BeautyCore','BeautyDetection','BeautyRender','BeautyResources','BeautyEffects','BeautySDK')
    objects=[str(p) for t in targets for p in sorted((build/(t+'.build')).glob('*.o'))]
    if len(objects)<30:raise ValueError('sdk_build_missing')
    command=['/usr/bin/swiftc','-O','-package-name','beautysdk','-I',str(build/'Modules'),str(source),*objects,'-o',str(binary)]
    # Compiler data contains public code only, but still discard its transcript.
    status,output=gate['bounded'](command,180)
    if status:
        # Exact sanitized Swift error text can be used only in compile mode.
        errors=[line for line in output.decode(errors='replace').splitlines() if 'error:' in line]
        raise ValueError('compile_failed:'+('\n'.join(errors)[:2400]))
    identity={str(p.relative_to(Path(directory))):hashlib.sha256(p.read_bytes()).hexdigest() for p in [binary,*map(Path,objects),*sorted((build/'Modules').glob('*'))] if p.is_file()}
    (Path(directory)/'build-identity.json').write_text(json.dumps(identity,sort_keys=True))
    return binary


def snapshot():
    value=gate['snapshot']()
    value['runtime']=mesh['runtime_snapshot']()
    value['surface_definition']={name:hashlib.sha256((PHASE/name).read_bytes()).hexdigest() for name in (
        '95-ROOT-SURFACE-MARKER-DEFINITION.md',
    )}
    return value


def check_binary(binary):
    identity=json.loads((binary.parent/'build-identity.json').read_text())
    if any(hashlib.sha256((binary.parent/p).read_bytes()).hexdigest()!=h for p,h in identity.items()):raise ValueError('build_changed')


def native(binary,mode):
    check_binary(binary)
    value=mesh['driver'].decode(pipe([str(binary),mode]))
    if set(value)!={'schema','source_sha256','contracts_sha256','width','height','roi','crop','eyes','mesh_input','images','signals','sampling'} or value['schema']!='phase95-root-surface-pixels-v1':raise ValueError('native_protocol')
    original=mesh['driver'].decode((PHASE/'95-ROI-REGISTRATION.json').read_bytes())
    if any(value[k]!=original[k] for k in ('source_sha256','contracts_sha256')):raise ValueError('source_identity')
    return value


def worker(value):
    with tempfile.TemporaryDirectory(prefix='surface-cache-',dir=LAB) as cache:
        command=['/usr/bin/sandbox-exec','-p','(version 1)(allow default)(deny network*)',str(LAB/'runtime/bin/python'),'-I','-B','-X','pycache_prefix='+cache,str(ROOT/'scripts/phase95-root-surface-worker.py')]
        return mesh['driver'].decode(pipe(command,json.dumps(value).encode(),90,1024*1024))


def digest(value):
    return hashlib.sha256(json.dumps(value,sort_keys=True,separators=(',',':'),allow_nan=False).encode()).hexdigest()


def clean_observation(value):
    """Reconstruct only typed aggregate facts; never echo a worker object."""
    keys={'schema','source_sha256','contracts_sha256','pairs','intervals_q16','positive_pair_counts',
          'targetChangedPixels','targetAbsoluteRGBDelta','outsideChangedPixels','outsideAbsoluteRGBDelta',
          'protectedRegions','neutralIdentity','threshold_pass','signal_protection_pass','root_candidate_pass',
          'measurement_admitted','milestone_acceptance','cohort_sha256'}
    if type(value) is not dict or set(value)!=keys or value['schema']!='phase95-surface-observation-v1':raise ValueError('observation_protocol')
    original=mesh['driver'].decode((PHASE/'95-ROI-REGISTRATION.json').read_bytes())
    if any(value[k]!=original[k] for k in ('source_sha256','contracts_sha256')):raise ValueError('observation_identity')
    if type(value['pairs']) is not int or not 4<=value['pairs']<=32:raise ValueError('observation_pairs')
    commit=value['cohort_sha256']
    if type(commit) is not str or len(commit)!=64 or any(c not in '0123456789abcdef' for c in commit):raise ValueError('observation_cohort')
    references=('source','neutral','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25')
    intervals={};counts={}
    if any(type(value[k]) is not dict or set(value[k])!=set(references) for k in ('intervals_q16','positive_pair_counts')):raise ValueError('observation_references')
    threshold=True
    for role in references:
        interval=value['intervals_q16'][role];count=value['positive_pair_counts'][role]
        if type(interval) is not list or len(interval)!=2 or any(type(n) is not int or abs(n)>2**31 for n in interval) or interval[0]>interval[1]:raise ValueError('observation_interval')
        if type(count) is not int or not 0<=count<=value['pairs']:raise ValueError('observation_count')
        intervals[role]=list(interval);counts[role]=count
        threshold &= interval[0]>=16 if role in ('source','neutral') else interval[0]>=16 or interval[1]<=-16
    for name in ('targetChangedPixels','targetAbsoluteRGBDelta','outsideChangedPixels','outsideAbsoluteRGBDelta'):
        if type(value[name]) is not int or not 0<=value[name]<2**63:raise ValueError('observation_signal')
    protected=value['protectedRegions'];clean=[];protection=True
    if type(protected) is not list or len(protected)!=4 or any(type(p) is not dict for p in protected):raise ValueError('observation_protection')
    if {p.get('id') for p in protected}!={'bridge','tip','background','watermark'}:raise ValueError('observation_protection')
    for p in sorted(protected,key=lambda p:p['id']):
        if set(p)!={'id','changedPixels','absoluteRGBDelta'} or any(type(p[k]) is not int or not 0<=p[k]<2**63 for k in ('changedPixels','absoluteRGBDelta')):raise ValueError('observation_protection')
        cp,delta=(64,256) if p['id'] in ('bridge','tip') else (0,0)
        protection &= p['changedPixels']<=cp and p['absoluteRGBDelta']<=delta
        clean.append({'id':p['id'],'changedPixels':p['changedPixels'],'absoluteRGBDelta':p['absoluteRGBDelta']})
    signal_pass=value['targetChangedPixels']>=500 and value['targetAbsoluteRGBDelta']>=2000 and value['outsideChangedPixels']<=128 and value['outsideAbsoluteRGBDelta']<=512 and protection
    flags={'neutralIdentity':True,'threshold_pass':bool(threshold),'signal_protection_pass':bool(signal_pass),
        'root_candidate_pass':bool(signal_pass and threshold),'measurement_admitted':False,'milestone_acceptance':False}
    if any(type(value[k]) is not bool or value[k]!=v for k,v in flags.items()):raise ValueError('observation_flags')
    return {'schema':'phase95-surface-observation-v1',**{k:value[k] for k in ('source_sha256','contracts_sha256','pairs','cohort_sha256','targetChangedPixels','targetAbsoluteRGBDelta','outsideChangedPixels','outsideAbsoluteRGBDelta')},
        'intervals_q16':intervals,'positive_pair_counts':counts,'protectedRegions':clean,**flags}


def clean_calibration(value):
    numeric=('case_count','total_points','measured_cases','unavailable_cases','evaluated_points','covered_points',
        'maximum_error_millipixels','mean_interval_failures','moving_truth_points','measured_moving_points','maximum_truth_motion_millipixels')
    if type(value) is not dict or set(value)!=set(numeric)|{'schema','precision_pass','cases','private_source_accessed','measurement_admitted'} or value['schema']!='phase95-surface-calibration-v1':raise ValueError('calibration_protocol')
    if any(type(value[k]) is not int or not 0<=value[k]<2**31 for k in numeric):raise ValueError('calibration_number')
    if value['case_count']!=6 or type(value['cases']) is not list or len(value['cases'])!=6:raise ValueError('calibration_cases')
    if value['private_source_accessed'] is not False or value['measurement_admitted'] is not False:raise ValueError('calibration_claim')
    clean=[];seen=set()
    keys={'full_image_width','strength','point_count','status','covered_points','maximum_error_millipixels','mean_interval_contains_truth','moving_truth_points'}
    for c in value['cases']:
        if type(c) is not dict or set(c)!=keys:raise ValueError('calibration_case')
        if any(type(c[k]) is not int or not 0<=c[k]<2**31 for k in ('full_image_width','point_count','covered_points','maximum_error_millipixels','moving_truth_points')):raise ValueError('calibration_case')
        if type(c['strength']) is not float or c['strength'] not in (0.,.125,.25) or c['full_image_width'] not in (512,1024):raise ValueError('calibration_case')
        if type(c['mean_interval_contains_truth']) is not bool or c['status'] not in ('measured','unavailable'):raise ValueError('calibration_case')
        identity=(c['full_image_width'],c['strength'])
        if identity in seen or c['point_count']!=72 or not 0<=c['covered_points']<=72 or not 0<=c['moving_truth_points']<=72:raise ValueError('calibration_case')
        if (c['strength']==0 and c['moving_truth_points']!=0) or (c['strength']!=0 and c['moving_truth_points']==0):raise ValueError('calibration_positive_control')
        seen.add(identity);clean.append({k:c[k] for k in sorted(keys)})
    facts={'case_count':6,'total_points':sum(c['point_count'] for c in clean),
        'measured_cases':sum(c['status']=='measured' for c in clean),'unavailable_cases':sum(c['status']=='unavailable' for c in clean),
        'evaluated_points':sum(c['point_count'] for c in clean if c['status']=='measured'),
        'covered_points':sum(c['covered_points'] for c in clean),
        'maximum_error_millipixels':max(c['maximum_error_millipixels'] for c in clean),
        'mean_interval_failures':sum(not c['mean_interval_contains_truth'] for c in clean if c['status']=='measured'),
        'moving_truth_points':sum(c['moving_truth_points'] for c in clean),
        'measured_moving_points':sum(c['moving_truth_points'] for c in clean if c['status']=='measured')}
    if any(value[k]!=v for k,v in facts.items()) or value['maximum_truth_motion_millipixels']==0:raise ValueError('calibration_totals')
    passes=facts['measured_cases']==6 and facts['covered_points']==facts['evaluated_points'] and facts['mean_interval_failures']==0 and facts['moving_truth_points']>0 and facts['measured_moving_points']==facts['moving_truth_points']
    if type(value['precision_pass']) is not bool or value['precision_pass']!=passes:raise ValueError('calibration_pass')
    return {'schema':'phase95-surface-calibration-v1',**facts,'maximum_truth_motion_millipixels':value['maximum_truth_motion_millipixels'],
        'precision_pass':passes,'cases':clean,'private_source_accessed':False,'measurement_admitted':False}


if __name__=='__main__':
    stage='inputs'
    try:
        if sys.argv[1:]==['--review-inputs']:
            print(json.dumps(snapshot(),sort_keys=True));sys.exit(0)
        if sys.argv[1:] not in (['--compile-only'],['--calibrate'],['--evaluate']):raise ValueError('arguments')
        before=snapshot()
        if sys.argv[1:]==['--evaluate']:
            review=mesh['driver'].decode((PHASE/'95-ROOT-SURFACE-EXECUTION-REVIEW.json').read_bytes())
            if set(review)!={'schema','status','reviewer','snapshot','findings'} or review['schema']!='phase95-surface-execution-review-v1' or review['status']!='pass' or review['snapshot']!=before or review['findings']!=[] or type(review['reviewer']) is not str or len(review['reviewer'])<8:raise ValueError('review_required')
        with tempfile.TemporaryDirectory(prefix='beauty-surface-native-') as directory:
            stage='compile'
            binary=compile_native(directory)
            if sys.argv[1:]==['--compile-only']:
                if pipe([str(binary),'--generated-control'])!=b'{"generated_control":true}\n':raise ValueError('generated_control')
                check_binary(binary)
                if snapshot()!=before:raise ValueError('execution_changed')
                print('{"compiled":true,"generated_control":true,"private_source_accessed":false}')
            elif sys.argv[1:]==['--calibrate']:
                stage='generated_raster'
                generated=mesh['driver'].decode(pipe([str(binary),'--generated-root']))
                stage='calibration'
                observed=worker({'mode':'calibrate-horizontal','generated':generated})
                check_binary(binary)
                stage='stability'
                if snapshot()!=before:raise ValueError('execution_changed')
                print(json.dumps(clean_calibration(observed),sort_keys=True))
            else:
                observations=[];cohorts=[]
                for _ in range(2):
                    stage='source'
                    source=native(binary,'--source')
                    stage='source_registration'
                    points=mesh['predict'](source['mesh_input'])
                    cohort=worker({'mode':'register','source':source,'points':points})
                    cohorts.append(digest(cohort))
                    stage='render'
                    rendered=native(binary,'--render')
                    stage='measurement'
                    observed=worker({'mode':'measure','source':source,'rendered':rendered,'cohort':cohort})
                    observations.append(clean_observation(observed))
                check_binary(binary)
                if observations[0]!=observations[1] or cohorts[0]!=cohorts[1] or snapshot()!=before:raise ValueError('execution_changed')
                print(json.dumps(observations[0],sort_keys=True))
    except Exception as error:
        if sys.argv[1:] in (['--compile-only'],['--calibrate']) and str(error).startswith('compile_failed:'):print(str(error))
        else:
            allowed={'surface_worker','source_surface_geometry','source_surface_coverage','sibling_sampling_unsupported',
                'insufficient_crop_context','no_sampler_correspondence','inconsistent_correspondence',
                'unavailable_forward_position','ambiguous_pair_order','integer_source_rows_required',
                'identity_region_changed','invalid_pairs','unordered_pairs','child_timeout','child_failed','execution_changed'}
            print(json.dumps({'status':'rejected','stage':stage,'reason':str(error) if str(error) in allowed else 'surface_execution'}))
        sys.exit(1)
