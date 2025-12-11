extends Node2D

const SPEED = 60

@export var health = 10 
# --- NEW CODE START ---
# This creates a box in the editor to set coins for each slime!
@export var coins_given = 1 
# --- NEW CODE END ---

var direction = 1

@onready var ray_castright: RayCast2D = $RayCastright
@onready var ray_castleft: RayCast2D = $RayCastleft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _process(delta):
	# ... (Keep this part the same) ...
	if ray_castright.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_castleft.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta

func take_damage(amount):
	# ... (Keep this part the same) ...
	health -= amount
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# --- CHANGE THIS LINE ---
	# Old: Global.total_coins += 1
	Global.total_coins += coins_given 
	# ------------------------
	
	print("Slime died! Total coins: ", Global.total_coins)
	
	animated_sprite.visible = false
	set_process(false)
	
	# (Don't forget the fix we just added for the collider!)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	if has_node("Killzone"):
		$Killzone.set_deferred("monitoring", false)
	
	audio_player.play()
	await audio_player.finished
	queue_free()
