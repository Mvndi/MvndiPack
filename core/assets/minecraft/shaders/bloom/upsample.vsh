#version 330

layout(std140) uniform SamplerInfo {
    vec2 OutSize;
    vec2 InSize;
};
layout(std140) uniform Iteration {
    vec4 IterationIndex;
} iteration;

flat out ivec2 inRes;
flat out ivec2 outRes;

void main() {
    vec2 uv = vec2((gl_VertexID << 1) & 2, gl_VertexID & 2);
    vec4 pos = vec4(uv * vec2(2, 2) + vec2(-1, -1), 0, 1);
    
    gl_Position = pos;
    
    ivec2 size = ivec2(floor(OutSize)) >> int(iteration.IterationIndex - 1);
    inRes = size / 2;
    outRes = size;
}