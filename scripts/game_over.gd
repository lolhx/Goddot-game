extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scene/choose_Didficulty.tscn")
	Global.player_lives = 3
	Global.total_coins = 0
	
	
	
func _on_quit_pressed():
	get_tree().quit()
