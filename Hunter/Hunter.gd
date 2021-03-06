extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 6.5
var active = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.day or not active or Global.pause:
		$AnimationPlayer.stop()
		return
	else:
		$AnimationPlayer.play("Jumping")
		
		var dir = get_parent().get_node("Player").translation - translation
		move_and_slide(dir.normalized() * speed)
		
		if dir.length() < 1:
			$SwordHit.play()
			$HunterHitGrunt.play()
			get_parent().get_node("Player").damage()
			active = false
			$GracePeriod.start()

func _on_GracePeriod_timeout():
	active = true

func _on_BreathArea_body_entered(body):
	if not Global.day:
		if body.is_in_group("player"):
			$Breath.play()
