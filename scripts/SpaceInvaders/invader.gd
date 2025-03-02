extends Area2D

@onready var sprite = $Sprite2D  # Reference to the enemy sprite

func _ready():
	add_to_group("enemies")  # Ensures Game.gd can track all enemies

func _on_area_entered(area):
	# If hit by a bullet, destroy self
	if area.is_in_group("bullets"):
		var game_controller = get_tree().get_first_node_in_group("game_controller")
		game_controller.add_score(1)
		area.queue_free()  # Destroy bullet
		queue_free()  # Destroy enemy
		
