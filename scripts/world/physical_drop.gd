extends RigidBody3D

@export var resource_id := "wood"
@export var amount := 1

func _ready() -> void:
    add_to_group("interactable")
    collision_layer = 2
    collision_mask = 1
    mass = 0.35
    linear_damp = 1.1
    angular_damp = 1.4
    _build_visual()

func _build_visual() -> void:
    if get_child_count() > 0:
        return
    var mesh_instance := MeshInstance3D.new()
    var material := StandardMaterial3D.new()
    material.roughness = 0.88
    var collision := CollisionShape3D.new()
    var shape := SphereShape3D.new()
    shape.radius = 0.28
    collision.shape = shape
    add_child(collision)

    if resource_id == "wood":
        var mesh := CylinderMesh.new()
        mesh.top_radius = 0.13
        mesh.bottom_radius = 0.15
        mesh.height = 0.75
        mesh.radial_segments = 7
        mesh_instance.mesh = mesh
        mesh_instance.rotation.z = deg_to_rad(80.0)
        material.albedo_color = Color("#b97843")
    elif resource_id == "stone":
        var mesh := SphereMesh.new()
        mesh.radius = 0.3
        mesh.height = 0.5
        mesh.radial_segments = 7
        mesh.rings = 4
        mesh_instance.mesh = mesh
        mesh_instance.scale = Vector3(1.0, 0.72, 0.86)
        material.albedo_color = Color("#939b98")
    elif resource_id == "raw_meat":
        var mesh := SphereMesh.new()
        mesh.radius = 0.25
        mesh.height = 0.35
        mesh_instance.mesh = mesh
        mesh_instance.scale = Vector3(1.1, 0.55, 0.8)
        material.albedo_color = Color("#b84c49")
    else:
        var mesh := SphereMesh.new()
        mesh.radius = 0.22
        mesh.height = 0.4
        mesh_instance.mesh = mesh
        material.albedo_color = Color("#75ae51")
    mesh_instance.material_override = material
    add_child(mesh_instance)

func interact(_player: Node) -> void:
    GameState.add_resource(resource_id, amount)
    GameState.notification.emit("+%d %s" % [amount, GameState.get_item_name(resource_id)])
    queue_free()

func get_interaction_text() -> String:
    return "Recoger %s" % GameState.get_item_name(resource_id)
