extends Node3D

@export var player_path: NodePath
@export var grid_size := 2.0

var player: Node3D
var preview: MeshInstance3D
var preview_item := ""
var rotation_steps := 0

func _ready() -> void:
    add_to_group("build_system")
    player = get_node_or_null(player_path) as Node3D
    preview = MeshInstance3D.new()
    add_child(preview)
    preview.visible = false

func _process(_delta: float) -> void:
    if not is_instance_valid(player):
        return
    var selected := GameState.get_selected_item()
    if GameState.is_build_item(selected) and GameState.get_amount(selected) > 0:
        _update_preview(selected)
    else:
        preview.visible = false
        preview_item = ""

func rotate_preview() -> void:
    rotation_steps = posmod(rotation_steps + 1, 4)

func place_selected() -> bool:
    if not is_instance_valid(player):
        return false
    var item_id := GameState.get_selected_item()
    if not GameState.is_build_item(item_id) or GameState.get_amount(item_id) <= 0:
        return false
    var placement := _placement_transform(item_id)
    var built := _create_structure(item_id, placement)
    if built and GameState.remove_resource(item_id, 1):
        GameState.notification.emit("Colocado: %s" % GameState.get_item_name(item_id))
        return true
    return false

func _update_preview(item_id: String) -> void:
    if preview_item != item_id:
        preview_item = item_id
        preview.mesh = _mesh_for(item_id)
        var mat := StandardMaterial3D.new()
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mat.albedo_color = Color(0.45, 0.9, 0.65, 0.42)
        mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
        preview.material_override = mat
    preview.visible = true
    preview.global_transform = _placement_transform(item_id)

func _placement_transform(item_id: String) -> Transform3D:
    var forward := -player.global_transform.basis.z
    var target := player.global_position + Vector3(forward.x, 0.0, forward.z).normalized() * 3.2
    target.x = round(target.x / grid_size) * grid_size
    target.z = round(target.z / grid_size) * grid_size
    target.y = 0.12 if item_id == "floor_piece" else (1.25 if item_id == "wall_piece" else 0.3)
    var basis := Basis(Vector3.UP, rotation_steps * PI * 0.5)
    return Transform3D(basis, target)

func _mesh_for(item_id: String) -> PrimitiveMesh:
    if item_id == "wall_piece":
        var wall := BoxMesh.new()
        wall.size = Vector3(2.0, 2.5, 0.2)
        return wall
    if item_id == "campfire":
        var fire := CylinderMesh.new()
        fire.top_radius = 0.65
        fire.bottom_radius = 0.65
        fire.height = 0.25
        fire.radial_segments = 10
        return fire
    var floor := BoxMesh.new()
    floor.size = Vector3(2.0, 0.22, 2.0)
    return floor

func _create_structure(item_id: String, placement: Transform3D) -> bool:
    var body := StaticBody3D.new()
    body.global_transform = placement
    body.add_to_group("construction")

    var mesh_instance := MeshInstance3D.new()
    mesh_instance.mesh = _mesh_for(item_id)
    var mat := StandardMaterial3D.new()
    mat.roughness = 0.9
    mat.albedo_color = Color("#88623f") if item_id != "campfire" else Color("#6f6257")
    mesh_instance.material_override = mat
    body.add_child(mesh_instance)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    if item_id == "wall_piece":
        shape.size = Vector3(2.0, 2.5, 0.2)
    elif item_id == "campfire":
        shape.size = Vector3(1.2, 0.3, 1.2)
    else:
        shape.size = Vector3(2.0, 0.22, 2.0)
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

    if item_id == "campfire":
        var light := OmniLight3D.new()
        light.position = Vector3(0, 0.65, 0)
        light.light_color = Color("#ff9a48")
        light.light_energy = 1.6
        light.omni_range = 7.0
        body.add_child(light)
        var fire_mesh := SphereMesh.new()
        fire_mesh.radius = 0.28
        fire_mesh.height = 0.55
        var fire_instance := MeshInstance3D.new()
        fire_instance.position = Vector3(0, 0.45, 0)
        fire_instance.mesh = fire_mesh
        var fire_mat := StandardMaterial3D.new()
        fire_mat.albedo_color = Color("#ff7b35")
        fire_mat.emission_enabled = true
        fire_mat.emission = Color("#ff6a24")
        fire_mat.emission_energy_multiplier = 2.6
        fire_instance.material_override = fire_mat
        body.add_child(fire_instance)
    return true
