extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var day_env = load("res://env_day.tres")
var night_env = load("res://env_night.tres")
var sun = load("res://Environment/sun.png")
var moon = load("res://Environment/moon.png")
var sun_offset

# Called when the node enters the scene tree for the first time.
func _ready():
	$WorldEnvironment.environment = day_env
	for c in get_children():
		if c.is_in_group("villager"):
			Global.villagers.append(c)
	sun_offset = $Sun.translation - $Player.translation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("day_night"):
		swap_day_night()
	$Sun.translation = $Player.translation + sun_offset

func stop_music(stop):
	if stop:
		$Music/NightMusic.stream_paused = true
		$Music/DayMusic.stream_paused = true
	else:
		if Global.day:
			$Music/DayMusic.stream_paused = false
		else:
			$Music/NightMusic.stream_paused = false

func swap_day_night():
	Global.day = not Global.day
	if (Global.day):
		$WorldEnvironment.environment = day_env
		$Sun.texture = sun
		$Music/NightMusic.stop()
		$Music/Dawn.play()
		$Light.light_energy = 2
	else:
		$WorldEnvironment.environment = night_env
		$Sun.texture = moon
		$Player.drop_body()
		$Music/DayMusic.stop()
		$Music/Dusk.play()
		$Light.light_energy = 1
	
	var villagers = Global.villagers
	for villager in villagers:
		var wr = weakref(villager)
		if wr.get_ref(): # villager might be freed...
			villager.use_sprite(Global.day)
#		else:
#			villagers.erase(villager)


func _on_Dusk_finished():
	$Music/NightMusic.play()
	$Music/NightMusic.stream_paused = false


func _on_Dawn_finished():
	$Music/DayMusic.play()
	$Music/DayMusic.stream_paused = false
