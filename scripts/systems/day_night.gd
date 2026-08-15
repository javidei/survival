extends Node

signal time_changed(day: int, hour: float)

@export var sun_path: NodePath
@export var day_length_seconds := 360.0
@export var start_hour := 8.0

var day := 1
var hour := 8.0
var sun: DirectionalLight3D
var world_environment: WorldEnvironment

func _ready() -> void:
    add_to_group("day_night")
    hour = start_hour
    sun = get_node_or_null(sun_path) as DirectionalLight3D
    world_environment = get_parent().get_node_or_null("WorldEnvironment") as WorldEnvironment
    _apply_light()

func _process(delta: float) -> void:
    hour += (24.0 / day_length_seconds) * delta
    if hour >= 24.0:
        hour -= 24.0
        day += 1
    _apply_light()
    time_changed.emit(day, hour)

func _apply_light() -> void:
    var normalized := hour / 24.0
    var daylight := clampf(sin((hour - 6.0) / 12.0 * PI), 0.0, 1.0)
    if is_instance_valid(sun):
        sun.rotation_degrees.x = normalized * 360.0 - 90.0
        sun.rotation_degrees.y = -32.0
        sun.light_energy = lerpf(0.025, 1.35, daylight)
        sun.light_color = Color("#7f98c9").lerp(Color("#fff1d2"), daylight)
    if is_instance_valid(world_environment) and world_environment.environment != null:
        world_environment.environment.background_energy_multiplier = lerpf(0.12, 1.0, daylight)
        world_environment.environment.fog_light_energy = lerpf(0.18, 1.0, daylight)
        world_environment.environment.fog_light_color = Color("#263852").lerp(Color("#9ebaba"), daylight)

func get_display_time() -> String:
    var hours := int(floor(hour))
    var minutes := int(floor((hour - hours) * 60.0))
    return "Día %d · %02d:%02d" % [day, hours, minutes]

func is_night() -> bool:
    return hour < 6.0 or hour >= 20.0
