extends CharacterBody3D

@onready var camrig = $Pivot
@onready var camera = $Pivot/Camera3D
var mouse_sensitivity := 0.001
var SPEED = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	camrig.set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Press Esc and mouse will appear again.
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		pass
		
func _physics_process(delta):
	var input_dir = Input.get_vector("move_backward", "move_forward", "move_left", "move_right")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x  * SPEED
		velocity.z = direction.z * SPEED
		$MeshInstance3D.look_at(position * direction, Vector3.UP)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	camera_follow_player()

func camera_follow_player():
	var player_pos = global_transform.origin
	camrig.global_transform.origin = player_pos
