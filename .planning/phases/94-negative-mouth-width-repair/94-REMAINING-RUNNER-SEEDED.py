#!/usr/bin/env python3
"""Phase94 remaining lanes. Historical helpers supply capture, never authority.

Parent review headers are a single fenced json object. Test-review schema:
phase94.test-review.1, reviewer_role independent-parent, verdict PASS,
unresolved_blockers 0, inputs (exact batch files plus this runner).
Negative wire record: P94N_AGGREGATE followed by canonical JSON with exactly
case, comparisons, metrics, predicates. No diagnostic strings are persisted.
"""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time
import types

# The sixteen cases are defined before their admission implementation.
def self_tests():
    results = []
    def check(name, action):
        action(); results.append(name)
    def reject(action):
        try:
            action()
        except (GateError, H.GateError):
            return
        raise AssertionError('expected_rejection')
    method = NEGATIVE[0]
    clean = "Test Case '-[" + method.replace('/', ' ') + "]' started.\nTest Case '-[" + method.replace('/', ' ') + "]' passed (0.01 seconds).\nExecuted 1 test, with 0 failures (0 unexpected)\n"
    good = sample_negative()
    check('normal_admission', lambda: classify(clean, 0, method))
    check('zero_discovery', lambda: reject(lambda: H.discover('', [method])))
    check('duplicate_discovery', lambda: reject(lambda: H.discover((method+'\n')*2, [method])))
    check('skip', lambda: reject(lambda: classify(clean+'skipped', 0, method)))
    check('wrong_method_summary', lambda: reject(lambda: classify(clean.replace('1 test', '2 tests'), 0, method)))
    def timeout():
        reject(lambda: H.child([sys.executable, '-c', 'import time; time.sleep(5)'], .05))
        need(H.LAST_REAPED, 'cleanup_failure')
    check('timeout_group_cleanup', timeout)
    def overflow():
        reject(lambda: H.child([sys.executable, '-c', 'import sys; sys.stdout.write("x"*(9*1024*1024))'], 5))
        need(H.LAST_REAPED, 'cleanup_failure')
    check('capture_overflow', overflow)
    check('unknown_private_aggregate', lambda: reject(lambda: negative_record(dict(good, private='forbidden'))))
    check('missing_comparison', lambda: reject(lambda: negative_record(dict(good, comparisons=COMPARISONS[:-1]))))
    def reviews():
        expected = {'attempt': 1, 'status': 'pass', 'provider_after_sha256': 'a'*64}
        for value in (None, dict(expected, attempt=2), dict(expected, status='fail'), dict(expected, provider_after_sha256='b'*64)):
            reject(lambda v=value: exact(v, expected, 'review_failure'))
    check('stale_review_compile', reviews)
    check('historical_tamper', lambda: reject(lambda: exact({'a':'0'*64}, {'a':'1'*64}, 'historical_drift')))
    check('nonprovider_drift', lambda: reject(lambda: exact({'a':'0'*64}, {'a':'1'*64}, 'authority_drift')))
    def allowed():
        original = b'prefix\n    private func widthPoints\n suffix\n'
        candidate = original.replace(b' suffix', DISPATCH.encode()+b' suffix') + HELPER_START.encode()+b'    private func phase94NegativeWidth() {}\n'+HELPER_END.encode()
        need(strip_candidate(candidate) == original, 'provider_scope')
        exact({'compile':'a'*64,'review':'b'*64,'seal':'c'*64}, {'compile':'a'*64,'review':'b'*64,'seal':'c'*64}, 'review_failure')
    check('allowed_negative_seal', allowed)
    check('positive_shared_edit', lambda: reject(lambda: need(sha(strip_candidate(b'changed')) == '0'*64, 'provider_scope')))
    def attempts():
        reject(lambda: attempt_number(2, 0)); reject(lambda: attempt_number(3, 2))
    check('attempt_reset_third_begin', attempts)
    def closeout():
        reject(lambda: exact({'PLANS.md':'a'*64}, {'PLANS.md':'b'*64}, 'owner_drift'))
        reject(lambda: need(False, 'completion_absent'))
    check('stale_checks_goal', closeout)
    need(len(results) == 16, 'self_test_failure')
    return {'status':'pure_pass','executed':16,'passed':16,'failed':0,'skipped':0,'native_tests':0}

ROOT = Path(__file__).resolve().parent.parent
P = '.planning/phases/94-negative-mouth-width-repair/'
REL = 'scripts/check-phase94-remaining.py'
BINDING = P+'94-REMAINING-BINDING.json'
EVENTS = P+'94-REMAINING-EVENTS.jsonl'
PROVIDER = 'BeautySDK/Sources/BeautyEffects/Warp/MouthWarpProvider.swift'
ORIGINAL = 'd8f306e3643aca367451a3dbd3bc97c2208e0abfa9b4ab80fdfb3c4390fcc6b3'
OLD_HELPER = 'scripts/check-phase94-mouth-repair.py'
HELPER_SHA = '9135d44c7dc9012429f79f30e2ae0e0825ec2011a89814d6ff70b00481385afc'
METADATA = P+'94-METADATA-BASELINE.json'
METADATA_SHA = '5a8b3d22d8378b8b0746877c62f4c3d0c97f9bd220ca501d38737bb8d3711c64'
CORE = 'BeautySDK/Tests/BeautyCoreTests/'
EFFECTS = 'BeautySDK/Tests/BeautyEffectsTests/'
BATCHES = {'oracle':[CORE+'MouthNegativeOracleTests.swift', CORE+'BeautyEngineMouthNegativeTests.swift'],
           'field':[EFFECTS+'MouthNegativeFieldTests.swift'],
           'lifecycle':[CORE+'BeautyEngineMouthLifecycleTests.swift']}
