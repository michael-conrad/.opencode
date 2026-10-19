# Shared fixture code for .opencode#2640 image-work scenarios.
# Sourced by fixtures/setup/2640-sc*.sh; provides make_test_png — a
# dependency-free PNG generator (three horizontal color bands) so the
# scenario's image material exists on disk before the model runs
# (pre-supplied environment mandate, tests-v2 AGENTS.md §3a).

make_test_png() {
    # $1 = output path. Writes a 300x200 PNG: top band red, middle green,
    # bottom blue.
    python3 - "$1" <<'PY'
import struct, sys, zlib

path = sys.argv[1]
w, h = 300, 200
band = h // 3
rows = []
for y in range(h):
    if y < band:
        px = (255, 0, 0)
    elif y < 2 * band:
        px = (0, 255, 0)
    else:
        px = (0, 0, 255)
    rows.append(b'\x00' + bytes(px * w))
raw = b''.join(rows)

def chunk(tag, data):
    return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)

png = (b'\x89PNG\r\n\x1a\n'
       + chunk(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 2, 0, 0, 0))
       + chunk(b'IDAT', zlib.compress(raw))
       + chunk(b'IEND', b''))
with open(path, 'wb') as f:
    f.write(png)
print(f"fixture png written: {path}")
PY
}
