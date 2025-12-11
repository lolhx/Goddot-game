extends Area2D


@onready var timer: Timer = $Timer

func _on_body_entered(body):
	# Change "Player" to "player"
	if body.name == "player":
		print("you died")
		Engine.time_scale = 0.5
		Global.player_lives -= 1
		body.get_node("CollisionShape2D").queue_free()
		timer.start()
		
		if Global.player_lives > 0:
			print("reloding scene")
		else:
			get_tree().change_scene_to_file("res://scene/game_over.tscn")

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
