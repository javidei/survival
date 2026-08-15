extends Control

const TITLE_FONT_SOURCE: FontFile = preload("res://assets/fonts/ONESIZE_.TTF")
const REVERSE_FONT_SOURCE: FontFile = preload("res://assets/fonts/ONESR___.TTF")
const GAME_SCENE := "res://scenes/main.tscn"

const BASE_SIZE := Vector2(1280.0, 720.0)
const COL_TITLE := Color("f3e7c8")
const COL_GOLD := Color("e5b96d")
const COL_TOP := Color("918a9c")
const COL_VERSION := Color("555564")

var title_font: FontFile
var reverse_font: FontFile
var changing_scene := false

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    mouse_filter = Control.MOUSE_FILTER_STOP
    title_font = _pixel_font(TITLE_FONT_SOURCE)
    reverse_font = _pixel_font(REVERSE_FONT_SOURCE)
    queue_redraw()

func _process(_delta: float) -> void:
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        queue_redraw()

func _pixel_font(source: FontFile) -> FontFile:
    var font: FontFile = source.duplicate() as FontFile
    font.antialiasing = TextServer.FONT_ANTIALIASING_NONE
    font.hinting = TextServer.HINTING_NONE
    font.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
    font.generate_mipmaps = false
    font.multichannel_signed_distance_field = false
    font.oversampling = 1.0
    font.allow_system_fallback = false
    return font

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)

    # Render directo a la resolución real: sin lienzo 320x180 reescalado.
    # Las fuentes se rasterizan en 1 bit, sin antialiasing ni subpíxel.
    var scale_factor: float = minf(size.x / BASE_SIZE.x, size.y / BASE_SIZE.y)
    scale_factor = maxf(scale_factor, 0.1)
    var content_width: float = minf(size.x, BASE_SIZE.x * scale_factor)
    var left: float = floor((size.x - content_width) * 0.5)

    _center_text(reverse_font, "BIENVENIDO A", left, content_width, 150.0 * scale_factor, maxi(12, int(round(28.0 * scale_factor))), COL_TOP)
    _center_text(title_font, "NARANJAL SURVIVAL", left, content_width, 315.0 * scale_factor, maxi(24, int(round(64.0 * scale_factor))), COL_TITLE)

    if int(Time.get_ticks_msec() / 520) % 2 == 0:
        _center_text(title_font, "PULSA PARA CONTINUAR", left, content_width, 465.0 * scale_factor, maxi(14, int(round(32.0 * scale_factor))), COL_GOLD)

    _center_text(reverse_font, "NARANJAL SURVIVAL - PROTOTIPO 0.2.6", left, content_width, 665.0 * scale_factor, maxi(10, int(round(18.0 * scale_factor))), COL_VERSION)

func _center_text(font: Font, text: String, left: float, width: float, baseline_y: float, font_size: int, color: Color) -> void:
    draw_string(
        font,
        Vector2(round(left), round(baseline_y)),
        text,
        HORIZONTAL_ALIGNMENT_CENTER,
        round(width),
        font_size,
        color
    )

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
