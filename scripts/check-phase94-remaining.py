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
import tempfile
import time
import types

ROOT = Path(__file__).resolve().parent.parent
P = '.planning/phases/94-negative-mouth-width-repair/'
REL = 'scripts/check-phase94-remaining.py'
BINDING = P+'94-REMAINING-BINDING.json'
EVENTS = P+'94-REMAINING-EVENTS.jsonl'
SEEDED = P+'94-REMAINING-RUNNER-SEEDED.py'
DISPOSITION = P+'94-REMAINING-AUTHORING-DISPOSITION.json'
RUNNER_REVIEW = P+'94-REMAINING-RUNNER-REVIEW.md'
SEEDED_SHA = 'a72b2f3a0abb4bcef7340a85bd5be133612f0cfd3a9a9b4cf2684228ee6cd9ac'
SEED_BINDING_SHA = '6b7785547dd2b74ce9ec2ff965e5fc2e77135f080cee8971bca033b52725470b'
SEED_EVENTS_SHA = 'b92a2b38857999d9557eebed44df5a5f72bc0c49f1b94c08660a4fd2780c001a'
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
def exact(a,b,category):
    if isinstance(a,bytes) or isinstance(b,bytes):
        need(type(a) is bytes and type(b) is bytes and a == b,category)
    else:
        need(canonical(a) == canonical(b),category)
def decode_json(raw):
    def unique(pairs):
        value={}
        for key,item in pairs:
            need(key not in value,'duplicate_key'); value[key]=item
        return value
    try:
        return json.loads(raw,object_pairs_hook=unique,parse_constant=lambda _: need(False,'json_constant'))
    except (ValueError,UnicodeError):
        raise GateError('json_schema') from None
def load_json(name): return decode_json(read(name))
def exclusive(name,value):
    destination=path(name)
    need(not destination.exists(),'receipt_exists')
    temporary=None
    try:
        with tempfile.NamedTemporaryFile(dir=destination.parent,prefix='.phase94-',delete=False) as f:
            temporary=Path(f.name)
            f.write(canonical(value)+b'\n'); f.flush(); os.fsync(f.fileno())
        # link is atomic and refuses to overwrite a concurrently created name.
        os.link(temporary,destination,follow_symlinks=False)
        descriptor=os.open(destination.parent,os.O_RDONLY)
        try: os.fsync(descriptor)
        finally: os.close(descriptor)
    finally:
        if temporary is not None: temporary.unlink(missing_ok=True)
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
    execution=execution_evidence(output,method)
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
            records.append(negative_record(decode_json(line[len('P94N_AGGREGATE '):])))
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
        exact(sorted(set(markers)),sorted(expected),'assertion_mismatch')
    need(failures==len(markers) and len(set(markers))==len(markers),'assertion_mismatch')
    need(set(markers)<=allowed,'assertion_failure')
    need((code==0 and failures==0 and ends[0][1]=='passed') or (code==1 and failures>0 and ends[0][1]=='failed'),'completion_failure')
    return {'method':method,'status':'semantic_fail' if failures else 'pass','assertion_failures':failures,'markers':sorted(markers),'records':records,'execution':execution}

def execution_evidence(output,method):
    """Trusted bounded counts survive classification failure. A launched child
    with no complete transcript is unknown, never silently unexecuted."""
    identity=re.escape(method.replace('/',' '))
    starts=len(re.findall(r"^Test Case '-\["+identity+r"\]' started\.$",output,re.M))
    ends=re.findall(r"^Test Case '-\["+identity+r"\]' (passed|failed|skipped) \([0-9.]+ seconds\)\.$",output,re.M)
    known=starts==1 and len(ends)==1
    return dict(launched=True,started=starts,ended=len(ends),executed=int(known),
        passed=int(known and ends[0]=='passed'),failed=int(known and ends[0]=='failed'),
        skipped=int(known and ends[0]=='skipped'),completion_unknown=not known)

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
    events=[decode_json(x) for x in raw.splitlines()]
    prev=sha(read(BINDING))
    for i,e in enumerate(events):
        need(set(e)=={'sequence','previous','kind','data'} and e['sequence']==i+1 and e['previous']==prev,'event_history')
        need(e['kind'] in {'seed','authoring','build_started','build_finished','freeze','lane_started','method','lane_finished','hold','select','begin','compile_started','compile_finished','seal','rollback','review','behavior','qualification','finalize'},'event_history')
        prev=event_sha(e)
    need(events and events[0]['kind']=='seed' and events[0]['data']['binding']==sha(read(BINDING)),'event_history')
    replay(events)
    return events

# One storage boundary is shared by disk admission and the in-memory adversarial
# tests. Receipts are evidence only when exactly one legal event binds their bytes.
def bound_receipt(name, events, reader=None):
    reader=reader or read
    raw=reader(name); value=decode_json(raw)
    matches=[e for e in events if e['data'].get('receipt')==name]
    need(len(matches)==1,'receipt_event')
    event=matches[0]; data=event['data']
    exact(data['receipt_sha256'],sha(raw),'receipt_hash')
    expected_kind = ('select' if name==receipt('CANDIDATE-DECISION') else
                     'compile_finished' if re.fullmatch(re.escape(P)+r'94-CANDIDATE-0[12]-COMPILE.json',name) else
                     'finalize' if name==receipt('REMAINING-COMPLETE') else 'lane_finished')
    exact(event['kind'],expected_kind,'receipt_event')
    exact(value,data['value'],'receipt_content')
    return value

def publish(events, kind, name, value, **extra):
    raw=canonical(value)+b'\n'
    data=dict(extra,receipt=name,receipt_sha256=sha(raw),value=value)
    prospective(events,kind,data,lambda n: raw if n==name else read(n))
    exclusive(name,value)
    return append(events,kind,data)

def validate_published(events):
    # Publication interrupted before event binding is an explicit hold, never
    # completion or a receipt that can authorize another command.
    for name in ('NEGATIVE-BASELINE','FULL-BASELINE','CANDIDATE-DECISION',
                 'CANDIDATE-01-COMPILE','CANDIDATE-02-COMPILE','REMAINING-CHECKS','REMAINING-COMPLETE'):
        target=receipt(name)
        if path(target).exists(): bound_receipt(target,events)

def fields(value, keys):
    need(type(value) is dict and set(value)==set(keys.split()),'event_schema')

