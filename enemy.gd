extends CharacterBody2D

var player = null
var punch = false
var health = 100
var hud
var death = false 

func _ready() -> void:
	#player = null
	hud = $"../HUD"
	$hitBox/CollisionShape2D.set_deferred("disabled", true)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
		#var distance = global_position.distance_to(player.global_position)
			#print(distance)
	#if player == null:
		#return
	
	if not punch:
		$hitBox/CollisionShape2D.set_deferred("disabled", true)
#
	if not death:
		#print(player)
		if player and player.health > 0:
			var distance = global_position.distance_to(player.global_position)
			#print(distance)
			if position.x > player.global_position.x:
				if $AnimatedSprite2D.flip_h:
					$AnimatedSprite2D.flip_h = false
					
			else:
				$AnimatedSprite2D.flip_h = true
		#
			if distance < 160:
				#print("Punch"
				velocity.x = 0
				punch = true
				#$hitBox/CollisionShape2D.set_deferred("disabled", false)
				#$Punch_sound.play()
				if $AnimatedSprite2D.flip_h:
					if $hitBox.position.x < 0:
						$hitBox.position.x *= -1
				elif not $AnimatedSprite2D.flip_h:
					if $hitBox.position.x > 0:
						$hitBox.position.x *= -1
			elif distance < 250:
				#print("Stand Ready")
				velocity.x = 0
				punch = false
			elif distance < 600:
				#print("Walk to Player")
				punch = false
				if position.x > player.global_position.x:
					velocity.x = -150
				else:
					velocity.x = 150
			else:
				punch = false
			
		move_and_slide()
		
		if is_on_floor():
			if punch:
				#if $AnimatedSprite2D.animation != "Punch":
				#print("punch is: ", punch)
				if !$Punch_sound.playing:
					$Punch_sound.play()
				$AnimatedSprite2D.play("Punch")
				if $AnimatedSprite2D.frame == 2:
					$hitBox/CollisionShape2D.set_deferred("disabled", false)
			else:
				if velocity.x != 0:
					$AnimatedSprite2D.play("Walk")
				else:
					$AnimatedSprite2D.play("Idle")
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	print(body.get_groups())
	if body.is_in_group("player"):
		player = body


func _on_animated_sprite_2d_animation_finished() -> void:
	
	if $AnimatedSprite2D.animation == "Punch":
		punch = false
		#print("punch is: ", punch)if player.got_hit:
		if player.got_hit:
			player.health -= 10
			#$AnimatedSprite2D.play("Hurt")
			hud.update_score_player(player.health)
			if player.health <= 0 :
				if not player.death: 
					player.Death()
		$hitBox/CollisionShape2D.disabled = true
		


func _on_hurt_box_area_entered(area: Area2D) -> void:
	#$AnimatedSprite2D.play("Hurt")
	health -= 10
	hud.update_score_enemy(health)
	if health <= 0 :
		if not death: 
			Death()
	
func Death ():
	death = true
	$hitBox/CollisionShape2D.set_deferred("disabled", true)
	#await get_tree().create_timer(0.3).timeout
	$Hurt_sound.play()
	await get_tree().create_timer(1).timeout
	$AnimatedSprite2D.play("Death")
	$playerDetectionArea/CollisionShape2D.set_deferred("disabled", true)
	$hurtBox/CollisionShape2D.set_deferred("disabled", true)
	$body.set_deferred("disabled", true)
	$head.set_deferred("disabled", true)
	await get_tree().create_timer(10).timeout
	hud.show_game_over()
