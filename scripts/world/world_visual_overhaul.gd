extends Node3D

const HARVESTABLE_SCRIPT = preload("res://scripts/world/harvestable.gd")
const VILLAGER_SCRIPT = preload("res://scripts/world/villager_npc.gd")
const NPC_MAGE = preload("res://assets/third_party/kaykit/adventurers/characters/Mage.glb")
const NPC_RANGER = preload("res://assets/third_party/kaykit/adventurers/characters/Ranger.glb")

@export var seed_value: int = 20260816
@export var grass_count: int = 1850
@export var tree_count: int = 44

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var materials: Dictionary = {}
var trunk_mesh: CylinderMesh
var crown_mesh: SphereMesh
var rock_mesh: SphereMesh

const COTTAGE_POSITIONS = [
    Vector3(-10.5, 0.0, -7.5),
    Vector3(10.8, 0.0, -10.0),
    Vector3(-9.0, 0.0, -23.0),
    Vector3(11.5, 0.0, -25.5)
]
const COTTAGE_YAWS = [18.0, -24.0, 13.0, -15.0]
const COTTAGE_PALETTES = [0, 1, 2, 0]

func _ready() -> void:
    rng.seed = seed_value
    _prepare_shared_meshes()
    _build_dirt_clearings()
    _build_grass_field()
    _build_forest()
    _build_cottages()
    _build_rocks_and_shrubs()
    _spawn_two_villagers()

func _prepare_shared_meshes() -> void:
    trunk_mesh = CylinderMesh.new()
    trunk_mesh.top_radius = 0.28
    trunk_mesh.bottom_radius = 0.43
    trunk_mesh.height = 3.4
    trunk_mesh.radial_segments = 9

    crown_mesh = SphereMesh.new()
    crown_mesh.radius = 1.1
    crown_mesh.height = 2.1
    crown_mesh.radial_segments = 9
    crown_mesh.rings = 6

    rock_mesh = SphereMesh.new()
    rock_mesh.radius = 0.62
    rock_mesh.height = 1.05
    rock_mesh.radial_segments = 8
    rock_mesh.rings = 5

func _material(key: String, color: Color, roughness: float = 0.92) -> StandardMaterial3D:
    if materials.has(key):
        return materials[key] as StandardMaterial3D
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = roughness
    materials[key] = mat
    return mat

func _emissive_material(key: String, color: Color, energy: float = 1.35) -> StandardMaterial3D:
    if materials.has(key):
        return materials[key] as StandardMaterial3D
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.55
    mat.emission_enabled = true
    mat.emission = color
    mat.emission_energy_multiplier = energy
    materials[key] = mat
    return mat

