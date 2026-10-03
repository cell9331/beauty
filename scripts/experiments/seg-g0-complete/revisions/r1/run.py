#!/usr/bin/env python3
"""Private disposable SEG G0 source/control check; no automatic candidate."""
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

HERE = Path(os.path.abspath(__file__)).parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('pilot_runner', HERE.parent/'retouch-mvp-pilot/run.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)
helper = runner.helper
SOURCES = json.loads((HERE/'sources.json').read_text())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run():
    if len(sys.argv) != 2 or sys.argv[1] not in [*SOURCES,'development','holdout','rejection','all']:
        raise helper.ExperimentError('source_id_required')
    case = sys.argv[1]
    cases = sorted(SOURCES) if case=='all' else (sorted(k for k,v in SOURCES.items() if v['set']==case) if case in ('development','holdout','rejection') else [case])
    normal = [id for id in cases if not id.startswith('R')]
    rejection = [id for id in cases if id.startswith('R')]
    extras = ['testMetricControls']+(['testInputFailureControls'] if 'D01' in cases else [])
    helper.require_regular(HERE, directory=True)
    parent = ROOT/'BeautySDK/.build'
    helper.require_regular(parent, directory=True)
    if subprocess.run(['git','-C',str(ROOT),'check-ignore','-q','BeautySDK/.build/']).returncode:
        raise helper.ExperimentError('input_not_ignored')
    local = parent/'seg-g0-local'
    helper.require_regular(local, directory=True)
    bindings = {p.name:digest(p) for p in [HERE/'SegG0Tests.swift',HERE/'run.py',HERE/'README.md',HERE/'sources.json']}
    bindings['texture_source'] = digest(ROOT/'BeautySDK/Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift')
    bindings['package'] = digest(ROOT/'BeautySDK/Package.swift')
    # A fresh review directory preserves previous attempts and never follows a link.
    review = Path(tempfile.mkdtemp(prefix='complete-'+case+'-',dir=local))
    with tempfile.TemporaryDirectory(prefix='seg-g0-',dir=parent) as temporary:
        root = Path(temporary)
        package = root/'BeautySDK'; package.mkdir()
        shutil.copyfile(ROOT/'BeautySDK/Package.swift',package/'Package.swift')
        helper.copy_tree(ROOT/'BeautySDK/Sources',package/'Sources')
        for name in ['BeautySDK','BeautyCore','BeautyDetection','BeautyEffects','BeautyRender','BeautyResources']:
            path = package/'Tests'/(name+'Tests'); path.mkdir(parents=True)
            (path/'Placeholder.swift').write_text('import XCTest\n')
        shutil.copyfile(HERE/'SegG0Tests.swift',package/'Tests/BeautyCoreTests/SegG0Tests.swift')
        texture = package/'Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift'
        source = texture.read_text()
        signature = 'exclusionMask: BeautyTextureExclusionMask? = nil\n    ) -> [UInt8] {'
        anchor = '                guard !protectedEdge else { continue }\n'
        if source.count(signature)!=1 or source.count(anchor)!=1:
            raise helper.ExperimentError('observer_anchor_changed')
        source = source.replace(signature,'exclusionMask: BeautyTextureExclusionMask? = nil,\n        pilotObserver: ((Int) -> Void)? = nil\n    ) -> [UInt8] {')
        source = source.replace(anchor,anchor+'                pilotObserver?(y * width + x)\n')
        texture.write_text(source)
        fixtures = root/'inputs'; fixtures.mkdir(mode=0o700)
        for id in cases:
            for suffix,key in [('source.png','source_sha256'),('author.json','author_sha256')]:
                name = 'SEG-'+id+'-'+suffix
                if SOURCES[id][key] is not None:
                    (fixtures/name).write_bytes(helper.verified_bytes(local/name,SOURCES[id][key]))
        env = os.environ.copy()
        env.update(SEG_G0_INPUT=str(fixtures),SEG_G0_REVIEW=str(review),SEG_G0_ID=case,
                   BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS='1')
        env.pop('BEAUTYSDK_UPPER_EYELID_FIXTURE',None)
        command = ['swift','test','--package-path',str(package),'--scratch-path',str(root/'build'),
                   '--configuration','release','--filter','SegG0Tests/('+'|'.join(['test'+id for id in cases]+extras)+')']
        print('seg_g0_started id=SEG-'+case+' candidates=0 isolated=1',flush=True)
        status,transcript = runner.child_run(command,root,env)
        events = re.findall(r"^Test Case '([^']+)' (started|passed|failed|skipped)\b",transcript,re.M)
        expected = {'-[BeautyCoreTests.SegG0Tests test'+id+']' for id in cases}
        expected.update('-[BeautyCoreTests.SegG0Tests '+name+']' for name in extras)
        starts = [n for n,e in events if e=='started']
        finishes = [(n,e) for n,e in events if e!='started']
        summaries = re.findall(r'Executed (\d+) tests?, with (?:(\d+) tests? skipped and )?(\d+) failures?',transcript)
        complete = (set(starts)==expected and len(starts)==len(expected) and len(finishes)==len(expected)
                    and {n for n,e in finishes}==expected and all(e in ('passed','failed') for n,e in finishes) and bool(summaries)
                    and all(int(n)==len(expected) and int(skip or 0)==0 for n,skip,fail in summaries))
        rows = []
        for line in transcript.splitlines():
            if line.startswith('SEG_G0 '):
                row = json.loads(line[7:])
                if row.get('kind') not in ('control','input','error','rejection','matrix','input_controls'):
                    raise helper.ExperimentError('unexpected_report')
                rows.append(row)
                print(json.dumps(row,sort_keys=True,allow_nan=False))
        control_keys={(r['id'],r['side'],r['smoothing']) for r in rows if r['kind']=='control'}
        input_keys={(r['id'],r['side']) for r in rows if r['kind']=='input'}
        expected_inputs={('SEG-'+id+'-'+p,s) for id in normal for p in ['negative','positive'] for s in [1024,512]}
        expected_controls={(i,s,b) for i,s in expected_inputs for b in [True,False]}
        expected_rejection={('SEG-'+id,s) for id in rejection for s in [1024,512]}
        rejection_rows=[r for r in rows if r['kind']=='rejection']
        matrix=[r for r in rows if r['kind']=='matrix']
        expected_matrix={('SEG-D01-'+p,s,b) for p in ['negative','positive'] for s in [1024,512] for b in [True,False]} if 'D01' in cases else set()
        error_rows=[r for r in rows if r['kind']=='input_controls']
        report_complete=(control_keys==expected_controls and input_keys==expected_inputs
                         and {(r['id'],r['side']) for r in rejection_rows}==expected_rejection
                         and all(r['reference_exact'] for r in rejection_rows)
                         and {(r['id'],r['side'],r['smoothing']) for r in matrix}==expected_matrix
                         and all(r['orientation_combinations']==16 for r in matrix)
                         and len(error_rows)==int('D01' in cases)
                         and len(rows)==12*len(normal)+2*len(rejection)+9*int('D01' in cases))
        failures=max((int(f) for n,skip,f in summaries),default=0)
        passed=complete and report_complete and status==0 and failures==0 and all(r['numeric'] for r in rows if r['kind']=='control')
        result={'kind':'execution','id':'SEG-'+case,'tests_started':len(starts),'complete':complete,
                'report_complete':report_complete,'failures':failures,'swift_exit':status,
                'passed':passed,'diagnostic_lines':sorted(set(map(int,re.findall(r'SegG0Tests.swift:(\d+)(?::\d+)?: (?:error|warning):',transcript))))}
        print(json.dumps(result,sort_keys=True))
        (review/'receipt.json').write_text(json.dumps({'bindings':bindings,'execution':result,'rows':rows},sort_keys=True,allow_nan=False)+'\n')
        return 0 if passed else (1 if complete and report_complete else 2)


if __name__=='__main__':
    try:
        sys.exit(run())
    except helper.ExperimentError as error:
        print('seg_g0_error code='+str(error)); sys.exit(2)
    except Exception:
        print('seg_g0_error code=io_or_internal_failure'); sys.exit(2)
