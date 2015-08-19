#ifdef GL_ES
precision highp float;
#endif

  uniform vec4 ambient;
  uniform vec4 diffuse;
  uniform vec4 specular;
  uniform float shininess;

  varying vec4 vposition;
  varying vec4 vworldPosition;
  varying vec3 vnormal;
  varying vec4 vprojTextureCoords;

  uniform sampler2D shadowMapSampler;

  uniform vec3 lightWorldPos;
  uniform mat4 viewInverse;

  vec3 lighting(vec3 position, vec3 normal, vec4 pigment, vec4 specular, float shininess) {
    vec3 l = normalize(vec3(lightWorldPos) - position);  // Toward light.
    vec3 n = normalize(normal);                          // Normal.
    vec3 v = normalize(vec3(viewInverse * vec4(0,0,0,1)) - position); // Toward eye.
    vec3 r = normalize(-reflect(v, n));

    return clamp(dot(n,l), 0.0, 1.0) * diffuse.rgb +
        0.2 * specular.rgb * pow(max(dot(l, r), 0.0), shininess);
  }

  void main() {
    vec3 outColor = ambient.rgb;
    vec4 projCoords = vprojTextureCoords;

    // Convert texture coords to [0, 1] range.
    projCoords /= projCoords.w;
    projCoords = 0.5 * projCoords + 0.5;

    float depth = projCoords.z;
    float light;

    // If the rednered point is farther from the light than the distance encoded
    // in the shadow map, we give it a light coefficient of 0.
    vec4 color = texture2D(shadowMapSampler, projCoords.xy);

    light = (color.a +
             color.b / 256.0 +
             color.g / 65536.0 +
             color.r / 16777216.0) + 0.008 > depth ? 1.0 : 0.0;

    // Make the illuninated area a round spotlight shape just for fun.
    // Comment this line out to see just the shadows.
    light *= 1.0 - smoothstep(0.45, 0.5,
        length(projCoords.xy - vec2(0.5, 0.5)));

    outColor += light * lighting(
        vec3(vworldPosition),
        vnormal,
        diffuse,
        specular,
        shininess);

    gl_FragColor = vec4(outColor, 1.0);
  }
