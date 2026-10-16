// IrisScale.metal
// 眼瞳(黑眼珠/虹膜)放大：源空间局部重映射 Pass，位于磨皮/调色之后、网格 Warp 之前。
// 设计骨架：映射函数已用 numpy 验证（单调、C0 连续、窗口外恒等、保护区逐位不变），
// 但该 Metal 代码本身未在真机编译联调。
#include <metal_stdlib>
using namespace metal;

struct IrisParams {
    float2 center;      // 虹膜中心(像素)，来自 468 / 473，已滤波
    float  r0;          // 虹膜半径(像素)，稳健估计 + 时域平滑
    float  scale;       // s >= 1，已按开口/眼角空间限幅
    float  margin;      // m，保护带宽度(以 r0 为单位)，建议 0.6~1.0
    float  strength;    // 0...1，含眨眼/姿态/丢脸门控，0 时直接恒等
};

// 输出半径 -> 源半径（反向映射）
inline float irisInverseRadius(float r, float r0, float s, float m)
{
    float x1 = s * r0;                 // 放大后的虹膜边界
    float R  = (s + m) * r0;           // 影响窗口外边界
    if (r >= R)  return r;             // 窗口外：恒等
    if (r <= x1) return r / s;         // 虹膜内：均匀放大（保持纹理与瞳孔形状）
    // 巩膜保护带：Hermite，起点 (x1, r0) 斜率=割线，终点 (R, R) 斜率=1，保证与窗口外 C1 衔接
    float h  = R - x1;
    float D  = (R - r0) / h;           // 割线斜率 >= 1（巩膜被挤压）
    float t  = (r - x1) / h;
    float t2 = t * t, t3 = t2 * t;
    float h00 = 2*t3 - 3*t2 + 1, h10 = t3 - 2*t2 + t;
    float h01 = -2*t3 + 3*t2,    h11 = t3 - t2;
    return h00 * r0 + h10 * h * D + h01 * R + h11 * h * 1.0;
}

kernel void irisScale(texture2d<half, access::sample> src      [[texture(0)]],
                      texture2d<half, access::sample> aperture [[texture(1)]], // R8：眼睑开口，已腐蚀+SDF羽化
                      texture2d<half, access::write>  dst      [[texture(2)]],
                      constant IrisParams &P                   [[buffer(0)]],
                      uint2 gid [[thread_position_in_grid]])
{
    if (gid.x >= dst.get_width() || gid.y >= dst.get_height()) return;
    constexpr sampler smp(filter::linear, address::clamp_to_edge, coord::pixel);

    float2 p = float2(gid) + 0.5;
    half4 orig = src.sample(smp, p);

    float2 d = p - P.center;
    float  r = length(d);
    float  R = (P.scale + P.margin) * P.r0;

    // 早退：保护区(窗口外 / 强度为 0) 直接拷贝，保证逐位不变
    if (P.strength <= 0.0 || r >= R) { dst.write(orig, gid); return; }

    float w = float(aperture.sample(smp, p).r);          // 开口权重：眼睑/睫毛/皮肤处为 0
    if (w <= 0.0) { dst.write(orig, gid); return; }

    float rs = irisInverseRadius(r, P.r0, P.scale, P.margin);
    float2 sp = (r > 1e-4) ? P.center + d * (rs / r) : P.center;

    // 射线夹取：源位置落在开口外(被眼睑遮住的虹膜上部)时，向中心收缩，避免把眼睑/睫毛采进虹膜
    for (int i = 0; i < 4; ++i) {
        if (float(aperture.sample(smp, sp).r) > 0.5) break;
        sp = P.center + (sp - P.center) * 0.75;
    }

    half4 remapped = src.sample(smp, sp);
    dst.write(mix(orig, remapped, half(w * P.strength)), gid);
}
