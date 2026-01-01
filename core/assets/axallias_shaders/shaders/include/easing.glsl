#version 150

float cubic_in_out(float t) {
    t = 1.0 - t;
    t = 1.0 - t*t;
    return t*t;
}
vec2 cubic_in_out(vec2 v) {
    return vec2(
        cubic_in_out(v.x),
        cubic_in_out(v.y)
    );
}
vec3 cubic_in_out(vec3 v) {
    return vec3(
        cubic_in_out(v.x),
        cubic_in_out(v.y),
        cubic_in_out(v.z)
    );
}

float half_square(float t) {
    float b = t*t;
    return (t+b)*0.5;
}

float minor_square(float t) {
    float b = t*t;
    return t*0.6 + b*0.4;
}

float any_square(float t, float k) {
    float b = t*t;
    return t*(1.0 - k) + b*k;
}

float smooth_contrast_cap(float _in) {
    float a = _in + 0.5;
    a*=a;
    a*=a;
    return 1.0 - (1.0625 / (a + 1.0));
}