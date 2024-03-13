extends Node

signal start_game

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	await $MessageTimer.timeout
	$Message.hide()

func update_highest_score(highest_Score, score):
	$HighestScore.text = "Score: " + str(score) + "\nHighest score: " + str(highest_Score)

func show_game_over(highest_Score, score):
	update_highest_score(highest_Score, score)
	# Wait until the MessageTimer has counted down.
	$HighestScore.show()
	await get_tree().create_timer(0.5).timeout
	$Message.text = "Space:\n Feed the Snakey Sneak!"
	$Message.show()

func _on_start_button_pressed():
	$HighestScore.hide()
	$Message.hide()
	
	start_game.emit()




# Called when the node enters the scene tree for the first time.

