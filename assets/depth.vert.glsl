attribute vec3 vertexPosition;
attribute vec2 vertexTCoord;
attribute vec4 vertexColor;
attribute vec3 vertexNormal;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

varying vec4 vPos;

void main(void) {
    vec4 pos = vec4(vertexPosition, 1.0);
    vec4 mpos = modelViewMatrix * pos;
    vPos = projectionMatrix * mpos;
    gl_Position = vPos;
}