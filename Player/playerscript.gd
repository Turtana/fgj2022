extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mouse_sensitivity = .001
var camera_anglev = 0
var move_speed = 7
var pause = false

var carryingBody = false
var villager = preload("res://Villager/villager.tscn")

var score_saved = 0
var score_killed = 0

var sun_health = 100
var drain_rate = 3

var health = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# pause mode
	if Input.is_action_just_pressed("ui_cancel"):
		if Global.pause and not Global.game_over:
			Global.pause = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_parent().stop_music(false)
		else:
			Global.pause = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_parent().stop_music(true)
	
	if Global.pause:
		return
	
	var input = get_movement_input()
	move_and_slide(input * move_speed)
	
	$RayCast.rotation = $Camera.rotation
	detect_action()
	
	# sun health draining
	var in_shadow = false
	if Global.day and not in_shadow:
		sun_health -= drain_rate * delta
	else:
		sun_health += drain_rate * delta
	sun_health = clamp(sun_health, 0, 100)
	
	if sun_health == 0:
		kill()
	
	# UI
	$CanvasLayer/SunHealth.value = sun_health
	$CanvasLayer/Health.value = health
	
	# action detection
	if Input.is_action_just_pressed("action"):
		if (Global.day):
			day_action()
		else:
			night_action()
	
	

func day_action():
	var coll = $RayCast.get_collider()
	if coll:
		if coll.is_in_group("villager") and not carryingBody:
			coll.queue_free()
			$CanvasLayer/CarryVillager.visible = true
			carryingBody = true
		if coll.is_in_group("rescue") and carryingBody:
			$CanvasLayer/CarryVillager.visible = false
			carryingBody = false
			score_saved += 1
			Global.population -= 1
			update_score()
	else:
		if carryingBody:
			drop_body()

func night_action():
	var coll = $RayCast.get_collider()
	if coll:
		if coll.is_in_group("villager"):
			coll.kill()
			$Hit.play()
			score_killed += 1
			Global.population -= 1
			update_score()

func damage():
	health -= 25
	if health <= 0:
		kill()

func kill():
	Global.pause = true
	Global.game_over = true
	get_parent().stop_music(true)
	$CanvasLayer/ActionText.text = "GAME OVER"

func detect_action():
	var coll = $RayCast.get_collider()
	if coll == null:
		if carryingBody:
			$CanvasLayer/ActionText.text = "DROP"
		else:
			$CanvasLayer/ActionText.text = ""
		return
	
	if coll.is_in_group("villager") and not carryingBody and Global.day:
		$CanvasLayer/ActionText.text = "CARRY"
	if coll.is_in_group("villager") and not Global.day:
		$CanvasLayer/ActionText.text = "KILL"
	if coll.is_in_group("rescue") and carryingBody:
		$CanvasLayer/ActionText.text = "RESCUE"


func drop_body():
	if not carryingBody:
		return
	
	$CanvasLayer/CarryVillager.visible = false
	carryingBody = false
	var new_villager = villager.instance()
	new_villager.translation = translation - $Camera.global_transform.basis.z * 1.2
	new_villager.translation.y = 0
	Global.villagers.append(new_villager)
	get_parent().add_child(new_villager)

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

func update_score():
	$CanvasLayer/Score.text = "Saved: %s\nKilled: %s\nVillagers left: %s" % [score_saved, score_killed, Global.population]
