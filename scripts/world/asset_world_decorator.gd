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
const KENNEY_WATERMILL = preload("res://assets/third_party/kenney/fantasy_town/models/watermill.glb")
const KENNEY_WALL = preload("res://assets/third_party/kenney/fantasy_town/models/wall-wood.glb")
const KENNEY_WALL_DOOR = preload("res://assets/third_party/kenney/fantasy_town/models/wall-wood-door.glb")
const KENNEY_WALL_WINDOW = preload("res://assets/third_party/kenney/fantasy_town/models/wall-wood-window-glass.glb")
const KENNEY_ROOF_GABLE = preload("res://assets/third_party/kenney/fantasy_town/models/roof-gable.glb")
const KENNEY_STALL_GREEN = preload("res://assets/third_party/kenney/fantasy_town/models/stall-green.glb")
const KENNEY_STALL_RED = preload("res://assets/third_party/kenney/fantasy_town/models/stall-red.glb")
const KENNEY_FOUNTAIN = preload("res://assets/third_party/kenney/fantasy_town/models/fountain-round-detail.glb")
const KENNEY_HEDGE = preload("res://assets/third_party/kenney/fantasy_town/models/hedge.glb")
const KENNEY_HEDGE_GATE = preload("res://assets/third_party/kenney/fantasy_town/models/hedge-gate.glb")
const QUATERNIUS_FLOOR = preload("res://assets/third_party/quaternius/medieval_village/models/Floor_UnevenBrick.gltf")

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = 20260816
    call_deferred("_apply_asset_pass")

func _apply_asset_pass() -> void:
    _replace_harvestable_visuals()
    _build_prefab_routes()
    _build_market_square()
    _build_settlement()
    _build_prefab_props()
    _build_landmarks()

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
            var tree_scene: PackedScene = KENNEY_TREE_SCENES[rng.randi_range(0, KENNEY_TREE_SCENES.size() - 1)]
            _replace_visual(child, tree_scene, Vector3.ONE * 1.55)
        elif resource_id == "stone":
            var rock_scene: PackedScene = KENNEY_ROCK_SCENES[rng.randi_range(0, KENNEY_ROCK_SCENES.size() - 1)]
            _replace_visual(child, rock_scene, Vector3.ONE * 1.15)

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

func _build_prefab_routes() -> void:
    _build_road_between(Vector3(0.0, 0.035, -1.5), Vector3(-16.0, 0.035, -18.0), 13)
    _build_road_between(Vector3(-15.0, 0.035, -19.0), Vector3(16.0, 0.035, -34.0), 18)
    _build_road_between(Vector3(2.0, 0.035, 2.0), Vector3(12.0, 0.035, -10.0), 10)
    _build_road_between(Vector3(17.0, 0.035, -34.0), Vector3(47.0, 0.035, -46.0), 16)

func _build_road_between(start: Vector3, finish: Vector3, segment_count: int) -> void:
    if segment_count < 2:
        return
    var direction := finish - start
    var yaw := atan2(direction.x, direction.z)
    for i in range(segment_count):
        var t := float(i) / float(segment_count - 1)
        var point := start.lerp(finish, t)
        _spawn_asset(KENNEY_ROAD, point, yaw, Vector3(1.18, 1.0, 1.18))

