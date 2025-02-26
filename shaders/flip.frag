#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float flip_horizontal;
uniform float flip_vertical;
uniform sampler2D uTexture;

out vec4 fragColor;

// simple flip shader
void main() {
    vec2 uv = FlutterFragCoord().xy / uSize.xy;

    if (flip_horizontal == 1.0) {
        uv.x = 1.0 - uv.x;
    }

    if (flip_vertical == 1.0) {
        uv.y = 1.0 - uv.y;
    }

    fragColor = texture(uTexture, uv);
    //fragColor = vec4(.5, .5, .5, 1.0);
}
