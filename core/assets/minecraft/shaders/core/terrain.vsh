#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:chunksection.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler2;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

#define ALPHA_FLAME 17
#define ALPHA_EMISSION 254
#define ALPHA_EMISSION_TRANSPARENT 16
const float[] FLAME_HEIGHT_OFFSETS = float[]( 1.0/16.0*(12.0-0.001), -1.0/16.0 );
const float[] FLAME_WIDTH_OFFSETS  = float[]( -0.5/16.0*(6.0-0.001), 0.5/16.0*(6.0-0.001) );

vec4 minecraft_sample_lightmap(sampler2D lightMap, ivec2 uv) {
    return texture(lightMap, clamp( (uv / 256.0) + 0.5 / 16.0, vec2(0.5 / 16.0), vec2(15.5 / 16.0) ));
}

#define std_gl_pos_calc gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0)

void main() {
    vec3 pos = Position + (ChunkPosition - CameraBlockPos) + CameraOffset;
    sphericalVertexDistance = fog_spherical_distance(pos);
    cylindricalVertexDistance = fog_cylindrical_distance(pos);

    int alpha_of_current = int(texture(Sampler0, UV0).a * 255.);
    switch (alpha_of_current) {
        case ALPHA_EMISSION:
        case ALPHA_EMISSION_TRANSPARENT:
            vertexColor = vec4(1.0);
            texCoord0 = UV0;
            std_gl_pos_calc;

            return;

        case ALPHA_FLAME:
            int bottom_top = ((gl_VertexID+1)>>1)&1;
            pos.y += FLAME_HEIGHT_OFFSETS[bottom_top];
            gl_Position = ModelViewMat * vec4(pos, 1.0);
            float flip = sign(dot(pos.xz, (transpose(ModelViewMat)*vec4(0.0,0.001*ModelViewMat[1][2],-1.0,1.0)).xz));
            gl_Position.x += FLAME_WIDTH_OFFSETS[(gl_VertexID>>1)&1] * flip;
            gl_Position = ProjMat * gl_Position;

            vertexColor = vec4(1.0);
            texCoord0 = UV0;

            return;
    }

    std_gl_pos_calc;

    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
}
