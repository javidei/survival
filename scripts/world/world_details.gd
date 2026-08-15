extends Node3D

const CAMPFIRE_SCRIPT = preload("res://scripts/world/campfire.gd")

var material_cache: Dictionary = {}

func _ready() -> void:
    _build_spawn_ground()
    _build_starter_campfire(Vector3(-2.2, 0.08, 1.0))
    _build_small_shelter(Vector3(-8.0, 0.0, -9.5))
    _build_path(Vector3(0.0, 0.03, -1.5), Vector3(-9.0, 0.03, -11.5))
    _build_fence()
    _build_prop_clusters()
    _build_lantern(Vector3(-5.4, 0.0, -5.6))
    _build_lantern(Vector3(-9.4, 0.0, -10.4))

func _material(key: String, color: Color, roughness := 0.9) -> StandardMaterial3D:
    if material_cache.has(key):
        return material_cache[key]
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = roughness
    material_cache[key] = mat
    return mat

func _emissive_material(key: String, color: Color, energy := 2.8) -> StandardMaterial3D:
    if material_cache.has(key):
        return material_cache[key]
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = energy
    mat.roughness = 0.55
    material_cache[key] = mat
    return mat

func _mesh(mesh: Mesh, material: Material, position: Vector3, scale_value := Vector3.ONE, rotation_value := Vector3.ZERO, parent: Node3D = null) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.material_override = material
    instance.position = position
    instance.scale = scale_value
    instance.rotation = rotation_value
    var target_parent: Node3D = parent if parent != null else self
    target_parent.add_child(instance)
    return instance

func _build_spawn_ground() -> void:
    var clearing := CylinderMesh.new()
    clearing.top_radius = 5.4
    clearing.bottom_radius = 5.4
    clearing.height = 0.035
    clearing.radial_segments = 28
    _mesh(clearing, _material("clearing", Color("#6e6845")), Vector3(-1.0, 0.015, 1.0))

    var grass_patch := CylinderMesh.new()
    grass_patch.top_radius = 2.2
    grass_patch.bottom_radius = 2.2
    grass_patch.height = 0.028
    grass_patch.radial_segments = 22
    _mesh(grass_patch, _material("grass_patch", Color("#456f3b")), Vector3(3.2, 0.02, -1.8), Vector3(1.4, 1.0, 0.72))

func _build_starter_campfire(position: Vector3) -> void:
    var fire := Area3D.new()
    fire.set_script(CAMPFIRE_SCRIPT)
    fire.position = position
    add_child(fire)

    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 1.15
    collision.shape = shape
    collision.position = Vector3(0, 0.35, 0)
    fire.add_child(collision)

    var stone_mesh := SphereMesh.new()
    stone_mesh.radius = 0.21
    stone_mesh.height = 0.32
    stone_mesh.radial_segments = 7
    stone_mesh.rings = 4
    for i in range(12):
        var angle := TAU * float(i) / 12.0
        var p := Vector3(cos(angle) * 0.72, 0.16, sin(angle) * 0.72)
        _mesh(stone_mesh, _material("fire_stone", Color("#77766d")), p, Vector3(1.0, 0.65, 0.9), Vector3.ZERO, fire)

    var log_mesh := CylinderMesh.new()
    log_mesh.top_radius = 0.11
    log_mesh.bottom_radius = 0.14
    log_mesh.height = 1.2
    log_mesh.radial_segments = 7
    var log_mat := _material("fire_log", Color("#5a3827"))
    _mesh(log_mesh, log_mat, Vector3(0, 0.19, 0), Vector3.ONE, Vector3(0, 0, deg_to_rad(90)), fire).rotation.y = deg_to_rad(45)
    _mesh(log_mesh, log_mat, Vector3(0, 0.19, 0), Vector3.ONE, Vector3(0, 0, deg_to_rad(90)), fire).rotation.y = deg_to_rad(-45)

    var flame_outer := SphereMesh.new()
    flame_outer.radius = 0.32
    flame_outer.height = 0.82
    flame_outer.radial_segments = 8
    flame_outer.rings = 5
    _mesh(flame_outer, _emissive_material("flame_outer", Color("#ff7a32"), 3.2), Vector3(0, 0.52, 0), Vector3(0.9, 1.3, 0.9), Vector3.ZERO, fire)

    var flame_inner := SphereMesh.new()
    flame_inner.radius = 0.18
    flame_inner.height = 0.48
    flame_inner.radial_segments = 8
    flame_inner.rings = 5
    _mesh(flame_inner, _emissive_material("flame_inner", Color("#ffd36a"), 4.0), Vector3(0, 0.58, -0.04), Vector3(0.9, 1.15, 0.9), Vector3.ZERO, fire)

    var light := OmniLight3D.new()
    light.position = Vector3(0, 1.0, 0)
    light.light_color = Color("#ff9f4a")
    light.light_energy = 2.35
    light.omni_range = 10.0
    light.shadow_enabled = true
    fire.add_child(light)

    _build_log_seat(position + Vector3(0.0, 0.0, 2.0), 0.0)
    _build_log_seat(position + Vector3(0.0, 0.0, -2.0), 0.0)
    _build_log_seat(position + Vector3(2.1, 0.0, 0.0), 90.0)

