#!/usr/bin/env python3
"""Source-only mesh/visible-structure diagnostic; NEVER scoring or admission."""
from fractions import Fraction as F
import hashlib
import importlib.metadata
import json
import math
import os
from pathlib import Path
import runpy
import selectors
import signal
import subprocess
import sys
import threading
import tempfile
import time
import zipfile

ROOT=Path(__file__).resolve().parents[1]
PHASE=ROOT/'.planning/phases/95-compatibility-and-sdk-only-closeout'
LAB=Path('/tmp/beauty-root-mesh-lab')
transport=runpy.run_path(str(ROOT/'scripts/phase95-root-source-candidate-diagnostic.py'))
driver=transport['driver']
visible=runpy.run_path(str(ROOT/'scripts/phase95-root-visible-registration.py'))
mesh=runpy.run_path(str(ROOT/'scripts/phase95-root-mesh-topology.py'))
WORKER=ROOT/'scripts/phase95-root-mesh-source-worker.py'


def runtime_extras(site, expected, distributions):
    """Reject unbound executable files; existing cache is never loaded by worker."""
    bookkeeping=[]
    for path in site.rglob('*'):
        if path.is_symlink():raise ValueError('runtime_link')
        if path.is_dir():continue
        relative=path.relative_to(site).as_posix()
        if relative in expected:continue
        parts=Path(relative).parts
        if len(parts)==2 and parts[0] in distributions and parts[1] in ('RECORD','INSTALLER','REQUESTED','uv_cache.json'):
            bookkeeping.append((relative,driver.sha(path.read_bytes())));continue
        if len(parts)>=2 and parts[-2]=='__pycache__' and parts[-1].endswith('.pyc'):
            source=Path(*parts[:-2])/(parts[-1].split('.')[0]+'.py')
            if source.as_posix() in expected:continue
        raise ValueError('runtime_extra')
    return bookkeeping


def snapshot():
    result=driver.snapshot()
    spec_name=str((PHASE/'95-ROOT-MESH-SOURCE-SPEC.md').relative_to(ROOT))
    result[spec_name]=driver.sha(driver.read(spec_name))
    for name in ('phase95-root-mesh-source-worker.py','phase95-root-mesh-source-diagnostic.py',
                 'phase95-root-visible-registration.py','phase95-root-affine-source.py',
                 'phase95-root-mesh-topology.py','phase95-root-source-candidate-diagnostic.py',
                 'test-phase95-root-visible-registration.py','test-phase95-root-mesh-source-diagnostic.py'):
        result['scripts/'+name]=driver.sha(driver.read('scripts/'+name))
    result.update(runtime_snapshot())
    return result


def runtime_snapshot():
    """Verify the isolated predictor without inheriting a retired metric's pins."""
    result={}
    result['runtime_config']=driver.sha((LAB/'runtime/pyvenv.cfg').read_bytes())
    result['runtime_lock']=driver.sha((LAB/'requirements.lock').read_bytes())
    result['model']=driver.sha((LAB/'face_landmarker.task.partial').read_bytes())
    inventory=(LAB/'wheel-inventory.json').read_bytes()
    if driver.sha(inventory)!='5e0936d5b9f6fb07d95c9ed0d1a7944629bd33a0db419343e764ebe243b079ad':
        raise ValueError('wheel_inventory')
    entries=json.loads(inventory)
    site=LAB/'runtime/lib/python3.12/site-packages'
    normalize=lambda name: name.lower().replace('_','-').replace('.','-')
    installed={normalize(d.metadata['Name']):d.version for d in importlib.metadata.distributions(path=[str(site)])}
    if installed!={normalize(e['name']):e['version'] for e in entries}:raise ValueError('runtime_packages')
    expected={e['sha256'] for e in entries};found=set();payload=[];paths=set();distributions=set()
    for wheel in sorted((LAB/'wheels').glob('*.whl')):
        data=wheel.read_bytes();digest=driver.sha(data)
        if digest not in expected or digest in found:raise ValueError('wheel_identity')
        found.add(digest)
        with zipfile.ZipFile(wheel) as archive:
            for info in archive.infolist():
                if info.is_dir() or info.filename.endswith('.dist-info/RECORD'):continue
                if '.data/' in info.filename:
                    if not info.filename.endswith('.data/data/share/man/man1/ttx.1'):raise ValueError('wheel_layout')
                    continue
                relative=Path(info.filename)
                if relative.is_absolute() or '..' in relative.parts:raise ValueError('wheel_layout')
                target=site/relative
                if target.is_symlink() or any(p.is_symlink() for p in target.parents if p!=Path('/tmp')):raise ValueError('runtime_link')
                content=archive.read(info)
                if not target.is_file() or target.read_bytes()!=content:raise ValueError('runtime_payload')
                payload.append((info.filename,driver.sha(content)));paths.add(info.filename)
                if relative.parts[0].endswith('.dist-info'):distributions.add(relative.parts[0])
    if found!=expected:raise ValueError('wheel_inventory')
    payload.extend(runtime_extras(site,paths,distributions))
    result['runtime_payload']=driver.sha(json.dumps(sorted(payload)).encode())
    result['runtime_python']=driver.sha((LAB/'runtime/bin/python').resolve().read_bytes())
    if (result['model']!='64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff'
        or result['runtime_lock']!='f8ba252e0f40533ac46813c8b9e3e1964f84f6e9802aa5b09cea6a467b6381bb'
        or 'include-system-site-packages = false' not in (LAB/'runtime/pyvenv.cfg').read_text()):
        raise ValueError('runtime_identity')
    return result


