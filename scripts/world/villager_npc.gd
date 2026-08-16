extends CharacterBody3D

const KAYKIT_ANIMATOR = preload("res://scripts/player/kaykit_character_animator.gd")

@export var model_scene: PackedScene
@export var npc_name := "Habitante"
@export var role := "Aldeano"
@export_multiline var greeting := "Hola."
@export var wander_radius := 3.5
@export var move_speed := 1.15
@export var ground_stick_velocity := 1.25

var home_position := Vector3.ZERO
var target_position := Vector3.ZERO
var pause_left := 0.0
var gravity := 18.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    add_to_group("interactable")
    add_to_group("npc")
    collision_layer = 2
    collision_mask = 1
    floor_snap_length = 0.55
    floor_stop_on_slope = true
    home_position = global_position
    rng.seed = hash(npc_name) + int(abs(global_position.x * 37.0 + global_position.z * 53.0))
    _create_collision()
    _build_visual()
    _pick_target()

func _physics_process(delta: float) -> void:
    # Mantener una presión descendente mínima evita que un NPC quede separado del suelo
    # al pasar de caminar a idle sobre juntas o pequeños desniveles.
    if is_on_floor():
        velocity.y = -ground_stick_velocity
    else:
        velocity.y -= gravity * delta

    var desired := Vector3.ZERO
    if pause_left > 0.0:
        pause_left -= delta
    else:
        var to_target: Vector3 = target_position - global_position
        to_target.y = 0.0
        if to_target.length() < 0.55:
            pause_left = rng.randf_range(1.8, 4.8)
            _pick_target()
        else:
            desired = to_target.normalized()

    velocity.x = move_toward(velocity.x, desired.x * move_speed, 4.0 * delta)
    velocity.z = move_toward(velocity.z, desired.z * move_speed, 4.0 * delta)

    if desired.length_squared() > 0.05:
        rotation.y = lerp_angle(rotation.y, atan2(-desired.x, -desired.z), delta * 5.0)

    move_and_slide()
    if velocity.y <= 0.0 and not is_on_floor():
        apply_floor_snap()

func _pick_target() -> void:
    var angle := rng.randf_range(0.0, TAU)
    var distance := rng.randf_range(0.8, wander_radius)
    target_position = home_position + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)

func _create_collision() -> void:
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    shape.radius = 0.34
    shape.height = 1.72
    collision.shape = shape
    collision.position = Vector3(0.0, 0.86, 0.0)
    add_child(collision)

func _build_visual() -> void:
    if model_scene == null:
        return

    var character := model_scene.instantiate() as Node3D
    if character == null:
        return

    var visual := Node3D.new()
    visual.name = "Visual"
    visual.rotation.y = PI
    visual.set_script(KAYKIT_ANIMATOR)

    character.name = "Ranger"
    visual.add_child(character)
    add_child(visual)

func get_interaction_text() -> String:
    return "%s · %s" % [npc_name, role]

func interact(actor: Node) -> void:
    if actor is Node3D:
        var to_actor: Vector3 = (actor as Node3D).global_position - global_position
        to_actor.y = 0.0
        if to_actor.length_squared() > 0.01:
            rotation.y = atan2(-to_actor.x, -to_actor.z)
    pause_left = 3.0
    GameState.notification.emit("%s: %s" % [npc_name, greeting])
