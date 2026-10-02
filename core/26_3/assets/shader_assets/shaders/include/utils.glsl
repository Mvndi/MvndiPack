#include <axallias_shaders:easing.glsl>

vec4 bilinear(sampler2D sourceTexture, vec2 uv)
{
    vec2 texSize = textureSize(sourceTexture, 0);
    vec2 IUV = uv * texSize;
    ivec2 fl = ivec2(floor(IUV));
    vec2 fr = cubic_in_out(fract(IUV));
    const ivec2 offset = ivec2(0, 1);

    return mix(
        mix(texelFetch(sourceTexture, fl, 0), texelFetch(sourceTexture, fl + offset.yx, 0), fr.x),
        mix(texelFetch(sourceTexture, fl + offset, 0), texelFetch(sourceTexture, fl + offset.yy, 0), fr.x),
        fr.y
    );
}