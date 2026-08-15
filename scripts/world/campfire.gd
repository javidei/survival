extends Area3D

func _ready() -> void:
    add_to_group("interactable")
    collision_layer = 2
    collision_mask = 0

func interact(_player: Node) -> void:
    if GameState.get_amount("raw_meat") <= 0:
        GameState.notification.emit("No tienes carne cruda")
        return
    GameState.remove_resource("raw_meat", 1)
    GameState.add_resource("cooked_meat", 1)
    GameState.notification.emit("Has cocinado una ración de carne")

func get_interaction_text() -> String:
    return "Cocinar carne"
