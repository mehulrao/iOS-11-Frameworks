precision highp float;

uniform sampler2D sampler;
uniform ivec2 iconsPerDimension;

varying vec2 textureOffset;
varying vec4 color;

void main() {
    vec2 textureCoordinate = (gl_PointCoord / vec2(iconsPerDimension)) + textureOffset;
    mediump float texSample = texture2D(sampler, textureCoordinate).a;
    
    gl_FragColor = vec4(color.rgb, texSample * color.a);
}
