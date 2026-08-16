extends Node3D

const MOVEMENT_SOURCE = preload("res://assets/third_party/kaykit/adventurers/animations/Rig_Medium/Rig_Medium_MovementBasic.glb")

@export var player_path: NodePath = NodePath("..")
@export var blend_time := 0.14
@export var walk_threshold := 0.25
@export var run_threshold := 6.15

@onready var player: CharacterBody3D = get_node(player_path) as CharacterBody3D
@onready var ranger_root: Node3D = $Ranger

var animation_player: AnimationPlayer
var current_animation := StringName()
var idle_animation := StringName()
var walk_animation := StringName()
var run_animation := StringName()
var jump_animation := StringName()

func _ready() -> void:
    call_deferred("_setup_animations")

func _process(_delta: float) -> void:
    if animation_player == null or not is_instance_valid(player):
        return

    var horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
    var desired := idle_animation

    if not player.is_on_floor() and jump_animation != &"":
        desired = jump_animation
    elif horizontal_speed >= run_threshold and run_animation != &"":
        desired = run_animation
    elif horizontal_speed > walk_threshold and walk_animation != &"":
        desired = walk_animation

    if desired == &"":
        return

    if desired != current_animation or not animation_player.is_playing():
        animation_player.play(desired, blend_time)
        current_animation = desired

    if desired == walk_animation:
        animation_player.speed_scale = clamp(horizontal_speed / 5.2, 0.75, 1.35)
    elif desired == run_animation:
        animation_player.speed_scale = clamp(horizontal_speed / 8.2, 0.8, 1.25)
    else:
        animation_player.speed_scale = 1.0

func _setup_animations() -> void:
    animation_player = _find_animation_player(ranger_root)
    if animation_player == null:
        push_warning("KayKit Ranger no contiene AnimationPlayer; no se pueden aplicar animaciones.")
        return

    _import_movement_libraries()

    var names := animation_player.get_animation_list()
    idle_animation = _pick_animation(names, ["idle_a", "idle"])
    walk_animation = _pick_animation(names, ["walking_a", "walk", "walking"])
    run_animation = _pick_animation(names, ["running_a", "run", "running"])
    jump_animation = _pick_animation(names, ["jump_full_short", "jump", "falling", "fall"])

    if idle_animation != &"":
        animation_player.play(idle_animation)
        current_animation = idle_animation

func _import_movement_libraries() -> void:
    var existing_names := animation_player.get_animation_list()
    if _contains_fragment(existing_names, "walk") and _contains_fragment(existing_names, "run"):
        return

    var source_root := MOVEMENT_SOURCE.instantiate()
    var source_player := _find_animation_player(source_root)
    if source_player == null:
        source_root.free()
        push_warning("No se encontró AnimationPlayer en Rig_Medium_MovementBasic.glb")
        return

    var library_index := 0
    for source_library_name in source_player.get_animation_library_list():
        var source_library := source_player.get_animation_library(source_library_name)
        if source_library == null:
            continue

        var target_name := StringName("kaykit_movement")
        if library_index > 0:
            target_name = StringName("kaykit_movement_%d" % library_index)
        while animation_player.has_animation_library(target_name):
            library_index += 1
            target_name = StringName("kaykit_movement_%d" % library_index)

        var copied_library := source_library.duplicate(true) as AnimationLibrary
        if copied_library != null:
            animation_player.add_animation_library(target_name, copied_library)
        library_index += 1

    source_root.free()

func _find_animation_player(root: Node) -> AnimationPlayer:
    if root is AnimationPlayer:
        return root as AnimationPlayer
    for child in root.get_children():
        var found := _find_animation_player(child)
        if found != null:
            return found
    return null

func _pick_animation(names: PackedStringArray, fragments: Array[String]) -> StringName:
    for fragment in fragments:
        var wanted := fragment.to_lower()
        for animation_name in names:
            if wanted in animation_name.to_lower():
                return StringName(animation_name)
    return &""

func _contains_fragment(names: PackedStringArray, fragment: String) -> bool:
    var wanted := fragment.to_lower()
    for animation_name in names:
        if wanted in animation_name.to_lower():
            return true
    return false
