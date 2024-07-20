extends CharacterBody3D

@onready var animation_player = $visuals/player/AnimationPlayer
@onready var visuals = $visuals

const SPEED = 2
const RUN_SPEED = 5
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var walking = false
var running = false

func _ready():
	animation_player.set_blend_time("idle", "walk", 0.2)
	animation_player.set_blend_time("walk", "idle", 0.2)
	animation_player.set_blend_time("run", "walk", 0.2)
	animation_player.set_blend_time("walk", "run", 0.2)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
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
		
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if walking:
			walking = false
			animation_player.play("idle")
		
		elif running:
			running = false
			animation_player.play("idle")

	move_and_slide()
