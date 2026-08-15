extends Node3D

const PICKUP_SCRIPT = preload("res://scripts/world/resource_pickup.gd")

@export var seed_value := 10493
@export var world_radius := 58.0
@export var tree_count := 115
@export var rock_count := 46
@export var bush_count := 70
@export var flower_count := 55

var rng := RandomNumberGenerator.new()
var material_cache: Dictionary = {}

func _ready() -> void:
    rng.seed = seed_value
    _build_forest()
    _build_cabin(Vector3(-16.0, 0.0, -21.0))
    _spawn_resources()

func _build_forest() -> void:
    for i in range(tree_count):
        var p := _random_ground_position(10.0)
        _make_tree(p, rng.randf_range(0.8, 1.45))
    for i in range(rock_count):
        _make_rock(_random_ground_position(6.0), rng.randf_range(0.65, 1.7))
    for i in range(bush_count):
        _make_bush(_random_ground_position(5.0), rng.randf_range(0.65, 1.25))
    for i in range(flower_count):
        _make_flower(_random_ground_position(4.0))

func _random_ground_position(clear_radius: float) -> Vector3:
    for _attempt in range(20):
        var angle := rng.randf_range(0.0, TAU)
        var distance := sqrt(rng.randf()) * world_radius
        var p := Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
        if p.length() > clear_radius:
            return p
    return Vector3(clear_radius + 2.0, 0.0, 0.0)

func _material(key: String, color: Color, roughness := 0.85) -> StandardMaterial3D:
    if material_cache.has(key):
        return material_cache[key]
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = roughness
    material_cache[key] = mat
    return mat

func _make_mesh(mesh: Mesh, material: Material, position: Vector3, scale_value := Vector3.ONE, parent: Node3D = self) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.material_override = material
    instance.position = position
    instance.scale = scale_value
    parent.add_child(instance)
    return instance

func _make_tree(position: Vector3, scale_value: float) -> void:
    var root := Node3D.new()
    root.position = position
    root.rotation.y = rng.randf_range(0.0, TAU)
    add_child(root)

    var trunk := CylinderMesh.new()
    trunk.top_radius = 0.24
    trunk.bottom_radius = 0.36
    trunk.height = 3.7
    trunk.radial_segments = 7
    _make_mesh(trunk, _material("bark", Color("#76513b")), Vector3(0, 1.85, 0), Vector3.ONE * scale_value, root)

    var crown := ConeMesh.new()
    crown.bottom_radius = 1.65
    crown.top_radius = 0.18
    crown.height = 3.7
    crown.radial_segments = 8
    _make_mesh(crown, _material("pine", Color("#3f7e4f")), Vector3(0, 4.35, 0), Vector3.ONE * scale_value, root)

    var crown2 := ConeMesh.new()
    crown2.bottom_radius = 1.3
    crown2.top_radius = 0.12
    crown2.height = 2.8
    crown2.radial_segments = 8
    _make_mesh(crown2, _material("pine_light", Color("#55965c")), Vector3(0, 5.65, 0), Vector3.ONE * scale_value, root)

func _make_rock(position: Vector3, scale_value: float) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = 0.55
    mesh.height = 1.1
    mesh.radial_segments = 7
    mesh.rings = 4
    var rock := _make_mesh(mesh, _material("rock", Color("#788178")), position + Vector3(0, 0.35, 0), Vector3(scale_value, scale_value * 0.65, scale_value * 0.85))
    rock.rotation = Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(0.0, TAU), rng.randf_range(-0.18, 0.18))

func _make_bush(position: Vector3, scale_value: float) -> void:
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 7
    mesh.rings = 4
    _make_mesh(mesh, _material("bush", Color("#66a452")), position + Vector3(0, 0.45, 0), Vector3(scale_value, scale_value * 0.75, scale_value))

