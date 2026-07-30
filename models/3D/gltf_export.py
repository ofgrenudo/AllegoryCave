"""Minimal, dependency-free glTF 2.0 (.glb) exporter + simple box/prism mesh builder.

Built because trimesh/blender aren't available offline in this sandbox.
Handles exactly what a low-poly modular dungeon kit needs: boxes and n-gon prisms,
each mesh with a single flat PBR material, exported as binary glTF (.glb) for Godot 4.
"""
import json
import struct
import numpy as np

GLTF_MAGIC = 0x46546C67
JSON_CHUNK_TYPE = 0x4E4F534A
BIN_CHUNK_TYPE = 0x004E4942

COMPONENT_FLOAT = 5126
COMPONENT_UINT = 5125
TARGET_ARRAY_BUFFER = 34962
TARGET_ELEMENT_ARRAY_BUFFER = 34963


class MeshPart:
    """One mesh: a soup of positions/normals/triangle indices + one material."""

    def __init__(self, name, material):
        self.name = name
        self.material = material  # dict: baseColor(rgba tuple), metallic, roughness
        self.positions = []  # list of (x,y,z)
        self.normals = []  # list of (x,y,z)
        self.indices = []  # list of int

    def add_face(self, points, inside_ref):
        """Add a convex planar polygon face (>=3 pts). Auto-orients winding/normal
        so the face points AWAY from inside_ref (the solid's interior reference point)."""
        pts = [np.array(p, dtype=np.float64) for p in points]
        v0, v1, v2 = pts[0], pts[1], pts[2]
        normal = np.cross(v1 - v0, v2 - v1)
        mid = np.mean(pts, axis=0)
        if np.dot(normal, mid - np.array(inside_ref, dtype=np.float64)) < 0:
            pts = pts[::-1]
            normal = -normal
        norm = np.linalg.norm(normal)
        if norm > 1e-12:
            normal = normal / norm
        base = len(self.positions)
        for p in pts:
            self.positions.append((float(p[0]), float(p[1]), float(p[2])))
            self.normals.append((float(normal[0]), float(normal[1]), float(normal[2])))
        for i in range(1, len(pts) - 1):
            self.indices += [base, base + i, base + i + 1]

    def add_box(self, xmin, xmax, ymin, ymax, zmin, zmax):
        center = ((xmin + xmax) / 2.0, (ymin + ymax) / 2.0, (zmin + zmax) / 2.0)
        # -z, +z, -x, +x, -y, +y (order doesn't matter; auto-orient fixes winding)
        self.add_face([(xmin, ymin, zmin), (xmax, ymin, zmin), (xmax, ymax, zmin), (xmin, ymax, zmin)], center)
        self.add_face([(xmin, ymin, zmax), (xmax, ymin, zmax), (xmax, ymax, zmax), (xmin, ymax, zmax)], center)
        self.add_face([(xmin, ymin, zmin), (xmin, ymin, zmax), (xmin, ymax, zmax), (xmin, ymax, zmin)], center)
        self.add_face([(xmax, ymin, zmin), (xmax, ymin, zmax), (xmax, ymax, zmax), (xmax, ymax, zmin)], center)
        self.add_face([(xmin, ymin, zmin), (xmax, ymin, zmin), (xmax, ymin, zmax), (xmin, ymin, zmax)], center)
        self.add_face([(xmin, ymax, zmin), (xmax, ymax, zmin), (xmax, ymax, zmax), (xmin, ymax, zmax)], center)

    def add_prism(self, cx, cz, radius, ymin, ymax, sides=8, rot=0.0):
        """N-sided vertical prism (used for the pillar)."""
        center = (cx, (ymin + ymax) / 2.0, cz)
        angles = [rot + 2 * np.pi * i / sides for i in range(sides)]
        ring = [(cx + radius * np.cos(a), cz + radius * np.sin(a)) for a in angles]
        # sides
        for i in range(sides):
            x0, z0 = ring[i]
            x1, z1 = ring[(i + 1) % sides]
            self.add_face([(x0, ymin, z0), (x1, ymin, z1), (x1, ymax, z1), (x0, ymax, z0)], center)
        # bottom cap
        self.add_face([(x, ymin, z) for x, z in ring], center)
        # top cap
        self.add_face([(x, ymax, z) for x, z in ring], center)


def _pad(data, align, pad_byte):
    rem = len(data) % align
    if rem:
        data += pad_byte * (align - rem)
    return data


