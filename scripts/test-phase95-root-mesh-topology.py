#!/usr/bin/env python3
import runpy,unittest,tempfile
from pathlib import Path
m=runpy.run_path(str(Path(__file__).with_name('phase95-root-mesh-topology.py')))
class Tests(unittest.TestCase):
    vertices=((-1,2,0),(-1,0,1),(1,2,0),(1,0,1),(0,1,2))
    faces=((0,1,4),(2,3,4));chains=(((0,1),(2,3)),)
    def test_connected_mirror_prior_is_not_acceptance(self):
        r=m['validate'](self.vertices,self.faces,self.chains)
        self.assertEqual(r['hypotheses'],1);self.assertFalse(r['anatomical_boundary_qualified']);self.assertFalse(r['portrait_scoring_enabled'])
    def test_invalid_topology_cannot_supply_a_side(self):
        for f,c in ((self.faces[:1],self.chains),(self.faces,(((1,0),(3,2)),)),(self.faces,(((0,0),(2,2)),)),(self.faces,(((0,4),(2,3)),))):
            with self.assertRaises(m['Rejected']):m['validate'](self.vertices,f,c)
    def test_shape_and_nonfinite_reject(self):
        for v,f,c in (((),self.faces,self.chains),(self.vertices,(),self.chains),(self.vertices,((0,1,99),),self.chains),(self.vertices,self.faces,()),(((float('nan'),2,0),)+self.vertices[1:],self.faces,self.chains)):
            with self.assertRaises(m['Rejected']):m['validate'](v,f,c)
    def test_wrong_mirror_rejects(self):
        v=self.vertices[:2]+((2,2,0),)+self.vertices[3:]
        with self.assertRaises(m['Rejected']):m['validate'](v,self.faces,self.chains)
    def test_changed_asset_and_symlink_reject(self):
        with tempfile.TemporaryDirectory() as d:
            p=Path(d)/'model.obj';p.write_text('v 0 0 0\n')
            with self.assertRaises(m['Rejected']):m['inspect'](p)
            link=Path(d)/'link.obj';link.symlink_to(p)
            with self.assertRaises(m['Rejected']):m['inspect'](link)
    def test_malformed_elements_reject_without_untyped_errors(self):
        for f,c in ((((0,1,[]),),self.chains),(self.faces,(((0,[]),(2,3)),))):
            with self.assertRaises(m['Rejected']):m['validate'](self.vertices,f,c)
        v=((10**1000,2,0),)+self.vertices[1:]
        with self.assertRaises(m['Rejected']):m['validate'](v,self.faces,self.chains)
if __name__=='__main__':unittest.main()
