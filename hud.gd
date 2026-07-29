extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Game_over.hide()
	$player_bar.max_value = 100
	$player_bar.value = 100
	$Enemy_health_bar.max_value = 100
	$Enemy_health_bar.value = 100


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_score_enemy(score):
	$Enemy_health_bar.value = score
	
func update_score_player(score):
	$player_bar.value = score

	
	
func show_game_over():
	$Game_over.text = "GAME OVER"
	$Game_over.show()
	get_tree().change_scene_to_file("res://level2.tscn")
	
func show_game_over2():
	$Game_over.text = "GAME OVER"
	$Game_over.show()