def export_glb(path, parts, extra_root_transform=None):
    """parts: list of MeshPart. Each becomes its own mesh+node+material in the file."""
    buffer_bytes = bytearray()
    accessors = []
    buffer_views = []
    materials = []
    material_index_by_key = {}
    meshes = []
    nodes = []

    for part in parts:
        pos = np.array(part.positions, dtype=np.float32)
        nrm = np.array(part.normals, dtype=np.float32)
        idx = np.array(part.indices, dtype=np.uint32)

        # positions bufferView/accessor
        pos_offset = len(buffer_bytes)
        buffer_bytes += pos.tobytes()
        bv_pos = len(buffer_views)
        buffer_views.append({
            "buffer": 0, "byteOffset": pos_offset, "byteLength": pos.nbytes,
            "target": TARGET_ARRAY_BUFFER,
        })
        acc_pos = len(accessors)
        accessors.append({
            "bufferView": bv_pos, "componentType": COMPONENT_FLOAT, "count": len(pos),
            "type": "VEC3",
            "min": pos.min(axis=0).tolist(), "max": pos.max(axis=0).tolist(),
        })

        # normals
        nrm_offset = len(buffer_bytes)
        buffer_bytes += nrm.tobytes()
        bv_nrm = len(buffer_views)
        buffer_views.append({
            "buffer": 0, "byteOffset": nrm_offset, "byteLength": nrm.nbytes,
            "target": TARGET_ARRAY_BUFFER,
        })
        acc_nrm = len(accessors)
        accessors.append({
            "bufferView": bv_nrm, "componentType": COMPONENT_FLOAT, "count": len(nrm),
            "type": "VEC3",
        })

        # indices
        idx_offset = len(buffer_bytes)
        buffer_bytes += idx.tobytes()
        bv_idx = len(buffer_views)
        buffer_views.append({
            "buffer": 0, "byteOffset": idx_offset, "byteLength": idx.nbytes,
            "target": TARGET_ELEMENT_ARRAY_BUFFER,
        })
        acc_idx = len(accessors)
        accessors.append({
            "bufferView": bv_idx, "componentType": COMPONENT_UINT, "count": len(idx),
            "type": "SCALAR",
        })

        # material (dedupe by key)
        mkey = part.material["name"]
        if mkey not in material_index_by_key:
            m = part.material
            material_index_by_key[mkey] = len(materials)
            materials.append({
                "name": mkey,
                "pbrMetallicRoughness": {
                    "baseColorFactor": list(m["baseColor"]),
                    "metallicFactor": m.get("metallic", 0.0),
                    "roughnessFactor": m.get("roughness", 0.9),
                },
                "doubleSided": False,
            })
        mat_idx = material_index_by_key[mkey]

        mesh_idx = len(meshes)
        meshes.append({
            "name": part.name,
            "primitives": [{
                "attributes": {"POSITION": acc_pos, "NORMAL": acc_nrm},
                "indices": acc_idx,
                "material": mat_idx,
            }],
        })
        node = {"name": part.name, "mesh": mesh_idx}
        nodes.append(node)

    root_children = list(range(len(nodes)))
    if extra_root_transform:
        nodes.append({"name": "root", "children": root_children, **extra_root_transform})
        scene_roots = [len(nodes) - 1]
    else:
        scene_roots = root_children

    gltf = {
        "asset": {"version": "2.0", "generator": "dungeon-kit-mini-exporter"},
        "scene": 0,
        "scenes": [{"nodes": scene_roots}],
        "nodes": nodes,
        "meshes": meshes,
        "materials": materials,
        "accessors": accessors,
        "bufferViews": buffer_views,
        "buffers": [{"byteLength": len(buffer_bytes)}],
    }

    json_bytes = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    json_bytes = _pad(bytearray(json_bytes), 4, b" ")
    bin_bytes = _pad(bytearray(buffer_bytes), 4, b"\x00")

    total_len = 12 + (8 + len(json_bytes)) + (8 + len(bin_bytes))
    with open(path, "wb") as f:
        f.write(struct.pack("<III", GLTF_MAGIC, 2, total_len))
        f.write(struct.pack("<II", len(json_bytes), JSON_CHUNK_TYPE))
        f.write(json_bytes)
        f.write(struct.pack("<II", len(bin_bytes), BIN_CHUNK_TYPE))
        f.write(bin_bytes)
