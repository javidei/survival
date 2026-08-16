extends Node3D

# Capa de integración no destructiva: conserva WorldVisualOverhaul y añade
# prefabs reales de los packs que ya viven en assets/third_party/.
const KENNEY_ROAD = preload("res://assets/third_party/kenney/fantasy_town/models/road.glb")
const KENNEY_FENCE = preload("res://assets/third_party/kenney/fantasy_town/models/fence.glb")
const KENNEY_FENCE_GATE = preload("res://assets/third_party/kenney/fantasy_town/models/fence-gate.glb")
const KENNEY_LANTERN = preload("res://assets/third_party/kenney/fantasy_town/models/lantern.glb")
const KENNEY_CART = preload("res://assets/third_party/kenney/fantasy_town/models/cart.glb")
const KENNEY_WINDMILL = preload("res://assets/third_party/kenney/fantasy_town/models/windmill.glb")
const KENNEY_STALL_GREEN = preload("res://assets/third_party/kenney/fantasy_town/models/stall-green.glb")
const KENNEY_STALL_RED = preload("res://assets/third_party/kenney/fantasy_town/models/stall-red.glb")
const KENNEY_FOUNTAIN = preload("res://assets/third_party/kenney/fantasy_town/models/fountain-round-detail.glb")
const QUATERNIUS_FLOOR = preload("res://assets/third_party/quaternius/medieval_village/models/Floor_UnevenBrick.gltf")

const VILLAGER_SCRIPT = preload("res://scripts/world/villager_npc.gd")
const NPC_KNIGHT = preload("res://assets/third_party/kaykit/adventurers/characters/Knight.glb")
const NPC_ROGUE_HOODED = preload("res://assets/third_party/kaykit/adventurers/characters/Rogue_Hooded.glb")

const MARKET_CENTER := Vector3(27.0, 0.0, -37.0)
const WINDMILL_POSITION := Vector3(53.0, 0.0, -53.0)

func _ready() -> void:
    call_deferred("_build_hybrid_asset_layer")

func _build_hybrid_asset_layer() -> void:
    _build_prefab_terrain()
    _build_prefab_routes()
    _build_market_props()
    _build_landmark()
    _spawn_asset_villagers()

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

func _build_prefab_terrain() -> void:
    var trailhead := Node3D.new()
    trailhead.name = "PrefabTerrainTrailhead"
    trailhead.position = Vector3(0.0, 0.0, -29.6)
    add_child(trailhead)

    for x in range(-1, 2):
        for z in range(-1, 2):
            _spawn_asset(
                QUATERNIUS_FLOOR,
                Vector3(float(x) * 2.0, 0.055, float(z) * 2.0),
                0.0,
                Vector3.ONE,
                trailhead
            )

    var market := Node3D.new()
    market.name = "PrefabTerrainMarket"
    market.position = MARKET_CENTER
    add_child(market)

    for x in range(-2, 3):
        for z in range(-2, 3):
            _spawn_asset(
                QUATERNIUS_FLOOR,
                Vector3(float(x) * 2.0, 0.055, float(z) * 2.0),
                0.0,
                Vector3.ONE,
                market
            )

func _build_prefab_routes() -> void:
    _build_road_between(Vector3(0.0, 0.065, -30.0), MARKET_CENTER + Vector3(-5.0, 0.065, 1.5), 18)
    _build_road_between(MARKET_CENTER + Vector3(4.5, 0.065, -2.0), WINDMILL_POSITION + Vector3(-4.0, 0.065, 2.0), 15)

func _build_road_between(start: Vector3, finish: Vector3, segment_count: int) -> void:
    if segment_count < 2:
        return
    var direction := finish - start
    var yaw := atan2(direction.x, direction.z)
    for i in range(segment_count):
        var t := float(i) / float(segment_count - 1)
        var point := start.lerp(finish, t)
        _spawn_asset(KENNEY_ROAD, point, yaw, Vector3(1.14, 1.0, 1.14))

