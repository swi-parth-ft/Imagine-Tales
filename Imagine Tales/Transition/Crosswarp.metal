//
// Crosswarp.metal
// Imagine Tales
//
// Created by Parth Antala on 8/31/24.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[stitchable]] half4 crosswarpLTRTransition(float2 position,
                                            SwiftUI::Layer layer,
                                            float2 size,
                                            float amount) {
    // Calculate our coordinate in UV space, 0 to 1.
    half2 uv = half2(position / size);

    // Calculate how far this pixel is through the
    half progress = amount * 2.0h + uv.x - 1.0h;

    // Move smoothly between 0 and 1 with easing, making
    half x = smoothstep(0.0h, 1.0h, progress);

    half2 newPosition = mix(uv, half2(0.5h), x);

    // Now blend the pixel at that location with the clear
    return mix(layer.sample(float2(newPosition) * size), 0.0h, x);
}
















/// A transition that stretches and fades pixels starting from the left edge.
/// - Parameter position: The user-space coordinate of the current pixel.
/// - Parameter layer: The SwiftUI layer we're reading from.
/// - Parameter size: The size of the whole image, in user-space.
/// - Parameter amount: The progress of the transition, from 0 to 1.
/// - Returns: The new pixel color.
[[stitchable]] half4 crosswarpRTLTransition(float2 position, SwiftUI::Layer layer, float2 size, float amount) {
    // Calculate our coordinate in UV space, 0 to 1.
    half2 uv = half2(position / size);

    // Calculate how far this pixel is through the
    // transition. When amount is 0, the left edge will
    // be 0 and the right edge will be -1. When amount is
    // 0.5, the left edge will be 1, and the right edge
    // will be 0. When amount is 1, the left edge will be
    // 2, and the right edge 1.
    half progress = amount * 2.0h + (1.0h - uv.x) - 1.0h;

    // Move smoothly between 0 and 1 with easing, making
    // sure to clamp to 0 and 1 at the same time.
    half x = smoothstep(0.0h, 1.0h, progress);

    // We want to read pixels increasingly close to the
    // original position as the transition progresses.
    // So, we move the UV origin towards the center,
    // scale the value upwards by 1 minus our smoothed
    // progress, then move the UV back to where it was.
    half2 newPosition = (uv - 0.5h) * (1.0h - x) + 0.5h;

    // Now blend the pixel at that location with the clear
    // color based on x, so we fade out over time.
    return mix(layer.sample(float2(newPosition) * size), 0.0h, x);
}
