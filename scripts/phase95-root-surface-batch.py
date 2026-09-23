#!/usr/bin/env python3
"""Strict all65 root bridge: caller's actual crop RGB, ephemeral source/cohort, no candidate rendering."""
from pathlib import Path
import base64, hashlib, json, math, os, runpy, selectors, signal, subprocess, sys, tempfile, time
ROOT=Path(__file__).resolve().parents[1]
LAB=Path('/tmp/beauty-root-mesh-lab')
PHASE=ROOT/'.planning/phases/95-compatibility-and-sdk-only-closeout'
METRIC='rootSurfaceSpanQ16_v4'
ROLES=('source','neutral','candidate','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25')
REFERENCES=('source','neutral','noseBridge_0p30','noseSlim_0p35','noseTipLift_0p25')

def need(ok):
    if not ok:raise ValueError('root_batch_rejected')

def keys(value,names):need(type(value) is dict and set(value)==set(names.split()))

def digest(value):
    return hashlib.sha256(json.dumps(value,sort_keys=True,separators=(',',':'),allow_nan=False).encode()).hexdigest()

def unique(items):
    result={}
    for key,value in items:
        need(key not in result);result[key]=value
    return result

def decode(data):
    def invalid(_):raise ValueError('root_batch_rejected')
    return json.loads(data,object_pairs_hook=unique,parse_constant=invalid)

def managed_exchange(command,payload=b'',seconds=180,maximum=32*1024*1024):
    """Nested children inherit the readiness-acknowledged batch group.

    The Swift owner always removes that entire group, including descendants of
    exited leaders. This layer uses no detached sessions or blocked I/O threads.
    """
    need(os.getpid()==os.getpgrp() and type(payload) is bytes and len(payload)<=128*1024*1024)
    need(type(seconds) in (int,float) and math.isfinite(seconds) and 0<seconds<=600)
    need(type(maximum) is int and 0<maximum<=32*1024*1024)
    child=subprocess.Popen(command,cwd=ROOT,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,
        start_new_session=False,env=dict(os.environ,MPLCONFIGDIR=str(LAB/'mpl-cache')))
    output=bytearray();total=0;sent=0;deadline=time.monotonic()+seconds
    try:
        with selectors.DefaultSelector() as selector:
            for stream,events,role in [(child.stdin,selectors.EVENT_WRITE,'input'),
                (child.stdout,selectors.EVENT_READ,'output'),(child.stderr,selectors.EVENT_READ,'error')]:
                os.set_blocking(stream.fileno(),False);selector.register(stream,events,role)
            if not payload:selector.unregister(child.stdin);child.stdin.close()
            while selector.get_map():
                need(time.monotonic()<deadline)
                for key,_ in selector.select(min(.05,max(0,deadline-time.monotonic()))):
                    try:
                        if key.data=='input':
                            written=os.write(key.fd,memoryview(payload)[sent:sent+65536]);sent+=written
                            if sent==len(payload):selector.unregister(key.fileobj);key.fileobj.close()
                        else:
                            chunk=os.read(key.fd,65536)
                            if not chunk:selector.unregister(key.fileobj);continue
                            total+=len(chunk);need(total<=maximum)
                            if key.data=='output':output.extend(chunk)
                    except (BlockingIOError,InterruptedError):continue
            need(sent==len(payload))
            return child.wait(timeout=max(.001,deadline-time.monotonic())),bytes(output)
    finally:
        for stream in (child.stdin,child.stdout,child.stderr):stream.close()
        if child.poll() is None:
            child.terminate()
            try:child.wait(timeout=.2)
            except subprocess.TimeoutExpired:
                child.kill()
                try:child.wait(timeout=2)
                except subprocess.TimeoutExpired:raise ValueError('root_batch_rejected')


def managed_pipe(command,payload=b'',seconds=180,maximum=32*1024*1024):
    status,output=managed_exchange(command,payload,seconds,maximum)
    need(status==0);return output


def managed_worker(value):
    with tempfile.TemporaryDirectory(prefix='surface-cache-',dir=LAB) as cache:
        command=['/usr/bin/sandbox-exec','-p','(version 1)(allow default)(deny network*)',
            str(LAB/'runtime/bin/python'),'-I','-B','-X','pycache_prefix='+cache,str(ROOT/'scripts/phase95-root-surface-worker.py')]
        return decode(managed_pipe(command,json.dumps(value,allow_nan=False).encode(),90,1024*1024))