BATCHES['safety'] = BATCHES['field']+BATCHES['lifecycle']
NEW_TESTS = set(BATCHES['oracle']+BATCHES['safety'])
OWNERS = ['DESIGN.md','SECURITY.md','RELIABILITY.md','PRODUCT_SENSE.md','QUALITY_SCORE.md','docs/SDK_EFFECT_TAXONOMY.md','PLANS.md']
COMPARISONS = ['source','geometryBaseline_noop','mouthWidth_plus0p35','mouthSize_plus0p35','mouthSize_minus0p35']
NEGATIVE = ['BeautyCoreTests.MouthNegativeOracleTests/'+n for n in ('testNegativeIntegerMetricMatchesFrozenContract','testEveryNegativePredicateIsNecessary','testArrayCounterexamplesCannotMasqueradeAsContraction')]+['BeautyCoreTests.BeautyEngineMouthNegativeTests/testNegativeWidthAllFiveComparisons']
FIELD = ['BeautyEffectsTests.MouthNegativeFieldTests/'+n for n in ('testFinalFloatScalingAndRendererCutoff','testMalformedSupportAndSiblingIsolation','testActualNegativeMapAndOverlapSafety','testReuseConflictAndRetainedEmissions')]
LIFE = ['BeautyCoreTests.BeautyEngineMouthLifecycleTests/'+n for n in ('testNeutralCapsExtentAndDeterminism','testOrientationEncodingsPreserveRawContract','testMirrorPoliciesUseMappedSourceSupport','testRejectedSupportResetRecoveryIsSourceSafe')]
PROVIDER_METHODS = ['BeautyEffectsTests.MouthWarpProviderTests/'+n for n in (
 'testMouthSizeExpandsLipRegionAroundMouthCenterWithCappedStrength','testMouthProviderOutputIsDeterministicAndClampedForAllCurrentFields','testMouthWidthMovesCornersOutwardWithCappedStrength','testNegativeMouthSizeAndWidthMoveLipPointsInwardWithCappedStrength','testSmileLiftsBothMouthCornersWithCappedStrength','testMissingOuterLipsReturnsMissingMouthSkipReason','testPhase38LegacyMouthEmissionArraysRemainExact','testPhase38SignedTranslationsUseUniformAxesAndReverseExactly','testPhase38TiltUsesStableClockwiseImageConventionAndOppositeTangents','testPhase38PeakUsesUpperAndInnerForLocalSymmetricCupidBow','testPhase38PlumpUsesBothSurfacesAwayFromInnerOpeningAndDoesNotAliasPeak','testPhase38EightEmissionsAggregateInCanonicalOrderAndRemainSafe','testPhase38MalformedLocalSupportFailsOnlyDependentFields','testPhase38MalformedWholeSupportDoesNotMaskValidLocalSiblings','testPhase38DisplacementEmptyAndInvalidBoundsFailClosedPerField','testPhase38SkipReasonRequiresRequestedAggregateEmptyWorkAndStaysRedacted')]
DEGRADE = ['BeautyEffectsTests.MissingLandmarkDegradationTests/'+n for n in ('testPhase35ReviewConflictThresholdCrossingSignedMouthFieldsAreSkippedAndExcluded','testPhase35ReviewConflictThresholdCrossingSignedMouthFieldsKeepSupportedSibling','testMissingMouthSkipsOnlyMouthAndKeepsEyeNoseAndSafeDomainsActive','testReusedLandmarksReduceMouthGeometry','testPhase38MOUTH08ReusedStaleMissingOuterAndNoFaceApplyPerMouthGeometry','testStaleLandmarksSkipStrongMouthGeometry')]
DISPATCH = '''        // BEGIN PHASE94 NEGATIVE DISPATCH
        if signedStrength < 0 { return phase94NegativeWidth(face: face, strength: signedStrength) }
        // END PHASE94 NEGATIVE DISPATCH
'''
HELPER_START = '    // BEGIN PHASE94 NEGATIVE HELPER\n'
HELPER_END = '    // END PHASE94 NEGATIVE HELPER\n'

class GateError(Exception): pass
def need(value, category):
    if not value: raise GateError(category)
def canonical(v): return json.dumps(v,sort_keys=True,separators=(',',':'),allow_nan=False).encode()
def sha(raw): return hashlib.sha256(raw).hexdigest()
def path(name):
    p = ROOT/name
    need(not Path(name).is_absolute() and '..' not in Path(name).parts, 'path_failure')
    need(all(not x.is_symlink() for x in [p,*p.parents] if x != ROOT.parent), 'path_failure')
    return p
def read(name):
    p=path(name); need(p.is_file() and p.stat().st_size <= 8*1024*1024, 'input_missing')
    return p.read_bytes()
