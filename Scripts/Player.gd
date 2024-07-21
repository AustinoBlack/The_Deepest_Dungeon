extends CharacterBody3D

@onready var animation_player = $visuals/player/AnimationPlayer
@onready var visuals = $visuals
@onready var camera = $Pivot/Camera3D

# Movement Variables
const SPEED = 2
const RUN_SPEED = 5
const JUMP_VELOCITY = 4.5
var walking = false
var running = false
var aiming = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Camera variables
var rayorigin = Vector3()
var rayend = Vector3()

func _ready():
	animation_player.set_blend_time("idle", "walk", 0.2)
	animation_player.set_blend_time("walk", "idle", 0.2)
	animation_player.set_blend_time("run", "walk", 0.2)
	animation_player.set_blend_time("walk", "run", 0.2)
	animation_player.set_blend_time("idle", "aim_idle", 0.2)
	animation_player.set_blend_time("aim_idle", "idle", 0.2)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Handle Movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#look at cursor - probably need to move this into the direction if statement eventually
	if Input.is_action_pressed("Aim"): # if right click ( aiming )
		var space_state = get_world_3d().direct_space_state
		var mouse_position = get_viewport().get_mouse_position()
		rayorigin = camera.project_ray_origin(mouse_position)
		rayend = rayorigin + camera.project_ray_normal(mouse_position) * 2000
		var query = PhysicsRayQueryParameters3D.create(rayorigin, rayend);
		var intersection = space_state.intersect_ray(query)
		if not intersection.is_empty():
			var pos = intersection.position
			visuals.look_at(Vector3(pos.x, 0.5, pos.z), Vector3(0, 0.5, 0))
			aiming = true
			animation_player.play("aim_idle")
	
	elif direction: # if moving
		if Input.is_action_pressed("Sprint"):
			velocity.x = direction.x * RUN_SPEED
			velocity.z = direction.z * RUN_SPEED
			
			if !running:
				running = true
				animation_player.play("run")
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			
			if running:
				running = false
				animation_player.play("walk")
				
			if !walking:
				walking = true
				animation_player.play("walk")
		
		visuals.rotation.y = lerp_angle(visuals.rotation.y, atan2(-direction.x, -direction.z), delta * 10)
		
	else: # you are not moving, default to idle
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if walking:
			walking = false
			animation_player.play("idle")
		
		elif running:
			running = false
			animation_player.play("idle")
			
		elif aiming:
			aiming = false
			animation_player.play("idle")

	move_and_slide()