def managed_predict(packet):
    with tempfile.TemporaryDirectory(prefix='mesh-empty-cache-',dir=LAB) as cache:
        command=['/usr/bin/sandbox-exec','-p','(version 1)(allow default)(deny network*)',
            str(LAB/'runtime/bin/python'),'-I','-B','-X','pycache_prefix='+cache,
            str(ROOT/'scripts/phase95-root-mesh-source-worker.py'),str(LAB/'face_landmarker.task.partial')]
        value=decode(managed_pipe(command,json.dumps(packet,allow_nan=False).encode(),90,1024*1024))
    keys(value,'schema face_count points')
    need(value['schema']=='phase95-mesh-pipe-v1' and type(value['face_count']) is int and value['face_count']==1)
    points=value['points']
    need(type(points) is list and len(points)==478 and all(type(p) is list and len(p)==2 and
        all(type(v) is float and math.isfinite(v) and 0<=v<=1 for v in p) for p in points))
    return points


def check_admission():
    evidence=runpy.run_path(str(ROOT/'scripts/phase95-closeout-evidence.py'))
    admission=evidence['root_admission'](ROOT)
    need(admission['metric_id']==METRIC)
    probe=runpy.run_path(str(ROOT/'scripts/phase95-root-surface-probe.py'))
    # Only this batch invocation replaces transport; independent probe policy stays unchanged.
    probe['pipe']=managed_pipe;probe['worker']=managed_worker;probe['mesh']['predict']=managed_predict
    runtime=probe['mesh']['runtime_snapshot']()
    need(admission['definition_sha256']==hashlib.sha256((PHASE/'95-ROOT-SURFACE-MARKER-DEFINITION.md').read_bytes()).hexdigest())
    need(admission['model_sha256']==runtime['model'] and admission['runtime_sha256']==digest(runtime))
    return admission,probe,evidence['snapshot'](ROOT)

def compile_native(directory,probe):
    comparator=(ROOT/'scripts/compare-face-feature-batches.swift').read_bytes()
    marker=b'\nlet commandArguments = Array(CommandLine.arguments.dropFirst())\n'
    need(comparator.count(marker)==1)
    entry=b'''\ndo {
        let data=FileHandle.standardInput.readData(ofLength:128*1024*1024+1)
        guard data.count<=128*1024*1024,
            let value=try JSONSerialization.jsonObject(with:data) as? [String:Any] else {throw SemanticContractError.admission}
        let output=try RootSurfaceBatchNative.execute(value)
        let encoded=try JSONSerialization.data(withJSONObject:output,options:[.sortedKeys])
        guard encoded.count<=32*1024*1024 else {throw SemanticContractError.admission}
        FileHandle.standardOutput.write(encoded)
    } catch {print("{\\"status\\":\\"rejected\\",\\"reason\\":\\"root_batch_rejected\\"}");exit(1)}
    '''
    source=Path(directory)/'batch.swift';binary=Path(directory)/'batch';scratch=Path(directory)/'sdk'
    native=(ROOT/'scripts/phase95-root-surface-native.swift').read_bytes()
    native_entry=b'    static func run(render:Bool)'
    need(native.count(native_entry)==1)
    # Reuse only qualification helpers; the independent probe's rendering entry
    # and fixture locator are not part of this compiled helper at all.
    helpers=native.split(native_entry)[0]+b'\n}\n'
    source.write_bytes(comparator.split(marker)[0]+b'\n'+helpers+b'\n'+(ROOT/'scripts/phase95-root-surface-batch-native.swift').read_bytes()+entry)
    status,_=managed_exchange(['/usr/bin/swift','build','--package-path',str(ROOT/'BeautySDK'),'--scratch-path',str(scratch),'--target','BeautySDK'],seconds=240)
    need(status==0)
    build=scratch/'arm64-apple-macosx/debug'
    targets=('BeautyCore','BeautyDetection','BeautyRender','BeautyResources','BeautyEffects','BeautySDK')
    objects=[str(p) for target in targets for p in sorted((build/(target+'.build')).glob('*.o'))]
    need(len(objects)>=30)
    status,_=managed_exchange(['/usr/bin/swiftc','-O','-package-name','beautysdk','-I',str(build/'Modules'),str(source),*objects,'-o',str(binary)],seconds=180)
    need(status==0)
    identity={str(path.relative_to(Path(directory))):hashlib.sha256(path.read_bytes()).hexdigest()
              for path in [binary,*map(Path,objects),*sorted((build/'Modules').glob('*'))] if path.is_file()}
    (Path(directory)/'build-identity.json').write_text(json.dumps(identity,sort_keys=True))
    return binary

