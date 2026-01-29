#version 330

#moj_import <minecraft:dynamictransforms.glsl>

in vec3 starColor;

out vec4 fragColor;

void main() {
    fragColor = vec4(starColor, ColorModulator.a * 2);
}