func _mesh(
    mesh: Mesh,
    material: Material,
    position: Vector3,
    parent: Node3D = null,
    scale_value: Vector3 = Vector3.ONE,
    rotation_value: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
    var instance := MeshInstance3D.new()
    instance.mesh = mesh
    instance.material_override = material
    instance.position = position
    instance.scale = scale_value
    instance.rotation = rotation_value
    instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    var target_parent: Node3D = self
    if parent != null:
        target_parent = parent
    target_parent.add_child(instance)
    return instance

func _build_grass_field() -> void:
    var grass_mesh: ArrayMesh = _make_grass_tuft_mesh()
    var multi_mesh := MultiMesh.new()
    multi_mesh.transform_format = MultiMesh.TRANSFORM_3D
    multi_mesh.use_colors = true
    multi_mesh.mesh = grass_mesh
    multi_mesh.instance_count = grass_count

    var placed: int = 0
    var attempts: int = 0
    while placed < grass_count and attempts < grass_count * 10:
        attempts += 1
        var x: float = rng.randf_range(-78.0, 78.0)
        var z: float = rng.randf_range(-78.0, 78.0)
        var p := Vector3(x, 0.035, z)
        if not _grass_allowed(p):
            continue
        var yaw: float = rng.randf_range(0.0, TAU)
        var width_scale: float = rng.randf_range(0.75, 1.35)
        var height_scale: float = rng.randf_range(0.65, 1.55)
        var basis := Basis(Vector3.UP, yaw)
        basis = basis.scaled(Vector3(width_scale, height_scale, width_scale))
        multi_mesh.set_instance_transform(placed, Transform3D(basis, p))
        var tint: float = rng.randf_range(-0.035, 0.055)
        multi_mesh.set_instance_color(placed, Color(0.22 + tint, 0.42 + tint, 0.16 + tint * 0.5, 1.0))
        placed += 1

    if placed < grass_count:
        multi_mesh.instance_count = placed

    var grass := MultiMeshInstance3D.new()
    grass.name = "GrassField"
    grass.multimesh = multi_mesh
    grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(grass)

func _make_grass_tuft_mesh() -> ArrayMesh:
    var vertices := PackedVector3Array()
    var colors := PackedColorArray()
    var indices := PackedInt32Array()
    var half_width: float = 0.085
    var height: float = 0.46

    for blade_index in range(3):
        var angle: float = float(blade_index) * PI / 3.0
        var right := Vector3(cos(angle), 0.0, sin(angle)) * half_width
        var base_index: int = vertices.size()
        vertices.append(-right)
        vertices.append(right)
        vertices.append(right * 0.28 + Vector3(0.0, height, 0.0))
        vertices.append(-right * 0.28 + Vector3(0.0, height, 0.0))
        colors.append(Color(0.20, 0.38, 0.14, 1.0))
        colors.append(Color(0.20, 0.38, 0.14, 1.0))
        colors.append(Color(0.34, 0.56, 0.21, 1.0))
        colors.append(Color(0.34, 0.56, 0.21, 1.0))
        indices.append_array(PackedInt32Array([
            base_index, base_index + 1, base_index + 2,
            base_index, base_index + 2, base_index + 3
        ]))

    var arrays: Array = []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = vertices
    arrays[Mesh.ARRAY_COLOR] = colors
    arrays[Mesh.ARRAY_INDEX] = indices

    var mesh := ArrayMesh.new()
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    var mat := StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 1.0
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mesh.surface_set_material(0, mat)
    return mesh

func _grass_allowed(p: Vector3) -> bool:
    if p.length() < 5.8:
        return false
    if p.distance_to(Vector3(15.0, 0.0, -12.0)) < 6.0:
        return false
    if absf(p.x) < 3.2 and p.z < 7.0 and p.z > -32.0:
        return false

    for index in range(COTTAGE_POSITIONS.size()):
        var cottage_position: Vector3 = COTTAGE_POSITIONS[index]
        if p.distance_to(cottage_position) < 5.3:
            return false
    return true

func _build_dirt_clearings() -> void:
    var dirt := _material("dirt", Color("#77613f"), 1.0)
    var dirt_dark := _material("dirt_dark", Color("#665238"), 1.0)
    _flat_patch(Vector3(0.0, 0.025, -10.5), Vector2(5.7, 10.5), dirt)
    _flat_patch(Vector3(-1.0, 0.027, 1.0), Vector2(5.4, 4.8), dirt_dark)
    _build_path(Vector3(0.0, 0.03, 5.0), Vector3(0.0, 0.03, -30.0), 18, dirt)
    _build_path(Vector3(0.0, 0.03, -9.0), Vector3(-10.0, 0.03, -7.5), 7, dirt_dark)
    _build_path(Vector3(0.0, 0.03, -12.0), Vector3(10.8, 0.03, -10.0), 7, dirt_dark)
    _build_path(Vector3(0.0, 0.03, -21.0), Vector3(-9.0, 0.03, -23.0), 7, dirt_dark)
    _build_path(Vector3(0.0, 0.03, -24.0), Vector3(11.5, 0.03, -25.5), 7, dirt_dark)

func _flat_patch(position: Vector3, size_value: Vector2, material: Material) -> void:
    var patch := CylinderMesh.new()
    patch.top_radius = 1.0
    patch.bottom_radius = 1.0
    patch.height = 0.035
    patch.radial_segments = 32
    _mesh(patch, material, position, self, Vector3(size_value.x, 1.0, size_value.y))

func _build_path(start: Vector3, finish: Vector3, pieces: int, material: Material) -> void:
    for i in range(pieces):
        var t: float = float(i) / float(maxi(1, pieces - 1))
        var p: Vector3 = start.lerp(finish, t)
        p.x += sin(float(i) * 1.61) * 0.23
        p.z += cos(float(i) * 1.19) * 0.18
        var patch := CylinderMesh.new()
        patch.top_radius = 0.72
        patch.bottom_radius = 0.78
        patch.height = 0.025
        patch.radial_segments = 10
        _mesh(
            patch,
            material,
            p,
            self,
            Vector3(rng.randf_range(0.95, 1.35), 1.0, rng.randf_range(0.72, 1.08)),
            Vector3(0.0, rng.randf_range(0.0, TAU), 0.0)
        )

func _build_forest() -> void:
    var centers: Array[Vector3] = [
        Vector3(-43.0, 0.0, 18.0),
        Vector3(42.0, 0.0, 20.0),
        Vector3(-49.0, 0.0, -18.0),
        Vector3(50.0, 0.0, -20.0),
        Vector3(-38.0, 0.0, -52.0),
        Vector3(37.0, 0.0, -54.0),
        Vector3(0.0, 0.0, -62.0)
    ]
    var per_cluster: int = maxi(4, int(tree_count / centers.size()))
    var spawned: int = 0

    for center in centers:
        for _i in range(per_cluster):
            if spawned >= tree_count:
                break
            var angle: float = rng.randf_range(0.0, TAU)
            var distance: float = rng.randf_range(2.0, 12.0)
            var p: Vector3 = center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
            _spawn_tree(p, rng.randf_range(1.05, 1.5), spawned % 3)
            spawned += 1

    while spawned < tree_count:
        var angle: float = rng.randf_range(0.0, TAU)
        var p := Vector3(cos(angle) * 59.0, 0.0, sin(angle) * 59.0)
        _spawn_tree(p, rng.randf_range(1.0, 1.45), spawned % 3)
        spawned += 1

func _spawn_tree(position: Vector3, scale_value: float, palette_index: int) -> void:
    var root := Area3D.new()
    root.name = "StylizedHarvestableTree"
    root.set_script(HARVESTABLE_SCRIPT)
    root.set("resource_id", "wood")
    root.set("required_tool", "axe")
    root.set("hits_required", 4)
    root.set("drop_amount", rng.randi_range(3, 6))
    root.position = position
    root.rotation.y = rng.randf_range(0.0, TAU)
    root.scale = Vector3.ONE * scale_value
    add_child(root)

    var bark := _material("tree_bark", Color("#64462f"))
    _mesh(trunk_mesh, bark, Vector3(0.0, 1.7, 0.0), root)

    var foliage_colors: Array[Color] = [
        Color("#3f7f42"),
        Color("#4f934b"),
        Color("#356d3d")
    ]
    var foliage := _material("foliage_%d" % palette_index, foliage_colors[palette_index])
    var crown_positions: Array[Vector3] = [
        Vector3(0.0, 3.55, 0.0),
        Vector3(0.85, 3.7, 0.12),
        Vector3(-0.82, 3.72, -0.08),
        Vector3(0.18, 4.3, 0.68),
        Vector3(-0.18, 4.25, -0.72)
    ]

    for i in range(crown_positions.size()):
        var scale_variation: float = 0.88 + float((i * 7 + palette_index) % 5) * 0.055
        _mesh(
            crown_mesh,
            foliage,
            crown_positions[i],
            root,
            Vector3(1.15 * scale_variation, 0.92 * scale_variation, 1.08 * scale_variation)
        )

    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.54
    shape.height = 4.0
    collision.shape = shape
    collision.position = Vector3(0.0, 2.0, 0.0)
    root.add_child(collision)

func _build_cottages() -> void:
    for index in range(COTTAGE_POSITIONS.size()):
        var cottage_position: Vector3 = COTTAGE_POSITIONS[index]
        var cottage_yaw: float = deg_to_rad(float(COTTAGE_YAWS[index]))
        var palette_index: int = int(COTTAGE_PALETTES[index])
        _build_cottage(cottage_position, cottage_yaw, palette_index)

func _build_cottage(position: Vector3, yaw: float, palette_index: int) -> void:
    var root := Node3D.new()
    root.name = "Cottage"
    root.position = position
    root.rotation.y = yaw
    add_child(root)

    var plaster_colors: Array[Color] = [
        Color("#d7c7a4"),
        Color("#c9d0b4"),
        Color("#d4b7a0")
    ]
    var roof_colors: Array[Color] = [
        Color("#364b55"),
        Color("#4a3c43"),
        Color("#48513b")
    ]
    var plaster := _material("plaster_%d" % palette_index, plaster_colors[palette_index])
    var timber := _material("timber", Color("#4b3528"))
    var roof_mat := _material("roof_%d" % palette_index, roof_colors[palette_index])
    var stone := _material("foundation", Color("#77776d"))
    var door_mat := _material("cottage_door", Color("#5f402a"))
    var window_mat := _emissive_material("cottage_window", Color("#d8e7cf"), 0.45)

    var foundation := BoxMesh.new()
    foundation.size = Vector3(6.4, 0.35, 4.9)
    _mesh(foundation, stone, Vector3(0.0, 0.18, 0.0), root)

    var body := BoxMesh.new()
    body.size = Vector3(5.9, 3.0, 4.35)
    _mesh(body, plaster, Vector3(0.0, 1.75, 0.0), root)

    var roof := PrismMesh.new()
    roof.size = Vector3(6.9, 2.3, 5.25)
    _mesh(roof, roof_mat, Vector3(0.0, 4.15, 0.0), root)

    var post := BoxMesh.new()
    post.size = Vector3(0.22, 3.15, 0.22)
    var post_positions: Array[Vector3] = [
        Vector3(-2.84, 1.78, 2.06),
        Vector3(2.84, 1.78, 2.06),
        Vector3(-2.84, 1.78, -2.06),
        Vector3(2.84, 1.78, -2.06)
    ]
    for post_position in post_positions:
        _mesh(post, timber, post_position, root)

    var front_beam := BoxMesh.new()
    front_beam.size = Vector3(5.9, 0.22, 0.22)
    _mesh(front_beam, timber, Vector3(0.0, 3.0, 2.08), root)
    _mesh(front_beam, timber, Vector3(0.0, 3.0, -2.08), root)

    var side_beam := BoxMesh.new()
    side_beam.size = Vector3(0.22, 0.22, 4.35)
    _mesh(side_beam, timber, Vector3(-2.84, 3.0, 0.0), root)
    _mesh(side_beam, timber, Vector3(2.84, 3.0, 0.0), root)

    var door := BoxMesh.new()
    door.size = Vector3(1.2, 2.35, 0.16)
    _mesh(door, door_mat, Vector3(0.0, 1.25, 2.24), root)

    var window := BoxMesh.new()
    window.size = Vector3(1.15, 1.05, 0.12)
    _mesh(window, window_mat, Vector3(-1.85, 1.8, 2.25), root)
    _mesh(window, window_mat, Vector3(1.85, 1.8, 2.25), root)

    var frame_v := BoxMesh.new()
    frame_v.size = Vector3(0.08, 1.12, 0.16)
    var frame_h := BoxMesh.new()
    frame_h.size = Vector3(1.22, 0.08, 0.16)
    var window_xs: Array[float] = [-1.85, 1.85]
    for window_x in window_xs:
        _mesh(frame_v, timber, Vector3(window_x, 1.8, 2.32), root)
        _mesh(frame_h, timber, Vector3(window_x, 1.8, 2.32), root)

    var porch := BoxMesh.new()
    porch.size = Vector3(2.45, 0.15, 1.15)
    _mesh(porch, timber, Vector3(0.0, 0.38, 2.72), root)

    var chimney := BoxMesh.new()
    chimney.size = Vector3(0.62, 2.0, 0.62)
    _mesh(chimney, stone, Vector3(2.0, 4.55, -0.6), root)

    var body_collision := StaticBody3D.new()
    body_collision.name = "CottageCollision"
    root.add_child(body_collision)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(6.0, 3.2, 4.5)
    collision.shape = shape
    collision.position = Vector3(0.0, 1.7, 0.0)
    body_collision.add_child(collision)

func _build_rocks_and_shrubs() -> void:
    var rock_mat := _material("natural_rock", Color("#717a72"))
    var shrub_mesh := SphereMesh.new()
    shrub_mesh.radius = 0.55
    shrub_mesh.height = 0.9
    shrub_mesh.radial_segments = 8
    shrub_mesh.rings = 5
    var shrub_mat := _material("shrub", Color("#477c3f"))

    for i in range(28):
        var angle: float = rng.randf_range(0.0, TAU)
        var distance: float = rng.randf_range(15.0, 70.0)
        var p := Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
        if i % 2 == 0:
            _mesh(
                rock_mesh,
                rock_mat,
                p + Vector3(0.0, 0.35, 0.0),
                self,
                Vector3(rng.randf_range(0.7, 1.5), rng.randf_range(0.5, 0.9), rng.randf_range(0.8, 1.45)),
                Vector3(rng.randf_range(-0.18, 0.18), rng.randf_range(0.0, TAU), rng.randf_range(-0.18, 0.18))
            )
        else:
            _mesh(
                shrub_mesh,
                shrub_mat,
                p + Vector3(0.0, 0.42, 0.0),
                self,
                Vector3(rng.randf_range(0.9, 1.5), rng.randf_range(0.7, 1.1), rng.randf_range(0.9, 1.5))
            )

func _spawn_two_villagers() -> void:
    _spawn_villager(
        NPC_MAGE,
        "Elena",
        "herborista",
        "El bosque está más vivo de lo que parece. Recoge solo lo que necesites.",
        Vector3(-3.3, 0.08, -8.0),
        2.8
    )
    _spawn_villager(
        NPC_RANGER,
        "Gael",
        "cazador",
        "Los árboles grandes dan buena madera. Lleva el hacha equipada.",
        Vector3(3.6, 0.08, -17.0),
        3.0
    )

func _spawn_villager(
    scene: PackedScene,
    display_name: String,
    role: String,
    greeting: String,
    position: Vector3,
    radius: float
) -> void:
    var npc := CharacterBody3D.new()
    npc.name = "NPC_%s" % display_name
    npc.set_script(VILLAGER_SCRIPT)
    npc.set("model_scene", scene)
    npc.set("npc_name", display_name)
    npc.set("role", role)
    npc.set("greeting", greeting)
    npc.set("wander_radius", radius)
    npc.position = position
    add_child(npc)
