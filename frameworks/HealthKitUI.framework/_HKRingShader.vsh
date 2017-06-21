precision lowp float;

attribute vec4 inPosition;
attribute vec2 inCoordinate;
attribute vec4 inRingColor1;
attribute vec4 inRingColor2;
attribute vec4 inRingSizes; // x, y, z, w = size, innerRadius, halfRingWidth, midRadius
attribute vec2 inRingPercentages; // x, y = mainPercentage, percentageScaleFactor
attribute vec2 inTrigResults; // x, y = cos(2*M_PI*mainPercentage), sin(2*M_PI*mainPercentage)
attribute float inCoordinatePercentage;

uniform mat4 transform;

varying vec4 coordinateAndMainEndCenter; // xy, zw = coordinate, main end center
varying vec4 color1;
varying vec4 color2;
varying mediump vec4 percentages; // x, y, z, w = main, percentageScaleFactor, mod(main, 1.0), pixelEndCapDotProduct
varying mediump vec4 sizes; // x, y, z, w = size, innerRadius, halfRingWidth, midRadius
varying vec2 percentageOverflowOffsets; // x, y = offset for angle of pixel < mod(main %)
varying float coordinatePercent;

void main() {
    gl_Position = transform * inPosition;
    
    coordinatePercent = inCoordinatePercentage;
    color1 = inRingColor1;
    color2 = inRingColor2;
    sizes = inRingSizes;
    
    percentages.xy = inRingPercentages.xy;
    mediump float flooredPercent = floor(percentages.x);
    percentages.z = percentages.x - flooredPercent; // mod(percentages.x, 1.0);
    percentageOverflowOffsets.x = flooredPercent;
    percentageOverflowOffsets.y = max(0.0, flooredPercent - 1.0);
    
    coordinateAndMainEndCenter.xy = inCoordinate - vec2(0.5);
    
    float midRadius = inRingSizes.w;
    coordinateAndMainEndCenter.zw = vec2(inTrigResults.y, -inTrigResults.x) * midRadius;
    
    float pixelEndCapDotProduct = dot(coordinateAndMainEndCenter.xy - coordinateAndMainEndCenter.zw, inTrigResults);
    percentages.w = pixelEndCapDotProduct;
}
