extends Node2D

const SPEED = 60
const GRAVITY = 800
@export var health = 10 
@export var coins_given = 2 

var is_dead = false 
var is_taking_damage = false 
var turn_cooldown = false 

# STATE VARIABLE
# False = Falling (Gravity On)
# True = Stuck to wall (Gravity Off, Ledge Logic On)
var is_crawling = false 

@onready var wall_check = $WallCheck
@onready var floor_check = $FloorCheck
@onready var animated_sprite = $AnimatedSprite2D
@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	# --- SENSOR SETUP ---
	if wall_check:
		wall_check.position = Vector2(5, -5)
		wall_check.target_position = Vector2(10, 0)
		wall_check.enabled = true
		wall_check.collision_mask = 1 # Only see World
		
	if floor_check:
		floor_check.position = Vector2(5, 0)
		floor_check.target_position = Vector2(0, 15)
		floor_check.enabled = true
		floor_check.collision_mask = 1 # Only see World

func _process(delta):
	if is_dead or is_taking_damage:
		return
	
	# --- PHASE 1: FALLING (Gravity) ---
	if not is_crawling:
		# Fall down
		global_position.y += 200 * delta
		
		# CHECK FOR LANDING
		if floor_check.is_colliding() or wall_check.is_colliding():
			is_crawling = true
			# Snap to the floor immediately
			if floor_check.is_colliding():
				rotation_degrees = 0
		return # Skip crawling logic while falling

	# --- PHASE 2: CRAWLING (No Gravity) ---
	
	# Move Forward
	position += transform.x * SPEED * delta
	
	if turn_cooldown: return

	# --- TURNING LOGIC ---
	if wall_check.is_colliding():
		# WALL DETECTED -> Turn Up
		position += transform.x * 2 # Nudge into wall to latch on
		start_turn_cooldown()
		rotation_degrees -= 90
		
	elif not floor_check.is_colliding():
		# LEDGE DETECTED -> Turn Down
		# Because is_crawling is true, we know this is a ledge, not air!
		position += transform.x * 5 # Move past the corner
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
