extends Control

const COMMODORE_FONT: Font = preload("res://assets/fonts/Commodore Pixelized v1.2.ttf")
const GAME_SCENE := "res://scenes/main.tscn"

# Se mantiene la misma base lógica de Pixel Adventure para que la composición,
# tamaños y espaciado sean equivalentes antes de escalar a 1280x720.
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
	# El texto de continuar parpadea con la misma cadencia que Pixel Adventure.
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

func _draw() -> void:
	# Negro absoluto en toda la ventana, incluyendo posibles bandas laterales.
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)

	var scale_factor := minf(size.x / VIEW_WIDTH, size.y / VIEW_HEIGHT)
	var scaled_size := BASE_SIZE * scale_factor
	var offset := (size - scaled_size) * 0.5

	# Dibuja en la misma cuadrícula virtual 320x180 de Pixel Adventure y después
	# escala el conjunto de forma uniforme. Así se conservan las proporciones.
	draw_set_transform(offset, 0.0, Vector2(scale_factor, scale_factor))
	_comm_center("BIENVENIDO A", 52.0, COL_TOP, 8)
	_comm_center("NARANJAL SURVIVAL", 82.0, COL_TEXT, 15)
	if int(Time.get_ticks_msec() / 520) % 2 == 0:
		_comm_center("PULSA PARA CONTINUAR", 114.0, COL_GOLD, 8)
	_comm_center("NARANJAL SURVIVAL - PROTOTIPO 0.2.2", 164.0, COL_VERSION, 6)
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
	# Mismo helper y misma caja horizontal que utiliza Pixel Adventure.
	draw_string(
		COMMODORE_FONT,
		Vector2(12.0, y),
		text,
		HORIZONTAL_ALIGNMENT_CENTER,
		296.0,
		font_size,
		color
	)
