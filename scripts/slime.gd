extends Node2D

const SPEED = 60

var direction = 1

@onready var ray_castright: RayCast2D = $RayCastright
@onready var ray_castleft: RayCast2D = $RayCastleft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta):  # <--- Make sure this says "delta", not "de lta"
	if ray_castright.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_castleft.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta

# --- ADD THIS FUNCTION BELOW ---
func die():
	# 1. Add a coin directly to the global counter
	Global.total_coins += 1
	
	# Optional: Print to console to verify it works
	print("Slime died! Total coins: ", Global.total_coins)
	
	# 2. Destroy the slime
	queue_free()