def replay(events, reader=None):
    """Strict, small phase-specific transition replay; never infers permission
    from an isolated receipt or the last event's label. In-flight tails are
    representable but cannot authorize another operation."""
    reader=reader or read
    need(events and events[0]['kind']=='seed','event_history')
    state={'active':None,'hold':False,'frozen':{},'lanes':{},'attempt':0,
           'decision':None,'compile':None,'seal':None,'rollback':False,
           'review':None,'behavior':None,'qualification':None,'complete':None}
    builds={}; finished_builds={}; seen_lanes=set(); rows=[]
    schemas={
      'seed':'binding implementation_attempts negative_pixels',
      'authoring':'disposition_sha256 runner_sha256 review_sha256',
      'build_started':'batch inputs provider',
      'build_finished':'exit_code error_count category status tests_executed start batch inputs',
      'freeze':'batch inputs review review_sha256',
      'lane_started':'lane inputs provider methods',
      'method':'method status assertion_failures markers records execution lane counts provider inputs',
      'lane_finished':'receipt receipt_sha256 value',
      'select':'receipt receipt_sha256 value',
      'begin':'attempt policy provider_before_sha256 inputs',
      'compile_started':'attempt policy begin_event_sha256 provider_before_sha256 provider_after_sha256 frozen_inputs_sha256 runner_sha256',
      'compile_finished':'receipt receipt_sha256 value start category',
      'seal':'attempt provider review_sha256',
      'rollback':'attempt before after',
      'review':'checks_sha256 provider_sha256 inputs review_sha256',
      'behavior':'checks_sha256 provider_sha256 inputs owners review_sha256',
      'qualification':'checks_sha256 provider_sha256 inputs owners review_sha256',
      'finalize':'receipt receipt_sha256 value goal',
    }
    previous=sha(reader(BINDING))
    for index,event in enumerate(events):
        fields(event,'sequence previous kind data')
        exact(event['sequence'],index+1,'event_history'); exact(event['previous'],previous,'event_history')
        previous=event_sha(event); kind=event['kind']; d=event['data']
        need(kind in schemas or kind=='hold','event_schema')
        need(not state['complete'],'completion_terminal')
        if kind=='hold':
            fields(d,'category start lane counts method execution inputs provider' if 'lane' in d else 'category attempt')
            need(type(d['category']) is str and re.fullmatch(r'[a-z][a-z0-9_]{0,63}',d['category']),'event_schema')
            need(state['active'] is not None or state['compile'] is not None or
                 (index>0 and events[index-1]['kind']=='build_finished' and events[index-1]['data']['status']=='fail'),'hold_state')
            if 'lane' in d:
                active=state['active']; need(active and active['kind']=='lane_started','hold_state')
                exact(d['start'],event_sha(active),'start_state')
                for key in ('lane','inputs','provider'): exact(d[key],active['data'][key],'hold_state')
                methods=active['data']['methods']; expected=lane_counts(rows,len(methods))
                if not rows and d['method'] is None: expected['discovered']=0
                if d['execution'] is not None:
                    need(len(rows)<len(methods),'method_state'); exact(d['method'],methods[len(rows)],'method_order')
                    ex=d['execution']; fields(ex,'launched started ended executed passed failed skipped completion_unknown')
                    need(ex['launched'] is True and type(ex['completion_unknown']) is bool,'execution_schema')
                    need(all(type(ex[k]) is int and ex[k]>=0 for k in ('started','ended','executed','passed','failed','skipped')),'execution_schema')
                    need(ex['executed']==ex['passed']+ex['failed']+ex['skipped']==int(not ex['completion_unknown']),'execution_schema')
                    expected['unexecuted']-=1; expected['completion_unknown']=int(ex['completion_unknown'])
                    for key in ('executed','passed','failed','skipped'): expected[key]+=ex[key]
                exact(d['counts'],expected,'count_state')
            else: exact(d['attempt'],state['attempt'],'attempt_state')
            state['hold']=True; state['active']=None; continue
        fields(d,schemas[kind])
        need(not state['hold'] or kind=='rollback','terminal_hold')
        active=state['active']
        if active:
            allowed={'build_started':{'build_finished'},'compile_started':{'compile_finished'},'lane_started':{'method','lane_finished'}}
            need(kind in allowed[active['kind']],'interrupted_hold')
        if kind=='seed':
            need(index==0,'seed_state')
            exact(d,dict(binding=sha(reader(BINDING)),implementation_attempts=0,negative_pixels='not_measured'),'seed_state')
        elif kind=='authoring':
            need(index==1 and not state['frozen'] and state['attempt']==0,'authoring_state')
        elif kind=='build_started':
            batch=d['batch']; need(batch in ('oracle','field','lifecycle') and 'full-baseline' not in state['lanes'] and not state['attempt'],'build_state')
            need(not any(set(BATCHES[batch])<=set(f['inputs']) for f in state['frozen'].values()),'frozen_drift')
            builds[batch]=builds.get(batch,0)+1; need(builds[batch]<=2,'author_build_budget')
            exact(set_keys(d['inputs']),sorted(BATCHES[batch]),'event_schema'); exact(d['provider'],ORIGINAL,'provider_scope')
            state['active']=event
        elif kind=='build_finished':
            need(active and active['kind']=='build_started','build_state')
            exact(d['start'],event_sha(active),'start_state'); exact(d['batch'],active['data']['batch'],'build_state')
            exact(d['inputs'],active['data']['inputs'],'build_state')
            need(d['status'] in ('pass','fail') and d['tests_executed']==0,'build_state')
            if d['status']=='pass': need(d['exit_code']==0 and d['error_count']==0 and d['category']=='pass','build_state')
            finished_builds[d['batch']]=d; state['active']=None
        elif kind=='freeze':
            batch=d['batch']; need(batch in ('oracle','safety') and batch not in state['frozen'] and not state['attempt'],'freeze_state')
            exact(set_keys(d['inputs']),sorted(BATCHES[batch]+[REL]),'event_schema')
            for bb in (['oracle'] if batch=='oracle' else ['field','lifecycle']):
                built=finished_builds.get(bb); need(built and built['status']=='pass','compile_missing')
                exact(built['inputs'],{n:d['inputs'][n] for n in BATCHES[bb]},'compile_stale')
            state['frozen'][batch]=d
        elif kind=='lane_started':
            lane=d['lane']; need(lane in ('negative-baseline','full-baseline','accept'),'lane_state')
            need('oracle' in state['frozen'],'review_missing')
            if lane!='negative-baseline': need('safety' in state['frozen'] and 'negative-baseline' in state['lanes'],'lane_order')
            if lane=='accept':
                need(state['decision'] is not None and (state['decision']['policy']=='retain_original' or state['seal'] is not None),'seal_missing')
                exact(d['provider'],ORIGINAL if state['decision']['policy']=='retain_original' else state['compile']['provider_after_sha256'],'provider_scope')
                need(not state['rollback'],'attempt_state')
            else: need(state['attempt']==0 and state['decision'] is None and d['provider']==ORIGINAL,'provider_scope')
            identity=(lane,d['provider']); need(identity not in seen_lanes,'measurement_exists'); seen_lanes.add(identity)
            exact(d['methods'],BASE+NEGATIVE if lane=='negative-baseline' else FULL,'method_manifest')
            exact(d['inputs'],replay_inputs(state,reader),'frozen_drift')
            state['active']=event; rows=[]
        elif kind=='method':
            need(active and active['kind']=='lane_started' and len(rows)<len(active['data']['methods']),'method_state')
            exact(d['method'],active['data']['methods'][len(rows)],'method_order')
            for k in ('lane','inputs','provider'): exact(d[k],active['data'][k],'method_state')
            need(d['status'] in ('pass','semantic_fail'),'method_state')
            need(d['execution']['executed']==1 and not d['execution']['completion_unknown'],'completion_failure')
            fields(d['execution'],'launched started ended executed passed failed skipped completion_unknown')
            exact(d['execution'],dict(launched=True,started=1,ended=1,executed=1,passed=int(d['status']=='pass'),failed=int(d['status']=='semantic_fail'),skipped=0,completion_unknown=False),'completion_failure')
            need(type(d['markers']) is list and len(d['markers'])==len(set(d['markers'])) and d['assertion_failures']==len(d['markers']),'assertion_mismatch')
            allowed=SEMANTIC if d['method']==NEGATIVE[-1] else FIELD_MARKERS if d['method']==FIELD[2] else set()
            need(set(d['markers'])<=allowed,'assertion_failure')
            exact(d['status'],'semantic_fail' if d['markers'] else 'pass','assertion_mismatch')
            if d['method']==NEGATIVE[-1]:
                need(len(d['records'])==1,'aggregate_schema'); record=negative_record(d['records'][0])
                exact(sorted(k for k,v in record['predicates'].items() if not v),d['markers'],'assertion_mismatch')
            else: exact(d['records'],[],'aggregate_schema')
            rows.append({k:d[k] for k in ('method','status','assertion_failures','markers','records','execution')})
            exact(d['counts'],lane_counts(rows,len(active['data']['methods'])),'count_state')
        elif kind=='lane_finished':
            need(active and active['kind']=='lane_started','lane_state')
            v=bound_receipt(d['receipt'],events,reader) if d['receipt'] else d['value']
            if not d['receipt']: exact(d['receipt_sha256'],sha(canonical(v)),'receipt_hash')
            fields(v,'schema lane status counts records inputs provider start implementation_attempts phase_complete historical_receipt')
            exact(v['schema'],'phase94.remaining-checks.1','receipt_schema')
            exact(v['start'],event_sha(active),'start_state'); exact(v['records'],rows,'method_state')
            for k in ('lane','inputs','provider'): exact(v[k],active['data'][k],'lane_state')
            need(len(rows)==len(active['data']['methods']),'incomplete_measurement')
            exact(v['counts'],lane_counts(rows,len(rows)),'count_state')
            exact(v['status'],'semantic_fail' if v['counts']['failed'] else 'pass','lane_state')
            exact(v['implementation_attempts'],state['attempt'],'attempt_budget')
            exact(v['phase_complete'],False,'receipt_schema'); exact(v['historical_receipt'],METADATA_SHA,'historical_drift')
            name=receipt({'negative-baseline':'NEGATIVE-BASELINE','full-baseline':'FULL-BASELINE','accept':'REMAINING-CHECKS'}[v['lane']])
            exact(d['receipt'],None if v['lane']=='accept' and v['status']=='semantic_fail' else name,'receipt_event')
            state['lanes'][v['lane']]=v; state['active']=None
        elif kind=='select':
            need(state['decision'] is None and 'full-baseline' in state['lanes'],'select_state')
            exact(d['receipt'],receipt('CANDIDATE-DECISION'),'receipt_event')
            v=bound_receipt(d['receipt'],events,reader); baseline=state['lanes']['full-baseline']
            markers=failed_markers(baseline); need(markers<=SEMANTIC|FIELD_MARKERS,'ineligible_failure')
            exact(v,dict(policy='A' if markers else 'retain_original',baseline=sha(reader(receipt('FULL-BASELINE'))),markers=sorted(markers),inputs=baseline['inputs'],provider=ORIGINAL,research_passes=1,checked_plan_sets=1,implementation_attempts=0),'select_state')
            state['decision']=v
        elif kind=='begin':
            need(state['decision'] and state['decision']['policy']=='A','attempt_state')
            attempt_number(d['attempt'],state['attempt'])
            if d['attempt']==2:
                need(state['rollback'] and eligible_b(state['lanes'].get('accept')),'attempt_state')
            exact(d,dict(attempt=d['attempt'],policy='A' if d['attempt']==1 else 'B',provider_before_sha256=ORIGINAL,inputs=replay_inputs(state,reader)),'begin_state')
            state.update(attempt=d['attempt'],begin=event,compile=None,seal=None,rollback=False)
        elif kind=='compile_started':
            need(state['attempt'] and not state['compile'] and not state['rollback'],'compile_state')
            begin=state['begin']; exact(d['attempt'],state['attempt'],'attempt_state')
            exact(d['begin_event_sha256'],event_sha(begin),'begin_state'); exact(d['policy'],begin['data']['policy'],'attempt_state')
            exact(d['provider_before_sha256'],ORIGINAL,'provider_scope')
            exact(d['frozen_inputs_sha256'],sha(canonical(replay_inputs(state,reader))),'frozen_drift')
            exact(d['runner_sha256'],sha(reader(REL)),'runner_drift'); state['active']=event
        elif kind=='compile_finished':
            need(active and active['kind']=='compile_started','compile_state')
            exact(d['start'],event_sha(active),'start_state')
            exact(d['receipt'],receipt(f"CANDIDATE-{state['attempt']:02d}-COMPILE"),'receipt_event')
            v=bound_receipt(d['receipt'],events,reader)
            fields(v,'attempt policy begin_event_sha256 provider_before_sha256 provider_after_sha256 frozen_inputs_sha256 runner_sha256 schema exit_code status tests_executed')
            exact({k:v[k] for k in active['data']},active['data'],'compile_stale')
            need(v['schema']=='phase94.candidate-compile.1' and v['status'] in ('pass','fail') and v['tests_executed']==0,'compile_state')
            if v['status']=='pass': need(v['exit_code']==0 and d['category']=='pass','compile_state')
            state['compile']=v; state['active']=None
            if v['status']=='fail': state['hold']=True
        elif kind=='seal':
            need(state['compile'] and state['compile']['status']=='pass' and not state['seal'] and not state['rollback'],'seal_state')
            exact(d['attempt'],state['attempt'],'attempt_state'); exact(d['provider'],state['compile']['provider_after_sha256'],'compile_stale'); state['seal']=d
        elif kind=='rollback':
            failed=state['lanes'].get('accept',{})
            need(state['attempt'] and not state['rollback'] and (state['hold'] or (failed.get('status')=='semantic_fail' and failed.get('implementation_attempts')==state['attempt'])),'rollback_state')
            exact(d['attempt'],state['attempt'],'attempt_state'); exact(d['after'],ORIGINAL,'provider_scope')
            comp=state['compile']
            if comp: exact(d['before'],comp['provider_after_sha256'],'concurrent_provider')
            else:
                starts=[e for e in events[:index] if e['kind']=='compile_started']; need(starts,'rollback_state')
                exact(d['before'],starts[-1]['data']['provider_after_sha256'],'concurrent_provider')
            state['rollback']=True; state['seal']=None
        elif kind in ('review','behavior','qualification','finalize'):
            checks=state['lanes'].get('accept'); need(checks and checks['status']=='pass','checks_failure')
            accepted=dict(checks_sha256=sha(reader(receipt('REMAINING-CHECKS'))),provider_sha256=checks['provider'],inputs=checks['inputs'])
            if kind=='finalize':
                need(state['qualification'] and not state['complete'],'owner_binding_missing')
                exact(d['receipt'],receipt('REMAINING-COMPLETE'),'receipt_event')
                v=bound_receipt(d['receipt'],events,reader)
                fields(v,'checks_sha256 provider_sha256 inputs owners owner_event_sha256 implementation_review_sha256 all_truths phase_complete schema goal_sha256 status')
                q=state['qualification']
                expected=dict(accepted,owners=q['data']['owners'],owner_event_sha256=event_sha(q),implementation_review_sha256=state['review']['review_sha256'],all_truths=True,phase_complete=True,schema='phase94.remaining-complete.1',goal_sha256=sha(reader(d['goal'])),status='complete')
                exact(v,expected,'completion_stale'); state['complete']=v
            else:
                exact({k:d[k] for k in accepted},accepted,'checks_stale')
                need(state[kind] is None,'duplicate_closeout')
                if kind!='review':
                    need(state['review'] and (kind!='qualification' or state['behavior']),'review_missing')
                    exact(d['review_sha256'],state['review']['review_sha256'],'review_stale')
                    exact(set_keys(d['owners']),sorted(OWNERS[:4] if kind=='behavior' else OWNERS),'owner_schema')
                state[kind]=event if kind=='qualification' else d
    return state

