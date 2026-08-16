extends Node3D

const PICKUP_SCRIPT = preload("res://scripts/world/resource_pickup.gd")
const HARVESTABLE_SCRIPT = preload("res://scripts/world/harvestable.gd")
const WILDLIFE_SCRIPT = preload("res://scripts/world/wildlife.gd")
const WATER_SOURCE_SCRIPT = preload("res://scripts/world/water_source.gd")

@export var seed_value := 10493
@export var world_radius := 68.0
@export var tree_count := 0
@export var rock_count := 0
@export var bush_count := 0
@export var flower_count := 28

var rng := RandomNumberGenerator.new()
var material_cache: Dictionary = {}

func _ready() -> void:
    rng.seed = seed_value
    _build_forest()
    _build_cabin(Vector3(-16.0, 0.0, -21.0))
    _build_water_source(Vector3(15.0, 0.02, -12.0))
    _spawn_resources()
    _spawn_wildlife()

func _build_forest() -> void:
    for i in range(tree_count):
        _make_tree(_random_ground_position(10.0), rng.randf_range(0.8, 1.45))
    for i in range(rock_count):
        _make_rock(_random_ground_position(6.0), rng.randf_range(0.65, 1.7))
    for i in range(bush_count):
        _make_bush(_random_ground_position(5.0), rng.randf_range(0.65, 1.25))
    for i in range(flower_count):
        _make_flower(_random_ground_position(4.0))

func _random_ground_position(clear_radius: float) -> Vector3:
    for _attempt in range(24):
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

func _make_mesh(mesh: Mesh, material: Material, position: Vector3, scale_value := Vector3.ONE, parent: Node3D = null) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.material_override = material
    instance.position = position
    instance.scale = scale_value
    var target_parent: Node3D = parent if parent != null else self
    target_parent.add_child(instance)
    return instance

func _make_tree(position: Vector3, scale_value: float) -> void:
    var root := Area3D.new()
    root.set_script(HARVESTABLE_SCRIPT)
    root.set("resource_id", "wood")
    root.set("required_tool", "axe")
    root.set("hits_required", 4)
    root.set("drop_amount", rng.randi_range(3, 6))
    root.position = position
    root.scale = Vector3.ONE * scale_value
    root.rotation.y = rng.randf_range(0.0, TAU)
    add_child(root)

    var trunk := CylinderMesh.new()
    trunk.top_radius = 0.24
    trunk.bottom_radius = 0.36
    trunk.height = 3.7
    trunk.radial_segments = 7
    _make_mesh(trunk, _material("bark", Color("#76513b")), Vector3(0, 1.85, 0), Vector3.ONE, root)

    var crown := CylinderMesh.new()
    crown.bottom_radius = 1.65
    crown.top_radius = 0.18
    crown.height = 3.7
    crown.radial_segments = 8
    _make_mesh(crown, _material("pine", Color("#3f7e4f")), Vector3(0, 4.35, 0), Vector3.ONE, root)

    var crown2 := CylinderMesh.new()
    crown2.bottom_radius = 1.3
    crown2.top_radius = 0.12
    crown2.height = 2.8
    crown2.radial_segments = 8
    _make_mesh(crown2, _material("pine_light", Color("#55965c")), Vector3(0, 5.65, 0), Vector3.ONE, root)

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.5
    shape.height = 4.1
    collision.shape = shape
    collision.position = Vector3(0, 2.0, 0)
    root.add_child(collision)

