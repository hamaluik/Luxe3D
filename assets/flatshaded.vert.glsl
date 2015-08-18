attribute vec3 vertexPosition;
attribute vec2 vertexTCoord;
attribute vec4 vertexColor;
attribute vec3 vertexNormal;

varying vec3 viewPos;
varying vec4 vertColour;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

void main(void) {
    vec4 pos = vec4(vertexPosition, 1.0);
    vec4 mpos = modelViewMatrix * pos;
    gl_Position = projectionMatrix * mpos;
    
    viewPos = -mpos.xyz;
    vertColour = vertexColor;
}