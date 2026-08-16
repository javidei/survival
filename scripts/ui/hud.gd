extends CanvasLayer

const HOTBAR_SLOT_SCRIPT = preload("res://scripts/ui/hotbar_slot.gd")

@export var player_path: NodePath
@onready var inventory_label: Label = %InventoryLabel
@onready var prompt_label: Label = %PromptLabel
@onready var status_label: Label = %StatusLabel
@onready var player: Node = get_node_or_null(player_path)

var survival_label: Label
var hotbar_container: HBoxContainer
var hotbar_name_label: Label
var hotbar_slots: Array[Control] = []
var recipe_label: Label
var notification_label: Label
var notification_time := 0.0

func _ready() -> void:
    _build_extra_labels()
    GameState.inventory_changed.connect(_on_inventory_changed)
    GameState.stats_changed.connect(_on_stats_changed)
    GameState.hotbar_changed.connect(_on_hotbar_changed)
    GameState.recipe_changed.connect(_on_recipe_changed)
    GameState.notification.connect(_on_notification)
    _on_inventory_changed(GameState.inventory)
    _on_stats_changed(GameState.stats)
    _on_hotbar_changed(GameState.selected_hotbar_index, GameState.get_selected_item())
    _on_recipe_changed(GameState.get_current_recipe())

func _process(delta: float) -> void:
    if is_instance_valid(player) and player.has_method("get_interaction_text"):
        prompt_label.text = player.get_interaction_text()
        prompt_label.visible = not prompt_label.text.is_empty()
    var day_night := get_tree().get_first_node_in_group("day_night")
    var clock_text := "Día 1 · 08:00"
    if is_instance_valid(day_night) and day_night.has_method("get_display_time"):
        clock_text = day_night.get_display_time()
    status_label.text = "NARANJAL SURVIVAL  •  ALPHA 0.2.9  •  %s" % clock_text
    if notification_time > 0.0:
        notification_time -= delta
        notification_label.visible = true
    else:
        notification_label.visible = false

func _build_extra_labels() -> void:
    survival_label = Label.new()
    survival_label.position = Vector2(20, 122)
    survival_label.add_theme_font_size_override("font_size", 16)
    survival_label.add_theme_color_override("font_color", Color(0.95, 0.97, 0.9, 1))
    add_child(survival_label)

    hotbar_name_label = Label.new()
    hotbar_name_label.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    hotbar_name_label.offset_left = -210.0
    hotbar_name_label.offset_top = -118.0
    hotbar_name_label.offset_right = 210.0
    hotbar_name_label.offset_bottom = -94.0
    hotbar_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hotbar_name_label.add_theme_font_size_override("font_size", 14)
    hotbar_name_label.add_theme_color_override("font_color", Color("#f5e5b9"))
    hotbar_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
    hotbar_name_label.add_theme_constant_override("shadow_offset_x", 1)
    hotbar_name_label.add_theme_constant_override("shadow_offset_y", 1)
    add_child(hotbar_name_label)

    hotbar_container = HBoxContainer.new()
    hotbar_container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
    hotbar_container.offset_left = -224.0
    hotbar_container.offset_top = -92.0
    hotbar_container.offset_right = 224.0
    hotbar_container.offset_bottom = -18.0
    hotbar_container.alignment = BoxContainer.ALIGNMENT_CENTER
    hotbar_container.add_theme_constant_override("separation", 6)
    add_child(hotbar_container)

    for i in range(GameState.HOTBAR.size()):
        var item_id: String = GameState.HOTBAR[i]
        var slot: Control = HOTBAR_SLOT_SCRIPT.new()
        slot.configure(i, item_id, GameState.get_item_name(item_id))
        hotbar_container.add_child(slot)
        hotbar_slots.append(slot)

    recipe_label = Label.new()
    recipe_label.position = Vector2(20, 150)
    recipe_label.size = Vector2(650, 28)
    recipe_label.add_theme_font_size_override("font_size", 14)
    recipe_label.add_theme_color_override("font_color", Color(0.84, 0.91, 0.82, 1))
    add_child(recipe_label)

    notification_label = Label.new()
    notification_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
    notification_label.position = Vector2(-260, 22)
    notification_label.size = Vector2(520, 34)
    notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    notification_label.add_theme_font_size_override("font_size", 18)
    notification_label.add_theme_color_override("font_color", Color("#ffd17a"))
    notification_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
    notification_label.add_theme_constant_override("shadow_offset_x", 2)
    notification_label.add_theme_constant_override("shadow_offset_y", 2)
    notification_label.visible = false
    add_child(notification_label)

func _on_inventory_changed(inventory: Dictionary) -> void:
    inventory_label.text = "Madera %d   Piedra %d   Fibra %d   Bayas %d   Carne %d/%d" % [
        inventory.get("wood", 0),
        inventory.get("stone", 0),
        inventory.get("fiber", 0),
        inventory.get("berry", 0),
        inventory.get("raw_meat", 0),
        inventory.get("cooked_meat", 0),
    ]
    _on_hotbar_changed(GameState.selected_hotbar_index, GameState.get_selected_item())

func _on_stats_changed(stats: Dictionary) -> void:
    survival_label.text = "VIDA %3d   HAMBRE %3d   SED %3d" % [
        int(stats.get("health", 0.0)),
        int(stats.get("hunger", 0.0)),
        int(stats.get("thirst", 0.0)),
    ]

func _on_hotbar_changed(index: int, item_id: String) -> void:
    for i in range(hotbar_slots.size()):
        var current_id: String = GameState.HOTBAR[i]
        hotbar_slots[i].update_state(i == index, GameState.get_amount(current_id))
    hotbar_name_label.text = "%s  x%d" % [GameState.get_item_name(item_id), GameState.get_amount(item_id)]

func _on_recipe_changed(recipe_id: String) -> void:
    recipe_label.text = "[C] Fabricar · [V] Cambiar receta  →  %s" % GameState.get_recipe_text(recipe_id)

func _on_notification(message: String) -> void:
    notification_label.text = message
    notification_time = 2.4
