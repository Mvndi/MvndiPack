#version 330

#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

#moj_import <axallias_shaders:matching.glsl>
#moj_import <axallias_flaming_torches:item_torch_flame.setup.glsl>
#define EMISSIVITY_TRIGGER_COLOR  ((37 << 16) | (69 << 8) | 42)

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
#ifdef PER_FACE_LIGHTING
out vec4 vertexPerFaceColorBack;
out vec4 vertexPerFaceColorFront;
#else
out vec4 vertexColor;
#endif
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;

#define std_gl_pos_calc gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0)

void main() {

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);

    int packed_color = pack_vec(Color.rgb);
    switch (packed_color & 0xfffffe) {
    case EMISSIVITY_TRIGGER_COLOR:
        #ifdef PER_FACE_LIGHTING
        vertexPerFaceColorBack = vec4(1.0);
        vertexPerFaceColorFront = vec4(1.0);
        #else
        vertexColor = vec4(1.0);
        #endif
        lightMapColor = vec4(1.0);
        texCoord0 = UV0;
        overlayColor = texelFetch(Sampler1, UV1, 0);
        std_gl_pos_calc;
        return;
    case TORCH_FLAME_TRIGGER_COLOR:
        vec3 pos = Position;
        #moj_import <axallias_flaming_torches:item_torch_flame.apply.glsl>

        lightMapColor = vec4(1.0);
        overlayColor = texelFetch(Sampler1, UV1, 0);

        return;
    default:
        std_gl_pos_calc;
    }

#ifdef PER_FACE_LIGHTING
    vec2 light = minecraft_compute_light(Light0_Direction, Light1_Direction, Normal);
    vertexPerFaceColorBack = minecraft_mix_light_separate(-light, Color);
    vertexPerFaceColorFront = minecraft_mix_light_separate(light, Color);
#elif defined(NO_CARDINAL_LIGHTING)
    vertexColor = Color;
#else
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
#endif
#ifndef EMISSIVE
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
#endif
    overlayColor = texelFetch(Sampler1, UV1, 0);

    texCoord0 = UV0;
#ifdef APPLY_TEXTURE_MATRIX
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
#endif
}
