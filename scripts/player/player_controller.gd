extends CharacterBody3D

@export var walk_speed := 5.2
@export var run_speed := 8.2
@export var acceleration := 18.0
@export var jump_velocity := 7.2
@export var mouse_sensitivity := 0.003
@export var camera_min_pitch := deg_to_rad(-55.0)
@export var camera_max_pitch := deg_to_rad(35.0)

@onready var pivot: Node3D = $CameraPivot
@onready var interaction_area: Area3D = $InteractionArea

var gravity := 18.0
var pitch := deg_to_rad(-12.0)
var prompt_target: Node = null
var spawn_position := Vector3.ZERO

func _ready() -> void:
    add_to_group("player")
    spawn_position = global_position
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    GameState.player_died.connect(_on_player_died)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        pitch = clamp(pitch - event.relative.y * mouse_sensitivity, camera_min_pitch, camera_max_pitch)
        pivot.rotation.x = pitch
        return
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
    elif event.is_action_pressed("interact"):
        _interact()
    elif event.is_action_pressed("primary_action"):
        _perform_primary_action()
    elif event.is_action_pressed("craft"):
        GameState.craft_current_recipe()
    elif event.is_action_pressed("recipe_next"):
        GameState.cycle_recipe(1)
    elif event.is_action_pressed("consume"):
        GameState.consume_food()
    elif event.is_action_pressed("build_rotate"):
        var builder := get_tree().get_first_node_in_group("build_system")
        if is_instance_valid(builder) and builder.has_method("rotate_preview"):
            builder.rotate_preview()
    else:
        for index in range(GameState.HOTBAR.size()):
            if event.is_action_pressed("hotbar_%d" % (index + 1)):
                GameState.select_hotbar(index)
                break

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = jump_velocity

    var input_vector := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var local_direction := Vector3(input_vector.x, 0.0, input_vector.y)
    var direction := (transform.basis * local_direction).normalized()
    var target_speed := run_speed if Input.is_action_pressed("run") else walk_speed
    var target_velocity := direction * target_speed

    velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
    velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
    move_and_slide()
    _refresh_interaction_target()

func _refresh_interaction_target() -> void:
    prompt_target = null
    var nearest_distance := INF
    var candidates: Array[Node] = []
    candidates.append_array(interaction_area.get_overlapping_areas())
    candidates.append_array(interaction_area.get_overlapping_bodies())
    for candidate in candidates:
        if not candidate.is_in_group("interactable") and not candidate.is_in_group("damageable"):
            continue
        var candidate_3d := candidate as Node3D
        if candidate_3d == null:
            continue
        var distance := global_position.distance_squared_to(candidate_3d.global_position)
        if distance < nearest_distance:
            nearest_distance = distance
            prompt_target = candidate

func _interact() -> void:
    if is_instance_valid(prompt_target) and prompt_target.has_method("interact"):
        prompt_target.interact(self)

func _perform_primary_action() -> void:
    var selected := GameState.get_selected_item()
    if GameState.is_build_item(selected):
        var builder := get_tree().get_first_node_in_group("build_system")
        if is_instance_valid(builder) and builder.has_method("place_selected"):
            if not builder.place_selected():
                GameState.notification.emit("No tienes piezas de %s" % GameState.get_item_name(selected))
        return

    if is_instance_valid(prompt_target):
        if prompt_target.has_method("harvest"):
            prompt_target.harvest(selected, self)
            return
        if prompt_target.has_method("take_hit"):
            prompt_target.take_hit(selected, self)
            return
    GameState.notification.emit("No hay nada a alcance")

func get_interaction_text() -> String:
    if is_instance_valid(prompt_target) and prompt_target.has_method("get_interaction_text"):
        return "[E] %s" % prompt_target.get_interaction_text()
    return ""

func _on_player_died() -> void:
    global_position = spawn_position
    velocity = Vector3.ZERO
    GameState.reset_run()
    GameState.notification.emit("Has caído. Regresas al campamento.")