def source_code():
    code=transport['source_code']().decode()
    marker='        return ["schema": "phase95-source-profiles-ephemeral-v1", "source_sha256": sourceHash,'
    if code.count(marker)!=1:
        raise ValueError('source_definition')
    addition='''        let factor = min(1.0, 512.0 / Double(max(image.width, image.height)))
        let sw = max(1, Int(Double(image.width) * factor)), sh = max(1, Int(Double(image.height) * factor))
        var rgb: [UInt8] = []; rgb.reserveCapacity(sw * sh * 3)
        for yy in 0..<sh { for xx in 0..<sw {
            let x = min(image.width - 1, (2 * xx + 1) * image.width / (2 * sw))
            let y = min(image.height - 1, (2 * yy + 1) * image.height / (2 * sh))
            let offset = 4 * (y * image.width + x)
            rgb.append(contentsOf: image.rgba[offset..<offset+3])
        }}
        let rows = (0..<16).map { Int(region.minY) + (2 * $0 + 1) * Int(region.maxY - region.minY) / 32 }
        return ["schema": "phase95-mesh-source-ephemeral-v1", "source_sha256": sourceHash,
                "width": sw, "height": sh, "rgb": Data(rgb).base64EncodedString(),
                "source_width": image.width, "source_height": image.height, "rows": rows,
'''
    return code.replace(marker,addition).encode()


def predict(packet):
    with tempfile.TemporaryDirectory(prefix='mesh-empty-cache-',dir=LAB) as cache:
        return predict_with_cache(packet,cache)


def predict_with_cache(packet,cache):
    command=['/usr/bin/sandbox-exec','-p','(version 1)(allow default)(deny network*)',
             str(LAB/'runtime/bin/python'),'-I','-B','-X','pycache_prefix='+cache,str(WORKER),str(LAB/'face_landmarker.task.partial')]
    env=dict(os.environ,MPLCONFIGDIR=str(LAB/'mpl-cache'))
    child=subprocess.Popen(command,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.PIPE,
                           start_new_session=True,env=env,cwd=ROOT)
    def feed():
        try:child.stdin.write(json.dumps(packet).encode());child.stdin.close()
        except (BrokenPipeError,OSError):pass
    writer=threading.Thread(target=feed,daemon=True);writer.start()
    output=bytearray();total=0;start=time.monotonic()
    try:
        with selectors.DefaultSelector() as selector:
            selector.register(child.stdout,selectors.EVENT_READ,True)
            selector.register(child.stderr,selectors.EVENT_READ,False)
            while selector.get_map():
                if time.monotonic()-start>90:raise ValueError('worker_timeout')
                for key,_ in selector.select(.1):
                    chunk=os.read(key.fileobj.fileno(),8192)
                    if not chunk:selector.unregister(key.fileobj);continue
                    total+=len(chunk)
                    if total>1024*1024:raise ValueError('worker_output')
                    if key.data:output.extend(chunk)
        if child.wait(timeout=3)!=0:raise ValueError('worker_failed')
        value=driver.decode(bytes(output))
        if (set(value)!={'schema','face_count','points'} or value['schema']!='phase95-mesh-pipe-v1'
            or type(value['face_count']) is not int or not 0<=value['face_count']<=2
            or type(value['points']) is not list):raise ValueError('worker_protocol')
        if value['face_count']!=1:
            if value['points']!=[]:raise ValueError('worker_protocol')
            raise ValueError('one_face_required')
        points=value['points']
        if len(points)!=478 or any(type(p) is not list or len(p)!=2 or any(type(v) is not float or not math.isfinite(v) or not 0<=v<=1 for v in p) for p in points):raise ValueError('worker_points')
        return points
    finally:
        try:os.killpg(child.pid,signal.SIGKILL)
        except ProcessLookupError:pass
        child.wait(timeout=3);writer.join(timeout=2)
        child.stdout.close();child.stderr.close()


def profile_coordinate(normalized, size):
    return F(normalized)*size-F(1,2)


