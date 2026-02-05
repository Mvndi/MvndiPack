float scaler = FLAME_SIZE_SCALERS[packed_color&1];
pos.y += FLAME_HEIGHT_OFFSETS[((gl_VertexID+1)>>1)&1]*scaler;
gl_Position = ModelViewMat * vec4(pos, 1.0);
float flip = sign(dot(pos.xz, (transpose(ModelViewMat)*vec4(0.0,0.001*(ModelViewMat[1][2]),-1.0,1.0)).xz));
gl_Position.x += FLAME_WIDTH_OFFSETS[(gl_VertexID>>1)&1]*scaler*flip;
gl_Position = ProjMat * gl_Position;

#ifdef PER_FACE_LIGHTING
vertexPerFaceColorBack = vec4(1.0);
vertexPerFaceColorFront = vec4(1.0);
#else
vertexColor = vec4(1.0);
#endif

texCoord0 = UV0;