#version 330

#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;

out vec3 starColor;

const vec3[] COLORS = vec3[](
    vec3(100, 100, 100) / 255,
    vec3(100, 100, 70) / 255,
    vec3(90, 100, 120) / 255
);

void main() {
    starColor = COLORS[gl_VertexID / 4 % 3];

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
}