def set_keys(value):
    need(type(value) is dict,'event_schema'); return sorted(value)

def replay_inputs(state,reader):
    result={REL:sha(reader(REL))}
    for frozen_data in state['frozen'].values(): result.update(frozen_data['inputs'])
    return dict(sorted(result.items()))

def eligible_b(value):
    return bool(value and value['lane']=='accept' and value['status']=='semantic_fail' and value['implementation_attempts']==1 and
                failed_markers(value) and failed_markers(value)<={'P94N_NEG_SOURCE_SIGNAL','P94N_NEG_NEUTRAL_SIGNAL','P94N_NEG_SOURCE_SIGN','P94N_NEG_NEUTRAL_SIGN'})

def lane_counts(rows,total):
    failed=sum(r['status']=='semantic_fail' for r in rows)
    return dict(discovered=total,executed=len(rows),passed=len(rows)-failed,failed=failed,skipped=0,unexecuted=total-len(rows))

def prospective(events,kind,data,reader=None):
    # Compare the complete current history immediately before append; never truncate.
    current=read(EVENTS) if path(EVENTS).exists() else b''
    expected=b''.join(canonical(e)+b'\n' for e in events)
    exact(current,expected,'concurrent_history')
    e={'sequence':len(events)+1,'previous':event_sha(events[-1]) if events else sha(read(BINDING)),'kind':kind,'data':data}
    replay(events+[e],reader)
    return e

def append(events,kind,data):
    e=prospective(events,kind,data)
    with path(EVENTS).open('ab' if events else 'xb') as f:
        f.write(canonical(e)+b'\n'); f.flush(); os.fsync(f.fileno())
    events.append(e); return e

def tracked_inputs():
    result=subprocess.run(['git','ls-files','-z'],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=5,check=True)
    names=result.stdout.decode().split('\0')
    return sorted(n for n in names if n and (n.startswith('BeautySDK/Sources/') or n.startswith('BeautySDK/Tests/') or n=='BeautySDK/Package.swift' or n.startswith(P) or (n.startswith('scripts/') and ('phase94' in n or n in (H.MANIFEST,H.COMPARATOR)))) and n not in NEW_TESTS and n not in (REL,BINDING,EVENTS))

