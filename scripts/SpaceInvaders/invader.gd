extends Area2D

@onready var sprite = $Sprite2D  # Reference to the enemy sprite

func _ready():
	add_to_group("enemies")  # Ensures Game.gd can track all enemies

func _on_area_entered(area):
	# If hit by a bullet, destroy self
	if area.is_in_group("bullets"):
		queue_free()  # Destroy enemy
		area.queue_free()  # Destroy bullet
