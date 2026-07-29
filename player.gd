extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const JUMP_VELOCITY_dive_kick = -400.0

var dive_kick = false
var jump = false
var jab = false
var jump_kick = false
var kick = false
var punch = false
var health = 100
var hud
var death = false
var got_hit = false

func _ready():
	$hitBox_punch/CollisionShape2D.set_deferred("disabled", true)
	$hitBox_kick/CollisionShape2D.set_deferred("disabled", true)
	$hitBox_dive_kick/CollisionShape2D.set_deferred("disabled", true)
	$hitBox_jump_kick/CollisionShape2D.set_deferred("disabled", true)
	hud = $"../HUD"
	add_to_group("player")

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Jab":
		jab = false
		$hitBox_punch/CollisionShape2D.disabled = true
	if $AnimatedSprite2D.animation == "Dive_kick":
		dive_kick = false
		$hitBox_dive_kick/CollisionShape2D.disabled = true
	if $AnimatedSprite2D.animation == "Jump":
		jump = false
	if $AnimatedSprite2D.animation == "Jump_kick":
		jump_kick = false
		$hitBox_jump_kick/CollisionShape2D.disabled = true
	if $AnimatedSprite2D.animation == "Kick":
		kick = false
		$hitBox_kick/CollisionShape2D.disabled = true
	if $AnimatedSprite2D.animation == "Punch":
		punch = false
		$hitBox_punch/CollisionShape2D.disabled = true

func _physics_process(delta: float) -> void:
	
	if not death:
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
			velocity = Vector2(direction * SPEED, JUMP_VELOCITY_dive_kick)
			if $AnimatedSprite2D.flip_h:
				if $hitBox_dive_kick.position.x > 0:
					await get_tree().create_timer(0.12).timeout
					$hitBox_dive_kick.position.x *= -1
			elif not $AnimatedSprite2D.flip_h:
				if $hitBox_dive_kick.position.x < 0:
					await get_tree().create_timer(0.12).timeout
					$hitBox_dive_kick.position.x *= -1
			
		if Input.is_action_just_pressed("Jab"):
			jab = true
			if $AnimatedSprite2D.flip_h:
				if $hitBox_punch.position.x > 0:
					$hitBox_punch.position.x *= -1
			elif not $AnimatedSprite2D.flip_h:
				if $hitBox_punch.position.x < 0:
					$hitBox_punch.position.x *= -1
					
		if Input.is_action_just_pressed("Punch"):
			punch = true
			if $AnimatedSprite2D.flip_h:
				if $hitBox_punch.position.x > 0:
					$hitBox_punch.position.x *= -1
			elif not $AnimatedSprite2D.flip_h:
				if $hitBox_punch.position.x < 0:
					$hitBox_punch.position.x *= -1
					
		if Input.is_action_just_pressed("Kick"):
			kick = true 
			if $AnimatedSprite2D.flip_h:
				if $hitBox_kick.position.x > 0:
					$hitBox_kick.position.x *= -1
			elif not $AnimatedSprite2D.flip_h:
				if $hitBox_kick.position.x < 0:
					$hitBox_kick.position.x *= -1
			
			
		
			
		if Input.is_action_just_pressed("Jump_kick") and is_on_floor():
			jump_kick = true
			jump = false
			dive_kick = false
			if $AnimatedSprite2D.flip_h:
				if $hitBox_jump_kick.position.x > 0:
					$hitBox_jump_kick.position.x *= -1
			elif not $AnimatedSprite2D.flip_h:
				if $hitBox_jump_kick.position.x < 0:
					$hitBox_jump_kick.position.x *= -1
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
				if $AnimatedSprite2D.flip_h:
					$AnimatedSprite2D.flip_h = false
					if $CollisionShape2D.position.x > 0:
						$CollisionShape2D.position.x *= -1
					if $Hurtbox.position.x > 0:
						$Hurtbox.position.x *= -1
				$AnimatedSprite2D.play("Walk")
					
			elif velocity.x < 0:
				if not $AnimatedSprite2D.flip_h:
					$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.play("Walk")
				if $AnimatedSprite2D.flip_h:
					if $CollisionShape2D.position.x < 0:
						$CollisionShape2D.position.x *= -1
					if $Hurtbox.position.x < 0:
						$Hurtbox.position.x *= -1
				
			else :
				if jab:
					$AnimatedSprite2D.play("Jab")
					$Jab_sound.play()
					$hitBox_punch/CollisionShape2D.set_deferred("disabled", false)
				elif jump_kick:
					if $AnimatedSprite2D.animation != "Jump_kick":
						$AnimatedSprite2D.play("Jump_kick")
						$Jump_kick_sound.play()
						$hitBox_jump_kick/CollisionShape2D.set_deferred("disabled", false)
				elif kick:
					if $AnimatedSprite2D.animation != "Kick":
						$AnimatedSprite2D.play("Kick") 
						$kick_sound.play()
						$hitBox_kick/CollisionShape2D.set_deferred("disabled", false)  
				elif punch:
					if $AnimatedSprite2D.animation != "Punch":
						$AnimatedSprite2D.play("Punch")
						$Punch_sound.play()
						$hitBox_punch/CollisionShape2D.set_deferred("disabled", false)
				else:
					$AnimatedSprite2D.play("Idle")
		if not is_on_floor():
			if dive_kick:
				if $AnimatedSprite2D.animation != "Dive_kick":
					$AnimatedSprite2D.play("Dive_kick")
					$Dive_kick_sound.play()
					$hitBox_dive_kick/CollisionShape2D.set_deferred("disabled", false)
			if jump:
				if $AnimatedSprite2D.animation != "Jump":
					$Jump_sound.play()
					$AnimatedSprite2D.play("Jump")
					#$Jump_sound.play()
		
	


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		got_hit = true

func _on_hurtbox_area_exited(area: Area2D) -> void:
	got_hit = false

func Death():
	death = true
	$hitBox_punch/CollisionShape2D.set_deferred("disabled", true)
	$hitBox_kick/CollisionShape2D.set_deferred("disabled", true)
	$hitBox_dive_kick/CollisionShape2D.set_deferred("disabled", true)
	$hitBox_jump_kick/CollisionShape2D.set_deferred("disabled", true)
	#await get_tree().create_timer(0.3).timeout
	#$Hurt_sound.play()
	#await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.play("Death")
	#$playerDetectionArea/CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	#$CollisionShape2D.set_deferred("disabled", true)
	#$head.set_deferred("disabled", true)
	await get_tree().create_timer(10).timeout
	hud.show_game_over()
