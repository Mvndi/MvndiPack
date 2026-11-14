from pathlib import Path
import re
import sys

BEGIN = "// MVNDI_INSTRUMENT_BEGIN"
END = "// MVNDI_INSTRUMENT_END"
CALL = "if (layer == MVNDI_NOTE_LAYER) mvndiInstrumentNote(pos, vertexColor, Color, UV0, GameTime);"
ANCHOR = "pos.x += xGui;"
KERNEL = Path(__file__).with_name("instrument_notes.glsl").read_text()
BLOCK = BEGIN + "\n" + KERNEL + END + "\n"


def patch(source):
    if BEGIN in source:
        source = re.sub(re.escape(BEGIN) + r".*?" + re.escape(END) + r"\n?", "", source, flags=re.S)
        source = source.replace(CALL + "\n", "")
    assert source.count("void main()") == 1
    assert source.count(ANCHOR) == 1
    assert "void mvndiInstrumentNote" not in source
    block = BLOCK
    if not re.search(r"uniform\s+sampler2D\s+Sampler0\s*;", source):
        block = BEGIN + "\nuniform sampler2D Sampler0;\n" + KERNEL + END + "\n"
    updated = source.replace("void main()", block + "void main()", 1)
    updated = updated.replace(ANCHOR, CALL + "\n" + ANCHOR, 1)
    assert updated.count("void mvndiInstrumentNote") == 1
    assert updated.count(CALL) == 1
    return updated


def apply(root):
    pending = []
    for target in sorted(Path(root).rglob("*.vsh")):
        source = target.read_text()
        if ANCHOR in source:
            result = patch(source)
            assert patch(result) == result, target
            pending.append((target, result))
    if not pending:
        raise ValueError("No BetterHUD text shaders found in " + str(root))
    for target, result in pending:
        target.write_text(result)
    print(str(root) + ": patched " + str(len(pending)) + " text shaders")


if __name__ == "__main__":
    for directory in sys.argv[1:]:
        apply(directory)
