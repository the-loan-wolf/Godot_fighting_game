extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

var dive_kick = false
var jump = false
var jab = false
var jump_kick = false
var kick = false
var punch = false

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Jab":
		jab = false
	if $AnimatedSprite2D.animation == "Dive_kick":
		dive_kick = false
	if $AnimatedSprite2D.animation == "Jump":
		jump = false
	if $AnimatedSprite2D.animation == "Jump_kick":
		jump_kick = false
	if $AnimatedSprite2D.animation == "Kick":
		kick = false
	if $AnimatedSprite2D.animation == "Punch":
		punch = false

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		velocity.x = 0

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump = true
		jump_kick = false
		dive_kick = false
	
	if Input.is_action_just_pressed("Dive_kick") and is_on_floor():
		dive_kick = true
		jump_kick = false
		jump = false
		var direction = 1
		if $AnimatedSprite2D.flip_h:
			direction = -1
		velocity = Vector2(direction * SPEED, JUMP_VELOCITY)
		
	if Input.is_action_just_pressed("Jab"):
		jab = true
	if Input.is_action_just_pressed("Kick"):
		kick = true
	if Input.is_action_just_pressed("Punch"):
		punch = true 
	
		
	if Input.is_action_just_pressed("Jump_kick") and is_on_floor():
		jump_kick = true
		jump = false
		dive_kick = false
		#var direction = 1
		#if $AnimatedSprite2D.flip_h:
			#direction = -1
		#velocity = Vector2(direction * SPEED, JUMP_VELOCITY)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
		
	if direction:
		velocity.x = direction * SPEED
		#else:
			#velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	if is_on_floor():
		if velocity.x > 0:
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("Walk")
		elif velocity.x < 0:
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("Walk")
		else :
			if jab:
				$AnimatedSprite2D.play("Jab")
			elif jump_kick:
				if $AnimatedSprite2D.animation != "Jump_kick":
					$AnimatedSprite2D.play("Jump_kick")
			elif kick:
				if $AnimatedSprite2D.animation != "Kick":
					$AnimatedSprite2D.play("Kick")   
			elif punch:
				if $AnimatedSprite2D.animation != "Punch":
					$AnimatedSprite2D.play("Punch")
			else:
				$AnimatedSprite2D.play("Idle")
	if not is_on_floor():
		if dive_kick:
			if $AnimatedSprite2D.animation != "Dive_kick":
				$AnimatedSprite2D.play("Dive_kick")
		if jump:
			if $AnimatedSprite2D.animation != "Jump":
				$AnimatedSprite2D.play("Jump")
		
	
