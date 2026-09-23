#!/usr/bin/env python3
"""Generated protocol tests. No private input, actual admission, model, or renderer is opened."""
import base64,copy,hashlib,importlib.util,json,os,signal,subprocess,tempfile,time,unittest
from pathlib import Path
from unittest import mock
spec=importlib.util.spec_from_file_location('root_batch',Path(__file__).with_name('phase95-root-surface-batch.py'))
b=importlib.util.module_from_spec(spec);spec.loader.exec_module(b)

class ProtocolTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory(prefix='generated-root-batch-test-');self.addCleanup(self.tmp.cleanup)
        self.phase=Path(self.tmp.name);self.raw=b'generated source identity';self.sha=hashlib.sha256(self.raw).hexdigest()
        self.other='b'*64;self.runtime={'model':self.other};self.before={'input_digest':'c'*64}
        self.admission={'metric_id':b.METRIC,'source_sha256':self.sha,'registered_pairs':4,
            'registration_sha256':'d'*64,'measurement_identity':'e'*64,'original_registration_sha256':'f'*64,
            'definition_sha256':'a'*64,'model_sha256':self.other,'runtime_sha256':b.digest(self.runtime)}
        (self.phase/'95-ROI-REGISTRATION.json').write_text(json.dumps({'source_sha256':self.sha,'contracts_sha256':self.other}))
        self.rgb={role:base64.b64encode(bytes([i+1])*12).decode() for i,role in enumerate(b.ROLES)}
        self.rgb['neutral']=self.rgb['source']
        self.packet={'images':{'source':self.rgb['source']},'signals':{},'source_sha256':self.sha,'contracts_sha256':self.other}
        self.cohort={'cohort_commitment':self.admission['registration_sha256'],'ids':[0,1,2,3]}
        self.packet['mesh_input']={'width':2,'height':2,'rgb':self.rgb['source']}
        self.calls=[];self.checked=[]
        def native(command,payload,*_):
            self.calls.append(json.loads(payload));out=copy.deepcopy(self.packet)
            if self.calls[-1]['images']:out['images']=self.calls[-1]['images']
            return json.dumps(out).encode()
        def worker(value):
            if value['mode']=='register':return copy.deepcopy(self.cohort)
            self.measured=copy.deepcopy(value)
            return {'cohort_sha256':self.cohort['cohort_commitment'],'pairs':4,
                'intervals_q16':{role:[16,28] for role in b.REFERENCES}}
        self.probe={'pipe':native,'worker':worker,'clean_observation':lambda value:value,
            'check_binary':lambda path:self.checked.append(path),
            'mesh':{'runtime_snapshot':lambda:self.runtime,'predict':lambda packet:[]}}
        self.real_check=b.check_admission
        patches=[mock.patch.object(b,'PHASE',self.phase),
            mock.patch.object(b,'check_admission',lambda:(self.admission,self.probe,self.before)),
            mock.patch.object(b,'compile_native',lambda directory,probe:Path(directory)/'generated-binary'),
            mock.patch.object(b.runpy,'run_path',lambda path:{'snapshot':lambda root:self.before,'root_admission':lambda root:self.admission})]
        for patch in patches:patch.start();self.addCleanup(patch.stop)
        self.request={'schema':'phase95-root-batch-input-v1','mode':'register','source_encoded':base64.b64encode(self.raw).decode(),
            'source_sha256':self.sha,'source_rgba_sha256':self.other,'contracts_sha256':self.other,
            'registration':None,'images':{},'signals':{}}

    def measure_request(self):
        registration=b.execute(self.request)
        return {**self.request,'mode':'measure','registration':registration,'images':self.rgb,'signals':{'neutralIdentity':True}}

    def test_source_only_register_before_outputs(self):
        value=b.execute(self.request)
        self.assertEqual(value['cohort'],self.cohort);self.assertEqual(self.calls[0]['images'],{})
        self.assertEqual(len(self.checked),2)

    def test_supplied_batch_bytes_are_forwarded_and_hashed(self):
        request=self.measure_request();value=b.execute(request)
        self.assertEqual(self.measured['rendered']['images'],self.rgb)
        expected={role:hashlib.sha256(base64.b64decode(data)).hexdigest() for role,data in self.rgb.items()}
        self.assertEqual(value['crop_rgb_sha256'],expected)
        self.assertEqual(value['registration_sha256'],self.admission['registration_sha256'])
        self.assertEqual(set(value),set('schema metric_id measurement_identity source_sha256 original_registration_sha256 definition_sha256 registration_sha256 model_sha256 runtime_sha256 pair_count crop_rgb_sha256 intervals_q16'.split()))
        self.assertNotIn('images',value);self.assertNotIn('cohort',value)

    def test_mutating_one_actual_output_changes_its_binding(self):
        request=self.measure_request();first=b.execute(request)
        altered=copy.deepcopy(request);altered['images']['candidate']=base64.b64encode(b'changed crop').decode()
        second=b.execute(altered)
        self.assertNotEqual(first['crop_rgb_sha256']['candidate'],second['crop_rgb_sha256']['candidate'])
        self.assertEqual(first['crop_rgb_sha256']['source'],second['crop_rgb_sha256']['source'])

    def test_registration_rejects_candidate_before_native(self):
        request=copy.deepcopy(self.request);request['images']=self.rgb
        with self.assertRaises(ValueError):b.execute(request)
        self.assertEqual(self.calls,[])

    def test_closed_request_fields_and_modes(self):
        for key,value in [('extra',1),('mode','evaluate'),('schema','old'),('images',[]),('signals',True)]:
            request=copy.deepcopy(self.request);request[key]=value
            with self.subTest(key=key),self.assertRaises(ValueError):b.execute(request)

    def test_source_bytes_cannot_be_substituted(self):
        request=copy.deepcopy(self.request);request['source_encoded']=base64.b64encode(b'another').decode()
        with self.assertRaises(ValueError):b.execute(request)
        self.assertEqual(self.calls,[])

    def test_exact_six_roles(self):
        for role in b.ROLES:
            request=self.measure_request();del request['images'][role]
            with self.subTest(role=role),self.assertRaises(ValueError):b.execute(request)

    def test_cohort_and_measurement_binding(self):
        for key in ('cohort_commitment','ids'):
            request=self.measure_request()
            request['registration']['cohort'][key]='0'*64 if key=='cohort_commitment' else [0,1,2]
            with self.subTest(key=key),self.assertRaises(ValueError):b.execute(request)
        request=self.measure_request();request['registration']['measurement_identity']='0'*64
        with self.assertRaises(ValueError):b.execute(request)

    def test_runtime_change_during_execution_rejects(self):
        changed=dict(self.runtime,model='0'*64)
        self.probe['mesh']['runtime_snapshot']=lambda:changed
        with self.assertRaises(ValueError):b.execute(self.request)

    def test_duplicate_and_nonfinite_input_rejected(self):
        for raw in [b'{"mode":1,"mode":2}',b'{"x":NaN}',b'{"x":Infinity}']:
            with self.subTest(raw=raw),self.assertRaises(ValueError):b.decode(raw)

    def test_old_metric_admission_rejected(self):
        old=dict(self.admission,metric_id='rootStructuralEdgeSpanQ16_v3')
        with mock.patch.object(b.runpy,'run_path',return_value={'root_admission':lambda root:old}):
            with self.assertRaises(ValueError):self.real_check()


