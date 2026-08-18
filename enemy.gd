extends CharacterBody2D

var player = null
var punch = false
var health = 100
var walking_speed = 150
var death = false 

@onready var hitbox_collisionShape = $hitBox/CollisionShape2D
@onready var hitbox = $hitBox
@onready var HUD = $"../HUD"
@onready var sprite = $AnimatedSprite2D
@onready var attack_sound = $Punch_sound
@onready var hurt_sound = $Hurt_sound
@onready var PlayerDetectionArea_collisionShape = $playerDetectionArea/CollisionShape2D
@onready var hurtbox_collisionShape = $hurtBox/CollisionShape2D
@onready var enemy_body = $body
@onready var enemy_head = $head

func _ready() -> void:
	#player = null
	hitbox_collisionShape.set_deferred("disabled", true)

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not punch:
		hitbox_collisionShape.set_deferred("disabled", true)
#
	if not death:
		if player and player.health > 0:
			var distance = global_position.distance_to(player.global_position) #distance between enemy & player
			#when game starts player is at left and enemy right so we've to flip
			#the enemy sprite so it look at player
			#if position.x > player.global_position.x:
				#if sprite.flip_h:
					#sprite.flip_h = false
			#else:
				#sprite.flip_h = true
			#oneliner version:
			sprite.flip_h = position.x <= player.global_position.x
			
			#Attack state
			if distance < 160:
				velocity.x = 0
				punch = true
				#keeping hitbox node on the correct side of sprite
				#if sprite.flip_h and hitbox.position.x < 0:
					#hitbox.position.x *= -1
				#elif not sprite.flip_h and hitbox.position.x > 0:
					#hitbox.position.x *= -1
				#oneliner version:
				hitbox.position.x = abs(hitbox.position.x) if sprite.flip_h else -abs(hitbox.position.x)
				
			#stand state
			elif distance < 250:
				velocity.x = 0
				punch = false
			
			#walk state
			elif distance < 600:
				punch = false
				#if position.x > player.global_position.x:
					#velocity.x = -walking_speed
				#else:
					#velocity.x = walking_speed
				#oneliner version:
				velocity.x = walking_speed * sign(player.global_position.x - global_position.x)
			else:
				punch = false
			
		move_and_slide()
		
		if is_on_floor():
			if punch:
				#if sprite.animation != "Punch":
				#print("punch is: ", punch)
				if !attack_sound.playing:
					attack_sound.play()
				sprite.play("Punch")
				if sprite.frame == 2:
					hitbox_collisionShape.set_deferred("disabled", false)
			else:
				if velocity.x != 0:
					sprite.play("Walk")
				else:
					sprite.play("Idle")
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "Punch":
		punch = false
		hitbox_collisionShape.disabled = true
		if player.got_hit:
			player.health -= 10
			HUD.update_score_player(player.health)
			if player.health <= 0 :
				if not player.death: 
					player.Death()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	#sprite.play("Hurt")
	health -= 10
	HUD.update_score_enemy(health)
	if health <= 0 :
		if not death: 
			Death()
	
func Death ():
	death = true
	hitbox_collisionShape.set_deferred("disabled", true)
	#await get_tree().create_timer(0.3).timeout
	hurt_sound.play()
	await get_tree().create_timer(1).timeout
	sprite.play("Death")
	PlayerDetectionArea_collisionShape.set_deferred("disabled", true)
	hurtbox_collisionShape.set_deferred("disabled", true)
	enemy_body.set_deferred("disabled", true)
	enemy_head.set_deferred("disabled", true)
	await get_tree().create_timer(10).timeout
	HUD.show_game_over()
