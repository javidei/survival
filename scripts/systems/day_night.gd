extends Node

signal time_changed(day: int, hour: float)

@export var sun_path: NodePath
@export var day_length_seconds := 360.0
@export var start_hour := 8.0

var day := 1
var hour := 8.0
var sun: DirectionalLight3D

func _ready() -> void:
    add_to_group("day_night")
    hour = start_hour
    sun = get_node_or_null(sun_path) as DirectionalLight3D
    _apply_light()

func _process(delta: float) -> void:
    hour += (24.0 / day_length_seconds) * delta
    if hour >= 24.0:
        hour -= 24.0
        day += 1
    _apply_light()
    time_changed.emit(day, hour)

func _apply_light() -> void:
    if not is_instance_valid(sun):
        return
    var normalized := hour / 24.0
    sun.rotation_degrees.x = normalized * 360.0 - 90.0
    sun.rotation_degrees.y = -32.0
    var daylight := clampf(sin((hour - 6.0) / 12.0 * PI), 0.0, 1.0)
    sun.light_energy = lerpf(0.05, 1.35, daylight)
    sun.light_color = Color("#ffb56b").lerp(Color("#fff1d2"), daylight)

func get_display_time() -> String:
    var hours := int(floor(hour))
    var minutes := int(floor((hour - hours) * 60.0))
    return "Día %d · %02d:%02d" % [day, hours, minutes]

func is_night() -> bool:
    return hour < 6.0 or hour >= 20.0
