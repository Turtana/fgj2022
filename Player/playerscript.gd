extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mouse_sensitivity = .001
var camera_anglev = 0
var move_speed = 5
var pause = false

var carryingBody = false
var villager = preload("res://Villager/villager.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input = get_movement_input()
	move_and_slide(input * move_speed)
	
	# action detection
	if Input.is_action_just_pressed("action"):
		$RayCast.rotation = $Camera.rotation
		var coll = $RayCast.get_collider()
		if coll:
			print(coll.name)
			if coll.is_in_group("villager") and not carryingBody:
				coll.queue_free()
				$CanvasLayer/CarryVillager.visible = true
				carryingBody = true
		else:
			if carryingBody:
				$CanvasLayer/CarryVillager.visible = false
				carryingBody = false
				var new_villager = villager.instance()
				new_villager.translation = translation - $Camera.global_transform.basis.z * 1.2
				new_villager.translation.y = 0
				get_parent().add_child(new_villager)
	
	# pause mode
	if Input.is_action_just_pressed("ui_cancel"):
		if pause:
			pause = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			pause = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	

# movement controls
func get_movement_input():
	var input_dir = Vector3()

	if Input.is_action_pressed("move_forward"):
		input_dir += -$Camera.global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += $Camera.global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -$Camera.global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += $Camera.global_transform.basis.x
	
	input_dir.y = 0
	input_dir = input_dir.normalized()
	return input_dir

# camera controls
func _unhandled_input(event):
	if pause:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		$Camera.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Camera.rotation.x = clamp($Camera.rotation.x, -1.2, 1.2)
