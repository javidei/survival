extends Control

const COMMODORE_FONT: Font = preload("res://assets/fonts/Commodore Pixelized v1.2.ttf")
const GAME_SCENE := "res://scenes/main.tscn"

const VIEW_WIDTH := 320.0
const VIEW_HEIGHT := 180.0
const BASE_SIZE := Vector2(VIEW_WIDTH, VIEW_HEIGHT)

const COL_TEXT := Color("f3e7c8")
const COL_GOLD := Color("e5b96d")
const COL_TOP := Color("918a9c")
const COL_VERSION := Color("555564")

var changing_scene := false

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    mouse_filter = Control.MOUSE_FILTER_STOP
    queue_redraw()

func _process(_delta: float) -> void:
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)

    # Pixel Adventure se renderiza a 320x180 y luego se escala. Aquí conservamos
    # esa cuadrícula, pero obligando a que el factor de escala sea entero para
    # que el navegador no interpole los píxeles ni emborrone la tipografía.
    var raw_scale := minf(size.x / VIEW_WIDTH, size.y / VIEW_HEIGHT)
    var scale_factor := floor(raw_scale) if raw_scale >= 1.0 else raw_scale
    scale_factor = maxf(scale_factor, 0.01)
    var scaled_size := BASE_SIZE * scale_factor
    var offset := Vector2(
        floor((size.x - scaled_size.x) * 0.5),
        floor((size.y - scaled_size.y) * 0.5)
    )

    draw_set_transform(offset, 0.0, Vector2(scale_factor, scale_factor))
    _comm_center("BIENVENIDO A", 52.0, COL_TOP, 8)
    _comm_center("NARANJAL SURVIVAL", 82.0, COL_TEXT, 15)
    if int(Time.get_ticks_msec() / 520) % 2 == 0:
        _comm_center("PULSA PARA CONTINUAR", 114.0, COL_GOLD, 8)
    _comm_center("NARANJAL SURVIVAL - PROTOTIPO 0.2.4", 164.0, COL_VERSION, 6)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _input(event: InputEvent) -> void:
    if changing_scene:
        return
    if _is_activation_event(event):
        changing_scene = true
        get_viewport().set_input_as_handled()
        get_tree().change_scene_to_file(GAME_SCENE)

func _is_activation_event(event: InputEvent) -> bool:
    if event is InputEventMouseButton:
        var mouse := event as InputEventMouseButton
        return mouse.button_index == MOUSE_BUTTON_LEFT and mouse.pressed
    if event is InputEventScreenTouch:
        return (event as InputEventScreenTouch).pressed
    if event is InputEventKey:
        var key := event as InputEventKey
        return key.pressed and not key.echo
    return false

func _comm_center(text: String, y: float, color: Color, font_size: int) -> void:
    draw_string(
        COMMODORE_FONT,
        Vector2(12.0, y),
        text,
        HORIZONTAL_ALIGNMENT_CENTER,
        296.0,
        font_size,
        color
    )
