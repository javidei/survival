extends Area3D

func _ready() -> void:
    add_to_group("interactable")
    collision_layer = 2
    collision_mask = 0

func interact(_player: Node) -> void:
    GameState.drink(42.0)

func get_interaction_text() -> String:
    return "Beber agua"
