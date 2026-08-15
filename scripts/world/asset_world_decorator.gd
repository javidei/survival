extends Node3D

const KENNEY_TREE_SCENES = [
    preload("res://assets/third_party/kenney/fantasy_town/models/tree.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/tree-high.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/tree-crooked.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/tree-high-round.glb")
]
const KENNEY_ROCK_SCENES = [
    preload("res://assets/third_party/kenney/fantasy_town/models/rock-small.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/rock-large.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/rock-wide.glb")
]
const KENNEY_ROAD = preload("res://assets/third_party/kenney/fantasy_town/models/road.glb")
const KENNEY_FENCE = preload("res://assets/third_party/kenney/fantasy_town/models/fence.glb")
const KENNEY_FENCE_GATE = preload("res://assets/third_party/kenney/fantasy_town/models/fence-gate.glb")
const KENNEY_LANTERN = preload("res://assets/third_party/kenney/fantasy_town/models/lantern.glb")
const KENNEY_CART = preload("res://assets/third_party/kenney/fantasy_town/models/cart.glb")
const KENNEY_WINDMILL = preload("res://assets/third_party/kenney/fantasy_town/models/windmill.glb")
const QUATERNIUS_FLOOR = preload("res://assets/third_party/quaternius/medieval_village/models/Floor_UnevenBrick.gltf")

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 20260816
    call_deferred("_apply_asset_pass")

func _apply_asset_pass() -> void:
    _replace_harvestable_visuals()
    _build_prefab_route()
    _build_prefab_floor_patch()
    _build_prefab_props()
    _build_landmark()

func _replace_harvestable_visuals() -> void:
    var world_builder := get_node_or_null("../WorldBuilder")
    if world_builder == null:
        return

    for child in world_builder.get_children():
        if not (child is Area3D):
            continue
        if not child.has_method("harvest"):
            continue

        var resource_id := str(child.get("resource_id"))
        if resource_id == "wood":
            var scene: PackedScene = KENNEY_TREE_SCENES[rng.randi_range(0, KENNEY_TREE_SCENES.size() - 1)]
            _replace_visual(child, scene, Vector3.ONE * 1.55)
        elif resource_id == "stone":
            var scene: PackedScene = KENNEY_ROCK_SCENES[rng.randi_range(0, KENNEY_ROCK_SCENES.size() - 1)]
            _replace_visual(child, scene, Vector3.ONE * 1.15)

func _replace_visual(root: Node3D, scene: PackedScene, local_scale: Vector3) -> void:
    for child in root.get_children():
        if child is MeshInstance3D:
            child.visible = false

    var visual := scene.instantiate() as Node3D
    if visual == null:
        return
    visual.name = "AssetVisual"
    visual.scale = local_scale
    root.add_child(visual)

func _spawn_asset(scene: PackedScene, position: Vector3, yaw := 0.0, scale_value := Vector3.ONE, parent: Node3D = null) -> Node3D:
    var instance := scene.instantiate() as Node3D
    if instance == null:
        return null
    var target_parent: Node3D = parent if parent != null else self
    target_parent.add_child(instance)
    instance.position = position
    instance.rotation.y = yaw
    instance.scale = scale_value
    return instance

func _build_prefab_route() -> void:
    var start := Vector3(0.0, 0.035, -1.5)
    var finish := Vector3(-9.0, 0.035, -11.5)
    var direction := finish - start
    var yaw := atan2(direction.x, direction.z)
    var segment_count := 8

    for i in range(segment_count):
        var t := float(i) / float(segment_count - 1)
        var point := start.lerp(finish, t)
        _spawn_asset(KENNEY_ROAD, point, yaw, Vector3(1.15, 1.0, 1.15))

func _build_prefab_floor_patch() -> void:
    var origin := Vector3(3.7, 0.025, 1.2)
    var spacing := 2.0
    for x in range(2):
        for z in range(2):
            var point := origin + Vector3(float(x) * spacing, 0.0, float(z) * spacing)
            _spawn_asset(QUATERNIUS_FLOOR, point, 0.0, Vector3.ONE)

func _build_prefab_props() -> void:
    for i in range(4):
        _spawn_asset(
            KENNEY_FENCE,
            Vector3(4.8 + float(i) * 2.0, 0.0, 3.65),
            0.0,
            Vector3.ONE
        )
    _spawn_asset(KENNEY_FENCE_GATE, Vector3(12.8, 0.0, 3.65), 0.0, Vector3.ONE)

    _spawn_asset(KENNEY_CART, Vector3(-6.2, 0.0, -7.2), deg_to_rad(24.0), Vector3.ONE)
    _spawn_lantern(Vector3(-3.7, 0.0, -4.7))
    _spawn_lantern(Vector3(-7.5, 0.0, -9.2))

func _spawn_lantern(position: Vector3) -> void:
    _spawn_asset(KENNEY_LANTERN, position, 0.0, Vector3.ONE)
    var light := OmniLight3D.new()
    light.position = position + Vector3(0.0, 1.8, 0.0)
    light.light_color = Color("#ffc06a")
    light.light_energy = 0.9
    light.omni_range = 5.0
    add_child(light)

func _build_landmark() -> void:
    _spawn_asset(
        KENNEY_WINDMILL,
        Vector3(27.0, 0.0, -29.0),
        deg_to_rad(-28.0),
        Vector3.ONE * 1.35
    )
