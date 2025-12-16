extends Node2D

const SPEED = 60
const GRAVITY = 800
@export var health = 10 
@export var coins_given = 2 

var is_dead = false 
var is_taking_damage = false 
var turn_cooldown = false 

@onready var wall_check = $WallCheck
@onready var floor_check = $FloorCheck
@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	# --- 1. SETUP SENSORS ---
	if wall_check:
		wall_check.position = Vector2(5, -5)
		wall_check.target_position = Vector2(12, 0) # Slightly longer reach
		wall_check.enabled = true
		# FORCE mask to Layer 1 (World) only. Ignores Player (2) and Enemies (3)
		wall_check.collision_mask = 1 
		
	if floor_check:
		floor_check.position = Vector2(5, 0)
		floor_check.target_position = Vector2(0, 20) # Deeper reach
		floor_check.enabled = true
		# FORCE mask to Layer 1 (World) only
		floor_check.collision_mask = 1

func _process(delta):
	if is_dead or is_taking_damage:
		return
	
	# --- 2. GRAVITY (Prevents Floating) ---
	if not floor_check.is_colliding() and not wall_check.is_colliding():
		# If we are falling, fall FAST so we catch the floor
		global_position.y += 200 * delta
		return 

	# --- 3. MOVEMENT ---
	position += transform.x * SPEED * delta
	
	# --- 4. COOLDOWN ---
	if turn_cooldown:
		return

	# --- 5. TURNING LOGIC ---
	if wall_check.is_colliding():
		# Wall detected? Snap to it and rotate UP
		var collider = wall_check.get_collider()
		# Only rotate if it's actually a TileMap or World object
		if collider is TileMap or collider is StaticBody2D:
			position += transform.x * 3 # Nudge into wall
			start_turn_cooldown()
			rotation_degrees -= 90
		
	elif not floor_check.is_colliding():
		# Ledge detected? Move past edge and rotate DOWN
		position += transform.x * 5 # Nudge past corner
		start_turn_cooldown()
		rotation_degrees += 90

func start_turn_cooldown():
	turn_cooldown = true
	await get_tree().create_timer(0.2).timeout
	turn_cooldown = false

func take_damage(amount, attacker_pos = null):
	if is_dead: return
	health -= amount
	animated_sprite.modulate = Color.RED
	is_taking_damage = true
	position -= transform.x * 10 
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE
	is_taking_damage = false
	if health <= 0: die()

func die():
	is_dead = true
	Global.total_coins += coins_given
	animated_sprite.visible = false
	if has_node("Killzone"): $Killzone.queue_free()
	audio_player.play()
	await audio_player.finished
	if Engine.time_scale == 1.0: queue_free()
