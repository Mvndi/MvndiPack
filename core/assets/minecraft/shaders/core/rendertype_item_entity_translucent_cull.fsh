#version 330

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <shader_assets:utils.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;

flat in int custom;

out vec4 fragColor;

void main() {
    vec4 color;
    if (custom != 0)
    {
        if (custom == 1) //Skybox
        {
            color = bilinear(Sampler0, texCoord0);

            float mask = color.g;
            
            color.a *= mask;


            color *= vertexColor;
        }
    }
    else
    {
        color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
        if (color.a < 0.1) {
            discard;
        }
    }


    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}
