#!/usr/bin/env python3
"""
把 MediaPipe 478 点按"功能分组"着色画到真人照片上，并可标注索引编号，
用来核对 docs/12 与 code/Landmark478.swift 里 [经验] 点位是否落在预期位置。

依赖：pip install mediapipe opencv-python numpy
模型：下载 face_landmarker.task（Google 官方 MediaPipe 模型页提供），用 --model 指定。

用法：
  python3 draw_indices.py --model face_landmarker.task --image face.jpg --out out.png
  python3 draw_indices.py ... --labels 116,117,118,123,345,346,347,352      # 只标注指定编号
  python3 draw_indices.py ... --all-labels                                   # 标注全部编号（建议放大图片）
  python3 draw_indices.py ... --group templeR,cheekboneR                     # 只画指定经验分组
"""
import argparse

import cv2
import numpy as np
import mediapipe as mp
from mediapipe.tasks import python as mpp
from mediapipe.tasks.python import vision

# 与 code/Landmark478.swift 保持一致（right = 被摄者右 = 图像左）
GROUPS = {
    "faceOval":  ([10,338,297,332,284,251,389,356,454,323,361,288,397,365,379,378,400,377,152,148,176,149,150,136,172,58,132,93,234,127,162,21,54,103,67,109], (0,255,0)),
    "eyeR":      ([33,246,161,160,159,158,157,173,133,155,154,153,145,144,163,7], (255,200,0)),
    "eyeL":      ([263,466,388,387,386,385,384,398,362,382,381,380,374,373,390,249], (255,200,0)),
    "irisR":     ([468,469,470,471,472], (255,0,255)),
    "irisL":     ([473,474,475,476,477], (255,0,255)),
    "browR":     ([70,63,105,66,107,46,53,52,65,55], (0,200,255)),
    "browL":     ([300,293,334,296,336,276,283,282,295,285], (0,200,255)),
    "noseMid":   ([168,6,197,195,5,4,1,19,94,2], (0,128,255)),
    "noseWingR": ([220,115,48,64,98,97], (0,128,255)),
    "noseWingL": ([440,344,278,294,327,326], (0,128,255)),
    "lipsOuter": ([61,185,40,39,37,0,267,269,270,409,291,375,321,405,314,17,84,181,91,146], (60,60,255)),
    "lipsInner": ([78,191,80,81,82,13,312,311,310,415,308,324,318,402,317,14,87,178,88,95], (120,120,255)),
    # ↓ [经验] 分组：重点核对
    "cheekboneR": ([116,117,118,123], (255,255,0)),
    "cheekboneL": ([345,346,347,352], (255,255,0)),
    "templeR":    ([21,54,71,68,139], (200,100,255)),
    "templeL":    ([251,284,301,298,368], (200,100,255)),
    "jawAngleR":  ([58,172], (0,255,255)),
    "jawAngleL":  ([288,397], (0,255,255)),
    "chinMid":    ([17,18,200,199,175,152], (255,128,0)),
    "foreheadMid":([10,151,9,8,168], (128,255,128)),
    "philtrum":   ([164,2,0], (128,128,255)),
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", required=True)
    ap.add_argument("--image", required=True)
    ap.add_argument("--out", default="out.png")
    ap.add_argument("--labels", default="", help="逗号分隔的索引，标注这些编号")
    ap.add_argument("--all-labels", action="store_true")
    ap.add_argument("--group", default="", help="逗号分隔分组名；缺省画全部")
    ap.add_argument("--scale", type=float, default=1.0, help="输出放大倍数，标注全部编号时建议 2~3")
    args = ap.parse_args()

    opts = vision.FaceLandmarkerOptions(
        base_options=mpp.BaseOptions(model_asset_path=args.model),
        num_faces=1,
        output_face_blendshapes=True,
        output_facial_transformation_matrixes=True,
    )
    det = vision.FaceLandmarker.create_from_options(opts)
    mp_img = mp.Image.create_from_file(args.image)
    res = det.detect(mp_img)
    if not res.face_landmarks:
        raise SystemExit("未检测到人脸")

    img = cv2.imread(args.image)
    if args.scale != 1.0:
        img = cv2.resize(img, None, fx=args.scale, fy=args.scale, interpolation=cv2.INTER_CUBIC)
    h, w = img.shape[:2]
    lms = res.face_landmarks[0]
    pts = np.array([[l.x * w, l.y * h] for l in lms])          # 归一化 -> 像素（x、y 分别乘各自尺寸）
    print("点数:", len(pts))

    want = set(g for g in args.group.split(",") if g) or set(GROUPS)
    for name, (idx, color) in GROUPS.items():
        if name not in want:
            continue
        for i in idx:
            cv2.circle(img, tuple(pts[i].astype(int)), 2, color, -1)

    label_ids = set()
    if args.all_labels:
        label_ids = set(range(len(pts)))
    elif args.labels:
        label_ids = {int(s) for s in args.labels.split(",") if s}
    for i in label_ids:
        cv2.putText(img, str(i), tuple((pts[i] + [2, -2]).astype(int)),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.28 if args.all_labels else 0.4, (255, 255, 255), 1, cv2.LINE_AA)

    if res.facial_transformation_matrixes:
        m = np.array(res.facial_transformation_matrixes[0])
        f = m[:3, 2]
        print("朝向列向量(第3列):", f, " yaw≈%.1f° pitch≈%.1f°（符号需标定）" % (
            np.degrees(np.arctan2(f[0], f[2])), np.degrees(np.arcsin(np.clip(-f[1], -1, 1)))))
    if res.face_blendshapes:
        top = sorted(res.face_blendshapes[0], key=lambda c: -c.score)[:8]
        print("blendshape top8:", [(c.category_name, round(c.score, 2)) for c in top])

    cv2.imwrite(args.out, img)
    print("已写出", args.out)


if __name__ == "__main__":
    main()
