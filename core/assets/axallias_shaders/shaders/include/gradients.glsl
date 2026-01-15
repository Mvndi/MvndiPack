#moj_import <ruthless:waves.glsl>
#moj_import <ruthless:easing.glsl>

float cubic_wave(float t) {
    return cubic_in_out(triangular_wave(t));
}

float steep(float t) {
    float b = 1.0 - pow(t, 4.0);
    return pow(b, 120.0);
}
float steep_wave(float t) {
    return steep(triangular_wave(t));
}

vec3 weird_glistering(float factor) {
    float factorA = cubic_wave(factor * 16.0) * 0.8;
    float factorB = cubic_wave(factor * 43.0 + 0.3) * 0.5;
    float factorC = cubic_wave(factor * 7.0 + 0.5) * 0.4;
    
    float factorD = cubic_wave(factor * 5.0 + 3.2434) * 0.8;
    float factorE = cubic_wave(factor * 23.0 + 0.4) * 0.3;
    float factorF = cubic_wave(factor * 6.0 + 0.65) * 0.2;
    
    float factorG = steep_wave(factor * 3.2);
    float factorH = steep_wave(factor * 6.2);
    
    vec3 col = vec3(
        (factorA + factorB + factorC), (factorD+factorE+factorF), 1.0
    );
    float max_of_all = max(col.r, col.g);
    vec3 col_mod = col/max_of_all;
    
    return mix(col, col_mod, factorG+factorH*0.25) * 0.25 + vec3(0.75);
}

vec3 paper_drawn(float x) {
    return vec3(x, half_square(x)*0.9, x*x*0.6) + vec3(0.02, 0.03, 0.03);
}