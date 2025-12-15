extends Node2D

const SPEED = 60

@export var health = 10 
@export var coins_given = 1 

var direction = 1
var is_dead = false 
var is_taking_damage = false # Stops movement when hit

# Wall Detectors
@onready var ray_castright: RayCast2D = $RayCastright
@onready var ray_castleft: RayCast2D = $RayCastleft

# [NEW] Ledge Detectors (Make sure you added these in the Scene!)
@onready var ray_cast_down_right: RayCast2D = $RayCastDownRight
@onready var ray_cast_down_left: RayCast2D = $RayCastDownLeft

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _process(delta):
	# Don't move if dead or stunned by a hit
	if is_dead or is_taking_damage:
		return
	
	# --- WALL DETECTION ---
	if ray_castright.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_castleft.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
		
	# --- [NEW] LEDGE DETECTION ---
	# If we are moving Right, but there is NO floor on the right... Turn Left!
	if direction == 1 and not ray_cast_down_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
		
	# If we are moving Left, but there is NO floor on the left... Turn Right!
	if direction == -1 and not ray_cast_down_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	# Apply movement
	position.x += direction * SPEED * delta

func take_damage(amount, attacker_pos = null):
	if is_dead: return

	health -= amount
	
	# --- HIT FEEDBACK ---
	animated_sprite.modulate = Color.RED
	is_taking_damage = true
	
	# --- SMART KNOCKBACK ---
	if attacker_pos != null:
		# Calculate direction AWAY from the attacker
		# If Attacker is to the Right -> Push Left (-1)
		# If Attacker is to the Left -> Push Right (+1)
		var knockback_dir = 1
		if attacker_pos.x > global_position.x:
			knockback_dir = -1
			
		# Apply Knockback
		position.x += knockback_dir * 15 # Adjust 15 to change push distance
		
	else:
		# Fallback (Old logic) if we forget to pass position
		position.x += -direction * 10 
	
	await get_tree().create_timer(0.1).timeout
	
	# Reset
	animated_sprite.modulate = Color.WHITE
	is_taking_damage = false
	
	if health <= 0:
		die()

func die():
	if is_dead: return
	
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
	
	# Check if game is running normally before deleting
	if Engine.time_scale == 1.0:
		queue_free()
