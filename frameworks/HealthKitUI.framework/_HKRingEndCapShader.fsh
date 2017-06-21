precision lowp float;

uniform float endCapShadowDistance;

varying vec4 coordinateAndMainEndCenter;
varying mediump vec4 percentages; // x, y, z, w = main, percentageScaleFactor, mod(main, 1.0), pixelEndCapDotProduct
varying vec4 color1;
varying vec4 color2;
varying vec4 sizes; // x, y, z, w = size, innerRadius, halfRingWidth, midRadius
varying vec2 percentageOverflowOffsets;
varying float coordinatePercent;

const float shadowOpacity = 0.7;

void main() {
    vec2 coordinate = coordinateAndMainEndCenter.xy;
    vec2 mainEndCenter = coordinateAndMainEndCenter.zw;
    float centerDistance = length(coordinate);
    float size = sizes.x;
    float innerRadius = sizes.y;
    float halfRingWidth = sizes.z; // Precomputed as (1.0 - innerRadius) * 0.25
    float midRadius = sizes.w;     // Precomputed as (1.0 + innerRadius) * 0.25
    
    // Unused in this end cap shader, so just suppress the warnings
    percentageOverflowOffsets;
    coordinatePercent;
    
    // Clip out the inside and outside edges, anti-aliasing over 1 pixel based on the distance from the middle of the ring's arc
    float ringDistance = abs(centerDistance - midRadius) - halfRingWidth;
    float alpha = clamp(1.0 - ringDistance * size, 0.0, 1.0);
    
    float distanceToEndCapEdge = length(coordinate - mainEndCenter) - halfRingWidth;
    float distanceToEndCapEdgeInPixels = distanceToEndCapEdge * size;
    
    // End cap shadow color
    // Going from inside the end cap to outside it, we want to go smoothly from the main color to black over 1 pixel
    float colorToShadowColorMixer = clamp(1.0 - distanceToEndCapEdgeInPixels, 0.0, 1.0);
    
    // End cap shadow alpha
    // When shadowAmount is 1.0, the shadow is at its darkest; it fades out to 0.0
    mediump float shadowAmount = clamp(1.0 - distanceToEndCapEdgeInPixels / endCapShadowDistance, 0.0, 1.0);
    mediump float curvedShadowAmount = shadowAmount * shadowAmount * shadowAmount;
    
    // Only draw the shadow on the clockwise-facing half of the circle
    float pixelEndCapDotProduct = percentages.w;
//    if (pixelEndCapDotProduct < 0.0 && distanceToEndCapEdge >= 0.0) {
//        curvedShadowAmount = 0.0;
//    }
    // A more optimized version of the above
    curvedShadowAmount *= step(-pixelEndCapDotProduct + distanceToEndCapEdge, 0.0);
    
    alpha *= curvedShadowAmount;
    
    // Reduce the shadow to the desired opacity without affecting the end cap's opacity
    alpha = mix(alpha, alpha * shadowOpacity, 1.0 - colorToShadowColorMixer);
    
    // Determine the end cap's color
    // From 0-50%, end cap color goes from 0-100% of color spectrum. After that, it stays at 100%
    float colorMixer = min(percentages.x * 2.0, 1.0);
    vec4 color = mix(color1, color2, colorMixer);
    
    // Now multiply in the shadow, taking it from the normal color down to rgb(0, 0, 0)
    color.rgb *= colorToShadowColorMixer;
    
    color.a = alpha;
    
    gl_FragColor = color;
}
