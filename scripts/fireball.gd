extends CharacterBody2D

var pos:Vector2
var rota:float
var dir: float
var speed = 200

# Get a reference to the fireball's AnimatedSprite2D node
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Set the initial position and rotation from the values passed by the player
	global_position = pos
	global_rotation = rota
	
	# Flip the fireball sprite based on the 'dir' value
	if dir == PI:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

func _physics_process(delta: float) -> void:
	# Use the 'dir' variable to rotate the velocity vector
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	
	# Check for a wall collision after moving
	if is_on_wall():
		# This function safely removes the fireball node from the scene tree
		queue_free()
