extends Control

signal textbox_closed

export(Resource) var enemy = null

var current_enemy_health = 0
var current_player_health = 0
var is_defending = false


func _ready():
	set_health($enemycontainer/healthBar, enemy.health, enemy.health)
	set_health($playerPanel/playerData/healthBar, State.current_health, State.max_health)
	$Enemy.texture = enemy.texture
	
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	
	$TextBox.hide()
	$actionPanel.hide()
	
	display_text("The %s appears!" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	$actionPanel.show()
	
func set_health(healthBar, health, max_health):
	healthBar.value = health
	healthBar.max_value = max_health
	healthBar.get_node("Label").text = "HP: %d/%d" % [health, max_health]
	


func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(BUTTON_LEFT)) and $TextBox.visible:
		$TextBox.hide()
		emit_signal("textbox_closed")
	
	
func display_text(text):
	$actionPanel.hide()
	$TextBox.show()
	$TextBox/Label.text = text


func _on_Run_pressed() -> void:
	display_text("You escaped from the enemy!")
	yield(self, "textbox_closed")
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().quit()
	
func enemy_turn():
	display_text("%s attacked you with its weapon!" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	
	if is_defending:
		is_defending = false
		
		$AnimationPlayer.play("mini_shake")
		yield($AnimationPlayer, "animation_finished")
		
		display_text("You defended succesfully!")
		yield(self, "textbox_closed")
	else:
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($playerPanel/playerData/healthBar, current_player_health, State.max_health)
		
		$AnimationPlayer.play("screen_shake")
		yield($AnimationPlayer, "animation_finished")

		display_text("%s dealth %d damage to the enemy!" % [enemy.name, enemy.damage])
		yield(self, "textbox_closed")

	$actionPanel.show()


func _on_Attack_pressed() -> void:
	display_text("You attacked the %s!" % enemy.name.to_upper())
	yield(self, "textbox_closed")
	
	current_enemy_health = max(0, current_enemy_health - State.player_damage)
	set_health($enemycontainer/healthBar, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	yield($AnimationPlayer, "animation_finished")
	
	display_text("You dealth %d damage to the enemy!" % State.player_damage)
	yield(self, "textbox_closed")
	
	if current_enemy_health == 0:
		display_text("You defeated the %s!" % enemy.name.to_upper())
		yield(self, "textbox_closed")
		
		$AnimationPlayer.play("enemy_death_anim")
		yield($AnimationPlayer, "animation_finished")
		
		yield(get_tree().create_timer(1.0), "timeout")
		get_tree().quit()
	enemy_turn()


func _on_Defend_pressed() -> void:
	is_defending = true
	
	
	display_text("You defended yourself!")
	yield(self, "textbox_closed")
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	enemy_turn()
	
	
	
