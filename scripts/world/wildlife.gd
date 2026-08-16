extends CharacterBody3D

const DROP_SCRIPT = preload("res://scripts/world/physical_drop.gd")

@export var hostile := false
@export var move_speed := 2.2
@export var health := 3
@export var detect_radius := 9.0
@export var attack_damage := 8.0
@export var meat_drops := 2

var target: Node3D = null
var wander_direction := Vector3.ZERO
var wander_timer := 0.0
var attack_cooldown := 0.0
var gravity := 18.0
var walk_phase := 0.0
var leg_pivots: Array[Node3D] = []

func _ready() -> void:
    add_to_group("damageable")
    add_to_group("interactable")
    add_to_group("wildlife")
    collision_layer = 2
    collision_mask = 1
    if hostile:
        _build_boar_visual()
    else:
        _build_deer_visual()
    _pick_wander_direction()

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
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
    _animate_legs(delta)

func _get_wander_direction() -> Vector3:
    if wander_timer <= 0.0:
        _pick_wander_direction()
    return wander_direction

func _pick_wander_direction() -> void:
    wander_timer = randf_range(2.5, 6.0)
    var angle := randf_range(0.0, TAU)
    wander_direction = Vector3(cos(angle), 0.0, sin(angle))

func _animate_legs(delta: float) -> void:
    if leg_pivots.is_empty():
        return
    var horizontal_speed := Vector2(velocity.x, velocity.z).length()
    var moving := horizontal_speed > 0.2 and is_on_floor()
    if moving:
        walk_phase += delta * clamp(horizontal_speed * 3.0, 5.5, 13.0)
    for i in range(leg_pivots.size()):
        var target_angle := 0.0
        if moving:
            var phase_offset := 0.0 if i % 2 == 0 else PI
            target_angle = sin(walk_phase + phase_offset) * 0.42
        leg_pivots[i].rotation.x = lerp(leg_pivots[i].rotation.x, target_angle, delta * 10.0)

func take_hit(tool_id: String, attacker: Node) -> void:
    var damage := 2 if tool_id == "spear" and GameState.get_amount("spear") > 0 else 1
    health -= damage
    if is_instance_valid(attacker):
        var away: Vector3 = global_position - attacker.global_position
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

func _material(color: Color, roughness := 0.94) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    return material

func _part(mesh: Mesh, material: Material, position: Vector3, scale_value := Vector3.ONE, rotation_value := Vector3.ZERO, parent: Node3D = null) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.mesh = mesh
    part.material_override = material
    part.position = position
    part.scale = scale_value
    part.rotation = rotation_value
    var target_parent: Node3D = parent if parent != null else self
    target_parent.add_child(part)
    return part

func _create_leg(position: Vector3, material: Material, hoof_material: Material, length := 0.72) -> void:
    var pivot := Node3D.new()
    pivot.position = position
    add_child(pivot)
    leg_pivots.append(pivot)

    var leg_mesh := CylinderMesh.new()
    leg_mesh.top_radius = 0.075
    leg_mesh.bottom_radius = 0.095
    leg_mesh.height = length
    leg_mesh.radial_segments = 6
    _part(leg_mesh, material, Vector3(0, -length * 0.42, 0), Vector3.ONE, Vector3.ZERO, pivot)

    var hoof_mesh := BoxMesh.new()
    hoof_mesh.size = Vector3(0.17, 0.12, 0.25)
    _part(hoof_mesh, hoof_material, Vector3(0, -length * 0.82, -0.04), Vector3.ONE, Vector3.ZERO, pivot)

