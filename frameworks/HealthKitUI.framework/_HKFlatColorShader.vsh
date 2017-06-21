precision lowp float;

uniform mat4 transform;
attribute vec4 inPosition;

void main() {
    gl_Position = transform * inPosition;
}