func _make_flower(position: Vector3) -> void:
    var stem := CylinderMesh.new()
    stem.top_radius = 0.025
    stem.bottom_radius = 0.035
    stem.height = 0.35
    stem.radial_segments = 5
    _make_mesh(stem, _material("stem", Color("#5d934e")), position + Vector3(0, 0.18, 0))
    var bloom := SphereMesh.new()
    bloom.radius = 0.09
    bloom.height = 0.18
    bloom.radial_segments = 6
    bloom.rings = 3
    var palette := [Color("#ffd45c"), Color("#ff8a8a"), Color("#a98bff"), Color("#f5f4e9")]
    var palette_index := rng.randi_range(0, palette.size() - 1)
    _make_mesh(bloom, _material("flower_%s" % str(palette_index), palette[palette_index]), position + Vector3(0, 0.39, 0))

func _build_cabin(position: Vector3) -> void:
    var cabin := Node3D.new()
    cabin.position = position
    cabin.rotation.y = deg_to_rad(28.0)
    add_child(cabin)

    var wall_mat := _material("cabin_wall", Color("#59483c"))
    var roof_mat := _material("cabin_roof", Color("#27323a"))
    var glow_mat := StandardMaterial3D.new()
    glow_mat.albedo_color = Color("#ffb85c")
    glow_mat.emission_enabled = true
    glow_mat.emission = Color("#ff8a32")
    glow_mat.emission_energy_multiplier = 2.4

    var body := BoxMesh.new()
    body.size = Vector3(7.5, 3.7, 5.5)
    _make_mesh(body, wall_mat, Vector3(0, 1.85, 0), Vector3.ONE, cabin)

    var roof := PrismMesh.new()
    roof.size = Vector3(8.4, 2.6, 6.3)
    _make_mesh(roof, roof_mat, Vector3(0, 4.45, 0), Vector3.ONE, cabin)

    var door := BoxMesh.new()
    door.size = Vector3(1.25, 2.45, 0.15)
    _make_mesh(door, _material("door", Color("#2f2722")), Vector3(0.0, 1.25, 2.82), Vector3.ONE, cabin)

    var window := BoxMesh.new()
    window.size = Vector3(1.4, 1.15, 0.12)
    _make_mesh(window, glow_mat, Vector3(2.2, 2.15, 2.84), Vector3.ONE, cabin)

    var light := OmniLight3D.new()
    light.position = Vector3(2.2, 2.0, 3.3)
    light.light_color = Color("#ffad55")
    light.light_energy = 1.4
    light.omni_range = 8.0
    cabin.add_child(light)

func _spawn_resources() -> void:
    for i in range(24):
        _create_pickup("wood", _random_ground_position(7.0), Color("#b77a44"), Vector3(0.22, 0.22, 0.8))
    for i in range(16):
        _create_pickup("stone", _random_ground_position(7.0), Color("#9da49f"), Vector3(0.42, 0.32, 0.48))
    for i in range(20):
        _create_pickup("fiber", _random_ground_position(7.0), Color("#82bd55"), Vector3(0.35, 0.52, 0.35))

func _create_pickup(resource_id: String, position: Vector3, color: Color, scale_value: Vector3) -> void:
    var area := Area3D.new()
    area.set_script(PICKUP_SCRIPT)
    area.collision_layer = 2
    area.collision_mask = 0
    area.set("resource_id", resource_id)
    area.position = position + Vector3(0, 0.34, 0)
    add_child(area)

    var mesh_instance := MeshInstance3D.new()
    var mesh: PrimitiveMesh
    if resource_id == "wood":
        var wood_mesh := CylinderMesh.new()
        wood_mesh.top_radius = 0.18
        wood_mesh.bottom_radius = 0.2
        wood_mesh.height = 1.15
        wood_mesh.radial_segments = 7
        mesh = wood_mesh
        mesh_instance.rotation.z = deg_to_rad(78.0)
    else:
        var sphere_mesh := SphereMesh.new()
        sphere_mesh.radius = 0.45
        sphere_mesh.height = 0.9
        sphere_mesh.radial_segments = 7
        sphere_mesh.rings = 4
        mesh = sphere_mesh
    mesh_instance.mesh = mesh
    mesh_instance.scale = scale_value
    mesh_instance.material_override = _material("pickup_%s" % resource_id, color)
    area.add_child(mesh_instance)

    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 0.55
    collision.shape = shape
    area.add_child(collision)
