extends CharacterBody2D

var player = null
var Attack = false
var health = 100
var hud
var death = false 
var attackList = ["Attack1", "Attack2", "Attack3"]
var current_attack
var current_collisionShape
var current_hitbox

func _ready() -> void:
	#player = null
	hud = $"../HUD"
	$Attack1_hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Attack2_hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Attack3_hitbox/CollisionShape2D.set_deferred("disabled", true)
	$Run_Attack_hitbox/CollisionShape2D.set_deferred("disabled", true)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		#var distance = global_position.distance_to(player.global_position)
			#print(distance)
	#if player == null:
		#return
	
	if not Attack:
		#$Attack2_hitbox/CollisionShape2D.set_deferred("disabled", true)
		if current_collisionShape:
			current_collisionShape.set_deferred("disabled", true)
#
	if not death:
		#print(player)
		if player and player.health > 0:
			#print(player.got_hit)
			var dis = player.global_position
			var distance = dis.x
			var diff = abs(dis.x - position.x)
			#print(player.global_position)
			#print("player: ",distance)
			#print("Enemy: ",position)
			if position.x > player.global_position.x:
				if not $AnimatedSprite2D.flip_h:
					$AnimatedSprite2D.flip_h = true
					
			else:
				$AnimatedSprite2D.flip_h = false
		#
			if diff < 160 and !Attack:
				#print("Attack2"
				#print("1st block",distance)
				velocity.x = 0
				#Attack = true
				start_attack()
				#$hitBox/CollisionShape2D.set_deferred("disabled", false)
				#$Attack2_sound.play()
				if $AnimatedSprite2D.flip_h:
					#print(current_collisionShape.position.x)
					if current_hitbox.position.x > 0:
						current_hitbox.position.x *= -1
				elif not $AnimatedSprite2D.flip_h:
					if current_hitbox.position.x < 0:
						current_hitbox.position.x *= -1
			elif diff < 250:
				#print("Stand Ready")
				#print("2nd block",distance)
				velocity.x = 0
				#Attack = false
			elif diff < 600:
				#print("last block", distance)
				#print("Walk to Player")
				#Attack = false
				if position.x > player.global_position.x:
					velocity.x = -150
					pass
				else:
					velocity.x = 150
					pass
			else:
				pass
				#Attack = false
			
		move_and_slide()
		
		if is_on_floor():
			if Attack:
				pass
				#if $AnimatedSprite2D.animation != "Attack2":
				#print("Attack2 is: ", Attack2)
				#if !$Attack2_sound.playing:
					#$Attack2_sound.play()
				#random_attack = attackList.pick_random()
				#$AnimatedSprite2D.play(current_attack)
				#if $AnimatedSprite2D.frame == 2:
				#$random_attack/CollisionShape2D.set_deferred("disabled", false)
				#get_node(current_attack + "_hitbox").get_node("CollisionShape2D").set_deferred("disabled", false)
			else:
				if velocity.x != 0:
					$AnimatedSprite2D.play("Walk")
				else:
					$AnimatedSprite2D.play("Idle")
	


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation.begins_with("Attack"):
		Attack = false
		if player.got_hit:
			if $AnimatedSprite2D.animation == "Attack1" :
				player.health -= 1
			elif $AnimatedSprite2D.animation == "Attack2" :
				player.health -= 2
			elif $AnimatedSprite2D.animation == "Attack3" :
				player.health -= 3
			#$AnimatedSprite2D.play("Hurt")
			hud.update_score_player(player.health)
			if player.health <= 0 :
				if not player.death: 
					player.Death()
	
func Death ():
	death = true
	current_collisionShape.set_deferred("disabled", true)
	#await get_tree().create_timer(0.3).timeout
	#$Hurt_sound.play()
	await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.play("Dead")
	$PlayerDetectionarea/CollisionShape2D.set_deferred("disabled", true)
	$hurtbox/CollisionShape2D.set_deferred("disabled", true)
	
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(10).timeout
	hud.show_game_over2()


func _on_player_detectionarea_body_entered(body: Node2D) -> void:
	#print(body.name)
	#print(body.get_groups())
	if body.is_in_group("player"):
		player = body


func _on_hurtbox_area_entered(area: Area2D) -> void:
	#$AnimatedSprite2D.play("Hurt")
	health -= 10
	hud.update_score_enemy(health)
	if health <= 0 :
		if not death: 
			Death()

func start_attack():
	Attack = true
	
	current_attack = attackList.pick_random()
	$AnimatedSprite2D.play(current_attack)
	current_collisionShape = get_node(current_attack + "_hitbox/CollisionShape2D")
	current_hitbox = get_node(current_attack + "_hitbox")
	current_collisionShape.set_deferred("disabled", false)
	print(current_collisionShape)
	print(current_hitbox)
	print(current_attack + "_hitbox")