def authoring_identity(b,events):
    current=sha(read(REL))
    if current==b['runner']: return
    exact(b['runner'],SEEDED_SHA,'runner_drift')
    exact(sha(read(SEEDED)),SEEDED_SHA,'historical_drift')
    exact(sha(read(BINDING)),SEED_BINDING_SHA,'historical_drift')
    prefix=read(EVENTS).splitlines(keepends=True)[0]
    exact(sha(prefix),SEED_EVENTS_SHA,'historical_drift')
    disposition=load_json(DISPOSITION)
    expected=dict(schema='phase94.authoring-disposition.1',seeded_runner_sha256=SEEDED_SHA,
        seeded_snapshot=SEEDED,binding_sha256=SEED_BINDING_SHA,seed_events_sha256=SEED_EVENTS_SHA,
        successor_runner_sha256=current,review_file=RUNNER_REVIEW,review_sha256=sha(read(RUNNER_REVIEW)),
        research_passes=1,checked_plan_sets=1,implementation_attempts=0,native_tests=0)
    exact(disposition,expected,'authoring_disposition')
    review_header(RUNNER_REVIEW,'phase94.runner-review.1',{'inputs':{
        SEEDED:SEEDED_SHA,REL:current,BINDING:SEED_BINDING_SHA,EVENTS:SEED_EVENTS_SHA}})
    admitted=[e for e in events if e['kind']=='authoring']
    if admitted:
        need(len(admitted)==1 and admitted[0]['sequence']==2,'authoring_state')
        exact(admitted[0]['data'],dict(disposition_sha256=sha(read(DISPOSITION)),runner_sha256=current,review_sha256=sha(read(RUNNER_REVIEW))),'authoring_drift')
    else:
        need(len(events)==1,'authoring_state')

def admit_authoring(b,events):
    authoring_identity(b,events)
    if sha(read(REL))!=b['runner'] and not any(e['kind']=='authoring' for e in events):
        append(events,'authoring',dict(disposition_sha256=sha(read(DISPOSITION)),runner_sha256=sha(read(REL)),review_sha256=sha(read(RUNNER_REVIEW))))

def validate_authorities(b, reader, current_sdk):
    for key,category in (('historical','historical_drift'),('current','authority_drift')):
        exact({n:sha(reader(n)) for n in b[key]},b[key],category)
    need(current_sdk-{PROVIDER}-NEW_TESTS <= set(b['current']),'authority_drift')

def snapshot():
    b=load_json(BINDING); need(b['schema']=='phase94.remaining-binding.1','binding_failure')
    current_sdk={str(p.relative_to(ROOT)) for folder in ('BeautySDK/Sources','BeautySDK/Tests') for p in (ROOT/folder).rglob('*.swift')}
    validate_authorities(b,read,current_sdk)
    events=history(b)
    validate_published(events)
    authoring_identity(b,events)
    validate_reviews(events)
    return b,events

def validate_reviews(events):
    for e in events:
        if e['kind']=='freeze':
            d=e['data']; exact(hashes(d['inputs']),d['inputs'],'frozen_drift')
            rn=P+('94-02-TEST-REVIEW.md' if d['batch']=='oracle' else '94-03-TEST-REVIEW.md')
            exact(d['review'],rn,'review_failure')
            exact(review_header(rn,'phase94.test-review.1',{'inputs':d['inputs']}),d['review_sha256'],'review_failure')
        if e['kind']=='seal':
            n=e['data']['attempt']; comp=bound_receipt(receipt(f'CANDIDATE-{n:02d}-COMPILE'),events)
            expected={k:v for k,v in comp.items() if k not in ('schema','exit_code','status','tests_executed')}
            rh=review_header(P+f'94-CANDIDATE-{n:02d}-REVIEW.md','phase94.candidate-review.1',dict(expected,compilation_receipt_sha256=sha(read(receipt(f'CANDIDATE-{n:02d}-COMPILE')))))
            exact(rh,e['data']['review_sha256'],'review_failure')

def live_inputs(events):
    result={REL:sha(read(REL))}
    for e in events:
        if e['kind']=='freeze': result.update(e['data']['inputs'])
    return dict(sorted(result.items()))

def open_state(events):
    state=replay(events)
    need(not state['hold'],'terminal_hold')
    need(state['active'] is None,'interrupted_hold')

def review_header(name,schema,expected):
    text=read(name).decode(); blocks=re.findall(r'```json\s*\n(.*?)\n```',text,re.S)
    need(len(blocks)==1,'review_failure'); value=decode_json(blocks[0])
    exact(value,dict(schema=schema,reviewer_role='independent-parent',verdict='PASS',unresolved_blockers=0,**expected),'review_failure')
    return sha(read(name))

def seed():
    # This successor has exactly one original seed. Missing history cannot be
    # repaired by recreating a fresh zero-attempt binding.
    need(path(BINDING).exists() and path(EVENTS).exists(),'seed_missing')
    b,e=snapshot(); return {'status':'seed_verified','events':len(e),'native_tests':0}

def compile_child(child=None):
    child=child or H.child
    try:
        code,out=child(['swift','build','--package-path','BeautySDK','--build-tests'],600)
        errors=len(re.findall(r'\berror:',out)); category='pass' if code==0 and errors==0 else 'compile_failure'
        if 'unable to type-check' in out: category='type_check_timeout'
        return {'exit_code':code,'error_count':errors,'category':category,'status':'pass' if category=='pass' else 'fail','tests_executed':0}
    except H.GateError as error:
        return {'exit_code':None,'error_count':0,'category':str(error),'status':'fail','tests_executed':0}

def child_identity(events, inputs, provider):
    _,current=snapshot()
    exact(current,events,'concurrent_history')
    exact(hashes(inputs),inputs,'frozen_drift')
    exact(sha(read(PROVIDER)),provider,'provider_scope')
    return dict(binding=sha(read(BINDING)),history=sha(read(EVENTS)),
        inputs=hashes(inputs),provider=provider,disposition=sha(read(DISPOSITION)),review=sha(read(RUNNER_REVIEW)))

def guarded_compile(events,inputs,provider,child=None):
    try:
        before=child_identity(events,inputs,provider)
        result=compile_child(child)
        exact(child_identity(events,inputs,provider),before,'identity_drift')
        return result
    except (GateError,H.GateError,ValueError,OSError,KeyError,TypeError):
        return dict(exit_code=None,error_count=0,category='identity_drift',status='fail',tests_executed=0)

def guarded_child(args,timeout,events,inputs,provider,observe=None,launch=None,child=None):
    before=child_identity(events,inputs,provider)
    if launch: launch()
    try:
        code,out=(child or H.child)(args,timeout)
        if observe: observe(out)
    finally:
        exact(child_identity(events,inputs,provider),before,'identity_drift')
    return code,out

def author_build(batch,b,events):
    need(batch in ('oracle','field','lifecycle'),'batch_failure'); open_state(events)
    need(not any(e['kind']=='freeze' and set(BATCHES[batch])<=set(e['data']['inputs']) for e in events),'frozen_drift')
    need(sum(e['kind']=='build_started' and e['data']['batch']==batch for e in events)<2,'author_build_budget')
    exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope')
    inputs=hashes(BATCHES[batch]); start=append(events,'build_started',{'batch':batch,'inputs':inputs,'provider':ORIGINAL})
    result=guarded_compile(events,inputs,ORIGINAL)
    append(events,'build_finished',dict(result,start=event_sha(start),batch=batch,inputs=inputs))
    if result['category'] in ('identity_drift','interrupted_hold'):
        append(events,'hold',{'category':result['category'],'attempt':0})
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
    state=replay(events)
    need(not state['hold'] and not state['active'] and not state['rollback'],'attempt_state')
    current=sha(read(PROVIDER))
    if current==ORIGINAL:
        decision=bound_receipt(receipt('CANDIDATE-DECISION'),events)
        need(decision['policy']=='retain_original','provider_scope'); return 'retain_original'
    begin=event_last(events,'begin'); n=begin['data']['attempt']; policy=begin['data']['policy']
    exact(sha(strip_candidate(read(PROVIDER))),ORIGINAL,'provider_scope')
    comp=bound_receipt(receipt(f'CANDIDATE-{n:02d}-COMPILE'),events)
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
    if command!='negative-baseline': bound_receipt(receipt('NEGATIVE-BASELINE'),events)
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
    records=[]; oldrecords=[]; current=None; execution=None; deadline=time.monotonic()+(2490 if command=='negative-baseline' else 4890)-30
    try:
        for args in (['swift','build','--package-path','BeautySDK','--build-tests'],['swift','test','--package-path','BeautySDK','list']):
            code,out=guarded_child(args,min(600,deadline-time.monotonic()),events,inputs,provider); need(code==0,'child_failure')
        H.discover(out,methods); counts['discovered']=len(methods)
        for current in methods:
            execution=None
            def launched():
                nonlocal execution
                execution=execution_evidence('',current)
            def observe(output):
                nonlocal execution
                execution=execution_evidence(output,current)
            code,out=guarded_child(['swift','test','--package-path','BeautySDK','--skip-build','--filter','^'+re.escape(current)+'$'],min(method_timeout(current),deadline-time.monotonic()),events,inputs,provider,observe,launched)
            result=classify(out,code,current)
            oldrecords.extend(H.parse_aggregates(out))
            counts['executed']+=1; counts['unexecuted']-=1
            counts['failed' if result['status']=='semantic_fail' else 'passed']+=1
            records.append(result)
            append(events,'method',dict(result,lane=command,counts=dict(counts),provider=provider,inputs=inputs))
            execution=None
        historical=load_json(METADATA)['records']
        oldhash={v['case']:v['sha256'] for v in historical if 'sha256' in v}
        observed={v['case']:v['sha256'] for v in oldrecords if 'sha256' in v}
        exact(observed,oldhash,'retained_drift')
        exact(hashes(inputs),inputs,'frozen_drift'); exact(sha(read(PROVIDER)),provider,'provider_scope'); snapshot()
        value={'schema':'phase94.remaining-checks.1','lane':command,'status':'semantic_fail' if counts['failed'] else 'pass','counts':counts,'records':records,'inputs':inputs,'provider':provider,'start':event_sha(start),'implementation_attempts':sum(e['kind']=='begin' for e in events),'phase_complete':False,'historical_receipt':METADATA_SHA}
        if command!='accept' or not counts['failed']: publish(events,'lane_finished',outname,value)
        else: append(events,'lane_finished',dict(receipt=None,receipt_sha256=sha(canonical(value)),value=value))
        return value
    except (GateError,H.GateError,ValueError,OSError) as error:
        category=str(error) if isinstance(error,(GateError,H.GateError)) else 'infrastructure_failure'
        if execution:
            counts['unexecuted']-=1
            for key in ('executed','passed','failed','skipped'): counts[key]+=execution[key]
            counts['completion_unknown']=int(execution['completion_unknown'])
        value={'category':category,'lane':command,'counts':counts,'method':current,'execution':execution,'inputs':inputs,'provider':provider,'start':event_sha(start)}
        append(events,'hold',value); return dict(value,status='terminal_hold')


