extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input = get_input()
	
	move_and_slide(input)

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction

	if Input.is_action_pressed("move_forward"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.x += 1
	if Input.is_action_pressed("strafe_left"):
		input_dir.z += 1
	if Input.is_action_pressed("strafe_right"):
		input_dir.z -= 1
	input_dir = input_dir.normalized()
	return input_dir
