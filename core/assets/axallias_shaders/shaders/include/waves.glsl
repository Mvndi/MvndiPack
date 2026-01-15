#version 330

float triangular_wave(float t) {
    return abs(fract(t)*2.0 - 1.0);
}