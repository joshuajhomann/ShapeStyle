//
//  shaders.metal
//  Fill
//
//  Created by Joshua Homann on 8/12/23.
//


#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]]
half4 mix(float2 position, half4 source, half4 destination, float time, float frequency)
{
    float angle = (sin(fract(time * frequency) * 2 * 3.14159) + 1) / 2;
    return mix(source, destination, angle);
}

[[ stitchable ]]
half4 colorize(float2 position, half4 currentColor, half4 targetColor)
{
    half gray = 0.299 * currentColor.r + 0.587 * currentColor.g + 0.114 * currentColor.g;
    half4 colorized = gray * targetColor;
    colorized.a = currentColor.a;
    return gray > 0.999 ? currentColor : colorized;
}

[[ stitchable ]]
half4 bilinear(float2 position, half4 currentColor, float2 size)
{
    return half4(position.y / size.y, position.x / size.x, 0.0, 1.0);
}

auto noise22(float2 coordinate) {
    return fract(sin(dot(coordinate.xy,float2(314,159)))*62812);
}

auto noise21(float2 coordinate) {
    float2 noise = fract(sin(dot(coordinate.xy,float2(314,159)))*62812);
    return fract(noise.x + noise.y);
}

[[ stitchable ]]
half4 vornoi(float2 position, half4 currentColor, float2 size, float time)
{
    auto const aspect = size.x / size.y;
    auto const uv = float2(position.x / size.x * aspect, position.y / size.y);
    auto const count = 10;
    auto const qr = uv * count;
    auto const gridFraction = fract(qr) - 0.5;
    auto const gridCoordinate = floor(qr);
    auto minimumDistance = 1e6;
    float2 closestCell = 0;
    for (auto x : { -1.0, 0.0, 1.0 })
      {
        for (auto y : { -1.0, 0.0, 1.0 })
          {
            auto offset = float2(x,y);
            auto cell = gridCoordinate + offset;
            auto animatedCoordinate = noise22(cell);
            auto animatedOffsetCoordinate = sin(animatedCoordinate * time )/2.0 + offset;
            auto distance = length(gridFraction - animatedOffsetCoordinate);
            if (distance < minimumDistance) {
                minimumDistance = distance;
                closestCell = cell;
            }
          }
      }
    auto color = half4(minimumDistance);
    color.rb = half2(closestCell/count);
    return half4(color.r, color.g, color.b, currentColor.a);
}

[[ stitchable ]]
half4 vornoiManhattan(float2 position, half4 currentColor, float2 size, float time)
{
    auto const aspect = size.x / size.y;
    auto const count = 10;
    auto const uv = float2(position.x / size.x * aspect, position.y / size.y) * count;
    auto const gridFraction = fract(uv) - 0.5;
    auto const gridCoordinate = floor(uv);
    auto minimumDistance = 1e6;
    float2 closestCell = 0;
    for (auto x : { -1.0, 0.0, 1.0 })
      {
        for (auto y : { -1.0, 0.0, 1.0 })
          {
            auto offset = float2(x,y);
            auto cell = gridCoordinate + offset;
            auto animatedCoordinate = noise22(cell);
            auto animatedOffsetCoordinate = sin(animatedCoordinate * time )/2.0 + offset;
            auto manhattan = gridFraction - animatedOffsetCoordinate;
            auto distance = abs(manhattan.x) + abs(manhattan.y);
            if (distance < minimumDistance) {
                minimumDistance = distance;
                closestCell = cell;
            }
          }
      }
    auto color = half4(minimumDistance);
    color.b = half(closestCell.x/count);
    return half4(color.r, color.g, color.b, currentColor.a);
}

[[ stitchable ]]
half4 truchetQuadLine(float2 position, half4 currentColor, float2 size, float time)
{
    auto const aspect = half(size.x / size.y);
    auto const count = 10;
    auto const uv = float2(position.x / size.x * aspect, position.y / size.y) * count + time;
    auto gridFraction = fract(uv) - 0.5;
    auto const gridCoordinate = floor(uv);
    auto random = noise21(gridCoordinate);
    if (random < 0.5) {
        gridFraction.x *= -1.0;
    }
    auto lineWidth = 0.25;
    auto distanceFromCenterGridOrigin = abs(abs(gridFraction.x + gridFraction.y) - 0.5);
    auto line = smoothstep(0.02, -0.02, distanceFromCenterGridOrigin - lineWidth);
    return half4(half(line), half(line), half(line), currentColor.a);
}

[[ stitchable ]]
half4 truchetQuadCircle(float2 position, half4 currentColor, float2 size, float time)
{
    auto const aspect = half(size.x / size.y);
    auto const count = 10;
    auto const uv = float2(position.x / size.x * aspect, position.y / size.y) * count - time;
    auto gridFraction = fract(uv) - 0.5;
    auto const gridCoordinate = floor(uv);
    auto random = noise21(gridCoordinate);
    if (random < 0.5) {
        gridFraction.x *= -1.0;
    }
    auto width = 0.1;
    auto distance = length(gridFraction - 0.5 * (sign(gridFraction.x + gridFraction.y + 1e-3))) - 0.5;
    auto line = smoothstep(0.02, -0.02, abs(distance) - width);
    auto color = half4(0);
    color += half(line);
    return half4(color.r, color.g, color.b, currentColor.a);
}

[[ stitchable ]]
half4 channelOffset(float2 position, SwiftUI::Layer layer, float2 redOffset, float2 greenOffset, float2 blueOffset) {
    return half4(
                 layer.sample(position + redOffset).r,
                 layer.sample(position + greenOffset).g,
                 layer.sample(position + blueOffset).b,
                 layer.sample(position).a
                 );
}

[[ stitchable ]] float2 ripple(float2 position, float2 size, float2 frequency, float amplitude, float time) {
    auto pixelFrequency = frequency * size;
    auto samplePosition = pixelFrequency * position + time;
    return position + amplitude * float2(cos(samplePosition.x), sin(samplePosition.y));
}


