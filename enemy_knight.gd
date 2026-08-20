extends CharacterBody2D

var player = null
var Attack = false
var health = 100
var death = false 
var attackList = ["Attack1", "Attack2", "Attack3"]
var current_attack
var current_collisionShape
var current_hitbox

@onready var HUD = $"../HUD"
@onready var Attack1_hitbox_CollisionShape = $Attack1_hitbox/CollisionShape2D
@onready var Attack1_hitbox = $Attack1_hitbox
@onready var Attack2_hitbox_CollisionShape = $Attack2_hitbox/CollisionShape2D
@onready var Attack2_hitbox = $Attack2_hitbox
@onready var Attack3_hitbox_CollisionShape = $Attack3_hitbox/CollisionShape2D
@onready var Attack3_hitbox = $Attack3_hitbox
@onready var Run_attack_hitbox_CollisionShape = $Run_Attack_hitbox/CollisionShape2D
@onready var Run_attack_hitbox = $Run_Attack_hitbox
@onready var sprite = $AnimatedSprite2D
@onready var PlayerDetectionarea_CollisionShape = $PlayerDetectionarea/CollisionShape2D
@onready var hurtbox_CollisionShape = $hurtbox/CollisionShape2D
@onready var CollisionShape = $CollisionShape2D

func _ready() -> void:
	#player = null
	Attack1_hitbox_CollisionShape.set_deferred("disabled", true)
	Attack2_hitbox_CollisionShape.set_deferred("disabled", true)
	Attack3_hitbox_CollisionShape.set_deferred("disabled", true)
	Run_attack_hitbox_CollisionShape.set_deferred("disabled", true)

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if not Attack:
		if current_collisionShape:
			current_collisionShape.set_deferred("disabled", true)
#
	if not death:
		if player and player.health > 0:
			var distance = player.global_position
			var diff = abs(distance.x - position.x)
			if position.x > distance.x:
				if not sprite.flip_h:
					sprite.flip_h = true
			else:
				sprite.flip_h = false
			#Attack state
			if diff < 160 and !Attack:
				velocity.x = 0
				start_attack()
				if sprite.flip_h:
					if current_hitbox.position.x > 0:
						current_hitbox.position.x *= -1
				elif not sprite.flip_h:
					if current_hitbox.position.x < 0:
						current_hitbox.position.x *= -1
			#stand state
			elif diff < 250:
				velocity.x = 0
			#walk state
			elif diff < 600:
				if position.x > player.global_position.x:
					velocity.x = -150
				else:
					velocity.x = 150
		
		move_and_slide()
		
		if is_on_floor():
			if not Attack:
				if velocity.x != 0:
					sprite.play("Walk")
				else:
					sprite.play("Idle")
			elif Attack:
				if sprite.animation == "Attack1":
					if sprite.frame == 4:
						current_collisionShape.set_deferred("disabled", false)
				elif sprite.animation == "Attack2":
					if sprite.frame == 2:
						current_collisionShape.set_deferred("disabled", false)
				elif sprite.animation == "Attack3":
					if sprite.frame == 2:
						current_collisionShape.set_deferred("disabled", false)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation.begins_with("Attack"):
		Attack = false
		if player.got_hit:
			if sprite.animation == "Attack1" :
				player.health -= 1
			elif sprite.animation == "Attack2" :
				player.health -= 2
			elif sprite.animation == "Attack3" :
				player.health -= 3
			#sprite.play("Hurt")
			HUD.update_score_player(player.health)
			if player.health <= 0 :
				if not player.death: 
					player.Death()

func Death ():
	if death:
		return
	death = true
	if current_collisionShape:
		current_collisionShape.set_deferred("disabled", true)
	#await get_tree().create_timer(0.3).timeout
	#$Hurt_sound.play()
	await get_tree().create_timer(1).timeout
	sprite.play("Dead")
	PlayerDetectionarea_CollisionShape.set_deferred("disabled", true)
	hurtbox_CollisionShape.set_deferred("disabled", true)
	CollisionShape.set_deferred("disabled", true)
	await get_tree().create_timer(10).timeout
	HUD.show_game_over2()

func _on_player_detectionarea_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _on_hurtbox_area_entered(area: Area2D) -> void:
	#sprite.play("Hurt")
	health -= 10
	HUD.update_score_enemy(health)
	if health <= 0 :
		if not death:
			Death()

func start_attack():
	Attack = true
	
	current_attack = attackList.pick_random()
	sprite.play(current_attack)
	match current_attack:
		"Attack1":
			current_collisionShape = Attack1_hitbox_CollisionShape
			current_hitbox = Attack1_hitbox
		"Attack2":
			current_collisionShape = Attack2_hitbox_CollisionShape
			current_hitbox = Attack2_hitbox
		"Attack3":
			current_collisionShape = Attack3_hitbox_CollisionShape
			current_hitbox = Attack3_hitbox
