extends Node2D

const SPEED = 60

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

func die():
	# 1. Add the coin
	Global.total_coins += 1
	print("Slime died! Total coins: ", Global.total_coins)
	
	# 2. Hide the slime and stop it from moving (so it looks dead)
	animated_sprite.visible = false
	set_process(false) # Stops the _process function so it stops moving
	
	# 3. Play the sound
	audio_player.play()
	
	# 4. Wait for the sound to finish
	await audio_player.finished
	
	# 5. NOW destroy the slime
	queue_free()
