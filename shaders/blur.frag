#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec2 direction;
uniform float strength;
uniform sampler2D uTexture;

out vec4 fragColor;

// Using gaussian blur from https://github.com/Experience-Monks/glsl-fast-gaussian-blur
void main() {
    vec2 uv = FlutterFragCoord().xy / uSize.xy;

    vec4 baseColor = texture(uTexture, uv);

    //vec4 color = vec4(0.0);
    //vec2 off1 = vec2(1.3846153846) * direction;
    //vec2 off2 = vec2(3.2307692308) * direction;
    //color += texture(uTexture, uv) * 0.2270270270;
    //color += texture(uTexture, uv + (off1 / uSize)) * 0.3162162162;
    //color += texture(uTexture, uv - (off1 / uSize)) * 0.3162162162;
    //color += texture(uTexture, uv + (off2 / uSize)) * 0.0702702703;
    //color += texture(uTexture, uv - (off2 / uSize)) * 0.0702702703;

    vec4 color = vec4(0.0);
    vec2 off1 = vec2(1.411764705882353) * direction;
    vec2 off2 = vec2(3.2941176470588234) * direction;
    vec2 off3 = vec2(5.176470588235294) * direction;
    color += texture(uTexture, uv) * 0.1964825501511404;
    color += texture(uTexture, uv + (off1 / uSize)) * 0.2969069646728344;
    color += texture(uTexture, uv - (off1 / uSize)) * 0.2969069646728344;
    color += texture(uTexture, uv + (off2 / uSize)) * 0.09447039785044732;
    color += texture(uTexture, uv - (off2 / uSize)) * 0.09447039785044732;
    color += texture(uTexture, uv + (off3 / uSize)) * 0.010381362401148057;
    color += texture(uTexture, uv - (off3 / uSize)) * 0.010381362401148057;

    fragColor = mix(baseColor, color, strength);
}
