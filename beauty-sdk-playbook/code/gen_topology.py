#!/usr/bin/env python3
"""
离线生成固定三角拓扑（在"标准脸"上做一次 Delaunay，运行时不再重新剖分）。

用法：
    python3 gen_topology.py --canonical canonical_68.json --out indices.bin --preview topology.png

canonical_68.json 格式：{"points": [[x, y], ...68个点...], "image_size": [W, H]}
  - 坐标为标准脸(平均脸)在 image_size 画布中的像素坐标，左上原点。
  - 若不提供 --canonical，则使用内置的粗略示意脸（仅供跑通流程，不代表真实标准脸）。

生成顶点顺序（运行时必须与之一致）：
  [0..67]            主关键点
  [68..68+E-1]       额头扩展点
  [..]               外环点（轮廓点沿外法线外扩，位移恒 0）
  [..]               图像边界锚点（四角 + 每边若干点，位移恒 0）
说明：加密点(眼睑/唇样条)请按你的点位模型在 build_vertices() 中追加。
"""
import argparse
import json
import struct

import numpy as np
from scipy.spatial import Delaunay

MIN_ANGLE_DEG = 15.0
MIN_AREA_RATIO = 1e-4          # 相对画布面积


def builtin_canonical():
    """内置粗略示意脸：仅用于跑通脚本。68 点按 dlib 顺序大致摆放在 512x512 画布。"""
    W = H = 512
    pts = []
    # 轮廓 0..16：半椭圆
    for i in range(17):
        t = np.pi * (i / 16.0)
        pts.append([256 - 150 * np.cos(t), 230 + 200 * np.sin(t)])
    # 眉 17..26
    for i in range(5):
        pts.append([150 + i * 28, 170 - 8 * np.sin(i / 4 * np.pi)])
    for i in range(5):
        pts.append([262 + i * 28, 170 - 8 * np.sin(i / 4 * np.pi)])
    # 鼻梁 27..30
    for i in range(4):
        pts.append([256, 200 + i * 25])
    # 鼻底 31..35
    for i in range(5):
        pts.append([230 + i * 13, 290 + (6 if i in (0, 4) else 0)])
    # 右眼 36..41、左眼 42..47
    for cx in (190, 322):
        for k in range(6):
            a = 2 * np.pi * k / 6
            pts.append([cx + 28 * np.cos(a), 215 + 11 * np.sin(a)])
    # 外唇 48..59
    for k in range(12):
        a = 2 * np.pi * k / 12
        pts.append([256 + 55 * np.cos(a), 350 + 20 * np.sin(a)])
    # 内唇 60..67
    for k in range(8):
        a = 2 * np.pi * k / 8
        pts.append([256 + 35 * np.cos(a), 350 + 9 * np.sin(a)])
    return np.array(pts, dtype=np.float64), (W, H)


def build_vertices(canon, size, forehead_n=5, ring_offset=0.25, border_per_side=3):
    W, H = size
    face_w = canon[16][0] - canon[0][0]
    eye_mid = (canon[36:42].mean(0) + canon[42:48].mean(0)) / 2
    chin = canon[8]
    up = (eye_mid - chin)
    up = up / np.linalg.norm(up)

    verts = [p for p in canon]                     # 主关键点

    # 额头扩展点：沿"下巴->眉心"方向向上外推，横向分布
    brow_mid = (canon[19] + canon[24]) / 2
    forehead_h = np.linalg.norm(brow_mid - chin) * 0.35
    xs = np.linspace(canon[17][0], canon[26][0], forehead_n)
    for x in xs:
        base = np.array([x, brow_mid[1]])
        verts.append(base + up * forehead_h)

    # 外环点：轮廓点(0..16) + 额头点 沿外法线外扩
    center = canon[27:31].mean(0)
    ring_src = list(canon[0:17]) + list(verts[68:68 + forehead_n][::-1])
    for p in ring_src:
        d = p - center
        d = d / np.linalg.norm(d)
        verts.append(p + d * ring_offset * face_w)

    # 图像边界锚点
    for i in range(border_per_side + 1):
        t = i / border_per_side
        verts.append(np.array([t * (W - 1), 0.0]))
        verts.append(np.array([t * (W - 1), H - 1.0]))
    for i in range(1, border_per_side):
        t = i / border_per_side
        verts.append(np.array([0.0, t * (H - 1)]))
        verts.append(np.array([W - 1.0, t * (H - 1)]))

    verts = np.array(verts)
    # 裁剪到画布内（外环可能略超出）
    verts[:, 0] = np.clip(verts[:, 0], 0, W - 1)
    verts[:, 1] = np.clip(verts[:, 1], 0, H - 1)
    return verts


