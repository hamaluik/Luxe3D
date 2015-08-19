precision highp float;
precision highp int;

varying vec4 vPos;

void main() {
	vec4 color;
	vec3 q = vPos.xyz / vPos.w;

	float depth = 0.5*(q.z + 1.0);
	color.r = fract(16777216.0 * depth);
	color.g = fract(65536.0 * depth);
	color.b = fract(256.0 * depth);
	color.a = depth;

	gl_FragColor = color;
}