extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var day_env = load("res://env_day.tres")
var night_env = load("res://env_night.tres")
var sun = load("res://Environment/sun.png")
var moon = load("res://Environment/moon.png")
var sun_offset
var time_left_day = 999

# Called when the node enters the scene tree for the first time.
func _ready():
	$WorldEnvironment.environment = day_env
	for c in get_children():
		if c.is_in_group("villager"):
			Global.villagers.append(c)
	Global.population = Global.villagers.size()
	$Player.update_score()
	sun_offset = $Sun.translation - $Player.translation
	
	randomize()
	var cycletime = randi() % 61 + 60
	$DayCycle.start(cycletime / 2)
	$Player.pause()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.pause:
		return
	
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
	if (Global.day):
		$Music/DayMusic.stop()
		$Music/Dusk.play()
	else:
		$Music/NightMusic.stop()
		$Music/Dawn.play()

func swap_villager_sprites():
	var villagers = Global.villagers
	for villager in villagers:
		var wr = weakref(villager)
		if wr.get_ref(): # villager might be freed...
			villager.use_sprite(Global.day)

func pause_timer(pause):
	$DayCycle.paused = pause

func _on_Dusk_finished():
	Global.day = not Global.day
	$WorldEnvironment.environment = night_env
	$Sun.texture = moon
	$Player.drop_body()
	$Music/NightMusic.play()
	$Music/NightMusic.stream_paused = false
	$Light.light_energy = 1
	$Player.set_hands(false)
	swap_villager_sprites()

func _on_Dawn_finished():
	Global.day = not Global.day
	$WorldEnvironment.environment = day_env
	$Sun.texture = sun
	$Music/DayMusic.play()
	$Music/DayMusic.stream_paused = false
	$Light.light_energy = 2
	$Player.set_hands(true)
	swap_villager_sprites()


func _on_DayCycle_timeout():
	swap_day_night()
	var cycletime = randi() % 61 + 60
	$DayCycle.start(cycletime / 2)
