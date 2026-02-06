#version 330


int pack_vec(vec4 vec) {
    ivec4 ivec = ivec4(vec*255.0);
    return (ivec.x << 24) | (ivec.y << 16) | (ivec.z << 8) | ivec.a;
}
int pack_vec(vec3 vec) {
    ivec3 ivec = ivec3(vec*255.0);
    return (ivec.x << 16) | (ivec.y << 8) | ivec.z;
}
int pack_vec(vec2 vec) {
    ivec2 ivec = ivec2(vec*255.0);
    return (ivec.x << 8) | ivec.y;
}
int pack_vec(ivec4 ivec) {
    return (ivec.x << 24) | (ivec.y << 16) | (ivec.z << 8) | ivec.a;
}
int pack_vec(ivec3 ivec) {
    return (ivec.x << 16) | (ivec.y << 8) | ivec.z;
}
int pack_vec(ivec2 ivec) {
    return (ivec.x << 8) | ivec.y;
}


bool approx_match(float first, float second, float threshold) {
    return abs(first - second) <= threshold;
}
bool approx_match(vec2 first, vec2 second, float threshold) {
    return (
        (abs(first.x - second.x) <= threshold) &&
        (abs(first.y - second.y) <= threshold)
    );
}
bool approx_match(vec3 first, vec3 second, float threshold) {
    return (
        abs(first.x - second.x) <= threshold &&
        abs(first.y - second.y) <= threshold &&
        abs(first.z - second.z) <= threshold
    );
}