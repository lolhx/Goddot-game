extends CanvasLayer

@onready var lives_left: Label = $"Lives Left"
@onready var coins_collected: Label = $"Coins collected"
@onready var score: Label = $Score


func _process(delta):
	$"Coins collected".text ="" + str(Global.total_coins)
	$"Lives Left".text ="" + str(Global.player_lives)
	$Score.text =  "score:  " + str(Global.total_coins * 400 * Global.player_lives)




func _on_lvl_2_hard_pressed() -> void:
		get_tree().change_scene_to_file("res://scene/lvl_2_hard.tscn")
		Global.player_lives = Global.player_lives + 3
func _on_lvl_2_easy_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/lvl_2.tscn")
	Global.player_lives = Global.player_lives + 3
