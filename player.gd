extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("Jump")
	
	if Input.is_action_just_pressed("Dive_kick") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("Dive_kick")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if is_on_floor():
		if direction:
			velocity.x = direction * SPEED
			if velocity.x > 0:
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.play("Walk")
			elif velocity.x < 0:
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.play("Walk")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$AnimatedSprite2D.play("Idle")
	#elif not is_on_floor():
		#if Input.is_action_just_pressed("Dive_kick"):
			#$AnimatedSprite2D.play("Dive_kick")
		#else:
			#$AnimatedSprite2D.play("Jump")
	
	

	move_and_slide()
	
	#if is_on_floor():
		#if velocity.x > 0:
			#$AnimatedSprite2D.flip_h = false
			#$AnimatedSprite2D.play("Walk")
		#elif velocity.x < 0:
			#$AnimatedSprite2D.flip_h = true
			#$AnimatedSprite2D.play("Walk")
		#else :
			#$AnimatedSprite2D.play("Idle")
	#if not is_on_floor():
		#if Input.is_action_just_pressed("Dive_kick"):
			#$AnimatedSprite2D.play("Dive_kick")
		#$AnimatedSprite2D.play("Jump")
		
		
