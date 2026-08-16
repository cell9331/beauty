#include <metal_stdlib>
using namespace metal;

struct BeautyMetalColorUniform {
    float saturationDelta;
    float contrastScale;
    float lightLift;
    float redBias;
    float greenBias;
    float blueBias;
    float highlightLift;
    float shadowLift;
    float smoothing;
    float lipCenterX;
    float lipCenterY;
    float lipRadiusX;
    float lipRadiusY;
    float lipStrength;
    uint lipEnabled;
    uint reserved;
};

kernel void beauty_warp_placeholder(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) {
        return;
    }
    output.write(input.read(gid), gid);
}

kernel void beauty_color_pass(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    constant BeautyMetalColorUniform& parameters [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) {
        return;
    }
    float4 source = input.read(gid);
    float3 rgb = source.rgb;
    float luminance = dot(rgb, float3(0.299, 0.587, 0.114));
    float saturationScale = max(0.0f, 1.0f + parameters.saturationDelta);
    rgb = luminance + (rgb - luminance) * saturationScale;
    rgb = (rgb - 0.5f) * parameters.contrastScale + 0.5f;
    rgb += parameters.lightLift;
    rgb.r += parameters.redBias;
    rgb.g += parameters.greenBias;
    rgb.b += parameters.blueBias;
    rgb += (luminance > 0.5f ? parameters.highlightLift : parameters.shadowLift);

    float smoothing = clamp(parameters.smoothing, 0.0f, 1.0f);
    if (smoothing > 0.0f) {
        float smoothedLuminance = dot(rgb, float3(0.299, 0.587, 0.114));
        rgb = mix(rgb, float3(smoothedLuminance), smoothing);
    }

    if (parameters.lipEnabled != 0 && parameters.lipRadiusX > 0.0f && parameters.lipRadiusY > 0.0f) {
        float2 point = (float2(gid) + 0.5f) / float2(output.get_width(), output.get_height());
        float2 delta = (point - float2(parameters.lipCenterX, parameters.lipCenterY)) /
            float2(parameters.lipRadiusX, parameters.lipRadiusY);
        float mask = max(0.0f, 1.0f - dot(delta, delta));
        float blend = min(parameters.lipStrength, 0.5f) * mask;
        float lipLuminance = dot(rgb, float3(0.299, 0.587, 0.114));
        float3 enhanced = float3(
            min(1.0f, lipLuminance * 0.45f + rgb.r * 0.55f + 0.20f),
            max(0.0f, rgb.g * 0.94f),
            max(0.0f, rgb.b * 0.90f)
        );
        rgb = mix(rgb, enhanced, blend);
    }
    output.write(float4(clamp(rgb, 0.0f, 1.0f), source.a), gid);
}

struct BeautyMetalWarpPoint {
    float sourceX;
    float sourceY;
    float targetX;
    float targetY;
    float radius;
    float strength;
    float falloff;
};

inline float2 beauty_clamp_point(float2 point) {
    return clamp(point, float2(0.0f), float2(1.0f));
}

inline float beauty_falloff_weight(float value, float falloff) {
    float clamped = clamp(value, 0.0f, 1.0f);
    float rounded = max(1.0f, round(falloff));
    if (rounded <= 1.0f) {
        return clamped;
    }
    if (rounded <= 2.0f) {
        return clamped * clamped;
    }
    return clamped * clamped * clamped;
}

inline float4 beauty_bilinear_sample(
    texture2d<float, access::read> input,
    float2 normalized
) {
    uint width = input.get_width();
    uint height = input.get_height();
    float sampleX = normalized.x * float(max(uint(1), width - 1));
    float sampleY = normalized.y * float(max(uint(1), height - 1));
    uint x0 = min(uint(max(0.0f, floor(sampleX))), width - 1);
    uint y0 = min(uint(max(0.0f, floor(sampleY))), height - 1);
    uint x1 = min(x0 + 1, width - 1);
    uint y1 = min(y0 + 1, height - 1);
    float xWeight = sampleX - float(x0);
    float yWeight = sampleY - float(y0);
    float4 topLeft = input.read(uint2(x0, y0));
    float4 topRight = input.read(uint2(x1, y0));
    float4 bottomLeft = input.read(uint2(x0, y1));
    float4 bottomRight = input.read(uint2(x1, y1));
    float4 top = mix(topLeft, topRight, xWeight);
    float4 bottom = mix(bottomLeft, bottomRight, xWeight);
    return mix(top, bottom, yWeight);
}

kernel void beauty_geometry_pass(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    constant BeautyMetalWarpPoint* points [[buffer(0)]],
    constant uint& pointCount [[buffer(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= output.get_width() || gid.y >= output.get_height()) {
        return;
    }

    float2 destination = (float2(gid) + 0.5f) /
        float2(output.get_width(), output.get_height());
    float2 sample = destination;
    bool hasInfluence = false;
    for (uint index = 0; index < pointCount; ++index) {
        BeautyMetalWarpPoint point = points[index];
        float2 delta = destination - float2(point.targetX, point.targetY);
        float radius = max(point.radius, 0.000001f);
        float distance = length(delta);
        if (distance >= radius) {
            continue;
        }
        float normalizedDistance = clamp(1.0f - distance / radius, 0.0f, 1.0f);
        float weight = beauty_falloff_weight(normalizedDistance, point.falloff);
        // Inverse displacement is the established CPU sampling direction.
        sample -= (float2(point.targetX, point.targetY) -
            float2(point.sourceX, point.sourceY)) * weight;
        hasInfluence = true;
    }

    float4 value = hasInfluence
        ? beauty_bilinear_sample(input, beauty_clamp_point(sample))
        : input.read(gid);
    output.write(float4(value.rgb, input.read(gid).a), gid);
}

kernel void beauty_local_retouch_pass(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x < output.get_width() && gid.y < output.get_height()) {
        output.write(input.read(gid), gid);
    }
}
