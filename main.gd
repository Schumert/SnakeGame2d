class_name main extends Node

var snake_parts = []
var _rotation_degree = 0
var score = 0

const SAVEFILE = "user://savefile.save"
var highest_score = 0



var is_game_over = true






func _input(event):
	if event.is_action_pressed("ui_right") and ($Snake.rotation_degrees != 180 ):
		_rotation_degree = 0
		

	elif event.is_action_pressed("ui_left") and ($Snake.rotation_degrees != 0 ):
		_rotation_degree = 180
		

	elif event.is_action_pressed("ui_up") and ($Snake.rotation_degrees != 90 ):
		_rotation_degree = 270
		
		
	elif event.is_action_pressed("ui_down") and ($Snake.rotation_degrees != 270):
		_rotation_degree = 90

	if event.is_action_pressed("ui_restart"):
		restart()
		

	if event.is_action_pressed("ui_accept") and is_game_over:
		$hud.show_message("Get Ready!")
		get_tree().call_group("snake_parts", "queue_free")
		snake_parts.clear()
		_grow_bigger()
		$Snake.position = Vector2(463, 495)
		$Snake.rotation = 0
		_rotation_degree = 0
		
		await get_tree().create_timer(0.5).timeout
		$hud._on_start_button_pressed() #triggers new_game

func new_game():
	score = 0
	update_score()
	is_game_over = false

	$Timer.start()
	
	
	
	

func hit(area:Node2D):
	if area.is_in_group("obstacles"):
		_game_over()


func _game_over():
	$Timer.stop()
	#get_tree().call_group("foods", "queue_free")
	$Timer.wait_time = 0.1
	#$Snake/CollisionShape2D.set_deferred("disabled", true)
	save_score()
	if score > highest_score:
		highest_score = score
		save_score()
	$hud.show_game_over(highest_score, score)

	await get_tree().create_timer(0.5).timeout
	is_game_over = true
	



func restart():
	if is_game_over == false:
		_game_over()


var body_part = preload("res://snake_parts.tscn")
func _grow_bigger():
	call_deferred("_grow_bigger_deferred")
func _grow_bigger_deferred():
	var instance_body_part = body_part.instantiate()
	
	var tail:Node2D
	if snake_parts.size() != 0:
		tail = snake_parts.back()
	else:
		tail = $Snake


	var rot = deg_to_rad(tail.rotation_degrees + 180)
	var dir = Vector2(cos(rot), sin(rot)) * 32
	var pos = tail.position + dir

	
	
	instance_body_part.add_to_group("obstacles")
	instance_body_part.position = pos
	snake_parts.append(instance_body_part)
	add_child(instance_body_part)




func snake_move():
	var snake_head = $Snake

	var snake_head_old_pos = snake_head.position

	$Snake.rotation_degrees = _rotation_degree
	snake_head.position += Vector2(1, 0).rotated(snake_head.rotation) * 32

	

	var last_tail = snake_parts.pop_back()
	last_tail.position = snake_head_old_pos
	snake_parts.push_front(last_tail)
	

var foods = []
func spawn_random_food():
	for n in $foods.get_child_count():
		foods.append($foods.get_child(n))
	var  random = randi() % foods.size()-1

	var food = foods[random].duplicate()
	var x_pos:float
	var y_pos:float
	var rng = RandomNumberGenerator.new()
	x_pos = rng.randf_range(2, 30) * 32 #64, 961
	y_pos = rng.randf_range(2, 20) * 32 # 54, 641
	food.position = Vector2(x_pos, y_pos)
	food.visible = true
	add_child(food)
	
func update_score():
	var string_score = str("Score: ", score)
	$CanvasLayer/score.text = string_score


func _gather(body:TileMap):
	if body.is_in_group("foods"):
		body.queue_free()
		
		if body.is_in_group("special_foods"):
			score+=1
			_grow_bigger()
		score+=1
		update_score()
		spawn_random_food()
		_grow_bigger()
		faster()

func faster():
	if $Timer.wait_time > 0.07:
		$Timer.wait_time -= 0.0003
	elif $Timer.wait_time > 0.05:
		$Timer.wait_time -= 0.0002


func save_score():
	var file = FileAccess.open(SAVEFILE, FileAccess.WRITE_READ)
	file.store_32(highest_score)

func load_score():
	var file = FileAccess.open(SAVEFILE, FileAccess.READ)
	if FileAccess.file_exists(SAVEFILE):
		highest_score = file.get_32()



# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_random_food()
	load_score()
	$hud.update_highest_score(highest_score, score)
	
	



