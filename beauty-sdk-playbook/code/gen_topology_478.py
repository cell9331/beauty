#!/usr/bin/env python3
"""
478 点方案：离线生成固定三角拓扑 + 示例权重图。

输入：MediaPipe 的规范人脸模型 canonical_face_model.obj（468 个顶点 + 三角面）。
      官方仓库路径：mediapipe/modules/face_geometry/data/canonical_face_model.obj
      请自行下载，并确认其许可条款。本脚本不内置该文件。
      不提供 --obj 时，退化为对 --points JSON（{"points": [[x,y],...468或478]}) 做 Delaunay。

顶点布局（运行时必须一致）：
  [0..467]      MediaPipe 468 面部网格点（虹膜 468~477 不入网格，随周围顶点插值运动）
  [468..]       额头扩展点（在脸外上方，位移由额头/发际线功能决定，默认随脸）
  [..]          下颌/颈部扩展点（去双下巴用）
  [..]          外环点（位移恒 0）
  [..]          图像边界锚点（位移恒 0）
vertex_types.json 记录每段类型与范围，运行时据此决定 fixed 标记。

用法：
  python3 gen_topology_478.py --obj canonical_face_model.obj --out indices478.bin \
      --meta canonical478.json --preview topology478.png
"""
import argparse, json, struct
import numpy as np
from scipy.spatial import Delaunay, ConvexHull

OVAL = [10,338,297,332,284,251,389,356,454,323,361,288,397,365,379,378,400,377,152,
        148,176,149,150,136,172,58,132,93,234,127,162,21,54,103,67,109]
TOP_ARC = [54,103,67,109,10,338,297,332,284]          # 额头上缘
LOW_ARC = [58,172,136,150,149,176,148,152,377,400,378,379,365,397,288]  # 下颌下缘
EYE_OUT_R, EYE_OUT_L, NASION, CHIN, TOP = 33, 263, 168, 152, 10
EAR_R, EAR_L = 234, 454


def load_obj(path):
    v, f = [], []
    for line in open(path, encoding="utf-8"):
        if line.startswith("v "):
            v.append([float(x) for x in line.split()[1:4]])
        elif line.startswith("f "):
            f.append([int(t.split("/")[0]) - 1 for t in line.split()[1:4]])
    return np.array(v), np.array(f, dtype=int)


def to_canvas(v3, W, H):
    """规范模型(y 向上, 厘米) -> 画布像素(左上原点, y 向下)，脸宽占画布 50%。"""
    p = np.stack([v3[:, 0], -v3[:, 1]], 1)
    face_w = np.linalg.norm(p[EAR_L] - p[EAR_R])
    s = 0.5 * W / face_w
    p = (p - p[NASION]) * s + np.array([W / 2, H * 0.42])
    return p


def point_in_poly(pt, poly):
    x, y = pt; inside = False
    n = len(poly)
    for i in range(n):
        x1, y1 = poly[i]; x2, y2 = poly[(i + 1) % n]
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1 + 1e-12) + x1:
            inside = not inside
    return inside


def build_vertices(face, W, H, forehead_k=0.35, neck_k=0.30, ring_off=0.25, border_n=4):
    face_w = np.linalg.norm(face[EAR_L] - face[EAR_R])
    face_h = np.linalg.norm(face[TOP] - face[CHIN])
    up = face[NASION] - face[CHIN]; up /= np.linalg.norm(up)
    center = face[NASION]

    ext_fore = np.array([face[i] + up * forehead_k * face_h for i in TOP_ARC])
    ext_neck = np.array([face[i] - up * neck_k * face_h for i in LOW_ARC])

    outer = np.vstack([face[OVAL], ext_fore, ext_neck])
    hull = ConvexHull(outer); hp = outer[hull.vertices]
    ring = []
    for i in range(len(hp)):
        a, b = hp[i], hp[(i + 1) % len(hp)]
        for q in (a, (a + b) / 2):
            d = q - center; d /= np.linalg.norm(d)
            ring.append(q + d * ring_off * face_w)
    ring = np.array(ring)

    border = []
    for i in range(border_n + 1):
        t = i / border_n
        border += [[t * (W - 1), 0], [t * (W - 1), H - 1]]
    for i in range(1, border_n):
        t = i / border_n
        border += [[0, t * (H - 1)], [W - 1, t * (H - 1)]]
    border = np.array(border, dtype=float)

    allv = np.vstack([face, ext_fore, ext_neck, ring, border])
    allv[:, 0] = np.clip(allv[:, 0], 0, W - 1); allv[:, 1] = np.clip(allv[:, 1], 0, H - 1)
    n0 = len(face)
    types = [("face", 0, n0),
             ("forehead_ext", n0, n0 + len(ext_fore)),
             ("neck_ext", n0 + len(ext_fore), n0 + len(ext_fore) + len(ext_neck))]
    s = types[-1][2]
    types += [("ring_fixed", s, s + len(ring)), ("border_fixed", s + len(ring), len(allv))]
    return allv, types


