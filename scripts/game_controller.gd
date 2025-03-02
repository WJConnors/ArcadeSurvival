extends Node

var points_bar
var points_label

var score := 0  # 🔥 Store the player's score
var mult := 1

func _ready():
	add_to_group("game_controller")  # 🔥 Allows other nodes to find it
	var main_scene = get_tree().current_scene  # Get the root scene
	points_bar = main_scene.get_node("VBoxContainer/ProgressBar")
	points_label = main_scene.get_node("VBoxContainer/Label")
		
func add_score(amount: int):
	score += amount * mult
	points_bar.value = score
	
func game_lost():
	mult = 1

func game_switched():
	mult += 1
