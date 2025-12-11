extends CharacterBody2D

var pos:Vector2
var rota:float
var dir: float
var speed = 200

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	global_position = pos
	global_rotation = rota
	
	if dir == PI:
		animated_sprite.flip_h = true
	else:
		animated_sprite.flip_h = false

func _physics_process(delta: float) -> void:
	velocity = Vector2(speed, 0).rotated(dir)
	move_and_slide()
	
	if is_on_wall():
		queue_free()

# This is the new function triggered by the signal
func _on_hitbox_area_entered(area):
	print("Fireball hit area: ", area.name) # Debug print
	
	# Check if the parent (the Slime) has the 'die' function
	if area.get_parent().has_method("die"):
		area.get_parent().die()
		queue_free()