func _build_log_seat(position: Vector3, yaw_degrees: float) -> void:
    var log := CylinderMesh.new()
    log.top_radius = 0.28
    log.bottom_radius = 0.34
    log.height = 2.0
    log.radial_segments = 8
    var seat := _mesh(log, _material("seat_log", Color("#68452f")), position + Vector3(0, 0.33, 0), Vector3.ONE, Vector3(0, 0, deg_to_rad(90)))
    seat.rotation.y = deg_to_rad(yaw_degrees)

func _build_small_shelter(position: Vector3) -> void:
    var root := Node3D.new()
    root.position = position
    root.rotation.y = deg_to_rad(-18.0)
    add_child(root)

    var wood := _material("shelter_wood", Color("#70503a"))
    var dark_wood := _material("shelter_dark", Color("#3e3028"))
    var roof_mat := _material("shelter_roof", Color("#344037"))

    var floor_mesh := BoxMesh.new()
    floor_mesh.size = Vector3(4.5, 0.22, 3.3)
    _mesh(floor_mesh, wood, Vector3(0, 0.18, 0), Vector3.ONE, Vector3.ZERO, root)

    var post_mesh := BoxMesh.new()
    post_mesh.size = Vector3(0.22, 2.6, 0.22)
    for p in [Vector3(-2.0, 1.45, -1.35), Vector3(2.0, 1.45, -1.35), Vector3(-2.0, 1.45, 1.35), Vector3(2.0, 1.45, 1.35)]:
        _mesh(post_mesh, dark_wood, p, Vector3.ONE, Vector3.ZERO, root)

    var back := BoxMesh.new()
    back.size = Vector3(4.2, 2.2, 0.18)
    _mesh(back, wood, Vector3(0, 1.35, 1.4), Vector3.ONE, Vector3.ZERO, root)

    var roof := BoxMesh.new()
    roof.size = Vector3(5.0, 0.2, 4.2)
    _mesh(roof, roof_mat, Vector3(0, 2.8, 0), Vector3.ONE, Vector3(deg_to_rad(-8), 0, 0), root)

    var crate := BoxMesh.new()
    crate.size = Vector3(1.0, 0.8, 1.0)
    _mesh(crate, _material("crate", Color("#8a623d")), Vector3(-1.25, 0.62, 0.35), Vector3.ONE, Vector3.ZERO, root)
    _mesh(crate, _material("crate_dark", Color("#745034")), Vector3(-0.15, 0.52, 0.7), Vector3(0.8, 0.8, 0.8), Vector3.ZERO, root)

    var bed := BoxMesh.new()
    bed.size = Vector3(1.5, 0.28, 2.2)
    _mesh(bed, _material("bed", Color("#596d58")), Vector3(1.2, 0.48, 0.55), Vector3.ONE, Vector3.ZERO, root)

func _build_path(start: Vector3, end: Vector3) -> void:
    var stone := CylinderMesh.new()
    stone.top_radius = 0.55
    stone.bottom_radius = 0.6
    stone.height = 0.045
    stone.radial_segments = 8
    var mat := _material("path_stone", Color("#85857a"))
    var count := 15
    for i in range(count):
        var t := float(i) / float(count - 1)
        var p := start.lerp(end, t)
        p.x += sin(float(i) * 1.7) * 0.22
        p.z += cos(float(i) * 1.2) * 0.16
        var piece := _mesh(stone, mat, p, Vector3(1.0 + 0.18 * sin(i), 1.0, 0.75 + 0.12 * cos(i)))
        piece.rotation.y = float(i) * 0.43

func _build_fence() -> void:
    var post_mesh := BoxMesh.new()
    post_mesh.size = Vector3(0.18, 1.4, 0.18)
    var rail_mesh := BoxMesh.new()
    rail_mesh.size = Vector3(2.2, 0.16, 0.16)
    var mat := _material("fence", Color("#6d4b33"))
    var base := Vector3(4.7, 0.0, 3.6)
    for i in range(5):
        var post_pos := base + Vector3(float(i) * 2.0, 0.72, 0)
        _mesh(post_mesh, mat, post_pos)
        if i < 4:
            var rail_pos := base + Vector3(float(i) * 2.0 + 1.0, 0.9, 0)
            _mesh(rail_mesh, mat, rail_pos)
            _mesh(rail_mesh, mat, rail_pos + Vector3(0, -0.48, 0))

