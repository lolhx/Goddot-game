extends Node2D

const SPEED = 60

# --- NEW VARIABLE ---
# By using @export, you can change this number in the Editor for each slime!
@export var health = 10 

var direction = 1

@onready var ray_castright: RayCast2D = $RayCastright
@onready var ray_castleft: RayCast2D = $RayCastleft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _process(delta):
	if ray_castright.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_castleft.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	
	position.x += direction * SPEED * delta

# --- NEW FUNCTION ---
# This replaces the old direct call to die()
func take_damage(amount):
	health -= amount
	
	# Visual feedback (optional): Flash red when hit
	animated_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	animated_sprite.modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	Global.total_coins += 1
	print("Slime died! Total coins: ", Global.total_coins)
	
	animated_sprite.visible = false
	set_process(false)
	
	audio_player.play()
	await audio_player.finished
	queue_free()