def signed_area(a, b, c):
    return 0.5 * ((b[0]-a[0])*(c[1]-a[1]) - (c[0]-a[0])*(b[1]-a[1]))


def triangulate(verts, canon_faces, n_face):
    tri = Delaunay(verts).simplices
    hull_area = ConvexHull(verts).volume                     # 2D 下 volume = 面积
    if canon_faces is not None:
        oval_poly = verts[OVAL]
        keep = [t for t in tri if not point_in_poly(verts[t].mean(0), oval_poly)]
        tris = np.vstack([np.array(keep).reshape(-1, 3), canon_faces])
        cov = sum(abs(signed_area(*verts[t])) for t in tris) / hull_area
        if abs(cov - 1) < 0.01:
            mode = "canonical_faces+outer_delaunay"
        else:
            print(f"警告：拼接后面积覆盖比 {cov:.3f}，回退到整体 Delaunay")
            tris, mode = tri, "delaunay_fallback"
    else:
        tris, mode = tri, "delaunay"
    out = []                                                  # 统一朝向
    for t in tris:
        a, b, c = verts[t]
        out.append(t if signed_area(a, b, c) > 0 else [t[0], t[2], t[1]])
    return np.array(out, dtype=np.uint16), mode


def smoothstep(e0, e1, x):
    t = np.clip((x - e0) / (e1 - e0), 0, 1); return t * t * (3 - 2 * t)


def region_weights(verts, center, radius):
    """示例：以 center 为中心、radius 为半径的平滑衰减权重（1 在中心，0 在半径外）。
    实际项目对每个功能用"种子点集合到各顶点的最近距离"生成，离线写入，运行时只读。"""
    d = np.linalg.norm(verts - center, axis=1)
    return 1 - smoothstep(0.0, radius, d)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--obj"); ap.add_argument("--points")
    ap.add_argument("--out", default="indices478.bin"); ap.add_argument("--meta", default="canonical478.json")
    ap.add_argument("--preview"); ap.add_argument("--size", type=int, default=1024)
    a = ap.parse_args(); W = H = a.size

    faces = None
    if a.obj:
        v3, faces = load_obj(a.obj); face = to_canvas(v3[:468], W, H)
    elif a.points:
        pts = np.array(json.load(open(a.points))["points"])[:468]; face = pts
    else:
        raise SystemExit("需要 --obj 或 --points")

    verts, types = build_vertices(face, W, H)
    tris, mode = triangulate(verts, faces, 468)
    print(f"顶点 {len(verts)}，三角形 {len(tris)}，模式 {mode}")

    with open(a.out, "wb") as f:
        f.write(struct.pack("<II", len(verts), len(tris))); f.write(tris.astype("<u2").tobytes())

    # 示例权重：右眼大眼影响范围（以 33/133 中点为中心，半径=眼宽*1.8）
    eye_c = (verts[33] + verts[133]) / 2; eye_w = np.linalg.norm(verts[33] - verts[133])
    meta = {"canvas": [W, H], "vertex_types": [{"type": t, "start": s, "end": e} for t, s, e in types],
            "vertices": verts.round(3).tolist(), "topology_mode": mode,
            "demo_weights": {"bigEyeR": region_weights(verts, eye_c, eye_w * 1.8).round(4).tolist()}}
    json.dump(meta, open(a.meta, "w"))
    print("已写出", a.out, a.meta)

    if a.preview:
        try:
            import matplotlib; matplotlib.use("Agg"); import matplotlib.pyplot as plt
        except ImportError:
            return
        fig, ax = plt.subplots(figsize=(7, 7))
        ax.triplot(verts[:, 0], verts[:, 1], tris.astype(int), lw=0.3)
        ax.set_xlim(0, W); ax.set_ylim(H, 0); ax.set_aspect("equal"); fig.savefig(a.preview, dpi=150)


if __name__ == "__main__":
    main()
