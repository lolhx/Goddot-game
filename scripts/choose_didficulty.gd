extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	





func _on_easy_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/game.tscn")



func _on_hard_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/game_hard.tscn")


func _on_practise_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/new_game.tscn")
