#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

#moj_import <shader_assets:utils.glsl>
flat in int customSkybox;

void main() {
    if (customSkybox == 1) {
        vec4 skyColor = bilinear(Sampler0, texCoord0);
        skyColor.a *= skyColor.g;
#ifdef OIT_ALPHA_ONLY
        executeAlphaOnlyPhase(gl_FragCoord.z, skyColor.a);
#else
        skyColor *= vertexColor;
#ifdef OIT_ACCUMULATE
        skyColor = sampleColorForAccumulation(skyColor);
#endif
        fragColor = skyColor;
#endif
        return;
    }

    vec4 color = texture(Sampler0, texCoord0);
#ifdef ALPHA_CUTOUT
    if (color.a < ALPHA_CUTOUT) {
        discard;
    }
#endif

    color *= vertexColor * ColorModulator;
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
