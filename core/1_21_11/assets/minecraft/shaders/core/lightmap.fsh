#version 330

#moj_import <axallias_shaders:easing.glsl>
#moj_import <axallias_shaders:waves.glsl>
#moj_import <minecraft:globals.glsl>

layout(std140) uniform LightmapInfo {
    float AmbientLightFactor;
    float SkyFactor;
    float BlockFactor;
    float NightVisionFactor;
    float DarknessScale;
    float DarkenWorldFactor;
    float BrightnessFactor;
    vec3 SkyLightColor;
    vec3 AmbientColor;
} lightmapInfo;

in vec2 texCoord;

out vec4 fragColor;

#define MOONLIGHT_COLOR vec3(0.04, 0.02, 0.06)
#define SUNLIGHT_COLOR  vec3(1.0, 1.0, 0.9)
#define SUNSET_COLOR    vec3(1.2, 0.9, 0.3)

#define BLOCK_LIGHT_COLOR vec3(1.0, 0.9, 0.4)

vec3 notGamma(vec3 color) {
    float maxComponent = max(max(color.x, color.y), color.z);
    float maxInverted = 1.0f - maxComponent;
    float maxScaled = 1.0f - maxInverted * maxInverted * maxInverted * maxInverted;
    return color * (maxScaled / maxComponent);
}

void main() {
    //if (texCoord.xy > vec2(1.0/17.0, 1.0/17.0)) {
    //    fragColor = vec4(1.0); return;
    //}

    vec3 color;
    // please remind to me pick better names
    float factor = texCoord.x;

    // don't ask, works fast enough.
    float sunsetness = 1.0 - abs(lightmapInfo.SkyFactor*2-1.0);
    sunsetness *= sunsetness;
    sunsetness *= sunsetness;
    sunsetness *= sunsetness;
    sunsetness = 1.0-sunsetness;
    sunsetness *= sunsetness;
    sunsetness *= sunsetness;
    sunsetness *= sunsetness;
    sunsetness = 1.0-sunsetness;

    float daynight_factor = max(lightmapInfo.SkyFactor-0.25, 0.0)*1.3333;

    vec3 skylight_color = mix(MOONLIGHT_COLOR * (lightmapInfo.BrightnessFactor + 1.0), SUNLIGHT_COLOR, cubic_in_out(daynight_factor));
    vec3 sunset_color = vec3(
        skylight_color.r*1.4, 
        skylight_color.g*skylight_color.g*1.4, 
        skylight_color.b*skylight_color.b*skylight_color.b
    );
    skylight_color = mix(skylight_color, sunset_color, sunsetness*0.4);


    float block_light_jitter = 
        -0.125 + (
            triangular_wave(GameTime*244.0)*0.3125
            + triangular_wave(GameTime*43454.678)*0.125
            + triangular_wave(GameTime*700.23)*0.25
            + triangular_wave(GameTime*323.234)*0.3125
        ) * 0.5;

    float factor2 = any_square(texCoord.x*texCoord.x, block_light_jitter);
    float factor4 = factor2*factor2;
    float factor8 = factor4*factor4;

    vec3 block_light = vec3(factor2, minor_square(factor2), half_square(factor2)*0.7);

    block_light = min(
        block_light + vec3(factor8*factor8*0.3),
        vec3(1.0)
    );

    block_light = mix(
        block_light,
        vec3(0.9, 0.7, 0.0)*factor4,
        texCoord.y*daynight_factor
    );

    float darkening = lightmapInfo.DarknessScale < 0.01 
        ? 1.0
        : pow(max(texCoord.x, texCoord.y), lightmapInfo.DarknessScale*5.0);

    fragColor = vec4((block_light+skylight_color*texCoord.y + vec3(lightmapInfo.NightVisionFactor*0.3))*darkening, 1.0);

    //fragColor.rgb = mix(fragColor.rgb, vec3(1.0), lightmapInfo.NightVisionFactor);  // just for debug
}