#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float contrast;
uniform sampler2D uTexture;

out vec4 fragColor;

mat4 contrastMatrix(float contrast) {
    float t = (1.0 - contrast) / 2.0;

    return mat4(contrast, 0, 0, 0,
        0, contrast, 0, 0,
        0, 0, contrast, 0,
        t, t, t, 1);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    fragColor = texture(uTexture, uv);
    fragColor = contrastMatrix(contrast) * fragColor;
}
