extends Node3D

const HARVESTABLE_SCRIPT = preload("res://scripts/world/harvestable.gd")
const TREE_SCENES = [
    preload("res://assets/third_party/kenney/fantasy_town/models/tree.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/tree-high.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/tree-crooked.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/tree-high-crooked.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/tree-high-round.glb")
]
const ROCK_SCENES = [
    preload("res://assets/third_party/kenney/fantasy_town/models/rock-small.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/rock-large.glb"),
    preload("res://assets/third_party/kenney/fantasy_town/models/rock-wide.glb")
]

@export var seed_value: int = 20260816
@export var villagers_to_keep: int = 2

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
    rng.seed = seed_value
    _build_clustered_forest()
    _trim_npcs_after_spawn()

func _build_clustered_forest() -> void:
    var cluster_centers: Array[Vector3] = [
        Vector3(-48.0, 0.0, 18.0),
        Vector3(48.0, 0.0, 16.0),
        Vector3(-54.0, 0.0, -18.0),
        Vector3(54.0, 0.0, -20.0),
        Vector3(-42.0, 0.0, -55.0),
        Vector3(42.0, 0.0, -56.0),
        Vector3(0.0, 0.0, -64.0)
    ]

    for center in cluster_centers:
        for _tree_index in range(8):
            var angle: float = rng.randf_range(0.0, TAU)
            var distance: float = rng.randf_range(2.0, 10.5)
            var position := center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
            _spawn_harvestable_tree(position, rng.randf_range(1.25, 1.75))

    # Sotobosque ligero: árboles jóvenes sin físicas ni scripts individuales.
    for center in cluster_centers:
        for _sapling_index in range(2):
            var angle: float = rng.randf_range(0.0, TAU)
            var distance: float = rng.randf_range(5.0, 12.0)
            var position := center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
            _spawn_decorative_sapling(position)

    var rock_clusters: Array[Vector3] = [
        Vector3(-34.0, 0.0, 24.0),
        Vector3(35.0, 0.0, 24.0),
        Vector3(-58.0, 0.0, -38.0),
        Vector3(58.0, 0.0, -40.0),
        Vector3(-18.0, 0.0, -62.0),
        Vector3(20.0, 0.0, -64.0)
    ]
    for center in rock_clusters:
        for _rock_index in range(3):
            var angle: float = rng.randf_range(0.0, TAU)
            var distance: float = rng.randf_range(1.2, 4.8)
            var position := center + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
            _spawn_harvestable_rock(position, rng.randf_range(0.95, 1.35))

func _spawn_harvestable_tree(position: Vector3, scale_value: float) -> void:
    var root := Area3D.new()
    root.name = "HarvestableTree"
    root.set_script(HARVESTABLE_SCRIPT)
    root.set("resource_id", "wood")
    root.set("required_tool", "axe")
    root.set("hits_required", 4)
    root.set("drop_amount", rng.randi_range(3, 6))
    root.position = position
    root.rotation.y = rng.randf_range(0.0, TAU)
    root.scale = Vector3.ONE * scale_value

    var tree_scene: PackedScene = TREE_SCENES[rng.randi_range(0, TREE_SCENES.size() - 1)]
    var visual := tree_scene.instantiate() as Node3D
    if visual != null:
        visual.name = "AssetVisual"
        root.add_child(visual)

    var interaction_collision := CollisionShape3D.new()
    var interaction_shape := CapsuleShape3D.new()
    interaction_shape.radius = 0.52
    interaction_shape.height = 4.2
    interaction_collision.shape = interaction_shape
    interaction_collision.position = Vector3(0.0, 2.0, 0.0)
    root.add_child(interaction_collision)

    add_child(root)

func _spawn_harvestable_rock(position: Vector3, scale_value: float) -> void:
    var root := Area3D.new()
    root.name = "HarvestableRock"
    root.set_script(HARVESTABLE_SCRIPT)
    root.set("resource_id", "stone")
    root.set("required_tool", "pickaxe")
    root.set("hits_required", 3)
    root.set("drop_amount", rng.randi_range(2, 5))
    root.position = position
    root.rotation.y = rng.randf_range(0.0, TAU)
    root.scale = Vector3.ONE * scale_value

    var rock_scene: PackedScene = ROCK_SCENES[rng.randi_range(0, ROCK_SCENES.size() - 1)]
    var visual := rock_scene.instantiate() as Node3D
    if visual != null:
        visual.name = "AssetVisual"
        root.add_child(visual)

    var interaction_collision := CollisionShape3D.new()
    var interaction_shape := SphereShape3D.new()
    interaction_shape.radius = 0.72
    interaction_collision.shape = interaction_shape
    interaction_collision.position = Vector3(0.0, 0.45, 0.0)
    root.add_child(interaction_collision)

    add_child(root)

func _spawn_decorative_sapling(position: Vector3) -> void:
    var tree_scene: PackedScene = TREE_SCENES[rng.randi_range(0, TREE_SCENES.size() - 1)]
    var visual := tree_scene.instantiate() as Node3D
    if visual == null:
        return
    visual.name = "DecorativeSapling"
    visual.position = position
    visual.rotation.y = rng.randf_range(0.0, TAU)
    visual.scale = Vector3.ONE * rng.randf_range(0.55, 0.85)
    add_child(visual)

func _trim_npcs_after_spawn() -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    var npcs: Array[Node] = get_tree().get_nodes_in_group("npc")
    if npcs.size() <= villagers_to_keep:
        return
    for npc_index in range(villagers_to_keep, npcs.size()):
        var npc: Node = npcs[npc_index]
        if is_instance_valid(npc):
            npc.queue_free()
