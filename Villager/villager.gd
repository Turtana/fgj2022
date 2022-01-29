extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var day_sprite = preload("res://Villager/villager_concept.png")
var night_sprite = preload("res://Villager/villager_night.png")
var blood = preload("res://Villager/Blood.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use_sprite(day):
	if day:
		$Sprite.texture = day_sprite
	else:
		$Sprite.texture = night_sprite

func kill():
	var b = blood.instance()
	b.translation = translation
	b.translation.y += 1
	b.emitting = true
	get_parent().add_child(b)
	queue_free()