func _make_rock(position: Vector3, scale_value: float) -> void:
    var root := Area3D.new()
    root.set_script(HARVESTABLE_SCRIPT)
    root.set("resource_id", "stone")
    root.set("required_tool", "pickaxe")
    root.set("hits_required", 3)
    root.set("drop_amount", rng.randi_range(2, 5))
    root.position = position
    root.scale = Vector3.ONE * scale_value
    root.rotation = Vector3(rng.randf_range(-0.12, 0.12), rng.randf_range(0.0, TAU), rng.randf_range(-0.12, 0.12))
    add_child(root)

    var mesh := SphereMesh.new()
    mesh.radius = 0.55
    mesh.height = 1.1
    mesh.radial_segments = 7
    mesh.rings = 4
    _make_mesh(mesh, _material("rock", Color("#788178")), Vector3(0, 0.35, 0), Vector3(1.0, 0.65, 0.85), root)

    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 0.6
    collision.shape = shape
    collision.position = Vector3(0, 0.4, 0)
    root.add_child(collision)

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
    cabin.name = "ForestCabin"
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

    var collision_body := StaticBody3D.new()
    collision_body.name = "CabinCollision"
    cabin.add_child(collision_body)
    var collision := CollisionShape3D.new()
    var cabin_shape := BoxShape3D.new()
    cabin_shape.size = Vector3(7.5, 3.7, 5.5)
    collision.shape = cabin_shape
    collision.position = Vector3(0, 1.85, 0)
    collision_body.add_child(collision)

    var light := OmniLight3D.new()
    light.position = Vector3(2.2, 2.0, 3.3)
    light.light_color = Color("#ffad55")
    light.light_energy = 1.4
    light.omni_range = 8.0
    cabin.add_child(light)

func _build_water_source(position: Vector3) -> void:
    var source := Area3D.new()
    source.set_script(WATER_SOURCE_SCRIPT)
    source.position = position
    add_child(source)

    var water_mesh := CylinderMesh.new()
    water_mesh.top_radius = 4.1
    water_mesh.bottom_radius = 4.1
    water_mesh.height = 0.08
    water_mesh.radial_segments = 32
    var water_mat := StandardMaterial3D.new()
    water_mat.albedo_color = Color(0.24, 0.62, 0.78, 0.78)
    water_mat.metallic = 0.12
    water_mat.roughness = 0.22
    _make_mesh(water_mesh, water_mat, Vector3.ZERO, Vector3.ONE, source)

    var collision := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.radius = 4.1
    shape.height = 0.5
    collision.shape = shape
    source.add_child(collision)

    for i in range(20):
        var angle := TAU * float(i) / 20.0
        var rock_pos := Vector3(cos(angle) * 4.35, 0.18, sin(angle) * 4.35)
        var mesh := SphereMesh.new()
        mesh.radius = 0.34
        mesh.height = 0.55
        mesh.radial_segments = 7
        mesh.rings = 4
        _make_mesh(mesh, _material("pond_rock", Color("#717d73")), rock_pos, Vector3(1.0, 0.65, 0.9), source)

func _spawn_resources() -> void:
    for i in range(24):
        _create_pickup("wood", _random_ground_position(7.0), Color("#b77a44"), Vector3(0.22, 0.22, 0.8))
    for i in range(18):
        _create_pickup("stone", _random_ground_position(7.0), Color("#9da49f"), Vector3(0.42, 0.32, 0.48))
    for i in range(28):
        _create_pickup("fiber", _random_ground_position(7.0), Color("#82bd55"), Vector3(0.35, 0.52, 0.35))
    for i in range(22):
        _create_pickup("berry", _random_ground_position(7.0), Color("#c34b69"), Vector3(0.25, 0.25, 0.25))

func _spawn_wildlife() -> void:
    for i in range(4):
        _create_wildlife(false, _random_ground_position(18.0))
    for i in range(2):
        _create_wildlife(true, _random_ground_position(28.0))

func _create_wildlife(hostile: bool, position: Vector3) -> void:
    var animal := CharacterBody3D.new()
    animal.set_script(WILDLIFE_SCRIPT)
    animal.set("hostile", hostile)
    animal.set("move_speed", 3.0 if hostile else 2.4)
    animal.set("health", 5 if hostile else 3)
    animal.set("detect_radius", 12.0 if hostile else 10.0)
    animal.set("meat_drops", 3 if hostile else 2)
    animal.position = position + Vector3(0, 0.1, 0)
    add_child(animal)

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