def tri_min_angle(a, b, c):
    def ang(p, q, r):
        v1, v2 = q - p, r - p
        cosv = np.dot(v1, v2) / (np.linalg.norm(v1) * np.linalg.norm(v2) + 1e-12)
        return np.degrees(np.arccos(np.clip(cosv, -1, 1)))
    return min(ang(a, b, c), ang(b, c, a), ang(c, a, b))


def build_topology(verts, size):
    W, H = size
    tri = Delaunay(verts)
    keep, dropped = [], 0
    for s in tri.simplices:
        a, b, c = verts[s]
        area = 0.5 * abs((b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1]))
        if area < MIN_AREA_RATIO * W * H:
            dropped += 1
            continue
        if tri_min_angle(a, b, c) < MIN_ANGLE_DEG:
            # 注意：直接丢弃会在网格上留下空洞。边界/外环处的狭长三角往往不可避免；
            # 实际项目应改为"调整点位或手工补点"，这里仅统计并保留，避免空洞。
            dropped += 0
        keep.append(s)
    return np.array(keep, dtype=np.uint16), dropped


def check_coverage(verts, tris, size):
    """粗略检查：三角形面积之和应接近凸包面积；有向面积符号统一。"""
    total, signs = 0.0, set()
    for s in tris:
        a, b, c = verts[s]
        sa = 0.5 * ((b[0] - a[0]) * (c[1] - a[1]) - (c[0] - a[0]) * (b[1] - a[1]))
        total += abs(sa)
        signs.add(sa > 0)
    W, H = size
    return total / (W * H), signs


def preview(verts, tris, size, path):
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib 未安装，跳过预览")
        return
    fig, ax = plt.subplots(figsize=(6, 6))
    ax.triplot(verts[:, 0], verts[:, 1], tris.astype(int), lw=0.5)
    ax.plot(verts[:, 0], verts[:, 1], "r.", ms=2)
    ax.set_xlim(0, size[0]); ax.set_ylim(size[1], 0); ax.set_aspect("equal")
    fig.savefig(path, dpi=150)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--canonical")
    ap.add_argument("--out", default="indices.bin")
    ap.add_argument("--preview")
    args = ap.parse_args()

    if args.canonical:
        d = json.load(open(args.canonical))
        canon = np.array(d["points"], dtype=np.float64)
        size = tuple(d["image_size"])
    else:
        canon, size = builtin_canonical()
        print("使用内置示意脸（仅用于跑通流程）")

    verts = build_vertices(canon, size)
    tris, dropped = build_topology(verts, size)
    cov, signs = check_coverage(verts, tris, size)
    print(f"顶点 {len(verts)}，三角形 {len(tris)}，丢弃 {dropped}，面积覆盖比 {cov:.3f}，朝向符号集合 {signs}")

    with open(args.out, "wb") as f:
        f.write(struct.pack("<II", len(verts), len(tris)))
        f.write(tris.astype("<u2").tobytes())
    print("已写出", args.out, "（头部：uint32 顶点数, uint32 三角数；随后为 uint16 索引 x 3N）")

    if args.preview:
        preview(verts, tris, size, args.preview)


if __name__ == "__main__":
    main()
