#ifdef GL_ES
precision highp float;
#endif

attribute vec3 vertexPosition;
attribute vec2 vertexTCoord;
attribute vec4 vertexColor;
attribute vec3 vertexNormal;

uniform mat4 projectionMatrix;
uniform mat4 modelViewMatrix;

uniform mat4 worldViewProjection;
uniform mat4 world;
uniform mat4 worldInverseTranspose;
uniform mat4 lightViewProjection;

varying vec4 vposition;
varying vec3 vnormal;
varying vec4 vprojTextureCoords;
varying vec4 vworldPosition;

/**
 * The vertex shader simply transforms the input vertices to screen space.
 */
void main() {
  vworldPosition = world * vertexPosition;
  vposition = worldViewProjection * vertexPosition;
  vprojTextureCoords = lightViewProjection * world * vertexPosition;
  gl_Position = vposition;
}