def hashes(names): return {n:sha(read(n)) for n in sorted(names)}
def exact(a,b,category): need(a == b, category)
def load_json(name): return json.loads(read(name))
def exclusive(name,value):
    with path(name).open('xb') as f:
        f.write(canonical(value)+b'\n'); f.flush(); os.fsync(f.fileno())
raw = read(OLD_HELPER)
need(sha(raw)==HELPER_SHA,'historical_drift')
H = types.ModuleType('phase94_capture'); H.__file__=str(ROOT/OLD_HELPER)
exec(compile(raw,H.__file__,'exec'),H.__dict__)
BASE = list(H.BASE_METHODS)
FULL = list(dict.fromkeys(BASE+NEGATIVE+FIELD+LIFE+PROVIDER_METHODS+DEGRADE))
need(len(BASE)==9 and len(FULL)==41,'method_manifest')

GROUPS = {'outside':(128,512),'height':(64,256),'face':(64,256),'background':(0,0),'watermark':(0,0)}
METRICS = {'source_changed','source_rgb','neutral_changed','neutral_rgb','source_margin','neutral_margin','positive_margin','size_plus_margin','size_minus_margin'} | {g+'_'+v for g in GROUPS for v in ('changed','rgb')}
def predicates(m):
    p={}
    for ref in ('source','neutral'):
        p['P94N_NEG_'+ref.upper()+'_SIGNAL']=m[ref+'_changed']>=500 and m[ref+'_rgb']>=2000
        p['P94N_NEG_'+ref.upper()+'_SIGN']=m[ref+'_margin']<=-16
    for ref,marker in [('positive','POS'),('size_plus','SIZE_PLUS'),('size_minus','SIZE_MINUS')]:
        p['P94N_NEG_'+marker+'_DISTINCT']=m[ref+'_margin']>=16
    for group,limits in GROUPS.items():
        for key,limit in zip(('changed','rgb'),limits):
            p['P94N_NEG_'+group.upper()+'_'+key.upper()]=0<=m[group+'_'+key]<=limit
    return p

def sample_negative():
    m={k:0 for k in METRICS}
    m.update(source_changed=500,neutral_changed=500,source_rgb=2000,neutral_rgb=2000,source_margin=-16,neutral_margin=-16,positive_margin=16,size_plus_margin=16,size_minus_margin=16)
    return {'case':'negative','comparisons':COMPARISONS,'metrics':m,'predicates':predicates(m)}
SEMANTIC=set(predicates(sample_negative()['metrics']))
FIELD_MARKERS={'P94N_FIELD_CROSSING','P94N_FIELD_INTERIOR_REVERSAL'}
META={'P94N_META_'+k for k in ('COLOR','EXTENT','ALPHA','REPEAT','CAP','ORIENTATION','MIRROR','RECOVERY','REASONS')}
STAGES={'P94N_STAGE_'+k for k in ('SOURCE','DETECT','RESULT','LEGACY','EXTRACT','METRIC','RECEIPT')}
def negative_record(v):
    need(type(v) is dict and set(v)=={'case','comparisons','metrics','predicates'},'aggregate_schema')
    need(v['case']=='negative' and v['comparisons']==COMPARISONS,'aggregate_schema')
    m=v['metrics']; need(type(m) is dict and set(m)==METRICS,'aggregate_schema')
    need(all(type(x) is int and -(2**63)<x<2**63 for x in m.values()),'aggregate_schema')
    need(all(m[k]>=0 for k in m if k not in ('source_margin','neutral_margin')),'aggregate_schema')
    need(type(v['predicates']) is dict and all(type(x) is bool for x in v['predicates'].values()),'aggregate_schema')
    exact(v['predicates'],predicates(m),'aggregate_schema')
    return v

def classify(output,code,method):
    need(code in (0,1) and not re.search(r'\bskipped\b',output,re.I),'child_failure')
    identity=method.replace('/',' ')
    starts=re.findall(r"^Test Case '-\[([^\]]+)\]' started\.$",output,re.M)
    ends=re.findall(r"^Test Case '-\[([^\]]+)\]' (passed|failed) \([0-9.]+ seconds\)\.$",output,re.M)
    sums=re.findall(r'Executed (\d+) tests?, with (\d+) failures? \((\d+) unexpected\)',output)
    need(starts==[identity] and len(ends)==1 and ends[0][0]==identity and sums and len(set(sums))==1 and sums[0][0]=='1' and sums[0][2]=='0','completion_failure')
    need(len(re.findall(r'^Test Case ',output,re.M))==2,'completion_failure')
    records=[]
    for line in output.splitlines():
        if 'P94N_AGGREGATE' in line:
            need(line.startswith('P94N_AGGREGATE '),'aggregate_schema')
            records.append(negative_record(json.loads(line[len('P94N_AGGREGATE '):])))
    if method==NEGATIVE[-1]: need(len(records)==1,'aggregate_schema')
    else: need(not records,'aggregate_schema')
    failure_lines=[line for line in output.splitlines() if re.search(r'\berror:|XCTAssert\w* failed|XCTFail failed',line)]
    markers=[]
    for line in failure_lines:
        found=re.findall(r'\bP94N_[A-Z_]+\b',line)
        need(len(found)==1 and found[0] in SEMANTIC|FIELD_MARKERS|META|STAGES,'unknown_failure')
        markers.append(found[0])
    allowed=SEMANTIC if method==NEGATIVE[-1] else FIELD_MARKERS if method==FIELD[2] else set()
    failures=int(sums[0][1])
    if records:
        expected={k for k,v in records[0]['predicates'].items() if not v}
        exact(set(markers),expected,'assertion_mismatch')
    need(failures==len(markers) and len(set(markers))==len(markers),'assertion_mismatch')
    need(set(markers)<=allowed,'assertion_failure')
    need((code==0 and failures==0 and ends[0][1]=='passed') or (code==1 and failures>0 and ends[0][1]=='failed'),'completion_failure')
    return {'method':method,'status':'semantic_fail' if failures else 'pass','assertion_failures':failures,'markers':sorted(markers),'records':records}

