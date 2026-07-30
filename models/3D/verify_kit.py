"""Independent .glb parser + validator + preview renderer (doesn't reuse export code,
so it actually catches bugs in the exporter rather than just re-trusting it)."""
import json
import struct
import sys
import os
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection

COMPTYPE_SIZE = {5120: 1, 5121: 1, 5122: 2, 5123: 2, 5125: 4, 5126: 4}
COMPTYPE_FMT = {5120: "b", 5121: "B", 5122: "h", 5123: "H", 5125: "I", 5126: "f"}
TYPE_COUNT = {"SCALAR": 1, "VEC2": 2, "VEC3": 3, "VEC4": 4}


def parse_glb(path):
    with open(path, "rb") as f:
        data = f.read()
    magic, version, length = struct.unpack_from("<III", data, 0)
    assert magic == 0x46546C67, "bad magic"
    assert length == len(data), f"length mismatch: header says {length}, file is {len(data)}"
    offset = 12
    json_chunk = None
    bin_chunk = None
    while offset < length:
        chunk_len, chunk_type = struct.unpack_from("<II", data, offset)
        offset += 8
        chunk_data = data[offset:offset + chunk_len]
        offset += chunk_len
        if chunk_type == 0x4E4F534A:
            json_chunk = chunk_data
        elif chunk_type == 0x004E4942:
            bin_chunk = chunk_data
    gltf = json.loads(json_chunk)
    return gltf, bin_chunk


def read_accessor(gltf, bin_chunk, acc_idx):
    acc = gltf["accessors"][acc_idx]
    bv = gltf["bufferViews"][acc["bufferView"]]
    comp_size = COMPTYPE_SIZE[acc["componentType"]]
    ncomp = TYPE_COUNT[acc["type"]]
    fmt = "<" + COMPTYPE_FMT[acc["componentType"]] * ncomp
    stride = bv.get("byteStride", comp_size * ncomp)
    base = bv.get("byteOffset", 0)
    out = np.zeros((acc["count"], ncomp))
    for i in range(acc["count"]):
        off = base + i * stride
        vals = struct.unpack_from(fmt, bin_chunk, off)
        out[i] = vals
    return out


def validate_and_render(path, ax=None):
    name = os.path.splitext(os.path.basename(path))[0]
    gltf, bin_chunk = parse_glb(path)
    assert gltf["asset"]["version"] == "2.0"

    all_tris = []
    all_colors = []
    mat_colors = [m["pbrMetallicRoughness"]["baseColorFactor"][:3] for m in gltf["materials"]]

    total_tris = 0
    total_verts = 0
    degenerate = 0
    for mesh in gltf["meshes"]:
        for prim in mesh["primitives"]:
            pos = read_accessor(gltf, bin_chunk, prim["attributes"]["POSITION"])
            nrm = read_accessor(gltf, bin_chunk, prim["attributes"]["NORMAL"])
            idx = read_accessor(gltf, bin_chunk, prim["indices"]).astype(int).flatten()
            assert idx.max() < len(pos), "index out of range"
            assert not np.isnan(pos).any(), "NaN in positions"
            color = mat_colors[prim["material"]]
            total_verts += len(pos)
            for t in range(0, len(idx), 3):
                a, b, c = idx[t], idx[t + 1], idx[t + 2]
                v0, v1, v2 = pos[a], pos[b], pos[c]
                cross = np.cross(v1 - v0, v2 - v1)
                area = np.linalg.norm(cross)
                total_tris += 1
                if area < 1e-9:
                    degenerate += 1
                    continue
                face_n = cross / area
                # check face normal roughly matches stored vertex normals (within 90deg)
                stored_n = (nrm[a] + nrm[b] + nrm[c]) / 3.0
                if np.linalg.norm(stored_n) > 1e-6:
                    dot = np.dot(face_n, stored_n / np.linalg.norm(stored_n))
                    assert dot > 0.5, f"{name}: winding/normal mismatch (dot={dot:.2f})"
                # remap (x,y,z)world -> (x,z,y) so world-up(Y) plots as chart-up(Z)
                def remap(v):
                    return (v[0], v[2], v[1])
                all_tris.append([remap(v0), remap(v1), remap(v2)])
                all_colors.append(color)

    bounds_min = np.min([p for tri in all_tris for p in tri], axis=0)  # (x, z, y-height)
    bounds_max = np.max([p for tri in all_tris for p in tri], axis=0)
    print(f"{name:16s} verts={total_verts:4d} tris={total_tris:4d} degenerate={degenerate} "
          f"x=[{bounds_min[0]:.2f},{bounds_max[0]:.2f}] z=[{bounds_min[1]:.2f},{bounds_max[1]:.2f}] "
          f"height=[{bounds_min[2]:.2f},{bounds_max[2]:.2f}]")
    assert degenerate == 0, f"{name} has degenerate triangles"

    if ax is not None:
        poly = Poly3DCollection(all_tris, facecolors=all_colors, edgecolors="k", linewidths=0.15)
        ax.add_collection3d(poly)
        ax.set_title(name, fontsize=9)
        mid = (bounds_min + bounds_max) / 2
        r = max((bounds_max - bounds_min).max(), 0.5) / 2 + 0.2
        ax.set_xlim(mid[0] - r, mid[0] + r)
        ax.set_ylim(mid[1] - r, mid[1] + r)
        ax.set_zlim(mid[2] - r, mid[2] + r)
        ax.set_axis_off()
        try:
            ax.set_box_aspect((1, 1, 1))
        except Exception:
            pass
        ax.view_init(elev=22, azim=-60)
    return total_tris, degenerate


def main():
    outdir = os.path.dirname(os.path.abspath(__file__))
    names = ["floor_tile", "wall_straight", "wall_corner", "doorway",
             "window_wall", "pillar", "stairs", "wall_broken"]
    fig = plt.figure(figsize=(16, 8))
    ok = True
    for i, name in enumerate(names):
        ax = fig.add_subplot(2, 4, i + 1, projection="3d")
        path = os.path.join(outdir, name + ".glb")
        try:
            validate_and_render(path, ax)
        except AssertionError as e:
            print(f"FAIL {name}: {e}")
            ok = False
    plt.tight_layout()
    preview_path = os.path.join(outdir, "_preview.png")
    plt.savefig(preview_path, dpi=130)
    print("Preview saved:", preview_path)
    print("ALL OK" if ok else "SOME CHECKS FAILED")


if __name__ == "__main__":
    main()
