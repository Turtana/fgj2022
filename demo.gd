extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var day = true
var day_env = load("res://env_day.tres")
var night_env = load("res://env_night.tres")
var sun = load("res://sun.png")
var moon = load("res://moon.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$WorldEnvironment.environment = day_env


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("day_night"):
		swap_day_night()

func swap_day_night():
	day = not day
	if (day):
		print("day")
		$WorldEnvironment.environment = day_env
		$Sun.texture = sun
	else:
		print("night")
		$WorldEnvironment.environment = night_env
		$Sun.texture = moon
