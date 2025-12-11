extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const WALL_JUMP_VELOCITY = Vector2(750, -300)
const GRAVITY = 800.0
const WALL_SLIDE_SPEED = 30.0 

var DASH_SPEED = 400.0
var dashing = false 
var cand_dash = true

var direction = 0
var gundirection = Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- MANA VARIABLES ---
var current_mana = 0.0
var mana_cost = 20.0

# --- NODES ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var FireballAim = $fireballPosition 

# UI References
@onready var mana_bar = $CanvasLayer/ProgressBar
@onready var mana_label = $CanvasLayer/ProgressBar/ManaLabel
@onready var shop_menu = $CanvasLayer/ShopMenu 

var fireball_path = preload("res://scene/fireballl_attack.tscn")

var jumps_left = 2

func _ready():
	current_mana = Global.max_mana
	if shop_menu:
		shop_menu.visible = false

func fire(fire_direction):
	var fireball = fireball_path.instantiate()
	fireball.dir = fire_direction
	fireball.pos = $fireballPosition.global_position
	get_parent().add_child(fireball)

func _physics_process(delta):
	# --- SHOP INPUT ---
	if Input.is_action_just_pressed("shop"): 
		if shop_menu.visible:
			shop_menu.visible = false
			get_tree().paused = false 
		else:
			shop_menu.visible = true
			get_tree().paused = true 

	if get_tree().paused:
		return

	# --- MANA LOGIC ---
	if current_mana < Global.max_mana:
		current_mana += Global.mana_regen * delta
		if current_mana > Global.max_mana:
			current_mana = Global.max_mana
	
	# --- UPDATE UI ---
	if mana_bar:
		mana_bar.max_value = Global.max_mana
		mana_bar.value = current_mana
	
	if mana_label:
		mana_label.text = str(int(current_mana)) + " / " + str(int(Global.max_mana))

	# --- FIREBALL LOGIC ---
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
	
	# [CHANGE 1] Reset jumps to the Global max when hitting the floor
	if is_on_floor():
		jumps_left = Global.max_jumps

	if Input.is_action_just_pressed("left"):
		FireballAim.position.x = -9
	if Input.is_action_just_pressed("right"):
		FireballAim.position.x = 9
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_wall() and !is_on_floor():
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
		var normal = get_wall_normal()
		direction = Input.get_axis("left", "right")
		if (direction > 0 and normal.x == -1) or (direction < 0 and normal.x == 1):
			velocity.x = 0
		else:
			velocity.x = direction * SPEED
	
	if Input.is_action_just_pressed("jump"):
		if is_on_wall():
			var normal = get_wall_normal()
			velocity = Vector2(WALL_JUMP_VELOCITY.x * normal.x, WALL_JUMP_VELOCITY.y)
			
			# [CHANGE 2] Reset jumps to Global max when wall jumping
			jumps_left = Global.max_jumps
			
		elif jumps_left > 0:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
		
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
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
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
		
	if direction:
		if dashing:
			velocity.x = direction * DASH_SPEED
		else:
			velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_dash_timeout():
	dashing = false

func _on_can_dash_timer_timeout() -> void:
	cand_dash = true
