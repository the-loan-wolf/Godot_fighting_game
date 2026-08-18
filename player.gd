extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const JUMP_VELOCITY_dive_kick = -400.0

const ANIM_IDLE = "Idle"
const ANIM_DEATH = "Death"
const ANIM_WALK = "Walk"
const ANIM_JAB = "Jab"
const ANIM_KICK = "Kick"
const ANIM_JUMP_KICK = "Jump_kick"
const ANIM_JUMP = "Jump"
const ANIM_PUNCH = "Punch"
const ANIM_DIVE_KICK = "Dive_kick"

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

@onready var sprite = $AnimatedSprite2D
@onready var collisionShape = $CollisionShape2D
@onready var hurtBox = $Hurtbox
@onready var hurtBox_collisionShape = $Hurtbox/CollisionShape2D
@onready var punch_hitbox = $hitBox_punch
@onready var punch_collisionShape = $hitBox_punch/CollisionShape2D
@onready var kick_hitbox = $hitBox_kick
@onready var kick_collisionShape = $hitBox_kick/CollisionShape2D
@onready var dive_kick_hitbox = $hitBox_dive_kick
@onready var dive_kick_collisionShape = $hitBox_dive_kick/CollisionShape2D
@onready var jump_kick_hitbox = $hitBox_jump_kick
@onready var jump_kick_collisionShape = $hitBox_jump_kick/CollisionShape2D

func _ready():
	punch_collisionShape.set_deferred("disabled", true)
	kick_collisionShape.set_deferred("disabled", true)
	dive_kick_collisionShape.set_deferred("disabled", true)
	jump_kick_collisionShape.set_deferred("disabled", true)
	hud = $"../HUD"
	add_to_group("player")

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == ANIM_JAB:
		jab = false
		punch_collisionShape.disabled = true
	if sprite.animation == ANIM_DIVE_KICK:
		dive_kick = false
		dive_kick_collisionShape.disabled = true
	if sprite.animation == ANIM_JUMP:
		jump = false
	if sprite.animation == ANIM_JUMP_KICK:
		jump_kick = false
		jump_kick_collisionShape.disabled = true
	if sprite.animation == ANIM_KICK:
		kick = false
		kick_collisionShape.disabled = true
	if sprite.animation == ANIM_PUNCH:
		punch = false
		punch_collisionShape.disabled = true

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
			if sprite.flip_h:
				direction = -1
			velocity = Vector2(direction * SPEED, JUMP_VELOCITY_dive_kick)
			flip_node(dive_kick_hitbox)
		
		if Input.is_action_just_pressed("Jump_kick") and is_on_floor():
			jump_kick = true
			jump = false
			dive_kick = false
			flip_node(jump_kick_hitbox)
		
		if Input.is_action_just_pressed("Jab"):
			jab = true
			flip_node(punch_hitbox)
		
		if Input.is_action_just_pressed("Punch"):
			punch = true
			flip_node(punch_hitbox)
		
		if Input.is_action_just_pressed("Kick"):
			kick = true 
			flip_node(kick_hitbox)
		
		
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
				if sprite.flip_h:
					sprite.flip_h = false
				flip_node(collisionShape)
				flip_node(hurtBox)
				sprite.play(ANIM_WALK)
					
			elif velocity.x < 0:
				if not sprite.flip_h:
					sprite.flip_h = true
				flip_node(collisionShape)
				flip_node(hurtBox)
				sprite.play(ANIM_WALK)
				
			else :
				if jab:
					sprite.play(ANIM_JAB)
					$Jab_sound.play()
					punch_collisionShape.set_deferred("disabled", false)
				elif jump_kick:
					if sprite.animation != ANIM_JUMP_KICK:
						sprite.play(ANIM_JUMP_KICK)
						$Jump_kick_sound.play()
						jump_kick_collisionShape.set_deferred("disabled", false)
				elif kick:
					if sprite.animation != ANIM_KICK:
						sprite.play(ANIM_KICK) 
						$kick_sound.play()
						kick_collisionShape.set_deferred("disabled", false)  
				elif punch:
					if sprite.animation != ANIM_PUNCH:
						sprite.play(ANIM_PUNCH)
						$Punch_sound.play()
						punch_collisionShape.set_deferred("disabled", false)
				else:
					sprite.play(ANIM_IDLE)
		if not is_on_floor():
			if dive_kick:
				if sprite.animation != ANIM_DIVE_KICK:
					sprite.play(ANIM_DIVE_KICK)
					$Dive_kick_sound.play()
					dive_kick_collisionShape.set_deferred("disabled", false)
			if jump:
				if sprite.animation != ANIM_JUMP:
					$Jump_sound.play()
					sprite.play(ANIM_JUMP)
					#$Jump_sound.play()
		
	


func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_attack"):
		got_hit = true

func _on_hurtbox_area_exited(area: Area2D) -> void:
	got_hit = false

func Death():
	death = true
	punch_collisionShape.set_deferred("disabled", true)
	kick_collisionShape.set_deferred("disabled", true)
	dive_kick_collisionShape.set_deferred("disabled", true)
	jump_kick_collisionShape.set_deferred("disabled", true)
	#await get_tree().create_timer(0.3).timeout
	#$Hurt_sound.play()
	#await get_tree().create_timer(1).timeout
	sprite.play(ANIM_DEATH)
	#$playerDetectionArea/CollisionShape2D.set_deferred("disabled", true)
	hurtBox_collisionShape.set_deferred("disabled", true)
	#$CollisionShape2D.set_deferred("disabled", true)
	#$head.set_deferred("disabled", true)
	await get_tree().create_timer(10).timeout
	hud.show_game_over()

func flip_node(node):
	node.position.x = abs(node.position.x)
	
	if sprite.flip_h:
		node.position.x *= -1
