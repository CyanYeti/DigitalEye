#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float steps;
uniform sampler2D uTexture;

out vec4 fragColor;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    fragColor = texture(uTexture, uv);

    vec3 greyscaledHSV = rgb2hsv(fragColor.rgb);

    float lower = floor(greyscaledHSV.b * steps) / steps;
    float lowerDiff = abs(greyscaledHSV.b - lower);

    float upper = ceil(greyscaledHSV.b * steps) / steps;
    float upperDiff = abs(greyscaledHSV.b - upper);

    float level = lowerDiff <= upperDiff ? lower : upper;
    float adjustment = level / greyscaledHSV.b;

    fragColor.rgb = fragColor.rgb * adjustment;
}
