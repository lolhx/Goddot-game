extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

const WALL_JUMP_VELOCITY = Vector2(750, -300)

const GRAVITY = 800.0

const WALL_SLIDE_SPEED = 30.0 # New constant for wall slide speed

var DASH_SPEED = 400.0
var dashing = false 
var cand_dash = true

var direction = 0

var gundirection = Vector2.ZERO

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
var fireball_path=preload("res://scene/fireballl_attack.tscn")
func fire(fire_direction):
	var fireball = fireball_path.instantiate()
	fireball.dir = fire_direction
	fireball.pos = $fireballPosition.global_position
	get_parent().add_child(fireball)


@onready var FireballAim = $fireballPosition # Use the copied path here

# New variable for double jump
var jumps_left = 2

func _physics_process(delta):
	# Reset jumps when on the floor
	if is_on_floor():
		jumps_left = 2

	# Check if the player can fire before doing so
	if Input.is_action_just_pressed("fire"):
		audio_player.play()
		# Correctly determine the direction without rotating the player
		if animated_sprite.flip_h == true:
			fire(PI)  # 180 degrees for left
		else:
			fire(0)  # 0 degrees for right
	
	if Input.is_action_just_pressed("left"):
		FireballAim.position.x = - 9
	if Input.is_action_just_pressed("right"):
		FireballAim.position.x =  9
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	 # Handle wall slide logic
	if is_on_wall() and !is_on_floor():
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
		# Prevent movement against the wall
		var normal = get_wall_normal()
		direction = Input.get_axis("left", "right")
		if (direction > 0 and normal.x == -1) or (direction < 0 and normal.x == 1):
			velocity.x = 0
		else:
			velocity.x = direction * SPEED
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_wall():
			var normal = get_wall_normal()
			velocity = Vector2(WALL_JUMP_VELOCITY.x * normal.x, WALL_JUMP_VELOCITY.y)
			# Reset jumps after a wall jump
			jumps_left = 2
		# Check if jumps are available
		elif jumps_left > 0:
			velocity.y = JUMP_VELOCITY
			jumps_left -= 1
		
	if Input.is_action_just_pressed("dash") and cand_dash:
		dashing = true
		cand_dash = false
		$Dash_timer.start()
		$CanDashTimer.start()
		
		
		
		
		
	# gets input direction 1,0.-1
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
	#flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
		#play animations
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

#make dash stop
func _on_dash_timeout():
	dashing =  false


func _on_can_dash_timer_timeout() -> void:
	cand_dash = true
