extends Node2D

const SPEED = 60
const GRAVITY = 800
@export var health = 10 
@export var coins_given = 2 

var is_dead = false 
var is_taking_damage = false 
var turn_cooldown = false 

# --- SENSORS ---
@onready var wall_check = $WallCheck
@onready var floor_check = $FloorCheck
@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	# --- AUTO-CORRECT SENSORS ---
	# This forces your RayCasts to the correct positions via code
	# so you don't have to worry about the Scene tab settings.
	
	if wall_check:
		# Start at "chest height" (y=-5) to avoid tripping on the floor
		wall_check.position = Vector2(5, -5)
		# Look straight forward (x=10, y=0)
		wall_check.target_position = Vector2(10, 0)
		wall_check.enabled = true
		
	if floor_check:
		# Start slightly forward (x=5) to see ledges early
		floor_check.position = Vector2(5, 0)
		# Look straight down
		floor_check.target_position = Vector2(0, 15)
		floor_check.enabled = true

func _process(delta):
	if is_dead or is_taking_damage:
		return
	
	# --- 1. GRAVITY FIX ---
	# If neither sensor hits anything, we are floating. Fall down!
	if not floor_check.is_colliding() and not wall_check.is_colliding():
		global_position.y += 150 * delta
		return # Stop crawling while falling

	# --- 2. MOVEMENT ---
	position += transform.x * SPEED * delta
	
	# --- 3. COOLDOWN ---
	# If we just turned, stop thinking for 0.2s so we don't spin
	if turn_cooldown:
		return

	# --- 4. TURNING LOGIC ---
	
	if wall_check.is_colliding():
		# HIT A WALL -> Nudge forward into it, then rotate UP (-90)
		position += transform.x * 2 
		start_turn_cooldown()
		rotation_degrees -= 90
		
	elif not floor_check.is_colliding():
		# RAN OFF LEDGE -> Nudge forward over the edge, then rotate DOWN (+90)
		position += transform.x * 5
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
	
	# Simple knockback
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
