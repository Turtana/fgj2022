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
var drain_rate = 10
var in_shadow = false

var health = 100

var grunt_sounds = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$CanvasLayer/NewGameButton.visible = false
	_proload_grunts()

func pause():
	Global.pause = true
	get_parent().pause_timer(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_parent().stop_music(true)
	$CanvasLayer/NewGameButton.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# pause mode
	if Input.is_action_just_pressed("ui_cancel"):
		if Global.pause and not Global.game_over:
			Global.pause = false
			get_parent().pause_timer(false)
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_parent().stop_music(false)
			$CanvasLayer/NewGameButton.visible = false
		else:
			pause()
	
	if Global.pause:
		return
	
	var input = get_movement_input()
	move_and_slide(input * move_speed)
	
	var gravity = Vector3(0,-0.1,0)
	if input == Vector3(0,0,0):
		move_and_collide(gravity)
	else:
		move_and_collide(gravity*1/translation.length()*100)
		
		#if dir.length_squared() < 20:

	
	$RayCast.rotation = $Camera.rotation
	detect_action()
	
	# sun health draining
	if Global.day and not in_shadow:
		sun_health -= drain_rate * delta
	else:
		sun_health += drain_rate * delta * 2
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
			$WolfArms1/CarryVillagerNew.visible = true
			carryingBody = true
		if coll.is_in_group("rescue") and carryingBody:
			$WolfArms1/CarryVillagerNew.visible = false
			$Saved.play()
			carryingBody = false
			score_saved += 1
			Global.population -= 1
			update_score()
			check_win()
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
			check_win()
			yield(get_tree().create_timer(0.1), "timeout")
			random_grunts()

func damage():
	health -= 25
	if health <= 0:
		kill()

func kill():
	Global.pause = true
	Global.game_over = true
	get_parent().stop_music(true)
	$CanvasLayer/ActionText.text = "GAME OVER"
	$CanvasLayer/NewGameButton.visible = true
	$GameOver.play()
	$CanvasLayer/NewGameButton/ActionText2.visible = false
	$CanvasLayer/TimerDisplayer.stop_timer()

func check_win():
	if Global.population == 0:
		Global.pause = true
		Global.game_over = true
		get_parent().stop_music(true)
		$CanvasLayer/ActionText.text = "YOU WIN!"
		$CanvasLayer/NewGameButton.visible = true
		$YouWin.play()
		$CanvasLayer/NewGameButton/ActionText2.visible = false
		$CanvasLayer/TimerDisplayer.stop_timer()

func new_game():
	Global.reset()
	get_tree().change_scene("res://demo.tscn")

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
	
	$WolfArms1/CarryVillagerNew.visible = false
	carryingBody = false
	var new_villager = villager.instance()
	new_villager.translation = translation - $Camera.global_transform.basis.z * 1.2
	#new_villager.translation.y = 0
	Global.villagers.append(new_villager)
	get_parent().add_child(new_villager)
	

func set_hands(day):
#	$CanvasLayer/HandsHuman.visible = day
#	$CanvasLayer/HandsWolf.visible = !day
	$CanvasLayer/SunHealth.visible = day
	$CanvasLayer/Health.visible = !day

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


func _on_NewGameButton_button_up():
	new_game()

func _proload_grunts():
	randomize()
	grunt_sounds.append(preload("res://Sounds/WolfGrunts/WherewolfWolfGrowl01.wav"))
	grunt_sounds.append(preload("res://Sounds/WolfGrunts/WherewolfWolfGrowl02.wav"))
	grunt_sounds.append(preload("res://Sounds/WolfGrunts/WherewolfWolfGrowl03.wav"))
	grunt_sounds.append(preload("res://Sounds/WolfGrunts/WherewolfWolfGrowl04.wav"))
	grunt_sounds.append(preload("res://Sounds/WolfGrunts/WherewolfWolfGrowl08.wav"))

func random_grunts():
	grunt_sounds.shuffle()
	$WolfGrunt.stream=grunt_sounds.front()
	$WolfGrunt.play()
