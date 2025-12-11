extends Panel

@onready var coin_label = $CoinLabel
@onready var btn_mana_max = $BtnManaMax
@onready var btn_mana_regen = $BtnManaRegen

func _process(delta):
	# Always update coin text so we see it change
	coin_label.text = "Coins: " + str(Global.total_coins)
	
	# Update button text to show current price
	btn_mana_max.text = "Max Mana (+20) \nCost: " + str(Global.cost_max_mana)
	btn_mana_regen.text = "Regen Speed (+5) \nCost: " + str(Global.cost_mana_regen)

func _on_btn_mana_max_pressed():
	if Global.total_coins >= Global.cost_max_mana:
		# 1. Pay Coins
		Global.total_coins -= Global.cost_max_mana
		# 2. Upgrade Stat
		Global.max_mana += 20.0
		# 3. Increase Price for next time
		Global.cost_max_mana += 5
	else:
		print("Not enough money!")

func _on_btn_mana_regen_pressed():
	if Global.total_coins >= Global.cost_mana_regen:
		Global.total_coins -= Global.cost_mana_regen
		Global.mana_regen += 5.0
		Global.cost_mana_regen += 5
	else:
		print("Not enough money!")

func _on_btn_close_pressed():
	visible = false
	get_tree().paused = false
