extends CharacterBody3D

const DROP_SCRIPT = preload("res://scripts/world/physical_drop.gd")

@export var hostile := false
@export var move_speed := 2.2
@export var health := 3
@export var detect_radius := 9.0
@export var attack_damage := 8.0
@export var meat_drops := 2
@export var model_scene: PackedScene
@export var target_visual_height := 1.2
@export var model_yaw_offset := PI

var target: Node3D = null
var wander_direction := Vector3.ZERO
var wander_timer := 0.0
var attack_cooldown := 0.0
var animation_lock_left := 0.0
var gravity := 18.0
var animation_player: AnimationPlayer = null
var active_animation := ""

func _ready() -> void:
    add_to_group("damageable")
    add_to_group("interactable")
    add_to_group("wildlife")
    collision_layer = 2
    collision_mask = 1
    floor_snap_length = 0.45
    floor_stop_on_slope = true
    _build_collision()
    if not _build_prefab_visual():
        _build_fallback_visual()
    _pick_wander_direction()
    _play_animation_matching(["idle", "stand"])

func _physics_process(delta: float) -> void:
    if is_on_floor():
        velocity.y = -1.1
    else:
        velocity.y -= gravity * delta

    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    animation_lock_left = maxf(0.0, animation_lock_left - delta)
    wander_timer -= delta
    if target == null or not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player") as Node3D

    var desired := Vector3.ZERO
    var current_speed := move_speed
    if is_instance_valid(target):
        var to_player: Vector3 = target.global_position - global_position
        var planar_to_player := Vector3(to_player.x, 0.0, to_player.z)
        var player_distance := planar_to_player.length()

        if hostile and player_distance <= detect_radius:
            desired = planar_to_player.normalized()
            current_speed = move_speed * 1.12
            if player_distance < 1.55 and attack_cooldown <= 0.0:
                GameState.damage(attack_damage)
                GameState.notification.emit("Te ha atacado un jabalí")
                attack_cooldown = 1.25
                animation_lock_left = 0.45
                _play_animation_matching(["attack", "bite", "headbutt"])
        elif not hostile and player_distance <= detect_radius * 0.82:
            desired = -planar_to_player.normalized()
            current_speed = move_speed * 1.55
            wander_timer = 1.0
        else:
            desired = _get_wander_direction()
    else:
        desired = _get_wander_direction()

    velocity.x = desired.x * current_speed
    velocity.z = desired.z * current_speed
    if desired.length_squared() > 0.05:
        rotation.y = lerp_angle(rotation.y, atan2(-desired.x, -desired.z), delta * 5.0)

    move_and_slide()
    if velocity.y <= 0.0 and not is_on_floor():
        apply_floor_snap()
    _update_model_animation()

func _get_wander_direction() -> Vector3:
    if wander_timer <= 0.0:
        _pick_wander_direction()
    return wander_direction

func _pick_wander_direction() -> void:
    wander_timer = randf_range(2.5, 6.0)
    var angle := randf_range(0.0, TAU)
    wander_direction = Vector3(cos(angle), 0.0, sin(angle))

func _build_collision() -> void:
    var collision := CollisionShape3D.new()
    var shape := CapsuleShape3D.new()
    if hostile:
        shape.radius = 0.34
        shape.height = 0.78
        collision.position = Vector3(0.0, 0.39, 0.0)
    else:
        shape.radius = 0.30
        shape.height = 1.24
        collision.position = Vector3(0.0, 0.62, 0.0)
    collision.shape = shape
    add_child(collision)

func _build_prefab_visual() -> bool:
    if model_scene == null:
        return false
    var model := model_scene.instantiate() as Node3D
    if model == null:
        return false

    var visual := Node3D.new()
    visual.name = "AnimalVisual"
    add_child(visual)
    visual.add_child(model)
    model.rotation.y = model_yaw_offset
    _fit_prefab_to_height(model, target_visual_height)
    animation_player = _find_animation_player(model)
    return true

