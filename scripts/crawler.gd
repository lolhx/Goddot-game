extends Node2D

const SPEED = 40
const DAMAGE_AMOUNT = 10 # How much it hurts the player
@export var health = 10 
@export var coins_given = 2 # Harder enemy = more coins

var is_dead = false 
var is_taking_damage = false 

# --- SENSORS ---
@onready var wall_check = $WallCheck
@onready var floor_check = $FloorCheck
@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D

func _process(delta):
	if is_dead or is_taking_damage:
		return
	
	# 1. MOVE FORWARD (Relative to rotation)
	# "transform.x" is the direction to the object's Right.
	# Since we rotate the object, this always points "Forward" along the wall.
	position += transform.x * SPEED * delta
	
	# 2. CLIMBING LOGIC
	
	if wall_check.is_colliding():
		# HIT A WALL -> Rotate -90 degrees to climb UP it
		rotation_degrees -= 90
		
	elif not floor_check.is_colliding():
		# RAN OFF LEDGE -> Rotate +90 degrees to climb DOWN it
		rotation_degrees += 90
		# We push it slightly forward/down to span the gap so it doesn't get stuck looping
		position += transform.x * SPEED * delta

func take_damage(amount, attacker_pos = null):
	if is_dead: return

	health -= amount
	
	# Visual Feedback
	animated_sprite.modulate = Color.RED
	is_taking_damage = true
	
	# --- KNOCKBACK (Along the surface) ---
	# We move BACKWARDS relative to our facing direction
	position -= transform.x * 20 
	
	await get_tree().create_timer(0.1).timeout
	
	animated_sprite.modulate = Color.WHITE
	is_taking_damage = false
	
	if health <= 0:
		die()

func die():
	is_dead = true
	Global.total_coins += coins_given
	
	# Hide sprite and disable collisions
	animated_sprite.visible = false
	if has_node("Killzone"): $Killzone.queue_free() # Remove hurtbox immediately
	
	# Play sound and delete
	audio_player.play()
	await audio_player.finished
	queue_free()
