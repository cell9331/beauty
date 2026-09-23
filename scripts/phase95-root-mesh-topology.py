#!/usr/bin/env python3
"""PUBLIC canonical mesh candidates, never portrait inputs or admission."""
import hashlib,json,math,sys
from pathlib import Path
MODEL_SHA='8bac80443397e113f41a8b565ea72c59390bc031d9defab289dba7bc0c54e618'
CHAINS=(((55,193,122,196),(285,417,351,419)),((55,193,189,244,128),(285,417,413,464,357)))
class Rejected(Exception):pass

def validate(vertices,faces,chains):
    if (type(vertices) is not tuple or not 4<=len(vertices)<=478
        or any(type(v) is not tuple or len(v)!=3 or any(type(x) not in (int,float) or not -10000<=x<=10000 or not math.isfinite(x) for x in v) for v in vertices)
        or type(faces) is not tuple or not 1<=len(faces)<=2000
        or any(type(f) is not tuple or len(f)!=3 or any(type(i) is not int or not 0<=i<len(vertices) for i in f) or len(set(f))!=3 for f in faces)
        or type(chains) is not tuple or not 1<=len(chains)<=64):raise Rejected('invalid_mesh')
    edges={tuple(sorted((f[i],f[(i+1)%3]))) for f in faces for i in range(3)}
    for pair in chains:
        if type(pair) is not tuple or len(pair)!=2:raise Rejected('invalid_chain')
        left,right=pair
        if (any(type(c) is not tuple or not 2<=len(c)<=16 or any(type(i) is not int or not 0<=i<len(vertices) for i in c) or len(set(c))!=len(c) for c in pair)
            or len(left)!=len(right)):raise Rejected('invalid_chain')
        for a,b in zip(left,right):
            x,y,z=vertices[a];xx,yy,zz=vertices[b]
            if not x<0<xx or (xx,yy,zz)!=(-x,y,z):raise Rejected('not_mirrored_sides')
        for c in pair:
            if any(tuple(sorted((a,b))) not in edges or not vertices[a][1]>vertices[b][1] for a,b in zip(c,c[1:])):raise Rejected('disconnected_or_nonmonotone')
    return {'hypotheses':len(chains),'chains':2*len(chains),'canonical_prior_only':True,'anatomical_boundary_qualified':False,'portrait_scoring_enabled':False}

def inspect(path):
    path=Path(path)
    if path.is_symlink() or not path.is_file() or not 0<path.stat().st_size<=1024*1024:raise Rejected('public_asset')
    data=path.read_bytes()
    if hashlib.sha256(data).hexdigest()!=MODEL_SHA:raise Rejected('public_asset_identity')
    vertices=[];faces=[]
    for line in data.decode('ascii').splitlines():
        words=line.split()
        if words and words[0]=='v':vertices.append(tuple(map(float,words[1:])))
        elif words and words[0]=='f':faces.append(tuple(int(v.split('/')[0])-1 for v in words[1:]))
    if len(vertices)!=468 or len(faces)!=898:raise Rejected('public_asset_shape')
    return dict(validate(tuple(vertices),tuple(faces),CHAINS),schema='phase95-public-mesh-prior-v1',vertices=468,faces=898,public_asset_sha256=MODEL_SHA)

if __name__=='__main__':
    try:
        if len(sys.argv)!=3 or sys.argv[1]!='--inspect-public-mesh':raise Rejected('arguments')
        print(json.dumps(inspect(sys.argv[2]),sort_keys=True))
    except Exception:
        print('{"status":"rejected","reason":"public_mesh_prior"}');sys.exit(1)
