extends RigidBody3D
class_name Player

@export var jump = 15.0
@export var move_speed = 50.0

@onready var body: CollisionShape3D = $Body
@onready var camera_pivot: Node3D = %CameraPivot

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var move_direction := Vector3.ZERO
var previous_contact_normal := Vector3.ZERO
var mouse_motion := Vector2.ZERO


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.005

	if event.is_action_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_handle_camera_rotation()
	for contact in state.get_contact_count():
		var contact_normal = state.get_contact_local_normal(contact)
		previous_contact_normal = contact_normal
		move_direction = _handle_input()
		print(move_direction)
		apply_central_force(move_direction * move_speed)
	
	transform = _align_with_gravity_point(transform,state.total_gravity.normalized())


func _handle_input() -> Vector3:
	var raw_input := Vector3.ZERO
	
	if Input.is_action_pressed("forward"):
		raw_input -= transform.basis.z
	if Input.is_action_pressed("backward"):
		raw_input += transform.basis.z
	if Input.is_action_pressed("left"):
		raw_input -= transform.basis.x
	if Input.is_action_pressed("right"):
		raw_input += transform.basis.x
	if Input.is_action_pressed("jump"):
		apply_central_impulse(transform.basis.y * jump)
		
	return raw_input


func _align_with_gravity_point(xform: Transform3D, gravity_point: Vector3) -> Transform3D:
	xform.basis.y = -gravity_point
	xform.basis.x = -xform.basis.z.cross(-gravity_point)
	xform.basis = xform.basis.orthonormalized()
	return xform


func _handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90, 90)
	mouse_motion = Vector2.ZERO
