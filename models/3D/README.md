# Modular Dungeon Kit (glTF / .glb)

A low-poly modular dungeon kit built on a **2m x 2m grid**, wall height **3m**,
wall thickness **0.3m**. Each piece has a basic stone material baked in (no
textures — just PBR base color/roughness) so it drops straight into Godot 4
looking reasonable, and can be re-textured later.

## Pieces

| File | Description |
|---|---|
| `floor_tile.glb` | 2x2m floor slab |
| `wall_straight.glb` | Straight wall segment, one tile edge |
| `wall_corner.glb` | L-shaped corner wall |
| `doorway.glb` | Wall with an open archway + trim |
| `window_wall.glb` | Wall with a window opening + sill |
| `pillar.glb` | Freestanding octagonal column w/ base + capital |
| `stairs.glb` | 8-step staircase, rises one full wall height (3m) over one tile |
| `wall_broken.glb` | Damaged/crumbling wall variant with a hole |
| `kit_overview.glb` | All pieces laid out in a row, for previewing the whole set at once |

`_preview.png` is a quick render of every piece for reference.

## Importing into Godot 4

1. Copy the `.glb` files into your project's `res://` folder (e.g. `res://models/dungeon/`).
2. Godot auto-imports `.glb` as a `PackedScene`. Drag each into your level scene, or instance via code (`load("res://models/dungeon/wall_straight.glb").instantiate()`).
3. **Grid snapping:** every piece's origin (0,0,0) is at a corner of its 2x2m footprint, sitting on the ground plane (Y=0 up). Place pieces at X/Z positions that are multiples of 2 and they'll line up edge-to-edge automatically. In the 3D editor, enable Snap (the magnet icon) and set the translate snap step to `2`.
4. **Corners & doorways:** `wall_corner.glb` and `wall_straight.glb` share the same footprint, so you can rotate `wall_corner` in 90° increments (Y-axis) to turn any tile corner. Same for `doorway` / `window_wall` — they're drop-in replacements for `wall_straight`.
5. **Stairs:** `stairs.glb` rises the full 3m wall height across one 2x2 tile — place it where you want to transition to a floor one level up.
6. **Collision:** these are visual meshes only (no collision shapes baked in). In Godot, select the imported scene in the FileSystem dock → Import tab → set **Root Type** or use "MeshInstance3D → Create Trimesh/Convex Collision Sibling" from the right-click menu after adding it to the scene, or wrap pieces in `StaticBody3D` + `CollisionShape3D` (box shapes matching the wall/floor dimensions are simplest and cheapest).
7. **Materials:** three simple stone materials are embedded (`Stone_Wall`, `Stone_Floor`, `Stone_Trim`). Godot will import them as `StandardMaterial3D`/`BaseMaterial3D` resources you can tweak or swap out for your own textures.

## Notes on how these were made

No 3D modeling software was available in this environment, so the kit was
generated with a small custom Python script (`build_kit.py` + `gltf_export.py`)
that builds the geometry from boxes/prisms and writes valid binary glTF
(.glb) directly — no external engine or library required. `verify_kit.py`
independently re-parses each `.glb` and checks index bounds, degenerate
triangles, and face winding/normals before shipping.

If you want variations (different tile size, taller walls, more pieces like
a T-junction or a ceiling piece), the script is easy to extend — just ask.
