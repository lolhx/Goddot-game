extends CanvasLayer

func _process(delta):
	$Label.text ="" + str(Global.total_coins)
	$Label2.text ="" + str(Global.player_lives)
