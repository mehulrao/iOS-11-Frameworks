// This fragment shader is designed to work with ring.vsh
// As such, there are lots of varyings in here that we won't
// actually use, but they need to be here just to compile
precision lowp float;

varying vec4 coordinateAndMainEndCenter;
varying mediump vec4 percentages; // x, y, z = main, percentageScaleFactor, mod(main, 1.0)
varying vec4 color1;
varying vec4 color2;
varying vec4 sizes; // x, y, z, w = size, innerRadius, halfRingWidth, midRadius
varying vec2 percentageOverflowOffsets;
varying float coordinatePercent;

uniform float emptyRingAlpha;

void main() {
    vec2 coordinate = coordinateAndMainEndCenter.xy;
    float centerDistance = length(coordinate);
    float size = sizes.x;
    float halfRingWidth = sizes.z; // Precomputed as (1.0 - innerRadius) * 0.25
    float midRadius = sizes.w;     // Precomputed as (1.0 + innerRadius) * 0.25
    
    // Suppress compiler warnings about unused variables
    vec4 unused = vec4(color2.r, percentageOverflowOffsets.x, coordinatePercent, percentages.x);
    
    float ringDistance = abs(centerDistance - midRadius) - halfRingWidth;
    float alpha = clamp(1.0 - ringDistance * size, 0.0, 1.0);
    
    float dimmingFactor = clamp(emptyRingAlpha, 0.0, 1.0);
    
    float colorMultiplier;
    if (percentages.x < 0.0) {
        colorMultiplier = dimmingFactor;
    } else {
        colorMultiplier = 1.0;
    }
    
    vec4 color = color1;
    color.a = alpha * dimmingFactor;
    
    gl_FragColor = color;
}
