extends Node

var total_coins = 0
var player_lives = 3

# --- PLAYER STATS (These are now Global!) ---
var max_mana = 100.0
var mana_regen = 15.0
var max_jumps = 2       # Default is 2 (Double Jump)


# --- UPGRADE COSTS ---
var cost_max_mana = 5   # Price to increase max mana
var cost_mana_regen = 5 # Price to increase regen speed
var cost_jump_upgrade = 100
