#version 330
#extension GL_ARB_separate_shader_objects : require

#include <minecraft:dynamictransforms.glsl>
#include <minecraft:projection.glsl>

layout(location = 0) in vec3 Position;

layout(location = 0) out vec3 starColor;

const vec3[] COLORS = vec3[](
    vec3(100, 100, 100) / 255,
    vec3(100, 100, 70) / 255,
    vec3(90, 100, 120) / 255
);

void main() {
    starColor = COLORS[gl_VertexIndex / 4 % 3];

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
}
