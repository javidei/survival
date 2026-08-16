extends Node3D

const MOVEMENT_SOURCE = preload("res://assets/third_party/kaykit/adventurers/animations/Rig_Medium/Rig_Medium_MovementBasic.glb")
const GENERAL_SOURCE = preload("res://assets/third_party/kaykit/adventurers/animations/Rig_Medium/Rig_Medium_General.glb")

@export var player_path: NodePath = NodePath("..")
@export var blend_time := 0.14
@export var walk_threshold := 0.25
@export var run_threshold := 6.15
@export var visual_ground_offset := -0.10

@onready var player: CharacterBody3D = get_node(player_path) as CharacterBody3D
@onready var ranger_root: Node3D = $Ranger

var animation_player: AnimationPlayer
var character_skeleton: Skeleton3D
var current_animation := StringName()
var idle_animation := StringName()
var walk_animation := StringName()
var run_animation := StringName()
var jump_animation := StringName()

func _ready() -> void:
    position.y = visual_ground_offset
    call_deferred("_setup_animations")

func _process(_delta: float) -> void:
    if animation_player == null or not is_instance_valid(player):
        return

    var horizontal_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
    var desired: StringName = idle_animation

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
        animation_player.speed_scale = clampf(horizontal_speed / 5.2, 0.75, 1.35)
    elif desired == run_animation:
        animation_player.speed_scale = clampf(horizontal_speed / 8.2, 0.8, 1.25)
    else:
        animation_player.speed_scale = 1.0

func _setup_animations() -> void:
    character_skeleton = _find_skeleton(ranger_root)
    if character_skeleton == null:
        push_warning("KayKit: no se encontró Skeleton3D en el personaje")
        return

    # Usamos un AnimationPlayer propio cuya raíz es Visual. Las animaciones de los
    # GLB auxiliares se retargetean explícitamente al Skeleton3D del personaje actual.
    animation_player = AnimationPlayer.new()
    animation_player.name = "KayKitRetargetedAnimationPlayer"
    animation_player.root_node = NodePath("..")
    add_child(animation_player)

    var target_skeleton_path: NodePath = get_path_to(character_skeleton)
    _import_retargeted_source(MOVEMENT_SOURCE, &"kaykit_movement", target_skeleton_path)
    _import_retargeted_source(GENERAL_SOURCE, &"kaykit_general", target_skeleton_path)

    var names: PackedStringArray = animation_player.get_animation_list()
    idle_animation = _pick_animation(names, ["idle_a", "idle_b", "idle"])
    walk_animation = _pick_animation(names, ["walking_a", "walking", "walk"])
    run_animation = _pick_animation(names, ["running_a", "running", "run"])
    jump_animation = _pick_animation(names, ["jump_full_short", "jump", "falling", "fall"])

    if idle_animation == &"":
        push_warning("KayKit: no se encontró animación idle compatible")
        return

    animation_player.play(idle_animation)
    animation_player.advance(0.001)
    current_animation = idle_animation

func _import_retargeted_source(source_scene: PackedScene, library_prefix: StringName, target_skeleton_path: NodePath) -> void:
    var source_root: Node = source_scene.instantiate()
    var source_player: AnimationPlayer = _find_animation_player(source_root)
    if source_player == null:
        source_root.free()
        push_warning("KayKit: el GLB de animaciones no contiene AnimationPlayer")
        return

    var library_index: int = 0
    for source_library_name in source_player.get_animation_library_list():
        var source_library: AnimationLibrary = source_player.get_animation_library(source_library_name)
        if source_library == null:
            continue

        var target_library := AnimationLibrary.new()
        for animation_name in source_library.get_animation_list():
            var source_animation: Animation = source_library.get_animation(animation_name)
            if source_animation == null:
                continue

            var copied_animation: Animation = source_animation.duplicate(true) as Animation
            if copied_animation == null:
                continue

            _retarget_animation_tracks(copied_animation, target_skeleton_path)
            if _is_looping_animation(animation_name):
                copied_animation.loop_mode = Animation.LOOP_LINEAR
            target_library.add_animation(animation_name, copied_animation)

        if target_library.get_animation_list_size() > 0:
            var target_name: StringName = library_prefix
            if library_index > 0:
                target_name = StringName("%s_%d" % [String(library_prefix), library_index])
            while animation_player.has_animation_library(target_name):
                library_index += 1
                target_name = StringName("%s_%d" % [String(library_prefix), library_index])
            animation_player.add_animation_library(target_name, target_library)
            library_index += 1

    source_root.free()

func _retarget_animation_tracks(animation: Animation, target_skeleton_path: NodePath) -> void:
    var target_path_text: String = String(target_skeleton_path)
    var track_count: int = animation.get_track_count()

    for track_index in range(track_count):
        var source_path_text: String = String(animation.track_get_path(track_index))
        var separator: int = source_path_text.find(":")
        if separator < 0:
            continue

        # Las pistas importadas de KayKit apuntan a otro Skeleton3D, pero conservan
        # el mismo nombre de hueso. Sustituimos solo la ruta del nodo y preservamos
        # el subnombre del hueso que aparece después de ':'.
        var bone_suffix: String = source_path_text.substr(separator)
        animation.track_set_path(track_index, NodePath(target_path_text + bone_suffix))

func _is_looping_animation(animation_name: StringName) -> bool:
    var lower_name: String = String(animation_name).to_lower()
    return "idle" in lower_name or "walk" in lower_name or "run" in lower_name

func _find_animation_player(root: Node) -> AnimationPlayer:
    if root is AnimationPlayer:
        return root as AnimationPlayer
    for child in root.get_children():
        var found: AnimationPlayer = _find_animation_player(child)
        if found != null:
            return found
    return null

func _find_skeleton(root: Node) -> Skeleton3D:
    if root is Skeleton3D:
        return root as Skeleton3D
    for child in root.get_children():
        var found: Skeleton3D = _find_skeleton(child)
        if found != null:
            return found
    return null

func _pick_animation(names: PackedStringArray, fragments: Array[String]) -> StringName:
    for fragment in fragments:
        var wanted: String = fragment.to_lower()
        for animation_name in names:
            if wanted in animation_name.to_lower():
                return StringName(animation_name)
    return &""
