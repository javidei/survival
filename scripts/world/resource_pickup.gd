extends Area3D

@export var resource_id: String = "wood"
@export var amount: int = 1
@export var interaction_label: String = "Recoger"

func _ready() -> void:
    add_to_group("interactable")

func interact(_player: Node) -> void:
    GameState.add_resource(resource_id, amount)
    GameState.notification.emit("+%d %s" % [amount, GameState.get_item_name(resource_id)])
    queue_free()

func get_interaction_text() -> String:
    return "%s %s" % [interaction_label, GameState.get_item_name(resource_id).to_lower()]