def failed_markers(value): return {m for row in value['records'] for m in row['markers']}
def complete_counts(v):
    c=v['counts']; need(c['discovered']==41 and c['executed']==41 and c['unexecuted']==c['skipped']==0 and c['passed']+c['failed']==41,'incomplete_measurement')

def control(args,b,events):
    command=args.command
    if command=='status':
        state=replay(events)
        if state['hold'] or state['active']:
            if state['rollback'] or not state['attempt']: exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope')
            elif state['compile']: exact(sha(read(PROVIDER)),state['compile']['provider_after_sha256'],'provider_scope')
            elif state['active'] and state['active']['kind']=='compile_started': exact(sha(read(PROVIDER)),state['active']['data']['provider_after_sha256'],'provider_scope')
            return dict(status='terminal_hold' if state['hold'] else 'interrupted_hold',phase_complete=False)
        if path(receipt('REMAINING-COMPLETE')).exists() or state['complete']:
            validate_complete(events)
            return dict(status='complete',phase_complete=True)
        if state['decision'] and (state['decision']['policy']=='retain_original' or state['seal']):
            policy=provider_scope(events)
            return dict(status='scope_pass',policy=policy,phase_complete=False)
        if not state['attempt'] or state['rollback']: exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope')
        elif state['compile']: exact(sha(read(PROVIDER)),state['compile']['provider_after_sha256'],'provider_scope')
        elif sha(read(PROVIDER))!=ORIGINAL: exact(sha(strip_candidate(read(PROVIDER))),ORIGINAL,'provider_scope')
        return dict(status='incomplete',implementation_attempts=state['attempt'],phase_complete=False)
    if command=='rollback':
        begin=event_last(events,'begin'); attempt=begin['data']['attempt']
        comp=event_last(events,'compile_started')
        state=replay(events)
        failed=state['lanes'].get('accept',{})
        need(comp['data']['attempt']==attempt and not state['rollback'] and (state['hold'] or (failed.get('status')=='semantic_fail' and failed.get('implementation_attempts')==attempt)),'rollback_state')
        current=sha(read(PROVIDER)); exact(current,comp['data']['provider_after_sha256'],'concurrent_provider')
        proc=subprocess.run(['git','show','624cee5a:'+PROVIDER],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,timeout=5,check=True)
        exact(sha(proc.stdout),ORIGINAL,'historical_drift'); exact(sha(read(PROVIDER)),current,'concurrent_provider')
        path(PROVIDER).write_bytes(proc.stdout); exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope')
        append(events,'rollback',{'attempt':attempt,'before':current,'after':ORIGINAL}); return {'status':'rolled_back'}
    open_state(events)
    if command=='scope': return {'status':'scope_pass','policy':provider_scope(events)}
    if command=='select':
        bound_receipt(receipt('NEGATIVE-BASELINE'),events)
        value=bound_receipt(receipt('FULL-BASELINE'),events); complete_counts(value)
        exact(value['provider'],ORIGINAL,'provider_scope'); exact(value['inputs'],live_inputs(events),'frozen_drift')
        markers=failed_markers(value); need(markers<=SEMANTIC|FIELD_MARKERS,'ineligible_failure')
        policy='A' if markers else 'retain_original'
        decision={'policy':policy,'baseline':sha(read(receipt('FULL-BASELINE'))),'markers':sorted(markers),'inputs':live_inputs(events),'provider':ORIGINAL,'research_passes':1,'checked_plan_sets':1,'implementation_attempts':0}
        publish(events,'select',receipt('CANDIDATE-DECISION'),decision); return decision
    if command=='begin':
        n=args.attempt; used=sum(e['kind']=='begin' for e in events); attempt_number(n,used)
        exact(sha(read(PROVIDER)),ORIGINAL,'provider_scope'); decision=bound_receipt(receipt('CANDIDATE-DECISION'),events); need(decision['policy']=='A','attempt_state')
        if n==2:
            rollback=event_last(events,'rollback'); need(rollback['data']['attempt']==1,'attempt_state')
            failed=event_last(events,'lane_finished')['data']['value']; complete_counts(failed)
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
            start=append(events,'compile_started',data); result=guarded_compile(events,live_inputs(events),data['provider_after_sha256'])
            value=dict(data,schema='phase94.candidate-compile.1',exit_code=result['exit_code'],status=result['status'],tests_executed=0)
            publish(events,'compile_finished',cn,value,start=event_sha(start),category=result['category'])
            if result['status']!='pass': append(events,'hold',{'category':result['category'],'attempt':n})
            return result
        comp=bound_receipt(cn,events); exact(comp,dict(data,schema='phase94.candidate-compile.1',exit_code=0,status='pass',tests_executed=0),'compile_stale')
        rn=P+f'94-CANDIDATE-{n:02d}-REVIEW.md'; exact(args.review,rn,'review_failure')
        rh=review_header(rn,'phase94.candidate-review.1',dict(data,compilation_receipt_sha256=sha(read(cn))))
        need(not any(e['kind']=='seal' and e['data']['attempt']==n for e in events),'seal_exists')
        append(events,'seal',{'attempt':n,'provider':data['provider_after_sha256'],'review_sha256':rh}); return {'status':'sealed','attempt':n}
    # Closeout is a separate parent-authored evidence chain, with no native child.
    checks=bound_receipt(receipt('REMAINING-CHECKS'),events); complete_counts(checks)
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
    exact(hashes(OWNERS),owner_map,'owner_drift')
    publish(events,'finalize',receipt('REMAINING-COMPLETE'),value,goal=args.goal)
    validate_complete(events)
    return {'status':'complete','phase_complete':True}

def validate_complete(events):
    _,current=snapshot(); exact(current,events,'concurrent_history'); open_state(events)
    return complete_inputs(events)

def complete_inputs(events):
    state=replay(events); need(state['complete'],'completion_absent')
    value=bound_receipt(receipt('REMAINING-COMPLETE'),events)
    checks=bound_receipt(receipt('REMAINING-CHECKS'),events)
    exact(checks['provider'],sha(read(PROVIDER)),'checks_stale')
    exact(checks['inputs'],live_inputs(events),'checks_stale'); provider_scope(events)
    exact(hashes(OWNERS),value['owners'],'owner_drift')
    expected={k:v for k,v in value.items() if k not in ('schema','goal_sha256','status')}
    goal=event_last(events,'finalize')['data']['goal']
    exact(review_header(goal,'phase94.goal-review.1',expected),value['goal_sha256'],'goal_stale')
    accepted={k:value[k] for k in ('checks_sha256','provider_sha256','inputs')}
    exact(review_header(P+'94-IMPLEMENTATION-REVIEW.md','phase94.implementation-review.1',dict(accepted,high_security_findings=0)),value['implementation_review_sha256'],'review_stale')
    return value

