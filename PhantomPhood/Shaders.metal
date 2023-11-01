//
//  Shaders.metal
//  PhantomPhood
//
//  Created by Kia Abdi on 20.09.2023.
//

#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 circleLoader(
    float2 position,
    half4 color,
    float4 bounds,
    float secs
) {
    float cols = 6;
    float PI2 = 6.2831853071795864769252867665590;
    float timeScale = 0.04;

    vector_float2 uv = position/bounds.zw;

    float circle_rows = (cols * bounds.w) / bounds.z;
    float scaledTime = secs * timeScale;

    float circle = -cos((uv.x - scaledTime) * PI2 * cols) * cos((uv.y + scaledTime) * PI2 * circle_rows);
    float stepCircle = step(circle, -sin(secs + uv.x - uv.y));

    // Blue Colors
    vector_float4 background = vector_float4(0.1, 0.1, 0.1, 1.0);
    vector_float4 circles = vector_float4(0.2, 0.2, 0.2, 1.0);

    return half4(mix(background, circles, stepCircle));
}
