extends Node

signal inventory_changed(inventory: Dictionary)
signal stats_changed(stats: Dictionary)
signal hotbar_changed(index: int, item_id: String)
signal recipe_changed(recipe_id: String)
signal notification(message: String)
signal player_died

const MAX_STAT := 100.0
const HOTBAR := ["axe", "pickaxe", "spear", "floor_piece", "wall_piece", "campfire"]
const RECIPE_ORDER := ["axe", "pickaxe", "spear", "floor_piece", "wall_piece", "campfire"]

const ITEM_NAMES := {
    "wood": "Madera",
    "stone": "Piedra",
    "fiber": "Fibra",
    "berry": "Bayas",
    "raw_meat": "Carne cruda",
    "cooked_meat": "Carne cocinada",
    "axe": "Hacha",
    "pickaxe": "Pico",
    "spear": "Lanza",
    "floor_piece": "Suelo",
    "wall_piece": "Pared",
    "campfire": "Hoguera",
}

const RECIPES := {
    "axe": {"wood": 4, "stone": 2, "fiber": 2},
    "pickaxe": {"wood": 3, "stone": 4, "fiber": 2},
    "spear": {"wood": 5, "stone": 1, "fiber": 2},
    "floor_piece": {"wood": 4, "fiber": 1},
    "wall_piece": {"wood": 5, "fiber": 2},
    "campfire": {"wood": 4, "stone": 6},
}

var inventory: Dictionary = {
    "wood": 6,
    "stone": 4,
    "fiber": 4,
    "berry": 2,
    "raw_meat": 0,
    "cooked_meat": 0,
    "axe": 0,
    "pickaxe": 0,
    "spear": 0,
    "floor_piece": 0,
    "wall_piece": 0,
    "campfire": 0,
}

var stats := {
    "health": MAX_STAT,
    "hunger": MAX_STAT,
    "thirst": MAX_STAT,
}

var selected_hotbar_index := 0
var selected_recipe_index := 0
var _survival_accumulator := 0.0

func _process(delta: float) -> void:
    _survival_accumulator += delta
    if _survival_accumulator < 1.0:
        return
    var elapsed := _survival_accumulator
    _survival_accumulator = 0.0
    stats.hunger = maxf(0.0, stats.hunger - 0.22 * elapsed)
    stats.thirst = maxf(0.0, stats.thirst - 0.36 * elapsed)
    if stats.hunger <= 0.0 or stats.thirst <= 0.0:
        stats.health = maxf(0.0, stats.health - 2.5 * elapsed)
    elif stats.hunger > 75.0 and stats.thirst > 75.0:
        stats.health = minf(MAX_STAT, stats.health + 0.25 * elapsed)
    stats_changed.emit(stats.duplicate())
    if stats.health <= 0.0:
        player_died.emit()

func reset_run() -> void:
    stats = {"health": MAX_STAT, "hunger": MAX_STAT, "thirst": MAX_STAT}
    stats_changed.emit(stats.duplicate())

func add_resource(resource_id: String, amount: int = 1) -> void:
    inventory[resource_id] = int(inventory.get(resource_id, 0)) + amount
    inventory_changed.emit(inventory.duplicate())

func remove_resource(resource_id: String, amount: int = 1) -> bool:
    var current := get_amount(resource_id)
    if current < amount:
        return false
    inventory[resource_id] = current - amount
    inventory_changed.emit(inventory.duplicate())
    return true

func get_amount(resource_id: String) -> int:
    return int(inventory.get(resource_id, 0))

func get_item_name(item_id: String) -> String:
    return str(ITEM_NAMES.get(item_id, item_id.capitalize()))

func select_hotbar(index: int) -> void:
    selected_hotbar_index = clampi(index, 0, HOTBAR.size() - 1)
    hotbar_changed.emit(selected_hotbar_index, get_selected_item())

func get_selected_item() -> String:
    return str(HOTBAR[selected_hotbar_index])

func has_selected_item() -> bool:
    return get_amount(get_selected_item()) > 0

func is_build_item(item_id: String) -> bool:
    return item_id in ["floor_piece", "wall_piece", "campfire"]

func get_current_recipe() -> String:
    return str(RECIPE_ORDER[selected_recipe_index])

func cycle_recipe(step: int = 1) -> void:
    selected_recipe_index = posmod(selected_recipe_index + step, RECIPE_ORDER.size())
    recipe_changed.emit(get_current_recipe())

func can_craft(recipe_id: String) -> bool:
    var costs: Dictionary = RECIPES.get(recipe_id, {})
    if costs.is_empty():
        return false
    for resource_id in costs:
        if get_amount(resource_id) < int(costs[resource_id]):
            return false
    return true

func craft(recipe_id: String) -> bool:
    if not can_craft(recipe_id):
        notification.emit("Faltan materiales para %s" % get_item_name(recipe_id))
        return false
    var costs: Dictionary = RECIPES[recipe_id]
    for resource_id in costs:
        inventory[resource_id] = get_amount(resource_id) - int(costs[resource_id])
    inventory[recipe_id] = get_amount(recipe_id) + 1
    inventory_changed.emit(inventory.duplicate())
    notification.emit("Fabricado: %s" % get_item_name(recipe_id))
    return true

func craft_current_recipe() -> bool:
    return craft(get_current_recipe())

func get_recipe_text(recipe_id: String) -> String:
    var parts: Array[String] = []
    var costs: Dictionary = RECIPES.get(recipe_id, {})
    for resource_id in costs:
        parts.append("%s %d" % [get_item_name(resource_id), int(costs[resource_id])])
    return "%s: %s" % [get_item_name(recipe_id), ", ".join(parts)]

func damage(amount: float) -> void:
    stats.health = maxf(0.0, stats.health - amount)
    stats_changed.emit(stats.duplicate())
    if stats.health <= 0.0:
        player_died.emit()

func restore(stat_id: String, amount: float) -> void:
    if not stats.has(stat_id):
        return
    stats[stat_id] = minf(MAX_STAT, float(stats[stat_id]) + amount)
    stats_changed.emit(stats.duplicate())

func drink(amount: float = 38.0) -> void:
    restore("thirst", amount)
    notification.emit("Has bebido agua")

func consume_food() -> bool:
    if remove_resource("cooked_meat", 1):
        restore("hunger", 38.0)
        restore("health", 8.0)
        notification.emit("Has comido carne cocinada")
        return true
    if remove_resource("berry", 1):
        restore("hunger", 12.0)
        restore("thirst", 4.0)
        notification.emit("Has comido bayas")
        return true
    notification.emit("No tienes comida lista para comer")
    return false
