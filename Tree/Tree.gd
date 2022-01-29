extends StaticBody

func _on_Shadow_body_entered(body):
	if body.is_in_group("player"):
		body.in_shadow = true

func _on_Shadow_body_exited(body):
	if body.is_in_group("player"):
		body.in_shadow = false
