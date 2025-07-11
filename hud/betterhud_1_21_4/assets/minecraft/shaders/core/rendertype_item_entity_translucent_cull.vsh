#version 150
#define HEIGHT_BIT 13
#define MAX_BIT 10
#define ADD_OFFSET 4095
#define DEFAULT_OFFSET 10
#define SHADER_VERSION 2
#if SHADER_VERSION >= 1
#moj_import <minecraft:light.glsl>
#moj_import <minecraft:fog.glsl>
#else
#moj_import <light.glsl>
#moj_import <fog.glsl>
#endif
#if SHADER_VERSION >= 3
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>
out float sphericalVertexDistance;out float cylindricalVertexDistance;
#else
uniform mat4 ProjMat;uniform mat4 ModelViewMat;uniform int FogShape;uniform vec3 Light0_Direction;uniform vec3 Light1_Direction;out float vertexDistance;uniform vec2 ScreenSize;
#endif
in vec3 Position;in vec4 Color;in vec2 UV0;in vec2 UV1;in ivec2 UV2;in vec3 Normal;uniform sampler2D Sampler2;uniform vec3 ChunkOffset;out vec4 vertexColor;out vec2 texCoord0;out vec2 texCoord1;out vec2 texCoord2;out vec4 normal;float fogDistance(vec3 pos, int shape) {if (shape == 0) {return length(pos);} else {float distXZ = length(pos.xz);float distY = abs(pos.y);return max(distXZ, distY);}}void main() {vec3 pos = Position;gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
#if SHADER_VERSION >= 3
sphericalVertexDistance = fog_spherical_distance(pos);cylindricalVertexDistance = fog_cylindrical_distance(pos);
#else
vertexDistance = fogDistance(pos, FogShape);
#endif
vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);texCoord0 = UV0;texCoord1 = UV1;texCoord2 = UV2;normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);}