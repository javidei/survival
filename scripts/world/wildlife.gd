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

func _ready() -> void:
    add_to_group("damageable")
    add_to_group("interactable")
    collision_layer = 2
    collision_mask = 1
    _build_visual()
    _pick_wander_direction()

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y -= gravity * delta
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    wander_timer -= delta
    if target == null or not is_instance_valid(target):
        target = get_tree().get_first_node_in_group("player") as Node3D

    var desired := Vector3.ZERO
    if hostile and is_instance_valid(target) and global_position.distance_to(target.global_position) <= detect_radius:
        var to_player: Vector3 = target.global_position - global_position
        desired = Vector3(to_player.x, 0.0, to_player.z).normalized()
        if to_player.length() < 1.55 and attack_cooldown <= 0.0:
            GameState.damage(attack_damage)
            GameState.notification.emit("Te ha atacado un jabalí")
            attack_cooldown = 1.25
    else:
        if wander_timer <= 0.0:
            _pick_wander_direction()
        desired = wander_direction

    velocity.x = desired.x * move_speed
    velocity.z = desired.z * move_speed
    if desired.length_squared() > 0.05:
        rotation.y = lerp_angle(rotation.y, atan2(-desired.x, -desired.z), delta * 5.0)
    move_and_slide()

func _pick_wander_direction() -> void:
    wander_timer = randf_range(2.5, 6.0)
    var angle := randf_range(0.0, TAU)
    wander_direction = Vector3(cos(angle), 0.0, sin(angle))

func take_hit(tool_id: String, attacker: Node) -> void:
    var damage := 2 if tool_id == "spear" and GameState.get_amount("spear") > 0 else 1
    health -= damage
    if is_instance_valid(attacker):
        var away: Vector3 = global_position - attacker.global_position
        velocity += Vector3(away.x, 0.0, away.z).normalized() * 4.0
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
    return "Jabalí hostil" if hostile else "Animal salvaje"

func _part(mesh: Mesh, material: Material, position: Vector3, scale_value := Vector3.ONE, rotation_value := Vector3.ZERO) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.mesh = mesh
    part.material_override = material
    part.position = position
    part.scale = scale_value
    part.rotation = rotation_value
    add_child(part)
    return part

func _build_visual() -> void:
    var fur := StandardMaterial3D.new()
    fur.albedo_color = Color("#4b3328") if hostile else Color("#8d6847")
    fur.roughness = 0.96

    var fur_light := StandardMaterial3D.new()
    fur_light.albedo_color = Color("#6f4c38") if hostile else Color("#b18861")
    fur_light.roughness = 0.95

    var dark := StandardMaterial3D.new()
    dark.albedo_color = Color("#171513")
    dark.roughness = 0.9

    var tusk_mat := StandardMaterial3D.new()
    tusk_mat.albedo_color = Color("#e4d7b5")
    tusk_mat.roughness = 0.72

    # Torso largo y hombros altos: silueta mucho más reconocible de jabalí.
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
    _part(snout_mesh, fur_light, Vector3(0, 0.76, -1.23), Vector3.ONE)

    var nose_mesh := BoxMesh.new()
    nose_mesh.size = Vector3(0.34, 0.2, 0.12)
    _part(nose_mesh, dark, Vector3(0, 0.76, -1.52), Vector3.ONE)

    # Orejas inclinadas.
    var ear_mesh := BoxMesh.new()
    ear_mesh.size = Vector3(0.18, 0.3, 0.09)
    _part(ear_mesh, fur, Vector3(-0.27, 1.17, -0.92), Vector3.ONE, Vector3(0, 0, deg_to_rad(-28)))
    _part(ear_mesh, fur, Vector3(0.27, 1.17, -0.92), Vector3.ONE, Vector3(0, 0, deg_to_rad(28)))

    # Ojos.
    var eye_mesh := SphereMesh.new()
    eye_mesh.radius = 0.045
    eye_mesh.height = 0.09
    eye_mesh.radial_segments = 6
    eye_mesh.rings = 3
    _part(eye_mesh, dark, Vector3(-0.2, 0.94, -1.22), Vector3.ONE)
    _part(eye_mesh, dark, Vector3(0.2, 0.94, -1.22), Vector3.ONE)

    # Colmillos a ambos lados del hocico.
    var tusk_mesh := CylinderMesh.new()
    tusk_mesh.top_radius = 0.025
    tusk_mesh.bottom_radius = 0.055
    tusk_mesh.height = 0.3
    tusk_mesh.radial_segments = 7
    _part(tusk_mesh, tusk_mat, Vector3(-0.22, 0.68, -1.42), Vector3.ONE, Vector3(deg_to_rad(65), 0, deg_to_rad(-18)))
    _part(tusk_mesh, tusk_mat, Vector3(0.22, 0.68, -1.42), Vector3.ONE, Vector3(deg_to_rad(65), 0, deg_to_rad(18)))

    # Cuatro patas diferenciadas.
    var leg_mesh := CylinderMesh.new()
    leg_mesh.top_radius = 0.11
    leg_mesh.bottom_radius = 0.13
    leg_mesh.height = 0.64
    leg_mesh.radial_segments = 7
    for p in [
        Vector3(-0.4, 0.34, -0.5), Vector3(0.4, 0.34, -0.5),
        Vector3(-0.4, 0.34, 0.58), Vector3(0.4, 0.34, 0.58)
    ]:
        _part(leg_mesh, fur, p)

    var hoof_mesh := BoxMesh.new()
    hoof_mesh.size = Vector3(0.22, 0.12, 0.3)
    for p in [
        Vector3(-0.4, 0.08, -0.55), Vector3(0.4, 0.08, -0.55),
        Vector3(-0.4, 0.08, 0.53), Vector3(0.4, 0.08, 0.53)
    ]:
        _part(hoof_mesh, dark, p)

    # Cola corta levantada.
    var tail_mesh := CylinderMesh.new()
    tail_mesh.top_radius = 0.035
    tail_mesh.bottom_radius = 0.055
    tail_mesh.height = 0.42
    tail_mesh.radial_segments = 6
    _part(tail_mesh, fur, Vector3(0, 0.88, 1.05), Vector3.ONE, Vector3(deg_to_rad(62), 0, 0))

    var shape := CapsuleShape3D.new()
    shape.radius = 0.58
    shape.height = 1.45
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position = Vector3(0, 0.62, 0)
    collision.rotation.x = deg_to_rad(90)
    add_child(collision)