func _build_market_square() -> void:
    var square_root := Node3D.new()
    square_root.name = "MarketSquare"
    square_root.position = Vector3(18.0, 0.0, -35.0)
    add_child(square_root)

    var spacing := 2.0
    for x in range(-2, 3):
        for z in range(-2, 3):
            _spawn_asset(
                QUATERNIUS_FLOOR,
                Vector3(float(x) * spacing, 0.025, float(z) * spacing),
                0.0,
                Vector3.ONE,
                square_root
            )

    _spawn_asset(KENNEY_FOUNTAIN, Vector3(0, 0.0, 0), 0.0, Vector3.ONE * 1.15, square_root)
    _add_box_collider(square_root, Vector3(0, 0.65, 0), Vector3(2.8, 1.3, 2.8))

    _spawn_asset(KENNEY_STALL_GREEN, Vector3(-4.4, 0.0, -4.0), deg_to_rad(35.0), Vector3.ONE, square_root)
    _add_box_collider(square_root, Vector3(-4.4, 0.75, -4.0), Vector3(2.5, 1.5, 1.5), deg_to_rad(35.0))
    _spawn_asset(KENNEY_STALL_RED, Vector3(4.4, 0.0, 3.8), deg_to_rad(-145.0), Vector3.ONE, square_root)
    _add_box_collider(square_root, Vector3(4.4, 0.75, 3.8), Vector3(2.5, 1.5, 1.5), deg_to_rad(-145.0))

    _spawn_lantern(Vector3(13.6, 0.0, -30.7))
    _spawn_lantern(Vector3(22.2, 0.0, -39.1))

func _build_settlement() -> void:
    _build_house(Vector3(-27.0, 0.0, -31.0), deg_to_rad(24.0), 1.0)
    _build_house(Vector3(31.0, 0.0, -31.0), deg_to_rad(-32.0), 1.05)
    _build_house(Vector3(7.0, 0.0, -47.0), deg_to_rad(8.0), 0.95)
    _build_house(Vector3(-38.0, 0.0, 18.0), deg_to_rad(118.0), 1.0)
    _build_hedge_yard(Vector3(34.0, 0.0, -18.0), deg_to_rad(-12.0))

func _build_house(position: Vector3, yaw: float, scale_value: float) -> void:
    var house := Node3D.new()
    house.name = "PrefabHouse"
    house.position = position
    house.rotation.y = yaw
    house.scale = Vector3.ONE * scale_value
    add_child(house)

    var wall_spacing := 2.0
    _spawn_asset(KENNEY_WALL, Vector3(-wall_spacing, 0.0, -2.2), 0.0, Vector3.ONE, house)
    _spawn_asset(KENNEY_WALL_WINDOW, Vector3(0.0, 0.0, -2.2), 0.0, Vector3.ONE, house)
    _spawn_asset(KENNEY_WALL, Vector3(wall_spacing, 0.0, -2.2), 0.0, Vector3.ONE, house)

    _spawn_asset(KENNEY_WALL, Vector3(-wall_spacing, 0.0, 2.2), PI, Vector3.ONE, house)
    _spawn_asset(KENNEY_WALL_DOOR, Vector3(0.0, 0.0, 2.2), PI, Vector3.ONE, house)
    _spawn_asset(KENNEY_WALL_WINDOW, Vector3(wall_spacing, 0.0, 2.2), PI, Vector3.ONE, house)

    _spawn_asset(KENNEY_WALL_WINDOW, Vector3(-3.0, 0.0, 0.0), deg_to_rad(90.0), Vector3.ONE, house)
    _spawn_asset(KENNEY_WALL, Vector3(3.0, 0.0, 0.0), deg_to_rad(-90.0), Vector3.ONE, house)
    _spawn_asset(KENNEY_ROOF_GABLE, Vector3(0, 2.15, 0), 0.0, Vector3(1.55, 1.0, 1.35), house)

    _add_box_collider(house, Vector3(0, 1.35, -2.15), Vector3(6.1, 2.7, 0.35))
    _add_box_collider(house, Vector3(-3.0, 1.35, 0), Vector3(0.35, 2.7, 4.4))
    _add_box_collider(house, Vector3(3.0, 1.35, 0), Vector3(0.35, 2.7, 4.4))
    _add_box_collider(house, Vector3(-2.05, 1.35, 2.15), Vector3(2.0, 2.7, 0.35))
    _add_box_collider(house, Vector3(2.05, 1.35, 2.15), Vector3(2.0, 2.7, 0.35))

