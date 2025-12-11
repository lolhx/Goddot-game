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


# Add a damage variable
var damage_amount = 10

func _on_hit_box_area_entered(area):
	# Get the parent (the Slime)
	var enemy = area.get_parent()
	
	# Check if it can take damage
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage_amount)
		queue_free() # Destroy fireball
	# Fallback: if it's an old enemy with only die(), just kill it
	elif enemy.has_method("die"):
		enemy.die()
		queue_free()
