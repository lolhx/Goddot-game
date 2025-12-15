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
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- MANA & SPELL SETTINGS ---
var current_mana = 0.0
var mana_cost = 20.0

# --- JUMP SETTINGS ---
var jumps_left = 2

# --- COMBAT SETTINGS ---
var is_attacking = false
var sword_damage = 20
var is_pogo_attack = false 

# [NEW] Input Buffer: Remembers direction presses during attacks
var buffered_direction = 0 

# --- NODES ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var FireballAim = $fireballPosition 

@onready var mana_bar = $CanvasLayer/ProgressBar
@onready var mana_label = $CanvasLayer/ProgressBar/ManaLabel
@onready var shop_menu = $CanvasLayer/ShopMenu 

# Sword References
@onready var sword_area = $SwordArea 
@onready var sword_sprite = $SwordArea/Sprite2D
@onready var sword_collider = $SwordArea/CollisionShape2D

var fireball_path = preload("res://scene/fireballl_attack.tscn")

func _ready():
	current_mana = Global.max_mana
	if shop_menu: shop_menu.visible = false
	
	if sword_area:
		sword_area.monitoring = false
		sword_sprite.visible = false

func _physics_process(delta):
	# --- SHOP ---
	if Input.is_action_just_pressed("shop"): 
		if shop_menu.visible:
			shop_menu.visible = false
			get_tree().paused = false 
		else:
			shop_menu.visible = true
			get_tree().paused = true 
	if get_tree().paused: return

	# --- MANA ---
	if current_mana < Global.max_mana:
		current_mana += Global.mana_regen * delta
		if current_mana > Global.max_mana: current_mana = Global.max_mana
	if mana_bar:
		mana_bar.max_value = Global.max_mana
		mana_bar.value = current_mana
	if mana_label:
		mana_label.text = str(int(current_mana)) + " / " + str(int(Global.max_mana))

	# --- INPUT HANDLING ---
	
	# 1. Get current input (-1, 0, or 1)
	var input_dir = Input.get_axis("left", "right")
	
	# 2. INPUT BUFFERING
	# If we are attacking, we can't turn yet. 
	# But if the player presses a key, SAVE IT into 'buffered_direction'.
	if is_attacking:
		if input_dir != 0:
			buffered_direction = input_dir
	
	# 3. ATTACK INPUT
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	# 4. FIREBALL INPUT
	if Input.is_action_just_pressed("fire"):
		if current_mana >= mana_cost:
			current_mana -= mana_cost
			audio_player.play()
			if animated_sprite.flip_h: fire(PI)
			else: fire(0)

	# --- MOVEMENT & FACING LOGIC ---
	if is_on_floor(): jumps_left = Global.max_jumps

	# Only change facing direction if we are NOT attacking
	if not is_attacking:
		
		# [NEW] Check Buffer First
		# If we have a saved turn from the attack, use it immediately!
		if buffered_direction != 0:
			input_dir = buffered_direction
			buffered_direction = 0 # Clear the buffer after using it
		
		# Apply Direction
		if input_dir > 0:
			sword_area.scale.x = 1       # Face Right
			FireballAim.position.x = 9
			animated_sprite.flip_h = false
		elif input_dir < 0:
			sword_area.scale.x = -1      # Face Left
			FireballAim.position.x = -9
			animated_sprite.flip_h = true

		# Pogo Aiming (Down + Air)
		if not is_on_floor() and Input.is_action_pressed("down"):
			is_pogo_attack = true
			sword_area.rotation_degrees = 180 
			sword_area.position.y = 10 
		else:
			is_pogo_attack = false
			sword_area.rotation_degrees = 0
			sword_area.position.y = 0

	# Gravity
	if not is_on_floor(): velocity += get_gravity() * delta

	# Wall Logic
	if is_on_wall() and !is_on_floor():
		if velocity.y > WALL_SLIDE_SPEED: velocity.y = WALL_SLIDE_SPEED
		var normal = get_wall_normal()
		if (input_dir > 0 and normal.x == -1) or (input_dir < 0 and normal.x == 1): velocity.x = 0
		else: velocity.x = input_dir * SPEED
	
	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_wall():
			var normal = get_wall_normal()
			velocity = Vector2(WALL_JUMP_VELOCITY.x * normal.x, WALL_JUMP_VELOCITY.y)
			jumps_left = Global.max_jumps
		elif jumps_left > 0:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
		
	# Dash
	if Input.is_action_just_pressed("dash") and cand_dash:
		dashing = true
		cand_dash = false
		$Dash_timer.start()
		$CanDashTimer.start()
		
	# Animations
	if not is_attacking:
		if dashing == false:
			if is_on_floor():
				if input_dir == 0: animated_sprite.play("Idle")
				else: animated_sprite.play("run")
			else: animated_sprite.play("jump")
		else: animated_sprite.play("Dash")
		
	# Apply Velocity
	if input_dir:
		if dashing: velocity.x = input_dir * DASH_SPEED
		else: velocity.x = input_dir * SPEED
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
	sword_sprite.visible = true
	sword_area.monitoring = true
	
	# --- SWEEP ANIMATION ---
	var tween = get_tree().create_tween()
	
	var start_angle
	var end_angle
	
	if is_pogo_attack:
		start_angle = 45
		end_angle = 135
	else:
		start_angle = -45 
		end_angle = 45
		
	# Flip angles if facing left
	if sword_area.scale.x == -1:
		start_angle = start_angle * -1
		end_angle = end_angle * -1
	
	sword_area.rotation_degrees = start_angle
	tween.tween_property(sword_area, "rotation_degrees", end_angle, 0.2)
	
	await get_tree().create_timer(0.2).timeout
	
	# Reset
	sword_area.monitoring = false
	sword_sprite.visible = false
	is_attacking = false
	sword_area.rotation_degrees = 0
	
	# [NEW] Check buffer immediately after attack ends!
	# This handles the "Tap" case perfectly.
	if buffered_direction != 0:
		if buffered_direction > 0:
			sword_area.scale.x = 1
			animated_sprite.flip_h = false
		elif buffered_direction < 0:
			sword_area.scale.x = -1
			animated_sprite.flip_h = true
		buffered_direction = 0

# --- HIT DETECTION ---
func _on_sword_area_area_entered(area):
	var enemy = area.get_parent()
	if enemy.has_method("take_damage"):
		enemy.take_damage(Global.sword_damage)
		if is_pogo_attack:
			velocity.y = -350 
			cand_dash = true  
		else:
			if animated_sprite.flip_h == false: velocity.x = -300
			else: velocity.x = 300

func _on_sword_area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(Global.sword_damage)

func _on_dash_timeout(): dashing = false
func _on_can_dash_timer_timeout() -> void: cand_dash = true
