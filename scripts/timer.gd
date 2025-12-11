extends Node


@onready var label = $Timerlvl1
@onready var timer = $Timer

func _ready():
	timer.start()



func time_left_to_live():
	var  time_left = timer.time_left
	#var minute = floor(time_left / 60)
	var seconds = int(time_left)
	if time_left == 0:
		get_tree().change_scene_to_file("res://scene/game_over.tscn")
	
	return [seconds]
	

		
func _process(delta):
	label.text = "%02d" % time_left_to_live()
	
