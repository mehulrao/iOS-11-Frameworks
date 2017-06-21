precision lowp float;

varying vec4 coordinateAndMainEndCenter;
varying mediump vec4 percentages; // x, y, z, w = main, percentageScaleFactor, mod(main, 1.0), pixelEndCapDotProduct
varying vec4 color1;
varying vec4 color2;
varying vec4 sizes; // x, y, z, w = size, innerRadius, halfRingWidth, midRadius
varying vec2 percentageOverflowOffsets;
varying float coordinatePercent;

uniform float emptyRingAlpha;

// The coordinate percent is interpolated across the vertices in order to avoid the expensive atan() calculation per fragment
// The downside is that there's some error in doing so, so instead of getting a smooth line across, we get a concave shape
// While the end cap does its best to cover it up, we were still seeeing a tiny bit of error at the outer edges
// To fix those off pixels at the edges, be slightly more generous with the coordinate percent comparison
const float coordinatePercentGeometryErrorFactor = 0.004;

void main() {
    vec2 coordinate = coordinateAndMainEndCenter.xy;
    float centerDistance = length(coordinate);
    float size = sizes.x;
    float innerRadius = sizes.y;
    float halfRingWidth = sizes.z; // Precomputed as (1.0 - innerRadius) * 0.25
    float midRadius = sizes.w;     // Precomputed as (1.0 + innerRadius) * 0.25
    
    float ringDistance = abs(centerDistance - midRadius) - halfRingWidth;
    
    // Clip out the inside and outside edges, anti-aliasing over 1 pixel based on the distance from the middle of the ring's arc
    float alpha = clamp(1.0 - ringDistance * size, 0.0, 1.0);
    
    // How far to stretch this color, mixing between start and end
    float mainPercentage = percentages.x;
    float colorPercentageScaleFactor = percentages.y;
    
    float dimmingFactor = clamp(emptyRingAlpha, 0.0, 1.0);
    
    // Clip out the start cap and unfilled portion of the ring track
    if (coordinatePercent - coordinatePercentGeometryErrorFactor > mainPercentage && mainPercentage < 1.0) {
        // This could be separated into its own start cap shader
        float startCapDistanceInPixels = (length(coordinate - vec2(0.0, halfRingWidth - 0.5)) - halfRingWidth) * size;
        
        alpha *= clamp(1.0 - startCapDistanceInPixels, dimmingFactor, 1.0);
        // Use the start color in both the start cap and the unfilled ring background
        colorPercentageScaleFactor = 0.0;
    }
    
    // Determine what percentage through the ring this pixel is
    // If the ring percentage goes over 1.0, continue to have it "draw over" the existing ring
    //    if (coordinatePercent < percentages.z) {
    //        pixelAngleAsPercent = coordinatePercent + percentageOverflowOffsets.x;
    //    } else {
    //        pixelAngleAsPercent = coordinatePercent + percentageOverflowOffsets.y;
    //    }
    
    // This step + mix is a branch-free version of the above
    float isBeforeEndCap = step(percentages.z - coordinatePercent, 0.0);
    float pixelAngleAsPercent = coordinatePercent + mix(percentageOverflowOffsets.x, percentageOverflowOffsets.y, isBeforeEndCap);
    
    vec4 color = mix(color1, color2, pixelAngleAsPercent * colorPercentageScaleFactor);
    
    color.a = alpha;
    
    gl_FragColor = color;
}
