// MeshWarp.metal
// 设计骨架：未在真机联调。
// 思路：顶点位置 = 目标点(NDC)，UV = 源点(归一化纹理坐标，左上原点)。
// 光栅化后每个输出像素的 UV 由硬件插值得到 → 等价于 inverse warp，无空洞。
#include <metal_stdlib>
using namespace metal;

struct WarpVertexOut {
    float4 position [[position]];
    float2 uv;
};

// dstNDC：目标位置，已转换到 NDC([-1,1]，y 向上)
// srcUV ：源位置，归一化纹理坐标(左上原点，[0,1])
vertex WarpVertexOut warpVertex(uint vid [[vertex_id]],
                                const device float2 *dstNDC [[buffer(0)]],
                                const device float2 *srcUV  [[buffer(1)]])
{
    WarpVertexOut out;
    out.position = float4(dstNDC[vid], 0.0, 1.0);
    out.uv = srcUV[vid];
    return out;
}

fragment half4 warpFragment(WarpVertexOut in [[stage_in]],
                            texture2d<half> source [[texture(0)]])
{
    constexpr sampler s(filter::linear, address::clamp_to_edge, coord::normalized);
    return source.sample(s, in.uv);
}

// ---------------------------------------------------------------------------
// 可选：带"人像保护"的版本。
// protect ∈ [0,1]：1 = 完全采用 warp 结果；0 = 回退到原图（用于人像边界外背景保护）。
// 注意：这是对 warp 后输出与原图的混合，会产生轻微重影，只在必要时使用；
// 首选方案仍是外环衰减 + 对位移本身乘权重（在 CPU 端对顶点位移做）。
// ---------------------------------------------------------------------------
fragment half4 warpFragmentProtected(WarpVertexOut in [[stage_in]],
                                     texture2d<half> source  [[texture(0)]],
                                     texture2d<half> protect [[texture(1)]],
                                     constant float2 &viewport [[buffer(0)]])  // 输出尺寸(像素)
{
    constexpr sampler s(filter::linear, address::clamp_to_edge, coord::normalized);
    float2 pixelUV = in.position.xy / viewport;               // 当前输出像素位置(归一化，未 warp)
    half4 warped   = source.sample(s, in.uv);
    half4 original = source.sample(s, pixelUV);
    half  w        = protect.sample(s, pixelUV).r;
    return mix(original, warped, w);
}

// ---------------------------------------------------------------------------
// 参考：径向局部缩放（正向形式，用于 CPU 端对顶点求目标位置的同一公式）。
// v：顶点源位置(像素)，C：中心(像素)，R：影响半径(像素)，a：强度(<1.25，建议<=0.5)
// 返回目标位置(像素)。距离在像素空间计算，避免宽高比导致椭圆。
// ---------------------------------------------------------------------------
inline float2 radialScaleForward(float2 v, float2 C, float R, float a)
{
    float2 d = v - C;
    float r = length(d);
    if (r >= R) return v;
    float t = r / R;
    float g = 1.0 + a * pow(1.0 - t * t, 2.0);
    return C + d * g;
}

// ---------------------------------------------------------------------------
// 磨皮合成示意：output = low + alpha * (orig - low)，再用皮肤 mask 混合回原图
// ---------------------------------------------------------------------------
kernel void smoothCompose(texture2d<half, access::read>  original [[texture(0)]],
                          texture2d<half, access::read>  low      [[texture(1)]],  // 保边平滑结果(已上采样)
                          texture2d<half, access::read>  skinMask [[texture(2)]],
                          texture2d<half, access::write> output   [[texture(3)]],
                          constant float &texKeep [[buffer(0)]],   // alpha：纹理保留比例 0.3~0.7
                          constant float &amount  [[buffer(1)]],   // 磨皮强度 0~1
                          uint2 gid [[thread_position_in_grid]])
{
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) return;
    half4 o = original.read(gid);
    half4 l = low.read(gid);
    half  m = skinMask.read(gid).r * half(amount);
    half4 smoothed = l + half(texKeep) * (o - l);
    output.write(mix(o, smoothed, m), gid);
}
