extends Node3D

const KENNEY_WALL = preload("res://assets/third_party/kenney/fantasy_town/models/wall-wood.glb")
const KENNEY_WALL_DOOR = preload("res://assets/third_party/kenney/fantasy_town/models/wall-wood-door.glb")
const KENNEY_WALL_WINDOW = preload("res://assets/third_party/kenney/fantasy_town/models/wall-wood-window-glass.glb")
const KENNEY_ROOF_GABLE = preload("res://assets/third_party/kenney/fantasy_town/models/roof-gable.glb")
const QUATERNIUS_FLOOR = preload("res://assets/third_party/quaternius/medieval_village/models/Floor_UnevenBrick.gltf")

const HOUSE_MIN_SCALE := 1.16
const HOUSE_MAX_SCALE := 1.32

func _ready() -> void:
    call_deferred("_refine_after_generation")

func _refine_after_generation() -> void:
    # El decorador principal también genera su contenido de forma diferida.
    # Esperamos un frame para trabajar sobre el poblado ya construido.
    await get_tree().process_frame
    var decorator := get_node_or_null("../AssetWorldDecorator") as Node3D
    if decorator == null:
        return

    var house_specs: Array[Dictionary] = []
    for child in decorator.get_children():
        if child is Node3D and child.name == "PrefabHouse":
            var old_house := child as Node3D
            house_specs.append({
                "position": old_house.position,
                "yaw": old_house.rotation.y,
                "scale": old_house.scale.x,
            })
            old_house.queue_free()

    for spec in house_specs:
        var origin: Vector3 = spec.get("position", Vector3.ZERO)
        _build_compact_house(
            decorator,
            origin,
            float(spec.get("yaw", 0.0)),
            float(spec.get("scale", 1.0))
        )

    _trim_test_villagers(decorator)

func _build_compact_house(parent: Node3D, origin: Vector3, yaw: float, source_scale: float) -> void:
    var house := Node3D.new()
    house.name = "CompactTimberHouse"
    house.position = origin
    house.rotation.y = yaw
    var corrected_scale := clampf(source_scale * 1.28, HOUSE_MIN_SCALE, HOUSE_MAX_SCALE)
    house.scale = Vector3.ONE * corrected_scale
    parent.add_child(house)

    # El prefab anterior solo tenía un módulo en cada lateral y quedaban huecos claros.
    # Aquí los módulos se solapan ligeramente para formar un volumen cerrado y legible.
    var x_spacing := 1.72
    var half_width := 2.55
    var half_depth := 2.02

    _spawn_asset(KENNEY_WALL_WINDOW, Vector3(-x_spacing, 0.0, -half_depth), 0.0, house)
    _spawn_asset(KENNEY_WALL, Vector3(0.0, 0.0, -half_depth), 0.0, house)
    _spawn_asset(KENNEY_WALL_WINDOW, Vector3(x_spacing, 0.0, -half_depth), 0.0, house)

    _spawn_asset(KENNEY_WALL_WINDOW, Vector3(-x_spacing, 0.0, half_depth), PI, house)
    _spawn_asset(KENNEY_WALL_DOOR, Vector3(0.0, 0.0, half_depth), PI, house)
    _spawn_asset(KENNEY_WALL, Vector3(x_spacing, 0.0, half_depth), PI, house)

    for side_z in [-1.0, 1.0]:
        _spawn_asset(KENNEY_WALL, Vector3(-half_width, 0.0, side_z), deg_to_rad(90.0), house)
        _spawn_asset(KENNEY_WALL_WINDOW, Vector3(half_width, 0.0, side_z), deg_to_rad(-90.0), house)

    # El suelo interior evita que las paredes parezcan piezas independientes flotando.
    for floor_x in [-1.65, 0.0, 1.65]:
        for floor_z in [-0.9, 0.9]:
            var floor_piece := _spawn_asset(QUATERNIUS_FLOOR, Vector3(floor_x, 0.025, floor_z), 0.0, house)
            if floor_piece != null:
                floor_piece.scale = Vector3.ONE * 0.92

    var roof := _spawn_asset(KENNEY_ROOF_GABLE, Vector3(0.0, 2.1, 0.0), 0.0, house)
    if roof != null:
        roof.scale = Vector3(1.38, 1.08, 1.18)

    _add_box_collider(house, Vector3(0.0, 1.3, -half_depth), Vector3(5.35, 2.6, 0.32))
    _add_box_collider(house, Vector3(-half_width, 1.3, 0.0), Vector3(0.32, 2.6, 4.05))
    _add_box_collider(house, Vector3(half_width, 1.3, 0.0), Vector3(0.32, 2.6, 4.05))
    # Dejamos libre el hueco central de la puerta.
    _add_box_collider(house, Vector3(-1.78, 1.3, half_depth), Vector3(1.75, 2.6, 0.32))
    _add_box_collider(house, Vector3(1.78, 1.3, half_depth), Vector3(1.75, 2.6, 0.32))

func _trim_test_villagers(decorator: Node3D) -> void:
    # La fase actual de arte/rendimiento se prueba con dos aldeanos más el jugador.
    var keep_names := {"NPC_Hugo": true, "NPC_Elena": true}
    for child in decorator.get_children():
        if child is CharacterBody3D and child.name.begins_with("NPC_") and not keep_names.has(child.name):
            child.queue_free()

func _spawn_asset(scene: PackedScene, local_position: Vector3, yaw: float, parent: Node3D) -> Node3D:
    var instance := scene.instantiate() as Node3D
    if instance == null:
        return null
    parent.add_child(instance)
    instance.position = local_position
    instance.rotation.y = yaw
    return instance

func _add_box_collider(parent: Node3D, local_position: Vector3, size: Vector3) -> void:
    var body := StaticBody3D.new()
    body.position = local_position
    parent.add_child(body)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = size
    collision.shape = shape
    body.add_child(collision)
