extends Node


# Declare member variables here. Examples:
# var a = 2
var day = true
var villagers = []
var population = 0
var pause = false
var game_over = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	day = true
	villagers = []
	population = 0
	pause = false
	game_over = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
