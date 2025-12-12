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
var is_pogo_attack = false # Tracks if we are attacking DOWN

# --- NODES ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var FireballAim = $fireballPosition 

@onready var mana_bar = $CanvasLayer/ProgressBar
@onready var mana_label = $CanvasLayer/ProgressBar/ManaLabel
@onready var shop_menu = $CanvasLayer/ShopMenu 

# --- SWORD NODES ---
# Make sure you created a node named "SwordArea" inside your Player scene!
@onready var sword_area = $SwordArea 
@onready var sword_sprite = $SwordArea/Sprite2D
@onready var sword_collider = $SwordArea/CollisionShape2D

var fireball_path = preload("res://scene/fireballl_attack.tscn")

func _ready():
	current_mana = Global.max_mana
	if shop_menu: shop_menu.visible = false
	
	# Start with sword hidden and safe
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

	# --- ATTACK INPUT ---
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()

	# --- FIREBALL INPUT ---
	if Input.is_action_just_pressed("fire"):
		if current_mana >= mana_cost:
			current_mana -= mana_cost
			audio_player.play()
			if animated_sprite.flip_h: fire(PI)
			else: fire(0)

	# --- MOVEMENT ---
	if is_on_floor(): jumps_left = Global.max_jumps

	# --- AIMING ---
	if Input.is_action_just_pressed("left"):
		FireballAim.position.x = -9
		sword_area.scale.x = -1 # Flip sword left
	if Input.is_action_just_pressed("right"):
		FireballAim.position.x = 9
		sword_area.scale.x = 1 # Flip sword right
		
	# --- POGO LOGIC (Down Attack) ---
	if not is_on_floor() and Input.is_action_pressed("down"):
		is_pogo_attack = true
		# Rotate sword to point DOWN
		sword_area.rotation_degrees = 90 * sword_area.scale.x
		sword_area.position.y = 15 # Lower it to feet
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
		direction = Input.get_axis("left", "right")
		if (direction > 0 and normal.x == -1) or (direction < 0 and normal.x == 1): velocity.x = 0
		else: velocity.x = direction * SPEED
	
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
		
	var direction := Input.get_axis("left", "right")
	
	if direction > 0: animated_sprite.flip_h = false
	elif direction < 0: animated_sprite.flip_h = true
		
	# Animations
	if not is_attacking:
		if dashing == false:
			if is_on_floor():
				if direction == 0: animated_sprite.play("Idle")
				else: animated_sprite.play("run")
			else: animated_sprite.play("jump")
		else: animated_sprite.play("Dash")
		
	if direction:
		if dashing: velocity.x = direction * DASH_SPEED
		else: velocity.x = direction * SPEED
	else: velocity.x = move_toward(velocity.x, 0, SPEED)

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
	
	# Wait for swing
	await get_tree().create_timer(0.3).timeout
	
	sword_area.monitoring = false
	sword_sprite.visible = false
	is_attacking = false

# --- HIT DETECTION ---
# IMPORTANT: Connect the 'area_entered' signal from SwordArea to this function!
func _on_sword_area_area_entered(area):
	var enemy = area.get_parent() # Gets the "Slime" node
	
	if enemy.has_method("take_damage"):
		print("Sword hit enemy!") # Watch for this in the Output window
		enemy.take_damage(sword_damage)
		
		# --- BOUNCE LOGIC ---
		if is_pogo_attack:
			velocity.y = -400 # Bounce Up!
			cand_dash = true  # Refresh Dash
		else:
			# Normal Pushback
			if animated_sprite.flip_h == false: velocity.x = -300
			else: velocity.x = 300

# Keep this for walls/boxes (Physics Bodies)
func _on_sword_area_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(sword_damage)

func _on_dash_timeout(): dashing = false
func _on_can_dash_timer_timeout() -> void: cand_dash = true