def input_identity(value,admission):
    for name in ('source_sha256','contracts_sha256','source_rgba_sha256'):
        need(type(value[name]) is str and len(value[name])==64 and all(c in '0123456789abcdef' for c in value[name]))
    original=decode((PHASE/'95-ROI-REGISTRATION.json').read_bytes())
    need(value['source_sha256']==admission['source_sha256']==original['source_sha256'])
    need(value['contracts_sha256']==original['contracts_sha256'])
    need(type(value['source_encoded']) is str and len(value['source_encoded'])<=96*1024*1024)
    need(hashlib.sha256(base64.b64decode(value['source_encoded'],validate=True)).hexdigest()==value['source_sha256'])

def native_request(value,images):
    return dict(schema='phase95-root-batch-native-input-v1',
        **{key:value[key] for key in ('source_encoded','source_sha256','source_rgba_sha256','contracts_sha256')},images=images)

def execute(value):
    keys(value,'schema mode source_encoded source_sha256 source_rgba_sha256 contracts_sha256 registration images signals')
    need(value['schema']=='phase95-root-batch-input-v1' and value['mode'] in ('register','measure'))
    admission,probe,before=check_admission()
    input_identity(value,admission)
    need(type(value['images']) is dict and type(value['signals']) is dict)
    if value['mode']=='register':
        need(value['registration'] is None and not value['images'] and not value['signals'])
    else:
        keys(value['registration'],'schema source cohort measurement_identity')
        need(set(value['images'])==set(ROLES))
        need(value['registration']['schema']=='phase95-root-batch-registration-v1' and value['registration']['measurement_identity']==admission['measurement_identity'])
    with tempfile.TemporaryDirectory(prefix='beauty-root-batch-native-') as directory:
        binary=compile_native(directory,probe)
        encoded=json.dumps(native_request(value,value['images']),allow_nan=False,separators=(',',':')).encode()
        probe['check_binary'](binary)
        packet=decode(probe['pipe']([str(binary)],encoded,180,32*1024*1024))
        probe['check_binary'](binary)
        if value['mode']=='register':
            need(value['registration'] is None and not value['images'] and not value['signals'])
            points=probe['mesh']['predict'](packet['mesh_input'])
            cohort=probe['worker']({'mode':'register','source':packet,'points':points})
            need(cohort['cohort_commitment']==admission['registration_sha256'] and len(cohort['ids'])==admission['registered_pairs'])
            result={'schema':'phase95-root-batch-registration-v1','source':packet,'cohort':cohort,
                    'measurement_identity':admission['measurement_identity']}
        else:
            keys(value['registration'],'schema source cohort measurement_identity')
            registration=value['registration']
            need(registration['schema']=='phase95-root-batch-registration-v1' and registration['measurement_identity']==admission['measurement_identity'])
            need(set(value['images'])==set(ROLES))
            cohort=registration['cohort']
            need(cohort['cohort_commitment']==admission['registration_sha256'] and len(cohort['ids'])==admission['registered_pairs'])
            packet['signals']=value['signals']
            observed=probe['clean_observation'](probe['worker']({'mode':'measure','source':registration['source'],'rendered':packet,'cohort':cohort}))
            need(observed['cohort_sha256']==admission['registration_sha256'] and observed['pairs']==admission['registered_pairs'])
            hashes={role:hashlib.sha256(base64.b64decode(value['images'][role],validate=True)).hexdigest() for role in ROLES}
            result={'schema':'phase95-root-batch-evidence-v1','metric_id':METRIC,
                **{key:admission[key] for key in ('measurement_identity','source_sha256','original_registration_sha256','definition_sha256','registration_sha256','model_sha256','runtime_sha256')},
                'pair_count':observed['pairs'],'crop_rgb_sha256':hashes,'intervals_q16':observed['intervals_q16']}
    fresh=runpy.run_path(str(ROOT/'scripts/phase95-closeout-evidence.py'))
    need(fresh['snapshot'](ROOT)==before and fresh['root_admission'](ROOT)==admission)
    need(digest(probe['mesh']['runtime_snapshot']())==admission['runtime_sha256'])
    return result

if __name__=='__main__':
    def interrupted(_signum,_frame):raise SystemExit(1)
    signal.signal(signal.SIGTERM,interrupted)
    try:
        need(sys.flags.isolated and sys.argv[1:]==['--pipe'] and os.getpgrp()==os.getpid())
        raw=sys.stdin.buffer.read(128*1024*1024+1);need(len(raw)<=128*1024*1024)
        result=execute(decode(raw))
        encoded=json.dumps(result,sort_keys=True,separators=(',',':'),allow_nan=False).encode()
        need(len(encoded)<=32*1024*1024)
        sys.stdout.buffer.write(encoded)
    except Exception:
        print('{"status":"rejected","reason":"root_batch_rejected"}');sys.exit(1)
