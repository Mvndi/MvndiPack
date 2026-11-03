#version 150
#define HEIGHT_BIT 13
#define MAX_BIT 10
#define ADD_OFFSET 4095
#define DEFAULT_OFFSET 10
#define SHADER_VERSION 3
#if SHADER_VERSION >= 1
#moj_import <minecraft:fog.glsl>
#else
#moj_import <fog.glsl>
#endif
#if SHADER_VERSION >= 3
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <minecraft:globals.glsl>
out float sphericalVertexDistance;out float cylindricalVertexDistance;
#else
uniform mat4 ProjMat;uniform mat4 ModelViewMat;uniform int FogShape;out float vertexDistance;uniform vec2 ScreenSize;uniform float GameTime;
#endif
in vec3 Position;in vec4 Color;in vec2 UV0;in ivec2 UV2;uniform sampler2D Sampler0;uniform sampler2D Sampler2;uniform vec3 ChunkOffset;out vec4 vertexColor;out vec2 texCoord0;out float applyColor;bool range(float t, float m1, float m2) {return t >= m1 && t <= m2;}bool range(vec2 t, vec2 m1, vec2 m2) {return range(t.x, m1.x, m2.x) && range(t.y, m1.y, m2.y);}bool range(vec3 t, vec3 m1, vec3 m2) {return range(t.x, m1.x, m2.x) && range(t.y, m1.y, m2.y) && range(t.z, m1.z, m2.z);}bool checkElement(float z) {if (z == 0) return true; else if (z == 1000) return true; else if (z == -90) return true; else if (z == 2800) return true; return false;}bool checkExp(float z) {if (z == 0) return true; else if (z == 600) return true; return false;}float fogDistance(vec3 pos, int shape) {if (shape == 0) {return length(pos);} else {float distXZ = length(pos.xz);float distY = abs(pos.y);return max(distXZ, distY);}}// MVNDI_INSTRUMENT_BEGIN
const float MVNDI_NOTE_LAYER = 18.0;
const float MVNDI_NOTE_DAY_MS = 1200000.0;
const float MVNDI_NOTE_TRAVEL = 156.0;
const ivec2 MVNDI_NOTE_SIZE = ivec2(24, 5);

bool mvndiNoteMarker(ivec2 origin, ivec2 atlasSize) {
    if (any(lessThan(origin, ivec2(0))) || any(greaterThan(origin + MVNDI_NOTE_SIZE, atlasSize))) return false;
    ivec4 first = ivec4(round(texelFetch(Sampler0, origin, 0) * 255.0));
    if (any(notEqual(first, ivec4(227, 206, 160, 254)))) return false;
    ivec4 second = ivec4(round(texelFetch(Sampler0, origin + ivec2(1, 0), 0) * 255.0));
    return all(equal(second, ivec4(184, 151, 85, 253)));
}

