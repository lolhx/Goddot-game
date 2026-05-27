extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body):
	if body.name == "player":
		# --- NEW: Check if the player is currently Pogoing ---
		if body.is_pogo_attack:
			return # Do nothing! The player is safe while pogoing.
			
		# If not pogoing, proceed with death logic...
		if Engine.time_scale != 1.0:
			return
		
		print("you died")
		Engine.time_scale = 0.5
		Global.player_lives -= 1
		
		# Check if the collision shape exists before trying to queue_free it
		if body.has_node("CollisionShape2D"):
			body.get_node("CollisionShape2D").queue_free()
		
		timer.start()
		
		if Global.player_lives > 0:
			print("reloding scene")
		else:
			get_tree().change_scene_to_file("res://scene/game_over.tscn")

func _on_timer_timeout():
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
