extends CharacterBody3D
class_name Player

var SPEED : float = 5.0
var walk_speed : float = 5
var run_speed : float = 7
const JUMP_VELOCITY = 4.5
@onready var neck: Node3D = $neck
@onready var head: Camera3D = $neck/head
var sens = 0.005

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("sprint"):
		SPEED = run_speed
	else:
		SPEED = walk_speed

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * sens)
		head.rotate_x(-event.relative.y * sens)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (neck.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