func _build_hedge_yard(position: Vector3, yaw: float) -> void:
    var yard := Node3D.new()
    yard.name = "HedgeYard"
    yard.position = position
    yard.rotation.y = yaw
    add_child(yard)

    for i in range(3):
        var x := -3.0 + float(i) * 3.0
        _spawn_asset(KENNEY_HEDGE, Vector3(x, 0, -3.0), 0.0, Vector3.ONE, yard)
        _add_box_collider(yard, Vector3(x, 0.65, -3.0), Vector3(2.6, 1.3, 0.7))
    _spawn_asset(KENNEY_HEDGE_GATE, Vector3(0, 0, 3.0), PI, Vector3.ONE, yard)
    _spawn_asset(KENNEY_HEDGE, Vector3(-3.0, 0, 3.0), PI, Vector3.ONE, yard)
    _spawn_asset(KENNEY_HEDGE, Vector3(3.0, 0, 3.0), PI, Vector3.ONE, yard)
    _add_box_collider(yard, Vector3(-3.0, 0.65, 3.0), Vector3(2.6, 1.3, 0.7))
    _add_box_collider(yard, Vector3(3.0, 0.65, 3.0), Vector3(2.6, 1.3, 0.7))

func _build_prefab_props() -> void:
    var fence_root := Node3D.new()
    fence_root.name = "CampFence"
    add_child(fence_root)
    for i in range(4):
        var fence_position := Vector3(4.8 + float(i) * 2.0, 0.0, 3.65)
        _spawn_asset(KENNEY_FENCE, fence_position, 0.0, Vector3.ONE, fence_root)
        _add_box_collider(fence_root, fence_position + Vector3(0, 0.7, 0), Vector3(1.8, 1.4, 0.28))
    _spawn_asset(KENNEY_FENCE_GATE, Vector3(12.8, 0.0, 3.65), 0.0, Vector3.ONE, fence_root)

    _spawn_asset(KENNEY_CART, Vector3(-6.2, 0.0, -7.2), deg_to_rad(24.0), Vector3.ONE)
    _add_box_collider(self, Vector3(-6.2, 0.72, -7.2), Vector3(2.2, 1.45, 3.0), deg_to_rad(24.0))
    _spawn_lantern(Vector3(-3.7, 0.0, -4.7))
    _spawn_lantern(Vector3(-7.5, 0.0, -9.2))
    _spawn_lantern(Vector3(-18.0, 0.0, -21.0))
    _spawn_lantern(Vector3(6.5, 0.0, -19.0))

func _spawn_lantern(position: Vector3) -> void:
    _spawn_asset(KENNEY_LANTERN, position, 0.0, Vector3.ONE)
    var light := OmniLight3D.new()
    light.position = position + Vector3(0.0, 1.8, 0.0)
    light.light_color = Color("#ffc06a")
    light.light_energy = 0.9
    light.omni_range = 5.0
    add_child(light)

func _build_landmarks() -> void:
    _spawn_asset(KENNEY_WINDMILL, Vector3(58.0, 0.0, -52.0), deg_to_rad(-28.0), Vector3.ONE * 1.35)
    _add_box_collider(self, Vector3(58.0, 2.3, -52.0), Vector3(5.3, 4.6, 5.3), deg_to_rad(-28.0))

    _spawn_asset(KENNEY_WATERMILL, Vector3(23.0, 0.0, -17.0), deg_to_rad(42.0), Vector3.ONE * 1.1)
    _add_box_collider(self, Vector3(23.0, 1.8, -17.0), Vector3(5.0, 3.6, 4.2), deg_to_rad(42.0))

func _add_box_collider(parent: Node3D, position: Vector3, size: Vector3, yaw := 0.0) -> StaticBody3D:
    var body := StaticBody3D.new()
    body.position = position
    body.rotation.y = yaw
    parent.add_child(body)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)
    return body
