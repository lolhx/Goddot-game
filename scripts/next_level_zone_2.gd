extends Area2D

@onready var timer: Timer = $Timer


func _on_body_entered(body):
	print("you won")
	
	timer.start()

	

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scene/score_level_2.tscn")
