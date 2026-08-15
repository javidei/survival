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

func _build_visual() -> void:
    var body_mesh := SphereMesh.new()
    body_mesh.radius = 0.62
    body_mesh.height = 1.05
    body_mesh.radial_segments = 8
    body_mesh.rings = 4
    var body_mat := StandardMaterial3D.new()
    body_mat.albedo_color = Color("#5c4032") if hostile else Color("#b68b5a")
    body_mat.roughness = 0.92
    var body := MeshInstance3D.new()
    body.mesh = body_mesh
    body.material_override = body_mat
    body.position = Vector3(0, 0.75, 0)
    body.scale = Vector3(1.2, 0.8, 1.5)
    add_child(body)

    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.38
    head_mesh.height = 0.62
    head_mesh.radial_segments = 8
    head_mesh.rings = 4
    var head := MeshInstance3D.new()
    head.mesh = head_mesh
    head.material_override = body_mat
    head.position = Vector3(0, 0.83, -0.72)
    head.scale = Vector3(0.9, 0.75, 1.0)
    add_child(head)

    var shape := CapsuleShape3D.new()
    shape.radius = 0.55
    shape.height = 1.25
    var collision := CollisionShape3D.new()
    collision.shape = shape
    collision.position = Vector3(0, 0.62, 0)
    add_child(collision)
