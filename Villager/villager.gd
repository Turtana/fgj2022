extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var day_sprite = preload("res://Villager/villagerPNG.png")
var night_sprite = preload("res://Villager/villagerYo.png")
var blood = preload("res://Villager/Blood.tscn")

var state = 0
var rng = RandomNumberGenerator.new()
var radius = 1
var random_position = Vector3(rng.randf_range(-radius, radius),0,rng.randf_range(-radius, radius))

var speed = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	_proload_greetings()
	_proload_help()
	rng.randomize()
	$Timer.set_autostart(true)
	
var greeting_sounds = []
var help_sounds = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.pause:
		return
	if Global.day:
		if state == 0:
			return
		if state == 1:
			random_movement()
		return
	
	var dir = translation - get_parent().get_node("Player").translation
	if dir.length_squared() < 20:
		move_and_slide(dir.normalized() * speed)

func random_movement():
#	move_and_slide(motion * speed)
	return

func use_sprite(day):
	if day:
		$Sprite.texture = day_sprite
	else:
		$Sprite.texture = night_sprite

func kill():
	var b = blood.instance()
	b.translation = translation
	b.translation.y += 2
	b.emitting = true
	get_parent().add_child(b)
	queue_free()


func _on_GreetArea_body_entered(body):
	if body.is_in_group("player"):
		if Global.day:
			random_hello()
		else:
			random_help()

func _proload_greetings():
	randomize()
	greeting_sounds.append(preload("res://Sounds/Greetings/WherewolfDayGreeting01.wav"))
	greeting_sounds.append(preload("res://Sounds/Greetings/WherewolfDayGreeting02.wav"))
	greeting_sounds.append(preload("res://Sounds/Greetings/WherewolfDayGreeting05.wav"))
	greeting_sounds.append(preload("res://Sounds/Greetings/WherewolfDayGreeting06.wav"))
	greeting_sounds.append(preload("res://Sounds/Greetings/WherewolfDayGreeting07.wav"))
	greeting_sounds.append(preload("res://Sounds/Greetings/WherewolfDayGreeting08.wav"))

func random_hello():
	greeting_sounds.shuffle()
	$Hello.stream=greeting_sounds.front()
	$Hello.play()
	
func _proload_help():
	randomize()
	help_sounds.append(preload("res://Sounds/Screams/WherewolfNightScream03.wav"))
	help_sounds.append(preload("res://Sounds/Screams/WherewolfNightScream04.wav"))
	help_sounds.append(preload("res://Sounds/Screams/WherewolfNightScream05.wav"))
	help_sounds.append(preload("res://Sounds/Screams/WherewolfNightScream06.wav"))
	help_sounds.append(preload("res://Sounds/Screams/WherewolfNightScream08.wav"))

func random_help():
	help_sounds.shuffle()
	$Help.stream=help_sounds.front()
	$Help.play()


func _on_Timer_timeout():
	rng.randomize()
	state = floor(rand_range(0,2))
	print(state)
	pass # Replace with function body.
