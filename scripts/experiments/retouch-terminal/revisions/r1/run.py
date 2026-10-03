#!/usr/bin/env python3
"""Finite EYE diagnosis; no production edits and no effect qualification."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]

def load_module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    return module

batch=load_module('terminal_child',ROOT/'scripts/current-batch/run.py')
frozen=load_module('terminal_fixture',HERE.parent/'upper-eyelid-natural-challenge/run.py')

def digest(path):
    return hashlib.sha256(batch.read(path,128*1024*1024)).hexdigest()

def bindings():
    files=['README.md','TerminalTests.swift','Candidates.swift','Evaluation.swift','run.py']
    result={name:digest(HERE/name) for name in files}
    result['child_runner']=digest(ROOT/'scripts/current-batch/run.py')
    result['fixture_runner']=digest(HERE.parent/'upper-eyelid-natural-challenge/run.py')
    result['frozen_pilot']=digest(HERE.parent/'retouch-mvp-pilot/PilotTests.swift')
    sources={str(p.relative_to(ROOT)):digest(p) for p in sorted((ROOT/'BeautySDK/Sources').rglob('*')) if p.is_file()}
    result['sdk_source_tree']=hashlib.sha256(json.dumps(sources,sort_keys=True).encode()).hexdigest()
    return result

def record(path,payload):
    batch.require(not path.exists(),'receipt_already_exists')
    temporary=path.with_suffix('.tmp');temporary.write_text(json.dumps(payload,sort_keys=True,allow_nan=False,indent=2)+'\n')
    temporary.replace(path)

def collect(output,names):
    transcript=output.decode('utf-8',errors='replace')
    events=re.findall(r"^Test Case '([^']+)' (started|passed|failed|skipped)\b",transcript,re.M)
    expected={'-[BeautyCoreTests.RetouchTerminalTests '+name+']' for name in names}
    starts=[n for n,e in events if e=='started'];ends=[(n,e) for n,e in events if e!='started']
    summary=re.findall(r'Executed (\d+) tests?, with (?:(\d+) tests? skipped and )?(\d+) failures?',transcript)
    valid=(len(starts)==len(names) and set(starts)==expected and len(ends)==len(names)
           and {n for n,e in ends}==expected and all(e=='passed' for n,e in ends)
           and bool(summary) and all(int(n)==len(names) and int(s or 0)==0 and int(f)==0 for n,s,f in summary))
    rows=[]
    for line in transcript.splitlines():
        if line.startswith('TERMINAL '):
            row=batch.parse(line[9:]);batch.require(row.get('kind') in ('eye_controls','candidate','negative','outcome'),'unknown_row')
            rows.append(row)
    diagnostics=sorted(set(re.findall(r'(TerminalTests|Candidates|Evaluation)\.swift:(\d+)(?::\d+)?: (?:error|warning):',transcript)))
    return valid,rows,diagnostics

def run():
    bound=bindings()
    batch.require(batch.parse(batch.read(HERE/'registration.json'))['bindings']==bound,'registration_changed')
    parent=ROOT/'BeautySDK/.build';batch.regular(parent,directory=True);batch.ignored(parent)
    review=Path(tempfile.mkdtemp(prefix='retouch-terminal-review-',dir=parent))
    print(json.dumps({'stage':'started','review_id':review.name,'qualified':False}),flush=True)
    all_results=[]
    with tempfile.TemporaryDirectory(prefix='retouch-terminal-',dir=parent) as temporary:
        root=Path(temporary);package=root/'BeautySDK';package.mkdir()
        shutil.copyfile(ROOT/'BeautySDK/Package.swift',package/'Package.swift')
        frozen.copy_tree(ROOT/'BeautySDK/Sources',package/'Sources')
        for module in ['BeautySDK','BeautyCore','BeautyDetection','BeautyEffects','BeautyRender','BeautyResources']:
            tests=package/'Tests'/(module+'Tests');tests.mkdir(parents=True)
            (tests/'Placeholder.swift').write_text('import XCTest\n')
        for name in ['TerminalTests.swift','Candidates.swift','Evaluation.swift']:
            shutil.copyfile(HERE/name,package/'Tests/BeautyCoreTests'/name)
        fixtures=root/'fixtures';fixtures.mkdir(mode=0o700)
        for name,sha in frozen.FIXTURES:
            pixels=frozen.verified_bytes(ROOT/'example-images/input/portraits'/name,sha)
            (fixtures/name).write_bytes(pixels)
        env={k:v for k,v in os.environ.items() if not k.startswith(('BEAUTY_','BEAUTYSDK_','PILOT_'))}
        env.update(PILOT_FIXTURES=str(fixtures),BEAUTYSDK_RUN_VISION_INTEGRATION_TESTS='1')
        stages=[('controls',['testEyeControls']),('candidates',['testE1V2','testE2V1','testE2V2'])]
        for stage,names in stages:
            batch.require(bindings()==bound,'source_changed_during_run')
            output_dir=review/stage;output_dir.mkdir(mode=0o700);env['PILOT_REVIEW']=str(output_dir)
            command=['swift','test','--package-path',package,'--scratch-path',root/'build','--configuration','release',
                     '--filter','RetouchTerminalTests/('+'|'.join(names)+')']
            if stage=='candidates':command.append('--skip-build')
            status,output=batch.child(command,timeout=600,limit=16*1024*1024,env=env)
            valid,rows,diagnostics=collect(output,names)
            report={'schema':'beauty.retouch-terminal.v1','stage':stage,'bindings':bound,'swift_exit':status,
                    'execution_valid':valid,'expected_tests':len(names),'rows':rows,'diagnostic_lines':diagnostics,
                    'qualified':False}
            if status or not valid:
                report['exit_code']=2;record(review/(stage+'.json'),report)
                print(json.dumps(report,sort_keys=True),flush=True);return 2
            if stage=='controls':
                batch.require(len(rows)==1 and rows[0]['kind']=='eye_controls' and rows[0]['direction'] and rows[0]['hard']==0,'controls_incomplete')
                report['exit_code']=0
            else:
                for mode in ('E1-v2','E2-v1','E2-v2'):
                    selected=[r for r in rows if r.get('mode')==mode]
                    batch.require(len(selected)==5,'candidate_rows_incomplete')
                    batch.require(sorted(r['strength'] for r in selected if r['kind']=='candidate')==[0.5,1.0],'strength_inventory')
                    batch.require(sorted(r['case_id'] for r in selected if r['kind']=='negative')==['N01','N02'],'negative_inventory')
                    batch.require(len([r for r in selected if r['kind']=='outcome'])==1,'outcome_inventory')
                outcomes=[r for r in rows if r['kind']=='outcome']
                report['exit_code']=0 if any(r['numeric'] for r in outcomes) else 1
                report['all_candidates_failed']=not any(r['numeric'] for r in outcomes)
            record(review/(stage+'.json'),report);all_results.append(report)
            print(json.dumps(report,sort_keys=True),flush=True)
        record(review/'result.json',{'schema':'beauty.retouch-terminal.summary.v1','results':all_results,
                                    'qualified':False,'exit_code':all_results[-1]['exit_code']})
    return all_results[-1]['exit_code']

if __name__=='__main__':
    try:
        raise SystemExit(run())
    except (batch.Invalid,frozen.ExperimentError) as error:
        print(json.dumps({'error':str(error),'exit_code':2}));raise SystemExit(2)
    except (Exception,KeyboardInterrupt):
        print(json.dumps({'error':'execution_unavailable','exit_code':2}));raise SystemExit(2)