func _build_market_props() -> void:
    var market := Node3D.new()
    market.name = "HybridMarketProps"
    market.position = MARKET_CENTER
    add_child(market)

    _spawn_asset(KENNEY_FOUNTAIN, Vector3.ZERO, 0.0, Vector3.ONE, market)
    _add_box_collider(market, Vector3(0.0, 0.58, 0.0), Vector3(2.5, 1.16, 2.5))

    _spawn_asset(KENNEY_STALL_GREEN, Vector3(-4.2, 0.0, -3.5), deg_to_rad(28.0), Vector3.ONE, market)
    _add_box_collider(market, Vector3(-4.2, 0.72, -3.5), Vector3(2.4, 1.45, 1.5), deg_to_rad(28.0))

    _spawn_asset(KENNEY_STALL_RED, Vector3(4.2, 0.0, 3.4), deg_to_rad(-152.0), Vector3.ONE, market)
    _add_box_collider(market, Vector3(4.2, 0.72, 3.4), Vector3(2.4, 1.45, 1.5), deg_to_rad(-152.0))

    _spawn_asset(KENNEY_CART, Vector3(5.1, 0.0, -2.2), deg_to_rad(-22.0), Vector3.ONE, market)
    _add_box_collider(market, Vector3(5.1, 0.72, -2.2), Vector3(2.1, 1.45, 2.9), deg_to_rad(-22.0))

    for i in range(3):
        var z := -4.0 + float(i) * 3.8
        _spawn_asset(KENNEY_FENCE, Vector3(-6.2, 0.0, z), deg_to_rad(90.0), Vector3.ONE, market)
        _add_box_collider(market, Vector3(-6.2, 0.68, z), Vector3(0.3, 1.36, 1.9))

    _spawn_asset(KENNEY_FENCE, Vector3(6.2, 0.0, -3.8), deg_to_rad(90.0), Vector3.ONE, market)
    _spawn_asset(KENNEY_FENCE_GATE, Vector3(6.2, 0.0, 0.0), deg_to_rad(90.0), Vector3.ONE, market)
    _spawn_asset(KENNEY_FENCE, Vector3(6.2, 0.0, 3.8), deg_to_rad(90.0), Vector3.ONE, market)

    for local_position in [
        Vector3(-4.8, 0.0, 4.8),
        Vector3(4.8, 0.0, 4.8),
        Vector3(-4.8, 0.0, -4.8),
        Vector3(4.8, 0.0, -4.8)
    ]:
        _spawn_lantern(local_position, market)

func _spawn_lantern(local_position: Vector3, parent: Node3D) -> void:
    _spawn_asset(KENNEY_LANTERN, local_position, 0.0, Vector3.ONE, parent)
    var light := OmniLight3D.new()
    light.position = local_position + Vector3(0.0, 1.8, 0.0)
    light.light_color = Color("#ffc06a")
    light.light_energy = 0.78
    light.omni_range = 5.2
    parent.add_child(light)

func _build_landmark() -> void:
    _spawn_asset(KENNEY_WINDMILL, WINDMILL_POSITION, deg_to_rad(-28.0), Vector3.ONE * 1.3)
    _add_box_collider(self, WINDMILL_POSITION + Vector3(0.0, 2.2, 0.0), Vector3(5.1, 4.4, 5.1), deg_to_rad(-28.0))

func _spawn_asset_villagers() -> void:
    _spawn_villager(
        NPC_KNIGHT,
        "Hugo",
        "guardia del mercado",
        "El camino de piedra lleva hasta el molino. De noche conviene volver con luz.",
        MARKET_CENTER + Vector3(-2.8, 0.08, 1.8),
        2.3
    )
    _spawn_villager(
        NPC_ROGUE_HOODED,
        "Iria",
        "rastreadora",
        "Más allá del molino el bosque se vuelve bastante más cerrado.",
        MARKET_CENTER + Vector3(2.9, 0.08, -2.0),
        2.7
    )

func _spawn_villager(scene: PackedScene, display_name: String, role: String, greeting: String, position: Vector3, radius: float) -> void:
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
