"""Generates the modular dungeon kit .glb files. Grid unit = 2m x 2m tiles,
wall height = 3m, wall thickness = 0.3m. All pieces are pivoted at the
local-space corner (0,0,0) of their 2x2 footprint so they snap to a 2m grid
in Godot (just place at multiples of 2 on X/Z).
"""
import os
from gltf_export import MeshPart, export_glb

OUT = os.path.dirname(os.path.abspath(__file__))

T = 2.0      # tile size (grid unit)
H = 3.0      # wall height
W = 0.3      # wall thickness
FLOOR_H = 0.2

MAT_WALL = {"name": "Stone_Wall", "baseColor": (0.52, 0.49, 0.45, 1.0), "roughness": 0.92, "metallic": 0.0}
MAT_FLOOR = {"name": "Stone_Floor", "baseColor": (0.40, 0.37, 0.34, 1.0), "roughness": 0.95, "metallic": 0.0}
MAT_TRIM = {"name": "Stone_Trim", "baseColor": (0.58, 0.52, 0.42, 1.0), "roughness": 0.85, "metallic": 0.0}


def save(name, parts):
    path = os.path.join(OUT, name + ".glb")
    export_glb(path, parts)
    size = os.path.getsize(path)
    print(f"{name:20s} {size/1024:8.1f} KB  tris={sum(len(p.indices)//3 for p in parts)}")


# ---------------------------------------------------------------- floor tile
def build_floor_tile():
    p = MeshPart("FloorTile", MAT_FLOOR)
    p.add_box(0, T, -FLOOR_H, 0, 0, T)
    return [p]


# ------------------------------------------------------------- straight wall
def build_wall_straight():
    p = MeshPart("WallStraight", MAT_WALL)
    p.add_box(0, T, 0, H, 0, W)
    return [p]


# ---------------------------------------------------------------- corner wall
def build_wall_corner():
    p = MeshPart("WallCorner", MAT_WALL)
    p.add_box(0, T, 0, H, 0, W)          # leg along X (at z=0 edge)
    p.add_box(0, W, 0, H, 0, T)          # leg along Z (at x=0 edge)
    return [p]


# ------------------------------------------------------------------ doorway
def build_doorway():
    p = MeshPart("Doorway", MAT_WALL)
    jamb = 0.4
    door_top = 2.4
    p.add_box(0, jamb, 0, H, 0, W)                 # left jamb
    p.add_box(T - jamb, T, 0, H, 0, W)              # right jamb
    p.add_box(0, T, door_top, H, 0, W)              # lintel
    trim = MeshPart("DoorwayTrim", MAT_TRIM)
    trim.add_box(jamb - 0.06, jamb, 0, door_top, 0, W + 0.03)          # left frame lip
    trim.add_box(T - jamb, T - jamb + 0.06, 0, door_top, 0, W + 0.03)  # right frame lip
    trim.add_box(0, T, door_top, door_top + 0.08, 0, W + 0.03)         # lintel lip
    return [p, trim]


# -------------------------------------------------------------- window wall
def build_window_wall():
    p = MeshPart("WindowWall", MAT_WALL)
    jamb = 0.4
    sill_top = 1.0
    head_bottom = 2.2
    p.add_box(0, T, 0, sill_top, 0, W)              # base under window
    p.add_box(0, T, head_bottom, H, 0, W)           # header above window
    p.add_box(0, jamb, sill_top, head_bottom, 0, W)         # left jamb
    p.add_box(T - jamb, T, sill_top, head_bottom, 0, W)     # right jamb
    trim = MeshPart("WindowSill", MAT_TRIM)
    trim.add_box(jamb - 0.05, T - jamb + 0.05, sill_top - 0.08, sill_top, 0, W + 0.05)
    return [p, trim]


# -------------------------------------------------------------------- pillar
def build_pillar():
    cx, cz = T / 2.0, T / 2.0
    shaft = MeshPart("PillarShaft", MAT_WALL)
    shaft.add_prism(cx, cz, 0.28, 0.15, H - 0.15, sides=8)
    trim = MeshPart("PillarCapBase", MAT_TRIM)
    trim.add_prism(cx, cz, 0.4, 0.0, 0.15, sides=8)       # base
    trim.add_prism(cx, cz, 0.4, H - 0.15, H, sides=8)     # capital
    return [shaft, trim]


# -------------------------------------------------------------------- stairs
def build_stairs(steps=8):
    p = MeshPart("Stairs", MAT_FLOOR)
    step_h = H / steps
    step_d = T / steps
    for i in range(steps):
        z0 = i * step_d
        y1 = (i + 1) * step_h
        p.add_box(0, T, 0, y1, z0, T)
    return [p]


# ---------------------------------------------------------------- broken wall
def build_wall_broken(seed=7):
    import random
    rnd = random.Random(seed)
    p = MeshPart("WallBroken", MAT_WALL)
    cols, rows = 5, 6
    cw, rh = T / cols, H / rows
    # hole roughly centered, irregular
    hole_cols = {2}
    hole_rows = {2, 3}
    for c in range(cols):
        for r in range(rows):
            if c in hole_cols and r in hole_rows:
                continue
            # crumble the top row randomly, and a couple random extra gaps
            if r == rows - 1 and rnd.random() < 0.45:
                continue
            if rnd.random() < 0.06:
                continue
            x0, x1 = c * cw, (c + 1) * cw
            y0, y1 = r * rh, (r + 1) * rh
            p.add_box(x0, x1, y0, y1, 0, W)
    return [p]


def main():
    save("floor_tile", build_floor_tile())
    save("wall_straight", build_wall_straight())
    save("wall_corner", build_wall_corner())
    save("doorway", build_doorway())
    save("window_wall", build_window_wall())
    save("pillar", build_pillar())
    save("stairs", build_stairs())
    save("wall_broken", build_wall_broken())

    # combined overview file: lay pieces out in a row along X with gaps
    from gltf_export import export_glb
    layout = [
        ("floor_tile", build_floor_tile()),
        ("wall_straight", build_wall_straight()),
        ("wall_corner", build_wall_corner()),
        ("doorway", build_doorway()),
        ("window_wall", build_window_wall()),
        ("pillar", build_pillar()),
        ("stairs", build_stairs()),
        ("wall_broken", build_wall_broken()),
    ]
    gap = 3.0
    all_parts = []
    for i, (name, parts) in enumerate(layout):
        offset = i * (T + gap)
        for part in parts:
            shifted = MeshPart(f"{name}_{part.name}", part.material)
            shifted.positions = [(x + offset, y, z) for x, y, z in part.positions]
            shifted.normals = part.normals
            shifted.indices = part.indices
            all_parts.append(shifted)
    export_glb(os.path.join(OUT, "kit_overview.glb"), all_parts)
    print("kit_overview.glb written")


if __name__ == "__main__":
    main()