func _build_deer_visual() -> void:
    var fur := _material(Color("#9b7048"))
    var fur_light := _material(Color("#c49a6b"))
    var dark := _material(Color("#251d18"), 0.88)
    var antler_mat := _material(Color("#66513d"), 0.9)

    var body_mesh := SphereMesh.new()
    body_mesh.radius = 0.56
    body_mesh.height = 1.0
    body_mesh.radial_segments = 10
    body_mesh.rings = 6
    _part(body_mesh, fur, Vector3(0, 1.05, 0.08), Vector3(0.95, 0.9, 1.5))

    var chest_mesh := SphereMesh.new()
    chest_mesh.radius = 0.39
    chest_mesh.height = 0.72
    chest_mesh.radial_segments = 9
    chest_mesh.rings = 5
    _part(chest_mesh, fur_light, Vector3(0, 1.16, -0.45), Vector3(0.9, 1.0, 0.9))

    var neck_mesh := CylinderMesh.new()
    neck_mesh.top_radius = 0.2
    neck_mesh.bottom_radius = 0.3
    neck_mesh.height = 0.9
    neck_mesh.radial_segments = 8
    _part(neck_mesh, fur, Vector3(0, 1.55, -0.64), Vector3.ONE, Vector3(deg_to_rad(-24.0), 0, 0))

    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.3
    head_mesh.height = 0.58
    head_mesh.radial_segments = 9
    head_mesh.rings = 5
    _part(head_mesh, fur, Vector3(0, 1.92, -0.9), Vector3(0.82, 0.9, 1.18))

    var muzzle_mesh := BoxMesh.new()
    muzzle_mesh.size = Vector3(0.3, 0.2, 0.38)
    _part(muzzle_mesh, fur_light, Vector3(0, 1.84, -1.16))

    var nose_mesh := BoxMesh.new()
    nose_mesh.size = Vector3(0.24, 0.15, 0.1)
    _part(nose_mesh, dark, Vector3(0, 1.84, -1.38))

    var ear_mesh := BoxMesh.new()
    ear_mesh.size = Vector3(0.15, 0.34, 0.09)
    _part(ear_mesh, fur, Vector3(-0.24, 2.18, -0.92), Vector3.ONE, Vector3(0, 0, deg_to_rad(-38.0)))
    _part(ear_mesh, fur, Vector3(0.24, 2.18, -0.92), Vector3.ONE, Vector3(0, 0, deg_to_rad(38.0)))

    var eye_mesh := SphereMesh.new()
    eye_mesh.radius = 0.04
    eye_mesh.height = 0.08
    eye_mesh.radial_segments = 6
    eye_mesh.rings = 3
    _part(eye_mesh, dark, Vector3(-0.18, 1.99, -1.13))
    _part(eye_mesh, dark, Vector3(0.18, 1.99, -1.13))

    var antler_mesh := CylinderMesh.new()
    antler_mesh.top_radius = 0.025
    antler_mesh.bottom_radius = 0.045
    antler_mesh.height = 0.52
    antler_mesh.radial_segments = 5
    _part(antler_mesh, antler_mat, Vector3(-0.16, 2.34, -0.9), Vector3.ONE, Vector3(0, 0, deg_to_rad(-20.0)))
    _part(antler_mesh, antler_mat, Vector3(0.16, 2.34, -0.9), Vector3.ONE, Vector3(0, 0, deg_to_rad(20.0)))
    _part(antler_mesh, antler_mat, Vector3(-0.3, 2.48, -0.9), Vector3(0.75, 0.75, 0.75), Vector3(0, 0, deg_to_rad(55.0)))
    _part(antler_mesh, antler_mat, Vector3(0.3, 2.48, -0.9), Vector3(0.75, 0.75, 0.75), Vector3(0, 0, deg_to_rad(-55.0)))

    _create_leg(Vector3(-0.31, 0.78, -0.42), fur, dark, 0.82)
    _create_leg(Vector3(0.31, 0.78, -0.42), fur, dark, 0.82)
    _create_leg(Vector3(-0.31, 0.78, 0.52), fur, dark, 0.82)
    _create_leg(Vector3(0.31, 0.78, 0.52), fur, dark, 0.82)

    var tail_mesh := SphereMesh.new()
    tail_mesh.radius = 0.18
    tail_mesh.height = 0.34
    tail_mesh.radial_segments = 7
    tail_mesh.rings = 4
    _part(tail_mesh, fur_light, Vector3(0, 1.18, 0.94), Vector3(0.65, 0.85, 1.0))

    var shape := CapsuleShape3D.new()
    shape.radius = 0.52
    shape.height = 1.5
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position = Vector3(0, 1.0, 0)
    collision.rotation.x = deg_to_rad(90.0)
    add_child(collision)

