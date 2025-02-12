#version 150
#moj_import <light.glsl>
#moj_import <fog.glsl>
in vec3 Position;in vec4 Color;in vec2 UV0;in vec2 UV1;in ivec2 UV2;in vec3 Normal;uniform sampler2D Sampler2;uniform mat4 ModelViewMat;uniform mat4 ProjMat;uniform int FogShape;uniform vec3 Light0_Direction;uniform vec3 Light1_Direction;uniform vec2 ScreenSize;uniform vec3 ChunkOffset;out float vertexDistance;out vec4 vertexColor;out vec2 texCoord0;out vec2 texCoord1;out vec2 texCoord2;out vec4 normal;
#define HEIGHT_BIT 13
#define MAX_BIT 10
#define ADD_OFFSET 4095
#define DEFAULT_OFFSET 10
float getDistance(vec3 pos, int shape) {if (shape == 0) {return length(pos);} else {float distXZ = length(pos.xz);float distY = abs(pos.y);return max(distXZ, distY);}}void main() {vec3 pos = Position;gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);vertexDistance = getDistance(pos, FogShape);vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);texCoord0 = UV0;texCoord1 = UV1;texCoord2 = UV2;normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);}