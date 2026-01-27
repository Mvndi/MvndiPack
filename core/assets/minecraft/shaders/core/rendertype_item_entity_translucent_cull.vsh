#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;

flat out int custom;

void main() {
    custom = 0;
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    const vec2[4] corners = vec2[4](vec2(0), vec2(0, 1), vec2(1), vec2(1, 0));
    vec2 corner = corners[gl_VertexID % 4];

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;

    
    if (floor(textureLod(Sampler0, UV0, 0).a * 255) == 249) //Skybox
    {
        custom = 1;
        vec3 pos = Position;
        if (abs(Normal.y) > 0.9)
        {
            pos = vec3((1 - corner * 2), -1).xzy * vec3(1, sign(Normal.y), sign(Normal.y));
        }
        else
        {
            pos = (cross(vec3(0, 1, 0), Normal) + vec3(0, -1, 0)) * (corner * 2 - 1).xyx - Normal;
        }
        pos *= 1000;

        gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
        sphericalVertexDistance = 0;
        cylindricalVertexDistance = 0;
        vertexColor = texelFetch(Sampler2, ivec2(0, 15), 0);
    }
}