func _build_boar_visual() -> void:
    var fur := _material(Color("#4b3328"))
    var fur_light := _material(Color("#6f4c38"))
    var dark := _material(Color("#171513"), 0.88)
    var tusk_mat := _material(Color("#e4d7b5"), 0.72)

    var body_mesh := SphereMesh.new()
    body_mesh.radius = 0.62
    body_mesh.height = 1.08
    body_mesh.radial_segments = 10
    body_mesh.rings = 6
    _part(body_mesh, fur, Vector3(0, 0.78, 0.08), Vector3(1.16, 0.86, 1.62))

    var shoulder_mesh := SphereMesh.new()
    shoulder_mesh.radius = 0.48
    shoulder_mesh.height = 0.86
    shoulder_mesh.radial_segments = 9
    shoulder_mesh.rings = 5
    _part(shoulder_mesh, fur_light, Vector3(0, 0.88, -0.48), Vector3(1.12, 1.0, 1.08))

    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.38
    head_mesh.height = 0.66
    head_mesh.radial_segments = 9
    head_mesh.rings = 5
    _part(head_mesh, fur, Vector3(0, 0.88, -0.9), Vector3(0.95, 0.82, 1.12))

    var snout_mesh := BoxMesh.new()
    snout_mesh.size = Vector3(0.42, 0.28, 0.5)
    _part(snout_mesh, fur_light, Vector3(0, 0.76, -1.23))

    var nose_mesh := BoxMesh.new()
    nose_mesh.size = Vector3(0.34, 0.2, 0.12)
    _part(nose_mesh, dark, Vector3(0, 0.76, -1.52))

    var ear_mesh := BoxMesh.new()
    ear_mesh.size = Vector3(0.18, 0.3, 0.09)
    _part(ear_mesh, fur, Vector3(-0.27, 1.17, -0.92), Vector3.ONE, Vector3(0, 0, deg_to_rad(-28.0)))
    _part(ear_mesh, fur, Vector3(0.27, 1.17, -0.92), Vector3.ONE, Vector3(0, 0, deg_to_rad(28.0)))

    var eye_mesh := SphereMesh.new()
    eye_mesh.radius = 0.045
    eye_mesh.height = 0.09
    eye_mesh.radial_segments = 6
    eye_mesh.rings = 3
    _part(eye_mesh, dark, Vector3(-0.2, 0.94, -1.22))
    _part(eye_mesh, dark, Vector3(0.2, 0.94, -1.22))

    var tusk_mesh := CylinderMesh.new()
    tusk_mesh.top_radius = 0.025
    tusk_mesh.bottom_radius = 0.055
    tusk_mesh.height = 0.3
    tusk_mesh.radial_segments = 7
    _part(tusk_mesh, tusk_mat, Vector3(-0.22, 0.68, -1.42), Vector3.ONE, Vector3(deg_to_rad(65.0), 0, deg_to_rad(-18.0)))
    _part(tusk_mesh, tusk_mat, Vector3(0.22, 0.68, -1.42), Vector3.ONE, Vector3(deg_to_rad(65.0), 0, deg_to_rad(18.0)))

    _create_leg(Vector3(-0.4, 0.56, -0.5), fur, dark, 0.64)
    _create_leg(Vector3(0.4, 0.56, -0.5), fur, dark, 0.64)
    _create_leg(Vector3(-0.4, 0.56, 0.58), fur, dark, 0.64)
    _create_leg(Vector3(0.4, 0.56, 0.58), fur, dark, 0.64)

    var tail_mesh := CylinderMesh.new()
    tail_mesh.top_radius = 0.035
    tail_mesh.bottom_radius = 0.055
    tail_mesh.height = 0.42
    tail_mesh.radial_segments = 6
    _part(tail_mesh, fur, Vector3(0, 0.88, 1.05), Vector3.ONE, Vector3(deg_to_rad(62.0), 0, 0))

    var shape := CapsuleShape3D.new()
    shape.radius = 0.58
    shape.height = 1.45
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position = Vector3(0, 0.62, 0)
    collision.rotation.x = deg_to_rad(90.0)
    add_child(collision)
