extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#it does not work
func _player_lives(body):
	if Global.total_coins == 5: 
		Global.player_lives += 1
		print("1")