func _fit_prefab_to_height(root: Node3D, desired_height: float) -> void:
    var min_bounds := Vector3(INF, INF, INF)
    var max_bounds := Vector3(-INF, -INF, -INF)
    var found_mesh := false
    var mesh_nodes: Array[Node] = []
    if root is MeshInstance3D:
        mesh_nodes.append(root)
    mesh_nodes.append_array(root.find_children("*", "MeshInstance3D", true, false))

    for node in mesh_nodes:
        var mesh_instance := node as MeshInstance3D
        if mesh_instance == null or mesh_instance.mesh == null:
            continue
        var aabb := mesh_instance.get_aabb()
        for x_index in range(2):
            for y_index in range(2):
                for z_index in range(2):
                    var corner := Vector3(
                        aabb.position.x + aabb.size.x * float(x_index),
                        aabb.position.y + aabb.size.y * float(y_index),
                        aabb.position.z + aabb.size.z * float(z_index)
                    )
                    var local_corner := root.to_local(mesh_instance.to_global(corner))
                    min_bounds.x = minf(min_bounds.x, local_corner.x)
                    min_bounds.y = minf(min_bounds.y, local_corner.y)
                    min_bounds.z = minf(min_bounds.z, local_corner.z)
                    max_bounds.x = maxf(max_bounds.x, local_corner.x)
                    max_bounds.y = maxf(max_bounds.y, local_corner.y)
                    max_bounds.z = maxf(max_bounds.z, local_corner.z)
                    found_mesh = true

    if not found_mesh:
        return
    var source_height := max_bounds.y - min_bounds.y
    if source_height <= 0.001:
        return

    var scale_factor := desired_height / source_height
    var center_x := (min_bounds.x + max_bounds.x) * 0.5
    var center_z := (min_bounds.z + max_bounds.z) * 0.5
    root.scale *= scale_factor
    root.position = Vector3(-center_x * scale_factor, -min_bounds.y * scale_factor + 0.02, -center_z * scale_factor)

func _find_animation_player(root: Node) -> AnimationPlayer:
    if root is AnimationPlayer:
        return root as AnimationPlayer
    var players: Array[Node] = root.find_children("*", "AnimationPlayer", true, false)
    if players.is_empty():
        return null
    return players[0] as AnimationPlayer

func _update_model_animation() -> void:
    if animation_player == null or animation_lock_left > 0.0:
        return
    var horizontal_speed := Vector2(velocity.x, velocity.z).length()
    if horizontal_speed > move_speed * 1.25:
        _play_animation_matching(["run", "gallop", "sprint", "walk"])
    elif horizontal_speed > 0.15:
        _play_animation_matching(["walk", "run", "gallop"])
    else:
        _play_animation_matching(["idle", "stand"])

func _play_animation_matching(candidates: Array) -> void:
    if animation_player == null:
        return
    var selected := ""
    var animation_names := animation_player.get_animation_list()
    for candidate in candidates:
        var needle := String(candidate).to_lower()
        for animation_name in animation_names:
            var animation_text := String(animation_name)
            if animation_text.to_lower().contains(needle):
                selected = animation_text
                break
        if not selected.is_empty():
            break

    if selected.is_empty() or selected == active_animation:
        return
    animation_player.play(selected)
    active_animation = selected

func _build_fallback_visual() -> void:
    var mesh_instance := MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.34 if hostile else 0.30
    mesh.height = 0.78 if hostile else 1.24
    mesh_instance.mesh = mesh
    mesh_instance.position = Vector3(0.0, 0.39 if hostile else 0.62, 0.0)
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("#4b3328") if hostile else Color("#9b7048")
    material.roughness = 0.94
    mesh_instance.material_override = material
    add_child(mesh_instance)

func take_hit(tool_id: String, attacker: Node) -> void:
    var damage := 2 if tool_id == "spear" and GameState.get_amount("spear") > 0 else 1
    health -= damage
    if is_instance_valid(attacker):
        var away: Vector3 = global_position - (attacker as Node3D).global_position
        var planar_away := Vector3(away.x, 0.0, away.z).normalized()
        velocity += planar_away * 4.0
        if not hostile:
            wander_direction = planar_away
            wander_timer = 2.2
    if health <= 0:
        _die()
    else:
        GameState.notification.emit("Golpe: %d de daño" % damage)

func _die() -> void:
    for i in range(meat_drops):
        var drop := RigidBody3D.new()
        drop.set_script(DROP_SCRIPT)
        drop.set("resource_id", "raw_meat")
        get_parent().add_child(drop)
        drop.global_position = global_position + Vector3(0, 0.8 + i * 0.12, 0)
        drop.apply_central_impulse(Vector3(randf_range(-1.0, 1.0), 2.2, randf_range(-1.0, 1.0)))
    queue_free()

func get_interaction_text() -> String:
    return "Jabalí hostil" if hostile else "Ciervo"
