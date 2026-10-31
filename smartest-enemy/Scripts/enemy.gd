extends CharacterBody3D
class_name Enemy

enum States {IDLE, STALKING, FOLLOWING}
var current_state : States = States.IDLE
var Target
var idle : bool = false
var target_set : bool = false
var walk_speed : float = 3
var run_speed : float = 5
var rotation_speed : float = 2
@onready var nav_agent: NavigationAgent3D = $NavAgent
@onready var idle_timer: Timer = $IdleTimer
@onready var detect_area: Area3D = $DetectArea
@onready var detect_ray: RayCast3D = $DetectRay
@onready var state_label: Label3D = $StateLabel
@onready var rotation_mark: Marker3D = $RotationMark

func _ready() -> void:
	current_state = States.IDLE
	idle_timer.start()

func _process(delta: float) -> void:
	state_label.text = str(States.find_key(current_state))
	
	if nav_agent.target_position:
		rotation_mark.look_at(nav_agent.get_next_path_position())
		self.global_rotation.y = lerp_angle(self.global_rotation.y, rotation_mark.global_rotation.y, deg_to_rad(rotation_speed))
	
	for body in detect_area.get_overlapping_bodies():
		if body is Player:
			detect_ray.look_at(body.global_position, Vector3.UP)
			Target = body

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match current_state:
		States.IDLE:
			target_set = false
			
			if detect_ray.is_colliding():
				if detect_ray.get_collider() is Player:
					idle_timer.stop()
					current_state = States.FOLLOWING
			
			velocity.x = 0
			velocity.z = 0
			
			if !idle:
				idle = true
				idle_timer.start(5)
			
		
		States.STALKING:
			idle = false
			
			if !target_set:
				set_nav_target(choose_random_point())
			
			if detect_ray.is_colliding():
				if detect_ray.get_collider() is Player:
					idle_timer.stop()
					current_state = States.FOLLOWING
			
			var next_pos = nav_agent.get_next_path_position()
			var dir = global_position.direction_to(next_pos)
			
			dir.y = 0
			dir = dir.normalized()
			
			velocity.x = dir.x * walk_speed
			velocity.z = dir.z * walk_speed
			
			if nav_agent.is_navigation_finished():
				current_state = States.IDLE
		
		States.FOLLOWING:
			idle = false
			
			velocity.x = 0
			velocity.z = 0
			
			if Target is Player:
				set_nav_target(Target.global_position)
			
			var next_pos = nav_agent.get_next_path_position()
			var dir = global_position.direction_to(next_pos)
			
			dir.y = 0
			dir = dir.normalized()
			
			velocity.x = dir.x * run_speed
			velocity.z = dir.z * run_speed
			
			if nav_agent.is_navigation_finished():
				current_state = States.IDLE
	
	move_and_slide()

func _on_idle_timer_timeout() -> void:
	current_state = States.STALKING

func set_nav_target(pos : Vector3):
	target_set = true
	nav_agent.set_target_position(pos)
	Target = pos

func choose_random_point():
	var map = nav_agent.get_navigation_map()
	
	for i in 100:
		var offset = Vector3(
			randf_range(-50, 50),
			randf_range(-50, 50),
			randf_range(-50, 50)
		)
		
		var point = self.global_position + offset
		
		var pos = NavigationServer3D.map_get_closest_point(map, point)
		
		if global_position.distance_to(pos) > 10 and global_position.distance_to(pos) < 60:
			return pos