def strip_candidate(raw):
    text=raw.decode()
    need(text.count(DISPATCH)==1 and text.count(HELPER_START)==1 and text.count(HELPER_END)==1,'provider_scope')
    start=text.index(HELPER_START); end=text.index(HELPER_END,start)+len(HELPER_END)
    body=text[start+len(HELPER_START):end-len(HELPER_END)]
    need(body.startswith('    private func phase94NegativeWidth') and '\n    public ' not in body and '#if' not in body and '#else' not in body and 'extension ' not in body,'provider_scope')
    # Entire original file must survive byte-for-byte; helper has one top-level function.
    depth=0
    for char in body:
        if char=='{': depth+=1
        if char=='}': depth-=1
        need(depth>=0,'provider_scope')
    need(depth==0 and len(re.findall(r'^    (?:private |internal |public )?func ',body,re.M))==1,'provider_scope')
    return (text[:start]+text[end:]).replace(DISPATCH,'').encode()

def attempt_number(requested,used): need(requested in (1,2) and requested==used+1,'attempt_budget')
def receipt(name): return P+'94-'+name+'.json'
def event_sha(e): return sha(canonical(e))
def event_last(events,kind):
    matches=[e for e in events if e['kind']==kind]
    need(matches,'state_failure'); return matches[-1]

def history(binding):
    raw=read(EVENTS); need(raw.endswith(b'\n'),'event_history')
    events=[json.loads(x) for x in raw.splitlines()]
    prev=sha(read(BINDING))
    for i,e in enumerate(events):
        need(set(e)=={'sequence','previous','kind','data'} and e['sequence']==i+1 and e['previous']==prev,'event_history')
        need(e['kind'] in {'seed','build_started','build_finished','freeze','lane_started','method','lane_finished','hold','select','begin','compile_started','compile_finished','seal','rollback','review','behavior','qualification','finalize'},'event_history')
        prev=event_sha(e)
    need(events and events[0]['kind']=='seed' and events[0]['data']['binding']==sha(read(BINDING)),'event_history')
    return events

def append(events,kind,data):
    # Compare the complete current history immediately before append; never truncate.
    current=read(EVENTS) if path(EVENTS).exists() else b''
    expected=b''.join(canonical(e)+b'\n' for e in events)
    exact(current,expected,'concurrent_history')
    e={'sequence':len(events)+1,'previous':event_sha(events[-1]) if events else sha(read(BINDING)),'kind':kind,'data':data}
    with path(EVENTS).open('ab' if events else 'xb') as f:
        f.write(canonical(e)+b'\n'); f.flush(); os.fsync(f.fileno())
    events.append(e); return e

def tracked_inputs():
    result=subprocess.run(['git','ls-files','-z'],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=5,check=True)
    names=result.stdout.decode().split('\0')
    return sorted(n for n in names if n and (n.startswith('BeautySDK/Sources/') or n.startswith('BeautySDK/Tests/') or n=='BeautySDK/Package.swift' or n.startswith(P) or (n.startswith('scripts/') and ('phase94' in n or n in (H.MANIFEST,H.COMPARATOR)))) and n not in NEW_TESTS and n not in (REL,BINDING,EVENTS))

def snapshot():
    b=load_json(BINDING); need(b['schema']=='phase94.remaining-binding.1','binding_failure')
    exact(hashes(b['historical']),b['historical'],'historical_drift')
    exact(hashes(b['current']),b['current'],'authority_drift')
    current_sdk={str(p.relative_to(ROOT)) for folder in ('BeautySDK/Sources','BeautySDK/Tests') for p in (ROOT/folder).rglob('*.swift')}
    need(current_sdk-{PROVIDER}-NEW_TESTS <= set(b['current']),'authority_drift')
    exact(sha(read(REL)),b['runner'],'runner_drift')
    events=history(b)
    for e in events:
        if e['kind']=='freeze': exact(hashes(e['data']['inputs']),e['data']['inputs'],'frozen_drift')
    begins=[e for e in events if e['kind']=='begin']
    need([e['data']['attempt'] for e in begins]==list(range(1,len(begins)+1)) and len(begins)<=2,'attempt_budget')
    return b,events

def live_inputs(events):
    result={REL:sha(read(REL))}
    for e in events:
        if e['kind']=='freeze': result.update(e['data']['inputs'])
    return dict(sorted(result.items()))

