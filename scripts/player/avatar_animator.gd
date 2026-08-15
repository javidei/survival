extends Node3D

@export var player_path: NodePath = NodePath("..")
@onready var player: CharacterBody3D = get_node(player_path)
@onready var left_arm: Node3D = $LeftArm
@onready var right_arm: Node3D = $RightArm
@onready var left_leg: Node3D = $LeftLeg
@onready var right_leg: Node3D = $RightLeg

var walk_time := 0.0

func _process(delta: float) -> void:
    if not is_instance_valid(player):
        return

    var horizontal_speed := Vector2(player.velocity.x, player.velocity.z).length()
    var moving := horizontal_speed > 0.25 and player.is_on_floor()

    if moving:
        walk_time += delta * clamp(horizontal_speed * 1.35, 5.0, 11.0)
        var swing := sin(walk_time) * 0.5
        left_arm.rotation.x = lerp(left_arm.rotation.x, swing, delta * 12.0)
        right_arm.rotation.x = lerp(right_arm.rotation.x, -swing, delta * 12.0)
        left_leg.rotation.x = lerp(left_leg.rotation.x, -swing * 0.8, delta * 12.0)
        right_leg.rotation.x = lerp(right_leg.rotation.x, swing * 0.8, delta * 12.0)
    else:
        left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, delta * 8.0)
        right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, delta * 8.0)
        left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, delta * 8.0)
        right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, delta * 8.0)
