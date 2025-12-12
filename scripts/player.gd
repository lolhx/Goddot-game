extends CharacterBody2D

# --- MOVEMENT SETTINGS ---
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = Vector2(750, -300)
const GRAVITY = 800.0
const WALL_SLIDE_SPEED = 30.0 
var DASH_SPEED = 400.0
var dashing = false 
var cand_dash = true

# --- INTERNAL VARIABLES ---
var direction = 0
var gundirection = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- MANA & SPELL SETTINGS ---
var current_mana = 0.0
var mana_cost = 20.0

# --- JUMP SETTINGS ---
var jumps_left = 2

# --- COMBAT SETTINGS ---
var is_attacking = false
var sword_damage = 20 # How much damage the sword does

# --- NODES ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var FireballAim = $fireballPosition 

# UI References
@onready var mana_bar = $CanvasLayer/ProgressBar
@onready var mana_label = $CanvasLayer/ProgressBar/ManaLabel
@onready var shop_menu = $CanvasLayer/ShopMenu 

# Sword References (Make sure names match exactly in your Scene Tree!)
@onready var sword_area = $SwordArea 
@onready var sword_sprite = $SwordArea/Sprite2D
@onready var sword_collider = $SwordArea/CollisionShape2D

var fireball_path = preload("res://scene/fireballl_attack.tscn")

func _ready():
	# Initialize Stats
	current_mana = Global.max_mana
	
	# Hide UI overlays
	if shop_menu:
		shop_menu.visible = false
	
	# Initialize Sword (Hidden and Safe)
	if sword_area:
		sword_area.monitoring = false
		sword_sprite.visible = false

func _physics_process(delta):
	# --- SHOP / PAUSE LOGIC ---
	if Input.is_action_just_pressed("shop"): 
		if shop_menu.visible:
			shop_menu.visible = false
			get_tree().paused = false 
		else:
			shop_menu.visible = true
			get_tree().paused = true 

	if get_tree().paused:
		return

	# --- MANA REGENERATION ---
	if current_mana < Global.max_mana:
		current_mana += Global.mana_regen * delta
		if current_mana > Global.max_mana:
			current_mana = Global.max_mana
	
	# --- UPDATE MANA UI ---
	if mana_bar:
		mana_bar.max_value = Global.max_mana
		mana_bar.value = current_mana
	if mana_label:
		mana_label.text = str(int(current_mana)) + " / " + str(int(Global.max_mana))

	# --- MELEE ATTACK INPUT ---
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	# --- FIREBALL INPUT ---
	if Input.is_action_just_pressed("fire"):
		if current_mana >= mana_cost:
			current_mana -= mana_cost
			audio_player.play()
			
			if animated_sprite.flip_h == true:
				fire(PI)
			else:
				fire(0)
		else:
			print("Not enough mana!")

	# --- MOVEMENT LOGIC ---
	
	# Reset Jumps when on floor
	if is_on_floor():
		jumps_left = Global.max_jumps

	# Aiming & Sword Direction
	if Input.is_action_just_pressed("left"):
		FireballAim.position.x = -9
		if sword_area: sword_area.scale.x = -1 # Flip sword to left
	if Input.is_action_just_pressed("right"):
		FireballAim.position.x = 9
		if sword_area: sword_area.scale.x = 1  # Flip sword to right
		
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Wall Slide & Jump
	if is_on_wall() and !is_on_floor():
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
		var normal = get_wall_normal()
		direction = Input.get_axis("left", "right")
		if (direction > 0 and normal.x == -1) or (direction < 0 and normal.x == 1):
			velocity.x = 0
		else:
			velocity.x = direction * SPEED
	
	# Jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_wall():
			var normal = get_wall_normal()
			velocity = Vector2(WALL_JUMP_VELOCITY.x * normal.x, WALL_JUMP_VELOCITY.y)
			jumps_left = Global.max_jumps # Reset jumps on wall jump
			
		elif jumps_left > 0:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
	
	# Dashing
	if Input.is_action_just_pressed("dash") and cand_dash:
		dashing = true
		cand_dash = false
		$Dash_timer.start()
		$CanDashTimer.start()
		
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	# Sprite Flipping
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
	# --- ANIMATION CONTROL ---
	# We only play movement animations if we are NOT attacking.
	if not is_attacking:
		if dashing == false:
			if is_on_floor():
				if direction == 0:
					animated_sprite.play("Idle")
				else:
					animated_sprite.play("run")
			else:
				animated_sprite.play("jump")
		else:
			animated_sprite.play("Dash")
		
	# Apply Movement
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# --- COMBAT FUNCTIONS ---

func fire(fire_direction):
	var fireball = fireball_path.instantiate()
	fireball.dir = fire_direction
	fireball.pos = $fireballPosition.global_position
	get_parent().add_child(fireball)

func attack():
	is_attacking = true
	
	# 1. Enable the Sword
	sword_sprite.visible = true
	sword_area.monitoring = true
	
	# Optional: Play an attack animation if you made one
	# animated_sprite.play("attack")
	
	# 2. Wait for the swing (0.3 seconds)
	await get_tree().create_timer(0.3).timeout
	
	# 3. Disable the Sword
	sword_area.monitoring = false
	sword_sprite.visible = false
	is_attacking = false

# This function runs when the Sword Hitbox touches something
func _on_sword_area_body_entered(body):
	if body.has_method("take_damage"):
		print("Slash! Hit enemy.")
		body.take_damage(sword_damage)
	elif body.has_method("die"):
		body.die()

# --- TIMERS ---
func _on_dash_timeout():
	dashing = false

func _on_can_dash_timer_timeout() -> void:
	cand_dash = true


func _on_sword_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var enemy = area.get_parent()
	if enemy.has_method("take_damage"):
		# Use Global damage instead of the local variable
		enemy.take_damage(Global.sword_damage)
