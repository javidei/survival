extends Node3D

const PICKUP_SCRIPT = preload("res://scripts/world/resource_pickup.gd")
const WILDLIFE_SCRIPT = preload("res://scripts/world/wildlife.gd")
const WATER_SOURCE_SCRIPT = preload("res://scripts/world/water_source.gd")

@export var seed_value := 10493
@export var world_radius := 68.0

var rng := RandomNumberGenerator.new()
var material_cache: Dictionary = {}

func _ready() -> void:
    rng.seed = seed_value
    _build_water_source(Vector3(15.0, 0.02, -12.0))
    _spawn_resources()
    _spawn_wildlife()

func _random_ground_position(clear_radius: float) -> Vector3:
    for _attempt in range(32):
        var angle := rng.randf_range(0.0, TAU)
        var distance := sqrt(rng.randf()) * world_radius
        var p := Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
        if p.length() > clear_radius and not _inside_village(p) and p.distance_to(Vector3(15.0, 0.0, -12.0)) > 6.0:
            return p
    return Vector3(clear_radius + 4.0, 0.0, 0.0)

func _inside_village(p: Vector3) -> bool:
    return absf(p.x) < 15.5 and p.z < 7.0 and p.z > -31.0

func _material(key: String, color: Color, roughness := 0.9) -> StandardMaterial3D:
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

func _build_water_source(position: Vector3) -> void:
    var source := Area3D.new()
    source.name = "ForestPond"
    source.set_script(WATER_SOURCE_SCRIPT)
    source.position = position
    add_child(source)

    var water_mesh := CylinderMesh.new()
    water_mesh.top_radius = 4.0
    water_mesh.bottom_radius = 4.0
    water_mesh.height = 0.07
    water_mesh.radial_segments = 36
    var water_mat := StandardMaterial3D.new()
    water_mat.albedo_color = Color(0.19, 0.51, 0.65, 0.88)
    water_mat.metallic = 0.08
    water_mat.roughness = 0.18
    _make_mesh(water_mesh, water_mat, Vector3.ZERO, Vector3.ONE, source)

    var collision := CollisionShape3D.new()
    var shape := CylinderShape3D.new()
    shape.radius = 4.0
    shape.height = 0.45
    collision.shape = shape
    source.add_child(collision)

    var stone_mesh := SphereMesh.new()
    stone_mesh.radius = 0.34
    stone_mesh.height = 0.55
    stone_mesh.radial_segments = 8
    stone_mesh.rings = 5
    var stone_mat := _material("pond_rock", Color("#6f7970"))
    for i in range(18):
        var angle := TAU * float(i) / 18.0
        var radius := 4.18 + 0.14 * sin(float(i) * 1.7)
        var rock_pos := Vector3(cos(angle) * radius, 0.18, sin(angle) * radius)
        _make_mesh(stone_mesh, stone_mat, rock_pos, Vector3(1.0, 0.62, 0.88), source)

func _spawn_resources() -> void:
    for _i in range(10):
        _create_pickup("wood", _random_ground_position(12.0), Color("#9b693f"), Vector3(0.22, 0.22, 0.72))
    for _i in range(8):
        _create_pickup("stone", _random_ground_position(12.0), Color("#8d9690"), Vector3(0.38, 0.30, 0.44))
    for _i in range(12):
        _create_pickup("fiber", _random_ground_position(11.0), Color("#6fa14f"), Vector3(0.28, 0.42, 0.28))
    for _i in range(8):
        _create_pickup("berry", _random_ground_position(11.0), Color("#a94059"), Vector3(0.21, 0.21, 0.21))

func _spawn_wildlife() -> void:
    for _i in range(2):
        _create_wildlife(false, _random_ground_position(22.0))
    _create_wildlife(true, _random_ground_position(32.0))

func _create_wildlife(hostile: bool, position: Vector3) -> void:
    var animal := CharacterBody3D.new()
    animal.set_script(WILDLIFE_SCRIPT)
    animal.set("hostile", hostile)
    animal.set("move_speed", 3.0 if hostile else 2.4)
    animal.set("health", 5 if hostile else 3)
    animal.set("detect_radius", 12.0 if hostile else 10.0)
    animal.set("meat_drops", 3 if hostile else 2)
    animal.position = position + Vector3(0.0, 0.1, 0.0)
    add_child(animal)

func _create_pickup(resource_id: String, position: Vector3, color: Color, scale_value: Vector3) -> void:
    var area := Area3D.new()
    area.name = "Pickup_%s" % resource_id
    area.set_script(PICKUP_SCRIPT)
    area.collision_layer = 2
    area.collision_mask = 0
    area.set("resource_id", resource_id)
    area.position = position + Vector3(0.0, 0.22, 0.0)
    add_child(area)

    var mesh_instance := MeshInstance3D.new()
    var mesh: PrimitiveMesh
    if resource_id == "wood":
        var wood_mesh := CylinderMesh.new()
        wood_mesh.top_radius = 0.16
        wood_mesh.bottom_radius = 0.18
        wood_mesh.height = 0.95
        wood_mesh.radial_segments = 8
        mesh = wood_mesh
        mesh_instance.rotation.z = deg_to_rad(82.0)
    else:
        var sphere_mesh := SphereMesh.new()
        sphere_mesh.radius = 0.36
        sphere_mesh.height = 0.72
        sphere_mesh.radial_segments = 8
        sphere_mesh.rings = 5
        mesh = sphere_mesh
    mesh_instance.mesh = mesh
    mesh_instance.scale = scale_value
    mesh_instance.material_override = _material("pickup_%s" % resource_id, color)
    area.add_child(mesh_instance)

    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 0.42
    collision.shape = shape
    area.add_child(collision)
