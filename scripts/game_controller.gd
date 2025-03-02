extends Node

var score := 0  # 🔥 Store the player's score

func _ready():
	add_to_group("game_controller")  # 🔥 Allows other nodes to find it

func add_score(amount: int):
	score += amount
