#!/usr/bin/env python3
import base64
from fractions import Fraction as F
import json
from pathlib import Path
import runpy
import unittest
import tempfile

ROOT=Path(__file__).resolve().parents[1]
worker=runpy.run_path(str(ROOT/'scripts/phase95-root-mesh-source-worker.py'))
diagnostic=runpy.run_path(str(ROOT/'scripts/phase95-root-mesh-source-diagnostic.py'))


class MeshSourceProtocolTests(unittest.TestCase):
    def test_generated_packet_and_strict_rejections(self):
        valid={'width':2,'height':2,'rgb':base64.b64encode(bytes(12)).decode()}
        self.assertEqual(worker['packet'](json.dumps(valid).encode()),(2,2,bytes(12)))
        for key,value in [('width',True),('width',513),('height',0),('rgb','!'),('rgb',None),('rgb','')]:
            bad=dict(valid);bad[key]=value
            with self.assertRaises((ValueError,TypeError)):
                worker['packet'](json.dumps(bad).encode())
        for data in (b'[]',b'{}',b'{"width":2,"width":2}',b'x'*(2*1024*1024+1)):
            with self.assertRaises((ValueError,TypeError)):
                worker['packet'](data)

    def test_all_polyline_intersections_retained_without_extrapolation(self):
        points=((F(0),F(0)),(F(1),F(1)),(F(2),F(0)))
        self.assertEqual(diagnostic['crossings'](points,(0,1,2),F(1,2)),[F(1,2),F(3,2)])
        self.assertEqual(diagnostic['crossings'](points,(0,1,2),F(2)),[])
        self.assertEqual(diagnostic['crossings'](((F(0),F(1)),(F(2),F(1))),(0,1),F(1)),[F(0),F(2)])

    def test_pixel_center_mapping_with_noninteger_scaling(self):
        for width in (63,64,511,512,777,1024):
            for x in (0,width//2,width-1):
                self.assertEqual(diagnostic['profile_coordinate'](F(2*x+1,2*width),width),x)
            small=min(width,512)
            for x in (0,small//2,small-1):
                normalized=F(2*x+1,2*small)
                mapped=diagnostic['profile_coordinate'](normalized,width)
                sampled=(2*x+1)*width//(2*small)
                self.assertLessEqual(abs(mapped-sampled),F(1,2))

    def test_runtime_executable_closure(self):
        with tempfile.TemporaryDirectory() as directory:
            site=Path(directory);(site/'pkg').mkdir();(site/'pkg/a.py').write_text('pass')
            expected={'pkg/a.py'}
            self.assertEqual(diagnostic['runtime_extras'](site,expected,set()),[])
            for name in ('extra.pth','sitecustomize.py','a.pyc'):
                path=site/name;path.write_text('pass')
                with self.assertRaises(ValueError):diagnostic['runtime_extras'](site,expected,set())
                path.unlink()
            link=site/'link';link.symlink_to(site/'pkg')
            with self.assertRaises(ValueError):diagnostic['runtime_extras'](site,expected,set())
            link.unlink()
            cache=site/'pkg/__pycache__';cache.mkdir()
            (cache/'a.cpython-312.pyc').write_bytes(b'ignored by fresh cache prefix')
            self.assertEqual(diagnostic['runtime_extras'](site,expected,set()),[])
            (cache/'unknown.cpython-312.pyc').write_bytes(b'bad')
            with self.assertRaises(ValueError):diagnostic['runtime_extras'](site,expected,set())

    def test_source_export_is_bounded_and_does_not_dispatch_outputs(self):
        code=diagnostic['source_code']().decode()
        self.assertIn('512.0 / Double(max(image.width, image.height))',code)
        self.assertIn('"phase95-mesh-source-ephemeral-v1"',code)
        self.assertIn('image.rgba[offset..<offset+3]',code)
        self.assertNotIn('let commandArguments = Array(CommandLine.arguments.dropFirst())',code)
        self.assertNotIn('let binding = try RootStructuralMetricPrototype.register(luminance,',code)


if __name__=='__main__':unittest.main()
