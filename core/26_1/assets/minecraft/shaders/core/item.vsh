#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:sample_lightmap.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

uniform sampler2D Sampler0;
flat out int customSkybox;

void main() {
    customSkybox = 0;
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * sample_lightmap(Sampler2, UV2);

    texCoord0 = UV0;

    if (floor(textureLod(Sampler0, UV0, 0).a * 255.0) == 249.0) {
        customSkybox = 1;
        const vec2 corners[4] = vec2[4](vec2(0), vec2(0, 1), vec2(1), vec2(1, 0));
        vec2 corner = corners[gl_VertexID % 4];
        vec3 pos;
        if (abs(Normal.y) > 0.9) {
            pos = vec3((1.0 - corner * 2.0), -1.0).xzy
                * vec3(1, sign(Normal.y), sign(Normal.y));
        } else {
            pos = (cross(vec3(0, 1, 0), Normal) + vec3(0, -1, 0))
                * (corner * 2.0 - 1.0).xyx - Normal;
        }
        gl_Position = ProjMat * ModelViewMat * vec4(pos * 1000.0, 1.0);
#ifndef OIT_ALPHA_ONLY
        sphericalVertexDistance = 0.0;
        cylindricalVertexDistance = 0.0;
        vertexColor = texelFetch(Sampler2, ivec2(0, 15), 0);
#endif
    }
}
