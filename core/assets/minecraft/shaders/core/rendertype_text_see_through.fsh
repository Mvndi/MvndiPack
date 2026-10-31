#version 330

#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 texColor = texture(Sampler0, texCoord0);
    vec4 color = texColor * vertexColor;
    // Alpha 254 marks the capture arrow's neutral pixels so team tint does not recolor them.
    if (all(equal(ivec4(round(texColor * 255.0)), ivec4(170, 170, 170, 254)))) {
        color = vec4(texColor.rgb, vertexColor.a);
    }

    if (color.a < 0.1) {
        discard;
    }
    fragColor = color * ColorModulator;
}