void mvndiInstrumentNote(inout vec3 position, inout vec4 vertexTint, vec4 encodedTint, vec2 uv, float gameTime) {
    ivec2 atlasSize = textureSize(Sampler0, 0);
    ivec2 pixel = ivec2(round(uv * vec2(atlasSize)));
    const ivec2 corners[4] = ivec2[4](ivec2(0), ivec2(0, 5), ivec2(24, 5), ivec2(24, 0));
    bool isNote = false;
    for (int corner = 0; corner < 4; corner++) {
        if (mvndiNoteMarker(pixel - corners[corner], atlasSize)) isNote = true;
    }
    if (!isNote) return;

    // Text color carries a 25 ms deadline and a 50 ms approach duration.
    ivec3 encoded = ivec3(round(encodedTint.rgb * 255.0));
    float deadline = float(encoded.r * 256 + encoded.g) * 25.0;
    float approach = float(encoded.b) * 50.0;
    float remaining = mod(deadline - gameTime * MVNDI_NOTE_DAY_MS + MVNDI_NOTE_DAY_MS * 0.5,
                          MVNDI_NOTE_DAY_MS) - MVNDI_NOTE_DAY_MS * 0.5;
    if (approach < 500.0 || approach > 10000.0 || remaining < 0.0 || remaining > approach) {
        vertexTint.a = 0.0;
        return;
    }
    position.y -= MVNDI_NOTE_TRAVEL * remaining / approach;
    vertexTint.rgb = vec3(1.0);
}
// MVNDI_INSTRUMENT_END
void main() {vec3 pos = Position;vec2 ui = ceil(2 / vec2(ProjMat[0][0], -ProjMat[1][1]));vec2 uiScreen = ui / ScreenSize;vec3 color = Color.xyz;applyColor = 0;vertexColor = Color * texture(Sampler2, UV2 / 16);if (pos.y >= ui.y && ProjMat[3].x == -1) {int bit = int(pos.y) >> HEIGHT_BIT;if (((bit >> MAX_BIT) & 1) == 1) {int id = bit - (1 << MAX_BIT);pos.x -= 0.5 * ui.x;pos.y -= (bit << HEIGHT_BIT) + ADD_OFFSET + DEFAULT_OFFSET;float xGui = 0;float yGui = 0;float layer = 0;float opacity = 1;bool outline = false;int property = 0;switch (id) {case 1:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 100.0 / 100.0;outline = true;break;case 2:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 100.0 / 100.0;break;case 3:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 100.0 / 100.0;layer = 1;outline = true;break;case 4:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 100.0 / 100.0;layer = 1;break;case 5:xGui = ui.x * 100.0 / 100.0;yGui = ui.y * 50.0 / 100.0;break;case 6:xGui = ui.x * 100.0 / 100.0;yGui = ui.y * 50.0 / 100.0;layer = 1;outline = true;break;case 7:layer = 5;outline = true;break;case 8:yGui = ui.y * 50.0 / 100.0;layer = 5;outline = true;break;case 9:yGui = ui.y * 100.0 / 100.0;layer = 5;outline = true;break;case 10:xGui = ui.x * 50.0 / 100.0;layer = 5;outline = true;break;case 11:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 100.0 / 100.0;layer = 5;outline = true;break;case 12:xGui = ui.x * 100.0 / 100.0;layer = 5;outline = true;break;case 13:xGui = ui.x * 100.0 / 100.0;yGui = ui.y * 50.0 / 100.0;layer = 5;outline = true;break;case 14:xGui = ui.x * 100.0 / 100.0;yGui = ui.y * 100.0 / 100.0;layer = 5;outline = true;break;case 15:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 50.0 / 100.0;break;case 16:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 50.0 / 100.0;layer = 1;break;case 17:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 50.0 / 100.0;layer = 2;break;case 18:xGui = ui.x * 50.0 / 100.0;yGui = ui.y * 50.0 / 100.0;layer = 18;break;}
#if SHADER_VERSION < 2
vertexColor = (checkElement(pos.z) && !outline) ? vec4(0) : Color * texture(Sampler2, UV2 / 16) * vec4(1, 1, 1, opacity);
#else
vertexColor = Color * texture(Sampler2, UV2 / 16, 0) * vec4(1, 1, 1, opacity);
#endif
if ((property & 1) > 0) {pos.y += 4 * sin((GameTime * 1200 + pos.x / ui.x) * 3.1415 * 2);}if ((property & 2) > 0) {int hash = int(pos.x) * int(pos.y);float time = GameTime * 1200;hash = 31 * (hash + int(vertexColor.x + time));float r = float(hash % 224 + 32) / 255;hash = 31 * (hash + int(vertexColor.y + time));float g = float(hash % 224 + 32) / 255;hash = 31 * (hash + int(vertexColor.z + time));float b = float(hash % 224 + 32) / 255;float maxValue = max(max(r, g), b);vertexColor = vec4(pow(r / maxValue, 3), pow(g / maxValue, 3), pow(b / maxValue, 3), vertexColor.w);}if ((property & 4) > 0) {int hash = int(pos.x) * int(pos.y);float time = GameTime * 1200;hash = 31 * (hash + int(vertexColor.x + time));float r = vertexColor.x + float(hash % 64) / 255;hash = 31 * (hash + int(vertexColor.y + time));float g = vertexColor.y + float(hash % 64) / 255;hash = 31 * (hash + int(vertexColor.z + time));float b = vertexColor.z + float(hash % 64) / 255;vertexColor = vec4(r, g, b, vertexColor.w);}if (layer == MVNDI_NOTE_LAYER) mvndiInstrumentNote(pos, vertexColor, Color, UV0, GameTime);
pos.x += xGui;pos.y += yGui;pos.z += layer;}} else {}
#if SHADER_VERSION >= 3
sphericalVertexDistance = fog_spherical_distance(pos);cylindricalVertexDistance = fog_cylindrical_distance(pos);
#else
vertexDistance = fogDistance(pos, FogShape);
#endif
texCoord0 = UV0;gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
    if (ProjMat[3].x == -1.0 && all(lessThan(abs(Color.rgb - vec3(1.0, 2.0, 3.0) / 255.0), vec3(0.001)))) {
        const vec2 loadingCorners[4] = vec2[4](vec2(-1.0, 1.0), vec2(-1.0, -1.0), vec2(1.0, -1.0), vec2(1.0, 1.0));
        gl_Position = vec4(loadingCorners[gl_VertexID % 4], -0.999, 1.0);
        vertexColor = vec4(0.0, 0.0, 0.0, Color.a);
    }
}
