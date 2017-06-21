attribute vec4 inPosition;
attribute mediump float inSize;
attribute vec2 inTextureOffset;
attribute vec4 inColor;

uniform mat4 transform;

varying vec2 textureOffset;
varying vec4 color;

void main() {
    gl_Position = transform * inPosition;
    gl_PointSize = inSize;
    
    textureOffset = inTextureOffset;
    color = inColor;
}
