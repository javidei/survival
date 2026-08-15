extends CanvasLayer

@export var player_path: NodePath
@onready var inventory_label: Label = %InventoryLabel
@onready var prompt_label: Label = %PromptLabel
@onready var status_label: Label = %StatusLabel
@onready var player: Node = get_node_or_null(player_path)

func _ready() -> void:
    GameState.inventory_changed.connect(_on_inventory_changed)
    _on_inventory_changed(GameState.inventory)

func _process(_delta: float) -> void:
    if is_instance_valid(player) and player.has_method("get_interaction_text"):
        prompt_label.text = player.get_interaction_text()
        prompt_label.visible = not prompt_label.text.is_empty()
    status_label.text = "NARANJAL SURVIVAL  •  ALPHA 0.1.0"

func _on_inventory_changed(inventory: Dictionary) -> void:
    inventory_label.text = "Madera  %d    Piedra  %d    Fibra  %d" % [
        inventory.get("wood", 0),
        inventory.get("stone", 0),
        inventory.get("fiber", 0),
    ]
