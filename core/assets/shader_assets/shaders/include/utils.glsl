#moj_import <axallias_shaders:easing.glsl>

vec4 bilinear(sampler2D sampler, vec2 uv)
{
    vec2 texSize = textureSize(sampler, 0);
    vec2 IUV = uv * texSize;
    ivec2 fl = ivec2(floor(IUV));
    vec2 fr = cubic_in_out(fract(IUV));
    const ivec2 offset = ivec2(0, 1);

    return mix(
        mix(texelFetch(sampler, fl, 0), texelFetch(sampler, fl + offset.yx, 0), fr.x),
        mix(texelFetch(sampler, fl + offset, 0), texelFetch(sampler, fl + offset.yy, 0), fr.x),
        fr.y
    );
}