def open_state(events):
    need(not any(e['kind']=='hold' for e in events),'terminal_hold')
    starts=[e for e in events if e['kind'] in ('lane_started','compile_started','build_started')]
    for e in starts:
        terminal={'lane_started':'lane_finished','compile_started':'compile_finished','build_started':'build_finished'}[e['kind']]
        need(any(x['kind']==terminal and x['data'].get('start')==event_sha(e) for x in events),'interrupted_hold')

def review_header(name,schema,expected):
    text=read(name).decode(); blocks=re.findall(r'```json\s*\n(.*?)\n```',text,re.S)
    need(len(blocks)==1,'review_failure'); value=json.loads(blocks[0])
    exact(value,dict(schema=schema,reviewer_role='independent-parent',verdict='PASS',unresolved_blockers=0,**expected),'review_failure')
    return sha(read(name))

def seed():
    if path(BINDING).exists():
        b,e=snapshot(); return {'status':'seed_verified','events':len(e),'native_tests':0}
    need(not path(EVENTS).exists(),'event_history')
    exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope'); exact(sha(read(METADATA)),METADATA_SHA,'historical_drift')
    exact(sha(read('scripts/check-phase94-metadata-recovery.py')),'32d982b3d5cc35c733b2bdda6b59b6603700aa19aacdb7a601898583ca62de18','historical_drift')
    code,out=H.child([sys.executable,'scripts/check-phase94-metadata-recovery.py','status'],10)
    need(code==0,'historical_status'); status=json.loads(out)
    need(status.get('status')=='prerequisite_green_phase_incomplete','historical_status')
    old=load_json(METADATA)
    exact(old['counts'],{'discovered':9,'executed':9,'passed':9,'failed':0,'skipped':0,'unexecuted':0},'historical_counts')
    need(old['counters']['implementation_attempts']==0 and old['negative_pixels']=='not_measured','counter_reset')
    names=tracked_inputs(); historical=[n for n in names if not n.startswith('BeautySDK/')]
    current=[n for n in names if n.startswith('BeautySDK/') and n!=PROVIDER]
    # Include untracked existing Swift files, but never accidentally pin future owned tests.
    current=sorted(set(current)|{str(p.relative_to(ROOT)) for folder in ('BeautySDK/Sources','BeautySDK/Tests') for p in (ROOT/folder).rglob('*.swift') if str(p.relative_to(ROOT)) not in NEW_TESTS|{PROVIDER}})
    b={'schema':'phase94.remaining-binding.1','historical':hashes(historical),'current':hashes(current),'provider':ORIGINAL,'runner':sha(read(REL)),'metadata_receipt':METADATA_SHA,'research_passes':1,'checked_plan_sets':1,'implementation_attempt_limit':2,'seed_attempts':0,'self_tests':self_tests()}
    exclusive(BINDING,b); append([],'seed',{'binding':sha(read(BINDING)),'implementation_attempts':0,'negative_pixels':'not_measured'})
    return {'status':'seeded','pure_tests':16,'native_tests':0,'implementation_attempts':0}

def compile_child():
    try:
        code,out=H.child(['swift','build','--package-path','BeautySDK','--build-tests'],600)
        errors=len(re.findall(r'\berror:',out)); category='pass' if code==0 and errors==0 else 'compile_failure'
        if 'unable to type-check' in out: category='type_check_timeout'
        return {'exit_code':code,'error_count':errors,'category':category,'status':'pass' if category=='pass' else 'fail','tests_executed':0}
    except H.GateError as error:
        return {'exit_code':None,'error_count':0,'category':str(error),'status':'fail','tests_executed':0}

def author_build(batch,b,events):
    need(batch in ('oracle','field','lifecycle'),'batch_failure'); open_state(events)
    need(not any(e['kind']=='freeze' and set(BATCHES[batch])<=set(e['data']['inputs']) for e in events),'frozen_drift')
    need(sum(e['kind']=='build_started' and e['data']['batch']==batch for e in events)<2,'author_build_budget')
    exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope')
    inputs=hashes(BATCHES[batch]); start=append(events,'build_started',{'batch':batch,'inputs':inputs,'provider':ORIGINAL})
    result=compile_child()
    if hashes(inputs)!=inputs: result.update(status='fail',category='authority_drift')
    append(events,'build_finished',dict(result,start=event_sha(start),batch=batch,inputs=inputs))
    snapshot()
    return result

def frozen(events,batch):
    selected=[e for e in events if e['kind']=='freeze' and e['data']['batch']==batch]
    need(len(selected)==1,'review_missing'); return selected[0]

def freeze(batch,review,b,events):
    open_state(events); need(batch in ('oracle','safety'),'batch_failure')
    need(not any(e['kind']=='freeze' and e['data']['batch']==batch for e in events),'freeze_exists')
    inputs=hashes(BATCHES[batch]+[REL])
    for build_batch in (['oracle'] if batch=='oracle' else ['field','lifecycle']):
        builds=[e for e in events if e['kind']=='build_finished' and e['data']['batch']==build_batch]
        need(builds and builds[-1]['data']['status']=='pass' and builds[-1]['data']['inputs']==hashes(BATCHES[build_batch]),'compile_missing')
    exact(review,P+('94-02-TEST-REVIEW.md' if batch=='oracle' else '94-03-TEST-REVIEW.md'),'review_failure')
    rh=review_header(review,'phase94.test-review.1',{'inputs':inputs})
    append(events,'freeze',{'batch':batch,'inputs':inputs,'review':review,'review_sha256':rh})
    return {'status':'frozen','batch':batch,'inputs':inputs,'native_tests':0}

