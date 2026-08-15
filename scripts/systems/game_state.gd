extends Node

signal inventory_changed(inventory: Dictionary)

var inventory: Dictionary = {
    "wood": 0,
    "stone": 0,
    "fiber": 0,
}

func add_resource(resource_id: String, amount: int = 1) -> void:
    inventory[resource_id] = int(inventory.get(resource_id, 0)) + amount
    inventory_changed.emit(inventory.duplicate())

func get_amount(resource_id: String) -> int:
    return int(inventory.get(resource_id, 0))
