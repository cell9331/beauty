#!/usr/bin/env python3
"""Bounded isolated SEG development evaluation. Never reads holdout media."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

HERE=Path(os.path.abspath(__file__)).parent
ROOT=HERE.parents[2]
G0=HERE.parent/'seg-g0-complete'
FREEZE_SHA='7aa9ef16a66b77dc21e3f79af2f109900b2ad5b1302c5afe0f2d4f1bfe37bcd5'
spec=importlib.util.spec_from_file_location('pilot_runner',HERE.parent/'retouch-mvp-pilot/run.py')
runner=importlib.util.module_from_spec(spec);spec.loader.exec_module(runner)
helper=runner.helper

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def require(condition,code):
    if not condition:raise helper.ExperimentError(code)
def checked_json(path,sha):return json.loads(helper.verified_bytes(path,sha))

def run():
    require(len(sys.argv)==2 and sys.argv[1] in ('baseline','S1-v1','S1-v2'),'version_required')
    version=sys.argv[1]
    freeze=checked_json(G0/'g0-freeze.json',FREEZE_SHA)
    require(freeze['g0']=='passed','g0_not_passed')
    for name,sha in freeze['contract_bindings'].items():helper.verified_bytes(ROOT/name,sha)
    for name,sha in freeze['execution_receipt']['bindings'].items():
        path={'package':ROOT/'BeautySDK/Package.swift','texture_source':ROOT/'BeautySDK/Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift'}.get(name,G0/name)
        helper.verified_bytes(path,sha)
    source_tree={str(f.relative_to(ROOT)):digest(f) for f in sorted((ROOT/'BeautySDK/Sources').rglob('*')) if f.is_file()}
    tree_hash=hashlib.sha256(json.dumps(source_tree,sort_keys=True,separators=(',',':')).encode()).hexdigest()
    require(tree_hash==freeze['sdk_source_tree_sha256'],'sdk_source_changed')
    sources=json.loads((G0/'sources.json').read_text())
    cases=['D%02d'%i for i in range(1,7)]
    expected_inputs={(r['id'],r['side']):r['rgba_sha256'] for r in freeze['execution_receipt']['rows'] if r['kind']=='input' and r['id'].startswith('SEG-D')}
    bindings={name:digest(HERE/name) for name in ['run.py','README.md','SegDevelopmentTests.swift']}
    bindings.update(g0_freeze=FREEZE_SHA,sdk_source_tree=tree_hash)
    candidate=HERE/'versions'/(version+'.swift')
    candidate_sha=digest(candidate)
    if version=='S1-v1':
        original=(HERE.parent/'retouch-mvp-pilot/PilotTests.swift').read_text()
        start=original.index('    func segCandidate(');end=original.index('\n    func testEyeCandidates',start)
        method=original[start:end].rstrip()
        require(method in candidate.read_text(),'original_candidate_changed')
    parent=ROOT/'BeautySDK/.build';helper.require_regular(parent,directory=True)
    require(subprocess.run(['git','-C',str(ROOT),'check-ignore','-q','BeautySDK/.build/']).returncode==0,'review_not_ignored')
    local=parent/'seg-g0-local';helper.require_regular(local,directory=True)
    prior=local/'automatic-baseline-controls.json'
    if version!='baseline':
        helper.require_regular(prior)
        previous=json.loads(prior.read_text())
        require(previous['bindings']==bindings and previous['controls_passed'] is True,'current_controls_required')
    review=Path(tempfile.mkdtemp(prefix='automatic-'+version+'-',dir=local))
    with tempfile.TemporaryDirectory(prefix='seg-development-',dir=parent) as tmp:
        root=Path(tmp);package=root/'BeautySDK';package.mkdir()
        shutil.copyfile(ROOT/'BeautySDK/Package.swift',package/'Package.swift')
        helper.copy_tree(ROOT/'BeautySDK/Sources',package/'Sources')
        for name in ['BeautySDK','BeautyCore','BeautyDetection','BeautyEffects','BeautyRender','BeautyResources']:
            d=package/'Tests'/(name+'Tests');d.mkdir(parents=True);(d/'Placeholder.swift').write_text('import XCTest\n')
        shutil.copyfile(G0/'SegG0Tests.swift',package/'Tests/BeautyCoreTests/SegG0Tests.swift')
        shutil.copyfile(HERE/'SegDevelopmentTests.swift',package/'Tests/BeautyCoreTests/SegDevelopmentTests.swift')
        shutil.copyfile(candidate,package/'Sources/BeautyEffects/Render/SegAutomaticCandidate.swift')
        texture=package/'Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift';source=texture.read_text()
        signature='exclusionMask: BeautyTextureExclusionMask? = nil\n    ) -> [UInt8] {'
        support='                guard !protectedEdge else { continue }\n'
        activation='        guard gain != 0 else { return source }\n'
        maskguard='                guard exclusionMask?.bytes[y * width + x] != 255 else { continue }\n'
        require(all(source.count(s)==1 for s in [signature,support,activation,maskguard]),'observer_anchor_changed')
        source=source.replace(signature,'exclusionMask: BeautyTextureExclusionMask? = nil,\n        pilotAutomatic: Bool = true,\n        pilotObserver: ((Int) -> Void)? = nil\n    ) -> [UInt8] {')
        source=source.replace(activation,activation+'        let pilotExclusions = exclusionMask == nil && pilotAutomatic\n            ? SegAutomaticCandidate().protection(source, width: width, height: height, bounds: faceBounds) : Set<Int>()\n')
        source=source.replace(maskguard,'                guard exclusionMask?.bytes[y * width + x] != 255,\n                      !pilotExclusions.contains(y * width + x) else { continue }\n')
        source=source.replace(support,support+'                pilotObserver?(y * width + x)\n');texture.write_text(source)
        fixtures=root/'inputs';fixtures.mkdir(mode=0o700)
        for id in cases:
            for suffix,key in [('source.png','source_sha256'),('author.json','author_sha256')]:
                name='SEG-'+id+'-'+suffix;(fixtures/name).write_bytes(helper.verified_bytes(local/name,sources[id][key]))
        (fixtures/'expected-inputs.json').write_text(json.dumps({i+'-'+str(s):h for (i,s),h in expected_inputs.items()},sort_keys=True))
        reports=root/'reports';reports.mkdir(mode=0o700)
        env=os.environ.copy();env.update(SEG_G0_INPUT=str(fixtures),SEG_G0_REVIEW=str(review),SEG_G0_REPORT=str(reports),BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS='1');env.pop('BEAUTYSDK_UPPER_EYELID_FIXTURE',None)
        tests=['testAuto'+id for id in cases]
        if version=='baseline':tests+=['test'+id for id in cases]+['testMetricControls','testInputFailureControls']
        command=['swift','test','--package-path',str(package),'--scratch-path',str(root/'build'),'--configuration','release','--filter','SegG0Tests/('+'|'.join(tests)+')']
        print('seg_development_started version='+version+' holdout_media=0 production_changes=0',flush=True)
        status,transcript=runner.child_run(command,root,env)
        events=re.findall(r"^Test Case '([^']+)' (started|passed|failed|skipped)\b",transcript,re.M)
        expected={'-[BeautyCoreTests.SegG0Tests '+t+']' for t in tests}
        starts=[n for n,e in events if e=='started'];finishes=[(n,e) for n,e in events if e!='started']
        summaries=re.findall(r'Executed (\d+) tests?, with (?:(\d+) tests? skipped and )?(\d+) failures?',transcript)
        complete=set(starts)==expected and len(starts)==len(expected) and len(finishes)==len(expected) and {n for n,e in finishes}==expected and all(e in ('passed','failed') for n,e in finishes) and bool(summaries) and all(int(n)==len(expected) and int(sk or 0)==0 for n,sk,f in summaries)
        failures=max((int(f) for n,sk,f in summaries),default=0)
        rows=[json.loads(helper.verified_bytes(p,digest(p))) for p in sorted(reports.glob('*.json'))]
        allowed={'automatic','automatic_input','control','input','matrix','input_controls'}
        require(all(r.get('kind') in allowed for r in rows),'unexpected_report')
        rows.sort(key=lambda r:(r.get('id',''),r['kind'],r.get('side',0),r.get('smoothing',False)))
        auto=[r for r in rows if r['kind']=='automatic'];inputs=[r for r in rows if r['kind']=='automatic_input'];controls=[r for r in rows if r['kind']=='control']
        keys={(i,s,b) for i,s in expected_inputs for b in [True,False]}
        report_complete=len(auto)==48 and {(r['id'],r['side'],r['smoothing']) for r in auto}==keys and len(inputs)==24 and {(r['id'],r['side']):r['rgba_sha256'] for r in inputs}==expected_inputs and len(rows)==(153 if version=='baseline' else 72)
        controls_ok=False
        if version=='baseline':
            regular=[r for r in rows if r['kind']=='input'];matrix=[r for r in rows if r['kind']=='matrix'];errors=[r for r in rows if r['kind']=='input_controls']
            matrixkeys={('SEG-D01-'+pol,s,b) for pol in ['positive','negative'] for s in [1024,512] for b in [True,False]}
            controls_ok=len(controls)==48 and {(r['id'],r['side'],r['smoothing']) for r in controls}==keys and all(r['numeric'] for r in controls) and len(regular)==24 and {(r['id'],r['side']):r['rgba_sha256'] for r in regular}==expected_inputs and len(matrix)==8 and {(r['id'],r['side'],r['smoothing']) for r in matrix}==matrixkeys and all(r['orientation_combinations']==16 for r in matrix) and len(errors)==1 and all(errors[0].get(k) is True for k in ['corrupt','empty','alpha','recovery']) and errors[0].get('metadata_mutations')==2
            report_complete=report_complete and controls_ok
        execution_ok=complete and report_complete and failures==0 and status==0
        groups={}
        for id in sorted({i for i,s in expected_inputs}):
            rs=[r for r in auto if r['id']==id]
            groups[id]='unmeasured' if len(rs)!=4 else ('hard_failure' if any(r['hard'] for r in rs) else ('numeric_pass' if all(r['numeric'] for r in rs) else ('abstained' if all(r['source_exact'] for r in rs) else 'insufficient_effect')))
        positive=[id for id,v in groups.items() if id.endswith('positive') and v=='numeric_pass'];negative=[id for id,v in groups.items() if id.endswith('negative') and v=='numeric_pass']
        indices={int(id.split('-')[1][1:]) for id in positive}
        strata=all(indices & q for q in [{1,2},{3,4},{5,6},{1,3,5},{2,4,6}])
        numeric_pass=execution_ok and len(positive)>=4 and len(negative)==6 and strata and all(v!='hard_failure' for v in groups.values())
        result={'version':version,'execution_complete':complete,'report_complete':report_complete,'tests':len(starts),'failures':failures,'skips':sum(e=='skipped' for n,e in finishes),'swift_exit':status,'execution_passed':execution_ok,'development_numeric_pass':numeric_pass,'g1_passed':False,'positive_numeric_pass':len(positive),'negative_numeric_pass':len(negative),'positive_denominator':6,'negative_denominator':6,'groups':groups,'diagnostic_lines':sorted(set(map(int,re.findall(r'(?:SegDevelopmentTests|SegG0Tests|SegAutomaticCandidate).swift:(\d+)(?::\d+)?: (?:error|warning):',transcript))))}
        receipt={'bindings':bindings,'candidate_sha256':candidate_sha,'result':result,'rows':rows}
        (review/'receipt.json').write_text(json.dumps(receipt,sort_keys=True,allow_nan=False)+'\n')
        if version=='baseline' and execution_ok and controls_ok:(prior).write_text(json.dumps({'bindings':bindings,'controls_passed':True,'receipt_sha256':digest(review/'receipt.json')},sort_keys=True)+'\n')
        print(json.dumps(result,sort_keys=True))
        return 2 if not execution_ok else (0 if numeric_pass else 1)

if __name__=='__main__':
    try:sys.exit(run())
    except helper.ExperimentError as e:print('seg_development_error code='+str(e));sys.exit(2)
    except Exception as e:print('seg_development_error code=internal type='+type(e).__name__);sys.exit(2)