class MemoryStore:
    """Self-test storage adapter. No writes, subprocesses, or native acceptance."""
    def __init__(self):
        self.files={REL:b'runner',BINDING:b'binding',PROVIDER:b'original',
                    DISPOSITION:b'disposition',RUNNER_REVIEW:b'review','history':b'old','source':b'source'}
        self.binding={'historical':{'history':sha(b'old')},'current':{'source':sha(b'source')}}
        self.events=[]
        self.add('seed',dict(binding=sha(self.files[BINDING]),implementation_attempts=0,negative_pixels='not_measured'))

    def read(self,name):
        need(name in self.files,'input_missing'); return self.files[name]

    def add(self,kind,data):
        event=dict(sequence=len(self.events)+1,previous=event_sha(self.events[-1]) if self.events else sha(self.files[BINDING]),kind=kind,data=data)
        self.events.append(event); self.sync(); return event

    def sync(self):
        self.files[EVENTS]=b''.join(canonical(e)+b'\n' for e in self.events)

    def snapshot(self):
        validate_authorities(self.binding,self.read,{'source'})
        events=decode_json(b'['+b','.join(self.read(EVENTS).splitlines())+b']')
        replay(events); validate_reviews(events)
        return self.binding,events

    def publish(self,kind,name,value,**extra):
        self.files[name]=canonical(value)+b'\n'
        return self.add(kind,dict(extra,receipt=name,receipt_sha256=sha(self.files[name]),value=value))

    def review(self,name,schema,expected):
        self.files[name]=b'```json\n'+canonical(dict(schema=schema,reviewer_role='independent-parent',verdict='PASS',unresolved_blockers=0,**expected))+b'\n```\n'
        return sha(self.files[name])

    def prepare(self):
        for batch in ('oracle','field','lifecycle'):
            for name in BATCHES[batch]: self.files[name]=name.encode()
            inputs=hashes(BATCHES[batch]); start=self.add('build_started',dict(batch=batch,inputs=inputs,provider=ORIGINAL))
            self.add('build_finished',dict(batch=batch,inputs=inputs,start=event_sha(start),exit_code=0,error_count=0,category='pass',status='pass',tests_executed=0))
        for batch in ('oracle','safety'):
            inputs=hashes(BATCHES[batch]+[REL]); rn=P+('94-02-TEST-REVIEW.md' if batch=='oracle' else '94-03-TEST-REVIEW.md')
            rh=self.review(rn,'phase94.test-review.1',{'inputs':inputs})
            self.add('freeze',dict(batch=batch,inputs=inputs,review=rn,review_sha256=rh))

    def lane(self,lane,semantic=False):
        methods=BASE+NEGATIVE if lane=='negative-baseline' else FULL
        inputs=live_inputs(self.events); provider=sha(self.read(PROVIDER))
        start=self.add('lane_started',dict(lane=lane,inputs=inputs,provider=provider,methods=methods)); rows=[]
        for method in methods:
            markers=[]; records=[]
            if method==NEGATIVE[-1]:
                record=sample_negative()
                if semantic:
                    record['metrics']['source_margin']=0; record['predicates']=predicates(record['metrics']); markers=['P94N_NEG_SOURCE_SIGN']
                records=[record]
            failed=bool(markers)
            row=dict(method=method,status='semantic_fail' if failed else 'pass',assertion_failures=len(markers),markers=markers,records=records,
                execution=dict(launched=True,started=1,ended=1,executed=1,passed=int(not failed),failed=int(failed),skipped=0,completion_unknown=False))
            rows.append(row); self.add('method',dict(row,lane=lane,inputs=inputs,provider=provider,counts=lane_counts(rows,len(methods))))
        value=dict(schema='phase94.remaining-checks.1',lane=lane,status='semantic_fail' if semantic else 'pass',counts=lane_counts(rows,len(methods)),records=rows,inputs=inputs,provider=provider,start=event_sha(start),implementation_attempts=sum(e['kind']=='begin' for e in self.events),phase_complete=False,historical_receipt=METADATA_SHA)
        if lane=='accept' and semantic: self.add('lane_finished',dict(receipt=None,receipt_sha256=sha(canonical(value)),value=value))
        else: self.publish('lane_finished',receipt({'negative-baseline':'NEGATIVE-BASELINE','full-baseline':'FULL-BASELINE','accept':'REMAINING-CHECKS'}[lane]),value)
        return value

    def selected(self,candidate=False):
        self.prepare(); self.lane('negative-baseline',candidate); full=self.lane('full-baseline',candidate)
        value=dict(policy='A' if candidate else 'retain_original',baseline=sha(self.read(receipt('FULL-BASELINE'))),markers=sorted(failed_markers(full)),inputs=live_inputs(self.events),provider=ORIGINAL,research_passes=1,checked_plan_sets=1,implementation_attempts=0)
        self.publish('select',receipt('CANDIDATE-DECISION'),value)

    def candidate(self,n=1):
        begin=self.add('begin',dict(attempt=n,policy='A' if n==1 else 'B',provider_before_sha256=ORIGINAL,inputs=live_inputs(self.events)))
        self.files[PROVIDER]=b'original'+DISPATCH.encode()+HELPER_START.encode()+b'    private func phase94NegativeWidth() {}\n'+HELPER_END.encode()
        d=dict(attempt=n,policy=begin['data']['policy'],begin_event_sha256=event_sha(begin),provider_before_sha256=ORIGINAL,provider_after_sha256=sha(self.read(PROVIDER)),frozen_inputs_sha256=sha(canonical(live_inputs(self.events))),runner_sha256=sha(self.read(REL)))
        start=self.add('compile_started',d); cn=receipt(f'CANDIDATE-{n:02d}-COMPILE')
        self.publish('compile_finished',cn,dict(d,schema='phase94.candidate-compile.1',exit_code=0,status='pass',tests_executed=0),start=event_sha(start),category='pass')
        rn=P+f'94-CANDIDATE-{n:02d}-REVIEW.md'
        rh=self.review(rn,'phase94.candidate-review.1',dict(d,compilation_receipt_sha256=sha(self.read(cn))))
        self.add('seal',dict(attempt=n,provider=sha(self.read(PROVIDER)),review_sha256=rh))

    def complete(self):
        self.selected(); self.lane('accept')
        accepted=dict(checks_sha256=sha(self.read(receipt('REMAINING-CHECKS'))),provider_sha256=ORIGINAL,inputs=live_inputs(self.events))
        rh=self.review(P+'94-IMPLEMENTATION-REVIEW.md','phase94.implementation-review.1',dict(accepted,high_security_findings=0))
        self.add('review',dict(accepted,review_sha256=rh))
        for name in OWNERS: self.files[name]=name.encode()
        self.add('behavior',dict(accepted,review_sha256=rh,owners=hashes(OWNERS[:4])))
        q=self.add('qualification',dict(accepted,review_sha256=rh,owners=hashes(OWNERS)))
        expected=dict(accepted,owners=hashes(OWNERS),owner_event_sha256=event_sha(q),implementation_review_sha256=rh,all_truths=True,phase_complete=True)
        goal=P+'94-GOAL.md'; gh=self.review(goal,'phase94.goal-review.1',expected)
        self.publish('finalize',receipt('REMAINING-COMPLETE'),dict(expected,schema='phase94.remaining-complete.1',goal_sha256=gh,status='complete'),goal=goal)


