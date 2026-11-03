const float MVNDI_NOTE_LAYER = 18.0;
const float MVNDI_NOTE_DAY_MS = 1200000.0;
const float MVNDI_NOTE_TRAVEL = 156.0;
const ivec2 MVNDI_NOTE_SIZE = ivec2(24, 5);

bool mvndiNoteMarker(ivec2 origin, ivec2 atlasSize) {
    if (any(lessThan(origin, ivec2(0))) || any(greaterThan(origin + MVNDI_NOTE_SIZE, atlasSize))) return false;
    ivec4 first = ivec4(round(texelFetch(Sampler0, origin, 0) * 255.0));
    if (any(notEqual(first, ivec4(227, 206, 160, 254)))) return false;
    ivec4 second = ivec4(round(texelFetch(Sampler0, origin + ivec2(1, 0), 0) * 255.0));
    return all(equal(second, ivec4(184, 151, 85, 253)));
}

void mvndiInstrumentNote(inout vec3 position, inout vec4 vertexTint, vec4 encodedTint, vec2 uv, float gameTime) {
    ivec2 atlasSize = textureSize(Sampler0, 0);
    ivec2 pixel = ivec2(round(uv * vec2(atlasSize)));
    const ivec2 corners[4] = ivec2[4](ivec2(0), ivec2(0, 5), ivec2(24, 5), ivec2(24, 0));
    bool isNote = false;
    for (int corner = 0; corner < 4; corner++) {
        if (mvndiNoteMarker(pixel - corners[corner], atlasSize)) isNote = true;
    }
    if (!isNote) return;

    // Text color carries a 25 ms deadline and a 50 ms approach duration.
    ivec3 encoded = ivec3(round(encodedTint.rgb * 255.0));
    float deadline = float(encoded.r * 256 + encoded.g) * 25.0;
    float approach = float(encoded.b) * 50.0;
    float remaining = mod(deadline - gameTime * MVNDI_NOTE_DAY_MS + MVNDI_NOTE_DAY_MS * 0.5,
                          MVNDI_NOTE_DAY_MS) - MVNDI_NOTE_DAY_MS * 0.5;
    if (approach < 500.0 || approach > 10000.0 || remaining < 0.0 || remaining > approach) {
        vertexTint.a = 0.0;
        return;
    }
    position.y -= MVNDI_NOTE_TRAVEL * remaining / approach;
    vertexTint.rgb = vec3(1.0);
}