def crossings(points,chain,y):
    values=[]
    for a,b in zip(chain,chain[1:]):
        x0,y0=map(F,points[a]);x1,y1=map(F,points[b])
        if y0==y1:
            if y==y0:values.extend((x0,x1))
        elif min(y0,y1)<=y<=max(y0,y1):values.append(x0+(y-y0)*(x1-x0)/(y1-y0))
    return values


def inspect_once():
    code,data=driver.execute(source_code())
    if code!=0:raise ValueError('source_failed')
    value=driver.decode(data);del data
    keys={'schema','source_sha256','contracts_sha256','width','height','rgb','source_width','source_height','rows','profiles','bounds'}
    if set(value)!=keys or value['schema']!='phase95-mesh-source-ephemeral-v1':raise ValueError('source_protocol')
    original=driver.decode(driver.read(str(PHASE.relative_to(ROOT))+'/95-ROI-REGISTRATION.json'))
    if any(value[k]!=original[k] for k in ('source_sha256','contracts_sha256')):raise ValueError('source_identity')
    if any(type(value[k]) is not int or not 1<=value[k]<=8192 for k in ('source_width','source_height')):raise ValueError('dimensions')
    if any(type(value[k]) is not list or len(value[k])!=16 for k in ('rows','profiles','bounds')):raise ValueError('rows')
    if any(type(y) is not int or not 0<=y<value['source_height'] for y in value['rows']):raise ValueError('rows')
    if any(type(p) is not list or len(p)!=value['source_width'] for p in value['profiles']):raise ValueError('profiles')
    if any(type(v) is not int or not 0<=v<=255*256 for p in value['profiles'] for v in p):raise ValueError('profiles')
    if any(type(b) is not list or len(b)!=3 or any(type(x) is not int for x in b)
           or not 0<=b[0]<b[1]<b[2]<=value['source_width'] for b in value['bounds']):raise ValueError('bounds')
    points=predict({k:value[k] for k in ('width','height','rgb')})
    counts={'mesh_prior_rows':0,'visible_pair_rows':0,'candidate_pairs':0,'unavailable_rows':0}
    for y,profile,bound in zip(value['rows'],value['profiles'],value['bounds']):
        if type(bound) is not list or len(bound)!=3 or any(type(v) is not int for v in bound):raise ValueError('bounds')
        lo,split,hi=bound;priors=[]
        for side in (0,1):
            xs=[profile_coordinate(x,value['source_width']) for pair in mesh['CHAINS'] for x in crossings(points,pair[side],F(2*y+1,2*value['source_height']))]
            if not xs:break
            # One small-image pixel is a SEARCH padding, not detector error.
            pad=F(value['source_width'],value['width'])
            a,b=min(xs)-pad,max(xs)+pad
            a,b=(a-lo,b-lo) if side==0 else (F(hi-1)-b,F(hi-1)-a)
            if not 0<=a<=b<(split-lo if side==0 else hi-split):break
            # Pixel search bands are rationalized outward, never narrowed.
            priors.append((F(math.floor(a)),F(math.ceil(b))))
        if len(priors)!=2:
            counts['unavailable_rows']+=1;continue
        counts['mesh_prior_rows']+=1
        try:
            pairs=visible['row_candidates'](tuple(profile),tuple(bound),tuple(priors))
        except visible['Unavailable']:
            counts['unavailable_rows']+=1;continue
        counts['visible_pair_rows']+=1;counts['candidate_pairs']+=len(pairs)
    return dict(counts,source_sha256=value['source_sha256'],contracts_sha256=value['contracts_sha256'],
                source_registered=False,portrait_acceptance=False,acceptance_credit=False)


def inspect():
    before=snapshot()
    review=driver.decode((PHASE/'95-ROOT-MESH-SOURCE-REVIEW.json').read_bytes())
    if (set(review)!={'schema','status','files','reviewer','findings'} or review['schema']!='phase95-mesh-source-review-v1'
        or review['status']!='pass' or review['files']!=before or review['findings']!=[]
        or type(review['reviewer']) is not str or len(review['reviewer'])<8):raise ValueError('review_required')
    first,second=inspect_once(),inspect_once()
    if first!=second or snapshot()!=before:raise ValueError('source_unstable')
    return dict(first,schema='phase95-mesh-source-observation-v1',attempts=2)


if __name__=='__main__':
    try:
        if sys.argv[1:]==['--review-inputs']:print(json.dumps(snapshot(),sort_keys=True))
        elif sys.argv[1:]==['--inspect-source']:print(json.dumps(inspect(),sort_keys=True))
        else:raise ValueError('arguments')
    except Exception:
        print('{"status":"rejected","reason":"mesh_source_diagnostic"}');sys.exit(1)
