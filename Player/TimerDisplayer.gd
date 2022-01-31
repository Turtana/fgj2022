extends RichTextLabel

var time = 0
var timer_on = false
var mils = 0
var secs = 0
var mins = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	if(timer_on):
		time += delta
		
	var mils = fmod(time,1)*1000
	var secs = fmod(time,60)
	var mins = fmod(time, 60*60) / 60
	set_text("%02d:%02d:%03d" % [mins,secs,mils])

	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_timer():
	timer_on = true
	pass
	
func stop_timer():
	timer_on = false
	pass
func reset_timer():
	time = 0
	pass
