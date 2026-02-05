#version 330

#define TORCH_FLAME_TRIGGER_COLOR ((17 << 16) | (96 << 8) | 90)

const float[] FLAME_HEIGHT_OFFSETS = float[]( 1.0/16.0*(12.0-0.001), -1.0/16.0 );
const float[] FLAME_WIDTH_OFFSETS  = float[]( -0.5/16.0*(6.0-0.001), 0.5/16.0*(6.0-0.001) );

const float[] FLAME_SIZE_SCALERS = float[]( 0.33, 1.0 );