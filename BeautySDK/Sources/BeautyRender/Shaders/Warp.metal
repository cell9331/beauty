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

// Geometry and composed-retouch ownership remains in later adapters. These
// bounded kernels establish their pass contracts without changing pixels.
kernel void beauty_geometry_pass(
    texture2d<float, access::read> input [[texture(0)]],
    texture2d<float, access::write> output [[texture(1)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x < output.get_width() && gid.y < output.get_height()) {
        output.write(input.read(gid), gid);
    }
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
