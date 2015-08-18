#extension GL_OES_standard_derivatives : enable
precision highp float;
precision highp int;

varying vec3 viewPos;
varying vec4 vertColour;

uniform vec3 lightDirection;
uniform vec3 lightColour;
uniform vec3 ambientColour;

vec3 normals_1_0(vec3 pos) {
    vec3 fdx = dFdx(pos);
    vec3 fdy = dFdy(pos);
    return normalize(cross(fdx, fdy));
}

void main() {
    vec3 normal = normals_1_0(viewPos);
    vec3 ambientLight = ambientColour * vertColour.rgb;
    
    float cosTheta = clamp(dot(normal, lightDirection), 0.0, 1.0);
    gl_FragColor.rgb = ambientLight + lightColour * vertColour.rgb * cosTheta;
    gl_FragColor.a = vertColour.a;
}