def self_tests():
    original_read=read; original_sha=ORIGINAL; original_snapshot=snapshot; results=[]; attacks=0
    def reject(action):
        nonlocal attacks
        try: action()
        except (GateError,H.GateError): attacks+=1; return
        raise AssertionError('expected_rejection')
    def fixture():
        store=MemoryStore(); globals()['read']=store.read; globals()['snapshot']=store.snapshot; return store
    def valid(store): return replay(store.events)
    def case(name,action):
        action(); results.append(name)
    method=NEGATIVE[0]
    clean="Test Case '-["+method.replace('/',' ')+"]' started.\nTest Case '-["+method.replace('/',' ')+"]' passed (0.01 seconds).\nExecuted 1 test, with 0 failures (0 unexpected)\n"
    def parse_attack(output):
        classify(clean,0,method); reject(lambda: classify(output,0,method))
    try:
        globals()['ORIGINAL']=sha(b'original')
        def normal():
            s=fixture(); s.selected(); valid(s); provider_scope(s.events)
            # Isolated select receipt cannot authorize begin1, even if well formed.
            s.events=s.events[:1]; s.add('begin',dict(attempt=1,policy='A',provider_before_sha256=ORIGINAL,inputs={REL:sha(s.read(REL))}))
            reject(lambda: valid(s))
            s=fixture(); s.prepare(); valid(s); s.lane('full-baseline')
            reject(lambda: valid(s))
        case('normal_admission',normal)
        def discovery(text):
            H.discover(method+'\n',[method]); reject(lambda: H.discover(text,[method]))
        case('zero_discovery',lambda: discovery(''))
        case('duplicate_discovery',lambda: discovery((method+'\n')*2))
        case('skip',lambda: parse_attack(clean.replace('passed','skipped')))
        case('wrong_method_summary',lambda: (parse_attack(clean.replace('1 test','2 tests')),parse_attack(clean.replace(method.split('/')[1],'wrongMethod'))))
        def interruption(category):
            child_code='import time; time.sleep(5)' if category=='timeout' else 'import sys; sys.stdout.write("x"*(9*1024*1024))'
            reject(lambda: H.child([sys.executable,'-c',child_code],.05 if category=='timeout' else 5))
            need(H.LAST_REAPED,'cleanup_failure')
            s=fixture(); s.prepare(); valid(s)
            inputs=live_inputs(s.events)
            guarded_child([],1,s.events,inputs,ORIGINAL,child=lambda *_:(0,clean))
            def failed_child(*_): raise H.GateError(category)
            reject(lambda: guarded_child([],1,s.events,inputs,ORIGINAL,child=failed_child))
            start=s.add('lane_started',dict(lane='negative-baseline',inputs=live_inputs(s.events),provider=ORIGINAL,methods=BASE+NEGATIVE))
            reject(lambda: open_state(s.events))
            execution=execution_evidence('',BASE[0]); need(execution['completion_unknown'] and execution['executed']==0,'self_test_failure')
            s.add('hold',dict(category=category,start=event_sha(start),lane='negative-baseline',counts=dict(discovered=13,executed=0,passed=0,failed=0,skipped=0,unexecuted=12,completion_unknown=1),method=BASE[0],execution=execution,inputs=live_inputs(s.events),provider=ORIGINAL))
            valid(s); reject(lambda: open_state(s.events))
        case('timeout_group_cleanup',lambda: interruption('timeout'))
        case('capture_overflow',lambda: interruption('capture_overflow'))
        def aggregate(key,value):
            negative_record(sample_negative()); reject(lambda: negative_record(dict(sample_negative(),**{key:value})))
            public_clean=clean.replace(method.replace('/',' '),NEGATIVE[-1].replace('/',' '))
            wire=canonical(sample_negative()).decode()
            classify(public_clean+'P94N_AGGREGATE '+wire+'\n',0,NEGATIVE[-1])
            duplicate=wire[:-1]+',"case":"negative"}'
            reject(lambda: classify(public_clean+'P94N_AGGREGATE '+duplicate+'\n',0,NEGATIVE[-1]))
            failed=clean.replace('passed','failed').replace('0 failures','1 failures')+'error: private failure\n'
            e=execution_evidence(failed,method); need(e['failed']==1 and e['executed']==1,'self_test_failure')
            reject(lambda: classify(failed,1,method))
        case('unknown_private_aggregate',lambda: aggregate('private','forbidden'))
        case('missing_comparison',lambda: aggregate('comparisons',COMPARISONS[:-1]))
        def reviews():
            for target in ('missing','failed','attempt','review','event','duplicate'):
                s=fixture(); s.selected(True); s.candidate(); valid(s); provider_scope(s.events)
                cn=receipt('CANDIDATE-01-COMPILE')
                if target=='missing': del s.files[cn]
                elif target in ('failed','attempt'):
                    value=decode_json(s.files[cn]); value['status' if target=='failed' else 'attempt']='fail' if target=='failed' else 2; s.files[cn]=canonical(value)
                elif target=='review': s.files[P+'94-CANDIDATE-01-REVIEW.md']+=b'changed'
                elif target=='event': s.events=[e for e in s.events if e['kind']!='compile_finished']
                else: s.events.append(copy.deepcopy(event_last(s.events,'compile_finished')))
                reject(lambda: provider_scope(s.events))
        case('stale_review_compile',reviews)
        def authority(which):
            s=fixture(); b={'historical':{'history':sha(b'old')},'current':{'source':sha(b'source')}}
            s.files.update(history=b'old',source=b'source'); validate_authorities(b,s.read,{'source'})
            s.files[which]+=b'changed'; reject(lambda: validate_authorities(b,s.read,{'source'}))
            s=fixture(); valid(s); s.events[0]['data']['implementation_attempts']=1
            reject(lambda: valid(s))
            # Every child gets a fresh complete authority check, both before
            # launch and after capture. Test each identity independently.
            for target in ('history','source',PROVIDER,REL,DISPOSITION,RUNNER_REVIEW,
                           CORE+'MouthNegativeOracleTests.swift',P+'94-02-TEST-REVIEW.md',
                           P+'94-CANDIDATE-01-REVIEW.md',EVENTS):
                s=fixture(); s.selected(True); s.candidate(); inputs=live_inputs(s.events); provider=sha(s.read(PROVIDER))
                guarded_child([],1,s.events,inputs,provider,child=lambda *_:(0,clean))
                def drift(*_): s.files[target]+=b'changed'; return 0,clean
                reject(lambda: guarded_child([],1,s.events,inputs,provider,child=drift))
            # Compile success is downgraded before receipt publication.
            s=fixture(); s.selected(True); s.candidate(); inputs=live_inputs(s.events); provider=sha(s.read(PROVIDER))
            need(guarded_compile(s.events,inputs,provider,child=lambda *_:(0,''))['status']=='pass','self_test_failure')
            def compile_drift(*_): s.files['history']+=b'changed'; return 0,''
            need(guarded_compile(s.events,inputs,provider,child=compile_drift)['status']=='fail','self_test_failure')
            if which=='history':
                saved={key:globals()[key] for key in ('SEEDED_SHA','SEED_BINDING_SHA','SEED_EVENTS_SHA')}
                try:
                    s=fixture(); s.files[SEEDED]=b'seeded'
                    globals()['SEEDED_SHA']=sha(s.read(SEEDED)); globals()['SEED_BINDING_SHA']=sha(s.read(BINDING)); globals()['SEED_EVENTS_SHA']=sha(s.read(EVENTS))
                    expected_inputs={SEEDED:SEEDED_SHA,REL:sha(s.read(REL)),BINDING:SEED_BINDING_SHA,EVENTS:SEED_EVENTS_SHA}
                    rh=s.review(RUNNER_REVIEW,'phase94.runner-review.1',{'inputs':expected_inputs})
                    disposition=dict(schema='phase94.authoring-disposition.1',seeded_runner_sha256=SEEDED_SHA,seeded_snapshot=SEEDED,binding_sha256=SEED_BINDING_SHA,seed_events_sha256=SEED_EVENTS_SHA,successor_runner_sha256=sha(s.read(REL)),review_file=RUNNER_REVIEW,review_sha256=rh,research_passes=1,checked_plan_sets=1,implementation_attempts=0,native_tests=0)
                    s.files[DISPOSITION]=canonical(disposition); b={'runner':SEEDED_SHA}
                    authoring_identity(b,s.events)
                    s.add('authoring',dict(disposition_sha256=sha(s.read(DISPOSITION)),runner_sha256=sha(s.read(REL)),review_sha256=rh))
                    authoring_identity(b,s.events); valid(s)
                    # Subsequent history is allowed; only the seed prefix is pinned.
                    s.prepare(); authoring_identity(b,s.events); valid(s)
                    s.files[DISPOSITION]=canonical(dict(disposition,native_tests=1))
                    reject(lambda: authoring_identity(b,s.events))
                    s.files[DISPOSITION]=canonical(disposition)
                    s.files[EVENTS]=b' '+s.files[EVENTS]
                    reject(lambda: authoring_identity(b,s.events))
                finally: globals().update(saved)
        case('historical_tamper',lambda: authority('history'))
        case('nonprovider_drift',lambda: authority('source'))
        def allowed():
            s=fixture(); s.selected(True); s.candidate(); valid(s); provider_scope(s.events)
            s.events=s.events[:-1]; reject(lambda: provider_scope(s.events))
        case('allowed_negative_seal',allowed)
        def positive():
            s=fixture(); s.selected(True); s.candidate(); valid(s); provider_scope(s.events)
            s.files[PROVIDER]=s.files[PROVIDER].replace(b'original',b'changed'); reject(lambda: provider_scope(s.events))
        case('positive_shared_edit',positive)
        def attempts():
            # An ordinary authoring compile failure permits exactly the
            # already-budgeted second compile, not a third.
            s=fixture(); batch='oracle'
            for name in BATCHES[batch]: s.files[name]=b'test'
            inputs=hashes(BATCHES[batch])
            for status in ('fail','pass'):
                start=s.add('build_started',dict(batch=batch,inputs=inputs,provider=ORIGINAL))
                s.add('build_finished',dict(batch=batch,inputs=inputs,start=event_sha(start),exit_code=int(status=='fail'),error_count=int(status=='fail'),category='pass' if status=='pass' else 'compile_failure',status=status,tests_executed=0)); valid(s)
            s.add('build_started',dict(batch=batch,inputs=inputs,provider=ORIGINAL)); reject(lambda: valid(s))
            s=fixture(); s.selected(True); s.candidate(); s.lane('accept',True); valid(s)
            s.add('rollback',dict(attempt=1,before=sha(s.read(PROVIDER)),after=ORIGINAL)); s.files[PROVIDER]=b'original'
            s.candidate(2); valid(s)
            for n in (1,3):
                saved=copy.deepcopy(s.events); s.add('begin',dict(attempt=n,policy='B',provider_before_sha256=ORIGINAL,inputs=live_inputs(s.events)))
                reject(lambda: valid(s)); s.events=saved; s.sync()
            s=fixture(); s.selected(True); s.candidate()
            s.add('hold',dict(category='infrastructure_failure',attempt=1)); valid(s)
            s.add('rollback',dict(attempt=1,before=sha(s.read(PROVIDER)),after=ORIGINAL)); valid(s)
            s.add('begin',dict(attempt=2,policy='B',provider_before_sha256=ORIGINAL,inputs=live_inputs(s.events)))
            reject(lambda: valid(s))
        case('attempt_reset_third_begin',attempts)
        def closeout():
            for target in ('plans','checks','goal','event','schema'):
                s=fixture(); s.complete(); valid(s); complete_inputs(s.events)
                if target=='event': s.events=s.events[:-1]
                elif target=='schema': s.events[-1]['data']['unknown']=True
                else: s.files[{'plans':'PLANS.md','checks':receipt('REMAINING-CHECKS'),'goal':P+'94-GOAL.md'}[target]]+=b'changed'
                reject(lambda: complete_inputs(s.events))
            # Exercise real command -> prospective replay -> disk append and
            # atomic receipt publication on synthetic evidence only.
            for interrupted in (False,True):
                s=fixture(); s.selected(); s.lane('accept')
                accepted=dict(checks_sha256=sha(s.read(receipt('REMAINING-CHECKS'))),provider_sha256=ORIGINAL,inputs=live_inputs(s.events))
                rn=P+'94-IMPLEMENTATION-REVIEW.md'
                rh=s.review(rn,'phase94.implementation-review.1',dict(accepted,high_security_findings=0))
                for name in OWNERS:
                    s.files[name]=('## Phase94\nMOUTH-01 Phase95 no-skip '+accepted['checks_sha256']+
                        '\nStatus: verifying (snapshot before independent goal decision)\n94-REMAINING-COMPLETE.json incomplete\n').encode()
                saved={key:globals()[key] for key in ('ROOT','read','snapshot','append')}
                try:
                    with tempfile.TemporaryDirectory(prefix='phase94-admission-') as directory:
                        globals()['ROOT']=Path(directory).resolve()
                        for name,raw in s.files.items():
                            target=ROOT/name; target.parent.mkdir(parents=True,exist_ok=True); target.write_bytes(raw)
                        globals()['read']=original_read
                        def disk_snapshot():
                            validate_authorities(s.binding,read,{'source'})
                            events=history(s.binding); validate_reviews(events); validate_published(events)
                            return s.binding,events
                        globals()['snapshot']=disk_snapshot
                        events=copy.deepcopy(s.events)
                        args=argparse.Namespace(command='review',file=rn)
                        control(args,s.binding,events)
                        def disk_bytes(): return {str(p.relative_to(ROOT)):p.read_bytes() for p in ROOT.rglob('*') if p.is_file()}
                        before=disk_bytes()
                        reject(lambda: control(args,s.binding,events))
                        need(disk_bytes()==before,'rejection_mutated_history')
                        owners=argparse.Namespace(command='owners',group='qualification')
                        reject(lambda: control(owners,s.binding,events))
                        need(disk_bytes()==before,'rejection_mutated_history')
                        owners.group='behavior'; control(owners,s.binding,events)
                        owners.group='qualification'; control(owners,s.binding,events)
                        bound=event_last(events,'qualification')
                        expected=dict(accepted,owners=hashes(OWNERS),owner_event_sha256=event_sha(bound),implementation_review_sha256=rh,all_truths=True,phase_complete=True)
                        goal=P+'94-GOAL.md'
                        path(goal).write_bytes(b'```json\n'+canonical(dict(schema='phase94.goal-review.1',reviewer_role='independent-parent',verdict='PASS',unresolved_blockers=0,**expected))+b'\n```\n')
                        final=argparse.Namespace(command='finalize',goal=goal)
                        if interrupted:
                            def interrupted_append(*_): raise GateError('publication_interrupted')
                            globals()['append']=interrupted_append
                            reject(lambda: control(final,s.binding,events))
                            globals()['append']=saved['append']
                            # A fully written but unbound receipt still fails.
                            reject(disk_snapshot)
                            path(receipt('REMAINING-COMPLETE')).write_bytes(b'{')
                            reject(disk_snapshot)
                        else:
                            control(final,s.binding,events)
                            need(control(argparse.Namespace(command='status'),s.binding,events)['phase_complete'],'completion_absent')
                            before=disk_bytes()
                            reject(lambda: control(final,s.binding,events))
                            need(disk_bytes()==before,'rejection_mutated_history')
                        need(not list(ROOT.rglob('.phase94-*')),'cleanup_failure')
                finally:
                    globals().update(saved)
        case('stale_checks_goal',closeout)
    finally:
        globals()['read']=original_read; globals()['ORIGINAL']=original_sha; globals()['snapshot']=original_snapshot
    need(len(results)==16,'self_test_failure')
    return dict(status='pure_pass',executed=16,passed=16,failed=0,skipped=0,native_tests=0,attack_rejections=attacks,cases=results)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command',choices=['self-test','seed','author-build','freeze','negative-baseline','full-baseline','select','begin','candidate-compile','seal','scope','status','accept','rollback','review','owners','finalize'])
    parser.add_argument('--batch',choices=list(BATCHES)); parser.add_argument('--attempt',type=int,choices=[1,2]); parser.add_argument('--review'); parser.add_argument('--file'); parser.add_argument('--group',choices=['behavior','qualification']); parser.add_argument('--goal')
    args=parser.parse_args()
    if args.command=='self-test': value=self_tests()
    elif args.command=='seed': value=seed()
    else:
        b,events=snapshot()
        if args.command not in ('status','scope'): admit_authoring(b,events)
        if args.command=='author-build': value=author_build(args.batch,b,events)
        elif args.command=='freeze': value=freeze(args.batch,args.review,b,events)
        elif args.command in ('negative-baseline','full-baseline','accept'): value=measure_lane(args.command,b,events)
        else: value=control(args,b,events)
    print(json.dumps(value,sort_keys=True))
    return 1 if value.get('status') in ('fail','terminal_hold','interrupted_hold') or (args.command=='accept' and value.get('status')=='semantic_fail') else 0

if __name__=='__main__':
    try: sys.exit(main())
    except (GateError,H.GateError,OSError,ValueError,TypeError,KeyError,AssertionError,subprocess.SubprocessError) as error:
        category=str(error) if isinstance(error,(GateError,H.GateError)) else 'infrastructure_failure'
        print(json.dumps({'status':'gate_rejected','category':category,'phase_complete':False},sort_keys=True)); sys.exit(1)
