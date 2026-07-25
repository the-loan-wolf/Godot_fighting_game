extends CharacterBody2D

var player = null
var punch = false

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if player == null:
		return
#
	var distance = global_position.distance_to(player.global_position)
	print(distance)
	if position.x > player.global_position.x:
		if $AnimatedSprite2D.flip_h:
			$AnimatedSprite2D.flip_h = false
			
	else:
		$AnimatedSprite2D.flip_h = true
#
	if distance < 160:
		print("Punch")
		velocity.x = 0
		punch = true
	elif distance < 250:
		print("Stand Ready")
		velocity.x = 0
		punch = false
	elif distance < 600:
		print("Walk to Player")
		punch = false
		if position.x > player.global_position.x:
			velocity.x = -100
		else:
			velocity.x = 100
	else:
		punch = false
		
	move_and_slide()
	
	if is_on_floor():
		if punch:
			#if $AnimatedSprite2D.animation != "Punch":
			$AnimatedSprite2D.play("Punch")
		else:
			if velocity.x != 0:
				$AnimatedSprite2D.play("Walk")
			else:
				$AnimatedSprite2D.play("Idle")
	





func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	player = body


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "Punch":
		punch = false
