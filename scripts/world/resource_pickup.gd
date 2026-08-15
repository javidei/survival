extends Area3D

@export var resource_id: String = "wood"
@export var amount: int = 1
@export var interaction_label: String = "Recoger"

func _ready() -> void:
    add_to_group("interactable")

func interact(_player: Node) -> void:
    GameState.add_resource(resource_id, amount)
    queue_free()

func get_interaction_text() -> String:
    var names := {
        "wood": "madera",
        "stone": "piedra",
        "fiber": "fibra",
    }
    return "%s %s" % [interaction_label, names.get(resource_id, resource_id)]
