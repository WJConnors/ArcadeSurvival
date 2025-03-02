extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("player"):  # Check if the player collects it
		var game_controller = get_tree().get_first_node_in_group("game_controller")
		game_controller.add_score(3)
		queue_free()  # Remove the point pickup
