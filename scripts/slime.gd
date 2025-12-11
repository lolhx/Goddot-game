extends Node2D

const SPEED = 60

@export var health = 10 
@export var coins_given = 1 

var direction = 1
var is_dead = false 

@onready var ray_castright: RayCast2D = $RayCastright
@onready var ray_castleft: RayCast2D = $RayCastleft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _process(delta):
	if is_dead:
		return
		
	if ray_castright.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_castleft.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta

func take_damage(amount):
	if is_dead:
		return

	health -= amount
	
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	
	is_dead = true 
	
	Global.total_coins += coins_given
	print("Slime died! Total coins: ", Global.total_coins)
	
	animated_sprite.visible = false
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	if has_node("Killzone"):
		$Killzone.set_deferred("monitoring", false)
	
	audio_player.play()
	await audio_player.finished
	
	# --- NEW CRITICAL FIX ---
	# Check if the game is running at full speed (1.0).
	# If it is NOT (meaning it's 0.5 because you died), we SKIP deleting the slime.
	# This keeps the Killzone Timer alive so the level can actually reset.
	if Engine.time_scale == 1.0:
		queue_free()
