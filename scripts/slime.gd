extends Node2D

const SPEED = 60

# --- CONFIGURABLE STATS ---
@export var health = 10 
@export var coins_given = 1 

# --- INTERNAL VARIABLES ---
var direction = 1
var is_dead = false 

# --- REFERENCES ---
@onready var ray_castright: RayCast2D = $RayCastright
@onready var ray_castleft: RayCast2D = $RayCastleft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _process(delta):
	# If the slime is dead, stop all movement immediately
	if is_dead:
		return
		
	# Check for walls/edges to turn around
	if ray_castright.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_castleft.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	# Move the slime
	position.x += direction * SPEED * delta

func take_damage(amount):
	# If already dead, ignore any new damage
	if is_dead:
		return

	health -= amount
	
	# Visual Feedback: Flash Red
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	# DOUBLE CHECK: If logic already ran, stop here.
	if is_dead:
		return
	
	# 1. Set the flag so this code only runs once
	is_dead = true 
	
	# 2. Give Rewards
	Global.total_coins += coins_given
	print("Slime died! Total coins: ", Global.total_coins)
	
	# 3. Disable Visuals
	animated_sprite.visible = false
	
	# 4. Disable Collisions (CRITICAL FIX)
	# This stops the invisible slime from killing the player
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	# This stops the "Killzone" from resetting the level
	if has_node("Killzone"):
		$Killzone.set_deferred("monitoring", false)
	
	# 5. Play Sound and Delete
	audio_player.play()
	await audio_player.finished
	queue_free()
