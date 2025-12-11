extends Panel

@onready var coin_label = $CoinLabel
@onready var btn_mana_max = $BtnManaMax
@onready var btn_mana_regen = $BtnManaRegen
@onready var btn_jump = $BtnJump 

func _process(delta):
	# Update Coin UI
	coin_label.text = "Coins: " + str(Global.total_coins)
	
	# Update Button Text with current prices
	if btn_mana_max:
		btn_mana_max.text = "Max Mana (+20) \nCost: " + str(Global.cost_max_mana)
	
	if btn_mana_regen:
		btn_mana_regen.text = "Regen Speed (+5) \nCost: " + str(Global.cost_mana_regen)
	
	if btn_jump:
		btn_jump.text = "Max Jumps (+1) \nCost: " + str(Global.cost_jump_upgrade)

# --- BUTTON 1: MAX MANA ---
func _on_btn_mana_max_pressed():
	if Global.total_coins >= Global.cost_max_mana:
		Global.total_coins -= Global.cost_max_mana
		Global.max_mana += 20.0
		Global.cost_max_mana += 5
	else:
		print("Not enough money for Mana Max!")

# --- BUTTON 2: MANA REGEN ---
func _on_btn_mana_regen_pressed():
	if Global.total_coins >= Global.cost_mana_regen:
		Global.total_coins -= Global.cost_mana_regen
		Global.mana_regen += 5.0
		Global.cost_mana_regen += 5
	else:
		print("Not enough money for Mana Regen!")

# --- BUTTON 3: MAX JUMPS ---
func _on_btn_jump_pressed():
	if Global.total_coins >= Global.cost_jump_upgrade:
		Global.total_coins -= Global.cost_jump_upgrade
		Global.max_jumps += 1
		Global.cost_jump_upgrade += 10 # Increase price by 10
	else:
		print("Not enough money for Jump Upgrade!")

# --- CLOSE BUTTON ---
func _on_btn_close_pressed():
	visible = false
	get_tree().paused = false
