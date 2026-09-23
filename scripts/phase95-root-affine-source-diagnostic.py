#!/usr/bin/env python3
"""Reviewed affine-source diagnostic; reuses the immutable source-only transport."""
import importlib.util
import json
from pathlib import Path
import re
import sys

ROOT=Path(__file__).resolve().parents[1]
PHASE='.planning/phases/95-compatibility-and-sdk-only-closeout/'
REVIEW=PHASE+'95-ROOT-AUTOMATIC-MODEL-REVIEW.json'
SPEC=PHASE+'95-ROOT-AUTOMATIC-MODEL.md'


def module(name,path):
    spec=importlib.util.spec_from_file_location(name,ROOT/path)
    value=importlib.util.module_from_spec(spec);spec.loader.exec_module(value)
    return value


transport=module('source_transport','scripts/phase95-root-source-candidate-diagnostic.py')
model=module('affine_source','scripts/phase95-root-affine-source.py')
driver=transport.driver


def snapshot():
    files=transport.snapshot()
    for name in (SPEC,'scripts/phase95-root-affine-source.py',
                 'scripts/test-phase95-root-affine-source.py',
                 'scripts/phase95-root-affine-source-diagnostic.py',
                 'scripts/phase95-root-sampler-correspondence.py',
                 'scripts/test-phase95-root-sampler-correspondence.py',
                 'BeautySDK/Tests/BeautyEffectsTests/Phase95RootImageFormationTests.swift'):
        files[name]=driver.sha(driver.read(name))
    return files


def inspect():
    before=snapshot()
    review=driver.decode(driver.read(REVIEW))
    if (set(review)!={'schema','status','reviewer_agent_id','files','findings'}
        or review['schema']!='phase95-automatic-model-review-v1'
        or review['status']!='pass' or review['files']!=before or review['findings']!=[]
        or type(review['reviewer_agent_id']) is not str
        or re.fullmatch('[A-Za-z0-9-]{8,80}',review['reviewer_agent_id']) is None):
        raise driver.AdmissionError('review_required')
    results=[]
    for _ in range(2):
        code,data=driver.execute(transport.source_code())
        if code!=0:raise driver.AdmissionError('source_rejected')
        value=driver.decode(data)
        del data
        if (set(value)!={'schema','source_sha256','contracts_sha256','profiles','bounds'}
            or value['schema']!='phase95-source-profiles-ephemeral-v1'
            or type(value['profiles']) is not list or type(value['bounds']) is not list
            or len(value['profiles'])!=16 or len(value['bounds'])!=16
            or any(type(row) is not list for row in value['profiles']+value['bounds'])):
            raise driver.AdmissionError('source_protocol')
        original=driver.decode(driver.read(PHASE+'95-ROI-REGISTRATION.json'))
        if any(value[k]!=original[k] for k in ('source_sha256','contracts_sha256')):
            raise driver.AdmissionError('source_identity')
        result=model.diagnostic(tuple(map(tuple,value['profiles'])),tuple(map(tuple,value['bounds'])))
        result.update(source_sha256=value['source_sha256'],contracts_sha256=value['contracts_sha256'],
            source_profile_digest=driver.sha(json.dumps(value,sort_keys=True,separators=(',',':')).encode()),
            source_registered=False)
        del value
        results.append(result)
    if results[0]!=results[1] or snapshot()!=before:raise driver.AdmissionError('unstable_diagnostic')
    return dict(results[0],schema='phase95-affine-source-observation-v1',attempts=2,
                diagnostic_identity=driver.sha(json.dumps(before,sort_keys=True).encode()),acceptance_credit=False)


if __name__=='__main__':
    try:
        if sys.argv[1:]==['--review-inputs']:print(json.dumps(snapshot(),sort_keys=True))
        elif sys.argv[1:]==['--inspect-source']:print(json.dumps(inspect(),sort_keys=True))
        else:raise driver.AdmissionError('arguments')
    except Exception:
        print('{"status":"rejected","reason":"affine_source_diagnostic"}')
        sys.exit(1)
