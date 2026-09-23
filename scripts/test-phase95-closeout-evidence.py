#!/usr/bin/env python3
"""Generated evidence tests only; never creates a real milestone receipt."""
import copy
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location('evidence', Path(__file__).with_name('phase95-closeout-evidence.py'))
e = importlib.util.module_from_spec(spec)
spec.loader.exec_module(e)

class EvidenceTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='beauty-evidence-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.phase = self.root / e.PHASE_REL
        self.phase.mkdir(parents=True)
        for name in ('AGENTS.md', 'DESIGN.md', 'ARCHITECTURE.md', 'SECURITY.md', 'RELIABILITY.md',
                     'PRODUCT_SENSE.md', 'PLANS.md', 'QUALITY_SCORE.md', 'docs/SDK_EFFECT_TAXONOMY.md',
                     'BeautySDK/Package.swift', e.PHASE_REL + '/' + e.CONTRACT, e.PHASE_REL + '/' + e.ROOT_DEFINITION):
            p = self.root / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text('generated fixture\n')
        manifest_path=self.root/'scripts/face-feature-batch-manifest.json'
        manifest_path.parent.mkdir(parents=True,exist_ok=True)
        manifest_path.write_bytes(Path(__file__).with_name('face-feature-batch-manifest.json').read_bytes())
        self.contracts=e.load(manifest_path)['semanticContracts']
        self.write('95-ROI-REGISTRATION.json', {'source_sha256': '1' * 64, 'manifest_sha256':e.sha(manifest_path), 'contracts_sha256':'6'*64})
        implementation = {}
        for name in e.ROOT_IMPLEMENTATION:
            p = self.root / name
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text('generated fixture, not an executed implementation\n')
            implementation[name] = e.sha(p)
        a = dict(source_sha256='1' * 64, original_registration_sha256=e.sha(self.phase / '95-ROI-REGISTRATION.json'),
                 metric_id=e.ROOT_METRIC, definition_sha256=e.sha(self.phase/e.ROOT_DEFINITION),
                 registration_sha256='3' * 64, registered_pairs=31, model_sha256=e.ROOT_MODEL,
                 runtime_sha256='7' * 64, implementation=implementation)
        a['measurement_identity'] = e.digest(a)
        a.update(schema='phase95-root-measurement-admission-v4', status='registered',
                 reviewer_agent_id='test-root-reviewer', findings=[])
        self.write(e.ROOT_ADMISSION, a)
        self.admission = a
        self.current = e.snapshot(self.root)
        review = dict(schema='phase95-independent-repair-review-v3', status='pass',
                      reviewer_agent_id='test-implementation-reviewer', findings=[], input_digest=self.current['input_digest'])
        self.write(e.REVIEW, review)
        portrait = dict(schema='phase95-clean-65-v4', status='pass', comparison_count=65, outputs=65,
                        fixture_count=1, repeat_count=2,
                        directions={**{x: 'effective' for x in e.ACTIVE}, e.DEFERRED: 'deferred/partial'},
                        measurements=[self.valid_row(c,a) for c in self.contracts],
                        source_report_digest='4'*64, stable_payload_digest='5'*64, contract_id='6'*64,
                        measurement_identity=a['measurement_identity'], root_metric_id=a['metric_id'],
                        root_source_registration_sha256=a['registration_sha256'], root_evidence=self.valid_root_evidence(a))
        self.write('95-CLEAN-65-REPORT.json', portrait)
        binding = dict(self.current, schema='phase95-closeout-binding-v3', review_sha256=e.sha(self.phase/e.REVIEW),
                       portrait_sha256=e.sha(self.phase/'95-CLEAN-65-REPORT.json'),
                       ledger_snapshot={n:e.sha(self.root/n) for n in ('PLANS.md','QUALITY_SCORE.md')})
        self.write('95-CLOSEOUT-BINDING.json', binding)
        self.checks = dict(schema='phase95-closeout-checks-v3', status='pass', phase_complete=False,
                           binding_sha256=e.sha(self.phase/'95-CLOSEOUT-BINDING.json'),
                           input_digest=self.current['input_digest'], portrait_sha256=e.sha(self.phase/'95-CLEAN-65-REPORT.json'),
                           safety=dict(executed=1, failed=0, skipped=0, methods=sorted(e.METHODS['safety'])),
                           compatibility=dict(executed=4, failed=0, skipped=0, methods=sorted(e.METHODS['compatibility'])),
                           no_skip=dict(executed=900, failed=0, skipped=0, opt_in_tests=8), archive_first=True,
                           sdk_boundary='pass', wrapper_self_test='pass', remaining=['95-04-owner-sync-and-goal-verification'])
        self.write('95-CLOSEOUT-CHECKS.json',self.checks)
        self.goal = dict(schema='phase95-goal-verification-v3', status='pass', reviewer_agent_id='test-goal-reviewer',
                         input_digest=self.current['input_digest'], checks_sha256=e.sha(self.phase/'95-CLOSEOUT-CHECKS.json'),
                         binding_sha256=e.sha(self.phase/'95-CLOSEOUT-BINDING.json'), review_sha256=e.sha(self.phase/e.REVIEW),
                         portrait_sha256=e.sha(self.phase/'95-CLEAN-65-REPORT.json'), requirements=e.REQUIREMENTS, findings=[])
        self.write(e.GOAL,self.goal)

    def valid_root_evidence(self,a):
        value={k:a[k] for k in ('metric_id','measurement_identity','source_sha256','original_registration_sha256',
                 'definition_sha256','registration_sha256','model_sha256','runtime_sha256')}
        value.update(schema='phase95-root-batch-evidence-v1',pair_count=a['registered_pairs'],
            crop_rgb_sha256={k:'8'*64 for k in (*e.ROOT_REFERENCES,'candidate')},
            intervals_q16={k:[16,64] for k in e.ROOT_REFERENCES})
        return value

    def test_surface_batch_identity_and_margin_mutations_rejected(self):
        original=e.load(self.phase/'95-CLEAN-65-REPORT.json')
        mutations=[]
        for key in ('definition_sha256','registration_sha256','model_sha256','runtime_sha256','measurement_identity'):
            v=copy.deepcopy(original);v['root_evidence'][key]='0'*64;mutations.append(v)
        v=copy.deepcopy(original);v['root_evidence']['pair_count']=True;mutations.append(v)
        v=copy.deepcopy(original);v['root_evidence']['crop_rgb_sha256'].pop('noseSlim_0p35');mutations.append(v)
        v=copy.deepcopy(original);v['root_evidence']['crop_rgb_sha256']['neutral']='9'*64;mutations.append(v)
        v=copy.deepcopy(original);v['root_evidence']['intervals_q16']['source']=[17,64];mutations.append(v)
        v=copy.deepcopy(original);v['root_evidence']['intervals_q16']['noseBridge_0p30']=[-1,64];mutations.append(v)
        v=copy.deepcopy(original);v['root_evidence']['intervals_q16']['neutral']=[True,64];mutations.append(v)
        v=copy.deepcopy(original);v['root_evidence']['intervals_q16']['source']=[65,64];mutations.append(v)
        for v in mutations:
            with self.subTest(v=v),self.assertRaises(e.GateError):
                e.validate_portrait(v,self.admission,self.contracts,original_contract_id='6'*64)

    def test_portrait_contract_digest_must_match_original_registration(self):
        v=e.load(self.phase/'95-CLEAN-65-REPORT.json')
        v['contract_id']='0'*64
        with self.assertRaises(e.GateError):
            e.validate_portrait(v,self.admission,self.contracts,original_contract_id='6'*64)

    def test_surface_definition_bytes_bound(self):
        (self.phase/e.ROOT_DEFINITION).write_text('changed definition')
        with self.assertRaises(e.GateError):e.root_admission(self.root)

    def valid_row(self,c,a):
        t=c['thresholds'];deferred=c['caseID']==e.DEFERRED
        signed=0 if deferred else t['minimumSignedMarginQ16']*(1 if c['expectedSign']=='positive' else -1)
        row=dict(caseID=c['caseID'],metric=a['metric_id'] if c['caseID']=='noseRootNarrowing_0p25' else c['metric'],
                 fixtureCount=1,sourceTargetChangedPixels=t['minimumChangedPixels'],sourceTargetAbsoluteRGBDelta=t['minimumAbsoluteRGBDelta'],
                 neutralTargetChangedPixels=t['minimumChangedPixels'],neutralTargetAbsoluteRGBDelta=t['minimumAbsoluteRGBDelta'],
                 sourceSignedMarginQ16=signed,neutralSignedMarginQ16=signed,signedMarginQ16=signed,
                 siblingDistinctMarginQ16=t['minimumSignedMarginQ16'],outsideChangedPixels=0,outsideAbsoluteRGBDelta=0,
                 protectedRegions=[dict(id=p['id'],changedPixels=0,absoluteRGBDelta=0) for p in c['protectedRegions']],
                 failureReasonCodes=['neutral_direction','source_direction'] if deferred else [],
                 verdict='semantic_fail' if deferred else 'semantic_pass')
        return row

    def write(self, name, value):
        (self.phase/name).write_text(json.dumps(value, sort_keys=True)+'\n')

    def rejects(self):
        with self.assertRaises(e.GateError):
            e.finalize(self.root)
        self.assertFalse((self.phase/'95-COMPLETE.json').exists())

    def test_complete_is_atomic_exclusive_and_bound(self):
        result=e.finalize(self.root)
        self.assertTrue(result['phase_complete'])
        self.assertEqual(e.load(self.phase/'95-COMPLETE.json'),result)
        before=(self.phase/'95-COMPLETE.json').read_bytes()
        with self.assertRaises(e.GateError): e.finalize(self.root)
        self.assertEqual(before,(self.phase/'95-COMPLETE.json').read_bytes())

    def test_change_during_publication_revokes_only_new_receipt(self):
        publish=e.publish
        def mutate(path,value):
            publish(path,value)
            (self.root/'DESIGN.md').write_text('concurrent contract change')
        with patch.object(e,'publish',side_effect=mutate):
            self.rejects()

    def test_verify_complete_checks_current_code(self):
        e.finalize(self.root)
        self.assertTrue(e.verify_complete(self.root)['phase_complete'])
        (self.root/'DESIGN.md').write_text('changed contract')
        with self.assertRaises(e.GateError):e.verify_complete(self.root)

    def test_reporting_changes_do_not_revoke_acceptance(self):
        for name in ('PLANS.md','QUALITY_SCORE.md','.planning/STATE.md','.planning/ROADMAP.md'):
            p=self.root/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text('new reporting\n')
        self.assertEqual(self.current,e.snapshot(self.root))
        self.assertTrue(e.finalize(self.root)['phase_complete'])

    def test_normative_change_rejects(self):
        (self.root/'DESIGN.md').write_text('changed contract\n')
        self.rejects()

    def test_code_change_rejects(self):
        (self.root/'scripts/phase95-root-forward-span.py').write_text('different\n')
        self.rejects()

    def test_missing_evidence_rejects(self):
        for name in (e.ROOT_ADMISSION,e.REVIEW,e.GOAL,'95-CLOSEOUT-CHECKS.json','95-CLOSEOUT-BINDING.json','95-CLEAN-65-REPORT.json'):
            p=self.phase/name;data=p.read_bytes();p.unlink()
            with self.subTest(name=name):self.rejects()
            p.write_bytes(data)

    def test_checks_reject_even_with_recomputed_goal_hash(self):
        mutations=[('status','fail'),('phase_complete',True),('archive_first',False),('wrapper_self_test','fail'),
                   ('schema','phase95-closeout-checks-v2'),('binding_sha256','0'*64)]
        for key,value in mutations:
            c=copy.deepcopy(self.checks);c[key]=value;self.write('95-CLOSEOUT-CHECKS.json',c)
            g=copy.deepcopy(self.goal);g['checks_sha256']=e.sha(self.phase/'95-CLOSEOUT-CHECKS.json');self.write(e.GOAL,g)
            with self.subTest(key=key):self.rejects()
        for lane in ('safety','compatibility','no_skip'):
            for field,value in (('executed',0),('executed',True),('failed',1),('skipped',1)):
                c=copy.deepcopy(self.checks);c[lane][field]=value;self.write('95-CLOSEOUT-CHECKS.json',c)
                g=copy.deepcopy(self.goal);g['checks_sha256']=e.sha(self.phase/'95-CLOSEOUT-CHECKS.json');self.write(e.GOAL,g)
                with self.subTest(lane=lane,field=field):self.rejects()

    def test_goal_reviewer_coverage_and_bindings(self):
        for key,value in (('reviewer_agent_id','test-implementation-reviewer'),('requirements',{}),('status','fail'),
                          ('checks_sha256','0'*64),('portrait_sha256','0'*64),('findings',['open'])):
            g=copy.deepcopy(self.goal);g[key]=value;self.write(e.GOAL,g)
            with self.subTest(key=key):self.rejects()

    def test_legacy_and_wrong_root_portraits_reject(self):
        p=e.load(self.phase/'95-CLEAN-65-REPORT.json')
        for key,value in (('schema','phase95-clean-65-v2'),('root_metric_id','darkHalfCentroidSpanQ16'),
                          ('measurement_identity','0'*64),('outputs',64),('fixture_count',True),('repeat_count',1)):
            changed=copy.deepcopy(p);changed[key]=value
            with self.subTest(key=key),self.assertRaises(e.GateError): e.validate_portrait(changed,self.admission,self.contracts,original_contract_id='6'*64)
        changed=copy.deepcopy(p);next(row for row in changed['measurements'] if row['caseID']=='noseRootNarrowing_0p25')['metric']='rootWidthContraction'
        with self.assertRaises(e.GateError):e.validate_portrait(changed,self.admission,self.contracts,original_contract_id='6'*64)

    def test_failed_or_incomplete_measurements_reject_after_hash_rebinding(self):
        original=e.load(self.phase/'95-CLEAN-65-REPORT.json')
        for key,value in (('sourceTargetChangedPixels',0),('sourceTargetChangedPixels',True),
                          ('sourceTargetAbsoluteRGBDelta',-1),('neutralSignedMarginQ16',0),
                          ('siblingDistinctMarginQ16',0),('outsideChangedPixels',2**63),
                          ('metric','wrong'),('protectedRegions',[]),('failureReasonCodes',['protected_region'])):
            changed=copy.deepcopy(original)
            row=next(x for x in changed['measurements'] if x['caseID']=='noseRootNarrowing_0p25')
            row[key]=value
            with self.subTest(key=key),self.assertRaises(e.GateError):
                e.validate_portrait(changed,self.admission,self.contracts,original_contract_id='6'*64)
        changed=copy.deepcopy(original)
        next(x for x in changed['measurements'] if x['caseID']=='noseRootNarrowing_0p25')['protectedRegions'][-1]['changedPixels']=1
        self.write('95-CLEAN-65-REPORT.json',changed)
        binding=e.load(self.phase/'95-CLOSEOUT-BINDING.json');binding['portrait_sha256']=e.sha(self.phase/'95-CLEAN-65-REPORT.json')
        self.write('95-CLOSEOUT-BINDING.json',binding)
        checks=copy.deepcopy(self.checks);checks['portrait_sha256']=binding['portrait_sha256'];checks['binding_sha256']=e.sha(self.phase/'95-CLOSEOUT-BINDING.json')
        self.write('95-CLOSEOUT-CHECKS.json',checks)
        goal=copy.deepcopy(self.goal);goal['checks_sha256']=e.sha(self.phase/'95-CLOSEOUT-CHECKS.json');goal['binding_sha256']=checks['binding_sha256'];goal['portrait_sha256']=binding['portrait_sha256']
        self.write(e.GOAL,goal)
        self.rejects()

    def test_false_coverage_and_generic_freeze_reject(self):
        for key,value in (('registered_pairs',3),('registered_pairs',True),('status','source_coverage'),
                          ('metric_id','rootStructuralEdgeSpanQ16_v2_draft2'),('source_sha256','0'*64)):
            a=copy.deepcopy(self.admission);a[key]=value;self.write(e.ROOT_ADMISSION,a)
            with self.subTest(key=key),self.assertRaises(e.GateError):e.root_admission(self.root)

    def test_duplicate_nonfinite_bad_json_reject(self):
        p=self.phase/e.GOAL
        for text in ('{"status":"fail","status":"pass"}','{"n":NaN}','{"n":Infinity}','{"n":1e999}','{'):
            p.write_text(text)
            with self.assertRaises(e.GateError):e.load(p)
        p.write_bytes(b'\xff')
        with self.assertRaises(e.GateError):e.load(p)

    def test_symlink_rejects(self):
        p=self.phase/e.GOAL;data=p.read_bytes();p.unlink();q=self.phase/'another.json';q.write_bytes(data);p.symlink_to(q)
        self.rejects()

    def test_interrupted_publication_leaves_no_partial_receipt(self):
        with patch.object(e.os,'link',side_effect=OSError('simulated interruption')):
            with self.assertRaises(OSError):e.finalize(self.root)
        self.assertFalse((self.phase/'95-COMPLETE.json').exists())
        self.assertEqual([],list(self.phase.glob('.phase95-*')))

    def test_focused_counts_require_actual_methods_and_totals(self):
        for lane in e.METHODS:
            lines=''.join("Test Case '"+m+"' passed (0.01 seconds)\n" for m in e.METHODS[lane])
            text=lines+"Test Suite 'Selected tests' passed at time\n Executed "+str(len(e.METHODS[lane]))+" tests, with 0 failures\n"
            self.assertEqual(e.focused_counts(text.encode(),lane)['executed'],len(e.METHODS[lane]))
            darwin = text
            qualified = text
            for method in e.METHODS[lane]:
                suite, name = method.split('.')
                darwin = darwin.replace(method, '-[BeautyCoreTests.' + suite + ' ' + name + ']')
                qualified = qualified.replace(method, 'BeautyCoreTests.' + method)
            for accepted in (darwin, qualified):
                self.assertEqual(e.focused_counts(accepted.encode(),lane)['executed'],len(e.METHODS[lane]))
            for bad in (text.replace('passed (','skipped ('),text+lines,text.replace('0 failures','1 failures'),
                        text.replace(e.METHODS[lane][0],'Wrong.testMethod')):
                with self.assertRaises(e.GateError):e.focused_counts(bad.encode(),lane)

if __name__=='__main__': unittest.main()