func _build_prop_clusters() -> void:
    var stump := CylinderMesh.new()
    stump.top_radius = 0.38
    stump.bottom_radius = 0.46
    stump.height = 0.72
    stump.radial_segments = 8
    var stump_mat := _material("stump", Color("#755034"))
    for p in [Vector3(3.1, 0.36, 2.3), Vector3(-4.5, 0.36, 3.8), Vector3(4.8, 0.36, -3.0)]:
        _mesh(stump, stump_mat, p)

    var bush := SphereMesh.new()
    bush.radius = 0.48
    bush.height = 0.86
    bush.radial_segments = 7
    bush.rings = 4
    var bush_mat := _material("detail_bush", Color("#5f9149"))
    for p in [Vector3(4.4, 0.4, 1.2), Vector3(-4.2, 0.4, -1.8), Vector3(2.8, 0.4, -4.0), Vector3(-5.4, 0.4, 0.5), Vector3(5.7, 0.4, -1.4)]:
        _mesh(bush, bush_mat, p, Vector3(1.25, 0.8, 1.0))

    var flower_stem := CylinderMesh.new()
    flower_stem.top_radius = 0.025
    flower_stem.bottom_radius = 0.03
    flower_stem.height = 0.32
    flower_stem.radial_segments = 5
    var bloom := SphereMesh.new()
    bloom.radius = 0.09
    bloom.height = 0.17
    bloom.radial_segments = 6
    bloom.rings = 3
    var flower_positions := [
        Vector3(2.1, 0, 3.7), Vector3(2.5, 0, 3.4), Vector3(2.9, 0, 3.9),
        Vector3(-3.7, 0, -3.0), Vector3(-4.1, 0, -3.3), Vector3(-3.4, 0, -3.6)
    ]
    var colors := [Color("#ffd55f"), Color("#ff8ca0"), Color("#b394ff")]
    for i in range(flower_positions.size()):
        var p: Vector3 = flower_positions[i]
        _mesh(flower_stem, _material("detail_stem", Color("#517d43")), p + Vector3(0, 0.16, 0))
        _mesh(bloom, _material("detail_flower_%d" % (i % colors.size()), colors[i % colors.size()]), p + Vector3(0, 0.35, 0))

    _build_woodpile(Vector3(-4.0, 0.0, 2.1))
    _build_sign(Vector3(1.8, 0.0, -4.8))

func _build_woodpile(position: Vector3) -> void:
    var log := CylinderMesh.new()
    log.top_radius = 0.1
    log.bottom_radius = 0.12
    log.height = 1.15
    log.radial_segments = 7
    var mat := _material("woodpile", Color("#7b4d2d"))
    for row in range(2):
        for col in range(3):
            var p := position + Vector3(float(col) * 0.28, 0.14 + float(row) * 0.22, 0)
            var piece := _mesh(log, mat, p, Vector3.ONE, Vector3(0, 0, deg_to_rad(90)))
            piece.rotation.y = deg_to_rad(90)

func _build_sign(position: Vector3) -> void:
    var post := BoxMesh.new()
    post.size = Vector3(0.16, 1.7, 0.16)
    var board := BoxMesh.new()
    board.size = Vector3(1.65, 0.58, 0.14)
    var mat := _material("sign", Color("#715039"))
    _mesh(post, mat, position + Vector3(0, 0.85, 0))
    var board_instance := _mesh(board, mat, position + Vector3(0, 1.38, 0))
    board_instance.rotation.y = deg_to_rad(-15.0)

func _build_lantern(position: Vector3) -> void:
    var post := CylinderMesh.new()
    post.top_radius = 0.06
    post.bottom_radius = 0.08
    post.height = 2.2
    post.radial_segments = 7
    _mesh(post, _material("lantern_post", Color("#40372e")), position + Vector3(0, 1.1, 0))

    var lamp := SphereMesh.new()
    lamp.radius = 0.17
    lamp.height = 0.3
    lamp.radial_segments = 8
    lamp.rings = 4
    _mesh(lamp, _emissive_material("lantern_glow", Color("#ffc66b"), 3.4), position + Vector3(0, 2.05, 0))

    var light := OmniLight3D.new()
    light.position = position + Vector3(0, 2.0, 0)
    light.light_color = Color("#ffbe65")
    light.light_energy = 1.0
    light.omni_range = 5.5
    add_child(light)
