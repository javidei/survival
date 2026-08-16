extends Control

var slot_index := 0
var item_id := ""
var display_name := ""
var amount := 0
var selected := false
var ui_font: Font

func _init() -> void:
    custom_minimum_size = Vector2(68.0, 68.0)
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _ready() -> void:
    ui_font = ThemeDB.fallback_font
    queue_redraw()

func configure(index: int, id: String, label: String) -> void:
    slot_index = index
    item_id = id
    display_name = label
    queue_redraw()

func update_state(is_selected: bool, new_amount: int) -> void:
    selected = is_selected
    amount = new_amount
    queue_redraw()

func _draw() -> void:
    if ui_font == null:
        ui_font = ThemeDB.fallback_font

    var panel_rect := Rect2(Vector2.ZERO, size)
    var inner_rect := Rect2(Vector2(3.0, 3.0), size - Vector2(6.0, 6.0))
    var background := Color(0.10, 0.10, 0.09, 0.94) if amount > 0 else Color(0.075, 0.075, 0.07, 0.9)
    var border := Color("#d8b66e") if selected else Color(0.46, 0.43, 0.37, 0.95)

    draw_rect(panel_rect, Color(0.02, 0.02, 0.02, 0.82), true)
    draw_rect(inner_rect, background, true)
    draw_rect(inner_rect, border, false, 3.0 if selected else 1.5)

    if selected:
        draw_rect(Rect2(Vector2(6.0, 6.0), size - Vector2(12.0, 12.0)), Color(0.88, 0.68, 0.29, 0.08), true)

    draw_string(ui_font, Vector2(7.0, 16.0), str(slot_index + 1), HORIZONTAL_ALIGNMENT_LEFT, 18.0, 13, Color(0.94, 0.94, 0.9, 0.95))

    _draw_item_icon()

    var count_text := str(amount)
    draw_string(
        ui_font,
        Vector2(size.x - 31.0, size.y - 7.0),
        count_text,
        HORIZONTAL_ALIGNMENT_RIGHT,
        24.0,
        13,
        Color(0.94, 0.94, 0.9, 0.95) if amount > 0 else Color(0.52, 0.52, 0.5, 0.95)
    )

func _draw_item_icon() -> void:
    var icon_color := Color(0.86, 0.84, 0.75, 1.0) if amount > 0 else Color(0.40, 0.40, 0.37, 1.0)
    var wood_color := Color(0.48, 0.30, 0.16, 1.0) if amount > 0 else Color(0.30, 0.25, 0.20, 1.0)
    var stone_color := Color(0.57, 0.61, 0.62, 1.0) if amount > 0 else Color(0.35, 0.36, 0.36, 1.0)
    var fire_color := Color(1.0, 0.50, 0.17, 1.0) if amount > 0 else Color(0.45, 0.31, 0.22, 1.0)

    match item_id:
        "axe":
            draw_line(Vector2(27, 52), Vector2(42, 20), wood_color, 6.0, true)
            draw_colored_polygon(PackedVector2Array([Vector2(37, 17), Vector2(52, 19), Vector2(48, 31), Vector2(38, 28)]), stone_color)
        "pickaxe":
            draw_line(Vector2(31, 53), Vector2(38, 21), wood_color, 5.0, true)
            draw_line(Vector2(22, 21), Vector2(52, 18), stone_color, 6.0, true)
            draw_line(Vector2(22, 21), Vector2(18, 25), stone_color, 3.0, true)
            draw_line(Vector2(52, 18), Vector2(55, 23), stone_color, 3.0, true)
        "spear":
            draw_line(Vector2(23, 53), Vector2(43, 20), wood_color, 4.0, true)
            draw_colored_polygon(PackedVector2Array([Vector2(43, 11), Vector2(49, 23), Vector2(40, 21)]), stone_color)
        "floor_piece":
            draw_colored_polygon(PackedVector2Array([Vector2(17, 36), Vector2(34, 24), Vector2(53, 34), Vector2(35, 48)]), wood_color)
            draw_line(Vector2(25, 31), Vector2(44, 42), icon_color, 1.5, true)
            draw_line(Vector2(32, 27), Vector2(50, 37), icon_color, 1.5, true)
        "wall_piece":
            draw_rect(Rect2(Vector2(19, 20), Vector2(34, 31)), wood_color, true)
            draw_line(Vector2(19, 30), Vector2(53, 30), icon_color, 1.5, true)
            draw_line(Vector2(19, 40), Vector2(53, 40), icon_color, 1.5, true)
            draw_line(Vector2(31, 20), Vector2(31, 51), icon_color, 1.5, true)
            draw_line(Vector2(43, 20), Vector2(43, 51), icon_color, 1.5, true)
        "campfire":
            draw_line(Vector2(22, 49), Vector2(48, 38), wood_color, 7.0, true)
            draw_line(Vector2(23, 38), Vector2(49, 49), wood_color, 7.0, true)
            draw_colored_polygon(PackedVector2Array([Vector2(35, 16), Vector2(45, 32), Vector2(39, 42), Vector2(30, 39), Vector2(27, 31)]), fire_color)
            draw_colored_polygon(PackedVector2Array([Vector2(35, 24), Vector2(40, 33), Vector2(36, 39), Vector2(31, 34)]), icon_color)
        _:
            draw_circle(Vector2(size.x * 0.5, size.y * 0.52), 12.0, icon_color)