class ManagedTransportTests(unittest.TestCase):
    """Public generated subprocesses only; never invoke admission or a model."""
    def run_managed(self,child,payload=b'generated',maximum=4096,seconds=1):
        # The test supervisor stands in for the Swift readiness-owned leader.
        # All actual batch children must retain that leader's process group.
        program="""
import os,sys,runpy,json,time
b=runpy.run_path(sys.argv[1]);spec=json.loads(sys.stdin.buffer.read())
real=b['subprocess'].Popen;observed=[]
def tracked(*args,**kwargs):
    p=real(*args,**kwargs);observed.append(p.pid);return p
b['subprocess'].Popen=tracked
start=time.monotonic()
try:
    output=b['managed_pipe'](['/usr/bin/python3','-I','-B','-c',spec['child']],
        bytes(spec['payload']),spec['seconds'],spec['maximum'])
    status='ok';value=output.decode()
except Exception:
    status='rejected';value=''
print(json.dumps(dict(status=status,value=value,pids=observed,group=os.getpgrp(),elapsed=time.monotonic()-start)))
"""
        command=['/usr/bin/python3','-I','-B','-c',program,str(Path(b.__file__).resolve())]
        process=subprocess.Popen(command,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,start_new_session=True)
        try:
            data=json.dumps(dict(child=child,payload=list(payload),maximum=maximum,seconds=seconds)).encode()
            raw,_=process.communicate(data,timeout=5)
            self.assertEqual(process.returncode,0);value=json.loads(raw)
            self.assertEqual(value['group'],process.pid)
            self.assertLess(value['elapsed'],4)
            for pid in value['pids']:
                with self.assertRaises(ProcessLookupError):os.kill(pid,0)
            return value
        finally:
            try:os.killpg(process.pid,signal.SIGKILL)
            except ProcessLookupError:pass
            process.wait(timeout=2)
            for stream in (process.stdin,process.stdout):stream.close()

    def test_actual_child_inherits_owned_group_and_drains_backpressure(self):
        script="import os,sys,json;data=sys.stdin.buffer.read();print(json.dumps([os.getpgrp(),len(data)]))"
        result=self.run_managed(script,payload=b'x'*200000)
        self.assertEqual(result['status'],'ok');self.assertEqual(json.loads(result['value']),[result['group'],200000])

    def test_actual_term_ignoring_timeout_is_bounded_and_reaped(self):
        script="import signal,time;signal.signal(signal.SIGTERM,signal.SIG_IGN);time.sleep(60)"
        self.assertEqual(self.run_managed(script,payload=b'x'*200000,seconds=.3)['status'],'rejected')

    def test_actual_oversized_stdout_and_stderr_fail_closed(self):
        for fd in (1,2):
            script="import os,sys;sys.stdin.buffer.read();os.write(%d,b'x'*8192)"%fd
            with self.subTest(fd=fd):self.assertEqual(self.run_managed(script)['status'],'rejected')

    def test_actual_nonzero_child_rejected(self):
        self.assertEqual(self.run_managed("import sys;sys.stdin.buffer.read();sys.exit(3)")['status'],'rejected')

    def test_unmanaged_group_rejected_before_spawn(self):
        with mock.patch.object(b.os,'getpgrp',return_value=os.getpid()+1),mock.patch.object(b.subprocess,'Popen') as spawned:
            with self.assertRaises(ValueError):b.managed_pipe(['/usr/bin/true'])
            spawned.assert_not_called()

if __name__=='__main__':unittest.main()
