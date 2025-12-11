extends CanvasLayer

@onready var lives_left: Label = $"Lives Left"
@onready var coins_collected: Label = $"Coins collected"
@onready var score: Label = $Score


func _process(delta):
	$"Coins collected".text ="" + str(Global.total_coins)
	$"Lives Left".text ="" + str(Global.player_lives)
	$Score.text =  "score:  " + str(Global.total_coins * 400 * Global.player_lives)


func _on_start_pressed():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://scene/choose_Didficulty.tscn")
	Global.player_lives = 3
	Global.total_coins = 0
	
	
	
func _on_quit_pressed():
	get_tree().quit()
