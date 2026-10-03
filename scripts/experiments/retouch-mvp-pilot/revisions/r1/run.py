#!/usr/bin/env python3
"""Bounded, private, disposable R2 development pilot. Never a qualification gate."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import selectors
import shutil
import signal
import subprocess
import sys
import tempfile
import time

HERE = Path(os.path.abspath(__file__)).parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('frozen_runner', HERE.parent / 'upper-eyelid-natural-challenge/run.py')
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
MAX_BYTES = 16 * 1024 * 1024
TIMEOUT = 600


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bindings():
    result = {p.name: digest(p) for p in [HERE/'PilotTests.swift', HERE/'run.py', HERE/'README.md']}
    result['texture_source'] = digest(ROOT/'BeautySDK/Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift')
    result['package'] = digest(ROOT/'BeautySDK/Package.swift')
    return result


def child_run(command, cwd, env):
    child = subprocess.Popen(command, cwd=cwd, env=env, stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, start_new_session=True)
    output = bytearray()
    deadline = time.monotonic() + TIMEOUT
    selector = selectors.DefaultSelector()
    selector.register(child.stdout, selectors.EVENT_READ)
    try:
        while selector.get_map():
            if time.monotonic() >= deadline:
                raise helper.ExperimentError('timeout')
            for key, _ in selector.select(timeout=1):
                chunk = os.read(key.fileobj.fileno(), 8192)
                if not chunk:
                    selector.unregister(key.fileobj)
                else:
                    output.extend(chunk)
                    if len(output) > MAX_BYTES:
                        raise helper.ExperimentError('transcript_limit')
        status = child.wait(timeout=max(1, deadline-time.monotonic()))
        return status, output.decode('utf-8', errors='replace')
    finally:
        selector.close()
        try:
            os.killpg(child.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        try:
            child.wait(timeout=5)
        except subprocess.TimeoutExpired:
            os.killpg(child.pid, signal.SIGKILL)
            child.wait()
        child.stdout.close()


def run():
    if len(sys.argv) != 2 or sys.argv[1] not in ('controls', 'candidates'):
        raise helper.ExperimentError('stage_required')
    stage = sys.argv[1]
    helper.require_regular(HERE, directory=True)
    parent = ROOT/'BeautySDK/.build'
    parent.mkdir(exist_ok=True)
    helper.require_regular(parent, directory=True)
    if subprocess.run(['git','-C',str(ROOT),'check-ignore','-q','BeautySDK/.build/']).returncode:
        raise helper.ExperimentError('review_not_ignored')
    review = parent/'retouch-pilot-review'
    review.mkdir(exist_ok=True, mode=0o700)
    helper.require_regular(review, directory=True)
    receipt = review/'controls.json'
    bound = bindings()
    if stage == 'candidates':
        helper.require_regular(receipt)
        control = json.loads(receipt.read_text())
        if control.get('bindings') != bound or control.get('controls_passed') is not True:
            raise helper.ExperimentError('controls_missing_or_changed')
    names = ['testEyeControls','testSegControls'] if stage=='controls' else ['testEyeCandidates','testSegCandidates']
    with tempfile.TemporaryDirectory(prefix='retouch-pilot-',dir=parent) as temporary:
        root = Path(temporary)
        package = root/'BeautySDK'
        package.mkdir()
        shutil.copyfile(ROOT/'BeautySDK/Package.swift', package/'Package.swift')
        helper.copy_tree(ROOT/'BeautySDK/Sources',package/'Sources')
        # Preserve the original package graph but compile only this isolated suite.
        for name in ['BeautySDK','BeautyCore','BeautyDetection','BeautyEffects','BeautyRender','BeautyResources']:
            path = package/'Tests'/(name+'Tests')
            path.mkdir(parents=True)
            (path/'Placeholder.swift').write_text('import XCTest\n')
        shutil.copyfile(HERE/'PilotTests.swift',package/'Tests/BeautyCoreTests/PilotTests.swift')
        texture = package/'Sources/BeautyEffects/Render/BeautySkinTexturePipeline.swift'
        source = texture.read_text()
        signature = 'exclusionMask: BeautyTextureExclusionMask? = nil\n    ) -> [UInt8] {'
        anchor = '                guard !protectedEdge else { continue }\n'
        if source.count(signature)!=1 or source.count(anchor)!=1:
            raise helper.ExperimentError('observer_anchor_changed')
        source=source.replace(signature,'exclusionMask: BeautyTextureExclusionMask? = nil,\n        pilotObserver: ((Int) -> Void)? = nil\n    ) -> [UInt8] {')
        source=source.replace(anchor,anchor+'                pilotObserver?(y * width + x)\n')
        texture.write_text(source)
        fixtures=root/'fixtures'; fixtures.mkdir(mode=0o700)
        for name,sha in helper.FIXTURES:
            fixture=ROOT/'example-images/input/portraits'/name
            data=helper.verified_bytes(fixture,sha)
            (fixtures/name).write_bytes(data)
        stage_review=review/stage
        if stage_review.exists():
            helper.require_regular(stage_review,directory=True)
            shutil.rmtree(stage_review)
        stage_review.mkdir(mode=0o700)
        env=os.environ.copy()
        env['PILOT_FIXTURES']=str(fixtures)
        env['PILOT_REVIEW']=str(stage_review)
        env['BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS']='1'
        env.pop('BEAUTYSDK_UPPER_EYELID_FIXTURE',None)
        command=['swift','test','--package-path',str(package),'--scratch-path',str(root/'build'),
                 '--configuration','release','--filter','RetouchPilotTests/('+'|'.join(names)+')']
        print('pilot_started stage='+stage+' isolated=1',flush=True)
        status,transcript=child_run(command,root,env)
        events=re.findall(r"^Test Case '([^']+)' (started|passed|failed|skipped)\b",transcript,re.M)
        expected={'-[BeautyCoreTests.RetouchPilotTests '+name+']' for name in names}
        starts=[n for n,event in events if event=='started']
        finishes=[(n,event) for n,event in events if event!='started']
        summaries=re.findall(r'Executed (\d+) tests?, with (?:(\d+) tests? skipped and )?(\d+) failures?',transcript)
        valid=(len(starts)==2 and set(starts)==expected and len(finishes)==2
               and {n for n,_ in finishes}==expected and all(e=='passed' for _,e in finishes)
               and bool(summaries) and all(int(n)==2 and int(skip or 0)==0 and int(fail)==0 for n,skip,fail in summaries))
        # Only known structured aggregates and new-source line numbers escape.
        rows=[]
        allowed_kinds={'eye_controls','seg_controls','eye_candidate','eye_outcome','seg_candidate','seg_outcome'}
        for line in transcript.splitlines():
            if line.startswith('PILOT '):
                row=json.loads(line[6:])
                if row.get('kind') not in allowed_kinds:
                    raise helper.ExperimentError('unexpected_report')
                rows.append(row)
                print(json.dumps(row,sort_keys=True,allow_nan=False))
        line_numbers=sorted(set(map(int,re.findall(r'PilotTests.swift:(\d+)(?::\d+)?: (?:error|warning):',transcript))))
        print(json.dumps({'kind':'execution','stage':stage,'tests_started':len(starts),'valid':valid,
                          'swift_exit':status,'diagnostic_lines':line_numbers},sort_keys=True))
        if not valid or status:
            return 2
        if stage=='controls':
            if sorted(row['kind'] for row in rows)!=['eye_controls','seg_controls']:
                raise helper.ExperimentError('controls_report_incomplete')
            receipt.write_text(json.dumps({'bindings':bound,'controls_passed':True,'results':rows},sort_keys=True)+'\n')
            return 0
        outcomes=[row for row in rows if row['kind'] in ('eye_outcome','seg_outcome') and row['mode']!='baseline']
        if len(outcomes)!=2:
            raise helper.ExperimentError('candidate_report_incomplete')
        return 0 if all(row['numeric'] for row in outcomes) else 1


def main():
    try:
        return run()
    except helper.ExperimentError as error:
        print('pilot_error code='+str(error)); return 2
    except Exception:
        print('pilot_error code=io_or_internal_failure'); return 2


if __name__=='__main__':
    sys.exit(main())