def provider_scope(events):
    current=sha(read(PROVIDER))
    if current==ORIGINAL:
        decision=load_json(receipt('CANDIDATE-DECISION'))
        need(decision['policy']=='retain_original','provider_scope'); return 'retain_original'
    begin=event_last(events,'begin'); n=begin['data']['attempt']; policy=begin['data']['policy']
    exact(sha(strip_candidate(read(PROVIDER))),ORIGINAL,'provider_scope')
    comp=load_json(receipt(f'CANDIDATE-{n:02d}-COMPILE'))
    expected={'attempt':n,'policy':policy,'begin_event_sha256':event_sha(begin),'provider_before_sha256':ORIGINAL,'provider_after_sha256':current,'frozen_inputs_sha256':sha(canonical(live_inputs(events))),'runner_sha256':sha(read(REL))}
    need(comp['schema']=='phase94.candidate-compile.1' and comp['status']=='pass' and comp['exit_code']==0 and comp['tests_executed']==0,'compile_failure')
    exact({k:comp[k] for k in expected},expected,'compile_stale')
    seal=event_last(events,'seal'); exact(seal['data']['attempt'],n,'review_failure')
    rn=P+f'94-CANDIDATE-{n:02d}-REVIEW.md'
    rh=review_header(rn,'phase94.candidate-review.1',dict(expected,compilation_receipt_sha256=sha(read(receipt(f'CANDIDATE-{n:02d}-COMPILE')))))
    exact(seal['data']['review_sha256'],rh,'review_failure')
    exact(seal['data']['provider'],current,'review_failure')
    return policy

def method_timeout(m):
    if m==BASE[5]: return 120
    if m==BASE[6]: return 360
    if m==NEGATIVE[-1] or m in (LIFE[0],LIFE[2],LIFE[3]): return 180
    if m==LIFE[1]: return 420
    return 60

def measure_lane(command,b,events):
    open_state(events); frozen(events,'oracle')
    if command!='negative-baseline': frozen(events,'safety')
    if command=='accept':
        provider_scope(events)
        if any(e['kind']=='begin' for e in events):
            begin=event_last(events,'begin')
            need(not any(e['kind']=='lane_started' and e['data']['lane']=='accept' and e['sequence']>begin['sequence'] for e in events),'measurement_exists')
    else: exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope')
    need(not any(e['kind']=='lane_started' and e['data']['lane']==command and e['data']['provider']==sha(read(PROVIDER)) for e in events),'measurement_exists')
    methods=BASE+NEGATIVE if command=='negative-baseline' else FULL
    outname=receipt({'negative-baseline':'NEGATIVE-BASELINE','full-baseline':'FULL-BASELINE','accept':'REMAINING-CHECKS'}[command])
    need(not path(outname).exists(),'receipt_exists')
    inputs=live_inputs(events); provider=sha(read(PROVIDER)); start=append(events,'lane_started',{'lane':command,'inputs':inputs,'provider':provider,'methods':methods})
    counts={'discovered':0,'executed':0,'passed':0,'failed':0,'skipped':0,'unexecuted':len(methods)}
    records=[]; oldrecords=[]; current=None; deadline=time.monotonic()+(2490 if command=='negative-baseline' else 4890)-30
    try:
        for args in (['swift','build','--package-path','BeautySDK','--build-tests'],['swift','test','--package-path','BeautySDK','list']):
            code,out=H.child(args,min(600,deadline-time.monotonic())); need(code==0,'child_failure')
        H.discover(out,methods); counts['discovered']=len(methods)
        for current in methods:
            code,out=H.child(['swift','test','--package-path','BeautySDK','--skip-build','--filter','^'+re.escape(current)+'$'],min(method_timeout(current),deadline-time.monotonic()))
            result=classify(out,code,current)
            oldrecords.extend(H.parse_aggregates(out))
            counts['executed']+=1; counts['unexecuted']-=1
            counts['failed' if result['status']=='semantic_fail' else 'passed']+=1
            records.append(result)
            append(events,'method',dict(result,lane=command,counts=dict(counts),provider=provider,inputs=inputs))
        historical=load_json(METADATA)['records']
        oldhash={v['case']:v['sha256'] for v in historical if 'sha256' in v}
        observed={v['case']:v['sha256'] for v in oldrecords if 'sha256' in v}
        exact(observed,oldhash,'retained_drift')
        exact(hashes(inputs),inputs,'frozen_drift'); exact(sha(read(PROVIDER)),provider,'provider_scope'); snapshot()
        value={'schema':'phase94.remaining-checks.1','lane':command,'status':'semantic_fail' if counts['failed'] else 'pass','counts':counts,'records':records,'inputs':inputs,'provider':provider,'start':event_sha(start),'implementation_attempts':sum(e['kind']=='begin' for e in events),'phase_complete':False,'historical_receipt':METADATA_SHA}
        if command!='accept' or not counts['failed']: exclusive(outname,value)
        append(events,'lane_finished',value)
        return value
    except (GateError,H.GateError,ValueError,OSError) as error:
        category=str(error) if isinstance(error,(GateError,H.GateError)) else 'infrastructure_failure'
        value={'status':'terminal_hold','category':category,'lane':command,'counts':counts,'method':current,'inputs':inputs,'provider':provider,'start':event_sha(start)}
        append(events,'hold',value); return value


