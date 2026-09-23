#!/usr/bin/env python3
"""Internal pipe worker. No image paths, file output, camera or network input."""
import base64
import errno
import hashlib
import json
import math
from pathlib import Path
import socket
import sys

MODEL_SHA = '64184e229b263107bc2b804c6625db1341ff2bb731874b0bcc2fe6544e0bc9ff'


def unique(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('duplicate')
        result[key] = value
    return result


def packet(data):
    if len(data) > 2*1024*1024:
        raise ValueError('size')
    value = json.loads(data, object_pairs_hook=unique)
    if type(value) is not dict or set(value) != {'width','height','rgb'}:
        raise ValueError('schema')
    if any(type(value[k]) is not int or not 1 <= value[k] <= 512 for k in ('width','height')):
        raise ValueError('dimensions')
    if type(value['rgb']) is not str:
        raise ValueError('rgb')
    raw = base64.b64decode(value['rgb'], validate=True)
    if len(raw) != value['width']*value['height']*3:
        raise ValueError('rgb')
    return value['width'], value['height'], raw


def run():
    if not sys.flags.isolated or len(sys.argv) != 2:
        raise ValueError('invocation')
    try:
        with socket.socket() as probe:
            probe.bind(('127.0.0.1',0))
    except OSError as error:
        if error.errno not in (errno.EPERM,errno.EACCES):
            raise ValueError('network_probe')
    else:
        raise ValueError('network_not_denied')
    path = Path(sys.argv[1])
    if path.is_symlink() or not path.is_file() or path.stat().st_size != 3758596:
        raise ValueError('model')
    model = path.read_bytes()
    if hashlib.sha256(model).hexdigest() != MODEL_SHA:
        raise ValueError('model')
    width,height,raw = packet(sys.stdin.buffer.read(2*1024*1024+1))
    import numpy as np
    import mediapipe as mp
    if mp.__version__ != '0.10.32':
        raise ValueError('runtime')
    data = np.frombuffer(raw,dtype=np.uint8).reshape(height,width,3).copy()
    options = mp.tasks.vision.FaceLandmarkerOptions(
        base_options=mp.tasks.BaseOptions(model_asset_buffer=model,delegate=mp.tasks.BaseOptions.Delegate.CPU),
        running_mode=mp.tasks.vision.RunningMode.IMAGE,num_faces=2,
        output_face_blendshapes=False,output_facial_transformation_matrixes=False)
    with mp.tasks.vision.FaceLandmarker.create_from_options(options) as detector:
        result = detector.detect(mp.Image(image_format=mp.ImageFormat.SRGB,data=data))
    if data.tobytes() != raw:
        raise ValueError('input_mutated')
    faces = result.face_landmarks
    points = []
    if len(faces) == 1:
        if len(faces[0]) != 478:
            raise ValueError('inventory')
        points = [[float(p.x),float(p.y)] for p in faces[0]]
        if any(not math.isfinite(v) or not 0 <= v <= 1 for p in points for v in p):
            raise ValueError('coordinates')
    # Only the bounded parent consumes this ephemeral result. It never persists
    # or forwards these coordinates to the external tool transcript.
    print(json.dumps({'schema':'phase95-mesh-pipe-v1','face_count':len(faces),'points':points},sort_keys=True))


if __name__ == '__main__':
    try:
        run()
    except Exception:
        print('{"status":"rejected","reason":"mesh_worker"}')
        sys.exit(1)
