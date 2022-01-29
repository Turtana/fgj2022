extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.day:
		return
	else:
		var dir = get_parent().get_node("Player").translation - translation
		move_and_slide(dir.normalized() * speed)