def failed_markers(value): return {m for row in value['records'] for m in row['markers']}
def complete_counts(v):
    c=v['counts']; need(c['discovered']==41 and c['executed']==41 and c['unexecuted']==c['skipped']==0 and c['passed']+c['failed']==41,'incomplete_measurement')

def control(args,b,events):
    command=args.command
    if command=='status':
        return {'status':'terminal_hold' if any(e['kind']=='hold' for e in events) else events[-1]['kind'],'events':len(events),'provider':sha(read(PROVIDER)),'implementation_attempts':sum(e['kind']=='begin' for e in events),'phase_complete':False}
    if command=='rollback':
        begin=event_last(events,'begin'); attempt=begin['data']['attempt']
        comp=event_last(events,'compile_started')
        need(comp['data']['attempt']==attempt and any(e['kind'] in ('hold','compile_finished','lane_finished') and e['sequence']>comp['sequence'] and (e['kind']=='hold' or e['data'].get('status') in ('fail','semantic_fail')) for e in events),'rollback_state')
        current=sha(read(PROVIDER)); exact(current,comp['data']['provider_after_sha256'],'concurrent_provider')
        proc=subprocess.run(['git','show','624cee5a:'+PROVIDER],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=5,check=True)
        exact(sha(proc.stdout),ORIGINAL,'historical_drift'); exact(sha(read(PROVIDER)),current,'concurrent_provider')
        path(PROVIDER).write_bytes(proc.stdout); exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope')
        append(events,'rollback',{'attempt':attempt,'before':current,'after':ORIGINAL}); return {'status':'rolled_back'}
    open_state(events)
    if command=='scope': return {'status':'scope_pass','policy':provider_scope(events)}
    if command=='select':
        value=load_json(receipt('FULL-BASELINE')); complete_counts(value)
        exact(value['provider'],ORIGINAL,'provider_scope'); exact(value['inputs'],live_inputs(events),'frozen_drift')
        markers=failed_markers(value); need(markers<=SEMANTIC|FIELD_MARKERS,'ineligible_failure')
        policy='A' if markers else 'retain_original'
        decision={'policy':policy,'baseline':sha(read(receipt('FULL-BASELINE'))),'markers':sorted(markers),'inputs':live_inputs(events),'provider':ORIGINAL,'research_passes':1,'checked_plan_sets':1,'implementation_attempts':0}
        exclusive(receipt('CANDIDATE-DECISION'),decision); append(events,'select',decision); return decision
    if command=='begin':
        n=args.attempt; used=sum(e['kind']=='begin' for e in events); attempt_number(n,used)
        exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope'); decision=load_json(receipt('CANDIDATE-DECISION')); need(decision['policy']=='A','attempt_state')
        if n==2:
            rollback=event_last(events,'rollback'); need(rollback['data']['attempt']==1,'attempt_state')
            failed=event_last(events,'lane_finished')['data']; complete_counts(failed)
            need(failed['lane']=='accept' and failed['status']=='semantic_fail','attempt_state')
            need(failed_markers(failed) and failed_markers(failed)<={'P94N_NEG_SOURCE_SIGNAL','P94N_NEG_NEUTRAL_SIGNAL','P94N_NEG_SOURCE_SIGN','P94N_NEG_NEUTRAL_SIGN'},'ineligible_failure')
        data={'attempt':n,'policy':'A' if n==1 else 'B','provider_before_sha256':ORIGINAL,'inputs':live_inputs(events)}
        append(events,'begin',data); return dict(data,status='attempt_open')
    if command in ('candidate-compile','seal'):
        begin=event_last(events,'begin'); n=args.attempt; need(begin['data']['attempt']==n,'attempt_state')
        exact(sha(strip_candidate(read(PROVIDER))),ORIGINAL,'provider_scope')
        data={'attempt':n,'policy':begin['data']['policy'],'begin_event_sha256':event_sha(begin),'provider_before_sha256':ORIGINAL,'provider_after_sha256':sha(read(PROVIDER)),'frozen_inputs_sha256':sha(canonical(live_inputs(events))),'runner_sha256':sha(read(REL))}
        cn=receipt(f'CANDIDATE-{n:02d}-COMPILE')
        if command=='candidate-compile':
            need(not path(cn).exists() and not any(e['kind']=='compile_started' and e['data']['attempt']==n for e in events),'compile_exists')
            start=append(events,'compile_started',data); result=compile_child()
            if sha(read(PROVIDER))!=data['provider_after_sha256']: result.update(status='fail',category='provider_scope')
            value=dict(data,schema='phase94.candidate-compile.1',exit_code=result['exit_code'],status=result['status'],tests_executed=0)
            exclusive(cn,value); append(events,'compile_finished',dict(result,start=event_sha(start),attempt=n,receipt_sha256=sha(read(cn))))
            snapshot()
            if result['status']!='pass': append(events,'hold',{'category':result['category'],'attempt':n})
            return result
        comp=load_json(cn); exact(comp,dict(data,schema='phase94.candidate-compile.1',exit_code=0,status='pass',tests_executed=0),'compile_stale')
        rn=P+f'94-CANDIDATE-{n:02d}-REVIEW.md'; exact(args.review,rn,'review_failure')
        rh=review_header(rn,'phase94.candidate-review.1',dict(data,compilation_receipt_sha256=sha(read(cn))))
        need(not any(e['kind']=='seal' and e['data']['attempt']==n for e in events),'seal_exists')
        append(events,'seal',{'attempt':n,'provider':data['provider_after_sha256'],'review_sha256':rh}); return {'status':'sealed','attempt':n}
    # Closeout is a separate parent-authored evidence chain, with no native child.
    checks=load_json(receipt('REMAINING-CHECKS')); complete_counts(checks)
    need(checks['status']=='pass' and checks['counts']['failed']==0,'checks_failure')
    exact(checks['provider'],sha(read(PROVIDER)),'checks_stale'); exact(checks['inputs'],live_inputs(events),'checks_stale'); provider_scope(events)
    accepted={'checks_sha256':sha(read(receipt('REMAINING-CHECKS'))),'provider_sha256':sha(read(PROVIDER)),'inputs':live_inputs(events)}
    if command=='review':
        exact(args.file,P+'94-IMPLEMENTATION-REVIEW.md','review_failure')
        rh=review_header(args.file,'phase94.implementation-review.1',dict(accepted,high_security_findings=0))
        append(events,'review',dict(accepted,review_sha256=rh)); return {'status':'review_bound'}
    reviewed=event_last(events,'review')['data']; exact({k:reviewed[k] for k in accepted},accepted,'review_stale')
    exact(reviewed['review_sha256'],sha(read(P+'94-IMPLEMENTATION-REVIEW.md')),'review_stale')
    if command=='owners':
        names=OWNERS[:4] if args.group=='behavior' else OWNERS
        for name in names:
            text=read(name).decode(); sections=re.findall(r'(?im)^##? .*Phase\s*94.*$',text)
            need(sections,'owner_section_missing')
            # Fixed facts must be explicitly present in the Phase94 tail.
            tail=text[text.rfind(sections[-1]):]
            need('MOUTH-01' in tail and 'Phase95' in tail and ('no-skip' in tail) and accepted['checks_sha256'] in tail,'owner_contract')
        if args.group=='qualification':
            plans=read('PLANS.md').decode()
            need('Status: verifying (snapshot before independent goal decision)' in plans and '94-REMAINING-COMPLETE.json' in plans and 'incomplete' in plans,'owner_contract')
        owner_map=hashes(names); append(events,args.group,dict(accepted,owners=owner_map,review_sha256=reviewed['review_sha256']))
        return {'status':'owners_bound','group':args.group,'owners':owner_map}
    need(command=='finalize','command_failure')
    bound=event_last(events,'qualification'); owner_map=bound['data']['owners']; exact(hashes(OWNERS),owner_map,'owner_drift')
    expected=dict(accepted,owners=owner_map,owner_event_sha256=event_sha(bound),implementation_review_sha256=reviewed['review_sha256'],all_truths=True,phase_complete=True)
    rh=review_header(args.goal,'phase94.goal-review.1',expected)
    value=dict(expected,schema='phase94.remaining-complete.1',goal_sha256=rh,status='complete')
    exact(hashes(OWNERS),owner_map,'owner_drift'); exclusive(receipt('REMAINING-COMPLETE'),value); exact(hashes(OWNERS),owner_map,'owner_drift')
    append(events,'finalize',{'receipt_sha256':sha(read(receipt('REMAINING-COMPLETE'))),'owners':owner_map}); return {'status':'complete','phase_complete':True}

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command',choices=['self-test','seed','author-build','freeze','negative-baseline','full-baseline','select','begin','candidate-compile','seal','scope','status','accept','rollback','review','owners','finalize'])
    parser.add_argument('--batch',choices=list(BATCHES)); parser.add_argument('--attempt',type=int,choices=[1,2]); parser.add_argument('--review'); parser.add_argument('--file'); parser.add_argument('--group',choices=['behavior','qualification']); parser.add_argument('--goal')
    args=parser.parse_args()
    if args.command=='self-test': value=self_tests()
    elif args.command=='seed': value=seed()
    else:
        b,events=snapshot()
        if args.command=='author-build': value=author_build(args.batch,b,events)
        elif args.command=='freeze': value=freeze(args.batch,args.review,b,events)
        elif args.command in ('negative-baseline','full-baseline','accept'): value=measure_lane(args.command,b,events)
        else: value=control(args,b,events)
    print(json.dumps(value,sort_keys=True))
    return 1 if value.get('status') in ('fail','terminal_hold') else 0

if __name__=='__main__':
    try: sys.exit(main())
    except (GateError,H.GateError,OSError,ValueError,TypeError,KeyError,AssertionError,subprocess.SubprocessError) as error:
        category=str(error) if isinstance(error,(GateError,H.GateError)) else 'infrastructure_failure'
        print(json.dumps({'status':'gate_rejected','category':category,'phase_complete':False},sort_keys=True)); sys.exit(1)
