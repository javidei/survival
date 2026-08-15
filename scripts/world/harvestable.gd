extends Area3D

const DROP_SCRIPT = preload("res://scripts/world/physical_drop.gd")

@export var resource_id := "wood"
@export var required_tool := "axe"
@export var hits_required := 4
@export var drop_amount := 4

var hits_left := 0
var _broken := false

func _ready() -> void:
    add_to_group("interactable")
    add_to_group("harvestable")
    collision_layer = 2
    collision_mask = 0
    hits_left = hits_required
    _create_solid_collision()

func _create_solid_collision() -> void:
    var solid := StaticBody3D.new()
    solid.collision_layer = 1
    solid.collision_mask = 1
    var collision := CollisionShape3D.new()
    if resource_id == "wood":
        var shape := CapsuleShape3D.new()
        shape.radius = 0.42
        shape.height = 3.8
        collision.shape = shape
        collision.position = Vector3(0, 1.9, 0)
    else:
        var shape := SphereShape3D.new()
        shape.radius = 0.55
        collision.shape = shape
        collision.position = Vector3(0, 0.4, 0)
    solid.add_child(collision)
    add_child(solid)

func harvest(tool_id: String, attacker: Node) -> void:
    if _broken:
        return
    if tool_id != required_tool or GameState.get_amount(tool_id) <= 0:
        GameState.notification.emit("Necesitas %s" % GameState.get_item_name(required_tool))
        return
    hits_left -= 1
    var original_scale := scale
    var tween := create_tween()
    tween.tween_property(self, "scale", original_scale * 0.94, 0.06)
    tween.tween_property(self, "scale", original_scale, 0.08)
    if hits_left <= 0:
        _break(attacker)
    else:
        GameState.notification.emit("%s: %d golpes" % [GameState.get_item_name(resource_id), hits_left])

func _break(attacker: Node) -> void:
    _broken = true
    monitoring = false
    for i in range(drop_amount):
        var drop := RigidBody3D.new()
        drop.set_script(DROP_SCRIPT)
        drop.set("resource_id", resource_id)
        drop.set("amount", 1)
        get_parent().add_child(drop)
        drop.global_position = global_position + Vector3(0, 1.0 + i * 0.08, 0)
        var away := Vector3(randf_range(-1.0, 1.0), randf_range(1.7, 2.8), randf_range(-1.0, 1.0)).normalized()
        if is_instance_valid(attacker):
            var from_player: Vector3 = global_position - attacker.global_position
            away += Vector3(from_player.x, 0.0, from_player.z).normalized() * 0.35
        drop.apply_central_impulse(away * randf_range(1.4, 2.4))
    GameState.notification.emit("Has obtenido %s" % GameState.get_item_name(resource_id))
    queue_free()

func get_interaction_text() -> String:
    return "%s · usar %s" % [
        "Talar" if resource_id == "wood" else "Picar",
        GameState.get_item_name(required_tool),
    ]
